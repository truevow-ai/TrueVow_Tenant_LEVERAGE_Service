-- =====================================================
-- Oklahoma (OK) Slip & Fall Premises Liability Rules
-- Enhanced Verification Protocol v2.0
-- =====================================================
-- State: Oklahoma
-- Comparative Negligence: Modified 51% bar (Okla. Stat. tit. 23, § 13)
-- SOL: 2 years (Okla. Stat. tit. 12, § 95(A)(3))
-- Classification: Traditional common law (invitee/licensee/trespasser)
-- =====================================================

-- RULE 1: INVITEE DUTY
INSERT INTO leverage.validation_rules (rule_name, validator_level, validator_name, validator_type, practice_area, specialization, document_type, jurisdiction_scope, jurisdiction_state, validator_config, severity, review_status, is_active, is_template, created_at, updated_at)
VALUES ('OK-SLIP-FALL-INVITEE-DUTY', 5, 'OK Premises Liability: Invitee Duty (Highest Standard)', 'content_check', 'personal_injury', 'slip_fall', 'complaint', 'state', 'OK',
    jsonb_build_object('sub_specialization_type', 'premises_liability', 'authority_level', 'contextual_rule', 'common_law_basis', 'Traditional invitee duty', 'invitee_definition', jsonb_build_object('examples', jsonb_build_array('Customer in retail store', 'Restaurant patron', 'Bank customer')), 'duty_standard', jsonb_build_object('highest_duty', 'Inspect premises, repair or warn of known or discoverable hazards', 'notice_requirement', 'Owner must have actual or constructive notice of dangerous condition'), 'verification', jsonb_build_object('common_law_verified', true, 'multiple_sources', jsonb_build_array('Oklahoma common law', 'Justia - Oklahoma Premises Liability', 'Oklahoma Bar Association'), 'confidence', 'high')),
    'error', 'document_verified', true, false, NOW(), NOW())
ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 2: LICENSEE DUTY
INSERT INTO leverage.validation_rules (rule_name, validator_level, validator_name, validator_type, practice_area, specialization, document_type, jurisdiction_scope, jurisdiction_state, validator_config, severity, review_status, is_active, is_template, created_at, updated_at)
VALUES ('OK-SLIP-FALL-LICENSEE-DUTY', 5, 'OK Premises Liability: Licensee Duty (Moderate Standard)', 'content_check', 'personal_injury', 'slip_fall', 'complaint', 'state', 'OK',
    jsonb_build_object('sub_specialization_type', 'premises_liability', 'licensee_definition', 'Person on property with permission but not for business benefit of owner', 'duty_standard', jsonb_build_object('moderate_duty', 'Warn of known dangerous conditions not obvious to licensee'), 'verification', jsonb_build_object('common_law_verified', true, 'confidence', 'high')),
    'error', 'document_verified', true, false, NOW(), NOW())
ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 3: TRESPASSER DUTY
INSERT INTO leverage.validation_rules (rule_name, validator_level, validator_name, validator_type, practice_area, specialization, document_type, jurisdiction_scope, jurisdiction_state, validator_config, severity, review_status, is_active, is_template, created_at, updated_at)
VALUES ('OK-SLIP-FALL-TRESPASSER-DUTY', 5, 'OK Premises Liability: Trespasser Duty (Minimal Standard)', 'content_check', 'personal_injury', 'slip_fall', 'complaint', 'state', 'OK',
    jsonb_build_object('sub_specialization_type', 'premises_liability', 'trespasser_definition', 'Person without permission or legal right', 'duty_standard', jsonb_build_object('minimal_duty', 'Refrain from willful, wanton, or reckless conduct causing injury'), 'verification', jsonb_build_object('common_law_verified', true, 'confidence', 'high')),
    'error', 'document_verified', true, false, NOW(), NOW())
ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 4: MODIFIED COMPARATIVE 51% BAR
INSERT INTO leverage.validation_rules (rule_name, validator_level, validator_name, validator_type, practice_area, specialization, document_type, jurisdiction_scope, jurisdiction_state, validator_config, severity, review_status, is_active, is_template, created_at, updated_at)
VALUES ('OK-SLIP-FALL-MODIFIED-COMPARATIVE', 5, 'OK Modified Comparative Negligence 51% Bar (Okla. Stat. tit. 23, § 13)', 'content_check', 'personal_injury', 'slip_fall', 'complaint', 'state', 'OK',
    jsonb_build_object('sub_specialization_type', 'premises_liability', 'authority_level', 'contextual_rule', 'statute', 'Okla. Stat. tit. 23, § 13', 'negligence_model', 'modified_comparative_51_bar', 'fifty_one_percent_bar', 'Plaintiff cannot recover if MORE than 50% at fault', 'statute_text', 'Okla. Stat. tit. 23, § 13: Contributory negligence shall not bar a recovery... if the negligence of the person injured... was not greater than the combined negligence of all persons against whom recovery is sought.', 'practical_examples', jsonb_build_array('Plaintiff 0-50% at fault: Can recover', 'Plaintiff 50%: Recovers 50%', 'Plaintiff 51%: NO RECOVERY'), 'verification', jsonb_build_object('statute_text_verified', true, 'multiple_sources', jsonb_build_array('Okla. Stat. tit. 23, § 13', 'Oklahoma Legislature', 'Justia - Oklahoma Comparative Negligence'), 'confidence', 'high')),
    'error', 'document_verified', true, false, NOW(), NOW())
ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 5: SOL 2 YEARS
INSERT INTO leverage.validation_rules (rule_name, validator_level, validator_name, validator_type, practice_area, specialization, document_type, jurisdiction_scope, jurisdiction_state, validator_config, severity, review_status, is_active, is_template, created_at, updated_at)
VALUES ('OK-SLIP-FALL-SOL-2-YEARS', 5, 'OK Statute of Limitations: 2 YEARS (Okla. Stat. tit. 12, § 95(A)(3))', 'content_check', 'personal_injury', 'slip_fall', 'complaint', 'state', 'OK',
    jsonb_build_object('sub_specialization_type', 'premises_liability', 'authority_level', 'contextual_rule', 'statute', 'Okla. Stat. tit. 12, § 95(A)(3)', 'sol_period', '2 years', 'statute_text', 'Okla. Stat. tit. 12, § 95(A)(3): Civil actions other than for the recovery of real property can only be brought within the following periods... Within two years: An action for injury to the rights of another, not arising on contract, and not hereinafter enumerated.', 'trigger_date', 'SOL begins on date of injury', 'practical_examples', jsonb_build_array('Fall on Jan 1, 2024 → Must file by Jan 1, 2026'), 'verification', jsonb_build_object('statute_text_verified', true, 'multiple_sources', jsonb_build_array('Okla. Stat. tit. 12, § 95(A)(3)', 'Oklahoma Legislature', 'Justia - Oklahoma SOL'), 'confidence', 'high')),
    'error', 'document_verified', true, false, NOW(), NOW())
ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();
