-- =====================================================
-- TrueVow DRAFT Service - Row Level Security (RLS) Policies
-- Migration: 999_rls_policies_draft_service
-- Created: 2026-01-09
-- =====================================================
-- 
-- SCOPE: RLS policies for DRAFT service tables
-- - Validation rules (global templates + tenant-specific)
-- - Validation analytics (tenant-isolated)
-- - Template inheritance
-- 
-- ARCHITECTURE:
-- - Uses Clerk for authentication (not Supabase Auth)
-- - Application code handles authorization
-- - RLS policies serve as defense-in-depth
-- - Service role used for database operations
-- =====================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- HELPER FUNCTIONS FOR CLERK AUTHENTICATION
-- =====================================================

-- Get current Clerk user ID from session variable
CREATE OR REPLACE FUNCTION get_current_clerk_user_id()
RETURNS TEXT AS $$
BEGIN
    RETURN current_setting('app.current_clerk_user_id', true);
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Check if user is a team member (for tenant access)
CREATE OR REPLACE FUNCTION is_team_member(tenant_id_param UUID)
RETURNS BOOLEAN AS $$
DECLARE
    clerk_user_id TEXT;
BEGIN
    clerk_user_id := get_current_clerk_user_id();
    
    -- If no Clerk user ID set, deny access (service role bypasses this)
    IF clerk_user_id IS NULL THEN
        RETURN FALSE;
    END IF;
    
    -- Check if user is a member of the tenant's team
    -- This would query your team_members table
    -- For now, we'll use a placeholder that checks tenant_id
    -- In production, you'd join with your team_members table
    RETURN EXISTS (
        SELECT 1
        FROM team_members tm
        WHERE tm.tenant_id = tenant_id_param
        AND tm.clerk_user_id = clerk_user_id
        AND tm.is_active = TRUE
    );
EXCEPTION
    WHEN OTHERS THEN
        RETURN FALSE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Get current user's role
CREATE OR REPLACE FUNCTION get_current_user_role(tenant_id_param UUID)
RETURNS TEXT AS $$
DECLARE
    clerk_user_id TEXT;
    user_role TEXT;
BEGIN
    clerk_user_id := get_current_clerk_user_id();
    
    IF clerk_user_id IS NULL THEN
        RETURN NULL;
    END IF;
    
    SELECT tm.role INTO user_role
    FROM team_members tm
    WHERE tm.tenant_id = tenant_id_param
    AND tm.clerk_user_id = clerk_user_id
    AND tm.is_active = TRUE
    LIMIT 1;
    
    RETURN user_role;
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Check if user has specific role
CREATE OR REPLACE FUNCTION has_role(tenant_id_param UUID, required_role TEXT)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN get_current_user_role(tenant_id_param) = required_role;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Check if user has any of the specified roles
CREATE OR REPLACE FUNCTION has_any_role(tenant_id_param UUID, roles TEXT[])
RETURNS BOOLEAN AS $$
DECLARE
    user_role TEXT;
BEGIN
    user_role := get_current_user_role(tenant_id_param);
    RETURN user_role = ANY(roles);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Check if user is admin
CREATE OR REPLACE FUNCTION is_admin(tenant_id_param UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN has_role(tenant_id_param, 'admin');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Check if user is SaaS Admin (global admin, not tenant-specific)
CREATE OR REPLACE FUNCTION is_saas_admin()
RETURNS BOOLEAN AS $$
DECLARE
    clerk_user_id TEXT;
BEGIN
    clerk_user_id := get_current_clerk_user_id();
    
    IF clerk_user_id IS NULL THEN
        RETURN FALSE;
    END IF;
    
    -- Check if user is a SaaS admin (in a special admin tenant or admin_users table)
    -- This is a placeholder - adjust based on your admin structure
    RETURN EXISTS (
        SELECT 1
        FROM admin_users au
        WHERE au.clerk_user_id = clerk_user_id
        AND au.is_active = TRUE
    );
EXCEPTION
    WHEN OTHERS THEN
        RETURN FALSE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Set Clerk user ID for RLS (called from application code)
CREATE OR REPLACE FUNCTION set_current_clerk_user_id(clerk_user_id TEXT)
RETURNS VOID AS $$
BEGIN
    PERFORM set_config('app.current_clerk_user_id', clerk_user_id, false);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- ENABLE RLS ON ALL TABLES
-- =====================================================

-- Validation Rules Table (in draft schema)
ALTER TABLE draft.validation_rules ENABLE ROW LEVEL SECURITY;

-- Validation Analytics Table (in draft schema)
ALTER TABLE draft.validation_analytics ENABLE ROW LEVEL SECURITY;

-- Templates Table (in draft schema)
ALTER TABLE draft.templates ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- RLS POLICIES - VALIDATION RULES
-- =====================================================

-- Policy: Global templates are readable by all authenticated users
-- (Templates have tenant_id = NULL, is_template = TRUE)
DROP POLICY IF EXISTS validation_rules_global_templates_read ON draft.validation_rules;
CREATE POLICY validation_rules_global_templates_read ON draft.validation_rules
    FOR SELECT
    USING (
        is_template = TRUE 
        AND tenant_id IS NULL
    );

-- Policy: SaaS Admin can manage global templates
DROP POLICY IF EXISTS validation_rules_global_templates_admin ON draft.validation_rules;
CREATE POLICY validation_rules_global_templates_admin ON draft.validation_rules
    FOR ALL
    USING (
        is_template = TRUE 
        AND tenant_id IS NULL
        AND is_saas_admin()
    )
    WITH CHECK (
        is_template = TRUE 
        AND tenant_id IS NULL
        AND is_saas_admin()
    );

-- Policy: Team members can read their tenant's rules
DROP POLICY IF EXISTS validation_rules_tenant_read ON draft.validation_rules;
CREATE POLICY validation_rules_tenant_read ON draft.validation_rules
    FOR SELECT
    USING (
        is_template = FALSE
        AND tenant_id IS NOT NULL
        AND is_team_member(tenant_id)
    );

-- Policy: Team members can create tenant-specific rules
DROP POLICY IF EXISTS validation_rules_tenant_create ON draft.validation_rules;
CREATE POLICY validation_rules_tenant_create ON draft.validation_rules
    FOR INSERT
    WITH CHECK (
        is_template = FALSE
        AND tenant_id IS NOT NULL
        AND is_team_member(tenant_id)
    );

-- Policy: Team admins can update their tenant's rules
DROP POLICY IF EXISTS validation_rules_tenant_update ON draft.validation_rules;
CREATE POLICY validation_rules_tenant_update ON draft.validation_rules
    FOR UPDATE
    USING (
        is_template = FALSE
        AND tenant_id IS NOT NULL
        AND is_team_member(tenant_id)
        AND (is_admin(tenant_id) OR has_any_role(tenant_id, ARRAY['admin', 'manager']))
    )
    WITH CHECK (
        is_template = FALSE
        AND tenant_id IS NOT NULL
        AND is_team_member(tenant_id)
        AND (is_admin(tenant_id) OR has_any_role(tenant_id, ARRAY['admin', 'manager']))
    );

-- Policy: Team admins can delete their tenant's rules
DROP POLICY IF EXISTS validation_rules_tenant_delete ON draft.validation_rules;
CREATE POLICY validation_rules_tenant_delete ON draft.validation_rules
    FOR DELETE
    USING (
        is_template = FALSE
        AND tenant_id IS NOT NULL
        AND is_team_member(tenant_id)
        AND (is_admin(tenant_id) OR has_any_role(tenant_id, ARRAY['admin', 'manager']))
    );

-- =====================================================
-- RLS POLICIES - VALIDATION ANALYTICS
-- =====================================================

-- Policy: Team members can read their tenant's analytics
DROP POLICY IF EXISTS validation_analytics_tenant_read ON draft.validation_analytics;
CREATE POLICY validation_analytics_tenant_read ON draft.validation_analytics
    FOR SELECT
    USING (
        tenant_id IS NOT NULL
        AND is_team_member(tenant_id)
    );

-- Policy: Team members can create analytics records for their tenant
DROP POLICY IF EXISTS validation_analytics_tenant_create ON draft.validation_analytics;
CREATE POLICY validation_analytics_tenant_create ON draft.validation_analytics
    FOR INSERT
    WITH CHECK (
        tenant_id IS NOT NULL
        AND is_team_member(tenant_id)
    );

-- Policy: SaaS Admin can read all analytics (for compliance reports)
DROP POLICY IF EXISTS validation_analytics_admin_read ON draft.validation_analytics;
CREATE POLICY validation_analytics_admin_read ON draft.validation_analytics
    FOR SELECT
    USING (is_saas_admin());

-- Policy: Analytics records are immutable (no updates/deletes)
-- This enforces audit trail integrity

-- =====================================================
-- COMMENTS
-- =====================================================

COMMENT ON FUNCTION get_current_clerk_user_id() IS 'Gets Clerk user ID from session variable for RLS';
COMMENT ON FUNCTION is_team_member(UUID) IS 'Checks if current user is a team member of the specified tenant';
COMMENT ON FUNCTION get_current_user_role(UUID) IS 'Gets current user role for a tenant';
COMMENT ON FUNCTION has_role(UUID, TEXT) IS 'Checks if user has specific role';
COMMENT ON FUNCTION has_any_role(UUID, TEXT[]) IS 'Checks if user has any of the specified roles';
COMMENT ON FUNCTION is_admin(UUID) IS 'Checks if user is admin for a tenant';
COMMENT ON FUNCTION is_saas_admin() IS 'Checks if user is SaaS admin (global)';
COMMENT ON FUNCTION set_current_clerk_user_id(TEXT) IS 'Sets Clerk user ID in session for RLS (called from app code)';

COMMENT ON POLICY validation_rules_global_templates_read ON draft.validation_rules IS 'All authenticated users can read global templates';
COMMENT ON POLICY validation_rules_global_templates_admin ON draft.validation_rules IS 'SaaS Admin can manage global templates';
COMMENT ON POLICY validation_rules_tenant_read ON draft.validation_rules IS 'Team members can read their tenant rules';
COMMENT ON POLICY validation_rules_tenant_create ON draft.validation_rules IS 'Team members can create tenant rules';
COMMENT ON POLICY validation_rules_tenant_update ON draft.validation_rules IS 'Team admins can update tenant rules';
COMMENT ON POLICY validation_rules_tenant_delete ON draft.validation_rules IS 'Team admins can delete tenant rules';

COMMENT ON POLICY validation_analytics_tenant_read ON draft.validation_analytics IS 'Team members can read their tenant analytics';
COMMENT ON POLICY validation_analytics_tenant_create ON draft.validation_analytics IS 'Team members can create analytics records';
COMMENT ON POLICY validation_analytics_admin_read ON draft.validation_analytics IS 'SaaS Admin can read all analytics for compliance';

-- =====================================================
-- RLS POLICIES - TEMPLATES
-- =====================================================

-- Policy: Team members can read their tenant's templates
DROP POLICY IF EXISTS templates_tenant_read ON draft.templates;
CREATE POLICY templates_tenant_read ON draft.templates
    FOR SELECT
    USING (
        tenant_id IS NOT NULL
        AND is_team_member(tenant_id)
    );

-- Policy: Team members can read public templates
DROP POLICY IF EXISTS templates_public_read ON draft.templates;
CREATE POLICY templates_public_read ON draft.templates
    FOR SELECT
    USING (is_public = TRUE);

-- Policy: Team members can create templates for their tenant
DROP POLICY IF EXISTS templates_tenant_create ON draft.templates;
CREATE POLICY templates_tenant_create ON draft.templates
    FOR INSERT
    WITH CHECK (
        tenant_id IS NOT NULL
        AND is_team_member(tenant_id)
    );

-- Policy: Team admins can update their tenant's templates
DROP POLICY IF EXISTS templates_tenant_update ON draft.templates;
CREATE POLICY templates_tenant_update ON draft.templates
    FOR UPDATE
    USING (
        tenant_id IS NOT NULL
        AND is_team_member(tenant_id)
        AND (is_admin(tenant_id) OR has_any_role(tenant_id, ARRAY['admin', 'manager']))
    )
    WITH CHECK (
        tenant_id IS NOT NULL
        AND is_team_member(tenant_id)
        AND (is_admin(tenant_id) OR has_any_role(tenant_id, ARRAY['admin', 'manager']))
    );

-- Policy: Team admins can delete their tenant's templates
DROP POLICY IF EXISTS templates_tenant_delete ON draft.templates;
CREATE POLICY templates_tenant_delete ON draft.templates
    FOR DELETE
    USING (
        tenant_id IS NOT NULL
        AND is_team_member(tenant_id)
        AND (is_admin(tenant_id) OR has_any_role(tenant_id, ARRAY['admin', 'manager']))
    );

COMMENT ON POLICY templates_tenant_read ON draft.templates IS 'Team members can read their tenant templates';
COMMENT ON POLICY templates_public_read ON draft.templates IS 'All users can read public templates';
COMMENT ON POLICY templates_tenant_create ON draft.templates IS 'Team members can create tenant templates';
COMMENT ON POLICY templates_tenant_update ON draft.templates IS 'Team admins can update tenant templates';
COMMENT ON POLICY templates_tenant_delete ON draft.templates IS 'Team admins can delete tenant templates';
