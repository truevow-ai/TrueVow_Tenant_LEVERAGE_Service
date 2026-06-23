-- ============================================================================
-- CITATION VERIFICATION REMEDIATION SCRIPT v5
-- ============================================================================
-- Purpose: Final batch of verified county citations
-- Date: January 30, 2026
-- ============================================================================

BEGIN;

-- ============================================================================
-- NEW YORK COUNTY CORRECTIONS
-- ============================================================================

-- Bronx County - VERIFIED from nycourts.gov
UPDATE leverage.rule_citations 
SET 
    source_url = 'https://ww2.nycourts.gov/courts/12jd/BRONX/civil/filingrules-efile.shtml',
    excerpt = 'E-filing via NYSCEF is mandatory for civil motions. Motions on Notice returnable in Room 217. Motion Support Office automatically calendars motions. Working copies not accepted except for orders to show cause. Fee paid through NYSCEF.',
    verifier = 'web_verified_official',
    confidence_level = 'high',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'NY' 
AND ls.jurisdiction_county = 'Bronx';

-- ============================================================================
-- ILLINOIS COUNTY CORRECTIONS
-- ============================================================================

-- DuPage County - VERIFIED from dupageco.org
UPDATE leverage.rule_citations 
SET 
    source_url = 'https://dupageco.org/18th_judicial_circuit_court/legal_resources/court_rules/index.php',
    excerpt = 'DuPage County 18th Judicial Circuit Court local court rules. Rules organized into sections covering administration, civil proceedings, pleadings, motions, and discovery. E-filing available through Circuit Clerk portal.',
    verifier = 'web_verified_official',
    confidence_level = 'high',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'IL' 
AND ls.jurisdiction_county = 'DuPage';

-- ============================================================================
-- TEXAS COUNTY CORRECTIONS
-- ============================================================================

-- Tarrant County - VERIFIED from tarrantcounty.com
UPDATE leverage.rule_citations 
SET 
    source_url = 'https://www.tarrantcounty.com/en/district-clerk/about-us/rules/local-rules-of-the-courts.html',
    excerpt = 'Tarrant County District Courts Local Rules. Outlines procedures and guidelines for civil trial dispositions including filing requirements, timelines, and specific rules for civil cases.',
    verifier = 'web_verified_official',
    confidence_level = 'high',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'TX' 
AND ls.jurisdiction_county = 'Tarrant';

-- Travis County - VERIFIED from traviscountytx.gov
UPDATE leverage.rule_citations 
SET 
    source_url = 'https://www.traviscountytx.gov/courts/files/civil-district',
    excerpt = 'Travis County Local Rules of Civil Procedure and Rules of Decorum. Amended local rules effective November 15, 2024. Governs civil cases in Travis County District Courts.',
    verifier = 'web_verified_official',
    confidence_level = 'high',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'TX' 
AND ls.jurisdiction_county = 'Travis';

-- ============================================================================
-- OHIO COUNTY CORRECTIONS
-- ============================================================================

-- Cuyahoga County - VERIFIED from cuyahogacounty.us
UPDATE leverage.rule_citations 
SET 
    source_url = 'https://cp.cuyahogacounty.us/',
    excerpt = 'Cuyahoga County Court of Common Pleas. E-filing portal for civil cases. Platform for fair resolution of civil and criminal cases. Access to court resources, judges, dockets, and local rules.',
    verifier = 'web_verified_official',
    confidence_level = 'high',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'OH' 
AND ls.jurisdiction_county = 'Cuyahoga';

COMMIT;

-- Show final counts
SELECT 
    rc.verifier,
    rc.confidence_level,
    COUNT(*) as count
FROM leverage.rule_citations rc
JOIN leverage.legal_sources ls ON rc.legal_source_id = ls.id
WHERE ls.jurisdiction_county IS NOT NULL
GROUP BY rc.verifier, rc.confidence_level
ORDER BY rc.verifier;
