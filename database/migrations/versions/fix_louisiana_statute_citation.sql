-- =====================================================================================
-- FIX LOUISIANA STATUTE CITATION
-- =====================================================================================
-- Purpose: Correct Louisiana primary SOL statute citation
-- Issue: Statute cite is "La. Civ. Code Art. 3493.1" but should be "La. Civ. Code Art. 3493.11"
-- Context: Louisiana changed from 1-year (Art. 3492, repealed) to 2-year (Art. 3493.11) effective July 1, 2024
-- =====================================================================================

UPDATE draft.validation_rules
SET 
    validator_config = validator_config || '{
        "statute": "La. Civ. Code Art. 3493.11"
    }'::jsonb,
    updated_at = NOW()
WHERE jurisdiction_state = 'LA'
  AND practice_area = 'personal_injury'
  AND validator_config->>'authority_level' = 'primary_state_sol'
  AND is_active = true;

-- Verification
SELECT 
    jurisdiction_state,
    validator_config->>'sol_years' AS sol_years,
    validator_config->>'statute' AS statute,
    validator_config->>'sol_version' AS version,
    validator_config->>'valid_from' AS valid_from,
    validator_config->>'valid_to' AS valid_to
FROM draft.validation_rules
WHERE jurisdiction_state = 'LA'
  AND practice_area = 'personal_injury'
  AND validator_config->>'authority_level' = 'primary_state_sol'
ORDER BY validator_config->>'valid_from' DESC;

-- =====================================================================================
-- END OF FIX
-- =====================================================================================
