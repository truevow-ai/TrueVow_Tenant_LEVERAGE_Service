-- ============================================================================
-- Massachusetts County-Specific PI Court Rules Seed
-- ============================================================================
-- Version: 1.0.0
-- Date: January 30, 2026
-- Purpose: Add Massachusetts county-level court rules with verified citations
-- High-volume PI counties: Suffolk, Middlesex, Worcester, Essex, Norfolk
-- Data Due Diligence: Citations verified from mass.gov and malegislature.gov
-- ============================================================================

BEGIN;

-- ============================================================================
-- PART 1: ADD MASSACHUSETTS STATE AND COUNTY LEGAL SOURCES
-- ============================================================================

-- Massachusetts State-level Sources
INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    ('state', 'MA', NULL, NULL,
     'Massachusetts General Laws',
     'Massachusetts General Court',
     'M.G.L.',
     'https://malegislature.gov/Laws/GeneralLaws',
     'statute',
     'high',
     'Official statutory code for the Commonwealth of Massachusetts'),
    ('state', 'MA', NULL, NULL,
     'Massachusetts Rules of Civil Procedure',
     'Massachusetts Supreme Judicial Court',
     'Mass. R. Civ. P.',
     'https://www.mass.gov/law-library/massachusetts-rules-of-civil-procedure',
     'court_rule',
     'high',
     'Official civil procedure rules for Massachusetts'),
    ('state', 'MA', NULL, NULL,
     'Massachusetts Superior Court Standing Orders',
     'Massachusetts Superior Court',
     'Super. Ct. S.O.',
     'https://www.mass.gov/law-library/massachusetts-superior-court-standing-orders',
     'court_rule',
     'high',
     'Standing orders including e-filing requirements')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET base_url = EXCLUDED.base_url;

-- Massachusetts County Sources (Major PI Jurisdictions)
INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    ('county', 'MA', 'Suffolk', 'Superior Court',
     'Suffolk County Superior Court Local Rules',
     'Suffolk County Superior Court',
     'Suffolk Super. Ct. R.',
     'https://www.mass.gov/guides/efiling-in-the-superior-court',
     'court_rule',
     'high',
     'Local rules for Boston metro area civil cases'),
    ('county', 'MA', 'Middlesex', 'Superior Court',
     'Middlesex County Superior Court Local Rules',
     'Middlesex County Superior Court',
     'Middlesex Super. Ct. R.',
     'https://www.mass.gov/orgs/middlesex-county-superior-court',
     'court_rule',
     'high',
     'Local rules for Cambridge/Lowell metro area civil cases'),
    ('county', 'MA', 'Worcester', 'Superior Court',
     'Worcester County Superior Court Local Rules',
     'Worcester County Superior Court',
     'Worcester Super. Ct. R.',
     'https://www.mass.gov/orgs/worcester-county-superior-court',
     'court_rule',
     'high',
     'Local rules for Worcester County civil cases'),
    ('county', 'MA', 'Essex', 'Superior Court',
     'Essex County Superior Court Local Rules',
     'Essex County Superior Court',
     'Essex Super. Ct. R.',
     'https://www.mass.gov/orgs/essex-county-superior-court',
     'court_rule',
     'high',
     'Local rules for Salem/Lawrence area civil cases'),
    ('county', 'MA', 'Norfolk', 'Superior Court',
     'Norfolk County Superior Court Local Rules',
     'Norfolk County Superior Court',
     'Norfolk Super. Ct. R.',
     'https://www.mass.gov/orgs/norfolk-county-superior-court',
     'court_rule',
     'high',
     'Local rules for Dedham area civil cases')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET base_url = EXCLUDED.base_url;

-- ============================================================================
-- PART 2: ADD MASSACHUSETTS STATE AND COUNTY CITATIONS
-- ============================================================================

DO $$
DECLARE
    ma_mgl_id INTEGER;
    ma_rules_id INTEGER;
    ma_so_id INTEGER;
    suffolk_id INTEGER;
    middlesex_id INTEGER;
    worcester_id INTEGER;
    essex_id INTEGER;
    norfolk_id INTEGER;
BEGIN
    -- Get legal source IDs
    SELECT id INTO ma_mgl_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'MA' AND abbreviation = 'M.G.L.';
    
    SELECT id INTO ma_rules_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'MA' AND abbreviation = 'Mass. R. Civ. P.';
    
    SELECT id INTO ma_so_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'MA' AND abbreviation = 'Super. Ct. S.O.';
    
    SELECT id INTO suffolk_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'MA' AND jurisdiction_county = 'Suffolk';
    
    SELECT id INTO middlesex_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'MA' AND jurisdiction_county = 'Middlesex';
    
    SELECT id INTO worcester_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'MA' AND jurisdiction_county = 'Worcester';
    
    SELECT id INTO essex_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'MA' AND jurisdiction_county = 'Essex';
    
    SELECT id INTO norfolk_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'MA' AND jurisdiction_county = 'Norfolk';

    -- M.G.L. c. 260, § 2A - Statute of Limitations for Personal Injury (3 years)
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        ma_mgl_id, 'statute', 'Massachusetts General Laws',
        'M.G.L. c. 260, § 2A',
        'https://malegislature.gov/Laws/GeneralLaws/PartIII/TitleV/Chapter260/Section2a',
        'Except as otherwise provided, actions of tort, actions of contract to recover for personal injuries, and actions of replevin, shall be commenced only within three years next after the cause of action accrues.',
        'c. 260, § 2A', '2026-01-01', NOW(), 'web_verified_official', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Mass. R. Civ. P. 3 - Commencement of Action
    -- DOCUMENT VERIFIED: EXACT TEXT from mass.gov
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        ma_rules_id, 'court_rule', 'Massachusetts Rules of Civil Procedure',
        'Mass. R. Civ. P. 3',
        'https://www.mass.gov/rules-of-civil-procedure/civil-procedure-rule-3-commencement-of-action',
        'A civil action is commenced by (1) mailing to the clerk of the proper court by certified or registered mail a complaint and an entry fee prescribed by law, (2) filing such complaint and an entry fee with such clerk, or (3) submitting the complaint to the court through the court''s electronic filing system accompanied by electronic payment of the entry fee pursuant to the Massachusetts Rules of Electronic Filing.',
        'Rule 3', '2021-09-01', NOW(), 'document_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        verifier = EXCLUDED.verifier;

    -- Superior Court Standing Order 1-23 - E-Filing
    -- DOCUMENT VERIFIED: EXACT TEXT from mass.gov
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        ma_so_id, 'court_rule', 'Massachusetts Superior Court Standing Orders',
        'Super. Ct. S.O. 1-23',
        'https://www.mass.gov/superior-court-rules/superior-court-standing-order-1-23-e-filing-policies-and-procedures-for-civil-actions',
        'The Superior Court adopts these policies and procedures for electronic filing (e-filing) in designated civil actions. E-filed text documents must be in searchable Portable Document Format (PDF). The size limit for a single e-filed document is 25 megabytes (MB), and for a single e-filed envelope is 50MB.',
        'S.O. 1-23', '2023-02-01', NOW(), 'document_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        verifier = EXCLUDED.verifier;

    -- Suffolk County E-Filing - DOCUMENT VERIFIED from mass.gov
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        suffolk_id, 'local_rule', 'Suffolk County Superior Court Local Rules',
        'Suffolk County Superior Court E-Filing',
        'https://www.mass.gov/guides/efiling-in-the-superior-court',
        'Superior Court case types accepted for eFiling: Contract/business cases, equitable remedies, real property, actions involving state/municipality, administrative civil actions, miscellaneous civil actions, torts, and business litigation (Suffolk only). eFiling is processed through eFileMA.com.',
        'E-Filing', '2024-05-01', NOW(), 'document_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        verifier = EXCLUDED.verifier;

    -- Middlesex County E-Filing
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        middlesex_id, 'local_rule', 'Middlesex County Superior Court Local Rules',
        'Middlesex County Superior Court E-Filing',
        'https://www.mass.gov/orgs/middlesex-county-superior-court',
        'Middlesex County Superior Court civil filings processed through eFileMA.com electronic filing system pursuant to Superior Court Standing Order 1-23.',
        'E-Filing', '2026-01-01', NOW(), 'web_verified_official', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Worcester County E-Filing
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        worcester_id, 'local_rule', 'Worcester County Superior Court Local Rules',
        'Worcester County Superior Court E-Filing',
        'https://www.mass.gov/orgs/worcester-county-superior-court',
        'Worcester County Superior Court civil filings processed through eFileMA.com electronic filing system pursuant to Superior Court Standing Order 1-23.',
        'E-Filing', '2026-01-01', NOW(), 'web_verified_official', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Essex County E-Filing
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        essex_id, 'local_rule', 'Essex County Superior Court Local Rules',
        'Essex County Superior Court E-Filing',
        'https://www.mass.gov/orgs/essex-county-superior-court',
        'Essex County Superior Court civil filings processed through eFileMA.com electronic filing system pursuant to Superior Court Standing Order 1-23.',
        'E-Filing', '2026-01-01', NOW(), 'web_verified_official', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Norfolk County E-Filing
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        norfolk_id, 'local_rule', 'Norfolk County Superior Court Local Rules',
        'Norfolk County Superior Court E-Filing',
        'https://www.mass.gov/orgs/norfolk-county-superior-court',
        'Norfolk County Superior Court civil filings processed through eFileMA.com electronic filing system pursuant to Superior Court Standing Order 1-23.',
        'E-Filing', '2026-01-01', NOW(), 'web_verified_official', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

END $$;

-- ============================================================================
-- PART 3: ADD MASSACHUSETTS VALIDATION RULES
-- ============================================================================

DO $$
DECLARE
    ma_sol_id INTEGER;
    ma_rule3_id INTEGER;
    ma_so123_id INTEGER;
    suffolk_efile_id INTEGER;
    middlesex_efile_id INTEGER;
    worcester_efile_id INTEGER;
    essex_efile_id INTEGER;
    norfolk_efile_id INTEGER;
BEGIN
    -- Get citation IDs
    SELECT id INTO ma_sol_id FROM leverage.rule_citations 
    WHERE citation = 'M.G.L. c. 260, § 2A';
    
    SELECT id INTO ma_rule3_id FROM leverage.rule_citations 
    WHERE citation = 'Mass. R. Civ. P. 3';
    
    SELECT id INTO ma_so123_id FROM leverage.rule_citations 
    WHERE citation = 'Super. Ct. S.O. 1-23';
    
    SELECT id INTO suffolk_efile_id FROM leverage.rule_citations 
    WHERE citation = 'Suffolk County Superior Court E-Filing';
    
    SELECT id INTO middlesex_efile_id FROM leverage.rule_citations 
    WHERE citation = 'Middlesex County Superior Court E-Filing';
    
    SELECT id INTO worcester_efile_id FROM leverage.rule_citations 
    WHERE citation = 'Worcester County Superior Court E-Filing';
    
    SELECT id INTO essex_efile_id FROM leverage.rule_citations 
    WHERE citation = 'Essex County Superior Court E-Filing';
    
    SELECT id INTO norfolk_efile_id FROM leverage.rule_citations 
    WHERE citation = 'Norfolk County Superior Court E-Filing';

    -- MA Statewide PI Statute of Limitations (3 years)
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'MA-SOL-260-2A-PI-3YEAR', 5, 'MA PI Statute of Limitations', 'threshold_check',
        'personal_injury', 'complaint',
        'state', 'MA', NULL, NULL,
        '{"sol_years": 3, "sol_days": 1095}'::jsonb,
        'error', ma_sol_id, 'draft',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- MA Commencement of Action
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'MA-RULE3-COMMENCEMENT', 3, 'MA Commencement of Action', 'content_check',
        'personal_injury', 'complaint',
        'state', 'MA', NULL, NULL,
        '{"requires_complaint_filing": true, "requires_entry_fee": true, "efiling_option": true}'::jsonb,
        'error', ma_rule3_id, 'document_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id,
        review_status = EXCLUDED.review_status;

    -- MA Superior Court E-Filing Standing Order
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'MA-SO-1-23-EFILE', 2, 'MA Superior Court E-Filing', 'format_check',
        'personal_injury', 'complaint',
        'state', 'MA', NULL, NULL,
        '{"requires_efiling": true, "system": "eFileMA", "pdf_searchable": true, "max_file_mb": 25, "max_envelope_mb": 50}'::jsonb,
        'error', ma_so123_id, 'document_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id,
        review_status = EXCLUDED.review_status;

    -- Suffolk County E-Filing
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'MA-SUFFOLK-EFILE', 2, 'Suffolk County E-Filing', 'format_check',
        'personal_injury', 'complaint',
        'state', 'MA', 'Suffolk', 'Superior Court',
        '{"requires_efiling": true, "system": "eFileMA", "includes_torts": true, "business_litigation": true}'::jsonb,
        'error', suffolk_efile_id, 'document_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id,
        review_status = EXCLUDED.review_status;

    -- Middlesex County E-Filing
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'MA-MIDDLESEX-EFILE', 2, 'Middlesex County E-Filing', 'format_check',
        'personal_injury', 'complaint',
        'state', 'MA', 'Middlesex', 'Superior Court',
        '{"requires_efiling": true, "system": "eFileMA"}'::jsonb,
        'error', middlesex_efile_id, 'draft',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Worcester County E-Filing
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'MA-WORCESTER-EFILE', 2, 'Worcester County E-Filing', 'format_check',
        'personal_injury', 'complaint',
        'state', 'MA', 'Worcester', 'Superior Court',
        '{"requires_efiling": true, "system": "eFileMA"}'::jsonb,
        'error', worcester_efile_id, 'draft',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Essex County E-Filing
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'MA-ESSEX-EFILE', 2, 'Essex County E-Filing', 'format_check',
        'personal_injury', 'complaint',
        'state', 'MA', 'Essex', 'Superior Court',
        '{"requires_efiling": true, "system": "eFileMA"}'::jsonb,
        'error', essex_efile_id, 'draft',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Norfolk County E-Filing
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'MA-NORFOLK-EFILE', 2, 'Norfolk County E-Filing', 'format_check',
        'personal_injury', 'complaint',
        'state', 'MA', 'Norfolk', 'Superior Court',
        '{"requires_efiling": true, "system": "eFileMA"}'::jsonb,
        'error', norfolk_efile_id, 'draft',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

END $$;

COMMIT;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Show MA legal sources
SELECT 
    jurisdiction_type,
    CASE 
        WHEN jurisdiction_county IS NOT NULL THEN jurisdiction_county
        ELSE 'STATE'
    END as location,
    name,
    abbreviation
FROM leverage.legal_sources
WHERE jurisdiction_state = 'MA'
ORDER BY jurisdiction_type, location;

-- Show MA citations
SELECT 
    ls.jurisdiction_county as county,
    rc.citation,
    rc.verifier,
    rc.confidence_level
FROM leverage.rule_citations rc
JOIN leverage.legal_sources ls ON rc.legal_source_id = ls.id
WHERE ls.jurisdiction_state = 'MA'
ORDER BY ls.jurisdiction_county NULLS FIRST, rc.citation;

-- Show MA validation rules
SELECT 
    rule_name,
    validator_name,
    severity,
    jurisdiction_county,
    review_status
FROM leverage.validation_rules
WHERE jurisdiction_state = 'MA'
ORDER BY jurisdiction_county NULLS FIRST, rule_name;

-- Verify no missing citations
SELECT COUNT(*) as rules_without_citations
FROM leverage.validation_rules vr
WHERE vr.jurisdiction_state = 'MA'
AND vr.citation_id IS NULL;
