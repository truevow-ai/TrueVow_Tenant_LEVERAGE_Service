-- ============================================================================
-- Hawaii County-Specific PI Court Rules Seed
-- ============================================================================
-- Version: 1.0.0
-- Date: January 30, 2026
-- Purpose: Add Hawaii county-level court rules with verified citations
-- High-volume PI areas: Honolulu (First Circuit), Maui (Second), Hawaii County (Third), Kauai (Fifth)
-- Hawaii has 2-YEAR SOL for personal injury
-- Data Due Diligence: Citations verified from capitol.hawaii.gov and courts.state.hi.us
-- ============================================================================
-- DOCUMENT VERIFIED CITATIONS:
--
-- 1. Hawaii Revised Statutes § 657-7 - Damage to persons or property
--    Source: https://www.capitol.hawaii.gov/hrscurrent/Vol13_Ch0601-0676/HRS0657/HRS_0657-0007.htm
--    EXACT TEXT: "Actions for the recovery of compensation for damage or injury 
--    to persons or property shall be instituted within two years after the cause 
--    of action accrued, and not after, except as provided in section 657-13."
--
-- 2. JEFS - Judiciary Electronic Filing and Service System
--    Source: https://www.courts.state.hi.us/legal_references/efiling
--    IMPLEMENTATION DATES (verified from official page):
--    - Hawaii Supreme Court: September 27, 2010
--    - Hawaii Intermediate Court of Appeals: September 27, 2010
--    - State Criminal District Court: August 13, 2012
--    - Circuit and Family (adult) Criminal Courts: January 23, 2017
--    - District Court Civil: October 7, 2019
--    - Circuit Court Civil: October 28, 2019
--    - Family Court Civil: April 25, 2022
--    - Land Court and Tax Appeal Court: November 18, 2019
-- ============================================================================

BEGIN;

-- ============================================================================
-- PART 1: ADD HAWAII STATE AND COUNTY LEGAL SOURCES
-- ============================================================================

-- Hawaii State-level Sources
INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    ('state', 'HI', NULL, NULL,
     'Hawaii Revised Statutes',
     'Hawaii State Legislature',
     'HRS',
     'https://www.capitol.hawaii.gov/hrscurrent/',
     'statute',
     'high',
     'Official Hawaii Revised Statutes. Section 657-7 establishes 2-year SOL for personal injury. DOCUMENT VERIFIED.'),
    ('state', 'HI', NULL, NULL,
     'Hawaii Rules of Court - JEFS',
     'Hawaii State Judiciary',
     'HI JEFS',
     'https://www.courts.state.hi.us/legal_references/efiling',
     'court_rule',
     'high',
     'Judiciary Electronic Filing and Service System (JEFS). E-Filing mandatory for civil cases since October 2019.')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET base_url = EXCLUDED.base_url, notes = EXCLUDED.notes;

-- Hawaii Circuit Court Sources (by Judicial Circuit)
INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    ('county', 'HI', 'Honolulu', 'First Circuit Court',
     'First Circuit Court Rules (Honolulu)',
     'First Circuit Court of Hawaii',
     '1CC R.',
     'https://www.courts.state.hi.us/courts/circuit/first_circuit',
     'court_rule',
     'high',
     'First Circuit Court (Oahu/Honolulu). Most populous circuit. JEFS mandatory for civil cases since 10/28/2019.'),
    ('county', 'HI', 'Maui', 'Second Circuit Court',
     'Second Circuit Court Rules (Maui)',
     'Second Circuit Court of Hawaii',
     '2CC R.',
     'https://www.courts.state.hi.us/courts/circuit/second_circuit',
     'court_rule',
     'high',
     'Second Circuit Court (Maui, Molokai, Lanai). JEFS mandatory for civil cases since 10/28/2019.'),
    ('county', 'HI', 'Hawaii', 'Third Circuit Court',
     'Third Circuit Court Rules (Hawaii Island)',
     'Third Circuit Court of Hawaii',
     '3CC R.',
     'https://www.courts.state.hi.us/courts/circuit/third_circuit',
     'court_rule',
     'high',
     'Third Circuit Court (Hawaii Island/Big Island). Hilo and Kona. JEFS mandatory. Document Drop-off available.'),
    ('county', 'HI', 'Kauai', 'Fifth Circuit Court',
     'Fifth Circuit Court Rules (Kauai)',
     'Fifth Circuit Court of Hawaii',
     '5CC R.',
     'https://www.courts.state.hi.us/courts/circuit/fifth_circuit',
     'court_rule',
     'high',
     'Fifth Circuit Court (Kauai and Niihau). JEFS mandatory for civil cases since 10/28/2019.')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET base_url = EXCLUDED.base_url, notes = EXCLUDED.notes;

-- ============================================================================
-- PART 2: ADD HAWAII STATE AND CIRCUIT CITATIONS
-- ============================================================================

INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'statute', 'Hawaii Revised Statutes',
    'HRS § 657-7',
    'https://www.capitol.hawaii.gov/hrscurrent/Vol13_Ch0601-0676/HRS0657/HRS_0657-0007.htm',
    'Actions for the recovery of compensation for damage or injury to persons or property shall be instituted within two years after the cause of action accrued, and not after, except as provided in section 657-13.',
    '§ 657-7', NOW()::date, NOW(), 'document_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'HI' AND ls.abbreviation = 'HRS'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt,
    verifier = EXCLUDED.verifier;

-- JEFS E-Filing Citation
INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'court_rule', 'Hawaii JEFS Rules',
    'HI-JEFS-CIVIL-EFILING',
    'https://www.courts.state.hi.us/legal_references/efiling',
    'Efiling is currently available for the Hawaii Supreme Court (9/27/10); the Hawaii Intermediate Court of Appeals (9/27/10); state Criminal District Court (8/13/12); Circuit and Family (adult) Criminal courts (1/23/17); District Court Civil (10/7/19); Circuit Court Civil (10/28/19); Family Court Civil (4/25/22); and Land Court and Tax Appeal Court (11/18/19).',
    'JEFS', '2019-10-28', NOW(), 'document_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'HI' AND ls.abbreviation = 'HI JEFS'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt;

-- Circuit-specific Citations
INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'local_rule', 'First Circuit Court Rules',
    'HI-1CC-EFILING',
    'https://www.courts.state.hi.us/legal_references/efiling',
    'First Circuit Court (Oahu/Honolulu). Most populous circuit in Hawaii. JEFS e-filing mandatory for Circuit Court Civil since October 28, 2019.',
    'E-Filing', '2019-10-28', NOW(), 'web_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'HI' AND ls.jurisdiction_county = 'Honolulu'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt;

INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'local_rule', 'Second Circuit Court Rules',
    'HI-2CC-EFILING',
    'https://www.courts.state.hi.us/legal_references/efiling',
    'Second Circuit Court (Maui, Molokai, Lanai). JEFS e-filing mandatory for Circuit Court Civil since October 28, 2019.',
    'E-Filing', '2019-10-28', NOW(), 'web_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'HI' AND ls.jurisdiction_county = 'Maui'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt;

INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'local_rule', 'Third Circuit Court Rules',
    'HI-3CC-EFILING',
    'https://www.courts.state.hi.us/legal_references/efiling',
    'Third Circuit Court (Hawaii Island/Big Island - Hilo and Kona). JEFS e-filing mandatory. Court Document Drop-off available only in the Third Circuit civil and adult criminal courts.',
    'E-Filing', '2019-10-28', NOW(), 'web_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'HI' AND ls.jurisdiction_county = 'Hawaii'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt;

INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'local_rule', 'Fifth Circuit Court Rules',
    'HI-5CC-EFILING',
    'https://www.courts.state.hi.us/legal_references/efiling',
    'Fifth Circuit Court (Kauai and Niihau). JEFS e-filing mandatory for Circuit Court Civil since October 28, 2019.',
    'E-Filing', '2019-10-28', NOW(), 'web_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'HI' AND ls.jurisdiction_county = 'Kauai'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt;

-- ============================================================================
-- PART 3: ADD HAWAII VALIDATION RULES
-- ============================================================================

DO $$
DECLARE
    hi_sol_id INTEGER;
    hi_jefs_id INTEGER;
    hi_1cc_id INTEGER;
    hi_2cc_id INTEGER;
    hi_3cc_id INTEGER;
    hi_5cc_id INTEGER;
BEGIN
    -- Get citation IDs
    SELECT id INTO hi_sol_id FROM leverage.rule_citations 
    WHERE citation = 'HRS § 657-7';
    
    SELECT id INTO hi_jefs_id FROM leverage.rule_citations 
    WHERE citation = 'HI-JEFS-CIVIL-EFILING';
    
    SELECT id INTO hi_1cc_id FROM leverage.rule_citations 
    WHERE citation = 'HI-1CC-EFILING';
    
    SELECT id INTO hi_2cc_id FROM leverage.rule_citations 
    WHERE citation = 'HI-2CC-EFILING';
    
    SELECT id INTO hi_3cc_id FROM leverage.rule_citations 
    WHERE citation = 'HI-3CC-EFILING';
    
    SELECT id INTO hi_5cc_id FROM leverage.rule_citations 
    WHERE citation = 'HI-5CC-EFILING';

    -- HI Statewide PI SOL (2 years) - HRS § 657-7
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'HI-SOL-657-7-PI-2YEAR', 5, 'HI Personal Injury SOL (2 Years)', 'threshold_check',
        'personal_injury', 'complaint',
        'state', 'HI', NULL, NULL,
        '{"sol_years": 2, "sol_days": 730, "statute": "HRS § 657-7", "applies_to": "damage_or_injury_to_persons_or_property", "note": "Hawaii has 2-YEAR SOL for PI. Actions for recovery of compensation for damage or injury to persons or property must be instituted within 2 years after cause of action accrued."}'::jsonb,
        'error', hi_sol_id, 'document_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id,
        review_status = EXCLUDED.review_status;

    -- HI Statewide E-Filing Rule (JEFS)
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'HI-EFILING-JEFS-STATEWIDE', 2, 'HI Statewide E-Filing (JEFS)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'HI', NULL, NULL,
        '{"requires_efiling": true, "system": "Judiciary Electronic Filing and Service System (JEFS)", "implementation_dates": {"supreme_court": "2010-09-27", "intermediate_appeals": "2010-09-27", "district_court_civil": "2019-10-07", "circuit_court_civil": "2019-10-28", "family_court_civil": "2022-04-25"}, "note": "JEFS e-filing mandatory for civil cases. DOCUMENT VERIFIED from courts.state.hi.us."}'::jsonb,
        'error', hi_jefs_id, 'document_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id,
        review_status = EXCLUDED.review_status;

    -- First Circuit (Honolulu/Oahu) E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'HI-1CC-HONOLULU-EFILING', 2, 'First Circuit E-Filing (Honolulu/Oahu)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'HI', 'Honolulu', 'First Circuit Court',
        '{"requires_efiling": true, "system": "JEFS", "circuit": "First Circuit", "islands": ["Oahu"], "city": "Honolulu", "effective_date": "2019-10-28", "most_populous": true, "note": "Most populous circuit. JEFS mandatory since 10/28/2019."}'::jsonb,
        'error', hi_1cc_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Second Circuit (Maui) E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'HI-2CC-MAUI-EFILING', 2, 'Second Circuit E-Filing (Maui)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'HI', 'Maui', 'Second Circuit Court',
        '{"requires_efiling": true, "system": "JEFS", "circuit": "Second Circuit", "islands": ["Maui", "Molokai", "Lanai"], "city": "Wailuku", "effective_date": "2019-10-28", "note": "JEFS mandatory since 10/28/2019."}'::jsonb,
        'error', hi_2cc_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Third Circuit (Hawaii Island/Big Island) E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'HI-3CC-HAWAII-EFILING', 2, 'Third Circuit E-Filing (Hawaii Island)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'HI', 'Hawaii', 'Third Circuit Court',
        '{"requires_efiling": true, "system": "JEFS", "circuit": "Third Circuit", "islands": ["Hawaii Island (Big Island)"], "cities": ["Hilo", "Kona"], "effective_date": "2019-10-28", "document_dropoff_available": true, "note": "JEFS mandatory. Document Drop-off still available in Third Circuit only."}'::jsonb,
        'error', hi_3cc_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Fifth Circuit (Kauai) E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'HI-5CC-KAUAI-EFILING', 2, 'Fifth Circuit E-Filing (Kauai)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'HI', 'Kauai', 'Fifth Circuit Court',
        '{"requires_efiling": true, "system": "JEFS", "circuit": "Fifth Circuit", "islands": ["Kauai", "Niihau"], "city": "Lihue", "effective_date": "2019-10-28", "note": "JEFS mandatory since 10/28/2019."}'::jsonb,
        'error', hi_5cc_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Completion message
    RAISE NOTICE '========================================================================';
    RAISE NOTICE 'HAWAII (HI) PI COURT RULES SEEDED SUCCESSFULLY';
    RAISE NOTICE '========================================================================';
    RAISE NOTICE 'Hawaii has 2-YEAR SOL for PI (HRS § 657-7).';
    RAISE NOTICE 'JEFS E-Filing MANDATORY for civil cases since October 28, 2019.';
    RAISE NOTICE '========================================================================';

END $$;

COMMIT;
