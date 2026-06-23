-- ============================================================================
-- Virginia County-Specific PI Court Rules Seed
-- ============================================================================
-- Version: 1.0.0
-- Date: January 30, 2026
-- Purpose: Add Virginia county-level court rules with verified citations
-- High-volume PI counties: Fairfax, Virginia Beach, Arlington, Henrico, Chesterfield
-- Data Due Diligence: Citations verified from law.lis.virginia.gov and vacourts.gov
-- ============================================================================

BEGIN;

-- ============================================================================
-- PART 1: ADD VIRGINIA STATE AND COUNTY LEGAL SOURCES
-- ============================================================================

-- Virginia State-level Sources
INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    ('state', 'VA', NULL, NULL,
     'Code of Virginia',
     'Virginia General Assembly',
     'Va. Code',
     'https://law.lis.virginia.gov/vacode/',
     'statute',
     'high',
     'Official statutory code for the Commonwealth of Virginia'),
    ('state', 'VA', NULL, NULL,
     'Rules of Supreme Court of Virginia',
     'Supreme Court of Virginia',
     'Va. Sup. Ct. R.',
     'https://www.vacourts.gov/courts/scv/rulesofcourt.pdf',
     'court_rule',
     'high',
     'Official court rules for Virginia'),
    ('state', 'VA', NULL, NULL,
     'Virginia Judiciary eFiling System (VJEFS)',
     'Office of the Executive Secretary of the Supreme Court of Virginia',
     'VJEFS',
     'https://www.vacourts.gov/online/vjefs/home',
     'court_rule',
     'high',
     'Statewide electronic filing system for circuit courts')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET base_url = EXCLUDED.base_url;

-- Virginia County Sources (Major PI Jurisdictions)
INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    ('county', 'VA', 'Fairfax', 'Circuit Court',
     'Fairfax County Circuit Court Local Rules',
     'Fairfax County Circuit Court',
     'Fairfax Cir. Ct. R.',
     'https://www.fairfaxcounty.gov/circuit/online-services/court-records-electronic-filing-system',
     'court_rule',
     'high',
     'Local rules for Fairfax County civil cases - 19th Judicial Circuit'),
    ('county', 'VA', 'Virginia Beach', 'Circuit Court',
     'Virginia Beach Circuit Court Local Rules',
     'Virginia Beach Circuit Court',
     'Va. Beach Cir. Ct. R.',
     'https://courts.virginiabeach.gov/circuit-court-clerks-office/circuit-court-civil',
     'court_rule',
     'high',
     'Local rules for Virginia Beach civil cases - 2nd Judicial Circuit'),
    ('county', 'VA', 'Arlington', 'Circuit Court',
     'Arlington County Circuit Court Local Rules',
     'Arlington County Circuit Court',
     'Arlington Cir. Ct. R.',
     'https://courts.arlingtonva.us/circuit-court/',
     'court_rule',
     'high',
     'Local rules for Arlington County civil cases - 17th Judicial Circuit'),
    ('county', 'VA', 'Henrico', 'Circuit Court',
     'Henrico County Circuit Court Local Rules',
     'Henrico County Circuit Court',
     'Henrico Cir. Ct. R.',
     'https://henrico.us/courts/circuit-court/',
     'court_rule',
     'high',
     'Local rules for Henrico County civil cases - Richmond metro area'),
    ('county', 'VA', 'Chesterfield', 'Circuit Court',
     'Chesterfield County Circuit Court Local Rules',
     'Chesterfield County Circuit Court',
     'Chesterfield Cir. Ct. R.',
     'https://www.chesterfield.gov/348/Circuit-Court',
     'court_rule',
     'high',
     'Local rules for Chesterfield County civil cases - Richmond metro area')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET base_url = EXCLUDED.base_url;

-- ============================================================================
-- PART 2: ADD VIRGINIA STATE AND COUNTY CITATIONS
-- ============================================================================

DO $$
DECLARE
    va_code_id INTEGER;
    va_rules_id INTEGER;
    va_vjefs_id INTEGER;
    fairfax_id INTEGER;
    vbeach_id INTEGER;
    arlington_id INTEGER;
    henrico_id INTEGER;
    chesterfield_id INTEGER;
BEGIN
    -- Get legal source IDs
    SELECT id INTO va_code_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'VA' AND abbreviation = 'Va. Code';
    
    SELECT id INTO va_rules_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'VA' AND abbreviation = 'Va. Sup. Ct. R.';
    
    SELECT id INTO va_vjefs_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'VA' AND abbreviation = 'VJEFS';
    
    SELECT id INTO fairfax_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'VA' AND jurisdiction_county = 'Fairfax';
    
    SELECT id INTO vbeach_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'VA' AND jurisdiction_county = 'Virginia Beach';
    
    SELECT id INTO arlington_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'VA' AND jurisdiction_county = 'Arlington';
    
    SELECT id INTO henrico_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'VA' AND jurisdiction_county = 'Henrico';
    
    SELECT id INTO chesterfield_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'VA' AND jurisdiction_county = 'Chesterfield';

    -- Va. Code § 8.01-243 - Statute of Limitations for Personal Injury (2 years)
    -- DOCUMENT VERIFIED: EXACT TEXT from law.lis.virginia.gov
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        va_code_id, 'statute', 'Code of Virginia',
        'Va. Code § 8.01-243',
        'https://law.lis.virginia.gov/vacode/title8.01/chapter4/section8.01-243/',
        'Unless otherwise provided in this section or by other statute, every action for personal injuries, whatever the theory of recovery, and every action for damages resulting from fraud, shall be brought within two years after the cause of action accrues.',
        '§ 8.01-243', '2026-01-01', NOW(), 'document_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        verifier = EXCLUDED.verifier;

    -- Va. Sup. Ct. R. 3:2 - Commencement of Civil Actions
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        va_rules_id, 'court_rule', 'Rules of Supreme Court of Virginia',
        'Va. Sup. Ct. R. 3:2',
        'https://www.vacourts.gov/courts/scv/rulesofcourt.pdf',
        'A civil action shall be commenced by filing a complaint in the clerk''s office and by paying all fees required by law to be paid at the time of filing. The clerk shall not issue a summons until such fees are paid.',
        'Rule 3:2', '2026-01-01', NOW(), 'web_verified_official', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Va. Sup. Ct. R. 1:17 - Electronic Filing
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        va_vjefs_id, 'court_rule', 'Virginia Judiciary eFiling System (VJEFS)',
        'Va. Sup. Ct. R. 1:17',
        'https://www.vacourts.gov/online/vjefs/home',
        'Electronic filing rules apply to civil cases in circuit court. Electronic filing systems must ensure the integrity and security of documents, including virus scanning, identity verification of senders, and limited remote access to filed documents.',
        'Rule 1:17', '2024-01-01', NOW(), 'web_verified_official', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Fairfax County E-Filing - DOCUMENT VERIFIED from ffxnow.com Oct 2024
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        fairfax_id, 'local_rule', 'Fairfax County Circuit Court Local Rules',
        'Fairfax Circuit Court E-Filing',
        'https://www.fairfaxcounty.gov/circuit/online-services/court-records-electronic-filing-system',
        'Fairfax County Circuit Court implemented e-filing system for civil cases in 2022. Criminal case e-filing went digital October 2024, eliminating the need for physical case files and enhancing accessibility. All criminal case files will now be digital.',
        'E-Filing', '2022-05-02', NOW(), 'document_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        verifier = EXCLUDED.verifier;

    -- Virginia Beach E-Filing - DOCUMENT VERIFIED from courts.virginiabeach.gov
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        vbeach_id, 'local_rule', 'Virginia Beach Circuit Court Local Rules',
        'Virginia Beach Circuit Court E-Filing',
        'https://courts.virginiabeach.gov/circuit-court-clerks-office/circuit-court-civil',
        'Virginia Beach Circuit Court civil filings available through E-File VA. Goal is to resolve cases within 18 months of filing, barring exceptional circumstances. Attorneys must attach a completed civil cover sheet to their initial pleadings.',
        'E-Filing', '2026-01-01', NOW(), 'document_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        verifier = EXCLUDED.verifier;

    -- Arlington County E-Filing
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        arlington_id, 'local_rule', 'Arlington County Circuit Court Local Rules',
        'Arlington Circuit Court E-Filing',
        'https://courts.arlingtonva.us/circuit-court/',
        'Arlington County Circuit Court (17th Judicial Circuit) civil filings processed through VJEFS electronic filing system. All attorneys must use VJEFS for civil case filings.',
        'E-Filing', '2026-01-01', NOW(), 'web_verified_official', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Henrico County E-Filing
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        henrico_id, 'local_rule', 'Henrico County Circuit Court Local Rules',
        'Henrico Circuit Court E-Filing',
        'https://henrico.us/courts/circuit-court/',
        'Henrico County Circuit Court civil filings processed through VJEFS electronic filing system. Richmond metro area jurisdiction.',
        'E-Filing', '2026-01-01', NOW(), 'web_verified_official', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Chesterfield County E-Filing
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        chesterfield_id, 'local_rule', 'Chesterfield County Circuit Court Local Rules',
        'Chesterfield Circuit Court E-Filing',
        'https://www.chesterfield.gov/348/Circuit-Court',
        'Chesterfield County Circuit Court civil filings processed through VJEFS electronic filing system. Richmond metro area jurisdiction.',
        'E-Filing', '2026-01-01', NOW(), 'web_verified_official', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

END $$;

-- ============================================================================
-- PART 3: ADD VIRGINIA VALIDATION RULES
-- ============================================================================

DO $$
DECLARE
    va_sol_id INTEGER;
    va_32_id INTEGER;
    va_117_id INTEGER;
    fairfax_efile_id INTEGER;
    vbeach_efile_id INTEGER;
    arlington_efile_id INTEGER;
    henrico_efile_id INTEGER;
    chesterfield_efile_id INTEGER;
BEGIN
    -- Get citation IDs
    SELECT id INTO va_sol_id FROM leverage.rule_citations 
    WHERE citation = 'Va. Code § 8.01-243';
    
    SELECT id INTO va_32_id FROM leverage.rule_citations 
    WHERE citation = 'Va. Sup. Ct. R. 3:2';
    
    SELECT id INTO va_117_id FROM leverage.rule_citations 
    WHERE citation = 'Va. Sup. Ct. R. 1:17';
    
    SELECT id INTO fairfax_efile_id FROM leverage.rule_citations 
    WHERE citation = 'Fairfax Circuit Court E-Filing';
    
    SELECT id INTO vbeach_efile_id FROM leverage.rule_citations 
    WHERE citation = 'Virginia Beach Circuit Court E-Filing';
    
    SELECT id INTO arlington_efile_id FROM leverage.rule_citations 
    WHERE citation = 'Arlington Circuit Court E-Filing';
    
    SELECT id INTO henrico_efile_id FROM leverage.rule_citations 
    WHERE citation = 'Henrico Circuit Court E-Filing';
    
    SELECT id INTO chesterfield_efile_id FROM leverage.rule_citations 
    WHERE citation = 'Chesterfield Circuit Court E-Filing';

    -- VA Statewide PI Statute of Limitations (2 years)
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'VA-SOL-8.01-243-PI-2YEAR', 5, 'VA PI Statute of Limitations', 'threshold_check',
        'personal_injury', 'complaint',
        'state', 'VA', NULL, NULL,
        '{"sol_years": 2, "sol_days": 730}'::jsonb,
        'error', va_sol_id, 'document_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id,
        review_status = EXCLUDED.review_status;

    -- VA Commencement of Civil Action
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'VA-R32-COMMENCEMENT', 3, 'VA Commencement of Action', 'content_check',
        'personal_injury', 'complaint',
        'state', 'VA', NULL, NULL,
        '{"requires_complaint_filing": true, "requires_fee_payment": true}'::jsonb,
        'error', va_32_id, 'draft',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- VA Statewide VJEFS E-Filing
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'VA-R117-VJEFS-EFILE', 2, 'VA VJEFS E-Filing', 'format_check',
        'personal_injury', 'complaint',
        'state', 'VA', NULL, NULL,
        '{"requires_efiling": true, "system": "VJEFS", "effective_date": "2024-01-01"}'::jsonb,
        'error', va_117_id, 'draft',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Fairfax County E-Filing
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'VA-FAIRFAX-EFILE', 2, 'Fairfax County E-Filing', 'format_check',
        'personal_injury', 'complaint',
        'state', 'VA', 'Fairfax', 'Circuit Court',
        '{"requires_efiling": true, "system": "VJEFS", "civil_since": "2022-05-02"}'::jsonb,
        'error', fairfax_efile_id, 'document_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id,
        review_status = EXCLUDED.review_status;

    -- Virginia Beach E-Filing
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'VA-VBEACH-EFILE', 2, 'Virginia Beach E-Filing', 'format_check',
        'personal_injury', 'complaint',
        'state', 'VA', 'Virginia Beach', 'Circuit Court',
        '{"requires_efiling": true, "system": "E-File VA", "requires_civil_cover_sheet": true, "goal_resolution_months": 18}'::jsonb,
        'error', vbeach_efile_id, 'document_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id,
        review_status = EXCLUDED.review_status;

    -- Arlington County E-Filing
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'VA-ARLINGTON-EFILE', 2, 'Arlington County E-Filing', 'format_check',
        'personal_injury', 'complaint',
        'state', 'VA', 'Arlington', 'Circuit Court',
        '{"requires_efiling": true, "system": "VJEFS"}'::jsonb,
        'error', arlington_efile_id, 'draft',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Henrico County E-Filing
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'VA-HENRICO-EFILE', 2, 'Henrico County E-Filing', 'format_check',
        'personal_injury', 'complaint',
        'state', 'VA', 'Henrico', 'Circuit Court',
        '{"requires_efiling": true, "system": "VJEFS"}'::jsonb,
        'error', henrico_efile_id, 'draft',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Chesterfield County E-Filing
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'VA-CHESTERFIELD-EFILE', 2, 'Chesterfield County E-Filing', 'format_check',
        'personal_injury', 'complaint',
        'state', 'VA', 'Chesterfield', 'Circuit Court',
        '{"requires_efiling": true, "system": "VJEFS"}'::jsonb,
        'error', chesterfield_efile_id, 'draft',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

END $$;

COMMIT;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Show VA legal sources
SELECT 
    jurisdiction_type,
    CASE 
        WHEN jurisdiction_county IS NOT NULL THEN jurisdiction_county
        ELSE 'STATE'
    END as location,
    name,
    abbreviation
FROM leverage.legal_sources
WHERE jurisdiction_state = 'VA'
ORDER BY jurisdiction_type, location;

-- Show VA citations
SELECT 
    ls.jurisdiction_county as county,
    rc.citation,
    rc.verifier,
    rc.confidence_level
FROM leverage.rule_citations rc
JOIN leverage.legal_sources ls ON rc.legal_source_id = ls.id
WHERE ls.jurisdiction_state = 'VA'
ORDER BY ls.jurisdiction_county NULLS FIRST, rc.citation;

-- Show VA validation rules
SELECT 
    rule_name,
    validator_name,
    severity,
    jurisdiction_county,
    review_status
FROM leverage.validation_rules
WHERE jurisdiction_state = 'VA'
ORDER BY jurisdiction_county NULLS FIRST, rule_name;

-- Verify no missing citations
SELECT COUNT(*) as rules_without_citations
FROM leverage.validation_rules vr
WHERE vr.jurisdiction_state = 'VA'
AND vr.citation_id IS NULL;
