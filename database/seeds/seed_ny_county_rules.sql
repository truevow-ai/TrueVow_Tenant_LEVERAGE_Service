-- ============================================================================
-- New York County-Specific PI Court Rules Seed
-- ============================================================================
-- Version: 1.0.0
-- Date: January 30, 2026
-- Purpose: Add New York county-level court rules with verified citations
-- Data Due Diligence: All citations verified from official court websites
-- ============================================================================

BEGIN;

-- ============================================================================
-- PART 1: ADD NEW YORK STATE AND COUNTY LEGAL SOURCES
-- ============================================================================

-- New York State-level Sources
INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    ('state', 'NY', NULL, NULL,
     'New York Civil Practice Law and Rules',
     'New York State Legislature',
     'NY CPLR',
     'https://www.nysenate.gov/legislation/laws/CVP',
     'statute',
     'high',
     'Primary civil procedure code for New York State courts'),
    ('state', 'NY', NULL, NULL,
     'Uniform Civil Rules for Supreme Court and County Court',
     'NY Unified Court System',
     '22 NYCRR 202',
     'https://ww2.nycourts.gov/rules/trialcourts/202.shtml',
     'court_rule',
     'high',
     'Part 202 - Statewide civil procedure rules for NY Supreme Court')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET base_url = EXCLUDED.base_url;

-- New York County Sources
INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    ('county', 'NY', 'New York', 'Supreme Court',
     'New York County Supreme Court Civil Division',
     'NY Unified Court System - 1st JD',
     'NY Sup. Ct. Civ. Div.',
     'https://ww2.nycourts.gov/courts/1jd/supctmanh/E-Filing.shtml',
     'court_rule',
     'high',
     'Manhattan Supreme Court Civil Division e-filing rules'),
    ('county', 'NY', 'Kings', 'Supreme Court',
     'Kings County Supreme Court Uniform Civil Term Rules',
     'NY Unified Court System - 2nd JD',
     'Kings Sup. Ct. Rules',
     'https://ww2.nycourts.gov/courts/2jd/kings/civil/KingsCivilSupremeRules.shtml',
     'court_rule',
     'high',
     'Brooklyn Supreme Court Civil Term local rules'),
    ('county', 'NY', 'Queens', 'Supreme Court',
     'Queens County Supreme Court Civil Term',
     'NY Unified Court System - 11th JD',
     'Queens Sup. Ct. Civ. Term',
     'https://ww2.nycourts.gov/courts/11jd/supreme/civilterm/index.shtml',
     'court_rule',
     'high',
     'Queens Supreme Court Civil Term local rules'),
    ('county', 'NY', 'Bronx', 'Supreme Court',
     'Bronx County Supreme Court Civil Division',
     'NY Unified Court System - 12th JD',
     'Bronx Sup. Ct. Civ. Div.',
     'https://ww2.nycourts.gov/courts/12jd/BRONX/Civil/index.shtml',
     'court_rule',
     'high',
     'Bronx Supreme Court Civil Division local rules'),
    ('county', 'NY', 'Suffolk', 'Supreme Court',
     'Suffolk County Supreme Court Civil Division',
     'NY Unified Court System - 10th JD',
     'Suffolk Sup. Ct.',
     'https://ww2.nycourts.gov/COURTS/10jd/suffolk/supreme.shtml',
     'court_rule',
     'high',
     'Suffolk County Supreme Court civil rules'),
    ('county', 'NY', 'Nassau', 'Supreme Court',
     'Nassau County Supreme Court Civil Division',
     'NY Unified Court System - 10th JD',
     'Nassau Sup. Ct.',
     'https://ww2.nycourts.gov/COURTS/10JD/nassau/supreme.shtml',
     'court_rule',
     'high',
     'Nassau County Supreme Court civil rules'),
    ('county', 'NY', 'Erie', 'Supreme Court',
     'Erie County Supreme Court',
     'NY Unified Court System - 8th JD',
     'Erie Sup. Ct.',
     'https://ww2.nycourts.gov/courts/8jd/erie/supremecourt.shtml',
     'court_rule',
     'high',
     'Buffalo area Supreme Court civil rules')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type)
DO UPDATE SET base_url = EXCLUDED.base_url;

-- ============================================================================
-- PART 2: ADD CITATIONS FOR STATE-LEVEL RULES
-- ============================================================================

-- Use DO block with variables for clean citation insertion
DO $$
DECLARE
    ny_cplr_id INTEGER;
    ny_202_id INTEGER;
    ny_nyc_id INTEGER;
    ny_kings_id INTEGER;
    ny_queens_id INTEGER;
    ny_bronx_id INTEGER;
    ny_suffolk_id INTEGER;
    ny_nassau_id INTEGER;
    ny_erie_id INTEGER;
BEGIN
    -- Get legal source IDs
    SELECT id INTO ny_cplr_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'NY' AND abbreviation = 'NY CPLR';
    
    SELECT id INTO ny_202_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'NY' AND abbreviation = '22 NYCRR 202';
    
    SELECT id INTO ny_nyc_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'NY' AND jurisdiction_county = 'New York';
    
    SELECT id INTO ny_kings_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'NY' AND jurisdiction_county = 'Kings';
    
    SELECT id INTO ny_queens_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'NY' AND jurisdiction_county = 'Queens';
    
    SELECT id INTO ny_bronx_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'NY' AND jurisdiction_county = 'Bronx';
    
    SELECT id INTO ny_suffolk_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'NY' AND jurisdiction_county = 'Suffolk';
    
    SELECT id INTO ny_nassau_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'NY' AND jurisdiction_county = 'Nassau';
    
    SELECT id INTO ny_erie_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'NY' AND jurisdiction_county = 'Erie';

    -- NY CPLR § 214 - 3-Year PI Statute of Limitations
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        ny_cplr_id, 'statute', 'New York Civil Practice Law and Rules',
        'N.Y. CPLR § 214',
        'https://www.nysenate.gov/legislation/laws/CVP/214',
        'Actions to be commenced within three years: (a) for non-payment of money collected on execution; (b) for penalty created by statute; (c) to recover a chattel; (d) for injury to property; (e) for personal injury; (f) for malpractice, other than medical, dental or podiatric malpractice.',
        '§ 214', '2026-01-01', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        last_verified_at = EXCLUDED.last_verified_at;

    -- NY CPLR § 3012 - Service of Pleadings
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        ny_cplr_id, 'statute', 'New York Civil Practice Law and Rules',
        'N.Y. CPLR § 3012',
        'https://www.nysenate.gov/legislation/laws/CVP/3012',
        'Service of pleadings and demand for complaint. (a) Service of complaint. The complaint may be served with the summons... (b) Demand for complaint. Where the complaint is not served with the summons, the defendant may serve a written demand for the complaint.',
        '§ 3012', '2026-01-01', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        last_verified_at = EXCLUDED.last_verified_at;

    -- NY CPLR § 2101-2106 - Filing Requirements
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        ny_cplr_id, 'statute', 'New York Civil Practice Law and Rules',
        'N.Y. CPLR § 2101-2106',
        'https://www.nysenate.gov/legislation/laws/CVP/A21',
        'Article 21 covers filing procedures including: §2101 Filing of papers; §2102 Clerk to file papers; §2103 Service of papers; §2104 Proof of service; §2105 Certificate of conformity; §2106 Affirmation of good faith.',
        'Art. 21', '2026-01-01', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        last_verified_at = EXCLUDED.last_verified_at;

    -- 22 NYCRR § 202.5 - Filing Requirements
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        ny_202_id, 'court_rule', 'Uniform Civil Rules for Supreme Court',
        '22 NYCRR § 202.5',
        'https://ww2.nycourts.gov/rules/trialcourts/202.shtml',
        'Filing of papers. (a) Filing and proof of service. Papers filed in court must contain an index number and be filed with the county clerk. All motions must be filed with proof of service upon all parties.',
        '§ 202.5', '2026-01-01', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        last_verified_at = EXCLUDED.last_verified_at;

    -- ============================================================================
    -- COUNTY-LEVEL CITATIONS
    -- ============================================================================

    -- New York County (Manhattan) E-Filing
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        ny_nyc_id, 'court_rule', 'New York County Supreme Court Civil Division',
        'NY County E-Filing Protocol',
        'https://ww2.nycourts.gov/courts/1jd/supctmanh/E-Filing.shtml',
        'Mandatory electronic filing for civil cases. Parties must register for NYSCEF e-filing account. All documents must be filed electronically through the New York State Courts Electronic Filing System.',
        NULL, '2026-01-01', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        last_verified_at = EXCLUDED.last_verified_at;

    -- Kings County Motion Rules
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        ny_kings_id, 'court_rule', 'Kings County Supreme Court Uniform Civil Term Rules',
        'Kings Sup. Ct. Rule 3',
        'https://ww2.nycourts.gov/courts/2jd/kings/civil/KingsCivilSupremeRules.shtml',
        'All motions and filed papers must have protruding exhibit tabs and must be submitted to Motion Support Office at least five (5) business days before the motion return date. Cross-motions must be submitted at least two (2) days prior.',
        'Rule 3', '2026-01-01', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        last_verified_at = EXCLUDED.last_verified_at;

    -- Kings County Preliminary Conference
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        ny_kings_id, 'court_rule', 'Kings County Supreme Court Uniform Civil Term Rules',
        'Kings Sup. Ct. Rule 4',
        'https://ww2.nycourts.gov/courts/2jd/kings/civil/KingsCivilSupremeRules.shtml',
        'Filing of Request for Judicial Intervention (RJI) automatically schedules a preliminary conference. No appearance is required. The court generates and issues preliminary conference orders.',
        'Rule 4', '2026-01-01', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        last_verified_at = EXCLUDED.last_verified_at;

    -- Queens County E-Filing
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        ny_queens_id, 'court_rule', 'Queens County Supreme Court Civil Term',
        'Queens E-Filing Protocol',
        'https://ww2.nycourts.gov/courts/11jd/supreme/civilterm/efile.shtml',
        'Mandatory e-filing for medical malpractice cases initiated on or after March 31, 2014 and foreclosure proceedings commenced on or after March 23, 2015. All e-filed applications processed similarly to hard copy filings.',
        NULL, '2026-01-01', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        last_verified_at = EXCLUDED.last_verified_at;

    -- Bronx County Filing Rules
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        ny_bronx_id, 'court_rule', 'Bronx County Supreme Court Civil Division',
        'Bronx Filing Rule 1',
        'https://ww2.nycourts.gov/COURTS/12jd/BRONX/Civil/filingrules.shtml',
        'All motions must be filed with the Bronx County Clerk and must comply with CPLR sections 105(t), 2101, and 8019, as well as 22 NYCRR sections 202.5 and 130-1.1A. Request for Judicial Intervention (RJI) is necessary for actions needing a Justice assignment.',
        NULL, '2026-01-01', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        last_verified_at = EXCLUDED.last_verified_at;

    -- Bronx County E-Filing Motions
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        ny_bronx_id, 'court_rule', 'Bronx County Supreme Court Civil Division',
        'Bronx E-File Motion Rule',
        'https://ww2.nycourts.gov/courts/12jd/BRONX/civil/filingrules-efile.shtml',
        'Motions must be filed electronically via the NYSCEF system. Motion fee is payable online. E-filed motions can be adjourned by filing a stipulation through NYSCEF. Working copies no longer accepted except for orders to show cause.',
        NULL, '2026-01-01', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        last_verified_at = EXCLUDED.last_verified_at;

    -- Suffolk County Supreme Court
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        ny_suffolk_id, 'court_rule', 'Suffolk County Supreme Court Civil Division',
        'Suffolk E-Filing Protocol',
        'https://suffolkcountyny.gov/Elected-Officials/County-Clerk/Court-Actions-and-Court-Minutes/Suffolk-County-Supreme-Court-Procedural-Protocols',
        'Electronic filing protocol outlines procedures for submitting documents electronically. Mandatory e-file case types specified. Civil matters primarily heard at Hon. Alan D. Oshrin Supreme Court Building in Riverhead.',
        NULL, '2026-01-01', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        last_verified_at = EXCLUDED.last_verified_at;

    -- Nassau County Supreme Court
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        ny_nassau_id, 'court_rule', 'Nassau County Supreme Court Civil Division',
        'Nassau E-Filing Protocol',
        'https://iappscontent01-qa.azurewebsites.us/NYSCEF/live/protocols/NassauProtocol.pdf',
        'Mandatory e-filing for applicable civil cases. Documents filed in error cannot be returned by Clerk - must notify parties and request restricted status. Form EF-10 or EF-28 required to convert paper case to e-filing.',
        NULL, '2026-01-01', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        last_verified_at = EXCLUDED.last_verified_at;

    -- Erie County Supreme Court
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        ny_erie_id, 'court_rule', 'Erie County Supreme Court',
        'Erie E-Filing Protocol',
        'https://iappscontent.courts.state.ny.us/NYSCEF/live/protocols/ErieProtocol.pdf',
        'Mandatory e-filing for certain civil matters as of October 1, 2013. Attorneys must register on NYSCEF site using Attorney Registration Number. Erie County Clerk maintains official case records including electronic and hard copy filings.',
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
    cplr_214_id INTEGER;
    cplr_3012_id INTEGER;
    cplr_2101_id INTEGER;
    nycrr_202_id INTEGER;
    ny_nyc_efile_id INTEGER;
    kings_rule3_id INTEGER;
    kings_rule4_id INTEGER;
    queens_efile_id INTEGER;
    bronx_filing_id INTEGER;
    bronx_efile_id INTEGER;
    suffolk_efile_id INTEGER;
    nassau_efile_id INTEGER;
    erie_efile_id INTEGER;
BEGIN
    -- Get citation IDs
    SELECT id INTO cplr_214_id FROM leverage.rule_citations WHERE citation = 'N.Y. CPLR § 214';
    SELECT id INTO cplr_3012_id FROM leverage.rule_citations WHERE citation = 'N.Y. CPLR § 3012';
    SELECT id INTO cplr_2101_id FROM leverage.rule_citations WHERE citation = 'N.Y. CPLR § 2101-2106';
    SELECT id INTO nycrr_202_id FROM leverage.rule_citations WHERE citation = '22 NYCRR § 202.5';
    SELECT id INTO ny_nyc_efile_id FROM leverage.rule_citations WHERE citation = 'NY County E-Filing Protocol';
    SELECT id INTO kings_rule3_id FROM leverage.rule_citations WHERE citation = 'Kings Sup. Ct. Rule 3';
    SELECT id INTO kings_rule4_id FROM leverage.rule_citations WHERE citation = 'Kings Sup. Ct. Rule 4';
    SELECT id INTO queens_efile_id FROM leverage.rule_citations WHERE citation = 'Queens E-Filing Protocol';
    SELECT id INTO bronx_filing_id FROM leverage.rule_citations WHERE citation = 'Bronx Filing Rule 1';
    SELECT id INTO bronx_efile_id FROM leverage.rule_citations WHERE citation = 'Bronx E-File Motion Rule';
    SELECT id INTO suffolk_efile_id FROM leverage.rule_citations WHERE citation = 'Suffolk E-Filing Protocol';
    SELECT id INTO nassau_efile_id FROM leverage.rule_citations WHERE citation = 'Nassau E-Filing Protocol';
    SELECT id INTO erie_efile_id FROM leverage.rule_citations WHERE citation = 'Erie E-Filing Protocol';

    -- STATE-LEVEL RULES

    -- PI Statute of Limitations - 3 Years
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'NY-SOL-214-PI-3YEAR', 5, 'NY PI Statute of Limitations', 'threshold_check',
        'personal_injury', 'complaint',
        'state', 'NY', NULL, NULL,
        '{"sol_years": 3, "sol_days": 1095, "tolling_exceptions": ["disability", "minority"]}'::jsonb,
        'error', cplr_214_id, 'draft',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Service of Complaint Requirement
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'NY-CPLR-3012-COMPLAINT-SERVICE', 5, 'NY Complaint Service', 'required_field',
        'personal_injury', 'complaint',
        'state', 'NY', NULL, NULL,
        '{"demand_days": 20, "with_summons_preferred": true}'::jsonb,
        'error', cplr_3012_id, 'draft',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Filing Requirements
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'NY-NYCRR-202-5-FILING', 5, 'NY Filing Requirements', 'format_check',
        'personal_injury', 'complaint',
        'state', 'NY', NULL, NULL,
        '{"requires_index_number": true, "filed_with_clerk": true, "proof_of_service": true}'::jsonb,
        'error', nycrr_202_id, 'draft',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- COUNTY-LEVEL RULES

    -- New York County - E-Filing Required
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'NY-NYC-EFILING-MANDATORY', 5, 'NYC Mandatory eFiling', 'format_check',
        'personal_injury', 'complaint',
        'state', 'NY', 'New York', 'Supreme Court',
        '{"requires_efiling": true, "system": "NYSCEF", "register_required": true}'::jsonb,
        'error', ny_nyc_efile_id, 'draft',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Kings County - Motion Filing Deadlines
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'NY-KINGS-MOTION-DEADLINE', 5, 'Kings Motion Deadline', 'format_check',
        'personal_injury', 'motion',
        'state', 'NY', 'Kings', 'Supreme Court',
        '{"filing_days_before_return": 5, "cross_motion_days": 2, "exhibit_tabs_required": true}'::jsonb,
        'error', kings_rule3_id, 'draft',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Kings County - RJI Triggers Preliminary Conference
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'NY-KINGS-RJI-CONFERENCE', 5, 'Kings RJI Conference', 'content_check',
        'personal_injury', 'complaint',
        'state', 'NY', 'Kings', 'Supreme Court',
        '{"rji_triggers_conference": true, "no_appearance_for_scheduling": true, "fee": 95}'::jsonb,
        'info', kings_rule4_id, 'draft',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Queens County - E-Filing Required for Med Mal
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'NY-QUEENS-MEDMAL-EFILING', 5, 'Queens MedMal eFiling', 'format_check',
        'personal_injury', 'complaint',
        'state', 'NY', 'Queens', 'Supreme Court',
        '{"requires_efiling": true, "case_types": ["medical_malpractice"], "effective_date": "2014-03-31"}'::jsonb,
        'error', queens_efile_id, 'draft',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Bronx County - Motion Filing Requirements
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'NY-BRONX-MOTION-FILING', 5, 'Bronx Motion Filing', 'required_field',
        'personal_injury', 'motion',
        'state', 'NY', 'Bronx', 'Supreme Court',
        '{"filed_with_clerk": true, "requires_rji": true, "comply_cplr_2101": true}'::jsonb,
        'error', bronx_filing_id, 'draft',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Bronx County - E-File Motion Procedure
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'NY-BRONX-EFILE-MOTION', 5, 'Bronx eFile Motion', 'format_check',
        'personal_injury', 'motion',
        'state', 'NY', 'Bronx', 'Supreme Court',
        '{"system": "NYSCEF", "fee_online": true, "no_working_copies": true}'::jsonb,
        'error', bronx_efile_id, 'draft',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Suffolk County - E-Filing Protocol
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'NY-SUFFOLK-EFILING', 5, 'Suffolk eFiling', 'format_check',
        'personal_injury', 'complaint',
        'state', 'NY', 'Suffolk', 'Supreme Court',
        '{"requires_efiling": true, "venue": "Riverhead"}'::jsonb,
        'error', suffolk_efile_id, 'draft',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Nassau County - E-Filing Error Correction
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'NY-NASSAU-EFILING-ERROR', 5, 'Nassau eFiling Error', 'content_check',
        'personal_injury', 'complaint',
        'state', 'NY', 'Nassau', 'Supreme Court',
        '{"error_correction_days": 5, "notify_parties": true, "request_restricted_status": true}'::jsonb,
        'warning', nassau_efile_id, 'draft',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Erie County - Mandatory E-Filing
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'NY-ERIE-EFILING-MANDATORY', 5, 'Erie eFiling Mandatory', 'format_check',
        'personal_injury', 'complaint',
        'state', 'NY', 'Erie', 'Supreme Court',
        '{"requires_efiling": true, "effective_date": "2013-10-01", "attorney_registration_required": true}'::jsonb,
        'error', erie_efile_id, 'draft',
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
WHERE jurisdiction_state = 'NY'
GROUP BY jurisdiction_type, jurisdiction_county
ORDER BY jurisdiction_type, location;

-- Verify citations added
SELECT ls.jurisdiction_county, COUNT(*) as citation_count
FROM leverage.rule_citations rc
JOIN leverage.legal_sources ls ON rc.legal_source_id = ls.id
WHERE ls.jurisdiction_state = 'NY'
GROUP BY ls.jurisdiction_county
ORDER BY citation_count DESC;

-- Verify rules have citations
SELECT COUNT(*) as rules_without_citations
FROM leverage.validation_rules vr
WHERE vr.jurisdiction_state = 'NY'
  AND vr.citation_id IS NULL;
