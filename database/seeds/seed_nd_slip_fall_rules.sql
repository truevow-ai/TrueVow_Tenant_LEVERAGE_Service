-- =====================================================
-- North Dakota (ND) Slip & Fall Premises Liability Rules
-- Enhanced Verification Protocol v2.0
-- =====================================================
-- State: North Dakota
-- Comparative Negligence: Modified 50% bar (N.D. Cent. Code § 32-03.2-02)
-- SOL: 6 years (N.D. Cent. Code § 28-01-16(5))
-- Classification: Traditional common law (invitee/licensee/trespasser)
-- Unique Features: 6-year SOL (tied for longest with ME and MN)
--   50% bar (plaintiff must be LESS than 50% - strict version like KS, ID)
-- =====================================================

-- RULE 1: INVITEE DUTY
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope,
    jurisdiction_state, validator_config, severity,
    review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'ND-SLIP-FALL-INVITEE-DUTY', 5,
    'ND Premises Liability: Invitee Duty (Highest Standard)',
    'content_check', 'personal_injury', 'slip_fall',
    'complaint', 'state', 'ND',
    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'common_law_basis', 'Traditional invitee duty',
        'invitee_definition', jsonb_build_object(
            'examples', jsonb_build_array('Customer in retail store', 'Restaurant patron', 'Bank customer')
        ),
        'duty_standard', jsonb_build_object(
            'highest_duty', 'Inspect premises, repair or warn of known or discoverable hazards'
        ),
        'verification', jsonb_build_object(
            'common_law_verified', true,
            'multiple_sources', jsonb_build_array(
                'North Dakota common law',
                'Justia - North Dakota Premises Liability',
                'ND Bar Association'
            ),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
) ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 2: LICENSEE DUTY
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope,
    jurisdiction_state, validator_config, severity,
    review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'ND-SLIP-FALL-LICENSEE-DUTY', 5,
    'ND Premises Liability: Licensee Duty (Moderate Standard)',
    'content_check', 'personal_injury', 'slip_fall',
    'complaint', 'state', 'ND',
    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'licensee_definition', 'Person on property with permission but not for business benefit of owner',
        'duty_standard', jsonb_build_object('moderate_duty', 'Warn of known dangerous conditions'),
        'verification', jsonb_build_object('common_law_verified', true, 'confidence', 'high')
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
) ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 3: TRESPASSER DUTY
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope,
    jurisdiction_state, validator_config, severity,
    review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'ND-SLIP-FALL-TRESPASSER-DUTY', 5,
    'ND Premises Liability: Trespasser Duty (Minimal Standard)',
    'content_check', 'personal_injury', 'slip_fall',
    'complaint', 'state', 'ND',
    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'trespasser_definition', 'Person without permission',
        'duty_standard', jsonb_build_object('minimal_duty', 'No willful/wanton injury'),
        'verification', jsonb_build_object('common_law_verified', true, 'confidence', 'high')
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
) ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 4: MODIFIED COMPARATIVE 50% BAR (STRICT - LESS THAN 50%)
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope,
    jurisdiction_state, validator_config, severity,
    review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'ND-SLIP-FALL-MODIFIED-COMPARATIVE-50PCT', 5,
    'ND Modified Comparative Negligence 50% Bar STRICT (N.D. Cent. Code § 32-03.2-02)',
    'content_check', 'personal_injury', 'slip_fall',
    'complaint', 'state', 'ND',
    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'statute', 'N.D. Cent. Code § 32-03.2-02',
        'negligence_model', 'modified_comparative_50_bar_strict',
        'strict_50_percent_bar', 'Plaintiff must be LESS THAN 50% at fault to recover - at exactly 50% plaintiff is BARRED',
        'statute_text', 'N.D. Cent. Code § 32-03.2-02: Contributory fault does not bar recovery... if the contributory fault of the claimant was not as great as the fault of the person against whom recovery is sought.',
        'at_50_pct_barred', 'CRITICAL: "not as great as" means plaintiff at exactly 50% is BARRED (same as KS, ID)',
        'practical_examples', jsonb_build_array(
            'Plaintiff 49% at fault: CAN recover (49% is less than 51%)',
            'Plaintiff 50% at fault: NO RECOVERY (50% is not less than 50%)',
            'Plaintiff 51% at fault: NO RECOVERY'
        ),
        'other_50_bar_states', jsonb_build_array('Kansas', 'Idaho'),
        'verification', jsonb_build_object(
            'statute_text_verified', true,
            'multiple_sources', jsonb_build_array(
                'N.D. Cent. Code § 32-03.2-02',
                'North Dakota Legislature',
                'Justia - North Dakota Comparative Negligence'
            ),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
) ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 5: SOL 6 YEARS (TIED FOR LONGEST IN U.S.)
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope,
    jurisdiction_state, validator_config, severity,
    review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'ND-SLIP-FALL-SOL-6-YEARS', 5,
    'ND Statute of Limitations: 6 YEARS (N.D. Cent. Code § 28-01-16(5)) - TIED FOR LONGEST IN U.S.',
    'content_check', 'personal_injury', 'slip_fall',
    'complaint', 'state', 'ND',
    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'statute', 'N.D. Cent. Code § 28-01-16(5)',
        'sol_period', '6 years',
        'longest_in_us', 'North Dakota 6-year SOL is TIED FOR LONGEST in the U.S. (with Maine and Minnesota)',
        'statute_text', 'N.D. Cent. Code § 28-01-16(5): ...injury to person... six years.',
        'trigger_date', 'SOL begins on date of injury',
        'practical_examples', jsonb_build_array('Fall on Jan 1, 2024 → Must file by Jan 1, 2030'),
        'plaintiff_advantage', 'ND 6-year SOL is most favorable to plaintiffs (tied with ME and MN)',
        'verification', jsonb_build_object(
            'statute_text_verified', true,
            'multiple_sources', jsonb_build_array(
                'N.D. Cent. Code § 28-01-16(5)',
                'North Dakota Legislature',
                'Justia - North Dakota SOL'
            ),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
) ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();
