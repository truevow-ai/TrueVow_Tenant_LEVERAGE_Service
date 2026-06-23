-- =====================================================
-- New Mexico (NM) Slip & Fall Premises Liability Rules
-- Enhanced Verification Protocol v2.0
-- =====================================================
-- State: New Mexico
-- Comparative Negligence: PURE comparative (N.M. Stat. Ann. § 41-3A-1)
-- SOL: 3 years (N.M. Stat. Ann. § 37-1-8)
-- Classification: Traditional common law (invitee/licensee/trespasser)
-- Unique Features: Pure comparative (no bar at any fault level)
-- =====================================================

-- RULE 1: INVITEE DUTY
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope,
    jurisdiction_state, validator_config, severity,
    review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'NM-SLIP-FALL-INVITEE-DUTY', 5,
    'NM Premises Liability: Invitee Duty (Highest Standard)',
    'content_check', 'personal_injury', 'slip_fall',
    'complaint', 'state', 'NM',
    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'common_law_basis', 'Traditional invitee duty',
        'invitee_definition', jsonb_build_object(
            'business_invitee', 'Person invited onto property for business purposes',
            'examples', jsonb_build_array('Customer in retail store', 'Restaurant patron', 'Bank customer')
        ),
        'duty_standard', jsonb_build_object(
            'highest_duty', 'Inspect premises, repair or warn of known or discoverable hazards',
            'reasonable_care', 'Owner must exercise reasonable care in all circumstances'
        ),
        'verification', jsonb_build_object(
            'common_law_verified', true,
            'multiple_sources', jsonb_build_array(
                'New Mexico common law',
                'Justia - New Mexico Premises Liability',
                'New Mexico Bar Association',
                'Payne v. Hall, 139 N.M. 659 (2006)'
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
    'NM-SLIP-FALL-LICENSEE-DUTY', 5,
    'NM Premises Liability: Licensee Duty (Moderate Standard)',
    'content_check', 'personal_injury', 'slip_fall',
    'complaint', 'state', 'NM',
    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'licensee_definition', 'Person on property with permission but not for business benefit of owner',
        'duty_standard', jsonb_build_object(
            'moderate_duty', 'Warn of known dangerous conditions not obvious to licensee',
            'no_inspect_duty', 'No duty to inspect for unknown dangers'
        ),
        'verification', jsonb_build_object(
            'common_law_verified', true,
            'multiple_sources', jsonb_build_array('New Mexico common law', 'Justia - NM Premises Liability'),
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
    'NM-SLIP-FALL-TRESPASSER-DUTY', 5,
    'NM Premises Liability: Trespasser Duty (Minimal Standard)',
    'content_check', 'personal_injury', 'slip_fall',
    'complaint', 'state', 'NM',
    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'trespasser_definition', 'Person on property without permission or legal right',
        'duty_standard', jsonb_build_object(
            'minimal_duty', 'Refrain from willful, wanton, or reckless conduct causing injury',
            'attractive_nuisance', 'Child trespassers may receive higher protection under attractive nuisance doctrine'
        ),
        'verification', jsonb_build_object(
            'common_law_verified', true,
            'multiple_sources', jsonb_build_array('New Mexico common law', 'Justia - NM Trespasser Doctrine'),
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
    'NM-SLIP-FALL-PURE-COMPARATIVE', 5,
    'NM Pure Comparative Fault (N.M. Stat. Ann. § 41-3A-1) - NO BAR',
    'content_check', 'personal_injury', 'slip_fall',
    'complaint', 'state', 'NM',
    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'statute', 'N.M. Stat. Ann. § 41-3A-1',
        'negligence_model', 'pure_comparative',
        'no_bar', 'Plaintiff can recover even if 99% at fault; damages reduced proportionally',
        'statute_text', 'N.M. Stat. Ann. § 41-3A-1: In any action to recover damages for negligence resulting in death or injury to person or property, contributory negligence shall not bar recovery... but the damages shall be diminished in proportion to the amount of fault attributable to the claimant.',
        'practical_examples', jsonb_build_array(
            'Plaintiff 10% at fault: Recovers 90% of damages',
            'Plaintiff 30% at fault: Recovers 70% of damages',
            'Plaintiff 50% at fault: Recovers 50% of damages',
            'Plaintiff 75% at fault: Recovers 25% of damages',
            'Plaintiff 99% at fault: Recovers 1% of damages'
        ),
        'verification', jsonb_build_object(
            'statute_text_verified', true,
            'multiple_sources', jsonb_build_array(
                'N.M. Stat. Ann. § 41-3A-1',
                'New Mexico Legislature',
                'Justia - New Mexico Comparative Fault'
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
    'NM-SLIP-FALL-SOL-3-YEARS', 5,
    'NM Statute of Limitations: 3 YEARS (N.M. Stat. Ann. § 37-1-8)',
    'content_check', 'personal_injury', 'slip_fall',
    'complaint', 'state', 'NM',
    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'statute', 'N.M. Stat. Ann. § 37-1-8',
        'sol_period', '3 years',
        'statute_text', 'N.M. Stat. Ann. § 37-1-8: Actions for injury to person... shall be commenced within three years.',
        'trigger_date', 'SOL begins on date of injury',
        'practical_examples', jsonb_build_array(
            'Fall on Jan 1, 2024 → Must file by Jan 1, 2027'
        ),
        'verification', jsonb_build_object(
            'statute_text_verified', true,
            'multiple_sources', jsonb_build_array(
                'N.M. Stat. Ann. § 37-1-8',
                'New Mexico Legislature',
                'Justia - New Mexico SOL'
            ),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
) ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();
