-- =====================================================================================
-- SOL AUTHORITY GOVERNANCE MIGRATION
-- =====================================================================================
-- Purpose: Enforce architectural separation between intake authority and legal intelligence
-- Created: January 30, 2026
-- 
-- CRITICAL: This migration establishes permanent governance to prevent:
--   1. Multiple primary SOL authorities per state+practice
--   2. Invalid authority_level values
--   3. Primary SOL rows missing required fields
-- 
-- Systems Affected:
--   - DRAFT-service: Deep legal intelligence (contextual rules)
--   - Tenant Intake App: Timing gate (primary_state_sol only)
-- =====================================================================================

-- =====================================================================================
-- CONSTRAINT 1: Authority Level Enum Enforcement
-- =====================================================================================
-- Prevents free-form authority levels
-- Only allows: 'primary_state_sol' or 'contextual_rule'
-- Blocks chaos like: 'primary', 'main_sol', 'intake_authority', etc.
-- =====================================================================================

ALTER TABLE draft.validation_rules
ADD CONSTRAINT authority_level_valid
CHECK (
    validator_config ? 'authority_level' IS FALSE
    OR validator_config->>'authority_level' IN (
        'primary_state_sol',
        'contextual_rule'
    )
);

COMMENT ON CONSTRAINT authority_level_valid ON draft.validation_rules IS 
'Enforces controlled enum for authority_level: only primary_state_sol or contextual_rule allowed. Prevents free-form values that would break intake routing determinism.';

-- =====================================================================================
-- CONSTRAINT 2: Unique Primary SOL Authority per State+Practice
-- =====================================================================================
-- CRITICAL: Ensures exactly ONE intake authority row per (state, practice_area)
-- Prevents dual authority that would break generator determinism
-- =====================================================================================

-- Drop old index if exists (replaced with versioned index below)
DROP INDEX IF EXISTS unique_primary_state_sol;

-- Create versioned unique index: Only one ACTIVE version per state+practice
CREATE UNIQUE INDEX unique_active_primary_state_sol
ON draft.validation_rules (jurisdiction_state, practice_area)
WHERE is_active = true
AND validator_config->>'authority_level' = 'primary_state_sol'
AND validator_config->>'valid_to' IS NULL;

COMMENT ON INDEX unique_active_primary_state_sol IS 
'Enforces single ACTIVE intake authority per state+practice. Allows multiple historical versions (valid_to IS NOT NULL) but only one current version (valid_to IS NULL). Prevents dual active authorities that would break tenant-app generator determinism.';

-- =====================================================================================
-- CONSTRAINT 3: Primary SOL Must Have Required Fields
-- =====================================================================================
-- Ensures primary_state_sol rows contain fields needed for intake routing
-- Required fields: sol_years, statute
-- Recommended fields: effective_date, discovery_rule
-- =====================================================================================

ALTER TABLE draft.validation_rules
ADD CONSTRAINT primary_sol_must_have_sol_years
CHECK (
    validator_config->>'authority_level' != 'primary_state_sol'
    OR (validator_config ? 'sol_years' AND validator_config ? 'statute')
);

COMMENT ON CONSTRAINT primary_sol_must_have_sol_years ON draft.validation_rules IS 
'Ensures primary_state_sol rows contain required fields: sol_years and statute. These are mandatory for tenant-app intake routing logic.';

-- =====================================================================================
-- CONSTRAINT 4: Primary SOL Must Be State-Level (Not County)
-- =====================================================================================
-- Intake authority must be state-level only
-- County-specific rules must be contextual_rule, not primary_state_sol
-- =====================================================================================

ALTER TABLE draft.validation_rules
ADD CONSTRAINT primary_sol_must_be_state_level
CHECK (
    validator_config->>'authority_level' != 'primary_state_sol'
    OR (jurisdiction_scope = 'state' AND jurisdiction_county IS NULL)
);

COMMENT ON CONSTRAINT primary_sol_must_be_state_level ON draft.validation_rules IS 
'Ensures primary_state_sol rows are state-level only (not county-specific). County variations must use contextual_rule authority level.';

-- =====================================================================================
-- CONSTRAINT 5: Primary SOL Must Have Versioning Fields
-- =====================================================================================
-- Ensures primary_state_sol rows contain version metadata for legal defensibility
-- Required fields: sol_version, valid_from
-- Optional field: valid_to (NULL while active)
-- =====================================================================================

ALTER TABLE draft.validation_rules
ADD CONSTRAINT primary_sol_requires_version_fields
CHECK (
    validator_config->>'authority_level' != 'primary_state_sol'
    OR (
        validator_config ? 'sol_version'
        AND validator_config ? 'valid_from'
    )
);

COMMENT ON CONSTRAINT primary_sol_requires_version_fields ON draft.validation_rules IS 
'Ensures primary_state_sol rows contain versioning metadata: sol_version (semantic version) and valid_from (legal effective date). This enables proper law change tracking and historical reconstruction.';

-- =====================================================================================
-- VERIFICATION QUERIES
-- =====================================================================================
-- Run these after migration to verify governance is working
-- =====================================================================================

-- Verify no duplicate primary authorities exist
-- Should return 0 rows
DO $$
DECLARE
    duplicate_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO duplicate_count
    FROM (
        SELECT jurisdiction_state, practice_area, COUNT(*) as cnt
        FROM draft.validation_rules
        WHERE is_active = true
        AND validator_config->>'authority_level' = 'primary_state_sol'
        GROUP BY jurisdiction_state, practice_area
        HAVING COUNT(*) > 1
    ) duplicates;
    
    IF duplicate_count > 0 THEN
        RAISE EXCEPTION 'GOVERNANCE VIOLATION: Found % duplicate primary_state_sol authorities. Fix before proceeding.', duplicate_count;
    ELSE
        RAISE NOTICE '✅ Governance verification passed: No duplicate primary authorities found.';
    END IF;
END $$;

-- Verify all primary_state_sol rows have required fields
-- Should return 0 rows
DO $$
DECLARE
    missing_fields_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO missing_fields_count
    FROM draft.validation_rules
    WHERE is_active = true
    AND validator_config->>'authority_level' = 'primary_state_sol'
    AND (
        validator_config->>'sol_years' IS NULL
        OR validator_config->>'statute' IS NULL
    );
    
    IF missing_fields_count > 0 THEN
        RAISE EXCEPTION 'GOVERNANCE VIOLATION: Found % primary_state_sol rows missing required fields (sol_years or statute).', missing_fields_count;
    ELSE
        RAISE NOTICE '✅ Governance verification passed: All primary authorities have required fields.';
    END IF;
END $$;

-- Verify no primary_state_sol rows at county level
-- Should return 0 rows
DO $$
DECLARE
    county_primary_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO county_primary_count
    FROM draft.validation_rules
    WHERE is_active = true
    AND validator_config->>'authority_level' = 'primary_state_sol'
    AND jurisdiction_county IS NOT NULL;
    
    IF county_primary_count > 0 THEN
        RAISE EXCEPTION 'GOVERNANCE VIOLATION: Found % primary_state_sol rows at county level. Must be state-level only.', county_primary_count;
    ELSE
        RAISE NOTICE '✅ Governance verification passed: All primary authorities are state-level.';
    END IF;
END $$;

-- =====================================================================================
-- VERSIONED SOL UPDATE PROCEDURE (When Law Changes)
-- =====================================================================================
-- Example: California changes SOL from 2 years to 3 years effective 2027-01-01
-- =====================================================================================

-- STEP A: Close old version (set valid_to date, deactivate)
-- UPDATE draft.validation_rules
-- SET validator_config = jsonb_set(
--     validator_config,
--     '{valid_to}',
--     to_jsonb('2027-01-01'::text)
-- ),
-- is_active = false,
-- updated_at = NOW()
-- WHERE jurisdiction_state = 'CA'
-- AND practice_area = 'personal_injury'
-- AND validator_config->>'authority_level' = 'primary_state_sol'
-- AND validator_config->>'valid_to' IS NULL;

-- STEP B: Insert new version (increment version, new valid_from, valid_to = NULL)
-- INSERT INTO draft.validation_rules (
--     rule_name, practice_area, jurisdiction_scope, jurisdiction_state,
--     validator_config, is_active, review_status, created_at, updated_at
-- ) VALUES (
--     'CA-PI-PRIMARY-SOL',
--     'personal_injury',
--     'state',
--     'CA',
--     '{
--         "sol_years": 3,
--         "statute": "Cal. Code Civ. Proc. § 335.1 (Amended 2027)",
--         "effective_date": "2027-01-01",
--         "discovery_rule": true,
--         "authority_level": "primary_state_sol",
--         "sol_version": "2.0.0",
--         "valid_from": "2027-01-01",
--         "valid_to": null
--     }'::jsonb,
--     true,
--     'document_verified',
--     NOW(),
--     NOW()
-- );

-- Result:
-- - Version 1.0.0: valid_from=2003-01-01, valid_to=2027-01-01, is_active=false (historical)
-- - Version 2.0.0: valid_from=2027-01-01, valid_to=NULL, is_active=true (current)

-- =====================================================================================
-- GOVERNANCE SUMMARY
-- =====================================================================================
-- After this migration:
--   ✅ Only 'primary_state_sol' or 'contextual_rule' allowed
--   ✅ Maximum ONE ACTIVE primary_state_sol per state+practice (valid_to IS NULL)
--   ✅ Multiple historical versions allowed (valid_to IS NOT NULL)
--   ✅ Primary rows MUST contain sol_years, statute, sol_version, valid_from
--   ✅ Primary rows MUST be state-level (not county)
--   ✅ Database enforces these rules at INSERT/UPDATE time
--   ✅ Tenant-app generator reads only active version (valid_to IS NULL)
--   ✅ Historical versions preserved for audit/reconstruction
--   ✅ DRAFT-service maintains legal intelligence separately
--   ✅ Law changes handled through versioned update procedure
-- =====================================================================================

-- Display current primary authorities (with version info)
SELECT 
    jurisdiction_state,
    practice_area,
    rule_name,
    validator_config->>'sol_years' AS sol_years,
    validator_config->>'statute' AS statute,
    validator_config->>'sol_version' AS version,
    validator_config->>'valid_from' AS valid_from,
    validator_config->>'valid_to' AS valid_to,
    validator_config->>'authority_level' AS authority_level,
    is_active
FROM draft.validation_rules
WHERE validator_config->>'authority_level' = 'primary_state_sol'
ORDER BY jurisdiction_state, practice_area, validator_config->>'valid_from' DESC;

-- =====================================================================================
-- END OF SOL AUTHORITY GOVERNANCE MIGRATION
-- =====================================================================================
