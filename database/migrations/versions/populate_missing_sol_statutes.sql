-- =====================================================================================
-- POPULATE MISSING SOL STATUTE REFERENCES (16 STATES)
-- =====================================================================================
-- Purpose: Add statute field to 16 primary SOL rows missing this critical field
-- Context: Tenant-app requires statute field to generate JSON configs
-- =====================================================================================

-- STATE: ARIZONA (AZ)
UPDATE draft.validation_rules
SET 
    validator_config = validator_config || '{
        "statute": "A.R.S. § 12-542"
    }'::jsonb,
    updated_at = NOW()
WHERE jurisdiction_state = 'AZ'
  AND practice_area = 'personal_injury'
  AND validator_config->>'authority_level' = 'primary_state_sol'
  AND is_active = true
  AND (validator_config->>'statute' IS NULL OR validator_config->>'statute' = '');

-- STATE: COLORADO (CO)
UPDATE draft.validation_rules
SET 
    validator_config = validator_config || '{
        "statute": "C.R.S. § 13-80-102(1)(a)"
    }'::jsonb,
    updated_at = NOW()
WHERE jurisdiction_state = 'CO'
  AND practice_area = 'personal_injury'
  AND validator_config->>'authority_level' = 'primary_state_sol'
  AND is_active = true
  AND (validator_config->>'statute' IS NULL OR validator_config->>'statute' = '');

-- STATE: FLORIDA (FL) - Post-2023 change
UPDATE draft.validation_rules
SET 
    validator_config = validator_config || '{
        "statute": "Fla. Stat. § 95.11(3)(o)"
    }'::jsonb,
    updated_at = NOW()
WHERE jurisdiction_state = 'FL'
  AND practice_area = 'personal_injury'
  AND validator_config->>'authority_level' = 'primary_state_sol'
  AND is_active = true
  AND (validator_config->>'statute' IS NULL OR validator_config->>'statute' = '');

-- STATE: GEORGIA (GA)
UPDATE draft.validation_rules
SET 
    validator_config = validator_config || '{
        "statute": "O.C.G.A. § 9-3-33"
    }'::jsonb,
    updated_at = NOW()
WHERE jurisdiction_state = 'GA'
  AND practice_area = 'personal_injury'
  AND validator_config->>'authority_level' = 'primary_state_sol'
  AND is_active = true
  AND (validator_config->>'statute' IS NULL OR validator_config->>'statute' = '');

-- STATE: ILLINOIS (IL)
UPDATE draft.validation_rules
SET 
    validator_config = validator_config || '{
        "statute": "735 ILCS 5/13-202"
    }'::jsonb,
    updated_at = NOW()
WHERE jurisdiction_state = 'IL'
  AND practice_area = 'personal_injury'
  AND validator_config->>'authority_level' = 'primary_state_sol'
  AND is_active = true
  AND (validator_config->>'statute' IS NULL OR validator_config->>'statute' = '');

-- STATE: MASSACHUSETTS (MA)
UPDATE draft.validation_rules
SET 
    validator_config = validator_config || '{
        "statute": "M.G.L. c. 260, § 2A"
    }'::jsonb,
    updated_at = NOW()
WHERE jurisdiction_state = 'MA'
  AND practice_area = 'personal_injury'
  AND validator_config->>'authority_level' = 'primary_state_sol'
  AND is_active = true
  AND (validator_config->>'statute' IS NULL OR validator_config->>'statute' = '');

-- STATE: MARYLAND (MD)
UPDATE draft.validation_rules
SET 
    validator_config = validator_config || '{
        "statute": "Md. Code, Cts. & Jud. Proc. § 5-101"
    }'::jsonb,
    updated_at = NOW()
WHERE jurisdiction_state = 'MD'
  AND practice_area = 'personal_injury'
  AND validator_config->>'authority_level' = 'primary_state_sol'
  AND is_active = true
  AND (validator_config->>'statute' IS NULL OR validator_config->>'statute' = '');

-- STATE: NORTH CAROLINA (NC)
UPDATE draft.validation_rules
SET 
    validator_config = validator_config || '{
        "statute": "N.C. Gen. Stat. § 1-52(16)"
    }'::jsonb,
    updated_at = NOW()
WHERE jurisdiction_state = 'NC'
  AND practice_area = 'personal_injury'
  AND validator_config->>'authority_level' = 'primary_state_sol'
  AND is_active = true
  AND (validator_config->>'statute' IS NULL OR validator_config->>'statute' = '');

-- STATE: NEW JERSEY (NJ)
UPDATE draft.validation_rules
SET 
    validator_config = validator_config || '{
        "statute": "N.J.S.A. 2A:14-2"
    }'::jsonb,
    updated_at = NOW()
WHERE jurisdiction_state = 'NJ'
  AND practice_area = 'personal_injury'
  AND validator_config->>'authority_level' = 'primary_state_sol'
  AND is_active = true
  AND (validator_config->>'statute' IS NULL OR validator_config->>'statute' = '');

-- STATE: NEW YORK (NY)
UPDATE draft.validation_rules
SET 
    validator_config = validator_config || '{
        "statute": "N.Y. C.P.L.R. § 214"
    }'::jsonb,
    updated_at = NOW()
WHERE jurisdiction_state = 'NY'
  AND practice_area = 'personal_injury'
  AND validator_config->>'authority_level' = 'primary_state_sol'
  AND is_active = true
  AND (validator_config->>'statute' IS NULL OR validator_config->>'statute' = '');

-- STATE: OHIO (OH)
UPDATE draft.validation_rules
SET 
    validator_config = validator_config || '{
        "statute": "Ohio Rev. Code § 2305.10"
    }'::jsonb,
    updated_at = NOW()
WHERE jurisdiction_state = 'OH'
  AND practice_area = 'personal_injury'
  AND validator_config->>'authority_level' = 'primary_state_sol'
  AND is_active = true
  AND (validator_config->>'statute' IS NULL OR validator_config->>'statute' = '');

-- STATE: PENNSYLVANIA (PA)
UPDATE draft.validation_rules
SET 
    validator_config = validator_config || '{
        "statute": "42 Pa. C.S. § 5524(2)"
    }'::jsonb,
    updated_at = NOW()
WHERE jurisdiction_state = 'PA'
  AND practice_area = 'personal_injury'
  AND validator_config->>'authority_level' = 'primary_state_sol'
  AND is_active = true
  AND (validator_config->>'statute' IS NULL OR validator_config->>'statute' = '');

-- STATE: TENNESSEE (TN)
UPDATE draft.validation_rules
SET 
    validator_config = validator_config || '{
        "statute": "Tenn. Code Ann. § 28-3-104"
    }'::jsonb,
    updated_at = NOW()
WHERE jurisdiction_state = 'TN'
  AND practice_area = 'personal_injury'
  AND validator_config->>'authority_level' = 'primary_state_sol'
  AND is_active = true
  AND (validator_config->>'statute' IS NULL OR validator_config->>'statute' = '');

-- STATE: TEXAS (TX)
UPDATE draft.validation_rules
SET 
    validator_config = validator_config || '{
        "statute": "Tex. Civ. Prac. & Rem. Code § 16.003"
    }'::jsonb,
    updated_at = NOW()
WHERE jurisdiction_state = 'TX'
  AND practice_area = 'personal_injury'
  AND validator_config->>'authority_level' = 'primary_state_sol'
  AND is_active = true
  AND (validator_config->>'statute' IS NULL OR validator_config->>'statute' = '');

-- STATE: VIRGINIA (VA)
UPDATE draft.validation_rules
SET 
    validator_config = validator_config || '{
        "statute": "Va. Code Ann. § 8.01-243(A)"
    }'::jsonb,
    updated_at = NOW()
WHERE jurisdiction_state = 'VA'
  AND practice_area = 'personal_injury'
  AND validator_config->>'authority_level' = 'primary_state_sol'
  AND is_active = true
  AND (validator_config->>'statute' IS NULL OR validator_config->>'statute' = '');

-- STATE: WASHINGTON (WA)
UPDATE draft.validation_rules
SET 
    validator_config = validator_config || '{
        "statute": "RCW 4.16.080(2)"
    }'::jsonb,
    updated_at = NOW()
WHERE jurisdiction_state = 'WA'
  AND practice_area = 'personal_injury'
  AND validator_config->>'authority_level' = 'primary_state_sol'
  AND is_active = true
  AND (validator_config->>'statute' IS NULL OR validator_config->>'statute' = '');

-- =====================================================================================
-- VERIFICATION QUERY
-- =====================================================================================

-- Show states that were updated
SELECT 
    jurisdiction_state,
    validator_config->>'sol_years' AS sol_years,
    validator_config->>'statute' AS statute,
    validator_config->>'sol_version' AS version,
    validator_config->>'valid_from' AS valid_from
FROM draft.validation_rules
WHERE jurisdiction_state IN ('AZ','CO','FL','GA','IL','MA','MD','NC','NJ','NY','OH','PA','TN','TX','VA','WA')
  AND practice_area = 'personal_injury'
  AND validator_config->>'authority_level' = 'primary_state_sol'
  AND is_active = true
ORDER BY jurisdiction_state;

-- Final count check (should be 0 states missing statute)
SELECT 
    COUNT(*) AS states_still_missing_statute
FROM draft.validation_rules
WHERE validator_config->>'authority_level' = 'primary_state_sol'
  AND practice_area = 'personal_injury'
  AND is_active = true
  AND (validator_config->>'statute' IS NULL OR validator_config->>'statute' = '');

-- =====================================================================================
-- END OF MIGRATION
-- =====================================================================================
