-- =============================================================================
-- Migration: audit_standardization_20260302.sql
-- Date: 2026-03-02
-- Purpose: Align Draft Service schema with cross-service audit/data-quality
--          standards (platform-wide initiative).
--
-- Changes:
--   1. draft.validation_rules
--      - tenant_id: UUID → VARCHAR(255)  (Clerk org ID, e.g. org_2abc123)
--      - created_by: UUID → VARCHAR(255) (Clerk user/org ID)
--      - Add updated_by  VARCHAR(255)
--      - Add deleted_at  TIMESTAMPTZ  (indexed)
--      - Add deleted_by  VARCHAR(255)
--
--   2. draft.api_keys
--      - tenant_id: UUID → VARCHAR(255)
--      - created_by: UUID → VARCHAR(255)
--      - Add updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
--      - Add updated_by  VARCHAR(255)
--      - Add deleted_at  TIMESTAMPTZ  (indexed)
--      - Add deleted_by  VARCHAR(255)
--
--   3. draft.templates
--      - tenant_id: UUID → VARCHAR(255)
--      - created_by: UUID → VARCHAR(255)
--      - Add updated_by  VARCHAR(255)
--      - Add deleted_at  TIMESTAMPTZ  (indexed)
--      - Add deleted_by  VARCHAR(255)
--
--   4. draft.validation_analytics
--      - tenant_id: UUID → VARCHAR(255)
--      NOTE: This table is IMMUTABLE / APPEND-ONLY.
--            NO updated_at, NO deleted_at, NO deleted_by are added.
--
-- Safety:
--   - All ALTER COLUMN changes use ::TEXT cast with no data loss
--     (existing UUIDs become their text representation, e.g. "a1b2c3d4-...")
--   - All ADD COLUMN steps are backward-compatible (nullable / have defaults)
--   - Run inside a transaction; ROLLBACK if any step fails
--
-- Post-migration:
--   Back-fill tenant_id values with the correct Clerk org ID strings using:
--     UPDATE draft.validation_rules SET tenant_id = 'org_XXXXX' WHERE ...
--   (do this in a follow-up data migration once Clerk IDs are available)
-- =============================================================================

BEGIN;

-- ---------------------------------------------------------------------------
-- 1. draft.validation_rules
-- ---------------------------------------------------------------------------

-- 1a. tenant_id: UUID → VARCHAR(255)
ALTER TABLE draft.validation_rules
    ALTER COLUMN tenant_id TYPE VARCHAR(255) USING tenant_id::TEXT;

-- 1b. created_by: UUID → VARCHAR(255)
ALTER TABLE draft.validation_rules
    ALTER COLUMN created_by TYPE VARCHAR(255) USING created_by::TEXT;

-- 1c. Add updated_by (idempotent: column may already exist from ORM sync)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'draft'
          AND table_name   = 'validation_rules'
          AND column_name  = 'updated_by'
    ) THEN
        ALTER TABLE draft.validation_rules
            ADD COLUMN updated_by VARCHAR(255) NULL;
    END IF;
END$$;

-- 1d. Add deleted_at (TIMESTAMPTZ, indexed)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'draft'
          AND table_name   = 'validation_rules'
          AND column_name  = 'deleted_at'
    ) THEN
        ALTER TABLE draft.validation_rules
            ADD COLUMN deleted_at TIMESTAMPTZ NULL;
    END IF;
END$$;

CREATE INDEX IF NOT EXISTS idx_validation_rules_deleted_at
    ON draft.validation_rules (deleted_at)
    WHERE deleted_at IS NOT NULL;

-- 1e. Add deleted_by
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'draft'
          AND table_name   = 'validation_rules'
          AND column_name  = 'deleted_by'
    ) THEN
        ALTER TABLE draft.validation_rules
            ADD COLUMN deleted_by VARCHAR(255) NULL;
    END IF;
END$$;

COMMENT ON COLUMN draft.validation_rules.tenant_id  IS 'Clerk org ID e.g. org_2abc123 — VARCHAR(255), never a UUID. NULL = global template.';
COMMENT ON COLUMN draft.validation_rules.updated_by IS 'Clerk user/org ID of last editor';
COMMENT ON COLUMN draft.validation_rules.deleted_at IS 'Soft-delete timestamp. NULL = active. All queries must filter WHERE deleted_at IS NULL.';
COMMENT ON COLUMN draft.validation_rules.deleted_by IS 'Clerk user/org ID who deleted this record. Set by soft_delete(), NOT updated_by.';


-- ---------------------------------------------------------------------------
-- 2. draft.api_keys
-- ---------------------------------------------------------------------------

-- 2a. tenant_id: UUID → VARCHAR(255)
ALTER TABLE draft.api_keys
    ALTER COLUMN tenant_id TYPE VARCHAR(255) USING tenant_id::TEXT;

-- 2b. created_by: UUID → VARCHAR(255)
ALTER TABLE draft.api_keys
    ALTER COLUMN created_by TYPE VARCHAR(255) USING created_by::TEXT;

-- 2c. Add updated_at
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'draft'
          AND table_name   = 'api_keys'
          AND column_name  = 'updated_at'
    ) THEN
        ALTER TABLE draft.api_keys
            ADD COLUMN updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW();
    END IF;
END$$;

-- 2d. Add updated_by
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'draft'
          AND table_name   = 'api_keys'
          AND column_name  = 'updated_by'
    ) THEN
        ALTER TABLE draft.api_keys
            ADD COLUMN updated_by VARCHAR(255) NULL;
    END IF;
END$$;

-- 2e. Add deleted_at (indexed)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'draft'
          AND table_name   = 'api_keys'
          AND column_name  = 'deleted_at'
    ) THEN
        ALTER TABLE draft.api_keys
            ADD COLUMN deleted_at TIMESTAMPTZ NULL;
    END IF;
END$$;

CREATE INDEX IF NOT EXISTS idx_api_keys_deleted_at
    ON draft.api_keys (deleted_at)
    WHERE deleted_at IS NOT NULL;

-- 2f. Add deleted_by
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'draft'
          AND table_name   = 'api_keys'
          AND column_name  = 'deleted_by'
    ) THEN
        ALTER TABLE draft.api_keys
            ADD COLUMN deleted_by VARCHAR(255) NULL;
    END IF;
END$$;

COMMENT ON COLUMN draft.api_keys.tenant_id  IS 'Clerk org ID e.g. org_2abc123 — VARCHAR(255), never a UUID. NULL = admin key.';
COMMENT ON COLUMN draft.api_keys.updated_by IS 'Clerk user/org ID of last editor';
COMMENT ON COLUMN draft.api_keys.deleted_at IS 'Soft-delete timestamp. NULL = active. All queries must filter WHERE deleted_at IS NULL.';
COMMENT ON COLUMN draft.api_keys.deleted_by IS 'Clerk user/org ID who deleted this key. Set by soft_delete(), NOT updated_by.';


-- ---------------------------------------------------------------------------
-- 3. draft.templates
-- ---------------------------------------------------------------------------

-- 3a. tenant_id: UUID → VARCHAR(255)
ALTER TABLE draft.templates
    ALTER COLUMN tenant_id TYPE VARCHAR(255) USING tenant_id::TEXT;

-- 3b. created_by: UUID → VARCHAR(255)
ALTER TABLE draft.templates
    ALTER COLUMN created_by TYPE VARCHAR(255) USING created_by::TEXT;

-- 3c. Add updated_by
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'draft'
          AND table_name   = 'templates'
          AND column_name  = 'updated_by'
    ) THEN
        ALTER TABLE draft.templates
            ADD COLUMN updated_by VARCHAR(255) NULL;
    END IF;
END$$;

-- 3d. Add deleted_at (indexed)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'draft'
          AND table_name   = 'templates'
          AND column_name  = 'deleted_at'
    ) THEN
        ALTER TABLE draft.templates
            ADD COLUMN deleted_at TIMESTAMPTZ NULL;
    END IF;
END$$;

CREATE INDEX IF NOT EXISTS idx_templates_deleted_at
    ON draft.templates (deleted_at)
    WHERE deleted_at IS NOT NULL;

-- 3e. Add deleted_by
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'draft'
          AND table_name   = 'templates'
          AND column_name  = 'deleted_by'
    ) THEN
        ALTER TABLE draft.templates
            ADD COLUMN deleted_by VARCHAR(255) NULL;
    END IF;
END$$;

COMMENT ON COLUMN draft.templates.tenant_id  IS 'Clerk org ID e.g. org_2abc123 — VARCHAR(255), never a UUID.';
COMMENT ON COLUMN draft.templates.updated_by IS 'Clerk user/org ID of last editor';
COMMENT ON COLUMN draft.templates.deleted_at IS 'Soft-delete timestamp. NULL = active. All queries must filter WHERE deleted_at IS NULL.';
COMMENT ON COLUMN draft.templates.deleted_by IS 'Clerk user/org ID who deleted this record. Set by soft_delete(), NOT updated_by.';


-- ---------------------------------------------------------------------------
-- 4. draft.validation_analytics  (tenant_id type only — IMMUTABLE table)
-- ---------------------------------------------------------------------------

-- 4a. tenant_id: UUID → VARCHAR(255)
ALTER TABLE draft.validation_analytics
    ALTER COLUMN tenant_id TYPE VARCHAR(255) USING tenant_id::TEXT;

COMMENT ON COLUMN draft.validation_analytics.tenant_id IS 'Clerk org ID e.g. org_2abc123. VARCHAR(255), never a UUID.';
COMMENT ON TABLE  draft.validation_analytics             IS 'IMMUTABLE / APPEND-ONLY audit log. No updates, no deletes, no soft-delete columns. content_uploaded must always be FALSE.';


-- ---------------------------------------------------------------------------
-- Verification queries (review output after running this migration)
-- ---------------------------------------------------------------------------

SELECT
    c.table_name,
    c.column_name,
    c.data_type,
    c.character_maximum_length,
    c.is_nullable,
    c.column_default
FROM information_schema.columns c
WHERE c.table_schema = 'draft'
  AND c.table_name   IN ('validation_rules', 'api_keys', 'templates', 'validation_analytics')
  AND c.column_name  IN ('tenant_id', 'created_by', 'updated_by', 'deleted_at', 'deleted_by', 'updated_at')
ORDER BY c.table_name, c.column_name;

COMMIT;
