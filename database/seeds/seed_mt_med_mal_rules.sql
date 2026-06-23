-- =====================================================
-- Montana (MT) Medical Malpractice Rules
-- Enhanced Verification Protocol v2.0
-- =====================================================
-- State: Montana
-- Governing Law: MCA Title 27, Chapter 6 (Montana Medical Legal Panel Act)
--                MCA § 25-9-411 (Damage Limitations)
-- Negligence Model: MODIFIED COMPARATIVE (50% bar) — MCA § 27-1-702
-- SOL: 2 years discovery rule; 5-year repose; minor exception (MCA § 27-2-205)
-- Damage Caps: Non-economic damages capped at $250,000 (MCA § 25-9-411)
-- Pre-Litigation: Mandatory Medical Legal Panel review before court action
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
    'MT-MED-MAL-STANDARD-OF-CARE', 5,
    'MT Medical Malpractice: Standard of Care (MCA § 50-16-101)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'MT',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'contextual_rule',
        'statute', 'MCA § 50-16-101',
        'standard_text', 'A health care provider shall exercise that degree of care, skill, and learning expected of a reasonably prudent health care provider in the profession or class to which the provider belongs in the state acting in the same or similar circumstances',
        'key_elements', jsonb_build_array(
            'Duty: provider-patient relationship must be established',
            'Breach: failure to meet standard of a reasonably prudent similar provider in Montana',
            'Causation: breach was the proximate cause of plaintiff''s injury',
            'Damages: actual physical or economic harm resulted'
        ),
        'locality_rule', 'Montana uses a statewide standard, not a strict locality rule; "in the state" language applies',
        'informed_consent', 'Available; provider must disclose material information a reasonable patient would want to know before consenting to treatment',
        'res_ipsa', 'Recognized in Montana; available where injury does not ordinarily occur without negligence',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('MCA § 50-16-101', 'Montana Medical Legal Panel Act', 'Justia Montana'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 2: MEDICAL LEGAL PANEL (PRE-LITIGATION REQUIREMENT)
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, specialization, document_type,
    jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status,
    is_active, is_template, created_at, updated_at
)
VALUES (
    'MT-MED-MAL-MEDICAL-LEGAL-PANEL', 5,
    'MT Medical Malpractice: Mandatory Medical Legal Panel (MCA Title 27, Chapter 6)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'MT',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'filing_requirement',
        'statute', 'MCA § 27-6-101 et seq.',
        'requirement', 'Before filing a medical malpractice lawsuit in district court, a claimant must first submit the claim to the Montana Medical Legal Panel (MMLP) for review',
        'panel_composition', 'Three-member panel: one attorney, one physician, one lay member',
        'panel_process', jsonb_build_array(
            'Claimant files application with MMLP Director',
            'Panel conducts hearing; both parties present evidence',
            'Panel issues decision (for or against claimant) — not binding on court',
            'Either party may proceed to district court regardless of panel outcome'
        ),
        'tolling', 'SOL is tolled from the date the director receives the application until 30 days after the final panel decision is served (MCA § 27-6-702)',
        'panel_decision_admissible', 'Panel decision is admissible in subsequent court proceedings as evidence',
        'failure_to_submit', 'Filing suit without first submitting to MMLP is a procedural defect; case may be stayed',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('MCA § 27-6-101', 'MCA § 27-6-702', 'Montana Judicial Branch'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 3: DAMAGE CAPS
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, specialization, document_type,
    jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status,
    is_active, is_template, created_at, updated_at
)
VALUES (
    'MT-MED-MAL-DAMAGE-CAPS', 5,
    'MT Medical Malpractice: Non-Economic Damage Cap $250,000 (MCA § 25-9-411)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'MT',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'damages_rule',
        'statute', 'MCA § 25-9-411',
        'caps_apply', true,
        'non_economic_cap', 250000,
        'annual_adjustment', false,
        'cap_notes', 'Flat $250,000 cap on non-economic damages (pain, suffering, inconvenience, emotional distress, loss of society/companionship) in medical malpractice actions; cap has remained static since enactment',
        'economic_damages', 'No cap — past and future medical expenses, lost wages, and economic losses are fully recoverable',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('MCA § 25-9-411', 'Justia Montana 2024'),
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
    'MT-MED-MAL-SOL-2-YEARS', 5,
    'MT Medical Malpractice: Statute of Limitations 2 Years (MCA § 27-2-205)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'MT',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'timeliness_rule',
        'statute', 'MCA § 27-2-205',
        'sol_period', '2 years',
        'trigger', 'Date of injury OR date plaintiff discovered or reasonably should have discovered the injury (discovery rule)',
        'discovery_rule', true,
        'repose_period', '5 years from date of act or omission (absolute bar except for fraud/concealment)',
        'minor_rule', 'If plaintiff is under 4 years old at time of injury, SOL runs until the minor reaches age 8; otherwise standard 2-year rule applies',
        'wrongful_death', '3 years from date of death (MCA § 27-2-204)',
        'tolling', jsonb_build_array(
            'MMLP panel proceedings: tolled from application submission to 30 days after final panel decision',
            'Legal disability (minority as specified, mental incapacity)',
            'Fraudulent concealment by defendant'
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('MCA § 27-2-205', 'MCA § 27-2-204', 'MCA § 27-6-702'),
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
    'MT-MED-MAL-MODIFIED-COMPARATIVE', 5,
    'MT Medical Malpractice: Modified Comparative Fault 50% Bar (MCA § 27-1-702)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'MT',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'negligence_model',
        'statute', 'MCA § 27-1-702',
        'negligence_model', 'modified_comparative',
        'complete_bar', true,
        'bar_threshold', '50%',
        'rule_description', 'Montana follows modified comparative fault with a 50% bar — plaintiff may recover only if their fault is 50% or less; if plaintiff is more than 50% at fault, recovery is completely barred',
        'damages_reduction', 'If plaintiff is 50% or less at fault, damages are reduced proportionally by plaintiff''s percentage of fault',
        'joint_several_liability', 'Montana abolished joint and several liability in 1995; each defendant liable only for their proportionate share',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('MCA § 27-1-702', 'Montana comparative fault case law'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();
