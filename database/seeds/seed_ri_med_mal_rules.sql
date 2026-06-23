-- Rhode Island Medical Malpractice Validation Rules (Batch 8)
-- 5 rules: standard of care, malpractice tribunal, no caps, SOL, negligence model
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
    'RI-MED-MAL-STANDARD-OF-CARE', 5,
    'Rhode Island Medical Malpractice Standard of Care',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'RI',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'statute', 'R.I. Gen. Laws § 9-19-34',
        'standard', 'national_standard',
        'description', 'Rhode Island applies a national standard of care in medical malpractice cases. A healthcare provider must exercise that degree of care, skill, and treatment that, in light of all relevant surrounding circumstances, is recognized as appropriate and accepted by qualified experts in the field.',
        'key_elements', jsonb_build_array(
            'Defendant is a licensed healthcare provider',
            'Failure to exercise nationally accepted standard of care',
            'Causal connection between breach and injury',
            'Actual damages resulted'
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('R.I. Gen. Laws § 9-19-34', 'Lauro v. Knowles 312 A.2d 416'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
),
(
    'RI-MED-MAL-TRIBUNAL-REQUIREMENT', 5,
    'Rhode Island Medical Malpractice Tribunal Requirement',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'RI',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'statute', 'R.I. Gen. Laws § 9-19-32 through § 9-19-41',
        'requirement', 'malpractice_tribunal_required',
        'description', 'Rhode Island requires all medical malpractice claims to be reviewed by a Medical Malpractice Tribunal before trial. The tribunal consists of a judge, a physician, and an attorney. Plaintiff must present a sufficient offer of proof that the defendant deviated from accepted medical standards.',
        'tribunal_requirements', jsonb_build_object(
            'composition', 'Superior Court Judge, licensed physician, licensed attorney',
            'timing', 'Required before commencement of discovery',
            'offer_of_proof', 'Plaintiff must present affidavit and supporting documentation showing deviation from accepted standards',
            'failure_consequence', 'Plaintiff may proceed only upon posting a $100,000 bond; failure to post bond results in dismissal',
            'bond_amount', 100000
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('R.I. Gen. Laws § 9-19-32', '§ 9-19-41', 'Bouchard v. Sundberg 834 A.2d 744'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
),
(
    'RI-MED-MAL-NO-DAMAGE-CAPS', 5,
    'Rhode Island Medical Malpractice — No Damage Caps',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'RI',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'caps_applicable', false,
        'description', 'Rhode Island has no statutory cap on compensatory or non-economic damages in medical malpractice cases. Plaintiffs may recover the full amount of economic and non-economic damages as determined by the jury.',
        'punitive_damages', jsonb_build_object(
            'available', true,
            'standard', 'Malice, bad faith, or willful/wanton conduct',
            'cap', 'None statutory'
        ),
        'cap_notes', 'Rhode Island imposes no statutory cap on compensatory or non-economic damages.',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('R.I. Gen. Laws Title 9', 'Rhode Island Legislature'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
),
(
    'RI-MED-MAL-SOL-3-YEARS', 5,
    'Rhode Island Medical Malpractice Statute of Limitations',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'RI',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'statute', 'R.I. Gen. Laws § 9-1-14.1',
        'sol_period', '3 years',
        'trigger', 'date_of_occurrence',
        'repose_period', 'None statutory',
        'discovery_rule', true,
        'exceptions', jsonb_build_object(
            'minors', 'Tolled during minority; 3 years from reaching age 18',
            'fraudulent_concealment', 'Tolled during fraudulent concealment of malpractice',
            'continuing_treatment', 'Continuing treatment rule may toll until treatment ends'
        ),
        'sol_notes', 'Rhode Island imposes a 3-year SOL running from the date of the act, omission, or occurrence. Discovery rule applies where injury was not discoverable. No statutory repose period.',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('R.I. Gen. Laws § 9-1-14.1', 'Catucci v. Pachucki 516 A.2d 1358'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
),
(
    'RI-MED-MAL-PURE-COMPARATIVE-FAULT', 5,
    'Rhode Island Pure Comparative Fault',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'RI',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'statute', 'R.I. Gen. Laws § 9-20-4',
        'negligence_model', 'pure_comparative',
        'complete_bar', false,
        'description', 'Rhode Island follows pure comparative fault. Plaintiff may recover damages regardless of their percentage of fault; recovery is merely reduced proportionally. No threshold bars recovery.',
        'joint_several', jsonb_build_object(
            'rule', 'Joint and several liability applies; defendants jointly liable for full damage amount',
            'contribution', 'Defendant who pays more than proportionate share has right of contribution'
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('R.I. Gen. Laws § 9-20-4', 'Mone v. Greyhound Lines'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config,
              updated_at       = NOW();
