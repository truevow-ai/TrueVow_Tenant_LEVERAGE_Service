-- ============================================================================
-- Delaware County-Specific PI Court Rules Seed
-- ============================================================================
-- Version: 1.0.0
-- Date: January 30, 2026
-- Purpose: Add Delaware county-level court rules with verified citations
-- High-volume PI counties: New Castle (Wilmington), Kent (Dover - Capital), Sussex
-- Delaware has 2-YEAR SOL for personal injury
-- NOTE: Delaware has only 3 counties - the second smallest state
-- Data Due Diligence: Citations verified from delcode.delaware.gov and courts.delaware.gov
-- ============================================================================
-- DOCUMENT VERIFIED CITATIONS:
--
-- 1. Delaware Code 10 Del. C. § 8119 - Personal injuries
--    Source: https://delcode.delaware.gov/title10/c081/
--    EXACT TEXT: "No action for the recovery of damages upon a claim for alleged 
--    personal injuries shall be brought after the expiration of 2 years from the 
--    date upon which it is claimed that such alleged injuries were sustained; 
--    subject, however, to the provisions of § 8127 of this title."
--
-- 2. Delaware E-Filing - File & ServeXpress
--    Source: https://courts.delaware.gov/efiling/
--    SYSTEMS:
--    - File & ServeXpress: Supreme Court, Court of Chancery, Superior Court
--    - File & Serve Delaware: Court of Common Pleas
--    - Delaware eFlex: Justice of the Peace Court
--    Delaware was an early leader in e-filing (CLAD system since 1991)
-- ============================================================================

BEGIN;

-- ============================================================================
-- PART 1: ADD DELAWARE STATE AND COUNTY LEGAL SOURCES
-- ============================================================================

-- Delaware State-level Sources
INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    ('state', 'DE', NULL, NULL,
     'Delaware Code',
     'Delaware General Assembly',
     '10 Del. C.',
     'https://delcode.delaware.gov/',
     'statute',
     'high',
     'Official Delaware Code. Section 8119 establishes 2-year SOL for personal injury. DOCUMENT VERIFIED.'),
    ('state', 'DE', NULL, NULL,
     'Delaware Rules of Electronic Filing',
     'Delaware Judiciary',
     'DE E-Filing',
     'https://courts.delaware.gov/efiling/',
     'court_rule',
     'high',
     'Delaware E-Filing systems: File & ServeXpress (Superior, Chancery, Supreme), File & Serve Delaware (Common Pleas), eFlex (JP Court).')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET base_url = EXCLUDED.base_url, notes = EXCLUDED.notes;

-- Delaware County Sources (All 3 Counties - Second Smallest State)
INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    ('county', 'DE', 'New Castle', 'Superior Court',
     'New Castle County Superior Court Rules',
     'New Castle County Superior Court',
     'New Castle Co. Super. Ct. R.',
     'https://courts.delaware.gov/superior/',
     'court_rule',
     'high',
     'New Castle County Superior Court (Wilmington). Most populous county (~70% of state population). File & ServeXpress mandatory. WEB VERIFIED.'),
    ('county', 'DE', 'Kent', 'Superior Court',
     'Kent County Superior Court Rules',
     'Kent County Superior Court',
     'Kent Co. Super. Ct. R.',
     'https://courts.delaware.gov/superior/',
     'court_rule',
     'high',
     'Kent County Superior Court (Dover - State Capital). File & ServeXpress mandatory. WEB VERIFIED.'),
    ('county', 'DE', 'Sussex', 'Superior Court',
     'Sussex County Superior Court Rules',
     'Sussex County Superior Court',
     'Sussex Co. Super. Ct. R.',
     'https://courts.delaware.gov/superior/',
     'court_rule',
     'high',
     'Sussex County Superior Court (Georgetown). Largest county by area. File & ServeXpress mandatory. WEB VERIFIED.')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET base_url = EXCLUDED.base_url, notes = EXCLUDED.notes;

-- ============================================================================
-- PART 2: ADD DELAWARE STATE AND COUNTY CITATIONS
-- ============================================================================

INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'statute', 'Delaware Code',
    '10 Del. C. § 8119',
    'https://delcode.delaware.gov/title10/c081/',
    'No action for the recovery of damages upon a claim for alleged personal injuries shall be brought after the expiration of 2 years from the date upon which it is claimed that such alleged injuries were sustained; subject, however, to the provisions of § 8127 of this title.',
    '§ 8119', NOW()::date, NOW(), 'document_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'DE' AND ls.abbreviation = '10 Del. C.'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt,
    verifier = EXCLUDED.verifier;

-- Delaware E-Filing Citation
INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'court_rule', 'Delaware Rules of Electronic Filing',
    'DE-EFILING-FILE-SERVEXPRESS',
    'https://courts.delaware.gov/efiling/',
    'File & ServeXpress is used in the Supreme Court, Court of Chancery and Superior Court. Any person intending to eFile in these courts must register with File & ServeXpress. Delaware was a leader in e-filing, with the Superior Court implementing an electronic docketing and filing system (CLAD) in 1991.',
    'E-Filing', '2003-01-01', NOW(), 'document_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'DE' AND ls.abbreviation = 'DE E-Filing'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt;

-- County-specific Citations
INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'local_rule', 'New Castle County Superior Court Rules',
    'DE-NEWCASTLE-EFILING',
    'https://courts.delaware.gov/superior/elitigation/tech_efile.aspx',
    'New Castle County Superior Court (Wilmington). Most populous county - approximately 70% of Delaware population. File & ServeXpress mandatory per Administrative Directive 2007-6.',
    'E-Filing', '2007-01-01', NOW(), 'web_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'DE' AND ls.jurisdiction_county = 'New Castle'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt;

INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'local_rule', 'Kent County Superior Court Rules',
    'DE-KENT-EFILING',
    'https://courts.delaware.gov/superior/elitigation/tech_efile.aspx',
    'Kent County Superior Court (Dover - State Capital). File & ServeXpress mandatory per Administrative Directive 2007-6.',
    'E-Filing', '2007-01-01', NOW(), 'web_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'DE' AND ls.jurisdiction_county = 'Kent'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt;

INSERT INTO leverage.rule_citations (
    legal_source_id, source_type, source_name, citation, source_url, excerpt,
    locator, effective_date, last_verified_at, verifier, confidence_level
)
SELECT 
    ls.id, 'local_rule', 'Sussex County Superior Court Rules',
    'DE-SUSSEX-EFILING',
    'https://courts.delaware.gov/superior/elitigation/tech_efile.aspx',
    'Sussex County Superior Court (Georgetown). Largest county by area in Delaware. File & ServeXpress mandatory per Administrative Directive 2007-6.',
    'E-Filing', '2007-01-01', NOW(), 'web_verified', 'high'
FROM leverage.legal_sources ls
WHERE ls.jurisdiction_state = 'DE' AND ls.jurisdiction_county = 'Sussex'
ON CONFLICT (legal_source_id, citation) DO UPDATE SET
    source_url = EXCLUDED.source_url,
    excerpt = EXCLUDED.excerpt;

-- ============================================================================
-- PART 3: ADD DELAWARE VALIDATION RULES
-- ============================================================================

DO $$
DECLARE
    de_sol_id INTEGER;
    de_efiling_id INTEGER;
    de_newcastle_id INTEGER;
    de_kent_id INTEGER;
    de_sussex_id INTEGER;
BEGIN
    -- Get citation IDs
    SELECT id INTO de_sol_id FROM leverage.rule_citations 
    WHERE citation = '10 Del. C. § 8119';
    
    SELECT id INTO de_efiling_id FROM leverage.rule_citations 
    WHERE citation = 'DE-EFILING-FILE-SERVEXPRESS';
    
    SELECT id INTO de_newcastle_id FROM leverage.rule_citations 
    WHERE citation = 'DE-NEWCASTLE-EFILING';
    
    SELECT id INTO de_kent_id FROM leverage.rule_citations 
    WHERE citation = 'DE-KENT-EFILING';
    
    SELECT id INTO de_sussex_id FROM leverage.rule_citations 
    WHERE citation = 'DE-SUSSEX-EFILING';

    -- DE Statewide PI SOL (2 years) - 10 Del. C. § 8119
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'DE-SOL-8119-PI-2YEAR', 5, 'DE Personal Injury SOL (2 Years)', 'threshold_check',
        'personal_injury', 'complaint',
        'state', 'DE', NULL, NULL,
        '{"sol_years": 2, "sol_days": 730, "statute": "10 Del. C. § 8119", "applies_to": "alleged_personal_injuries", "only_3_counties": true, "second_smallest_state": true, "note": "Delaware has 2-YEAR SOL for PI. No action for recovery of damages for alleged personal injuries shall be brought after 2 years from date injuries sustained."}'::jsonb,
        'error', de_sol_id, 'document_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id,
        review_status = EXCLUDED.review_status;

    -- DE Statewide E-Filing Rule (File & ServeXpress)
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'DE-EFILING-FSX-STATEWIDE', 2, 'DE Statewide E-Filing (File & ServeXpress)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'DE', NULL, NULL,
        '{"requires_efiling": true, "systems": {"superior_court": "File & ServeXpress", "court_of_chancery": "File & ServeXpress", "supreme_court": "File & ServeXpress", "court_of_common_pleas": "File & Serve Delaware", "justice_of_peace": "Delaware eFlex"}, "early_adopter": true, "clad_since": 1991, "note": "DOCUMENT VERIFIED: Delaware was a leader in e-filing with CLAD system since 1991."}'::jsonb,
        'error', de_efiling_id, 'document_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id,
        review_status = EXCLUDED.review_status;

    -- County E-Filing Rules (All 3 Delaware Counties)
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'DE-NEWCASTLE-EFILING', 2, 'New Castle County E-Filing (Wilmington)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'DE', 'New Castle', 'Superior Court',
        '{"requires_efiling": true, "system": "File & ServeXpress", "city": "Wilmington", "most_populous": true, "population_percent": 70, "authority": "Administrative Directive 2007-6", "note": "Most populous county (~70% of state). File & ServeXpress mandatory."}'::jsonb,
        'error', de_newcastle_id, 'web_verified',
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
        'DE-KENT-EFILING', 2, 'Kent County E-Filing (Dover)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'DE', 'Kent', 'Superior Court',
        '{"requires_efiling": true, "system": "File & ServeXpress", "city": "Dover", "state_capital": true, "authority": "Administrative Directive 2007-6", "note": "State capital. File & ServeXpress mandatory."}'::jsonb,
        'error', de_kent_id, 'web_verified',
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
        'DE-SUSSEX-EFILING', 2, 'Sussex County E-Filing (Georgetown)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'DE', 'Sussex', 'Superior Court',
        '{"requires_efiling": true, "system": "File & ServeXpress", "city": "Georgetown", "largest_by_area": true, "authority": "Administrative Directive 2007-6", "note": "Largest county by area. File & ServeXpress mandatory."}'::jsonb,
        'error', de_sussex_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Completion message
    RAISE NOTICE '========================================================================';
    RAISE NOTICE 'DELAWARE (DE) PI COURT RULES SEEDED SUCCESSFULLY';
    RAISE NOTICE '========================================================================';
    RAISE NOTICE 'Delaware has 2-YEAR SOL for PI (10 Del. C. § 8119).';
    RAISE NOTICE 'SECOND SMALLEST STATE - Only 3 counties (all seeded).';
    RAISE NOTICE 'E-Filing pioneer - CLAD system since 1991, File & ServeXpress mandatory.';
    RAISE NOTICE '========================================================================';

END $$;

COMMIT;
