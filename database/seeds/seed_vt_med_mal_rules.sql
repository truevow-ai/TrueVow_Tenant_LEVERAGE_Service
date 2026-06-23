-- Vermont Medical Malpractice Validation Rules (Batch 10)
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
    'VT-MED-MAL-STANDARD-OF-CARE', 5,
    'Vermont Medical Malpractice Standard of Care',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'VT',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'statute', '12 V.S.A. § 1908',
        'standard', 'reasonable_care_and_skill',
        'description', 'Vermont requires a healthcare provider to exercise that degree of care and skill ordinarily possessed and exercised by members of the medical profession in good standing, in the same or similar locality. Vermont uses a reasonable care standard applicable to the specialty.',
        'key_elements', jsonb_build_array(
            'Defendant is a licensed healthcare provider',
            'Failure to exercise reasonable care and skill for the specialty',
            'Causal connection between breach and injury',
            'Actual damages resulted'
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('12 V.S.A. § 1908', 'Boivin v. Weisberg'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
),
(
    'VT-MED-MAL-EXPERT-REQUIREMENT', 5,
    'Vermont Medical Malpractice Expert Witness Requirement',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'VT',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'statute', '12 V.S.A. § 1908',
        'requirement', 'expert_required_at_trial',
        'description', 'Vermont does not require a pre-suit expert affidavit. However, expert testimony is required at trial to establish the standard of care, breach, and causation. Expert must be qualified in the same or related specialty.',
        'pre_suit_requirement', false,
        'trial_requirement', true,
        'expert_qualifications', 'Must be qualified in same or related specialty',
        'notice_requirement', jsonb_build_object(
            'required', false,
            'notes', 'No pre-suit notice or affidavit required under Vermont law'
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('12 V.S.A. § 1908', 'V.R.E. 702'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
),
(
    'VT-MED-MAL-NO-DAMAGE-CAPS', 5,
    'Vermont Medical Malpractice — No Damage Caps',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'VT',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'caps_applicable', false,
        'description', 'Vermont has no statutory cap on non-economic or compensatory damages in medical malpractice cases. Plaintiffs may recover the full amount of damages as determined by the jury.',
        'punitive_damages', jsonb_build_object(
            'available', true,
            'standard', 'Malicious, willful, or wanton conduct',
            'cap', 'None statutory'
        ),
        'cap_notes', 'Vermont imposes no statutory cap on compensatory or non-economic damages.',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('12 V.S.A. Title 12', 'Vermont Legislature'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
),
(
    'VT-MED-MAL-SOL-3-YEARS', 5,
    'Vermont Medical Malpractice Statute of Limitations',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'VT',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'statute', '12 V.S.A. § 521',
        'sol_period', '3 years',
        'trigger', 'date_of_act_or_discovery',
        'repose_period', 'None statutory',
        'discovery_rule', true,
        'exceptions', jsonb_build_object(
            'minors', 'SOL tolled during minority; 3 years from age 18',
            'fraudulent_concealment', 'Tolled during fraudulent concealment',
            'foreign_object', '3 years from discovery'
        ),
        'sol_notes', 'Vermont uses a 3-year SOL from the date of the act or omission, or from discovery if the injury was not discoverable. No separate statute of repose.',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('12 V.S.A. § 521', 'Lillicrap v. Martin'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
),
(
    'VT-MED-MAL-PURE-COMPARATIVE-FAULT', 5,
    'Vermont Pure Comparative Fault',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'VT',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'statute', '12 V.S.A. § 1036',
        'negligence_model', 'modified_comparative',
        'bar_threshold', 51,
        'complete_bar', true,
        'description', 'Vermont follows modified comparative fault with a 51% bar (Uniform Comparative Fault Act). Plaintiff may recover if their fault does not exceed 50%; recovery is barred if plaintiff is 51% or more at fault. Damages are reduced by plaintiff share of fault.',
        'joint_several', jsonb_build_object(
            'rule', 'Defendants jointly and severally liable for full damages',
            'contribution', 'Right of contribution among defendants based on proportionate fault'
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('12 V.S.A. § 1036', 'Champine v. Doolittle'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config,
              updated_at       = NOW();
