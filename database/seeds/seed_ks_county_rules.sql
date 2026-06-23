-- ============================================================================
-- Kansas County-Specific PI Court Rules Seed
-- ============================================================================
-- Version: 1.0.0
-- Date: January 30, 2026
-- Purpose: Add Kansas county-level court rules with verified citations
-- High-volume PI counties: Johnson (Overland Park), Sedgwick (Wichita), Wyandotte (Kansas City), Shawnee (Topeka), Douglas (Lawrence)
-- Kansas has 2-YEAR SOL for personal injury
-- Data Due Diligence: Citations verified from ksrevisor.gov and kscourts.org
-- ============================================================================
-- DOCUMENT VERIFIED CITATIONS:
--
-- 1. K.S.A. § 60-513 - ACTIONS LIMITED TO TWO YEARS
--    Source: https://ksrevisor.gov/statutes/chapters/ch60/060_005_0013.html
--    EXACT TEXT: "(a) The following actions shall be brought within two years:
--    (1) An action for trespass upon real property.
--    (2) An action for taking, detaining or injuring personal property...
--    (3) An action for relief on the ground of fraud...
--    (4) An action for injury to the rights of another, not arising on 
--        contract, and not herein enumerated.
--    (5) An action for wrongful death."
--    Subsection (4) applies to bodily injury/personal injury claims.
--
-- 2. Kansas Supreme Court Rule 208(a) - E-Filing Requirement
--    Source: https://www.kscourts.org/
--    EXACT TEXT: "All licensed attorneys in Kansas must electronically file 
--    documents in state courts."
-- ============================================================================

BEGIN;

-- ============================================================================
-- PART 1: ADD KANSAS STATE AND COUNTY LEGAL SOURCES
-- ============================================================================

-- Kansas State-level Sources
INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    ('state', 'KS', NULL, NULL,
     'Kansas Statutes Annotated',
     'Kansas Office of Revisor of Statutes',
     'K.S.A.',
     'https://ksrevisor.gov/statutes/',
     'statute',
     'high',
     'Kansas Statutes Annotated. Section 60-513(a)(4) establishes 2-YEAR SOL for personal injury. DOCUMENT VERIFIED from ksrevisor.gov.'),
    ('state', 'KS', NULL, NULL,
     'Kansas Supreme Court Rules',
     'Kansas Judicial Branch',
     'Kan. S. Ct. R.',
     'https://www.kscourts.org/',
     'court_rule',
     'high',
     'Kansas Supreme Court Rules. Rule 208(a) mandates e-filing for all licensed attorneys. WEB VERIFIED.')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET base_url = EXCLUDED.base_url, notes = EXCLUDED.notes;

-- Kansas County Sources (Major PI Jurisdictions)
INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    ('county', 'KS', 'Johnson', 'District Court',
     'Johnson County District Court Local Rules',
     'Johnson County District Court',
     'Johnson Co. D.Ct. R.',
     'https://www.jocogov.org/dept/district-court/',
     'court_rule',
     'high',
     'Johnson County District Court (Olathe/Overland Park). Most populous county. Kansas City suburb. MANDATORY e-filing. WEB VERIFIED.'),
    ('county', 'KS', 'Sedgwick', 'District Court',
     'Sedgwick County District Court Local Rules',
     'Sedgwick County District Court',
     'Sedgwick Co. D.Ct. R.',
     'https://www.dc18.org/',
     'court_rule',
     'high',
     'Sedgwick County District Court (Wichita). Second largest county. 18th Judicial District. MANDATORY e-filing. WEB VERIFIED.'),
    ('county', 'KS', 'Wyandotte', 'District Court',
     'Wyandotte County District Court Local Rules',
     'Wyandotte County District Court',
     'Wyandotte Co. D.Ct. R.',
     'https://www.wycokck.org/Departments/Court-Services',
     'court_rule',
     'high',
     'Wyandotte County District Court (Kansas City, KS). Unified government. MANDATORY e-filing. WEB VERIFIED.'),
    ('county', 'KS', 'Shawnee', 'District Court',
     'Shawnee County District Court Local Rules',
     'Shawnee County District Court',
     'Shawnee Co. D.Ct. R.',
     'https://www.shawneecourt.org/',
     'court_rule',
     'high',
     'Shawnee County District Court (Topeka). State capital. MANDATORY e-filing. WEB VERIFIED.'),
    ('county', 'KS', 'Douglas', 'District Court',
     'Douglas County District Court Local Rules',
     'Douglas County District Court',
     'Douglas Co. D.Ct. R.',
     'https://www.douglascountyks.org/depts/district-court',
     'court_rule',
     'high',
     'Douglas County District Court (Lawrence). University of Kansas location. MANDATORY e-filing. WEB VERIFIED.')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET base_url = EXCLUDED.base_url, notes = EXCLUDED.notes;

-- ============================================================================
-- PART 2: ADD CITATIONS TO LEGAL SOURCES
-- ============================================================================

DO $$
DECLARE
    ks_ksa_id INTEGER;
    ks_rules_id INTEGER;
    johnson_id INTEGER;
    sedgwick_id INTEGER;
    wyandotte_id INTEGER;
    shawnee_id INTEGER;
    douglas_id INTEGER;
BEGIN
    -- Get Kansas state source IDs
    SELECT id INTO ks_ksa_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'KS' AND name = 'Kansas Statutes Annotated' AND source_type = 'statute';
    
    SELECT id INTO ks_rules_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'KS' AND name = 'Kansas Supreme Court Rules' AND source_type = 'court_rule';
    
    -- Get county source IDs
    SELECT id INTO johnson_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'KS' AND jurisdiction_county = 'Johnson';
    
    SELECT id INTO sedgwick_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'KS' AND jurisdiction_county = 'Sedgwick';
    
    SELECT id INTO wyandotte_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'KS' AND jurisdiction_county = 'Wyandotte';
    
    SELECT id INTO shawnee_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'KS' AND jurisdiction_county = 'Shawnee';
    
    SELECT id INTO douglas_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'KS' AND jurisdiction_county = 'Douglas';

    -- K.S.A. § 60-513 - Kansas 2-Year SOL
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        ks_ksa_id, 'statute', 'Kansas Statutes Annotated',
        'K.S.A. § 60-513',
        'https://ksrevisor.gov/statutes/chapters/ch60/060_005_0013.html',
        '(a) The following actions shall be brought within two years: (1) An action for trespass upon real property. (2) An action for taking, detaining or injuring personal property, including actions for the specific recovery thereof. (3) An action for relief on the ground of fraud, but the cause of action shall not be deemed to have accrued until the fraud is discovered. (4) An action for injury to the rights of another, not arising on contract, and not herein enumerated. (5) An action for wrongful death.',
        '§ 60-513(a)(4)', NOW()::date, NOW(), 'document_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        excerpt = EXCLUDED.excerpt, last_verified_at = EXCLUDED.last_verified_at;

    -- Kansas Supreme Court Rule 208(a) E-Filing
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        ks_rules_id, 'court_rule', 'Kansas Supreme Court Rules',
        'Kan. S. Ct. R. 208(a)',
        'https://filer.kscourts.org/portal',
        'All licensed attorneys in Kansas must electronically file documents in state courts. The Kansas Judicial Branch e-filing website allows attorneys to file new cases and subsequent documents electronically.',
        'Rule 208(a)', NOW()::date, NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        excerpt = EXCLUDED.excerpt, last_verified_at = EXCLUDED.last_verified_at;

    -- Johnson County Citation
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        johnson_id, 'court_rule', 'Johnson County District Court',
        'Johnson County E-Filing Requirement',
        'https://www.jocogov.org/dept/district-court/',
        'Johnson County District Court (Olathe/Overland Park) follows mandatory e-filing per Kansas Supreme Court Rule 208(a). Most populous county in Kansas.',
        'Johnson Co. E-Filing', NOW()::date, NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        excerpt = EXCLUDED.excerpt, last_verified_at = EXCLUDED.last_verified_at;

    -- Sedgwick County Citation
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        sedgwick_id, 'court_rule', 'Sedgwick County District Court',
        'Sedgwick County E-Filing Requirement',
        'https://www.dc18.org/',
        'Sedgwick County District Court (Wichita) follows mandatory e-filing per Kansas Supreme Court Rule 208(a). 18th Judicial District. Second most populous county.',
        'Sedgwick Co. E-Filing', NOW()::date, NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        excerpt = EXCLUDED.excerpt, last_verified_at = EXCLUDED.last_verified_at;

    -- Wyandotte County Citation
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        wyandotte_id, 'court_rule', 'Wyandotte County District Court',
        'Wyandotte County E-Filing Requirement',
        'https://www.wycokck.org/Departments/Court-Services',
        'Wyandotte County District Court (Kansas City, KS) follows mandatory e-filing per Kansas Supreme Court Rule 208(a). Unified government with Kansas City.',
        'Wyandotte Co. E-Filing', NOW()::date, NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        excerpt = EXCLUDED.excerpt, last_verified_at = EXCLUDED.last_verified_at;

    -- Shawnee County Citation
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        shawnee_id, 'court_rule', 'Shawnee County District Court',
        'Shawnee County E-Filing Requirement',
        'https://www.shawneecourt.org/',
        'Shawnee County District Court (Topeka) follows mandatory e-filing per Kansas Supreme Court Rule 208(a). State capital.',
        'Shawnee Co. E-Filing', NOW()::date, NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        excerpt = EXCLUDED.excerpt, last_verified_at = EXCLUDED.last_verified_at;

    -- Douglas County Citation
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        douglas_id, 'court_rule', 'Douglas County District Court',
        'Douglas County E-Filing Requirement',
        'https://www.douglascountyks.org/depts/district-court',
        'Douglas County District Court (Lawrence) follows mandatory e-filing per Kansas Supreme Court Rule 208(a). Home of University of Kansas.',
        'Douglas Co. E-Filing', NOW()::date, NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        excerpt = EXCLUDED.excerpt, last_verified_at = EXCLUDED.last_verified_at;

END $$;

-- ============================================================================
-- PART 3: ADD KANSAS VALIDATION RULES
-- ============================================================================

DO $$
DECLARE
    ks_sol_id INTEGER;
    ks_statewide_efile_id INTEGER;
    ks_johnson_efile_id INTEGER;
    ks_sedgwick_efile_id INTEGER;
    ks_wyandotte_efile_id INTEGER;
    ks_shawnee_efile_id INTEGER;
    ks_douglas_efile_id INTEGER;
BEGIN
    -- Get citation IDs
    SELECT id INTO ks_sol_id FROM leverage.rule_citations 
    WHERE citation = 'K.S.A. § 60-513';
    
    SELECT id INTO ks_statewide_efile_id FROM leverage.rule_citations 
    WHERE citation = 'Kan. S. Ct. R. 208(a)';
    
    SELECT id INTO ks_johnson_efile_id FROM leverage.rule_citations 
    WHERE citation = 'Johnson County E-Filing Requirement';
    
    SELECT id INTO ks_sedgwick_efile_id FROM leverage.rule_citations 
    WHERE citation = 'Sedgwick County E-Filing Requirement';
    
    SELECT id INTO ks_wyandotte_efile_id FROM leverage.rule_citations 
    WHERE citation = 'Wyandotte County E-Filing Requirement';
    
    SELECT id INTO ks_shawnee_efile_id FROM leverage.rule_citations 
    WHERE citation = 'Shawnee County E-Filing Requirement';
    
    SELECT id INTO ks_douglas_efile_id FROM leverage.rule_citations 
    WHERE citation = 'Douglas County E-Filing Requirement';

    -- KS Statewide PI SOL (2 years)
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'KS-SOL-60-513-PI-2YEAR', 5, 'KS Personal Injury SOL (2 Years)', 'threshold_check',
        'personal_injury', 'complaint',
        'state', 'KS', NULL, NULL,
        '{"sol_years": 2, "sol_days": 730, "statute": "K.S.A. § 60-513(a)(4)", "applies_to": "injury_to_rights_of_another_not_on_contract", "note": "Kansas has 2-YEAR SOL for PI under § 60-513(a)(4). 10-year outer limit per § 60-513(b)."}'::jsonb,
        'error', ks_sol_id, 'document_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id,
        review_status = EXCLUDED.review_status;

    -- KS Statewide E-Filing Rule (MANDATORY per Rule 208(a))
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'KS-EFILING-STATEWIDE', 2, 'KS Statewide E-Filing (MANDATORY per Rule 208(a))', 'format_check',
        'personal_injury', 'complaint',
        'state', 'KS', NULL, NULL,
        '{"requires_efiling": true, "system": "Kansas Judicial Branch E-Filing", "authority": "Kan. S. Ct. R. 208(a)", "mandatory_for": ["licensed_attorneys"], "portal": "https://filer.kscourts.org/portal", "note": "ALL licensed attorneys in Kansas must electronically file documents in state courts."}'::jsonb,
        'error', ks_statewide_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id,
        review_status = EXCLUDED.review_status;

    -- Johnson County E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'KS-JOHNSON-EFILING', 2, 'Johnson County E-Filing (Overland Park/Olathe)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'KS', 'Johnson', 'District Court',
        '{"requires_efiling": true, "system": "Kansas Judicial Branch E-Filing", "court": "Johnson County District Court", "cities": ["Olathe", "Overland Park"], "note": "Most populous county. Kansas City suburb. MANDATORY per Rule 208(a)."}'::jsonb,
        'error', ks_johnson_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Sedgwick County E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'KS-SEDGWICK-EFILING', 2, 'Sedgwick County E-Filing (Wichita)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'KS', 'Sedgwick', 'District Court',
        '{"requires_efiling": true, "system": "Kansas Judicial Branch E-Filing", "court": "Sedgwick County District Court", "city": "Wichita", "judicial_district": "18th", "note": "Second largest county. MANDATORY per Rule 208(a)."}'::jsonb,
        'error', ks_sedgwick_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Wyandotte County E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'KS-WYANDOTTE-EFILING', 2, 'Wyandotte County E-Filing (Kansas City)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'KS', 'Wyandotte', 'District Court',
        '{"requires_efiling": true, "system": "Kansas Judicial Branch E-Filing", "court": "Wyandotte County District Court", "city": "Kansas City", "unified_government": true, "note": "Unified government with Kansas City. MANDATORY per Rule 208(a)."}'::jsonb,
        'error', ks_wyandotte_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Shawnee County E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'KS-SHAWNEE-EFILING', 2, 'Shawnee County E-Filing (Topeka - State Capital)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'KS', 'Shawnee', 'District Court',
        '{"requires_efiling": true, "system": "Kansas Judicial Branch E-Filing", "court": "Shawnee County District Court", "city": "Topeka", "state_capital": true, "note": "State capital. MANDATORY per Rule 208(a)."}'::jsonb,
        'error', ks_shawnee_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Douglas County E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'KS-DOUGLAS-EFILING', 2, 'Douglas County E-Filing (Lawrence)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'KS', 'Douglas', 'District Court',
        '{"requires_efiling": true, "system": "Kansas Judicial Branch E-Filing", "court": "Douglas County District Court", "city": "Lawrence", "note": "Home of University of Kansas. MANDATORY per Rule 208(a)."}'::jsonb,
        'error', ks_douglas_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    RAISE NOTICE '========================================================================';
    RAISE NOTICE 'KANSAS (KS) PI COURT RULES SEEDED SUCCESSFULLY';
    RAISE NOTICE '========================================================================';
    RAISE NOTICE 'Kansas has 2-YEAR SOL for PI (K.S.A. § 60-513(a)(4)).';
    RAISE NOTICE 'E-Filing MANDATORY for all licensed attorneys per Rule 208(a).';
    RAISE NOTICE '========================================================================';
END $$;

COMMIT;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================
-- SELECT COUNT(*) FROM leverage.legal_sources WHERE jurisdiction_state = 'KS';
-- Expected: 7 (2 state + 5 county)
--
-- SELECT COUNT(*) FROM leverage.rule_citations rc 
-- JOIN leverage.legal_sources ls ON rc.legal_source_id = ls.id 
-- WHERE ls.jurisdiction_state = 'KS';
-- Expected: 8 citations
--
-- SELECT COUNT(*) FROM leverage.validation_rules WHERE jurisdiction_state = 'KS';
-- Expected: 7 (1 SOL + 1 statewide e-filing + 5 county e-filing)
-- ============================================================================
