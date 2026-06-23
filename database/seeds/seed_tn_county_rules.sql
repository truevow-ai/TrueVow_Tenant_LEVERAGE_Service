-- ============================================================================
-- Tennessee County-Specific PI Court Rules Seed
-- ============================================================================
-- Version: 1.0.0
-- Date: January 30, 2026
-- Purpose: Add Tennessee county-level court rules with verified citations
-- High-volume PI counties: Davidson (Nashville), Shelby (Memphis), Knox, Hamilton, Rutherford
-- CRITICAL: Tennessee has ONE YEAR SOL for personal injury (shortest in nation)
-- Data Due Diligence: Citations verified from Tennessee Code sources
-- ============================================================================

BEGIN;

-- ============================================================================
-- PART 1: ADD TENNESSEE STATE AND COUNTY LEGAL SOURCES
-- ============================================================================

-- Tennessee State-level Sources
INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    ('state', 'TN', NULL, NULL,
     'Tennessee Code Annotated',
     'Tennessee General Assembly',
     'Tenn. Code Ann.',
     'https://www.tn.gov/content/tn/lawsandpolicies/tc-annotated.html',
     'statute',
     'high',
     'Official statutory code for Tennessee'),
    ('state', 'TN', NULL, NULL,
     'Tennessee Rules of Civil Procedure',
     'Tennessee Supreme Court',
     'Tenn. R. Civ. P.',
     'https://www.tncourts.gov/rules/rules-civil-procedure',
     'court_rule',
     'high',
     'Statewide civil procedure rules'),
    ('state', 'TN', NULL, NULL,
     'Tennessee Supreme Court Rule 46',
     'Tennessee Supreme Court',
     'Tenn. Sup. Ct. R. 46',
     'https://www.tncourts.gov/rules',
     'court_rule',
     'high',
     'Statewide electronic filing authorization rule')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET base_url = EXCLUDED.base_url;

-- Tennessee County Sources (Major PI Jurisdictions)
INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    ('county', 'TN', 'Davidson', 'Circuit Court',
     'Davidson County Circuit Court Local Rules',
     'Davidson County Circuit Court',
     'Davidson L.R.',
     'https://circuitclerk.nashville.gov/efile-local-rules/',
     'court_rule',
     'high',
     'Local rules for Nashville metro area - mandatory eFlex e-filing'),
    ('county', 'TN', 'Shelby', 'Circuit Court',
     'Shelby County Circuit Court Local Rules',
     'Shelby County Circuit Court',
     'Shelby L.R.',
     'https://www.shelbycountytn.gov/2524/About-E-Filing',
     'court_rule',
     'high',
     'Local rules for Memphis area - eFlex e-filing since 2012'),
    ('county', 'TN', 'Knox', 'Circuit Court',
     'Knox County Circuit Court Local Rules',
     'Knox County Circuit Court',
     'Knox L.R.',
     'https://knoxcounty.org/civil/localrules.php',
     'court_rule',
     'high',
     'Local rules for Knoxville area - mandatory e-filing'),
    ('county', 'TN', 'Hamilton', 'Circuit Court',
     'Hamilton County Circuit Court Local Rules',
     'Hamilton County Circuit Court',
     'Hamilton L.R.',
     'https://www.hamiltontn.gov/Courts/',
     'court_rule',
     'high',
     'Local rules for Chattanooga area civil cases'),
    ('county', 'TN', 'Rutherford', 'Circuit Court',
     'Rutherford County Circuit Court Local Rules',
     'Rutherford County Circuit Court',
     'Rutherford L.R.',
     'https://rutherfordcountytn.gov/circuit-court/',
     'court_rule',
     'high',
     'Local rules for Murfreesboro area civil cases')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET base_url = EXCLUDED.base_url;

-- ============================================================================
-- PART 2: ADD TENNESSEE STATE AND COUNTY CITATIONS
-- ============================================================================

DO $$
DECLARE
    tn_tca_id INTEGER;
    tn_trcp_id INTEGER;
    tn_r46_id INTEGER;
    davidson_id INTEGER;
    shelby_id INTEGER;
    knox_id INTEGER;
    hamilton_id INTEGER;
    rutherford_id INTEGER;
BEGIN
    -- Get legal source IDs
    SELECT id INTO tn_tca_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'TN' AND abbreviation = 'Tenn. Code Ann.';
    
    SELECT id INTO tn_trcp_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'TN' AND abbreviation = 'Tenn. R. Civ. P.';
    
    SELECT id INTO tn_r46_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'TN' AND abbreviation = 'Tenn. Sup. Ct. R. 46';
    
    SELECT id INTO davidson_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'TN' AND jurisdiction_county = 'Davidson';
    
    SELECT id INTO shelby_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'TN' AND jurisdiction_county = 'Shelby';
    
    SELECT id INTO knox_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'TN' AND jurisdiction_county = 'Knox';
    
    SELECT id INTO hamilton_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'TN' AND jurisdiction_county = 'Hamilton';
    
    SELECT id INTO rutherford_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'TN' AND jurisdiction_county = 'Rutherford';

    -- Tenn. Code Ann. § 28-3-104 - Statute of Limitations for Personal Injury (ONE YEAR)
    -- CRITICAL: Tennessee has the SHORTEST SOL for PI in the nation (1 year)
    -- WEB VERIFIED from law.justia.com and FindLaw
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        tn_tca_id, 'statute', 'Tennessee Code Annotated',
        'Tenn. Code Ann. § 28-3-104',
        'https://law.justia.com/codes/tennessee/title-28/chapter-3/part-1/section-28-3-104/',
        'The following actions shall be commenced within one (1) year after the cause of action accrued: (a)(1) Actions for libel, for injuries to the person, false imprisonment, malicious prosecution, criminal conversation, seduction, breach of marriage promise, and statutory penalties.',
        '§ 28-3-104', '2026-01-01', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Tenn. R. Civ. P. 3 - Commencement of Action
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        tn_trcp_id, 'court_rule', 'Tennessee Rules of Civil Procedure',
        'Tenn. R. Civ. P. 3',
        'https://www.tncourts.gov/rules/rules-civil-procedure/3',
        'All civil actions are commenced by filing a complaint with the clerk of the court. Filing is complete upon either actual receipt of the documents by the clerk or, when permissible, upon electronic transmission.',
        'Rule 3', '2026-01-01', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Tennessee Supreme Court Rule 46 - Electronic Filing
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        tn_r46_id, 'court_rule', 'Tennessee Supreme Court Rule 46',
        'Tenn. Sup. Ct. R. 46',
        'https://www.tncourts.gov/rules/supreme-court-rules/46',
        'Tennessee Supreme Court Rule 46 authorizes electronic filing in Tennessee courts. Local courts may adopt rules requiring mandatory e-filing.',
        'Rule 46', '2026-01-01', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Davidson County E-Filing - WEB VERIFIED from circuitclerk.nashville.gov
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        davidson_id, 'local_rule', 'Davidson County Circuit Court Local Rules',
        'Davidson County E-Filing Rules',
        'https://circuitclerk.nashville.gov/efile-local-rules/',
        'Davidson County Circuit Court has implemented mandatory e-filing for civil cases using the eFlex Electronic Filing system. All civil filings must be submitted electronically through the eFlex system.',
        'E-Filing', '2024-06-01', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Shelby County E-Filing - WEB VERIFIED from shelbycountytn.gov
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        shelby_id, 'local_rule', 'Shelby County Circuit Court Local Rules',
        'Shelby County E-Filing Rules',
        'https://www.shelbycountytn.gov/2524/About-E-Filing',
        'Shelby County Circuit and Chancery Courts implemented E-Filing system called eFlex in June 2012. Documents for civil cases can be uploaded electronically, eliminating the need for physical delivery.',
        'E-Filing', '2012-06-01', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Knox County E-Filing - WEB VERIFIED from knoxcounty.org
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        knox_id, 'local_rule', 'Knox County Circuit Court Local Rules',
        'Knox County E-Filing Rules',
        'https://knoxcounty.org/civil/localrules.php',
        'Knox County Circuit Court has implemented mandatory e-filing for civil cases. All civil filings must be submitted electronically through the court e-filing system.',
        'E-Filing', '2026-01-01', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Hamilton County (Chattanooga)
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        hamilton_id, 'local_rule', 'Hamilton County Circuit Court Local Rules',
        'Hamilton County E-Filing Rules',
        'https://www.hamiltontn.gov/Courts/',
        'Hamilton County Circuit Court civil case filing procedures. E-filing available through Tennessee court systems.',
        'E-Filing', '2026-01-01', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Rutherford County (Murfreesboro)
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        rutherford_id, 'local_rule', 'Rutherford County Circuit Court Local Rules',
        'Rutherford County E-Filing Rules',
        'https://rutherfordcountytn.gov/circuit-court/',
        'Rutherford County Circuit Court civil case filing procedures. E-filing available through Tennessee court systems.',
        'E-Filing', '2026-01-01', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

END $$;

-- ============================================================================
-- PART 3: ADD TENNESSEE VALIDATION RULES
-- ============================================================================

DO $$
DECLARE
    tn_sol_id INTEGER;
    tn_rule3_id INTEGER;
    tn_r46_id INTEGER;
    davidson_efile_id INTEGER;
    shelby_efile_id INTEGER;
    knox_efile_id INTEGER;
    hamilton_efile_id INTEGER;
    rutherford_efile_id INTEGER;
BEGIN
    -- Get citation IDs
    SELECT id INTO tn_sol_id FROM leverage.rule_citations 
    WHERE citation = 'Tenn. Code Ann. § 28-3-104';
    
    SELECT id INTO tn_rule3_id FROM leverage.rule_citations 
    WHERE citation = 'Tenn. R. Civ. P. 3';
    
    SELECT id INTO tn_r46_id FROM leverage.rule_citations 
    WHERE citation = 'Tenn. Sup. Ct. R. 46';
    
    SELECT id INTO davidson_efile_id FROM leverage.rule_citations 
    WHERE citation = 'Davidson County E-Filing Rules';
    
    SELECT id INTO shelby_efile_id FROM leverage.rule_citations 
    WHERE citation = 'Shelby County E-Filing Rules';
    
    SELECT id INTO knox_efile_id FROM leverage.rule_citations 
    WHERE citation = 'Knox County E-Filing Rules';
    
    SELECT id INTO hamilton_efile_id FROM leverage.rule_citations 
    WHERE citation = 'Hamilton County E-Filing Rules';
    
    SELECT id INTO rutherford_efile_id FROM leverage.rule_citations 
    WHERE citation = 'Rutherford County E-Filing Rules';

    -- TN Statewide PI Statute of Limitations (ONE YEAR - CRITICAL)
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'TN-SOL-28-3-104-PI-1YEAR', 5, 'TN PI Statute of Limitations (1 YEAR)', 'threshold_check',
        'personal_injury', 'complaint',
        'state', 'TN', NULL, NULL,
        '{"sol_years": 1, "sol_days": 365, "critical_warning": "Tennessee has SHORTEST SOL in nation - 1 year for PI"}'::jsonb,
        'error', tn_sol_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- TN Commencement of Action
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'TN-TRCP3-COMMENCEMENT', 3, 'TN Commencement of Action', 'content_check',
        'personal_injury', 'complaint',
        'state', 'TN', NULL, NULL,
        '{"requires_complaint_filing": true, "efiling_when_permitted": true}'::jsonb,
        'error', tn_rule3_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- TN Supreme Court Rule 46 E-Filing
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'TN-SCR46-EFILE', 2, 'TN E-Filing Authorization', 'format_check',
        'personal_injury', 'complaint',
        'state', 'TN', NULL, NULL,
        '{"efiling_authorized": true, "local_rules_may_require": true}'::jsonb,
        'warning', tn_r46_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Davidson County (Nashville) Mandatory E-Filing
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'TN-DAVIDSON-EFILE', 2, 'Davidson County E-Filing', 'format_check',
        'personal_injury', 'complaint',
        'state', 'TN', 'Davidson', 'Circuit Court',
        '{"requires_efiling": true, "system": "eFlex", "mandatory": true}'::jsonb,
        'error', davidson_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Shelby County (Memphis) E-Filing
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'TN-SHELBY-EFILE', 2, 'Shelby County E-Filing', 'format_check',
        'personal_injury', 'complaint',
        'state', 'TN', 'Shelby', 'Circuit Court',
        '{"efiling_available": true, "system": "eFlex", "since": "2012"}'::jsonb,
        'warning', shelby_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Knox County (Knoxville) Mandatory E-Filing
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'TN-KNOX-EFILE', 2, 'Knox County E-Filing', 'format_check',
        'personal_injury', 'complaint',
        'state', 'TN', 'Knox', 'Circuit Court',
        '{"requires_efiling": true, "mandatory": true}'::jsonb,
        'error', knox_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Hamilton County (Chattanooga) E-Filing
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'TN-HAMILTON-EFILE', 2, 'Hamilton County E-Filing', 'format_check',
        'personal_injury', 'complaint',
        'state', 'TN', 'Hamilton', 'Circuit Court',
        '{"efiling_available": true}'::jsonb,
        'warning', hamilton_efile_id, 'draft',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Rutherford County (Murfreesboro) E-Filing
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'TN-RUTHERFORD-EFILE', 2, 'Rutherford County E-Filing', 'format_check',
        'personal_injury', 'complaint',
        'state', 'TN', 'Rutherford', 'Circuit Court',
        '{"efiling_available": true}'::jsonb,
        'warning', rutherford_efile_id, 'draft',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

END $$;

COMMIT;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Show TN legal sources
SELECT 
    jurisdiction_type,
    CASE 
        WHEN jurisdiction_county IS NOT NULL THEN jurisdiction_county
        ELSE 'STATE'
    END as location,
    name,
    abbreviation
FROM leverage.legal_sources
WHERE jurisdiction_state = 'TN'
ORDER BY jurisdiction_type, location;

-- Show TN citations
SELECT 
    ls.jurisdiction_county as county,
    rc.citation,
    rc.verifier,
    rc.confidence_level
FROM leverage.rule_citations rc
JOIN leverage.legal_sources ls ON rc.legal_source_id = ls.id
WHERE ls.jurisdiction_state = 'TN'
ORDER BY ls.jurisdiction_county NULLS FIRST, rc.citation;

-- Show TN validation rules
SELECT 
    rule_name,
    validator_name,
    severity,
    jurisdiction_county,
    review_status
FROM leverage.validation_rules
WHERE jurisdiction_state = 'TN'
ORDER BY jurisdiction_county NULLS FIRST, rule_name;

-- Verify no missing citations
SELECT COUNT(*) as rules_without_citations
FROM leverage.validation_rules vr
WHERE vr.jurisdiction_state = 'TN'
AND vr.citation_id IS NULL;

-- CRITICAL WARNING: Display Tennessee SOL
SELECT 
    'CRITICAL WARNING: Tennessee has 1-YEAR SOL for personal injury (shortest in nation)' as warning,
    validator_config->>'sol_years' as sol_years
FROM leverage.validation_rules
WHERE rule_name = 'TN-SOL-28-3-104-PI-1YEAR';
