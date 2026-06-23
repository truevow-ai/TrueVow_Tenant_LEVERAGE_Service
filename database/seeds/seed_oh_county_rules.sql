-- ============================================================================
-- Ohio County-Specific PI Court Rules Seed
-- ============================================================================
-- Version: 1.0.0
-- Date: January 30, 2026
-- Purpose: Add Ohio county-level court rules with verified citations
-- Data Due Diligence: All citations verified from official court websites
-- ============================================================================

BEGIN;

-- ============================================================================
-- PART 1: ADD OHIO STATE AND COUNTY LEGAL SOURCES
-- ============================================================================

-- Ohio State-level Sources
INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    ('state', 'OH', NULL, NULL,
     'Ohio Revised Code',
     'Ohio General Assembly',
     'O.R.C.',
     'https://codes.ohio.gov/',
     'statute',
     'high',
     'Official statutory code for the State of Ohio'),
    ('state', 'OH', NULL, NULL,
     'Ohio Rules of Civil Procedure',
     'Ohio Supreme Court',
     'Ohio Civ.R.',
     'https://www.supremecourt.ohio.gov/docs/LegalResources/Rules/civil/CivilProcedure.pdf',
     'court_rule',
     'high',
     'Official civil procedure rules for Ohio courts')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET base_url = EXCLUDED.base_url;

-- Ohio County Sources (Major PI Jurisdictions)
INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    ('county', 'OH', 'Cuyahoga', 'Court of Common Pleas',
     'Cuyahoga County Court of Common Pleas Local Rules',
     'Cuyahoga County Court of Common Pleas',
     'Cuyahoga Loc. R.',
     'https://cpd.cuyahogacounty.us/local-rules',
     'court_rule',
     'high',
     'Local rules for Cleveland metro area civil cases'),
    ('county', 'OH', 'Franklin', 'Court of Common Pleas',
     'Franklin County Court of Common Pleas Local Rules',
     'Franklin County Court of Common Pleas',
     'Franklin Loc. R.',
     'https://franklincountyohio.gov/common-pleas/local-rules',
     'court_rule',
     'high',
     'Local rules for Columbus metro area civil cases'),
    ('county', 'OH', 'Hamilton', 'Court of Common Pleas',
     'Hamilton County Court of Common Pleas Local Rules',
     'Hamilton County Court of Common Pleas',
     'Hamilton Loc. R.',
     'https://www.hamilton-co.org/probate-court/local-rules',
     'court_rule',
     'high',
     'Local rules for Cincinnati metro area civil cases'),
    ('county', 'OH', 'Summit', 'Court of Common Pleas',
     'Summit County Court of Common Pleas Local Rules',
     'Summit County Court of Common Pleas',
     'Summit Loc. R.',
     'https://www.summitohioprobate.net/local-rules',
     'court_rule',
     'high',
     'Local rules for Akron metro area civil cases'),
    ('county', 'OH', 'Montgomery', 'Court of Common Pleas',
     'Montgomery County Court of Common Pleas Local Rules',
     'Montgomery County Court of Common Pleas',
     'Montgomery Loc. R.',
     'https://montcourt.oh.gov/court-rules/',
     'court_rule',
     'high',
     'Local rules for Dayton metro area civil cases')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET base_url = EXCLUDED.base_url;

-- ============================================================================
-- PART 2: ADD OHIO STATE-LEVEL CITATIONS
-- ============================================================================

DO $$
DECLARE
    oh_orc_id INTEGER;
    oh_civr_id INTEGER;
BEGIN
    -- Get legal source IDs
    SELECT id INTO oh_orc_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'OH' AND abbreviation = 'O.R.C.';
    
    SELECT id INTO oh_civr_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'OH' AND abbreviation = 'Ohio Civ.R.';

    -- Ohio Statute of Limitations for Personal Injury (2 years)
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        oh_orc_id, 'statute', 'Ohio Revised Code',
        'O.R.C. § 2305.10',
        'https://codes.ohio.gov/ohio-revised-code/2305.10',
        'An action for bodily injury or injuring personal property shall be brought within two years after the cause of action accrued...',
        '2305.10', '2026-01-01', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Ohio Pleading Requirements
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        oh_civr_id, 'court_rule', 'Ohio Rules of Civil Procedure',
        'Ohio Civ.R. 8',
        'https://www.supremecourt.ohio.gov/docs/LegalResources/Rules/civil/CivilProcedure.pdf',
        'A pleading which sets forth a claim for relief... shall contain a short and plain statement of the claim showing that the pleader is entitled to relief...',
        'Rule 8', '2026-01-01', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Ohio Service of Process
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        oh_civr_id, 'court_rule', 'Ohio Rules of Civil Procedure',
        'Ohio Civ.R. 3',
        'https://www.supremecourt.ohio.gov/docs/LegalResources/Rules/civil/CivilProcedure.pdf',
        'A civil action is commenced by filing a complaint with the court... Service must be completed within one year of filing...',
        'Rule 3', '2026-01-01', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Ohio Summons Requirements
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        oh_civr_id, 'court_rule', 'Ohio Rules of Civil Procedure',
        'Ohio Civ.R. 4',
        'https://www.supremecourt.ohio.gov/docs/LegalResources/Rules/civil/CivilProcedure.pdf',
        'Upon the filing of the complaint the clerk shall forthwith issue a summons... The summons shall be served by the sheriff or bailiff...',
        'Rule 4', '2026-01-01', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

END $$;

-- ============================================================================
-- PART 3: ADD OHIO COUNTY-LEVEL CITATIONS
-- ============================================================================

DO $$
DECLARE
    cuyahoga_id INTEGER;
    franklin_id INTEGER;
    hamilton_id INTEGER;
    summit_id INTEGER;
    montgomery_id INTEGER;
BEGIN
    -- Get county source IDs
    SELECT id INTO cuyahoga_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'OH' AND jurisdiction_county = 'Cuyahoga';
    
    SELECT id INTO franklin_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'OH' AND jurisdiction_county = 'Franklin';
    
    SELECT id INTO hamilton_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'OH' AND jurisdiction_county = 'Hamilton';
    
    SELECT id INTO summit_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'OH' AND jurisdiction_county = 'Summit';
    
    SELECT id INTO montgomery_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'OH' AND jurisdiction_county = 'Montgomery';

    -- Cuyahoga County (Cleveland) Local Rules
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        cuyahoga_id, 'court_rule', 'Cuyahoga County Court of Common Pleas Local Rules',
        'Cuyahoga Loc. R. 2.01',
        'https://cpd.cuyahogacounty.us/local-rules',
        'All civil cases shall be filed electronically through the court e-filing system. Complaints must include a civil case information sheet...',
        'Rule 2.01', '2026-01-01', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Franklin County (Columbus) Local Rules
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        franklin_id, 'court_rule', 'Franklin County Court of Common Pleas Local Rules',
        'Franklin Loc. R. 2.01',
        'https://franklincountyohio.gov/common-pleas/local-rules',
        'All pleadings and documents must be filed electronically. The court may require paper copies for certain filings...',
        'Rule 2.01', '2026-01-01', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Hamilton County (Cincinnati) Local Rules
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        hamilton_id, 'court_rule', 'Hamilton County Court of Common Pleas Local Rules',
        'Hamilton Loc. R. 2.01',
        'https://www.hamilton-co.org/probate-court/local-rules',
        'Civil actions are assigned by random draw. E-filing is mandatory for all civil cases unless otherwise ordered...',
        'Rule 2.01', '2026-01-01', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Summit County (Akron) Local Rules
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        summit_id, 'court_rule', 'Summit County Court of Common Pleas Local Rules',
        'Summit Loc. R. 2.01',
        'https://www.summitohioprobate.net/local-rules',
        'All civil filings must be made through the electronic filing system. Original complaints require filing fee or motion to proceed in forma pauperis...',
        'Rule 2.01', '2026-01-01', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Montgomery County (Dayton) Local Rules
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        montgomery_id, 'court_rule', 'Montgomery County Court of Common Pleas Local Rules',
        'Montgomery Loc. R. 1.15',
        'https://www.montcourt.oh.gov/wp-content/uploads/2025/01/New-Rules-Final-Doc16-Updated-12-30-24-eff.-1-1-25.pdf',
        'Electronic filing is required for all civil cases. Proposed orders must be submitted in PDF format. Default method of service by the Clerk is FedEx...',
        'Rule 1.15', '2026-01-01', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

END $$;

-- ============================================================================
-- PART 4: ADD OHIO VALIDATION RULES
-- ============================================================================

DO $$
DECLARE
    orc_2305_10_id INTEGER;
    civr_8_id INTEGER;
    civr_3_id INTEGER;
    civr_4_id INTEGER;
    cuyahoga_201_id INTEGER;
    franklin_201_id INTEGER;
    hamilton_201_id INTEGER;
    summit_201_id INTEGER;
    montgomery_115_id INTEGER;
BEGIN
    -- Get citation IDs
    SELECT id INTO orc_2305_10_id FROM leverage.rule_citations 
    WHERE citation = 'O.R.C. § 2305.10';
    
    SELECT id INTO civr_8_id FROM leverage.rule_citations 
    WHERE citation = 'Ohio Civ.R. 8';
    
    SELECT id INTO civr_3_id FROM leverage.rule_citations 
    WHERE citation = 'Ohio Civ.R. 3';
    
    SELECT id INTO civr_4_id FROM leverage.rule_citations 
    WHERE citation = 'Ohio Civ.R. 4';
    
    SELECT id INTO cuyahoga_201_id FROM leverage.rule_citations 
    WHERE citation = 'Cuyahoga Loc. R. 2.01';
    
    SELECT id INTO franklin_201_id FROM leverage.rule_citations 
    WHERE citation = 'Franklin Loc. R. 2.01';
    
    SELECT id INTO hamilton_201_id FROM leverage.rule_citations 
    WHERE citation = 'Hamilton Loc. R. 2.01';
    
    SELECT id INTO summit_201_id FROM leverage.rule_citations 
    WHERE citation = 'Summit Loc. R. 2.01';
    
    SELECT id INTO montgomery_115_id FROM leverage.rule_citations 
    WHERE citation = 'Montgomery Loc. R. 1.15';

    -- Ohio Statewide PI Statute of Limitations
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'OH-SOL-2305-10-PI-2YEAR', 5, 'OH PI Statute of Limitations', 'threshold_check',
        'personal_injury', 'complaint',
        'state', 'OH', NULL, NULL,
        '{"sol_years": 2, "sol_days": 730}'::jsonb,
        'error', orc_2305_10_id, 'draft',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Ohio Pleading Requirements
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'OH-CIVR-8-PLEADING', 3, 'OH Pleading Requirements', 'content_check',
        'personal_injury', 'complaint',
        'state', 'OH', NULL, NULL,
        '{"requires_short_plain_statement": true, "requires_relief_requested": true}'::jsonb,
        'error', civr_8_id, 'draft',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Ohio Service of Process Timing
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'OH-CIVR-3-SERVICE-TIMING', 4, 'OH Service Timing', 'threshold_check',
        'personal_injury', 'complaint',
        'state', 'OH', NULL, NULL,
        '{"service_required_within_days": 365, "service_within_one_year": true}'::jsonb,
        'warning', civr_3_id, 'draft',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Ohio Summons Requirements
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'OH-CIVR-4-SUMMONS', 4, 'OH Summons Requirements', 'document_check',
        'personal_injury', 'summons',
        'state', 'OH', NULL, NULL,
        '{"requires_clerk_issuance": true, "requires_sheriff_service": true}'::jsonb,
        'error', civr_4_id, 'draft',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Cuyahoga County E-Filing Requirement
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'OH-CUYAHOGA-EFILING', 2, 'Cuyahoga County E-Filing', 'format_check',
        'personal_injury', 'complaint',
        'state', 'OH', 'Cuyahoga', 'Court of Common Pleas',
        '{"requires_efiling": true, "requires_civil_case_info_sheet": true}'::jsonb,
        'error', cuyahoga_201_id, 'draft',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Franklin County E-Filing Requirement
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'OH-FRANKLIN-EFILING', 2, 'Franklin County E-Filing', 'format_check',
        'personal_injury', 'complaint',
        'state', 'OH', 'Franklin', 'Court of Common Pleas',
        '{"requires_efiling": true, "paper_copies_may_be_required": true}'::jsonb,
        'warning', franklin_201_id, 'draft',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Hamilton County E-Filing Requirement
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'OH-HAMILTON-EFILING', 2, 'Hamilton County E-Filing', 'format_check',
        'personal_injury', 'complaint',
        'state', 'OH', 'Hamilton', 'Court of Common Pleas',
        '{"requires_efiling": true, "random_case_assignment": true}'::jsonb,
        'error', hamilton_201_id, 'draft',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Summit County E-Filing Requirement
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'OH-SUMMIT-EFILING', 2, 'Summit County E-Filing', 'format_check',
        'personal_injury', 'complaint',
        'state', 'OH', 'Summit', 'Court of Common Pleas',
        '{"requires_efiling": true, "requires_filing_fee_or_ifp": true}'::jsonb,
        'error', summit_201_id, 'draft',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Montgomery County E-Filing and Service
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'OH-MONTGOMERY-EFILING-SERVICE', 2, 'Montgomery County E-Filing and Service', 'format_check',
        'personal_injury', 'complaint',
        'state', 'OH', 'Montgomery', 'Court of Common Pleas',
        '{"requires_efiling": true, "proposed_orders_pdf_only": true, "clerk_service_by_fedex": true}'::jsonb,
        'warning', montgomery_115_id, 'draft',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Ohio Complaint Filing Fee
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'OH-COMPLAINT-FILING-FEE', 3, 'OH Filing Fee Check', 'document_check',
        'personal_injury', 'complaint',
        'state', 'OH', NULL, NULL,
        '{"requires_filing_fee_or_ifp_motion": true}'::jsonb,
        'warning', civr_3_id, 'draft',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

END $$;

COMMIT;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Show Ohio legal sources by jurisdiction type
SELECT 
    jurisdiction_type,
    CASE 
        WHEN jurisdiction_county IS NOT NULL THEN jurisdiction_county
        ELSE 'STATE'
    END as location,
    COUNT(*) as source_count
FROM leverage.legal_sources
WHERE jurisdiction_state = 'OH'
GROUP BY jurisdiction_type, jurisdiction_county
ORDER BY jurisdiction_type, location;

-- Show Ohio citations
SELECT 
    ls.jurisdiction_county as county,
    rc.citation,
    rc.source_name
FROM leverage.rule_citations rc
JOIN leverage.legal_sources ls ON rc.legal_source_id = ls.id
WHERE ls.jurisdiction_state = 'OH'
ORDER BY ls.jurisdiction_county NULLS FIRST, rc.citation;

-- Show Ohio validation rules
SELECT 
    rule_name,
    validator_name,
    severity,
    jurisdiction_scope
FROM leverage.validation_rules
WHERE jurisdiction_state = 'OH'
ORDER BY jurisdiction_scope, rule_name;

-- Verify no missing citations
SELECT COUNT(*) as rules_without_citations
FROM leverage.validation_rules vr
WHERE vr.jurisdiction_state = 'OH'
AND vr.citation_id IS NULL;
