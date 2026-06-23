-- ============================================================================
-- CITATION VERIFICATION REMEDIATION SCRIPT v3
-- ============================================================================
-- Purpose: Update additional county-level citations with VERIFIED data
-- Date: January 30, 2026
-- ============================================================================

BEGIN;

-- ============================================================================
-- CALIFORNIA COUNTY CORRECTIONS - Batch 2
-- ============================================================================

-- San Francisco - VERIFIED from sfsuperiorcourt.org
UPDATE leverage.rule_citations 
SET 
    citation = 'SFSCR Rule 2.11',
    source_url = 'https://www.sfsuperiorcourt.org/online-services/efiling',
    excerpt = 'Rule 2.11 - E-Filing. Mandatory electronic filing for most civil case types, with exceptions for Small Claims, initial Name/Gender Changes, Civil Harassment, and Unlawful Detainers. Self-represented parties not subject to mandatory e-filing. Expanded July 1, 2024 to include Probate Guardianship and Conservatorship.',
    verifier = 'web_verified_official',
    confidence_level = 'high',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'CA' 
AND ls.jurisdiction_county = 'San Francisco';

-- ============================================================================
-- FLORIDA COUNTY CORRECTIONS - Batch 2
-- ============================================================================

-- Hillsborough County - VERIFIED from fljud13.org
UPDATE leverage.rule_citations 
SET 
    citation = '13th JC Admin Order S-2015-013',
    source_url = 'https://www.fljud13.org/Portals/0/AO/DOCS/S-2015-013.pdf',
    excerpt = 'Administrative Order S-2015-013 - General Civil Division Procedures. Nineteen divisions for standard and specialty civil matters including Business Court, Mortgage Foreclosure, Asbestos Litigation. Uses JAWS and Clerk Odyssey system. Cases assigned randomly for equitable distribution.',
    verifier = 'web_verified_official',
    confidence_level = 'high',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'FL' 
AND ls.jurisdiction_county = 'Hillsborough';

-- Duval County - VERIFIED from jud4.org
UPDATE leverage.rule_citations 
SET 
    citation = '4th JC Civil Case Management Orders',
    source_url = 'https://www.jud4.org/court-administration/civil-case-management',
    excerpt = 'Civil Case Management Orders for Duval, Clay, Nassau Counties. Third Amended Administrative Orders effective January 1, 2025 per Supreme Court of Florida directives. Uniform Trial and Case Management Order issued within three business days of filing initial complaint.',
    verifier = 'web_verified_official',
    confidence_level = 'high',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'FL' 
AND ls.jurisdiction_county = 'Duval';

-- Orange County FL - VERIFIED from ninthcircuit.org
UPDATE leverage.rule_citations 
SET 
    citation = '9th JC Admin Order 2021-04',
    source_url = 'https://ninthcircuit.org/civil-case-management',
    excerpt = 'Administrative Order 2021-04 - Civil Case Management. Effective January 1, 2025 for all circuit civil cases. Uniform Trial and Case Management Order issued within 3 business days of filing. Cases categorized as complex, streamlined, or general.',
    verifier = 'web_verified_official',
    confidence_level = 'high',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'FL' 
AND ls.jurisdiction_county = 'Orange';

-- Palm Beach County - VERIFIED from 15thcircuit.com (Admin Order 3.107)
UPDATE leverage.rule_citations 
SET 
    citation = '15th JC Admin Order 3.107',
    source_url = 'https://www.15thcircuit.com/sites/default/files/divisions/A.O.%203.107%20-%20Adoption%20and%20Implementation%20of%20Civil%20Differentiaed%20Case%20Management%20Plan%20for%20Cases%20Filed%20on%20or%20After%20April%2030%2C%202021%20(v.04262021).pdf',
    excerpt = 'Administrative Order 3.107 - Civil Differentiated Case Management Plan. Effective April 30, 2021. Four tracks: General (18 months), Streamlined (12 months), Expedited (9-12 months), Complex (30 months). Case management hearing within 30 days of service deadline.',
    verifier = 'web_verified_official',
    confidence_level = 'high',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'FL' 
AND ls.jurisdiction_county = 'Palm Beach';

-- Pinellas County - VERIFIED from jud6.org
UPDATE leverage.rule_citations 
SET 
    citation = '6th JC Admin Order 2025-006',
    source_url = 'https://www.jud6.org/LegalCommunity/LegalPractice/AOSAndRules/aos/aos2025/2025-006.pdf',
    excerpt = 'Administrative Order 2025-006 - Standing Order for Civil Case Management. Effective January 1, 2025. Plaintiffs must designate case as General or Streamlined upon filing. Streamlined: limited discovery, 3-day trial, 12-month disposition. General: all other civil actions.',
    verifier = 'web_verified_official',
    confidence_level = 'high',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'FL' 
AND ls.jurisdiction_county = 'Pinellas';

COMMIT;

-- ============================================================================
-- VERIFICATION QUERY - Show updated status
-- ============================================================================

SELECT 
    ls.jurisdiction_state,
    ls.jurisdiction_county,
    rc.citation,
    rc.verifier,
    rc.confidence_level
FROM leverage.rule_citations rc
JOIN leverage.legal_sources ls ON rc.legal_source_id = ls.id
WHERE ls.jurisdiction_county IS NOT NULL
AND rc.verifier = 'web_verified_official'
ORDER BY ls.jurisdiction_state, ls.jurisdiction_county;
