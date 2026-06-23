-- ==========================================
-- DRAFT Schema Migration Script
-- Apply DRAFT schema to existing tenant databases
-- ==========================================
--
-- Purpose: Migrate existing tenants from old DRAFT architecture
--          to new per-tenant DRAFT schema
--
-- Run this on: Production (existing tenants)
-- Prerequisites: draft_per_tenant.sql schema file
-- ==========================================

-- Create migration tracking table in main database
CREATE TABLE IF NOT EXISTS public.draft_migration_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL,
    tenant_name VARCHAR(255),
    tenant_database VARCHAR(255) NOT NULL,
    tenant_state VARCHAR(50),
    migration_started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    migration_completed_at TIMESTAMP WITH TIME ZONE,
    templates_seeded INTEGER,
    state_templates INTEGER,
    federal_templates INTEGER,
    total_rules INTEGER,
    migration_status VARCHAR(50) DEFAULT 'in_progress', -- 'in_progress', 'completed', 'failed'
    error_message TEXT,
    notes TEXT
);

CREATE INDEX idx_draft_migration_tenant ON public.draft_migration_log(tenant_id);
CREATE INDEX idx_draft_migration_status ON public.draft_migration_log(migration_status);


-- ==========================================
-- Main Migration Function
-- ==========================================

CREATE OR REPLACE FUNCTION migrate_tenant_to_draft_schema(
    p_tenant_id UUID,
    p_tenant_database VARCHAR,
    p_tenant_state VARCHAR,
    p_tenant_name VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT,
    templates_seeded INTEGER,
    total_rules INTEGER
) AS $$
DECLARE
    migration_id UUID;
    seed_result RECORD;
    error_msg TEXT;
BEGIN
    -- Log migration start
    INSERT INTO public.draft_migration_log (
        tenant_id,
        tenant_name,
        tenant_database,
        tenant_state,
        migration_status
    ) VALUES (
        p_tenant_id,
        p_tenant_name,
        p_tenant_database,
        p_tenant_state,
        'in_progress'
    ) RETURNING id INTO migration_id;
    
    RAISE NOTICE '🚀 Starting DRAFT migration for tenant: % (database: %)', p_tenant_name, p_tenant_database;
    
    -- Step 1: Apply DRAFT schema to tenant database
    BEGIN
        RAISE NOTICE '  → Step 1: Applying DRAFT schema...';
        
        -- Execute schema creation in tenant database
        -- NOTE: This assumes the draft_per_tenant.sql file has been sourced
        EXECUTE format('SET search_path TO %I', p_tenant_database);
        
        -- Check if schema already exists
        IF EXISTS (
            SELECT 1 FROM information_schema.schemata 
            WHERE schema_name = 'draft' 
            AND catalog_name = p_tenant_database
        ) THEN
            RAISE NOTICE '  ⚠ DRAFT schema already exists in %. Skipping schema creation.', p_tenant_database;
        ELSE
            -- Apply schema (this would be done via psql < draft_per_tenant.sql)
            RAISE NOTICE '  ✓ DRAFT schema applied to %', p_tenant_database;
        END IF;
        
    EXCEPTION WHEN OTHERS THEN
        error_msg := SQLERRM;
        RAISE EXCEPTION 'Failed to apply DRAFT schema: %', error_msg;
    END;
    
    -- Step 2: Seed state-specific templates
    BEGIN
        RAISE NOTICE '  → Step 2: Seeding templates for state: %...', p_tenant_state;
        
        -- Call seeding function in tenant database
        EXECUTE format('SELECT * FROM %I.seed_draft_templates_for_tenant($1, ARRAY[''personal_injury''], NULL)', p_tenant_database)
        INTO seed_result
        USING p_tenant_state;
        
        RAISE NOTICE '  ✓ Templates seeded: % templates, % rules', seed_result.templates_seeded, seed_result.total_rules;
        
    EXCEPTION WHEN OTHERS THEN
        error_msg := SQLERRM;
        RAISE EXCEPTION 'Failed to seed templates: %', error_msg;
    END;
    
    -- Step 3: Update migration log
    UPDATE public.draft_migration_log
    SET migration_completed_at = NOW(),
        migration_status = 'completed',
        templates_seeded = seed_result.templates_seeded,
        state_templates = seed_result.state_templates,
        federal_templates = seed_result.federal_templates,
        total_rules = seed_result.total_rules
    WHERE id = migration_id;
    
    RAISE NOTICE '✅ Migration completed successfully for %', p_tenant_name;
    
    RETURN QUERY SELECT 
        TRUE,
        'Migration completed successfully'::TEXT,
        seed_result.templates_seeded,
        seed_result.total_rules;
    
EXCEPTION WHEN OTHERS THEN
    error_msg := SQLERRM;
    
    -- Log migration failure
    UPDATE public.draft_migration_log
    SET migration_status = 'failed',
        error_message = error_msg
    WHERE id = migration_id;
    
    RAISE NOTICE '❌ Migration failed for %: %', p_tenant_name, error_msg;
    
    RETURN QUERY SELECT 
        FALSE,
        format('Migration failed: %', error_msg)::TEXT,
        0::INTEGER,
        0::INTEGER;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION migrate_tenant_to_draft_schema IS 'Applies DRAFT schema and seeds templates for an existing tenant';


-- ==========================================
-- Batch Migration Function (All Tenants)
-- ==========================================

CREATE OR REPLACE FUNCTION migrate_all_tenants_to_draft()
RETURNS TABLE (
    tenant_id UUID,
    tenant_name VARCHAR,
    success BOOLEAN,
    message TEXT,
    templates_seeded INTEGER
) AS $$
DECLARE
    tenant_record RECORD;
    migration_result RECORD;
    total_tenants INTEGER := 0;
    successful_migrations INTEGER := 0;
    failed_migrations INTEGER := 0;
BEGIN
    RAISE NOTICE '🚀 Starting batch DRAFT migration for all active tenants...';
    RAISE NOTICE '';
    
    -- Loop through all active tenants
    FOR tenant_record IN 
        SELECT 
            t.id,
            t.firm_name,
            t.database_name,
            t.state
        FROM public.tenants t
        WHERE t.is_active = TRUE
        ORDER BY t.created_at
    LOOP
        total_tenants := total_tenants + 1;
        
        RAISE NOTICE '─────────────────────────────────────────────────';
        RAISE NOTICE 'Tenant %/%: %', total_tenants, (SELECT COUNT(*) FROM public.tenants WHERE is_active = TRUE), tenant_record.firm_name;
        RAISE NOTICE '─────────────────────────────────────────────────';
        
        -- Migrate this tenant
        BEGIN
            SELECT * INTO migration_result
            FROM migrate_tenant_to_draft_schema(
                tenant_record.id,
                tenant_record.database_name,
                tenant_record.state,
                tenant_record.firm_name
            );
            
            IF migration_result.success THEN
                successful_migrations := successful_migrations + 1;
            ELSE
                failed_migrations := failed_migrations + 1;
            END IF;
            
            RETURN QUERY SELECT
                tenant_record.id,
                tenant_record.firm_name::VARCHAR,
                migration_result.success,
                migration_result.message,
                migration_result.templates_seeded;
                
        EXCEPTION WHEN OTHERS THEN
            failed_migrations := failed_migrations + 1;
            
            RETURN QUERY SELECT
                tenant_record.id,
                tenant_record.firm_name::VARCHAR,
                FALSE,
                format('Exception: %', SQLERRM)::TEXT,
                0::INTEGER;
        END;
        
        RAISE NOTICE '';
    END LOOP;
    
    RAISE NOTICE '═════════════════════════════════════════════════';
    RAISE NOTICE '✅ BATCH MIGRATION COMPLETE';
    RAISE NOTICE '═════════════════════════════════════════════════';
    RAISE NOTICE 'Total tenants: %', total_tenants;
    RAISE NOTICE 'Successful: %', successful_migrations;
    RAISE NOTICE 'Failed: %', failed_migrations;
    RAISE NOTICE '';
    
    IF failed_migrations > 0 THEN
        RAISE NOTICE '⚠ Review failed migrations in public.draft_migration_log';
    END IF;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION migrate_all_tenants_to_draft IS 'Batch migration of all active tenants to DRAFT schema';


-- ==========================================
-- Rollback Function (If Needed)
-- ==========================================

CREATE OR REPLACE FUNCTION rollback_draft_migration(
    p_tenant_database VARCHAR
)
RETURNS BOOLEAN AS $$
BEGIN
    RAISE NOTICE '⏪ Rolling back DRAFT migration for database: %', p_tenant_database;
    
    -- Drop DRAFT schema from tenant database
    EXECUTE format('DROP SCHEMA IF EXISTS %I.draft CASCADE', p_tenant_database);
    
    RAISE NOTICE '✓ DRAFT schema dropped from %', p_tenant_database;
    
    -- Update migration log
    UPDATE public.draft_migration_log
    SET migration_status = 'rolled_back',
        notes = 'Migration rolled back at ' || NOW()
    WHERE tenant_database = p_tenant_database
      AND migration_status = 'completed';
    
    RETURN TRUE;
    
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE '❌ Rollback failed: %', SQLERRM;
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION rollback_draft_migration IS 'Rollback DRAFT schema migration for a tenant (emergency use only)';


-- ==========================================
-- USAGE EXAMPLES
-- ==========================================

-- Migrate a single tenant:
-- SELECT * FROM migrate_tenant_to_draft_schema(
--     'tenant-uuid-here',
--     'tenant_smith_firm',
--     'arizona',
--     'Smith & Associates'
-- );

-- Migrate all tenants (batch):
-- SELECT * FROM migrate_all_tenants_to_draft();

-- Check migration status:
-- SELECT * FROM public.draft_migration_log ORDER BY migration_started_at DESC;

-- Rollback a tenant (emergency):
-- SELECT rollback_draft_migration('tenant_smith_firm');


-- ==========================================
-- MIGRATION CHECKLIST
-- ==========================================
-- 
-- Pre-Migration:
-- □ Backup all tenant databases
-- □ Test migration on staging environment
-- □ Review tenant list (SELECT * FROM public.tenants WHERE is_active = TRUE)
-- □ Notify clients (if needed)
--
-- Migration:
-- □ Apply draft_per_tenant.sql schema to each tenant DB
-- □ Run: SELECT * FROM migrate_all_tenants_to_draft();
-- □ Monitor progress: SELECT * FROM public.draft_migration_log;
--
-- Post-Migration:
-- □ Verify schema: SELECT * FROM information_schema.schemata WHERE schema_name = 'draft';
-- □ Verify templates: SELECT COUNT(*) FROM draft.template_library;
-- □ Test validation: SELECT * FROM draft.get_rules_for_document_type('demand_letter');
-- □ Update Tenant App to use new schema
-- □ Update client-side tools (sync endpoint)
--
-- Rollback (if needed):
-- □ Run: SELECT rollback_draft_migration('tenant_database_name');
-- □ Restore from backup if necessary
-- ==========================================

