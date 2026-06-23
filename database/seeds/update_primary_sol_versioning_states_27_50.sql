-- =====================================================================================
-- UPDATE PRIMARY SOL VERSIONING: STATES 27-50
-- =====================================================================================
-- Purpose: Add versioning fields to existing primary SOL authority rows
-- This script UPDATES existing rows (doesn't insert new ones)
-- =====================================================================================

-- STATE 27: NEBRASKA (NE)
UPDATE leverage.validation_rules
SET 
    validator_config = validator_config || '{
        "sol_version": "1.0.0",
        "valid_from": "1873-01-01",
        "valid_to": null
    }'::jsonb,
    updated_at = NOW()
WHERE jurisdiction_state = 'NE'
  AND practice_area = 'personal_injury'
  AND validator_config->>'authority_level' = 'primary_state_sol';

-- STATE 28: NEVADA (NV)
UPDATE leverage.validation_rules
SET 
    validator_config = validator_config || '{
        "sol_version": "1.0.0",
        "valid_from": "1953-01-01",
        "valid_to": null
    }'::jsonb,
    updated_at = NOW()
WHERE jurisdiction_state = 'NV'
  AND practice_area = 'personal_injury'
  AND validator_config->>'authority_level' = 'primary_state_sol';

-- STATE 29: NEW HAMPSHIRE (NH)
UPDATE leverage.validation_rules
SET 
    validator_config = validator_config || '{
        "sol_version": "1.0.0",
        "valid_from": "1963-01-01",
        "valid_to": null
    }'::jsonb,
    updated_at = NOW()
WHERE jurisdiction_state = 'NH'
  AND practice_area = 'personal_injury'
  AND validator_config->>'authority_level' = 'primary_state_sol';

-- STATE 30: NEW JERSEY (NJ)
UPDATE leverage.validation_rules
SET 
    validator_config = validator_config || '{
        "sol_version": "1.0.0",
        "valid_from": "1951-01-01",
        "valid_to": null
    }'::jsonb,
    updated_at = NOW()
WHERE jurisdiction_state = 'NJ'
  AND practice_area = 'personal_injury'
  AND validator_config->>'authority_level' = 'primary_state_sol';

-- STATE 31: NEW MEXICO (NM)
UPDATE leverage.validation_rules
SET 
    validator_config = validator_config || '{
        "sol_version": "1.0.0",
        "valid_from": "1880-01-01",
        "valid_to": null
    }'::jsonb,
    updated_at = NOW()
WHERE jurisdiction_state = 'NM'
  AND practice_area = 'personal_injury'
  AND validator_config->>'authority_level' = 'primary_state_sol';

-- STATE 32: NEW YORK (NY)
UPDATE leverage.validation_rules
SET 
    validator_config = validator_config || '{
        "sol_version": "1.0.0",
        "valid_from": "1962-09-01",
        "valid_to": null
    }'::jsonb,
    updated_at = NOW()
WHERE jurisdiction_state = 'NY'
  AND practice_area = 'personal_injury'
  AND validator_config->>'authority_level' = 'primary_state_sol';

-- STATE 33: NORTH CAROLINA (NC)
UPDATE leverage.validation_rules
SET 
    validator_config = validator_config || '{
        "sol_version": "1.0.0",
        "valid_from": "1868-01-01",
        "valid_to": null
    }'::jsonb,
    updated_at = NOW()
WHERE jurisdiction_state = 'NC'
  AND practice_area = 'personal_injury'
  AND validator_config->>'authority_level' = 'primary_state_sol';

-- STATE 34: NORTH DAKOTA (ND)
UPDATE leverage.validation_rules
SET 
    validator_config = validator_config || '{
        "sol_version": "1.0.0",
        "valid_from": "1895-01-01",
        "valid_to": null
    }'::jsonb,
    updated_at = NOW()
WHERE jurisdiction_state = 'ND'
  AND practice_area = 'personal_injury'
  AND validator_config->>'authority_level' = 'primary_state_sol';

-- STATE 35: OHIO (OH)
UPDATE leverage.validation_rules
SET 
    validator_config = validator_config || '{
        "sol_version": "1.0.0",
        "valid_from": "2004-04-09",
        "valid_to": null
    }'::jsonb,
    updated_at = NOW()
WHERE jurisdiction_state = 'OH'
  AND practice_area = 'personal_injury'
  AND validator_config->>'authority_level' = 'primary_state_sol';

-- STATE 36: OKLAHOMA (OK)
UPDATE leverage.validation_rules
SET 
    validator_config = validator_config || '{
        "sol_version": "1.0.0",
        "valid_from": "1984-11-01",
        "valid_to": null
    }'::jsonb,
    updated_at = NOW()
WHERE jurisdiction_state = 'OK'
  AND practice_area = 'personal_injury'
  AND validator_config->>'authority_level' = 'primary_state_sol';

-- STATE 37: OREGON (OR)
UPDATE leverage.validation_rules
SET 
    validator_config = validator_config || '{
        "sol_version": "1.0.0",
        "valid_from": "1961-01-01",
        "valid_to": null
    }'::jsonb,
    updated_at = NOW()
WHERE jurisdiction_state = 'OR'
  AND practice_area = 'personal_injury'
  AND validator_config->>'authority_level' = 'primary_state_sol';

-- STATE 38: PENNSYLVANIA (PA)
UPDATE leverage.validation_rules
SET 
    validator_config = validator_config || '{
        "sol_version": "1.0.0",
        "valid_from": "1978-06-27",
        "valid_to": null
    }'::jsonb,
    updated_at = NOW()
WHERE jurisdiction_state = 'PA'
  AND practice_area = 'personal_injury'
  AND validator_config->>'authority_level' = 'primary_state_sol';

-- STATE 39: RHODE ISLAND (RI)
UPDATE leverage.validation_rules
SET 
    validator_config = validator_config || '{
        "sol_version": "1.0.0",
        "valid_from": "1971-01-01",
        "valid_to": null
    }'::jsonb,
    updated_at = NOW()
WHERE jurisdiction_state = 'RI'
  AND practice_area = 'personal_injury'
  AND validator_config->>'authority_level' = 'primary_state_sol';

-- STATE 40: SOUTH CAROLINA (SC)
UPDATE leverage.validation_rules
SET 
    validator_config = validator_config || '{
        "sol_version": "1.0.0",
        "valid_from": "1988-01-01",
        "valid_to": null
    }'::jsonb,
    updated_at = NOW()
WHERE jurisdiction_state = 'SC'
  AND practice_area = 'personal_injury'
  AND validator_config->>'authority_level' = 'primary_state_sol';

-- STATE 41: SOUTH DAKOTA (SD)
UPDATE leverage.validation_rules
SET 
    validator_config = validator_config || '{
        "sol_version": "1.0.0",
        "valid_from": "1966-01-01",
        "valid_to": null
    }'::jsonb,
    updated_at = NOW()
WHERE jurisdiction_state = 'SD'
  AND practice_area = 'personal_injury'
  AND validator_config->>'authority_level' = 'primary_state_sol';

-- STATE 42: TENNESSEE (TN)
UPDATE leverage.validation_rules
SET 
    validator_config = validator_config || '{
        "sol_version": "1.0.0",
        "valid_from": "1972-01-01",
        "valid_to": null
    }'::jsonb,
    updated_at = NOW()
WHERE jurisdiction_state = 'TN'
  AND practice_area = 'personal_injury'
  AND validator_config->>'authority_level' = 'primary_state_sol';

-- STATE 43: TEXAS (TX)
UPDATE leverage.validation_rules
SET 
    validator_config = validator_config || '{
        "sol_version": "1.0.0",
        "valid_from": "1985-09-01",
        "valid_to": null
    }'::jsonb,
    updated_at = NOW()
WHERE jurisdiction_state = 'TX'
  AND practice_area = 'personal_injury'
  AND validator_config->>'authority_level' = 'primary_state_sol';

-- STATE 44: UTAH (UT)
UPDATE leverage.validation_rules
SET 
    validator_config = validator_config || '{
        "sol_version": "1.0.0",
        "valid_from": "2008-02-07",
        "valid_to": null
    }'::jsonb,
    updated_at = NOW()
WHERE jurisdiction_state = 'UT'
  AND practice_area = 'personal_injury'
  AND validator_config->>'authority_level' = 'primary_state_sol';

-- STATE 45: VERMONT (VT)
UPDATE leverage.validation_rules
SET 
    validator_config = validator_config || '{
        "sol_version": "1.0.0",
        "valid_from": "1959-01-01",
        "valid_to": null
    }'::jsonb,
    updated_at = NOW()
WHERE jurisdiction_state = 'VT'
  AND practice_area = 'personal_injury'
  AND validator_config->>'authority_level' = 'primary_state_sol';

-- STATE 46: VIRGINIA (VA)
UPDATE leverage.validation_rules
SET 
    validator_config = validator_config || '{
        "sol_version": "1.0.0",
        "valid_from": "1977-10-01",
        "valid_to": null
    }'::jsonb,
    updated_at = NOW()
WHERE jurisdiction_state = 'VA'
  AND practice_area = 'personal_injury'
  AND validator_config->>'authority_level' = 'primary_state_sol';

-- STATE 47: WASHINGTON (WA)
UPDATE leverage.validation_rules
SET 
    validator_config = validator_config || '{
        "sol_version": "1.0.0",
        "valid_from": "1959-03-23",
        "valid_to": null
    }'::jsonb,
    updated_at = NOW()
WHERE jurisdiction_state = 'WA'
  AND practice_area = 'personal_injury'
  AND validator_config->>'authority_level' = 'primary_state_sol';

-- STATE 48: WEST VIRGINIA (WV)
UPDATE leverage.validation_rules
SET 
    validator_config = validator_config || '{
        "sol_version": "1.0.0",
        "valid_from": "1959-01-01",
        "valid_to": null
    }'::jsonb,
    updated_at = NOW()
WHERE jurisdiction_state = 'WV'
  AND practice_area = 'personal_injury'
  AND validator_config->>'authority_level' = 'primary_state_sol';

-- STATE 49: WISCONSIN (WI)
UPDATE leverage.validation_rules
SET 
    validator_config = validator_config || '{
        "sol_version": "1.0.0",
        "valid_from": "1980-01-01",
        "valid_to": null
    }'::jsonb,
    updated_at = NOW()
WHERE jurisdiction_state = 'WI'
  AND practice_area = 'personal_injury'
  AND validator_config->>'authority_level' = 'primary_state_sol';

-- STATE 50: WYOMING (WY)
UPDATE leverage.validation_rules
SET 
    validator_config = validator_config || '{
        "sol_version": "1.0.0",
        "valid_from": "1977-01-01",
        "valid_to": null
    }'::jsonb,
    updated_at = NOW()
WHERE jurisdiction_state = 'WY'
  AND practice_area = 'personal_injury'
  AND validator_config->>'authority_level' = 'primary_state_sol';

-- =====================================================================================
-- VERIFICATION QUERY
-- =====================================================================================

SELECT 
    COUNT(*) AS updated_count
FROM leverage.validation_rules
WHERE validator_config->>'authority_level' = 'primary_state_sol'
  AND validator_config ? 'sol_version'
  AND validator_config ? 'valid_from';

SELECT
  jurisdiction_state,
  validator_config->>'sol_years' AS sol_years,
  validator_config->>'sol_version' AS version,
  validator_config->>'valid_from' AS valid_from,
  validator_config->>'valid_to' AS valid_to
FROM leverage.validation_rules
WHERE validator_config->>'authority_level' = 'primary_state_sol'
  AND jurisdiction_state IN ('TX','NY','TN')
ORDER BY jurisdiction_state;

-- =====================================================================================
-- END OF UPDATE SCRIPT
-- =====================================================================================
