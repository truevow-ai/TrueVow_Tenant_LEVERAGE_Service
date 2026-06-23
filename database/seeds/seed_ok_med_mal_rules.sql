-- Oklahoma Medical Malpractice Validation Rules (Batch 8)
-- 5 rules: standard of care, expert affidavit, damage caps, SOL, negligence model
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
    'OK-MED-MAL-STANDARD-OF-CARE', 5,
    'Oklahoma Medical Malpractice Standard of Care',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'OK',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'statute', '76 O.S. § 21',
        'standard', 'same_or_similar_locality',
        'description', 'Oklahoma uses the same or similar locality standard; defendant healthcare provider must have failed to use ordinary care as would be expected of a reasonably competent healthcare provider in the same or similar circumstances.',
        'key_elements', jsonb_build_array(
            'Defendant is a licensed healthcare provider',
            'Failure to meet standard of care applicable in same or similar locality',
            'Causal connection between breach and injury',
            'Actual damages resulted'
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('76 O.S. § 21', 'Okla. Stat. tit. 76'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
),
(
    'OK-MED-MAL-EXPERT-AFFIDAVIT', 5,
    'Oklahoma Expert Affidavit Requirement',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'OK',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'statute', '12 O.S. § 19.1',
        'requirement', 'expert_affidavit_required',
        'description', 'Oklahoma requires a plaintiff to attach an affidavit of a qualified expert to the petition in a professional negligence action. The expert must be licensed in the same or related field.',
        'affidavit_requirements', jsonb_build_object(
            'timing', 'Filed with petition',
            'expert_qualifications', 'Licensed in same or closely related field as defendant',
            'content', 'Expert must opine that there is a reasonable basis to believe negligence occurred',
            'failure_consequence', 'Dismissal of action'
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('12 O.S. § 19.1', 'Okla. Stat. tit. 12'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
),
(
    'OK-MED-MAL-DAMAGE-CAPS', 5,
    'Oklahoma Medical Malpractice Non-Economic Damage Cap',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'OK',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'statute', '23 O.S. § 61.2',
        'non_economic_cap', 350000,
        'cap_currency', 'USD',
        'exceptions', jsonb_build_array(
            'Conduct constituting reckless disregard for the rights of others',
            'Intentional misconduct',
            'Gross negligence with clear and convincing evidence'
        ),
        'punitive_damages', jsonb_build_object(
            'available', true,
            'cap', 'Greater of $100,000 or actual damages for non-intentional conduct; no cap for intentional conduct'
        ),
        'cap_notes', 'The $350,000 non-economic cap applies per occurrence, not per defendant. Gross negligence or intentional misconduct may remove cap.',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('23 O.S. § 61.2', 'Woods v. Mercy Health Center'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
),
(
    'OK-MED-MAL-SOL-2-YEARS', 5,
    'Oklahoma Medical Malpractice Statute of Limitations',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'OK',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'statute', '76 O.S. § 18',
        'sol_period', '2 years',
        'trigger', 'date_of_discovery_or_occurrence',
        'repose_period', 'None statutory (but see note)',
        'discovery_rule', true,
        'exceptions', jsonb_build_object(
            'minors', 'SOL tolled until age 19 (age of majority); outer limit 7 years from occurrence',
            'fraudulent_concealment', 'Tolled during period of fraudulent concealment',
            'foreign_object', '1 year from discovery of foreign object'
        ),
        'sol_notes', 'Oklahoma applies a 2-year discovery rule; the clock begins when plaintiff knows or should know of the injury and its cause. No statutory repose period for adults.',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('76 O.S. § 18', 'Okla. Stat. tit. 76 § 18'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
),
(
    'OK-MED-MAL-MODIFIED-COMPARATIVE-FAULT', 5,
    'Oklahoma Modified Comparative Fault (51% Bar)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'OK',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'statute', '23 O.S. § 13',
        'negligence_model', 'modified_comparative',
        'bar_threshold', 51,
        'complete_bar', true,
        'description', 'Oklahoma follows modified comparative fault with a 51% bar. Plaintiff may recover if their fault is 50% or less; plaintiff barred from recovery if 51% or more at fault. Damages reduced by plaintiff share of fault.',
        'joint_several', jsonb_build_object(
            'rule', 'Each defendant liable only for proportionate share of non-economic damages; joint and several for economic damages if defendant is more than 50% at fault'
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('23 O.S. § 13', '23 O.S. § 14'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config,
              updated_at       = NOW();
