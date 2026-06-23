-- Tennessee Medical Malpractice Validation Rules (Batch 9)
-- 5 rules: standard of care, pre-suit notice + certificate of good faith, damage caps, SOL, negligence model
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
    'TN-MED-MAL-STANDARD-OF-CARE', 5,
    'Tennessee Medical Malpractice Standard of Care',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'TN',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'statute', 'Tenn. Code Ann. § 29-26-115',
        'standard', 'locality_and_specialty',
        'description', 'Tennessee requires that a healthcare provider exercise that degree of care, skill, and treatment which, in light of all relevant surrounding circumstances, is recognized as acceptable and appropriate by reasonably prudent similar healthcare providers. Standard is determined by the recognized standard of acceptable professional practice in the profession and specialty in the community in which the defendant practices.',
        'key_elements', jsonb_build_array(
            'Defendant is a licensed healthcare provider',
            'Recognized standard of professional practice in the community',
            'Defendant deviated from that standard',
            'Deviation caused plaintiff injury'
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('Tenn. Code Ann. § 29-26-115', 'Roe v. Methodist Hosp.'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
),
(
    'TN-MED-MAL-PRESUIT-NOTICE-CERTIFICATE', 5,
    'Tennessee Pre-Suit Notice and Certificate of Good Faith',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'TN',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'statute', 'Tenn. Code Ann. §§ 29-26-121, 29-26-122',
        'requirement', 'presuit_notice_and_certificate_of_good_faith',
        'description', 'Tennessee requires a plaintiff to provide written pre-suit notice to each defendant healthcare provider at least 60 days before filing suit (§ 29-26-121). Plaintiff must also file a Certificate of Good Faith signed by plaintiff counsel stating that an expert has been consulted and believes there is a good faith basis for the claim (§ 29-26-122).',
        'notice_requirements', jsonb_build_object(
            'timing', 'At least 60 days before filing complaint',
            'notice_content', 'Full name and address of claimant, name of healthcare provider, claim summary',
            'sol_tolling', 'Pre-suit notice tolls SOL for 120 days',
            'failure_consequence', 'Complaint dismissed without prejudice'
        ),
        'certificate_requirements', jsonb_build_object(
            'timing', 'Filed with complaint',
            'signed_by', 'Attorney for plaintiff',
            'content', 'Expert in same specialty consulted and expressed good faith belief that negligence occurred',
            'failure_consequence', 'Dismissal with prejudice'
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('Tenn. Code Ann. § 29-26-121', '§ 29-26-122', 'Stevens v. Hickman'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
),
(
    'TN-MED-MAL-DAMAGE-CAPS', 5,
    'Tennessee Medical Malpractice Non-Economic Damage Caps',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'TN',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'statute', 'Tenn. Code Ann. § 29-39-102',
        'non_economic_cap', 750000,
        'non_economic_cap_catastrophic', 1000000,
        'cap_currency', 'USD',
        'description', 'Tennessee caps non-economic damages at $750,000 for standard injuries and $1,000,000 for catastrophic injuries (e.g., spinal cord injury, wrongful death of parent, amputation of limb). The caps apply per occurrence.',
        'catastrophic_injuries', jsonb_build_array(
            'Spinal cord injury causing paraplegia or quadriplegia',
            'Amputation of hand, foot, arm, or leg',
            'Third-degree burns on 40% or more of body',
            'Wrongful death of parent of a minor child'
        ),
        'punitive_damages', jsonb_build_object(
            'available', true,
            'statute', 'Tenn. Code Ann. § 29-39-104',
            'cap', 'Greater of 2x compensatory or $500,000',
            'standard', 'Clear and convincing evidence of intentional, fraudulent, malicious, or reckless conduct'
        ),
        'cap_notes', 'Caps apply to non-economic damages; no cap on economic damages. Catastrophic injury cap is $1M.',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('Tenn. Code Ann. § 29-39-102', '§ 29-39-104'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
),
(
    'TN-MED-MAL-SOL-1-YEAR', 5,
    'Tennessee Medical Malpractice Statute of Limitations',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'TN',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'statute', 'Tenn. Code Ann. § 29-26-116',
        'sol_period', '1 year',
        'trigger', 'date_of_discovery_or_occurrence',
        'repose_period', '3 years from negligent act or omission',
        'discovery_rule', true,
        'exceptions', jsonb_build_object(
            'minors_under_6', 'Until age 8 (2 years after 6th birthday)',
            'minors_over_6', 'Standard adult SOL rules apply',
            'fraudulent_concealment', 'Tolled during fraudulent concealment',
            'foreign_object', '1 year from discovery; 1-year repose begins on discovery'
        ),
        'sol_notes', 'Tennessee has a 1-year SOL from discovery or occurrence, with a 3-year absolute repose. Pre-suit notice tolls the SOL an additional 120 days.',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('Tenn. Code Ann. § 29-26-116', '§ 29-26-121'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
),
(
    'TN-MED-MAL-MODIFIED-COMPARATIVE-FAULT', 5,
    'Tennessee Modified Comparative Fault (50% Bar)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'TN',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'statute', 'McIntyre v. Balentine, 833 S.W.2d 52 (Tenn. 1992)',
        'negligence_model', 'modified_comparative',
        'bar_threshold', 50,
        'complete_bar', true,
        'description', 'Tennessee follows modified comparative fault with a 50% bar (not 51%). Plaintiff may recover only if their fault is less than 50%; recovery is completely barred if plaintiff is 50% or more at fault. Damages are reduced by plaintiff share of fault.',
        'joint_several', jsonb_build_object(
            'rule', 'Each defendant liable only for proportionate share (Tennessee Civil Justice Act of 2011)',
            'exception', 'Joint and several applies only if defendant is more than 50% at fault'
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('McIntyre v. Balentine 833 SW2d 52 (Tenn. 1992)', 'Tenn. Code Ann. § 29-11-107'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config,
              updated_at       = NOW();
