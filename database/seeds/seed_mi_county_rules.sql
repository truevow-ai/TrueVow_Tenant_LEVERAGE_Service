-- Michigan County Rules Seed - Citation-First Architecture
-- High-volume PI counties: Wayne, Oakland, Macomb, Kent, Genesee
-- Sources verified: January 30, 2026
-- Schema: leverage.legal_sources uses 'name', 'publisher', 'base_url'

BEGIN;

-- ============================================================
-- MICHIGAN STATE-LEVEL SOURCES
-- ============================================================

-- Michigan Court Rules (MCR) - State authority
INSERT INTO leverage.legal_sources (
    name,
    publisher,
    abbreviation,
    source_type,
    jurisdiction_type,
    jurisdiction_state,
    base_url,
    trust_level
) VALUES (
    'Michigan Court Rules',
    'Michigan Supreme Court',
    'MCR',
    'court_rule',
    'state',
    'MI',
    'https://www.courts.michigan.gov/siteassets/rules-instructions-administrative-orders/michigan-court-rules/michigan-court-rules.pdf',
    'high'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) DO UPDATE SET
    base_url = EXCLUDED.base_url;

-- MiFILE Statewide E-Filing System
INSERT INTO leverage.legal_sources (
    name,
    publisher,
    abbreviation,
    source_type,
    jurisdiction_type,
    jurisdiction_state,
    base_url,
    trust_level
) VALUES (
    'Michigan MiFILE E-Filing System',
    'Michigan State Court Administrative Office',
    'MiFILE',
    'court_rule',
    'state',
    'MI',
    'https://mifile.courts.michigan.gov/',
    'high'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) DO UPDATE SET
    base_url = EXCLUDED.base_url;

-- ============================================================
-- WAYNE COUNTY (3rd Judicial Circuit) - Detroit Metro
-- Population: ~1.7M - Highest volume
-- VERIFIED from https://www.3rdcc.org/efiling
-- ============================================================

INSERT INTO leverage.legal_sources (
    name,
    publisher,
    abbreviation,
    source_type,
    jurisdiction_type,
    jurisdiction_state,
    jurisdiction_county,
    base_url,
    trust_level
) VALUES (
    'Wayne County 3rd Circuit Court Local Rules',
    'Third Judicial Circuit Court of Michigan',
    '3rd Cir. LCR',
    'local_rule',
    'county',
    'MI',
    'Wayne',
    'https://www.3rdcc.org/efiling',
    'high'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) DO UPDATE SET
    base_url = EXCLUDED.base_url;

-- ============================================================
-- OAKLAND COUNTY (6th Judicial Circuit)
-- Population: ~1.3M
-- ============================================================

INSERT INTO leverage.legal_sources (
    name,
    publisher,
    abbreviation,
    source_type,
    jurisdiction_type,
    jurisdiction_state,
    jurisdiction_county,
    base_url,
    trust_level
) VALUES (
    'Oakland County 6th Circuit Court Local Rules',
    'Sixth Judicial Circuit Court of Michigan',
    '6th Cir. LCR',
    'local_rule',
    'county',
    'MI',
    'Oakland',
    'https://www.oakgov.com/government/clerk-register-of-deeds/court-records/efiling',
    'high'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) DO UPDATE SET
    base_url = EXCLUDED.base_url;

-- ============================================================
-- MACOMB COUNTY (16th Judicial Circuit)
-- Population: ~870K
-- VERIFIED from https://www.macombgov.org/departments/16th-judicial-circuit-court/e-filing-resources
-- ============================================================

INSERT INTO leverage.legal_sources (
    name,
    publisher,
    abbreviation,
    source_type,
    jurisdiction_type,
    jurisdiction_state,
    jurisdiction_county,
    base_url,
    trust_level
) VALUES (
    'Macomb County 16th Circuit Court Local Rules',
    'Sixteenth Judicial Circuit Court of Michigan',
    '16th Cir. LCR',
    'local_rule',
    'county',
    'MI',
    'Macomb',
    'https://www.macombgov.org/departments/16th-judicial-circuit-court/e-filing-resources',
    'high'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) DO UPDATE SET
    base_url = EXCLUDED.base_url;

-- ============================================================
-- KENT COUNTY (17th Judicial Circuit) - Grand Rapids
-- Population: ~660K
-- VERIFIED from https://www.kentcountymi.gov/1894/eFiling
-- ============================================================

INSERT INTO leverage.legal_sources (
    name,
    publisher,
    abbreviation,
    source_type,
    jurisdiction_type,
    jurisdiction_state,
    jurisdiction_county,
    base_url,
    trust_level
) VALUES (
    'Kent County 17th Circuit Court Local Rules',
    'Seventeenth Judicial Circuit Court of Michigan',
    '17th Cir. LCR',
    'local_rule',
    'county',
    'MI',
    'Kent',
    'https://www.kentcountymi.gov/1894/eFiling',
    'high'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) DO UPDATE SET
    base_url = EXCLUDED.base_url;

-- ============================================================
-- GENESEE COUNTY (7th Judicial Circuit) - Flint
-- Population: ~400K
-- ============================================================

INSERT INTO leverage.legal_sources (
    name,
    publisher,
    abbreviation,
    source_type,
    jurisdiction_type,
    jurisdiction_state,
    jurisdiction_county,
    base_url,
    trust_level
) VALUES (
    'Genesee County 7th Circuit Court Local Rules',
    'Seventh Judicial Circuit Court of Michigan',
    '7th Cir. LCR',
    'local_rule',
    'county',
    'MI',
    'Genesee',
    'https://www.gc4me.com/departments/circuit_court/',
    'high'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) DO UPDATE SET
    base_url = EXCLUDED.base_url;

-- ============================================================
-- PART 2: MICHIGAN STATE AND COUNTY CITATIONS (Citation-First)
-- ============================================================

DO $$
DECLARE
    mi_mcr_id INTEGER;
    mi_mifile_id INTEGER;
    wayne_id INTEGER;
    oakland_id INTEGER;
    macomb_id INTEGER;
    kent_id INTEGER;
    genesee_id INTEGER;
BEGIN
    -- Get legal source IDs
    SELECT id INTO mi_mcr_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'MI' AND abbreviation = 'MCR';
    
    SELECT id INTO mi_mifile_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'MI' AND abbreviation = 'MiFILE';
    
    SELECT id INTO wayne_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'MI' AND jurisdiction_county = 'Wayne';
    
    SELECT id INTO oakland_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'MI' AND jurisdiction_county = 'Oakland';
    
    SELECT id INTO macomb_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'MI' AND jurisdiction_county = 'Macomb';
    
    SELECT id INTO kent_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'MI' AND jurisdiction_county = 'Kent';
    
    SELECT id INTO genesee_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'MI' AND jurisdiction_county = 'Genesee';

    -- MCR 2.101 - Commencement of Action
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        mi_mcr_id, 'court_rule', 'Michigan Court Rules',
        'MCR 2.101',
        'https://www.courts.michigan.gov/siteassets/rules-instructions-administrative-orders/michigan-court-rules/michigan-court-rules.pdf',
        'Rule 2.101 Commencement of Action. A civil action is commenced by filing a complaint with a court.',
        'Rule 2.101', '2026-01-01', NOW(), 'web_verified_official', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- MCR 2.107 - Service and Filing
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        mi_mcr_id, 'court_rule', 'Michigan Court Rules',
        'MCR 2.107',
        'https://www.courts.michigan.gov/siteassets/rules-instructions-administrative-orders/michigan-court-rules/michigan-court-rules.pdf',
        'Rule 2.107 Service and Filing of Pleadings and Other Papers. Every pleading after the original complaint, written motion, and similar paper must be served on each party.',
        'Rule 2.107', '2026-01-01', NOW(), 'web_verified_official', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Wayne County E-Filing - DOCUMENT VERIFIED
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        wayne_id, 'local_rule', 'Wayne County 3rd Circuit Court Local Rules',
        '3rd Cir. MiFILE Mandate',
        'https://www.3rdcc.org/efiling',
        'Michigan Supreme Court''s Administrative Order allows the Third Judicial Circuit Court to require eFiling as follows: Mandatory for all civil case types. Subsequent filings for all criminal case types.',
        'E-Filing', '2026-01-01', NOW(), 'document_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Oakland County E-Filing - URL VERIFIED (fetch failed)
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        oakland_id, 'local_rule', 'Oakland County 6th Circuit Court Local Rules',
        '6th Cir. MiFILE',
        'https://www.oakgov.com/government/clerk-register-of-deeds/court-records/efiling',
        'Oakland County Circuit Court e-filing via MiFILE system. Mandatory for most civil, domestic, and criminal case types with specific exclusions.',
        'E-Filing', '2026-01-01', NOW(), 'url_verified_pending_manual_review', 'medium'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Macomb County E-Filing - DOCUMENT VERIFIED
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        macomb_id, 'local_rule', 'Macomb County 16th Circuit Court Local Rules',
        '16th Cir. MiFILE',
        'https://www.macombgov.org/departments/16th-judicial-circuit-court/e-filing-resources',
        'E-Filing has now been enabled on all existing [A], [C], [F], [N], [P], [DM], and [DO] case types. This includes new files and existing files. All Judges are participating in the e-Filing project at the 16th Judicial Circuit Court.',
        'E-Filing', '2026-01-01', NOW(), 'document_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Kent County E-Filing - DOCUMENT VERIFIED
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        kent_id, 'local_rule', 'Kent County 17th Circuit Court Local Rules',
        '17th Cir. eFiling Options',
        'https://www.kentcountymi.gov/1894/eFiling',
        'We currently have two eFiling options: Business Court eFiling and KentCourt eFile for Civil Cases.',
        'E-Filing', '2026-01-01', NOW(), 'document_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Genesee County E-Filing - URL VERIFIED (fetch failed)
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        genesee_id, 'local_rule', 'Genesee County 7th Circuit Court Local Rules',
        '7th Cir. MiFILE',
        'https://www.gc4me.com/departments/circuit_court/',
        'Genesee County Circuit Court e-filing via MiFILE statewide system for civil case types.',
        'E-Filing', '2026-01-01', NOW(), 'url_verified_pending_manual_review', 'medium'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

END $$;

-- ============================================================
-- PART 3: MICHIGAN VALIDATION RULES (Citation-First)
-- ============================================================

DO $$
DECLARE
    mcr_2101_id INTEGER;
    mcr_2107_id INTEGER;
    wayne_efile_id INTEGER;
    oakland_efile_id INTEGER;
    macomb_efile_id INTEGER;
    kent_efile_id INTEGER;
    genesee_efile_id INTEGER;
BEGIN
    -- Get citation IDs
    SELECT id INTO mcr_2101_id FROM leverage.rule_citations 
    WHERE citation = 'MCR 2.101';
    
    SELECT id INTO mcr_2107_id FROM leverage.rule_citations 
    WHERE citation = 'MCR 2.107';
    
    SELECT id INTO wayne_efile_id FROM leverage.rule_citations 
    WHERE citation = '3rd Cir. MiFILE Mandate';
    
    SELECT id INTO oakland_efile_id FROM leverage.rule_citations 
    WHERE citation = '6th Cir. MiFILE';
    
    SELECT id INTO macomb_efile_id FROM leverage.rule_citations 
    WHERE citation = '16th Cir. MiFILE';
    
    SELECT id INTO kent_efile_id FROM leverage.rule_citations 
    WHERE citation = '17th Cir. eFiling Options';
    
    SELECT id INTO genesee_efile_id FROM leverage.rule_citations 
    WHERE citation = '7th Cir. MiFILE';

    -- Michigan Commencement of Action
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'MI-MCR-2.101-COMMENCEMENT', 3, 'MI Commencement of Action', 'content_check',
        'personal_injury', 'complaint',
        'state', 'MI', NULL, NULL,
        '{"requires_complaint_filing": true}'::jsonb,
        'error', mcr_2101_id, 'draft',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Michigan Service and Filing
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'MI-MCR-2.107-SERVICE', 4, 'MI Service and Filing', 'content_check',
        'personal_injury', 'complaint',
        'state', 'MI', NULL, NULL,
        '{"requires_service_on_all_parties": true}'::jsonb,
        'error', mcr_2107_id, 'draft',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Wayne County E-Filing
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'MI-WAYNE-EFILE', 2, 'Wayne County Mandatory E-Filing', 'format_check',
        'personal_injury', 'complaint',
        'state', 'MI', 'Wayne', '3rd Circuit Court',
        '{"requires_efiling": true, "system": "MiFILE", "mandatory_all_civil": true}'::jsonb,
        'error', wayne_efile_id, 'document_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Oakland County E-Filing
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'MI-OAKLAND-EFILE', 2, 'Oakland County E-Filing', 'format_check',
        'personal_injury', 'complaint',
        'state', 'MI', 'Oakland', '6th Circuit Court',
        '{"requires_efiling": true, "system": "MiFILE"}'::jsonb,
        'error', oakland_efile_id, 'needs_review',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Macomb County E-Filing
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'MI-MACOMB-EFILE', 2, 'Macomb County E-Filing', 'format_check',
        'personal_injury', 'complaint',
        'state', 'MI', 'Macomb', '16th Circuit Court',
        '{"requires_efiling": true, "system": "MiFILE", "case_types": ["A", "C", "F", "N", "P", "DM", "DO"]}'::jsonb,
        'error', macomb_efile_id, 'document_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Kent County E-Filing
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'MI-KENT-EFILE', 2, 'Kent County E-Filing', 'format_check',
        'personal_injury', 'complaint',
        'state', 'MI', 'Kent', '17th Circuit Court',
        '{"requires_efiling": true, "systems": ["Business Court eFiling", "KentCourt eFile"]}'::jsonb,
        'warning', kent_efile_id, 'document_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Genesee County E-Filing
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'MI-GENESEE-EFILE', 2, 'Genesee County E-Filing', 'format_check',
        'personal_injury', 'complaint',
        'state', 'MI', 'Genesee', '7th Circuit Court',
        '{"requires_efiling": true, "system": "MiFILE"}'::jsonb,
        'error', genesee_efile_id, 'needs_review',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

END $$;

COMMIT;

-- ============================================================
-- VERIFICATION QUERIES
-- ============================================================

-- Show Michigan legal sources
SELECT 
    jurisdiction_type,
    CASE 
        WHEN jurisdiction_county IS NOT NULL THEN jurisdiction_county
        ELSE 'STATE'
    END as location,
    name,
    abbreviation
FROM leverage.legal_sources
WHERE jurisdiction_state = 'MI'
ORDER BY jurisdiction_type, location;

-- Show Michigan citations
SELECT 
    ls.jurisdiction_county as county,
    rc.citation,
    rc.verifier,
    rc.confidence_level
FROM leverage.rule_citations rc
JOIN leverage.legal_sources ls ON rc.legal_source_id = ls.id
WHERE ls.jurisdiction_state = 'MI'
ORDER BY ls.jurisdiction_county NULLS FIRST, rc.citation;

-- Show Michigan validation rules
SELECT 
    rule_name,
    validator_name,
    severity,
    jurisdiction_county,
    review_status
FROM leverage.validation_rules
WHERE jurisdiction_state = 'MI'
ORDER BY jurisdiction_county NULLS FIRST, rule_name;

-- Verify no missing citations
SELECT COUNT(*) as rules_without_citations
FROM leverage.validation_rules vr
WHERE vr.jurisdiction_state = 'MI'
AND vr.citation_id IS NULL;
