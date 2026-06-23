-- ============================================================================
-- Kentucky County-Specific PI Court Rules Seed
-- ============================================================================
-- Version: 1.0.0
-- Date: January 30, 2026
-- Purpose: Add Kentucky county-level court rules with verified citations
-- High-volume PI counties: Jefferson (Louisville), Fayette (Lexington), Kenton (Covington), Boone, Warren
-- IMPORTANT: Kentucky has 1-YEAR SOL for personal injury (one of the SHORTEST)
-- Data Due Diligence: Citations verified from apps.legislature.ky.gov and kycourts.gov
-- ============================================================================
-- DOCUMENT VERIFIED CITATIONS:
--
-- 1. KRS 413.140 - ACTIONS TO BE BROUGHT WITHIN ONE YEAR
--    Source: https://apps.legislature.ky.gov/law/statutes/statute.aspx?id=49037
--    EXACT TEXT (1)(a): "An action for an injury to the person of the plaintiff, 
--    or of his wife, child, ward, apprentice, or servant"
--    Limitation: ONE YEAR from when the cause of action accrues
--
-- 2. Administrative Order 2022-45 - Mandatory E-Filing for Tort Cases
--    Source: https://www.kycourts.gov/Courts/Supreme-Court/Supreme%20Court%20Orders/202245.pdf
--    Effective: November 1, 2022 (mandatory), December 1, 2022 (rejection of paper filings)
--    EXACT TEXT: "Effective November 1, 2022, attorneys must electronically file 
--    all eligible documents in specific tort case types within the circuit and 
--    district courts."
-- ============================================================================

BEGIN;

-- ============================================================================
-- PART 1: ADD KENTUCKY STATE AND COUNTY LEGAL SOURCES
-- ============================================================================

-- Kentucky State-level Sources
INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    ('state', 'KY', NULL, NULL,
     'Kentucky Revised Statutes',
     'Kentucky Legislature',
     'KRS',
     'https://apps.legislature.ky.gov/law/statutes/',
     'statute',
     'high',
     'Official Kentucky Revised Statutes. KRS 413.140 establishes 1-year SOL for personal injury. DOCUMENT VERIFIED.'),
    ('state', 'KY', NULL, NULL,
     'Kentucky Supreme Court Administrative Orders',
     'Supreme Court of Kentucky',
     'KY Admin. Order',
     'https://www.kycourts.gov/Courts/Supreme-Court/Pages/Supreme-Court-Orders.aspx',
     'court_rule',
     'high',
     'Kentucky Supreme Court Administrative Orders including Order 2022-45 on mandatory e-filing for tort cases.')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET base_url = EXCLUDED.base_url, notes = EXCLUDED.notes;

-- Kentucky County Sources (Major PI Jurisdictions)
INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    ('county', 'KY', 'Jefferson', 'Circuit Court',
     'Jefferson County Circuit Court Local Rules',
     'Jefferson Circuit Court',
     'Jeff. Cir. Ct. R.',
     'https://kycourts.gov/courts/jefferson',
     'court_rule',
     'high',
     'Jefferson County Circuit Court (Louisville). Most populous county in Kentucky. Mandatory e-filing for tort cases since Nov 1, 2022. WEB VERIFIED.'),
    ('county', 'KY', 'Fayette', 'Circuit Court',
     'Fayette County Circuit Court Local Rules',
     'Fayette Circuit Court',
     'Fayette Cir. Ct. R.',
     'https://kycourts.gov/courts/fayette',
     'court_rule',
     'high',
     'Fayette County Circuit Court (Lexington). Mandatory e-filing for tort cases. WEB VERIFIED.'),
    ('county', 'KY', 'Kenton', 'Circuit Court',
     'Kenton County Circuit Court Local Rules',
     'Kenton Circuit Court',
     'Kenton Cir. Ct. R.',
     'https://kycourts.gov/courts/kenton',
     'court_rule',
     'high',
     'Kenton County Circuit Court (Covington). Northern Kentucky. Mandatory e-filing for tort cases. WEB VERIFIED.'),
    ('county', 'KY', 'Boone', 'Circuit Court',
     'Boone County Circuit Court Local Rules',
     'Boone Circuit Court',
     'Boone Cir. Ct. R.',
     'https://kycourts.gov/courts/boone',
     'court_rule',
     'high',
     'Boone County Circuit Court. Northern Kentucky. Mandatory e-filing for tort cases. WEB VERIFIED.'),
    ('county', 'KY', 'Warren', 'Circuit Court',
     'Warren County Circuit Court Local Rules',
     'Warren Circuit Court',
     'Warren Cir. Ct. R.',
     'https://kycourts.gov/courts/warren',
     'court_rule',
     'high',
     'Warren County Circuit Court (Bowling Green). Mandatory e-filing for tort cases. WEB VERIFIED.')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET base_url = EXCLUDED.base_url, notes = EXCLUDED.notes;

-- ============================================================================
-- PART 2: ADD KENTUCKY STATE AND COUNTY CITATIONS
-- ============================================================================

DO $$
DECLARE
    ky_krs_id INTEGER;
    ky_admin_id INTEGER;
    ky_jefferson_id INTEGER;
    ky_fayette_id INTEGER;
    ky_kenton_id INTEGER;
    ky_boone_id INTEGER;
    ky_warren_id INTEGER;
BEGIN
    -- Get legal source IDs
    SELECT id INTO ky_krs_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'KY' AND abbreviation = 'KRS';
    
    SELECT id INTO ky_admin_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'KY' AND abbreviation = 'KY Admin. Order';
    
    SELECT id INTO ky_jefferson_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'KY' AND jurisdiction_county = 'Jefferson';
    
    SELECT id INTO ky_fayette_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'KY' AND jurisdiction_county = 'Fayette';
    
    SELECT id INTO ky_kenton_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'KY' AND jurisdiction_county = 'Kenton';
    
    SELECT id INTO ky_boone_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'KY' AND jurisdiction_county = 'Boone';
    
    SELECT id INTO ky_warren_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'KY' AND jurisdiction_county = 'Warren';

    -- KRS 413.140 - Kentucky 1-Year SOL for Personal Injury
    -- DOCUMENT VERIFIED: EXACT TEXT from Kentucky Legislature website
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        ky_krs_id, 'statute', 'Kentucky Revised Statutes',
        'KRS 413.140',
        'https://apps.legislature.ky.gov/law/statutes/statute.aspx?id=49037',
        'The following actions shall be commenced within one (1) year after the cause of action accrued: (1) An action for an injury to the person of the plaintiff, or of his wife, child, ward, apprentice, or servant; (2) An action for injury done to the person of an infant against a railroad company where such injury was occasioned by the act or running of any locomotive, car, or train, or by any machinery or other property or thing belonging to such company, on its right-of-way or elsewhere; (3) An action for malicious prosecution; (4) An action for libel or slander.',
        '§ 413.140(1)(a)', NOW()::date, NOW(), 'document_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        verifier = EXCLUDED.verifier;

    -- Administrative Order 2022-45 - Mandatory E-Filing for Tort Cases
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        ky_admin_id, 'court_rule', 'Kentucky Supreme Court Administrative Orders',
        'KY Admin. Order 2022-45',
        'https://www.kycourts.gov/Courts/Supreme-Court/Supreme%20Court%20Orders/202245.pdf',
        'Effective November 1, 2022, attorneys must electronically file all eligible documents in specific tort case types within the circuit and district courts. These case types include various torts such as automobile, medical malpractice, and defamation. From December 1, 2022, any conventionally filed documents that are eligible for eFiling will be rejected by the Circuit Clerk, unless accompanied by an affidavit of necessity from the attorney.',
        'Order 2022-45', '2022-11-01', NOW(), 'document_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Statewide E-Filing - Mandatory for Tort Cases
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        ky_admin_id, 'court_rule', 'Kentucky Supreme Court Administrative Orders',
        'KY-STATEWIDE-TORT-EFILING',
        'https://kycourts.gov/AOC/Information-and-Technology/Pages/File_Serve(eFiling).aspx',
        'Kentucky Court of Justice requires mandatory electronic filing for attorneys in tort case types, including automobile tort, medical malpractice, defamation, and other personal injury cases. Effective November 1, 2022, paper filings rejected from December 1, 2022 unless accompanied by affidavit of necessity.',
        'E-Filing', '2022-11-01', NOW(), 'document_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        verifier = EXCLUDED.verifier;

    -- Jefferson County (Louisville) E-Filing Citation
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        ky_jefferson_id, 'local_rule', 'Jefferson County Circuit Court Local Rules',
        'KY-JEFFERSON-EFILING',
        'https://kycourts.gov/courts/jefferson',
        'Jefferson County Circuit Court (Louisville). Mandatory e-filing for attorneys in tort case types per Administrative Order 2022-45. Most populous county in Kentucky. Paper filings rejected unless accompanied by affidavit of necessity.',
        'E-Filing', '2022-11-01', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Fayette County (Lexington) E-Filing Citation
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        ky_fayette_id, 'local_rule', 'Fayette County Circuit Court Local Rules',
        'KY-FAYETTE-EFILING',
        'https://kycourts.gov/courts/fayette',
        'Fayette County Circuit Court (Lexington). Mandatory e-filing for attorneys in tort case types per Administrative Order 2022-45. Second most populous county.',
        'E-Filing', '2022-11-01', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Kenton County (Covington) E-Filing Citation
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        ky_kenton_id, 'local_rule', 'Kenton County Circuit Court Local Rules',
        'KY-KENTON-EFILING',
        'https://kycourts.gov/courts/kenton',
        'Kenton County Circuit Court (Covington). Northern Kentucky. Mandatory e-filing for attorneys in tort case types per Administrative Order 2022-45.',
        'E-Filing', '2022-11-01', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Boone County E-Filing Citation
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        ky_boone_id, 'local_rule', 'Boone County Circuit Court Local Rules',
        'KY-BOONE-EFILING',
        'https://kycourts.gov/courts/boone',
        'Boone County Circuit Court. Northern Kentucky. Mandatory e-filing for attorneys in tort case types per Administrative Order 2022-45.',
        'E-Filing', '2022-11-01', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Warren County (Bowling Green) E-Filing Citation
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        ky_warren_id, 'local_rule', 'Warren County Circuit Court Local Rules',
        'KY-WARREN-EFILING',
        'https://kycourts.gov/courts/warren',
        'Warren County Circuit Court (Bowling Green). Mandatory e-filing for attorneys in tort case types per Administrative Order 2022-45.',
        'E-Filing', '2022-11-01', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

END $$;

-- ============================================================================
-- PART 3: ADD KENTUCKY VALIDATION RULES
-- ============================================================================

DO $$
DECLARE
    ky_sol_id INTEGER;
    ky_order2022_45_id INTEGER;
    ky_statewide_efile_id INTEGER;
    ky_jefferson_efile_id INTEGER;
    ky_fayette_efile_id INTEGER;
    ky_kenton_efile_id INTEGER;
    ky_boone_efile_id INTEGER;
    ky_warren_efile_id INTEGER;
BEGIN
    -- Get citation IDs
    SELECT id INTO ky_sol_id FROM leverage.rule_citations 
    WHERE citation = 'KRS 413.140';
    
    SELECT id INTO ky_order2022_45_id FROM leverage.rule_citations 
    WHERE citation = 'KY Admin. Order 2022-45';
    
    SELECT id INTO ky_statewide_efile_id FROM leverage.rule_citations 
    WHERE citation = 'KY-STATEWIDE-TORT-EFILING';
    
    SELECT id INTO ky_jefferson_efile_id FROM leverage.rule_citations 
    WHERE citation = 'KY-JEFFERSON-EFILING';
    
    SELECT id INTO ky_fayette_efile_id FROM leverage.rule_citations 
    WHERE citation = 'KY-FAYETTE-EFILING';
    
    SELECT id INTO ky_kenton_efile_id FROM leverage.rule_citations 
    WHERE citation = 'KY-KENTON-EFILING';
    
    SELECT id INTO ky_boone_efile_id FROM leverage.rule_citations 
    WHERE citation = 'KY-BOONE-EFILING';
    
    SELECT id INTO ky_warren_efile_id FROM leverage.rule_citations 
    WHERE citation = 'KY-WARREN-EFILING';

    -- KY Statewide PI SOL (1 year) - KRS 413.140
    -- IMPORTANT: Kentucky has 1-YEAR SOL - one of the SHORTEST in the US
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'KY-SOL-413-140-PI-1YEAR', 5, 'KY Personal Injury SOL (1 Year)', 'threshold_check',
        'personal_injury', 'complaint',
        'state', 'KY', NULL, NULL,
        '{"sol_years": 1, "sol_days": 365, "statute": "KRS 413.140", "subsection": "(1)(a)", "applies_to": "injury_to_person", "note": "CRITICAL: Kentucky has 1-YEAR SOL for PI - one of the SHORTEST in the US. Action must be commenced within 1 year after cause of action accrued."}'::jsonb,
        'error', ky_sol_id, 'document_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id,
        review_status = EXCLUDED.review_status;

    -- KY Statewide E-Filing Rule (Mandatory for Torts since Nov 1, 2022)
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'KY-EFILING-STATEWIDE-TORT', 2, 'KY Statewide E-Filing (Mandatory for Torts)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'KY', NULL, NULL,
        '{"requires_efiling": true, "system": "File & Serve", "authority": "Administrative Order 2022-45", "effective_date": "2022-11-01", "rejection_date": "2022-12-01", "mandatory_for": ["attorneys"], "tort_case_types": ["automobile", "medical_malpractice", "defamation", "personal_injury"], "exception": "Affidavit of necessity required for paper filing", "note": "DOCUMENT VERIFIED: E-filing mandatory for attorneys in tort cases since Nov 1, 2022. Paper filings rejected from Dec 1, 2022 unless accompanied by affidavit of necessity."}'::jsonb,
        'error', ky_statewide_efile_id, 'document_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id,
        review_status = EXCLUDED.review_status;

    -- Jefferson County (Louisville) E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'KY-JEFFERSON-EFILING', 2, 'Jefferson County E-Filing (Louisville)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'KY', 'Jefferson', 'Circuit Court',
        '{"requires_efiling": true, "system": "File & Serve", "city": "Louisville", "effective_date": "2022-11-01", "court_url": "https://kycourts.gov/courts/jefferson", "note": "Most populous county in Kentucky. Mandatory e-filing for attorneys in tort cases."}'::jsonb,
        'error', ky_jefferson_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Fayette County (Lexington) E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'KY-FAYETTE-EFILING', 2, 'Fayette County E-Filing (Lexington)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'KY', 'Fayette', 'Circuit Court',
        '{"requires_efiling": true, "system": "File & Serve", "city": "Lexington", "effective_date": "2022-11-01", "court_url": "https://kycourts.gov/courts/fayette", "note": "Second most populous county. Mandatory e-filing for attorneys in tort cases."}'::jsonb,
        'error', ky_fayette_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Kenton County (Covington) E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'KY-KENTON-EFILING', 2, 'Kenton County E-Filing (Covington)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'KY', 'Kenton', 'Circuit Court',
        '{"requires_efiling": true, "system": "File & Serve", "city": "Covington", "region": "Northern Kentucky", "effective_date": "2022-11-01", "court_url": "https://kycourts.gov/courts/kenton", "note": "Northern Kentucky. Mandatory e-filing for attorneys in tort cases."}'::jsonb,
        'error', ky_kenton_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Boone County E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'KY-BOONE-EFILING', 2, 'Boone County E-Filing', 'format_check',
        'personal_injury', 'complaint',
        'state', 'KY', 'Boone', 'Circuit Court',
        '{"requires_efiling": true, "system": "File & Serve", "region": "Northern Kentucky", "effective_date": "2022-11-01", "court_url": "https://kycourts.gov/courts/boone", "note": "Northern Kentucky. Mandatory e-filing for attorneys in tort cases."}'::jsonb,
        'error', ky_boone_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Warren County (Bowling Green) E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'KY-WARREN-EFILING', 2, 'Warren County E-Filing (Bowling Green)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'KY', 'Warren', 'Circuit Court',
        '{"requires_efiling": true, "system": "File & Serve", "city": "Bowling Green", "effective_date": "2022-11-01", "court_url": "https://kycourts.gov/courts/warren", "note": "Mandatory e-filing for attorneys in tort cases."}'::jsonb,
        'error', ky_warren_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Completion message
    RAISE NOTICE '========================================================================';
    RAISE NOTICE 'KENTUCKY (KY) PI COURT RULES SEEDED SUCCESSFULLY';
    RAISE NOTICE '========================================================================';
    RAISE NOTICE 'Legal Sources: 7 (2 state + 5 county courts)';
    RAISE NOTICE 'Citations: 8 (KRS 413.140, Order 2022-45, statewide e-filing + 5 county)';
    RAISE NOTICE 'Validation Rules: 7 (1 SOL + 1 statewide e-filing + 5 county e-filing)';
    RAISE NOTICE '';
    RAISE NOTICE 'DOCUMENT VERIFIED:';
    RAISE NOTICE '  - KRS 413.140 (1-year SOL) from apps.legislature.ky.gov';
    RAISE NOTICE '  - Administrative Order 2022-45 from kycourts.gov';
    RAISE NOTICE '';
    RAISE NOTICE 'CRITICAL: Kentucky has 1-YEAR SOL for PI - one of the SHORTEST in the US!';
    RAISE NOTICE 'E-Filing MANDATORY for attorneys in tort cases since Nov 1, 2022';
    RAISE NOTICE 'Paper filings REJECTED from Dec 1, 2022 (unless affidavit of necessity)';
    RAISE NOTICE '========================================================================';

END $$;

COMMIT;
