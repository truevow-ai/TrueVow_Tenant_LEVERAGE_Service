-- ============================================================================
-- Washington State County-Specific PI Court Rules Seed
-- ============================================================================
-- Version: 1.0.0
-- Date: January 30, 2026
-- Purpose: Add Washington county-level court rules with verified citations
-- High-volume PI counties: King (Seattle), Pierce (Tacoma), Snohomish, Clark, Spokane
-- Data Due Diligence: Citations verified from leg.wa.gov, kingcounty.gov, county sites
-- ============================================================================

BEGIN;

-- ============================================================================
-- PART 1: ADD WASHINGTON STATE AND COUNTY LEGAL SOURCES
-- ============================================================================

-- Washington State-level Sources
INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    ('state', 'WA', NULL, NULL,
     'Revised Code of Washington',
     'Washington State Legislature',
     'RCW',
     'https://app.leg.wa.gov/rcw/',
     'statute',
     'high',
     'Official statutory code for Washington State'),
    ('state', 'WA', NULL, NULL,
     'Washington Superior Court Civil Rules',
     'Washington State Courts',
     'CR',
     'https://www.courts.wa.gov/court_rules/?fa=court_rules.list&group=sup&set=CR',
     'court_rule',
     'high',
     'Statewide civil procedure rules for Superior Court'),
    ('state', 'WA', NULL, NULL,
     'Washington General Rule 30',
     'Washington State Courts',
     'GR 30',
     'https://www.courts.wa.gov/court_rules/?fa=court_rules.display&group=ga&set=GR&ruleid=gagr30',
     'court_rule',
     'high',
     'Statewide electronic filing authorization rule')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET base_url = EXCLUDED.base_url;

-- Washington County Sources (Major PI Jurisdictions)
INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    ('county', 'WA', 'King', 'Superior Court',
     'King County Superior Court Local Rules',
     'King County Superior Court',
     'KC LCR',
     'https://kingcounty.gov/en/dept/dja/courts-jails-legal-system/superior-court-local-rules',
     'court_rule',
     'high',
     'Local rules for Seattle metro area civil cases - mandatory e-filing'),
    ('county', 'WA', 'Pierce', 'Superior Court',
     'Pierce County Superior Court Local Rules',
     'Pierce County Superior Court',
     'PC LCR',
     'https://www.courts.wa.gov/court_rules/pdf/LCR/27/SUP/LCR_Pierce_SUP.pdf',
     'court_rule',
     'high',
     'Local rules for Tacoma area civil cases'),
    ('county', 'WA', 'Snohomish', 'Superior Court',
     'Snohomish County Superior Court Local Rules',
     'Snohomish County Superior Court',
     'SC LCR',
     'https://snohomishcountywa.gov/5517/E-Filing',
     'court_rule',
     'high',
     'Local rules for Everett area civil cases - attorney e-filing mandatory'),
    ('county', 'WA', 'Clark', 'Superior Court',
     'Clark County Superior Court Local Rules',
     'Clark County Superior Court',
     'CC LCR',
     'https://clark.wa.gov/clerk/electronic-filing-superior-court',
     'court_rule',
     'high',
     'Local rules for Vancouver area civil cases'),
    ('county', 'WA', 'Spokane', 'Superior Court',
     'Spokane County Superior Court Local Rules',
     'Spokane County Superior Court',
     'Spok LCR',
     'https://www.spokanecounty.gov/4957/Electronic-Filing',
     'court_rule',
     'high',
     'Local rules for Spokane area civil cases - TrueFiling system')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET base_url = EXCLUDED.base_url;

-- ============================================================================
-- PART 2: ADD WASHINGTON STATE AND COUNTY CITATIONS
-- ============================================================================

DO $$
DECLARE
    wa_rcw_id INTEGER;
    wa_cr_id INTEGER;
    wa_gr30_id INTEGER;
    king_id INTEGER;
    pierce_id INTEGER;
    snohomish_id INTEGER;
    clark_id INTEGER;
    spokane_id INTEGER;
BEGIN
    -- Get legal source IDs
    SELECT id INTO wa_rcw_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'WA' AND abbreviation = 'RCW';
    
    SELECT id INTO wa_cr_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'WA' AND abbreviation = 'CR';
    
    SELECT id INTO wa_gr30_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'WA' AND abbreviation = 'GR 30';
    
    SELECT id INTO king_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'WA' AND jurisdiction_county = 'King';
    
    SELECT id INTO pierce_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'WA' AND jurisdiction_county = 'Pierce';
    
    SELECT id INTO snohomish_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'WA' AND jurisdiction_county = 'Snohomish';
    
    SELECT id INTO clark_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'WA' AND jurisdiction_county = 'Clark';
    
    SELECT id INTO spokane_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'WA' AND jurisdiction_county = 'Spokane';

    -- RCW 4.16.080 - Statute of Limitations for Personal Injury (3 years)
    -- DOCUMENT VERIFIED: EXACT TEXT from app.leg.wa.gov
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        wa_rcw_id, 'statute', 'Revised Code of Washington',
        'RCW 4.16.080',
        'https://app.leg.wa.gov/rcw/default.aspx?cite=4.16.080',
        'The following actions shall be commenced within three years: (1) An action for waste or trespass upon real property; (2) An action for taking, detaining, or injuring personal property, including an action for the specific recovery thereof, or for any other injury to the person or rights of another not hereinafter enumerated.',
        '4.16.080', '2026-01-01', NOW(), 'document_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        verifier = EXCLUDED.verifier;

    -- CR 3 - Commencement of Action
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        wa_cr_id, 'court_rule', 'Washington Superior Court Civil Rules',
        'CR 3',
        'https://www.courts.wa.gov/court_rules/?fa=court_rules.display&group=sup&set=CR&ruleid=supcr03',
        'A civil action is commenced by service of a copy of a summons together with a copy of a complaint, as provided in rule 4, or by filing a complaint.',
        'CR 3', '2026-01-01', NOW(), 'web_verified_official', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- GR 30 - Electronic Filing Authorization
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        wa_gr30_id, 'court_rule', 'Washington General Rule 30',
        'GR 30',
        'https://www.courts.wa.gov/court_rules/?fa=court_rules.display&group=ga&set=GR&ruleid=gagr30',
        'General Rule 30 authorizes electronic filing (e-filing) in Washington courts. Courts may adopt local rules requiring mandatory e-filing for attorneys.',
        'GR 30', '2026-01-01', NOW(), 'web_verified_official', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- King County LGR 30 - Mandatory E-Filing
    -- DOCUMENT VERIFIED: EXACT TEXT from kingcounty.gov
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        king_id, 'local_rule', 'King County Superior Court Local Rules',
        'KC LGR 30',
        'https://kingcounty.gov/en/dept/dja/courts-jails-legal-system/superior-court-local-rules/local-general-rules/lgr-30',
        'Mandatory Electronic Filing. Attorneys shall electronically file (e-file) all documents using the Clerk''s online eFiling application unless this rule provides otherwise. Non-attorneys are not required to e-file but may do so.',
        'LGR 30', '2022-09-01', NOW(), 'document_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        verifier = EXCLUDED.verifier;

    -- Pierce County E-Filing
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        pierce_id, 'local_rule', 'Pierce County Superior Court Local Rules',
        'PC PCLGR 30',
        'https://www.courts.wa.gov/court_rules/pdf/LCR/27/SUP/LCR_Pierce_SUP.pdf',
        'Pierce County Superior Court local rules effective September 1, 2024, include provisions for mandatory electronic filing in civil cases pursuant to PCLGR 30.',
        'PCLGR 30', '2024-09-01', NOW(), 'web_verified_official', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Snohomish County E-Filing - DOCUMENT VERIFIED from snohomishcountywa.gov
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        snohomish_id, 'local_rule', 'Snohomish County Superior Court Local Rules',
        'SC SCLGR 30',
        'https://snohomishcountywa.gov/5517/E-Filing',
        'Attorneys must electronically file (e-file) court documents using the Clerk''s online eFile & Serve (EFS) e-filing system. Non-attorneys are encouraged to e-file but are not required to do so.',
        'SCLGR 30', '2020-12-01', NOW(), 'document_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        verifier = EXCLUDED.verifier;

    -- Clark County E-Filing
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        clark_id, 'local_rule', 'Clark County Superior Court Local Rules',
        'CC Local E-Filing',
        'https://clark.wa.gov/clerk/electronic-filing-superior-court',
        'Clark County Superior Court e-filing available for attorneys, schools, guardians ad litem, and government agencies. Self-represented individuals must file paper documents.',
        'E-Filing', '2026-01-01', NOW(), 'web_verified_official', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Spokane County E-Filing - DOCUMENT VERIFIED from spokanecounty.gov
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        spokane_id, 'local_rule', 'Spokane County Superior Court Local Rules',
        'Spokane TrueFiling',
        'https://www.spokanecounty.gov/4957/Electronic-Filing',
        'The Spokane County Clerk''s Office uses a new electronic filing solution by ImageSoft called TrueFiling. The system was rolled out in 2021, and all Superior Court Case Types are supported. eFiling will not be mandatory at this time.',
        'TrueFiling', '2021-01-01', NOW(), 'document_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        verifier = EXCLUDED.verifier;

END $$;

-- ============================================================================
-- PART 3: ADD WASHINGTON VALIDATION RULES
-- ============================================================================

DO $$
DECLARE
    wa_sol_id INTEGER;
    wa_cr3_id INTEGER;
    wa_gr30_id INTEGER;
    king_efile_id INTEGER;
    pierce_efile_id INTEGER;
    snohomish_efile_id INTEGER;
    clark_efile_id INTEGER;
    spokane_efile_id INTEGER;
BEGIN
    -- Get citation IDs
    SELECT id INTO wa_sol_id FROM leverage.rule_citations 
    WHERE citation = 'RCW 4.16.080';
    
    SELECT id INTO wa_cr3_id FROM leverage.rule_citations 
    WHERE citation = 'CR 3';
    
    SELECT id INTO wa_gr30_id FROM leverage.rule_citations 
    WHERE citation = 'GR 30';
    
    SELECT id INTO king_efile_id FROM leverage.rule_citations 
    WHERE citation = 'KC LGR 30';
    
    SELECT id INTO pierce_efile_id FROM leverage.rule_citations 
    WHERE citation = 'PC PCLGR 30';
    
    SELECT id INTO snohomish_efile_id FROM leverage.rule_citations 
    WHERE citation = 'SC SCLGR 30';
    
    SELECT id INTO clark_efile_id FROM leverage.rule_citations 
    WHERE citation = 'CC Local E-Filing';
    
    SELECT id INTO spokane_efile_id FROM leverage.rule_citations 
    WHERE citation = 'Spokane TrueFiling';

    -- WA Statewide PI Statute of Limitations (3 years)
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'WA-SOL-4-16-080-PI-3YEAR', 5, 'WA PI Statute of Limitations', 'threshold_check',
        'personal_injury', 'complaint',
        'state', 'WA', NULL, NULL,
        '{"sol_years": 3, "sol_days": 1095}'::jsonb,
        'error', wa_sol_id, 'document_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id,
        review_status = EXCLUDED.review_status;

    -- WA Commencement of Action
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'WA-CR3-COMMENCEMENT', 3, 'WA Commencement of Action', 'content_check',
        'personal_injury', 'complaint',
        'state', 'WA', NULL, NULL,
        '{"requires_summons_service": true, "requires_complaint": true, "alternative_filing": true}'::jsonb,
        'error', wa_cr3_id, 'draft',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- WA GR 30 E-Filing Authorization
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'WA-GR30-EFILE', 2, 'WA E-Filing Authorization', 'format_check',
        'personal_injury', 'complaint',
        'state', 'WA', NULL, NULL,
        '{"efiling_authorized": true, "local_rules_may_require": true}'::jsonb,
        'warning', wa_gr30_id, 'draft',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- King County Mandatory E-Filing
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'WA-KING-EFILE', 2, 'King County Mandatory E-Filing', 'format_check',
        'personal_injury', 'complaint',
        'state', 'WA', 'King', 'Superior Court',
        '{"requires_efiling": true, "system": "KC eFiling", "attorneys_mandatory": true, "non_attorneys_optional": true}'::jsonb,
        'error', king_efile_id, 'document_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id,
        review_status = EXCLUDED.review_status;

    -- Pierce County E-Filing
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'WA-PIERCE-EFILE', 2, 'Pierce County E-Filing', 'format_check',
        'personal_injury', 'complaint',
        'state', 'WA', 'Pierce', 'Superior Court',
        '{"requires_efiling": true, "system": "eFile & Serve", "effective_date": "2024-09-01"}'::jsonb,
        'error', pierce_efile_id, 'draft',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Snohomish County E-Filing
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'WA-SNOHOMISH-EFILE', 2, 'Snohomish County E-Filing', 'format_check',
        'personal_injury', 'complaint',
        'state', 'WA', 'Snohomish', 'Superior Court',
        '{"requires_efiling": true, "system": "eFile & Serve", "attorneys_mandatory": true, "non_attorneys_encouraged": true}'::jsonb,
        'error', snohomish_efile_id, 'document_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id,
        review_status = EXCLUDED.review_status;

    -- Clark County E-Filing
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'WA-CLARK-EFILE', 2, 'Clark County E-Filing', 'format_check',
        'personal_injury', 'complaint',
        'state', 'WA', 'Clark', 'Superior Court',
        '{"efiling_available": true, "attorneys_only": true, "pro_se_paper": true}'::jsonb,
        'warning', clark_efile_id, 'draft',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Spokane County E-Filing
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'WA-SPOKANE-EFILE', 2, 'Spokane County E-Filing', 'format_check',
        'personal_injury', 'complaint',
        'state', 'WA', 'Spokane', 'Superior Court',
        '{"efiling_available": true, "system": "TrueFiling", "mandatory": false, "all_case_types": true}'::jsonb,
        'warning', spokane_efile_id, 'document_verified',
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

-- Show WA legal sources
SELECT 
    jurisdiction_type,
    CASE 
        WHEN jurisdiction_county IS NOT NULL THEN jurisdiction_county
        ELSE 'STATE'
    END as location,
    name,
    abbreviation
FROM leverage.legal_sources
WHERE jurisdiction_state = 'WA'
ORDER BY jurisdiction_type, location;

-- Show WA citations
SELECT 
    ls.jurisdiction_county as county,
    rc.citation,
    rc.verifier,
    rc.confidence_level
FROM leverage.rule_citations rc
JOIN leverage.legal_sources ls ON rc.legal_source_id = ls.id
WHERE ls.jurisdiction_state = 'WA'
ORDER BY ls.jurisdiction_county NULLS FIRST, rc.citation;

-- Show WA validation rules
SELECT 
    rule_name,
    validator_name,
    severity,
    jurisdiction_county,
    review_status
FROM leverage.validation_rules
WHERE jurisdiction_state = 'WA'
ORDER BY jurisdiction_county NULLS FIRST, rule_name;

-- Verify no missing citations
SELECT COUNT(*) as rules_without_citations
FROM leverage.validation_rules vr
WHERE vr.jurisdiction_state = 'WA'
AND vr.citation_id IS NULL;
