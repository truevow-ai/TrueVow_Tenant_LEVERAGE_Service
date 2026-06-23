-- Verify all 50 U.S. states have been seeded with PI court rules

\echo ''
\echo '================================================================================'
\echo 'OVERALL SUMMARY'
\echo '================================================================================'

-- Count states with PI validation rules
WITH state_counts AS (
    SELECT 
        jurisdiction_state,
        COUNT(DISTINCT rule_name) as rule_count
    FROM leverage.validation_rules
    WHERE jurisdiction_scope = 'state'
    AND practice_area = 'personal_injury'
    AND is_active = true
    GROUP BY jurisdiction_state
)
SELECT 
    COUNT(*) as total_states,
    SUM(rule_count) as total_rules
FROM state_counts;

\echo ''
\echo '================================================================================'
\echo 'STATE-BY-STATE BREAKDOWN'
\echo '================================================================================'

SELECT 
    jurisdiction_state AS state,
    COUNT(DISTINCT rule_name) as rules,
    STRING_AGG(DISTINCT validator_name, ', ' ORDER BY validator_name) as rule_types
FROM leverage.validation_rules
WHERE jurisdiction_scope = 'state'
AND practice_area = 'personal_injury'
AND is_active = true
GROUP BY jurisdiction_state
ORDER BY jurisdiction_state;

\echo ''
\echo '================================================================================'
\echo 'CHECKING FOR MISSING STATES'
\echo '================================================================================'

WITH all_states AS (
    SELECT UNNEST(ARRAY[
        'AL', 'AK', 'AZ', 'AR', 'CA', 'CO', 'CT', 'DE', 'FL', 'GA',
        'HI', 'ID', 'IL', 'IN', 'IA', 'KS', 'KY', 'LA', 'ME', 'MD',
        'MA', 'MI', 'MN', 'MS', 'MO', 'MT', 'NE', 'NV', 'NH', 'NJ',
        'NM', 'NY', 'NC', 'ND', 'OH', 'OK', 'OR', 'PA', 'RI', 'SC',
        'SD', 'TN', 'TX', 'UT', 'VT', 'VA', 'WA', 'WV', 'WI', 'WY'
    ]) AS state_code
),
seeded_states AS (
    SELECT DISTINCT jurisdiction_state
    FROM leverage.validation_rules
    WHERE jurisdiction_scope = 'state'
    AND practice_area = 'personal_injury'
    AND is_active = true
)
SELECT 
    CASE 
        WHEN COUNT(*) = 0 THEN '✅ ALL 50 STATES SEEDED SUCCESSFULLY!'
        ELSE '❌ MISSING STATES: ' || STRING_AGG(state_code, ', ')
    END AS verification_status
FROM all_states a
LEFT JOIN seeded_states s ON a.state_code = s.jurisdiction_state
WHERE s.jurisdiction_state IS NULL;

\echo ''
\echo '================================================================================'
\echo 'STATUTE OF LIMITATIONS DISTRIBUTION'
\echo '================================================================================'

SELECT 
    (validator_config->>'sol_years')::int AS sol_years,
    COUNT(*) as state_count,
    STRING_AGG(jurisdiction_state, ', ' ORDER BY jurisdiction_state) as states
FROM leverage.validation_rules
WHERE jurisdiction_scope = 'state'
AND practice_area = 'personal_injury'
AND validator_name LIKE '%SOL%'
AND is_active = true
GROUP BY (validator_config->>'sol_years')::int
ORDER BY sol_years;

\echo ''
\echo '================================================================================'
\echo 'E-FILING SYSTEM BREAKDOWN'
\echo '================================================================================'

SELECT 
    validator_config->>'efiling_system' AS efiling_system,
    COUNT(*) as state_count,
    STRING_AGG(jurisdiction_state, ', ' ORDER BY jurisdiction_state) as states
FROM leverage.validation_rules
WHERE jurisdiction_scope = 'state'
AND practice_area = 'personal_injury'
AND validator_name LIKE '%E-Filing%'
AND is_active = true
GROUP BY validator_config->>'efiling_system'
ORDER BY state_count DESC;

\echo ''
\echo 'VERIFICATION COMPLETE'
\echo ''
