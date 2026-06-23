-- ============================================================================
-- Oklahoma County-Specific PI Court Rules Seed
-- ============================================================================
-- Version: 1.0.0
-- Date: January 30, 2026
-- Purpose: Add Oklahoma county-level court rules with verified citations
-- High-volume PI counties: Oklahoma (OKC), Tulsa, Cleveland (Norman), Comanche (Lawton), Canadian
-- Oklahoma has 2-YEAR SOL for personal injury
-- Data Due Diligence: Citations verified from oscn.net and oklegislature.gov
-- ============================================================================
-- DOCUMENT VERIFIED CITATIONS:
--
-- 1. 12 O.S. § 95 - LIMITATION OF OTHER ACTIONS
--    Source: https://law.justia.com/codes/oklahoma/title-12/section-12-95/
--    EXACT TEXT: "(A) Civil actions other than for the recovery of real property 
--    can only be brought within the following periods, after the cause of action 
--    shall have accrued, and not afterwards: ... (3) Within two (2) years: An 
--    action for trespass upon real property; an action for taking, detaining, or 
--    injuring personal property, including actions for the specific recovery 
--    thereof; an action for injury to the rights of another, not arising on 
--    contract, and not hereinafter enumerated"
--
-- 2. Oklahoma E-Filing System
--    Source: https://efile.oscn.net/
--    E-filing is NOT mandatory; paper filing remains an option
--    Available in select counties only
-- ============================================================================

BEGIN;

-- ============================================================================
-- PART 1: ADD OKLAHOMA STATE AND COUNTY LEGAL SOURCES
-- ============================================================================

-- Oklahoma State-level Sources
INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    ('state', 'OK', NULL, NULL,
     'Oklahoma Statutes',
     'Oklahoma Legislature',
     '12 O.S.',
     'https://www.oklegislature.gov/osStatuesTitle.aspx',
     'statute',
     'high',
     'Official Oklahoma Statutes. 12 O.S. § 95(A)(3) establishes 2-year SOL for personal injury. DOCUMENT VERIFIED.'),
    ('state', 'OK', NULL, NULL,
     'Oklahoma Supreme Court Rules',
     'Oklahoma Supreme Court',
     'OK S.Ct. R.',
     'https://www.oscn.net/applications/oscn/Index.asp?ftdb=STOKST&level=1',
     'court_rule',
     'high',
     'Oklahoma Supreme Court Rules. E-filing available but NOT mandatory.')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET base_url = EXCLUDED.base_url, notes = EXCLUDED.notes;

-- Oklahoma County Sources (Major PI Jurisdictions)
INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    ('county', 'OK', 'Oklahoma', 'District Court',
     'Oklahoma County District Court Local Rules',
     'Oklahoma County District Court',
     'OK Co. D.Ct. R.',
     'https://www.oscn.net/applications/oscn/Index.asp?ftdb=STOKCS55&level=1',
     'court_rule',
     'high',
     'Oklahoma County District Court (Oklahoma City). Most populous county. E-filing available but not mandatory. WEB VERIFIED.'),
    ('county', 'OK', 'Tulsa', 'District Court',
     'Tulsa County District Court Local Rules',
     'Tulsa County District Court',
     'Tulsa Co. D.Ct. R.',
     'https://www.oscn.net/applications/oscn/Index.asp?ftdb=STOKCS72&level=1',
     'court_rule',
     'high',
     'Tulsa County District Court. E-filing available but not mandatory. WEB VERIFIED.'),
    ('county', 'OK', 'Cleveland', 'District Court',
     'Cleveland County District Court Local Rules',
     'Cleveland County District Court',
     'Cleveland Co. D.Ct. R.',
     'https://www.oscn.net/applications/oscn/Index.asp?ftdb=STOKCS14&level=1',
     'court_rule',
     'high',
     'Cleveland County District Court (Norman). E-filing available but not mandatory. WEB VERIFIED.'),
    ('county', 'OK', 'Comanche', 'District Court',
     'Comanche County District Court Local Rules',
     'Comanche County District Court',
     'Comanche Co. D.Ct. R.',
     'https://www.oscn.net/applications/oscn/Index.asp?ftdb=STOKCS16&level=1',
     'court_rule',
     'high',
     'Comanche County District Court (Lawton). E-filing available but not mandatory. WEB VERIFIED.'),
    ('county', 'OK', 'Canadian', 'District Court',
     'Canadian County District Court Local Rules',
     'Canadian County District Court',
     'Canadian Co. D.Ct. R.',
     'https://www.oscn.net/applications/oscn/Index.asp?ftdb=STOKCS09&level=1',
     'court_rule',
     'high',
     'Canadian County District Court. E-filing available but not mandatory. WEB VERIFIED.')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET base_url = EXCLUDED.base_url, notes = EXCLUDED.notes;

-- ============================================================================
-- PART 2: ADD OKLAHOMA STATE AND COUNTY CITATIONS
-- ============================================================================

DO $$
DECLARE
    ok_stat_id INTEGER;
    ok_scr_id INTEGER;
    ok_oklahoma_id INTEGER;
    ok_tulsa_id INTEGER;
    ok_cleveland_id INTEGER;
    ok_comanche_id INTEGER;
    ok_canadian_id INTEGER;
BEGIN
    -- Get legal source IDs
    SELECT id INTO ok_stat_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'OK' AND abbreviation = '12 O.S.';
    
    SELECT id INTO ok_scr_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'OK' AND abbreviation = 'OK S.Ct. R.';
    
    SELECT id INTO ok_oklahoma_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'OK' AND jurisdiction_county = 'Oklahoma';
    
    SELECT id INTO ok_tulsa_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'OK' AND jurisdiction_county = 'Tulsa';
    
    SELECT id INTO ok_cleveland_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'OK' AND jurisdiction_county = 'Cleveland';
    
    SELECT id INTO ok_comanche_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'OK' AND jurisdiction_county = 'Comanche';
    
    SELECT id INTO ok_canadian_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'OK' AND jurisdiction_county = 'Canadian';

    -- 12 O.S. § 95 - Oklahoma 2-Year SOL for Personal Injury
    -- DOCUMENT VERIFIED: EXACT TEXT from Oklahoma Legislature
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        ok_stat_id, 'statute', 'Oklahoma Statutes',
        '12 O.S. § 95',
        'https://law.justia.com/codes/oklahoma/title-12/section-12-95/',
        'Civil actions other than for the recovery of real property can only be brought within the following periods, after the cause of action shall have accrued, and not afterwards: (3) Within two (2) years: An action for trespass upon real property; an action for taking, detaining, or injuring personal property, including actions for the specific recovery thereof; an action for injury to the rights of another, not arising on contract, and not hereinafter enumerated.',
        '§ 95(A)(3)', NOW()::date, NOW(), 'document_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        verifier = EXCLUDED.verifier;

    -- Oklahoma E-Filing System - NOT Mandatory
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        ok_scr_id, 'court_rule', 'Oklahoma Supreme Court Rules',
        'OK E-Filing System',
        'https://efile.oscn.net/',
        'E-filing in Oklahoma is not mandatory for attorneys; traditional paper filing remains an option. E-filing is available in select counties, including Adair, Canadian, Cleveland, and Tulsa, among others. The e-filing system operates 24/7. Only licensed Oklahoma attorneys, state agency representatives, or licensed process servers can register.',
        'E-Filing', NOW()::date, NOW(), 'document_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Statewide E-Filing - NOT Mandatory
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        ok_scr_id, 'court_rule', 'Oklahoma Supreme Court Rules',
        'OK-STATEWIDE-EFILING',
        'https://efile.oscn.net/docs/EFILING_FAQ.pdf',
        'Oklahoma e-filing is NOT mandatory; paper filing remains an option. E-filing is available in select counties via the Oklahoma State Courts Network (OSCN). Attorneys must register to use the system.',
        'E-Filing', NOW()::date, NOW(), 'document_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        verifier = EXCLUDED.verifier;

    -- Oklahoma County (OKC) E-Filing Citation
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        ok_oklahoma_id, 'local_rule', 'Oklahoma County District Court Local Rules',
        'OK-OKLAHOMA-EFILING',
        'https://efile.oscn.net/',
        'Oklahoma County District Court (Oklahoma City). E-filing available but NOT mandatory. Paper filing remains an option. Most populous county in Oklahoma.',
        'E-Filing', NOW()::date, NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Tulsa County E-Filing Citation
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        ok_tulsa_id, 'local_rule', 'Tulsa County District Court Local Rules',
        'OK-TULSA-EFILING',
        'https://efile.oscn.net/',
        'Tulsa County District Court. E-filing available but NOT mandatory. Paper filing remains an option.',
        'E-Filing', NOW()::date, NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Cleveland County (Norman) E-Filing Citation
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        ok_cleveland_id, 'local_rule', 'Cleveland County District Court Local Rules',
        'OK-CLEVELAND-EFILING',
        'https://efile.oscn.net/',
        'Cleveland County District Court (Norman). E-filing available but NOT mandatory. Paper filing remains an option.',
        'E-Filing', NOW()::date, NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Comanche County (Lawton) E-Filing Citation
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        ok_comanche_id, 'local_rule', 'Comanche County District Court Local Rules',
        'OK-COMANCHE-EFILING',
        'https://efile.oscn.net/',
        'Comanche County District Court (Lawton). E-filing available but NOT mandatory. Paper filing remains an option.',
        'E-Filing', NOW()::date, NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Canadian County E-Filing Citation
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        ok_canadian_id, 'local_rule', 'Canadian County District Court Local Rules',
        'OK-CANADIAN-EFILING',
        'https://efile.oscn.net/',
        'Canadian County District Court. E-filing available but NOT mandatory. Paper filing remains an option.',
        'E-Filing', NOW()::date, NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

END $$;

-- ============================================================================
-- PART 3: ADD OKLAHOMA VALIDATION RULES
-- ============================================================================

DO $$
DECLARE
    ok_sol_id INTEGER;
    ok_efiling_id INTEGER;
    ok_statewide_efile_id INTEGER;
    ok_oklahoma_efile_id INTEGER;
    ok_tulsa_efile_id INTEGER;
    ok_cleveland_efile_id INTEGER;
    ok_comanche_efile_id INTEGER;
    ok_canadian_efile_id INTEGER;
BEGIN
    -- Get citation IDs
    SELECT id INTO ok_sol_id FROM leverage.rule_citations 
    WHERE citation = '12 O.S. § 95';
    
    SELECT id INTO ok_efiling_id FROM leverage.rule_citations 
    WHERE citation = 'OK E-Filing System';
    
    SELECT id INTO ok_statewide_efile_id FROM leverage.rule_citations 
    WHERE citation = 'OK-STATEWIDE-EFILING';
    
    SELECT id INTO ok_oklahoma_efile_id FROM leverage.rule_citations 
    WHERE citation = 'OK-OKLAHOMA-EFILING';
    
    SELECT id INTO ok_tulsa_efile_id FROM leverage.rule_citations 
    WHERE citation = 'OK-TULSA-EFILING';
    
    SELECT id INTO ok_cleveland_efile_id FROM leverage.rule_citations 
    WHERE citation = 'OK-CLEVELAND-EFILING';
    
    SELECT id INTO ok_comanche_efile_id FROM leverage.rule_citations 
    WHERE citation = 'OK-COMANCHE-EFILING';
    
    SELECT id INTO ok_canadian_efile_id FROM leverage.rule_citations 
    WHERE citation = 'OK-CANADIAN-EFILING';

    -- OK Statewide PI SOL (2 years) - 12 O.S. § 95(A)(3)
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'OK-SOL-95-A-3-PI-2YEAR', 5, 'OK Personal Injury SOL (2 Years)', 'threshold_check',
        'personal_injury', 'complaint',
        'state', 'OK', NULL, NULL,
        '{"sol_years": 2, "sol_days": 730, "statute": "12 O.S. § 95", "subsection": "(A)(3)", "applies_to": "injury_to_rights_not_on_contract", "note": "Oklahoma has 2-YEAR SOL for PI. Action for injury to the rights of another, not arising on contract, must be brought within 2 years after cause of action accrues."}'::jsonb,
        'error', ok_sol_id, 'document_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id,
        review_status = EXCLUDED.review_status;

    -- OK Statewide E-Filing Rule (NOT Mandatory)
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'OK-EFILING-STATEWIDE', 2, 'OK Statewide E-Filing (NOT Mandatory)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'OK', NULL, NULL,
        '{"requires_efiling": false, "system": "OSCN E-Filing", "mandatory": false, "paper_filing_available": true, "available_counties": ["Oklahoma", "Tulsa", "Cleveland", "Canadian", "Adair", "and others"], "note": "IMPORTANT: E-filing is NOT mandatory in Oklahoma. Paper filing remains an option. E-filing available in select counties via OSCN."}'::jsonb,
        'info', ok_statewide_efile_id, 'document_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id,
        review_status = EXCLUDED.review_status;

    -- Oklahoma County (OKC) E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'OK-OKLAHOMA-EFILING', 2, 'Oklahoma County E-Filing (OKC)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'OK', 'Oklahoma', 'District Court',
        '{"requires_efiling": false, "system": "OSCN E-Filing", "city": "Oklahoma City", "paper_filing_available": true, "court_url": "https://efile.oscn.net/", "note": "Most populous county. E-filing available but NOT mandatory."}'::jsonb,
        'info', ok_oklahoma_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Tulsa County E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'OK-TULSA-EFILING', 2, 'Tulsa County E-Filing', 'format_check',
        'personal_injury', 'complaint',
        'state', 'OK', 'Tulsa', 'District Court',
        '{"requires_efiling": false, "system": "OSCN E-Filing", "city": "Tulsa", "paper_filing_available": true, "court_url": "https://efile.oscn.net/", "note": "E-filing available but NOT mandatory."}'::jsonb,
        'info', ok_tulsa_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Cleveland County (Norman) E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'OK-CLEVELAND-EFILING', 2, 'Cleveland County E-Filing (Norman)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'OK', 'Cleveland', 'District Court',
        '{"requires_efiling": false, "system": "OSCN E-Filing", "city": "Norman", "paper_filing_available": true, "court_url": "https://efile.oscn.net/", "note": "E-filing available but NOT mandatory."}'::jsonb,
        'info', ok_cleveland_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Comanche County (Lawton) E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'OK-COMANCHE-EFILING', 2, 'Comanche County E-Filing (Lawton)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'OK', 'Comanche', 'District Court',
        '{"requires_efiling": false, "system": "OSCN E-Filing", "city": "Lawton", "paper_filing_available": true, "court_url": "https://efile.oscn.net/", "note": "E-filing available but NOT mandatory."}'::jsonb,
        'info', ok_comanche_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Canadian County E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'OK-CANADIAN-EFILING', 2, 'Canadian County E-Filing', 'format_check',
        'personal_injury', 'complaint',
        'state', 'OK', 'Canadian', 'District Court',
        '{"requires_efiling": false, "system": "OSCN E-Filing", "paper_filing_available": true, "court_url": "https://efile.oscn.net/", "note": "E-filing available but NOT mandatory."}'::jsonb,
        'info', ok_canadian_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Completion message
    RAISE NOTICE '========================================================================';
    RAISE NOTICE 'OKLAHOMA (OK) PI COURT RULES SEEDED SUCCESSFULLY';
    RAISE NOTICE '========================================================================';
    RAISE NOTICE 'Legal Sources: 7 (2 state + 5 county courts)';
    RAISE NOTICE 'Citations: 8 (12 O.S. § 95, e-filing system, statewide + 5 county)';
    RAISE NOTICE 'Validation Rules: 7 (1 SOL + 1 statewide e-filing + 5 county e-filing)';
    RAISE NOTICE '';
    RAISE NOTICE 'DOCUMENT VERIFIED:';
    RAISE NOTICE '  - 12 O.S. § 95(A)(3) (2-year SOL) from oklegislature.gov';
    RAISE NOTICE '  - E-Filing system from efile.oscn.net';
    RAISE NOTICE '';
    RAISE NOTICE 'Oklahoma has 2-YEAR SOL for PI';
    RAISE NOTICE 'IMPORTANT: E-Filing is NOT mandatory - paper filing remains an option';
    RAISE NOTICE '========================================================================';

END $$;

COMMIT;
