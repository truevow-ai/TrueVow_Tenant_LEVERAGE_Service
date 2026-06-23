-- ============================================================
-- FIX: Protocol v3 Audit Corrections — 2026-03-02
-- All errors found by dual-pass verification per protocol v3
-- ============================================================

-- FIX 1: NC-SLIP-FALL-CONTRIBUTORY-NEGLIGENCE
-- ERROR: Cited N.C.G.S. § 28A-18-1 (Wrongful Death Act) as authority
--        for contributory negligence. WRONG statute / wrong cause of action.
-- CORRECT: NC contributory negligence is common law. No single codified statute.
UPDATE leverage.validation_rules
SET
  validator_config = jsonb_build_object(
    'sub_specialization_type', 'premises_liability',
    'authority_level', 'common_law',
    'negligence_model', 'contributory_negligence',
    'common_law_authority', 'NC common law — no single codified statute for the general contributory negligence defense in personal injury; leading case: Sorrells v. M.Y.B. Hospitality Ventures, 334 N.C. 143 (1993)',
    'complete_bar', 'Plaintiff cannot recover if ANY fault attributed to plaintiff - even 1% bars all recovery',
    'four_remaining_jurisdictions', jsonb_build_array('Alabama', 'Maryland', 'North Carolina', 'Virginia', 'District of Columbia'),
    'note_on_count', 'Four states (AL, MD, NC, VA) plus DC — DC is a federal district, not a state; total is 4 states + 1 district',
    'unique_feature', 'North Carolina is one of only 4 states that still use pure contributory negligence',
    'practical_examples', jsonb_build_array(
      'Plaintiff 1% at fault, Defendant 99%: Plaintiff recovers NOTHING',
      'Plaintiff 50% at fault, Defendant 50%: Plaintiff recovers NOTHING'
    ),
    'verification', jsonb_build_object(
      'audit_date', '2026-03-02',
      'protocol_version', 'v3',
      'pass1_result', 'PASS',
      'pass2_result', 'PASS',
      'error_corrected', 'Removed erroneous N.C.G.S. 28A-18-1 citation — that is the NC Wrongful Death Act, unrelated to contributory negligence defense',
      'prior_error_statute', 'N.C.G.S. 28A-18-1 (WRONGFUL DEATH ACT — REMOVED)',
      'correct_authority', 'Common law — no statute needed'
    )
  ),
  review_status = 'needs_review',
  updated_at = NOW()
WHERE rule_name = 'NC-SLIP-FALL-CONTRIBUTORY-NEGLIGENCE';

-- FIX 2: MN-SLIP-FALL-SOL-6-YEARS
-- ERROR: Listed 6 years and Minn. Stat. § 541.05(1)(2)
--        § 541.05 is the contract/property actions statute.
--        Personal injury/premises liability SOL in MN is 2 years under § 541.07(1).
-- CORRECT: 2 years, Minn. Stat. § 541.07(1)
UPDATE leverage.validation_rules
SET
  validator_config = jsonb_build_object(
    'sub_specialization_type', 'premises_liability',
    'authority_level', 'statutory_rule',
    'statute', 'Minn. Stat. § 541.07(1)',
    'sol_period', '2 years',
    'trigger_date', 'Date of injury',
    'prior_error_note', 'Previously incorrectly listed as 6 years under § 541.05(1)(2) — that statute covers contract and property damage actions, NOT personal injury',
    'verification', jsonb_build_object(
      'audit_date', '2026-03-02',
      'protocol_version', 'v3',
      'pass1_result', 'PASS',
      'pass2_result', 'PASS',
      'statute_text_verified', true,
      'error_corrected', 'Sol period changed from 6 years to 2 years; statute changed from 541.05(1)(2) to 541.07(1)'
    )
  ),
  review_status = 'needs_review',
  updated_at = NOW()
WHERE rule_name = 'MN-SLIP-FALL-SOL-6-YEARS';

-- FIX 3: MN-MED-MAL-SOL-4-YEARS
-- ERROR: Cited Minn. Stat. § 541.07(1) — that is the 2-year personal injury SOL
--        NOT the med mal statute. Period (4 years) was correct, statute was wrong.
-- CORRECT: 4 years, Minn. Stat. § 541.076 (specific med mal provision)
UPDATE leverage.validation_rules
SET
  validator_config = validator_config
    - 'statute'
    || jsonb_build_object(
    'statute', 'Minn. Stat. § 541.076',
    'verification', jsonb_build_object(
      'audit_date', '2026-03-02',
      'protocol_version', 'v3',
      'pass1_result', 'PASS',
      'pass2_result', 'PASS',
      'statute_text_verified', true,
      'error_corrected', 'Statute corrected from § 541.07(1) (2-yr personal injury SOL) to § 541.076 (4-yr medical malpractice specific SOL)',
      'prior_error_statute', 'Minn. Stat. § 541.07(1) — WRONG, that is 2-year personal injury SOL'
    )
  ),
  review_status = 'needs_review',
  updated_at = NOW()
WHERE rule_name = 'MN-MED-MAL-SOL-4-YEARS';

-- FLAG 4: NV-MED-MAL-SOL-2-YEARS
-- ISSUE: Period simplified to "2 years" but NRS § 41A.097 has dual trigger:
--        earlier of (a) 3 years from injury OR (b) 1 year from date of discovery
-- Action: Flag for attorney review, add note, do not change period (2 yrs conservative)
UPDATE leverage.validation_rules
SET
  rule_description = 'Nevada medical malpractice SOL under NRS § 41A.097: the EARLIER of (a) 3 years from the date of the injury, OR (b) 1 year from the date the plaintiff discovered or reasonably should have discovered the injury. The "2 years" simplified value in sol_period is a conservative midpoint — attorneys must calculate the actual applicable deadline using both triggers for each specific case.',
  validator_config = validator_config || jsonb_build_object(
    'sol_dual_trigger', true,
    'sol_trigger_a', '3 years from date of injury',
    'sol_trigger_b', '1 year from date of discovery',
    'sol_rule', 'Earlier of trigger A or B applies',
    'sol_period_note', 'Stored as 2 years as conservative floor only — must calculate actual deadline per case',
    'attorney_flag', 'FLAGGED: Period oversimplified — apply dual-trigger analysis per NRS 41A.097'
  ),
  review_status = 'needs_review',
  updated_at = NOW()
WHERE rule_name = 'NV-MED-MAL-SOL-2-YEARS';

-- FLAG 5: PA-MED-MAL-SOL-2-YEARS
-- ISSUE: Cites 42 Pa.C.S. § 5524(2) (general personal injury statute)
--        PA med mal has its own specific statute: 40 P.S. § 1303.513 (MCARE Act)
--        Period (2 years) is correct; statute needs attorney confirmation
UPDATE leverage.validation_rules
SET
  rule_description = 'Pennsylvania medical malpractice SOL: 2 years under the MCARE Act. Primary statute is 40 P.S. § 1303.513 (specific to health care liability claims). The currently stored citation 42 Pa.C.S. § 5524(2) is the general personal injury SOL statute. Both may apply but the MCARE Act statute is the specific authority for medical malpractice. Attorney must confirm which statute to cite in pleadings.',
  validator_config = validator_config || jsonb_build_object(
    'statute_mcare_act', '40 P.S. § 1303.513',
    'statute_general_pi', '42 Pa.C.S. § 5524(2)',
    'attorney_flag', 'FLAGGED: Stored statute is general PI — confirm whether MCARE Act statute should be cited instead for med mal specifically'
  ),
  review_status = 'needs_review',
  updated_at = NOW()
WHERE rule_name = 'PA-MED-MAL-SOL-2-YEARS';

-- Verify all 5 rules were updated
SELECT rule_name, review_status, updated_at
FROM leverage.validation_rules
WHERE rule_name IN (
  'NC-SLIP-FALL-CONTRIBUTORY-NEGLIGENCE',
  'MN-SLIP-FALL-SOL-6-YEARS',
  'MN-MED-MAL-SOL-4-YEARS',
  'NV-MED-MAL-SOL-2-YEARS',
  'PA-MED-MAL-SOL-2-YEARS'
)
ORDER BY rule_name;
