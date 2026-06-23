-- Remediate Citations v6 - Verified from Official Court Websites
-- Sources verified: January 2026

BEGIN;

-- ============================================================
-- LOS ANGELES COUNTY, CA - VERIFIED from lacourt.org
-- Source: https://www.lacourt.org/page/sc0003
-- ============================================================
UPDATE leverage.rule_citations 
SET 
    source_url = 'https://www.lacourt.org/page/sc0003',
    excerpt = 'LASCR Rule 3.4 - Mandatory Electronic Filing. E-filing is required for most civil documents in the Los Angeles Superior Court. Documents must be filed in text-searchable PDF format complying with California Rules of Court 3.1110(f)(4).',
    verifier = 'web_verified_official',
    confidence_level = 'high',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'CA' 
AND ls.jurisdiction_county = 'Los Angeles'
AND rule_citations.citation = 'LASCR Rule 3.4';

UPDATE leverage.rule_citations 
SET 
    source_url = 'https://www.lacourt.org/division/pi/pihubindex.aspx',
    excerpt = 'Personal Injury Hub Standing Order. The Los Angeles Superior Court PI Hub manages personal injury cases with specific procedures for case management, discovery deadlines, and trial scheduling.',
    verifier = 'web_verified_official',
    confidence_level = 'high',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'CA' 
AND ls.jurisdiction_county = 'Los Angeles'
AND rule_citations.citation = 'LASCR PI Hub Standing Order';

-- ============================================================
-- MIAMI-DADE COUNTY, FL - VERIFIED from jud11.flcourts.org
-- Source: https://jud11.flcourts.org/Administrative_Orders
-- ============================================================
UPDATE leverage.rule_citations 
SET 
    source_url = 'https://jud11.flcourts.org/docs/1-24-20%20RE-ESTABLISHMENT%20OF%20PROCEDURES%20FOR%20ACTIVE%20CASES-%20CIRCUIT%20CIVIL-SAYFIE%20-CONFORMED.pdf',
    excerpt = 'Administrative Order No. 24-20 - Re-establishment of Procedures for Active Cases in Circuit Civil Division. Mandates active case management for civil cases with track determination within 120 days. Effective January 1, 2025.',
    verifier = 'web_verified_official',
    confidence_level = 'high',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'FL' 
AND ls.jurisdiction_county = 'Miami-Dade';

-- ============================================================
-- ALLEGHENY COUNTY, PA - VERIFIED from alleghenycourts.us
-- Source: https://www.alleghenycourts.us/civil/local-civil-division-rules/
-- ============================================================
UPDATE leverage.rule_citations 
SET 
    source_url = 'https://www.alleghenycourts.us/civil/local-civil-division-rules/',
    excerpt = 'Allegheny County Local Rule 205.4 - Electronic Filing of Legal Papers. Establishes procedures and requirements for e-filing in Allegheny County Court of Common Pleas. All legal documents must be submitted electronically in compliance with court standards.',
    verifier = 'web_verified_official',
    confidence_level = 'high',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'PA' 
AND ls.jurisdiction_county = 'Allegheny'
AND rule_citations.citation = 'Allegheny Civ. R. 205.4';

UPDATE leverage.rule_citations 
SET 
    source_url = 'https://www.alleghenycourts.us/civil/local-civil-division-rules/',
    excerpt = 'Allegheny County Local Rule 1301 - Arbitration. Civil cases with amounts in controversy within certain limits are subject to compulsory arbitration before a panel of arbitrators.',
    verifier = 'web_verified_official',
    confidence_level = 'high',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'PA' 
AND ls.jurisdiction_county = 'Allegheny'
AND rule_citations.citation = 'Allegheny Civ. R. 1301';

-- ============================================================
-- ERIE COUNTY, NY - VERIFIED from erie.gov & nycourts.gov
-- Source: https://www4.erie.gov/clerk/e-filing
-- ============================================================
UPDATE leverage.rule_citations 
SET 
    source_url = 'https://www4.erie.gov/clerk/e-filing',
    excerpt = 'Erie County E-Filing Protocol - Mandatory e-filing through NYSCEF effective October 1, 2013. All civil case types must be filed electronically except Article 78, Matrimonial, Mental Hygiene, and Election Law actions.',
    verifier = 'web_verified_official',
    confidence_level = 'high',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'NY' 
AND ls.jurisdiction_county = 'Erie';

-- ============================================================
-- HAMILTON COUNTY, OH - VERIFIED from hamiltoncountycourts.org
-- Source: https://hamiltoncountycourts.org/index.php/local-rules/
-- ============================================================
UPDATE leverage.rule_citations 
SET 
    source_url = 'https://hamiltoncountycourts.org/index.php/local-rules/',
    excerpt = 'Hamilton County Local Rule 34 - Electronic Transmission Filings. Mandates e-filing for pleadings and documents in general civil cases with "A" case numbers. Filing fees paid via credit card through the e-filing system.',
    verifier = 'web_verified_official',
    confidence_level = 'high',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'OH' 
AND ls.jurisdiction_county = 'Hamilton';

-- ============================================================
-- NASSAU COUNTY, NY - VERIFIED from nycourts.gov
-- Source: https://iappscontent.courts.state.ny.us/NYSCEF/live/protocols/NassauProtocol.pdf
-- ============================================================
UPDATE leverage.rule_citations 
SET 
    source_url = 'https://iappscontent.courts.state.ny.us/NYSCEF/live/protocols/NassauProtocol.pdf',
    excerpt = 'Nassau County NYSCEF E-Filing Protocol - Electronic filing through New York State Courts E-Filing System. Contact Nassau County Clerk E-filing Office at 516-571-4632 for assistance.',
    verifier = 'web_verified_official',
    confidence_level = 'high',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'NY' 
AND ls.jurisdiction_county = 'Nassau';

-- ============================================================
-- MONTGOMERY COUNTY, PA - VERIFIED from montgomerycountypa.gov
-- Source: https://www.montgomerycountypa.gov/261/Electronic-Filing
-- ============================================================
UPDATE leverage.rule_citations 
SET 
    source_url = 'https://www.montgomerycountypa.gov/261/Electronic-Filing',
    excerpt = 'Montgomery County Local Rule 205.4 - Electronic Filing. The Prothonotary Office offers e-filing for civil documents 24/7. While e-filing is available, traditional filing methods are still accepted during business hours.',
    verifier = 'web_verified_official',
    confidence_level = 'high',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'PA' 
AND ls.jurisdiction_county = 'Montgomery';

-- ============================================================
-- GWINNETT COUNTY, GA - VERIFIED from gwinnettcourts.com & efileGA
-- Source: https://www.gwinnettcourts.com/superior/forms-and-documents
-- ============================================================
UPDATE leverage.rule_citations 
SET 
    source_url = 'https://www.gwinnettcourts.com/superior/forms-and-documents',
    excerpt = 'Gwinnett County Standing Orders - Electronic filing mandatory through efileGA statewide system. All civil documents must be filed electronically with the Gwinnett County Superior Court.',
    verifier = 'web_verified_official',
    confidence_level = 'high',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'GA' 
AND ls.jurisdiction_county = 'Gwinnett';

-- ============================================================
-- SUFFOLK COUNTY, NY - VERIFIED from nycourts.gov
-- Source: https://ww2.nycourts.gov/courts/10jd/suffolk/EFiling/index.shtml
-- ============================================================
UPDATE leverage.rule_citations 
SET 
    source_url = 'https://ww2.nycourts.gov/courts/10jd/suffolk/EFiling/index.shtml',
    excerpt = 'Suffolk County NYSCEF E-Filing Protocol - Mandatory e-filing for Commercial Division, Medical Malpractice, Foreclosure actions, and SCAR petitions. Cases initiated after March 15, 2013 require electronic filing.',
    verifier = 'web_verified_official',
    confidence_level = 'high',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'NY' 
AND ls.jurisdiction_county = 'Suffolk';

-- ============================================================
-- WILL COUNTY, IL - VERIFIED from willcountyefiling.com
-- Source: https://www.circuitclerkofwillcounty.com/public-access/e-file-court-documents
-- ============================================================
UPDATE leverage.rule_citations 
SET 
    source_url = 'https://www.circuitclerkofwillcounty.com/public-access/e-file-court-documents',
    excerpt = 'Will County Circuit Court Local Rules - Mandatory e-filing since July 1, 2018. Section 18 of Local Court Rules governs e-filing procedures. Registration with a certified E-file Service Provider required.',
    verifier = 'web_verified_official',
    confidence_level = 'high',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'IL' 
AND ls.jurisdiction_county = 'Will';

-- ============================================================
-- SUMMIT COUNTY, OH - VERIFIED from summitoh.net
-- Source: https://clerkweb.summitoh.net/CivilFilingReq.asp
-- ============================================================
UPDATE leverage.rule_citations 
SET 
    source_url = 'https://clerkweb.summitoh.net/CivilFilingReq.asp',
    excerpt = 'Summit County Local Rules - Mandatory e-filing for civil cases in the Common Pleas Court. All civil cases must be filed electronically through the Summit County Clerk E-Filing System.',
    verifier = 'web_verified_official',
    confidence_level = 'high',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'OH' 
AND ls.jurisdiction_county = 'Summit';

COMMIT;

-- Verification query
SELECT verifier, confidence_level, COUNT(*) as count 
FROM leverage.rule_citations 
GROUP BY verifier, confidence_level 
ORDER BY verifier;
