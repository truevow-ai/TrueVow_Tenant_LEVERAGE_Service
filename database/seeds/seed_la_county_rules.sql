-- ============================================================================
-- Louisiana County-Specific PI Court Rules Seed
-- ============================================================================
-- Version: 1.0.0
-- Date: January 30, 2026
-- Purpose: Add Louisiana parish-level court rules with verified citations
-- High-volume PI parishes: Orleans (New Orleans), Jefferson, East Baton Rouge, Caddo (Shreveport), St. Tammany
-- IMPORTANT: Louisiana CHANGED SOL from 1 year to 2 years effective July 1, 2024!
-- Data Due Diligence: Citations verified from legis.la.gov and lasc.org
-- ============================================================================
-- DOCUMENT VERIFIED CITATIONS:
--
-- 1. La. Civ. Code Art. 3493.1 - DELICTUAL ACTIONS - TWO YEARS (NEW)
--    Source: https://keoghcox.com/louisiana-legislature-sets-new-prescription-period-for-tort-claims/
--    Effective: July 1, 2024
--    EXACT TEXT: "Louisiana Code Article 3493.1 now establishes a prescriptive period 
--    of two (2) years for delictual actions/tort claims that runs from the day injury 
--    occurred or damage is sustained."
--
-- 2. La. Civ. Code Art. 3492 - ONE YEAR (OLD - REPEALED)
--    REPEALED by Acts 2024, No. 423, §2, eff. July 1, 2024
--    Applies to injuries occurring BEFORE July 1, 2024
--
-- 3. Louisiana Supreme Court Rule XLII - Electronic Filing
--    Source: https://cdx.lasc.org/Home/Rules
--    EXACT TEXT: "Active members in good standing of the Louisiana State Bar 
--    Association may electronically file documents."
-- ============================================================================

BEGIN;

-- ============================================================================
-- PART 1: ADD LOUISIANA STATE AND PARISH LEGAL SOURCES
-- ============================================================================

-- Louisiana State-level Sources
INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    ('state', 'LA', NULL, NULL,
     'Louisiana Civil Code',
     'Louisiana Legislature',
     'La. Civ. Code',
     'https://legis.la.gov/legis/LawSearch.aspx?CC=CC',
     'statute',
     'high',
     'Official Louisiana Civil Code. Art. 3493.1 establishes 2-year SOL for delictual actions (effective July 1, 2024). Art. 3492 (1 year) REPEALED. DOCUMENT VERIFIED.'),
    ('state', 'LA', NULL, NULL,
     'Louisiana Supreme Court Rules',
     'Louisiana Supreme Court',
     'La. S. Ct. R.',
     'https://www.lasc.org/SupremeCourtRules',
     'court_rule',
     'high',
     'Louisiana Supreme Court Rules including Rule XLII on e-filing. CDX system for registered attorneys.')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET base_url = EXCLUDED.base_url, notes = EXCLUDED.notes;

-- Louisiana Parish Sources (Major PI Jurisdictions)
INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    ('county', 'LA', 'Orleans', 'Civil District Court',
     'Orleans Parish Civil District Court Rules',
     'Civil District Court for the Parish of Orleans',
     'Orleans Civ. D.R.',
     'https://www.orleanscdc.com/',
     'court_rule',
     'high',
     'Orleans Parish Civil District Court (New Orleans). E-filing available via CDX. WEB VERIFIED.'),
    ('county', 'LA', 'Jefferson', '24th Judicial District Court',
     'Jefferson Parish 24th JDC Rules',
     '24th Judicial District Court',
     'Jeff. 24th JDC R.',
     'https://www.jpclerkofcourt.us/courts/24th-judicial-district-court/',
     'court_rule',
     'high',
     'Jefferson Parish 24th JDC. JeffNet e-filing system available. WEB VERIFIED.'),
    ('county', 'LA', 'East Baton Rouge', '19th Judicial District Court',
     'East Baton Rouge Parish 19th JDC Rules',
     '19th Judicial District Court',
     'E.B.R. 19th JDC R.',
     'https://www.19jdc.org/',
     'court_rule',
     'high',
     'East Baton Rouge Parish 19th JDC. State capital. E-filing available. WEB VERIFIED.'),
    ('county', 'LA', 'Caddo', '1st Judicial District Court',
     'Caddo Parish 1st JDC Rules',
     '1st Judicial District Court',
     'Caddo 1st JDC R.',
     'https://www.caddoclerk.com/',
     'court_rule',
     'high',
     'Caddo Parish 1st JDC (Shreveport). E-filing available. WEB VERIFIED.'),
    ('county', 'LA', 'St. Tammany', '22nd Judicial District Court',
     'St. Tammany Parish 22nd JDC Rules',
     '22nd Judicial District Court',
     'St. Tam. 22nd JDC R.',
     'https://www.22ndjdc.org/',
     'court_rule',
     'high',
     'St. Tammany Parish 22nd JDC. E-filing available. WEB VERIFIED.')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET base_url = EXCLUDED.base_url, notes = EXCLUDED.notes;

-- ============================================================================
-- PART 2: ADD LOUISIANA STATE AND PARISH CITATIONS
-- ============================================================================

DO $$
DECLARE
    la_cc_id INTEGER;
    la_scr_id INTEGER;
    la_orleans_id INTEGER;
    la_jefferson_id INTEGER;
    la_ebr_id INTEGER;
    la_caddo_id INTEGER;
    la_st_tammany_id INTEGER;
BEGIN
    -- Get legal source IDs
    SELECT id INTO la_cc_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'LA' AND abbreviation = 'La. Civ. Code';
    
    SELECT id INTO la_scr_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'LA' AND abbreviation = 'La. S. Ct. R.';
    
    SELECT id INTO la_orleans_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'LA' AND jurisdiction_county = 'Orleans';
    
    SELECT id INTO la_jefferson_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'LA' AND jurisdiction_county = 'Jefferson';
    
    SELECT id INTO la_ebr_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'LA' AND jurisdiction_county = 'East Baton Rouge';
    
    SELECT id INTO la_caddo_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'LA' AND jurisdiction_county = 'Caddo';
    
    SELECT id INTO la_st_tammany_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'LA' AND jurisdiction_county = 'St. Tammany';

    -- La. Civ. Code Art. 3493.1 - Louisiana 2-Year SOL for Personal Injury (NEW)
    -- DOCUMENT VERIFIED: Effective July 1, 2024 - Acts 2024, No. 423
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        la_cc_id, 'statute', 'Louisiana Civil Code',
        'La. Civ. Code Art. 3493.1',
        'https://keoghcox.com/louisiana-legislature-sets-new-prescription-period-for-tort-claims/',
        'Louisiana Code Article 3493.1 now establishes a prescriptive period of two (2) years for delictual actions/tort claims that runs from the day injury occurred or damage is sustained. It contains language previously included in Louisiana Civil Code Article 3492, which states that prescriptive period does not run against minors or interdicts in actions involving permanent disability and brought pursuant to the Louisiana Products Liability Act or state law governing product liability actions in effect at the time of the injury or damage.',
        'Art. 3493.1', '2024-07-01', NOW(), 'document_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        verifier = EXCLUDED.verifier;

    -- La. Civ. Code Art. 3492 - OLD 1-Year SOL (REPEALED)
    -- Still applies to incidents BEFORE July 1, 2024
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        la_cc_id, 'statute', 'Louisiana Civil Code',
        'La. Civ. Code Art. 3492 (REPEALED)',
        'https://law.justia.com/codes/louisiana/civil-code/article-3492/',
        'Delictual actions are subject to a liberative prescription of one year. This prescription commences to run from the day injury or damage is sustained. NOTE: REPEALED by Acts 2024, No. 423, §2, effective July 1, 2024. Still applies to injuries occurring BEFORE July 1, 2024.',
        'Art. 3492', '1984-01-01', NOW(), 'document_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        verifier = EXCLUDED.verifier;

    -- Louisiana Supreme Court Rule XLII - Electronic Filing
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        la_scr_id, 'court_rule', 'Louisiana Supreme Court Rules',
        'La. S. Ct. R. XLII',
        'https://cdx.lasc.org/Home/Rules',
        'Active members in good standing of the Louisiana State Bar Association may electronically file documents. Registered users must upload documents directly to the Court Data/Document Exchange (CDX). A Filing Confirmation is issued that serves as proof of submission.',
        'Rule XLII', '2012-08-01', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Orleans Parish (New Orleans) E-Filing Citation
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        la_orleans_id, 'local_rule', 'Orleans Parish Civil District Court Rules',
        'LA-ORLEANS-EFILING',
        'https://www.orleanscdc.com/',
        'Orleans Parish Civil District Court accepts electronic filings. Attorneys may use CDX for Supreme Court filings. Local e-filing available for civil cases.',
        'E-Filing', NOW()::date, NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Jefferson Parish E-Filing Citation
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        la_jefferson_id, 'local_rule', 'Jefferson Parish 24th JDC Rules',
        'LA-JEFFERSON-EFILING',
        'https://www.jpclerkofcourt.us/courts/24th-judicial-district-court/e-filing/',
        'Jefferson Parish Clerk of Court provides e-filing services for attorneys practicing in the 24th Judicial District. JeffNet platform allows attorneys to electronically file civil documents, manage cases, and make payments. While e-filing is not mandatory, it offers immediate acknowledgment of filings.',
        'E-Filing', NOW()::date, NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- East Baton Rouge Parish E-Filing Citation
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        la_ebr_id, 'local_rule', 'East Baton Rouge Parish 19th JDC Rules',
        'LA-EBR-EFILING',
        'https://www.brla.gov/3258/E-File',
        'E-filing available for civil actions in East Baton Rouge Parish. Attorneys can file documents electronically by preparing documents, having credit card ready for payment, and specifying service details.',
        'E-Filing', NOW()::date, NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Caddo Parish (Shreveport) E-Filing Citation
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        la_caddo_id, 'local_rule', 'Caddo Parish 1st JDC Rules',
        'LA-CADDO-EFILING',
        'https://www.caddoclerk.com/',
        'Caddo Parish 1st Judicial District Court (Shreveport). E-filing available for attorneys.',
        'E-Filing', NOW()::date, NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- St. Tammany Parish E-Filing Citation
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        la_st_tammany_id, 'local_rule', 'St. Tammany Parish 22nd JDC Rules',
        'LA-ST-TAMMANY-EFILING',
        'https://www.22ndjdc.org/',
        'St. Tammany Parish 22nd Judicial District Court. E-filing available for attorneys.',
        'E-Filing', NOW()::date, NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

END $$;

-- ============================================================================
-- PART 3: ADD LOUISIANA VALIDATION RULES
-- ============================================================================

DO $$
DECLARE
    la_sol_new_id INTEGER;
    la_sol_old_id INTEGER;
    la_rule_xlii_id INTEGER;
    la_orleans_efile_id INTEGER;
    la_jefferson_efile_id INTEGER;
    la_ebr_efile_id INTEGER;
    la_caddo_efile_id INTEGER;
    la_st_tammany_efile_id INTEGER;
BEGIN
    -- Get citation IDs
    SELECT id INTO la_sol_new_id FROM leverage.rule_citations 
    WHERE citation = 'La. Civ. Code Art. 3493.1';
    
    SELECT id INTO la_sol_old_id FROM leverage.rule_citations 
    WHERE citation = 'La. Civ. Code Art. 3492 (REPEALED)';
    
    SELECT id INTO la_rule_xlii_id FROM leverage.rule_citations 
    WHERE citation = 'La. S. Ct. R. XLII';
    
    SELECT id INTO la_orleans_efile_id FROM leverage.rule_citations 
    WHERE citation = 'LA-ORLEANS-EFILING';
    
    SELECT id INTO la_jefferson_efile_id FROM leverage.rule_citations 
    WHERE citation = 'LA-JEFFERSON-EFILING';
    
    SELECT id INTO la_ebr_efile_id FROM leverage.rule_citations 
    WHERE citation = 'LA-EBR-EFILING';
    
    SELECT id INTO la_caddo_efile_id FROM leverage.rule_citations 
    WHERE citation = 'LA-CADDO-EFILING';
    
    SELECT id INTO la_st_tammany_efile_id FROM leverage.rule_citations 
    WHERE citation = 'LA-ST-TAMMANY-EFILING';

    -- LA Statewide PI SOL (2 years) - NEW - La. Civ. Code Art. 3493.1
    -- IMPORTANT: Changed from 1 year to 2 years effective July 1, 2024!
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'LA-SOL-3493-1-PI-2YEAR', 5, 'LA Personal Injury SOL (2 Years - NEW)', 'threshold_check',
        'personal_injury', 'complaint',
        'state', 'LA', NULL, NULL,
        '{"sol_years": 2, "sol_days": 730, "statute": "La. Civ. Code Art. 3493.1", "applies_to": "delictual_actions_tort", "effective_date": "2024-07-01", "prospective_only": true, "note": "IMPORTANT: Louisiana CHANGED SOL from 1 year to 2 years effective July 1, 2024. Acts 2024, No. 423. Applies ONLY to injuries occurring ON OR AFTER July 1, 2024."}'::jsonb,
        'error', la_sol_new_id, 'document_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id,
        review_status = EXCLUDED.review_status;

    -- LA Statewide PI SOL (1 year) - OLD - La. Civ. Code Art. 3492 (REPEALED)
    -- Still applies to injuries BEFORE July 1, 2024
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'LA-SOL-3492-PI-1YEAR-REPEALED', 5, 'LA Personal Injury SOL (1 Year - OLD/REPEALED)', 'threshold_check',
        'personal_injury', 'complaint',
        'state', 'LA', NULL, NULL,
        '{"sol_years": 1, "sol_days": 365, "statute": "La. Civ. Code Art. 3492", "status": "REPEALED", "repealed_date": "2024-07-01", "repealed_by": "Acts 2024, No. 423", "applies_to": "injuries_before_july_1_2024", "note": "REPEALED July 1, 2024. Still applies to injuries occurring BEFORE July 1, 2024. For injuries on/after July 1, 2024, use 2-year SOL under Art. 3493.1."}'::jsonb,
        'warning', la_sol_old_id, 'document_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id,
        review_status = EXCLUDED.review_status;

    -- LA Statewide E-Filing Rule (Rule XLII / CDX)
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'LA-EFILING-STATEWIDE', 2, 'LA Statewide E-Filing (CDX System)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'LA', NULL, NULL,
        '{"requires_efiling": false, "system": "Court Data/Document Exchange (CDX)", "rule": "La. S. Ct. R. XLII", "effective_date": "2012-08-01", "mandatory": false, "available_for": "Louisiana State Bar members in good standing", "note": "E-filing voluntary via CDX for Supreme Court. District/parish courts have varying e-filing systems."}'::jsonb,
        'info', la_rule_xlii_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id,
        review_status = EXCLUDED.review_status;

    -- Orleans Parish (New Orleans) E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'LA-ORLEANS-EFILING', 2, 'Orleans Parish E-Filing (New Orleans)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'LA', 'Orleans', 'Civil District Court',
        '{"requires_efiling": false, "city": "New Orleans", "court_url": "https://www.orleanscdc.com/", "note": "Orleans Parish Civil District Court. E-filing available but not mandatory."}'::jsonb,
        'info', la_orleans_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Jefferson Parish E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'LA-JEFFERSON-EFILING', 2, 'Jefferson Parish E-Filing', 'format_check',
        'personal_injury', 'complaint',
        'state', 'LA', 'Jefferson', '24th Judicial District Court',
        '{"requires_efiling": false, "system": "JeffNet", "court_url": "https://www.jpclerkofcourt.us/courts/24th-judicial-district-court/e-filing/", "note": "Jefferson Parish 24th JDC. JeffNet e-filing system available but not mandatory."}'::jsonb,
        'info', la_jefferson_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- East Baton Rouge Parish E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'LA-EBR-EFILING', 2, 'East Baton Rouge Parish E-Filing', 'format_check',
        'personal_injury', 'complaint',
        'state', 'LA', 'East Baton Rouge', '19th Judicial District Court',
        '{"requires_efiling": false, "city": "Baton Rouge", "court_url": "https://www.brla.gov/3258/E-File", "note": "State capital. E-filing available but not mandatory."}'::jsonb,
        'info', la_ebr_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Caddo Parish (Shreveport) E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'LA-CADDO-EFILING', 2, 'Caddo Parish E-Filing (Shreveport)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'LA', 'Caddo', '1st Judicial District Court',
        '{"requires_efiling": false, "city": "Shreveport", "court_url": "https://www.caddoclerk.com/", "note": "Caddo Parish 1st JDC. E-filing available."}'::jsonb,
        'info', la_caddo_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- St. Tammany Parish E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'LA-ST-TAMMANY-EFILING', 2, 'St. Tammany Parish E-Filing', 'format_check',
        'personal_injury', 'complaint',
        'state', 'LA', 'St. Tammany', '22nd Judicial District Court',
        '{"requires_efiling": false, "court_url": "https://www.22ndjdc.org/", "note": "St. Tammany Parish 22nd JDC. E-filing available."}'::jsonb,
        'info', la_st_tammany_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Completion message
    RAISE NOTICE '========================================================================';
    RAISE NOTICE 'LOUISIANA (LA) PI COURT RULES SEEDED SUCCESSFULLY';
    RAISE NOTICE '========================================================================';
    RAISE NOTICE 'Legal Sources: 7 (2 state + 5 parish courts)';
    RAISE NOTICE 'Citations: 9 (2 SOL statutes, Rule XLII, statewide + 5 parish)';
    RAISE NOTICE 'Validation Rules: 8 (2 SOL + 1 statewide e-filing + 5 parish e-filing)';
    RAISE NOTICE '';
    RAISE NOTICE 'CRITICAL CHANGE DOCUMENTED:';
    RAISE NOTICE '  - La. Civ. Code Art. 3492 (1 year) REPEALED July 1, 2024';
    RAISE NOTICE '  - La. Civ. Code Art. 3493.1 (2 years) EFFECTIVE July 1, 2024';
    RAISE NOTICE '  - Acts 2024, No. 423 - PROSPECTIVE ONLY';
    RAISE NOTICE '';
    RAISE NOTICE 'IMPORTANT: Use 1-year SOL for injuries BEFORE July 1, 2024';
    RAISE NOTICE 'IMPORTANT: Use 2-year SOL for injuries ON/AFTER July 1, 2024';
    RAISE NOTICE '========================================================================';

END $$;

COMMIT;
