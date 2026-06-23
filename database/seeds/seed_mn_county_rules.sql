-- ============================================================================
-- Minnesota County-Specific PI Court Rules Seed
-- ============================================================================
-- Version: 1.0.0
-- Date: January 30, 2026
-- Purpose: Add Minnesota county-level court rules with verified citations
-- High-volume PI counties: Hennepin (Minneapolis), Ramsey (St. Paul), Dakota, Anoka, Washington
-- IMPORTANT: Minnesota has 6-YEAR SOL for personal injury (LONGEST among major states)
-- Data Due Diligence: Citations verified from revisor.mn.gov and mncourts.gov
-- ============================================================================
-- DOCUMENT VERIFIED CITATIONS:
--
-- 1. Minn. Stat. § 541.05 - VARIOUS CASES, SIX YEARS
--    Source: https://www.revisor.mn.gov/statutes/cite/541.05
--    EXACT TEXT: "Subdivision 1. Six-year limitation. Except where the Uniform 
--    Commercial Code otherwise prescribes, the following actions shall be 
--    commenced within six years: ... (5) for criminal conversation, or for any 
--    other injury to the person or rights of another, not arising on contract, 
--    and not hereinafter enumerated;"
--
-- 2. Minnesota General Rules of Practice, Rule 14 - Electronic Filing
--    Source: https://www.revisor.mn.gov/court_rules/gp/id/14/
--    Effective: July 1, 2015
--    Mandatory for attorneys, government agencies, guardians ad litem
--
-- 3. Statewide E-Filing (all 87 counties)
--    Source: https://mncourts.gov/file-a-case/file-in-a-district-trial-court
--    EXACT TEXT: "The use of eFS is mandatory for attorneys, government agencies, 
--    and guardians ad litem, in all court cases filed in all 87 Minnesota counties."
-- ============================================================================

BEGIN;

-- ============================================================================
-- PART 1: ADD MINNESOTA STATE AND COUNTY LEGAL SOURCES
-- ============================================================================

-- Minnesota State-level Sources
INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    ('state', 'MN', NULL, NULL,
     'Minnesota Statutes',
     'Minnesota Revisor of Statutes',
     'Minn. Stat.',
     'https://www.revisor.mn.gov/statutes/',
     'statute',
     'high',
     'Official Minnesota Statutes. Section 541.05 establishes 6-year SOL for personal injury. DOCUMENT VERIFIED.'),
    ('state', 'MN', NULL, NULL,
     'Minnesota General Rules of Practice',
     'Minnesota Supreme Court',
     'Minn. Gen. R. Prac.',
     'https://www.revisor.mn.gov/court_rules/gp/',
     'court_rule',
     'high',
     'Minnesota General Rules of Practice including Rule 14 on e-filing. Effective July 1, 2015.')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET base_url = EXCLUDED.base_url, notes = EXCLUDED.notes;

-- Minnesota County Sources (Major PI Jurisdictions)
INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
)
VALUES
    ('county', 'MN', 'Hennepin', 'District Court',
     'Hennepin County District Court Local Rules',
     'Fourth Judicial District Court',
     'Hennepin L.R.',
     'https://mncourts.gov/Find-Courts/Hennepin',
     'court_rule',
     'high',
     'Hennepin County District Court (Minneapolis). Fourth Judicial District. E-filing mandatory since July 1, 2015. WEB VERIFIED.'),
    ('county', 'MN', 'Ramsey', 'District Court',
     'Ramsey County District Court Local Rules',
     'Second Judicial District Court',
     'Ramsey L.R.',
     'https://mncourts.gov/Find-Courts/Ramsey',
     'court_rule',
     'high',
     'Ramsey County District Court (St. Paul). Second Judicial District. E-filing mandatory for attorneys. WEB VERIFIED.'),
    ('county', 'MN', 'Dakota', 'District Court',
     'Dakota County District Court Local Rules',
     'First Judicial District Court',
     'Dakota L.R.',
     'https://mncourts.gov/Find-Courts/Dakota',
     'court_rule',
     'high',
     'Dakota County District Court. First Judicial District. E-filing mandatory for attorneys. WEB VERIFIED.'),
    ('county', 'MN', 'Anoka', 'District Court',
     'Anoka County District Court Local Rules',
     'Tenth Judicial District Court',
     'Anoka L.R.',
     'https://mncourts.gov/Find-Courts/Anoka',
     'court_rule',
     'high',
     'Anoka County District Court. Tenth Judicial District. E-filing mandatory for attorneys. WEB VERIFIED.'),
    ('county', 'MN', 'Washington', 'District Court',
     'Washington County District Court Local Rules',
     'Tenth Judicial District Court',
     'Washington L.R.',
     'https://mncourts.gov/Find-Courts/Washington',
     'court_rule',
     'high',
     'Washington County District Court. Tenth Judicial District. E-filing mandatory for attorneys. WEB VERIFIED.')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET base_url = EXCLUDED.base_url, notes = EXCLUDED.notes;

-- ============================================================================
-- PART 2: ADD MINNESOTA STATE AND COUNTY CITATIONS
-- ============================================================================

DO $$
DECLARE
    mn_stat_id INTEGER;
    mn_grp_id INTEGER;
    mn_hennepin_id INTEGER;
    mn_ramsey_id INTEGER;
    mn_dakota_id INTEGER;
    mn_anoka_id INTEGER;
    mn_washington_id INTEGER;
BEGIN
    -- Get legal source IDs
    SELECT id INTO mn_stat_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'MN' AND abbreviation = 'Minn. Stat.';
    
    SELECT id INTO mn_grp_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'MN' AND abbreviation = 'Minn. Gen. R. Prac.';
    
    SELECT id INTO mn_hennepin_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'MN' AND jurisdiction_county = 'Hennepin';
    
    SELECT id INTO mn_ramsey_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'MN' AND jurisdiction_county = 'Ramsey';
    
    SELECT id INTO mn_dakota_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'MN' AND jurisdiction_county = 'Dakota';
    
    SELECT id INTO mn_anoka_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'MN' AND jurisdiction_county = 'Anoka';
    
    SELECT id INTO mn_washington_id FROM leverage.legal_sources 
    WHERE jurisdiction_state = 'MN' AND jurisdiction_county = 'Washington';

    -- Minn. Stat. § 541.05 - Minnesota 6-Year SOL for Personal Injury
    -- DOCUMENT VERIFIED: EXACT TEXT from revisor.mn.gov
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        mn_stat_id, 'statute', 'Minnesota Statutes',
        'Minn. Stat. § 541.05',
        'https://www.revisor.mn.gov/statutes/cite/541.05',
        'Subdivision 1. Six-year limitation. Except where the Uniform Commercial Code otherwise prescribes, the following actions shall be commenced within six years: (1) upon a contract or other obligation, express or implied, as to which no other limitation is expressly prescribed; (2) upon a liability created by statute, other than those arising upon a penalty or forfeiture or where a shorter period is provided by section 541.07; (3) for a trespass upon real estate; (4) for taking, detaining, or injuring personal property, including actions for the specific recovery thereof; (5) for criminal conversation, or for any other injury to the person or rights of another, not arising on contract, and not hereinafter enumerated.',
        '§ 541.05, Subd. 1(5)', NOW()::date, NOW(), 'document_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        verifier = EXCLUDED.verifier;

    -- Minnesota General Rules of Practice, Rule 14 - Electronic Filing
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        mn_grp_id, 'court_rule', 'Minnesota General Rules of Practice',
        'Minn. Gen. R. Prac. 14',
        'https://www.revisor.mn.gov/court_rules/gp/id/14/',
        'Rule 14 mandates electronic filing (e-filing) and electronic service (e-service) for Select Users in designated judicial districts. Select Users include attorneys, government agencies, and guardians ad litem, who must utilize the designated E-Filing System for submissions.',
        'Rule 14', '2015-07-01', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Statewide E-Filing - All 87 Counties
    -- DOCUMENT VERIFIED: EXACT TEXT from mncourts.gov
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        mn_grp_id, 'court_rule', 'Minnesota General Rules of Practice',
        'MN-STATEWIDE-EFILING',
        'https://mncourts.gov/file-a-case/file-in-a-district-trial-court',
        'The use of eFS is mandatory for attorneys, government agencies, and guardians ad litem, in all court cases filed in all 87 Minnesota counties. All filers who are not required by court rule to use eFS, such as self-represented litigants, may choose to use eFS in all Minnesota counties.',
        'E-Filing', '2015-07-01', NOW(), 'document_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        verifier = EXCLUDED.verifier;

    -- Hennepin County (Minneapolis) E-Filing Citation
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        mn_hennepin_id, 'local_rule', 'Hennepin County District Court Local Rules',
        'MN-HENNEPIN-EFILING',
        'https://mncourts.gov/Find-Courts/Hennepin/File-a-Document-in-Court.aspx',
        'eFiling is mandatory for attorneys, government agencies, and guardians ad litem filing documents in the Hennepin County District Court, as per amendments to the Minnesota General Rules of Practice effective July 1, 2015.',
        'E-Filing', '2015-07-01', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Ramsey County (St. Paul) E-Filing Citation
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        mn_ramsey_id, 'local_rule', 'Ramsey County District Court Local Rules',
        'MN-RAMSEY-EFILING',
        'https://mncourts.gov/Find-Courts/Ramsey',
        'Electronic filing (eFiling) is mandatory for attorneys, government agencies, and guardians ad litem in Ramsey County District Court. The eFile and eServe (eFS) system must be used for electronic filing and service.',
        'E-Filing', '2015-07-01', NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Dakota County E-Filing Citation
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        mn_dakota_id, 'local_rule', 'Dakota County District Court Local Rules',
        'MN-DAKOTA-EFILING',
        'https://mncourts.gov/Find-Courts/Dakota',
        'E-filing is mandatory for attorneys in Dakota County District Court per Minnesota statewide rules. First Judicial District.',
        'E-Filing', NOW()::date, NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Anoka County E-Filing Citation
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        mn_anoka_id, 'local_rule', 'Anoka County District Court Local Rules',
        'MN-ANOKA-EFILING',
        'https://mncourts.gov/Find-Courts/Anoka',
        'E-filing is mandatory for attorneys in Anoka County District Court per Minnesota statewide rules. Tenth Judicial District.',
        'E-Filing', NOW()::date, NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

    -- Washington County E-Filing Citation
    INSERT INTO leverage.rule_citations (
        legal_source_id, source_type, source_name, citation, source_url, excerpt,
        locator, effective_date, last_verified_at, verifier, confidence_level
    ) VALUES (
        mn_washington_id, 'local_rule', 'Washington County District Court Local Rules',
        'MN-WASHINGTON-EFILING',
        'https://mncourts.gov/Find-Courts/Washington',
        'E-filing is mandatory for attorneys in Washington County District Court per Minnesota statewide rules. Tenth Judicial District.',
        'E-Filing', NOW()::date, NOW(), 'web_verified', 'high'
    ) ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt;

END $$;

-- ============================================================================
-- PART 3: ADD MINNESOTA VALIDATION RULES
-- ============================================================================

DO $$
DECLARE
    mn_sol_id INTEGER;
    mn_rule14_id INTEGER;
    mn_statewide_efile_id INTEGER;
    mn_hennepin_efile_id INTEGER;
    mn_ramsey_efile_id INTEGER;
    mn_dakota_efile_id INTEGER;
    mn_anoka_efile_id INTEGER;
    mn_washington_efile_id INTEGER;
BEGIN
    -- Get citation IDs
    SELECT id INTO mn_sol_id FROM leverage.rule_citations 
    WHERE citation = 'Minn. Stat. § 541.05';
    
    SELECT id INTO mn_rule14_id FROM leverage.rule_citations 
    WHERE citation = 'Minn. Gen. R. Prac. 14';
    
    SELECT id INTO mn_statewide_efile_id FROM leverage.rule_citations 
    WHERE citation = 'MN-STATEWIDE-EFILING';
    
    SELECT id INTO mn_hennepin_efile_id FROM leverage.rule_citations 
    WHERE citation = 'MN-HENNEPIN-EFILING';
    
    SELECT id INTO mn_ramsey_efile_id FROM leverage.rule_citations 
    WHERE citation = 'MN-RAMSEY-EFILING';
    
    SELECT id INTO mn_dakota_efile_id FROM leverage.rule_citations 
    WHERE citation = 'MN-DAKOTA-EFILING';
    
    SELECT id INTO mn_anoka_efile_id FROM leverage.rule_citations 
    WHERE citation = 'MN-ANOKA-EFILING';
    
    SELECT id INTO mn_washington_efile_id FROM leverage.rule_citations 
    WHERE citation = 'MN-WASHINGTON-EFILING';

    -- MN Statewide PI SOL (6 years) - Minn. Stat. § 541.05
    -- IMPORTANT: Minnesota has 6-YEAR SOL - LONGEST among major states
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'MN-SOL-541-05-PI-6YEAR', 5, 'MN Personal Injury SOL (6 Years)', 'threshold_check',
        'personal_injury', 'complaint',
        'state', 'MN', NULL, NULL,
        '{"sol_years": 6, "sol_days": 2190, "statute": "Minn. Stat. § 541.05", "subdivision": "Subd. 1(5)", "applies_to": "injury_to_person_or_rights", "note": "Minnesota has 6-YEAR SOL for PI - LONGEST among major states. Action must be commenced within 6 years for any injury to the person or rights of another."}'::jsonb,
        'error', mn_sol_id, 'document_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id,
        review_status = EXCLUDED.review_status;

    -- MN Statewide E-Filing Rule (Rule 14 / eFS)
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'MN-EFILING-STATEWIDE', 2, 'MN Statewide E-Filing (All 87 Counties)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'MN', NULL, NULL,
        '{"requires_efiling": true, "system": "eFile and eServe (eFS)", "rule": "Minn. Gen. R. Prac. 14", "effective_date": "2015-07-01", "mandatory_for": ["attorneys", "government_agencies", "guardians_ad_litem"], "all_87_counties": true, "voluntary_for": "self_represented_litigants", "note": "DOCUMENT VERIFIED: E-filing mandatory for attorneys in all 87 Minnesota counties since July 1, 2015"}'::jsonb,
        'warning', mn_statewide_efile_id, 'document_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id,
        review_status = EXCLUDED.review_status;

    -- Hennepin County (Minneapolis) E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'MN-HENNEPIN-EFILING', 2, 'Hennepin County E-Filing (Minneapolis)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'MN', 'Hennepin', 'District Court',
        '{"requires_efiling": true, "system": "eFS", "city": "Minneapolis", "judicial_district": "Fourth", "effective_date": "2015-07-01", "court_url": "https://mncourts.gov/Find-Courts/Hennepin", "note": "Most populous county in Minnesota. E-filing mandatory for attorneys since July 1, 2015."}'::jsonb,
        'error', mn_hennepin_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Ramsey County (St. Paul) E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'MN-RAMSEY-EFILING', 2, 'Ramsey County E-Filing (St. Paul)', 'format_check',
        'personal_injury', 'complaint',
        'state', 'MN', 'Ramsey', 'District Court',
        '{"requires_efiling": true, "system": "eFS", "city": "St. Paul", "judicial_district": "Second", "court_url": "https://mncourts.gov/Find-Courts/Ramsey", "note": "State capital county. E-filing mandatory for attorneys."}'::jsonb,
        'error', mn_ramsey_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Dakota County E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'MN-DAKOTA-EFILING', 2, 'Dakota County E-Filing', 'format_check',
        'personal_injury', 'complaint',
        'state', 'MN', 'Dakota', 'District Court',
        '{"requires_efiling": true, "system": "eFS", "judicial_district": "First", "court_url": "https://mncourts.gov/Find-Courts/Dakota", "note": "E-filing mandatory for attorneys per statewide rules."}'::jsonb,
        'error', mn_dakota_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Anoka County E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'MN-ANOKA-EFILING', 2, 'Anoka County E-Filing', 'format_check',
        'personal_injury', 'complaint',
        'state', 'MN', 'Anoka', 'District Court',
        '{"requires_efiling": true, "system": "eFS", "judicial_district": "Tenth", "court_url": "https://mncourts.gov/Find-Courts/Anoka", "note": "E-filing mandatory for attorneys per statewide rules."}'::jsonb,
        'error', mn_anoka_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Washington County E-Filing Rule
    INSERT INTO leverage.validation_rules (
        rule_name, validator_level, validator_name, validator_type,
        practice_area, document_type,
        jurisdiction_scope, jurisdiction_state, jurisdiction_county, jurisdiction_court,
        validator_config, severity, citation_id, review_status,
        is_active, is_template, tenant_id, created_at, updated_at
    ) VALUES (
        'MN-WASHINGTON-EFILING', 2, 'Washington County E-Filing', 'format_check',
        'personal_injury', 'complaint',
        'state', 'MN', 'Washington', 'District Court',
        '{"requires_efiling": true, "system": "eFS", "judicial_district": "Tenth", "court_url": "https://mncourts.gov/Find-Courts/Washington", "note": "E-filing mandatory for attorneys per statewide rules."}'::jsonb,
        'error', mn_washington_efile_id, 'web_verified',
        true, true, NULL, NOW(), NOW()
    ) ON CONFLICT (rule_name) DO UPDATE SET
        validator_config = EXCLUDED.validator_config,
        citation_id = EXCLUDED.citation_id;

    -- Completion message
    RAISE NOTICE '========================================================================';
    RAISE NOTICE 'MINNESOTA (MN) PI COURT RULES SEEDED SUCCESSFULLY';
    RAISE NOTICE '========================================================================';
    RAISE NOTICE 'Legal Sources: 7 (2 state + 5 county courts)';
    RAISE NOTICE 'Citations: 8 (Minn. Stat. 541.05, Rule 14, statewide e-filing + 5 county)';
    RAISE NOTICE 'Validation Rules: 7 (1 SOL + 1 statewide e-filing + 5 county e-filing)';
    RAISE NOTICE '';
    RAISE NOTICE 'DOCUMENT VERIFIED:';
    RAISE NOTICE '  - Minn. Stat. § 541.05 (6-year SOL) from revisor.mn.gov';
    RAISE NOTICE '  - Statewide e-filing from mncourts.gov';
    RAISE NOTICE '';
    RAISE NOTICE 'IMPORTANT: Minnesota has 6-YEAR SOL for PI - LONGEST among major states!';
    RAISE NOTICE 'E-Filing mandatory for attorneys in all 87 counties since July 1, 2015';
    RAISE NOTICE '========================================================================';

END $$;

COMMIT;
