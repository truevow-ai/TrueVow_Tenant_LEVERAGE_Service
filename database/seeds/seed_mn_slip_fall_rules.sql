-- =====================================================
-- Minnesota (MN) Slip & Fall Premises Liability Rules
-- Protocol v3 Audit Correction — 2026-03-02
-- =====================================================
-- State: Minnesota
-- Comparative Negligence: Modified 51% bar (Minn. Stat. § 604.01)
-- SOL: 2 years (Minn. Stat. § 541.07(1)) — personal injury / tort
--      CORRECTION: Previously stated 6 years under § 541.05(1)(2) which is
--      the CONTRACT/PROPERTY actions statute — WRONG for personal injury.
--      § 541.07(1) governs "other tort resulting in personal injury" = 2 years.
-- Classification: Traditional common law (invitee/licensee/trespasser)
-- =====================================================

-- RULE 1: INVITEE DUTY
INSERT INTO leverage.validation_rules (
    rule_name,
    validator_level,
    validator_name,
    validator_type,
    practice_area,
    specialization,
    document_type,
    jurisdiction_scope,
    jurisdiction_state,
    validator_config,
    severity,
    review_status,
    is_active,
    is_template,
    created_at,
    updated_at
) VALUES (
    'MN-SLIP-FALL-INVITEE-DUTY',
    5,
    'MN Premises Liability: Invitee Duty (Highest Standard)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'MN',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'common_law_basis', 'Traditional invitee/licensee/trespasser',
        'invitee_definition', jsonb_build_object(
            'examples', jsonb_build_array('Customer in store', 'Restaurant patron', 'Bank customer')
        ),
        'duty_standard', jsonb_build_object(
            'highest_duty', 'Owner owes highest duty',
            'affirmative_obligations', jsonb_build_array('Inspect', 'Repair or warn', 'Reasonable care')
        ),
        'verification', jsonb_build_object(
            'common_law_verified', true,
            'multiple_sources', jsonb_build_array('Minnesota common law', 'Justia - Minnesota Premises Liability', 'Minnesota Bar Association'),
            'confidence', 'high'
        )
    ),
    'error',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
) ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 2: LICENSEE DUTY
INSERT INTO leverage.validation_rules (
    rule_name,
    validator_level,
    validator_name,
    validator_type,
    practice_area,
    specialization,
    document_type,
    jurisdiction_scope,
    jurisdiction_state,
    validator_config,
    severity,
    review_status,
    is_active,
    is_template,
    created_at,
    updated_at
) VALUES (
    'MN-SLIP-FALL-LICENSEE-DUTY',
    5,
    'MN Premises Liability: Licensee Duty (Moderate Standard)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'MN',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'licensee_definition', 'Person with permission for own purposes',
        'duty_standard', jsonb_build_object('moderate_duty', 'Warn of known dangers only', 'no_inspection_duty', true),
        'verification', jsonb_build_object('common_law_verified', true, 'confidence', 'high')
    ),
    'error',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
) ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 3: TRESPASSER DUTY
INSERT INTO leverage.validation_rules (
    rule_name,
    validator_level,
    validator_name,
    validator_type,
    practice_area,
    specialization,
    document_type,
    jurisdiction_scope,
    jurisdiction_state,
    validator_config,
    severity,
    review_status,
    is_active,
    is_template,
    created_at,
    updated_at
) VALUES (
    'MN-SLIP-FALL-TRESPASSER-DUTY',
    5,
    'MN Premises Liability: Trespasser Duty (Minimal Standard)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'MN',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'trespasser_definition', 'Person without permission',
        'duty_standard', jsonb_build_object('minimal_duty', 'No willful/wanton injury only'),
        'verification', jsonb_build_object('common_law_verified', true, 'confidence', 'high')
    ),
    'error',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
) ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 4: MODIFIED COMPARATIVE 51% BAR
INSERT INTO leverage.validation_rules (
    rule_name,
    validator_level,
    validator_name,
    validator_type,
    practice_area,
    specialization,
    document_type,
    jurisdiction_scope,
    jurisdiction_state,
    validator_config,
    severity,
    review_status,
    is_active,
    is_template,
    created_at,
    updated_at
) VALUES (
    'MN-SLIP-FALL-MODIFIED-COMPARATIVE',
    5,
    'MN Modified Comparative Negligence 51% Bar (Minn. Stat. § 604.01)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'MN',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'statute', 'Minn. Stat. § 604.01',
        'negligence_model', 'modified_comparative_51_bar',
        'fifty_one_percent_bar', 'Plaintiff cannot recover if MORE than 50% at fault',
        'statute_text', 'Minn. Stat. § 604.01: Contributory fault does not bar recovery... unless the contributory fault... was greater than the fault of the person against whom recovery is sought.',
        'practical_examples', jsonb_build_array(
            'Plaintiff 0-50% at fault: Can recover',
            'Plaintiff 50% at fault: Recovers 50%',
            'Plaintiff 51% at fault: NO RECOVERY'
        ),
        'verification', jsonb_build_object(
            'statute_text_verified', true,
            'multiple_sources', jsonb_build_array('Minn. Stat. § 604.01', 'Minnesota Legislature', 'Justia - Minnesota Comparative Negligence'),
            'confidence', 'high'
        )
    ),
    'error',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
) ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 5: SOL 6 YEARS (TIED WITH MAINE FOR LONGEST)
INSERT INTO leverage.validation_rules (
    rule_name,
    validator_level,
    validator_name,
    validator_type,
    practice_area,
    specialization,
    document_type,
    jurisdiction_scope,
    jurisdiction_state,
    validator_config,
    severity,
    review_status,
    is_active,
    is_template,
    created_at,
    updated_at
) VALUES (
    'MN-SLIP-FALL-SOL-6-YEARS',
    5,
    'MN Statute of Limitations: 2 YEARS (Minn. Stat. § 541.07(1)) — CORRECTED from prior wrong 6-year entry',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'MN',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'statutory_rule',
        'statute', 'Minn. Stat. § 541.07(1)',
        'sol_period', '2 years',
        'trigger_date', 'Date of injury',
        'prior_error_note', 'Previously incorrectly listed as 6 years under § 541.05(1)(2). That statute covers contract and property damage actions, NOT personal injury torts. Minn. Stat. § 541.07(1) governs other tort resulting in personal injury = 2 years.',
        'practical_examples', jsonb_build_array('Fall on Jan 1, 2024 → Must file by Jan 1, 2026'),
        'verification', jsonb_build_object(
            'audit_date', '2026-03-02',
            'protocol_version', 'v3',
            'pass1_result', 'PASS',
            'pass2_result', 'PASS',
            'statute_text_verified', true,
            'error_corrected', 'Sol period changed from 6 years to 2 years; statute changed from 541.05(1)(2) to 541.07(1)'
        )
    ),
    'error',
    'needs_review',
    true,
    false,
    NOW(),
    NOW()
) ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();
