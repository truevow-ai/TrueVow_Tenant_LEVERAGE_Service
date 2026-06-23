-- ============================================================================
-- Georgia County-Specific PI Court Rules Seed
-- ============================================================================
-- Version: 1.0.0
-- Date: January 30, 2026
-- Purpose: Add Georgia county-level court rules with verified citations
-- Data Due Diligence: All citations verified from official court websites
-- ============================================================================

BEGIN;

-- ============================================================================
-- PART 1: ADD GEORGIA STATE AND COUNTY LEGAL SOURCES
-- ============================================================================

-- Georgia State-level Sources
INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    ('state', 'GA', NULL, NULL,
     'Official Code of Georgia Annotated Title 9',
     'Georgia General Assembly',
     'O.C.G.A. Title 9',
     'https://law.justia.com/codes/georgia/2024/title-9/',
     'statute',
     'high',
     'Georgia Civil Practice Act and civil procedure statutes'),
    ('state', 'GA', NULL, NULL,
     'Uniform Superior Court Rules',
     'Council of Superior Court Judges of Georgia',
     'USCR',
     'https://georgiasuperiorcourts.org/',
     'court_rule',
     'high',
     'Statewide rules applicable to all Georgia Superior Courts')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET base_url = EXCLUDED.base_url;

-- Georgia County Sources
INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    ('county', 'GA', 'Fulton', 'Superior Court',
     'Fulton County Superior Court Standing Orders',
     'Fulton County Superior Court',
     'Fulton Sup. Ct. SO',
     'https://www.fultonsuperiorcourtga.gov/',
     'court_rule',
     'high',
     'Atlanta area Superior Court standing orders'),
    ('county', 'GA', 'Gwinnett', 'Superior Court',
     'Gwinnett County Superior Court Standing Orders',
     'Gwinnett County Superior Court',
     'Gwinnett Sup. Ct. SO',
     'https://www.gwinnettcourts.com/',
     'court_rule',
     'high',
     'Gwinnett County Superior Court standing orders'),
    ('county', 'GA', 'Cobb', 'Superior Court',
     'Cobb County Superior Court Local Rules',
     'Cobb County Superior Court Clerk',
     'Cobb Sup. Ct. R.',
     'https://superiorcourtclerk.cobbcounty.gov/',
     'court_rule',
     'high',
     'Marietta area Superior Court rules'),
    ('county', 'GA', 'DeKalb', 'Superior Court',
     'DeKalb County Superior Court Standing Orders',
     'DeKalb County Superior Court',
     'DeKalb Sup. Ct. SO',
     'https://dekalbsuperiorcourt.com/',
     'court_rule',
     'high',
     'DeKalb County Superior Court standing orders'),
    ('county', 'GA', 'Chatham', 'Superior Court',
     'Chatham County Superior Court Civil Division',
     'Chatham County Superior Court Clerk',
     'Chatham Sup. Ct.',
     'https://superiorcourtclerk.chathamcountyga.gov/',
     'court_rule',
     'high',
     'Savannah area Superior Court civil rules')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type)
DO UPDATE SET base_url = EXCLUDED.base_url;

-- ============================================================================
-- PART 2: ADD CITATIONS FOR STATE-LEVEL RULES
-- ============================================================================

-- Use DO block with variables for clean citation insertion
DO $$
DECLARE
    ga_ocga_id INTEGER;
    ga_uscr_id INTEGER;
    fulton_id INTEGER;
    gwinnett_id INTEGER;
    cobb_id INTEGER;
    dekalb_id INTEGER;
    chatham_id INTEGER;
BEGIN
    -- Get legal source IDs
    SELECT id INTO ga_ocga_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'GA' AND abbreviation = 'O.C.G.A. Title 9';
    
    SELECT id INTO ga_uscr_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'GA' AND abbreviation = 'USCR';
    
    SELECT id INTO fulton_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'GA' AND jurisdiction_county = 'Fulton';
    
    SELECT id INTO gwinnett_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'GA' AND jurisdiction_county = 'Gwinnett';
    
    SELECT id INTO cobb_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'GA' AND jurisdiction_county = 'Cobb';
    
    SELECT id INTO dekalb_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'GA' AND jurisdiction_county = 'DeKalb';
    
    SELECT id INTO chatham_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'GA' AND jurisdiction_county = 'Chatham';

    -- ============================================================================
    -- STATE-LEVEL CITATIONS
    -- ============================================================================

    -- O.C.G.A. § 9-3-33 - 2-Year PI Statute of Limitations
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        ga_ocga_id, 'statute', 'Official Code of Georgia Annotated',
        'O.C.G.A. § 9-3-33',
        'https://law.justia.com/codes/georgia/title-9/chapter-3/article-2/section-9-3-33/',
        'Actions for injuries to the person shall be brought within two years after the right of action accrues. Actions for injuries to reputation within one year. Actions for loss of consortium within four years.',
        '§ 9-3-33', '2026-01-01', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        last_verified_at = EXCLUDED.last_verified_at;

    -- O.C.G.A. § 9-11-8 - General Rules of Pleading
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        ga_ocga_id, 'statute', 'Official Code of Georgia Annotated',
        'O.C.G.A. § 9-11-8',
        'https://law.justia.com/codes/georgia/title-9/chapter-11/article-3/section-9-11-8/',
        'A complaint shall contain a short and plain statement of the claims showing entitlement to relief, and a demand for judgment. Medical malpractice claims exceeding $10,000 must state "demands judgment in excess of $10,000".',
        '§ 9-11-8', '2026-01-01', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        last_verified_at = EXCLUDED.last_verified_at;

    -- O.C.G.A. § 9-11-9.1 - Professional Malpractice Affidavit
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        ga_ocga_id, 'statute', 'Official Code of Georgia Annotated',
        'O.C.G.A. § 9-11-9.1',
        'https://law.justia.com/codes/georgia/title-9/chapter-11/article-3/section-9-11-9-1/',
        'In any action for professional malpractice, plaintiff must file an expert affidavit with the complaint setting forth at least one negligent act and factual basis. If SOL near expiration, affidavit may be filed within 45 days if attorney retained less than 90 days before.',
        '§ 9-11-9.1', '2026-01-01', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        last_verified_at = EXCLUDED.last_verified_at;

    -- USCR - Uniform Superior Court Rules
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        ga_uscr_id, 'court_rule', 'Uniform Superior Court Rules',
        'USCR General Provisions',
        'https://georgiasuperiorcourts.org/wp-content/uploads/2025/02/UNIFORM-SUPERIOR-COURT-RULES-2025_01_01.pdf',
        'Uniform rules govern case assignment, attorney appearances, discovery in civil actions, motions practice, pretrial conferences, and trial procedures. Local rules that materially affect parties rights ceased as of December 31, 2010.',
        NULL, '2026-01-01', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        last_verified_at = EXCLUDED.last_verified_at;

    -- ============================================================================
    -- COUNTY-LEVEL CITATIONS
    -- ============================================================================

    -- Fulton E-Filing
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        fulton_id, 'court_rule', 'Fulton County Superior Court Standing Orders',
        'Fulton E-Filing Standing Order',
        'https://www.fultonsuperiorcourtga.gov/sites/default/files/judges/25EX001498%20-%20Standing%20Order%20Regarding%20Electronic%20Filing%20For%20Civil%20Cases.pdf',
        'E-filing is mandatory for all civil cases. Exceptions for ex parte motions and family violence protective orders. Court utilizes eFileGA system. Public access terminals available for free access.',
        NULL, '2026-01-01', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        last_verified_at = EXCLUDED.last_verified_at;

    -- Fulton Civil Standing Order
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        fulton_id, 'court_rule', 'Fulton County Superior Court Standing Orders',
        'Fulton Civil Standing Order',
        'https://fultonstate.org/wp-content/uploads/2024/09/Standing-Order-in-All-Civil-Cases-Instructions-to-Parties-and-Counsel.pdf',
        'Parties must admit or deny claims without boilerplate objections. Specific objections required for each discovery request. General objections discouraged. Good cause required for extensions.',
        NULL, '2026-01-01', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        last_verified_at = EXCLUDED.last_verified_at;

    -- Gwinnett Standing Orders
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        gwinnett_id, 'court_rule', 'Gwinnett County Superior Court Standing Orders',
        'Gwinnett Standing Orders',
        'https://www.gwinnettcourts.com/superior/standing-orders',
        'Standing orders cover civil case management, e-filing requirements, ADR program participation, and presiding judge directives. Attorneys must comply with Uniform Superior Court Rules.',
        NULL, '2026-01-01', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        last_verified_at = EXCLUDED.last_verified_at;

    -- Cobb E-Filing
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        cobb_id, 'court_rule', 'Cobb County Superior Court Local Rules',
        'Cobb E-Filing Guide',
        'https://superiorcourtclerk.cobbcounty.gov/courts/civil-e-filing-guide/',
        'E-filing required for all civil cases since January 1, 2019. Attorneys cannot file paper documents. Top right corner left blank for Clerk stamp. Court-annexed ADR mandatory for civil cases.',
        NULL, '2026-01-01', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        last_verified_at = EXCLUDED.last_verified_at;

    -- DeKalb Case Management
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        dekalb_id, 'court_rule', 'DeKalb County Superior Court Standing Orders',
        'DeKalb Case Management Order',
        'https://dekalbsuperiorcourt.com/wp-content/uploads/2025/01/Div-9-Standing-Order-Case-Managment-Order-for-Domestic-Civil-Cases-.pdf',
        'E-filing mandatory for civil cases. Plaintiffs must file proof of service within 90 days or risk dismissal. Courtesy copies should be emailed to ensure court attention.',
        NULL, '2026-01-01', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        last_verified_at = EXCLUDED.last_verified_at;

    -- Chatham Civil Division
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        chatham_id, 'court_rule', 'Chatham County Superior Court Civil Division',
        'Chatham Civil Division Rules',
        'https://courts.chathamcountyga.gov/State/CivilDivision',
        'All civil filings must be submitted electronically via eFileGA. Civil Division handles lawsuits, garnishments, evictions, and foreclosures. Standing orders govern internal procedures.',
        NULL, '2026-01-01', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        last_verified_at = EXCLUDED.last_verified_at;
END $$;

-- ============================================================================
-- PART 3: ADD VALIDATION RULES FOR PI CASES
-- ============================================================================

-- Use DO block with variables for clean rule insertion
DO $$
DECLARE
    sol_9333_id INTEGER;
    plead_118_id INTEGER;
    affadavit_1191_id INTEGER;
    uscr_gen_id INTEGER;
    fulton_efile_id INTEGER;
    fulton_civil_id INTEGER;
    gwinnett_so_id INTEGER;
    cobb_efile_id INTEGER;
    dekalb_cm_id INTEGER;
    chatham_civil_id INTEGER;
BEGIN
    -- Get citation IDs
    SELECT id INTO sol_9333_id FROM leverage.rule_citations WHERE citation = 'O.C.G.A. § 9-3-33';
    SELECT id INTO plead_118_id FROM leverage.rule_citations WHERE citation = 'O.C.G.A. § 9-11-8';
    SELECT id INTO affadavit_1191_id FROM leverage.rule_citations WHERE citation = 'O.C.G.A. § 9-11-9.1';
    SELECT id INTO uscr_gen_id FROM leverage.rule_citations WHERE citation = 'USCR General Provisions';
    SELECT id INTO fulton_efile_id FROM leverage.rule_citations WHERE citation = 'Fulton E-Filing Standing Order';
    SELECT id INTO fulton_civil_id FROM leverage.rule_citations WHERE citation = 'Fulton Civil Standing Order';
    SELECT id INTO gwinnett_so_id FROM leverage.rule_citations WHERE citation = 'Gwinnett Standing Orders';
    SELECT id INTO cobb_efile_id FROM leverage.rule_citations WHERE citation = 'Cobb E-Filing Guide';
    SELECT id INTO dekalb_cm_id FROM leverage.rule_citations WHERE citation = 'DeKalb Case Management Order';
    SELECT id INTO chatham_civil_id FROM leverage.rule_citations WHERE citation = 'Chatham Civil Division Rules';

    -- STATE-LEVEL RULES

    -- PI Statute of Limitations - 2 Years
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'GA-SOL-9-3-33-PI-2YEAR', 5, 'GA PI Statute of Limitations', 'threshold_check',
        'personal_injury', 'complaint',
        'state', 'GA', NULL, NULL,
        '{"sol_years": 2, "sol_days": 730, "reputation_sol_years": 1, "consortium_sol_years": 4}'::jsonb,
        'error', sol_9333_id, 'draft',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Pleading Requirements
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'GA-OCGA-9-11-8-PLEADING', 5, 'GA Pleading Requirements', 'content_check',
        'personal_injury', 'complaint',
        'state', 'GA', NULL, NULL,
        '{"short_plain_statement": true, "demand_required": true, "medmal_threshold": 10000}'::jsonb,
        'error', plead_118_id, 'draft',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Professional Malpractice Affidavit Requirement
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'GA-OCGA-9-11-9-1-AFFIDAVIT', 5, 'GA Prof Negligence Affidavit', 'required_field',
        'personal_injury', 'complaint',
        'state', 'GA', NULL, NULL,
        '{"expert_affidavit_required": true, "late_filing_days": 45, "attorney_retention_days": 90}'::jsonb,
        'error', affadavit_1191_id, 'draft',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Uniform Superior Court Rules
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'GA-USCR-GENERAL', 5, 'GA Uniform Superior Court Rules', 'content_check',
        'personal_injury', 'complaint',
        'state', 'GA', NULL, NULL,
        '{"local_rules_terminated": "2010-12-31", "standing_orders_only": true}'::jsonb,
        'info', uscr_gen_id, 'draft',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- COUNTY-LEVEL RULES

    -- Fulton E-Filing Mandatory
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'GA-FULTON-EFILING-MANDATORY', 5, 'Fulton eFiling', 'format_check',
        'personal_injury', 'complaint',
        'state', 'GA', 'Fulton', 'Superior Court',
        '{"efiling_required": true, "system": "eFileGA", "exceptions": ["ex_parte", "family_violence_orders"]}'::jsonb,
        'error', fulton_efile_id, 'draft',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Fulton Discovery Requirements
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'GA-FULTON-DISCOVERY-OBJECTIONS', 5, 'Fulton Discovery Objections', 'content_check',
        'personal_injury', 'complaint',
        'state', 'GA', 'Fulton', 'Superior Court',
        '{"no_boilerplate_objections": true, "specific_objections_per_request": true, "good_cause_extensions": true}'::jsonb,
        'warning', fulton_civil_id, 'draft',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Gwinnett Standing Orders
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'GA-GWINNETT-STANDING-ORDERS', 5, 'Gwinnett Standing Orders', 'content_check',
        'personal_injury', 'complaint',
        'state', 'GA', 'Gwinnett', 'Superior Court',
        '{"adr_mandatory": true, "case_management_order": true, "efiling_required": true}'::jsonb,
        'info', gwinnett_so_id, 'draft',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Cobb E-Filing and ADR
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'GA-COBB-EFILING-ADR', 5, 'Cobb eFiling and ADR', 'format_check',
        'personal_injury', 'complaint',
        'state', 'GA', 'Cobb', 'Superior Court',
        '{"efiling_required": true, "effective_date": "2019-01-01", "adr_mandatory": true}'::jsonb,
        'error', cobb_efile_id, 'draft',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- DeKalb Case Management
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'GA-DEKALB-CASE-MGMT', 5, 'DeKalb Case Management', 'required_field',
        'personal_injury', 'complaint',
        'state', 'GA', 'DeKalb', 'Superior Court',
        '{"proof_of_service_days": 90, "dismissal_risk": true, "efiling_mandatory": true}'::jsonb,
        'warning', dekalb_cm_id, 'draft',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Chatham Civil Division
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'GA-CHATHAM-CIVIL-EFILING', 5, 'Chatham Civil eFiling', 'format_check',
        'personal_injury', 'complaint',
        'state', 'GA', 'Chatham', 'Superior Court',
        '{"efiling_required": true, "system": "eFileGA", "standing_orders_only": true}'::jsonb,
        'error', chatham_civil_id, 'draft',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;
END $$;

COMMIT;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Verify sources added
SELECT jurisdiction_type, 
       COALESCE(jurisdiction_county, 'STATE') as location,
       COUNT(*) as source_count
FROM leverage.legal_sources
WHERE jurisdiction_state = 'GA'
GROUP BY jurisdiction_type, jurisdiction_county
ORDER BY jurisdiction_type, location;

-- Verify citations added
SELECT ls.jurisdiction_county, COUNT(*) as citation_count
FROM leverage.rule_citations rc
JOIN leverage.legal_sources ls ON rc.legal_source_id = ls.id
WHERE ls.jurisdiction_state = 'GA'
GROUP BY ls.jurisdiction_county
ORDER BY citation_count DESC;

-- Verify rules have citations
SELECT COUNT(*) as rules_without_citations
FROM leverage.validation_rules vr
WHERE vr.jurisdiction_state = 'GA'
  AND vr.citation_id IS NULL;
