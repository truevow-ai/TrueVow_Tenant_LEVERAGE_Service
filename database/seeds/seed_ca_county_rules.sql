-- ============================================================================
-- California County-Specific PI Court Rules Seed
-- ============================================================================
-- Version: 1.0.0
-- Date: January 30, 2026
-- Purpose: Add California county-level court rules with verified citations
-- Data Due Diligence: All citations verified from official court websites
-- ============================================================================
-- IMPORTANT: This seed follows the citation-first architecture:
--   - legal_sources: jurisdiction fields (WHERE law came from)
--   - rule_citations: NO jurisdiction fields (WHY rule exists)
--   - validation_rules: jurisdiction fields (WHEN rule applies)
-- ============================================================================

BEGIN;

-- ============================================================================
-- PART 1: ADD COUNTY LEGAL SOURCES
-- ============================================================================
-- Each county Superior Court is a legal source with jurisdiction specificity

INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    -- Los Angeles County
    ('county', 'CA', 'Los Angeles', 'Superior Court',
     'Los Angeles Superior Court Local Rules', 'Los Angeles Superior Court', 'LASCR',
     'https://www.lacourt.ca.gov/courtrules/',
     'local_rule', 'high', 'Official local rules for Los Angeles County Superior Court'),
    
    -- Orange County
    ('county', 'CA', 'Orange', 'Superior Court',
     'Orange County Superior Court Local Rules', 'Orange County Superior Court', 'OCSCR',
     'https://www.occourts.org/forms-filing/rules-court',
     'local_rule', 'high', 'Official local rules for Orange County Superior Court'),
    
    -- San Diego County
    ('county', 'CA', 'San Diego', 'Superior Court',
     'San Diego Superior Court Local Rules', 'San Diego Superior Court', 'SDSCR',
     'https://sdcourt.ca.gov/',
     'local_rule', 'high', 'Official local rules for San Diego County Superior Court'),
    
    -- San Francisco County
    ('county', 'CA', 'San Francisco', 'Superior Court',
     'San Francisco Superior Court Local Rules', 'San Francisco Superior Court', 'SFSCR',
     'https://sf.courts.ca.gov/general-information/san-francisco-local-rules-court',
     'local_rule', 'high', 'Official local rules for San Francisco County Superior Court'),
    
    -- Riverside County
    ('county', 'CA', 'Riverside', 'Superior Court',
     'Riverside Superior Court Local Rules', 'Riverside Superior Court', 'RVSCR',
     'https://www.riverside.courts.ca.gov/general-information/local-rules',
     'local_rule', 'high', 'Official local rules for Riverside County Superior Court'),
    
    -- Alameda County
    ('county', 'CA', 'Alameda', 'Superior Court',
     'Alameda Superior Court Local Rules', 'Alameda Superior Court', 'ALMSCR',
     'https://www.alameda.courts.ca.gov/general-information/local-rules-forms',
     'local_rule', 'high', 'Official local rules for Alameda County Superior Court'),
    
    -- Santa Clara County
    ('county', 'CA', 'Santa Clara', 'Superior Court',
     'Santa Clara Superior Court Local Rules', 'Santa Clara Superior Court', 'SCSCR',
     'https://santaclara.courts.ca.gov/general-information/local-rules-court',
     'local_rule', 'high', 'Official local rules for Santa Clara County Superior Court'),
    
    -- Contra Costa County
    ('county', 'CA', 'Contra Costa', 'Superior Court',
     'Contra Costa Superior Court Local Rules', 'Contra Costa Superior Court', 'CCSCR',
     'https://contracosta.courts.ca.gov/general-information/local-rules-court',
     'local_rule', 'high', 'Official local rules for Contra Costa County Superior Court'),
    
    -- Sacramento County
    ('county', 'CA', 'Sacramento', 'Superior Court',
     'Sacramento Superior Court Local Rules', 'Sacramento Superior Court', 'SACSCR',
     'https://saccourt.ca.gov/local-rules/',
     'local_rule', 'high', 'Official local rules for Sacramento County Superior Court'),
    
    -- San Mateo County
    ('county', 'CA', 'San Mateo', 'Superior Court',
     'San Mateo Superior Court Local Rules', 'San Mateo Superior Court', 'SMSCR',
     'https://sanmateo.courts.ca.gov/',
     'local_rule', 'high', 'Official local rules for San Mateo County Superior Court'),
    
    -- Solano County
    ('county', 'CA', 'Solano', 'Superior Court',
     'Solano Superior Court Local Rules', 'Solano Superior Court', 'SOLSCR',
     'https://solano.courts.ca.gov/',
     'local_rule', 'high', 'Official local rules for Solano County Superior Court'),
    
    -- Kings County
    ('county', 'CA', 'Kings', 'Superior Court',
     'Kings Superior Court Local Rules', 'Kings Superior Court', 'KNGSCR',
     'https://www.kings.courts.ca.gov/',
     'local_rule', 'high', 'Official local rules for Kings County Superior Court')

ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET base_url = EXCLUDED.base_url;

-- ============================================================================
-- PART 2: ADD COUNTY-SPECIFIC CITATIONS
-- ============================================================================
-- Verified citations from official court rule documents
-- Each citation links to legal_source via legal_source_id FK

DO $$
DECLARE
    -- Legal source IDs
    lascr_id INTEGER;
    ocscr_id INTEGER;
    sdscr_id INTEGER;
    sfscr_id INTEGER;
    rvscr_id INTEGER;
    almscr_id INTEGER;
    scscr_id INTEGER;
    ccscr_id INTEGER;
    sacscr_id INTEGER;
    smscr_id INTEGER;
    solscr_id INTEGER;
    kngscr_id INTEGER;
BEGIN
    -- Get legal source IDs
    SELECT id INTO lascr_id FROM leverage.legal_sources WHERE abbreviation = 'LASCR';
    SELECT id INTO ocscr_id FROM leverage.legal_sources WHERE abbreviation = 'OCSCR';
    SELECT id INTO sdscr_id FROM leverage.legal_sources WHERE abbreviation = 'SDSCR';
    SELECT id INTO sfscr_id FROM leverage.legal_sources WHERE abbreviation = 'SFSCR';
    SELECT id INTO rvscr_id FROM leverage.legal_sources WHERE abbreviation = 'RVSCR';
    SELECT id INTO almscr_id FROM leverage.legal_sources WHERE abbreviation = 'ALMSCR';
    SELECT id INTO scscr_id FROM leverage.legal_sources WHERE abbreviation = 'SCSCR';
    SELECT id INTO ccscr_id FROM leverage.legal_sources WHERE abbreviation = 'CCSCR';
    SELECT id INTO sacscr_id FROM leverage.legal_sources WHERE abbreviation = 'SACSCR';
    SELECT id INTO smscr_id FROM leverage.legal_sources WHERE abbreviation = 'SMSCR';
    SELECT id INTO solscr_id FROM leverage.legal_sources WHERE abbreviation = 'SOLSCR';
    SELECT id INTO kngscr_id FROM leverage.legal_sources WHERE abbreviation = 'KNGSCR';

    -- ========================================================================
    -- LOS ANGELES COUNTY CITATIONS
    -- ========================================================================
    
    -- LA SCR Rule 3.30 - Mandatory Electronic Filing
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    )
    VALUES (
        lascr_id, 'local_rule', 'Los Angeles Superior Court Local Rules',
        'LASCR Rule 3.30',
        'https://www.lacourt.ca.gov/courtrules/CurrentCourtRulesPDF/Chap3.pdf',
        'Electronic filing is mandatory for all documents in civil cases for parties represented by attorneys. Self-represented litigants are exempt from mandatory electronic filing but may file electronically.',
        'Rule 3.30', '2025-01-01', NOW(), 'web_verified', 'high'
    )
    ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        last_verified_at = NOW();

    -- LA SCR Rule 3.4 - Electronic Filing Procedures
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    )
    VALUES (
        lascr_id, 'local_rule', 'Los Angeles Superior Court Local Rules',
        'LASCR Rule 3.4',
        'https://lascpubstorage.blob.core.windows.net/cts-webgrouppublic/LIBSVCJES/CourtRules/Master/LascCourtRules_CH3.pdf',
        'Documents filed electronically must be in PDF format, text-searchable, and comply with formatting requirements. Filing is complete when the court confirms receipt.',
        'Rule 3.4', '2025-01-01', NOW(), 'web_verified', 'high'
    )
    ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        last_verified_at = NOW();

    -- LA PI Hub Standing Order
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    )
    VALUES (
        lascr_id, 'court_rule', 'Los Angeles Superior Court Standing Order',
        'LASCR PI Hub Standing Order',
        'https://lascpubstorage.blob.core.windows.net/cpw/LIBOPSCivil-109-StandingOrderForProceduresInThePersonalInjuryHubCourts.pdf',
        'All newly filed personal injury (PI) cases in the Central District must be filed in the judicial district where the incident occurred. Cases may be dismissed if proof of service is not filed within 24 months.',
        'Standing Order', '2022-10-10', NOW(), 'web_verified', 'high'
    )
    ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        last_verified_at = NOW();

    -- ========================================================================
    -- ORANGE COUNTY CITATIONS
    -- ========================================================================
    
    -- OC SCR Rule 301 - Case Classification
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    )
    VALUES (
        ocscr_id, 'local_rule', 'Orange County Superior Court Local Rules',
        'OCSCR Rule 301',
        'https://www.occourts.org/system/files/local-rules/12div3.pdf',
        'Civil cases include personal injury, civil actions over and under $35,000, and small claims. Family law matters are excluded from civil case management rules.',
        'Rule 301', '2025-07-01', NOW(), 'web_verified', 'high'
    )
    ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        last_verified_at = NOW();

    -- OC SCR Rule 352 - Electronic Filing
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    )
    VALUES (
        ocscr_id, 'local_rule', 'Orange County Superior Court Local Rules',
        'OCSCR Rule 352',
        'https://www.occourts.org/system/files?file=19div3.pdf',
        'Electronic filing is mandatory for civil cases as of July 1, 2019. All civil cases must be filed electronically through approved electronic filing service providers.',
        'Rule 352', '2019-07-01', NOW(), 'web_verified', 'high'
    )
    ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        last_verified_at = NOW();

    -- ========================================================================
    -- SAN DIEGO COUNTY CITATIONS
    -- ========================================================================
    
    -- SD SCR CIV-409 - Electronic Filing Requirements
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    )
    VALUES (
        sdscr_id, 'local_rule', 'San Diego Superior Court Local Rules',
        'SDSCR CIV-409',
        'https://sdcourt.ca.gov/sites/default/files/SDCOURT/GENERALINFORMATION/FORMS/CIVILFORMS/CIV409.PDF',
        'Attorneys representing parties in limited and unlimited civil actions must file documents electronically through approved electronic filing service providers (EFSPs). Self-represented litigants are encouraged to e-file but are not mandated.',
        'CIV-409', '2021-04-15', NOW(), 'web_verified', 'high'
    )
    ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        last_verified_at = NOW();

    -- SD SCR Division II - Civil Filing Location
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    )
    VALUES (
        sdscr_id, 'local_rule', 'San Diego Superior Court Local Rules',
        'SDSCR Division II',
        'https://sdcourt.ca.gov/sites/default/files/sdcourt/generalinformation/localrulesofcourt/2025_division_ii_-_civil.pdf',
        'All civil papers must be filed in the civil business office of the appropriate division. Only clear, legible copies of Judicial Council and court forms are acceptable.',
        'Division II', '2025-01-01', NOW(), 'web_verified', 'high'
    )
    ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        last_verified_at = NOW();

    -- ========================================================================
    -- SAN FRANCISCO COUNTY CITATIONS
    -- ========================================================================
    
    -- SF SCR Rule 3 - Civil Case Management
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    )
    VALUES (
        sfscr_id, 'local_rule', 'San Francisco Superior Court Local Rules',
        'SFSCR Rule 3',
        'https://sf.courts.ca.gov/system/files/local-rules/local-rules-court-effective-january-1-2024_0.pdf',
        'Civil case management rules apply to all civil cases. Parties must adhere to specific filing protocols including electronic filing deadlines of 11:59 p.m. on the due court day.',
        'Rule 3', '2024-01-01', NOW(), 'web_verified', 'high'
    )
    ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        last_verified_at = NOW();

    -- ========================================================================
    -- RIVERSIDE COUNTY CITATIONS
    -- ========================================================================
    
    -- RV SCR Civil eFiling Rule
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    )
    VALUES (
        rvscr_id, 'local_rule', 'Riverside Superior Court Local Rules',
        'RVSCR Civil eFiling',
        'https://www.riverside.courts.ca.gov/forms-filing/civil-efiling',
        'eFiling is required for parties represented by counsel in civil cases. Documents must be filed by midnight on the due date to be considered timely. Self-represented litigants may e-file optionally.',
        'Civil eFiling', '2023-07-05', NOW(), 'web_verified', 'high'
    )
    ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        last_verified_at = NOW();

    -- ========================================================================
    -- ALAMEDA COUNTY CITATIONS
    -- ========================================================================
    
    -- ALM SCR Rule 3.27 - Electronic Filing
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    )
    VALUES (
        almscr_id, 'local_rule', 'Alameda Superior Court Local Rules',
        'ALMSCR Rule 3.27',
        'https://www.alameda.courts.ca.gov/system/files/local-rules/03-title-3-20250701.pdf',
        'Electronic filing is mandatory for civil and civil appeals cases as of January 1, 2022. Parties must maintain updated electronic service addresses and promptly notify the court of any changes.',
        'Rule 3.27', '2022-01-01', NOW(), 'web_verified', 'high'
    )
    ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        last_verified_at = NOW();

    -- ========================================================================
    -- SANTA CLARA COUNTY CITATIONS
    -- ========================================================================
    
    -- SC SCR Civil Lawsuit Notice Rule
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    )
    VALUES (
        scscr_id, 'local_rule', 'Santa Clara Superior Court Local Rules',
        'SCSCR Civil Lawsuit Notice',
        'https://santaclara.courts.ca.gov/system/files/rules/civil_1.pdf',
        'Upon filing a complaint, the filing party must submit a blank Civil Lawsuit Notice (CV-5012) to the Clerk for judicial assignment and hearing details. This notice must be served to all parties.',
        'Civil Lawsuit Notice', '2025-07-01', NOW(), 'web_verified', 'high'
    )
    ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        last_verified_at = NOW();

    -- ========================================================================
    -- CONTRA COSTA COUNTY CITATIONS
    -- ========================================================================
    
    -- CC SCR Civil Case Classification
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    )
    VALUES (
        ccscr_id, 'local_rule', 'Contra Costa Superior Court Local Rules',
        'CCSCR Civil Classification',
        'https://contracosta.courts.ca.gov/divisions/civil',
        'Civil cases are classified as: Small Claims (under $12,500), Limited Jurisdiction Civil cases ($1 to $35,000), and Unlimited Jurisdiction Civil cases (over $35,000). Zoom is the sole platform for remote appearances.',
        'Civil Classification', '2025-07-01', NOW(), 'web_verified', 'high'
    )
    ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        last_verified_at = NOW();

    -- ========================================================================
    -- SACRAMENTO COUNTY CITATIONS
    -- ========================================================================
    
    -- SAC SCR Rule 2.00 - Sanctions
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    )
    VALUES (
        sacscr_id, 'local_rule', 'Sacramento Superior Court Local Rules',
        'SACSCR Rule 2.00',
        'https://saccourt.ca.gov/local-rules/docs/chapter-02.pdf',
        'Non-compliance with court rules may result in penalties such as striking pleadings, dismissing actions, or imposing costs. Mandatory civil local forms must be used as required.',
        'Rule 2.00', '2025-07-01', NOW(), 'web_verified', 'high'
    )
    ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        last_verified_at = NOW();

    -- ========================================================================
    -- SAN MATEO COUNTY CITATIONS
    -- ========================================================================
    
    -- SM SCR Division III - Civil
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    )
    VALUES (
        smscr_id, 'local_rule', 'San Mateo Superior Court Local Rules',
        'SMSCR Division III',
        'https://sanmateo.courts.ca.gov/system/files/local-rules/localrules.pdf',
        'Division III outlines civil law and motion procedures including filing instructions and required forms for civil cases. Updated effective January 1, 2026.',
        'Division III', '2026-01-01', NOW(), 'web_verified', 'high'
    )
    ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        last_verified_at = NOW();

    -- ========================================================================
    -- SOLANO COUNTY CITATIONS
    -- ========================================================================
    
    -- SOL SCR Rule 3 - Civil Cases
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    )
    VALUES (
        solscr_id, 'local_rule', 'Solano Superior Court Local Rules',
        'SOLSCR Rule 3',
        'https://solano.courts.ca.gov/system/files/general/complete-local-rules-set-july-2024.pdf',
        'Rule 3 governs civil cases including filing procedures and case administration. Rule 4 covers Administration of Civil Litigation.',
        'Rule 3', '2024-07-01', NOW(), 'web_verified', 'high'
    )
    ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        last_verified_at = NOW();

    -- ========================================================================
    -- KINGS COUNTY CITATIONS
    -- ========================================================================
    
    -- KNG SCR Rule 125 - Electronic Filing
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    )
    VALUES (
        kngscr_id, 'local_rule', 'Kings Superior Court Local Rules',
        'KNGSCR Rule 125',
        'https://www.kings.courts.ca.gov/system/files/local-rules/current-local-rules_0.pdf',
        'Rule 125 addresses Electronic Filing (E-Filing) requirements. Rule 106 details payment of fees. Rule 111 specifies deadlines for filing documents.',
        'Rule 125', '2024-05-16', NOW(), 'web_verified', 'high'
    )
    ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        last_verified_at = NOW();

    RAISE NOTICE 'County citations seeded successfully';
END $$;

COMMIT;

-- ============================================================================
-- PART 3: ADD COUNTY-SPECIFIC VALIDATION RULES
-- ============================================================================
-- Rules link to citations via citation_id FK
-- Jurisdiction specificity lives HERE (not in citations)

DO $$
DECLARE
    -- Citation IDs
    lascr_330_id INTEGER;
    lascr_34_id INTEGER;
    lascr_pihub_id INTEGER;
    ocscr_301_id INTEGER;
    ocscr_352_id INTEGER;
    sdscr_409_id INTEGER;
    sdscr_div2_id INTEGER;
    sfscr_3_id INTEGER;
    rvscr_efile_id INTEGER;
    almscr_327_id INTEGER;
    scscr_notice_id INTEGER;
    ccscr_class_id INTEGER;
    sacscr_200_id INTEGER;
    smscr_div3_id INTEGER;
    solscr_3_id INTEGER;
    kngscr_125_id INTEGER;
BEGIN
    -- Get citation IDs
    SELECT id INTO lascr_330_id FROM leverage.rule_citations WHERE citation = 'LASCR Rule 3.30';
    SELECT id INTO lascr_34_id FROM leverage.rule_citations WHERE citation = 'LASCR Rule 3.4';
    SELECT id INTO lascr_pihub_id FROM leverage.rule_citations WHERE citation = 'LASCR PI Hub Standing Order';
    SELECT id INTO ocscr_301_id FROM leverage.rule_citations WHERE citation = 'OCSCR Rule 301';
    SELECT id INTO ocscr_352_id FROM leverage.rule_citations WHERE citation = 'OCSCR Rule 352';
    SELECT id INTO sdscr_409_id FROM leverage.rule_citations WHERE citation = 'SDSCR CIV-409';
    SELECT id INTO sdscr_div2_id FROM leverage.rule_citations WHERE citation = 'SDSCR Division II';
    SELECT id INTO sfscr_3_id FROM leverage.rule_citations WHERE citation = 'SFSCR Rule 3';
    SELECT id INTO rvscr_efile_id FROM leverage.rule_citations WHERE citation = 'RVSCR Civil eFiling';
    SELECT id INTO almscr_327_id FROM leverage.rule_citations WHERE citation = 'ALMSCR Rule 3.27';
    SELECT id INTO scscr_notice_id FROM leverage.rule_citations WHERE citation = 'SCSCR Civil Lawsuit Notice';
    SELECT id INTO ccscr_class_id UUID FROM leverage.rule_citations WHERE citation = 'CCSCR Civil Classification';
    SELECT id INTO sacscr_200_id FROM leverage.rule_citations WHERE citation = 'SACSCR Rule 2.00';
    SELECT id INTO smscr_div3_id FROM leverage.rule_citations WHERE citation = 'SMSCR Division III';
    SELECT id INTO solscr_3_id FROM leverage.rule_citations WHERE citation = 'SOLSCR Rule 3';
    SELECT id INTO kngscr_125_id FROM leverage.rule_citations WHERE citation = 'KNGSCR Rule 125';

    -- ========================================================================
    -- LOS ANGELES COUNTY RULES
    -- ========================================================================
    
    -- LA Mandatory eFiling for Attorneys
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    )
    SELECT 
        'CA-LA-SCR-3.30-MANDATORY-EFILING',
        5, 'LA Mandatory eFiling', 'format_check',
        'personal_injury', 'complaint',
        'state', 'CA', 'Los Angeles', 'Superior Court',
        '{"requires_efiling": true, "exemption": "self_represented"}'::jsonb,
        'error', lascr_330_id, 'draft',
        true, true, NULL, NOW(), NOW()
    WHERE NOT EXISTS (SELECT 1 FROM leverage.validation_rules WHERE rule_name = 'CA-LA-SCR-3.30-MANDATORY-EFILING');

    -- LA eFiling PDF Requirements
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    )
    SELECT 
        'CA-LA-SCR-3.4-PDF-FORMAT',
        5, 'LA PDF Format', 'format_check',
        'personal_injury', 'complaint',
        'state', 'CA', 'Los Angeles', 'Superior Court',
        '{"format": "PDF", "text_searchable": true, "bookmark_required": true}'::jsonb,
        'error', lascr_34_id, 'draft',
        true, true, NULL, NOW(), NOW()
    WHERE NOT EXISTS (SELECT 1 FROM leverage.validation_rules WHERE rule_name = 'CA-LA-SCR-3.4-PDF-FORMAT');

    -- LA PI Hub Venue Requirement
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    )
    SELECT 
        'CA-LA-PI-HUB-VENUE',
        5, 'LA PI Hub Venue', 'content_check',
        'personal_injury', 'complaint',
        'state', 'CA', 'Los Angeles', 'Superior Court',
        '{"venue_match": "incident_district"}'::jsonb,
        'warning', lascr_pihub_id, 'draft',
        true, true, NULL, NOW(), NOW()
    WHERE NOT EXISTS (SELECT 1 FROM leverage.validation_rules WHERE rule_name = 'CA-LA-PI-HUB-VENUE');

    -- ========================================================================
    -- ORANGE COUNTY RULES
    -- ========================================================================
    
    -- OC Civil Classification
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    )
    SELECT 
        'CA-OC-SCR-301-CIVIL-CLASS',
        5, 'OC Civil Classification', 'content_check',
        'personal_injury', 'complaint',
        'state', 'CA', 'Orange', 'Superior Court',
        '{"case_type": "civil", "excludes": ["family_law"]}'::jsonb,
        'info', ocscr_301_id, 'draft',
        true, true, NULL, NOW(), NOW()
    WHERE NOT EXISTS (SELECT 1 FROM leverage.validation_rules WHERE rule_name = 'CA-OC-SCR-301-CIVIL-CLASS');

    -- OC Mandatory eFiling
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    )
    SELECT 
        'CA-OC-SCR-352-EFILING',
        5, 'OC eFiling', 'format_check',
        'personal_injury', 'complaint',
        'state', 'CA', 'Orange', 'Superior Court',
        '{"requires_efiling": true, "effective_date": "2019-07-01"}'::jsonb,
        'error', ocscr_352_id, 'draft',
        true, true, NULL, NOW(), NOW()
    WHERE NOT EXISTS (SELECT 1 FROM leverage.validation_rules WHERE rule_name = 'CA-OC-SCR-352-EFILING');

    -- ========================================================================
    -- SAN DIEGO COUNTY RULES
    -- ========================================================================
    
    -- SD Mandatory eFiling for Attorneys
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    )
    SELECT 
        'CA-SD-CIV-409-EFILING',
        5, 'SD eFiling', 'format_check',
        'personal_injury', 'complaint',
        'state', 'CA', 'San Diego', 'Superior Court',
        '{"requires_efiling": true, "self_represented_optional": true}'::jsonb,
        'error', sdscr_409_id, 'draft',
        true, true, NULL, NOW(), NOW()
    WHERE NOT EXISTS (SELECT 1 FROM leverage.validation_rules WHERE rule_name = 'CA-SD-CIV-409-EFILING');

    -- SD Filing Location
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    )
    SELECT 
        'CA-SD-DIV2-FILING-LOCATION',
        5, 'SD Filing Location', 'required_field',
        'personal_injury', 'complaint',
        'state', 'CA', 'San Diego', 'Superior Court',
        '{"filing_office": "civil_business_office", "forms_required": "judicial_council"}'::jsonb,
        'error', sdscr_div2_id, 'draft',
        true, true, NULL, NOW(), NOW()
    WHERE NOT EXISTS (SELECT 1 FROM leverage.validation_rules WHERE rule_name = 'CA-SD-DIV2-FILING-LOCATION');

    -- ========================================================================
    -- SAN FRANCISCO COUNTY RULES
    -- ========================================================================
    
    -- SF eFiling Deadline
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    )
    SELECT 
        'CA-SF-SCR-3-EFILING-DEADLINE',
        5, 'SF eFiling Deadline', 'format_check',
        'personal_injury', 'complaint',
        'state', 'CA', 'San Francisco', 'Superior Court',
        '{"deadline_time": "23:59", "timezone": "America/Los_Angeles"}'::jsonb,
        'error', sfscr_3_id, 'draft',
        true, true, NULL, NOW(), NOW()
    WHERE NOT EXISTS (SELECT 1 FROM leverage.validation_rules WHERE rule_name = 'CA-SF-SCR-3-EFILING-DEADLINE');

    -- ========================================================================
    -- RIVERSIDE COUNTY RULES
    -- ========================================================================
    
    -- RV eFiling Midnight Deadline
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    )
    SELECT 
        'CA-RV-EFILING-DEADLINE',
        5, 'RV eFiling Deadline', 'format_check',
        'personal_injury', 'complaint',
        'state', 'CA', 'Riverside', 'Superior Court',
        '{"deadline_time": "23:59", "timezone": "America/Los_Angeles"}'::jsonb,
        'error', rvscr_efile_id, 'draft',
        true, true, NULL, NOW(), NOW()
    WHERE NOT EXISTS (SELECT 1 FROM leverage.validation_rules WHERE rule_name = 'CA-RV-EFILING-DEADLINE');

    -- ========================================================================
    -- ALAMEDA COUNTY RULES
    -- ========================================================================
    
    -- ALM Mandatory eFiling
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    )
    SELECT 
        'CA-ALM-SCR-3.27-EFILING',
        5, 'Alameda eFiling', 'format_check',
        'personal_injury', 'complaint',
        'state', 'CA', 'Alameda', 'Superior Court',
        '{"requires_efiling": true, "effective_date": "2022-01-01"}'::jsonb,
        'error', almscr_327_id, 'draft',
        true, true, NULL, NOW(), NOW()
    WHERE NOT EXISTS (SELECT 1 FROM leverage.validation_rules WHERE rule_name = 'CA-ALM-SCR-3.27-EFILING');

    -- ========================================================================
    -- SANTA CLARA COUNTY RULES
    -- ========================================================================
    
    -- SC Civil Lawsuit Notice
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    )
    SELECT 
        'CA-SC-CIVIL-NOTICE',
        5, 'SC Civil Lawsuit Notice', 'required_field',
        'personal_injury', 'complaint',
        'state', 'CA', 'Santa Clara', 'Superior Court',
        '{"required_form": "CV-5012", "must_serve": true}'::jsonb,
        'error', scscr_notice_id, 'draft',
        true, true, NULL, NOW(), NOW()
    WHERE NOT EXISTS (SELECT 1 FROM leverage.validation_rules WHERE rule_name = 'CA-SC-CIVIL-NOTICE');

    -- ========================================================================
    -- CONTRA COSTA COUNTY RULES
    -- ========================================================================
    
    -- CC Civil Classification Thresholds
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    )
    SELECT 
        'CA-CC-CIVIL-THRESHOLDS',
        5, 'CC Civil Thresholds', 'threshold_check',
        'personal_injury', 'complaint',
        'state', 'CA', 'Contra Costa', 'Superior Court',
        '{"small_claims_max": 12500, "limited_max": 35000}'::jsonb,
        'info', ccscr_class_id, 'draft',
        true, true, NULL, NOW(), NOW()
    WHERE NOT EXISTS (SELECT 1 FROM leverage.validation_rules WHERE rule_name = 'CA-CC-CIVIL-THRESHOLDS');

    -- ========================================================================
    -- SACRAMENTO COUNTY RULES
    -- ========================================================================
    
    -- SAC Sanctions Warning
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    )
    SELECT 
        'CA-SAC-SCR-2.00-SANCTIONS',
        5, 'Sacramento Sanctions', 'warning_check',
        'personal_injury', 'complaint',
        'state', 'CA', 'Sacramento', 'Superior Court',
        '{"non_compliance_warning": true, "penalties": ["strike_pleadings", "dismissal", "costs"]}'::jsonb,
        'warning', sacscr_200_id, 'draft',
        true, true, NULL, NOW(), NOW()
    WHERE NOT EXISTS (SELECT 1 FROM leverage.validation_rules WHERE rule_name = 'CA-SAC-SCR-2.00-SANCTIONS');

    -- ========================================================================
    -- SAN MATEO COUNTY RULES
    -- ========================================================================
    
    -- SM Civil Procedures
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    )
    SELECT 
        'CA-SM-DIV3-CIVIL',
        5, 'SM Civil Procedures', 'required_field',
        'personal_injury', 'complaint',
        'state', 'CA', 'San Mateo', 'Superior Court',
        '{"division": "III", "forms_required": true}'::jsonb,
        'info', smscr_div3_id, 'draft',
        true, true, NULL, NOW(), NOW()
    WHERE NOT EXISTS (SELECT 1 FROM leverage.validation_rules WHERE rule_name = 'CA-SM-DIV3-CIVIL');

    -- ========================================================================
    -- SOLANO COUNTY RULES
    -- ========================================================================
    
    -- SOL Civil Filing
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    )
    SELECT 
        'CA-SOL-RULE-3-CIVIL',
        5, 'Solano Civil Filing', 'required_field',
        'personal_injury', 'complaint',
        'state', 'CA', 'Solano', 'Superior Court',
        '{"rule": "3", "admin_rule": "4"}'::jsonb,
        'info', solscr_3_id, 'draft',
        true, true, NULL, NOW(), NOW()
    WHERE NOT EXISTS (SELECT 1 FROM leverage.validation_rules WHERE rule_name = 'CA-SOL-RULE-3-CIVIL');

    -- ========================================================================
    -- KINGS COUNTY RULES
    -- ========================================================================
    
    -- KNG eFiling Requirements
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    )
    SELECT 
        'CA-KNG-RULE-125-EFILING',
        5, 'Kings eFiling', 'format_check',
        'personal_injury', 'complaint',
        'state', 'CA', 'Kings', 'Superior Court',
        '{"rule": "125", "fee_rule": "106", "deadline_rule": "111"}'::jsonb,
        'error', kngscr_125_id, 'draft',
        true, true, NULL, NOW(), NOW()
    WHERE NOT EXISTS (SELECT 1 FROM leverage.validation_rules WHERE rule_name = 'CA-KNG-RULE-125-EFILING');

    RAISE NOTICE 'County validation rules seeded successfully';
END $$;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Count legal sources by type
SELECT 
    jurisdiction_type, 
    jurisdiction_county,
    COUNT(*) AS source_count
FROM leverage.legal_sources
WHERE jurisdiction_state = 'CA'
GROUP BY jurisdiction_type, jurisdiction_county
ORDER BY jurisdiction_county;

-- Count citations by county
SELECT 
    ls.jurisdiction_county,
    COUNT(rc.id) AS citation_count
FROM leverage.legal_sources ls
LEFT JOIN leverage.rule_citations rc ON rc.legal_source_id = ls.id
WHERE ls.jurisdiction_state = 'CA' AND ls.jurisdiction_type = 'county'
GROUP BY ls.jurisdiction_county
ORDER BY ls.jurisdiction_county;

-- Count rules by county
SELECT 
    jurisdiction_county,
    COUNT(*) AS rule_count
FROM leverage.validation_rules
WHERE jurisdiction_state = 'CA' 
  AND jurisdiction_county IS NOT NULL
  AND practice_area = 'personal_injury'
GROUP BY jurisdiction_county
ORDER BY jurisdiction_county;

-- Verify all county rules have citations
SELECT 
    vr.jurisdiction_county,
    COUNT(*) AS total_rules,
    COUNT(vr.citation_id) AS with_citation,
    COUNT(*) - COUNT(vr.citation_id) AS missing_citation
FROM leverage.validation_rules vr
WHERE vr.jurisdiction_state = 'CA' 
  AND vr.jurisdiction_county IS NOT NULL
  AND vr.practice_area = 'personal_injury'
GROUP BY vr.jurisdiction_county
ORDER BY vr.jurisdiction_county;

-- Show sample of rules with full citation info
SELECT 
    vr.rule_name,
    vr.jurisdiction_county,
    vr.severity,
    rc.citation,
    LEFT(rc.excerpt, 60) AS excerpt_preview,
    rc.source_url
FROM leverage.validation_rules vr
JOIN leverage.rule_citations rc ON rc.id = vr.citation_id
WHERE vr.jurisdiction_state = 'CA' 
  AND vr.jurisdiction_county IS NOT NULL
  AND vr.practice_area = 'personal_injury'
ORDER BY vr.jurisdiction_county, vr.rule_name
LIMIT 20;
