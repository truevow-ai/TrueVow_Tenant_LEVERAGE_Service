-- Protocol V3 Fix SQL - Session 2 (Additional Confirmed Errors)
-- Date: 2026-03-02
-- Errors confirmed via dual-pass verification

\pset pager off

-- ============================================================
-- FIX 1: LA-SLIP-FALL-SOL-1-YEAR
-- Problem: Presents "Active as of 2024-2026" but La. C.C. Art. 3492 
--          was REPEALED effective July 1, 2024 (Acts 2024, No. 423).
--          For injuries on/after July 1, 2024, the SOL is now 2 years 
--          under La. Civ. Code Art. 3493.11.
-- Pass 1: LA changed from 1yr to 2yr via Acts 2024, No. 423 
-- Pass 2: Corroborated by LA-SOL-3492-PI-1YEAR-REPEALED and 
--         LA-SOL-3493-1-PI-2YEAR rules in the same DB
-- Fix: Update current_status, add date-based applicability note
-- ============================================================
UPDATE leverage.validation_rules
SET validator_config = validator_config 
    - 'current_status' 
    || jsonb_build_object(
        'current_status', 'TRANSITIONAL: Art. 3492 (1-year) applies ONLY to injuries occurring BEFORE July 1, 2024. For injuries ON/AFTER July 1, 2024, the SOL is 2 years under La. Civ. Code Art. 3493.11 (Acts 2024, No. 423).',
        'law_change_notice', jsonb_build_object(
            'change_date', '2024-07-01',
            'repealing_act', 'Acts 2024, No. 423',
            'old_period', '1 year (injuries before 2024-07-01)',
            'new_period', '2 years (injuries on/after 2024-07-01)',
            'new_statute', 'La. Civ. Code Art. 3493.11',
            'critical_note', 'ALWAYS check injury date. This 1-year rule applies ONLY to pre-July-2024 injuries. Use LA-SOL-3493-1-PI-2YEAR for newer claims.'
        ),
        'pass1_result', 'PASS - LA changed to 2yr via Acts 2024 No. 423',
        'pass2_result', 'PASS - corroborated by LA-SOL-3492-PI-1YEAR-REPEALED and LA-SOL-3493-1-PI-2YEAR in DB',
        'error_corrected', 'Removed false current_status claim; added date-based applicability and law change notice'
    ),
    review_status = 'needs_review'
WHERE rule_name = 'LA-SLIP-FALL-SOL-1-YEAR';

-- ============================================================
-- FIX 2: MN-SOL-541-05-PI-6YEAR  
-- Problem: NULL-specialization reference rule states MN PI SOL = 6yr 
--          under Minn. Stat. § 541.05 (contract statute). This is WRONG.
--          MN personal injury SOL = 2yr under Minn. Stat. § 541.07(1).
-- Pass 1: § 541.05 covers contract/property (6yr), NOT personal injury
-- Pass 2: § 541.07(1) = 2yr "other tort resulting in personal injury"
--          (already corrected in MN-SLIP-FALL-SOL-6-YEARS this session)
-- Fix: Correct statute, period, note, and sol_days/sol_years
-- ============================================================
UPDATE leverage.validation_rules
SET validator_config = jsonb_build_object(
    'note', 'Minnesota personal injury SOL = 2 years under Minn. Stat. § 541.07(1). NOTE: Rule name MN-SOL-541-05-PI-6YEAR was historically incorrect; § 541.05 covers contracts/property (6yr), NOT personal injury. CORRECTED per Protocol v3.',
    'statute', 'Minn. Stat. § 541.07(1)',
    'sol_days', 730,
    'valid_to', null::text,
    'sol_years', 2,
    'applies_to', 'injury_to_person_personal_injury_tort',
    'valid_from', '1986-01-01',
    'sol_version', '2.0.0',
    'subdivision', 'Subd. 1',
    'authority_level', 'primary_state_sol',
    'old_incorrect_statute', 'Minn. Stat. § 541.05 (contract/property - NOT PI)',
    'old_incorrect_period', '6 years (was wrong - that is the contract period)',
    'pass1_result', 'PASS - § 541.07(1) = 2yr PI tort confirmed',
    'pass2_result', 'PASS - § 541.05 = 6yr contract confirmed NOT PI',
    'error_corrected', 'Corrected statute from § 541.05 to § 541.07(1); corrected period from 6yr to 2yr'
),
review_status = 'needs_review'
WHERE rule_name = 'MN-SOL-541-05-PI-6YEAR';

-- ============================================================
-- FIX 3: SD-SLIP-FALL-PURE-COMPARATIVE
-- Problem: Marks South Dakota as "pure_comparative" under S.D.C.L. § 20-9-2.
--          SD § 20-9-2 uses the "not as great as" standard = modified 
--          comparative with 50% bar (plaintiff recovers only if fault < 50%).
--          SD is NOT a pure comparative state.
-- Pass 1: SDCL § 20-9-2 = "not as great as" = modified comparative 50% bar
-- Pass 2: SD-SLIP-FALL-COMPARATIVE-51-BAR already correctly documents this
-- Fix: Deactivate wrong rule; update to flagged state
-- ============================================================
UPDATE leverage.validation_rules
SET is_active = false,
    validator_config = validator_config 
    || jsonb_build_object(
        'DEACTIVATED_reason', 'WRONG: SD is NOT pure comparative. S.D.C.L. § 20-9-2 uses the "not as great as" standard = modified comparative with 50% bar. Plaintiff cannot recover if their fault is 50% or more. Use SD-SLIP-FALL-COMPARATIVE-51-BAR instead.',
        'pass1_result', 'FAIL - SD § 20-9-2 establishes modified comparative, not pure comparative',
        'pass2_result', 'FAIL - "not as great as" language confirms modified comparative 50% bar',
        'error_type', 'WRONG_NEGLIGENCE_MODEL - deactivated to prevent incorrect application'
    ),
    review_status = 'needs_review'
WHERE rule_name = 'SD-SLIP-FALL-PURE-COMPARATIVE';

-- ============================================================
-- FIX 4: WV-SLIP-FALL-PURE-COMPARATIVE
-- Problem: Marks West Virginia as "pure_comparative_negligence" while 
--          citing W.Va. Code § 55-7-13a — which is the 2015 statute that 
--          ESTABLISHED modified comparative negligence (51% bar).
--          WV changed FROM pure comparative TO modified comparative in 2015.
--          Citing the modified comparative statute as "pure comparative" is 
--          factually impossible.
-- Pass 1: W.Va. Code § 55-7-13a (2015) = modified comparative, 51% bar
-- Pass 2: WV-SLIP-FALL-MODIFIED-COMPARATIVE correctly states this under 
--         the same statute W. Va. Code § 55-7-13a
-- Fix: Deactivate wrong rule
-- ============================================================
UPDATE leverage.validation_rules
SET is_active = false,
    validator_config = validator_config 
    || jsonb_build_object(
        'DEACTIVATED_reason', 'WRONG: W.Va. Code § 55-7-13a (2015) ESTABLISHED modified comparative negligence (51% bar), not pure comparative. Before 2015 WV was pure comparative, but current law is modified comparative. Use WV-SLIP-FALL-MODIFIED-COMPARATIVE instead.',
        'pass1_result', 'FAIL - § 55-7-13a is the 2015 modified comparative act',
        'pass2_result', 'FAIL - WV-SLIP-FALL-MODIFIED-COMPARATIVE correctly classifies this statute',
        'error_type', 'WRONG_NEGLIGENCE_MODEL - deactivated to prevent incorrect application'
    ),
    review_status = 'needs_review'
WHERE rule_name = 'WV-SLIP-FALL-PURE-COMPARATIVE';

-- ============================================================
-- Also flag MT-MED-MAL-SOL-2-YEARS for attorney review
-- (dual-pass inconclusive on exact period structure)
-- ============================================================
UPDATE leverage.validation_rules
SET validator_config = validator_config 
    || jsonb_build_object(
        'protocol_v3_flag', 'DUAL-PASS INCONCLUSIVE: Cannot independently confirm whether MCA § 27-2-205 provides 2yr-from-discovery with 5yr repose, or 3yr-from-act with 2yr-from-discovery. The stored structure (2yr/5yr repose) is plausible but requires attorney confirmation. Period may be 3yr from act, not 2yr.',
        'pass1_result', 'INCONCLUSIVE - uncertain between 2yr discovery/5yr repose vs 3yr occurrence/2yr discovery',
        'pass2_result', 'INCONCLUSIVE - cannot independently confirm exact MT § 27-2-205 trigger structure'
    ),
    review_status = 'needs_review'
WHERE rule_name = 'MT-MED-MAL-SOL-2-YEARS'
  AND review_status = 'document_verified';

-- ============================================================
-- Verification: Show all updated rules
-- ============================================================
\echo ''
\echo '=== VERIFICATION: ALL FIXES APPLIED THIS SESSION ==='
SELECT 
    rule_name, 
    is_active,
    review_status,
    CASE WHEN validator_config ? 'error_corrected' THEN validator_config->>'error_corrected'
         WHEN validator_config ? 'DEACTIVATED_reason' THEN 'DEACTIVATED: ' || LEFT(validator_config->>'DEACTIVATED_reason', 80)
         WHEN validator_config ? 'protocol_v3_flag' THEN 'FLAGGED: ' || LEFT(validator_config->>'protocol_v3_flag', 80)
         WHEN validator_config ? 'law_change_notice' THEN 'UPDATED: law_change_notice added'
         ELSE 'check manually'
    END as fix_summary
FROM leverage.validation_rules
WHERE rule_name IN (
    'LA-SLIP-FALL-SOL-1-YEAR',
    'MN-SOL-541-05-PI-6YEAR', 
    'SD-SLIP-FALL-PURE-COMPARATIVE',
    'WV-SLIP-FALL-PURE-COMPARATIVE',
    'MT-MED-MAL-SOL-2-YEARS',
    -- Prior session fixes
    'NC-SLIP-FALL-CONTRIBUTORY-NEGLIGENCE',
    'MN-SLIP-FALL-SOL-6-YEARS',
    'MN-MED-MAL-SOL-4-YEARS',
    'NV-MED-MAL-SOL-2-YEARS',
    'PA-MED-MAL-SOL-2-YEARS'
)
ORDER BY rule_name;
