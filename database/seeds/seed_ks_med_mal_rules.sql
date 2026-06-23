-- =====================================================
-- Kansas (KS) Medical Malpractice Rules
-- Enhanced Verification Protocol v2.0
-- =====================================================
-- State: Kansas
-- Governing Law: K.S.A. Chapter 60 (Civil Procedure)
-- Negligence Model: MODIFIED COMPARATIVE (50% bar) — K.S.A. § 60-258a
-- SOL: 2 years from discovery; 4-year repose (K.S.A. § 60-513)
-- Damage Caps: Non-economic cap evolving post-Hilburn; ~$350k for claims after 2022 (K.S.A. § 60-19a02)
-- Expert: Expert certificate required pre-filing
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
    'KS-MED-MAL-STANDARD-OF-CARE', 5,
    'KS Medical Malpractice: Standard of Care (K.S.A. § 60-3401)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'KS',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'contextual_rule',
        'statute', 'K.S.A. § 60-3401',
        'standard_text', 'Healthcare provider must exercise the degree of learning and skill ordinarily possessed and exercised by members of their profession in good standing in similar communities under similar circumstances',
        'key_elements', jsonb_build_array(
            'Duty: provider-patient relationship',
            'Breach: failure to meet applicable standard of care',
            'Causation: breach proximately caused injury',
            'Damages: actual injury resulted'
        ),
        'locality_rule', 'Kansas applies a similar community standard; locality rule considered',
        'informed_consent', 'Separate theory; reasonable patient standard applies',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('K.S.A. § 60-3401', 'Kansas Medical Malpractice Laws — Expertise.com 2024'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 2: EXPERT CERTIFICATE REQUIREMENT
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, specialization, document_type,
    jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status,
    is_active, is_template, created_at, updated_at
)
VALUES (
    'KS-MED-MAL-EXPERT-CERTIFICATE', 5,
    'KS Medical Malpractice: Expert Certificate Required (K.S.A. § 60-3412)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'KS',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'hard_rule',
        'statute', 'K.S.A. § 60-3412',
        'requirement', 'Plaintiff must file a certificate signed by a qualified expert stating there is a reasonable basis for the claim',
        'qualifications', jsonb_build_array(
            'Expert must be licensed healthcare provider in same or substantially similar specialty',
            'Must have knowledge of applicable standard of care',
            'Must state there is reasonable basis for claim of negligence',
            'Certificate must be filed with or soon after the complaint'
        ),
        'consequence_of_failure', 'Failure to file certificate may result in dismissal',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('K.S.A. § 60-3412', 'Prochaska Howell Kansas Med Mal 2025'),
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
    'KS-MED-MAL-DAMAGE-CAPS', 5,
    'KS Medical Malpractice: Non-Economic Damage Cap Post-Hilburn (K.S.A. § 60-19a02)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'KS',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'hard_rule',
        'statute', 'K.S.A. § 60-19a02',
        'non_economic_cap_current', 'Approximately $350,000 for claims filed after 2022 (cap restored by legislature after Hilburn)',
        'economic_damages', 'No cap on economic damages (medical expenses, lost wages, future care)',
        'hilburn_case', 'Hilburn v. Enerpipe Ltd., 309 Kan. 225 (2019) — Kansas Supreme Court struck general personal injury non-economic cap as unconstitutional',
        'medical_malpractice_cap_status', 'Legislature restored medical malpractice specific cap post-Hilburn via K.S.A. § 60-19a02 amendment',
        'cap_notes', jsonb_build_array(
            'General personal injury non-economic cap struck in Hilburn (2019)',
            'Medical malpractice specific cap reinstated by amendment for claims after 2022',
            'Wrongful death non-economic cap: $250,000 (K.S.A. § 60-1903)',
            'Confirm current cap amount with updated Kansas statutes'
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('K.S.A. § 60-19a02', 'Hilburn v. Enerpipe Ltd. 309 Kan. 225 (2019)', 'Lawshun.com Kansas Med Mal 2025'),
            'confidence', 'medium'
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
    'KS-MED-MAL-SOL-2-YEARS', 5,
    'KS Medical Malpractice: 2-Year SOL, 4-Year Repose (K.S.A. § 60-513)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'KS',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'hard_rule',
        'statute', 'K.S.A. § 60-513',
        'sol_period', '2 years from date of discovery or when injury should have been discovered',
        'repose_period', '4 years from date of negligent act — absolute bar',
        'discovery_rule', 'SOL runs from date plaintiff knew or should have known of injury and its causal link',
        'minor_exception', 'Minors: SOL starts at age 18; must file by age 19 or within 1 year, but not to exceed 8 years from incident',
        'tolling', jsonb_build_array(
            'Fraudulent concealment tolls SOL',
            'Discovery rule may extend beyond occurrence date up to repose period',
            'Minor exceptions apply'
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('K.S.A. § 60-513', 'Prochaska Howell Kansas SOL 2025'),
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
    'KS-MED-MAL-MODIFIED-COMPARATIVE', 5,
    'KS Medical Malpractice: Modified Comparative Fault 50% Bar (K.S.A. § 60-258a)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'KS',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'contextual_rule',
        'statute', 'K.S.A. § 60-258a',
        'negligence_model', 'modified_comparative',
        'bar_threshold', '50%',
        'rule_description', 'Plaintiff may recover if fault does not exceed 50%; damages reduced by plaintiff fault percentage',
        'complete_bar', 'Yes — plaintiff barred if found more than 50% at fault',
        'joint_several', 'Kansas proportionate several liability among defendants',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('K.S.A. § 60-258a', 'Expertise.com Kansas 2024'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();
