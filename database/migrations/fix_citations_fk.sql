-- ============================================================================
-- Fix rule_citations: Add proper FK to legal_sources
-- ============================================================================
-- Version: 1.0.0
-- Date: January 30, 2026
-- Purpose: Replace source_name text field with legal_source_id FK
--          Remove lingering jurisdiction fields (should have been done earlier)

BEGIN;

-- ============================================================================
-- STEP 1: Show current state
-- ============================================================================
SELECT 'BEFORE: rule_citations columns' as info;
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_schema = 'draft' AND table_name = 'rule_citations'
ORDER BY ordinal_position;

-- ============================================================================
-- STEP 2: Add legal_source_id FK column
-- ============================================================================
ALTER TABLE draft.rule_citations 
ADD COLUMN IF NOT EXISTS legal_source_id UUID;

-- ============================================================================
-- STEP 3: Populate legal_source_id from legal_sources using source_name
-- ============================================================================
-- Match by name (legal_sources.name = rule_citations.source_name)
UPDATE draft.rule_citations rc
SET legal_source_id = ls.id
FROM draft.legal_sources ls
WHERE rc.source_name = ls.name;

-- Verify all citations now have legal_source_id
SELECT 'Citations without legal_source_id' as check_type, COUNT(*) as count
FROM draft.rule_citations
WHERE legal_source_id IS NULL;

-- ============================================================================
-- STEP 4: Drop old UNIQUE constraint
-- ============================================================================
ALTER TABLE draft.rule_citations 
DROP CONSTRAINT IF EXISTS uq_rule_citations_source_citation;

-- ============================================================================
-- STEP 5: Add FK constraint
-- ============================================================================
ALTER TABLE draft.rule_citations 
DROP CONSTRAINT IF EXISTS fk_rule_citations_legal_source;

ALTER TABLE draft.rule_citations 
ADD CONSTRAINT fk_rule_citations_legal_source 
FOREIGN KEY (legal_source_id) REFERENCES draft.legal_sources(id) ON DELETE RESTRICT;

-- ============================================================================
-- STEP 6: Add new UNIQUE constraint on (legal_source_id, citation)
-- ============================================================================
ALTER TABLE draft.rule_citations 
ADD CONSTRAINT uq_rule_citations_source_citation 
UNIQUE (legal_source_id, citation);

-- ============================================================================
-- STEP 7: Remove jurisdiction fields (they belong in validation_rules only)
-- ============================================================================
ALTER TABLE draft.rule_citations DROP COLUMN IF EXISTS jurisdiction_state;
ALTER TABLE draft.rule_citations DROP COLUMN IF EXISTS jurisdiction_county;
ALTER TABLE draft.rule_citations DROP COLUMN IF EXISTS jurisdiction_court;

-- ============================================================================
-- STEP 8: Drop old jurisdiction indexes if they exist
-- ============================================================================
DROP INDEX IF EXISTS draft.idx_rule_citations_state;
DROP INDEX IF EXISTS draft.idx_rule_citations_county;

-- ============================================================================
-- STEP 9: Show final state
-- ============================================================================
SELECT 'AFTER: rule_citations columns' as info;
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_schema = 'draft' AND table_name = 'rule_citations'
ORDER BY ordinal_position;

-- Verify constraints
SELECT conname, contype
FROM pg_constraint
WHERE conrelid = 'draft.rule_citations'::regclass;

COMMIT;

-- ============================================================================
-- VERIFICATION
-- ============================================================================
SELECT 'Citation count' as label, COUNT(*) as count FROM draft.rule_citations;
SELECT 'Citations with legal_source_id' as label, COUNT(*) as count FROM draft.rule_citations WHERE legal_source_id IS NOT NULL;
SELECT 'Unique legal sources referenced' as label, COUNT(DISTINCT legal_source_id) as count FROM draft.rule_citations;
