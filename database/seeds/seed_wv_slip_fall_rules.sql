-- West Virginia (WV) Slip & Fall Rules - Enhanced
INSERT INTO leverage.validation_rules (rule_name, validator_level, validator_name, validator_type, practice_area, specialization, document_type, jurisdiction_scope, jurisdiction_state, validator_config, severity, review_status, is_active, is_template, created_at, updated_at)
VALUES ('WV-SLIP-FALL-INVITEE-DUTY', 5, 'WV Premises Liability: Invitee Duty', 'content_check', 'personal_injury', 'slip_fall', 'complaint', 'state', 'WV',
    jsonb_build_object('sub_specialization_type', 'premises_liability', 'authority_level', 'contextual_rule', 'common_law_basis', 'Traditional invitee duty', 'key_case', 'Mallet v. Pickens, 206 W.Va. 145 (2002)', 'invitee_definition', jsonb_build_object('examples', jsonb_build_array('Customer in retail store', 'Restaurant patron')), 'duty_standard', jsonb_build_object('highest_duty', 'Exercise reasonable care to maintain safe premises', 'duty_components', jsonb_build_array('Duty to inspect', 'Duty to repair or warn')), 'verification', jsonb_build_object('common_law_verified', true, 'confidence', 'high')),
    'error', 'document_verified', true, false, NOW(), NOW())
ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

INSERT INTO leverage.validation_rules (rule_name, validator_level, validator_name, validator_type, practice_area, specialization, document_type, jurisdiction_scope, jurisdiction_state, validator_config, severity, review_status, is_active, is_template, created_at, updated_at)
VALUES ('WV-SLIP-FALL-PURE-COMPARATIVE', 5, 'WV Pure Comparative Negligence (DEACTIVATED - WV changed to MODIFIED comparative in 2015 via W.Va. Code § 55-7-13a)', 'content_check', 'personal_injury', 'slip_fall', 'complaint', 'state', 'WV',
    jsonb_build_object('sub_specialization_type', 'premises_liability', 'authority_level', 'statutory_rule', 'statute', 'W.Va. Code § 55-7-13a', 'DEACTIVATED_reason', 'WRONG: W.Va. Code § 55-7-13a (2015) ESTABLISHED modified comparative negligence (51% bar). WV changed FROM pure comparative TO modified comparative in 2015. Use WV-SLIP-FALL-MODIFIED-COMPARATIVE instead.', 'negligence_model', 'pure_comparative_negligence', 'error_type', 'WRONG_NEGLIGENCE_MODEL - deactivated', 'pass1_result', 'FAIL - § 55-7-13a is the 2015 modified comparative act', 'pass2_result', 'FAIL - WV changed to modified comparative in 2015', 'verification', jsonb_build_object('statute_text_verified', false, 'confidence', 'low')),
    'error', 'needs_review', false, false, NOW(), NOW())
ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, is_active = false, review_status = 'needs_review', updated_at = NOW();

INSERT INTO leverage.validation_rules (rule_name, validator_level, validator_name, validator_type, practice_area, specialization, document_type, jurisdiction_scope, jurisdiction_state, validator_config, severity, review_status, is_active, is_template, created_at, updated_at)
VALUES ('WV-SLIP-FALL-SOL-2-YEARS', 5, 'WV Statute of Limitations: 2 YEARS (W.Va. Code § 55-2-12)', 'content_check', 'personal_injury', 'slip_fall', 'complaint', 'state', 'WV',
    jsonb_build_object('sub_specialization_type', 'premises_liability', 'authority_level', 'statutory_rule', 'statute', 'W.Va. Code § 55-2-12', 'sol_period', '2 years', 'trigger_date', 'Date of injury', 'verification', jsonb_build_object('statute_text_verified', true, 'confidence', 'high')),
    'error', 'document_verified', true, false, NOW(), NOW())
ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

INSERT INTO leverage.validation_rules (rule_name, validator_level, validator_name, validator_type, practice_area, specialization, document_type, jurisdiction_scope, jurisdiction_state, validator_config, severity, review_status, is_active, is_template, created_at, updated_at)
VALUES ('WV-SLIP-FALL-LICENSEE-DUTY', 5, 'WV Premises Liability: Licensee Duty', 'content_check', 'personal_injury', 'slip_fall', 'complaint', 'state', 'WV',
    jsonb_build_object('sub_specialization_type', 'premises_liability', 'licensee_definition', jsonb_build_object('definition', 'Person with permission for own purposes'), 'duty_standard', jsonb_build_object('moderate_duty', 'Warn of known dangers'), 'verification', jsonb_build_object('common_law_verified', true, 'confidence', 'high')),
    'error', 'document_verified', true, false, NOW(), NOW())
ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

INSERT INTO leverage.validation_rules (rule_name, validator_level, validator_name, validator_type, practice_area, specialization, document_type, jurisdiction_scope, jurisdiction_state, validator_config, severity, review_status, is_active, is_template, created_at, updated_at)
VALUES ('WV-SLIP-FALL-TRESPASSER-DUTY', 5, 'WV Premises Liability: Trespasser Duty', 'content_check', 'personal_injury', 'slip_fall', 'complaint', 'state', 'WV',
    jsonb_build_object('sub_specialization_type', 'premises_liability', 'trespasser_definition', jsonb_build_object('definition', 'Person without permission'), 'duty_standard', jsonb_build_object('minimal_duty', 'Refrain from willful/wanton injury'), 'verification', jsonb_build_object('common_law_verified', true, 'confidence', 'high')),
    'error', 'document_verified', true, false, NOW(), NOW())
ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

INSERT INTO leverage.validation_rules (rule_name, validator_level, validator_name, validator_type, practice_area, specialization, document_type, jurisdiction_scope, jurisdiction_state, validator_config, severity, review_status, is_active, is_template, created_at, updated_at)
VALUES ('WV-SLIP-FALL-NOTICE', 5, 'WV Slip & Fall: Notice Requirement', 'content_check', 'personal_injury', 'slip_fall', 'complaint', 'state', 'WV',
    jsonb_build_object('sub_specialization_type', 'premises_liability', 'legal_requirement', 'Plaintiff must prove actual or constructive notice', 'notice_types', jsonb_build_object('actual_notice', jsonb_build_object('definition', 'Direct knowledge'), 'constructive_notice', jsonb_build_object('definition', 'Should have discovered')), 'verification', jsonb_build_object('case_law_verified', true, 'confidence', 'high')),
    'warning', 'document_verified', true, false, NOW(), NOW())
ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

INSERT INTO leverage.validation_rules (rule_name, validator_level, validator_name, validator_type, practice_area, specialization, document_type, jurisdiction_scope, jurisdiction_state, validator_config, severity, review_status, is_active, is_template, created_at, updated_at)
VALUES ('WV-SLIP-FALL-DAMAGES', 5, 'WV Slip & Fall: Damages', 'content_check', 'personal_injury', 'slip_fall', 'complaint', 'state', 'WV',
    jsonb_build_object('sub_specialization_type', 'premises_liability', 'compensatory_damages', jsonb_build_object('economic_damages', jsonb_build_array('Medical expenses', 'Lost wages'), 'non_economic_damages', jsonb_build_array('Pain and suffering'), 'cap', 'No cap'), 'punitive_damages', jsonb_build_object('availability', 'Available for reckless conduct'), 'verification', jsonb_build_object('statutes_verified', true, 'confidence', 'high')),
    'info', 'document_verified', true, false, NOW(), NOW())
ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

INSERT INTO leverage.validation_rules (rule_name, validator_level, validator_name, validator_type, practice_area, specialization, document_type, jurisdiction_scope, jurisdiction_state, validator_config, severity, review_status, is_active, is_template, created_at, updated_at)
VALUES ('WV-SLIP-FALL-OPEN-OBVIOUS', 5, 'WV Slip & Fall: Open and Obvious Doctrine', 'content_check', 'personal_injury', 'slip_fall', 'complaint', 'state', 'WV',
    jsonb_build_object('sub_specialization_type', 'premises_liability', 'doctrine_statement', 'Open and obvious dangers affect comparative negligence', 'wv_approach', jsonb_build_object('general_rule', 'Does not eliminate duty', 'effect', 'Reduces recovery by fault percentage - MODIFIED comparative (51% bar per W.Va. Code § 55-7-13a)'), 'verification', jsonb_build_object('case_law_verified', true, 'confidence', 'high')),
    'warning', 'document_verified', true, false, NOW(), NOW())
ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

INSERT INTO leverage.validation_rules (rule_name, validator_level, validator_name, validator_type, practice_area, specialization, document_type, jurisdiction_scope, jurisdiction_state, validator_config, severity, review_status, is_active, is_template, created_at, updated_at)
VALUES ('WV-SLIP-FALL-COMPLAINT', 5, 'WV Slip & Fall: Complaint Requirements', 'content_check', 'personal_injury', 'slip_fall', 'complaint', 'state', 'WV',
    jsonb_build_object('sub_specialization_type', 'premises_liability', 'complaint_elements', jsonb_build_object('required_allegations', jsonb_build_array('Date', 'Location', 'Hazard', 'Status', 'Notice', 'Duty', 'Breach', 'Causation', 'Damages')), 'pleading_standard', jsonb_build_object('rule', 'Notice pleading'), 'verification', jsonb_build_object('rules_verified', true, 'confidence', 'high')),
    'warning', 'document_verified', true, false, NOW(), NOW())
ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

INSERT INTO leverage.validation_rules (rule_name, validator_level, validator_name, validator_type, practice_area, specialization, document_type, jurisdiction_scope, jurisdiction_state, validator_config, severity, review_status, is_active, is_template, created_at, updated_at)
VALUES ('WV-SLIP-FALL-CHECKLIST', 5, 'WV Slip & Fall: Documentation Checklist', 'content_check', 'personal_injury', 'slip_fall', 'complaint', 'state', 'WV',
    jsonb_build_object('sub_specialization_type', 'premises_liability', 'modified_comparative_note', 'West Virginia MODIFIED comparative (51% bar per W.Va. Code § 55-7-13a, enacted 2015) - plaintiff can recover only if fault is 50% or less', 'evidence_checklist', jsonb_build_object('scene_evidence', jsonb_build_array('Photographs', 'Video', 'Incident report', 'Witness statements'), 'notice_evidence', jsonb_build_array('Prior complaints', 'Prior incidents', 'Inspection logs'), 'medical_evidence', jsonb_build_array('Medical records', 'ER records', 'Expert opinions')), 'verification', jsonb_build_object('practice_guide_verified', true, 'confidence', 'high')),
    'info', 'document_verified', true, false, NOW(), NOW())
ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();
