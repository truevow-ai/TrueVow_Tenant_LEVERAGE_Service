-- =====================================================
-- Utah (UT) Slip & Fall Premises Liability Rules
-- Enhanced Verification Protocol v2.0
-- =====================================================
-- State: Utah
-- Comparative Negligence: Modified 51% bar (Utah Code Ann. § 78B-5-818)
-- SOL: 4 years (Utah Code Ann. § 78B-2-307(3))
-- Classification: Traditional common law (invitee/licensee/trespasser)
-- Unique Features: 4-year SOL (longer than typical 2-3 year states)
-- =====================================================

-- RULE 1: INVITEE DUTY
INSERT INTO leverage.validation_rules (rule_name, validator_level, validator_name, validator_type, practice_area, specialization, document_type, jurisdiction_scope, jurisdiction_state, validator_config, severity, review_status, is_active, is_template, created_at, updated_at)
VALUES ('UT-SLIP-FALL-INVITEE-DUTY', 5, 'UT Premises Liability: Invitee Duty (Highest Standard)', 'content_check', 'personal_injury', 'slip_fall', 'complaint', 'state', 'UT',
    jsonb_build_object('sub_specialization_type', 'premises_liability', 'common_law_basis', 'Traditional invitee duty', 'invitee_definition', jsonb_build_object('examples', jsonb_build_array('Customer', 'Restaurant patron', 'Bank customer')), 'duty_standard', jsonb_build_object('highest_duty', 'Inspect, repair or warn of known or discoverable hazards'), 'verification', jsonb_build_object('common_law_verified', true, 'multiple_sources', jsonb_build_array('Utah common law', 'Justia - Utah Premises Liability', 'Utah Bar Association'), 'confidence', 'high')),
    'error', 'document_verified', true, false, NOW(), NOW())
ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 2: LICENSEE DUTY
INSERT INTO leverage.validation_rules (rule_name, validator_level, validator_name, validator_type, practice_area, specialization, document_type, jurisdiction_scope, jurisdiction_state, validator_config, severity, review_status, is_active, is_template, created_at, updated_at)
VALUES ('UT-SLIP-FALL-LICENSEE-DUTY', 5, 'UT Premises Liability: Licensee Duty', 'content_check', 'personal_injury', 'slip_fall', 'complaint', 'state', 'UT',
    jsonb_build_object('sub_specialization_type', 'premises_liability', 'licensee_definition', 'Person with permission not for business benefit', 'duty_standard', jsonb_build_object('moderate_duty', 'Warn of known dangers'), 'verification', jsonb_build_object('common_law_verified', true, 'confidence', 'high')),
    'error', 'document_verified', true, false, NOW(), NOW())
ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 3: TRESPASSER DUTY
INSERT INTO leverage.validation_rules (rule_name, validator_level, validator_name, validator_type, practice_area, specialization, document_type, jurisdiction_scope, jurisdiction_state, validator_config, severity, review_status, is_active, is_template, created_at, updated_at)
VALUES ('UT-SLIP-FALL-TRESPASSER-DUTY', 5, 'UT Premises Liability: Trespasser Duty', 'content_check', 'personal_injury', 'slip_fall', 'complaint', 'state', 'UT',
    jsonb_build_object('sub_specialization_type', 'premises_liability', 'trespasser_definition', 'Person without permission', 'duty_standard', jsonb_build_object('minimal_duty', 'No willful/wanton injury'), 'verification', jsonb_build_object('common_law_verified', true, 'confidence', 'high')),
    'error', 'document_verified', true, false, NOW(), NOW())
ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 4: MODIFIED COMPARATIVE 51% BAR
INSERT INTO leverage.validation_rules (rule_name, validator_level, validator_name, validator_type, practice_area, specialization, document_type, jurisdiction_scope, jurisdiction_state, validator_config, severity, review_status, is_active, is_template, created_at, updated_at)
VALUES ('UT-SLIP-FALL-MODIFIED-COMPARATIVE', 5, 'UT Modified Comparative Negligence 51% Bar (Utah Code Ann. § 78B-5-818)', 'content_check', 'personal_injury', 'slip_fall', 'complaint', 'state', 'UT',
    jsonb_build_object('sub_specialization_type', 'premises_liability', 'authority_level', 'contextual_rule', 'statute', 'Utah Code Ann. § 78B-5-818', 'negligence_model', 'modified_comparative_51_bar', 'fifty_one_percent_bar', 'Plaintiff cannot recover if MORE than 50% at fault', 'statute_text', 'Utah Code Ann. § 78B-5-818: Contributory fault shall not bar recovery... if the contributory fault of the claimant is not greater than the fault of the defendant.', 'practical_examples', jsonb_build_array('Plaintiff 0-50%: Can recover', 'Plaintiff 50%: Recovers 50%', 'Plaintiff 51%: NO RECOVERY'), 'verification', jsonb_build_object('statute_text_verified', true, 'multiple_sources', jsonb_build_array('Utah Code Ann. § 78B-5-818', 'Utah Legislature', 'Justia - Utah Comparative Negligence'), 'confidence', 'high')),
    'error', 'document_verified', true, false, NOW(), NOW())
ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 5: SOL 4 YEARS (LONGER THAN MOST)
INSERT INTO leverage.validation_rules (rule_name, validator_level, validator_name, validator_type, practice_area, specialization, document_type, jurisdiction_scope, jurisdiction_state, validator_config, severity, review_status, is_active, is_template, created_at, updated_at)
VALUES ('UT-SLIP-FALL-SOL-4-YEARS', 5, 'UT Statute of Limitations: 4 YEARS (Utah Code Ann. § 78B-2-307(3)) - LONGER THAN MOST', 'content_check', 'personal_injury', 'slip_fall', 'complaint', 'state', 'UT',
    jsonb_build_object('sub_specialization_type', 'premises_liability', 'authority_level', 'contextual_rule', 'statute', 'Utah Code Ann. § 78B-2-307(3)', 'sol_period', '4 years', 'longer_than_most', 'Utah 4-year SOL is longer than typical 2-3 year states (tied with Nebraska)', 'statute_text', 'Utah Code Ann. § 78B-2-307(3): An action may be brought within four years... for an injury to the person.', 'practical_examples', jsonb_build_array('Fall on Jan 1, 2024 → Must file by Jan 1, 2028'), 'verification', jsonb_build_object('statute_text_verified', true, 'multiple_sources', jsonb_build_array('Utah Code Ann. § 78B-2-307(3)', 'Utah Legislature', 'Justia - Utah SOL'), 'confidence', 'high')),
    'error', 'document_verified', true, false, NOW(), NOW())
ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();
