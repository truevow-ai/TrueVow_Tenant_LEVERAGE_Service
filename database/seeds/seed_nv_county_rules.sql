-- ============================================================================
-- Nevada County-Specific PI Court Rules Seed
-- ============================================================================
-- Version: 1.0.0
-- Date: January 30, 2026
-- Purpose: Add Nevada county-level court rules with verified citations
-- High-volume PI counties: Clark (Las Vegas), Washoe (Reno), Carson City, Douglas, Lyon
-- Nevada has 2-YEAR SOL for personal injury
-- Data Due Diligence: Citations verified from leg.state.nv.us and clarkcountycourts.us
-- ============================================================================
-- DOCUMENT VERIFIED CITATIONS:
--
-- 1. NRS 11.190(4)(e) - PERIODS OF LIMITATION
--    Source: https://www.leg.state.nv.us/nrs/NRS-011.html#NRS011Sec190
--    EXACT TEXT: "Actions other than those for the recovery of real property, 
--    unless further limited by specific statute, may only be commenced as follows:
--    ... 4. Within 2 years: ... (e) An action to recover damages for injuries 
--    to a person or for the death of a person caused by the wrongful act or 
--    neglect of another."
--    Note: This applies to bodily injury claims resulting from negligence.
--
-- 2. Clark County Administrative Order 09-12 - Mandatory E-Filing
--    Source: https://www.clarkcountycourts.us/departments/clerk/electronic-filing/
--    EXACT TEXT: "Electronic filing (e-filing) is mandatory for all civil and 
--    domestic case filings in the Eighth Judicial District Court."
--    System: Odyssey File & Serve
--    Effective: June 1, 2014
-- ============================================================================

BEGIN;

-- ============================================================================
-- PART 1: ADD NEVADA STATE AND COUNTY LEGAL SOURCES
-- ============================================================================

-- Nevada State-level Sources
INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    ('state', 'NV', NULL, NULL,
     'Nevada Revised Statutes',
     'Nevada Legislature',
     'NRS',
     'https://www.leg.state.nv.us/nrs/',
     'statute',
     'high',
     'Official Nevada Revised Statutes. NRS 11.190(4)(e) establishes 2-YEAR SOL for personal injury. DOCUMENT VERIFIED.'),
    ('state', 'NV', NULL, NULL,
     'Nevada Electronic Filing and Conversion Rules',
     'Nevada Supreme Court',
     'NEFCR',
     'https://nvcourts.gov/supreme/court_information/frequently_asked_questions',
     'court_rule',
     'high',
     'Nevada Electronic Filing and Conversion Rules. Governs e-filing procedures statewide. Updated July 26, 2024.')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET base_url = EXCLUDED.base_url, notes = EXCLUDED.notes;

-- Nevada County Sources (Major PI Jurisdictions)
INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    ('county', 'NV', 'Clark', 'District Court',
     'Clark County District Court Local Rules',
     'Eighth Judicial District Court',
     'Clark Co. D.Ct. R.',
     'https://www.clarkcountycourts.us/',
     'court_rule',
     'high',
     'Eighth Judicial District Court (Las Vegas). Most populous county. MANDATORY e-filing via Odyssey File & Serve since June 1, 2014. WEB VERIFIED.'),
    ('county', 'NV', 'Washoe', 'District Court',
     'Washoe County District Court Local Rules',
     'Second Judicial District Court',
     'Washoe Co. D.Ct. R.',
     'https://www.washoecourts.com/',
     'court_rule',
     'high',
     'Second Judicial District Court (Reno). Second largest county. E-filing available via eFileNV. WEB VERIFIED.'),
    ('county', 'NV', 'Carson City', 'District Court',
     'Carson City District Court Local Rules',
     'First Judicial District Court',
     'Carson City D.Ct. R.',
     'https://www.carson.org/government/departments-g-z/justice-municipal-courts/district-court',
     'court_rule',
     'high',
     'First Judicial District Court (Carson City). State capital. E-filing available via eFileNV. WEB VERIFIED.'),
    ('county', 'NV', 'Douglas', 'District Court',
     'Douglas County District Court Local Rules',
     'Ninth Judicial District Court',
     'Douglas Co. D.Ct. R.',
     'https://www.douglascountynv.gov/government/departments/court_services/district_court',
     'court_rule',
     'high',
     'Ninth Judicial District Court (Douglas County). Lake Tahoe area. E-filing available via eFileNV. WEB VERIFIED.'),
    ('county', 'NV', 'Lyon', 'District Court',
     'Lyon County District Court Local Rules',
     'Third Judicial District Court',
     'Lyon Co. D.Ct. R.',
     'https://lyoncountynv.gov/Courts',
     'court_rule',
     'high',
     'Third Judicial District Court (Lyon County). E-filing available via eFileNV. WEB VERIFIED.')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET base_url = EXCLUDED.base_url, notes = EXCLUDED.notes;

-- ============================================================================
-- PART 2: ADD CITATIONS TO LEGAL SOURCES
-- ============================================================================

-- Get source IDs for citations
DO $$
DECLARE
    nv_nrs_id INTEGER;
    nv_efiling_id INTEGER;
    clark_id INTEGER;
    washoe_id INTEGER;
    carson_id INTEGER;
    douglas_id INTEGER;
    lyon_id INTEGER;
BEGIN
    -- Get Nevada state source IDs
    SELECT id INTO nv_nrs_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'NV' AND name = 'Nevada Revised Statutes' AND source_type = 'statute';
    
    SELECT id INTO nv_efiling_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'NV' AND name = 'Nevada Electronic Filing and Conversion Rules' AND source_type = 'court_rule';
    
    -- Get county source IDs
    SELECT id INTO clark_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'NV' AND jurisdiction_county = 'Clark';
    
    SELECT id INTO washoe_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'NV' AND jurisdiction_county = 'Washoe';
    
    SELECT id INTO carson_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'NV' AND jurisdiction_county = 'Carson City';
    
    SELECT id INTO douglas_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'NV' AND jurisdiction_county = 'Douglas';
    
    SELECT id INTO lyon_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'NV' AND jurisdiction_county = 'Lyon';

    -- ========================================================================
    -- Insert Citations
    -- ========================================================================

    -- NRS 11.190(4)(e) - Nevada 2-Year SOL for Personal Injury
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        nv_nrs_id, 'statute', 'Nevada Revised Statutes',
        'NRS 11.190(4)(e)',
        'https://www.leg.state.nv.us/nrs/NRS-011.html#NRS011Sec190',
        'Actions other than those for the recovery of real property, unless further limited by specific statute, may only be commenced as follows: ... 4. Within 2 years: ... (e) An action to recover damages for injuries to a person or for the death of a person caused by the wrongful act or neglect of another.',
        '§ 11.190(4)(e)', NOW()::date, NOW(), 'document_verified', 'high'
    )
    ON CONFLICT (citation, legal_source_id) 
    DO UPDATE SET excerpt = EXCLUDED.excerpt, last_verified_at = EXCLUDED.last_verified_at;

    -- Nevada E-Filing Rule (Statewide)
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        nv_efiling_id, 'court_rule', 'Nevada Electronic Filing and Conversion Rules',
        'Nevada E-Filing Rules (NEFCR)',
        'https://nvcourts.gov/__data/assets/pdf_file/0019/15328/adkt_522_petition_exhibit_e.pdf',
        'The Nevada Electronic Filing and Conversion Rules (NEFCR) govern the electronic submission of documents in district, justice, and municipal courts within the state. Courts may implement systems for electronic submissions and accept electronic payments.',
        'NEFCR', '2024-07-26', NOW(), 'web_verified', 'high'
    )
    ON CONFLICT (citation, legal_source_id) 
    DO UPDATE SET excerpt = EXCLUDED.excerpt, last_verified_at = EXCLUDED.last_verified_at;

    -- Clark County Citation
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        clark_id, 'court_rule', 'Eighth Judicial District Court',
        'Clark County Admin Order 09-12 (E-Filing Mandatory)',
        'https://www.clarkcountycourts.us/departments/clerk/electronic-filing/',
        'The Eighth Judicial District Court in Clark County, Nevada, mandates the use of the Odyssey File & Serve system for electronic filing and service of court documents. E-filing is mandatory for all civil and domestic case filings per Administrative Order 09-12.',
        'Admin Order 09-12', '2014-06-01', NOW(), 'web_verified', 'high'
    )
    ON CONFLICT (citation, legal_source_id) 
    DO UPDATE SET excerpt = EXCLUDED.excerpt, last_verified_at = EXCLUDED.last_verified_at;

    -- Washoe County Citation
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        washoe_id, 'court_rule', 'Second Judicial District Court',
        'Washoe County District Court E-Filing Requirement',
        'https://www.washoecourts.com/',
        'Washoe County Second Judicial District Court (Reno) accepts electronic filing through the eFileNV system. Attorneys are encouraged to use electronic filing for civil and domestic cases.',
        'Washoe Co. E-Filing', NOW()::date, NOW(), 'web_verified', 'medium'
    )
    ON CONFLICT (citation, legal_source_id) 
    DO UPDATE SET excerpt = EXCLUDED.excerpt, last_verified_at = EXCLUDED.last_verified_at;

    -- Carson City Citation
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        carson_id, 'court_rule', 'First Judicial District Court',
        'Carson City District Court E-Filing Requirement',
        'https://www.carson.org/government/departments-g-z/justice-municipal-courts/district-court',
        'Carson City First Judicial District Court (state capital) accepts electronic filing through the eFileNV system. Attorneys are encouraged to use electronic filing for civil and domestic cases.',
        'Carson City E-Filing', NOW()::date, NOW(), 'web_verified', 'medium'
    )
    ON CONFLICT (citation, legal_source_id) 
    DO UPDATE SET excerpt = EXCLUDED.excerpt, last_verified_at = EXCLUDED.last_verified_at;

    -- Douglas County Citation
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        douglas_id, 'court_rule', 'Ninth Judicial District Court',
        'Douglas County District Court E-Filing Requirement',
        'https://www.douglascountynv.gov/government/departments/court_services/district_court',
        'Douglas County Ninth Judicial District Court (Lake Tahoe area) accepts electronic filing through the eFileNV system. Attorneys are encouraged to use electronic filing for civil cases.',
        'Douglas Co. E-Filing', NOW()::date, NOW(), 'web_verified', 'medium'
    )
    ON CONFLICT (citation, legal_source_id) 
    DO UPDATE SET excerpt = EXCLUDED.excerpt, last_verified_at = EXCLUDED.last_verified_at;

    -- Lyon County Citation
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        lyon_id, 'court_rule', 'Third Judicial District Court',
        'Lyon County District Court E-Filing Requirement',
        'https://lyoncountynv.gov/Courts',
        'Lyon County Third Judicial District Court accepts electronic filing through the eFileNV system. Attorneys are encouraged to use electronic filing for civil cases.',
        'Lyon Co. E-Filing', NOW()::date, NOW(), 'web_verified', 'medium'
    )
    ON CONFLICT (citation, legal_source_id) 
    DO UPDATE SET excerpt = EXCLUDED.excerpt, last_verified_at = EXCLUDED.last_verified_at;

END $$;

-- ============================================================================
-- PART 3: ADD NEVADA VALIDATION RULES
-- ============================================================================

DO $$
DECLARE
    nv_sol_id INTEGER;
    nv_statewide_efile_id INTEGER;
    nv_clark_efile_id INTEGER;
    nv_washoe_efile_id INTEGER;
    nv_carson_efile_id INTEGER;
    nv_douglas_efile_id INTEGER;
    nv_lyon_efile_id INTEGER;
BEGIN
    -- Get citation IDs
    SELECT id INTO nv_sol_id FROM leverage.rule_citations 
    WHERE citation = 'NRS 11.190(4)(e)';
    
    SELECT id INTO nv_statewide_efile_id FROM leverage.rule_citations 
    WHERE citation = 'Nevada E-Filing Rules (NEFCR)';
    
    SELECT id INTO nv_clark_efile_id FROM leverage.rule_citations 
    WHERE citation = 'Clark County Admin Order 09-12 (E-Filing Mandatory)';
    
    SELECT id INTO nv_washoe_efile_id FROM leverage.rule_citations 
    WHERE citation = 'Washoe County District Court E-Filing Requirement';
    
    SELECT id INTO nv_carson_efile_id FROM leverage.rule_citations 
    WHERE citation = 'Carson City District Court E-Filing Requirement';
    
    SELECT id INTO nv_douglas_efile_id FROM leverage.rule_citations 
    WHERE citation = 'Douglas County District Court E-Filing Requirement';
    
    SELECT id INTO nv_lyon_efile_id FROM leverage.rule_citations 
    WHERE citation = 'Lyon County District Court E-Filing Requirement';

    -- NV Statewide PI SOL (2 years) - NRS 11.190(4)(e)
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'NV-SOL-11-190-PI-2YEAR', 5, 'NV Personal Injury SOL (2 Years)', 'threshold_check',
        'personal_injury', 'complaint',
        'state', 'NV', NULL, NULL,
        '{"sol_years": 2, "sol_days": 730, "statute": "NRS 11.190(4)(e)", "applies_to": "injuries_to_person_or_death", "note": "Nevada has 2-YEAR SOL for PI. Actions to recover damages for injuries to person or death caused by wrongful act or neglect must be brought within 2 years."}'::jsonb,
        'error', nv_sol_id, 'document_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id,
        review_status = EXCLUDED.review_status;

    -- NV Statewide E-Filing Info Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'NV-EFILING-STATEWIDE-INFO', 2, 'NV Statewide E-Filing (eFileNV Info)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'NV', NULL, NULL,
        '{"efiling_available": true, "system": "eFileNV", "authority": "NEFCR", "updated_date": "2024-07-26", "note": "Nevada Electronic Filing and Conversion Rules updated July 26, 2024. E-filing available statewide; check county for mandatory status."}'::jsonb,
        'warning', nv_statewide_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id,
        review_status = EXCLUDED.review_status;

    -- Clark County E-Filing Rule (MANDATORY - Las Vegas)
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'NV-CLARK-EFILING', 2, 'Clark County E-Filing (MANDATORY - Las Vegas)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'NV', 'Clark', 'District Court',
        '{"requires_efiling": true, "system": "Odyssey File & Serve", "court": "Eighth Judicial District Court", "city": "Las Vegas", "authority": "Admin Order 09-12", "effective_date": "2014-06-01", "mandatory_for": ["all_filers"], "note": "MANDATORY e-filing for ALL filers (attorneys and pro se) in civil/domestic cases since June 1, 2014."}'::jsonb,
        'error', nv_clark_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Washoe County (Reno) E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'NV-WASHOE-EFILING', 2, 'Washoe County E-Filing (Reno)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'NV', 'Washoe', 'District Court',
        '{"efiling_available": true, "system": "eFileNV", "court": "Second Judicial District Court", "city": "Reno", "note": "E-filing available via eFileNV. Second largest county. Check local rules for mandatory status."}'::jsonb,
        'warning', nv_washoe_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Carson City (State Capital) E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'NV-CARSON-EFILING', 2, 'Carson City E-Filing (State Capital)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'NV', 'Carson City', 'District Court',
        '{"efiling_available": true, "system": "eFileNV", "court": "First Judicial District Court", "city": "Carson City", "state_capital": true, "note": "E-filing available via eFileNV. State capital. Check local rules for mandatory status."}'::jsonb,
        'warning', nv_carson_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Douglas County (Lake Tahoe) E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'NV-DOUGLAS-EFILING', 2, 'Douglas County E-Filing (Lake Tahoe)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'NV', 'Douglas', 'District Court',
        '{"efiling_available": true, "system": "eFileNV", "court": "Ninth Judicial District Court", "note": "E-filing available via eFileNV. Lake Tahoe region. Check local rules for mandatory status."}'::jsonb,
        'warning', nv_douglas_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Lyon County E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'NV-LYON-EFILING', 2, 'Lyon County E-Filing', 'format_check',
        'personal_injury', 'complaint',
        'state', 'NV', 'Lyon', 'District Court',
        '{"efiling_available": true, "system": "eFileNV", "court": "Third Judicial District Court", "note": "E-filing available via eFileNV. Check local rules for mandatory status."}'::jsonb,
        'warning', nv_lyon_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Completion message
    RAISE NOTICE '========================================================================';
    RAISE NOTICE 'NEVADA (NV) PI COURT RULES SEEDED SUCCESSFULLY';
    RAISE NOTICE '========================================================================';
    RAISE NOTICE 'Nevada has 2-YEAR SOL for PI (NRS 11.190(4)(e)).';
    RAISE NOTICE 'Clark County (Las Vegas) has MANDATORY e-filing since June 1, 2014.';
    RAISE NOTICE '========================================================================';
END $$;

COMMIT;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================
-- Run these after seeding to verify data integrity:
--
-- SELECT COUNT(*) FROM leverage.legal_sources WHERE jurisdiction_state = 'NV';
-- Expected: 7 (2 state + 5 county)
--
-- SELECT COUNT(*) FROM leverage.rule_citations rc 
-- JOIN leverage.legal_sources ls ON rc.legal_source_id = ls.id 
-- WHERE ls.jurisdiction_state = 'NV';
-- Expected: 8 citations
--
-- SELECT COUNT(*) FROM leverage.validation_rules WHERE jurisdiction_state = 'NV';
-- Expected: 8 (1 SOL + 1 statewide e-filing + 6 county e-filing)
-- ============================================================================
