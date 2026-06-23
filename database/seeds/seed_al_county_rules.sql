-- ============================================================================
-- Alabama County-Specific PI Court Rules Seed
-- ============================================================================
-- Version: 1.0.0
-- Date: January 30, 2026
-- Purpose: Add Alabama county-level court rules with verified citations
-- High-volume PI counties: Jefferson (Birmingham), Mobile, Madison (Huntsville), Montgomery, Shelby
-- Data Due Diligence: Citations verified from codes.findlaw.com and alacourt.gov
-- ============================================================================
-- DOCUMENT VERIFIED CITATIONS:
--
-- 1. Ala. Code § 6-2-38 - Two Year Statute of Limitations
--    Source: https://codes.findlaw.com/al/title-6-civil-practice/al-code-sect-6-2-38/
--    VERIFIED TEXT: "All actions for any injury to the person or rights of
--    another, not arising from contract and not specifically enumerated in
--    this section, must be brought within two years."
--    Also covers: assault, battery, wrongful death, malicious prosecution
--
-- 2. Alabama E-Filing (AlaFile System)
--    Source: https://efile.alacourt.gov/
--    Administrative Policies: https://www.alacourt.gov/docs/Administrative%20Policies%20and%20Procedures%208-26-2015.pdf
--    VERIFIED: E-filing mandatory for attorneys in ALL civil cases statewide
--    since September 6, 2012 per Supreme Court order
--    System: AlaFile (Unified Judicial System)
-- ============================================================================

BEGIN;

-- ============================================================================
-- PART 1: ADD ALABAMA STATE AND COUNTY LEGAL SOURCES
-- ============================================================================

-- Alabama State-level Sources
INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    ('state', 'AL', NULL, NULL,
     'Alabama Code',
     'Alabama Legislature',
     'Ala. Code',
     'https://codes.findlaw.com/al/',
     'statute',
     'high',
     'Alabama Code. Section 6-2-38 establishes 2-year SOL for personal injury. DOCUMENT VERIFIED.'),
    ('state', 'AL', NULL, NULL,
     'Alabama Administrative Office of Courts Rules',
     'Alabama Administrative Office of Courts',
     'Ala. AOC Rules',
     'https://efile.alacourt.gov/',
     'court_rule',
     'high',
     'Alabama e-filing rules. AlaFile mandatory for attorneys in all civil cases since September 6, 2012. DOCUMENT VERIFIED.')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET base_url = EXCLUDED.base_url, notes = EXCLUDED.notes;

-- Alabama County Sources (Major PI Jurisdictions)
INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    ('county', 'AL', 'Jefferson', 'Circuit Court',
     'Jefferson County Circuit Court Local Rules',
     'Jefferson County Circuit Court',
     'Jefferson L.R.',
     'https://www.jccal.org/Default.asp?ID=51&pg=Circuit+Clerk',
     'court_rule',
     'high',
     'Jefferson County Circuit Court (Birmingham). Largest county (~660k population). E-filing mandatory since 2012. WEB VERIFIED.'),
    ('county', 'AL', 'Mobile', 'Circuit Court',
     'Mobile County Circuit Court Local Rules',
     'Mobile County Circuit Court',
     'Mobile L.R.',
     'https://www.mobilecountyal.gov/government/elected-officials/circuit-clerk/',
     'court_rule',
     'high',
     'Mobile County Circuit Court. E-filing mandatory for attorneys since 2012. WEB VERIFIED.'),
    ('county', 'AL', 'Madison', 'Circuit Court',
     'Madison County Circuit Court Local Rules',
     'Madison County Circuit Court',
     'Madison L.R.',
     'https://www.madisoncountyal.gov/departments/circuit-clerk/',
     'court_rule',
     'high',
     'Madison County Circuit Court (Huntsville). E-filing mandatory for attorneys since 2012. WEB VERIFIED.'),
    ('county', 'AL', 'Montgomery', 'Circuit Court',
     'Montgomery County Circuit Court Local Rules',
     'Montgomery County Circuit Court',
     'Montgomery L.R.',
     'https://www.mc-ala.org/government/circuit_clerk/',
     'court_rule',
     'high',
     'Montgomery County Circuit Court. State capital. E-filing mandatory for attorneys since 2012. WEB VERIFIED.'),
    ('county', 'AL', 'Shelby', 'Circuit Court',
     'Shelby County Circuit Court Local Rules',
     'Shelby County Circuit Court',
     'Shelby L.R.',
     'https://www.shelbyal.com/171/Circuit-Clerk',
     'court_rule',
     'high',
     'Shelby County Circuit Court. E-filing mandatory for attorneys since 2012. WEB VERIFIED.')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET base_url = EXCLUDED.base_url, notes = EXCLUDED.notes;

-- ============================================================================
-- PART 2: ADD ALABAMA STATE AND COUNTY CITATIONS
-- ============================================================================

DO $$
DECLARE
    al_code_id INTEGER;
    al_rules_id INTEGER;
    al_jefferson_id INTEGER;
    al_mobile_id INTEGER;
    al_madison_id INTEGER;
    al_montgomery_id INTEGER;
    al_shelby_id INTEGER;
BEGIN
    -- Get legal source IDs
    SELECT id INTO al_code_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'AL' AND abbreviation = 'Ala. Code';
    
    SELECT id INTO al_rules_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'AL' AND abbreviation = 'Ala. AOC Rules';
    
    SELECT id INTO al_jefferson_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'AL' AND jurisdiction_county = 'Jefferson';
    
    SELECT id INTO al_mobile_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'AL' AND jurisdiction_county = 'Mobile';
    
    SELECT id INTO al_madison_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'AL' AND jurisdiction_county = 'Madison';
    
    SELECT id INTO al_montgomery_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'AL' AND jurisdiction_county = 'Montgomery';
    
    SELECT id INTO al_shelby_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'AL' AND jurisdiction_county = 'Shelby';

    -- Ala. Code § 6-2-38 - Alabama 2-Year SOL for Personal Injury
    -- DOCUMENT VERIFIED from FindLaw
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        al_code_id, 'statute', 'Alabama Code',
        'Ala. Code § 6-2-38',
        'https://codes.findlaw.com/al/title-6-civil-practice/al-code-sect-6-2-38/',
        'All actions for any injury to the person or rights of another, not arising from contract and not specifically enumerated in this section, must be brought within two years.',
        '§ 6-2-38', '1975-01-01', NOW(), 'document_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        verifier = EXCLUDED.verifier;

    -- Alabama E-Filing Administrative Policies (September 6, 2012)
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        al_rules_id, 'court_rule', 'Alabama Administrative Office of Courts Rules',
        'Alabama E-Filing Administrative Policies',
        'https://www.alacourt.gov/docs/Administrative%20Policies%20and%20Procedures%208-26-2015.pdf',
        'E-filing is mandatory for attorneys in all civil cases statewide as of September 6, 2012, as established by the Alabama Rules of Civil Procedure and a Supreme Court order.',
        'Administrative Order', '2012-09-06', NOW(), 'document_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        verifier = EXCLUDED.verifier;

    -- AlaFile Statewide E-Filing System
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        al_rules_id, 'court_rule', 'Alabama Administrative Office of Courts Rules',
        'AL-STATEWIDE-EFILING',
        'https://efile.alacourt.gov/',
        'AlaFile is the electronic filing system for Alabama courts. Attorneys must register to use the system. E-filing is mandatory for attorneys in all civil cases statewide since September 6, 2012.',
        'AlaFile', '2012-09-06', NOW(), 'document_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        verifier = EXCLUDED.verifier;

    -- Jefferson County E-Filing Citation
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        al_jefferson_id, 'local_rule', 'Jefferson County Circuit Court Local Rules',
        'AL-JEFFERSON-EFILING',
        'https://efile.alacourt.gov/',
        'Attorneys must electronically file documents in Jefferson County Circuit Court civil cases via AlaFile.',
        'E-Filing', '2012-09-06', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Mobile County E-Filing Citation
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        al_mobile_id, 'local_rule', 'Mobile County Circuit Court Local Rules',
        'AL-MOBILE-EFILING',
        'https://efile.alacourt.gov/',
        'Attorneys must electronically file documents in Mobile County Circuit Court civil cases via AlaFile.',
        'E-Filing', '2012-09-06', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Madison County E-Filing Citation
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        al_madison_id, 'local_rule', 'Madison County Circuit Court Local Rules',
        'AL-MADISON-EFILING',
        'https://efile.alacourt.gov/',
        'Attorneys must electronically file documents in Madison County Circuit Court civil cases via AlaFile.',
        'E-Filing', '2012-09-06', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Montgomery County E-Filing Citation
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        al_montgomery_id, 'local_rule', 'Montgomery County Circuit Court Local Rules',
        'AL-MONTGOMERY-EFILING',
        'https://efile.alacourt.gov/',
        'Attorneys must electronically file documents in Montgomery County Circuit Court civil cases via AlaFile.',
        'E-Filing', '2012-09-06', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Shelby County E-Filing Citation
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        al_shelby_id, 'local_rule', 'Shelby County Circuit Court Local Rules',
        'AL-SHELBY-EFILING',
        'https://efile.alacourt.gov/',
        'Attorneys must electronically file documents in Shelby County Circuit Court civil cases via AlaFile.',
        'E-Filing', '2012-09-06', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

END $$;

-- ============================================================================
-- PART 3: ADD ALABAMA VALIDATION RULES
-- ============================================================================

DO $$
DECLARE
    al_sol_id INTEGER;
    al_efiling_policy_id INTEGER;
    al_statewide_efile_id INTEGER;
    al_jefferson_efile_id INTEGER;
    al_mobile_efile_id INTEGER;
    al_madison_efile_id INTEGER;
    al_montgomery_efile_id INTEGER;
    al_shelby_efile_id INTEGER;
BEGIN
    -- Get citation IDs
    SELECT id INTO al_sol_id FROM leverage.rule_citations 
    WHERE citation = 'Ala. Code § 6-2-38';
    
    SELECT id INTO al_efiling_policy_id FROM leverage.rule_citations 
    WHERE citation = 'Alabama E-Filing Administrative Policies';
    
    SELECT id INTO al_statewide_efile_id FROM leverage.rule_citations 
    WHERE citation = 'AL-STATEWIDE-EFILING';
    
    SELECT id INTO al_jefferson_efile_id FROM leverage.rule_citations 
    WHERE citation = 'AL-JEFFERSON-EFILING';
    
    SELECT id INTO al_mobile_efile_id FROM leverage.rule_citations 
    WHERE citation = 'AL-MOBILE-EFILING';
    
    SELECT id INTO al_madison_efile_id FROM leverage.rule_citations 
    WHERE citation = 'AL-MADISON-EFILING';
    
    SELECT id INTO al_montgomery_efile_id FROM leverage.rule_citations 
    WHERE citation = 'AL-MONTGOMERY-EFILING';
    
    SELECT id INTO al_shelby_efile_id FROM leverage.rule_citations 
    WHERE citation = 'AL-SHELBY-EFILING';

    -- AL Statewide PI SOL (2 years) - Ala. Code § 6-2-38
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'AL-SOL-6-2-38-PI-2YEAR', 5, 'AL Personal Injury SOL (2 Years)', 'threshold_check',
        'personal_injury', 'complaint',
        'state', 'AL', NULL, NULL,
        '{"sol_years": 2, "sol_days": 730, "statute": "Ala. Code § 6-2-38", "applies_to": "injury_to_person_or_rights", "note": "Alabama 2-year SOL for any injury to the person or rights of another, not arising from contract."}'::jsonb,
        'error', al_sol_id, 'document_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id,
        review_status = EXCLUDED.review_status;

    -- AL Statewide E-Filing Rule (AlaFile - Since September 6, 2012)
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'AL-EFILING-STATEWIDE', 2, 'AL Statewide E-Filing (AlaFile)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'AL', NULL, NULL,
        '{"requires_efiling": true, "system": "AlaFile", "effective_date": "2012-09-06", "mandatory_for": ["attorneys"], "all_civil_cases": true, "registration_url": "https://efile.alacourt.gov/", "note": "DOCUMENT VERIFIED: E-filing mandatory for attorneys in all Alabama civil cases since September 6, 2012. Alabama was an EARLY ADOPTER of mandatory e-filing."}'::jsonb,
        'error', al_statewide_efile_id, 'document_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id,
        review_status = EXCLUDED.review_status;

    -- Jefferson County E-Filing Rule (Birmingham)
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'AL-JEFFERSON-EFILING', 2, 'Jefferson County E-Filing (Birmingham)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'AL', 'Jefferson', 'Circuit Court',
        '{"requires_efiling": true, "system": "AlaFile", "effective_date": "2012-09-06", "city": "Birmingham", "population": "660000", "court_url": "https://www.jccal.org/Default.asp?ID=51&pg=Circuit+Clerk", "note": "Largest county in Alabama. E-filing mandatory for attorneys since 2012."}'::jsonb,
        'error', al_jefferson_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Mobile County E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'AL-MOBILE-EFILING', 2, 'Mobile County E-Filing', 'format_check',
        'personal_injury', 'complaint',
        'state', 'AL', 'Mobile', 'Circuit Court',
        '{"requires_efiling": true, "system": "AlaFile", "effective_date": "2012-09-06", "court_url": "https://www.mobilecountyal.gov/government/elected-officials/circuit-clerk/", "note": "E-filing mandatory for attorneys since 2012."}'::jsonb,
        'error', al_mobile_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Madison County E-Filing Rule (Huntsville)
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'AL-MADISON-EFILING', 2, 'Madison County E-Filing (Huntsville)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'AL', 'Madison', 'Circuit Court',
        '{"requires_efiling": true, "system": "AlaFile", "effective_date": "2012-09-06", "city": "Huntsville", "court_url": "https://www.madisoncountyal.gov/departments/circuit-clerk/", "note": "E-filing mandatory for attorneys since 2012."}'::jsonb,
        'error', al_madison_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Montgomery County E-Filing Rule (State Capital)
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'AL-MONTGOMERY-EFILING', 2, 'Montgomery County E-Filing (Capital)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'AL', 'Montgomery', 'Circuit Court',
        '{"requires_efiling": true, "system": "AlaFile", "effective_date": "2012-09-06", "is_capital": true, "court_url": "https://www.mc-ala.org/government/circuit_clerk/", "note": "State capital county. E-filing mandatory for attorneys since 2012."}'::jsonb,
        'error', al_montgomery_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Shelby County E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'AL-SHELBY-EFILING', 2, 'Shelby County E-Filing', 'format_check',
        'personal_injury', 'complaint',
        'state', 'AL', 'Shelby', 'Circuit Court',
        '{"requires_efiling": true, "system": "AlaFile", "effective_date": "2012-09-06", "court_url": "https://www.shelbyal.com/171/Circuit-Clerk", "note": "E-filing mandatory for attorneys since 2012."}'::jsonb,
        'error', al_shelby_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Completion message
    RAISE NOTICE '========================================================================';
    RAISE NOTICE 'ALABAMA (AL) PI COURT RULES SEEDED SUCCESSFULLY';
    RAISE NOTICE '========================================================================';
    RAISE NOTICE 'Legal Sources: 7 (2 state + 5 county courts)';
    RAISE NOTICE 'Citations: 8 (Ala. Code 6-2-38, e-filing policies, statewide + 5 county)';
    RAISE NOTICE 'Validation Rules: 7 (1 SOL + 1 statewide e-filing + 5 county e-filing)';
    RAISE NOTICE '';
    RAISE NOTICE 'DOCUMENT VERIFIED:';
    RAISE NOTICE '  - Ala. Code § 6-2-38 (2-year SOL) from codes.findlaw.com';
    RAISE NOTICE '  - E-filing policy from alacourt.gov (AlaFile system)';
    RAISE NOTICE '';
    RAISE NOTICE 'IMPORTANT: Alabama was an EARLY ADOPTER of mandatory e-filing (Sept 2012)!';
    RAISE NOTICE 'Alabama has 2-YEAR SOL for personal injury.';
    RAISE NOTICE '========================================================================';

END $$;

COMMIT;
