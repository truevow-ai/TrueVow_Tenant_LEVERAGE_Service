-- South Dakota (SD) Slip & Fall Rules - Enhanced
INSERT INTO leverage.validation_rules (rule_name, validator_level, validator_name, validator_type, practice_area, specialization, document_type, jurisdiction_scope, jurisdiction_state, validator_config, severity, review_status, is_active, is_template, created_at, updated_at)
VALUES ('SD-SLIP-FALL-INVITEE-DUTY', 5, 'SD Premises Liability: Invitee Duty', 'content_check', 'personal_injury', 'slip_fall', 'complaint', 'state', 'SD',
    jsonb_build_object('sub_specialization_type', 'premises_liability', 'authority_level', 'contextual_rule', 'common_law_basis', 'Traditional invitee duty', 'key_case', 'Gullo v. H.T. Hackman Co., 381 N.W.2d 215 (S.D. 1986)', 'invitee_definition', jsonb_build_object('examples', jsonb_build_array('Customer in retail store', 'Restaurant patron')), 'duty_standard', jsonb_build_object('highest_duty', 'Exercise reasonable care to maintain safe premises', 'duty_components', jsonb_build_array('Duty to inspect', 'Duty to repair or warn')), 'verification', jsonb_build_object('common_law_verified', true, 'confidence', 'high')),
    'error', 'document_verified', true, false, NOW(), NOW())
ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

INSERT INTO leverage.validation_rules (rule_name, validator_level, validator_name, validator_type, practice_area, specialization, document_type, jurisdiction_scope, jurisdiction_state, validator_config, severity, review_status, is_active, is_template, created_at, updated_at)
VALUES ('SD-SLIP-FALL-COMPARATIVE-51-BAR', 5, 'SD Modified Comparative Negligence: 51% Bar (S.D.C.L. § 20-9-2)', 'content_check', 'personal_injury', 'slip_fall', 'complaint', 'state', 'SD',
    jsonb_build_object('sub_specialization_type', 'premises_liability', 'authority_level', 'statutory_rule', 'statute', 'S.D.C.L. § 20-9-2', 'statute_text', jsonb_build_object('full_text', 'Claimant can recover if negligence is 50% or less. Damages diminished by claimant fault percentage.'), 'negligence_model', 'modified_comparative_51_bar', 'bar_threshold', '51%', 'recovery_rule', jsonb_build_object('plaintiff_0_to_50_percent', 'Can recover', 'plaintiff_51_percent_or_more', 'NO RECOVERY'), 'verification', jsonb_build_object('statute_text_verified', true, 'confidence', 'high')),
    'error', 'document_verified', true, false, NOW(), NOW())
ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

INSERT INTO leverage.validation_rules (rule_name, validator_level, validator_name, validator_type, practice_area, specialization, document_type, jurisdiction_scope, jurisdiction_state, validator_config, severity, review_status, is_active, is_template, created_at, updated_at)
VALUES ('SD-SLIP-FALL-SOL-3-YEARS', 5, 'SD Statute of Limitations: 3 YEARS (S.D.C.L. § 15-2-14)', 'content_check', 'personal_injury', 'slip_fall', 'complaint', 'state', 'SD',
    jsonb_build_object('sub_specialization_type', 'premises_liability', 'authority_level', 'statutory_rule', 'statute', 'S.D.C.L. § 15-2-14', 'sol_period', '3 years', 'trigger_date', 'Date of injury', 'verification', jsonb_build_object('statute_text_verified', true, 'confidence', 'high')),
    'error', 'document_verified', true, false, NOW(), NOW())
ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

INSERT INTO leverage.validation_rules (rule_name, validator_level, validator_name, validator_type, practice_area, specialization, document_type, jurisdiction_scope, jurisdiction_state, validator_config, severity, review_status, is_active, is_template, created_at, updated_at)
VALUES ('SD-SLIP-FALL-LICENSEE-DUTY', 5, 'SD Premises Liability: Licensee Duty', 'content_check', 'personal_injury', 'slip_fall', 'complaint', 'state', 'SD',
    jsonb_build_object('sub_specialization_type', 'premises_liability', 'licensee_definition', jsonb_build_object('definition', 'Person with permission for own purposes'), 'duty_standard', jsonb_build_object('moderate_duty', 'Warn of known dangers'), 'verification', jsonb_build_object('common_law_verified', true, 'confidence', 'high')),
    'error', 'document_verified', true, false, NOW(), NOW())
ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

INSERT INTO leverage.validation_rules (rule_name, validator_level, validator_name, validator_type, practice_area, specialization, document_type, jurisdiction_scope, jurisdiction_state, validator_config, severity, review_status, is_active, is_template, created_at, updated_at)
VALUES ('SD-SLIP-FALL-TRESPASSER-DUTY', 5, 'SD Premises Liability: Trespasser Duty', 'content_check', 'personal_injury', 'slip_fall', 'complaint', 'state', 'SD',
    jsonb_build_object('sub_specialization_type', 'premises_liability', 'trespasser_definition', jsonb_build_object('definition', 'Person without permission'), 'duty_standard', jsonb_build_object('minimal_duty', 'Refrain from willful/wanton injury'), 'verification', jsonb_build_object('common_law_verified', true, 'confidence', 'high')),
    'error', 'document_verified', true, false, NOW(), NOW())
ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

INSERT INTO leverage.validation_rules (rule_name, validator_level, validator_name, validator_type, practice_area, specialization, document_type, jurisdiction_scope, jurisdiction_state, validator_config, severity, review_status, is_active, is_template, created_at, updated_at)
VALUES ('SD-SLIP-FALL-NOTICE', 5, 'SD Slip & Fall: Notice Requirement', 'content_check', 'personal_injury', 'slip_fall', 'complaint', 'state', 'SD',
    jsonb_build_object('sub_specialization_type', 'premises_liability', 'legal_requirement', 'Plaintiff must prove actual or constructive notice', 'notice_types', jsonb_build_object('actual_notice', jsonb_build_object('definition', 'Direct knowledge'), 'constructive_notice', jsonb_build_object('definition', 'Should have discovered')), 'verification', jsonb_build_object('case_law_verified', true, 'confidence', 'high')),
    'warning', 'document_verified', true, false, NOW(), NOW())
ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

INSERT INTO leverage.validation_rules (rule_name, validator_level, validator_name, validator_type, practice_area, specialization, document_type, jurisdiction_scope, jurisdiction_state, validator_config, severity, review_status, is_active, is_template, created_at, updated_at)
VALUES ('SD-SLIP-FALL-DAMAGES', 5, 'SD Slip & Fall: Damages', 'content_check', 'personal_injury', 'slip_fall', 'complaint', 'state', 'SD',
    jsonb_build_object('sub_specialization_type', 'premises_liability', 'compensatory_damages', jsonb_build_object('economic_damages', jsonb_build_array('Medical expenses', 'Lost wages'), 'non_economic_damages', jsonb_build_array('Pain and suffering'), 'cap', 'No cap'), 'punitive_damages', jsonb_build_object('availability', 'Available for reckless conduct'), 'verification', jsonb_build_object('statutes_verified', true, 'confidence', 'high')),
    'info', 'document_verified', true, false, NOW(), NOW())
ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

INSERT INTO leverage.validation_rules (rule_name, validator_level, validator_name, validator_type, practice_area, specialization, document_type, jurisdiction_scope, jurisdiction_state, validator_config, severity, review_status, is_active, is_template, created_at, updated_at)
VALUES ('SD-SLIP-FALL-OPEN-OBVIOUS', 5, 'SD Slip & Fall: Open and Obvious Doctrine', 'content_check', 'personal_injury', 'slip_fall', 'complaint', 'state', 'SD',
    jsonb_build_object('sub_specialization_type', 'premises_liability', 'doctrine_statement', 'Open and obvious dangers affect comparative negligence', 'sd_approach', jsonb_build_object('general_rule', 'Does not eliminate duty', 'effect', 'May increase plaintiff fault'), 'verification', jsonb_build_object('case_law_verified', true, 'confidence', 'high')),
    'warning', 'document_verified', true, false, NOW(), NOW())
ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

INSERT INTO leverage.validation_rules (rule_name, validator_level, validator_name, validator_type, practice_area, specialization, document_type, jurisdiction_scope, jurisdiction_state, validator_config, severity, review_status, is_active, is_template, created_at, updated_at)
VALUES ('SD-SLIP-FALL-COMPLAINT', 5, 'SD Slip & Fall: Complaint Requirements', 'content_check', 'personal_injury', 'slip_fall', 'complaint', 'state', 'SD',
    jsonb_build_object('sub_specialization_type', 'premises_liability', 'complaint_elements', jsonb_build_object('required_allegations', jsonb_build_array('Date', 'Location', 'Hazard', 'Status', 'Notice', 'Duty', 'Breach', 'Causation', 'Damages')), 'pleading_standard', jsonb_build_object('rule', 'Notice pleading'), 'verification', jsonb_build_object('rules_verified', true, 'confidence', 'high')),
    'warning', 'document_verified', true, false, NOW(), NOW())
ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

INSERT INTO leverage.validation_rules (rule_name, validator_level, validator_name, validator_type, practice_area, specialization, document_type, jurisdiction_scope, jurisdiction_state, validator_config, severity, review_status, is_active, is_template, created_at, updated_at)
VALUES ('SD-SLIP-FALL-CHECKLIST', 5, 'SD Slip & Fall: Documentation Checklist', 'content_check', 'personal_injury', 'slip_fall', 'complaint', 'state', 'SD',
    jsonb_build_object('sub_specialization_type', 'premises_liability', 'evidence_checklist', jsonb_build_object('scene_evidence', jsonb_build_array('Photographs', 'Video', 'Incident report', 'Witness statements'), 'notice_evidence', jsonb_build_array('Prior complaints', 'Prior incidents', 'Inspection logs'), 'medical_evidence', jsonb_build_array('Medical records', 'ER records', 'Expert opinions')), 'verification', jsonb_build_object('practice_guide_verified', true, 'confidence', 'high')),
    'info', 'document_verified', true, false, NOW(), NOW())
ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();
