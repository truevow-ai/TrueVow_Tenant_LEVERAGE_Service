-- ============================================================================
-- New Hampshire County-Specific PI Court Rules Seed
-- ============================================================================
-- Version: 1.0.0
-- Date: January 30, 2026
-- Purpose: Add New Hampshire county-level court rules with verified citations
-- High-volume PI counties: Hillsborough (Manchester/Nashua), Rockingham (Salem), Merrimack (Concord), Strafford, Grafton
-- New Hampshire has 3-YEAR SOL for personal injury
-- Data Due Diligence: Citations verified from gencourt.state.nh.us and courts.nh.gov
-- ============================================================================
-- DOCUMENT VERIFIED CITATIONS:
--
-- 1. New Hampshire RSA 508:4 - Personal Actions
--    Source: https://gencourt.state.nh.us/rsa/html/LII/508/508-mrg.htm
--    EXACT TEXT: "Except as otherwise provided by law, all personal actions, except 
--    actions for slander or libel, may be brought only within 3 years of the act or 
--    omission complained of, except that when the injury and its causal relationship 
--    to the act or omission were not discovered and could not reasonably have been 
--    discovered at the time of the act or omission, the action shall be commenced 
--    within 3 years of the time the plaintiff discovers, or in the exercise of 
--    reasonable diligence should have discovered, the injury and its causal 
--    relationship to the act or omission complained of."
--
-- 2. NH e-Court Program - Mandatory E-Filing
--    Source: https://www.courts.nh.gov/resources/electronic-services/ecourt-program/overview
--    IMPLEMENTATION DATES (verified from official court system):
--    - Superior Court civil: September 19, 2018 (attorneys mandatory)
--    - Supreme Court: August 2018 (attorneys mandatory)
--    - Self-represented parties: January 2020
-- ============================================================================

BEGIN;

-- ============================================================================
-- PART 1: ADD NEW HAMPSHIRE STATE AND COUNTY LEGAL SOURCES
-- ============================================================================

-- New Hampshire State-level Sources
INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    ('state', 'NH', NULL, NULL,
     'New Hampshire Revised Statutes Annotated',
     'New Hampshire General Court',
     'RSA',
     'https://gencourt.state.nh.us/rsa/html/',
     'statute',
     'high',
     'Official New Hampshire Revised Statutes. Section 508:4 establishes 3-year SOL for personal actions. DOCUMENT VERIFIED.'),
    ('state', 'NH', NULL, NULL,
     'New Hampshire Rules of Electronic Filing',
     'New Hampshire Judicial Branch',
     'NH e-Court',
     'https://www.courts.nh.gov/resources/electronic-services/',
     'court_rule',
     'high',
     'NH e-Court Program. E-Filing MANDATORY for attorneys in Superior Court since September 19, 2018.')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET base_url = EXCLUDED.base_url, notes = EXCLUDED.notes;

-- New Hampshire County Sources (Major PI Jurisdictions)
INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    ('county', 'NH', 'Hillsborough', 'Superior Court',
     'Hillsborough County Superior Court Rules',
     'Hillsborough County Superior Court',
     'Hillsborough Co. Super. Ct. R.',
     'https://www.courts.nh.gov/court-locations/hillsborough-county',
     'court_rule',
     'high',
     'Hillsborough County Superior Court (Manchester, Nashua). Most populous county. E-Filing mandatory for attorneys. WEB VERIFIED.'),
    ('county', 'NH', 'Rockingham', 'Superior Court',
     'Rockingham County Superior Court Rules',
     'Rockingham County Superior Court',
     'Rockingham Co. Super. Ct. R.',
     'https://www.courts.nh.gov/court-locations/rockingham-county',
     'court_rule',
     'high',
     'Rockingham County Superior Court (Brentwood). E-Filing mandatory for attorneys. WEB VERIFIED.'),
    ('county', 'NH', 'Merrimack', 'Superior Court',
     'Merrimack County Superior Court Rules',
     'Merrimack County Superior Court',
     'Merrimack Co. Super. Ct. R.',
     'https://www.courts.nh.gov/court-locations/merrimack-county',
     'court_rule',
     'high',
     'Merrimack County Superior Court (Concord - State Capital). E-Filing mandatory for attorneys. WEB VERIFIED.'),
    ('county', 'NH', 'Strafford', 'Superior Court',
     'Strafford County Superior Court Rules',
     'Strafford County Superior Court',
     'Strafford Co. Super. Ct. R.',
     'https://www.courts.nh.gov/court-locations/strafford-county',
     'court_rule',
     'high',
     'Strafford County Superior Court (Dover). E-Filing mandatory for attorneys. WEB VERIFIED.'),
    ('county', 'NH', 'Grafton', 'Superior Court',
     'Grafton County Superior Court Rules',
     'Grafton County Superior Court',
     'Grafton Co. Super. Ct. R.',
     'https://www.courts.nh.gov/court-locations/grafton-county',
     'court_rule',
     'high',
     'Grafton County Superior Court (North Haverhill). E-Filing mandatory for attorneys. WEB VERIFIED.')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET base_url = EXCLUDED.base_url, notes = EXCLUDED.notes;

-- ============================================================================
-- PART 2: ADD NEW HAMPSHIRE STATE AND COUNTY CITATIONS
-- ============================================================================

INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'statute', 'New Hampshire Revised Statutes',
    'RSA 508:4',
    'https://gencourt.state.nh.us/rsa/html/LII/508/508-mrg.htm',
    'Except as otherwise provided by law, all personal actions, except actions for slander or libel, may be brought only within 3 years of the act or omission complained of, except that when the injury and its causal relationship to the act or omission were not discovered and could not reasonably have been discovered at the time of the act or omission, the action shall be commenced within 3 years of the time the plaintiff discovers, or in the exercise of reasonable diligence should have discovered, the injury and its causal relationship to the act or omission complained of.',
    '508:4', NOW()::date, NOW(), 'document_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'NH' AND ls.abbreviation = 'RSA'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt,
    verifier = EXCLUDED.verifier;

-- NH e-Court E-Filing Citation
INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'court_rule', 'New Hampshire e-Court Rules',
    'NH-ECOURT-MANDATORY-EFILING',
    'https://www.courts.nh.gov/resources/electronic-services/ecourt-program/overview',
    'The NH e-Court Program, initiated by the New Hampshire Judicial Branch (NHJB) in 2012, implemented mandatory e-filing for attorneys in Superior Court civil cases starting September 19, 2018. By early August 2018, e-filing became mandatory for attorneys in the Supreme Court. Self-represented parties were required to register as e-filers starting January 2020.',
    'e-Court', '2018-09-19', NOW(), 'document_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'NH' AND ls.abbreviation = 'NH e-Court'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt;

-- County-specific Citations
INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'local_rule', 'Hillsborough County Superior Court Rules',
    'NH-HILLSBOROUGH-EFILING',
    'https://www.courts.nh.gov/resources/electronic-services/superior-court/attorneys',
    'Hillsborough County Superior Court (Manchester, Nashua). Most populous county in New Hampshire. E-Filing mandatory for all new civil cases for attorneys since September 19, 2018.',
    'E-Filing', '2018-09-19', NOW(), 'web_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'NH' AND ls.jurisdiction_county = 'Hillsborough'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt;

INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'local_rule', 'Rockingham County Superior Court Rules',
    'NH-ROCKINGHAM-EFILING',
    'https://www.courts.nh.gov/resources/electronic-services/superior-court/attorneys',
    'Rockingham County Superior Court (Brentwood). E-Filing mandatory for all new civil cases for attorneys since September 19, 2018.',
    'E-Filing', '2018-09-19', NOW(), 'web_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'NH' AND ls.jurisdiction_county = 'Rockingham'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt;

INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'local_rule', 'Merrimack County Superior Court Rules',
    'NH-MERRIMACK-EFILING',
    'https://www.courts.nh.gov/resources/electronic-services/superior-court/attorneys',
    'Merrimack County Superior Court (Concord - State Capital). E-Filing mandatory for all new civil cases for attorneys since September 19, 2018.',
    'E-Filing', '2018-09-19', NOW(), 'web_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'NH' AND ls.jurisdiction_county = 'Merrimack'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt;

INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'local_rule', 'Strafford County Superior Court Rules',
    'NH-STRAFFORD-EFILING',
    'https://www.courts.nh.gov/resources/electronic-services/superior-court/attorneys',
    'Strafford County Superior Court (Dover). E-Filing mandatory for all new civil cases for attorneys since September 19, 2018.',
    'E-Filing', '2018-09-19', NOW(), 'web_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'NH' AND ls.jurisdiction_county = 'Strafford'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt;

INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'local_rule', 'Grafton County Superior Court Rules',
    'NH-GRAFTON-EFILING',
    'https://www.courts.nh.gov/resources/electronic-services/superior-court/attorneys',
    'Grafton County Superior Court (North Haverhill). E-Filing mandatory for all new civil cases for attorneys since September 19, 2018.',
    'E-Filing', '2018-09-19', NOW(), 'web_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'NH' AND ls.jurisdiction_county = 'Grafton'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt;

-- ============================================================================
-- PART 3: ADD NEW HAMPSHIRE VALIDATION RULES
-- ============================================================================

DO $$
DECLARE
    nh_sol_id INTEGER;
    nh_ecourt_id INTEGER;
    nh_hillsborough_id INTEGER;
    nh_rockingham_id INTEGER;
    nh_merrimack_id INTEGER;
    nh_strafford_id INTEGER;
    nh_grafton_id INTEGER;
BEGIN
    -- Get citation IDs
    SELECT id INTO nh_sol_id FROM leverage.rule_citations 
    WHERE citation = 'RSA 508:4';
    
    SELECT id INTO nh_ecourt_id FROM leverage.rule_citations 
    WHERE citation = 'NH-ECOURT-MANDATORY-EFILING';
    
    SELECT id INTO nh_hillsborough_id FROM leverage.rule_citations 
    WHERE citation = 'NH-HILLSBOROUGH-EFILING';
    
    SELECT id INTO nh_rockingham_id FROM leverage.rule_citations 
    WHERE citation = 'NH-ROCKINGHAM-EFILING';
    
    SELECT id INTO nh_merrimack_id FROM leverage.rule_citations 
    WHERE citation = 'NH-MERRIMACK-EFILING';
    
    SELECT id INTO nh_strafford_id FROM leverage.rule_citations 
    WHERE citation = 'NH-STRAFFORD-EFILING';
    
    SELECT id INTO nh_grafton_id FROM leverage.rule_citations 
    WHERE citation = 'NH-GRAFTON-EFILING';

    -- NH Statewide PI SOL (3 years) - RSA 508:4
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'NH-SOL-508-4-PI-3YEAR', 5, 'NH Personal Injury SOL (3 Years)', 'threshold_check',
        'personal_injury', 'complaint',
        'state', 'NH', NULL, NULL,
        '{"sol_years": 3, "sol_days": 1095, "statute": "RSA 508:4", "applies_to": "all_personal_actions_except_slander_libel", "discovery_rule": true, "note": "New Hampshire has 3-YEAR SOL for PI. Discovery rule applies - SOL can run from discovery date if injury not immediately apparent."}'::jsonb,
        'error', nh_sol_id, 'document_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id,
        review_status = EXCLUDED.review_status;

    -- NH Statewide E-Filing Rule (e-Court)
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'NH-EFILING-ECOURT-STATEWIDE', 2, 'NH Statewide E-Filing (e-Court)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'NH', NULL, NULL,
        '{"requires_efiling": true, "system": "NH e-Court Program", "implementation_dates": {"superior_court_civil": "2018-09-19", "supreme_court": "2018-08-01", "self_represented": "2020-01-01"}, "mandatory_for": ["attorneys"], "self_represented_required_since_2020": true, "note": "DOCUMENT VERIFIED: E-Filing mandatory for attorneys in Superior Court since September 19, 2018."}'::jsonb,
        'error', nh_ecourt_id, 'document_verified',
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
        'NH-HILLSBOROUGH-EFILING', 2, 'Hillsborough County E-Filing (Manchester/Nashua)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'NH', 'Hillsborough', 'Superior Court',
        '{"requires_efiling": true, "system": "e-Court", "cities": ["Manchester", "Nashua"], "most_populous": true, "effective_date": "2018-09-19", "note": "Most populous county. E-Filing mandatory for attorneys."}'::jsonb,
        'error', nh_hillsborough_id, 'web_verified',
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
        'NH-ROCKINGHAM-EFILING', 2, 'Rockingham County E-Filing', 'format_check',
        'personal_injury', 'complaint',
        'state', 'NH', 'Rockingham', 'Superior Court',
        '{"requires_efiling": true, "system": "e-Court", "city": "Brentwood", "effective_date": "2018-09-19", "note": "E-Filing mandatory for attorneys."}'::jsonb,
        'error', nh_rockingham_id, 'web_verified',
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
        'NH-MERRIMACK-EFILING', 2, 'Merrimack County E-Filing (Concord)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'NH', 'Merrimack', 'Superior Court',
        '{"requires_efiling": true, "system": "e-Court", "city": "Concord", "state_capital": true, "effective_date": "2018-09-19", "note": "State capital. E-Filing mandatory for attorneys."}'::jsonb,
        'error', nh_merrimack_id, 'web_verified',
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
        'NH-STRAFFORD-EFILING', 2, 'Strafford County E-Filing (Dover)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'NH', 'Strafford', 'Superior Court',
        '{"requires_efiling": true, "system": "e-Court", "city": "Dover", "effective_date": "2018-09-19", "note": "E-Filing mandatory for attorneys."}'::jsonb,
        'error', nh_strafford_id, 'web_verified',
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
        'NH-GRAFTON-EFILING', 2, 'Grafton County E-Filing', 'format_check',
        'personal_injury', 'complaint',
        'state', 'NH', 'Grafton', 'Superior Court',
        '{"requires_efiling": true, "system": "e-Court", "city": "North Haverhill", "effective_date": "2018-09-19", "note": "E-Filing mandatory for attorneys."}'::jsonb,
        'error', nh_grafton_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Completion message
    RAISE NOTICE '========================================================================';
    RAISE NOTICE 'NEW HAMPSHIRE (NH) PI COURT RULES SEEDED SUCCESSFULLY';
    RAISE NOTICE '========================================================================';
    RAISE NOTICE 'New Hampshire has 3-YEAR SOL for PI (RSA 508:4).';
    RAISE NOTICE 'Discovery rule applies - SOL can run from discovery date.';
    RAISE NOTICE 'E-Filing MANDATORY for attorneys since September 19, 2018.';
    RAISE NOTICE '========================================================================';

END $$;

COMMIT;
