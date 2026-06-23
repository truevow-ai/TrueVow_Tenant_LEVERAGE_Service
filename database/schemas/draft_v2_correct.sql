-- ============================================================================
-- TrueVow DRAFT™ Service - Database Schema v2.0 (CORRECT ARCHITECTURE)
-- ============================================================================
-- 
-- Architecture:
-- 1. Global Rule Templates (managed by SaaS Admin)
--    - is_template = TRUE, tenant_id = NULL
--    - Available for inheritance by all tenants
-- 
-- 2. Tenant-Specific Rules (managed by law firms)
--    - is_template = FALSE, tenant_id = <tenant_uuid>
--    - Can inherit from global templates
--    - Can be customized after inheritance
-- 
-- Zero-Knowledge Architecture:
-- - Rules contain NO document content
-- - Rules contain NO client data
-- - Document validation happens client-side
-- - Only validation metadata is logged (NO CONTENT)
-- ============================================================================

-- Create DRAFT schema
CREATE SCHEMA IF NOT EXISTS draft;

-- ============================================================================
-- TABLE: validation_rules
-- Stores both global rule templates AND tenant-specific rules
-- ============================================================================

CREATE TABLE draft.validation_rules (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Tenant Scoping (NULL = global template, UUID = tenant-specific)
    tenant_id UUID NULL,
    is_template BOOLEAN NOT NULL DEFAULT FALSE,
    
    -- Template Metadata (for global templates)
    template_name VARCHAR(200) NULL,
    template_description TEXT NULL,
    
    -- Rule Metadata (for tenant-specific rules)
    rule_name VARCHAR(200) NOT NULL,
    
    -- Template Inheritance
    inherited_from_template_id UUID NULL,
    is_customized BOOLEAN NOT NULL DEFAULT FALSE,
    template_version INTEGER NULL,
    
    -- 5-Level Validator Hierarchy
    validator_level INTEGER NOT NULL CHECK (validator_level BETWEEN 1 AND 5),
    validator_name VARCHAR(100) NOT NULL,
    validator_type VARCHAR(50) NOT NULL,
    
    -- Level 2: Practice Area Validators
    practice_area VARCHAR(100) NULL,
    
    -- Level 3: Specialization Validators
    specialization VARCHAR(100) NULL,
    
    -- Level 4: Document Type Validators
    document_type VARCHAR(100) NULL,
    
    -- Level 5: Jurisdiction Validators
    jurisdiction_state VARCHAR(2) NULL,
    jurisdiction_county VARCHAR(100) NULL,
    jurisdiction_court VARCHAR(200) NULL,
    
    -- Validator Configuration
    validator_config JSONB NOT NULL DEFAULT '{}'::jsonb,
    
    -- Validation Messages
    error_message TEXT NULL,
    warning_message TEXT NULL,
    info_message TEXT NULL,
    
    -- Validation Severity
    severity VARCHAR(20) NOT NULL DEFAULT 'error' CHECK (severity IN ('error', 'warning', 'info')),
    
    -- Rule Status
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    is_required BOOLEAN NOT NULL DEFAULT TRUE,
    
    -- Rule Selection (for document validation)
    is_enabled_for_validation BOOLEAN NOT NULL DEFAULT TRUE,
    
    -- Versioning
    version INTEGER NOT NULL DEFAULT 1,
    
    -- Rule Dependencies
    depends_on_rule_ids UUID[] NULL,
    
    -- Administrative
    created_by UUID NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    archived_at TIMESTAMPTZ NULL,
    
    -- Notes
    notes TEXT NULL,
    
    -- Constraints
    CONSTRAINT fk_inherited_from_template 
        FOREIGN KEY (inherited_from_template_id) 
        REFERENCES draft.validation_rules(id),
    
    -- Business Logic Constraints
    CONSTRAINT check_template_has_template_name 
        CHECK ((is_template = TRUE AND template_name IS NOT NULL) OR is_template = FALSE),
    
    CONSTRAINT check_template_has_no_tenant 
        CHECK ((is_template = TRUE AND tenant_id IS NULL) OR is_template = FALSE),
    
    CONSTRAINT check_tenant_rule_has_tenant 
        CHECK ((is_template = FALSE AND tenant_id IS NOT NULL) OR is_template = TRUE)
);

-- ============================================================================
-- INDEXES
-- ============================================================================

-- Tenant isolation
CREATE INDEX idx_validation_rules_tenant_id ON draft.validation_rules(tenant_id) WHERE tenant_id IS NOT NULL;
CREATE INDEX idx_validation_rules_is_template ON draft.validation_rules(is_template) WHERE is_template = TRUE;

-- Template inheritance
CREATE INDEX idx_validation_rules_inherited_from ON draft.validation_rules(inherited_from_template_id) WHERE inherited_from_template_id IS NOT NULL;

-- Validator hierarchy
CREATE INDEX idx_validation_rules_level ON draft.validation_rules(validator_level);
CREATE INDEX idx_validation_rules_practice_area ON draft.validation_rules(practice_area) WHERE practice_area IS NOT NULL;
CREATE INDEX idx_validation_rules_specialization ON draft.validation_rules(specialization) WHERE specialization IS NOT NULL;
CREATE INDEX idx_validation_rules_document_type ON draft.validation_rules(document_type) WHERE document_type IS NOT NULL;
CREATE INDEX idx_validation_rules_jurisdiction_state ON draft.validation_rules(jurisdiction_state) WHERE jurisdiction_state IS NOT NULL;

-- Status filters
CREATE INDEX idx_validation_rules_active ON draft.validation_rules(is_active) WHERE is_active = TRUE;
CREATE INDEX idx_validation_rules_archived ON draft.validation_rules(archived_at) WHERE archived_at IS NOT NULL;

-- Rule selection
CREATE INDEX idx_validation_rules_enabled ON draft.validation_rules(is_enabled_for_validation) WHERE is_enabled_for_validation = TRUE;

-- Performance
CREATE INDEX idx_validation_rules_created_at ON draft.validation_rules(created_at DESC);
CREATE INDEX idx_validation_rules_updated_at ON draft.validation_rules(updated_at DESC);

-- Composite indexes for common queries
CREATE INDEX idx_validation_rules_tenant_document_type 
    ON draft.validation_rules(tenant_id, document_type) 
    WHERE tenant_id IS NOT NULL AND document_type IS NOT NULL;

CREATE INDEX idx_validation_rules_template_practice_area 
    ON draft.validation_rules(is_template, practice_area) 
    WHERE is_template = TRUE AND practice_area IS NOT NULL;

-- ============================================================================
-- TABLE: api_keys
-- Stores encrypted API keys for authentication
-- ============================================================================

CREATE TABLE draft.api_keys (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- API Key (hashed with bcrypt, NOT encrypted with Fernet)
    key_hash TEXT NOT NULL UNIQUE,
    key_prefix VARCHAR(10) NOT NULL,  -- First 8 chars for identification
    
    -- Access Level
    access_level VARCHAR(20) NOT NULL CHECK (access_level IN ('tenant', 'admin', 'external')),
    
    -- Tenant Association (NULL for admin keys)
    tenant_id UUID NULL,
    
    -- Key Metadata
    description TEXT NULL,
    
    -- Status
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    
    -- Expiration
    expires_at TIMESTAMPTZ NULL,
    
    -- Usage Tracking
    last_used_at TIMESTAMPTZ NULL,
    usage_count INTEGER NOT NULL DEFAULT 0,
    
    -- Rate Limiting
    rate_limit_per_minute INTEGER NOT NULL DEFAULT 60,
    rate_limit_per_hour INTEGER NOT NULL DEFAULT 1000,
    
    -- Administrative
    created_by UUID NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    revoked_at TIMESTAMPTZ NULL,
    
    -- Constraints
    CONSTRAINT check_tenant_key_has_tenant 
        CHECK ((access_level = 'tenant' AND tenant_id IS NOT NULL) OR access_level != 'tenant'),
    
    CONSTRAINT check_admin_key_no_tenant 
        CHECK ((access_level = 'admin' AND tenant_id IS NULL) OR access_level != 'admin')
);

-- Indexes
CREATE INDEX idx_api_keys_tenant_id ON draft.api_keys(tenant_id) WHERE tenant_id IS NOT NULL;
CREATE INDEX idx_api_keys_active ON draft.api_keys(is_active) WHERE is_active = TRUE;
CREATE INDEX idx_api_keys_access_level ON draft.api_keys(access_level);
CREATE INDEX idx_api_keys_expires_at ON draft.api_keys(expires_at) WHERE expires_at IS NOT NULL;
CREATE INDEX idx_api_keys_key_prefix ON draft.api_keys(key_prefix);

-- ============================================================================
-- TABLE: validation_analytics
-- Stores validation metadata (NO DOCUMENT CONTENT)
-- ============================================================================

CREATE TABLE draft.validation_analytics (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Tenant Scoping
    tenant_id UUID NOT NULL,
    user_id UUID NULL,
    
    -- Validation Context
    practice_area VARCHAR(100) NULL,
    specialization VARCHAR(100) NULL,
    document_type VARCHAR(100) NOT NULL,
    jurisdiction_state VARCHAR(2) NULL,
    jurisdiction_county VARCHAR(100) NULL,
    
    -- Validation Source
    source_type VARCHAR(50) NOT NULL CHECK (source_type IN ('browser_extension', 'desktop_app', 'word_addin', 'email_attachment', 'api')),
    
    -- Validation Result (metadata only)
    validation_passed BOOLEAN NOT NULL,
    errors_count INTEGER NOT NULL DEFAULT 0,
    warnings_count INTEGER NOT NULL DEFAULT 0,
    info_count INTEGER NOT NULL DEFAULT 0,
    
    -- Rules Used
    selected_rule_ids UUID[] NULL,
    rules_checked INTEGER NOT NULL DEFAULT 0,
    rules_passed INTEGER NOT NULL DEFAULT 0,
    rules_failed INTEGER NOT NULL DEFAULT 0,
    
    -- Validation Metadata (NO CONTENT)
    validation_duration_ms INTEGER NULL,
    document_size_bytes BIGINT NULL,
    document_format VARCHAR(50) NULL,
    
    -- Email-Specific Metadata (for email attachments)
    email_message_id VARCHAR(255) NULL,
    email_subject_hash VARCHAR(64) NULL,  -- SHA-256 hash (never raw subject)
    attachment_filename VARCHAR(255) NULL,
    attachment_mime_type VARCHAR(100) NULL,
    attachment_size_bytes BIGINT NULL,
    
    -- Client Information
    client_type VARCHAR(50) NULL,
    client_version VARCHAR(20) NULL,
    device_id VARCHAR(255) NULL,
    session_id UUID NULL,
    
    -- Timestamps
    validated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Zero-Knowledge Compliance Flag
    content_uploaded BOOLEAN NOT NULL DEFAULT FALSE CHECK (content_uploaded = FALSE),
    
    -- Notes
    notes TEXT NULL
);

-- Indexes
CREATE INDEX idx_validation_analytics_tenant_id ON draft.validation_analytics(tenant_id);
CREATE INDEX idx_validation_analytics_user_id ON draft.validation_analytics(user_id) WHERE user_id IS NOT NULL;
CREATE INDEX idx_validation_analytics_document_type ON draft.validation_analytics(document_type);
CREATE INDEX idx_validation_analytics_practice_area ON draft.validation_analytics(practice_area) WHERE practice_area IS NOT NULL;
CREATE INDEX idx_validation_analytics_validated_at ON draft.validation_analytics(validated_at DESC);
CREATE INDEX idx_validation_analytics_source_type ON draft.validation_analytics(source_type);
CREATE INDEX idx_validation_analytics_validation_passed ON draft.validation_analytics(validation_passed);

-- Composite indexes
CREATE INDEX idx_validation_analytics_tenant_date 
    ON draft.validation_analytics(tenant_id, validated_at DESC);

CREATE INDEX idx_validation_analytics_tenant_document_type 
    ON draft.validation_analytics(tenant_id, document_type);

-- ============================================================================
-- TABLE: templates (DOCUMENT TEMPLATES - separate from validation rules)
-- ============================================================================

CREATE TABLE draft.templates (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Tenant Scoping (NULL = global, UUID = tenant-specific)
    tenant_id UUID NULL,
    is_global BOOLEAN NOT NULL DEFAULT FALSE,
    
    -- Template Metadata
    template_name VARCHAR(200) NOT NULL,
    template_description TEXT NULL,
    
    -- Template Classification
    practice_area VARCHAR(100) NULL,
    specialization VARCHAR(100) NULL,
    document_type VARCHAR(100) NOT NULL,
    jurisdiction_state VARCHAR(2) NULL,
    jurisdiction_county VARCHAR(100) NULL,
    
    -- Template Content (encrypted with Fernet)
    encrypted_content TEXT NOT NULL,
    content_format VARCHAR(50) NOT NULL CHECK (content_format IN ('docx', 'pdf', 'html')),
    content_size_bytes BIGINT NOT NULL,
    
    -- Template Usage
    usage_count INTEGER NOT NULL DEFAULT 0,
    last_used_at TIMESTAMPTZ NULL,
    
    -- Status
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    
    -- Versioning
    version INTEGER NOT NULL DEFAULT 1,
    
    -- Administrative
    created_by UUID NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    archived_at TIMESTAMPTZ NULL,
    
    -- Notes
    notes TEXT NULL
);

-- Indexes
CREATE INDEX idx_templates_tenant_id ON draft.templates(tenant_id) WHERE tenant_id IS NOT NULL;
CREATE INDEX idx_templates_is_global ON draft.templates(is_global) WHERE is_global = TRUE;
CREATE INDEX idx_templates_document_type ON draft.templates(document_type);
CREATE INDEX idx_templates_practice_area ON draft.templates(practice_area) WHERE practice_area IS NOT NULL;
CREATE INDEX idx_templates_active ON draft.templates(is_active) WHERE is_active = TRUE;

-- ============================================================================
-- MATERIALIZED VIEW: template_inheritance_stats
-- Tracks how many tenants have inherited each template
-- ============================================================================

CREATE MATERIALIZED VIEW draft.template_inheritance_stats AS
SELECT 
    t.id AS template_id,
    t.template_name,
    t.practice_area,
    t.document_type,
    COUNT(DISTINCT r.tenant_id) AS inheritance_count,
    COUNT(r.id) AS total_inherited_rules,
    COUNT(CASE WHEN r.is_customized = TRUE THEN 1 END) AS customized_count,
    MAX(r.created_at) AS last_inherited_at
FROM 
    draft.validation_rules t
LEFT JOIN 
    draft.validation_rules r ON r.inherited_from_template_id = t.id
WHERE 
    t.is_template = TRUE
GROUP BY 
    t.id, t.template_name, t.practice_area, t.document_type;

-- Index on materialized view
CREATE INDEX idx_template_inheritance_stats_template_id 
    ON draft.template_inheritance_stats(template_id);

-- ============================================================================
-- FUNCTIONS & TRIGGERS
-- ============================================================================

-- Function: Update updated_at timestamp
CREATE OR REPLACE FUNCTION draft.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger: Auto-update updated_at on validation_rules
CREATE TRIGGER trigger_validation_rules_updated_at
    BEFORE UPDATE ON draft.validation_rules
    FOR EACH ROW
    EXECUTE FUNCTION draft.update_updated_at_column();

-- Trigger: Auto-update updated_at on templates
CREATE TRIGGER trigger_templates_updated_at
    BEFORE UPDATE ON draft.templates
    FOR EACH ROW
    EXECUTE FUNCTION draft.update_updated_at_column();

-- Function: Refresh materialized view (call after inheritance operations)
CREATE OR REPLACE FUNCTION draft.refresh_template_inheritance_stats()
RETURNS VOID AS $$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY draft.template_inheritance_stats;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- COMMENTS (Documentation)
-- ============================================================================

COMMENT ON SCHEMA draft IS 'TrueVow DRAFT™ Service - Document Validation & Compliance';

COMMENT ON TABLE draft.validation_rules IS 'Stores both global rule templates (is_template=TRUE) and tenant-specific rules (tenant_id != NULL). Zero-knowledge architecture - NO document content.';

COMMENT ON TABLE draft.api_keys IS 'API keys for authentication. Keys are hashed (NOT encrypted). Admin keys have tenant_id=NULL, tenant keys have tenant_id set.';

COMMENT ON TABLE draft.validation_analytics IS 'Validation metadata (NO CONTENT). Zero-knowledge compliant - content_uploaded must always be FALSE.';

COMMENT ON TABLE draft.templates IS 'Document templates (separate from validation rules). Content is encrypted with Fernet.';

COMMENT ON COLUMN draft.validation_rules.tenant_id IS 'NULL = global template, UUID = tenant-specific rule';
COMMENT ON COLUMN draft.validation_rules.is_template IS 'TRUE = global template (managed by SaaS Admin), FALSE = tenant-specific rule';
COMMENT ON COLUMN draft.validation_rules.inherited_from_template_id IS 'If tenant rule was inherited from a global template, this is the template ID';
COMMENT ON COLUMN draft.validation_rules.is_customized IS 'TRUE if inherited rule was customized after inheritance';
COMMENT ON COLUMN draft.validation_rules.is_enabled_for_validation IS 'TRUE if this rule should be used when validating documents';

COMMENT ON COLUMN draft.validation_analytics.content_uploaded IS 'MUST ALWAYS BE FALSE - zero-knowledge architecture means NO CONTENT is uploaded';
COMMENT ON COLUMN draft.validation_analytics.email_subject_hash IS 'SHA-256 hash of email subject (NEVER raw subject)';

-- ============================================================================
-- SAMPLE DATA (for development/testing)
-- ============================================================================

-- Insert sample global rule template
INSERT INTO draft.validation_rules (
    is_template,
    template_name,
    template_description,
    validator_level,
    validator_name,
    validator_type,
    practice_area,
    document_type,
    jurisdiction_state,
    validator_config,
    error_message,
    severity,
    rule_name
) VALUES (
    TRUE,
    'Arizona Bar Demand Letter Format',
    'Ensures demand letters comply with Arizona Bar formatting requirements',
    4,  -- Document Type level
    'demand_letter_format_validator',
    'format',
    'personal_injury',
    'demand_letter',
    'AZ',
    '{"required_sections": ["header", "facts", "liability", "damages", "settlement_demand"], "font_size_min": 11, "font_size_max": 14, "margin_inches": 1.0}'::jsonb,
    'Demand letter does not meet Arizona Bar formatting requirements',
    'error',
    'Arizona Bar Demand Letter Format'
);

-- ============================================================================
-- END OF SCHEMA
-- ============================================================================

