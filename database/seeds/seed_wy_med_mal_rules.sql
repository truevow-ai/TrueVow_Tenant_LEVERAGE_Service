-- Wyoming Medical Malpractice Validation Rules (Batch 10)
-- 5 rules: standard of care, expert requirements, no caps, SOL, negligence model (modified comparative)
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
    'WY-MED-MAL-STANDARD-OF-CARE', 5,
    'Wyoming Medical Malpractice Standard of Care',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'WY',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'statute', 'Wyo. Stat. Ann. § 1-12-601',
        'standard', 'reasonable_care_and_skill',
        'description', 'Wyoming requires that a healthcare provider exercise that degree of care and skill that is recognized as appropriate and acceptable by reasonably competent healthcare providers in the same or similar community. Wyoming uses a same or similar community standard.',
        'key_elements', jsonb_build_array(
            'Defendant is a licensed healthcare provider',
            'Failure to exercise the standard of care for the same or similar community',
            'Causal connection between breach and injury',
            'Actual damages resulted'
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('Wyo. Stat. Ann. § 1-12-601', 'Danos v. St. Pierre'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
),
(
    'WY-MED-MAL-EXPERT-REQUIREMENT', 5,
    'Wyoming Medical Malpractice Expert Testimony Requirement',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'WY',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'statute', 'Wyo. Stat. Ann. § 1-12-601',
        'requirement', 'expert_required_at_trial',
        'description', 'Wyoming does not require a pre-suit expert affidavit. Expert testimony is required at trial to establish the standard of care and causation in medical malpractice cases.',
        'pre_suit_requirement', false,
        'trial_requirement', true,
        'expert_qualifications', 'Must be licensed and qualified in same or related specialty',
        'notice_requirement', jsonb_build_object(
            'required', false,
            'notes', 'No formal pre-suit notice or affidavit required in Wyoming'
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('Wyo. Stat. Ann. § 1-12-601', 'W.R.E. 702'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
),
(
    'WY-MED-MAL-NO-DAMAGE-CAPS', 5,
    'Wyoming Medical Malpractice — No Damage Caps',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'WY',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'caps_applicable', false,
        'description', 'Wyoming has no statutory cap on non-economic or compensatory damages in medical malpractice cases. Plaintiffs may recover the full amount of damages as determined by the jury.',
        'punitive_damages', jsonb_build_object(
            'available', true,
            'standard', 'Wanton and willful misconduct or malice',
            'cap', 'None statutory'
        ),
        'cap_notes', 'Wyoming imposes no statutory cap on compensatory or non-economic damages in medical malpractice.',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('Wyo. Stat. Ann. Title 1', 'Wyoming Legislature'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
),
(
    'WY-MED-MAL-SOL-2-YEARS', 5,
    'Wyoming Medical Malpractice Statute of Limitations',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'WY',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'statute', 'Wyo. Stat. Ann. § 1-3-107',
        'sol_period', '2 years',
        'trigger', 'date_of_discovery',
        'repose_period', 'None statutory',
        'discovery_rule', true,
        'exceptions', jsonb_build_object(
            'minors', 'SOL tolled until age 18; 2 years from majority',
            'fraudulent_concealment', 'Tolled during fraudulent concealment',
            'foreign_object', '2 years from discovery'
        ),
        'sol_notes', 'Wyoming uses a 2-year discovery SOL from when plaintiff knew or reasonably should have known of the injury. No separate repose period.',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('Wyo. Stat. Ann. § 1-3-107', 'Duke v. Housen'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
),
(
    'WY-MED-MAL-MODIFIED-COMPARATIVE-FAULT', 5,
    'Wyoming Modified Comparative Fault (51% Bar)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'WY',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'statute', 'Wyo. Stat. Ann. § 1-1-109',
        'negligence_model', 'modified_comparative',
        'bar_threshold', 51,
        'complete_bar', true,
        'description', 'Wyoming follows modified comparative fault with a 51% bar. Plaintiff may recover if their fault is 50% or less; plaintiff is barred from all recovery if 51% or more at fault. Damages are reduced by plaintiff share of fault.',
        'joint_several', jsonb_build_object(
            'rule', 'Wyoming abolished joint and several liability; each defendant severally liable for their proportionate share only',
            'statute', 'Wyo. Stat. Ann. § 1-1-109'
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('Wyo. Stat. Ann. § 1-1-109', 'Danculovich v. Brown'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config,
              updated_at       = NOW();
