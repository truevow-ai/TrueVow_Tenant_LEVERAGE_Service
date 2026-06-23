-- ============================================================================
-- Missouri County-Specific PI Court Rules Seed
-- ============================================================================
-- Version: 1.0.0
-- Date: January 30, 2026
-- Purpose: Add Missouri county-level court rules with verified citations
-- High-volume PI counties: St. Louis City, St. Louis County, Jackson, Greene, Clay
-- IMPORTANT: Missouri has 5-YEAR SOL for personal injury (longer than most states)
-- Data Due Diligence: Citations verified from revisor.mo.gov and official court sites
-- ============================================================================
-- DOCUMENT VERIFIED CITATIONS:
--
-- 1. RSMo § 516.120 - What actions within five years
--    Source: https://revisor.mo.gov/main/OneSection.aspx?section=516.120
--    Effective Date: 28 Aug 1939
--    EXACT TEXT: "Within five years: ... (4) An action for taking, detaining or 
--    injuring any goods or chattels, including actions for the recovery of specific 
--    personal property, or for any other injury to the person or rights of another, 
--    not arising on contract and not herein otherwise enumerated;"
--
-- 2. Jackson County 16th Judicial Circuit - Mandatory E-Filing
--    Source: https://www.16thcircuit.org/efiling-information
--    EXACT TEXT: "Cases in the 16th Judicial Circuit of Missouri, must be filed 
--    electronically except those filed by a non-attorney, a self represented party 
--    or certain filings by agencies in civil commitment matters."
--
-- 3. Greene County 31st Judicial Circuit - Mandatory E-Filing for Attorneys
--    Source: http://www.greenecountycourts.org/electronic-filing
--    EXACT TEXT: "Greene County accepts all new cases and documents from attorneys 
--    through Missouri's eFiling portal. This only applies to attorneys; pro se 
--    individuals will continue to file with paper documents."
--
-- 4. Clay County 7th Judicial Circuit - E-Filing effective April 11, 2016
--    Source: https://www.circuit7.net/efiling
--    E-filing mandatory for attorneys and authorized agencies since April 11, 2016
-- ============================================================================

BEGIN;

-- ============================================================================
-- PART 1: ADD MISSOURI STATE AND COUNTY LEGAL SOURCES
-- ============================================================================

-- Missouri State-level Sources
INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    ('state', 'MO', NULL, NULL,
     'Missouri Revised Statutes',
     'Missouri General Assembly',
     'RSMo',
     'https://revisor.mo.gov/',
     'statute',
     'high',
     'Official Missouri Revised Statutes. RSMo § 516.120 establishes 5-year SOL for personal injury. DOCUMENT VERIFIED.'),
    ('state', 'MO', NULL, NULL,
     'Missouri Supreme Court Rules',
     'Missouri Supreme Court',
     'Mo. R. Civ. P.',
     'https://www.courts.mo.gov/',
     'court_rule',
     'high',
     'Missouri Supreme Court Rules governing civil procedure')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET base_url = EXCLUDED.base_url, notes = EXCLUDED.notes;

-- Missouri County Sources (Major PI Jurisdictions)
INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    ('county', 'MO', 'St. Louis City', 'Circuit Court',
     'St. Louis City Circuit Court Local Rules',
     '22nd Judicial Circuit Court',
     '22nd Cir. L.R.',
     'https://www.stlcitycircuitcourt.com/',
     'court_rule',
     'high',
     'St. Louis City (22nd Judicial Circuit). E-filing mandatory for civil cases. WEB VERIFIED.'),
    ('county', 'MO', 'St. Louis County', 'Circuit Court',
     'St. Louis County Circuit Court Local Rules',
     '21st Judicial Circuit Court',
     '21st Cir. L.R.',
     'https://stlcountycourts.com/',
     'court_rule',
     'high',
     'St. Louis County (21st Judicial Circuit) in Clayton. E-filing mandatory for attorneys. WEB VERIFIED.'),
    ('county', 'MO', 'Jackson', 'Circuit Court',
     'Jackson County Circuit Court Local Rules',
     '16th Judicial Circuit Court',
     '16th Cir. L.R.',
     'https://www.16thcircuit.org/',
     'court_rule',
     'high',
     'Jackson County (16th Judicial Circuit - Kansas City). E-filing mandatory for attorneys. DOCUMENT VERIFIED.'),
    ('county', 'MO', 'Greene', 'Circuit Court',
     'Greene County Circuit Court Local Rules',
     '31st Judicial Circuit Court',
     '31st Cir. L.R.',
     'http://www.greenecountycourts.org/',
     'court_rule',
     'high',
     'Greene County (31st Judicial Circuit - Springfield). E-filing mandatory for attorneys. DOCUMENT VERIFIED.'),
    ('county', 'MO', 'Clay', 'Circuit Court',
     'Clay County Circuit Court Local Rules',
     '7th Judicial Circuit Court',
     '7th Cir. L.R.',
     'http://www.circuit7.net/',
     'court_rule',
     'high',
     'Clay County (7th Judicial Circuit - Liberty). E-filing mandatory since April 11, 2016. WEB VERIFIED.')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET base_url = EXCLUDED.base_url, notes = EXCLUDED.notes;

-- ============================================================================
-- PART 2: ADD MISSOURI STATE AND COUNTY CITATIONS
-- ============================================================================

DO $$
DECLARE
    mo_rsmo_id INTEGER;
    mo_stl_city_id INTEGER;
    mo_stl_county_id INTEGER;
    mo_jackson_id INTEGER;
    mo_greene_id INTEGER;
    mo_clay_id INTEGER;
BEGIN
    -- Get legal source IDs
    SELECT id INTO mo_rsmo_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'MO' AND abbreviation = 'RSMo';
    
    SELECT id INTO mo_stl_city_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'MO' AND jurisdiction_county = 'St. Louis City';
    
    SELECT id INTO mo_stl_county_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'MO' AND jurisdiction_county = 'St. Louis County';
    
    SELECT id INTO mo_jackson_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'MO' AND jurisdiction_county = 'Jackson';
    
    SELECT id INTO mo_greene_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'MO' AND jurisdiction_county = 'Greene';
    
    SELECT id INTO mo_clay_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'MO' AND jurisdiction_county = 'Clay';

    -- RSMo § 516.120 - Missouri 5-Year SOL for Personal Injury
    -- DOCUMENT VERIFIED: EXACT TEXT from revisor.mo.gov
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        mo_rsmo_id, 'statute', 'Missouri Revised Statutes',
        'RSMo § 516.120',
        'https://revisor.mo.gov/main/OneSection.aspx?section=516.120',
        'Within five years: (1) All actions upon contracts, obligations or liabilities, express or implied, except those mentioned in section 516.110, and except upon judgments or decrees of a court of record, and except where a different time is herein limited; (2) An action upon a liability created by a statute other than a penalty or forfeiture; (3) An action for trespass on real estate; (4) An action for taking, detaining or injuring any goods or chattels, including actions for the recovery of specific personal property, or for any other injury to the person or rights of another, not arising on contract and not herein otherwise enumerated; (5) An action for relief on the ground of fraud, the cause of action in such case to be deemed not to have accrued until the discovery by the aggrieved party, at any time within ten years, of the facts constituting the fraud.',
        '§ 516.120(4)', '1939-08-28', NOW(), 'document_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        verifier = EXCLUDED.verifier;

    -- St. Louis City 22nd Circuit E-Filing Citation
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        mo_stl_city_id, 'local_rule', 'St. Louis City Circuit Court Local Rules',
        'MO-STL-CITY-22ND-EFILING',
        'https://www.stlcitycircuitcourt.com/',
        'E-filing is mandatory for civil cases in the 22nd Judicial Circuit (St. Louis City). Users can access eFiling services through the Missouri eFiling System at courts.mo.gov.',
        'E-Filing', NOW()::date, NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- St. Louis County 21st Circuit E-Filing Citation
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        mo_stl_county_id, 'local_rule', 'St. Louis County Circuit Court Local Rules',
        'MO-STL-COUNTY-21ST-EFILING',
        'https://stlcountycourts.com/attorneys/efiling/',
        'E-filing is mandatory for attorneys in the 21st Judicial Circuit (St. Louis County). The court is located at 105 South Central Avenue, Clayton, MO 63105. Hours: Monday-Friday 8:00 AM - 5:00 PM.',
        'E-Filing', NOW()::date, NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Jackson County 16th Circuit E-Filing Citation
    -- DOCUMENT VERIFIED: EXACT TEXT from 16thcircuit.org
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        mo_jackson_id, 'local_rule', 'Jackson County Circuit Court Local Rules',
        'MO-JACKSON-16TH-EFILING',
        'https://www.16thcircuit.org/efiling-information',
        'Cases in the 16th Judicial Circuit of Missouri, must be filed electronically except those filed by a non-attorney, a self represented party or certain filings by agencies in civil commitment matters. A licensed attorney in the State of Missouri will have to register for a user account and subscribe to the Missouri Court e-Filing System in order to file any new case or any pleading in an existing case as the attorney for a party. There is no charge for registering.',
        'E-Filing', NOW()::date, NOW(), 'document_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        verifier = EXCLUDED.verifier;

    -- Greene County 31st Circuit E-Filing Citation
    -- DOCUMENT VERIFIED: EXACT TEXT from greenecountycourts.org
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        mo_greene_id, 'local_rule', 'Greene County Circuit Court Local Rules',
        'MO-GREENE-31ST-EFILING',
        'http://www.greenecountycourts.org/electronic-filing',
        'Greene County accepts all new cases and documents from attorneys through Missouri''s eFiling portal. This only applies to attorneys; pro se individuals will continue to file with paper documents. EFiling submissions will be rejected if no payment is made for cases that require a fee. Payment options: Credit or debit card, Electronic check, Manual business check/cashiers check.',
        'E-Filing', NOW()::date, NOW(), 'document_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        verifier = EXCLUDED.verifier;

    -- Clay County 7th Circuit E-Filing Citation
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        mo_clay_id, 'local_rule', 'Clay County Circuit Court Local Rules',
        'MO-CLAY-7TH-EFILING',
        'https://www.circuit7.net/efiling',
        'E-filing became mandatory for attorneys and authorized agencies on April 11, 2016, for filing documents related to new or pending cases in the 7th Judicial Circuit. Pro se individuals are exempt from this requirement and may file paper documents directly at the courthouse. There are no additional fees associated with eFiling. Main courthouse: James S. Rooney Justice Center, 11 South Water Street, Liberty, MO 64068.',
        'E-Filing', '2016-04-11', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

END $$;

-- ============================================================================
-- PART 3: ADD MISSOURI VALIDATION RULES
-- ============================================================================

DO $$
DECLARE
    mo_sol_id INTEGER;
    mo_stl_city_efile_id INTEGER;
    mo_stl_county_efile_id INTEGER;
    mo_jackson_efile_id INTEGER;
    mo_greene_efile_id INTEGER;
    mo_clay_efile_id INTEGER;
BEGIN
    -- Get citation IDs
    SELECT id INTO mo_sol_id FROM leverage.rule_citations 
    WHERE citation = 'RSMo § 516.120';
    
    SELECT id INTO mo_stl_city_efile_id FROM leverage.rule_citations 
    WHERE citation = 'MO-STL-CITY-22ND-EFILING';
    
    SELECT id INTO mo_stl_county_efile_id FROM leverage.rule_citations 
    WHERE citation = 'MO-STL-COUNTY-21ST-EFILING';
    
    SELECT id INTO mo_jackson_efile_id FROM leverage.rule_citations 
    WHERE citation = 'MO-JACKSON-16TH-EFILING';
    
    SELECT id INTO mo_greene_efile_id FROM leverage.rule_citations 
    WHERE citation = 'MO-GREENE-31ST-EFILING';
    
    SELECT id INTO mo_clay_efile_id FROM leverage.rule_citations 
    WHERE citation = 'MO-CLAY-7TH-EFILING';

    -- MO Statewide PI SOL (5 years) - RSMo § 516.120
    -- IMPORTANT: Missouri has 5-YEAR SOL - longer than most states!
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'MO-SOL-516-120-PI-5YEAR', 5, 'MO Personal Injury SOL (5 Years)', 'threshold_check',
        'personal_injury', 'complaint',
        'state', 'MO', NULL, NULL,
        '{"sol_years": 5, "sol_days": 1825, "statute": "RSMo § 516.120", "subdivision": "(4)", "applies_to": "personal_injury_tort", "note": "Missouri has 5-YEAR SOL for PI - LONGER than most states. Applies to any injury to person or rights of another not arising on contract."}'::jsonb,
        'error', mo_sol_id, 'document_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id,
        review_status = EXCLUDED.review_status;

    -- St. Louis City (22nd Circuit) E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'MO-STLCITY-22ND-EFILING', 2, 'St. Louis City E-Filing (22nd Circuit)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'MO', 'St. Louis City', 'Circuit Court',
        '{"requires_efiling": true, "system": "Missouri eFiling System", "circuit": "22nd Judicial Circuit", "court_url": "https://www.stlcitycircuitcourt.com/", "exemptions": ["pro_se_litigants"], "help_desk": "osca.help.desk@courts.mo.gov", "help_phone": "(888) 541-4894"}'::jsonb,
        'error', mo_stl_city_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- St. Louis County (21st Circuit) E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'MO-STLCOUNTY-21ST-EFILING', 2, 'St. Louis County E-Filing (21st Circuit)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'MO', 'St. Louis County', 'Circuit Court',
        '{"requires_efiling": true, "system": "Missouri eFiling System", "circuit": "21st Judicial Circuit", "courthouse": "105 South Central Avenue, Clayton, MO 63105", "court_url": "https://stlcountycourts.com/", "efiling_url": "https://stlcountycourts.com/attorneys/efiling/", "exemptions": ["pro_se_litigants"], "hours": "Monday-Friday 8:00 AM - 5:00 PM"}'::jsonb,
        'error', mo_stl_county_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Jackson County (16th Circuit - Kansas City) E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'MO-JACKSON-16TH-EFILING', 2, 'Jackson County E-Filing (16th Circuit)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'MO', 'Jackson', 'Circuit Court',
        '{"requires_efiling": true, "system": "Missouri eFiling System", "circuit": "16th Judicial Circuit", "city": "Kansas City", "court_url": "https://www.16thcircuit.org/", "efiling_url": "https://www.16thcircuit.org/efiling-information", "registration_free": true, "exemptions": ["non_attorneys", "self_represented_parties", "certain_civil_commitment_filings"], "note": "DOCUMENT VERIFIED: Mandatory e-filing for all cases except non-attorneys and pro se"}'::jsonb,
        'error', mo_jackson_efile_id, 'document_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id,
        review_status = EXCLUDED.review_status;

    -- Greene County (31st Circuit - Springfield) E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'MO-GREENE-31ST-EFILING', 2, 'Greene County E-Filing (31st Circuit)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'MO', 'Greene', 'Circuit Court',
        '{"requires_efiling": true, "system": "Missouri eFiling System", "circuit": "31st Judicial Circuit", "city": "Springfield", "court_url": "http://www.greenecountycourts.org/", "efiling_url": "http://www.greenecountycourts.org/electronic-filing", "attorneys_only": true, "pro_se_paper_filing": true, "payment_required": true, "payment_options": ["credit_card", "debit_card", "electronic_check", "business_check", "cashiers_check"], "note": "DOCUMENT VERIFIED: Attorneys must e-file; pro se may file paper documents"}'::jsonb,
        'error', mo_greene_efile_id, 'document_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id,
        review_status = EXCLUDED.review_status;

    -- Clay County (7th Circuit - Liberty) E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'MO-CLAY-7TH-EFILING', 2, 'Clay County E-Filing (7th Circuit)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'MO', 'Clay', 'Circuit Court',
        '{"requires_efiling": true, "system": "Missouri eFiling System", "circuit": "7th Judicial Circuit", "city": "Liberty", "effective_date": "2016-04-11", "courthouse": "James S. Rooney Justice Center, 11 South Water Street, Liberty, MO 64068", "court_url": "http://www.circuit7.net/", "efiling_url": "https://www.circuit7.net/efiling", "no_additional_fees": true, "exemptions": ["pro_se_individuals"], "note": "E-filing mandatory since April 11, 2016 for attorneys and authorized agencies"}'::jsonb,
        'error', mo_clay_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Completion message
    RAISE NOTICE '========================================================================';
    RAISE NOTICE 'MISSOURI (MO) PI COURT RULES SEEDED SUCCESSFULLY';
    RAISE NOTICE '========================================================================';
    RAISE NOTICE 'Legal Sources: 7 (2 state + 5 county courts)';
    RAISE NOTICE 'Citations: 6 (RSMo 516.120 + 5 county e-filing rules)';
    RAISE NOTICE 'Validation Rules: 6 (1 SOL + 5 e-filing rules)';
    RAISE NOTICE '';
    RAISE NOTICE 'DOCUMENT VERIFIED:';
    RAISE NOTICE '  - RSMo § 516.120 (5-year SOL) from revisor.mo.gov';
    RAISE NOTICE '  - Jackson County 16th Circuit from 16thcircuit.org';
    RAISE NOTICE '  - Greene County 31st Circuit from greenecountycourts.org';
    RAISE NOTICE '';
    RAISE NOTICE 'IMPORTANT: Missouri has 5-YEAR SOL for PI (longer than most states)';
    RAISE NOTICE '========================================================================';

END $$;

COMMIT;
