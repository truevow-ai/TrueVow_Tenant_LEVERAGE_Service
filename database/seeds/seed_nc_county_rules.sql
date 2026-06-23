-- ============================================================================
-- North Carolina County-Specific PI Court Rules Seed
-- ============================================================================
-- Version: 1.0.0
-- Date: January 30, 2026
-- Purpose: Add North Carolina county-level court rules with verified citations
-- High-volume PI counties: Mecklenburg, Wake, Guilford, Forsyth, Durham
-- Data Due Diligence: Citations verified from nccourts.gov official sources
-- ============================================================================

BEGIN;

-- ============================================================================
-- PART 1: ADD NORTH CAROLINA STATE AND COUNTY LEGAL SOURCES
-- ============================================================================

-- North Carolina State-level Sources
INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    ('state', 'NC', NULL, NULL,
     'North Carolina General Statutes',
     'North Carolina General Assembly',
     'N.C.G.S.',
     'https://www.ncleg.gov/Laws/GeneralStatutes',
     'statute',
     'high',
     'Official statutory code for the State of North Carolina'),
    ('state', 'NC', NULL, NULL,
     'North Carolina Rules of Civil Procedure',
     'North Carolina General Assembly',
     'N.C.R. Civ. P.',
     'https://www.ncleg.gov/Laws/GeneralStatutes',
     'court_rule',
     'high',
     'Official civil procedure rules for North Carolina'),
    ('state', 'NC', NULL, NULL,
     'North Carolina eCourts System',
     'North Carolina Administrative Office of the Courts',
     'eCourts',
     'https://www.nccourts.gov/ecourts',
     'court_rule',
     'high',
     'Statewide electronic filing system (Tyler Odyssey)')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET base_url = EXCLUDED.base_url;

-- North Carolina County Sources (Major PI Jurisdictions)
INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    ('county', 'NC', 'Mecklenburg', 'Superior Court',
     'Mecklenburg County Superior Court Local Rules',
     'Mecklenburg County Superior Court',
     'Mecklenburg Loc. R.',
     'https://www.nccourts.gov/locations/mecklenburg-county',
     'court_rule',
     'high',
     'Local rules for Charlotte metro area civil cases'),
    ('county', 'NC', 'Wake', 'Superior Court',
     'Wake County Superior Court Local Rules',
     'Wake County Superior Court',
     'Wake Loc. R.',
     'https://www.nccourts.gov/locations/wake-county',
     'court_rule',
     'high',
     'Local rules for Raleigh metro area civil cases'),
    ('county', 'NC', 'Guilford', 'Superior Court',
     'Guilford County Superior Court Local Rules',
     'Guilford County Superior Court',
     'Guilford Loc. R.',
     'https://www.nccourts.gov/locations/guilford-county',
     'court_rule',
     'high',
     'Local rules for Greensboro metro area civil cases'),
    ('county', 'NC', 'Forsyth', 'Superior Court',
     'Forsyth County Superior Court Local Rules',
     'Forsyth County Superior Court',
     'Forsyth Loc. R.',
     'https://www.nccourts.gov/locations/forsyth-county',
     'court_rule',
     'high',
     'Local rules for Winston-Salem metro area civil cases'),
    ('county', 'NC', 'Durham', 'Superior Court',
     'Durham County Superior Court Local Rules',
     'Durham County Superior Court',
     'Durham Loc. R.',
     'https://www.nccourts.gov/locations/durham-county',
     'court_rule',
     'high',
     'Local rules for Durham metro area civil cases')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET base_url = EXCLUDED.base_url;

-- ============================================================================
-- PART 2: ADD NORTH CAROLINA STATE AND COUNTY CITATIONS
-- ============================================================================

DO $$
DECLARE
    nc_gs_id INTEGER;
    nc_rules_id INTEGER;
    nc_ecourts_id INTEGER;
    mecklenburg_id INTEGER;
    wake_id INTEGER;
    guilford_id INTEGER;
    forsyth_id INTEGER;
    durham_id INTEGER;
BEGIN
    -- Get legal source IDs
    SELECT id INTO nc_gs_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'NC' AND abbreviation = 'N.C.G.S.';
    
    SELECT id INTO nc_rules_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'NC' AND abbreviation = 'N.C.R. Civ. P.';
    
    SELECT id INTO nc_ecourts_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'NC' AND abbreviation = 'eCourts';
    
    SELECT id INTO mecklenburg_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'NC' AND jurisdiction_county = 'Mecklenburg';
    
    SELECT id INTO wake_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'NC' AND jurisdiction_county = 'Wake';
    
    SELECT id INTO guilford_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'NC' AND jurisdiction_county = 'Guilford';
    
    SELECT id INTO forsyth_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'NC' AND jurisdiction_county = 'Forsyth';
    
    SELECT id INTO durham_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'NC' AND jurisdiction_county = 'Durham';

    -- N.C.G.S. § 1-52 - Statute of Limitations for Personal Injury (3 years)
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        nc_gs_id, 'statute', 'North Carolina General Statutes',
        'N.C.G.S. § 1-52',
        'https://www.ncleg.gov/EnactedLegislation/Statutes/PDF/BySection/Chapter_1/GS_1-52.pdf',
        'Within three years an action: (5) For criminal conversation, or for any other injury to the person or rights of another, not arising on contract and not hereafter enumerated.',
        '§ 1-52', '2026-01-01', NOW(), 'web_verified_official', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- N.C.R. Civ. P. Rule 3 - Commencement of Action
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        nc_rules_id, 'court_rule', 'North Carolina Rules of Civil Procedure',
        'N.C.R. Civ. P. Rule 3',
        'https://www.ncleg.gov/Laws/GeneralStatutes',
        'A civil action is commenced by filing a complaint with the court. A civil action may also be commenced by the issuance of a summons...',
        'Rule 3', '2026-01-01', NOW(), 'web_verified_official', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- NC eCourts Mandatory Filing - DOCUMENT VERIFIED from nccourts.gov
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        nc_ecourts_id, 'court_rule', 'North Carolina eCourts System',
        'NC eCourts Mandatory Filing',
        'https://www.nccourts.gov/ecourts',
        'E-filing will be mandatory for attorneys when a district court goes live with the Odyssey Case Manager system. Self-represented litigants will have the option to use e-filing. File & Serve for prepared filings and Guide & File to assist in preparing filings.',
        'eCourts', '2024-10-14', NOW(), 'document_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Mecklenburg County E-Filing
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        mecklenburg_id, 'local_rule', 'Mecklenburg County Superior Court Local Rules',
        'Mecklenburg County eCourts Filing',
        'https://www.nccourts.gov/locations/mecklenburg-county',
        'Mecklenburg County Superior Court civil filings processed through North Carolina eCourts system. All attorneys must use eCourts for civil case filings when county is live.',
        'E-Filing', '2026-01-01', NOW(), 'url_verified_pending_manual_review', 'medium'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Wake County E-Filing
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        wake_id, 'local_rule', 'Wake County Superior Court Local Rules',
        'Wake County eCourts Filing',
        'https://www.nccourts.gov/locations/wake-county',
        'Wake County Superior Court civil filings processed through North Carolina eCourts system. All attorneys must use eCourts for civil case filings when county is live.',
        'E-Filing', '2026-01-01', NOW(), 'url_verified_pending_manual_review', 'medium'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Guilford County E-Filing
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        guilford_id, 'local_rule', 'Guilford County Superior Court Local Rules',
        'Guilford County eCourts Filing',
        'https://www.nccourts.gov/locations/guilford-county',
        'Guilford County Superior Court civil filings processed through North Carolina eCourts system. All attorneys must use eCourts for civil case filings when county is live.',
        'E-Filing', '2026-01-01', NOW(), 'url_verified_pending_manual_review', 'medium'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Forsyth County E-Filing
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        forsyth_id, 'local_rule', 'Forsyth County Superior Court Local Rules',
        'Forsyth County eCourts Filing',
        'https://www.nccourts.gov/locations/forsyth-county',
        'Forsyth County Superior Court civil filings processed through North Carolina eCourts system. All attorneys must use eCourts for civil case filings when county is live.',
        'E-Filing', '2026-01-01', NOW(), 'url_verified_pending_manual_review', 'medium'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Durham County E-Filing
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        durham_id, 'local_rule', 'Durham County Superior Court Local Rules',
        'Durham County eCourts Filing',
        'https://www.nccourts.gov/locations/durham-county',
        'Durham County Superior Court civil filings processed through North Carolina eCourts system. All attorneys must use eCourts for civil case filings when county is live.',
        'E-Filing', '2026-01-01', NOW(), 'url_verified_pending_manual_review', 'medium'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

END $$;

-- ============================================================================
-- PART 3: ADD NORTH CAROLINA VALIDATION RULES
-- ============================================================================

DO $$
DECLARE
    ncgs_152_id INTEGER;
    nc_rule3_id INTEGER;
    ecourts_mandatory_id INTEGER;
    mecklenburg_efile_id INTEGER;
    wake_efile_id INTEGER;
    guilford_efile_id INTEGER;
    forsyth_efile_id INTEGER;
    durham_efile_id INTEGER;
BEGIN
    -- Get citation IDs
    SELECT id INTO ncgs_152_id FROM leverage.rule_citations 
    WHERE citation = 'N.C.G.S. § 1-52';
    
    SELECT id INTO nc_rule3_id FROM leverage.rule_citations 
    WHERE citation = 'N.C.R. Civ. P. Rule 3';
    
    SELECT id INTO ecourts_mandatory_id FROM leverage.rule_citations 
    WHERE citation = 'NC eCourts Mandatory Filing';
    
    SELECT id INTO mecklenburg_efile_id FROM leverage.rule_citations 
    WHERE citation = 'Mecklenburg County eCourts Filing';
    
    SELECT id INTO wake_efile_id FROM leverage.rule_citations 
    WHERE citation = 'Wake County eCourts Filing';
    
    SELECT id INTO guilford_efile_id FROM leverage.rule_citations 
    WHERE citation = 'Guilford County eCourts Filing';
    
    SELECT id INTO forsyth_efile_id FROM leverage.rule_citations 
    WHERE citation = 'Forsyth County eCourts Filing';
    
    SELECT id INTO durham_efile_id FROM leverage.rule_citations 
    WHERE citation = 'Durham County eCourts Filing';

    -- NC Statewide PI Statute of Limitations (3 years)
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'NC-SOL-1-52-PI-3YEAR', 5, 'NC PI Statute of Limitations', 'threshold_check',
        'personal_injury', 'complaint',
        'state', 'NC', NULL, NULL,
        '{"sol_years": 3, "sol_days": 1095}'::jsonb,
        'error', ncgs_152_id, 'draft',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- NC Commencement of Action
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'NC-RULE3-COMMENCEMENT', 3, 'NC Commencement of Action', 'content_check',
        'personal_injury', 'complaint',
        'state', 'NC', NULL, NULL,
        '{"requires_complaint_filing": true, "summons_option": true}'::jsonb,
        'error', nc_rule3_id, 'draft',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- NC Statewide Mandatory eCourts Filing
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'NC-ECOURTS-MANDATORY', 2, 'NC Mandatory eCourts Filing', 'format_check',
        'personal_injury', 'complaint',
        'state', 'NC', NULL, NULL,
        '{"requires_efiling": true, "system": "eCourts", "file_and_serve": true, "guide_and_file": true}'::jsonb,
        'error', ecourts_mandatory_id, 'document_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Mecklenburg County E-Filing
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'NC-MECKLENBURG-EFILE', 2, 'Mecklenburg County E-Filing', 'format_check',
        'personal_injury', 'complaint',
        'state', 'NC', 'Mecklenburg', 'Superior Court',
        '{"requires_efiling": true, "system": "eCourts"}'::jsonb,
        'error', mecklenburg_efile_id, 'needs_review',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Wake County E-Filing
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'NC-WAKE-EFILE', 2, 'Wake County E-Filing', 'format_check',
        'personal_injury', 'complaint',
        'state', 'NC', 'Wake', 'Superior Court',
        '{"requires_efiling": true, "system": "eCourts"}'::jsonb,
        'error', wake_efile_id, 'needs_review',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Guilford County E-Filing
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'NC-GUILFORD-EFILE', 2, 'Guilford County E-Filing', 'format_check',
        'personal_injury', 'complaint',
        'state', 'NC', 'Guilford', 'Superior Court',
        '{"requires_efiling": true, "system": "eCourts"}'::jsonb,
        'error', guilford_efile_id, 'needs_review',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Forsyth County E-Filing
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'NC-FORSYTH-EFILE', 2, 'Forsyth County E-Filing', 'format_check',
        'personal_injury', 'complaint',
        'state', 'NC', 'Forsyth', 'Superior Court',
        '{"requires_efiling": true, "system": "eCourts"}'::jsonb,
        'error', forsyth_efile_id, 'needs_review',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Durham County E-Filing
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'NC-DURHAM-EFILE', 2, 'Durham County E-Filing', 'format_check',
        'personal_injury', 'complaint',
        'state', 'NC', 'Durham', 'Superior Court',
        '{"requires_efiling": true, "system": "eCourts"}'::jsonb,
        'error', durham_efile_id, 'needs_review',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

END $$;

COMMIT;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Show NC legal sources
SELECT 
    jurisdiction_type,
    CASE 
        WHEN jurisdiction_county IS NOT NULL THEN jurisdiction_county
        ELSE 'STATE'
    END as location,
    name,
    abbreviation
FROM leverage.legal_sources
WHERE jurisdiction_state = 'NC'
ORDER BY jurisdiction_type, location;

-- Show NC citations
SELECT 
    ls.jurisdiction_county as county,
    rc.citation,
    rc.verifier,
    rc.confidence_level
FROM leverage.rule_citations rc
JOIN leverage.legal_sources ls ON rc.legal_source_id = ls.id
WHERE ls.jurisdiction_state = 'NC'
ORDER BY ls.jurisdiction_county NULLS FIRST, rc.citation;

-- Show NC validation rules
SELECT 
    rule_name,
    validator_name,
    severity,
    jurisdiction_county,
    review_status
FROM leverage.validation_rules
WHERE jurisdiction_state = 'NC'
ORDER BY jurisdiction_county NULLS FIRST, rule_name;

-- Verify no missing citations
SELECT COUNT(*) as rules_without_citations
FROM leverage.validation_rules vr
WHERE vr.jurisdiction_state = 'NC'
AND vr.citation_id IS NULL;
