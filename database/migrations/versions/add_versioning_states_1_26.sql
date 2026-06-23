-- =====================================================================================
-- ADD VERSIONING TO STATES 1-26 (MISSING VERSIONS)
-- =====================================================================================

-- Inject versioning into states 1-26 that have authority_level but missing sol_version
UPDATE draft.validation_rules
SET 
    validator_config = validator_config || 
    CASE jurisdiction_state
        WHEN 'AL' THEN '{"sol_version": "1.0.0", "valid_from": "1975-01-01", "valid_to": null}'
        WHEN 'AK' THEN '{"sol_version": "1.0.0", "valid_from": "1962-01-01", "valid_to": null}'
        WHEN 'AZ' THEN '{"sol_version": "1.0.0", "valid_from": "1956-01-01", "valid_to": null}'
        WHEN 'AR' THEN '{"sol_version": "1.0.0", "valid_from": "1969-01-01", "valid_to": null}'
        -- CA already has versioning (skip)
        WHEN 'CO' THEN '{"sol_version": "1.0.0", "valid_from": "1986-07-01", "valid_to": null}'
        WHEN 'CT' THEN '{"sol_version": "1.0.0", "valid_from": "1958-10-01", "valid_to": null}'
        WHEN 'DE' THEN '{"sol_version": "1.0.0", "valid_from": "1974-01-01", "valid_to": null}'
        WHEN 'FL' THEN '{"sol_version": "2.0.0", "valid_from": "2023-03-24", "valid_to": null}'
        WHEN 'GA' THEN '{"sol_version": "1.0.0", "valid_from": "1987-07-01", "valid_to": null}'
        WHEN 'HI' THEN '{"sol_version": "1.0.0", "valid_from": "1972-01-01", "valid_to": null}'
        WHEN 'ID' THEN '{"sol_version": "1.0.0", "valid_from": "1971-01-01", "valid_to": null}'
        WHEN 'IL' THEN '{"sol_version": "1.0.0", "valid_from": "1982-01-01", "valid_to": null}'
        WHEN 'IN' THEN '{"sol_version": "1.0.0", "valid_from": "1998-07-01", "valid_to": null}'
        WHEN 'IA' THEN '{"sol_version": "1.0.0", "valid_from": "1976-07-01", "valid_to": null}'
        WHEN 'KS' THEN '{"sol_version": "1.0.0", "valid_from": "1970-01-01", "valid_to": null}'
        WHEN 'KY' THEN '{"sol_version": "1.0.0", "valid_from": "1976-01-01", "valid_to": null}'
        WHEN 'LA' THEN '{"sol_version": "2.0.0", "valid_from": "2024-07-01", "valid_to": null}'
        WHEN 'ME' THEN '{"sol_version": "1.0.0", "valid_from": "1965-01-01", "valid_to": null}'
        WHEN 'MD' THEN '{"sol_version": "1.0.0", "valid_from": "1973-07-01", "valid_to": null}'
        WHEN 'MA' THEN '{"sol_version": "1.0.0", "valid_from": "1958-01-01", "valid_to": null}'
        -- MI already has versioning (skip)
        WHEN 'MN' THEN '{"sol_version": "1.0.0", "valid_from": "1986-01-01", "valid_to": null}'
        WHEN 'MS' THEN '{"sol_version": "1.0.0", "valid_from": "1972-01-01", "valid_to": null}'
        WHEN 'MO' THEN '{"sol_version": "1.0.0", "valid_from": "1977-01-01", "valid_to": null}'
        WHEN 'MT' THEN '{"sol_version": "1.0.0", "valid_from": "1997-10-01", "valid_to": null}'
    END::jsonb,
    updated_at = NOW()
WHERE practice_area = 'personal_injury'
  AND jurisdiction_state IN ('AL','AK','AZ','AR','CO','CT','DE','FL','GA','HI','ID','IL','IN','IA','KS','KY','LA','ME','MD','MA','MN','MS','MO','MT')
  AND validator_config->>'authority_level' = 'primary_state_sol'
  AND NOT (validator_config ? 'sol_version');

-- Handle Louisiana duplicate (close the older 1-year version)
UPDATE draft.validation_rules
SET 
    validator_config = validator_config || '{"valid_to": "2024-06-30"}'::jsonb,
    is_active = false,
    updated_at = NOW()
WHERE jurisdiction_state = 'LA'
  AND practice_area = 'personal_injury'
  AND validator_config->>'authority_level' = 'primary_state_sol'
  AND validator_config->>'sol_years' = '1'
  AND validator_config->>'sol_version' = '2.0.0';

-- Final verification
SELECT 
    COUNT(*) AS total_states_with_versioning
FROM draft.validation_rules
WHERE validator_config->>'authority_level' = 'primary_state_sol'
  AND validator_config ? 'sol_version'
  AND validator_config ? 'valid_from'
  AND practice_area = 'personal_injury'
  AND is_active = true;

-- Show states missing versioning (should be empty)
SELECT
  jurisdiction_state,
  validator_config->>'sol_years' AS sol_years
FROM draft.validation_rules
WHERE validator_config->>'authority_level' = 'primary_state_sol'
  AND practice_area = 'personal_injury'
  AND is_active = true
  AND NOT (validator_config ? 'sol_version')
ORDER BY jurisdiction_state;

-- Show all 50 active states with versioning
SELECT
  jurisdiction_state,
  validator_config->>'sol_years' AS sol_years,
  validator_config->>'sol_version' AS version,
  validator_config->>'valid_from' AS valid_from,
  validator_config->>'valid_to' AS valid_to
FROM draft.validation_rules
WHERE validator_config->>'authority_level' = 'primary_state_sol'
  AND practice_area = 'personal_injury'
  AND is_active = true
ORDER BY jurisdiction_state;
