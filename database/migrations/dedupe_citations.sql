-- ============================================================================
-- De-duplicate rule_citations and Add Unique Constraint
-- ============================================================================
-- Version: 1.0.0
-- Date: January 30, 2026
-- Purpose: Fix duplicate citations created by non-idempotent migration

BEGIN;

-- ============================================================================
-- STEP 1: Show current state
-- ============================================================================
SELECT 'BEFORE: Total citations' as metric, COUNT(*)::text as value FROM draft.rule_citations
UNION ALL
SELECT 'BEFORE: Unique citations', COUNT(DISTINCT citation)::text FROM draft.rule_citations;

-- ============================================================================
-- STEP 2: Remap validation_rules.citation_id to canonical (earliest) citation
-- ============================================================================
WITH ranked AS (
    SELECT
        id,
        source_name,
        citation,
        FIRST_VALUE(id) OVER (
            PARTITION BY source_name, citation
            ORDER BY created_at NULLS LAST, id
        ) AS keep_id
    FROM draft.rule_citations
),
to_remap AS (
    SELECT id AS old_id, keep_id
    FROM ranked
    WHERE id <> keep_id
)
UPDATE draft.validation_rules r
SET citation_id = to_remap.keep_id
FROM to_remap
WHERE r.citation_id = to_remap.old_id;

-- ============================================================================
-- STEP 3: Delete duplicate citations (keep earliest)
-- ============================================================================
WITH ranked AS (
    SELECT
        id,
        source_name,
        citation,
        ROW_NUMBER() OVER (
            PARTITION BY source_name, citation
            ORDER BY created_at NULLS LAST, id
        ) AS rn
    FROM draft.rule_citations
)
DELETE FROM draft.rule_citations rc
USING ranked r
WHERE rc.id = r.id
  AND r.rn > 1;

-- ============================================================================
-- STEP 4: Add UNIQUE constraint (idempotent)
-- ============================================================================
ALTER TABLE draft.rule_citations
DROP CONSTRAINT IF EXISTS uq_rule_citations_source_citation;

ALTER TABLE draft.rule_citations
ADD CONSTRAINT uq_rule_citations_source_citation UNIQUE (source_name, citation);

-- ============================================================================
-- STEP 5: Show final state
-- ============================================================================
SELECT 'AFTER: Total citations' as metric, COUNT(*)::text as value FROM draft.rule_citations
UNION ALL
SELECT 'AFTER: Unique citations', COUNT(DISTINCT citation)::text FROM draft.rule_citations;

-- Verify all rules still have valid citation_id
SELECT 'Rules with orphaned citations' as check_type, COUNT(*)::text as count
FROM draft.validation_rules r
WHERE r.citation_id IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM draft.rule_citations c WHERE c.id = r.citation_id);

COMMIT;

-- ============================================================================
-- VERIFICATION
-- ============================================================================
SELECT 'Citation count after dedupe' as label, COUNT(*) as count FROM draft.rule_citations;
SELECT 'Rules count' as label, COUNT(*) as count FROM draft.validation_rules WHERE citation_id IS NOT NULL;
