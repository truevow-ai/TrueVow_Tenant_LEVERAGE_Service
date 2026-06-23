-- =====================================================
-- Missouri (MO) Slip & Fall Premises Liability Rules
-- Enhanced Verification Protocol v2.0
-- =====================================================
-- State: Missouri
-- Comparative Negligence: PURE comparative (no bar)
-- SOL: 5 years (Mo. Rev. Stat. § 516.120(4))
-- Classification: Traditional common law (invitee/licensee/trespasser)
-- Unique Features: Pure comparative, 5-year SOL (longer than most)
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
    'MO-SLIP-FALL-INVITEE-DUTY',
    5,
    'MO Premises Liability: Invitee Duty (Highest Standard)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'MO',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'common_law_basis', 'Traditional invitee duty',
        'invitee_definition', jsonb_build_object('examples', jsonb_build_array('Customer', 'Restaurant patron', 'Bank customer')),
        'duty_standard', jsonb_build_object('highest_duty', 'Inspect, repair/warn, reasonable care'),
        'verification', jsonb_build_object(
            'common_law_verified', true,
            'multiple_sources', jsonb_build_array('Missouri common law', 'Justia - Missouri Premises Liability', 'Missouri Bar Association'),
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
    'MO-SLIP-FALL-LICENSEE-DUTY',
    5,
    'MO Premises Liability: Licensee Duty (Moderate Standard)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'MO',

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
    'MO-SLIP-FALL-TRESPASSER-DUTY',
    5,
    'MO Premises Liability: Trespasser Duty (Minimal Standard)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'MO',

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
    'MO-SLIP-FALL-PURE-COMPARATIVE',
    5,
    'MO Pure Comparative Fault (Mo. Rev. Stat. § 537.765) - NO BAR',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'MO',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'statute', 'Mo. Rev. Stat. § 537.765',
        'negligence_model', 'pure_comparative',
        'no_bar', 'Plaintiff can recover even if 99% at fault; damages reduced proportionally',
        'statute_text', 'Mo. Rev. Stat. § 537.765: ...the fact that the plaintiff may have been at fault shall not bar a recovery... but the damages allowed shall be diminished in proportion to the amount of fault attributable to the plaintiff.',
        'rule_description', 'Missouri follows PURE comparative fault: plaintiff can recover regardless of fault percentage',
        'practical_examples', jsonb_build_array(
            'Plaintiff 10% at fault: Recovers 90%',
            'Plaintiff 50% at fault: Recovers 50%',
            'Plaintiff 75% at fault: Recovers 25%',
            'Plaintiff 99% at fault: Recovers 1%'
        ),
        'comparative_note', 'Missouri is one of only 13 states with pure comparative fault',
        'verification', jsonb_build_object(
            'statute_text_verified', true,
            'multiple_sources', jsonb_build_array('Mo. Rev. Stat. § 537.765', 'Missouri Legislature', 'Justia - Missouri Comparative Fault'),
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

-- RULE 5: SOL 5 YEARS (LONGER THAN MOST)
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
    'MO-SLIP-FALL-SOL-5-YEARS',
    5,
    'MO Statute of Limitations: 5 YEARS (Mo. Rev. Stat. § 516.120(4)) - LONGER THAN MOST',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'MO',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'statute', 'Mo. Rev. Stat. § 516.120(4)',
        'sol_period', '5 years',
        'longer_than_most', 'Missouri 5-year SOL is LONGER than most states (typical is 2-3 years)',
        'statute_text', 'Mo. Rev. Stat. § 516.120(4): ...personal injuries... within five years.',
        'trigger_date', 'SOL begins on date of injury',
        'practical_examples', jsonb_build_array('Fall on Jan 1, 2024 → Must file by Jan 1, 2029'),
        'plaintiff_advantage', 'Missouri 5-year SOL is more favorable to plaintiffs than most states (only ME and MN have longer at 6 years)',
        'verification', jsonb_build_object(
            'statute_text_verified', true,
            'multiple_sources', jsonb_build_array('Mo. Rev. Stat. § 516.120(4)', 'Missouri Legislature', 'Justia - Missouri SOL'),
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
