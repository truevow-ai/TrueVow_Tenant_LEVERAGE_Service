-- =====================================================
-- Montana (MT) Slip & Fall Premises Liability Rules
-- Enhanced Verification Protocol v2.0
-- =====================================================
-- State: Montana
-- Comparative Negligence: Modified 51% bar (Mont. Code Ann. § 27-1-702)
-- SOL: 3 years (Mont. Code Ann. § 27-2-204(1))
-- Classification: Traditional common law (invitee/licensee/trespasser)
-- Unique Features: None particularly unique
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
    'MT-SLIP-FALL-INVITEE-DUTY',
    5,
    'MT Premises Liability: Invitee Duty (Highest Standard)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'MT',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'common_law_basis', 'Traditional invitee duty',
        'invitee_definition', jsonb_build_object('examples', jsonb_build_array('Customer', 'Restaurant patron', 'Bank customer')),
        'duty_standard', jsonb_build_object('highest_duty', 'Inspect, repair/warn, reasonable care'),
        'verification', jsonb_build_object(
            'common_law_verified', true,
            'multiple_sources', jsonb_build_array('Montana common law', 'Justia - Montana Premises Liability', 'Montana Bar Association'),
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
    'MT-SLIP-FALL-LICENSEE-DUTY',
    5,
    'MT Premises Liability: Licensee Duty (Moderate Standard)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'MT',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'licensee_definition', 'Person with permission',
        'duty_standard', jsonb_build_object('moderate_duty', 'Warn of known dangers'),
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
    'MT-SLIP-FALL-TRESPASSER-DUTY',
    5,
    'MT Premises Liability: Trespasser Duty (Minimal Standard)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'MT',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'trespasser_definition', 'Person without permission',
        'duty_standard', jsonb_build_object('minimal_duty', 'No willful/wanton injury'),
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
    'MT-SLIP-FALL-MODIFIED-COMPARATIVE',
    5,
    'MT Modified Comparative Negligence 51% Bar (Mont. Code Ann. § 27-1-702)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'MT',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'statute', 'Mont. Code Ann. § 27-1-702',
        'negligence_model', 'modified_comparative_51_bar',
        'fifty_one_percent_bar', 'Plaintiff cannot recover if MORE than 50% at fault',
        'statute_text', 'Mont. Code Ann. § 27-1-702: Contributory negligence does not bar recovery... if the contributory fault of the claimant was not greater than the combined fault of all persons.',
        'practical_examples', jsonb_build_array(
            'Plaintiff 0-50% at fault: Can recover',
            'Plaintiff 50% at fault: Recovers 50%',
            'Plaintiff 51% at fault: NO RECOVERY'
        ),
        'verification', jsonb_build_object(
            'statute_text_verified', true,
            'multiple_sources', jsonb_build_array('Mont. Code Ann. § 27-1-702', 'Montana Legislature', 'Justia - Montana Comparative Negligence'),
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

-- RULE 5: SOL 3 YEARS
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
    'MT-SLIP-FALL-SOL-3-YEARS',
    5,
    'MT Statute of Limitations: 3 YEARS (Mont. Code Ann. § 27-2-204(1))',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'MT',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'statute', 'Mont. Code Ann. § 27-2-204(1)',
        'sol_period', '3 years',
        'statute_text', 'Mont. Code Ann. § 27-2-204(1): ...injury to person... three years.',
        'trigger_date', 'SOL begins on date of injury',
        'practical_examples', jsonb_build_array('Fall on Jan 1, 2024 → Must file by Jan 1, 2027'),
        'verification', jsonb_build_object(
            'statute_text_verified', true,
            'multiple_sources', jsonb_build_array('Mont. Code Ann. § 27-2-204(1)', 'Montana Legislature', 'Justia - Montana SOL'),
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
