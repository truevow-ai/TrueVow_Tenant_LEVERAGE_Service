-- ============================================================================
-- CITATION VERIFICATION REMEDIATION SCRIPT v4
-- ============================================================================
-- Purpose: Update additional county-level citations - excerpts only
-- Date: January 30, 2026
-- ============================================================================

BEGIN;

-- San Francisco - VERIFIED from sfsuperiorcourt.org
UPDATE leverage.rule_citations 
SET 
    source_url = 'https://www.sfsuperiorcourt.org/online-services/efiling',
    excerpt = 'Rule 2.11 - E-Filing. Mandatory electronic filing for most civil case types, with exceptions for Small Claims, initial Name/Gender Changes, Civil Harassment, and Unlawful Detainers. Self-represented parties not subject to mandatory e-filing. Expanded July 1, 2024.',
    verifier = 'web_verified_official',
    confidence_level = 'high',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'CA' 
AND ls.jurisdiction_county = 'San Francisco';

-- Hillsborough County - VERIFIED from fljud13.org
UPDATE leverage.rule_citations 
SET 
    source_url = 'https://www.fljud13.org/Portals/0/AO/DOCS/S-2015-013.pdf',
    excerpt = 'Administrative Order S-2015-013 - General Civil Division Procedures. Nineteen divisions for standard and specialty civil matters including Business Court, Mortgage Foreclosure, Asbestos Litigation. Uses JAWS and Clerk Odyssey system.',
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
    source_url = 'https://www.jud4.org/court-administration/civil-case-management',
    excerpt = 'Civil Case Management Orders for Duval, Clay, Nassau Counties. Third Amended Administrative Orders effective January 1, 2025 per Supreme Court of Florida directives. Uniform Trial and Case Management Order issued within three business days of filing.',
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
    source_url = 'https://ninthcircuit.org/civil-case-management',
    excerpt = 'Administrative Order 2021-04 - Civil Case Management. Effective January 1, 2025 for all circuit civil cases. Uniform Trial and Case Management Order issued within 3 business days of filing. Cases categorized as complex, streamlined, or general.',
    verifier = 'web_verified_official',
    confidence_level = 'high',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'FL' 
AND ls.jurisdiction_county = 'Orange';

-- Palm Beach County - VERIFIED from 15thcircuit.com
UPDATE leverage.rule_citations 
SET 
    source_url = 'https://www.15thcircuit.com/civil-differentiated-forms-and-orders',
    excerpt = 'Administrative Order 3.107/3.110 - Civil Differentiated Case Management Plan. Four tracks: General (18 months), Streamlined (12 months), Expedited (9-12 months), Complex (30 months). Case management hearing within 30 days of service deadline.',
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
    source_url = 'https://www.jud6.org/LegalCommunity/LegalPractice/AOSAndRules/aos/aos2025/2025-006.pdf',
    excerpt = 'Administrative Order 2025-006 - Standing Order for Civil Case Management. Effective January 1, 2025. Plaintiffs must designate case as General or Streamlined upon filing. Streamlined: limited discovery, 3-day trial, 12-month disposition.',
    verifier = 'web_verified_official',
    confidence_level = 'high',
    last_verified_at = NOW()
FROM leverage.legal_sources ls
WHERE rule_citations.legal_source_id = ls.id
AND ls.jurisdiction_state = 'FL' 
AND ls.jurisdiction_county = 'Pinellas';

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
