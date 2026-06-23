-- =====================================================
-- Idaho (ID) Medical Malpractice Rules
-- Enhanced Verification Protocol v2.0
-- =====================================================
-- State: Idaho
-- Governing Law: Idaho Code Title 5 (SOL), Title 6 (damage caps)
-- Negligence Model: MODIFIED COMPARATIVE (50% bar) — Idaho Code § 6-801
-- SOL: 2 years from occurrence/discovery (Idaho Code § 5-219)
-- Damage Caps: Non-economic cap $250,000 inflation-adjusted (Idaho Code § 6-1603)
-- Expert: Required; Daubert standard; community standard rule (§ 6-1012/6-1013)
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
    'ID-MED-MAL-STANDARD-OF-CARE', 5,
    'ID Medical Malpractice: Standard of Care (Idaho Code § 6-1012)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'ID',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'contextual_rule',
        'statute', 'Idaho Code § 6-1012',
        'standard_text', 'Plaintiff must show defendant failed to meet the applicable standard of health care practice of the community in which care was provided, as that standard existed at the time and place of the alleged negligence',
        'key_elements', jsonb_build_array(
            'Duty: provider-patient relationship',
            'Breach: failure to meet community standard of health care practice',
            'Causation: breach proximately caused injury',
            'Damages: actual injury resulted'
        ),
        'locality_rule', 'Idaho applies a community standard — must show standard of care in local or similar community',
        'expert_required', 'Expert must establish community standard per Idaho Code § 6-1013',
        'informed_consent', 'Separate claim; failure to disclose material risk',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('Idaho Code § 6-1012', 'Idaho Code § 6-1013', 'Justia Idaho 2024'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 2: EXPERT WITNESS REQUIREMENTS
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, specialization, document_type,
    jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status,
    is_active, is_template, created_at, updated_at
)
VALUES (
    'ID-MED-MAL-EXPERT-WITNESS', 5,
    'ID Medical Malpractice: Expert Witness Requirements (Idaho Code § 6-1013)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'ID',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'hard_rule',
        'statute', 'Idaho Code § 6-1013',
        'requirement', 'Expert testimony required to establish community standard of health care practice and breach',
        'qualifications', jsonb_build_array(
            'Licensed to practice in same specialty in Idaho or similar community',
            'Familiar with applicable standard of care',
            'Must testify defendant deviated from that standard',
            'Idaho follows Daubert admissibility standards'
        ),
        'disclosure', 'Expert disclosure per I.R.C.P. 26(b)(4); name, opinions and basis must be disclosed',
        'no_presuit_certificate', 'Idaho does not require a pre-filing affidavit or certificate of merit',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('Idaho Code § 6-1013', 'Expert Institute Idaho Expert Witness Rules 2025'),
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
    'ID-MED-MAL-DAMAGE-CAPS', 5,
    'ID Medical Malpractice: Non-Economic Damage Cap Inflation-Adjusted (Idaho Code § 6-1603)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'ID',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'hard_rule',
        'statute', 'Idaho Code § 6-1603',
        'non_economic_cap', '$250,000 base, adjusted annually per Idaho Industrial Commission average annual wage calculations',
        'economic_damages', 'No cap on economic damages (medical expenses, lost wages, future care)',
        'adjustment_mechanism', 'Annual inflation adjustment tied to average annual wage per Idaho Industrial Commission',
        'exceptions', jsonb_build_array(
            'Cap does not apply to willful or reckless misconduct',
            'Cap does not apply to felony conduct by defendant',
            'Jury is not informed of cap during trial'
        ),
        'punitive_damages', 'Available for oppressive, fraudulent, malicious or outrageous conduct (Idaho Code § 6-1604)',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('Idaho Code § 6-1603', 'Justia Idaho 2024', 'Expertise.com Idaho 2024'),
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
    'ID-MED-MAL-SOL-2-YEARS', 5,
    'ID Medical Malpractice: 2-Year SOL (Idaho Code § 5-219)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'ID',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'hard_rule',
        'statute', 'Idaho Code § 5-219',
        'sol_period', '2 years from date of occurrence, act, or omission causing injury',
        'discovery_rule', 'Fraudulent concealment or foreign object: 1 year from discovery OR 2 years from occurrence, whichever is later',
        'foreign_object_exception', 'Foreign object left in body: 1 year from discovery of object',
        'minor_exception', 'Minors: SOL generally extends to 2 years after reaching majority (age 18)',
        'tolling', jsonb_build_array(
            'Fraudulent concealment by provider tolls SOL',
            'Foreign object discovery rule applies',
            'Mental incapacity may toll SOL'
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('Idaho Code § 5-219', 'Justia Idaho 2024'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 5: MODIFIED COMPARATIVE FAULT (50% BAR)
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, specialization, document_type,
    jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status,
    is_active, is_template, created_at, updated_at
)
VALUES (
    'ID-MED-MAL-MODIFIED-COMPARATIVE', 5,
    'ID Medical Malpractice: Modified Comparative Fault 50% Bar (Idaho Code § 6-801)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'ID',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'contextual_rule',
        'statute', 'Idaho Code § 6-801',
        'negligence_model', 'modified_comparative',
        'bar_threshold', '50%',
        'rule_description', 'Plaintiff may recover if contributory negligence does not exceed 50%; damages reduced by plaintiff fault percentage',
        'complete_bar', 'Yes — plaintiff barred if more than 50% at fault',
        'joint_several', 'Idaho modified several liability; each defendant responsible only for their proportionate share',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('Idaho Code § 6-801', 'Expertise.com Idaho 2024'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();
