-- ============================================================================
-- Colorado County-Specific PI Court Rules Seed
-- ============================================================================
-- Version: 1.0.0
-- Date: January 30, 2026
-- Purpose: Add Colorado county-level court rules with verified citations
-- High-volume PI counties: Denver, Arapahoe, Jefferson, Adams, El Paso
-- IMPORTANT: Colorado has 2-year SOL for most PI, but 3-year for motor vehicle
-- Data Due Diligence: Citations verified from colorado.public.law and courts.state.co.us
-- ============================================================================

BEGIN;

-- ============================================================================
-- PART 1: ADD COLORADO STATE AND COUNTY LEGAL SOURCES
-- ============================================================================

-- Colorado State-level Sources
INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    ('state', 'CO', NULL, NULL,
     'Colorado Revised Statutes',
     'Colorado General Assembly',
     'C.R.S.',
     'https://leg.colorado.gov/colorado-revised-statutes',
     'statute',
     'high',
     'Official statutory code for Colorado'),
    ('state', 'CO', NULL, NULL,
     'Colorado Rules of Civil Procedure',
     'Colorado Supreme Court',
     'C.R.C.P.',
     'https://www.courts.state.co.us/Courts/Supreme_Court/Rule_Changes.cfm',
     'court_rule',
     'high',
     'Statewide civil procedure rules'),
    ('state', 'CO', NULL, NULL,
     'Colorado Rules of Civil Procedure Rule 121 Section 1-26',
     'Colorado Supreme Court',
     'C.R.C.P. 121 § 1-26',
     'https://www.courts.state.co.us/userfiles/File/Administration/JBITS/New_CRCP_121_1-26_January_2006.pdf',
     'court_rule',
     'high',
     'Statewide electronic filing and service rules')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET base_url = EXCLUDED.base_url;

-- Colorado County Sources (Major PI Jurisdictions)
INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    ('county', 'CO', 'Denver', 'District Court',
     'Denver District Court Local Rules',
     'Denver District Court - 2nd Judicial District',
     'Denver L.R.',
     'https://www.coloradojudicial.gov/media/1520',
     'court_rule',
     'high',
     'Local rules - mandatory e-filing since January 1, 2010'),
    ('county', 'CO', 'Arapahoe', 'District Court',
     'Arapahoe County District Court Local Rules',
     'Arapahoe County District Court - 18th Judicial District',
     'Arapahoe L.R.',
     'https://www.courts.state.co.us/Courts/District/Index.cfm?District_ID=18',
     'court_rule',
     'high',
     'Local rules - 18th Judicial District'),
    ('county', 'CO', 'Jefferson', 'District Court',
     'Jefferson County District Court Local Rules',
     'Jefferson County District Court - 1st Judicial District',
     'Jefferson L.R.',
     'https://www.courts.state.co.us/Courts/District/Index.cfm?District_ID=1',
     'court_rule',
     'high',
     'Local rules - 1st Judicial District'),
    ('county', 'CO', 'Adams', 'District Court',
     'Adams County District Court Local Rules',
     'Adams County District Court - 17th Judicial District',
     'Adams L.R.',
     'https://www.courts.state.co.us/Courts/District/Index.cfm?District_ID=17',
     'court_rule',
     'high',
     'Local rules - 17th Judicial District'),
    ('county', 'CO', 'El Paso', 'District Court',
     'El Paso County District Court Local Rules',
     'El Paso County District Court - 4th Judicial District',
     'El Paso L.R.',
     'https://www.elpasoco.com/4th-judicial-district/',
     'court_rule',
     'high',
     'Local rules - 4th Judicial District')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET base_url = EXCLUDED.base_url;

-- ============================================================================
-- PART 2: ADD COLORADO STATE AND COUNTY CITATIONS
-- ============================================================================

DO $$
DECLARE
    co_crs_id INTEGER;
    co_crcp_id INTEGER;
    co_crcp121_id INTEGER;
    denver_id INTEGER;
    arapahoe_id INTEGER;
    jefferson_id INTEGER;
    adams_id INTEGER;
    el_paso_id INTEGER;
BEGIN
    -- Get legal source IDs
    SELECT id INTO co_crs_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'CO' AND abbreviation = 'C.R.S.';
    
    SELECT id INTO co_crcp_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'CO' AND abbreviation = 'C.R.C.P.';
    
    SELECT id INTO co_crcp121_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'CO' AND abbreviation = 'C.R.C.P. 121 § 1-26';
    
    SELECT id INTO denver_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'CO' AND jurisdiction_county = 'Denver';
    
    SELECT id INTO arapahoe_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'CO' AND jurisdiction_county = 'Arapahoe';
    
    SELECT id INTO jefferson_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'CO' AND jurisdiction_county = 'Jefferson';
    
    SELECT id INTO adams_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'CO' AND jurisdiction_county = 'Adams';
    
    SELECT id INTO el_paso_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'CO' AND jurisdiction_county = 'El Paso';

    -- C.R.S. § 13-80-102 - General Limitation (2 years for tort)
    -- DOCUMENT VERIFIED: EXACT TEXT from colorado.public.law
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        co_crs_id, 'statute', 'Colorado Revised Statutes',
        'C.R.S. § 13-80-102',
        'https://colorado.public.law/statutes/crs_13-80-102',
        'The following civil actions, regardless of the theory upon which suit is brought, or against whom suit is brought, must be commenced within two years after the cause of action accrues, and not thereafter: (a) Tort actions, including but not limited to actions for negligence, trespass, malicious abuse of process, malicious prosecution, outrageous conduct, interference with relationships, and tortious breach of contract.',
        '§ 13-80-102', '2026-01-01', NOW(), 'document_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        verifier = EXCLUDED.verifier;

    -- C.R.S. § 13-80-101(1)(n) - Motor Vehicle Exception (3 years)
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        co_crs_id, 'statute', 'Colorado Revised Statutes',
        'C.R.S. § 13-80-101(1)(n)',
        'https://colorado.public.law/statutes/crs_13-80-101',
        'The following civil actions shall be commenced within three years after the cause of action accrues: (n) All actions for injury to the person founded upon tort, resulting from the use or operation of a motor vehicle.',
        '§ 13-80-101(1)(n)', '2026-01-01', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- C.R.C.P. 121 Section 1-26 - Electronic Filing
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        co_crcp121_id, 'court_rule', 'Colorado Rules of Civil Procedure Rule 121 Section 1-26',
        'C.R.C.P. 121 § 1-26',
        'https://www.courts.state.co.us/userfiles/File/Administration/JBITS/New_CRCP_121_1-26_January_2006.pdf',
        'E-Filing allows for the electronic submission of documents to the court. E-Filing is complete when the document is transmitted to and acknowledged by the E-System by 11:59 p.m. Colorado time. The E-System is mandatory for attorneys in certain districts.',
        'Rule 121 § 1-26', '2006-01-01', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Denver District Court Mandatory E-Filing - WEB VERIFIED
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        denver_id, 'local_rule', 'Denver District Court Local Rules',
        'Denver District Court Mandatory E-Filing Order',
        'https://www.coloradojudicial.gov/media/1520',
        'Effective January 1, 2010, all pleadings, motions, and documents must be filed electronically using the electronic filing system. Paper filings will not be accepted and will incur a $50 fee for scanning if submitted.',
        'E-Filing Order', '2010-01-01', NOW(), 'document_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        verifier = EXCLUDED.verifier;

    -- Arapahoe County E-Filing
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        arapahoe_id, 'local_rule', 'Arapahoe County District Court Local Rules',
        'Arapahoe County E-Filing',
        'https://www.courts.state.co.us/Courts/District/Index.cfm?District_ID=18',
        'Arapahoe County District Court (18th Judicial District) requires e-filing through Colorado Courts E-Filing (CCE) system for civil cases.',
        'E-Filing', '2026-01-01', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Jefferson County E-Filing
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        jefferson_id, 'local_rule', 'Jefferson County District Court Local Rules',
        'Jefferson County E-Filing',
        'https://www.courts.state.co.us/Courts/District/Index.cfm?District_ID=1',
        'Jefferson County District Court (1st Judicial District) requires all licensed attorneys to electronically file and serve documents through the Colorado Courts E-Filing (CCE) system.',
        'E-Filing', '2026-01-01', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Adams County E-Filing
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        adams_id, 'local_rule', 'Adams County District Court Local Rules',
        'Adams County E-Filing',
        'https://www.courts.state.co.us/Courts/District/Index.cfm?District_ID=17',
        'Adams County District Court (17th Judicial District) requires e-filing through Colorado Courts E-Filing (CCE) system for civil cases.',
        'E-Filing', '2026-01-01', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- El Paso County E-Filing
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        el_paso_id, 'local_rule', 'El Paso County District Court Local Rules',
        'El Paso County E-Filing',
        'https://www.elpasoco.com/4th-judicial-district/',
        'El Paso County District Court (4th Judicial District) requires mandatory e-filing for civil cases through the Colorado Courts E-Filing system.',
        'E-Filing', '2026-01-01', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

END $$;

-- ============================================================================
-- PART 3: ADD COLORADO VALIDATION RULES
-- ============================================================================

DO $$
DECLARE
    co_sol_2yr_id INTEGER;
    co_sol_3yr_mv_id INTEGER;
    co_crcp121_id INTEGER;
    denver_efile_id INTEGER;
    arapahoe_efile_id INTEGER;
    jefferson_efile_id INTEGER;
    adams_efile_id INTEGER;
    el_paso_efile_id INTEGER;
BEGIN
    -- Get citation IDs
    SELECT id INTO co_sol_2yr_id FROM leverage.rule_citations 
    WHERE citation = 'C.R.S. § 13-80-102';
    
    SELECT id INTO co_sol_3yr_mv_id FROM leverage.rule_citations 
    WHERE citation = 'C.R.S. § 13-80-101(1)(n)';
    
    SELECT id INTO co_crcp121_id FROM leverage.rule_citations 
    WHERE citation = 'C.R.C.P. 121 § 1-26';
    
    SELECT id INTO denver_efile_id FROM leverage.rule_citations 
    WHERE citation = 'Denver District Court Mandatory E-Filing Order';
    
    SELECT id INTO arapahoe_efile_id FROM leverage.rule_citations 
    WHERE citation = 'Arapahoe County E-Filing';
    
    SELECT id INTO jefferson_efile_id FROM leverage.rule_citations 
    WHERE citation = 'Jefferson County E-Filing';
    
    SELECT id INTO adams_efile_id FROM leverage.rule_citations 
    WHERE citation = 'Adams County E-Filing';
    
    SELECT id INTO el_paso_efile_id FROM leverage.rule_citations 
    WHERE citation = 'El Paso County E-Filing';

    -- CO Statewide PI SOL (2 years - General Tort)
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'CO-SOL-13-80-102-PI-2YEAR', 5, 'CO General Tort SOL (2 Years)', 'threshold_check',
        'personal_injury', 'complaint',
        'state', 'CO', NULL, NULL,
        '{"sol_years": 2, "sol_days": 730, "note": "Does NOT apply to motor vehicle PI - see 13-80-101(1)(n) for 3-year SOL"}'::jsonb,
        'error', co_sol_2yr_id, 'document_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id,
        review_status = EXCLUDED.review_status;

    -- CO Motor Vehicle PI SOL (3 years - Exception)
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'CO-SOL-13-80-101-MV-3YEAR', 5, 'CO Motor Vehicle PI SOL (3 Years)', 'threshold_check',
        'personal_injury', 'complaint',
        'state', 'CO', NULL, NULL,
        '{"sol_years": 3, "sol_days": 1095, "applies_to": "motor_vehicle", "note": "Applies to injury resulting from use or operation of a motor vehicle"}'::jsonb,
        'error', co_sol_3yr_mv_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- CO Statewide E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'CO-CRCP121-EFILE', 2, 'CO E-Filing Rule', 'format_check',
        'personal_injury', 'complaint',
        'state', 'CO', NULL, NULL,
        '{"efiling_authorized": true, "system": "CCE", "deadline": "11:59 PM Colorado time", "attorneys_mandatory": true}'::jsonb,
        'warning', co_crcp121_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Denver District Court Mandatory E-Filing
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'CO-DENVER-EFILE', 2, 'Denver District Court E-Filing', 'format_check',
        'personal_injury', 'complaint',
        'state', 'CO', 'Denver', 'District Court',
        '{"requires_efiling": true, "system": "CCE", "effective_date": "2010-01-01", "paper_fee": 50}'::jsonb,
        'error', denver_efile_id, 'document_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id,
        review_status = EXCLUDED.review_status;

    -- Arapahoe County E-Filing
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'CO-ARAPAHOE-EFILE', 2, 'Arapahoe County E-Filing', 'format_check',
        'personal_injury', 'complaint',
        'state', 'CO', 'Arapahoe', 'District Court',
        '{"requires_efiling": true, "system": "CCE", "district": "18th Judicial District"}'::jsonb,
        'error', arapahoe_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Jefferson County E-Filing
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'CO-JEFFERSON-EFILE', 2, 'Jefferson County E-Filing', 'format_check',
        'personal_injury', 'complaint',
        'state', 'CO', 'Jefferson', 'District Court',
        '{"requires_efiling": true, "system": "CCE", "district": "1st Judicial District"}'::jsonb,
        'error', jefferson_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Adams County E-Filing
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'CO-ADAMS-EFILE', 2, 'Adams County E-Filing', 'format_check',
        'personal_injury', 'complaint',
        'state', 'CO', 'Adams', 'District Court',
        '{"requires_efiling": true, "system": "CCE", "district": "17th Judicial District"}'::jsonb,
        'error', adams_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- El Paso County E-Filing
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'CO-EL-PASO-EFILE', 2, 'El Paso County E-Filing', 'format_check',
        'personal_injury', 'complaint',
        'state', 'CO', 'El Paso', 'District Court',
        '{"requires_efiling": true, "system": "CCE", "district": "4th Judicial District"}'::jsonb,
        'error', el_paso_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

END $$;

COMMIT;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Show CO legal sources
SELECT 
    jurisdiction_type,
    CASE 
        WHEN jurisdiction_county IS NOT NULL THEN jurisdiction_county
        ELSE 'STATE'
    END as location,
    name,
    abbreviation
FROM leverage.legal_sources
WHERE jurisdiction_state = 'CO'
ORDER BY jurisdiction_type, location;

-- Show CO citations
SELECT 
    ls.jurisdiction_county as county,
    rc.citation,
    rc.verifier,
    rc.confidence_level
FROM leverage.rule_citations rc
JOIN leverage.legal_sources ls ON rc.legal_source_id = ls.id
WHERE ls.jurisdiction_state = 'CO'
ORDER BY ls.jurisdiction_county NULLS FIRST, rc.citation;

-- Show CO validation rules
SELECT 
    rule_name,
    validator_name,
    severity,
    jurisdiction_county,
    review_status
FROM leverage.validation_rules
WHERE jurisdiction_state = 'CO'
ORDER BY jurisdiction_county NULLS FIRST, rule_name;

-- Verify no missing citations
SELECT COUNT(*) as rules_without_citations
FROM leverage.validation_rules vr
WHERE vr.jurisdiction_state = 'CO'
AND vr.citation_id IS NULL;

-- IMPORTANT: Show Colorado SOL distinction
SELECT 
    rule_name,
    validator_name,
    validator_config->>'sol_years' as sol_years,
    validator_config->>'note' as note
FROM leverage.validation_rules
WHERE jurisdiction_state = 'CO' 
AND rule_name LIKE '%SOL%'
ORDER BY rule_name;
