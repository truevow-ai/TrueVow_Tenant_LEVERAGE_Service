-- =====================================================
-- Louisiana (LA) Medical Malpractice Rules
-- Enhanced Verification Protocol v2.0
-- =====================================================
-- State: Louisiana
-- Governing Law: La. RS § 40:1231.1 et seq. (Louisiana Medical Malpractice Act)
-- Negligence Model: PURE COMPARATIVE FAULT — La. Civil Code Art. 2323
-- SOL: 1 year from act or discovery; 3-year repose (La. RS § 9:5628)
-- Damage Caps: $500,000 non-economic cap per claim; economic uncapped; Patient Comp Fund for excess
-- Expert: Medical Review Panel mandatory pre-suit (La. RS § 40:1231.8)
-- =====================================================

-- RULE 1: STANDARD OF CARE
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, specialization, document_type,
    jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status,
    is_active, is_template, created_at, updated_at
)
VALUES (
    'LA-MED-MAL-STANDARD-OF-CARE', 5,
    'LA Medical Malpractice: Standard of Care (La. RS § 40:1231.1)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'LA',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'contextual_rule',
        'statute', 'La. RS § 40:1231.1',
        'standard_text', 'The standard of care required of every healthcare provider is to exercise that degree of care, skill, and treatment which, in light of all relevant surrounding circumstances, is recognized as acceptable and appropriate by reasonably prudent similar health care providers',
        'key_elements', jsonb_build_array(
            'Duty: provider-patient relationship',
            'Breach: failure to meet standard of reasonably prudent similar provider',
            'Causation: breach proximately caused injury',
            'Damages: actual injury resulted'
        ),
        'locality_rule', 'Louisiana applies a statewide reasonably prudent similar provider standard',
        'informed_consent', 'Separate theory under La. RS § 40:1299.40; patient must be informed of material risks',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('La. RS § 40:1231.1', 'Louisiana Medical Malpractice Act', 'Nolo Louisiana Med Mal'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 2: MEDICAL REVIEW PANEL (MANDATORY PRE-SUIT)
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, specialization, document_type,
    jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status,
    is_active, is_template, created_at, updated_at
)
VALUES (
    'LA-MED-MAL-MEDICAL-REVIEW-PANEL', 5,
    'LA Medical Malpractice: Mandatory Medical Review Panel Pre-Suit (La. RS § 40:1231.8)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'LA',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'hard_rule',
        'statute', 'La. RS § 40:1231.8',
        'requirement', 'All malpractice claims (except binding arbitration) must be reviewed by a Medical Review Panel before court filing',
        'panel_composition', jsonb_build_array(
            'Three healthcare providers selected by the parties from the same specialty as defendant',
            'One attorney chairperson who does not vote',
            'Panel reviews medical evidence and issues advisory opinion on standard of care'
        ),
        'filing_fee', '$100 per named defendant; must be paid within 45 days of confirmation; waivable in hardship',
        'sol_tolling', 'SOL is tolled while the medical review panel proceeding is pending',
        'panel_opinion_admissibility', 'Panel opinion is admissible at trial but not conclusive',
        'confidentiality', 'Panel proceedings are confidential and not reportable to licensing authorities',
        'exceptions', jsonb_build_array(
            'Binding arbitration may substitute for panel review',
            'Failure to pay filing fee within 45 days invalidates request and does not toll SOL'
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('La. RS § 40:1231.8', 'Justia Louisiana 2024', 'Nolo Louisiana Med Mal'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 3: DAMAGE CAPS
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, specialization, document_type,
    jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status,
    is_active, is_template, created_at, updated_at
)
VALUES (
    'LA-MED-MAL-DAMAGE-CAPS', 5,
    'LA Medical Malpractice: $500,000 Total Cap Per Claim (La. RS § 40:1231.2)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'LA',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'hard_rule',
        'statute', 'La. RS § 40:1231.2',
        'total_cap', '$500,000 total cap per malpractice claim (non-economic damages)',
        'economic_damages', 'Future medical expenses are not capped — may be recovered in full beyond the $500k cap',
        'patient_compensation_fund', 'Louisiana Patient Compensation Fund pays damages above individual provider liability; providers must qualify by paying surcharges',
        'cap_exception', 'Cap does not apply if healthcare provider is not qualified under the Louisiana Medical Malpractice Act (unqualified providers face unlimited liability)',
        'cap_notes', jsonb_build_array(
            '$500,000 cap applies to all damages except future medical care',
            'Individual provider liability limited to $100,000; PCF pays remainder up to $500k',
            'Cap applies per claim regardless of number of defendants',
            'Provider must be enrolled in PCF; non-enrolled providers subject to full liability'
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('La. RS § 40:1231.2', 'Nolo Louisiana Med Mal', 'VanWeyLaw Louisiana Med Negligence 2024'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 4: STATUTE OF LIMITATIONS
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, specialization, document_type,
    jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status,
    is_active, is_template, created_at, updated_at
)
VALUES (
    'LA-MED-MAL-SOL-1-YEAR', 5,
    'LA Medical Malpractice: 1-Year SOL, 3-Year Repose (La. RS § 9:5628)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'LA',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'hard_rule',
        'statute', 'La. RS § 9:5628',
        'sol_period', '1 year from date of alleged act, omission, or neglect, OR 1 year from date of discovery',
        'repose_period', '3 years from date of malpractice — absolute bar regardless of discovery',
        'discovery_rule', 'If injury not immediately apparent: 1 year from discovery, but no later than 3 years from incident',
        'review_panel_tolling', 'SOL is suspended while medical review panel proceeding is pending',
        'minor_exception', 'Minors: SOL provisions may apply from birth; 1-year period runs from majority in some cases',
        'tolling', jsonb_build_array(
            'Medical Review Panel filing suspends SOL',
            'Fraudulent concealment may toll SOL',
            'Mental incapacity may suspend SOL',
            'Wrongful death: 1 year from date of death'
        ),
        'verification', jsonb_build_object(
            'statute_verified', false,
            'sources', jsonb_build_array('La. RS § 9:5628', 'Justia Louisiana 2024', 'MGM Attorneys Louisiana SOL Blog 2025'),
            'confidence', 'medium'
        ),
        'protocol_v3_flag', jsonb_build_object(
            'flagged_by',        'protocol_v3_dual_pass',
            'flag_date',         '2026-03-02',
            'pass1_result',      'INCONCLUSIVE - Louisiana Acts 2024, No. 423 repealed La. C.C. Art. 3492 (general 1yr delictual). Med-mal rule uses La. RS 9:5628 (1yr from discovery, 3yr repose). Acts 2024 may only affect Civil Code prescription (Art. 3492), not RS 9:5628.',
            'pass2_result',      'INCONCLUSIVE - RS 9:5628 is a Revised Statute in Title 9 (Civil Code Ancillaries), distinct from La. Civil Code. Acts 2024 No. 423 amended the Civil Code directly. Whether it also amended or supersedes 9:5628 requires reading the actual Act text.',
            'attorney_question', 'Confirm whether La. Acts 2024, No. 423 affects La. RS 9:5628 (med-mal SOL). If 9:5628 is unaffected, LA-MED-MAL-SOL-1-YEAR (1yr discovery / 3yr repose) remains correct. If affected, new period may be 2yr under Art. 3493.11.',
            'priority',          'URGENT',
            'related_change',    'LA-SLIP-FALL-SOL-1-YEAR: Art. 3492 repealed 2024-07-01; now needs_review with transitional notice'
        )
    ),
    'error', 'needs_review', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    review_status    = EXCLUDED.review_status,
    updated_at       = NOW();

-- RULE 5: PURE COMPARATIVE FAULT
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, specialization, document_type,
    jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status,
    is_active, is_template, created_at, updated_at
)
VALUES (
    'LA-MED-MAL-PURE-COMPARATIVE-FAULT', 5,
    'LA Medical Malpractice: Pure Comparative Fault (La. Civil Code Art. 2323)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'LA',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'contextual_rule',
        'statute', 'La. Civil Code Art. 2323',
        'negligence_model', 'pure_comparative',
        'bar_threshold', 'None — plaintiff may recover regardless of fault percentage',
        'rule_description', 'Plaintiff recovery reduced proportionally by their percentage of fault; no bar even at high fault percentages',
        'complete_bar', 'No — Louisiana pure comparative fault allows partial recovery regardless of plaintiff fault percentage',
        'common_factors', jsonb_build_array(
            'Failure to follow medical advice',
            'Delaying treatment after symptoms appear',
            'Providing incomplete medical history',
            'Engaging in risky behaviors post-treatment'
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('La. Civil Code Art. 2323', 'MGM Attorneys Louisiana Comparative Fault Blog', 'Nolo Louisiana Med Mal'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();
