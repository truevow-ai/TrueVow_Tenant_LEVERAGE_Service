-- Wisconsin Medical Malpractice Validation Rules (Batch 10)
-- 5 rules: standard of care, expert requirements, damage caps, SOL, negligence model
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
    'WI-MED-MAL-STANDARD-OF-CARE', 5,
    'Wisconsin Medical Malpractice Standard of Care',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'WI',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'statute', 'Wis. Stat. § 893.55',
        'standard', 'national_standard_for_specialty',
        'description', 'Wisconsin requires that a healthcare provider exercise that degree of care and skill which, in light of all relevant surrounding circumstances, is recognized as necessary and appropriate by reasonably competent healthcare providers. Wisconsin uses a national standard for specialists.',
        'key_elements', jsonb_build_array(
            'Defendant is a licensed healthcare provider',
            'Failure to exercise the nationally recognized standard of care for the specialty',
            'Causal connection between breach and injury',
            'Actual damages resulted'
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('Wis. Stat. § 893.55', 'Shier v. Freedman'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
),
(
    'WI-MED-MAL-EXPERT-REQUIREMENT', 5,
    'Wisconsin Medical Malpractice Expert Testimony Requirement',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'WI',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'statute', 'Wis. Stat. § 893.555',
        'requirement', 'expert_required_at_trial',
        'description', 'Wisconsin does not require a pre-suit expert affidavit. Expert testimony is required at trial to establish the standard of care and causation. In Wisconsin, the plaintiff must also file a Notice of Claim if suing a governmental healthcare entity.',
        'pre_suit_requirement', false,
        'trial_requirement', true,
        'expert_qualifications', 'Must be qualified in same or related specialty',
        'notice_requirement', jsonb_build_object(
            'required', 'Only for claims against governmental entities',
            'notes', 'Wis. Stat. § 893.80 — notice of claim required for municipal/county healthcare providers'
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('Wis. Stat. § 893.555', 'Christianson v. Downs'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
),
(
    'WI-MED-MAL-DAMAGE-CAPS', 5,
    'Wisconsin Medical Malpractice Non-Economic Damage Cap',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'WI',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'statute', 'Wis. Stat. § 893.55(4)(d)',
        'non_economic_cap', 750000,
        'cap_currency', 'USD',
        'description', 'Wisconsin caps non-economic damages in medical malpractice actions at $750,000 per occurrence. The cap applies to pain, suffering, emotional distress, and loss of consortium.',
        'exceptions', jsonb_build_array(
            'Cap may be adjusted per inflation adjustment provisions'
        ),
        'punitive_damages', jsonb_build_object(
            'available', true,
            'standard', 'Malicious, oppressive, or fraudulent conduct',
            'cap', 'Lesser of $200,000 or twice the compensatory damages'
        ),
        'cap_notes', 'Wisconsin non-economic cap is $750,000 per occurrence. Punitive cap is lesser of $200k or 2x compensatory.',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('Wis. Stat. § 893.55(4)(d)', 'Ferdon v. Wisconsin Patients Comp. Fund'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
),
(
    'WI-MED-MAL-SOL-3-YEARS', 5,
    'Wisconsin Medical Malpractice Statute of Limitations',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'WI',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'statute', 'Wis. Stat. § 893.55(1)',
        'sol_period', '3 years',
        'trigger', 'date_of_injury_or_discovery',
        'repose_period', '5 years from negligent act or omission',
        'discovery_rule', true,
        'exceptions', jsonb_build_object(
            'minors', 'SOL tolled until age 10 for injuries occurring before age 10; otherwise standard adult SOL applies',
            'fraudulent_concealment', 'Tolled during fraudulent concealment',
            'foreign_object', '1 year from discovery; 10-year repose'
        ),
        'sol_notes', 'Wisconsin uses a 3-year discovery SOL with a 5-year statute of repose from the negligent act (§ 893.55(1m)).',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('Wis. Stat. § 893.55(1)', '§ 893.55(1m)', 'Franzen v. Children''s Hospital'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
),
(
    'WI-MED-MAL-MODIFIED-COMPARATIVE-FAULT', 5,
    'Wisconsin Modified Comparative Fault (51% Bar)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'WI',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'statute', 'Wis. Stat. § 895.045',
        'negligence_model', 'modified_comparative',
        'bar_threshold', 51,
        'complete_bar', true,
        'description', 'Wisconsin follows modified comparative fault with a 51% bar. Plaintiff may recover if their negligence does not exceed 50%; plaintiff is barred from all recovery if 51% or more at fault. Damages are reduced by plaintiff share of fault.',
        'joint_several', jsonb_build_object(
            'rule', 'Joint and several liability applies for defendants with 51% or more fault; proportionate liability for others',
            'statute', 'Wis. Stat. § 895.045(1)'
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('Wis. Stat. § 895.045', 'Beyer v. Aqua Jet Car Wash'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config,
              updated_at       = NOW();
