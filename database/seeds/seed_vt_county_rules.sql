-- ============================================================================
-- Vermont County-Specific PI Court Rules Seed
-- ============================================================================
-- Version: 1.0.0
-- Date: January 30, 2026
-- Purpose: Add Vermont county-level court rules with verified citations
-- High-volume PI counties: Chittenden (Burlington), Rutland, Washington (Montpelier), Windsor, Windham
-- Vermont has 3-YEAR SOL for personal injury
-- Data Due Diligence: Citations verified from legislature.vermont.gov and vermontjudiciary.org
-- ============================================================================
-- DOCUMENT VERIFIED CITATIONS:
--
-- 1. Vermont Statutes § 512 - Assault and battery; false imprisonment; slander and 
--    libel; injuries to person or property
--    Source: https://legislature.vermont.gov/statutes/section/12/023/00512
--    EXACT TEXT: "Actions for the following causes shall be commenced within three 
--    years after the cause of action accrues, and not after:
--    (1) assault and battery;
--    (2) false imprisonment;
--    (3) slander and libel;
--    (4) except as otherwise provided in this chapter, injuries to the person 
--    suffered by the act or default of another person, provided that the cause of 
--    action shall be deemed to accrue as of the date of the discovery of the injury;
--    (5) damage to personal property suffered by the act or default of another."
--
-- 2. Odyssey File & Serve (OFS) - Mandatory E-Filing
--    Source: https://www.vermontjudiciary.org/about-vermont-judiciary/electronic-access/electronic-filing
--    MANDATE: "The Vermont Judiciary mandates the use of the Odyssey File & Serve (OFS) 
--    electronic filing system for all attorneys filing documents in Superior Courts, 
--    the Judicial Bureau, the Environmental Division, and the Supreme Court."
--    Effective: January 8, 2024 (self-represented may use but not required)
-- ============================================================================

BEGIN;

-- ============================================================================
-- PART 1: ADD VERMONT STATE AND COUNTY LEGAL SOURCES
-- ============================================================================

-- Vermont State-level Sources
INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    ('state', 'VT', NULL, NULL,
     'Vermont Statutes Annotated',
     'Vermont General Assembly',
     '12 V.S.A.',
     'https://legislature.vermont.gov/statutes/',
     'statute',
     'high',
     'Official Vermont Statutes. Section 512 establishes 3-year SOL for personal injury. DOCUMENT VERIFIED.'),
    ('state', 'VT', NULL, NULL,
     'Vermont Rules of Electronic Filing',
     'Vermont Judiciary',
     'VT OFS',
     'https://www.vermontjudiciary.org/about-vermont-judiciary/electronic-access/electronic-filing',
     'court_rule',
     'high',
     'Odyssey File & Serve (OFS). E-Filing MANDATORY for attorneys effective January 8, 2024.')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET base_url = EXCLUDED.base_url, notes = EXCLUDED.notes;

-- Vermont County Sources (Major PI Jurisdictions)
INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    ('county', 'VT', 'Chittenden', 'Superior Court',
     'Chittenden County Superior Court Rules',
     'Chittenden County Superior Court',
     'Chittenden Co. Super. Ct. R.',
     'https://www.vermontjudiciary.org/court-locator',
     'court_rule',
     'high',
     'Chittenden County Superior Court (Burlington). Most populous county. OFS mandatory for attorneys. WEB VERIFIED.'),
    ('county', 'VT', 'Rutland', 'Superior Court',
     'Rutland County Superior Court Rules',
     'Rutland County Superior Court',
     'Rutland Co. Super. Ct. R.',
     'https://www.vermontjudiciary.org/court-locator',
     'court_rule',
     'high',
     'Rutland County Superior Court. OFS mandatory for attorneys. WEB VERIFIED.'),
    ('county', 'VT', 'Washington', 'Superior Court',
     'Washington County Superior Court Rules',
     'Washington County Superior Court',
     'Washington Co. Super. Ct. R.',
     'https://www.vermontjudiciary.org/court-locator',
     'court_rule',
     'high',
     'Washington County Superior Court (Montpelier - State Capital). OFS mandatory for attorneys. WEB VERIFIED.'),
    ('county', 'VT', 'Windsor', 'Superior Court',
     'Windsor County Superior Court Rules',
     'Windsor County Superior Court',
     'Windsor Co. Super. Ct. R.',
     'https://www.vermontjudiciary.org/court-locator',
     'court_rule',
     'high',
     'Windsor County Superior Court. OFS mandatory for attorneys. WEB VERIFIED.'),
    ('county', 'VT', 'Windham', 'Superior Court',
     'Windham County Superior Court Rules',
     'Windham County Superior Court',
     'Windham Co. Super. Ct. R.',
     'https://www.vermontjudiciary.org/court-locator',
     'court_rule',
     'high',
     'Windham County Superior Court. OFS mandatory for attorneys. WEB VERIFIED.')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET base_url = EXCLUDED.base_url, notes = EXCLUDED.notes;

-- ============================================================================
-- PART 2: ADD VERMONT STATE AND COUNTY CITATIONS
-- ============================================================================

INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'statute', 'Vermont Statutes Annotated',
    '12 V.S.A. § 512',
    'https://legislature.vermont.gov/statutes/section/12/023/00512',
    'Actions for the following causes shall be commenced within three years after the cause of action accrues, and not after: (1) assault and battery; (2) false imprisonment; (3) slander and libel; (4) except as otherwise provided in this chapter, injuries to the person suffered by the act or default of another person, provided that the cause of action shall be deemed to accrue as of the date of the discovery of the injury; (5) damage to personal property suffered by the act or default of another.',
    '§ 512', NOW()::date, NOW(), 'document_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'VT' AND ls.abbreviation = '12 V.S.A.'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt,
    verifier = EXCLUDED.verifier;

-- OFS E-Filing Citation
INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'court_rule', 'Vermont Rules of Electronic Filing',
    'VT-OFS-MANDATORY-EFILING',
    'https://www.vermontjudiciary.org/about-vermont-judiciary/electronic-access/electronic-filing',
    'The Vermont Judiciary mandates the use of the Odyssey File & Serve (OFS) electronic filing system for all attorneys filing documents in Superior Courts, the Judicial Bureau, the Environmental Division, and the Supreme Court. Effective January 8, 2024, self-represented litigants may also use OFS but are not required to do so.',
    'OFS', '2024-01-08', NOW(), 'document_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'VT' AND ls.abbreviation = 'VT OFS'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt;

-- County-specific Citations
INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'local_rule', 'Chittenden County Superior Court Rules',
    'VT-CHITTENDEN-EFILING',
    'https://www.vermontjudiciary.org/about-vermont-judiciary/electronic-access/electronic-filing',
    'Chittenden County Superior Court (Burlington). Most populous county in Vermont. OFS e-filing mandatory for attorneys since January 8, 2024.',
    'E-Filing', '2024-01-08', NOW(), 'web_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'VT' AND ls.jurisdiction_county = 'Chittenden'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt;

INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'local_rule', 'Rutland County Superior Court Rules',
    'VT-RUTLAND-EFILING',
    'https://www.vermontjudiciary.org/about-vermont-judiciary/electronic-access/electronic-filing',
    'Rutland County Superior Court. OFS e-filing mandatory for attorneys since January 8, 2024.',
    'E-Filing', '2024-01-08', NOW(), 'web_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'VT' AND ls.jurisdiction_county = 'Rutland'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt;

INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'local_rule', 'Washington County Superior Court Rules',
    'VT-WASHINGTON-EFILING',
    'https://www.vermontjudiciary.org/about-vermont-judiciary/electronic-access/electronic-filing',
    'Washington County Superior Court (Montpelier - State Capital). OFS e-filing mandatory for attorneys since January 8, 2024.',
    'E-Filing', '2024-01-08', NOW(), 'web_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'VT' AND ls.jurisdiction_county = 'Washington'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt;

INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'local_rule', 'Windsor County Superior Court Rules',
    'VT-WINDSOR-EFILING',
    'https://www.vermontjudiciary.org/about-vermont-judiciary/electronic-access/electronic-filing',
    'Windsor County Superior Court. OFS e-filing mandatory for attorneys since January 8, 2024.',
    'E-Filing', '2024-01-08', NOW(), 'web_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'VT' AND ls.jurisdiction_county = 'Windsor'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt;

INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'local_rule', 'Windham County Superior Court Rules',
    'VT-WINDHAM-EFILING',
    'https://www.vermontjudiciary.org/about-vermont-judiciary/electronic-access/electronic-filing',
    'Windham County Superior Court. OFS e-filing mandatory for attorneys since January 8, 2024.',
    'E-Filing', '2024-01-08', NOW(), 'web_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'VT' AND ls.jurisdiction_county = 'Windham'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt;

-- ============================================================================
-- PART 3: ADD VERMONT VALIDATION RULES
-- ============================================================================

DO $$
DECLARE
    vt_sol_id INTEGER;
    vt_ofs_id INTEGER;
    vt_chittenden_id INTEGER;
    vt_rutland_id INTEGER;
    vt_washington_id INTEGER;
    vt_windsor_id INTEGER;
    vt_windham_id INTEGER;
BEGIN
    -- Get citation IDs
    SELECT id INTO vt_sol_id FROM leverage.rule_citations 
    WHERE citation = '12 V.S.A. § 512';
    
    SELECT id INTO vt_ofs_id FROM leverage.rule_citations 
    WHERE citation = 'VT-OFS-MANDATORY-EFILING';
    
    SELECT id INTO vt_chittenden_id FROM leverage.rule_citations 
    WHERE citation = 'VT-CHITTENDEN-EFILING';
    
    SELECT id INTO vt_rutland_id FROM leverage.rule_citations 
    WHERE citation = 'VT-RUTLAND-EFILING';
    
    SELECT id INTO vt_washington_id FROM leverage.rule_citations 
    WHERE citation = 'VT-WASHINGTON-EFILING';
    
    SELECT id INTO vt_windsor_id FROM leverage.rule_citations 
    WHERE citation = 'VT-WINDSOR-EFILING';
    
    SELECT id INTO vt_windham_id FROM leverage.rule_citations 
    WHERE citation = 'VT-WINDHAM-EFILING';

    -- VT Statewide PI SOL (3 years) - 12 V.S.A. § 512
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'VT-SOL-512-PI-3YEAR', 5, 'VT Personal Injury SOL (3 Years)', 'threshold_check',
        'personal_injury', 'complaint',
        'state', 'VT', NULL, NULL,
        '{"sol_years": 3, "sol_days": 1095, "statute": "12 V.S.A. § 512", "applies_to": ["assault_battery", "false_imprisonment", "slander_libel", "injuries_to_person", "damage_personal_property"], "discovery_rule": true, "note": "Vermont has 3-YEAR SOL for PI. Cause of action accrues on date of DISCOVERY of injury."}'::jsonb,
        'error', vt_sol_id, 'document_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id,
        review_status = EXCLUDED.review_status;

    -- VT Statewide E-Filing Rule (OFS)
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'VT-EFILING-OFS-STATEWIDE', 2, 'VT Statewide E-Filing (Odyssey File & Serve)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'VT', NULL, NULL,
        '{"requires_efiling": true, "system": "Odyssey File & Serve (OFS)", "effective_date": "2024-01-08", "mandatory_for": ["attorneys"], "self_represented_optional": true, "courts": ["Superior Courts", "Judicial Bureau", "Environmental Division", "Supreme Court"], "note": "DOCUMENT VERIFIED: OFS mandatory for attorneys since January 8, 2024."}'::jsonb,
        'error', vt_ofs_id, 'document_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id,
        review_status = EXCLUDED.review_status;

    -- County E-Filing Rules
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'VT-CHITTENDEN-EFILING', 2, 'Chittenden County E-Filing (Burlington)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'VT', 'Chittenden', 'Superior Court',
        '{"requires_efiling": true, "system": "OFS", "city": "Burlington", "most_populous": true, "effective_date": "2024-01-08", "note": "Most populous county. OFS mandatory for attorneys."}'::jsonb,
        'error', vt_chittenden_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'VT-RUTLAND-EFILING', 2, 'Rutland County E-Filing', 'format_check',
        'personal_injury', 'complaint',
        'state', 'VT', 'Rutland', 'Superior Court',
        '{"requires_efiling": true, "system": "OFS", "city": "Rutland", "effective_date": "2024-01-08", "note": "OFS mandatory for attorneys."}'::jsonb,
        'error', vt_rutland_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'VT-WASHINGTON-EFILING', 2, 'Washington County E-Filing (Montpelier)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'VT', 'Washington', 'Superior Court',
        '{"requires_efiling": true, "system": "OFS", "city": "Montpelier", "state_capital": true, "effective_date": "2024-01-08", "note": "State capital. OFS mandatory for attorneys."}'::jsonb,
        'error', vt_washington_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'VT-WINDSOR-EFILING', 2, 'Windsor County E-Filing', 'format_check',
        'personal_injury', 'complaint',
        'state', 'VT', 'Windsor', 'Superior Court',
        '{"requires_efiling": true, "system": "OFS", "effective_date": "2024-01-08", "note": "OFS mandatory for attorneys."}'::jsonb,
        'error', vt_windsor_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'VT-WINDHAM-EFILING', 2, 'Windham County E-Filing', 'format_check',
        'personal_injury', 'complaint',
        'state', 'VT', 'Windham', 'Superior Court',
        '{"requires_efiling": true, "system": "OFS", "effective_date": "2024-01-08", "note": "OFS mandatory for attorneys."}'::jsonb,
        'error', vt_windham_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Completion message
    RAISE NOTICE '========================================================================';
    RAISE NOTICE 'VERMONT (VT) PI COURT RULES SEEDED SUCCESSFULLY';
    RAISE NOTICE '========================================================================';
    RAISE NOTICE 'Vermont has 3-YEAR SOL for PI (12 V.S.A. § 512).';
    RAISE NOTICE 'Discovery rule applies - SOL accrues on date of discovery.';
    RAISE NOTICE 'OFS E-Filing MANDATORY for attorneys since January 8, 2024.';
    RAISE NOTICE '========================================================================';

END $$;

COMMIT;
