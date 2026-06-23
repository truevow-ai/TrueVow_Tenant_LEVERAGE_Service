-- North Carolina (NC) Slip & Fall Rules - Enhanced
INSERT INTO leverage.validation_rules (rule_name, validator_level, validator_name, validator_type, practice_area, specialization, document_type, jurisdiction_scope, jurisdiction_state, validator_config, severity, review_status, is_active, is_template, created_at, updated_at)
VALUES ('NC-SLIP-FALL-INVITEE-DUTY', 5, 'NC Premises Liability: Invitee Duty', 'content_check', 'personal_injury', 'slip_fall', 'complaint', 'state', 'NC',
    jsonb_build_object('sub_specialization_type', 'premises_liability', 'authority_level', 'contextual_rule', 'common_law_basis', 'Traditional invitee duty under NC common law', 'key_case', 'Nelson v. Freeland, 350 N.C. 740 (1999)', 'invitee_definition', jsonb_build_object('examples', jsonb_build_array('Customer in retail store', 'Restaurant patron')), 'duty_standard', jsonb_build_object('highest_duty', 'Exercise reasonable care to maintain safe premises', 'duty_components', jsonb_build_array('Duty to inspect', 'Duty to repair or warn')), 'verification', jsonb_build_object('common_law_verified', true, 'confidence', 'high')),
    'error', 'document_verified', true, false, NOW(), NOW())
ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- North Carolina (NC) Slip & Fall Rules - Protocol v3 Audit Correction 2026-03-02
INSERT INTO leverage.validation_rules (rule_name, validator_level, validator_name, validator_type, practice_area, specialization, document_type, jurisdiction_scope, jurisdiction_state, validator_config, severity, review_status, is_active, is_template, created_at, updated_at)
VALUES ('NC-SLIP-FALL-CONTRIBUTORY-NEGLIGENCE', 5, 'NC Contributory Negligence (COMPLETE BAR) - ONE OF ONLY 4 REMAINING STATES', 'content_check', 'personal_injury', 'slip_fall', 'complaint', 'state', 'NC',
    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'common_law',
        'negligence_model', 'contributory_negligence',
        'common_law_authority', 'NC common law — no single codified statute for the general contributory negligence defense in personal injury; leading case: Sorrells v. M.Y.B. Hospitality Ventures, 334 N.C. 143 (1993)',
        'complete_bar', 'Plaintiff cannot recover if ANY fault attributed to plaintiff - even 1% bars all recovery',
        'four_remaining_jurisdictions', jsonb_build_array('Alabama', 'Maryland', 'North Carolina', 'Virginia', 'District of Columbia'),
        'note_on_count', 'Four states (AL, MD, NC, VA) plus DC — DC is a federal district, not a state; total is 4 states + 1 district',
        'unique_feature', 'North Carolina is one of only 4 states that still use pure contributory negligence',
        'practical_examples', jsonb_build_array(
            'Plaintiff 1% at fault, Defendant 99%: Plaintiff recovers NOTHING',
            'Plaintiff 50% at fault, Defendant 50%: Plaintiff recovers NOTHING'
        ),
        'verification', jsonb_build_object(
            'audit_date', '2026-03-02',
            'protocol_version', 'v3',
            'pass1_result', 'PASS',
            'pass2_result', 'PASS',
            'error_corrected', 'Removed erroneous N.C.G.S. 28A-18-1 citation. That is the NC Wrongful Death Act, unrelated to the contributory negligence defense. NC contributory negligence is pure common law.',
            'prior_error_statute', 'N.C.G.S. 28A-18-1 (WRONGFUL DEATH ACT) — REMOVED',
            'correct_authority', 'Common law — no statute needed'
        )
    ),
    'error', 'needs_review', true, false, NOW(), NOW())
ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, review_status = 'needs_review', updated_at = NOW();

INSERT INTO leverage.validation_rules (rule_name, validator_level, validator_name, validator_type, practice_area, specialization, document_type, jurisdiction_scope, jurisdiction_state, validator_config, severity, review_status, is_active, is_template, created_at, updated_at)
VALUES ('NC-SLIP-FALL-SOL-3-YEARS', 5, 'NC Statute of Limitations: 3 YEARS (N.C.G.S. § 1-52)', 'content_check', 'personal_injury', 'slip_fall', 'complaint', 'state', 'NC',
    jsonb_build_object('sub_specialization_type', 'premises_liability', 'authority_level', 'statutory_rule', 'statute', 'N.C.G.S. § 1-52', 'sol_period', '3 years', 'trigger_date', 'Date of injury', 'verification', jsonb_build_object('statute_text_verified', true, 'confidence', 'high')),
    'error', 'document_verified', true, false, NOW(), NOW())
ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

INSERT INTO leverage.validation_rules (rule_name, validator_level, validator_name, validator_type, practice_area, specialization, document_type, jurisdiction_scope, jurisdiction_state, validator_config, severity, review_status, is_active, is_template, created_at, updated_at)
VALUES ('NC-SLIP-FALL-LICENSEE-DUTY', 5, 'NC Premises Liability: Licensee Duty', 'content_check', 'personal_injury', 'slip_fall', 'complaint', 'state', 'NC',
    jsonb_build_object('sub_specialization_type', 'premises_liability', 'licensee_definition', jsonb_build_object('definition', 'Person with permission for own purposes'), 'duty_standard', jsonb_build_object('moderate_duty', 'Warn of known dangers'), 'verification', jsonb_build_object('common_law_verified', true, 'confidence', 'high')),
    'error', 'document_verified', true, false, NOW(), NOW())
ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

INSERT INTO leverage.validation_rules (rule_name, validator_level, validator_name, validator_type, practice_area, specialization, document_type, jurisdiction_scope, jurisdiction_state, validator_config, severity, review_status, is_active, is_template, created_at, updated_at)
VALUES ('NC-SLIP-FALL-TRESPASSER-DUTY', 5, 'NC Premises Liability: Trespasser Duty', 'content_check', 'personal_injury', 'slip_fall', 'complaint', 'state', 'NC',
    jsonb_build_object('sub_specialization_type', 'premises_liability', 'trespasser_definition', jsonb_build_object('definition', 'Person without permission'), 'duty_standard', jsonb_build_object('minimal_duty', 'Refrain from willful/wanton injury'), 'verification', jsonb_build_object('common_law_verified', true, 'confidence', 'high')),
    'error', 'document_verified', true, false, NOW(), NOW())
ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

INSERT INTO leverage.validation_rules (rule_name, validator_level, validator_name, validator_type, practice_area, specialization, document_type, jurisdiction_scope, jurisdiction_state, validator_config, severity, review_status, is_active, is_template, created_at, updated_at)
VALUES ('NC-SLIP-FALL-NOTICE', 5, 'NC Slip & Fall: Notice Requirement', 'content_check', 'personal_injury', 'slip_fall', 'complaint', 'state', 'NC',
    jsonb_build_object('sub_specialization_type', 'premises_liability', 'legal_requirement', 'Plaintiff must prove actual or constructive notice', 'notice_types', jsonb_build_object('actual_notice', jsonb_build_object('definition', 'Direct knowledge'), 'constructive_notice', jsonb_build_object('definition', 'Should have discovered')), 'verification', jsonb_build_object('case_law_verified', true, 'confidence', 'high')),
    'warning', 'document_verified', true, false, NOW(), NOW())
ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

INSERT INTO leverage.validation_rules (rule_name, validator_level, validator_name, validator_type, practice_area, specialization, document_type, jurisdiction_scope, jurisdiction_state, validator_config, severity, review_status, is_active, is_template, created_at, updated_at)
VALUES ('NC-SLIP-FALL-DAMAGES', 5, 'NC Slip & Fall: Damages', 'content_check', 'personal_injury', 'slip_fall', 'complaint', 'state', 'NC',
    jsonb_build_object('sub_specialization_type', 'premises_liability', 'compensatory_damages', jsonb_build_object('economic_damages', jsonb_build_array('Medical expenses', 'Lost wages'), 'non_economic_damages', jsonb_build_array('Pain and suffering'), 'cap', 'No cap'), 'punitive_damages', jsonb_build_object('availability', 'Available for reckless conduct'), 'verification', jsonb_build_object('statutes_verified', true, 'confidence', 'high')),
    'info', 'document_verified', true, false, NOW(), NOW())
ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

INSERT INTO leverage.validation_rules (rule_name, validator_level, validator_name, validator_type, practice_area, specialization, document_type, jurisdiction_scope, jurisdiction_state, validator_config, severity, review_status, is_active, is_template, created_at, updated_at)
VALUES ('NC-SLIP-FALL-OPEN-OBVIOUS', 5, 'NC Slip & Fall: Open and Obvious Doctrine', 'content_check', 'personal_injury', 'slip_fall', 'complaint', 'state', 'NC',
    jsonb_build_object('sub_specialization_type', 'premises_liability', 'doctrine_statement', 'Open and obvious dangers affect contributory negligence analysis', 'nc_approach', jsonb_build_object('general_rule', 'Does not eliminate duty', 'effect', 'May constitute contributory negligence as matter of law'), 'verification', jsonb_build_object('case_law_verified', true, 'confidence', 'high')),
    'warning', 'document_verified', true, false, NOW(), NOW())
ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

INSERT INTO leverage.validation_rules (rule_name, validator_level, validator_name, validator_type, practice_area, specialization, document_type, jurisdiction_scope, jurisdiction_state, validator_config, severity, review_status, is_active, is_template, created_at, updated_at)
VALUES ('NC-SLIP-FALL-COMPLAINT', 5, 'NC Slip & Fall: Complaint Requirements', 'content_check', 'personal_injury', 'slip_fall', 'complaint', 'state', 'NC',
    jsonb_build_object('sub_specialization_type', 'premises_liability', 'complaint_elements', jsonb_build_object('required_allegations', jsonb_build_array('Date', 'Location', 'Hazard', 'Status', 'Notice', 'Duty', 'Breach', 'Causation', 'Damages')), 'pleading_standard', jsonb_build_object('rule', 'Notice pleading'), 'verification', jsonb_build_object('rules_verified', true, 'confidence', 'high')),
    'warning', 'document_verified', true, false, NOW(), NOW())
ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

INSERT INTO leverage.validation_rules (rule_name, validator_level, validator_name, validator_type, practice_area, specialization, document_type, jurisdiction_scope, jurisdiction_state, validator_config, severity, review_status, is_active, is_template, created_at, updated_at)
VALUES ('NC-SLIP-FALL-CHECKLIST', 5, 'NC Slip & Fall: Documentation Checklist', 'content_check', 'personal_injury', 'slip_fall', 'complaint', 'state', 'NC',
    jsonb_build_object('sub_specialization_type', 'premises_liability', 'contributory_negligence_warning', 'CRITICAL: North Carolina is contributory negligence state - ANY plaintiff fault (even 1%) bars ALL recovery', 'evidence_checklist', jsonb_build_object('scene_evidence', jsonb_build_array('Photographs', 'Video', 'Incident report', 'Witness statements'), 'notice_evidence', jsonb_build_array('Prior complaints', 'Prior incidents', 'Inspection logs'), 'medical_evidence', jsonb_build_array('Medical records', 'ER records', 'Expert opinions')), 'verification', jsonb_build_object('practice_guide_verified', true, 'confidence', 'high')),
    'info', 'document_verified', true, false, NOW(), NOW())
ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();
