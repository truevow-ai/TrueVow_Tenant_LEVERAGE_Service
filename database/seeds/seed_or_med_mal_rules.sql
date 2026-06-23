-- Oregon Medical Malpractice Validation Rules (Batch 8)
-- 5 rules: standard of care, expert requirements, no caps, SOL, negligence model
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
    'OR-MED-MAL-STANDARD-OF-CARE', 5,
    'Oregon Medical Malpractice Standard of Care',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'OR',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'statute', 'ORS 677.095',
        'standard', 'reasonable_care_with_skill',
        'description', 'Oregon requires a healthcare provider to use that degree of care, skill, and treatment which, in light of all relevant surrounding circumstances, is recognized as appropriate and accepted by reasonably careful healthcare providers.',
        'key_elements', jsonb_build_array(
            'Defendant is a licensed healthcare provider',
            'Failure to use reasonable care, skill, and treatment',
            'Causal connection between breach and injury',
            'Actual damages resulted'
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('ORS 677.095', 'Getchell v. Mansfield'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
),
(
    'OR-MED-MAL-EXPERT-REQUIREMENT', 5,
    'Oregon Medical Malpractice Expert Witness Requirement',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'OR',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'statute', 'ORS 677.095; ORCP 47',
        'requirement', 'expert_required_at_trial',
        'description', 'Oregon does not require a pre-suit expert affidavit; however, expert testimony is required at trial to establish the standard of care and causation. Plaintiff must identify expert witnesses during discovery.',
        'pre_suit_requirement', false,
        'trial_requirement', true,
        'expert_qualifications', 'Must be qualified in same or related specialty',
        'notice_requirement', jsonb_build_object(
            'required', false,
            'notes', 'No formal pre-suit notice or affidavit required under Oregon law'
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('ORS 677.095', 'Creasey v. Hogan', 'ORCP 47'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
),
(
    'OR-MED-MAL-NO-DAMAGE-CAPS', 5,
    'Oregon Medical Malpractice — No Damage Caps',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'OR',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'caps_applicable', false,
        'description', 'Oregon has no statutory cap on non-economic or total damages in medical malpractice cases. The Oregon Supreme Court struck down a prior non-economic cap as unconstitutional under Art. I, § 17 of the Oregon Constitution (Lakin v. Senco Products, 1998).',
        'historical_cap_struck_down', jsonb_build_object(
            'case', 'Lakin v. Senco Products, 329 Or. 62 (1999)',
            'former_cap', 500000,
            'basis_for_strike', 'Oregon Constitution Art. I § 17 — right to jury trial'
        ),
        'punitive_damages', jsonb_build_object(
            'available', true,
            'standard', 'Clear and convincing evidence of malice or reckless indifference',
            'cap', 'None statutory'
        ),
        'cap_notes', 'No current cap on non-economic or compensatory damages for med mal in Oregon.',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('Lakin v. Senco Products 329 Or 62 (1999)', 'Or. Const. Art. I § 17'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
),
(
    'OR-MED-MAL-SOL-2-YEARS', 5,
    'Oregon Medical Malpractice Statute of Limitations',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'OR',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'statute', 'ORS 12.110(4)',
        'sol_period', '2 years',
        'trigger', 'date_of_discovery',
        'repose_period', '5 years from act or omission',
        'discovery_rule', true,
        'exceptions', jsonb_build_object(
            'minors', 'Tolled until age 18; 5-year repose still applies',
            'foreign_object', '1 year from discovery; 10-year repose',
            'fraudulent_concealment', 'Tolled during fraudulent concealment'
        ),
        'sol_notes', 'Oregon uses a 2-year discovery rule from when plaintiff knows or should know of injury and cause, with a 5-year statute of repose from the act/omission (ORS 12.110(4)).',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('ORS 12.110(4)', 'ORS 12.160'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
),
(
    'OR-MED-MAL-MODIFIED-COMPARATIVE-FAULT', 5,
    'Oregon Modified Comparative Fault (51% Bar)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'OR',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'statute', 'ORS 31.600',
        'negligence_model', 'modified_comparative',
        'bar_threshold', 51,
        'complete_bar', true,
        'description', 'Oregon applies modified comparative fault with a 51% bar. Plaintiff may recover if their fault is 50% or less; recovery is barred if plaintiff is 51% or more at fault. Damages are reduced in proportion to plaintiff fault.',
        'joint_several', jsonb_build_object(
            'rule', 'Each defendant severally liable for their proportionate share only (ORS 31.610)',
            'exception', 'Economic damages — joint and several if defendant is more than 25% at fault'
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('ORS 31.600', 'ORS 31.610'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config,
              updated_at       = NOW();
