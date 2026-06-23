-- Remediate Citations v9 - Flag remaining citations for manual paralegal review
-- These URLs point to official court websites but document content could not be fetched
-- Status: url_verified_pending_manual_review
-- Verification date: January 30, 2026

BEGIN;

-- ============================================================
-- CALIFORNIA COUNTIES - URL VERIFIED, FETCH FAILED
-- ============================================================

-- Riverside County
UPDATE leverage.rule_citations 
SET 
    source_url = 'https://www.riverside.courts.ca.gov/FormsFiling/eFiling/efiling.php',
    verifier = 'url_verified_pending_manual_review',
    confidence_level = 'medium',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'CA' 
AND ls.jurisdiction_county = 'Riverside';

-- San Mateo County
UPDATE leverage.rule_citations 
SET 
    source_url = 'https://www.sanmateocourt.org/court_divisions/civil/',
    verifier = 'url_verified_pending_manual_review',
    confidence_level = 'medium',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'CA' 
AND ls.jurisdiction_county = 'San Mateo';

-- Santa Clara County
UPDATE leverage.rule_citations 
SET 
    source_url = 'https://www.scscourt.org/online_services/efiling.shtml',
    verifier = 'url_verified_pending_manual_review',
    confidence_level = 'medium',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'CA' 
AND ls.jurisdiction_county = 'Santa Clara';

-- Solano County
UPDATE leverage.rule_citations 
SET 
    source_url = 'https://www.solano.courts.ca.gov/divisions/civil',
    verifier = 'url_verified_pending_manual_review',
    confidence_level = 'medium',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'CA' 
AND ls.jurisdiction_county = 'Solano';

-- ============================================================
-- GEORGIA COUNTIES - URL VERIFIED, FETCH FAILED
-- ============================================================

-- Chatham County
UPDATE leverage.rule_citations 
SET 
    source_url = 'https://courts.chathamcountyga.gov/Superior',
    verifier = 'url_verified_pending_manual_review',
    confidence_level = 'medium',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'GA' 
AND ls.jurisdiction_county = 'Chatham';

-- Cobb County
UPDATE leverage.rule_citations 
SET 
    source_url = 'https://www.cobbsuperiorcourtclerk.com/courts/civil-e-filing/',
    verifier = 'url_verified_pending_manual_review',
    confidence_level = 'medium',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'GA' 
AND ls.jurisdiction_county = 'Cobb';

-- DeKalb County
UPDATE leverage.rule_citations 
SET 
    source_url = 'https://www.dekalbsuperiorcourtclerk.com/',
    verifier = 'url_verified_pending_manual_review',
    confidence_level = 'medium',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'GA' 
AND ls.jurisdiction_county = 'DeKalb';

-- ============================================================
-- ILLINOIS COUNTIES - URL VERIFIED, FETCH FAILED
-- ============================================================

-- Lake County
UPDATE leverage.rule_citations 
SET 
    source_url = 'https://www.19thcircuitcourt.state.il.us/1958/Part-200-Electronic-Filing-of-Court-Reco',
    verifier = 'url_verified_pending_manual_review',
    confidence_level = 'medium',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'IL' 
AND ls.jurisdiction_county = 'Lake';

-- McHenry County
UPDATE leverage.rule_citations 
SET 
    source_url = 'https://www.co.mchenry.il.us/county-government/departments-a-i/circuit-court-clerk',
    verifier = 'url_verified_pending_manual_review',
    confidence_level = 'medium',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'IL' 
AND ls.jurisdiction_county = 'McHenry';

-- Will County
UPDATE leverage.rule_citations 
SET 
    source_url = 'https://www.circuitclerkofwillcounty.com/public-access/e-file-court-documents',
    verifier = 'url_verified_pending_manual_review',
    confidence_level = 'medium',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'IL' 
AND ls.jurisdiction_county = 'Will';

-- ============================================================
-- NEW YORK COUNTIES - URL VERIFIED, FETCH FAILED
-- ============================================================

-- Nassau County
UPDATE leverage.rule_citations 
SET 
    source_url = 'https://iappscontent.courts.state.ny.us/NYSCEF/live/protocols/NassauProtocol.pdf',
    verifier = 'url_verified_pending_manual_review',
    confidence_level = 'medium',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'NY' 
AND ls.jurisdiction_county = 'Nassau';

-- Suffolk County
UPDATE leverage.rule_citations 
SET 
    source_url = 'https://ww2.nycourts.gov/courts/10jd/suffolk/EFiling/index.shtml',
    verifier = 'url_verified_pending_manual_review',
    confidence_level = 'medium',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'NY' 
AND ls.jurisdiction_county = 'Suffolk';

-- ============================================================
-- OHIO COUNTIES - URL VERIFIED, FETCH FAILED
-- ============================================================

-- Hamilton County
UPDATE leverage.rule_citations 
SET 
    source_url = 'https://hamiltoncountycourts.org/index.php/local-rules/',
    verifier = 'url_verified_pending_manual_review',
    confidence_level = 'medium',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'OH' 
AND ls.jurisdiction_county = 'Hamilton';

-- Summit County
UPDATE leverage.rule_citations 
SET 
    source_url = 'https://clerkweb.summitoh.net/CivilFilingReq.asp',
    verifier = 'url_verified_pending_manual_review',
    confidence_level = 'medium',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'OH' 
AND ls.jurisdiction_county = 'Summit';

-- ============================================================
-- PENNSYLVANIA COUNTY - URL VERIFIED, FETCH FAILED
-- ============================================================

-- Montgomery County
UPDATE leverage.rule_citations 
SET 
    source_url = 'https://www.montgomerycountypa.gov/261/Electronic-Filing',
    verifier = 'url_verified_pending_manual_review',
    confidence_level = 'medium',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'PA' 
AND ls.jurisdiction_county = 'Montgomery';

COMMIT;

-- Final verification summary
SELECT verifier, confidence_level, COUNT(*) as count 
FROM leverage.rule_citations 
GROUP BY verifier, confidence_level 
ORDER BY verifier;
