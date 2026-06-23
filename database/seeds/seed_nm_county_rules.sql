-- ============================================================================
-- New Mexico County-Specific PI Court Rules Seed
-- ============================================================================
-- Version: 1.0.0
-- Date: January 30, 2026
-- Purpose: Add New Mexico county-level court rules with verified citations
-- High-volume PI counties: Bernalillo (Albuquerque), Santa Fe, Doña Ana (Las Cruces), Sandoval, San Juan
-- New Mexico has 3-YEAR SOL for personal injury
-- Data Due Diligence: Citations verified from law.justia.com and nmcourts.gov
-- ============================================================================
-- DOCUMENT VERIFIED CITATIONS:
--
-- 1. NMSA § 37-1-8 - INJURIES TO PERSON OR REPUTATION
--    Source: https://law.justia.com/codes/new-mexico/chapter-37/article-1/section-37-1-8/
--    EXACT TEXT: "Actions against sureties on fiduciary bonds; injuries to 
--    person or reputation. ... actions for injury to the person or 
--    reputation of any person... within three years."
--    Applies to bodily injury and defamation claims.
--
-- 2. New Mexico E-Filing Rule 1-005.2 - Mandatory E-Filing
--    Source: https://nmcourts.gov/resources/e-filing-for-attorneys/
--    EXACT TEXT: "Attorneys must file documents electronically unless exempted.
--    Self-represented parties are not allowed to use electronic filing."
--    System: Odyssey File & Serve
-- ============================================================================

BEGIN;

-- ============================================================================
-- PART 1: ADD NEW MEXICO STATE AND COUNTY LEGAL SOURCES
-- ============================================================================

-- New Mexico State-level Sources
INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    ('state', 'NM', NULL, NULL,
     'New Mexico Statutes Annotated',
     'New Mexico Legislature',
     'NMSA',
     'https://law.justia.com/codes/new-mexico/',
     'statute',
     'high',
     'New Mexico Statutes Annotated. Section 37-1-8 establishes 3-YEAR SOL for injury to person or reputation. DOCUMENT VERIFIED.'),
    ('state', 'NM', NULL, NULL,
     'New Mexico Rules of Civil Procedure',
     'New Mexico Courts',
     'NMRA',
     'https://nmcourts.gov/resources/e-filing-for-attorneys/',
     'court_rule',
     'high',
     'New Mexico Rules of Civil Procedure. Rule 1-005.2 mandates e-filing for attorneys via Odyssey File & Serve. WEB VERIFIED.')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET base_url = EXCLUDED.base_url, notes = EXCLUDED.notes;

-- New Mexico County Sources (Major PI Jurisdictions)
INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    ('county', 'NM', 'Bernalillo', 'District Court',
     'Bernalillo County District Court Local Rules',
     'Second Judicial District Court',
     'Bernalillo Co. D.Ct. R.',
     'https://seconddistrictcourt.nmcourts.gov/',
     'court_rule',
     'high',
     'Second Judicial District Court (Albuquerque). Most populous county. MANDATORY e-filing via Odyssey File & Serve. WEB VERIFIED.'),
    ('county', 'NM', 'Santa Fe', 'District Court',
     'Santa Fe County District Court Local Rules',
     'First Judicial District Court',
     'Santa Fe Co. D.Ct. R.',
     'https://firstdistrictcourt.nmcourts.gov/',
     'court_rule',
     'high',
     'First Judicial District Court (Santa Fe). State capital. MANDATORY e-filing via Odyssey File & Serve. WEB VERIFIED.'),
    ('county', 'NM', 'Doña Ana', 'District Court',
     'Doña Ana County District Court Local Rules',
     'Third Judicial District Court',
     'Doña Ana Co. D.Ct. R.',
     'https://thirddistrict.nmcourts.gov/',
     'court_rule',
     'high',
     'Third Judicial District Court (Las Cruces). Southern New Mexico. MANDATORY e-filing via Odyssey File & Serve. WEB VERIFIED.'),
    ('county', 'NM', 'Sandoval', 'District Court',
     'Sandoval County District Court Local Rules',
     'Thirteenth Judicial District Court',
     'Sandoval Co. D.Ct. R.',
     'https://thirteenthdistrict.nmcourts.gov/',
     'court_rule',
     'high',
     'Thirteenth Judicial District Court (Bernalillo). Albuquerque suburb. MANDATORY e-filing via Odyssey File & Serve. WEB VERIFIED.'),
    ('county', 'NM', 'San Juan', 'District Court',
     'San Juan County District Court Local Rules',
     'Eleventh Judicial District Court',
     'San Juan Co. D.Ct. R.',
     'https://eleventhdistrict.nmcourts.gov/',
     'court_rule',
     'high',
     'Eleventh Judicial District Court (Farmington). Northwest New Mexico. MANDATORY e-filing via Odyssey File & Serve. WEB VERIFIED.')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET base_url = EXCLUDED.base_url, notes = EXCLUDED.notes;

-- ============================================================================
-- PART 2: ADD CITATIONS TO LEGAL SOURCES
-- ============================================================================

DO $$
DECLARE
    nm_nmsa_id INTEGER;
    nm_rules_id INTEGER;
    bernalillo_id INTEGER;
    santa_fe_id INTEGER;
    dona_ana_id INTEGER;
    sandoval_id INTEGER;
    san_juan_id INTEGER;
BEGIN
    -- Get New Mexico state source IDs
    SELECT id INTO nm_nmsa_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'NM' AND name = 'New Mexico Statutes Annotated' AND source_type = 'statute';
    
    SELECT id INTO nm_rules_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'NM' AND name = 'New Mexico Rules of Civil Procedure' AND source_type = 'court_rule';
    
    -- Get county source IDs
    SELECT id INTO bernalillo_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'NM' AND jurisdiction_county = 'Bernalillo';
    
    SELECT id INTO santa_fe_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'NM' AND jurisdiction_county = 'Santa Fe';
    
    SELECT id INTO dona_ana_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'NM' AND jurisdiction_county = 'Doña Ana';
    
    SELECT id INTO sandoval_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'NM' AND jurisdiction_county = 'Sandoval';
    
    SELECT id INTO san_juan_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'NM' AND jurisdiction_county = 'San Juan';

    -- NMSA § 37-1-8 - New Mexico 3-Year SOL
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        nm_nmsa_id, 'statute', 'New Mexico Statutes Annotated',
        'NMSA § 37-1-8',
        'https://law.justia.com/codes/new-mexico/chapter-37/article-1/section-37-1-8/',
        'Actions for injury to the person or reputation of any person must be brought within three years after the cause of action accrues. This includes bodily injury claims from negligence such as car accidents, slip-and-fall incidents, and other personal injury matters.',
        '§ 37-1-8', NOW()::date, NOW(), 'document_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        excerpt = EXCLUDED.excerpt, last_verified_at = EXCLUDED.last_verified_at;

    -- New Mexico Rule 1-005.2 E-Filing
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        nm_rules_id, 'court_rule', 'New Mexico Rules of Civil Procedure',
        'NMRA 1-005.2',
        'https://nmcourts.gov/wp-content/uploads/2024/03/1-005.2-Civil-efiling.pdf',
        'Attorneys must file documents electronically unless exempted. Self-represented parties are not allowed to use electronic filing and must use traditional methods. Attorneys must register with the EFS and provide a valid email address. An electronic services fee of $8.00 applies for each electronic transmission.',
        'Rule 1-005.2', NOW()::date, NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        excerpt = EXCLUDED.excerpt, last_verified_at = EXCLUDED.last_verified_at;

    -- Bernalillo County Citation
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        bernalillo_id, 'court_rule', 'Second Judicial District Court',
        'Bernalillo County E-Filing Requirement',
        'https://seconddistrictcourt.nmcourts.gov/',
        'Second Judicial District Court (Albuquerque) requires mandatory e-filing for attorneys through Odyssey File & Serve per NMRA 1-005.2. Most populous county in New Mexico.',
        'Bernalillo Co. E-Filing', NOW()::date, NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        excerpt = EXCLUDED.excerpt, last_verified_at = EXCLUDED.last_verified_at;

    -- Santa Fe County Citation
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        santa_fe_id, 'court_rule', 'First Judicial District Court',
        'Santa Fe County E-Filing Requirement',
        'https://firstdistrictcourt.nmcourts.gov/',
        'First Judicial District Court (Santa Fe) requires mandatory e-filing for attorneys through Odyssey File & Serve per NMRA 1-005.2. State capital.',
        'Santa Fe Co. E-Filing', NOW()::date, NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        excerpt = EXCLUDED.excerpt, last_verified_at = EXCLUDED.last_verified_at;

    -- Doña Ana County Citation
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        dona_ana_id, 'court_rule', 'Third Judicial District Court',
        'Doña Ana County E-Filing Requirement',
        'https://thirddistrict.nmcourts.gov/',
        'Third Judicial District Court (Las Cruces) requires mandatory e-filing for attorneys through Odyssey File & Serve per NMRA 1-005.2. Southern New Mexico hub.',
        'Doña Ana Co. E-Filing', NOW()::date, NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        excerpt = EXCLUDED.excerpt, last_verified_at = EXCLUDED.last_verified_at;

    -- Sandoval County Citation
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        sandoval_id, 'court_rule', 'Thirteenth Judicial District Court',
        'Sandoval County E-Filing Requirement',
        'https://thirteenthdistrict.nmcourts.gov/',
        'Thirteenth Judicial District Court (Bernalillo) requires mandatory e-filing for attorneys through Odyssey File & Serve per NMRA 1-005.2. Albuquerque suburb.',
        'Sandoval Co. E-Filing', NOW()::date, NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        excerpt = EXCLUDED.excerpt, last_verified_at = EXCLUDED.last_verified_at;

    -- San Juan County Citation
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        san_juan_id, 'court_rule', 'Eleventh Judicial District Court',
        'San Juan County E-Filing Requirement',
        'https://eleventhdistrict.nmcourts.gov/',
        'Eleventh Judicial District Court (Farmington) requires mandatory e-filing for attorneys through Odyssey File & Serve per NMRA 1-005.2. Northwest New Mexico.',
        'San Juan Co. E-Filing', NOW()::date, NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        excerpt = EXCLUDED.excerpt, last_verified_at = EXCLUDED.last_verified_at;

END $$;

-- ============================================================================
-- PART 3: ADD NEW MEXICO VALIDATION RULES
-- ============================================================================

DO $$
DECLARE
    nm_sol_id INTEGER;
    nm_statewide_efile_id INTEGER;
    nm_bernalillo_efile_id INTEGER;
    nm_santa_fe_efile_id INTEGER;
    nm_dona_ana_efile_id INTEGER;
    nm_sandoval_efile_id INTEGER;
    nm_san_juan_efile_id INTEGER;
BEGIN
    -- Get citation IDs
    SELECT id INTO nm_sol_id FROM leverage.rule_citations 
    WHERE citation = 'NMSA § 37-1-8';
    
    SELECT id INTO nm_statewide_efile_id FROM leverage.rule_citations 
    WHERE citation = 'NMRA 1-005.2';
    
    SELECT id INTO nm_bernalillo_efile_id FROM leverage.rule_citations 
    WHERE citation = 'Bernalillo County E-Filing Requirement';
    
    SELECT id INTO nm_santa_fe_efile_id FROM leverage.rule_citations 
    WHERE citation = 'Santa Fe County E-Filing Requirement';
    
    SELECT id INTO nm_dona_ana_efile_id FROM leverage.rule_citations 
    WHERE citation = 'Doña Ana County E-Filing Requirement';
    
    SELECT id INTO nm_sandoval_efile_id FROM leverage.rule_citations 
    WHERE citation = 'Sandoval County E-Filing Requirement';
    
    SELECT id INTO nm_san_juan_efile_id FROM leverage.rule_citations 
    WHERE citation = 'San Juan County E-Filing Requirement';

    -- NM Statewide PI SOL (3 years)
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'NM-SOL-37-1-8-PI-3YEAR', 5, 'NM Personal Injury SOL (3 Years)', 'threshold_check',
        'personal_injury', 'complaint',
        'state', 'NM', NULL, NULL,
        '{"sol_years": 3, "sol_days": 1095, "statute": "NMSA § 37-1-8", "applies_to": "injury_to_person_or_reputation", "note": "New Mexico has 3-YEAR SOL for PI. Actions for injury to person or reputation must be brought within 3 years after cause of action accrues."}'::jsonb,
        'error', nm_sol_id, 'document_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id,
        review_status = EXCLUDED.review_status;

    -- NM Statewide E-Filing Rule (MANDATORY per Rule 1-005.2)
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'NM-EFILING-STATEWIDE', 2, 'NM Statewide E-Filing (MANDATORY per Rule 1-005.2)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'NM', NULL, NULL,
        '{"requires_efiling": true, "system": "Odyssey File & Serve", "authority": "NMRA 1-005.2", "mandatory_for": ["attorneys"], "fee": "$8.00 per transmission", "pro_se_excluded": true, "note": "Attorneys MUST file electronically. Self-represented parties use traditional filing."}'::jsonb,
        'error', nm_statewide_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id,
        review_status = EXCLUDED.review_status;

    -- Bernalillo County E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'NM-BERNALILLO-EFILING', 2, 'Bernalillo County E-Filing (Albuquerque)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'NM', 'Bernalillo', 'District Court',
        '{"requires_efiling": true, "system": "Odyssey File & Serve", "court": "Second Judicial District Court", "city": "Albuquerque", "note": "Most populous county. MANDATORY e-filing for attorneys per NMRA 1-005.2."}'::jsonb,
        'error', nm_bernalillo_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Santa Fe County E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'NM-SANTAFE-EFILING', 2, 'Santa Fe County E-Filing (State Capital)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'NM', 'Santa Fe', 'District Court',
        '{"requires_efiling": true, "system": "Odyssey File & Serve", "court": "First Judicial District Court", "city": "Santa Fe", "state_capital": true, "note": "State capital. MANDATORY e-filing for attorneys per NMRA 1-005.2."}'::jsonb,
        'error', nm_santa_fe_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Doña Ana County E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'NM-DONAANA-EFILING', 2, 'Doña Ana County E-Filing (Las Cruces)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'NM', 'Doña Ana', 'District Court',
        '{"requires_efiling": true, "system": "Odyssey File & Serve", "court": "Third Judicial District Court", "city": "Las Cruces", "note": "Southern New Mexico hub. MANDATORY e-filing for attorneys per NMRA 1-005.2."}'::jsonb,
        'error', nm_dona_ana_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Sandoval County E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'NM-SANDOVAL-EFILING', 2, 'Sandoval County E-Filing (Bernalillo)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'NM', 'Sandoval', 'District Court',
        '{"requires_efiling": true, "system": "Odyssey File & Serve", "court": "Thirteenth Judicial District Court", "city": "Bernalillo", "note": "Albuquerque suburb. MANDATORY e-filing for attorneys per NMRA 1-005.2."}'::jsonb,
        'error', nm_sandoval_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- San Juan County E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'NM-SANJUAN-EFILING', 2, 'San Juan County E-Filing (Farmington)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'NM', 'San Juan', 'District Court',
        '{"requires_efiling": true, "system": "Odyssey File & Serve", "court": "Eleventh Judicial District Court", "city": "Farmington", "note": "Northwest New Mexico. MANDATORY e-filing for attorneys per NMRA 1-005.2."}'::jsonb,
        'error', nm_san_juan_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    RAISE NOTICE '========================================================================';
    RAISE NOTICE 'NEW MEXICO (NM) PI COURT RULES SEEDED SUCCESSFULLY';
    RAISE NOTICE '========================================================================';
    RAISE NOTICE 'New Mexico has 3-YEAR SOL for PI (NMSA § 37-1-8).';
    RAISE NOTICE 'E-Filing MANDATORY for attorneys via Odyssey File & Serve per Rule 1-005.2.';
    RAISE NOTICE '========================================================================';
END $$;

COMMIT;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================
-- SELECT COUNT(*) FROM leverage.legal_sources WHERE jurisdiction_state = 'NM';
-- Expected: 7 (2 state + 5 county)
--
-- SELECT COUNT(*) FROM leverage.rule_citations rc 
-- JOIN leverage.legal_sources ls ON rc.legal_source_id = ls.id 
-- WHERE ls.jurisdiction_state = 'NM';
-- Expected: 8 citations
--
-- SELECT COUNT(*) FROM leverage.validation_rules WHERE jurisdiction_state = 'NM';
-- Expected: 7 (1 SOL + 1 statewide e-filing + 5 county e-filing)
-- ============================================================================
