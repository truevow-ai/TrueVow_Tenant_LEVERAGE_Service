-- =====================================================
-- Maine (ME) Medical Malpractice Rules
-- Enhanced Verification Protocol v2.0
-- =====================================================
-- State: Maine
-- Governing Law: 24 M.R.S. §§ 2501-2984 (Maine Health Security Act)
-- Negligence Model: MODIFIED COMPARATIVE (50% bar) — 14 M.R.S. § 156
-- SOL: 3 years from discovery (24 M.R.S. § 2902)
-- Damage Caps: NO statutory caps on damages in medical malpractice
-- Expert: Pre-litigation screening panel required; expert testimony required
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
    'ME-MED-MAL-STANDARD-OF-CARE', 5,
    'ME Medical Malpractice: Standard of Care (24 M.R.S. § 2501)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'ME',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'contextual_rule',
        'statute', '24 M.R.S. § 2501',
        'standard_text', 'A healthcare provider must exercise the degree of care and skill that a reasonable prudent similar healthcare provider in the same or similar specialty would exercise under similar circumstances',
        'key_elements', jsonb_build_array(
            'Duty: provider-patient relationship',
            'Breach: failure to meet standard of reasonably prudent similar provider',
            'Causation: breach proximately caused injury',
            'Damages: actual injury resulted'
        ),
        'locality_rule', 'Maine applies a statewide standard; not a strict locality rule',
        'informed_consent', 'Separate theory; provider must disclose material risks',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('24 M.R.S. § 2501', 'Nolo Maine Medical Malpractice Laws', 'Gilman Bedigian Maine Med Mal'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 2: PRE-LITIGATION SCREENING PANEL
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, specialization, document_type,
    jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status,
    is_active, is_template, created_at, updated_at
)
VALUES (
    'ME-MED-MAL-PRELITIGATION-SCREENING', 5,
    'ME Medical Malpractice: Pre-Litigation Screening Panel Required (24 M.R.S. § 2853)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'ME',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'hard_rule',
        'statute', '24 M.R.S. § 2853',
        'requirement', 'Plaintiffs must submit claim to pre-litigation screening panel before filing suit in court',
        'panel_process', jsonb_build_array(
            'Panel reviews the evidence and hears from both parties',
            'Process resembles a mini-trial with both parties presenting evidence',
            'Panel issues advisory opinion on whether claim has merit',
            'Panel opinion is not binding but can be used in subsequent litigation'
        ),
        'notice_requirement', 'Plaintiff must file notice of claim before initiating prelitigation process',
        'purpose', 'To identify meritorious claims and encourage settlement before litigation',
        'expert_requirement', 'Expert testimony typically required to support prelitigation screening and subsequent litigation',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('24 M.R.S. § 2853', 'Nolo Maine Med Mal Laws', 'Expertise.com Maine Med Mal 2025'),
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
    'ME-MED-MAL-NO-DAMAGE-CAPS', 5,
    'ME Medical Malpractice: No Statutory Damage Caps',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'ME',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'hard_rule',
        'current_rule', 'Maine does not impose statutory caps on damages in medical malpractice cases',
        'economic_damages', 'Fully recoverable (medical expenses, lost wages, future care)',
        'non_economic_damages', 'No statutory cap on pain and suffering, emotional distress, or loss of consortium',
        'punitive_damages', 'Punitive damages available for egregious conduct; no statutory cap in med mal',
        'cap_notes', jsonb_build_array(
            'No non-economic damage cap in Maine medical malpractice',
            'Full compensatory damages recoverable as determined by jury',
            'Legislature has not enacted damage caps for medical malpractice'
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('Nolo Maine Medical Malpractice Laws', 'Gilman Bedigian Maine Med Mal Laws'),
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
    'ME-MED-MAL-SOL-3-YEARS', 5,
    'ME Medical Malpractice: 3-Year SOL (24 M.R.S. § 2902)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'ME',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'hard_rule',
        'statute', '24 M.R.S. § 2902',
        'sol_period', '3 years from date of the alleged negligent act or from date of discovery',
        'discovery_rule', 'SOL runs from date plaintiff discovers or should have discovered the injury and its causal connection',
        'foreign_object_exception', 'For foreign objects left in body: SOL begins when plaintiff discovers harm',
        'minor_exception', 'Minors: SOL extends to 6 years from the act or 3 years from discovery, whichever is longer',
        'tolling', jsonb_build_array(
            'Discovery rule applies',
            'Minor exceptions apply',
            'Fraudulent concealment may toll SOL'
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('24 M.R.S. § 2902', 'Nolo Maine Medical Malpractice Laws'),
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
    'ME-MED-MAL-MODIFIED-COMPARATIVE', 5,
    'ME Medical Malpractice: Modified Comparative Fault 50% Bar (14 M.R.S. § 156)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'ME',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'contextual_rule',
        'statute', '14 M.R.S. § 156',
        'negligence_model', 'modified_comparative',
        'bar_threshold', '50%',
        'rule_description', 'Plaintiff may recover if fault does not exceed 50%; damages reduced by plaintiff fault percentage',
        'complete_bar', 'Yes — plaintiff barred if found 50% or more at fault',
        'joint_several', 'Maine proportionate several liability; each defendant liable for their share of fault',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('14 M.R.S. § 156', 'Expertise.com Maine Med Mal 2025', 'MedicalMalpracticeHelp.com Maine'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();
