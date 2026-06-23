-- =====================================================
-- North Dakota (ND) Medical Malpractice Rules
-- Enhanced Verification Protocol v2.0
-- =====================================================
-- State: North Dakota
-- Governing Law: NDCC Chapter 28-01.1, Chapter 32-42
-- Negligence Model: MODIFIED COMPARATIVE (50% bar) — NDCC § 32-03.2-02
-- SOL: 2 years from discovery; 6-year repose (NDCC § 28-01-18)
-- Damage Caps: Non-economic cap $500,000 (NDCC § 32-42-02); economic uncapped
-- Expert: Affidavit of expert opinion required within 3 months of service
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
    'ND-MED-MAL-STANDARD-OF-CARE', 5,
    'ND Medical Malpractice: Standard of Care (NDCC § 28-01.1-02)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'ND',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'contextual_rule',
        'statute', 'NDCC § 28-01.1-02',
        'standard_text', 'A health care provider is liable for personal injury or wrongful death if the patient or the patient''s representative establishes by competent evidence that the health care provider has failed to comply with the applicable standard of care and that the act of noncompliance was a proximate cause of the claimant''s harm',
        'key_elements', jsonb_build_array(
            'Duty: provider-patient relationship must be established',
            'Breach: failure to comply with applicable standard of care',
            'Causation: breach was proximate cause of plaintiff''s harm',
            'Damages: actual harm resulted'
        ),
        'causation_standard', 'Proximate cause; "but for" test applies in most cases',
        'informed_consent', 'Separate theory under NDCC § 23-12-13; provider must obtain informed consent and disclose material risks',
        'res_ipsa', 'Available in appropriate cases; recognized by ND courts',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('NDCC § 28-01.1-02', 'NDCC § 23-12-13', 'Justia North Dakota'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 2: EXPERT AFFIDAVIT REQUIREMENT
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, specialization, document_type,
    jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status,
    is_active, is_template, created_at, updated_at
)
VALUES (
    'ND-MED-MAL-EXPERT-AFFIDAVIT', 5,
    'ND Medical Malpractice: Expert Affidavit Requirement (NDCC § 28-01.1-04)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'ND',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'filing_requirement',
        'statute', 'NDCC § 28-01.1-04',
        'requirement', 'Plaintiff must serve upon each defendant an affidavit containing the expert''s qualifications and a statement of the acts or omissions alleged to constitute negligence and the reasons why they constitute a departure from the applicable standard of care',
        'deadline', 'Within 3 months after service of the complaint on the defendant; court may extend for good cause',
        'affidavit_contents', jsonb_build_array(
            'Expert''s qualifications and relevant experience',
            'Specific acts or omissions alleged to constitute negligence',
            'Explanation of why acts constitute departure from standard of care',
            'Statement of causal connection between negligence and claimed damages'
        ),
        'qualified_expert', jsonb_build_object(
            'same_specialty', 'Must be knowledgeable about the applicable standard of care',
            'active_clinical_practice', 'Must have been in active clinical practice within the past 5 years'
        ),
        'failure_consequence', 'Court may dismiss action for failure to timely serve affidavit',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('NDCC § 28-01.1-04', 'NDCC § 28-01.1-02', 'Justia North Dakota'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 3: NON-ECONOMIC DAMAGE CAP
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, specialization, document_type,
    jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status,
    is_active, is_template, created_at, updated_at
)
VALUES (
    'ND-MED-MAL-DAMAGE-CAP', 5,
    'ND Medical Malpractice: Non-Economic Damage Cap $500,000 (NDCC § 32-42-02)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'ND',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'damages_rule',
        'statute', 'NDCC § 32-42-02',
        'caps_apply', true,
        'non_economic_cap', 500000,
        'annual_adjustment', false,
        'cap_notes', 'Cap of $500,000 on non-economic damages (pain, suffering, mental anguish, inconvenience, physical impairment) in medical malpractice claims; applies per occurrence regardless of number of defendants or plaintiffs',
        'economic_damages', 'No cap — medical expenses, lost wages, future economic losses fully recoverable',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('NDCC § 32-42-02', 'AllLaw North Dakota', 'NCSL medical malpractice summary'),
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
    'ND-MED-MAL-SOL-2-YEARS', 5,
    'ND Medical Malpractice: Statute of Limitations 2 Years (NDCC § 28-01-18)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'ND',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'timeliness_rule',
        'statute', 'NDCC § 28-01-18',
        'sol_period', '2 years',
        'trigger', 'Date the claimant discovered or reasonably should have discovered the injury and its cause',
        'discovery_rule', true,
        'repose_period', '6 years from the act or omission (absolute bar)',
        'minor_rule', 'For claims involving minors, the 2-year period does not begin until the minor reaches age 18, subject to the 12-year outer limit from the act',
        'foreign_object', 'Discovery rule applies; SOL runs from date foreign object reasonably discovered',
        'wrongful_death', '2 years from date of death (NDCC § 28-01-18)',
        'tolling', jsonb_build_array(
            'Legal disability (minority as specified, incompetency)',
            'Fraudulent concealment by defendant'
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('NDCC § 28-01-18', 'Nolo North Dakota guide', 'Justia North Dakota'),
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
    'ND-MED-MAL-MODIFIED-COMPARATIVE', 5,
    'ND Medical Malpractice: Modified Comparative Fault 50% Bar (NDCC § 32-03.2-02)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'ND',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'negligence_model',
        'statute', 'NDCC § 32-03.2-02',
        'negligence_model', 'modified_comparative',
        'complete_bar', true,
        'bar_threshold', '50%',
        'rule_description', 'North Dakota follows modified comparative fault with a 50% bar — plaintiff may recover only if their fault is 50% or less; if plaintiff is more than 50% at fault, recovery is completely barred',
        'damages_reduction', 'If plaintiff is 50% or less at fault, damages are reduced proportionally by plaintiff''s percentage of fault',
        'joint_several_liability', 'North Dakota applies proportionate several liability; each defendant is liable only for their proportionate share of damages',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('NDCC § 32-03.2-02', 'NCSL summary', 'Justia North Dakota'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();
