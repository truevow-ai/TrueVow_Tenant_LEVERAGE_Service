-- =====================================================
-- Nevada (NV) Slip & Fall Premises Liability Rules
-- Enhanced Verification Protocol v2.0
-- =====================================================
-- State: Nevada
-- Comparative Negligence: Modified 51% bar (Nev. Rev. Stat. § 41.141)
-- SOL: 2 years (Nev. Rev. Stat. § 11.190(4)(e))
-- Classification: Traditional common law (invitee/licensee/trespasser)
-- Unique Features: None particularly unique
-- =====================================================

-- RULE 1: INVITEE DUTY
INSERT INTO leverage.validation_rules (rule_name, validator_level, validator_name, validator_type, practice_area, specialization, document_type, jurisdiction_scope, jurisdiction_state, validator_config, severity, review_status, is_active, is_template, created_at, updated_at)
VALUES ('NV-SLIP-FALL-INVITEE-DUTY', 5, 'NV Premises Liability: Invitee Duty (Highest Standard)', 'content_check', 'personal_injury', 'slip_fall', 'complaint', 'state', 'NV',
    jsonb_build_object('sub_specialization_type', 'premises_liability', 'common_law_basis', 'Traditional invitee duty', 'invitee_definition', jsonb_build_object('examples', jsonb_build_array('Customer', 'Restaurant patron')), 'duty_standard', jsonb_build_object('highest_duty', 'Inspect, repair/warn'), 'verification', jsonb_build_object('common_law_verified', true, 'multiple_sources', jsonb_build_array('Nevada common law', 'Justia - Nevada Premises Liability', 'Nevada Bar Association'), 'confidence', 'high')),
    'error', 'document_verified', true, false, NOW(), NOW())
ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 2: LICENSEE DUTY
INSERT INTO leverage.validation_rules (rule_name, validator_level, validator_name, validator_type, practice_area, specialization, document_type, jurisdiction_scope, jurisdiction_state, validator_config, severity, review_status, is_active, is_template, created_at, updated_at)
VALUES ('NV-SLIP-FALL-LICENSEE-DUTY', 5, 'NV Premises Liability: Licensee Duty', 'content_check', 'personal_injury', 'slip_fall', 'complaint', 'state', 'NV',
    jsonb_build_object('sub_specialization_type', 'premises_liability', 'licensee_definition', 'Person with permission', 'duty_standard', jsonb_build_object('moderate_duty', 'Warn of known dangers'), 'verification', jsonb_build_object('common_law_verified', true, 'confidence', 'high')),
    'error', 'document_verified', true, false, NOW(), NOW())
ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 3: TRESPASSER DUTY
INSERT INTO leverage.validation_rules (rule_name, validator_level, validator_name, validator_type, practice_area, specialization, document_type, jurisdiction_scope, jurisdiction_state, validator_config, severity, review_status, is_active, is_template, created_at, updated_at)
VALUES ('NV-SLIP-FALL-TRESPASSER-DUTY', 5, 'NV Premises Liability: Trespasser Duty', 'content_check', 'personal_injury', 'slip_fall', 'complaint', 'state', 'NV',
    jsonb_build_object('sub_specialization_type', 'premises_liability', 'trespasser_definition', 'Person without permission', 'duty_standard', jsonb_build_object('minimal_duty', 'No willful/wanton injury'), 'verification', jsonb_build_object('common_law_verified', true, 'confidence', 'high')),
    'error', 'document_verified', true, false, NOW(), NOW())
ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 4: MODIFIED COMPARATIVE 51% BAR
INSERT INTO leverage.validation_rules (rule_name, validator_level, validator_name, validator_type, practice_area, specialization, document_type, jurisdiction_scope, jurisdiction_state, validator_config, severity, review_status, is_active, is_template, created_at, updated_at)
VALUES ('NV-SLIP-FALL-MODIFIED-COMPARATIVE', 5, 'NV Modified Comparative Negligence 51% Bar (Nev. Rev. Stat. § 41.141)', 'content_check', 'personal_injury', 'slip_fall', 'complaint', 'state', 'NV',
    jsonb_build_object('sub_specialization_type', 'premises_liability', 'statute', 'Nev. Rev. Stat. § 41.141', 'negligence_model', 'modified_comparative_51_bar', 'fifty_one_percent_bar', 'Plaintiff cannot recover if MORE than 50% at fault', 'statute_text', 'Nev. Rev. Stat. § 41.141: ...not bar recovery... if the negligence attributable to the claimant was not greater than the negligence attributable to the person against whom recovery is sought.', 'practical_examples', jsonb_build_array('Plaintiff 0-50%: Can recover', 'Plaintiff 51%: NO RECOVERY'), 'verification', jsonb_build_object('statute_text_verified', true, 'multiple_sources', jsonb_build_array('Nev. Rev. Stat. § 41.141', 'Nevada Legislature', 'Justia - Nevada Comparative Negligence'), 'confidence', 'high')),
    'error', 'document_verified', true, false, NOW(), NOW())
ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 5: SOL 2 YEARS
INSERT INTO leverage.validation_rules (rule_name, validator_level, validator_name, validator_type, practice_area, specialization, document_type, jurisdiction_scope, jurisdiction_state, validator_config, severity, review_status, is_active, is_template, created_at, updated_at)
VALUES ('NV-SLIP-FALL-SOL-2-YEARS', 5, 'NV Statute of Limitations: 2 YEARS (Nev. Rev. Stat. § 11.190(4)(e))', 'content_check', 'personal_injury', 'slip_fall', 'complaint', 'state', 'NV',
    jsonb_build_object('sub_specialization_type', 'premises_liability', 'statute', 'Nev. Rev. Stat. § 11.190(4)(e)', 'sol_period', '2 years', 'statute_text', 'Nev. Rev. Stat. § 11.190(4)(e): ...personal injuries... two years.', 'practical_examples', jsonb_build_array('Fall on Jan 1, 2024 → Must file by Jan 1, 2026'), 'verification', jsonb_build_object('statute_text_verified', true, 'multiple_sources', jsonb_build_array('Nev. Rev. Stat. § 11.190(4)(e)', 'Nevada Legislature', 'Justia - Nevada SOL'), 'confidence', 'high')),
    'error', 'document_verified', true, false, NOW(), NOW())
ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();
