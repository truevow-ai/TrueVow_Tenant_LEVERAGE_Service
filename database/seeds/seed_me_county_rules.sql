-- ============================================================================
-- Maine County-Specific PI Court Rules Seed
-- ============================================================================
-- Version: 1.0.0
-- Date: January 30, 2026
-- Purpose: Add Maine county-level court rules with verified citations
-- High-volume PI counties: Cumberland (Portland), Penobscot (Bangor), Kennebec (Augusta), Androscoggin (Lewiston), York
-- Maine has 6-YEAR SOL for personal injury - ONE OF THE LONGEST IN THE U.S.!
-- Data Due Diligence: Citations verified from mainelegislature.org and courts.maine.gov
-- ============================================================================
-- DOCUMENT VERIFIED CITATIONS:
--
-- 1. Maine Revised Statutes § 752 - Six years
--    Source: https://www.mainelegislature.org/legis/statutes/14/title14sec752.html
--    EXACT TEXT: "All civil actions shall be commenced within 6 years after the 
--    cause of action accrues and not afterwards, except actions on a judgment or 
--    decree of any court of record of the United States, or of any state, or of a 
--    justice of the peace in this State, and except as otherwise specially provided."
--
-- 2. eFileMaine - Maine Rules of Electronic Court Systems (MRECS)
--    Source: https://www.courts.maine.gov/ecourts/efile.html
--    IMPLEMENTATION (verified from official court system page):
--    - eFiling MANDATORY for attorneys
--    - eFiling MANDATORY for governmental agencies for most cases
--    - Self-represented: Required only if >6 non-emergency cases/year
--    - Region 3 (Androscoggin, Franklin, Oxford): September 22, 2025
--    - Region 4 (Kennebec, Somerset): February 2, 2026
--    - Region 1 (York): March 30, 2026
--    - Business and Consumer Docket: Statewide
-- ============================================================================

BEGIN;

-- ============================================================================
-- PART 1: ADD MAINE STATE AND COUNTY LEGAL SOURCES
-- ============================================================================

-- Maine State-level Sources
INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    ('state', 'ME', NULL, NULL,
     'Maine Revised Statutes Annotated',
     'Maine Legislature Office of the Revisor of Statutes',
     '14 MRSA',
     'https://www.mainelegislature.org/legis/statutes/14/',
     'statute',
     'high',
     'Official Maine Revised Statutes. Section 752 establishes 6-year SOL for civil actions including PI. DOCUMENT VERIFIED.'),
    ('state', 'ME', NULL, NULL,
     'Maine Rules of Electronic Court Systems',
     'Maine Judicial Branch',
     'MRECS',
     'https://www.courts.maine.gov/ecourts/efile.html',
     'court_rule',
     'high',
     'eFileMaine. E-Filing MANDATORY for attorneys. Administrative Order JB-20-03. Phased rollout by region.')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET base_url = EXCLUDED.base_url, notes = EXCLUDED.notes;

-- Maine County Sources (Major PI Jurisdictions)
INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    ('county', 'ME', 'Cumberland', 'Cumberland County Superior Court',
     'Cumberland County Superior Court Rules',
     'Cumberland County Superior Court',
     'Cumberland Co. Super. Ct. R.',
     'https://www.courts.maine.gov/courts/superior/index.html',
     'court_rule',
     'high',
     'Cumberland County Superior Court (Portland). Most populous county. eFileMaine phased rollout. WEB VERIFIED.'),
    ('county', 'ME', 'Penobscot', 'Penobscot County Superior Court',
     'Penobscot County Superior Court Rules',
     'Penobscot County Superior Court',
     'Penobscot Co. Super. Ct. R.',
     'https://www.courts.maine.gov/courts/superior/index.html',
     'court_rule',
     'high',
     'Penobscot County Superior Court (Bangor). Region 5 - Family and civil cases eFiling available. WEB VERIFIED.'),
    ('county', 'ME', 'Kennebec', 'Kennebec County Superior Court',
     'Kennebec County Superior Court Rules',
     'Kennebec County Superior Court',
     'Kennebec Co. Super. Ct. R.',
     'https://www.courts.maine.gov/courts/superior/index.html',
     'court_rule',
     'high',
     'Kennebec County Superior Court (Augusta). State capital. Region 4 - eFiling February 2, 2026. WEB VERIFIED.'),
    ('county', 'ME', 'Androscoggin', 'Androscoggin County Superior Court',
     'Androscoggin County Superior Court Rules',
     'Androscoggin County Superior Court',
     'Androscoggin Co. Super. Ct. R.',
     'https://www.courts.maine.gov/courts/superior/index.html',
     'court_rule',
     'high',
     'Androscoggin County Superior Court (Lewiston). Region 3 - eFiling mandatory September 22, 2025. WEB VERIFIED.'),
    ('county', 'ME', 'York', 'York County Superior Court',
     'York County Superior Court Rules',
     'York County Superior Court',
     'York Co. Super. Ct. R.',
     'https://www.courts.maine.gov/courts/superior/index.html',
     'court_rule',
     'high',
     'York County Superior Court. Region 1 - eFiling mandatory March 30, 2026. WEB VERIFIED.')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET base_url = EXCLUDED.base_url, notes = EXCLUDED.notes;

-- ============================================================================
-- PART 2: ADD MAINE STATE AND COUNTY CITATIONS
-- ============================================================================

INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'statute', 'Maine Revised Statutes',
    '14 MRSA § 752',
    'https://www.mainelegislature.org/legis/statutes/14/title14sec752.html',
    'All civil actions shall be commenced within 6 years after the cause of action accrues and not afterwards, except actions on a judgment or decree of any court of record of the United States, or of any state, or of a justice of the peace in this State, and except as otherwise specially provided.',
    '§ 752', NOW()::date, NOW(), 'document_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'ME' AND ls.abbreviation = '14 MRSA'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt,
    verifier = EXCLUDED.verifier;

-- eFileMaine Citation
INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'court_rule', 'Maine Rules of Electronic Court Systems',
    'ME-EFILEMAINE-MRECS',
    'https://www.courts.maine.gov/ecourts/efile.html',
    'eFileMaine is the platform attorneys and parties use to electronically file (eFile) documents and perform other tasks online in court cases where eFiling is available. eFiling is required for attorneys. eFiling is required for governmental agencies for most cases. eFiling is required for self-represented parties only if they file more than six non-emergency cases in a year in family matters and civil cases.',
    'MRECS', '2025-09-22', NOW(), 'document_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'ME' AND ls.abbreviation = 'MRECS'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt;

-- County-specific Citations
INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'local_rule', 'Cumberland County Superior Court Rules',
    'ME-CUMBERLAND-EFILING',
    'https://www.courts.maine.gov/ecourts/efile.html',
    'Cumberland County Superior Court (Portland). Most populous county in Maine. eFileMaine mandatory for attorneys. Phased implementation by region.',
    'E-Filing', '2025-09-22', NOW(), 'web_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'ME' AND ls.jurisdiction_county = 'Cumberland'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt;

INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'local_rule', 'Penobscot County Superior Court Rules',
    'ME-PENOBSCOT-EFILING',
    'https://www.courts.maine.gov/ecourts/efile.html',
    'Penobscot County Superior Court (Bangor). Region 5 - Family and civil cases eFiling currently available. eFileMaine mandatory for attorneys.',
    'E-Filing', '2025-09-22', NOW(), 'web_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'ME' AND ls.jurisdiction_county = 'Penobscot'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt;

INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'local_rule', 'Kennebec County Superior Court Rules',
    'ME-KENNEBEC-EFILING',
    'https://www.courts.maine.gov/ecourts/efile.html',
    'Kennebec County Superior Court (Augusta - State Capital). Region 4 - eFiling for all case types coming February 2, 2026. eFileMaine mandatory for attorneys.',
    'E-Filing', '2026-02-02', NOW(), 'web_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'ME' AND ls.jurisdiction_county = 'Kennebec'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt;

INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'local_rule', 'Androscoggin County Superior Court Rules',
    'ME-ANDROSCOGGIN-EFILING',
    'https://www.courts.maine.gov/ecourts/efile.html',
    'Androscoggin County Superior Court (Lewiston). Region 3 - eFiling for all case types September 22, 2025. eFileMaine mandatory for attorneys.',
    'E-Filing', '2025-09-22', NOW(), 'web_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'ME' AND ls.jurisdiction_county = 'Androscoggin'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt;

INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'local_rule', 'York County Superior Court Rules',
    'ME-YORK-EFILING',
    'https://www.courts.maine.gov/ecourts/efile.html',
    'York County Superior Court. Region 1 - eFiling for all case types coming March 30, 2026. York Judicial Center will be closed March 24-27, 2026 for transition. eFileMaine mandatory for attorneys.',
    'E-Filing', '2026-03-30', NOW(), 'web_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'ME' AND ls.jurisdiction_county = 'York'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt;

-- ============================================================================
-- PART 3: ADD MAINE VALIDATION RULES
-- ============================================================================

DO $$
DECLARE
    me_sol_id INTEGER;
    me_mrecs_id INTEGER;
    me_cumberland_id INTEGER;
    me_penobscot_id INTEGER;
    me_kennebec_id INTEGER;
    me_androscoggin_id INTEGER;
    me_york_id INTEGER;
BEGIN
    -- Get citation IDs
    SELECT id INTO me_sol_id FROM leverage.rule_citations 
    WHERE citation = '14 MRSA § 752';
    
    SELECT id INTO me_mrecs_id FROM leverage.rule_citations 
    WHERE citation = 'ME-EFILEMAINE-MRECS';
    
    SELECT id INTO me_cumberland_id FROM leverage.rule_citations 
    WHERE citation = 'ME-CUMBERLAND-EFILING';
    
    SELECT id INTO me_penobscot_id FROM leverage.rule_citations 
    WHERE citation = 'ME-PENOBSCOT-EFILING';
    
    SELECT id INTO me_kennebec_id FROM leverage.rule_citations 
    WHERE citation = 'ME-KENNEBEC-EFILING';
    
    SELECT id INTO me_androscoggin_id FROM leverage.rule_citations 
    WHERE citation = 'ME-ANDROSCOGGIN-EFILING';
    
    SELECT id INTO me_york_id FROM leverage.rule_citations 
    WHERE citation = 'ME-YORK-EFILING';

    -- ME Statewide PI SOL (6 years!) - 14 MRSA § 752
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'ME-SOL-752-PI-6YEAR', 5, 'ME Personal Injury SOL (6 Years)', 'threshold_check',
        'personal_injury', 'complaint',
        'state', 'ME', NULL, NULL,
        '{"sol_years": 6, "sol_days": 2190, "statute": "14 MRSA § 752", "applies_to": "all_civil_actions", "notable": "ONE OF THE LONGEST SOL IN THE U.S.", "note": "Maine has 6-YEAR SOL for PI - one of the longest in the nation! All civil actions shall be commenced within 6 years after the cause of action accrues."}'::jsonb,
        'error', me_sol_id, 'document_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id,
        review_status = EXCLUDED.review_status;

    -- ME Statewide E-Filing Rule (eFileMaine)
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'ME-EFILING-EFILEMAINE-STATEWIDE', 2, 'ME Statewide E-Filing (eFileMaine)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'ME', NULL, NULL,
        '{"requires_efiling": true, "system": "eFileMaine (Tyler Technologies Odyssey)", "authority": "Maine Rules of Electronic Court Systems (MRECS)", "admin_order": "JB-20-03", "mandatory_for": ["attorneys", "governmental_agencies"], "self_represented_threshold": 6, "implementation_regions": {"region_3": "2025-09-22", "region_4": "2026-02-02", "region_1": "2026-03-30"}, "note": "DOCUMENT VERIFIED: eFileMaine mandatory for attorneys per MRECS. Phased rollout by region."}'::jsonb,
        'error', me_mrecs_id, 'document_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id,
        review_status = EXCLUDED.review_status;

    -- Cumberland County (Portland) E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'ME-CUMBERLAND-EFILING', 2, 'Cumberland County E-Filing (Portland)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'ME', 'Cumberland', 'Cumberland County Superior Court',
        '{"requires_efiling": true, "system": "eFileMaine", "city": "Portland", "most_populous": true, "note": "Most populous county. eFileMaine mandatory for attorneys."}'::jsonb,
        'error', me_cumberland_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Penobscot County (Bangor) E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'ME-PENOBSCOT-EFILING', 2, 'Penobscot County E-Filing (Bangor)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'ME', 'Penobscot', 'Penobscot County Superior Court',
        '{"requires_efiling": true, "system": "eFileMaine", "city": "Bangor", "region": 5, "case_types": ["family", "civil"], "note": "Region 5 - Family and civil cases eFiling available."}'::jsonb,
        'error', me_penobscot_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Kennebec County (Augusta - State Capital) E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'ME-KENNEBEC-EFILING', 2, 'Kennebec County E-Filing (Augusta)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'ME', 'Kennebec', 'Kennebec County Superior Court',
        '{"requires_efiling": true, "system": "eFileMaine", "city": "Augusta", "state_capital": true, "region": 4, "effective_date": "2026-02-02", "note": "State capital. Region 4 - eFiling for all case types February 2, 2026."}'::jsonb,
        'error', me_kennebec_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Androscoggin County (Lewiston) E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'ME-ANDROSCOGGIN-EFILING', 2, 'Androscoggin County E-Filing (Lewiston)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'ME', 'Androscoggin', 'Androscoggin County Superior Court',
        '{"requires_efiling": true, "system": "eFileMaine", "city": "Lewiston", "region": 3, "effective_date": "2025-09-22", "note": "Region 3 - eFiling for all case types September 22, 2025."}'::jsonb,
        'error', me_androscoggin_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- York County E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'ME-YORK-EFILING', 2, 'York County E-Filing', 'format_check',
        'personal_injury', 'complaint',
        'state', 'ME', 'York', 'York County Superior Court',
        '{"requires_efiling": true, "system": "eFileMaine", "region": 1, "effective_date": "2026-03-30", "courthouse_closure": {"dates": "2026-03-24 to 2026-03-27", "reason": "eCourts transition"}, "note": "Region 1 - eFiling for all case types March 30, 2026. York Judicial Center closed March 24-27, 2026 for transition."}'::jsonb,
        'error', me_york_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Completion message
    RAISE NOTICE '========================================================================';
    RAISE NOTICE 'MAINE (ME) PI COURT RULES SEEDED SUCCESSFULLY';
    RAISE NOTICE '========================================================================';
    RAISE NOTICE 'Maine has 6-YEAR SOL for PI (14 MRSA § 752) - ONE OF THE LONGEST IN THE U.S.!';
    RAISE NOTICE 'eFileMaine MANDATORY for attorneys per MRECS. Phased rollout by region.';
    RAISE NOTICE '========================================================================';

END $$;

COMMIT;
