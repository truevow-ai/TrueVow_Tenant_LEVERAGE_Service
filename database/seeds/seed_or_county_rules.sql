-- ============================================================================
-- Oregon County-Specific PI Court Rules Seed
-- ============================================================================
-- Version: 1.0.0
-- Date: January 30, 2026
-- Purpose: Add Oregon county-level court rules with verified citations
-- High-volume PI counties: Multnomah (Portland), Washington, Clackamas, Lane (Eugene), Marion (Salem)
-- Oregon has 2-YEAR SOL for personal injury
-- Data Due Diligence: Citations verified from oregon.public.law and courts.oregon.gov
-- ============================================================================
-- DOCUMENT VERIFIED CITATIONS:
--
-- 1. ORS 12.110 - ACTIONS FOR CERTAIN INJURIES TO PERSON NOT ARISING ON CONTRACT
--    Source: https://oregon.public.law/statutes/ors_12.110
--    EXACT TEXT (1): "An action for assault, battery, false imprisonment, or for 
--    any injury to the person or rights of another, not arising on contract, and 
--    not especially enumerated in this chapter, shall be commenced within two years"
--
-- 2. OJD eFiling Policy - Mandatory E-Filing for Oregon State Bar Members
--    Source: https://www.courts.oregon.gov/services/online/Documents/eFile/OJD-Policy-and-Standards-for-Acceptance-of-Electronic-Filings-in-the-Oregon-Circuit-Courts.pdf
--    Effective: December 1, 2014
--    EXACT TEXT: "The Oregon Judicial Department (OJD) has established a mandatory 
--    eFiling policy for active members of the Oregon State Bar in circuit courts 
--    utilizing the File and Serve system."
-- ============================================================================

BEGIN;

-- ============================================================================
-- PART 1: ADD OREGON STATE AND COUNTY LEGAL SOURCES
-- ============================================================================

-- Oregon State-level Sources
INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    ('state', 'OR', NULL, NULL,
     'Oregon Revised Statutes',
     'Oregon Legislative Assembly',
     'ORS',
     'https://oregon.public.law/statutes/',
     'statute',
     'high',
     'Official Oregon Revised Statutes. ORS 12.110 establishes 2-year SOL for personal injury. DOCUMENT VERIFIED from oregon.public.law.'),
    ('state', 'OR', NULL, NULL,
     'Oregon Judicial Department E-Filing Rules',
     'Oregon Judicial Department',
     'OJD eFiling',
     'https://www.courts.oregon.gov/services/online/Pages/eFiling.aspx',
     'court_rule',
     'high',
     'Oregon Judicial Department mandatory e-filing rules. File and Serve system. Mandatory for attorneys since Dec 1, 2014.')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET base_url = EXCLUDED.base_url, notes = EXCLUDED.notes;

-- Oregon County Sources (Major PI Jurisdictions)
INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    ('county', 'OR', 'Multnomah', 'Circuit Court',
     'Multnomah County Circuit Court Local Rules',
     'Multnomah County Circuit Court',
     'Mult. Co. Cir. Ct. R.',
     'https://www.courts.oregon.gov/courts/multnomah',
     'court_rule',
     'high',
     'Multnomah County Circuit Court (Portland). Most populous county in Oregon. Mandatory e-filing for attorneys since Dec 1, 2014. WEB VERIFIED.'),
    ('county', 'OR', 'Washington', 'Circuit Court',
     'Washington County Circuit Court Local Rules',
     'Washington County Circuit Court',
     'Wash. Co. Cir. Ct. R.',
     'https://www.courts.oregon.gov/courts/washington',
     'court_rule',
     'high',
     'Washington County Circuit Court. Second most populous county. Mandatory e-filing for attorneys. WEB VERIFIED.'),
    ('county', 'OR', 'Clackamas', 'Circuit Court',
     'Clackamas County Circuit Court Local Rules',
     'Clackamas County Circuit Court',
     'Clack. Co. Cir. Ct. R.',
     'https://www.courts.oregon.gov/courts/clackamas',
     'court_rule',
     'high',
     'Clackamas County Circuit Court. Portland metro area. Mandatory e-filing for attorneys. WEB VERIFIED.'),
    ('county', 'OR', 'Lane', 'Circuit Court',
     'Lane County Circuit Court Local Rules',
     'Lane County Circuit Court',
     'Lane Co. Cir. Ct. R.',
     'https://www.courts.oregon.gov/courts/lane',
     'court_rule',
     'high',
     'Lane County Circuit Court (Eugene). Mandatory e-filing for attorneys. WEB VERIFIED.'),
    ('county', 'OR', 'Marion', 'Circuit Court',
     'Marion County Circuit Court Local Rules',
     'Marion County Circuit Court',
     'Marion Co. Cir. Ct. R.',
     'https://www.courts.oregon.gov/courts/marion',
     'court_rule',
     'high',
     'Marion County Circuit Court (Salem). State capital. Mandatory e-filing for attorneys. WEB VERIFIED.')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET base_url = EXCLUDED.base_url, notes = EXCLUDED.notes;

-- ============================================================================
-- PART 2: ADD OREGON STATE AND COUNTY CITATIONS
-- ============================================================================

DO $$
DECLARE
    or_ors_id INTEGER;
    or_ojd_id INTEGER;
    or_multnomah_id INTEGER;
    or_washington_id INTEGER;
    or_clackamas_id INTEGER;
    or_lane_id INTEGER;
    or_marion_id INTEGER;
BEGIN
    -- Get legal source IDs
    SELECT id INTO or_ors_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'OR' AND abbreviation = 'ORS';
    
    SELECT id INTO or_ojd_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'OR' AND abbreviation = 'OJD eFiling';
    
    SELECT id INTO or_multnomah_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'OR' AND jurisdiction_county = 'Multnomah';
    
    SELECT id INTO or_washington_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'OR' AND jurisdiction_county = 'Washington';
    
    SELECT id INTO or_clackamas_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'OR' AND jurisdiction_county = 'Clackamas';
    
    SELECT id INTO or_lane_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'OR' AND jurisdiction_county = 'Lane';
    
    SELECT id INTO or_marion_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'OR' AND jurisdiction_county = 'Marion';

    -- ORS 12.110 - Oregon 2-Year SOL for Personal Injury
    -- DOCUMENT VERIFIED: EXACT TEXT from oregon.public.law
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        or_ors_id, 'statute', 'Oregon Revised Statutes',
        'ORS 12.110',
        'https://oregon.public.law/statutes/ors_12.110',
        'An action for assault, battery, false imprisonment, or for any injury to the person or rights of another, not arising on contract, and not especially enumerated in this chapter, shall be commenced within two years; provided, that in an action at law based upon fraud or deceit, the limitation shall be deemed to commence only from the discovery of the fraud or deceit.',
        '§ 12.110(1)', NOW()::date, NOW(), 'document_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        verifier = EXCLUDED.verifier;

    -- OJD E-Filing Policy - Mandatory for Oregon State Bar Members
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        or_ojd_id, 'court_rule', 'Oregon Judicial Department E-Filing Rules',
        'OJD eFiling Policy',
        'https://www.courts.oregon.gov/services/online/Documents/eFile/OJD-Policy-and-Standards-for-Acceptance-of-Electronic-Filings-in-the-Oregon-Circuit-Courts.pdf',
        'The Oregon Judicial Department (OJD) has established a mandatory eFiling policy for active members of the Oregon State Bar in circuit courts utilizing the File and Serve system. This policy, effective since December 1, 2014, aims to standardize the acceptance and return of electronic filings across all Oregon circuit courts.',
        'E-Filing Policy', '2014-12-01', NOW(), 'document_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Statewide E-Filing - All Circuit Courts
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        or_ojd_id, 'court_rule', 'Oregon Judicial Department E-Filing Rules',
        'OR-STATEWIDE-EFILING',
        'https://www.courts.oregon.gov/services/online/Pages/eFiling.aspx',
        'Electronic filing is mandatory for active members of the Oregon State Bar in all Oregon circuit courts using the File and Serve system. The OJD eFiling system was first implemented in 2013 with mandatory eFiling fully operational in all circuit courts by fall 2016. UTCR Chapter 21 governs electronic filing procedures.',
        'E-Filing', '2014-12-01', NOW(), 'document_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        verifier = EXCLUDED.verifier;

    -- Multnomah County (Portland) E-Filing Citation
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        or_multnomah_id, 'local_rule', 'Multnomah County Circuit Court Local Rules',
        'OR-MULTNOMAH-EFILING',
        'https://www.courts.oregon.gov/courts/multnomah',
        'Multnomah County Circuit Court (Portland). Mandatory e-filing for Oregon State Bar members per OJD eFiling Policy. File and Serve system. Most populous county in Oregon.',
        'E-Filing', '2014-12-01', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Washington County E-Filing Citation
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        or_washington_id, 'local_rule', 'Washington County Circuit Court Local Rules',
        'OR-WASHINGTON-EFILING',
        'https://www.courts.oregon.gov/courts/washington',
        'Washington County Circuit Court. Mandatory e-filing for Oregon State Bar members per OJD eFiling Policy. Second most populous county.',
        'E-Filing', '2014-12-01', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Clackamas County E-Filing Citation
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        or_clackamas_id, 'local_rule', 'Clackamas County Circuit Court Local Rules',
        'OR-CLACKAMAS-EFILING',
        'https://www.courts.oregon.gov/courts/clackamas',
        'Clackamas County Circuit Court. Portland metro area. Mandatory e-filing for Oregon State Bar members per OJD eFiling Policy.',
        'E-Filing', '2014-12-01', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Lane County (Eugene) E-Filing Citation
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        or_lane_id, 'local_rule', 'Lane County Circuit Court Local Rules',
        'OR-LANE-EFILING',
        'https://www.courts.oregon.gov/courts/lane',
        'Lane County Circuit Court (Eugene). Mandatory e-filing for Oregon State Bar members per OJD eFiling Policy.',
        'E-Filing', '2014-12-01', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Marion County (Salem) E-Filing Citation
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        or_marion_id, 'local_rule', 'Marion County Circuit Court Local Rules',
        'OR-MARION-EFILING',
        'https://www.courts.oregon.gov/courts/marion',
        'Marion County Circuit Court (Salem). State capital. Mandatory e-filing for Oregon State Bar members per OJD eFiling Policy.',
        'E-Filing', '2014-12-01', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

END $$;

-- ============================================================================
-- PART 3: ADD OREGON VALIDATION RULES
-- ============================================================================

DO $$
DECLARE
    or_sol_id INTEGER;
    or_ojd_policy_id INTEGER;
    or_statewide_efile_id INTEGER;
    or_multnomah_efile_id INTEGER;
    or_washington_efile_id INTEGER;
    or_clackamas_efile_id INTEGER;
    or_lane_efile_id INTEGER;
    or_marion_efile_id INTEGER;
BEGIN
    -- Get citation IDs
    SELECT id INTO or_sol_id FROM leverage.rule_citations 
    WHERE citation = 'ORS 12.110';
    
    SELECT id INTO or_ojd_policy_id FROM leverage.rule_citations 
    WHERE citation = 'OJD eFiling Policy';
    
    SELECT id INTO or_statewide_efile_id FROM leverage.rule_citations 
    WHERE citation = 'OR-STATEWIDE-EFILING';
    
    SELECT id INTO or_multnomah_efile_id FROM leverage.rule_citations 
    WHERE citation = 'OR-MULTNOMAH-EFILING';
    
    SELECT id INTO or_washington_efile_id FROM leverage.rule_citations 
    WHERE citation = 'OR-WASHINGTON-EFILING';
    
    SELECT id INTO or_clackamas_efile_id FROM leverage.rule_citations 
    WHERE citation = 'OR-CLACKAMAS-EFILING';
    
    SELECT id INTO or_lane_efile_id FROM leverage.rule_citations 
    WHERE citation = 'OR-LANE-EFILING';
    
    SELECT id INTO or_marion_efile_id FROM leverage.rule_citations 
    WHERE citation = 'OR-MARION-EFILING';

    -- OR Statewide PI SOL (2 years) - ORS 12.110
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'OR-SOL-12-110-PI-2YEAR', 5, 'OR Personal Injury SOL (2 Years)', 'threshold_check',
        'personal_injury', 'complaint',
        'state', 'OR', NULL, NULL,
        '{"sol_years": 2, "sol_days": 730, "statute": "ORS 12.110", "subsection": "(1)", "applies_to": "injury_to_person_or_rights", "note": "Oregon has 2-YEAR SOL for PI. Action for assault, battery, false imprisonment, or any injury to person or rights not arising on contract must be commenced within 2 years."}'::jsonb,
        'error', or_sol_id, 'document_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id,
        review_status = EXCLUDED.review_status;

    -- OR Statewide E-Filing Rule (Mandatory since Dec 1, 2014)
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'OR-EFILING-STATEWIDE', 2, 'OR Statewide E-Filing (Mandatory for OSB Members)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'OR', NULL, NULL,
        '{"requires_efiling": true, "system": "File and Serve", "authority": "OJD eFiling Policy", "effective_date": "2014-12-01", "mandatory_for": ["Oregon State Bar members"], "all_circuit_courts": true, "utcr": "Chapter 21", "note": "DOCUMENT VERIFIED: E-filing mandatory for Oregon State Bar members in all circuit courts since Dec 1, 2014. OJD system first implemented 2013, fully operational fall 2016."}'::jsonb,
        'error', or_statewide_efile_id, 'document_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id,
        review_status = EXCLUDED.review_status;

    -- Multnomah County (Portland) E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'OR-MULTNOMAH-EFILING', 2, 'Multnomah County E-Filing (Portland)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'OR', 'Multnomah', 'Circuit Court',
        '{"requires_efiling": true, "system": "File and Serve", "city": "Portland", "effective_date": "2014-12-01", "court_url": "https://www.courts.oregon.gov/courts/multnomah", "note": "Most populous county in Oregon. Mandatory e-filing for OSB members."}'::jsonb,
        'error', or_multnomah_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Washington County E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'OR-WASHINGTON-EFILING', 2, 'Washington County E-Filing', 'format_check',
        'personal_injury', 'complaint',
        'state', 'OR', 'Washington', 'Circuit Court',
        '{"requires_efiling": true, "system": "File and Serve", "effective_date": "2014-12-01", "court_url": "https://www.courts.oregon.gov/courts/washington", "note": "Second most populous county. Mandatory e-filing for OSB members."}'::jsonb,
        'error', or_washington_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Clackamas County E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'OR-CLACKAMAS-EFILING', 2, 'Clackamas County E-Filing', 'format_check',
        'personal_injury', 'complaint',
        'state', 'OR', 'Clackamas', 'Circuit Court',
        '{"requires_efiling": true, "system": "File and Serve", "region": "Portland Metro", "effective_date": "2014-12-01", "court_url": "https://www.courts.oregon.gov/courts/clackamas", "note": "Portland metro area. Mandatory e-filing for OSB members."}'::jsonb,
        'error', or_clackamas_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Lane County (Eugene) E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'OR-LANE-EFILING', 2, 'Lane County E-Filing (Eugene)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'OR', 'Lane', 'Circuit Court',
        '{"requires_efiling": true, "system": "File and Serve", "city": "Eugene", "effective_date": "2014-12-01", "court_url": "https://www.courts.oregon.gov/courts/lane", "note": "Mandatory e-filing for OSB members."}'::jsonb,
        'error', or_lane_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Marion County (Salem) E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'OR-MARION-EFILING', 2, 'Marion County E-Filing (Salem)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'OR', 'Marion', 'Circuit Court',
        '{"requires_efiling": true, "system": "File and Serve", "city": "Salem", "effective_date": "2014-12-01", "court_url": "https://www.courts.oregon.gov/courts/marion", "note": "State capital. Mandatory e-filing for OSB members."}'::jsonb,
        'error', or_marion_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Completion message
    RAISE NOTICE '========================================================================';
    RAISE NOTICE 'OREGON (OR) PI COURT RULES SEEDED SUCCESSFULLY';
    RAISE NOTICE '========================================================================';
    RAISE NOTICE 'Legal Sources: 7 (2 state + 5 county courts)';
    RAISE NOTICE 'Citations: 8 (ORS 12.110, OJD Policy, statewide e-filing + 5 county)';
    RAISE NOTICE 'Validation Rules: 7 (1 SOL + 1 statewide e-filing + 5 county e-filing)';
    RAISE NOTICE '';
    RAISE NOTICE 'DOCUMENT VERIFIED:';
    RAISE NOTICE '  - ORS 12.110 (2-year SOL) from oregon.public.law';
    RAISE NOTICE '  - OJD eFiling Policy from courts.oregon.gov';
    RAISE NOTICE '';
    RAISE NOTICE 'Oregon has 2-YEAR SOL for PI';
    RAISE NOTICE 'E-Filing MANDATORY for Oregon State Bar members since Dec 1, 2014';
    RAISE NOTICE 'File and Serve system used in all circuit courts';
    RAISE NOTICE '========================================================================';

END $$;

COMMIT;
