-- ============================================================================
-- West Virginia County-Specific PI Court Rules Seed
-- ============================================================================
-- Version: 1.0.0
-- Date: January 30, 2026
-- Purpose: Add West Virginia county-level court rules with verified citations
-- High-volume PI counties: Kanawha (Charleston - Capital), Cabell (Huntington), Berkeley, Wood (Parkersburg), Monongalia (Morgantown)
-- West Virginia has 2-YEAR SOL for personal injury
-- Data Due Diligence: Citations verified from code.wvlegislature.gov and courtswv.gov
-- ============================================================================
-- DOCUMENT VERIFIED CITATIONS:
--
-- 1. West Virginia Code § 55-2-12 - Personal injuries
--    Source: https://code.wvlegislature.gov/55-2-12/
--    VERIFIED TEXT: "Every personal action for which no limitation is otherwise 
--    prescribed shall be brought: (a) Within two years next after the right to 
--    bring the same shall have accrued if it be for damage to property; (b) within 
--    two years next after the right to bring the same shall have accrued if it be 
--    for damages for personal injuries."
--
-- 2. West Virginia Trial Court Rule 15A - Electronic Filing
--    Source: https://efile.courtswva.com/
--    WV E-File (WVACES) mandatory in active counties per Trial Court Rule 15A
--    File & ServeXpress mandatory for Supreme Court of Appeals
-- ============================================================================

BEGIN;

-- ============================================================================
-- PART 1: ADD WEST VIRGINIA STATE AND COUNTY LEGAL SOURCES
-- ============================================================================

-- West Virginia State-level Sources
INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    ('state', 'WV', NULL, NULL,
     'West Virginia Code',
     'West Virginia Legislature',
     'W.Va. Code',
     'https://code.wvlegislature.gov/',
     'statute',
     'high',
     'Official West Virginia Code. Section 55-2-12(b) establishes 2-year SOL for personal injury. DOCUMENT VERIFIED.'),
    ('state', 'WV', NULL, NULL,
     'West Virginia Trial Court Rule 15A',
     'Supreme Court of Appeals of West Virginia',
     'WV TCR 15A',
     'https://efile.courtswva.com/',
     'court_rule',
     'high',
     'West Virginia E-Filing Rule. WV E-File (WVACES) mandatory in active counties. File & ServeXpress mandatory for Supreme Court.')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET base_url = EXCLUDED.base_url, notes = EXCLUDED.notes;

-- West Virginia County Sources (Major PI Jurisdictions)
INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    ('county', 'WV', 'Kanawha', 'Circuit Court',
     'Kanawha County Circuit Court Rules',
     'Thirteenth Judicial Circuit',
     'Kanawha Co. Cir. Ct. R.',
     'https://www.courtswv.gov/circuit-courts/kanawha',
     'court_rule',
     'high',
     'Kanawha County Circuit Court (Charleston - State Capital). Most populous county. WV E-File mandatory. WEB VERIFIED.'),
    ('county', 'WV', 'Cabell', 'Circuit Court',
     'Cabell County Circuit Court Rules',
     'Sixth Judicial Circuit',
     'Cabell Co. Cir. Ct. R.',
     'https://www.courtswv.gov/circuit-courts/cabell',
     'court_rule',
     'high',
     'Cabell County Circuit Court (Huntington). Marshall University location. WV E-File mandatory. WEB VERIFIED.'),
    ('county', 'WV', 'Berkeley', 'Circuit Court',
     'Berkeley County Circuit Court Rules',
     'Twenty-Third Judicial Circuit',
     'Berkeley Co. Cir. Ct. R.',
     'https://www.courtswv.gov/circuit-courts/berkeley',
     'court_rule',
     'high',
     'Berkeley County Circuit Court (Martinsburg). Eastern Panhandle. WV E-File mandatory. WEB VERIFIED.'),
    ('county', 'WV', 'Wood', 'Circuit Court',
     'Wood County Circuit Court Rules',
     'Fourth Judicial Circuit',
     'Wood Co. Cir. Ct. R.',
     'https://www.courtswv.gov/circuit-courts/wood',
     'court_rule',
     'high',
     'Wood County Circuit Court (Parkersburg). WV E-File mandatory. WEB VERIFIED.'),
    ('county', 'WV', 'Monongalia', 'Circuit Court',
     'Monongalia County Circuit Court Rules',
     'Seventeenth Judicial Circuit',
     'Monongalia Co. Cir. Ct. R.',
     'https://www.courtswv.gov/circuit-courts/monongalia',
     'court_rule',
     'high',
     'Monongalia County Circuit Court (Morgantown). West Virginia University location. WV E-File mandatory. WEB VERIFIED.')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET base_url = EXCLUDED.base_url, notes = EXCLUDED.notes;

-- ============================================================================
-- PART 2: ADD WEST VIRGINIA STATE AND COUNTY CITATIONS
-- ============================================================================

INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'statute', 'West Virginia Code',
    'W.Va. Code § 55-2-12(b)',
    'https://code.wvlegislature.gov/55-2-12/',
    'Every personal action for which no limitation is otherwise prescribed shall be brought: (a) Within two years next after the right to bring the same shall have accrued if it be for damage to property; (b) within two years next after the right to bring the same shall have accrued if it be for damages for personal injuries.',
    '§ 55-2-12(b)', NOW()::date, NOW(), 'document_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'WV' AND ls.abbreviation = 'W.Va. Code'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt,
    verifier = EXCLUDED.verifier;

-- West Virginia E-Filing Citation
INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'court_rule', 'West Virginia Trial Court Rule 15A',
    'WV-TCR-15A-EFILING',
    'https://efile.courtswva.com/',
    'Electronic filing is mandatory for all Actions in Active Counties and shall be subject to these E-Filing Rules. West Virginia Trial Court Rule 15A governs electronic filing in circuit and family courts (WV E-File). File & ServeXpress is the exclusive e-filing provider for the Supreme Court of Appeals.',
    'TCR 15A', NOW()::date, NOW(), 'document_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'WV' AND ls.abbreviation = 'WV TCR 15A'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt;

-- County-specific Citations
INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'local_rule', 'Kanawha County Circuit Court Rules',
    'WV-KANAWHA-EFILING',
    'http://www.courtswv.gov/legal-community/e-filing/circuit-family-courts/about',
    'Kanawha County Circuit Court (Charleston - State Capital). Thirteenth Judicial Circuit. Most populous county in West Virginia. WV E-File (WVACES) mandatory per Trial Court Rule 15A.',
    'E-Filing', NOW()::date, NOW(), 'web_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'WV' AND ls.jurisdiction_county = 'Kanawha'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt;

INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'local_rule', 'Cabell County Circuit Court Rules',
    'WV-CABELL-EFILING',
    'http://www.courtswv.gov/legal-community/e-filing/circuit-family-courts/about',
    'Cabell County Circuit Court (Huntington). Sixth Judicial Circuit. Marshall University location. WV E-File (WVACES) mandatory per Trial Court Rule 15A.',
    'E-Filing', NOW()::date, NOW(), 'web_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'WV' AND ls.jurisdiction_county = 'Cabell'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt;

INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'local_rule', 'Berkeley County Circuit Court Rules',
    'WV-BERKELEY-EFILING',
    'http://www.courtswv.gov/legal-community/e-filing/circuit-family-courts/about',
    'Berkeley County Circuit Court (Martinsburg). Twenty-Third Judicial Circuit. Eastern Panhandle. WV E-File (WVACES) mandatory per Trial Court Rule 15A.',
    'E-Filing', NOW()::date, NOW(), 'web_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'WV' AND ls.jurisdiction_county = 'Berkeley'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt;

INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'local_rule', 'Wood County Circuit Court Rules',
    'WV-WOOD-EFILING',
    'http://www.courtswv.gov/legal-community/e-filing/circuit-family-courts/about',
    'Wood County Circuit Court (Parkersburg). Fourth Judicial Circuit. WV E-File (WVACES) mandatory per Trial Court Rule 15A.',
    'E-Filing', NOW()::date, NOW(), 'web_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'WV' AND ls.jurisdiction_county = 'Wood'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt;

INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'local_rule', 'Monongalia County Circuit Court Rules',
    'WV-MONONGALIA-EFILING',
    'http://www.courtswv.gov/legal-community/e-filing/circuit-family-courts/about',
    'Monongalia County Circuit Court (Morgantown). Seventeenth Judicial Circuit. West Virginia University location. WV E-File (WVACES) mandatory per Trial Court Rule 15A.',
    'E-Filing', NOW()::date, NOW(), 'web_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'WV' AND ls.jurisdiction_county = 'Monongalia'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt;

-- ============================================================================
-- PART 3: ADD WEST VIRGINIA VALIDATION RULES
-- ============================================================================

DO $$
DECLARE
    wv_sol_id INTEGER;
    wv_efiling_id INTEGER;
    wv_kanawha_id INTEGER;
    wv_cabell_id INTEGER;
    wv_berkeley_id INTEGER;
    wv_wood_id INTEGER;
    wv_monongalia_id INTEGER;
BEGIN
    -- Get citation IDs
    SELECT id INTO wv_sol_id FROM leverage.rule_citations 
    WHERE citation = 'W.Va. Code § 55-2-12(b)';
    
    SELECT id INTO wv_efiling_id FROM leverage.rule_citations 
    WHERE citation = 'WV-TCR-15A-EFILING';
    
    SELECT id INTO wv_kanawha_id FROM leverage.rule_citations 
    WHERE citation = 'WV-KANAWHA-EFILING';
    
    SELECT id INTO wv_cabell_id FROM leverage.rule_citations 
    WHERE citation = 'WV-CABELL-EFILING';
    
    SELECT id INTO wv_berkeley_id FROM leverage.rule_citations 
    WHERE citation = 'WV-BERKELEY-EFILING';
    
    SELECT id INTO wv_wood_id FROM leverage.rule_citations 
    WHERE citation = 'WV-WOOD-EFILING';
    
    SELECT id INTO wv_monongalia_id FROM leverage.rule_citations 
    WHERE citation = 'WV-MONONGALIA-EFILING';

    -- WV Statewide PI SOL (2 years) - W.Va. Code § 55-2-12(b)
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'WV-SOL-55-2-12-PI-2YEAR', 5, 'WV Personal Injury SOL (2 Years)', 'threshold_check',
        'personal_injury', 'complaint',
        'state', 'WV', NULL, NULL,
        '{"sol_years": 2, "sol_days": 730, "statute": "W.Va. Code § 55-2-12(b)", "applies_to": "damages_for_personal_injuries", "property_damage": 2, "medical_malpractice": 2, "medical_malpractice_max": 10, "note": "West Virginia has 2-YEAR SOL for PI. Every personal action for damages for personal injuries shall be brought within 2 years after the right to bring the same accrued."}'::jsonb,
        'error', wv_sol_id, 'document_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id,
        review_status = EXCLUDED.review_status;

    -- WV Statewide E-Filing Rule (WV E-File/WVACES)
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'WV-EFILING-TCR15A-STATEWIDE', 2, 'WV Statewide E-Filing (WV E-File)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'WV', NULL, NULL,
        '{"requires_efiling": "in_active_counties", "systems": {"circuit_family": "WV E-File (WVACES)", "supreme_court": "File & ServeXpress"}, "authority": "Trial Court Rule 15A", "supreme_court_fee": 15.00, "note": "DOCUMENT VERIFIED: E-Filing mandatory in active counties per Trial Court Rule 15A. File & ServeXpress mandatory for Supreme Court."}'::jsonb,
        'error', wv_efiling_id, 'document_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id,
        review_status = EXCLUDED.review_status;

    -- County E-Filing Rules
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'WV-KANAWHA-EFILING', 2, 'Kanawha County E-Filing (Charleston)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'WV', 'Kanawha', 'Circuit Court',
        '{"requires_efiling": true, "system": "WV E-File (WVACES)", "city": "Charleston", "state_capital": true, "most_populous": true, "judicial_circuit": 13, "authority": "Trial Court Rule 15A", "note": "State capital. Most populous county. E-Filing mandatory."}'::jsonb,
        'error', wv_kanawha_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'WV-CABELL-EFILING', 2, 'Cabell County E-Filing (Huntington)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'WV', 'Cabell', 'Circuit Court',
        '{"requires_efiling": true, "system": "WV E-File (WVACES)", "city": "Huntington", "judicial_circuit": 6, "university": "Marshall University", "authority": "Trial Court Rule 15A", "note": "Marshall University location. E-Filing mandatory."}'::jsonb,
        'error', wv_cabell_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'WV-BERKELEY-EFILING', 2, 'Berkeley County E-Filing (Martinsburg)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'WV', 'Berkeley', 'Circuit Court',
        '{"requires_efiling": true, "system": "WV E-File (WVACES)", "city": "Martinsburg", "judicial_circuit": 23, "eastern_panhandle": true, "authority": "Trial Court Rule 15A", "note": "Eastern Panhandle. E-Filing mandatory."}'::jsonb,
        'error', wv_berkeley_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'WV-WOOD-EFILING', 2, 'Wood County E-Filing (Parkersburg)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'WV', 'Wood', 'Circuit Court',
        '{"requires_efiling": true, "system": "WV E-File (WVACES)", "city": "Parkersburg", "judicial_circuit": 4, "authority": "Trial Court Rule 15A", "note": "E-Filing mandatory."}'::jsonb,
        'error', wv_wood_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'WV-MONONGALIA-EFILING', 2, 'Monongalia County E-Filing (Morgantown)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'WV', 'Monongalia', 'Circuit Court',
        '{"requires_efiling": true, "system": "WV E-File (WVACES)", "city": "Morgantown", "judicial_circuit": 17, "university": "West Virginia University", "authority": "Trial Court Rule 15A", "note": "West Virginia University location. E-Filing mandatory."}'::jsonb,
        'error', wv_monongalia_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Completion message
    RAISE NOTICE '========================================================================';
    RAISE NOTICE 'WEST VIRGINIA (WV) PI COURT RULES SEEDED SUCCESSFULLY';
    RAISE NOTICE '========================================================================';
    RAISE NOTICE 'West Virginia has 2-YEAR SOL for PI (W.Va. Code § 55-2-12(b)).';
    RAISE NOTICE 'E-Filing MANDATORY via WV E-File (WVACES) per Trial Court Rule 15A.';
    RAISE NOTICE 'File & ServeXpress mandatory for Supreme Court of Appeals.';
    RAISE NOTICE '========================================================================';

END $$;

COMMIT;
