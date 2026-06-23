-- =====================================================
-- Illinois (IL) Medical Malpractice Rules
-- Enhanced Verification Protocol v2.0
-- =====================================================
-- State: Illinois
-- Governing Law: 735 ILCS 5 (Code of Civil Procedure Part 17 - Healing Art Malpractice)
-- Negligence Model: MODIFIED COMPARATIVE (50% bar) — 735 ILCS 5/2-1116
-- SOL: 2 years discovery; 4-year repose (735 ILCS 5/13-212)
-- Damage Caps: NO caps — struck unconstitutional in Lebron v. Gottlieb (2010)
-- Expert: Affidavit of merit required at filing (735 ILCS 5/2-622)
-- =====================================================

-- RULE 1: STANDARD OF CARE
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, specialization, document_type,
    jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status,
    is_active, is_template, created_at, updated_at
)
VALUES (
    'IL-MED-MAL-STANDARD-OF-CARE', 5,
    'IL Medical Malpractice: Standard of Care (735 ILCS 5/2-1113)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'IL',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'contextual_rule',
        'statute', '735 ILCS 5/2-1113',
        'standard_text', 'In any action for healing art malpractice, the plaintiff must establish the standard of care through the testimony of a qualified expert witness',
        'key_elements', jsonb_build_array(
            'Duty: provider-patient relationship',
            'Breach: deviation from applicable standard of care for the specialty',
            'Causation: breach was proximate cause of injury',
            'Damages: actual injury resulted'
        ),
        'locality_rule', 'Illinois applies a statewide standard; no strict locality rule',
        'res_ipsa', 'Doctrine of res ipsa loquitur applicable in limited circumstances',
        'informed_consent', 'Separate theory under common law and statute; reasonable patient standard',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('735 ILCS 5/2-1113', 'Illinois Medical Malpractice Laws — Gilman Bedigian', 'LegalClarity 2025'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 2: AFFIDAVIT OF MERIT (CERTIFICATE OF MERIT)
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, specialization, document_type,
    jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status,
    is_active, is_template, created_at, updated_at
)
VALUES (
    'IL-MED-MAL-AFFIDAVIT-OF-MERIT', 5,
    'IL Medical Malpractice: Affidavit of Merit Required (735 ILCS 5/2-622)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'IL',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'hard_rule',
        'statute', '735 ILCS 5/2-622',
        'requirement', 'Plaintiff must file a certificate of merit (affidavit) with the complaint or within 90 days of filing',
        'affidavit_contents', jsonb_build_array(
            'Signed by a qualified health professional who has reviewed the complaint',
            'Must state that there is a reasonable basis for the lawsuit',
            'Expert must identify the standard of care applicable to the case',
            'Expert must state defendant deviated from that standard',
            'Expert must have substantial experience in the same medical field as defendant'
        ),
        'consequence_of_failure', 'Failure to file certificate of merit is grounds for dismissal of the complaint',
        'extension', 'Court may grant up to 90-day extension for good cause',
        'expert_not_required_to_testify', 'Expert who signs affidavit is not required to testify at trial',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('735 ILCS 5/2-622', 'Ankin Law Illinois Med Mal 2024', 'LegalClarity Illinois 2025'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 3: NO DAMAGE CAPS
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, specialization, document_type,
    jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status,
    is_active, is_template, created_at, updated_at
)
VALUES (
    'IL-MED-MAL-NO-DAMAGE-CAPS', 5,
    'IL Medical Malpractice: No Damage Caps — Struck Unconstitutional (Lebron v. Gottlieb 2010)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'IL',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'hard_rule',
        'key_case', 'Lebron v. Gottlieb Memorial Hospital, 237 Ill. 2d 217 (2010)',
        'holding', 'Illinois Supreme Court struck down non-economic damage caps as unconstitutional violation of separation of powers',
        'current_rule', 'No caps on non-economic damages in Illinois medical malpractice cases',
        'economic_damages', 'No cap on economic damages (medical expenses, lost wages, future care)',
        'punitive_damages', 'Punitive damages available for willful and wanton misconduct; no statutory cap in medical malpractice',
        'cap_history', jsonb_build_array(
            'Prior caps: $500,000 against physicians, $1,000,000 against hospitals (735 ILCS 5/2-1706.5)',
            'Struck as violating separation of powers in Lebron (2010)',
            'No legislative replacement cap has been enacted'
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('Lebron v. Gottlieb Memorial Hospital 237 Ill.2d 217 (2010)', 'LegalClarity Illinois Med Mal 2025'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 4: STATUTE OF LIMITATIONS
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, specialization, document_type,
    jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status,
    is_active, is_template, created_at, updated_at
)
VALUES (
    'IL-MED-MAL-SOL-2-YEARS', 5,
    'IL Medical Malpractice: 2-Year SOL, 4-Year Repose (735 ILCS 5/13-212)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'IL',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'hard_rule',
        'statute', '735 ILCS 5/13-212',
        'sol_period', '2 years from date plaintiff knew or should have known of injury',
        'repose_period', '4 years from date of negligent act — absolute bar regardless of discovery',
        'discovery_rule', 'SOL runs from date of discovery of injury and its causal connection to provider',
        'minor_exception', 'Minors under 18: period begins at age 18 (claim must be filed by age 20 under 2-year SOL)',
        'fraudulent_concealment', 'Fraudulent concealment may toll SOL but not repose in all cases',
        'tolling', jsonb_build_array(
            'Fraudulent concealment tolls 2-year SOL',
            'Foreign object in body: SOL runs from discovery',
            'Minors period begins at age 18'
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('735 ILCS 5/13-212', 'Gilman Bedigian Illinois Med Mal Laws', 'LegalClarity 2025'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 5: MODIFIED COMPARATIVE FAULT (50% BAR)
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, specialization, document_type,
    jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status,
    is_active, is_template, created_at, updated_at
)
VALUES (
    'IL-MED-MAL-MODIFIED-COMPARATIVE', 5,
    'IL Medical Malpractice: Modified Comparative Fault 50% Bar (735 ILCS 5/2-1116)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'IL',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'contextual_rule',
        'statute', '735 ILCS 5/2-1116',
        'negligence_model', 'modified_comparative',
        'bar_threshold', '50%',
        'rule_description', 'Plaintiff may recover if fault does not exceed 50%; damages reduced by plaintiff fault percentage',
        'complete_bar', 'Yes — plaintiff barred if found more than 50% at fault',
        'joint_several', 'Illinois: defendants with 25%+ fault jointly and severally liable; below 25% only severally liable (735 ILCS 5/2-1117)',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('735 ILCS 5/2-1116', 'Lawsuit Information Center Illinois'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();
