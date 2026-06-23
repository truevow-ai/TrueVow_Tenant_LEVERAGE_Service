-- ============================================================================
-- Wyoming County-Specific PI Court Rules Seed
-- ============================================================================
-- Version: 1.0.0
-- Date: January 30, 2026
-- Purpose: Add Wyoming county-level court rules with verified citations
-- High-volume PI counties: Laramie (Cheyenne), Natrona (Casper), Sweetwater, Fremont, Campbell
-- Wyoming has 4-YEAR SOL for personal injury (one of the longest in the U.S.)
-- Data Due Diligence: Citations verified from wyoleg.gov and wyocourts.gov
-- ============================================================================
-- DOCUMENT VERIFIED CITATIONS:
--
-- 1. Wyoming Statute § 1-3-105 - Actions Other Than Recovery of Real Property
--    Source: https://law.justia.com/codes/wyoming/title-1/chapter-3/section-1-3-105/
--    EXACT TEXT: "(a) Civil actions other than for the recovery of real property 
--    can only be brought within the following periods after the cause of action 
--    accrues: ... (iv) Within four (4) years, an action for:
--    (A) Trespass upon real property;
--    (B) The recovery of personal property or for taking, detaining or injuring 
--        personal property;
--    (C) An injury to the rights of the plaintiff, not arising on contract and 
--        not herein enumerated;
--    (D) For relief on the ground of fraud."
--
-- 2. Wyoming Rules for Electronic Filing and Service
--    Source: https://www.wyocourts.gov/court-rules/wyoming-rules-for-electronic-filing-and-service/
--    Wyoming Supreme Court Order adopting rules effective April 5, 2025
--    E-Filing mandatory in trial courts through Electronic Filing System (EFS)
-- ============================================================================

BEGIN;

-- ============================================================================
-- PART 1: ADD WYOMING STATE AND COUNTY LEGAL SOURCES
-- ============================================================================

-- Wyoming State-level Sources
INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    ('state', 'WY', NULL, NULL,
     'Wyoming Statutes',
     'Wyoming State Legislature',
     'Wyo. Stat.',
     'https://wyoleg.gov/statutes/',
     'statute',
     'high',
     'Official Wyoming Statutes. Section 1-3-105(a)(iv)(C) establishes 4-year SOL for injury to rights (personal injury). DOCUMENT VERIFIED.'),
    ('state', 'WY', NULL, NULL,
     'Wyoming Rules for Electronic Filing and Service',
     'Wyoming Supreme Court',
     'WY EFS',
     'https://www.wyocourts.gov/court-rules/wyoming-rules-for-electronic-filing-and-service/',
     'court_rule',
     'high',
     'Wyoming Rules for Electronic Filing and Service. E-Filing mandatory effective April 5, 2025 per Supreme Court Order.')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET base_url = EXCLUDED.base_url, notes = EXCLUDED.notes;

-- Wyoming County Sources (Major PI Jurisdictions)
INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    ('county', 'WY', 'Laramie', 'District Court',
     'Laramie County District Court Rules',
     'First Judicial District',
     'Laramie Co. D.Ct. R.',
     'https://www.wyocourts.gov/District-Courts/District-Court-Locations/laramie-county-district-court/',
     'court_rule',
     'high',
     'Laramie County District Court (Cheyenne - State Capital). Most populous county. E-Filing mandatory via EFS. WEB VERIFIED.'),
    ('county', 'WY', 'Natrona', 'District Court',
     'Natrona County District Court Rules',
     'Seventh Judicial District',
     'Natrona Co. D.Ct. R.',
     'https://www.wyocourts.gov/District-Courts/District-Court-Locations/natrona-county-district-court/',
     'court_rule',
     'high',
     'Natrona County District Court (Casper). Second most populous county. E-Filing mandatory via EFS. WEB VERIFIED.'),
    ('county', 'WY', 'Sweetwater', 'District Court',
     'Sweetwater County District Court Rules',
     'Third Judicial District',
     'Sweetwater Co. D.Ct. R.',
     'https://www.wyocourts.gov/District-Courts/District-Court-Locations/sweetwater-county-district-court/',
     'court_rule',
     'high',
     'Sweetwater County District Court (Green River). E-Filing mandatory via EFS. WEB VERIFIED.'),
    ('county', 'WY', 'Fremont', 'District Court',
     'Fremont County District Court Rules',
     'Ninth Judicial District',
     'Fremont Co. D.Ct. R.',
     'https://www.wyocourts.gov/District-Courts/District-Court-Locations/fremont-county-district-court/',
     'court_rule',
     'high',
     'Fremont County District Court (Lander). E-Filing mandatory via EFS. WEB VERIFIED.'),
    ('county', 'WY', 'Campbell', 'District Court',
     'Campbell County District Court Rules',
     'Sixth Judicial District',
     'Campbell Co. D.Ct. R.',
     'https://www.wyocourts.gov/District-Courts/District-Court-Locations/campbell-county-district-court/',
     'court_rule',
     'high',
     'Campbell County District Court (Gillette). Energy sector hub. E-Filing mandatory via EFS. WEB VERIFIED.')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET base_url = EXCLUDED.base_url, notes = EXCLUDED.notes;

-- ============================================================================
-- PART 2: ADD WYOMING STATE AND COUNTY CITATIONS
-- ============================================================================

INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'statute', 'Wyoming Statutes',
    'Wyo. Stat. § 1-3-105(a)(iv)(C)',
    'https://law.justia.com/codes/wyoming/title-1/chapter-3/section-1-3-105/',
    'Civil actions other than for the recovery of real property can only be brought within the following periods after the cause of action accrues: (iv) Within four (4) years, an action for: (C) An injury to the rights of the plaintiff, not arising on contract and not herein enumerated.',
    '§ 1-3-105(a)(iv)(C)', NOW()::date, NOW(), 'document_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'WY' AND ls.abbreviation = 'Wyo. Stat.'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt,
    verifier = EXCLUDED.verifier;

-- Wyoming EFS E-Filing Citation
INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'court_rule', 'Wyoming Rules for Electronic Filing and Service',
    'WY-EFS-RULES-2025',
    'https://www.wyocourts.gov/court-rules/wyoming-rules-for-electronic-filing-and-service/',
    'Wyoming Supreme Court Order adopting the Wyoming Rules for Electronic Filing and Service, effective April 5, 2025. These rules establish procedures for electronic filing and service in Wyoming trial courts through the Electronic Filing System (EFS). The rules supersede other Wyoming trial court procedural rules regarding electronic filing and service.',
    'EFS Rules', '2025-04-05', NOW(), 'document_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'WY' AND ls.abbreviation = 'WY EFS'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt;

-- County-specific Citations
INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'local_rule', 'Laramie County District Court Rules',
    'WY-LARAMIE-EFILING',
    'https://www.wyocourts.gov/efiling/efiling-district-court/',
    'Laramie County District Court (Cheyenne - State Capital). First Judicial District. Most populous county in Wyoming. E-Filing mandatory via EFS effective April 5, 2025.',
    'E-Filing', '2025-04-05', NOW(), 'web_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'WY' AND ls.jurisdiction_county = 'Laramie'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt;

INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'local_rule', 'Natrona County District Court Rules',
    'WY-NATRONA-EFILING',
    'https://www.wyocourts.gov/efiling/efiling-district-court/',
    'Natrona County District Court (Casper). Seventh Judicial District. Second most populous county. E-Filing mandatory via EFS effective April 5, 2025.',
    'E-Filing', '2025-04-05', NOW(), 'web_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'WY' AND ls.jurisdiction_county = 'Natrona'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt;

INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'local_rule', 'Sweetwater County District Court Rules',
    'WY-SWEETWATER-EFILING',
    'https://www.wyocourts.gov/efiling/efiling-district-court/',
    'Sweetwater County District Court (Green River). Third Judicial District. E-Filing mandatory via EFS effective April 5, 2025.',
    'E-Filing', '2025-04-05', NOW(), 'web_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'WY' AND ls.jurisdiction_county = 'Sweetwater'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt;

INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'local_rule', 'Fremont County District Court Rules',
    'WY-FREMONT-EFILING',
    'https://www.wyocourts.gov/efiling/efiling-district-court/',
    'Fremont County District Court (Lander). Ninth Judicial District. E-Filing mandatory via EFS effective April 5, 2025.',
    'E-Filing', '2025-04-05', NOW(), 'web_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'WY' AND ls.jurisdiction_county = 'Fremont'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt;

INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'local_rule', 'Campbell County District Court Rules',
    'WY-CAMPBELL-EFILING',
    'https://www.wyocourts.gov/efiling/efiling-district-court/',
    'Campbell County District Court (Gillette). Sixth Judicial District. Energy sector hub. E-Filing mandatory via EFS effective April 5, 2025.',
    'E-Filing', '2025-04-05', NOW(), 'web_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'WY' AND ls.jurisdiction_county = 'Campbell'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt;

-- ============================================================================
-- PART 3: ADD WYOMING VALIDATION RULES
-- ============================================================================

DO $$
DECLARE
    wy_sol_id INTEGER;
    wy_efs_id INTEGER;
    wy_laramie_id INTEGER;
    wy_natrona_id INTEGER;
    wy_sweetwater_id INTEGER;
    wy_fremont_id INTEGER;
    wy_campbell_id INTEGER;
BEGIN
    -- Get citation IDs
    SELECT id INTO wy_sol_id FROM leverage.rule_citations 
    WHERE citation = 'Wyo. Stat. § 1-3-105(a)(iv)(C)';
    
    SELECT id INTO wy_efs_id FROM leverage.rule_citations 
    WHERE citation = 'WY-EFS-RULES-2025';
    
    SELECT id INTO wy_laramie_id FROM leverage.rule_citations 
    WHERE citation = 'WY-LARAMIE-EFILING';
    
    SELECT id INTO wy_natrona_id FROM leverage.rule_citations 
    WHERE citation = 'WY-NATRONA-EFILING';
    
    SELECT id INTO wy_sweetwater_id FROM leverage.rule_citations 
    WHERE citation = 'WY-SWEETWATER-EFILING';
    
    SELECT id INTO wy_fremont_id FROM leverage.rule_citations 
    WHERE citation = 'WY-FREMONT-EFILING';
    
    SELECT id INTO wy_campbell_id FROM leverage.rule_citations 
    WHERE citation = 'WY-CAMPBELL-EFILING';

    -- WY Statewide PI SOL (4 years) - Wyo. Stat. § 1-3-105(a)(iv)(C)
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'WY-SOL-1-3-105-PI-4YEAR', 5, 'WY Personal Injury SOL (4 Years)', 'threshold_check',
        'personal_injury', 'complaint',
        'state', 'WY', NULL, NULL,
        '{"sol_years": 4, "sol_days": 1460, "statute": "Wyo. Stat. § 1-3-105(a)(iv)(C)", "applies_to": "injury_to_rights_not_arising_on_contract", "notable": "ONE OF THE LONGEST SOL IN THE U.S.", "note": "Wyoming has 4-YEAR SOL for PI - one of the longest in the nation! Action for injury to the rights of the plaintiff not arising on contract must be brought within 4 years."}'::jsonb,
        'error', wy_sol_id, 'document_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id,
        review_status = EXCLUDED.review_status;

    -- WY Statewide E-Filing Rule (EFS)
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'WY-EFILING-EFS-STATEWIDE', 2, 'WY Statewide E-Filing (EFS)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'WY', NULL, NULL,
        '{"requires_efiling": true, "system": "Wyoming Electronic Filing System (EFS)", "authority": "Wyoming Supreme Court Order", "effective_date": "2025-04-05", "note": "DOCUMENT VERIFIED: Wyoming Rules for Electronic Filing and Service effective April 5, 2025. E-Filing mandatory in trial courts."}'::jsonb,
        'error', wy_efs_id, 'document_verified',
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
        'WY-LARAMIE-EFILING', 2, 'Laramie County E-Filing (Cheyenne)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'WY', 'Laramie', 'District Court',
        '{"requires_efiling": true, "system": "EFS", "city": "Cheyenne", "state_capital": true, "most_populous": true, "judicial_district": 1, "effective_date": "2025-04-05", "note": "State capital. Most populous county. E-Filing mandatory."}'::jsonb,
        'error', wy_laramie_id, 'web_verified',
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
        'WY-NATRONA-EFILING', 2, 'Natrona County E-Filing (Casper)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'WY', 'Natrona', 'District Court',
        '{"requires_efiling": true, "system": "EFS", "city": "Casper", "judicial_district": 7, "effective_date": "2025-04-05", "note": "Second most populous county. E-Filing mandatory."}'::jsonb,
        'error', wy_natrona_id, 'web_verified',
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
        'WY-SWEETWATER-EFILING', 2, 'Sweetwater County E-Filing', 'format_check',
        'personal_injury', 'complaint',
        'state', 'WY', 'Sweetwater', 'District Court',
        '{"requires_efiling": true, "system": "EFS", "city": "Green River", "judicial_district": 3, "effective_date": "2025-04-05", "note": "E-Filing mandatory."}'::jsonb,
        'error', wy_sweetwater_id, 'web_verified',
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
        'WY-FREMONT-EFILING', 2, 'Fremont County E-Filing (Lander)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'WY', 'Fremont', 'District Court',
        '{"requires_efiling": true, "system": "EFS", "city": "Lander", "judicial_district": 9, "effective_date": "2025-04-05", "note": "E-Filing mandatory."}'::jsonb,
        'error', wy_fremont_id, 'web_verified',
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
        'WY-CAMPBELL-EFILING', 2, 'Campbell County E-Filing (Gillette)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'WY', 'Campbell', 'District Court',
        '{"requires_efiling": true, "system": "EFS", "city": "Gillette", "judicial_district": 6, "energy_hub": true, "effective_date": "2025-04-05", "note": "Energy sector hub. E-Filing mandatory."}'::jsonb,
        'error', wy_campbell_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Completion message
    RAISE NOTICE '========================================================================';
    RAISE NOTICE 'WYOMING (WY) PI COURT RULES SEEDED SUCCESSFULLY';
    RAISE NOTICE '========================================================================';
    RAISE NOTICE 'Wyoming has 4-YEAR SOL for PI (Wyo. Stat. § 1-3-105) - ONE OF THE LONGEST!';
    RAISE NOTICE 'E-Filing MANDATORY via EFS effective April 5, 2025.';
    RAISE NOTICE '========================================================================';

END $$;

COMMIT;
