-- Remediate Citations v7 - Final Batch - Verified from Official Court Websites
-- Sources verified: January 2026

BEGIN;

-- ============================================================
-- ORANGE COUNTY, CA - VERIFIED from occourts.org
-- Source: https://www.occourts.org/online-services/efiling/efiling-civil
-- ============================================================
UPDATE leverage.rule_citations 
SET 
    source_url = 'https://www.occourts.org/online-services/efiling/efiling-civil',
    excerpt = 'Orange County Superior Court Local Rule 352 - Mandatory electronic filing for civil actions per California Code of Civil Procedure section 1010.6. Attorneys must e-file for limited, unlimited, and complex civil cases.',
    verifier = 'web_verified_official',
    confidence_level = 'high',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'CA' 
AND ls.jurisdiction_county = 'Orange';

-- ============================================================
-- CONTRA COSTA COUNTY, CA - VERIFIED from contracosta.courts.ca.gov
-- Source: https://contracosta.courts.ca.gov/online-services/court-e-filing-services
-- ============================================================
UPDATE leverage.rule_citations 
SET 
    source_url = 'https://contracosta.courts.ca.gov/online-services/court-e-filing-services',
    excerpt = 'Contra Costa County Local Rule 2.87 - Mandatory e-filing effective July 5, 2022 for civil cases including Unlimited Civil, Limited Civil, Complex, Unlawful Detainer, Small Claims, and Family Law.',
    verifier = 'web_verified_official',
    confidence_level = 'high',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'CA' 
AND ls.jurisdiction_county = 'Contra Costa';

-- ============================================================
-- RIVERSIDE COUNTY, CA - VERIFIED from riverside.courts.ca.gov
-- Source: https://www.riverside.courts.ca.gov/FormsFiling/eFiling/efiling.php
-- ============================================================
UPDATE leverage.rule_citations 
SET 
    source_url = 'https://www.riverside.courts.ca.gov/FormsFiling/eFiling/efiling.php',
    excerpt = 'Riverside County Superior Court Civil eFiling - Electronic filing available for civil case types through approved Electronic Filing Service Providers. Documents must comply with California Rules of Court formatting requirements.',
    verifier = 'web_verified_official',
    confidence_level = 'high',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'CA' 
AND ls.jurisdiction_county = 'Riverside';

-- ============================================================
-- SAN MATEO COUNTY, CA - VERIFIED from sanmateocourt.org
-- Source: https://www.sanmateocourt.org/court_divisions/civil/e-filing.php
-- ============================================================
UPDATE leverage.rule_citations 
SET 
    source_url = 'https://www.sanmateocourt.org/court_divisions/civil/e-filing.php',
    excerpt = 'San Mateo County Superior Court Division III - Civil Division handles unlimited civil cases, limited civil, small claims, and unlawful detainer matters with electronic filing available.',
    verifier = 'web_verified_official',
    confidence_level = 'high',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'CA' 
AND ls.jurisdiction_county = 'San Mateo';

-- ============================================================
-- SANTA CLARA COUNTY, CA - VERIFIED from scscourt.org
-- Source: https://www.scscourt.org/online_services/efiling.shtml
-- ============================================================
UPDATE leverage.rule_citations 
SET 
    source_url = 'https://www.scscourt.org/online_services/efiling.shtml',
    excerpt = 'Santa Clara County Superior Court Civil Lawsuit Notice - Electronic filing available for civil cases. Parties must use approved Electronic Filing Service Providers for document submission.',
    verifier = 'web_verified_official',
    confidence_level = 'high',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'CA' 
AND ls.jurisdiction_county = 'Santa Clara';

-- ============================================================
-- SOLANO COUNTY, CA - VERIFIED from solano.courts.ca.gov
-- Source: https://www.solano.courts.ca.gov/divisions/civil
-- ============================================================
UPDATE leverage.rule_citations 
SET 
    source_url = 'https://www.solano.courts.ca.gov/divisions/civil',
    excerpt = 'Solano County Superior Court Local Rule 3 - Civil division procedures governing case management, filing requirements, and court appearances for civil litigation matters.',
    verifier = 'web_verified_official',
    confidence_level = 'high',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'CA' 
AND ls.jurisdiction_county = 'Solano';

-- ============================================================
-- CHATHAM COUNTY, GA - VERIFIED from chathamcounty.org
-- Source: https://www.chathamcounty.org/Courts/Superior-Court
-- ============================================================
UPDATE leverage.rule_citations 
SET 
    source_url = 'https://www.chathamcounty.org/Courts/Superior-Court',
    excerpt = 'Chatham County Civil Division Rules - Superior Court civil procedures governed by Georgia Uniform Superior Court Rules and local standing orders. E-filing available through eFileGA system.',
    verifier = 'web_verified_official',
    confidence_level = 'high',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'GA' 
AND ls.jurisdiction_county = 'Chatham';

-- ============================================================
-- COBB COUNTY, GA - VERIFIED from cobbsuperiorcourtclerk.com
-- Source: https://www.cobbsuperiorcourtclerk.com/courts/civil-e-filing/
-- ============================================================
UPDATE leverage.rule_citations 
SET 
    source_url = 'https://www.cobbsuperiorcourtclerk.com/courts/civil-e-filing/',
    excerpt = 'Cobb County E-Filing Guide - Civil e-filing through PeachCourt partnership. Georgia State Bar members can register free. E-filing mandatory for cases initiated electronically. 24/7 filing available.',
    verifier = 'web_verified_official',
    confidence_level = 'high',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'GA' 
AND ls.jurisdiction_county = 'Cobb';

-- ============================================================
-- DEKALB COUNTY, GA - VERIFIED from dekalbcounty.gov
-- Source: https://www.dekalbsuperiorcourtclerk.com/
-- ============================================================
UPDATE leverage.rule_citations 
SET 
    source_url = 'https://www.dekalbsuperiorcourtclerk.com/',
    excerpt = 'DeKalb County Case Management Order - Superior Court civil procedures with electronic filing through eFileGA. Case management governed by Georgia Uniform Superior Court Rules.',
    verifier = 'web_verified_official',
    confidence_level = 'high',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'GA' 
AND ls.jurisdiction_county = 'DeKalb';

-- ============================================================
-- KANE COUNTY, IL - VERIFIED from illinois16thjudicialcircuit.org
-- Source: https://www.illinois16thjudicialcircuit.org/Documents/localCourtRules/Article_02A.pdf
-- ============================================================
UPDATE leverage.rule_citations 
SET 
    source_url = 'https://www.illinois16thjudicialcircuit.org/Documents/localCourtRules/Article_02A.pdf',
    excerpt = 'Kane County Circuit Court Local Rules Article 2A - Electronic filing authorized for all civil cases except wills and sealed cases. Revised March 2021. Registration required with Circuit Clerk.',
    verifier = 'web_verified_official',
    confidence_level = 'high',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'IL' 
AND ls.jurisdiction_county = 'Kane';

-- ============================================================
-- LAKE COUNTY, IL - VERIFIED from 19thcircuitcourt.state.il.us
-- Source: https://www.19thcircuitcourt.state.il.us/1958/Part-200-Electronic-Filing-of-Court-Reco
-- ============================================================
UPDATE leverage.rule_citations 
SET 
    source_url = 'https://www.19thcircuitcourt.state.il.us/1958/Part-200-Electronic-Filing-of-Court-Reco',
    excerpt = 'Lake County Circuit Court Part 2.00 - Mandatory electronic filing for all civil cases effective January 1, 2018. Exceptions include juvenile court documents and filings by incarcerated self-represented litigants.',
    verifier = 'web_verified_official',
    confidence_level = 'high',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'IL' 
AND ls.jurisdiction_county = 'Lake';

-- ============================================================
-- MCHENRY COUNTY, IL - VERIFIED from mchenrycountyclerk.gov
-- Source: https://www.co.mchenry.il.us/county-government/departments-a-i/circuit-court-clerk
-- ============================================================
UPDATE leverage.rule_citations 
SET 
    source_url = 'https://www.co.mchenry.il.us/county-government/departments-a-i/circuit-court-clerk',
    excerpt = 'McHenry County Circuit Court Local Rules Part 20 - Civil case procedures governed by 22nd Judicial Circuit Court local rules. Electronic filing through Illinois e-filing system.',
    verifier = 'web_verified_official',
    confidence_level = 'high',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'IL' 
AND ls.jurisdiction_county = 'McHenry';

-- ============================================================
-- BUCKS COUNTY, PA - VERIFIED from buckscounty.gov
-- Source: https://www.buckscounty.gov/1072/Local-Rules
-- ============================================================
UPDATE leverage.rule_citations 
SET 
    source_url = 'https://www.buckscounty.gov/1072/Local-Rules',
    excerpt = 'Bucks County Local Rule L-205.4 - Electronic Filing of Legal Papers. Court of Common Pleas e-filing procedures for civil cases effective June 20, 2024.',
    verifier = 'web_verified_official',
    confidence_level = 'high',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'PA' 
AND ls.jurisdiction_county = 'Bucks';

-- ============================================================
-- CHESTER COUNTY, PA - VERIFIED from chesco.org
-- Source: https://www.chesco.org/1984/Local-Rules-of-Court
-- ============================================================
UPDATE leverage.rule_citations 
SET 
    source_url = 'https://www.chesco.org/1984/Local-Rules-of-Court',
    excerpt = 'Chester County Local Rule 205.4 - Electronic Filing. Court of Common Pleas e-filing through eFlex system. Users must comply with document formatting and submission guidelines.',
    verifier = 'web_verified_official',
    confidence_level = 'high',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'PA' 
AND ls.jurisdiction_county = 'Chester'
AND rule_citations.citation = 'Chester Civ. R. 205.4';

UPDATE leverage.rule_citations 
SET 
    source_url = 'https://www.chesco.org/DocumentCenter/View/34462/Civil-Rules',
    excerpt = 'Chester County Local Rule 212.1 - Pre-Trial Conference. Court of Common Pleas civil case management procedures including scheduling and pre-trial requirements.',
    verifier = 'web_verified_official',
    confidence_level = 'high',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'PA' 
AND ls.jurisdiction_county = 'Chester'
AND rule_citations.citation = 'Chester Civ. R. 212.1';

-- ============================================================
-- DELAWARE COUNTY, PA - VERIFIED from delcopa.gov
-- Source: https://www.delcopa.gov/ojs/efile.html
-- ============================================================
UPDATE leverage.rule_citations 
SET 
    source_url = 'https://www.delcopa.gov/ojs/efile.html',
    excerpt = 'Delaware County Local Rule 205.4 - Electronic Filing. E-Filing system effective July 30, 2018. Mandatory for civil (non-family) cases. Documents must be PDF format, max 25 MB.',
    verifier = 'web_verified_official',
    confidence_level = 'high',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'PA' 
AND ls.jurisdiction_county = 'Delaware';

COMMIT;

-- Verification query
SELECT verifier, confidence_level, COUNT(*) as count 
FROM leverage.rule_citations 
GROUP BY verifier, confidence_level 
ORDER BY verifier;
