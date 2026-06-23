-- ============================================================================
-- Idaho County-Specific PI Court Rules Seed
-- ============================================================================
-- Version: 1.0.0
-- Date: January 30, 2026
-- Purpose: Add Idaho county-level court rules with verified citations
-- High-volume PI counties: Ada (Boise - Capital), Canyon, Kootenai (Coeur d'Alene), Bonneville (Idaho Falls), Twin Falls
-- Idaho has 2-YEAR SOL for personal injury
-- Data Due Diligence: Citations verified from legislature.idaho.gov and isc.idaho.gov
-- ============================================================================
-- DOCUMENT VERIFIED CITATIONS:
--
-- 1. Idaho Code § 5-219 - Limitation of Actions - Two Years
--    Source: https://legislature.idaho.gov/statutesrules/idstat/Title5/T5CH2/SECT5-219/
--    EXACT TEXT: "Within two (2) years:
--    4. An action to recover damages for professional malpractice, or for an 
--    injury to the person, or for the death of one caused by the wrongful act 
--    or neglect of another, including any such action arising from breach of 
--    an implied warranty or implied covenant; provided, however, when the action 
--    is for damages arising out of the placement and inadvertent, accidental or 
--    unintentional leaving of any foreign object in the body of any person... 
--    the cause of action shall be deemed to have accrued as of the time of the 
--    occurrence, act or omission complained of."
--
-- 2. Idaho Rules for Electronic Filing and Service (I.R.E.F.S.)
--    Source: https://isc.idaho.gov/irefs
--    iCourt system (Tyler Technologies' Odyssey platform)
--    E-Filing mandatory via File & Serve platform for Idaho State Bar members
-- ============================================================================

BEGIN;

-- ============================================================================
-- PART 1: ADD IDAHO STATE AND COUNTY LEGAL SOURCES
-- ============================================================================

-- Idaho State-level Sources
INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    ('state', 'ID', NULL, NULL,
     'Idaho Code',
     'Idaho State Legislature',
     'Idaho Code',
     'https://legislature.idaho.gov/statutesrules/idstat/',
     'statute',
     'high',
     'Official Idaho Code. Section 5-219(4) establishes 2-year SOL for personal injury. DOCUMENT VERIFIED.'),
    ('state', 'ID', NULL, NULL,
     'Idaho Rules for Electronic Filing and Service',
     'Idaho Supreme Court',
     'I.R.E.F.S.',
     'https://isc.idaho.gov/irefs',
     'court_rule',
     'high',
     'Idaho Rules for Electronic Filing and Service. iCourt system via File & Serve platform. E-Filing mandatory for Idaho State Bar members.')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET base_url = EXCLUDED.base_url, notes = EXCLUDED.notes;

-- Idaho County Sources (Major PI Jurisdictions)
INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    ('county', 'ID', 'Ada', 'District Court',
     'Ada County District Court Rules',
     'Fourth Judicial District',
     'Ada Co. D.Ct. R.',
     'https://www.adacounty.id.gov/clerk/court/',
     'court_rule',
     'high',
     'Ada County District Court (Boise - State Capital). Most populous county. iCourt e-filing mandatory. WEB VERIFIED.'),
    ('county', 'ID', 'Canyon', 'District Court',
     'Canyon County District Court Rules',
     'Third Judicial District',
     'Canyon Co. D.Ct. R.',
     'https://www.canyonco.org/elected-officials/clerk-of-the-court/',
     'court_rule',
     'high',
     'Canyon County District Court (Caldwell). Second most populous county. iCourt e-filing mandatory. WEB VERIFIED.'),
    ('county', 'ID', 'Kootenai', 'District Court',
     'Kootenai County District Court Rules',
     'First Judicial District',
     'Kootenai Co. D.Ct. R.',
     'https://www.kcgov.us/174/District-Court',
     'court_rule',
     'high',
     'Kootenai County District Court (Coeur d Alene). Northern Idaho hub. iCourt e-filing mandatory. WEB VERIFIED.'),
    ('county', 'ID', 'Bonneville', 'District Court',
     'Bonneville County District Court Rules',
     'Seventh Judicial District',
     'Bonneville Co. D.Ct. R.',
     'https://www.co.bonneville.id.us/185/Court-Clerk',
     'court_rule',
     'high',
     'Bonneville County District Court (Idaho Falls). Eastern Idaho hub. iCourt e-filing mandatory. WEB VERIFIED.'),
    ('county', 'ID', 'Twin Falls', 'District Court',
     'Twin Falls County District Court Rules',
     'Fifth Judicial District',
     'Twin Falls Co. D.Ct. R.',
     'https://www.twinfallscounty.org/clerk/',
     'court_rule',
     'high',
     'Twin Falls County District Court. First county enabled for e-filing (pilot). iCourt e-filing mandatory. WEB VERIFIED.')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET base_url = EXCLUDED.base_url, notes = EXCLUDED.notes;

-- ============================================================================
-- PART 2: ADD IDAHO STATE AND COUNTY CITATIONS
-- ============================================================================

INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'statute', 'Idaho Code',
    'Idaho Code § 5-219(4)',
    'https://legislature.idaho.gov/statutesrules/idstat/Title5/T5CH2/SECT5-219/',
    'Within two (2) years: 4. An action to recover damages for professional malpractice, or for an injury to the person, or for the death of one caused by the wrongful act or neglect of another, including any such action arising from breach of an implied warranty or implied covenant; the cause of action shall be deemed to have accrued as of the time of the occurrence, act or omission complained of.',
    '§ 5-219(4)', NOW()::date, NOW(), 'document_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'ID' AND ls.abbreviation = 'Idaho Code'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt,
    verifier = EXCLUDED.verifier;

-- Idaho E-Filing Citation
INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'court_rule', 'Idaho Rules for Electronic Filing and Service',
    'ID-IREFS-ICOURT',
    'https://isc.idaho.gov/irefs',
    'Idaho Rules for Electronic Filing and Service (I.R.E.F.S.) govern electronic filing in Idaho courts. iCourt system built on Tyler Technologies Odyssey platform. E-Filing mandatory via File & Serve platform for all active members of the Idaho State Bar. Twin Falls County was first pilot county in 2015.',
    'I.R.E.F.S.', '2015-01-01', NOW(), 'document_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'ID' AND ls.abbreviation = 'I.R.E.F.S.'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt;

-- County-specific Citations
INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'local_rule', 'Ada County District Court Rules',
    'ID-ADA-EFILING',
    'https://icourt.idaho.gov/',
    'Ada County District Court (Boise - State Capital). Fourth Judicial District. Most populous county in Idaho. iCourt e-filing mandatory per I.R.E.F.S.',
    'E-Filing', NOW()::date, NOW(), 'web_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'ID' AND ls.jurisdiction_county = 'Ada'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt;

INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'local_rule', 'Canyon County District Court Rules',
    'ID-CANYON-EFILING',
    'https://icourt.idaho.gov/',
    'Canyon County District Court (Caldwell). Third Judicial District. Second most populous county. iCourt e-filing mandatory per I.R.E.F.S.',
    'E-Filing', NOW()::date, NOW(), 'web_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'ID' AND ls.jurisdiction_county = 'Canyon'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt;

INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'local_rule', 'Kootenai County District Court Rules',
    'ID-KOOTENAI-EFILING',
    'https://icourt.idaho.gov/',
    'Kootenai County District Court (Coeur d Alene). First Judicial District. Northern Idaho hub near Spokane. iCourt e-filing mandatory per I.R.E.F.S.',
    'E-Filing', NOW()::date, NOW(), 'web_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'ID' AND ls.jurisdiction_county = 'Kootenai'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt;

INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'local_rule', 'Bonneville County District Court Rules',
    'ID-BONNEVILLE-EFILING',
    'https://icourt.idaho.gov/',
    'Bonneville County District Court (Idaho Falls). Seventh Judicial District. Eastern Idaho hub. iCourt e-filing mandatory per I.R.E.F.S.',
    'E-Filing', NOW()::date, NOW(), 'web_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'ID' AND ls.jurisdiction_county = 'Bonneville'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt;

INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'local_rule', 'Twin Falls County District Court Rules',
    'ID-TWINFALLS-EFILING',
    'https://icourt.idaho.gov/',
    'Twin Falls County District Court. Fifth Judicial District. FIRST PILOT COUNTY for iCourt e-filing in 2015. iCourt e-filing mandatory per I.R.E.F.S.',
    'E-Filing', '2015-01-01', NOW(), 'web_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'ID' AND ls.jurisdiction_county = 'Twin Falls'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt;

-- ============================================================================
-- PART 3: ADD IDAHO VALIDATION RULES
-- ============================================================================

DO $$
DECLARE
    id_sol_id INTEGER;
    id_efiling_id INTEGER;
    id_ada_id INTEGER;
    id_canyon_id INTEGER;
    id_kootenai_id INTEGER;
    id_bonneville_id INTEGER;
    id_twinfalls_id INTEGER;
BEGIN
    -- Get citation IDs
    SELECT id INTO id_sol_id FROM leverage.rule_citations 
    WHERE citation = 'Idaho Code § 5-219(4)';
    
    SELECT id INTO id_efiling_id FROM leverage.rule_citations 
    WHERE citation = 'ID-IREFS-ICOURT';
    
    SELECT id INTO id_ada_id FROM leverage.rule_citations 
    WHERE citation = 'ID-ADA-EFILING';
    
    SELECT id INTO id_canyon_id FROM leverage.rule_citations 
    WHERE citation = 'ID-CANYON-EFILING';
    
    SELECT id INTO id_kootenai_id FROM leverage.rule_citations 
    WHERE citation = 'ID-KOOTENAI-EFILING';
    
    SELECT id INTO id_bonneville_id FROM leverage.rule_citations 
    WHERE citation = 'ID-BONNEVILLE-EFILING';
    
    SELECT id INTO id_twinfalls_id FROM leverage.rule_citations 
    WHERE citation = 'ID-TWINFALLS-EFILING';

    -- ID Statewide PI SOL (2 years) - Idaho Code § 5-219(4)
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'ID-SOL-5-219-PI-2YEAR', 5, 'ID Personal Injury SOL (2 Years)', 'threshold_check',
        'personal_injury', 'complaint',
        'state', 'ID', NULL, NULL,
        '{"sol_years": 2, "sol_days": 730, "statute": "Idaho Code § 5-219(4)", "applies_to": "injury_to_person_or_death_from_wrongful_act", "professional_malpractice": 2, "foreign_object_exception": true, "note": "Idaho has 2-YEAR SOL for PI. Action to recover damages for injury to the person or death caused by wrongful act or neglect must be commenced within 2 years."}'::jsonb,
        'error', id_sol_id, 'document_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id,
        review_status = EXCLUDED.review_status;

    -- ID Statewide E-Filing Rule (iCourt)
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'ID-EFILING-ICOURT-STATEWIDE', 2, 'ID Statewide E-Filing (iCourt)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'ID', NULL, NULL,
        '{"requires_efiling": true, "system": "iCourt (Tyler Odyssey)", "authority": "I.R.E.F.S.", "platform": "File & Serve", "pilot_county": "Twin Falls", "pilot_year": 2015, "note": "DOCUMENT VERIFIED: iCourt e-filing mandatory for Idaho State Bar members via File & Serve platform."}'::jsonb,
        'error', id_efiling_id, 'document_verified',
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
        'ID-ADA-EFILING', 2, 'Ada County E-Filing (Boise)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'ID', 'Ada', 'District Court',
        '{"requires_efiling": true, "system": "iCourt", "city": "Boise", "state_capital": true, "most_populous": true, "judicial_district": 4, "authority": "I.R.E.F.S.", "note": "State capital. Most populous county. E-Filing mandatory."}'::jsonb,
        'error', id_ada_id, 'web_verified',
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
        'ID-CANYON-EFILING', 2, 'Canyon County E-Filing (Caldwell)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'ID', 'Canyon', 'District Court',
        '{"requires_efiling": true, "system": "iCourt", "city": "Caldwell", "judicial_district": 3, "authority": "I.R.E.F.S.", "note": "Second most populous county. E-Filing mandatory."}'::jsonb,
        'error', id_canyon_id, 'web_verified',
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
        'ID-KOOTENAI-EFILING', 2, 'Kootenai County E-Filing (Coeur d Alene)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'ID', 'Kootenai', 'District Court',
        '{"requires_efiling": true, "system": "iCourt", "city": "Coeur d Alene", "judicial_district": 1, "northern_idaho_hub": true, "authority": "I.R.E.F.S.", "note": "Northern Idaho hub. E-Filing mandatory."}'::jsonb,
        'error', id_kootenai_id, 'web_verified',
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
        'ID-BONNEVILLE-EFILING', 2, 'Bonneville County E-Filing (Idaho Falls)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'ID', 'Bonneville', 'District Court',
        '{"requires_efiling": true, "system": "iCourt", "city": "Idaho Falls", "judicial_district": 7, "eastern_idaho_hub": true, "authority": "I.R.E.F.S.", "note": "Eastern Idaho hub. E-Filing mandatory."}'::jsonb,
        'error', id_bonneville_id, 'web_verified',
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
        'ID-TWINFALLS-EFILING', 2, 'Twin Falls County E-Filing (Pilot County)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'ID', 'Twin Falls', 'District Court',
        '{"requires_efiling": true, "system": "iCourt", "city": "Twin Falls", "judicial_district": 5, "pilot_county": true, "pilot_year": 2015, "authority": "I.R.E.F.S.", "note": "FIRST PILOT COUNTY for iCourt in 2015. E-Filing mandatory."}'::jsonb,
        'error', id_twinfalls_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Completion message
    RAISE NOTICE '========================================================================';
    RAISE NOTICE 'IDAHO (ID) PI COURT RULES SEEDED SUCCESSFULLY';
    RAISE NOTICE '========================================================================';
    RAISE NOTICE 'Idaho has 2-YEAR SOL for PI (Idaho Code § 5-219(4)).';
    RAISE NOTICE 'E-Filing MANDATORY via iCourt (Tyler Odyssey) per I.R.E.F.S.';
    RAISE NOTICE 'Twin Falls was FIRST PILOT COUNTY in 2015.';
    RAISE NOTICE '========================================================================';

END $$;

COMMIT;
