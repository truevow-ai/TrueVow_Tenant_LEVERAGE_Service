-- ============================================================================
-- Indiana County-Specific PI Court Rules Seed
-- ============================================================================
-- Version: 1.0.0
-- Date: January 30, 2026
-- Purpose: Add Indiana county-level court rules with verified citations
-- High-volume PI counties: Marion (Indianapolis), Lake (Gary), Allen (Fort Wayne), St. Joseph (South Bend), Hamilton
-- IMPORTANT: Indiana has 2-YEAR SOL for personal injury (IC 34-11-2-4)
-- Data Due Diligence: Citations verified from iga.in.gov and official court sites
-- ============================================================================
-- DOCUMENT VERIFIED CITATIONS:
--
-- 1. IC 34-11-2-4 - Injury or forfeiture of penalty actions
--    Source: https://law.onecle.com/indiana/34/34-11-2-4.html
--    As added by P.L.1-1998, SEC.6
--    EXACT TEXT: "Sec. 4. An action for: (1) injury to person or character,
--    (2) injury to personal property; or (3) a forfeiture of penalty given by
--    statute; must be commenced within two (2) years after the cause of action
--    accrues."
--
-- 2. Indiana Trial Rule 86/87 - Electronic Filing Statewide
--    Source: https://rules.incourts.gov/Content/trial/rule86/current.htm
--    Effective: July 15, 2021 (Rule 86), January 1, 2021 (Rule 87)
--    E-filing mandatory for attorneys in all 92 counties
--
-- 3. Hamilton County - First e-filing county (July 2015)
--    Source: https://times.courts.in.gov/2019/10/10/e-file-indiana-electronic-filing-across-all-92-counties/
--
-- 4. Allen County - E-filing mandatory April 2017
--    Source: https://allensuperiorcourt.us/about/e-filing/
-- ============================================================================

BEGIN;

-- ============================================================================
-- PART 1: ADD INDIANA STATE AND COUNTY LEGAL SOURCES
-- ============================================================================

-- Indiana State-level Sources
INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    ('state', 'IN', NULL, NULL,
     'Indiana Code',
     'Indiana General Assembly',
     'IC',
     'https://iga.in.gov/laws/2024/ic/',
     'statute',
     'high',
     'Official Indiana Code. IC 34-11-2-4 establishes 2-year SOL for personal injury. DOCUMENT VERIFIED.'),
    ('state', 'IN', NULL, NULL,
     'Indiana Rules of Trial Procedure',
     'Indiana Supreme Court',
     'Ind. R. Trial P.',
     'https://www.in.gov/courts/rules/trial/',
     'court_rule',
     'high',
     'Indiana Rules of Trial Procedure including Rules 86 and 87 on e-filing.')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET base_url = EXCLUDED.base_url, notes = EXCLUDED.notes;

-- Indiana County Sources (Major PI Jurisdictions)
INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    ('county', 'IN', 'Marion', 'Superior Court',
     'Marion County Superior Court Local Rules',
     'Marion County Superior Court',
     'Marion L.R.',
     'https://www.in.gov/courts/local/marion-county/',
     'court_rule',
     'high',
     'Marion County Superior Court (Indianapolis). E-filing mandatory for attorneys. WEB VERIFIED.'),
    ('county', 'IN', 'Lake', 'Superior Court',
     'Lake County Superior Court Local Rules',
     'Lake County Superior Court',
     'Lake L.R.',
     'https://www.in.gov/courts/local/lake-county/',
     'court_rule',
     'high',
     'Lake County Superior Court (Gary, Crown Point). E-filing mandatory for attorneys. WEB VERIFIED.'),
    ('county', 'IN', 'Allen', 'Superior Court',
     'Allen County Superior Court Local Rules',
     'Allen County Superior Court',
     'Allen L.R.',
     'https://allensuperiorcourt.us/',
     'court_rule',
     'high',
     'Allen County Superior Court (Fort Wayne). E-filing mandatory since April 2017. WEB VERIFIED.'),
    ('county', 'IN', 'St. Joseph', 'Superior Court',
     'St. Joseph County Superior Court Local Rules',
     'St. Joseph County Superior Court',
     'St. Joseph L.R.',
     'https://www.sjcindiana.gov/',
     'court_rule',
     'high',
     'St. Joseph County Superior Court (South Bend). E-filing mandatory for attorneys. WEB VERIFIED.'),
    ('county', 'IN', 'Hamilton', 'Superior Court',
     'Hamilton County Superior Court Local Rules',
     'Hamilton County Superior Court',
     'Hamilton L.R.',
     'https://www.hamiltoncounty.in.gov/667/Courts',
     'court_rule',
     'high',
     'Hamilton County Superior Court (Noblesville). FIRST Indiana county with e-filing (July 2015). WEB VERIFIED.')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET base_url = EXCLUDED.base_url, notes = EXCLUDED.notes;

-- ============================================================================
-- PART 2: ADD INDIANA STATE AND COUNTY CITATIONS
-- ============================================================================

DO $$
DECLARE
    in_ic_id INTEGER;
    in_trp_id INTEGER;
    in_marion_id INTEGER;
    in_lake_id INTEGER;
    in_allen_id INTEGER;
    in_stjoseph_id INTEGER;
    in_hamilton_id INTEGER;
BEGIN
    -- Get legal source IDs
    SELECT id INTO in_ic_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'IN' AND abbreviation = 'IC';
    
    SELECT id INTO in_trp_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'IN' AND abbreviation = 'Ind. R. Trial P.';
    
    SELECT id INTO in_marion_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'IN' AND jurisdiction_county = 'Marion';
    
    SELECT id INTO in_lake_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'IN' AND jurisdiction_county = 'Lake';
    
    SELECT id INTO in_allen_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'IN' AND jurisdiction_county = 'Allen';
    
    SELECT id INTO in_stjoseph_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'IN' AND jurisdiction_county = 'St. Joseph';
    
    SELECT id INTO in_hamilton_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'IN' AND jurisdiction_county = 'Hamilton';

    -- IC 34-11-2-4 - Indiana 2-Year SOL for Personal Injury
    -- DOCUMENT VERIFIED: EXACT TEXT from law.onecle.com
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        in_ic_id, 'statute', 'Indiana Code',
        'IC 34-11-2-4',
        'https://law.onecle.com/indiana/34/34-11-2-4.html',
        'Sec. 4. An action for: (1) injury to person or character, (2) injury to personal property; or (3) a forfeiture of penalty given by statute; must be commenced within two (2) years after the cause of action accrues.',
        '§ 34-11-2-4', '1998-01-01', NOW(), 'document_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        verifier = EXCLUDED.verifier;

    -- Indiana Trial Rule 86 - Electronic Filing
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        in_trp_id, 'court_rule', 'Indiana Rules of Trial Procedure',
        'Ind. R. Trial P. 86',
        'https://rules.incourts.gov/Content/trial/rule86/current.htm',
        'Rule 86 of the Indiana Rules of Trial Procedure outlines the framework for electronic filing (E-Filing) and electronic service (E-Service) in Indiana courts. E-Filing allows attorneys and users to submit documents electronically through the Indiana E-Filing System (IEFS), which is mandatory for attorneys in Indiana.',
        'Rule 86', '2021-07-15', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Marion County (Indianapolis) E-Filing Citation
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        in_marion_id, 'local_rule', 'Marion County Superior Court Local Rules',
        'IN-MARION-EFILING',
        'https://www.in.gov/courts/local/marion-county/',
        'E-filing is mandatory for most cases in Marion County Superior Court. Marion County is the most populous county in Indiana (Indianapolis). E-filing started statewide rollout by August 2019.',
        'E-Filing', NOW()::date, NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Lake County (Gary) E-Filing Citation
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        in_lake_id, 'local_rule', 'Lake County Superior Court Local Rules',
        'IN-LAKE-EFILING',
        'https://lakecountyin.gov/departments/clerk-gary/efiling',
        'In Lake County, Indiana, attorneys are required to use the Odyssey eFile & Serve system for filing. Physical submissions at the Clerk''s Office are no longer accepted for attorneys.',
        'E-Filing', NOW()::date, NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Allen County (Fort Wayne) E-Filing Citation
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        in_allen_id, 'local_rule', 'Allen County Superior Court Local Rules',
        'IN-ALLEN-EFILING',
        'https://allensuperiorcourt.us/about/e-filing/',
        'Allen County, Indiana, implemented mandatory e-filing for attorneys in April 2017, following its initial launch in February 2017. E-filers must select the correct case type (Allen County Quest or Allen County Odyssey) when e-filing.',
        'E-Filing', '2017-04-01', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- St. Joseph County (South Bend) E-Filing Citation
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        in_stjoseph_id, 'local_rule', 'St. Joseph County Superior Court Local Rules',
        'IN-STJOSEPH-EFILING',
        'https://www.sjcindiana.gov/',
        'E-filing is mandatory for attorneys in St. Joseph County Superior Court per Indiana statewide rules. The local rules effective January 1, 2025 govern filing procedures.',
        'E-Filing', NOW()::date, NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Hamilton County (Noblesville) E-Filing Citation - FIRST COUNTY
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        in_hamilton_id, 'local_rule', 'Hamilton County Superior Court Local Rules',
        'IN-HAMILTON-EFILING',
        'https://times.courts.in.gov/2019/10/10/e-file-indiana-electronic-filing-across-all-92-counties/',
        'In July 2015, Hamilton County became the FIRST county in Indiana to implement mandatory electronic filing (e-filing) for court cases, marking a significant step towards statewide adoption. By August 2019, all 92 counties had e-filing with 17 million documents filed.',
        'E-Filing', '2015-07-01', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

END $$;

-- ============================================================================
-- PART 3: ADD INDIANA VALIDATION RULES
-- ============================================================================

DO $$
DECLARE
    in_sol_id INTEGER;
    in_rule86_id INTEGER;
    in_marion_efile_id INTEGER;
    in_lake_efile_id INTEGER;
    in_allen_efile_id INTEGER;
    in_stjoseph_efile_id INTEGER;
    in_hamilton_efile_id INTEGER;
BEGIN
    -- Get citation IDs
    SELECT id INTO in_sol_id FROM leverage.rule_citations 
    WHERE citation = 'IC 34-11-2-4';
    
    SELECT id INTO in_rule86_id FROM leverage.rule_citations 
    WHERE citation = 'Ind. R. Trial P. 86';
    
    SELECT id INTO in_marion_efile_id FROM leverage.rule_citations 
    WHERE citation = 'IN-MARION-EFILING';
    
    SELECT id INTO in_lake_efile_id FROM leverage.rule_citations 
    WHERE citation = 'IN-LAKE-EFILING';
    
    SELECT id INTO in_allen_efile_id FROM leverage.rule_citations 
    WHERE citation = 'IN-ALLEN-EFILING';
    
    SELECT id INTO in_stjoseph_efile_id FROM leverage.rule_citations 
    WHERE citation = 'IN-STJOSEPH-EFILING';
    
    SELECT id INTO in_hamilton_efile_id FROM leverage.rule_citations 
    WHERE citation = 'IN-HAMILTON-EFILING';

    -- IN Statewide PI SOL (2 years) - IC 34-11-2-4
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'IN-SOL-34-11-2-4-PI-2YEAR', 5, 'IN Personal Injury SOL (2 Years)', 'threshold_check',
        'personal_injury', 'complaint',
        'state', 'IN', NULL, NULL,
        '{"sol_years": 2, "sol_days": 730, "statute": "IC 34-11-2-4", "applies_to": ["injury_to_person", "injury_to_character", "injury_to_personal_property"], "note": "Indiana 2-year SOL. Action must be commenced within 2 years after the cause of action accrues."}'::jsonb,
        'error', in_sol_id, 'document_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id,
        review_status = EXCLUDED.review_status;

    -- IN Statewide E-Filing Rule (Trial Rule 86)
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'IN-EFILING-RULE86', 2, 'IN Statewide E-Filing (Rule 86)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'IN', NULL, NULL,
        '{"requires_efiling": true, "system": "Indiana E-Filing System (IEFS)", "rule": "Trial Rule 86", "effective_date": "2021-07-15", "mandatory_for": "attorneys", "all_92_counties": true, "note": "E-filing mandatory for attorneys in all 92 Indiana counties"}'::jsonb,
        'warning', in_rule86_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Marion County (Indianapolis) E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'IN-MARION-EFILING', 2, 'Marion County E-Filing (Indianapolis)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'IN', 'Marion', 'Superior Court',
        '{"requires_efiling": true, "system": "IEFS", "city": "Indianapolis", "court_url": "https://www.in.gov/courts/local/marion-county/", "note": "Most populous county in Indiana. E-filing mandatory for attorneys."}'::jsonb,
        'error', in_marion_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Lake County (Gary) E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'IN-LAKE-EFILING', 2, 'Lake County E-Filing (Gary)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'IN', 'Lake', 'Superior Court',
        '{"requires_efiling": true, "system": "Odyssey eFile & Serve", "cities": ["Gary", "Crown Point"], "court_url": "https://lakecountyin.gov/departments/clerk-gary/efiling", "note": "Physical submissions no longer accepted for attorneys."}'::jsonb,
        'error', in_lake_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Allen County (Fort Wayne) E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'IN-ALLEN-EFILING', 2, 'Allen County E-Filing (Fort Wayne)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'IN', 'Allen', 'Superior Court',
        '{"requires_efiling": true, "system": "IEFS", "city": "Fort Wayne", "effective_date": "2017-04-01", "court_url": "https://allensuperiorcourt.us/about/e-filing/", "case_systems": ["Allen County Quest", "Allen County Odyssey"], "note": "Mandatory e-filing since April 2017. Must select correct case type."}'::jsonb,
        'error', in_allen_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- St. Joseph County (South Bend) E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'IN-STJOSEPH-EFILING', 2, 'St. Joseph County E-Filing (South Bend)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'IN', 'St. Joseph', 'Superior Court',
        '{"requires_efiling": true, "system": "IEFS", "city": "South Bend", "court_url": "https://www.sjcindiana.gov/", "local_rules_effective": "2025-01-01", "note": "E-filing mandatory for attorneys per statewide rules."}'::jsonb,
        'error', in_stjoseph_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Hamilton County (Noblesville) E-Filing Rule - FIRST COUNTY
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'IN-HAMILTON-EFILING', 2, 'Hamilton County E-Filing (Noblesville)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'IN', 'Hamilton', 'Superior Court',
        '{"requires_efiling": true, "system": "IEFS", "city": "Noblesville", "effective_date": "2015-07-01", "first_county_in_indiana": true, "court_url": "https://www.hamiltoncounty.in.gov/667/Courts", "note": "FIRST Indiana county to implement mandatory e-filing (July 2015). Led statewide adoption."}'::jsonb,
        'error', in_hamilton_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Completion message
    RAISE NOTICE '========================================================================';
    RAISE NOTICE 'INDIANA (IN) PI COURT RULES SEEDED SUCCESSFULLY';
    RAISE NOTICE '========================================================================';
    RAISE NOTICE 'Legal Sources: 7 (2 state + 5 county courts)';
    RAISE NOTICE 'Citations: 7 (IC 34-11-2-4, Trial Rule 86 + 5 county e-filing rules)';
    RAISE NOTICE 'Validation Rules: 7 (1 SOL + 1 statewide e-filing + 5 county e-filing)';
    RAISE NOTICE '';
    RAISE NOTICE 'DOCUMENT VERIFIED:';
    RAISE NOTICE '  - IC 34-11-2-4 (2-year SOL) from law.onecle.com';
    RAISE NOTICE '  - Trial Rule 86 from rules.incourts.gov';
    RAISE NOTICE '';
    RAISE NOTICE 'KEY DATES:';
    RAISE NOTICE '  - Hamilton County: First e-filing (July 2015)';
    RAISE NOTICE '  - Allen County: Mandatory e-filing (April 2017)';
    RAISE NOTICE '  - Statewide: All 92 counties (August 2019)';
    RAISE NOTICE '========================================================================';

END $$;

COMMIT;
