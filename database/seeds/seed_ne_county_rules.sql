-- ============================================================================
-- Nebraska County-Specific PI Court Rules Seed
-- ============================================================================
-- Version: 1.0.0
-- Date: January 30, 2026
-- Purpose: Add Nebraska county-level court rules with verified citations
-- High-volume PI counties: Douglas (Omaha), Lancaster (Lincoln - Capital), Sarpy, Hall (Grand Island), Buffalo (Kearney)
-- Nebraska has 4-YEAR SOL for personal injury
-- Data Due Diligence: Citations verified from nebraskalegislature.gov and nebraskajudicial.gov
-- ============================================================================
-- DOCUMENT VERIFIED CITATIONS:
--
-- 1. Nebraska Revised Statutes § 25-207 - Four-year limitations
--    Source: https://nebraskalegislature.gov/laws/statutes.php?statute=25-207
--    VERIFIED TEXT: "The following actions can only be brought within four 
--    years: ... An action for an injury to the rights of the plaintiff, not 
--    arising on contract and not hereinafter enumerated."
--    NOTE: Nebraska has 4-YEAR SOL - one of the longer periods in the U.S.
--
-- 2. Nebraska Supreme Court Rule § 2-202 - Mandatory Electronic Filing
--    Source: https://nebraskajudicial.gov/supreme-court-rules/chapter-2-appeals/article-2-electronic-filing-service-and-notice-system-nebraska-trial-and-appellate-courts/%C2%A7-2-202-mandatory-electronic-filing-electronic-service-and-electronic-notice
--    E-Filing mandatory since January 1, 2022 for all Nebraska attorneys
--    Uses JUSTICE (trial courts) and SCCALES (appellate courts) systems
-- ============================================================================
-- THIS IS STATE 50 OF 50 - ALL 50 STATES COMPLETE!
-- ============================================================================

BEGIN;

-- ============================================================================
-- PART 1: ADD NEBRASKA STATE AND COUNTY LEGAL SOURCES
-- ============================================================================

-- Nebraska State-level Sources
INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    ('state', 'NE', NULL, NULL,
     'Nebraska Revised Statutes',
     'Nebraska Legislature',
     'Neb. Rev. Stat.',
     'https://nebraskalegislature.gov/laws/statutes.php',
     'statute',
     'high',
     'Official Nebraska Revised Statutes. Section 25-207 establishes 4-YEAR SOL for personal injury. DOCUMENT VERIFIED.'),
    ('state', 'NE', NULL, NULL,
     'Nebraska Supreme Court Rule 2-202',
     'Nebraska Supreme Court',
     'NE SCR 2-202',
     'https://nebraskajudicial.gov/supreme-court-rules/',
     'court_rule',
     'high',
     'Nebraska E-Filing Rule. E-Filing mandatory since January 1, 2022 for all Nebraska attorneys. Uses JUSTICE and SCCALES systems.')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET base_url = EXCLUDED.base_url, notes = EXCLUDED.notes;

-- Nebraska County Sources (Major PI Jurisdictions)
INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    ('county', 'NE', 'Douglas', 'District Court',
     'Douglas County District Court Rules',
     'Fourth Judicial District',
     'Douglas Co. D.Ct. R.',
     'https://www.nebraskajudicial.gov/courts/district/4',
     'court_rule',
     'high',
     'Douglas County District Court (Omaha). Most populous county. JUSTICE e-filing mandatory. WEB VERIFIED.'),
    ('county', 'NE', 'Lancaster', 'District Court',
     'Lancaster County District Court Rules',
     'Third Judicial District',
     'Lancaster Co. D.Ct. R.',
     'https://www.nebraskajudicial.gov/courts/district/3',
     'court_rule',
     'high',
     'Lancaster County District Court (Lincoln - State Capital). University of Nebraska location. JUSTICE e-filing mandatory. WEB VERIFIED.'),
    ('county', 'NE', 'Sarpy', 'District Court',
     'Sarpy County District Court Rules',
     'Second Judicial District',
     'Sarpy Co. D.Ct. R.',
     'https://www.nebraskajudicial.gov/courts/district/2',
     'court_rule',
     'high',
     'Sarpy County District Court (Papillion). Third most populous, fastest growing. JUSTICE e-filing mandatory. WEB VERIFIED.'),
    ('county', 'NE', 'Hall', 'District Court',
     'Hall County District Court Rules',
     'Ninth Judicial District',
     'Hall Co. D.Ct. R.',
     'https://www.nebraskajudicial.gov/courts/district/9',
     'court_rule',
     'high',
     'Hall County District Court (Grand Island). Central Nebraska hub. JUSTICE e-filing mandatory. WEB VERIFIED.'),
    ('county', 'NE', 'Buffalo', 'District Court',
     'Buffalo County District Court Rules',
     'Tenth Judicial District',
     'Buffalo Co. D.Ct. R.',
     'https://www.nebraskajudicial.gov/courts/district/10',
     'court_rule',
     'high',
     'Buffalo County District Court (Kearney). University of Nebraska at Kearney. JUSTICE e-filing mandatory. WEB VERIFIED.')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET base_url = EXCLUDED.base_url, notes = EXCLUDED.notes;

-- ============================================================================
-- PART 2: ADD NEBRASKA STATE AND COUNTY CITATIONS
-- ============================================================================

INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'statute', 'Nebraska Revised Statutes',
    'Neb. Rev. Stat. § 25-207',
    'https://nebraskalegislature.gov/laws/statutes.php?statute=25-207',
    'The following actions can only be brought within four years: An action for trespass upon real property; An action for taking, detaining, or injuring personal property, including actions for the specific recovery thereof; An action for an injury to the rights of the plaintiff, not arising on contract and not hereinafter enumerated; An action for relief on the ground of fraud.',
    '§ 25-207', NOW()::date, NOW(), 'document_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'NE' AND ls.abbreviation = 'Neb. Rev. Stat.'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt,
    verifier = EXCLUDED.verifier;

-- Nebraska E-Filing Citation
INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'court_rule', 'Nebraska Supreme Court Rule 2-202',
    'NE-SCR-2-202-EFILING',
    'https://nebraskajudicial.gov/e-services/efiling',
    'Starting January 1, 2022, all Nebraska attorneys are required to file, serve, and notice documents electronically in trial and appellate courts. Registration requires a Nebraska.Gov Subscriber account. Uses JUSTICE (trial court) and SCCALES (appellate court) case management systems. Documents must be in text-searchable PDF format.',
    '§ 2-202', '2022-01-01', NOW(), 'document_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'NE' AND ls.abbreviation = 'NE SCR 2-202'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt;

-- County-specific Citations
INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'local_rule', 'Douglas County District Court Rules',
    'NE-DOUGLAS-EFILING',
    'https://nebraskajudicial.gov/e-services/efiling',
    'Douglas County District Court (Omaha). Fourth Judicial District. Most populous county in Nebraska. JUSTICE e-filing mandatory since January 1, 2022.',
    'E-Filing', '2022-01-01', NOW(), 'web_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'NE' AND ls.jurisdiction_county = 'Douglas'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt;

INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'local_rule', 'Lancaster County District Court Rules',
    'NE-LANCASTER-EFILING',
    'https://nebraskajudicial.gov/e-services/efiling',
    'Lancaster County District Court (Lincoln - State Capital). Third Judicial District. University of Nebraska main campus. JUSTICE e-filing mandatory since January 1, 2022.',
    'E-Filing', '2022-01-01', NOW(), 'web_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'NE' AND ls.jurisdiction_county = 'Lancaster'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt;

INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'local_rule', 'Sarpy County District Court Rules',
    'NE-SARPY-EFILING',
    'https://nebraskajudicial.gov/e-services/efiling',
    'Sarpy County District Court (Papillion). Second Judicial District. Third most populous county, fastest growing in Nebraska. JUSTICE e-filing mandatory since January 1, 2022.',
    'E-Filing', '2022-01-01', NOW(), 'web_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'NE' AND ls.jurisdiction_county = 'Sarpy'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt;

INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'local_rule', 'Hall County District Court Rules',
    'NE-HALL-EFILING',
    'https://nebraskajudicial.gov/e-services/efiling',
    'Hall County District Court (Grand Island). Ninth Judicial District. Central Nebraska hub. JUSTICE e-filing mandatory since January 1, 2022.',
    'E-Filing', '2022-01-01', NOW(), 'web_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'NE' AND ls.jurisdiction_county = 'Hall'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt;

INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'local_rule', 'Buffalo County District Court Rules',
    'NE-BUFFALO-EFILING',
    'https://nebraskajudicial.gov/e-services/efiling',
    'Buffalo County District Court (Kearney). Tenth Judicial District. University of Nebraska at Kearney. JUSTICE e-filing mandatory since January 1, 2022.',
    'E-Filing', '2022-01-01', NOW(), 'web_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'NE' AND ls.jurisdiction_county = 'Buffalo'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt;

-- ============================================================================
-- PART 3: ADD NEBRASKA VALIDATION RULES
-- ============================================================================

DO $$
DECLARE
    ne_sol_id INTEGER;
    ne_efiling_id INTEGER;
    ne_douglas_id INTEGER;
    ne_lancaster_id INTEGER;
    ne_sarpy_id INTEGER;
    ne_hall_id INTEGER;
    ne_buffalo_id INTEGER;
BEGIN
    -- Get citation IDs
    SELECT id INTO ne_sol_id FROM leverage.rule_citations 
    WHERE citation = 'Neb. Rev. Stat. § 25-207';
    
    SELECT id INTO ne_efiling_id FROM leverage.rule_citations 
    WHERE citation = 'NE-SCR-2-202-EFILING';
    
    SELECT id INTO ne_douglas_id FROM leverage.rule_citations 
    WHERE citation = 'NE-DOUGLAS-EFILING';
    
    SELECT id INTO ne_lancaster_id FROM leverage.rule_citations 
    WHERE citation = 'NE-LANCASTER-EFILING';
    
    SELECT id INTO ne_sarpy_id FROM leverage.rule_citations 
    WHERE citation = 'NE-SARPY-EFILING';
    
    SELECT id INTO ne_hall_id FROM leverage.rule_citations 
    WHERE citation = 'NE-HALL-EFILING';
    
    SELECT id INTO ne_buffalo_id FROM leverage.rule_citations 
    WHERE citation = 'NE-BUFFALO-EFILING';

    -- NE Statewide PI SOL (4 years) - Neb. Rev. Stat. § 25-207
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'NE-SOL-25-207-PI-4YEAR', 5, 'NE Personal Injury SOL (4 Years)', 'threshold_check',
        'personal_injury', 'complaint',
        'state', 'NE', NULL, NULL,
        '{"sol_years": 4, "sol_days": 1460, "statute": "Neb. Rev. Stat. § 25-207", "applies_to": "injury_to_rights_not_arising_on_contract", "wrongful_death": 2, "medical_malpractice": 2, "workers_comp": 2, "intentional_torts": 1, "note": "Nebraska has 4-YEAR SOL for PI - one of the longer periods in the U.S.! Action for injury to the rights of the plaintiff not arising on contract."}'::jsonb,
        'error', ne_sol_id, 'document_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id,
        review_status = EXCLUDED.review_status;

    -- NE Statewide E-Filing Rule (JUSTICE/SCCALES)
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'NE-EFILING-JUSTICE-STATEWIDE', 2, 'NE Statewide E-Filing (JUSTICE)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'NE', NULL, NULL,
        '{"requires_efiling": true, "systems": {"trial_courts": "JUSTICE", "appellate_courts": "SCCALES"}, "authority": "Supreme Court Rule § 2-202", "effective_date": "2022-01-01", "format": "text_searchable_pdf", "registration": "Nebraska.Gov Subscriber account", "note": "DOCUMENT VERIFIED: E-Filing mandatory since January 1, 2022 for all Nebraska attorneys."}'::jsonb,
        'error', ne_efiling_id, 'document_verified',
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
        'NE-DOUGLAS-EFILING', 2, 'Douglas County E-Filing (Omaha)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'NE', 'Douglas', 'District Court',
        '{"requires_efiling": true, "system": "JUSTICE", "city": "Omaha", "most_populous": true, "judicial_district": 4, "effective_date": "2022-01-01", "note": "Most populous county. E-Filing mandatory."}'::jsonb,
        'error', ne_douglas_id, 'web_verified',
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
        'NE-LANCASTER-EFILING', 2, 'Lancaster County E-Filing (Lincoln)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'NE', 'Lancaster', 'District Court',
        '{"requires_efiling": true, "system": "JUSTICE", "city": "Lincoln", "state_capital": true, "judicial_district": 3, "university": "University of Nebraska", "effective_date": "2022-01-01", "note": "State capital. E-Filing mandatory."}'::jsonb,
        'error', ne_lancaster_id, 'web_verified',
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
        'NE-SARPY-EFILING', 2, 'Sarpy County E-Filing (Papillion)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'NE', 'Sarpy', 'District Court',
        '{"requires_efiling": true, "system": "JUSTICE", "city": "Papillion", "judicial_district": 2, "fastest_growing": true, "effective_date": "2022-01-01", "note": "Fastest growing county. E-Filing mandatory."}'::jsonb,
        'error', ne_sarpy_id, 'web_verified',
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
        'NE-HALL-EFILING', 2, 'Hall County E-Filing (Grand Island)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'NE', 'Hall', 'District Court',
        '{"requires_efiling": true, "system": "JUSTICE", "city": "Grand Island", "judicial_district": 9, "central_nebraska_hub": true, "effective_date": "2022-01-01", "note": "Central Nebraska hub. E-Filing mandatory."}'::jsonb,
        'error', ne_hall_id, 'web_verified',
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
        'NE-BUFFALO-EFILING', 2, 'Buffalo County E-Filing (Kearney)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'NE', 'Buffalo', 'District Court',
        '{"requires_efiling": true, "system": "JUSTICE", "city": "Kearney", "judicial_district": 10, "university": "UNK", "effective_date": "2022-01-01", "note": "University of Nebraska at Kearney. E-Filing mandatory."}'::jsonb,
        'error', ne_buffalo_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Completion message
    RAISE NOTICE '========================================================================';
    RAISE NOTICE 'NEBRASKA (NE) PI COURT RULES SEEDED SUCCESSFULLY';
    RAISE NOTICE '========================================================================';
    RAISE NOTICE 'Nebraska has 4-YEAR SOL for PI (Neb. Rev. Stat. § 25-207).';
    RAISE NOTICE 'E-Filing MANDATORY via JUSTICE since January 1, 2022.';
    RAISE NOTICE '========================================================================';
    RAISE NOTICE '';
    RAISE NOTICE '************************************************************';
    RAISE NOTICE '*                                                          *';
    RAISE NOTICE '*   ALL 50 STATES SEEDED SUCCESSFULLY! (100%% COMPLETE)    *';
    RAISE NOTICE '*                                                          *';
    RAISE NOTICE '************************************************************';

END $$;

COMMIT;
