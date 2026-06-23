-- =====================================================================================
-- SOL GOVERNANCE INTEGRITY TEST SUITE
-- =====================================================================================
-- Purpose: Continuous validation of versioned SOL governance data quality
-- Usage: Run this query to verify 50-state SOL governance integrity
-- =====================================================================================

-- TEST 1: Count Active Primary SOL Rows (Should be exactly 50)
SELECT 
    '1. Active Primary SOL Row Count' AS test_name,
    COUNT(*) AS actual_count,
    50 AS expected_count,
    CASE 
        WHEN COUNT(*) = 50 THEN '✅ PASS'
        ELSE '❌ FAIL'
    END AS status
FROM draft.validation_rules
WHERE validator_config->>'authority_level' = 'primary_state_sol'
  AND practice_area = 'personal_injury'
  AND is_active = true;

-- TEST 2: Check for States with Missing Statute Field
SELECT 
    '2. States Missing Statute Field' AS test_name,
    COUNT(*) AS count_missing_statute,
    CASE 
        WHEN COUNT(*) = 0 THEN '✅ PASS'
        ELSE '❌ FAIL'
    END AS status,
    STRING_AGG(jurisdiction_state, ', ' ORDER BY jurisdiction_state) AS states_missing_statute
FROM draft.validation_rules
WHERE validator_config->>'authority_level' = 'primary_state_sol'
  AND practice_area = 'personal_injury'
  AND is_active = true
  AND (validator_config->>'statute' IS NULL OR validator_config->>'statute' = '');

-- TEST 3: Check for States with Missing sol_version Field
SELECT 
    '3. States Missing sol_version Field' AS test_name,
    COUNT(*) AS count_missing_version,
    CASE 
        WHEN COUNT(*) = 0 THEN '✅ PASS'
        ELSE '❌ FAIL'
    END AS status,
    STRING_AGG(jurisdiction_state, ', ' ORDER BY jurisdiction_state) AS states_missing_version
FROM draft.validation_rules
WHERE validator_config->>'authority_level' = 'primary_state_sol'
  AND practice_area = 'personal_injury'
  AND is_active = true
  AND NOT (validator_config ? 'sol_version');

-- TEST 4: Check for States with Missing valid_from Field
SELECT 
    '4. States Missing valid_from Field' AS test_name,
    COUNT(*) AS count_missing_valid_from,
    CASE 
        WHEN COUNT(*) = 0 THEN '✅ PASS'
        ELSE '❌ FAIL'
    END AS status,
    STRING_AGG(jurisdiction_state, ', ' ORDER BY jurisdiction_state) AS states_missing_valid_from
FROM draft.validation_rules
WHERE validator_config->>'authority_level' = 'primary_state_sol'
  AND practice_area = 'personal_injury'
  AND is_active = true
  AND NOT (validator_config ? 'valid_from');

-- TEST 5: Check for States with valid_to NOT NULL (Should be 0 active rows)
SELECT 
    '5. Active Rows with valid_to Set' AS test_name,
    COUNT(*) AS count_with_valid_to,
    CASE 
        WHEN COUNT(*) = 0 THEN '✅ PASS'
        ELSE '❌ FAIL'
    END AS status,
    STRING_AGG(jurisdiction_state, ', ' ORDER BY jurisdiction_state) AS states_with_valid_to
FROM draft.validation_rules
WHERE validator_config->>'authority_level' = 'primary_state_sol'
  AND practice_area = 'personal_injury'
  AND is_active = true
  AND validator_config->>'valid_to' IS NOT NULL;

-- TEST 6: Check for Duplicate Active Primary SOL (Should be 0)
SELECT 
    '6. Duplicate Active Primary SOL' AS test_name,
    COUNT(*) AS duplicate_count,
    CASE 
        WHEN COUNT(*) = 0 THEN '✅ PASS'
        ELSE '❌ FAIL'
    END AS status,
    STRING_AGG(jurisdiction_state, ', ') AS duplicate_states
FROM (
    SELECT jurisdiction_state, COUNT(*) AS row_count
    FROM draft.validation_rules
    WHERE validator_config->>'authority_level' = 'primary_state_sol'
      AND practice_area = 'personal_injury'
      AND is_active = true
    GROUP BY jurisdiction_state
    HAVING COUNT(*) > 1
) duplicates;

-- TEST 7: Check for States Missing from 50-State Set
WITH expected_states AS (
    SELECT unnest(ARRAY[
        'AL','AK','AZ','AR','CA','CO','CT','DE','FL','GA',
        'HI','ID','IL','IN','IA','KS','KY','LA','ME','MD',
        'MA','MI','MN','MS','MO','MT','NE','NV','NH','NJ',
        'NM','NY','NC','ND','OH','OK','OR','PA','RI','SC',
        'SD','TN','TX','UT','VT','VA','WA','WV','WI','WY'
    ]) AS state_code
),
actual_states AS (
    SELECT jurisdiction_state
    FROM draft.validation_rules
    WHERE validator_config->>'authority_level' = 'primary_state_sol'
      AND practice_area = 'personal_injury'
      AND is_active = true
)
SELECT 
    '7. Missing States from 50-State Set' AS test_name,
    COUNT(*) AS count_missing_states,
    CASE 
        WHEN COUNT(*) = 0 THEN '✅ PASS'
        ELSE '❌ FAIL'
    END AS status,
    STRING_AGG(state_code, ', ' ORDER BY state_code) AS missing_states
FROM expected_states
WHERE state_code NOT IN (SELECT jurisdiction_state FROM actual_states);

-- TEST 8: Check for Invalid sol_version Format (Should match X.Y.Z)
SELECT 
    '8. Invalid sol_version Format' AS test_name,
    COUNT(*) AS count_invalid_format,
    CASE 
        WHEN COUNT(*) = 0 THEN '✅ PASS'
        ELSE '❌ FAIL'
    END AS status,
    STRING_AGG(jurisdiction_state || ' (' || validator_config->>'sol_version' || ')', ', ') AS invalid_versions
FROM draft.validation_rules
WHERE validator_config->>'authority_level' = 'primary_state_sol'
  AND practice_area = 'personal_injury'
  AND is_active = true
  AND validator_config->>'sol_version' !~ '^\d+\.\d+\.\d+$';

-- TEST 9: Check for Invalid valid_from Date Format (Should be YYYY-MM-DD)
SELECT 
    '9. Invalid valid_from Date Format' AS test_name,
    COUNT(*) AS count_invalid_date,
    CASE 
        WHEN COUNT(*) = 0 THEN '✅ PASS'
        ELSE '❌ FAIL'
    END AS status,
    STRING_AGG(jurisdiction_state || ' (' || validator_config->>'valid_from' || ')', ', ') AS invalid_dates
FROM draft.validation_rules
WHERE validator_config->>'authority_level' = 'primary_state_sol'
  AND practice_area = 'personal_injury'
  AND is_active = true
  AND validator_config->>'valid_from' !~ '^\d{4}-\d{2}-\d{2}$';

-- TEST 10: Summary Report
SELECT 
    '10. SUMMARY' AS test_name,
    COUNT(*) AS total_active_rows,
    SUM(CASE WHEN validator_config->>'statute' IS NOT NULL AND validator_config->>'statute' != '' THEN 1 ELSE 0 END) AS rows_with_statute,
    SUM(CASE WHEN validator_config ? 'sol_version' THEN 1 ELSE 0 END) AS rows_with_version,
    SUM(CASE WHEN validator_config ? 'valid_from' THEN 1 ELSE 0 END) AS rows_with_valid_from,
    CASE 
        WHEN COUNT(*) = 50 
         AND SUM(CASE WHEN validator_config->>'statute' IS NOT NULL AND validator_config->>'statute' != '' THEN 1 ELSE 0 END) = 50
         AND SUM(CASE WHEN validator_config ? 'sol_version' THEN 1 ELSE 0 END) = 50
         AND SUM(CASE WHEN validator_config ? 'valid_from' THEN 1 ELSE 0 END) = 50
        THEN '✅ ALL TESTS PASS'
        ELSE '❌ INTEGRITY ISSUES DETECTED'
    END AS overall_status
FROM draft.validation_rules
WHERE validator_config->>'authority_level' = 'primary_state_sol'
  AND practice_area = 'personal_injury'
  AND is_active = true;

-- =====================================================================================
-- DETAILED REPORT: States Needing Statute Population
-- =====================================================================================
SELECT 
    jurisdiction_state,
    validator_config->>'sol_years' AS sol_years,
    validator_config->>'statute' AS statute,
    validator_config->>'sol_version' AS version,
    validator_config->>'valid_from' AS valid_from,
    CASE 
        WHEN validator_config->>'statute' IS NULL OR validator_config->>'statute' = '' 
        THEN '❌ NEEDS STATUTE'
        ELSE '✅ OK'
    END AS statute_status
FROM draft.validation_rules
WHERE validator_config->>'authority_level' = 'primary_state_sol'
  AND practice_area = 'personal_injury'
  AND is_active = true
ORDER BY 
    CASE 
        WHEN validator_config->>'statute' IS NULL OR validator_config->>'statute' = '' THEN 0
        ELSE 1
    END,
    jurisdiction_state;

-- =====================================================================================
-- END OF INTEGRITY TEST SUITE
-- =====================================================================================
