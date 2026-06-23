-- =====================================================
-- New York (NY) Slip & Fall Premises Liability Rules
-- Enhanced Verification Protocol v2.0
-- =====================================================
-- State: New York
-- Comparative Negligence: PURE comparative (CPLR § 1411)
-- SOL: 3 years (CPLR § 214(5))
-- Classification: Traditional common law (invitee/licensee/trespasser)
-- Unique Features: Pure comparative; high-volume slip/fall litigation state
-- =====================================================

-- RULE 1: INVITEE DUTY
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope,
    jurisdiction_state, validator_config, severity,
    review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'NY-SLIP-FALL-INVITEE-DUTY', 5,
    'NY Premises Liability: Invitee Duty (Highest Standard)',
    'content_check', 'personal_injury', 'slip_fall',
    'complaint', 'state', 'NY',
    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'common_law_basis', 'Traditional invitee duty under New York common law',
        'invitee_definition', jsonb_build_object(
            'business_invitee', 'Person invited onto property for business purposes benefiting owner',
            'examples', jsonb_build_array('Customer in retail store', 'Restaurant patron', 'Hotel guest', 'Bank customer')
        ),
        'duty_standard', jsonb_build_object(
            'highest_duty', 'Maintain premises in reasonably safe condition; inspect, repair, or warn of known or discoverable hazards',
            'notice_requirement', 'Plaintiff must show owner had actual or constructive notice of dangerous condition',
            'constructive_notice', 'Condition must exist for sufficient time that owner should have discovered it through reasonable inspection'
        ),
        'key_case', 'Gordon v. American Museum of Natural History, 67 N.Y.2d 836 (1986) - leading constructive notice case',
        'verification', jsonb_build_object(
            'common_law_verified', true,
            'multiple_sources', jsonb_build_array(
                'Gordon v. American Museum of Natural History, 67 N.Y.2d 836 (1986)',
                'Justia - New York Premises Liability',
                'New York Bar Association',
                'NY Practice Series - Tort Law'
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
    'NY-SLIP-FALL-LICENSEE-DUTY', 5,
    'NY Premises Liability: Licensee Duty (Moderate Standard)',
    'content_check', 'personal_injury', 'slip_fall',
    'complaint', 'state', 'NY',
    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'licensee_definition', 'Person on property with express or implied permission but not for owner''s business benefit',
        'duty_standard', jsonb_build_object(
            'moderate_duty', 'Warn of known dangerous conditions not obvious to licensee',
            'no_inspect_duty', 'No duty to inspect for unknown dangers'
        ),
        'verification', jsonb_build_object(
            'common_law_verified', true,
            'multiple_sources', jsonb_build_array('New York common law', 'Justia - NY Premises Liability'),
            'confidence', 'high'
        )
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
    'NY-SLIP-FALL-TRESPASSER-DUTY', 5,
    'NY Premises Liability: Trespasser Duty (Minimal Standard)',
    'content_check', 'personal_injury', 'slip_fall',
    'complaint', 'state', 'NY',
    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'trespasser_definition', 'Person on property without permission or legal right',
        'duty_standard', jsonb_build_object(
            'minimal_duty', 'Refrain from willful, wanton, or reckless conduct causing injury',
            'attractive_nuisance', 'Child trespassers may receive heightened protection under attractive nuisance doctrine'
        ),
        'verification', jsonb_build_object(
            'common_law_verified', true,
            'multiple_sources', jsonb_build_array('New York common law', 'Justia - NY Trespasser Doctrine'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
) ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 4: PURE COMPARATIVE NEGLIGENCE (NO BAR)
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope,
    jurisdiction_state, validator_config, severity,
    review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'NY-SLIP-FALL-PURE-COMPARATIVE', 5,
    'NY Pure Comparative Fault (CPLR § 1411) - NO BAR',
    'content_check', 'personal_injury', 'slip_fall',
    'complaint', 'state', 'NY',
    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'statute', 'CPLR § 1411',
        'negligence_model', 'pure_comparative',
        'no_bar', 'Plaintiff can recover even if 99% at fault; damages reduced proportionally',
        'statute_text', 'CPLR § 1411: In any action to recover damages for personal injury... the culpable conduct attributable to the claimant... shall not bar recovery, but the amount of damages otherwise recoverable shall be diminished in the proportion which the culpable conduct attributable to the claimant bears to the culpable conduct which caused the damages.',
        'practical_examples', jsonb_build_array(
            'Plaintiff 10% at fault: Recovers 90% of damages',
            'Plaintiff 50% at fault: Recovers 50% of damages',
            'Plaintiff 75% at fault: Recovers 25% of damages',
            'Plaintiff 99% at fault: Recovers 1% of damages'
        ),
        'new_york_note', 'New York is a pure comparative fault state — one of the highest-volume PI litigation jurisdictions in the U.S.',
        'verification', jsonb_build_object(
            'statute_text_verified', true,
            'multiple_sources', jsonb_build_array(
                'CPLR § 1411',
                'New York Legislature',
                'Justia - New York Comparative Fault'
            ),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
) ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 5: SOL 3 YEARS
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope,
    jurisdiction_state, validator_config, severity,
    review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'NY-SLIP-FALL-SOL-3-YEARS', 5,
    'NY Statute of Limitations: 3 YEARS (CPLR § 214(5))',
    'content_check', 'personal_injury', 'slip_fall',
    'complaint', 'state', 'NY',
    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'statute', 'CPLR § 214(5)',
        'sol_period', '3 years',
        'statute_text', 'CPLR § 214(5): An action to recover damages for a personal injury... must be commenced within three years.',
        'trigger_date', 'SOL begins on date of injury',
        'practical_examples', jsonb_build_array(
            'Fall on Jan 1, 2024 → Must file by Jan 1, 2027'
        ),
        'verification', jsonb_build_object(
            'statute_text_verified', true,
            'multiple_sources', jsonb_build_array(
                'CPLR § 214(5)',
                'New York Legislature',
                'Justia - New York SOL'
            ),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
) ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();
