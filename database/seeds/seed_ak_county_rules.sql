-- ============================================================================
-- Alaska County-Specific PI Court Rules Seed
-- ============================================================================
-- Version: 1.0.0
-- Date: January 30, 2026
-- Purpose: Add Alaska court rules with verified citations
-- High-volume PI areas: Anchorage, Fairbanks North Star, Juneau, Mat-Su, Kenai Peninsula
-- Alaska has 2-YEAR SOL for personal injury
-- Data Due Diligence: Citations verified from touchngo.com/lglcntr/akstats and courts.alaska.gov
-- ============================================================================
-- DOCUMENT VERIFIED CITATIONS:
--
-- 1. Alaska Statutes § 09.10.070 - Actions for Torts, Personal Injury (2 Years)
--    Source: https://touchngo.com/lglcntr/akstats/statutes/Title09/Chapter10/Section070.htm
--    EXACT TEXT: "Except as otherwise provided by law, a person may not bring an 
--    action (1) for libel, slander, assault, battery, seduction, or false imprisonment, 
--    (2) for personal injury or death, or injury to the rights of another, not arising 
--    on contract and not specifically provided otherwise; (3) for taking, detaining, 
--    or injuring personal property, including an action for its specific recovery; ... 
--    unless commenced within two years of the accrual of the cause of action."
--
-- 2. TrueFiling E-Filing System - Mandatory
--    Source: https://courts.alaska.gov/efile/index.htm
--    Administrative Bulletin 92 (Revised October 3, 2025, Effective October 1, 2025)
--    IMPLEMENTATION DATES (verified from official court system page):
--    - Civil & Small Claims: June 16, 2025 (most courts)
--    - Anchorage, Sand Point, Saint Paul: September 22, 2025
--    - Palmer: August 18, 2025
--    - Criminal/Minor Offense: Various dates from 2019-2024
-- ============================================================================

BEGIN;

-- ============================================================================
-- PART 1: ADD ALASKA STATE AND COURT LEGAL SOURCES
-- ============================================================================

-- Alaska State-level Sources
INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    ('state', 'AK', NULL, NULL,
     'Alaska Statutes',
     'Alaska State Legislature',
     'AS',
     'https://touchngo.com/lglcntr/akstats/statutes/',
     'statute',
     'high',
     'Official Alaska Statutes. Section 09.10.070 establishes 2-year SOL for personal injury. DOCUMENT VERIFIED.'),
    ('state', 'AK', NULL, NULL,
     'Alaska Court System TrueFiling Rules',
     'Alaska Court System',
     'AK TrueFiling',
     'https://courts.alaska.gov/efile/',
     'court_rule',
     'high',
     'TrueFiling electronic filing system. Administrative Bulletin 92. E-Filing MANDATORY effective October 1, 2025.')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET base_url = EXCLUDED.base_url, notes = EXCLUDED.notes;

-- Alaska Court Location Sources (Major PI Jurisdictions - by Borough/Municipality)
INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    ('county', 'AK', 'Anchorage', 'Anchorage Superior Court',
     'Anchorage Court Rules',
     'Anchorage Superior Court',
     'Anchorage Ct. R.',
     'https://courts.alaska.gov/courtdir/3an.htm',
     'court_rule',
     'high',
     'Anchorage Superior Court. Most populous. TrueFiling Civil/Small Claims mandatory September 22, 2025. WEB VERIFIED.'),
    ('county', 'AK', 'Fairbanks North Star', 'Fairbanks Superior Court',
     'Fairbanks Court Rules',
     'Fairbanks Superior Court',
     'Fairbanks Ct. R.',
     'https://courts.alaska.gov/courtdir/4fa.htm',
     'court_rule',
     'high',
     'Fairbanks Superior Court. Second largest city. TrueFiling Civil/Small Claims mandatory June 16, 2025. WEB VERIFIED.'),
    ('county', 'AK', 'Juneau', 'Juneau Superior Court',
     'Juneau Court Rules',
     'Juneau Superior Court',
     'Juneau Ct. R.',
     'https://courts.alaska.gov/courtdir/1ju.htm',
     'court_rule',
     'high',
     'Juneau Superior Court. State capital. TrueFiling Civil/Small Claims mandatory June 16, 2025. WEB VERIFIED.'),
    ('county', 'AK', 'Matanuska-Susitna', 'Palmer Superior Court',
     'Palmer Court Rules (Mat-Su)',
     'Palmer Superior Court',
     'Palmer Ct. R.',
     'https://courts.alaska.gov/courtdir/3pa.htm',
     'court_rule',
     'high',
     'Palmer Superior Court (Matanuska-Susitna Borough). Fast-growing region. TrueFiling Civil mandatory August 18, 2025. WEB VERIFIED.'),
    ('county', 'AK', 'Kenai Peninsula', 'Kenai Superior Court',
     'Kenai Court Rules',
     'Kenai Superior Court',
     'Kenai Ct. R.',
     'https://courts.alaska.gov/courtdir/3ke.htm',
     'court_rule',
     'high',
     'Kenai Superior Court (Kenai Peninsula Borough). TrueFiling Civil/Small Claims mandatory June 16, 2025. WEB VERIFIED.')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET base_url = EXCLUDED.base_url, notes = EXCLUDED.notes;

-- ============================================================================
-- PART 2: ADD ALASKA STATE AND COURT CITATIONS
-- ============================================================================

INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'statute', 'Alaska Statutes',
    'AS § 09.10.070',
    'https://touchngo.com/lglcntr/akstats/statutes/Title09/Chapter10/Section070.htm',
    'Except as otherwise provided by law, a person may not bring an action (1) for libel, slander, assault, battery, seduction, or false imprisonment, (2) for personal injury or death, or injury to the rights of another, not arising on contract and not specifically provided otherwise; (3) for taking, detaining, or injuring personal property, including an action for its specific recovery; unless commenced within two years of the accrual of the cause of action.',
    '§ 09.10.070', NOW()::date, NOW(), 'document_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'AK' AND ls.abbreviation = 'AS'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt,
    verifier = EXCLUDED.verifier;

-- TrueFiling E-Filing Citation
INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'court_rule', 'Alaska TrueFiling Rules',
    'AK-TRUEFILING-ADMIN-BULLETIN-92',
    'https://courts.alaska.gov/adbulls/docs/ab92.pdf',
    'Administrative Bulletin No. 92 (Revised October 3, 2025, Effective October 1, 2025): The Alaska Court System is deploying electronic filing (eFile) to courts throughout the state. In courts that have adopted eFiling, parties and attorneys file and serve documents in new and existing cases through TrueFiling, a web-based eFiling program. eFiling is mandatory at the time that it becomes available in a court location.',
    'Admin. Bull. 92', '2025-10-01', NOW(), 'document_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'AK' AND ls.abbreviation = 'AK TrueFiling'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt;

-- Court-specific Citations
INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'local_rule', 'Anchorage Court Rules',
    'AK-ANCHORAGE-EFILING',
    'https://courts.alaska.gov/efile/index.htm',
    'Anchorage Court. TrueFiling Civil & Small Claims mandatory September 22, 2025. Criminal eFiling: Minor Offense August 21, 2023; Criminal January 1, 2024. Most populous jurisdiction in Alaska.',
    'E-Filing', '2025-09-22', NOW(), 'web_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'AK' AND ls.jurisdiction_county = 'Anchorage'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt;

INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'local_rule', 'Fairbanks Court Rules',
    'AK-FAIRBANKS-EFILING',
    'https://courts.alaska.gov/efile/index.htm',
    'Fairbanks Court. TrueFiling Civil & Small Claims mandatory June 16, 2025. Criminal eFiling: Minor Offense March 3, 2022; Criminal October 30, 2023.',
    'E-Filing', '2025-06-16', NOW(), 'web_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'AK' AND ls.jurisdiction_county = 'Fairbanks North Star'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt;

INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'local_rule', 'Juneau Court Rules',
    'AK-JUNEAU-EFILING',
    'https://courts.alaska.gov/efile/index.htm',
    'Juneau Court (State Capital). TrueFiling Civil & Small Claims mandatory June 16, 2025. Criminal eFiling September 18, 2023.',
    'E-Filing', '2025-06-16', NOW(), 'web_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'AK' AND ls.jurisdiction_county = 'Juneau'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt;

INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'local_rule', 'Palmer Court Rules',
    'AK-PALMER-EFILING',
    'https://courts.alaska.gov/efile/index.htm',
    'Palmer Court (Matanuska-Susitna Borough). TrueFiling Civil & Small Claims mandatory August 18, 2025. Criminal eFiling: Minor Offense August 21, 2023; Criminal January 1, 2024. Fast-growing region.',
    'E-Filing', '2025-08-18', NOW(), 'web_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'AK' AND ls.jurisdiction_county = 'Matanuska-Susitna'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt;

INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'local_rule', 'Kenai Court Rules',
    'AK-KENAI-EFILING',
    'https://courts.alaska.gov/efile/index.htm',
    'Kenai Court (Kenai Peninsula Borough). TrueFiling Civil & Small Claims mandatory June 16, 2025. Criminal eFiling May 8, 2019.',
    'E-Filing', '2025-06-16', NOW(), 'web_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'AK' AND ls.jurisdiction_county = 'Kenai Peninsula'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt;

-- ============================================================================
-- PART 3: ADD ALASKA VALIDATION RULES
-- ============================================================================

DO $$
DECLARE
    ak_sol_id INTEGER;
    ak_truefiling_id INTEGER;
    ak_anchorage_id INTEGER;
    ak_fairbanks_id INTEGER;
    ak_juneau_id INTEGER;
    ak_palmer_id INTEGER;
    ak_kenai_id INTEGER;
BEGIN
    -- Get citation IDs
    SELECT id INTO ak_sol_id FROM leverage.rule_citations 
    WHERE citation = 'AS § 09.10.070';
    
    SELECT id INTO ak_truefiling_id FROM leverage.rule_citations 
    WHERE citation = 'AK-TRUEFILING-ADMIN-BULLETIN-92';
    
    SELECT id INTO ak_anchorage_id FROM leverage.rule_citations 
    WHERE citation = 'AK-ANCHORAGE-EFILING';
    
    SELECT id INTO ak_fairbanks_id FROM leverage.rule_citations 
    WHERE citation = 'AK-FAIRBANKS-EFILING';
    
    SELECT id INTO ak_juneau_id FROM leverage.rule_citations 
    WHERE citation = 'AK-JUNEAU-EFILING';
    
    SELECT id INTO ak_palmer_id FROM leverage.rule_citations 
    WHERE citation = 'AK-PALMER-EFILING';
    
    SELECT id INTO ak_kenai_id FROM leverage.rule_citations 
    WHERE citation = 'AK-KENAI-EFILING';

    -- AK Statewide PI SOL (2 years) - AS § 09.10.070
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'AK-SOL-09-10-070-PI-2YEAR', 5, 'AK Personal Injury SOL (2 Years)', 'threshold_check',
        'personal_injury', 'complaint',
        'state', 'AK', NULL, NULL,
        '{"sol_years": 2, "sol_days": 730, "statute": "AS § 09.10.070", "applies_to": ["libel", "slander", "assault", "battery", "personal_injury", "death", "injury_to_personal_property"], "note": "Alaska has 2-YEAR SOL for PI. Actions for personal injury or death must be commenced within 2 years of accrual."}'::jsonb,
        'error', ak_sol_id, 'document_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id,
        review_status = EXCLUDED.review_status;

    -- AK Statewide E-Filing Rule (TrueFiling)
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'AK-EFILING-TRUEFILING-STATEWIDE', 2, 'AK Statewide E-Filing (TrueFiling)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'AK', NULL, NULL,
        '{"requires_efiling": true, "system": "TrueFiling", "authority": "Administrative Bulletin 92", "effective_date": "2025-10-01", "civil_implementation": {"most_courts": "2025-06-16", "anchorage": "2025-09-22", "palmer": "2025-08-18"}, "note": "DOCUMENT VERIFIED: TrueFiling mandatory per Admin. Bulletin 92 effective October 1, 2025."}'::jsonb,
        'error', ak_truefiling_id, 'document_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id,
        review_status = EXCLUDED.review_status;

    -- Anchorage E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'AK-ANCHORAGE-EFILING', 2, 'Anchorage E-Filing (TrueFiling)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'AK', 'Anchorage', 'Anchorage Superior Court',
        '{"requires_efiling": true, "system": "TrueFiling", "city": "Anchorage", "effective_date_civil": "2025-09-22", "effective_date_criminal": "2024-01-01", "most_populous": true, "note": "Most populous jurisdiction. Civil eFiling September 22, 2025."}'::jsonb,
        'error', ak_anchorage_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Fairbanks E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'AK-FAIRBANKS-EFILING', 2, 'Fairbanks E-Filing (TrueFiling)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'AK', 'Fairbanks North Star', 'Fairbanks Superior Court',
        '{"requires_efiling": true, "system": "TrueFiling", "city": "Fairbanks", "effective_date_civil": "2025-06-16", "effective_date_criminal": "2023-10-30", "note": "Second largest city. Civil eFiling June 16, 2025."}'::jsonb,
        'error', ak_fairbanks_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Juneau E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'AK-JUNEAU-EFILING', 2, 'Juneau E-Filing (TrueFiling)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'AK', 'Juneau', 'Juneau Superior Court',
        '{"requires_efiling": true, "system": "TrueFiling", "city": "Juneau", "state_capital": true, "effective_date_civil": "2025-06-16", "effective_date_criminal": "2023-09-18", "note": "State capital. Civil eFiling June 16, 2025."}'::jsonb,
        'error', ak_juneau_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Palmer (Mat-Su) E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'AK-PALMER-EFILING', 2, 'Palmer E-Filing (Mat-Su Borough)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'AK', 'Matanuska-Susitna', 'Palmer Superior Court',
        '{"requires_efiling": true, "system": "TrueFiling", "city": "Palmer", "borough": "Matanuska-Susitna", "effective_date_civil": "2025-08-18", "effective_date_criminal": "2024-01-01", "fast_growing": true, "note": "Fast-growing region. Civil eFiling August 18, 2025."}'::jsonb,
        'error', ak_palmer_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Kenai E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'AK-KENAI-EFILING', 2, 'Kenai E-Filing (Kenai Peninsula)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'AK', 'Kenai Peninsula', 'Kenai Superior Court',
        '{"requires_efiling": true, "system": "TrueFiling", "city": "Kenai", "borough": "Kenai Peninsula", "effective_date_civil": "2025-06-16", "effective_date_criminal": "2019-05-08", "note": "Civil eFiling June 16, 2025."}'::jsonb,
        'error', ak_kenai_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Completion message
    RAISE NOTICE '========================================================================';
    RAISE NOTICE 'ALASKA (AK) PI COURT RULES SEEDED SUCCESSFULLY';
    RAISE NOTICE '========================================================================';
    RAISE NOTICE 'Alaska has 2-YEAR SOL for PI (AS § 09.10.070).';
    RAISE NOTICE 'TrueFiling E-Filing MANDATORY per Admin. Bulletin 92 effective Oct 1, 2025.';
    RAISE NOTICE '========================================================================';

END $$;

COMMIT;
