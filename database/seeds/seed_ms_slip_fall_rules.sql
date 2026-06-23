-- =====================================================
-- Mississippi (MS) Slip & Fall Premises Liability Rules
-- Enhanced Verification Protocol v2.0
-- =====================================================
-- State: Mississippi
-- Comparative Negligence: PURE comparative (no bar)
-- SOL: 3 years (Miss. Code Ann. § 15-1-49)
-- Classification: Traditional common law (invitee/licensee/trespasser)
-- Unique Features: Pure comparative (one of 13 states)
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
    'MS-SLIP-FALL-INVITEE-DUTY',
    5,
    'MS Premises Liability: Invitee Duty (Highest Standard)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'MS',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'common_law_basis', 'Traditional invitee duty',
        'invitee_definition', jsonb_build_object('examples', jsonb_build_array('Customer', 'Restaurant patron', 'Bank customer')),
        'duty_standard', jsonb_build_object('highest_duty', 'Inspect, repair/warn, reasonable care'),
        'verification', jsonb_build_object(
            'common_law_verified', true,
            'multiple_sources', jsonb_build_array('Mississippi common law', 'Justia - Mississippi Premises Liability', 'Mississippi Bar Association'),
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
    'MS-SLIP-FALL-LICENSEE-DUTY',
    5,
    'MS Premises Liability: Licensee Duty (Moderate Standard)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'MS',

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
    'MS-SLIP-FALL-TRESPASSER-DUTY',
    5,
    'MS Premises Liability: Trespasser Duty (Minimal Standard)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'MS',

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

-- RULE 4: PURE COMPARATIVE NEGLIGENCE (NO BAR)
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
    'MS-SLIP-FALL-PURE-COMPARATIVE',
    5,
    'MS Pure Comparative Negligence (Common Law) - NO BAR',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'MS',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'common_law_basis', 'Mississippi follows pure comparative negligence (common law)',
        'negligence_model', 'pure_comparative',
        'no_bar', 'Plaintiff can recover even if 99% at fault; damages reduced proportionally',
        'rule_description', 'Mississippi follows PURE comparative negligence: plaintiff can recover regardless of fault percentage',
        'practical_examples', jsonb_build_array(
            'Plaintiff 10% at fault: Recovers 90%',
            'Plaintiff 50% at fault: Recovers 50%',
            'Plaintiff 75% at fault: Recovers 25%',
            'Plaintiff 99% at fault: Recovers 1%'
        ),
        'comparative_note', 'Mississippi is one of only 13 states with pure comparative negligence',
        'verification', jsonb_build_object(
            'common_law_verified', true,
            'multiple_sources', jsonb_build_array('Mississippi common law', 'Justia - Mississippi Comparative Negligence', 'Mississippi Bar Association'),
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
    'MS-SLIP-FALL-SOL-3-YEARS',
    5,
    'MS Statute of Limitations: 3 YEARS (Miss. Code Ann. § 15-1-49)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'MS',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'statute', 'Miss. Code Ann. § 15-1-49',
        'sol_period', '3 years',
        'statute_text', 'Miss. Code Ann. § 15-1-49: ...personal injuries... three years.',
        'trigger_date', 'SOL begins on date of injury',
        'practical_examples', jsonb_build_array('Fall on Jan 1, 2024 → Must file by Jan 1, 2027'),
        'verification', jsonb_build_object(
            'statute_text_verified', true,
            'multiple_sources', jsonb_build_array('Miss. Code Ann. § 15-1-49', 'Mississippi Legislature', 'Justia - Mississippi SOL'),
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
