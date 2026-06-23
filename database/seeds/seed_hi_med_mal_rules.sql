-- =====================================================
-- Hawaii (HI) Medical Malpractice Rules
-- Enhanced Verification Protocol v2.0
-- =====================================================
-- State: Hawaii
-- Governing Law: HRS Chapter 671 (Medical Tort Reform Act)
-- Negligence Model: MODIFIED COMPARATIVE (50% bar) — HRS § 663-31
-- SOL: 2 years discovery rule; 6-year statute of repose (HRS § 657-7.3)
-- Damage Caps: Non-economic cap $375,000 (HRS § 663-8.7); economic uncapped
-- Expert: Required testimony; no separate certificate statute
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
    'HI-MED-MAL-STANDARD-OF-CARE', 5,
    'HI Medical Malpractice: Standard of Care (HRS § 671-3)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'HI',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'contextual_rule',
        'statute', 'HRS § 671-3',
        'standard_text', 'A healthcare provider shall exercise that degree of care, skill, and treatment which, in light of all relevant surrounding circumstances, is recognized as acceptable and appropriate by reasonably prudent similar health care providers',
        'key_elements', jsonb_build_array(
            'Duty: provider-patient relationship established',
            'Breach: failure to meet reasonably prudent similar provider standard',
            'Causation: breach proximately caused plaintiff injury',
            'Damages: actual injury/harm resulted'
        ),
        'locality_rule', 'Hawaii applies a statewide standard — not a strict locality rule',
        'res_ipsa', 'Doctrine of res ipsa loquitur available; HRS § 671-3(b) allows inference of negligence',
        'informed_consent', 'Separate theory; provider must disclose material information a reasonable patient would want',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('HRS § 671-3', 'Hawaii Medical Tort Reform Act', 'Justia Hawaii'),
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
    'HI-MED-MAL-EXPERT-WITNESS', 5,
    'HI Medical Malpractice: Expert Witness Requirements (HRS § 671-3)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'HI',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'contextual_rule',
        'statute', 'HRS § 671-3',
        'requirement', 'Expert witness required to establish standard of care and breach',
        'qualifications', jsonb_build_array(
            'Must be licensed healthcare provider in same or similar specialty',
            'Must have familiarity with standard of care applicable in Hawaii',
            'No statutory pre-filing certificate or affidavit requirement in Hawaii',
            'Expert opinion essential for prima facie case'
        ),
        'no_certificate_required', 'Hawaii does not mandate a pre-filing certificate of merit or expert affidavit',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('HRS § 671-3', 'Hawaii case law on expert testimony'),
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
    'HI-MED-MAL-DAMAGE-CAPS', 5,
    'HI Medical Malpractice: Non-Economic Damage Cap $375,000 (HRS § 663-8.7)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'HI',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'hard_rule',
        'statute', 'HRS § 663-8.7',
        'non_economic_cap', '$375,000 per occurrence',
        'economic_damages', 'No cap on economic damages (medical expenses, lost wages, future care)',
        'punitive_damages', 'Punitive damages available under HRS § 663-10.9 for reckless or intentional conduct',
        'cap_notes', jsonb_build_array(
            'Cap applies to non-economic damages: pain, suffering, loss of consortium, emotional distress',
            'Cap applies regardless of number of defendants',
            'Economic damages fully recoverable without limit',
            'Cap has not been struck down constitutionally in Hawaii'
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('HRS § 663-8.7', 'Hawaii Medical Tort Reform Act', 'Rosenfeld Injury Lawyers state guide'),
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
    'HI-MED-MAL-SOL-2-YEARS', 5,
    'HI Medical Malpractice: 2-Year SOL, 6-Year Repose (HRS § 657-7.3)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'HI',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'hard_rule',
        'statute', 'HRS § 657-7.3',
        'sol_period', '2 years from date of discovery of injury',
        'repose_period', '6 years from date of negligent act or omission',
        'discovery_rule', 'Clock starts when plaintiff discovers or should have discovered injury and its causal link',
        'minor_exception', 'For minors: 6 years from wrongful act OR until 10th birthday, whichever is longer',
        'tolling', jsonb_build_array(
            'Tolled for fraudulent concealment by provider',
            'Tolled if provider fails to disclose material information',
            'Tolled if parent/guardian acts with fraud or gross negligence'
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('HRS § 657-7.3', 'Justia Hawaii 2024'),
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
    'HI-MED-MAL-MODIFIED-COMPARATIVE', 5,
    'HI Medical Malpractice: Modified Comparative Fault 50% Bar (HRS § 663-31)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'HI',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'contextual_rule',
        'statute', 'HRS § 663-31',
        'negligence_model', 'modified_comparative',
        'bar_threshold', '50%',
        'rule_description', 'Plaintiff may recover if their fault does not exceed 50%; damages reduced proportionally by plaintiff fault percentage',
        'complete_bar', 'Yes — plaintiff barred if found more than 50% at fault',
        'joint_several', 'Hawaii follows modified joint and several liability; defendant 25%+ at fault liable for full economic damages',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('HRS § 663-31', 'Nolo Hawaii Personal Injury Laws'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();
