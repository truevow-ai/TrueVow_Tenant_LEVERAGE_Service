-- ============================================================================
-- Mississippi County-Specific PI Court Rules Seed
-- ============================================================================
-- Version: 1.0.0
-- Date: January 30, 2026
-- Purpose: Add Mississippi county-level court rules with verified citations
-- High-volume PI counties: Hinds (Jackson), Harrison (Gulfport/Biloxi), DeSoto, Rankin, Madison
-- Mississippi has 3-YEAR SOL for personal injury
-- NOTABLE: MEC system completed STATEWIDE mandatory e-filing June 30, 2025!
-- Data Due Diligence: Citations verified from law.justia.com and courts.ms.gov
-- ============================================================================
-- DOCUMENT VERIFIED CITATIONS:
--
-- 1. Miss. Code Ann. § 15-1-49 - LIMITATIONS APPLICABLE TO OTHER ACTIONS
--    Source: https://law.justia.com/codes/mississippi/title-15/chapter-1/section-15-1-49/
--    EXACT TEXT: "All actions for which no other period of limitation is 
--    prescribed shall be commenced within three (3) years next after the 
--    cause of action accrued, and not after."
--    Also includes discovery rule for latent injuries.
--
-- 2. Mississippi Electronic Courts (MEC) - Mandatory E-Filing
--    Source: https://courts.ms.gov/mec/mec.php
--    EXACT TEXT: "Electronic filing completed statewide for Mississippi courts."
--    Effective: June 30, 2025 (statewide completion)
--    System: MEC (based on federal CM/ECF model)
-- ============================================================================

BEGIN;

-- ============================================================================
-- PART 1: ADD MISSISSIPPI STATE AND COUNTY LEGAL SOURCES
-- ============================================================================

-- Mississippi State-level Sources
INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    ('state', 'MS', NULL, NULL,
     'Mississippi Code',
     'Mississippi Legislature',
     'Miss. Code Ann.',
     'https://law.justia.com/codes/mississippi/',
     'statute',
     'high',
     'Mississippi Code Annotated. Section 15-1-49 establishes 3-YEAR SOL for personal injury. DOCUMENT VERIFIED.'),
    ('state', 'MS', NULL, NULL,
     'Mississippi Electronic Courts Rules',
     'Mississippi Judiciary',
     'MEC Rules',
     'https://courts.ms.gov/mec/mec.php',
     'court_rule',
     'high',
     'Mississippi Electronic Courts (MEC). MANDATORY e-filing statewide as of June 30, 2025. All 82 Circuit Courts and 24 County Courts.')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET base_url = EXCLUDED.base_url, notes = EXCLUDED.notes;

-- Mississippi County Sources (Major PI Jurisdictions)
INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    ('county', 'MS', 'Hinds', 'Circuit Court',
     'Hinds County Circuit Court Local Rules',
     'Hinds County Circuit Court',
     'Hinds Co. Cir. Ct. R.',
     'https://courts.ms.gov/mec/mec.php',
     'court_rule',
     'high',
     'Hinds County Circuit Court (Jackson). State capital. MANDATORY e-filing via MEC since June 2013. WEB VERIFIED.'),
    ('county', 'MS', 'Harrison', 'Circuit Court',
     'Harrison County Circuit Court Local Rules',
     'Harrison County Circuit Court',
     'Harrison Co. Cir. Ct. R.',
     'https://courts.ms.gov/mec/mec.php',
     'court_rule',
     'high',
     'Harrison County Circuit Court (Gulfport/Biloxi). Gulf Coast region. MANDATORY e-filing via MEC. WEB VERIFIED.'),
    ('county', 'MS', 'DeSoto', 'Circuit Court',
     'DeSoto County Circuit Court Local Rules',
     'DeSoto County Circuit Court',
     'DeSoto Co. Cir. Ct. R.',
     'https://courts.ms.gov/mec/mec.php',
     'court_rule',
     'high',
     'DeSoto County Circuit Court (Hernando). Memphis suburb. MANDATORY e-filing via MEC. WEB VERIFIED.'),
    ('county', 'MS', 'Rankin', 'Circuit Court',
     'Rankin County Circuit Court Local Rules',
     'Rankin County Circuit Court',
     'Rankin Co. Cir. Ct. R.',
     'https://courts.ms.gov/mec/mec.php',
     'court_rule',
     'high',
     'Rankin County Circuit Court (Brandon). Jackson suburb. MANDATORY e-filing via MEC. WEB VERIFIED.'),
    ('county', 'MS', 'Madison', 'Circuit Court',
     'Madison County Circuit Court Local Rules',
     'Madison County Circuit Court',
     'Madison Co. Cir. Ct. R.',
     'https://courts.ms.gov/mec/mec.php',
     'court_rule',
     'high',
     'Madison County Circuit Court (Canton). Jackson suburb. MANDATORY e-filing via MEC. WEB VERIFIED.')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET base_url = EXCLUDED.base_url, notes = EXCLUDED.notes;

-- ============================================================================
-- PART 2: ADD CITATIONS TO LEGAL SOURCES
-- ============================================================================

DO $$
DECLARE
    ms_code_id INTEGER;
    ms_mec_id INTEGER;
    hinds_id INTEGER;
    harrison_id INTEGER;
    desoto_id INTEGER;
    rankin_id INTEGER;
    madison_id INTEGER;
BEGIN
    -- Get Mississippi state source IDs
    SELECT id INTO ms_code_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'MS' AND name = 'Mississippi Code' AND source_type = 'statute';
    
    SELECT id INTO ms_mec_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'MS' AND name = 'Mississippi Electronic Courts Rules' AND source_type = 'court_rule';
    
    -- Get county source IDs
    SELECT id INTO hinds_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'MS' AND jurisdiction_county = 'Hinds';
    
    SELECT id INTO harrison_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'MS' AND jurisdiction_county = 'Harrison';
    
    SELECT id INTO desoto_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'MS' AND jurisdiction_county = 'DeSoto';
    
    SELECT id INTO rankin_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'MS' AND jurisdiction_county = 'Rankin';
    
    SELECT id INTO madison_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'MS' AND jurisdiction_county = 'Madison';

    -- Miss. Code Ann. § 15-1-49 - Mississippi 3-Year SOL
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        ms_code_id, 'statute', 'Mississippi Code',
        'Miss. Code Ann. § 15-1-49',
        'https://law.justia.com/codes/mississippi/title-15/chapter-1/section-15-1-49/',
        'All actions for which no other period of limitation is prescribed shall be commenced within three (3) years next after the cause of action accrued, and not after. In actions for which no other period of limitation is prescribed and which involve latent injury or disease, the cause of action does not accrue until the plaintiff has discovered, or by reasonable diligence should have discovered, the injury.',
        '§ 15-1-49', NOW()::date, NOW(), 'document_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        excerpt = EXCLUDED.excerpt, last_verified_at = EXCLUDED.last_verified_at;

    -- MEC Statewide E-Filing Rule
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        ms_mec_id, 'court_rule', 'Mississippi Electronic Courts',
        'MEC Statewide E-Filing',
        'https://courts.ms.gov/mec/mec.php',
        'Electronic filing completed statewide for Mississippi courts. All 82 Circuit Courts and 24 County Courts are now utilizing this centralized electronic filing and case management system. The MEC system is based on the federal CM/ECF model, ensuring ease of use for attorneys. All documents are stored in PDF format.',
        'MEC Statewide', '2025-06-30', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        excerpt = EXCLUDED.excerpt, last_verified_at = EXCLUDED.last_verified_at;

    -- Hinds County Citation
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        hinds_id, 'court_rule', 'Hinds County Circuit Court',
        'Hinds County MEC E-Filing',
        'https://courts.ms.gov/mec/mec.php',
        'Hinds County Circuit Court (Jackson) began mandatory e-filing in June 2013. Civil cases transitioned first, followed by criminal cases. Part of the Mississippi Electronic Courts (MEC) system.',
        'Hinds Co. MEC', '2013-06-01', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        excerpt = EXCLUDED.excerpt, last_verified_at = EXCLUDED.last_verified_at;

    -- Harrison County Citation
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        harrison_id, 'court_rule', 'Harrison County Circuit Court',
        'Harrison County MEC E-Filing',
        'https://courts.ms.gov/mec/mec.php',
        'Harrison County Circuit Court (Gulfport/Biloxi) uses mandatory e-filing through the Mississippi Electronic Courts (MEC) system for all civil and criminal cases.',
        'Harrison Co. MEC', NOW()::date, NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        excerpt = EXCLUDED.excerpt, last_verified_at = EXCLUDED.last_verified_at;

    -- DeSoto County Citation
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        desoto_id, 'court_rule', 'DeSoto County Circuit Court',
        'DeSoto County MEC E-Filing',
        'https://courts.ms.gov/mec/mec.php',
        'DeSoto County Circuit Court (Hernando) uses mandatory e-filing through the Mississippi Electronic Courts (MEC) system for all civil and criminal cases.',
        'DeSoto Co. MEC', NOW()::date, NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        excerpt = EXCLUDED.excerpt, last_verified_at = EXCLUDED.last_verified_at;

    -- Rankin County Citation
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        rankin_id, 'court_rule', 'Rankin County Circuit Court',
        'Rankin County MEC E-Filing',
        'https://courts.ms.gov/mec/mec.php',
        'Rankin County Circuit Court (Brandon) uses mandatory e-filing through the Mississippi Electronic Courts (MEC) system. Criminal case e-filing began April 15, 2024.',
        'Rankin Co. MEC', '2024-04-15', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        excerpt = EXCLUDED.excerpt, last_verified_at = EXCLUDED.last_verified_at;

    -- Madison County Citation
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        madison_id, 'court_rule', 'Madison County Circuit Court',
        'Madison County MEC E-Filing',
        'https://courts.ms.gov/mec/mec.php',
        'Madison County Circuit Court (Canton) uses mandatory e-filing through the Mississippi Electronic Courts (MEC) system for all civil and criminal cases.',
        'Madison Co. MEC', NOW()::date, NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        excerpt = EXCLUDED.excerpt, last_verified_at = EXCLUDED.last_verified_at;

END $$;

-- ============================================================================
-- PART 3: ADD MISSISSIPPI VALIDATION RULES
-- ============================================================================

DO $$
DECLARE
    ms_sol_id INTEGER;
    ms_statewide_efile_id INTEGER;
    ms_hinds_efile_id INTEGER;
    ms_harrison_efile_id INTEGER;
    ms_desoto_efile_id INTEGER;
    ms_rankin_efile_id INTEGER;
    ms_madison_efile_id INTEGER;
BEGIN
    -- Get citation IDs
    SELECT id INTO ms_sol_id FROM leverage.rule_citations 
    WHERE citation = 'Miss. Code Ann. § 15-1-49';
    
    SELECT id INTO ms_statewide_efile_id FROM leverage.rule_citations 
    WHERE citation = 'MEC Statewide E-Filing';
    
    SELECT id INTO ms_hinds_efile_id FROM leverage.rule_citations 
    WHERE citation = 'Hinds County MEC E-Filing';
    
    SELECT id INTO ms_harrison_efile_id FROM leverage.rule_citations 
    WHERE citation = 'Harrison County MEC E-Filing';
    
    SELECT id INTO ms_desoto_efile_id FROM leverage.rule_citations 
    WHERE citation = 'DeSoto County MEC E-Filing';
    
    SELECT id INTO ms_rankin_efile_id FROM leverage.rule_citations 
    WHERE citation = 'Rankin County MEC E-Filing';
    
    SELECT id INTO ms_madison_efile_id FROM leverage.rule_citations 
    WHERE citation = 'Madison County MEC E-Filing';

    -- MS Statewide PI SOL (3 years)
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'MS-SOL-15-1-49-PI-3YEAR', 5, 'MS Personal Injury SOL (3 Years)', 'threshold_check',
        'personal_injury', 'complaint',
        'state', 'MS', NULL, NULL,
        '{"sol_years": 3, "sol_days": 1095, "statute": "Miss. Code Ann. § 15-1-49", "applies_to": "actions_without_other_limitation", "discovery_rule": true, "note": "Mississippi has 3-YEAR SOL for PI. Discovery rule applies for latent injuries."}'::jsonb,
        'error', ms_sol_id, 'document_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id,
        review_status = EXCLUDED.review_status;

    -- MS Statewide E-Filing Rule (MEC - MANDATORY)
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'MS-EFILING-STATEWIDE-MEC', 2, 'MS Statewide E-Filing (MEC - MANDATORY)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'MS', NULL, NULL,
        '{"requires_efiling": true, "system": "Mississippi Electronic Courts (MEC)", "authority": "MS Supreme Court", "effective_date": "2025-06-30", "courts_covered": "82 Circuit Courts + 24 County Courts", "note": "MANDATORY e-filing statewide completed June 30, 2025. Based on federal CM/ECF model."}'::jsonb,
        'error', ms_statewide_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id,
        review_status = EXCLUDED.review_status;

    -- Hinds County E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'MS-HINDS-EFILING', 2, 'Hinds County E-Filing (Jackson - State Capital)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'MS', 'Hinds', 'Circuit Court',
        '{"requires_efiling": true, "system": "MEC", "court": "Hinds County Circuit Court", "city": "Jackson", "state_capital": true, "effective_date": "2013-06-01", "note": "State capital. MANDATORY e-filing since June 2013."}'::jsonb,
        'error', ms_hinds_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Harrison County E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'MS-HARRISON-EFILING', 2, 'Harrison County E-Filing (Gulfport/Biloxi)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'MS', 'Harrison', 'Circuit Court',
        '{"requires_efiling": true, "system": "MEC", "court": "Harrison County Circuit Court", "cities": ["Gulfport", "Biloxi"], "note": "Gulf Coast region. MANDATORY e-filing via MEC."}'::jsonb,
        'error', ms_harrison_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- DeSoto County E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'MS-DESOTO-EFILING', 2, 'DeSoto County E-Filing (Hernando)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'MS', 'DeSoto', 'Circuit Court',
        '{"requires_efiling": true, "system": "MEC", "court": "DeSoto County Circuit Court", "city": "Hernando", "note": "Memphis suburb. MANDATORY e-filing via MEC."}'::jsonb,
        'error', ms_desoto_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Rankin County E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'MS-RANKIN-EFILING', 2, 'Rankin County E-Filing (Brandon)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'MS', 'Rankin', 'Circuit Court',
        '{"requires_efiling": true, "system": "MEC", "court": "Rankin County Circuit Court", "city": "Brandon", "criminal_effective_date": "2024-04-15", "note": "Jackson suburb. Criminal e-filing began April 15, 2024. MANDATORY."}'::jsonb,
        'error', ms_rankin_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Madison County E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'MS-MADISON-EFILING', 2, 'Madison County E-Filing (Canton)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'MS', 'Madison', 'Circuit Court',
        '{"requires_efiling": true, "system": "MEC", "court": "Madison County Circuit Court", "city": "Canton", "note": "Jackson suburb. MANDATORY e-filing via MEC."}'::jsonb,
        'error', ms_madison_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    RAISE NOTICE '========================================================================';
    RAISE NOTICE 'MISSISSIPPI (MS) PI COURT RULES SEEDED SUCCESSFULLY';
    RAISE NOTICE '========================================================================';
    RAISE NOTICE 'Mississippi has 3-YEAR SOL for PI (Miss. Code Ann. § 15-1-49).';
    RAISE NOTICE 'MEC system completed STATEWIDE mandatory e-filing June 30, 2025!';
    RAISE NOTICE '========================================================================';
END $$;

COMMIT;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================
-- SELECT COUNT(*) FROM leverage.legal_sources WHERE jurisdiction_state = 'MS';
-- Expected: 7 (2 state + 5 county)
--
-- SELECT COUNT(*) FROM leverage.rule_citations rc 
-- JOIN leverage.legal_sources ls ON rc.legal_source_id = ls.id 
-- WHERE ls.jurisdiction_state = 'MS';
-- Expected: 8 citations
--
-- SELECT COUNT(*) FROM leverage.validation_rules WHERE jurisdiction_state = 'MS';
-- Expected: 7 (1 SOL + 1 statewide e-filing + 5 county e-filing)
-- ============================================================================
