-- ============================================================================
-- Maryland County-Specific PI Court Rules Seed
-- ============================================================================
-- Version: 1.0.0
-- Date: January 30, 2026
-- Purpose: Add Maryland county-level court rules with verified citations
-- High-volume PI counties: Montgomery, Baltimore County, Prince George's, Anne Arundel, Baltimore City
-- MDEC (Maryland Electronic Courts) implemented statewide - mandatory for attorneys
-- Data Due Diligence: Citations verified from mgaleg.maryland.gov and mdcourts.gov
-- ============================================================================

BEGIN;

-- ============================================================================
-- PART 1: ADD MARYLAND STATE AND COUNTY LEGAL SOURCES
-- ============================================================================

-- Maryland State-level Sources
INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    ('state', 'MD', NULL, NULL,
     'Maryland Courts and Judicial Proceedings',
     'Maryland General Assembly',
     'Md. Code C&JP',
     'https://mgaleg.maryland.gov/mgawebsite/laws/Statutes',
     'statute',
     'high',
     'Official statutory code for Maryland'),
    ('state', 'MD', NULL, NULL,
     'Maryland Rules',
     'Maryland Court of Appeals',
     'Md. Rule',
     'https://www.mdcourts.gov/rules',
     'court_rule',
     'high',
     'Statewide court rules including MDEC e-filing rules'),
    ('state', 'MD', NULL, NULL,
     'Maryland Electronic Courts Rules Title 20',
     'Maryland Judiciary',
     'Md. Rule 20',
     'https://www.mdcourts.gov/sites/default/files/import/mdec/pdfs/rulestitle20.pdf',
     'court_rule',
     'high',
     'MDEC electronic filing rules - mandatory for attorneys statewide')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET base_url = EXCLUDED.base_url;

-- Maryland County Sources (Major PI Jurisdictions)
INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    ('county', 'MD', 'Montgomery', 'Circuit Court',
     'Montgomery County Circuit Court Local Rules',
     'Montgomery County Circuit Court',
     'Montgomery L.R.',
     'https://www.montgomerycountymd.gov/cct/',
     'court_rule',
     'high',
     'Local rules - MDEC mandatory since October 25, 2021'),
    ('county', 'MD', 'Baltimore County', 'Circuit Court',
     'Baltimore County Circuit Court Local Rules',
     'Baltimore County Circuit Court',
     'Baltimore Co. L.R.',
     'https://www.baltimorecountymd.gov/departments/circuit',
     'court_rule',
     'high',
     'Local rules - MDEC mandatory since May 14, 2019'),
    ('county', 'MD', 'Prince Georges', 'Circuit Court',
     'Prince Georges County Circuit Court Local Rules',
     'Prince Georges County Circuit Court',
     'PG L.R.',
     'https://www.princegeorgescountymd.gov/2082/Circuit-Court',
     'court_rule',
     'high',
     'Local rules - MDEC mandatory since October 17, 2022'),
    ('county', 'MD', 'Anne Arundel', 'Circuit Court',
     'Anne Arundel County Circuit Court Local Rules',
     'Anne Arundel County Circuit Court',
     'AA L.R.',
     'https://www.aacounty.org/circuit-court',
     'court_rule',
     'high',
     'Local rules - First MDEC county October 14, 2014'),
    ('county', 'MD', 'Baltimore City', 'Circuit Court',
     'Baltimore City Circuit Court Local Rules',
     'Baltimore City Circuit Court',
     'Balt City L.R.',
     'https://www.baltimorecitycourt.org/',
     'court_rule',
     'high',
     'Local rules - MDEC mandatory since May 6, 2024 (final county)')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET base_url = EXCLUDED.base_url;

-- ============================================================================
-- PART 2: ADD MARYLAND STATE AND COUNTY CITATIONS
-- ============================================================================

DO $$
DECLARE
    md_cjp_id INTEGER;
    md_rules_id INTEGER;
    md_rule20_id INTEGER;
    montgomery_id INTEGER;
    baltimore_co_id INTEGER;
    pg_id INTEGER;
    anne_arundel_id INTEGER;
    baltimore_city_id INTEGER;
BEGIN
    -- Get legal source IDs
    SELECT id INTO md_cjp_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'MD' AND abbreviation = 'Md. Code C&JP';
    
    SELECT id INTO md_rules_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'MD' AND abbreviation = 'Md. Rule';
    
    SELECT id INTO md_rule20_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'MD' AND abbreviation = 'Md. Rule 20';
    
    SELECT id INTO montgomery_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'MD' AND jurisdiction_county = 'Montgomery';
    
    SELECT id INTO baltimore_co_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'MD' AND jurisdiction_county = 'Baltimore County';
    
    SELECT id INTO pg_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'MD' AND jurisdiction_county = 'Prince Georges';
    
    SELECT id INTO anne_arundel_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'MD' AND jurisdiction_county = 'Anne Arundel';
    
    SELECT id INTO baltimore_city_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'MD' AND jurisdiction_county = 'Baltimore City';

    -- Md. Code C&JP § 5-101 - Statute of Limitations (3 years)
    -- DOCUMENT VERIFIED: EXACT TEXT from mgaleg.maryland.gov
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        md_cjp_id, 'statute', 'Maryland Courts and Judicial Proceedings',
        'Md. Code C&JP § 5-101',
        'https://mgaleg.maryland.gov/mgawebsite/laws/StatuteText?article=gcj&section=5-101',
        'A civil action at law shall be filed within three years from the date it accrues unless another provision of the Code provides a different period of time within which an action shall be commenced.',
        '§ 5-101', '2026-01-01', NOW(), 'document_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        verifier = EXCLUDED.verifier;

    -- Md. Rule 20-101 - MDEC Definitions and E-Filing
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        md_rule20_id, 'court_rule', 'Maryland Electronic Courts Rules Title 20',
        'Md. Rule 20-101',
        'https://www.mdcourts.gov/sites/default/files/import/mdec/pdfs/rulestitle20.pdf',
        'MDEC Rule 20-101 definitions. Applicable County means a county in which MDEC has been implemented. The e-filing mandate is only for attorneys; however, a self-represented (pro se) litigant or filer is able to use the system if they choose to do so.',
        'Rule 20-101', '2014-10-14', NOW(), 'document_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        verifier = EXCLUDED.verifier;

    -- Md. Rule 3-101 - Commencement of Action
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        md_rules_id, 'court_rule', 'Maryland Rules',
        'Md. Rule 3-101',
        'https://www.mdcourts.gov/rules/title3/chapter100',
        'A civil action is commenced by filing a complaint with a court.',
        'Rule 3-101', '2026-01-01', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Montgomery County MDEC - WEB VERIFIED from mdcourts.gov
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        montgomery_id, 'local_rule', 'Montgomery County Circuit Court Local Rules',
        'Montgomery County MDEC Implementation',
        'https://www.mdcourts.gov/media/news/2021/pr20211025',
        'Montgomery County district and circuit courts launch electronic case management system. E-filing mandatory for attorneys in civil and criminal cases in both Circuit Court and District Court effective October 25, 2021.',
        'MDEC', '2021-10-25', NOW(), 'document_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        verifier = EXCLUDED.verifier;

    -- Baltimore County MDEC - WEB VERIFIED
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        baltimore_co_id, 'local_rule', 'Baltimore County Circuit Court Local Rules',
        'Baltimore County MDEC Implementation',
        'https://www.baltimorecountymd.gov/departments/circuit/library/mdec',
        'Baltimore County has implemented mandatory e-filing through MDEC. All attorneys must use the Maryland Electronic Courts (MDEC) e-filing system for civil cases effective May 14, 2019.',
        'MDEC', '2019-05-14', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Prince George's County MDEC - DOCUMENT VERIFIED from mdcourts.gov
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        pg_id, 'local_rule', 'Prince Georges County Circuit Court Local Rules',
        'Prince Georges County MDEC Implementation',
        'https://www.mdcourts.gov/media/news/2022/pr20221017',
        'Maryland Electronic Courts (MDEC) launches at Prince Georges County. Electronic filing mandatory for attorneys in civil and criminal cases at both the Circuit Court and District Court effective October 17, 2022.',
        'MDEC', '2022-10-17', NOW(), 'document_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        verifier = EXCLUDED.verifier;

    -- Anne Arundel County MDEC - First MDEC county
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        anne_arundel_id, 'local_rule', 'Anne Arundel County Circuit Court Local Rules',
        'Anne Arundel County MDEC Implementation',
        'https://www.mdcourts.gov/mdec',
        'Anne Arundel County was the first Maryland county to implement MDEC on October 14, 2014. Electronic filing mandatory for attorneys in civil cases.',
        'MDEC', '2014-10-14', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Baltimore City MDEC - DOCUMENT VERIFIED from mdcourts.gov (final county)
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        baltimore_city_id, 'local_rule', 'Baltimore City Circuit Court Local Rules',
        'Baltimore City MDEC Implementation',
        'https://www.mdcourts.gov/media/news/2024/pr20240506',
        'Maryland Electronic Courts (MDEC) launches at Baltimore City District and circuit courts. E-filing mandatory for attorneys in all civil and criminal cases effective May 6, 2024. This completes the statewide MDEC rollout.',
        'MDEC', '2024-05-06', NOW(), 'document_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        verifier = EXCLUDED.verifier;

END $$;

-- ============================================================================
-- PART 3: ADD MARYLAND VALIDATION RULES
-- ============================================================================

DO $$
DECLARE
    md_sol_id INTEGER;
    md_rule20_id INTEGER;
    md_rule3_id INTEGER;
    montgomery_mdec_id INTEGER;
    baltimore_co_mdec_id INTEGER;
    pg_mdec_id INTEGER;
    anne_arundel_mdec_id INTEGER;
    baltimore_city_mdec_id INTEGER;
BEGIN
    -- Get citation IDs
    SELECT id INTO md_sol_id FROM leverage.rule_citations 
    WHERE citation = 'Md. Code C&JP § 5-101';
    
    SELECT id INTO md_rule20_id FROM leverage.rule_citations 
    WHERE citation = 'Md. Rule 20-101';
    
    SELECT id INTO md_rule3_id FROM leverage.rule_citations 
    WHERE citation = 'Md. Rule 3-101';
    
    SELECT id INTO montgomery_mdec_id FROM leverage.rule_citations 
    WHERE citation = 'Montgomery County MDEC Implementation';
    
    SELECT id INTO baltimore_co_mdec_id FROM leverage.rule_citations 
    WHERE citation = 'Baltimore County MDEC Implementation';
    
    SELECT id INTO pg_mdec_id FROM leverage.rule_citations 
    WHERE citation = 'Prince Georges County MDEC Implementation';
    
    SELECT id INTO anne_arundel_mdec_id FROM leverage.rule_citations 
    WHERE citation = 'Anne Arundel County MDEC Implementation';
    
    SELECT id INTO baltimore_city_mdec_id FROM leverage.rule_citations 
    WHERE citation = 'Baltimore City MDEC Implementation';

    -- MD Statewide PI Statute of Limitations (3 years)
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'MD-SOL-5-101-PI-3YEAR', 5, 'MD PI Statute of Limitations', 'threshold_check',
        'personal_injury', 'complaint',
        'state', 'MD', NULL, NULL,
        '{"sol_years": 3, "sol_days": 1095}'::jsonb,
        'error', md_sol_id, 'document_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id,
        review_status = EXCLUDED.review_status;

    -- MD MDEC E-Filing Statewide
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'MD-RULE20-MDEC-EFILE', 2, 'MD MDEC E-Filing', 'format_check',
        'personal_injury', 'complaint',
        'state', 'MD', NULL, NULL,
        '{"requires_efiling": true, "system": "MDEC", "attorneys_mandatory": true, "pro_se_optional": true, "max_file_mb": 25}'::jsonb,
        'error', md_rule20_id, 'document_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id,
        review_status = EXCLUDED.review_status;

    -- MD Commencement of Action
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'MD-RULE3-COMMENCEMENT', 3, 'MD Commencement of Action', 'content_check',
        'personal_injury', 'complaint',
        'state', 'MD', NULL, NULL,
        '{"requires_complaint_filing": true}'::jsonb,
        'error', md_rule3_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Montgomery County MDEC
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'MD-MONTGOMERY-MDEC', 2, 'Montgomery County MDEC', 'format_check',
        'personal_injury', 'complaint',
        'state', 'MD', 'Montgomery', 'Circuit Court',
        '{"requires_efiling": true, "system": "MDEC", "effective_date": "2021-10-25"}'::jsonb,
        'error', montgomery_mdec_id, 'document_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id,
        review_status = EXCLUDED.review_status;

    -- Baltimore County MDEC
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'MD-BALTIMORE-CO-MDEC', 2, 'Baltimore County MDEC', 'format_check',
        'personal_injury', 'complaint',
        'state', 'MD', 'Baltimore County', 'Circuit Court',
        '{"requires_efiling": true, "system": "MDEC", "effective_date": "2019-05-14"}'::jsonb,
        'error', baltimore_co_mdec_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Prince George's County MDEC
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'MD-PG-MDEC', 2, 'Prince Georges County MDEC', 'format_check',
        'personal_injury', 'complaint',
        'state', 'MD', 'Prince Georges', 'Circuit Court',
        '{"requires_efiling": true, "system": "MDEC", "effective_date": "2022-10-17"}'::jsonb,
        'error', pg_mdec_id, 'document_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id,
        review_status = EXCLUDED.review_status;

    -- Anne Arundel County MDEC (First MDEC county)
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'MD-ANNE-ARUNDEL-MDEC', 2, 'Anne Arundel County MDEC', 'format_check',
        'personal_injury', 'complaint',
        'state', 'MD', 'Anne Arundel', 'Circuit Court',
        '{"requires_efiling": true, "system": "MDEC", "effective_date": "2014-10-14", "first_mdec_county": true}'::jsonb,
        'error', anne_arundel_mdec_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Baltimore City MDEC (Final MDEC county)
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'MD-BALTIMORE-CITY-MDEC', 2, 'Baltimore City MDEC', 'format_check',
        'personal_injury', 'complaint',
        'state', 'MD', 'Baltimore City', 'Circuit Court',
        '{"requires_efiling": true, "system": "MDEC", "effective_date": "2024-05-06", "final_mdec_county": true}'::jsonb,
        'error', baltimore_city_mdec_id, 'document_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id,
        review_status = EXCLUDED.review_status;

END $$;

COMMIT;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Show MD legal sources
SELECT 
    jurisdiction_type,
    CASE 
        WHEN jurisdiction_county IS NOT NULL THEN jurisdiction_county
        ELSE 'STATE'
    END as location,
    name,
    abbreviation
FROM leverage.legal_sources
WHERE jurisdiction_state = 'MD'
ORDER BY jurisdiction_type, location;

-- Show MD citations
SELECT 
    ls.jurisdiction_county as county,
    rc.citation,
    rc.verifier,
    rc.confidence_level
FROM leverage.rule_citations rc
JOIN leverage.legal_sources ls ON rc.legal_source_id = ls.id
WHERE ls.jurisdiction_state = 'MD'
ORDER BY ls.jurisdiction_county NULLS FIRST, rc.citation;

-- Show MD validation rules
SELECT 
    rule_name,
    validator_name,
    severity,
    jurisdiction_county,
    review_status
FROM leverage.validation_rules
WHERE jurisdiction_state = 'MD'
ORDER BY jurisdiction_county NULLS FIRST, rule_name;

-- Verify no missing citations
SELECT COUNT(*) as rules_without_citations
FROM leverage.validation_rules vr
WHERE vr.jurisdiction_state = 'MD'
AND vr.citation_id IS NULL;

-- Show MDEC implementation timeline
SELECT 
    rule_name,
    jurisdiction_county,
    validator_config->>'effective_date' as mdec_effective_date
FROM leverage.validation_rules
WHERE jurisdiction_state = 'MD' 
AND rule_name LIKE '%MDEC%'
ORDER BY validator_config->>'effective_date';
