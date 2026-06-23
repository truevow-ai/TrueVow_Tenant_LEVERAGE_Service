-- =====================================================
-- New Hampshire (NH) Medical Malpractice Rules
-- Enhanced Verification Protocol v2.0
-- =====================================================
-- State: New Hampshire
-- Governing Law: RSA Chapter 507-E (Actions Against Health Care Providers)
-- Negligence Model: MODIFIED COMPARATIVE (51% bar) — RSA § 507:7-d
-- SOL: 3 years from discovery (RSA § 508:4) — general personal injury SOL applies
-- Damage Caps: NO CAPS on damages in NH medical malpractice
-- Expert: No mandatory pre-filing affidavit; expert testimony required at trial
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
    'NH-MED-MAL-STANDARD-OF-CARE', 5,
    'NH Medical Malpractice: Standard of Care (RSA § 507-E:2; RSA § 508:13)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'NH',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'contextual_rule',
        'statute', 'RSA § 507-E:2',
        'standard_text', 'In evaluating a medical malpractice claim, the jury or trier of fact is not restricted to local standards; they must consider whether the accused acted with due care based on the general standards, practices, and procedures of the profession, alongside the practitioner''s training, experience, and skill level (RSA § 508:13)',
        'key_elements', jsonb_build_array(
            'Duty: provider-patient relationship must be established',
            'Breach: failure to act in accordance with professional standards of care',
            'Causation: breach was proximate cause of plaintiff''s injury',
            'Damages: actual harm (economic or non-economic) resulted'
        ),
        'locality_rule', 'NH applies a NATIONAL standard — not a local or statewide locality rule; jury considers professional standards nationwide (RSA § 508:13)',
        'informed_consent', 'Available; provider must disclose material risks a reasonable patient would want to know',
        'res_ipsa', 'Doctrine available in appropriate NH medical malpractice cases',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('RSA § 507-E:2', 'RSA § 508:13', 'Justia New Hampshire 2024'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 2: EXPERT WITNESS REQUIREMENTS (NO MANDATORY PRE-FILING AFFIDAVIT)
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, specialization, document_type,
    jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status,
    is_active, is_template, created_at, updated_at
)
VALUES (
    'NH-MED-MAL-EXPERT-REQUIREMENTS', 5,
    'NH Medical Malpractice: Expert Witness Requirements (RSA § 507-E:2)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'NH',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'filing_requirement',
        'statute', 'RSA § 507-E:2',
        'requirement', 'New Hampshire does NOT require a mandatory pre-filing expert affidavit to screen malpractice claims; expert testimony is required at trial to establish the standard of care and deviation',
        'no_mandatory_affidavit', true,
        'trial_expert_required', 'Expert testimony is generally required at trial to establish: (1) applicable standard of care, (2) how defendant deviated from that standard, and (3) that the deviation caused plaintiff''s injury',
        'expert_qualifications', jsonb_build_object(
            'same_or_similar_field', 'Must have knowledge and experience in the same or similar specialty',
            'national_standard', 'NH uses national standard — expert may be from any state',
            'active_practice', 'Must be qualified to testify to professional standards of care'
        ),
        'res_ipsa_exception', 'In limited cases where negligence is obvious, expert testimony may not be required',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('RSA § 507-E:2', 'AllLaw New Hampshire guide', 'Nolo New Hampshire guide'),
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
    'NH-MED-MAL-NO-DAMAGE-CAPS', 5,
    'NH Medical Malpractice: No Statutory Damage Caps',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'NH',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'damages_rule',
        'caps_apply', false,
        'non_economic_cap', null,
        'economic_cap', null,
        'cap_notes', 'New Hampshire imposes NO statutory cap on damages in medical malpractice cases — neither economic nor non-economic damages are limited; plaintiffs can seek full compensation for all losses',
        'constitutional_history', 'NH courts have consistently upheld the right to full recovery; legislature has not enacted damage caps unlike most other states',
        'economic_damages', 'Fully recoverable without limitation',
        'non_economic_damages', 'Fully recoverable without limitation',
        'punitive_damages', 'Generally not available in NH medical malpractice cases',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('AllLaw NH damages summary', 'Nolo NH guide', 'NH Law Office analysis 2022'),
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
    'NH-MED-MAL-SOL-3-YEARS', 5,
    'NH Medical Malpractice: Statute of Limitations 3 Years (RSA § 508:4)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'NH',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'timeliness_rule',
        'statute', 'RSA § 508:4',
        'sol_period', '3 years',
        'trigger', 'Date of the alleged malpractice, or date plaintiff discovered or reasonably should have discovered the injury (discovery rule)',
        'discovery_rule', true,
        'sol_notes', 'NH applies the general 3-year personal injury SOL to medical malpractice; there is no separate specific medical malpractice SOL statute following the NH Supreme Court''s ruling',
        'repose_period', 'No specific statute of repose for medical malpractice in NH',
        'minor_rule', 'Minors: SOL tolled until age 18; parent may also bring action on behalf of minor',
        'wrongful_death', '3 years from death or discovery (RSA § 556:11)',
        'tolling', jsonb_build_array(
            'Legal disability (minority, incompetency)',
            'Defendant leaves jurisdiction',
            'Discovery rule delays start of limitations period'
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('RSA § 508:4', 'RSA § 556:11', 'Sabbeth Law analysis 2025'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 5: MODIFIED COMPARATIVE FAULT (51% BAR)
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, specialization, document_type,
    jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status,
    is_active, is_template, created_at, updated_at
)
VALUES (
    'NH-MED-MAL-MODIFIED-COMPARATIVE', 5,
    'NH Medical Malpractice: Modified Comparative Fault 51% Bar (RSA § 507:7-d)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'NH',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'negligence_model',
        'statute', 'RSA § 507:7-d',
        'negligence_model', 'modified_comparative',
        'complete_bar', true,
        'bar_threshold', '51%',
        'rule_description', 'New Hampshire follows modified comparative fault with a 51% bar — plaintiff may recover only if their fault is 50% or less (not more than 50%); if plaintiff is 51% or more at fault, recovery is completely barred',
        'damages_reduction', 'If plaintiff is 50% or less at fault, damages are reduced proportionally by plaintiff''s percentage of fault',
        'joint_several_liability', 'New Hampshire retains joint and several liability; defendants who are jointly negligent remain jointly and severally liable for plaintiff''s damages',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('RSA § 507:7-d', 'Medical Malpractice Help NH guide', 'Justia New Hampshire'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();
