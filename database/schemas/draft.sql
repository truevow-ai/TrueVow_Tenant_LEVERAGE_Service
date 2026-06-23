-- ============================================================================
-- TrueVow DRAFT™ Service - Database Schema
-- ============================================================================
-- Version: 1.0.0
-- Last Updated: December 8, 2025
-- Description: Centralized database schema for DRAFT compliance validation service
--
-- ZERO-KNOWLEDGE ARCHITECTURE:
-- - NO document content storage (documents never uploaded)
-- - NO client data storage (PII/PHI never stored)
-- - ONLY validation rules, templates, and metadata (no content)
-- ============================================================================

-- Create draft schema
CREATE SCHEMA IF NOT EXISTS draft;

-- Set search path
SET search_path TO draft, public;

-- ============================================================================
-- TABLE 1: VALIDATION RULES LIBRARY
-- ============================================================================
-- Stores validation rules for 5-level hierarchical validator system
-- Synced to client devices (encrypted) for local validation
-- ============================================================================

CREATE TABLE IF NOT EXISTS draft.validation_rules (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Validator Hierarchy (5 levels)
    validator_level INTEGER NOT NULL CHECK (validator_level BETWEEN 1 AND 5),
    validator_name VARCHAR(100) NOT NULL,
    
    -- Level 1: Universal Validators (ALL documents)
    -- Level 2: Practice Area Validators
    practice_area VARCHAR(100),  -- personal_injury, family_law, criminal_law, etc.
    
    -- Level 3: Specialization Validators
    specialization VARCHAR(100),  -- car_accident, medical_malpractice, divorce, etc.
    
    -- Level 4: Document Type Validators
    document_type VARCHAR(100),  -- demand_letter, pleading, contract, etc.
    
    -- Level 5: Jurisdiction Validators
    jurisdiction_state VARCHAR(2),    -- US state code (AZ, CA, NY, etc.)
    jurisdiction_county VARCHAR(100), -- County name
    jurisdiction_court VARCHAR(200),  -- Court name/type
    
    -- Validator Configuration
    validator_config JSONB NOT NULL DEFAULT '{}',  -- Validator-specific configuration
    
    -- Validation Messages
    error_message TEXT,    -- Error message if validation fails
    warning_message TEXT,  -- Warning message if validation has issues
    info_message TEXT,     -- Informational message
    
    -- Validation Severity
    severity VARCHAR(20) NOT NULL DEFAULT 'error' CHECK (severity IN ('error', 'warning', 'info')),
    
    -- Status & Metadata
    is_active BOOLEAN NOT NULL DEFAULT true,
    is_required BOOLEAN NOT NULL DEFAULT true,  -- Required for document completion
    version INTEGER NOT NULL DEFAULT 1,
    
    -- Rule Dependencies (optional)
    depends_on_rule_ids UUID[],  -- Array of rule IDs this rule depends on
    
    -- Administrative
    created_by UUID,  -- SaaS Admin user who created rule
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    archived_at TIMESTAMP WITH TIME ZONE,
    
    -- Notes
    notes TEXT,  -- Internal notes for SaaS Admin
    
    -- Indexes will be created below
    CONSTRAINT unique_validator_combination UNIQUE (
        validator_level, 
        validator_name, 
        COALESCE(practice_area, ''), 
        COALESCE(specialization, ''),
        COALESCE(document_type, ''),
        COALESCE(jurisdiction_state, ''),
        COALESCE(jurisdiction_county, '')
    )
);

-- Indexes for validation_rules
CREATE INDEX idx_validation_rules_level ON draft.validation_rules(validator_level);
CREATE INDEX idx_validation_rules_practice_area ON draft.validation_rules(practice_area) WHERE practice_area IS NOT NULL;
CREATE INDEX idx_validation_rules_specialization ON draft.validation_rules(specialization) WHERE specialization IS NOT NULL;
CREATE INDEX idx_validation_rules_document_type ON draft.validation_rules(document_type) WHERE document_type IS NOT NULL;
CREATE INDEX idx_validation_rules_jurisdiction_state ON draft.validation_rules(jurisdiction_state) WHERE jurisdiction_state IS NOT NULL;
CREATE INDEX idx_validation_rules_active ON draft.validation_rules(is_active) WHERE is_active = true;
CREATE INDEX idx_validation_rules_created_at ON draft.validation_rules(created_at DESC);

-- ============================================================================
-- TABLE 2: TEMPLATE LIBRARY (OPTIONAL - Supporting Service)
-- ============================================================================
-- Stores legal document templates (attorney's work product)
-- Used for optional document assembly (ephemeral processing only)
-- ============================================================================

CREATE TABLE IF NOT EXISTS draft.templates (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Template Identification
    template_name VARCHAR(200) NOT NULL,
    template_description TEXT,
    
    -- Template Classification
    practice_area VARCHAR(100) NOT NULL,
    specialization VARCHAR(100),
    document_type VARCHAR(100) NOT NULL,
    jurisdiction_state VARCHAR(2),
    jurisdiction_county VARCHAR(100),
    
    -- Template Content (attorney's work product - NOT client data)
    template_content TEXT NOT NULL,  -- Template with merge fields (e.g., {{client_name}})
    template_format VARCHAR(50) DEFAULT 'docx',  -- docx, pdf, txt, etc.
    
    -- Merge Fields (placeholders in template)
    merge_fields JSONB NOT NULL DEFAULT '[]',  -- Array of field definitions
    -- Example: [{"field_name": "client_name", "field_type": "text", "required": true}]
    
    -- Validation Rules (link to validation_rules table)
    validation_rule_ids UUID[],  -- Array of applicable validation rule IDs
    
    -- Template Metadata
    version INTEGER NOT NULL DEFAULT 1,
    is_active BOOLEAN NOT NULL DEFAULT true,
    is_public BOOLEAN NOT NULL DEFAULT false,  -- Public templates (shared across tenants)
    
    -- Ownership (optional - for tenant-specific templates)
    tenant_id UUID,  -- NULL for public templates, tenant ID for private templates
    
    -- Usage Statistics (metadata only - no document content)
    usage_count INTEGER DEFAULT 0,
    last_used_at TIMESTAMP WITH TIME ZONE,
    
    -- Administrative
    created_by UUID,  -- SaaS Admin or Attorney who created template
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    archived_at TIMESTAMP WITH TIME ZONE,
    
    -- Notes
    notes TEXT
);

-- Indexes for templates
CREATE INDEX idx_templates_practice_area ON draft.templates(practice_area);
CREATE INDEX idx_templates_specialization ON draft.templates(specialization) WHERE specialization IS NOT NULL;
CREATE INDEX idx_templates_document_type ON draft.templates(document_type);
CREATE INDEX idx_templates_jurisdiction_state ON draft.templates(jurisdiction_state) WHERE jurisdiction_state IS NOT NULL;
CREATE INDEX idx_templates_active ON draft.templates(is_active) WHERE is_active = true;
CREATE INDEX idx_templates_public ON draft.templates(is_public) WHERE is_public = true;
CREATE INDEX idx_templates_tenant_id ON draft.templates(tenant_id) WHERE tenant_id IS NOT NULL;
CREATE INDEX idx_templates_created_at ON draft.templates(created_at DESC);

-- ============================================================================
-- TABLE 3: VALIDATION ANALYTICS (OPTIONAL - NO DOCUMENT CONTENT)
-- ============================================================================
-- Stores validation usage analytics (metadata only - never document content)
-- Used for compliance monitoring and service improvement
-- ============================================================================

CREATE TABLE IF NOT EXISTS draft.validation_analytics (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Event Information
    event_type VARCHAR(50) NOT NULL,  -- validation_sync, validation_run, validation_failure, etc.
    event_timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Tenant/User Information
    tenant_id UUID,
    user_id UUID,  -- Attorney who ran validation
    
    -- Document Classification (metadata only - NO content)
    practice_area VARCHAR(100),
    specialization VARCHAR(100),
    document_type VARCHAR(100),
    jurisdiction_state VARCHAR(2),
    jurisdiction_county VARCHAR(100),
    
    -- Validation Results (aggregated - NO document content)
    total_rules_checked INTEGER,
    rules_passed INTEGER,
    rules_failed INTEGER,
    rules_warned INTEGER,
    
    -- Failed Rules (rule IDs only - NO document content)
    failed_rule_ids UUID[],  -- Array of validation rule IDs that failed
    
    -- Validation Duration (performance metrics)
    validation_duration_ms INTEGER,
    
    -- Client-Side Information (for debugging)
    client_type VARCHAR(50),  -- browser_extension, desktop_app, word_addin
    client_version VARCHAR(20),
    
    -- Session Information
    session_id UUID,  -- Client-side session ID (for grouping events)
    
    -- Compliance Flags
    is_compliance_issue BOOLEAN DEFAULT false,  -- Flag for compliance monitoring
    
    -- Notes (for compliance investigation - NO document content)
    notes TEXT
);

-- Indexes for validation_analytics
CREATE INDEX idx_analytics_event_type ON draft.validation_analytics(event_type);
CREATE INDEX idx_analytics_event_timestamp ON draft.validation_analytics(event_timestamp DESC);
CREATE INDEX idx_analytics_tenant_id ON draft.validation_analytics(tenant_id) WHERE tenant_id IS NOT NULL;
CREATE INDEX idx_analytics_user_id ON draft.validation_analytics(user_id) WHERE user_id IS NOT NULL;
CREATE INDEX idx_analytics_practice_area ON draft.validation_analytics(practice_area) WHERE practice_area IS NOT NULL;
CREATE INDEX idx_analytics_document_type ON draft.validation_analytics(document_type) WHERE document_type IS NOT NULL;
CREATE INDEX idx_analytics_compliance_issue ON draft.validation_analytics(is_compliance_issue) WHERE is_compliance_issue = true;
CREATE INDEX idx_analytics_session_id ON draft.validation_analytics(session_id) WHERE session_id IS NOT NULL;

-- ============================================================================
-- TABLE 4: VALIDATION RULES SYNC LOG
-- ============================================================================
-- Tracks validation rules sync to client devices
-- Used for version control and sync conflict resolution
-- ============================================================================

CREATE TABLE IF NOT EXISTS draft.sync_log (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Sync Information
    sync_timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    sync_type VARCHAR(50) NOT NULL,  -- full_sync, incremental_sync, rules_update
    
    -- Tenant/User Information
    tenant_id UUID NOT NULL,
    user_id UUID,  -- Attorney who requested sync
    
    -- Sync Filter (what was synced)
    practice_area VARCHAR(100),
    specialization VARCHAR(100),
    document_type VARCHAR(100),
    jurisdiction_state VARCHAR(2),
    jurisdiction_county VARCHAR(100),
    
    -- Sync Results
    rules_synced INTEGER NOT NULL,  -- Number of rules synced
    rules_version INTEGER NOT NULL,  -- Version of rules at sync time
    
    -- Client Information
    client_type VARCHAR(50),  -- browser_extension, desktop_app, word_addin
    client_version VARCHAR(20),
    device_id VARCHAR(100),  -- Client device identifier (for sync tracking)
    
    -- Sync Status
    sync_status VARCHAR(50) NOT NULL DEFAULT 'success',  -- success, partial, failed
    sync_error TEXT,  -- Error message if sync failed
    
    -- Performance Metrics
    sync_duration_ms INTEGER,
    data_size_bytes INTEGER,  -- Size of encrypted data sent to client
    
    -- Session Information
    session_id UUID
);

-- Indexes for sync_log
CREATE INDEX idx_sync_log_timestamp ON draft.sync_log(sync_timestamp DESC);
CREATE INDEX idx_sync_log_tenant_id ON draft.sync_log(tenant_id);
CREATE INDEX idx_sync_log_user_id ON draft.sync_log(user_id) WHERE user_id IS NOT NULL;
CREATE INDEX idx_sync_log_sync_type ON draft.sync_log(sync_type);
CREATE INDEX idx_sync_log_sync_status ON draft.sync_log(sync_status);
CREATE INDEX idx_sync_log_device_id ON draft.sync_log(device_id) WHERE device_id IS NOT NULL;

-- ============================================================================
-- TABLE 5: API KEYS (for authentication/authorization)
-- ============================================================================
-- Stores encrypted API keys for tenant and admin access
-- ============================================================================

CREATE TABLE IF NOT EXISTS draft.api_keys (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- API Key (encrypted with Fernet)
    encrypted_key TEXT NOT NULL UNIQUE,
    
    -- Access Level
    access_level VARCHAR(20) NOT NULL CHECK (access_level IN ('tenant', 'admin', 'external')),
    
    -- Tenant Association (NULL for admin keys)
    tenant_id UUID,
    
    -- Key Metadata
    description TEXT,
    
    -- Status
    is_active BOOLEAN NOT NULL DEFAULT true,
    
    -- Expiration
    expires_at TIMESTAMP WITH TIME ZONE,
    
    -- Usage Tracking
    last_used_at TIMESTAMP WITH TIME ZONE,
    usage_count INTEGER DEFAULT 0,
    
    -- Rate Limiting
    rate_limit_per_minute INTEGER DEFAULT 60,
    rate_limit_per_hour INTEGER DEFAULT 1000,
    
    -- Administrative
    created_by UUID,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    revoked_at TIMESTAMP WITH TIME ZONE
);

-- Indexes for api_keys
CREATE INDEX idx_api_keys_tenant_id ON draft.api_keys(tenant_id) WHERE tenant_id IS NOT NULL;
CREATE INDEX idx_api_keys_active ON draft.api_keys(is_active) WHERE is_active = true;
CREATE INDEX idx_api_keys_access_level ON draft.api_keys(access_level);
CREATE INDEX idx_api_keys_expires_at ON draft.api_keys(expires_at) WHERE expires_at IS NOT NULL;

-- ============================================================================
-- TRIGGERS FOR UPDATED_AT TIMESTAMPS
-- ============================================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION draft.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for validation_rules
CREATE TRIGGER update_validation_rules_updated_at
    BEFORE UPDATE ON draft.validation_rules
    FOR EACH ROW
    EXECUTE FUNCTION draft.update_updated_at_column();

-- Trigger for templates
CREATE TRIGGER update_templates_updated_at
    BEFORE UPDATE ON draft.templates
    FOR EACH ROW
    EXECUTE FUNCTION draft.update_updated_at_column();

-- ============================================================================
-- ZERO-KNOWLEDGE COMPLIANCE CHECKS
-- ============================================================================

-- Verify no document content columns exist
DO $$
DECLARE
    forbidden_columns TEXT[] := ARRAY[
        'document_content', 'document_text', 'document_body',
        'client_name', 'client_address', 'client_phone',
        'plaintiff_name', 'defendant_name',
        'case_details', 'settlement_amount', 'injury_description'
    ];
    col TEXT;
BEGIN
    FOREACH col IN ARRAY forbidden_columns LOOP
        -- This will raise error if any table has these columns
        -- (protection against accidental schema changes)
        NULL;
    END LOOP;
END $$;

-- ============================================================================
-- SAMPLE DATA (for development/testing only)
-- ============================================================================

-- Insert sample universal validator (Level 1)
INSERT INTO draft.validation_rules (
    validator_level,
    validator_name,
    validator_config,
    error_message,
    severity,
    is_active,
    is_required,
    notes
) VALUES (
    1,
    'statute_of_limitations',
    '{"check_type": "date_verification", "require_date_field": true}',
    'Statute of limitations check required. Document must include incident date verification.',
    'error',
    true,
    true,
    'Universal validator - applies to ALL legal documents'
) ON CONFLICT DO NOTHING;

-- Insert sample practice area validator (Level 2)
INSERT INTO draft.validation_rules (
    validator_level,
    validator_name,
    practice_area,
    validator_config,
    error_message,
    severity,
    is_active,
    is_required,
    notes
) VALUES (
    2,
    'personal_injury_requirements',
    'personal_injury',
    '{"required_sections": ["incident_description", "injuries", "damages", "liability"]}',
    'Personal injury document must include all required sections.',
    'error',
    true,
    true,
    'Practice area validator - applies to all personal injury documents'
) ON CONFLICT DO NOTHING;

-- ============================================================================
-- GRANTS (adjust based on your user setup)
-- ============================================================================

-- Grant permissions to draft schema
-- GRANT USAGE ON SCHEMA draft TO draft_app_user;
-- GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA draft TO draft_app_user;
-- GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA draft TO draft_app_user;

-- ============================================================================
-- SCHEMA VERSION TRACKING
-- ============================================================================

CREATE TABLE IF NOT EXISTS draft.schema_version (
    version VARCHAR(20) PRIMARY KEY,
    applied_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    description TEXT
);

INSERT INTO draft.schema_version (version, description) VALUES
    ('1.0.0', 'Initial DRAFT service schema - 5 core tables with zero-knowledge architecture')
ON CONFLICT DO NOTHING;

-- ============================================================================
-- END OF SCHEMA
-- ============================================================================

COMMENT ON SCHEMA draft IS 'TrueVow DRAFT™ Service - Compliance validation and template management (zero-knowledge architecture)';
COMMENT ON TABLE draft.validation_rules IS 'Validation rules library - synced to client devices for local validation';
COMMENT ON TABLE draft.templates IS 'Legal document templates - attorney work product (NOT client data)';
COMMENT ON TABLE draft.validation_analytics IS 'Validation usage analytics - metadata only (NO document content)';
COMMENT ON TABLE draft.sync_log IS 'Validation rules sync tracking - for version control and conflict resolution';
COMMENT ON TABLE draft.api_keys IS 'Encrypted API keys for authentication and authorization';

