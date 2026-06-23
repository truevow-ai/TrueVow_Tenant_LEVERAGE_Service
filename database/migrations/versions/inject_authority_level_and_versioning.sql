-- =====================================================================================
-- INJECT AUTHORITY_LEVEL AND VERSIONING INTO EXISTING PRIMARY SOL ROWS
-- =====================================================================================
-- Purpose: Retrofit existing SOL rows with proper authority_level separation
-- Context: Tenant-app created multiple rows per (state, practice_area) without authority_level
-- Solution: Inject authority_level based on validator_config content detection
-- =====================================================================================

-- STEP 1: Inject 'primary_state_sol' authority_level into rows containing sol_years
-- (These are the canonical SOL authority rows)

UPDATE draft.validation_rules
SET 
    validator_config = validator_config || '{
        "authority_level": "primary_state_sol"
    }'::jsonb,
    updated_at = NOW()
WHERE practice_area = 'personal_injury'
  AND validator_config ? 'sol_years'           -- Has SOL data
  AND NOT (validator_config ? 'authority_level'); -- Doesn't have authority_level yet

-- STEP 2: Inject 'contextual_rule' into rows containing e-filing or county data
-- (These are contextual intelligence, not intake authority)

UPDATE draft.validation_rules
SET 
    validator_config = validator_config || '{
        "authority_level": "contextual_rule"
    }'::jsonb,
    updated_at = NOW()
WHERE practice_area = 'personal_injury'
  AND (
      validator_config ? 'requires_efiling'    -- E-filing row
      OR validator_config ? 'city'             -- County row
      OR validator_config ? 'system'           -- Court system row
  )
  AND NOT (validator_config ? 'authority_level');

-- STEP 3: Now inject versioning fields into primary_state_sol rows
-- Using state-specific effective dates

-- States 27-50 (NE through WY)
UPDATE draft.validation_rules
SET 
    validator_config = validator_config || 
    CASE jurisdiction_state
        WHEN 'NE' THEN '{"sol_version": "1.0.0", "valid_from": "1873-01-01", "valid_to": null}'
        WHEN 'NV' THEN '{"sol_version": "1.0.0", "valid_from": "1953-01-01", "valid_to": null}'
        WHEN 'NH' THEN '{"sol_version": "1.0.0", "valid_from": "1963-01-01", "valid_to": null}'
        WHEN 'NJ' THEN '{"sol_version": "1.0.0", "valid_from": "1951-01-01", "valid_to": null}'
        WHEN 'NM' THEN '{"sol_version": "1.0.0", "valid_from": "1880-01-01", "valid_to": null}'
        WHEN 'NY' THEN '{"sol_version": "1.0.0", "valid_from": "1962-09-01", "valid_to": null}'
        WHEN 'NC' THEN '{"sol_version": "1.0.0", "valid_from": "1868-01-01", "valid_to": null}'
        WHEN 'ND' THEN '{"sol_version": "1.0.0", "valid_from": "1895-01-01", "valid_to": null}'
        WHEN 'OH' THEN '{"sol_version": "1.0.0", "valid_from": "2004-04-09", "valid_to": null}'
        WHEN 'OK' THEN '{"sol_version": "1.0.0", "valid_from": "1984-11-01", "valid_to": null}'
        WHEN 'OR' THEN '{"sol_version": "1.0.0", "valid_from": "1961-01-01", "valid_to": null}'
        WHEN 'PA' THEN '{"sol_version": "1.0.0", "valid_from": "1978-06-27", "valid_to": null}'
        WHEN 'RI' THEN '{"sol_version": "1.0.0", "valid_from": "1971-01-01", "valid_to": null}'
        WHEN 'SC' THEN '{"sol_version": "1.0.0", "valid_from": "1988-01-01", "valid_to": null}'
        WHEN 'SD' THEN '{"sol_version": "1.0.0", "valid_from": "1966-01-01", "valid_to": null}'
        WHEN 'TN' THEN '{"sol_version": "1.0.0", "valid_from": "1972-01-01", "valid_to": null}'
        WHEN 'TX' THEN '{"sol_version": "1.0.0", "valid_from": "1985-09-01", "valid_to": null}'
        WHEN 'UT' THEN '{"sol_version": "1.0.0", "valid_from": "2008-02-07", "valid_to": null}'
        WHEN 'VT' THEN '{"sol_version": "1.0.0", "valid_from": "1959-01-01", "valid_to": null}'
        WHEN 'VA' THEN '{"sol_version": "1.0.0", "valid_from": "1977-10-01", "valid_to": null}'
        WHEN 'WA' THEN '{"sol_version": "1.0.0", "valid_from": "1959-03-23", "valid_to": null}'
        WHEN 'WV' THEN '{"sol_version": "1.0.0", "valid_from": "1959-01-01", "valid_to": null}'
        WHEN 'WI' THEN '{"sol_version": "1.0.0", "valid_from": "1980-01-01", "valid_to": null}'
        WHEN 'WY' THEN '{"sol_version": "1.0.0", "valid_from": "1977-01-01", "valid_to": null}'
    END::jsonb,
    updated_at = NOW()
WHERE practice_area = 'personal_injury'
  AND jurisdiction_state IN ('NE','NV','NH','NJ','NM','NY','NC','ND','OH','OK','OR','PA','RI','SC','SD','TN','TX','UT','VT','VA','WA','WV','WI','WY')
  AND validator_config->>'authority_level' = 'primary_state_sol'
  AND NOT (validator_config ? 'sol_version');

-- =====================================================================================
-- VERIFICATION QUERIES
-- =====================================================================================

-- Count primary SOL rows with proper versioning
SELECT 
    COUNT(*) AS primary_sol_with_versioning
FROM draft.validation_rules
WHERE validator_config->>'authority_level' = 'primary_state_sol'
  AND validator_config ? 'sol_version'
  AND validator_config ? 'valid_from';

-- Show sample states (NE, TX, NY)
SELECT
  jurisdiction_state,
  validator_config->>'sol_years' AS sol_years,
  validator_config->>'authority_level' AS authority_level,
  validator_config->>'sol_version' AS version,
  validator_config->>'valid_from' AS valid_from,
  validator_config->>'valid_to' AS valid_to
FROM draft.validation_rules
WHERE validator_config->>'authority_level' = 'primary_state_sol'
  AND jurisdiction_state IN ('NE','TX','NY')
ORDER BY jurisdiction_state;

-- Count contextual rules (should not have versioning)
SELECT 
    COUNT(*) AS contextual_rules
FROM draft.validation_rules
WHERE validator_config->>'authority_level' = 'contextual_rule';

-- =====================================================================================
-- END OF MIGRATION
-- =====================================================================================
