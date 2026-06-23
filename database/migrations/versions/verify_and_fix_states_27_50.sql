-- =====================================================================================
-- VERIFY AND FIX STATES 27-50 VERSIONING
-- =====================================================================================

-- Check which states have SOL data but no authority_level yet
SELECT 
    jurisdiction_state,
    validator_config ? 'sol_years' AS has_sol_years,
    validator_config ? 'authority_level' AS has_authority_level,
    validator_config ? 'sol_version' AS has_sol_version
FROM draft.validation_rules
WHERE practice_area = 'personal_injury'
  AND jurisdiction_state IN ('NE','NV','NH','NJ','NM','NY','NC','ND','OH','OK','OR','PA','RI','SC','SD','TN','TX','UT','VT','VA','WA','WV','WI','WY')
  AND validator_config ? 'sol_years'
ORDER BY jurisdiction_state;

-- Now inject authority_level AND versioning in states that have sol_years but missing these fields
UPDATE draft.validation_rules
SET 
    validator_config = validator_config || 
    CASE jurisdiction_state
        WHEN 'NE' THEN '{"authority_level": "primary_state_sol", "sol_version": "1.0.0", "valid_from": "1873-01-01", "valid_to": null}'
        WHEN 'NV' THEN '{"authority_level": "primary_state_sol", "sol_version": "1.0.0", "valid_from": "1953-01-01", "valid_to": null}'
        WHEN 'NH' THEN '{"authority_level": "primary_state_sol", "sol_version": "1.0.0", "valid_from": "1963-01-01", "valid_to": null}'
        WHEN 'NJ' THEN '{"authority_level": "primary_state_sol", "sol_version": "1.0.0", "valid_from": "1951-01-01", "valid_to": null}'
        WHEN 'NM' THEN '{"authority_level": "primary_state_sol", "sol_version": "1.0.0", "valid_from": "1880-01-01", "valid_to": null}'
        WHEN 'NY' THEN '{"authority_level": "primary_state_sol", "sol_version": "1.0.0", "valid_from": "1962-09-01", "valid_to": null}'
        WHEN 'NC' THEN '{"authority_level": "primary_state_sol", "sol_version": "1.0.0", "valid_from": "1868-01-01", "valid_to": null}'
        WHEN 'ND' THEN '{"authority_level": "primary_state_sol", "sol_version": "1.0.0", "valid_from": "1895-01-01", "valid_to": null}'
        WHEN 'OH' THEN '{"authority_level": "primary_state_sol", "sol_version": "1.0.0", "valid_from": "2004-04-09", "valid_to": null}'
        WHEN 'OK' THEN '{"authority_level": "primary_state_sol", "sol_version": "1.0.0", "valid_from": "1984-11-01", "valid_to": null}'
        WHEN 'OR' THEN '{"authority_level": "primary_state_sol", "sol_version": "1.0.0", "valid_from": "1961-01-01", "valid_to": null}'
        WHEN 'PA' THEN '{"authority_level": "primary_state_sol", "sol_version": "1.0.0", "valid_from": "1978-06-27", "valid_to": null}'
        WHEN 'RI' THEN '{"authority_level": "primary_state_sol", "sol_version": "1.0.0", "valid_from": "1971-01-01", "valid_to": null}'
        WHEN 'SC' THEN '{"authority_level": "primary_state_sol", "sol_version": "1.0.0", "valid_from": "1988-01-01", "valid_to": null}'
        WHEN 'SD' THEN '{"authority_level": "primary_state_sol", "sol_version": "1.0.0", "valid_from": "1966-01-01", "valid_to": null}'
        WHEN 'TN' THEN '{"authority_level": "primary_state_sol", "sol_version": "1.0.0", "valid_from": "1972-01-01", "valid_to": null}'
        WHEN 'TX' THEN '{"authority_level": "primary_state_sol", "sol_version": "1.0.0", "valid_from": "1985-09-01", "valid_to": null}'
        WHEN 'UT' THEN '{"authority_level": "primary_state_sol", "sol_version": "1.0.0", "valid_from": "2008-02-07", "valid_to": null}'
        WHEN 'VT' THEN '{"authority_level": "primary_state_sol", "sol_version": "1.0.0", "valid_from": "1959-01-01", "valid_to": null}'
        WHEN 'VA' THEN '{"authority_level": "primary_state_sol", "sol_version": "1.0.0", "valid_from": "1977-10-01", "valid_to": null}'
        WHEN 'WA' THEN '{"authority_level": "primary_state_sol", "sol_version": "1.0.0", "valid_from": "1959-03-23", "valid_to": null}'
        WHEN 'WV' THEN '{"authority_level": "primary_state_sol", "sol_version": "1.0.0", "valid_from": "1959-01-01", "valid_to": null}'
        WHEN 'WI' THEN '{"authority_level": "primary_state_sol", "sol_version": "1.0.0", "valid_from": "1980-01-01", "valid_to": null}'
        WHEN 'WY' THEN '{"authority_level": "primary_state_sol", "sol_version": "1.0.0", "valid_from": "1977-01-01", "valid_to": null}'
    END::jsonb,
    updated_at = NOW()
WHERE practice_area = 'personal_injury'
  AND jurisdiction_state IN ('NE','NV','NH','NJ','NM','NY','NC','ND','OH','OK','OR','PA','RI','SC','SD','TN','TX','UT','VT','VA','WA','WV','WI','WY')
  AND validator_config ? 'sol_years'
  AND NOT (validator_config ? 'sol_version');

-- Final verification
SELECT 
    COUNT(*) AS total_states_with_versioning
FROM draft.validation_rules
WHERE validator_config->>'authority_level' = 'primary_state_sol'
  AND validator_config ? 'sol_version'
  AND validator_config ? 'valid_from'
  AND practice_area = 'personal_injury';

-- Show all 50 states
SELECT
  jurisdiction_state,
  validator_config->>'sol_years' AS sol_years,
  validator_config->>'authority_level' AS authority_level,
  validator_config->>'sol_version' AS version,
  validator_config->>'valid_from' AS valid_from
FROM draft.validation_rules
WHERE validator_config->>'authority_level' = 'primary_state_sol'
  AND practice_area = 'personal_injury'
ORDER BY jurisdiction_state;
