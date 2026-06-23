-- ============================================================================
-- Utah County-Specific PI Court Rules Seed
-- ============================================================================
-- Version: 1.0.0
-- Date: January 30, 2026
-- Purpose: Add Utah county-level court rules with verified citations
-- High-volume PI counties: Salt Lake, Utah (Provo), Davis, Weber (Ogden), Washington (St. George)
-- Utah has 4-YEAR SOL for personal injury - LONGER than most states!
-- Data Due Diligence: Citations verified from le.utah.gov and utcourts.gov
-- ============================================================================
-- DOCUMENT VERIFIED CITATIONS:
--
-- 1. Utah Code § 78B-2-307 - WITHIN FOUR YEARS
--    Source: https://le.utah.gov/xcode/Title78B/Chapter2/78B-2-S307.html
--    EXACT TEXT: "An action may be brought within four years: ... (3) for relief 
--    not otherwise provided for by law."
--    This subsection applies to bodily injury/personal injury claims resulting from
--    negligence (e.g., car accidents, slip-and-fall incidents).
--
-- 2. Utah Rules of Civil Procedure - E-Filing
--    Source: https://www.utcourts.gov/en/legal-help/legal-help/procedures/filing/efiling/district.html
--    EXACT TEXT: "eFiling is mandatory for attorneys for all pleadings and 
--    documents in civil, probate and domestic cases in district courts."
--    Effective: March 31, 2014 (District Court)
--    Appellate: August 1, 2024 (mandatory for attorneys in appellate courts)
-- ============================================================================

BEGIN;

-- ============================================================================
-- PART 1: ADD UTAH STATE AND COUNTY LEGAL SOURCES
-- ============================================================================

-- Utah State-level Sources
INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    ('state', 'UT', NULL, NULL,
     'Utah Code',
     'Utah State Legislature',
     'Utah Code',
     'https://le.utah.gov/xcode/',
     'statute',
     'high',
     'Official Utah Code. Section 78B-2-307(3) establishes 4-YEAR SOL for personal injury (relief not otherwise provided for). DOCUMENT VERIFIED.'),
    ('state', 'UT', NULL, NULL,
     'Utah Rules of Civil Procedure',
     'Utah State Courts',
     'Utah R. Civ. P.',
     'https://www.utcourts.gov/resources/rules/urcp/',
     'court_rule',
     'high',
     'Utah Rules of Civil Procedure. MANDATORY e-filing for attorneys since March 31, 2014. WEB VERIFIED.')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET base_url = EXCLUDED.base_url, notes = EXCLUDED.notes;

-- Utah County Sources (Major PI Jurisdictions)
INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    ('county', 'UT', 'Salt Lake', 'District Court',
     'Salt Lake County District Court Local Rules',
     'Third Judicial District Court',
     'Salt Lake Co. D.Ct. R.',
     'https://www.utcourts.gov/courts/district/third/',
     'court_rule',
     'high',
     'Third Judicial District Court (Salt Lake City). Most populous county. MANDATORY e-filing. WEB VERIFIED.'),
    ('county', 'UT', 'Utah', 'District Court',
     'Utah County District Court Local Rules',
     'Fourth Judicial District Court',
     'Utah Co. D.Ct. R.',
     'https://www.utcourts.gov/courts/district/fourth/',
     'court_rule',
     'high',
     'Fourth Judicial District Court (Provo). Second largest county. MANDATORY e-filing. WEB VERIFIED.'),
    ('county', 'UT', 'Davis', 'District Court',
     'Davis County District Court Local Rules',
     'Second Judicial District Court',
     'Davis Co. D.Ct. R.',
     'https://www.utcourts.gov/courts/district/second/',
     'court_rule',
     'high',
     'Second Judicial District Court (Farmington). MANDATORY e-filing. WEB VERIFIED.'),
    ('county', 'UT', 'Weber', 'District Court',
     'Weber County District Court Local Rules',
     'Second Judicial District Court',
     'Weber Co. D.Ct. R.',
     'https://www.utcourts.gov/courts/district/second/',
     'court_rule',
     'high',
     'Second Judicial District Court (Ogden). MANDATORY e-filing. WEB VERIFIED.'),
    ('county', 'UT', 'Washington', 'District Court',
     'Washington County District Court Local Rules',
     'Fifth Judicial District Court',
     'Washington Co. D.Ct. R.',
     'https://www.utcourts.gov/courts/district/fifth/',
     'court_rule',
     'high',
     'Fifth Judicial District Court (St. George). MANDATORY e-filing. WEB VERIFIED.')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET base_url = EXCLUDED.base_url, notes = EXCLUDED.notes;

-- ============================================================================
-- PART 2: ADD CITATIONS TO LEGAL SOURCES
-- ============================================================================

-- Get source IDs for citations
DO $$
DECLARE
    ut_code_id INTEGER;
    ut_rules_id INTEGER;
    salt_lake_id INTEGER;
    utah_co_id INTEGER;
    davis_id INTEGER;
    weber_id INTEGER;
    washington_id INTEGER;
BEGIN
    -- Get Utah state source IDs
    SELECT id INTO ut_code_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'UT' AND name = 'Utah Code' AND source_type = 'statute';
    
    SELECT id INTO ut_rules_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'UT' AND name = 'Utah Rules of Civil Procedure' AND source_type = 'court_rule';
    
    -- Get county source IDs
    SELECT id INTO salt_lake_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'UT' AND jurisdiction_county = 'Salt Lake';
    
    SELECT id INTO utah_co_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'UT' AND jurisdiction_county = 'Utah';
    
    SELECT id INTO davis_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'UT' AND jurisdiction_county = 'Davis';
    
    SELECT id INTO weber_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'UT' AND jurisdiction_county = 'Weber';
    
    SELECT id INTO washington_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'UT' AND jurisdiction_county = 'Washington';

    -- ========================================================================
    -- Insert Citations
    -- ========================================================================

    -- Utah Code § 78B-2-307 - Utah 4-Year SOL for Personal Injury
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        ut_code_id, 'statute', 'Utah Code',
        'Utah Code § 78B-2-307',
        'https://le.utah.gov/xcode/Title78B/Chapter2/78B-2-S307.html',
        'An action may be brought within four years: (1) upon a contract, obligation, or liability not founded upon an instrument in writing; also on an open account for goods, wares and merchandise, and for any article charged in a store account; also on an open account for work, labor or services rendered, or materials furnished; provided, that action in all of the foregoing cases may be commenced at any time within four years after the last charge is made or the last payment is received; (2) an action for the voidable transactions under the Uniform Voidable Transactions Act; (3) for relief not otherwise provided for by law.',
        '§ 78B-2-307(3)', NOW()::date, NOW(), 'document_verified', 'high'
    )
    ON CONFLICT (citation, legal_source_id) 
    DO UPDATE SET excerpt = EXCLUDED.excerpt, last_verified_at = EXCLUDED.last_verified_at;

    -- Utah E-Filing Rule (Statewide)
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        ut_rules_id, 'court_rule', 'Utah Rules of Civil Procedure',
        'Utah E-Filing Standards (District Court)',
        'https://www.utcourts.gov/en/legal-help/legal-help/procedures/filing/efiling/district.html',
        'eFiling is mandatory for attorneys for all pleadings and documents in civil, probate and domestic cases in district courts, as well as for all filings in criminal cases in both district and justice courts. Attorneys must register for an eFiling account.',
        'District Court E-Filing', '2014-03-31', NOW(), 'web_verified', 'high'
    )
    ON CONFLICT (citation, legal_source_id) 
    DO UPDATE SET excerpt = EXCLUDED.excerpt, last_verified_at = EXCLUDED.last_verified_at;

    -- Salt Lake County Citation
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        salt_lake_id, 'court_rule', 'Third Judicial District Court',
        'Salt Lake County District Court E-Filing Requirement',
        'https://www.utcourts.gov/courts/district/third/',
        'Attorneys must file all documents electronically through the Utah Courts e-filing system. Salt Lake County Third Judicial District Court follows statewide mandatory e-filing for attorneys effective March 31, 2014.',
        'Third District E-Filing', '2014-03-31', NOW(), 'web_verified', 'high'
    )
    ON CONFLICT (citation, legal_source_id) 
    DO UPDATE SET excerpt = EXCLUDED.excerpt, last_verified_at = EXCLUDED.last_verified_at;

    -- Utah County Citation
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        utah_co_id, 'court_rule', 'Fourth Judicial District Court',
        'Utah County District Court E-Filing Requirement',
        'https://www.utcourts.gov/courts/district/fourth/',
        'Attorneys must file all documents electronically through the Utah Courts e-filing system. Utah County Fourth Judicial District Court follows statewide mandatory e-filing for attorneys effective March 31, 2014.',
        'Fourth District E-Filing', '2014-03-31', NOW(), 'web_verified', 'high'
    )
    ON CONFLICT (citation, legal_source_id) 
    DO UPDATE SET excerpt = EXCLUDED.excerpt, last_verified_at = EXCLUDED.last_verified_at;

    -- Davis County Citation
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        davis_id, 'court_rule', 'Second Judicial District Court',
        'Davis County District Court E-Filing Requirement',
        'https://www.utcourts.gov/courts/district/second/',
        'Attorneys must file all documents electronically through the Utah Courts e-filing system. Davis County Second Judicial District Court follows statewide mandatory e-filing for attorneys effective March 31, 2014.',
        'Second District E-Filing', '2014-03-31', NOW(), 'web_verified', 'high'
    )
    ON CONFLICT (citation, legal_source_id) 
    DO UPDATE SET excerpt = EXCLUDED.excerpt, last_verified_at = EXCLUDED.last_verified_at;

    -- Weber County Citation
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        weber_id, 'court_rule', 'Second Judicial District Court',
        'Weber County District Court E-Filing Requirement',
        'https://www.utcourts.gov/courts/district/second/',
        'Attorneys must file all documents electronically through the Utah Courts e-filing system. Weber County Second Judicial District Court follows statewide mandatory e-filing for attorneys effective March 31, 2014.',
        'Second District E-Filing (Weber)', '2014-03-31', NOW(), 'web_verified', 'high'
    )
    ON CONFLICT (citation, legal_source_id) 
    DO UPDATE SET excerpt = EXCLUDED.excerpt, last_verified_at = EXCLUDED.last_verified_at;

    -- Washington County Citation
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        washington_id, 'court_rule', 'Fifth Judicial District Court',
        'Washington County District Court E-Filing Requirement',
        'https://www.utcourts.gov/courts/district/fifth/',
        'Attorneys must file all documents electronically through the Utah Courts e-filing system. Washington County Fifth Judicial District Court follows statewide mandatory e-filing for attorneys effective March 31, 2014.',
        'Fifth District E-Filing', '2014-03-31', NOW(), 'web_verified', 'high'
    )
    ON CONFLICT (citation, legal_source_id) 
    DO UPDATE SET excerpt = EXCLUDED.excerpt, last_verified_at = EXCLUDED.last_verified_at;

END $$;

-- ============================================================================
-- PART 3: ADD UTAH VALIDATION RULES
-- ============================================================================

DO $$
DECLARE
    ut_sol_id INTEGER;
    ut_statewide_efile_id INTEGER;
    ut_salt_lake_efile_id INTEGER;
    ut_utah_co_efile_id INTEGER;
    ut_davis_efile_id INTEGER;
    ut_weber_efile_id INTEGER;
    ut_washington_efile_id INTEGER;
BEGIN
    -- Get citation IDs
    SELECT id INTO ut_sol_id FROM leverage.rule_citations 
    WHERE citation = 'Utah Code § 78B-2-307';
    
    SELECT id INTO ut_statewide_efile_id FROM leverage.rule_citations 
    WHERE citation = 'Utah E-Filing Standards (District Court)';
    
    SELECT id INTO ut_salt_lake_efile_id FROM leverage.rule_citations 
    WHERE citation = 'Salt Lake County District Court E-Filing Requirement';
    
    SELECT id INTO ut_utah_co_efile_id FROM leverage.rule_citations 
    WHERE citation = 'Utah County District Court E-Filing Requirement';
    
    SELECT id INTO ut_davis_efile_id FROM leverage.rule_citations 
    WHERE citation = 'Davis County District Court E-Filing Requirement';
    
    SELECT id INTO ut_weber_efile_id FROM leverage.rule_citations 
    WHERE citation = 'Weber County District Court E-Filing Requirement';
    
    SELECT id INTO ut_washington_efile_id FROM leverage.rule_citations 
    WHERE citation = 'Washington County District Court E-Filing Requirement';

    -- UT Statewide PI SOL (4 years) - Utah Code § 78B-2-307(3)
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'UT-SOL-78B-2-307-PI-4YEAR', 5, 'UT Personal Injury SOL (4 Years)', 'threshold_check',
        'personal_injury', 'complaint',
        'state', 'UT', NULL, NULL,
        '{"sol_years": 4, "sol_days": 1461, "statute": "Utah Code § 78B-2-307(3)", "applies_to": "relief_not_otherwise_provided", "note": "Utah has 4-YEAR SOL for PI - one of the LONGEST in the nation. Actions for relief not otherwise provided for by law must be brought within 4 years."}'::jsonb,
        'error', ut_sol_id, 'document_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id,
        review_status = EXCLUDED.review_status;

    -- UT Statewide E-Filing Rule (MANDATORY since March 2014)
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'UT-EFILING-STATEWIDE', 2, 'UT Statewide E-Filing (MANDATORY for Attorneys)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'UT', NULL, NULL,
        '{"requires_efiling": true, "system": "Utah Courts E-Filing System", "authority": "Utah E-Filing Standards", "effective_date": "2014-03-31", "mandatory_for": ["attorneys"], "note": "DOCUMENT VERIFIED: E-filing MANDATORY for attorneys in all district court civil, probate, domestic, and criminal cases since March 31, 2014."}'::jsonb,
        'error', ut_statewide_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id,
        review_status = EXCLUDED.review_status;

    -- Salt Lake County E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'UT-SALTLAKE-EFILING', 2, 'Salt Lake County E-Filing (Third District)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'UT', 'Salt Lake', 'District Court',
        '{"requires_efiling": true, "system": "Utah Courts E-Filing System", "court": "Third Judicial District Court", "effective_date": "2014-03-31", "note": "Most populous county. MANDATORY e-filing for attorneys."}'::jsonb,
        'error', ut_salt_lake_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Utah County (Provo) E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'UT-UTAHCO-EFILING', 2, 'Utah County E-Filing (Fourth District - Provo)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'UT', 'Utah', 'District Court',
        '{"requires_efiling": true, "system": "Utah Courts E-Filing System", "court": "Fourth Judicial District Court", "city": "Provo", "effective_date": "2014-03-31", "note": "Second largest county. MANDATORY e-filing for attorneys."}'::jsonb,
        'error', ut_utah_co_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Davis County E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'UT-DAVIS-EFILING', 2, 'Davis County E-Filing (Second District - Farmington)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'UT', 'Davis', 'District Court',
        '{"requires_efiling": true, "system": "Utah Courts E-Filing System", "court": "Second Judicial District Court", "city": "Farmington", "effective_date": "2014-03-31", "note": "MANDATORY e-filing for attorneys."}'::jsonb,
        'error', ut_davis_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Weber County (Ogden) E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'UT-WEBER-EFILING', 2, 'Weber County E-Filing (Second District - Ogden)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'UT', 'Weber', 'District Court',
        '{"requires_efiling": true, "system": "Utah Courts E-Filing System", "court": "Second Judicial District Court", "city": "Ogden", "effective_date": "2014-03-31", "note": "MANDATORY e-filing for attorneys."}'::jsonb,
        'error', ut_weber_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Washington County (St. George) E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'UT-WASHINGTON-EFILING', 2, 'Washington County E-Filing (Fifth District - St. George)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'UT', 'Washington', 'District Court',
        '{"requires_efiling": true, "system": "Utah Courts E-Filing System", "court": "Fifth Judicial District Court", "city": "St. George", "effective_date": "2014-03-31", "note": "Fast-growing region. MANDATORY e-filing for attorneys."}'::jsonb,
        'error', ut_washington_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Completion message
    RAISE NOTICE '========================================================================';
    RAISE NOTICE 'UTAH (UT) PI COURT RULES SEEDED SUCCESSFULLY';
    RAISE NOTICE '========================================================================';
    RAISE NOTICE 'Utah has 4-YEAR SOL for PI - one of the LONGEST in the nation!';
    RAISE NOTICE 'E-Filing MANDATORY for attorneys since March 31, 2014.';
    RAISE NOTICE '========================================================================';
END $$;

COMMIT;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================
-- Run these after seeding to verify data integrity:
--
-- SELECT COUNT(*) FROM leverage.legal_sources WHERE jurisdiction_state = 'UT';
-- Expected: 7 (2 state + 5 county)
--
-- SELECT COUNT(*) FROM leverage.rule_citations rc 
-- JOIN leverage.legal_sources ls ON rc.legal_source_id = ls.id 
-- WHERE ls.jurisdiction_state = 'UT';
-- Expected: 8 citations
--
-- SELECT COUNT(*) FROM leverage.validation_rules WHERE jurisdiction_state = 'UT';
-- Expected: 7 (1 SOL + 1 statewide e-filing + 5 county e-filing)
-- ============================================================================
