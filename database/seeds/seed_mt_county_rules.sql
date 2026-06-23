-- ============================================================================
-- Montana County-Specific PI Court Rules Seed
-- ============================================================================
-- Version: 1.0.0
-- Date: January 30, 2026
-- Purpose: Add Montana county-level court rules with verified citations
-- High-volume PI counties: Yellowstone (Billings), Missoula, Gallatin (Bozeman), Flathead, Cascade (Great Falls)
-- Montana has 3-YEAR SOL for personal injury
-- Data Due Diligence: Citations verified from leg.mt.gov and courts.mt.gov
-- ============================================================================
-- DOCUMENT VERIFIED CITATIONS:
--
-- 1. Montana Code Annotated § 27-2-204 - Tort actions - general and personal injury
--    Source: https://leg.mt.gov/bills/mca/title_0270/chapter_0020/part_0020/section_0040/0270-0020-0020-0040.html
--    EXACT TEXT: "27-2-204. (Temporary) Tort actions -- general and personal injury. 
--    (1) Except as provided in 27-2-216, the period prescribed for the commencement 
--    of an action upon a liability not founded upon an instrument in writing is 
--    within 3 years.
--    (2) The period prescribed for the commencement of an action to recover damages 
--    for the death of one caused by the wrongful act or neglect of another is within 
--    3 years, except when the wrongful death is the result of a homicide, in which 
--    case the period is within 10 years.
--    (3) The period prescribed for the commencement of an action for libel, slander, 
--    assault, battery, false imprisonment, or seduction is within 2 years."
--
-- 2. Montana Courts Electronic Filing
--    Source: https://courts.mt.gov/Courts/EFile/Rules
--    Montana 2017 initiative for mandatory e-filing integrated with FullCourt CMS
--    E-filing available for Supreme Court, District Courts, and limited jurisdiction courts
-- ============================================================================

BEGIN;

-- ============================================================================
-- PART 1: ADD MONTANA STATE AND COUNTY LEGAL SOURCES
-- ============================================================================

-- Montana State-level Sources
INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    ('state', 'MT', NULL, NULL,
     'Montana Code Annotated',
     'Montana State Legislature',
     'MCA',
     'https://leg.mt.gov/bills/mca/',
     'statute',
     'high',
     'Official Montana Code Annotated. Section 27-2-204(1) establishes 3-year SOL for tort actions (personal injury). DOCUMENT VERIFIED.'),
    ('state', 'MT', NULL, NULL,
     'Montana Temporary Electronic Filing Rules',
     'Montana Supreme Court',
     'MT E-Filing',
     'https://courts.mt.gov/Courts/EFile/Rules',
     'court_rule',
     'high',
     'Montana Courts E-Filing Rules. 2017 initiative for mandatory e-filing integrated with FullCourt CMS.')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET base_url = EXCLUDED.base_url, notes = EXCLUDED.notes;

-- Montana County Sources (Major PI Jurisdictions)
INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    ('county', 'MT', 'Yellowstone', 'District Court',
     'Yellowstone County District Court Rules',
     'Thirteenth Judicial District',
     'Yellowstone Co. D.Ct. R.',
     'https://courts.mt.gov/courts/dcourt/13th-district',
     'court_rule',
     'high',
     'Yellowstone County District Court (Billings). Most populous county in Montana. E-Filing available via FullCourt. WEB VERIFIED.'),
    ('county', 'MT', 'Missoula', 'District Court',
     'Missoula County District Court Rules',
     'Fourth Judicial District',
     'Missoula Co. D.Ct. R.',
     'https://courts.mt.gov/courts/dcourt/4th-district',
     'court_rule',
     'high',
     'Missoula County District Court. University town. E-Filing available via FullCourt. WEB VERIFIED.'),
    ('county', 'MT', 'Gallatin', 'District Court',
     'Gallatin County District Court Rules',
     'Eighteenth Judicial District',
     'Gallatin Co. D.Ct. R.',
     'https://courts.mt.gov/courts/dcourt/18th-district',
     'court_rule',
     'high',
     'Gallatin County District Court (Bozeman). Fastest growing county. E-Filing available via FullCourt. WEB VERIFIED.'),
    ('county', 'MT', 'Flathead', 'District Court',
     'Flathead County District Court Rules',
     'Eleventh Judicial District',
     'Flathead Co. D.Ct. R.',
     'https://courts.mt.gov/courts/dcourt/11th-district',
     'court_rule',
     'high',
     'Flathead County District Court (Kalispell). Northwest Montana. E-Filing available via FullCourt. WEB VERIFIED.'),
    ('county', 'MT', 'Cascade', 'District Court',
     'Cascade County District Court Rules',
     'Eighth Judicial District',
     'Cascade Co. D.Ct. R.',
     'https://courts.mt.gov/courts/dcourt/8th-district',
     'court_rule',
     'high',
     'Cascade County District Court (Great Falls). E-Filing available via FullCourt. WEB VERIFIED.')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET base_url = EXCLUDED.base_url, notes = EXCLUDED.notes;

-- ============================================================================
-- PART 2: ADD MONTANA STATE AND COUNTY CITATIONS
-- ============================================================================

INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'statute', 'Montana Code Annotated',
    'MCA § 27-2-204(1)',
    'https://leg.mt.gov/bills/mca/title_0270/chapter_0020/part_0020/section_0040/0270-0020-0020-0040.html',
    '27-2-204. Tort actions -- general and personal injury. (1) Except as provided in 27-2-216, the period prescribed for the commencement of an action upon a liability not founded upon an instrument in writing is within 3 years. (2) The period prescribed for the commencement of an action to recover damages for the death of one caused by the wrongful act or neglect of another is within 3 years, except when the wrongful death is the result of a homicide, in which case the period is within 10 years. (3) The period prescribed for the commencement of an action for libel, slander, assault, battery, false imprisonment, or seduction is within 2 years.',
    '§ 27-2-204(1)', NOW()::date, NOW(), 'document_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'MT' AND ls.abbreviation = 'MCA'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt,
    verifier = EXCLUDED.verifier;

-- Montana E-Filing Citation
INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'court_rule', 'Montana Temporary Electronic Filing Rules',
    'MT-EFILING-FULLCOURT',
    'https://courts.mt.gov/Courts/EFile/Rules',
    'Montana Courts E-Filing Rules. Montana 2017 initiative to implement mandatory electronic filing for courts, integrated with FullCourt case management system (CMS). E-filing available for Supreme Court, District Courts, Justice Courts, City/Municipal Courts, and Montana Water Court. Consult trial courts local rules to determine if e-filing is mandatory.',
    'E-Filing', '2017-01-01', NOW(), 'document_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'MT' AND ls.abbreviation = 'MT E-Filing'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt;

-- County-specific Citations
INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'local_rule', 'Yellowstone County District Court Rules',
    'MT-YELLOWSTONE-EFILING',
    'https://courts.mt.gov/external/efile/docs/crt-policy.pdf',
    'Yellowstone County District Court (Billings). Thirteenth Judicial District. Most populous county in Montana. E-Filing available via FullCourt CMS.',
    'E-Filing', '2017-01-01', NOW(), 'web_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'MT' AND ls.jurisdiction_county = 'Yellowstone'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt;

INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'local_rule', 'Missoula County District Court Rules',
    'MT-MISSOULA-EFILING',
    'https://courts.mt.gov/external/efile/docs/crt-policy.pdf',
    'Missoula County District Court. Fourth Judicial District. University of Montana location. E-Filing available via FullCourt CMS.',
    'E-Filing', '2017-01-01', NOW(), 'web_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'MT' AND ls.jurisdiction_county = 'Missoula'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt;

INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'local_rule', 'Gallatin County District Court Rules',
    'MT-GALLATIN-EFILING',
    'https://courts.mt.gov/external/efile/docs/crt-policy.pdf',
    'Gallatin County District Court (Bozeman). Eighteenth Judicial District. Fastest growing county in Montana. E-Filing available via FullCourt CMS.',
    'E-Filing', '2017-01-01', NOW(), 'web_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'MT' AND ls.jurisdiction_county = 'Gallatin'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt;

INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'local_rule', 'Flathead County District Court Rules',
    'MT-FLATHEAD-EFILING',
    'https://courts.mt.gov/external/efile/docs/crt-policy.pdf',
    'Flathead County District Court (Kalispell). Eleventh Judicial District. Northwest Montana near Glacier National Park. E-Filing available via FullCourt CMS.',
    'E-Filing', '2017-01-01', NOW(), 'web_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'MT' AND ls.jurisdiction_county = 'Flathead'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt;

INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'local_rule', 'Cascade County District Court Rules',
    'MT-CASCADE-EFILING',
    'https://courts.mt.gov/external/efile/docs/crt-policy.pdf',
    'Cascade County District Court (Great Falls). Eighth Judicial District. E-Filing available via FullCourt CMS.',
    'E-Filing', '2017-01-01', NOW(), 'web_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'MT' AND ls.jurisdiction_county = 'Cascade'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt;

-- ============================================================================
-- PART 3: ADD MONTANA VALIDATION RULES
-- ============================================================================

DO $$
DECLARE
    mt_sol_id INTEGER;
    mt_efiling_id INTEGER;
    mt_yellowstone_id INTEGER;
    mt_missoula_id INTEGER;
    mt_gallatin_id INTEGER;
    mt_flathead_id INTEGER;
    mt_cascade_id INTEGER;
BEGIN
    -- Get citation IDs
    SELECT id INTO mt_sol_id FROM leverage.rule_citations 
    WHERE citation = 'MCA § 27-2-204(1)';
    
    SELECT id INTO mt_efiling_id FROM leverage.rule_citations 
    WHERE citation = 'MT-EFILING-FULLCOURT';
    
    SELECT id INTO mt_yellowstone_id FROM leverage.rule_citations 
    WHERE citation = 'MT-YELLOWSTONE-EFILING';
    
    SELECT id INTO mt_missoula_id FROM leverage.rule_citations 
    WHERE citation = 'MT-MISSOULA-EFILING';
    
    SELECT id INTO mt_gallatin_id FROM leverage.rule_citations 
    WHERE citation = 'MT-GALLATIN-EFILING';
    
    SELECT id INTO mt_flathead_id FROM leverage.rule_citations 
    WHERE citation = 'MT-FLATHEAD-EFILING';
    
    SELECT id INTO mt_cascade_id FROM leverage.rule_citations 
    WHERE citation = 'MT-CASCADE-EFILING';

    -- MT Statewide PI SOL (3 years) - MCA § 27-2-204(1)
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'MT-SOL-27-2-204-PI-3YEAR', 5, 'MT Personal Injury SOL (3 Years)', 'threshold_check',
        'personal_injury', 'complaint',
        'state', 'MT', NULL, NULL,
        '{"sol_years": 3, "sol_days": 1095, "statute": "MCA § 27-2-204(1)", "applies_to": "liability_not_founded_upon_written_instrument", "wrongful_death": 3, "wrongful_death_homicide": 10, "intentional_torts": 2, "note": "Montana has 3-YEAR SOL for PI tort actions. Period for commencement of action upon liability not founded upon written instrument is 3 years."}'::jsonb,
        'error', mt_sol_id, 'document_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id,
        review_status = EXCLUDED.review_status;

    -- MT Statewide E-Filing Rule (FullCourt)
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'MT-EFILING-FULLCOURT-STATEWIDE', 2, 'MT Statewide E-Filing (FullCourt)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'MT', NULL, NULL,
        '{"requires_efiling": "per_local_rules", "system": "FullCourt CMS", "initiative_year": 2017, "available_courts": ["Supreme Court", "District Courts", "Justice Courts", "City Courts", "Municipal Courts", "Water Court"], "note": "DOCUMENT VERIFIED: Montana 2017 e-filing initiative. Consult local court rules for mandatory status."}'::jsonb,
        'warning', mt_efiling_id, 'document_verified',
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
        'MT-YELLOWSTONE-EFILING', 2, 'Yellowstone County E-Filing (Billings)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'MT', 'Yellowstone', 'District Court',
        '{"requires_efiling": "per_local_rules", "system": "FullCourt", "city": "Billings", "most_populous": true, "judicial_district": 13, "note": "Most populous county in Montana. E-Filing via FullCourt."}'::jsonb,
        'warning', mt_yellowstone_id, 'web_verified',
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
        'MT-MISSOULA-EFILING', 2, 'Missoula County E-Filing', 'format_check',
        'personal_injury', 'complaint',
        'state', 'MT', 'Missoula', 'District Court',
        '{"requires_efiling": "per_local_rules", "system": "FullCourt", "city": "Missoula", "judicial_district": 4, "university_town": true, "note": "University of Montana location. E-Filing via FullCourt."}'::jsonb,
        'warning', mt_missoula_id, 'web_verified',
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
        'MT-GALLATIN-EFILING', 2, 'Gallatin County E-Filing (Bozeman)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'MT', 'Gallatin', 'District Court',
        '{"requires_efiling": "per_local_rules", "system": "FullCourt", "city": "Bozeman", "judicial_district": 18, "fastest_growing": true, "note": "Fastest growing county in Montana. E-Filing via FullCourt."}'::jsonb,
        'warning', mt_gallatin_id, 'web_verified',
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
        'MT-FLATHEAD-EFILING', 2, 'Flathead County E-Filing (Kalispell)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'MT', 'Flathead', 'District Court',
        '{"requires_efiling": "per_local_rules", "system": "FullCourt", "city": "Kalispell", "judicial_district": 11, "near_glacier_park": true, "note": "Northwest Montana near Glacier National Park. E-Filing via FullCourt."}'::jsonb,
        'warning', mt_flathead_id, 'web_verified',
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
        'MT-CASCADE-EFILING', 2, 'Cascade County E-Filing (Great Falls)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'MT', 'Cascade', 'District Court',
        '{"requires_efiling": "per_local_rules", "system": "FullCourt", "city": "Great Falls", "judicial_district": 8, "note": "E-Filing via FullCourt."}'::jsonb,
        'warning', mt_cascade_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Completion message
    RAISE NOTICE '========================================================================';
    RAISE NOTICE 'MONTANA (MT) PI COURT RULES SEEDED SUCCESSFULLY';
    RAISE NOTICE '========================================================================';
    RAISE NOTICE 'Montana has 3-YEAR SOL for PI tort actions (MCA § 27-2-204(1)).';
    RAISE NOTICE 'E-Filing available via FullCourt CMS (consult local rules for mandatory status).';
    RAISE NOTICE '========================================================================';

END $$;

COMMIT;
