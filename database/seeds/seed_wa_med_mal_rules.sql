-- Washington Medical Malpractice Validation Rules (Batch 10)
-- 5 rules: standard of care, expert requirements, no non-economic caps, SOL, negligence model
-- Schema: leverage.validation_rules (no physical sub_specialization_type / jurisdiction_code columns)

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, specialization, document_type,
    jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status,
    is_active, is_template, created_at, updated_at
)
VALUES
(
    'WA-MED-MAL-STANDARD-OF-CARE', 5,
    'Washington Medical Malpractice Standard of Care',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'WA',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'statute', 'RCW 7.70.040',
        'standard', 'reasonable_care_in_same_or_similar_circumstances',
        'description', 'Washington requires that a healthcare provider exercise that degree of care, skill, and learning expected of a reasonably prudent healthcare provider in the same or similar circumstances. The standard is determined as of the time of treatment.',
        'key_elements', jsonb_build_array(
            'Defendant is a healthcare provider as defined by RCW 7.70.020',
            'Failure to exercise the degree of care and skill of a reasonably prudent provider',
            'Proximate causation of injury',
            'Actual damages resulted'
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('RCW 7.70.040', 'RCW 7.70.010', 'Harbeson v. Parke-Davis'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
),
(
    'WA-MED-MAL-EXPERT-REQUIREMENT', 5,
    'Washington Medical Malpractice Expert Testimony Requirement',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'WA',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'statute', 'RCW 7.70.100',
        'requirement', 'expert_required_at_trial',
        'description', 'Washington does not require a pre-suit expert affidavit. Expert testimony is required at trial to establish the standard of care and causation. The expert must meet qualifications set by RCW 7.70.100.',
        'pre_suit_requirement', false,
        'trial_requirement', true,
        'expert_qualifications', 'Must have knowledge of the applicable standard of care; licensed in same or related specialty',
        'notice_requirement', jsonb_build_object(
            'required', false,
            'notes', 'No formal pre-suit notice required in Washington'
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('RCW 7.70.100', 'Harris v. Groth'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
),
(
    'WA-MED-MAL-NO-DAMAGE-CAPS', 5,
    'Washington Medical Malpractice — No Non-Economic Damage Caps',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'WA',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'caps_applicable', false,
        'description', 'Washington has no statutory cap on non-economic or compensatory damages in medical malpractice cases. The Washington Supreme Court struck down a prior non-economic cap as unconstitutional (Sofie v. Fibreboard Corp., 1989).',
        'historical_cap_struck_down', jsonb_build_object(
            'case', 'Sofie v. Fibreboard Corp., 112 Wn.2d 636 (1989)',
            'basis_for_strike', 'Washington Constitution Art. I § 21 — right to jury trial'
        ),
        'punitive_damages', jsonb_build_object(
            'available', false,
            'notes', 'Punitive damages generally not recoverable in Washington tort cases'
        ),
        'cap_notes', 'No current cap on non-economic or compensatory damages for med mal in Washington.',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('Sofie v. Fibreboard Corp. 112 Wn.2d 636 (1989)', 'RCW 7.70'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
),
(
    'WA-MED-MAL-SOL-3-YEARS', 5,
    'Washington Medical Malpractice Statute of Limitations',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'WA',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'statute', 'RCW 4.16.350',
        'sol_period', '3 years',
        'trigger', 'date_of_occurrence_or_discovery',
        'repose_period', '8 years from negligent act or omission',
        'discovery_rule', true,
        'exceptions', jsonb_build_object(
            'minors', 'SOL tolled until age 18; 8-year repose still applies',
            'fraudulent_concealment', 'Tolled during fraudulent concealment',
            'foreign_object', '1 year from discovery; no repose'
        ),
        'sol_notes', 'Washington uses a 3-year discovery SOL with an 8-year statute of repose from the negligent act. RCW 4.16.350 governs.',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('RCW 4.16.350', 'Young v. Key Pharmaceuticals'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
),
(
    'WA-MED-MAL-PURE-COMPARATIVE-FAULT', 5,
    'Washington Pure Comparative Fault',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'WA',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'statute', 'RCW 4.22.005',
        'negligence_model', 'pure_comparative',
        'complete_bar', false,
        'description', 'Washington follows pure comparative fault. Plaintiff may recover damages regardless of their percentage of fault; recovery is merely reduced by plaintiff share of fault. No threshold bars recovery.',
        'joint_several', jsonb_build_object(
            'rule', 'Each defendant liable only for their proportionate share (RCW 4.22.070)',
            'exception', 'Joint and several applies for intentional tortfeasors and for defendants who are more than 50% at fault'
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('RCW 4.22.005', 'RCW 4.22.070', 'Tegman v. Accident'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config,
              updated_at       = NOW();
