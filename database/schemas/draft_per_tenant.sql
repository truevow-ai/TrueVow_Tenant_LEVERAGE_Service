-- ==========================================
-- DRAFT Service - Per-Tenant Database Schema
-- Version: 2.0 (Integrated into Tenant App)
-- ==========================================
-- 
-- This schema is created in EACH tenant's database
-- (e.g., tenant_smith_firm, tenant_jones_law, etc.)
--
-- Architecture: Per-tenant isolation (like INTAKE)
-- No centralized database, no tenant_id filtering
-- ==========================================

-- Create DRAFT schema
CREATE SCHEMA IF NOT EXISTS draft;

-- ==========================================
-- 1. VALIDATION RULES
-- ==========================================
-- Each law firm's validation rules
-- State-specific templates seeded on onboarding

CREATE TABLE draft.validation_rules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Rule Identity
    rule_name VARCHAR(255) NOT NULL,
    rule_description TEXT,
    rule_type VARCHAR(50) NOT NULL, -- 'required_field', 'format_check', 'content_check', 'citation_check', etc.
    
    -- Organization
    document_type VARCHAR(100) NOT NULL, -- 'demand_letter', 'complaint', 'motion', 'brief', etc.
    practice_area VARCHAR(100), -- 'personal_injury', 'family_law', 'criminal_defense', etc.
    jurisdiction VARCHAR(100), -- 'arizona', 'california', 'federal', etc.
    
    -- Rule Configuration (JSON)
    rule_config JSONB NOT NULL,
    -- Example structures:
    -- Required Field: {"field_name": "Client Name", "pattern": "[A-Z][a-z]+ [A-Z][a-z]+", "required": true}
    -- Content Check: {"check_type": "section_exists", "section_name": "Statute of Limitations", "required": true}
    -- Format Check: {"check_type": "header_exists", "required": true, "error_message": "Professional letterhead required"}
    
    severity VARCHAR(20) NOT NULL DEFAULT 'error', -- 'error', 'warning', 'info'
    
    -- Template Tracking
    is_from_template BOOLEAN DEFAULT FALSE,
    template_source VARCHAR(100), -- 'truevow_arizona', 'truevow_california', 'truevow_federal', 'custom'
    template_version VARCHAR(20),
    is_customized BOOLEAN DEFAULT FALSE, -- Has tenant customized this template rule?
    customization_notes TEXT,
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    is_archived BOOLEAN DEFAULT FALSE,
    
    -- Audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID, -- References auth.users(id) in tenant database
    updated_by UUID,
    
    -- Constraints
    CONSTRAINT unique_rule_name UNIQUE (rule_name),
    CONSTRAINT valid_severity CHECK (severity IN ('error', 'warning', 'info')),
    CONSTRAINT valid_rule_type CHECK (rule_type IN (
        'required_field', 'format_check', 'content_check', 
        'citation_check', 'length_check', 'custom'
    ))
);

-- Indexes for performance
CREATE INDEX idx_draft_rules_document_type ON draft.validation_rules(document_type) WHERE is_active = TRUE;
CREATE INDEX idx_draft_rules_practice_area ON draft.validation_rules(practice_area) WHERE is_active = TRUE;
CREATE INDEX idx_draft_rules_jurisdiction ON draft.validation_rules(jurisdiction) WHERE is_active = TRUE;
CREATE INDEX idx_draft_rules_active ON draft.validation_rules(is_active) WHERE is_active = TRUE;
CREATE INDEX idx_draft_rules_template_source ON draft.validation_rules(template_source);

-- Comments
COMMENT ON TABLE draft.validation_rules IS 'Document validation rules for this law firm';
COMMENT ON COLUMN draft.validation_rules.rule_config IS 'JSON configuration for rule logic (field patterns, section names, etc.)';
COMMENT ON COLUMN draft.validation_rules.template_source IS 'Source of template: truevow_<state>, custom, or null';


-- ==========================================
-- 2. TEMPLATE LIBRARY
-- ==========================================
-- Pre-built templates available to this law firm
-- Seeded on tenant onboarding (state-specific)

CREATE TABLE draft.template_library (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Template Identity
    template_name VARCHAR(255) NOT NULL,
    template_description TEXT,
    template_category VARCHAR(100) NOT NULL, -- 'demand_letter', 'complaint', 'motion', etc.
    
    -- Jurisdiction
    state VARCHAR(50), -- 'arizona', 'california', 'texas', NULL for federal
    jurisdiction_type VARCHAR(50), -- 'state', 'federal', 'local'
    
    -- Template Rules (Array of rule configurations)
    rules JSONB NOT NULL,
    -- Example: [
    --   {"rule_name": "SOL Required", "rule_type": "content_check", "rule_config": {...}, "severity": "error"},
    --   {"rule_name": "Demand Amount", "rule_type": "required_field", "rule_config": {...}, "severity": "error"}
    -- ]
    
    -- Source & Version
    template_source VARCHAR(100) NOT NULL DEFAULT 'truevow', -- 'truevow', 'tenant_custom'
    template_version VARCHAR(20) NOT NULL DEFAULT '1.0',
    
    -- Usage Tracking
    times_used INTEGER DEFAULT 0,
    last_used_at TIMESTAMP WITH TIME ZONE,
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    
    -- Audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    
    -- Constraints
    CONSTRAINT unique_template_name UNIQUE (template_name),
    CONSTRAINT valid_jurisdiction_type CHECK (jurisdiction_type IN ('state', 'federal', 'local'))
);

-- Indexes
CREATE INDEX idx_draft_templates_category ON draft.template_library(template_category);
CREATE INDEX idx_draft_templates_state ON draft.template_library(state);
CREATE INDEX idx_draft_templates_source ON draft.template_library(template_source);
CREATE INDEX idx_draft_templates_active ON draft.template_library(is_active) WHERE is_active = TRUE;

-- Comments
COMMENT ON TABLE draft.template_library IS 'Pre-built validation rule templates for common document types';
COMMENT ON COLUMN draft.template_library.rules IS 'Array of rule configurations in JSON format';


-- ==========================================
-- 3. VALIDATION HISTORY (ANALYTICS)
-- ==========================================
-- Metadata about validation events
-- NO DOCUMENT CONTENT (zero-knowledge)

CREATE TABLE draft.validation_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Validation Context
    document_type VARCHAR(100) NOT NULL,
    source_type VARCHAR(50) NOT NULL, -- 'browser_extension', 'desktop_app', 'word_addin', 'email_attachment', 'intake_upload'
    
    -- Results Summary (Metadata Only - NO CONTENT)
    validation_passed BOOLEAN NOT NULL,
    errors_count INTEGER DEFAULT 0,
    warnings_count INTEGER DEFAULT 0,
    info_count INTEGER DEFAULT 0,
    total_rules_checked INTEGER NOT NULL,
    
    -- Rules Applied (Array of rule IDs)
    rules_applied UUID[],
    
    -- Errors/Warnings (NO DOCUMENT CONTENT)
    errors JSONB, -- [{"rule_id": "...", "rule_name": "...", "severity": "error", "message": "..."}]
    warnings JSONB,
    info JSONB,
    
    -- Email Context (if source_type = 'email_attachment')
    email_message_id VARCHAR(255),
    attachment_filename VARCHAR(255),
    attachment_mime_type VARCHAR(100),
    attachment_size_bytes BIGINT,
    
    -- Performance
    validation_duration_ms INTEGER,
    
    -- Client Info
    client_version VARCHAR(50),
    client_platform VARCHAR(50), -- 'chrome', 'firefox', 'safari', 'windows', 'mac', 'word'
    
    -- Audit
    validated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    validated_by UUID, -- User who performed validation
    
    -- Constraints
    CONSTRAINT valid_source_type CHECK (source_type IN (
        'browser_extension', 'desktop_app', 'word_addin', 
        'email_attachment', 'intake_upload', 'manual'
    ))
);

-- Indexes for analytics queries
CREATE INDEX idx_draft_history_document_type ON draft.validation_history(document_type);
CREATE INDEX idx_draft_history_source_type ON draft.validation_history(source_type);
CREATE INDEX idx_draft_history_validated_at ON draft.validation_history(validated_at DESC);
CREATE INDEX idx_draft_history_user ON draft.validation_history(validated_by);
CREATE INDEX idx_draft_history_passed ON draft.validation_history(validation_passed);

-- Comments
COMMENT ON TABLE draft.validation_history IS 'Validation event metadata (NO document content stored)';
COMMENT ON COLUMN draft.validation_history.errors IS 'Error details (rule violations) but NO document content';


-- ==========================================
-- 4. RULE SETS
-- ==========================================
-- Organize rules by document type
-- Allow multiple rule sets per document type

CREATE TABLE draft.rule_sets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Rule Set Identity
    rule_set_name VARCHAR(255) NOT NULL,
    rule_set_description TEXT,
    document_type VARCHAR(100) NOT NULL,
    
    -- Rules in This Set (Array of rule IDs)
    rule_ids UUID[] NOT NULL,
    
    -- Default for Document Type?
    is_default BOOLEAN DEFAULT FALSE,
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    
    -- Audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,
    
    -- Constraints
    CONSTRAINT unique_rule_set_name UNIQUE (rule_set_name)
);

-- Indexes
CREATE INDEX idx_draft_rule_sets_document_type ON draft.rule_sets(document_type);
CREATE INDEX idx_draft_rule_sets_default ON draft.rule_sets(is_default) WHERE is_default = TRUE;
CREATE INDEX idx_draft_rule_sets_active ON draft.rule_sets(is_active) WHERE is_active = TRUE;

-- Ensure only one default per document type
CREATE UNIQUE INDEX idx_draft_rule_sets_default_per_doc_type 
    ON draft.rule_sets(document_type) 
    WHERE is_default = TRUE;

-- Comments
COMMENT ON TABLE draft.rule_sets IS 'Organized collections of rules for specific document types';


-- ==========================================
-- 5. ANALYTICS VIEWS
-- ==========================================
-- Pre-computed analytics for dashboard

CREATE OR REPLACE VIEW draft.validation_analytics_summary AS
SELECT
    document_type,
    source_type,
    DATE_TRUNC('day', validated_at) AS validation_date,
    COUNT(*) AS total_validations,
    SUM(CASE WHEN validation_passed THEN 1 ELSE 0 END) AS passed_validations,
    SUM(CASE WHEN NOT validation_passed THEN 1 ELSE 0 END) AS failed_validations,
    ROUND(AVG(CASE WHEN validation_passed THEN 100 ELSE 0 END), 2) AS pass_rate,
    ROUND(AVG(errors_count), 2) AS avg_errors,
    ROUND(AVG(warnings_count), 2) AS avg_warnings,
    ROUND(AVG(validation_duration_ms), 0) AS avg_duration_ms
FROM draft.validation_history
WHERE validated_at >= NOW() - INTERVAL '90 days'
GROUP BY document_type, source_type, DATE_TRUNC('day', validated_at);

COMMENT ON VIEW draft.validation_analytics_summary IS 'Daily validation analytics by document type and source';


-- ==========================================
-- 6. FUNCTIONS
-- ==========================================

-- Function: Get active rules for document type
CREATE OR REPLACE FUNCTION draft.get_rules_for_document_type(
    p_document_type VARCHAR
)
RETURNS TABLE (
    id UUID,
    rule_name VARCHAR,
    rule_description TEXT,
    rule_type VARCHAR,
    rule_config JSONB,
    severity VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        vr.id,
        vr.rule_name,
        vr.rule_description,
        vr.rule_type,
        vr.rule_config,
        vr.severity
    FROM draft.validation_rules vr
    WHERE vr.document_type = p_document_type
      AND vr.is_active = TRUE
      AND vr.is_archived = FALSE
    ORDER BY 
        CASE vr.severity
            WHEN 'error' THEN 1
            WHEN 'warning' THEN 2
            WHEN 'info' THEN 3
        END,
        vr.created_at;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION draft.get_rules_for_document_type IS 'Get all active rules for a document type (for validation)';


-- Function: Apply template to create rules
CREATE OR REPLACE FUNCTION draft.apply_template(
    p_template_id UUID,
    p_user_id UUID
)
RETURNS SETOF draft.validation_rules AS $$
DECLARE
    template_record RECORD;
    rule_record JSONB;
    new_rule_id UUID;
BEGIN
    -- Get template
    SELECT * INTO template_record
    FROM draft.template_library
    WHERE id = p_template_id AND is_active = TRUE;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Template not found or inactive: %', p_template_id;
    END IF;
    
    -- Create rule for each rule in template
    FOR rule_record IN SELECT * FROM jsonb_array_elements(template_record.rules)
    LOOP
        INSERT INTO draft.validation_rules (
            rule_name,
            rule_description,
            rule_type,
            document_type,
            rule_config,
            severity,
            is_from_template,
            template_source,
            template_version,
            created_by,
            updated_by
        ) VALUES (
            (rule_record->>'rule_name')::VARCHAR,
            (rule_record->>'rule_description')::TEXT,
            (rule_record->>'rule_type')::VARCHAR,
            template_record.template_category,
            (rule_record->'rule_config')::JSONB,
            COALESCE((rule_record->>'severity')::VARCHAR, 'error'),
            TRUE,
            template_record.template_source,
            template_record.template_version,
            p_user_id,
            p_user_id
        )
        RETURNING * INTO STRICT rule_record;
        
        RETURN NEXT rule_record;
    END LOOP;
    
    -- Update template usage
    UPDATE draft.template_library
    SET times_used = times_used + 1,
        last_used_at = NOW()
    WHERE id = p_template_id;
    
    RETURN;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION draft.apply_template IS 'Apply a template to create validation rules';


-- Function: Get validation statistics
CREATE OR REPLACE FUNCTION draft.get_validation_statistics(
    p_days INTEGER DEFAULT 30
)
RETURNS TABLE (
    total_validations BIGINT,
    passed_validations BIGINT,
    failed_validations BIGINT,
    pass_rate NUMERIC,
    avg_errors_per_validation NUMERIC,
    avg_warnings_per_validation NUMERIC,
    most_common_document_type VARCHAR,
    most_common_source_type VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    WITH stats AS (
        SELECT
            COUNT(*) AS total,
            SUM(CASE WHEN validation_passed THEN 1 ELSE 0 END) AS passed,
            SUM(CASE WHEN NOT validation_passed THEN 1 ELSE 0 END) AS failed,
            AVG(errors_count) AS avg_errors,
            AVG(warnings_count) AS avg_warnings
        FROM draft.validation_history
        WHERE validated_at >= NOW() - (p_days || ' days')::INTERVAL
    ),
    doc_type AS (
        SELECT document_type
        FROM draft.validation_history
        WHERE validated_at >= NOW() - (p_days || ' days')::INTERVAL
        GROUP BY document_type
        ORDER BY COUNT(*) DESC
        LIMIT 1
    ),
    src_type AS (
        SELECT source_type
        FROM draft.validation_history
        WHERE validated_at >= NOW() - (p_days || ' days')::INTERVAL
        GROUP BY source_type
        ORDER BY COUNT(*) DESC
        LIMIT 1
    )
    SELECT
        s.total,
        s.passed,
        s.failed,
        CASE WHEN s.total > 0 THEN ROUND((s.passed::NUMERIC / s.total::NUMERIC) * 100, 2) ELSE 0 END,
        ROUND(s.avg_errors, 2),
        ROUND(s.avg_warnings, 2),
        d.document_type,
        src.source_type
    FROM stats s
    CROSS JOIN doc_type d
    CROSS JOIN src_type src;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION draft.get_validation_statistics IS 'Get validation statistics for the past N days';


-- ==========================================
-- 7. TRIGGERS
-- ==========================================

-- Trigger: Update updated_at on row update
CREATE OR REPLACE FUNCTION draft.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_validation_rules_updated_at
    BEFORE UPDATE ON draft.validation_rules
    FOR EACH ROW
    EXECUTE FUNCTION draft.update_updated_at_column();

CREATE TRIGGER update_template_library_updated_at
    BEFORE UPDATE ON draft.template_library
    FOR EACH ROW
    EXECUTE FUNCTION draft.update_updated_at_column();

CREATE TRIGGER update_rule_sets_updated_at
    BEFORE UPDATE ON draft.rule_sets
    FOR EACH ROW
    EXECUTE FUNCTION draft.update_updated_at_column();


-- ==========================================
-- 8. ROW LEVEL SECURITY (OPTIONAL)
-- ==========================================
-- Enable if tenant database is shared (not recommended)
-- For per-tenant databases, this is optional

-- ALTER TABLE draft.validation_rules ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE draft.template_library ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE draft.validation_history ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE draft.rule_sets ENABLE ROW LEVEL SECURITY;


-- ==========================================
-- SCHEMA COMPLETE
-- ==========================================

-- Grant permissions (adjust based on your auth setup)
-- GRANT USAGE ON SCHEMA draft TO authenticated;
-- GRANT ALL ON ALL TABLES IN SCHEMA draft TO authenticated;
-- GRANT ALL ON ALL SEQUENCES IN SCHEMA draft TO authenticated;
-- GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA draft TO authenticated;

-- Final comment
COMMENT ON SCHEMA draft IS 'DRAFT validation service schema (per-tenant isolation)';

