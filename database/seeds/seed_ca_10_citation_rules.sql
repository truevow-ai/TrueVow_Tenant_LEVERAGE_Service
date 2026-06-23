-- ============================================================================
-- Seed 10 Citation-Backed CA PI Foundation Rules
-- ============================================================================
-- Version: 1.3.0
-- Date: January 30, 2026
-- Updated: Fixed column names to match actual validation_rules schema
--          - uses validator_level, validator_name, validator_type, validator_config
--          - removed non-existent columns (source_url, excerpt, effective_date, etc.)

DO $$
DECLARE
    crc_2111_id INTEGER;
    crc_2108_id INTEGER;
    ccp_42510a1_id INTEGER;
    ccp_42510a2_id INTEGER;
    ccp_395_id INTEGER;
    ccp_41220a_id INTEGER;
    ccp_3351_id INTEGER;
    ccp_446_id INTEGER;
BEGIN
    -- Get citation IDs
    SELECT id INTO crc_2111_id FROM leverage.rule_citations WHERE citation = 'CRC Rule 2.111';
    SELECT id INTO crc_2108_id FROM leverage.rule_citations WHERE citation = 'CRC Rule 2.108';
    SELECT id INTO ccp_42510a1_id FROM leverage.rule_citations WHERE citation LIKE '%425.10(a)(1)%';
    SELECT id INTO ccp_42510a2_id FROM leverage.rule_citations WHERE citation LIKE '%425.10(a)(2)%';
    SELECT id INTO ccp_395_id FROM leverage.rule_citations WHERE citation LIKE '%395%';
    SELECT id INTO ccp_41220a_id FROM leverage.rule_citations WHERE citation LIKE '%412.20%';
    SELECT id INTO ccp_3351_id FROM leverage.rule_citations WHERE citation LIKE '%335.1%';
    SELECT id INTO ccp_446_id FROM leverage.rule_citations WHERE citation LIKE '%446%';
    
    -- Rule 1: Attorney Contact Block
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type, 
        jurisdiction_state, jurisdiction_scope,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    )
    SELECT 
        'CA-CRC-2.111-ATTORNEY-CONTACT-BLOCK',
        5,  -- Level 5: Jurisdiction Validator
        'Attorney Contact Block',
        'required_field',
        'personal_injury',
        'complaint',
        'CA',
        'state',
        '{"required_fields": ["attorney_name", "attorney_address", "attorney_phone", "attorney_email"]}'::jsonb,
        'error',
        crc_2111_id,
        'draft',
        true,
        true,  -- is_template = true (global template)
        NULL,  -- tenant_id = NULL for global template
        NOW(),
        NOW()
    WHERE NOT EXISTS (SELECT 1 FROM leverage.validation_rules WHERE rule_name = 'CA-CRC-2.111-ATTORNEY-CONTACT-BLOCK');

    -- Rule 2: Line Numbering
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type, 
        jurisdiction_state, jurisdiction_scope,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    )
    SELECT 
        'CA-CRC-2.108-LINE-NUMBERING',
        5,
        'Line Numbering',
        'format_check',
        'personal_injury',
        'complaint',
        'CA',
        'state',
        '{"check_line_numbers": true}'::jsonb,
        'error',
        crc_2108_id,
        'draft',
        true,
        true,
        NULL,
        NOW(),
        NOW()
    WHERE NOT EXISTS (SELECT 1 FROM leverage.validation_rules WHERE rule_name = 'CA-CRC-2.108-LINE-NUMBERING');

    -- Rule 3: Facts Section
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type, 
        jurisdiction_state, jurisdiction_scope,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    )
    SELECT 
        'CA-CCP-425.10-FACTS-SECTION',
        5,
        'Facts Section',
        'required_field',
        'personal_injury',
        'complaint',
        'CA',
        'state',
        '{"required_sections": ["Facts", "General Allegations"]}'::jsonb,
        'error',
        ccp_42510a1_id,
        'draft',
        true,
        true,
        NULL,
        NOW(),
        NOW()
    WHERE NOT EXISTS (SELECT 1 FROM leverage.validation_rules WHERE rule_name = 'CA-CCP-425.10-FACTS-SECTION');

    -- Rule 4: Demand for Judgment
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type, 
        jurisdiction_state, jurisdiction_scope,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    )
    SELECT 
        'CA-CCP-425.10-DEMAND-FOR-JUDGMENT',
        5,
        'Demand for Judgment',
        'required_field',
        'personal_injury',
        'complaint',
        'CA',
        'state',
        '{"required_sections": ["Prayer", "Demand for Relief"]}'::jsonb,
        'error',
        ccp_42510a2_id,
        'draft',
        true,
        true,
        NULL,
        NOW(),
        NOW()
    WHERE NOT EXISTS (SELECT 1 FROM leverage.validation_rules WHERE rule_name = 'CA-CCP-425.10-DEMAND-FOR-JUDGMENT');

    -- Rule 5: Venue Check
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type, 
        jurisdiction_state, jurisdiction_scope,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    )
    SELECT 
        'CA-CCP-395-VENUE-CHECK',
        5,
        'Venue Check',
        'content_check',
        'personal_injury',
        'complaint',
        'CA',
        'state',
        '{"compare_fields": ["defendant_county", "filing_county"]}'::jsonb,
        'warning',
        ccp_395_id,
        'draft',
        true,
        true,
        NULL,
        NOW(),
        NOW()
    WHERE NOT EXISTS (SELECT 1 FROM leverage.validation_rules WHERE rule_name = 'CA-CCP-395-VENUE-CHECK');

    -- Rule 6: Summons Requirements
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type, 
        jurisdiction_state, jurisdiction_scope,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    )
    SELECT 
        'CA-CCP-412.20-SUMMONS-REQUIREMENTS',
        5,
        'Summons Requirements',
        'required_field',
        'personal_injury',
        'summons',
        'CA',
        'state',
        '{"required_elements": ["defendant_name", "court_name"]}'::jsonb,
        'error',
        ccp_41220a_id,
        'draft',
        true,
        true,
        NULL,
        NOW(),
        NOW()
    WHERE NOT EXISTS (SELECT 1 FROM leverage.validation_rules WHERE rule_name = 'CA-CCP-412.20-SUMMONS-REQUIREMENTS');

    -- Rule 7: Summons Court Title
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type, 
        jurisdiction_state, jurisdiction_scope,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    )
    SELECT 
        'CA-CCP-412.20-COURT-PARTIES',
        5,
        'Summons Court Parties',
        'required_field',
        'personal_injury',
        'summons',
        'CA',
        'state',
        '{"required_sections": ["court_title"]}'::jsonb,
        'error',
        ccp_41220a_id,
        'draft',
        true,
        true,
        NULL,
        NOW(),
        NOW()
    WHERE NOT EXISTS (SELECT 1 FROM leverage.validation_rules WHERE rule_name = 'CA-CCP-412.20-COURT-PARTIES');

    -- Rule 8: 30-Day Response
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type, 
        jurisdiction_state, jurisdiction_scope,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    )
    SELECT 
        'CA-CCP-412.20-30-DAY-RESPONSE',
        5,
        '30-Day Response',
        'required_field',
        'personal_injury',
        'summons',
        'CA',
        'state',
        '{"deadline_days": 30}'::jsonb,
        'error',
        ccp_41220a_id,
        'draft',
        true,
        true,
        NULL,
        NOW(),
        NOW()
    WHERE NOT EXISTS (SELECT 1 FROM leverage.validation_rules WHERE rule_name = 'CA-CCP-412.20-30-DAY-RESPONSE');

    -- Rule 9: PI SOL Warning
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type, 
        jurisdiction_state, jurisdiction_scope,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    )
    SELECT 
        'CA-CCP-335.1-PI-SOL-WARNING',
        5,
        'PI SOL Warning',
        'threshold_check',
        'personal_injury',
        'complaint',
        'CA',
        'state',
        '{"threshold_days": 730}'::jsonb,
        'warning',
        ccp_3351_id,
        'draft',
        true,
        true,
        NULL,
        NOW(),
        NOW()
    WHERE NOT EXISTS (SELECT 1 FROM leverage.validation_rules WHERE rule_name = 'CA-CCP-335.1-PI-SOL-WARNING');

    -- Rule 10: Verification
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type, 
        jurisdiction_state, jurisdiction_scope,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    )
    SELECT 
        'CA-CCP-446-VERIFICATION',
        5,
        'Verification',
        'conditional_check',
        'personal_injury',
        'complaint',
        'CA',
        'state',
        '{"trigger_field": "is_verified"}'::jsonb,
        'warning',
        ccp_446_id,
        'draft',
        true,
        true,
        NULL,
        NOW(),
        NOW()
    WHERE NOT EXISTS (SELECT 1 FROM leverage.validation_rules WHERE rule_name = 'CA-CCP-446-VERIFICATION');

    RAISE NOTICE '10 CA PI rules seeded successfully with citation linkage';
END $$;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Count rules
SELECT COUNT(*) AS rules_count
FROM leverage.validation_rules
WHERE jurisdiction_state = 'CA' AND practice_area = 'personal_injury';

-- Ensure every rule has citation linkage
SELECT COUNT(*) AS rules_missing_citation
FROM leverage.validation_rules
WHERE jurisdiction_state = 'CA'
  AND practice_area = 'personal_injury'
  AND (citation_id IS NULL);

-- Ensure citations have URL + excerpt
SELECT COUNT(*) AS citations_missing_proof
FROM leverage.rule_citations
WHERE (source_url IS NULL OR source_url = '')
   OR (excerpt IS NULL OR excerpt = '');

-- Verify CHECK constraints work: federal rules should have NULL state
SELECT COUNT(*) AS federal_rules_with_state_violation
FROM leverage.validation_rules
WHERE jurisdiction_scope = 'federal' AND jurisdiction_state IS NOT NULL;

-- Spot check: list rules with citation text + url + jurisdiction
SELECT 
    r.rule_name, 
    r.document_type,
    r.severity,
    r.review_status,
    r.jurisdiction_scope,
    r.jurisdiction_state,
    c.citation,
    c.source_url,
    LEFT(c.excerpt, 60) AS excerpt_preview
FROM leverage.validation_rules r
JOIN leverage.rule_citations c ON c.id = r.citation_id
WHERE r.jurisdiction_state = 'CA' AND r.practice_area = 'personal_injury'
ORDER BY r.rule_name;
