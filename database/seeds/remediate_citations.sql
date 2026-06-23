-- ============================================================================
-- CITATION VERIFICATION REMEDIATION SCRIPT
-- ============================================================================
-- Purpose: Update county-level citations with VERIFIED data from official sources
-- All updates are based on web searches of official court websites
-- Date: January 30, 2026
-- ============================================================================

BEGIN;

-- ============================================================================
-- CALIFORNIA COUNTY CORRECTIONS
-- ============================================================================

-- Alameda County - VERIFIED from alameda.courts.ca.gov
UPDATE leverage.rule_citations 
SET 
    citation = 'ALMSCR 3.27',
    source_url = 'https://www.alameda.courts.ca.gov/system/files/local-rules/03-title-3-20250701.pdf',
    excerpt = 'Rule 3.27 governs electronic filing and service in all civil proceedings. E-filing is permitted in all civil cases through court-approved Electronic Filing Service Providers (EFSPs). Effective October 12, 2021.',
    verifier = 'web_verified_official',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'CA' 
AND ls.jurisdiction_county = 'Alameda';

-- Kings County - VERIFIED from kings.courts.ca.gov
UPDATE leverage.rule_citations 
SET 
    citation = 'KNGSCR 125',
    source_url = 'https://www.kings.courts.ca.gov/system/files/local-rules/current-local-rules_0.pdf',
    excerpt = 'Rule 125 - Electronic Filing (E-Filing) Rules. Electronic filing is mandatory for all civil case types including Unlimited, Limited, Small Claims, Probate, Family Law, and Guardianships, with exceptions for self-represented parties. Effective July 1, 2021.',
    verifier = 'web_verified_official',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'CA' 
AND ls.jurisdiction_county = 'Kings';

-- Los Angeles County - VERIFIED from lacourt.org
UPDATE leverage.rule_citations 
SET 
    citation = 'LASCR 3.30',
    source_url = 'https://www.lacourt.org/courtrules/currentcourtrulespdf/chap3.pdf',
    excerpt = 'Rule 3.30 mandates electronic filing (e-filing) for civil cases. E-filing is required for most civil documents, with specific exemptions outlined. The rule details timing for electronic submissions, including deadlines for ex parte applications.',
    verifier = 'web_verified_official',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'CA' 
AND ls.jurisdiction_county = 'Los Angeles'
AND rule_citations.citation LIKE '%3.30%';

-- Orange County - VERIFIED from occourts.org
UPDATE leverage.rule_citations 
SET 
    citation = 'OCSCR 301',
    source_url = 'https://www.occourts.org/system/files/local-rules/index.pdf',
    excerpt = 'Rule 301 governs civil case assignment and management. Division 3 covers civil rules including cases over and under $35,000, small claims, and general civil procedures. Effective July 1, 2025.',
    verifier = 'web_verified_official',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'CA' 
AND ls.jurisdiction_county = 'Orange'
AND rule_citations.citation LIKE '%301%';

-- San Diego County - VERIFIED from sdcourt.ca.gov
UPDATE leverage.rule_citations 
SET 
    citation = 'SDSC CIV-409',
    source_url = 'https://sdcourt.ca.gov/sites/default/files/SDCOURT/GENERALINFORMATION/FORMS/CIVILFORMS/CIV409.PDF',
    excerpt = 'CIV-409 Electronic Filing Requirements (Civil). Effective April 15, 2021, attorneys representing parties in civil actions must file documents electronically through approved EFSPs. Self-represented litigants are encouraged to e-file but not mandated unless ordered by court.',
    verifier = 'web_verified_official',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'CA' 
AND ls.jurisdiction_county = 'San Diego';

-- Sacramento County - VERIFIED from saccourt.ca.gov
UPDATE leverage.rule_citations 
SET 
    citation = 'SACSCR Chapter 2',
    source_url = 'https://saccourt.ca.gov/local-rules/docs/chapter-02.pdf',
    excerpt = 'Chapter 2 - Civil Local Rules. The court may strike pleadings, dismiss actions, or impose penalties for non-compliance. Mandatory civil local forms must be used. Orders after hearing must be prepared according to California Rules of Court and served within five days. Effective July 1, 2025.',
    verifier = 'web_verified_official',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'CA' 
AND ls.jurisdiction_county = 'Sacramento';

-- ============================================================================
-- FLORIDA COUNTY CORRECTIONS
-- ============================================================================

-- Broward County - VERIFIED from 17th.flcourts.org
UPDATE leverage.rule_citations 
SET 
    citation = '17th JC Admin. Order 2024-26-Civ',
    source_url = 'https://www.17th.flcourts.org/wp-content/uploads/2025/01/2024-26-Civ-2.pdf',
    excerpt = 'Administrative Order 2024-26-Civ establishes Civil Case Management Plan. Judges must actively manage cases, adhere to specific deadlines based on case complexity (complex, streamlined, or general). Effective January 1, 2025. Continuances only for good cause.',
    verifier = 'web_verified_official',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'FL' 
AND ls.jurisdiction_county = 'Broward';

-- ============================================================================
-- TEXAS COUNTY CORRECTIONS
-- ============================================================================

-- Harris County - VERIFIED from hcdistrictclerk.com
UPDATE leverage.rule_citations 
SET 
    citation = 'HCDCLR E-Filing Rules',
    source_url = 'https://www.hcdistrictclerk.com/common/civil/EFiling.aspx',
    excerpt = 'Mandatory e-filing for all civil cases effective January 1, 2014, with exceptions for Pro Se filers. All filings must be submitted through EFileTexas.gov. New technology standards approved by Texas Supreme Court effective January 31, 2025.',
    verifier = 'web_verified_official',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'TX' 
AND ls.jurisdiction_county = 'Harris';

-- Dallas County - VERIFIED from dallascounty.org
UPDATE leverage.rule_citations 
SET 
    citation = 'DCCLR Rule 2.02',
    source_url = 'https://www.dallascounty.org/Assets/uploads/docs/district-clerk/Local-Rules-for-Civil-District-Courts-With-Appendixes-Included.pdf',
    excerpt = 'Rule 2.02 - Application for TRO and Other Ex Parte Orders. Details process for applying for TRO, emphasizing need for immediate relief without notifying other party in certain circumstances. Rule 2.11 mandates providing notice for hearings.',
    verifier = 'web_verified_official',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'TX' 
AND ls.jurisdiction_county = 'Dallas';

-- Bexar County - VERIFIED from bexar.org
UPDATE leverage.rule_citations 
SET 
    citation = 'BCCLR 2024',
    source_url = 'https://www.bexar.org/DocumentCenter/View/40208/Bexar-County-Civil-District-Court-Local-Rules-2024',
    excerpt = 'Bexar County Civil District Court Local Rules effective January 9, 2024. Docket structure: 8:30 Docket (non-witness matters), 9:00 Docket (significant matters), 1:30 Docket (uncontested matters), 2:00 Docket (specialty dockets). All filings must be submitted electronically.',
    verifier = 'web_verified_official',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'TX' 
AND ls.jurisdiction_county = 'Bexar';

-- ============================================================================
-- NEW YORK COUNTY CORRECTIONS
-- ============================================================================

-- New York County (Manhattan) - VERIFIED from nycourts.gov
UPDATE leverage.rule_citations 
SET 
    citation = '22 NYCRR 202.5-bb',
    source_url = 'https://ww2.nycourts.gov/rules/trialcourts/202.shtml',
    excerpt = '22 NYCRR 202.5-bb - Mandatory electronic filing program in the Supreme Court. E-filing is mandatory for most civil case types. Attorneys must file documents electronically through NYSCEF system. Self-represented litigants may be exempt.',
    verifier = 'web_verified_official',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'NY' 
AND ls.jurisdiction_county = 'New York';

-- Kings County (Brooklyn) - VERIFIED from nycourts.gov
UPDATE leverage.rule_citations 
SET 
    citation = 'Kings Sup. Ct. Rule 3',
    source_url = 'https://ww2.nycourts.gov/courts/2jd/kings/civil/KingsCivilSupremeRules.shtml',
    excerpt = 'Rule 3 - Motion papers must be filed at least five business days before motion return date. Cross-motions must be filed at least two days prior. All filed papers must have protruding exhibit tabs, except matrimonial cases and pro se filings.',
    verifier = 'web_verified_official',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'NY' 
AND ls.jurisdiction_county = 'Kings';

-- Queens County - VERIFIED from nycourts.gov
UPDATE leverage.rule_citations 
SET 
    citation = 'Queens Sup. Ct. E-Filing Protocol',
    source_url = 'https://ww2.nycourts.gov/courts/11jd/supreme/civilterm/efile.shtml',
    excerpt = 'Mandatory e-filing for medical malpractice cases commenced on or after March 31, 2014, and foreclosure proceedings commenced on or after March 23, 2015. Attorneys must use NYSCEF system.',
    verifier = 'web_verified_official',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'NY' 
AND ls.jurisdiction_county = 'Queens';

-- ============================================================================
-- PENNSYLVANIA COUNTY CORRECTIONS
-- ============================================================================

-- Philadelphia - VERIFIED from courts.phila.gov
UPDATE leverage.rule_citations 
SET 
    citation = 'Phila. Civ. R. *205.4',
    source_url = 'https://www.courts.phila.gov/pdf/rules/CP-Trial-Civil-Compiled%20Rules.pdf',
    excerpt = 'Rule *205.4 - Electronic Filing. Mandatory electronic filing for all civil matters effective January 5, 2009. All civil documents must be filed electronically through the Philadelphia Court e-filing system. No additional cost for e-filing service.',
    verifier = 'web_verified_official',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'PA' 
AND ls.jurisdiction_county = 'Philadelphia';

-- ============================================================================
-- ILLINOIS COUNTY CORRECTIONS
-- ============================================================================

-- Cook County - VERIFIED from cookcountycourt.org
UPDATE leverage.rule_citations 
SET 
    citation = 'Cook Co. Gen. Admin. Order 2013-08',
    source_url = 'https://www.cookcountycourt.org/order/general-administrative-order-no-2013-08-electronic-filing-efiling-court-documents',
    excerpt = 'General Administrative Order 2013-08 - Electronic Filing. E-filing implemented for civil cases in Chancery, Law, Municipal, and Domestic Relations/Child Support Divisions effective July 15, 2013. Electronic filing encouraged but traditional filing remains available.',
    verifier = 'web_verified_official',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'IL' 
AND ls.jurisdiction_county = 'Cook';

-- ============================================================================
-- GEORGIA COUNTY CORRECTIONS
-- ============================================================================

-- Fulton County - VERIFIED from fultonsuperiorcourtga.gov
UPDATE leverage.rule_citations 
SET 
    citation = 'Fulton Standing Order - E-Filing',
    source_url = 'https://www.fultonsuperiorcourtga.gov/sites/default/files/judges/25EX001498%20-%20Standing%20Order%20Regarding%20Electronic%20Filing%20For%20Civil%20Cases.pdf',
    excerpt = 'Standing Order on Electronic Filing for Civil Cases. E-filing mandatory for all civil matters, with exceptions for ex parte motions and family violence protective orders. Paper filings generally not permitted. Uses eFileGA system. Effective September 2025 revision.',
    verifier = 'web_verified_official',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'GA' 
AND ls.jurisdiction_county = 'Fulton';

-- ============================================================================
-- OHIO COUNTY CORRECTIONS
-- ============================================================================

-- Franklin County - VERIFIED from franklincountyohio.gov
UPDATE leverage.rule_citations 
SET 
    citation = 'Franklin Co. Civ. E-Filing Guidelines',
    source_url = 'https://clerk.franklincountyohio.gov/efiling/efilingresources',
    excerpt = 'Civil e-Filing Guidelines. E-filing required for Court of Common Pleas civil cases. Filers receive automatic notice confirming submission. Filing not officially recognized until court updates status to "Filed." Clerk reviews and indexes filings. Updated July 29, 2022.',
    verifier = 'web_verified_official',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'OH' 
AND ls.jurisdiction_county = 'Franklin';

-- ============================================================================
-- MARK UNVERIFIED CITATIONS WITH LOWER CONFIDENCE
-- ============================================================================

-- Update any remaining citations that were not specifically verified
-- with a note that they require legal professional verification
UPDATE leverage.rule_citations 
SET 
    confidence_level = 'medium',
    verifier = 'ai_approximated_needs_review',
    notes = 'Citation requires verification by legal professional. Rule number is approximation based on court website patterns.'
WHERE verifier = 'web_verified'
AND legal_source_id IN (
    SELECT id FROM leverage.legal_sources WHERE jurisdiction_county IS NOT NULL
)
AND citation NOT IN (
    'ALMSCR 3.27',
    'KNGSCR 125',
    'LASCR 3.30',
    'OCSCR 301',
    'SDSC CIV-409',
    'SACSCR Chapter 2',
    '17th JC Admin. Order 2024-26-Civ',
    'HCDCLR E-Filing Rules',
    'DCCLR Rule 2.02',
    'BCCLR 2024',
    '22 NYCRR 202.5-bb',
    'Kings Sup. Ct. Rule 3',
    'Queens Sup. Ct. E-Filing Protocol',
    'Phila. Civ. R. *205.4',
    'Cook Co. Gen. Admin. Order 2013-08',
    'Fulton Standing Order - E-Filing',
    'Franklin Co. Civ. E-Filing Guidelines'
);

COMMIT;

-- ============================================================================
-- VERIFICATION QUERY
-- ============================================================================

SELECT 
    ls.jurisdiction_state,
    ls.jurisdiction_county,
    rc.citation,
    rc.verifier,
    rc.confidence_level,
    CASE 
        WHEN rc.verifier = 'web_verified_official' THEN 'VERIFIED'
        WHEN rc.verifier = 'ai_approximated_needs_review' THEN 'NEEDS REVIEW'
        ELSE 'UNKNOWN'
    END as verification_status
FROM leverage.rule_citations rc
JOIN leverage.legal_sources ls ON rc.legal_source_id = ls.id
WHERE ls.jurisdiction_county IS NOT NULL
ORDER BY ls.jurisdiction_state, ls.jurisdiction_county, rc.citation;
