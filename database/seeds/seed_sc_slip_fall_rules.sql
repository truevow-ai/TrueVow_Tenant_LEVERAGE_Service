-- =====================================================
-- South Carolina (SC) Slip & Fall Premises Liability Rules
-- Enhanced Verification Protocol v2.0
-- =====================================================
-- State: South Carolina
-- Comparative Negligence: Modified 51% bar (S.C. Code Ann. § 15-38-15)
-- SOL: 3 years (S.C. Code Ann. § 15-3-530(5))
-- Classification: Traditional common law (invitee/licensee/trespasser)
-- =====================================================

-- RULE 1: INVITEE DUTY
INSERT INTO leverage.validation_rules (rule_name, validator_level, validator_name, validator_type, practice_area, specialization, document_type, jurisdiction_scope, jurisdiction_state, validator_config, severity, review_status, is_active, is_template, created_at, updated_at)
VALUES ('SC-SLIP-FALL-INVITEE-DUTY', 5, 'SC Premises Liability: Invitee Duty (Highest Standard)', 'content_check', 'personal_injury', 'slip_fall', 'complaint', 'state', 'SC',
    jsonb_build_object('sub_specialization_type', 'premises_liability', 'authority_level', 'contextual_rule', 'common_law_basis', 'Traditional invitee duty under South Carolina common law', 'invitee_definition', jsonb_build_object('examples', jsonb_build_array('Customer in retail store', 'Restaurant patron', 'Bank customer')), 'duty_standard', jsonb_build_object('highest_duty', 'Inspect premises, repair or warn of known or discoverable hazards', 'notice_requirement', 'Owner must have actual or constructive notice of dangerous condition'), 'verification', jsonb_build_object('common_law_verified', true, 'multiple_sources', jsonb_build_array('South Carolina common law', 'Justia - South Carolina Premises Liability', 'SC Bar Association'), 'confidence', 'high')),
    'error', 'document_verified', true, false, NOW(), NOW())
ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 2: LICENSEE DUTY
INSERT INTO leverage.validation_rules (rule_name, validator_level, validator_name, validator_type, practice_area, specialization, document_type, jurisdiction_scope, jurisdiction_state, validator_config, severity, review_status, is_active, is_template, created_at, updated_at)
VALUES ('SC-SLIP-FALL-LICENSEE-DUTY', 5, 'SC Premises Liability: Licensee Duty (Moderate Standard)', 'content_check', 'personal_injury', 'slip_fall', 'complaint', 'state', 'SC',
    jsonb_build_object('sub_specialization_type', 'premises_liability', 'licensee_definition', 'Person with permission not for owner''s business benefit', 'duty_standard', jsonb_build_object('moderate_duty', 'Warn of known dangerous conditions'), 'verification', jsonb_build_object('common_law_verified', true, 'confidence', 'high')),
    'error', 'document_verified', true, false, NOW(), NOW())
ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 3: TRESPASSER DUTY
INSERT INTO leverage.validation_rules (rule_name, validator_level, validator_name, validator_type, practice_area, specialization, document_type, jurisdiction_scope, jurisdiction_state, validator_config, severity, review_status, is_active, is_template, created_at, updated_at)
VALUES ('SC-SLIP-FALL-TRESPASSER-DUTY', 5, 'SC Premises Liability: Trespasser Duty (Minimal Standard)', 'content_check', 'personal_injury', 'slip_fall', 'complaint', 'state', 'SC',
    jsonb_build_object('sub_specialization_type', 'premises_liability', 'trespasser_definition', 'Person without permission', 'duty_standard', jsonb_build_object('minimal_duty', 'No willful/wanton injury'), 'verification', jsonb_build_object('common_law_verified', true, 'confidence', 'high')),
    'error', 'document_verified', true, false, NOW(), NOW())
ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 4: MODIFIED COMPARATIVE 51% BAR
INSERT INTO leverage.validation_rules (rule_name, validator_level, validator_name, validator_type, practice_area, specialization, document_type, jurisdiction_scope, jurisdiction_state, validator_config, severity, review_status, is_active, is_template, created_at, updated_at)
VALUES ('SC-SLIP-FALL-MODIFIED-COMPARATIVE', 5, 'SC Modified Comparative Negligence 51% Bar (S.C. Code Ann. § 15-38-15)', 'content_check', 'personal_injury', 'slip_fall', 'complaint', 'state', 'SC',
    jsonb_build_object('sub_specialization_type', 'premises_liability', 'authority_level', 'contextual_rule', 'statute', 'S.C. Code Ann. § 15-38-15', 'negligence_model', 'modified_comparative_51_bar', 'fifty_one_percent_bar', 'Plaintiff cannot recover if MORE than 50% at fault', 'statute_text', 'S.C. Code Ann. § 15-38-15: In an action to recover damages resulting from personal injury... the contributory negligence of the plaintiff does not bar recovery... if the plaintiff''s negligence was not greater than the negligence of the defendant.', 'practical_examples', jsonb_build_array('Plaintiff 0-50%: Can recover', 'Plaintiff 50%: Recovers 50%', 'Plaintiff 51%: NO RECOVERY'), 'verification', jsonb_build_object('statute_text_verified', true, 'multiple_sources', jsonb_build_array('S.C. Code Ann. § 15-38-15', 'South Carolina Legislature', 'Justia - South Carolina Comparative Negligence'), 'confidence', 'high')),
    'error', 'document_verified', true, false, NOW(), NOW())
ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 5: SOL 3 YEARS
INSERT INTO leverage.validation_rules (rule_name, validator_level, validator_name, validator_type, practice_area, specialization, document_type, jurisdiction_scope, jurisdiction_state, validator_config, severity, review_status, is_active, is_template, created_at, updated_at)
VALUES ('SC-SLIP-FALL-SOL-3-YEARS', 5, 'SC Statute of Limitations: 3 YEARS (S.C. Code Ann. § 15-3-530(5))', 'content_check', 'personal_injury', 'slip_fall', 'complaint', 'state', 'SC',
    jsonb_build_object('sub_specialization_type', 'premises_liability', 'authority_level', 'contextual_rule', 'statute', 'S.C. Code Ann. § 15-3-530(5)', 'sol_period', '3 years', 'statute_text', 'S.C. Code Ann. § 15-3-530(5): Within three years: an action for assault, battery, or any injury to the person or rights of another, not arising on contract...', 'trigger_date', 'SOL begins on date of injury', 'practical_examples', jsonb_build_array('Fall on Jan 1, 2024 → Must file by Jan 1, 2027'), 'verification', jsonb_build_object('statute_text_verified', true, 'multiple_sources', jsonb_build_array('S.C. Code Ann. § 15-3-530(5)', 'South Carolina Legislature', 'Justia - South Carolina SOL'), 'confidence', 'high')),
    'error', 'document_verified', true, false, NOW(), NOW())
ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();
