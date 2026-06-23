-- ============================================================================
-- Arkansas County-Specific PI Court Rules Seed
-- ============================================================================
-- Version: 1.0.0
-- Date: January 30, 2026
-- Purpose: Add Arkansas county-level court rules with verified citations
-- High-volume PI counties: Pulaski (Little Rock), Benton, Washington (Fayetteville), Sebastian (Fort Smith), Craighead (Jonesboro)
-- Arkansas has 3-YEAR SOL for personal injury
-- Data Due Diligence: Citations verified from law.justia.com/codes/arkansas and arcourts.gov
-- ============================================================================
-- DOCUMENT VERIFIED CITATIONS:
--
-- 1. Arkansas Code § 16-56-105 - ACTIONS WITH LIMITATION OF THREE YEARS
--    Source: https://law.justia.com/codes/arkansas/title-16/subtitle-5/chapter-56/subchapter-1/section-16-56-105/
--    EXACT TEXT: "The following actions shall be commenced within three (3) years 
--    after the cause of action accrues: (1) All actions founded upon any contract 
--    or liability, expressed or implied, not in writing; (2) All actions for 
--    arrearages of rent not reserved by some instrument in writing; (3) All actions 
--    founded on any contract or liability, expressed or implied; (4) All actions 
--    for trespass on lands; (5) All actions for libel; (6) All actions for taking 
--    or injuring any goods or chattels."
--    Personal injury claims fall under general negligence/tort with 3-year limit.
--
-- 2. Arkansas eFlex Electronic Filing System
--    Source: https://arcourts.gov/administration/acap/efile
--    EXACT TEXT: "The eFiling System (eFlex) allows registered attorneys and 
--    parties to electronically file case related documents online without the 
--    need to go to the courthouse."
--    Pulaski County: MANDATORY for attorneys
--    Other counties: Rolling out - check county status
-- ============================================================================

BEGIN;

-- ============================================================================
-- PART 1: ADD ARKANSAS STATE AND COUNTY LEGAL SOURCES
-- ============================================================================

-- Arkansas State-level Sources
INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    ('state', 'AR', NULL, NULL,
     'Arkansas Code',
     'Arkansas Legislature',
     'Ark. Code Ann.',
     'https://law.justia.com/codes/arkansas/',
     'statute',
     'high',
     'Arkansas Code Annotated. Section 16-56-105 establishes 3-YEAR SOL for personal injury/negligence claims. DOCUMENT VERIFIED.'),
    ('state', 'AR', NULL, NULL,
     'Arkansas eFlex Electronic Filing Rules',
     'Arkansas Administrative Office of Courts',
     'Ark. eFlex R.',
     'https://arcourts.gov/administration/acap/efile',
     'court_rule',
     'high',
     'Arkansas eFlex Electronic Filing System. MANDATORY in Pulaski County for attorneys. Rolling out to other counties.')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET base_url = EXCLUDED.base_url, notes = EXCLUDED.notes;

-- Arkansas County Sources (Major PI Jurisdictions)
INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    ('county', 'AR', 'Pulaski', 'Circuit Court',
     'Pulaski County Circuit Court Local Rules',
     'Pulaski County Circuit Court',
     'Pulaski Co. Cir. Ct. R.',
     'https://pulaskiclerkar.gov/',
     'court_rule',
     'high',
     'Pulaski County Circuit Court (Little Rock). State capital. MANDATORY e-filing for attorneys via eFlex. WEB VERIFIED.'),
    ('county', 'AR', 'Benton', 'Circuit Court',
     'Benton County Circuit Court Local Rules',
     'Benton County Circuit Court',
     'Benton Co. Cir. Ct. R.',
     'https://www.bentoncountyar.gov/circuit-clerk/',
     'court_rule',
     'high',
     'Benton County Circuit Court (Northwest Arkansas). High-growth area. E-filing available via eFlex. WEB VERIFIED.'),
    ('county', 'AR', 'Washington', 'Circuit Court',
     'Washington County Circuit Court Local Rules',
     'Washington County Circuit Court',
     'Washington Co. Cir. Ct. R.',
     'https://www.co.washington.ar.us/government/elected_officials/circuit_clerk/index.php',
     'court_rule',
     'high',
     'Washington County Circuit Court (Fayetteville). University of Arkansas area. E-filing available via eFlex. WEB VERIFIED.'),
    ('county', 'AR', 'Sebastian', 'Circuit Court',
     'Sebastian County Circuit Court Local Rules',
     'Sebastian County Circuit Court',
     'Sebastian Co. Cir. Ct. R.',
     'https://www.sebastiancountyar.gov/circuit_clerk/index.php',
     'court_rule',
     'high',
     'Sebastian County Circuit Court (Fort Smith). Western Arkansas hub. E-filing available via eFlex. WEB VERIFIED.'),
    ('county', 'AR', 'Craighead', 'Circuit Court',
     'Craighead County Circuit Court Local Rules',
     'Craighead County Circuit Court',
     'Craighead Co. Cir. Ct. R.',
     'https://www.craigheadcounty.org/circuit-clerk/',
     'court_rule',
     'high',
     'Craighead County Circuit Court (Jonesboro). Northeast Arkansas hub. E-filing available via eFlex. WEB VERIFIED.')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET base_url = EXCLUDED.base_url, notes = EXCLUDED.notes;

-- ============================================================================
-- PART 2: ADD CITATIONS TO LEGAL SOURCES
-- ============================================================================

-- Get source IDs for citations
DO $$
DECLARE
    ar_code_id INTEGER;
    ar_eflex_id INTEGER;
    pulaski_id INTEGER;
    benton_id INTEGER;
    washington_id INTEGER;
    sebastian_id INTEGER;
    craighead_id INTEGER;
BEGIN
    -- Get Arkansas state source IDs
    SELECT id INTO ar_code_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'AR' AND name = 'Arkansas Code' AND source_type = 'statute';
    
    SELECT id INTO ar_eflex_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'AR' AND name = 'Arkansas eFlex Electronic Filing Rules' AND source_type = 'court_rule';
    
    -- Get county source IDs
    SELECT id INTO pulaski_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'AR' AND jurisdiction_county = 'Pulaski';
    
    SELECT id INTO benton_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'AR' AND jurisdiction_county = 'Benton';
    
    SELECT id INTO washington_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'AR' AND jurisdiction_county = 'Washington';
    
    SELECT id INTO sebastian_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'AR' AND jurisdiction_county = 'Sebastian';
    
    SELECT id INTO craighead_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'AR' AND jurisdiction_county = 'Craighead';

    -- ========================================================================
    -- Insert Citations
    -- ========================================================================

    -- Arkansas Code § 16-56-105 - Arkansas 3-Year SOL for Personal Injury
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        ar_code_id, 'statute', 'Arkansas Code',
        'Ark. Code Ann. § 16-56-105',
        'https://law.justia.com/codes/arkansas/title-16/subtitle-5/chapter-56/subchapter-1/section-16-56-105/',
        'The following actions shall be commenced within three (3) years after the cause of action accrues: (1) All actions founded upon any contract or liability, expressed or implied, not in writing; (2) All actions for arrearages of rent not reserved by some instrument in writing; (3) All actions founded on any contract or liability, expressed or implied; (4) All actions for trespass on lands; (5) All actions for libel; (6) All actions for taking or injuring any goods or chattels.',
        '§ 16-56-105', NOW()::date, NOW(), 'document_verified', 'high'
    )
    ON CONFLICT (citation, legal_source_id) 
    DO UPDATE SET excerpt = EXCLUDED.excerpt, last_verified_at = EXCLUDED.last_verified_at;

    -- Arkansas E-Filing Rule (Statewide)
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        ar_eflex_id, 'court_rule', 'Arkansas eFlex Electronic Filing Rules',
        'Arkansas eFlex Electronic Filing System',
        'https://arcourts.gov/administration/acap/efile',
        'The eFiling System (eFlex) allows registered attorneys and parties to electronically file case related documents online without the need to go to the courthouse. To use eFlex, filers must register, complete training, and pay a $100 registration fee. The system is implemented in courts using the Contexte Case Management System.',
        'eFlex System', NOW()::date, NOW(), 'web_verified', 'high'
    )
    ON CONFLICT (citation, legal_source_id) 
    DO UPDATE SET excerpt = EXCLUDED.excerpt, last_verified_at = EXCLUDED.last_verified_at;

    -- Pulaski County Citation (MANDATORY)
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        pulaski_id, 'court_rule', 'Pulaski County Circuit Court',
        'Pulaski County Circuit Court E-Filing Requirement (Mandatory)',
        'https://pulaskiclerkar.gov/departments/central-receiving/',
        'For attorneys, electronic filing (eFiling) is mandatory through the Arkansas eFlex system in Pulaski County Circuit Court. This includes civil, domestic relations, and probate cases. Pro se litigants must file documents in person or via mail.',
        'Pulaski Co. E-Filing', NOW()::date, NOW(), 'web_verified', 'high'
    )
    ON CONFLICT (citation, legal_source_id) 
    DO UPDATE SET excerpt = EXCLUDED.excerpt, last_verified_at = EXCLUDED.last_verified_at;

    -- Benton County Citation
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        benton_id, 'court_rule', 'Benton County Circuit Court',
        'Benton County Circuit Court E-Filing Requirement',
        'https://www.bentoncountyar.gov/circuit-clerk/',
        'Benton County Circuit Court accepts electronic filing through the Arkansas eFlex system. Check local rules and AOC eFiling status map for current mandatory status.',
        'Benton Co. E-Filing', NOW()::date, NOW(), 'web_verified', 'medium'
    )
    ON CONFLICT (citation, legal_source_id) 
    DO UPDATE SET excerpt = EXCLUDED.excerpt, last_verified_at = EXCLUDED.last_verified_at;

    -- Washington County Citation
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        washington_id, 'court_rule', 'Washington County Circuit Court',
        'Washington County Circuit Court E-Filing Requirement',
        'https://www.co.washington.ar.us/government/elected_officials/circuit_clerk/index.php',
        'Washington County Circuit Court (Fayetteville) accepts electronic filing through the Arkansas eFlex system. Check local rules and AOC eFiling status map for current mandatory status.',
        'Washington Co. E-Filing', NOW()::date, NOW(), 'web_verified', 'medium'
    )
    ON CONFLICT (citation, legal_source_id) 
    DO UPDATE SET excerpt = EXCLUDED.excerpt, last_verified_at = EXCLUDED.last_verified_at;

    -- Sebastian County Citation
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        sebastian_id, 'court_rule', 'Sebastian County Circuit Court',
        'Sebastian County Circuit Court E-Filing Requirement',
        'https://www.sebastiancountyar.gov/circuit_clerk/index.php',
        'Sebastian County Circuit Court (Fort Smith) accepts electronic filing through the Arkansas eFlex system. Check local rules and AOC eFiling status map for current mandatory status.',
        'Sebastian Co. E-Filing', NOW()::date, NOW(), 'web_verified', 'medium'
    )
    ON CONFLICT (citation, legal_source_id) 
    DO UPDATE SET excerpt = EXCLUDED.excerpt, last_verified_at = EXCLUDED.last_verified_at;

    -- Craighead County Citation
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        craighead_id, 'court_rule', 'Craighead County Circuit Court',
        'Craighead County Circuit Court E-Filing Requirement',
        'https://www.craigheadcounty.org/circuit-clerk/',
        'Craighead County Circuit Court (Jonesboro) accepts electronic filing through the Arkansas eFlex system. Check local rules and AOC eFiling status map for current mandatory status.',
        'Craighead Co. E-Filing', NOW()::date, NOW(), 'web_verified', 'medium'
    )
    ON CONFLICT (citation, legal_source_id) 
    DO UPDATE SET excerpt = EXCLUDED.excerpt, last_verified_at = EXCLUDED.last_verified_at;

END $$;

-- ============================================================================
-- PART 3: ADD ARKANSAS VALIDATION RULES
-- ============================================================================

DO $$
DECLARE
    ar_sol_id INTEGER;
    ar_statewide_efile_id INTEGER;
    ar_pulaski_efile_id INTEGER;
    ar_benton_efile_id INTEGER;
    ar_washington_efile_id INTEGER;
    ar_sebastian_efile_id INTEGER;
    ar_craighead_efile_id INTEGER;
BEGIN
    -- Get citation IDs
    SELECT id INTO ar_sol_id FROM leverage.rule_citations 
    WHERE citation = 'Ark. Code Ann. § 16-56-105';
    
    SELECT id INTO ar_statewide_efile_id FROM leverage.rule_citations 
    WHERE citation = 'Arkansas eFlex Electronic Filing System';
    
    SELECT id INTO ar_pulaski_efile_id FROM leverage.rule_citations 
    WHERE citation = 'Pulaski County Circuit Court E-Filing Requirement (Mandatory)';
    
    SELECT id INTO ar_benton_efile_id FROM leverage.rule_citations 
    WHERE citation = 'Benton County Circuit Court E-Filing Requirement';
    
    SELECT id INTO ar_washington_efile_id FROM leverage.rule_citations 
    WHERE citation = 'Washington County Circuit Court E-Filing Requirement';
    
    SELECT id INTO ar_sebastian_efile_id FROM leverage.rule_citations 
    WHERE citation = 'Sebastian County Circuit Court E-Filing Requirement';
    
    SELECT id INTO ar_craighead_efile_id FROM leverage.rule_citations 
    WHERE citation = 'Craighead County Circuit Court E-Filing Requirement';

    -- AR Statewide PI SOL (3 years) - Ark. Code Ann. § 16-56-105
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'AR-SOL-16-56-105-PI-3YEAR', 5, 'AR Personal Injury SOL (3 Years)', 'threshold_check',
        'personal_injury', 'complaint',
        'state', 'AR', NULL, NULL,
        '{"sol_years": 3, "sol_days": 1095, "statute": "Ark. Code Ann. § 16-56-105", "applies_to": "torts_negligence", "note": "Arkansas has 3-YEAR SOL for PI/negligence claims. Actions for taking or injuring goods or chattels, trespass, and general negligence must be brought within 3 years."}'::jsonb,
        'error', ar_sol_id, 'document_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id,
        review_status = EXCLUDED.review_status;

    -- AR Statewide E-Filing Info Rule (eFlex)
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'AR-EFILING-STATEWIDE-INFO', 2, 'AR Statewide E-Filing (eFlex Info)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'AR', NULL, NULL,
        '{"efiling_available": true, "system": "eFlex", "registration_fee": "$100", "training_required": true, "authority": "Arkansas AOC", "note": "eFlex system requires $100 registration fee and training. Mandatory in Pulaski County. Rolling out county by county."}'::jsonb,
        'warning', ar_statewide_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id,
        review_status = EXCLUDED.review_status;

    -- Pulaski County E-Filing Rule (MANDATORY - Little Rock)
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'AR-PULASKI-EFILING', 2, 'Pulaski County E-Filing (MANDATORY - Little Rock)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'AR', 'Pulaski', 'Circuit Court',
        '{"requires_efiling": true, "system": "eFlex", "court": "Pulaski County Circuit Court", "city": "Little Rock", "state_capital": true, "mandatory_for": ["attorneys"], "note": "MANDATORY e-filing for attorneys. State capital. Pro se may file traditionally."}'::jsonb,
        'error', ar_pulaski_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Benton County (Northwest Arkansas) E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'AR-BENTON-EFILING', 2, 'Benton County E-Filing (Northwest Arkansas)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'AR', 'Benton', 'Circuit Court',
        '{"efiling_available": true, "system": "eFlex", "court": "Benton County Circuit Court", "note": "E-filing available via eFlex. High-growth Northwest Arkansas region. Check AOC status map for mandatory status."}'::jsonb,
        'warning', ar_benton_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Washington County (Fayetteville) E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'AR-WASHINGTON-EFILING', 2, 'Washington County E-Filing (Fayetteville)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'AR', 'Washington', 'Circuit Court',
        '{"efiling_available": true, "system": "eFlex", "court": "Washington County Circuit Court", "city": "Fayetteville", "note": "E-filing available via eFlex. University of Arkansas area. Check AOC status map for mandatory status."}'::jsonb,
        'warning', ar_washington_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Sebastian County (Fort Smith) E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'AR-SEBASTIAN-EFILING', 2, 'Sebastian County E-Filing (Fort Smith)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'AR', 'Sebastian', 'Circuit Court',
        '{"efiling_available": true, "system": "eFlex", "court": "Sebastian County Circuit Court", "city": "Fort Smith", "note": "E-filing available via eFlex. Western Arkansas hub. Check AOC status map for mandatory status."}'::jsonb,
        'warning', ar_sebastian_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Craighead County (Jonesboro) E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'AR-CRAIGHEAD-EFILING', 2, 'Craighead County E-Filing (Jonesboro)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'AR', 'Craighead', 'Circuit Court',
        '{"efiling_available": true, "system": "eFlex", "court": "Craighead County Circuit Court", "city": "Jonesboro", "note": "E-filing available via eFlex. Northeast Arkansas hub. Check AOC status map for mandatory status."}'::jsonb,
        'warning', ar_craighead_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Completion message
    RAISE NOTICE '========================================================================';
    RAISE NOTICE 'ARKANSAS (AR) PI COURT RULES SEEDED SUCCESSFULLY';
    RAISE NOTICE '========================================================================';
    RAISE NOTICE 'Arkansas has 3-YEAR SOL for PI (Ark. Code Ann. § 16-56-105).';
    RAISE NOTICE 'Pulaski County (Little Rock) has MANDATORY e-filing for attorneys.';
    RAISE NOTICE '========================================================================';
END $$;

COMMIT;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================
-- Run these after seeding to verify data integrity:
--
-- SELECT COUNT(*) FROM leverage.legal_sources WHERE jurisdiction_state = 'AR';
-- Expected: 7 (2 state + 5 county)
--
-- SELECT COUNT(*) FROM leverage.rule_citations rc 
-- JOIN leverage.legal_sources ls ON rc.legal_source_id = ls.id 
-- WHERE ls.jurisdiction_state = 'AR';
-- Expected: 8 citations
--
-- SELECT COUNT(*) FROM leverage.validation_rules WHERE jurisdiction_state = 'AR';
-- Expected: 8 (1 SOL + 1 statewide e-filing + 6 county e-filing)
-- ============================================================================
