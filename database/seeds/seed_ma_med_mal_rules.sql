-- =====================================================
-- Massachusetts (MA) Medical Malpractice Rules
-- Enhanced Verification Protocol v2.0
-- =====================================================
-- State: Massachusetts
-- Governing Law: MGL c. 231 § 60B (Tribunal), c. 260 § 4 (SOL), c. 231 § 85 (comparative fault)
-- Negligence Model: PURE COMPARATIVE FAULT — MGL c. 231 § 85
-- SOL: 3 years from discovery; 7-year repose (MGL c. 260 § 4)
-- Damage Caps: NO caps on damages in medical malpractice
-- Expert: Medical Malpractice Tribunal mandatory pre-trial (MGL c. 231 § 60B)
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
    'MA-MED-MAL-STANDARD-OF-CARE', 5,
    'MA Medical Malpractice: Standard of Care (MGL c. 112 § 5, common law)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'MA',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'contextual_rule',
        'statute', 'MGL c. 112 § 5 and common law',
        'standard_text', 'A healthcare provider must exercise the degree of care and skill of the average qualified practitioner in the same or similar specialty, taking into account the advances of the profession',
        'key_elements', jsonb_build_array(
            'Duty: provider-patient relationship',
            'Breach: failure to meet standard of average qualified practitioner in same specialty',
            'Causation: breach proximately caused injury',
            'Damages: actual injury resulted'
        ),
        'locality_rule', 'Massachusetts applies a national standard for specialists; not a strict locality rule',
        'tribunal_requirement', 'Expert must provide evidence of breach through tribunal offer of proof (MGL c. 231 § 60B)',
        'informed_consent', 'Separate theory; reasonable patient standard — provider must disclose risks that would be material to a reasonable patient',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('MGL c. 112 § 5', 'Massachusetts Medical Malpractice Tribunal MassMed.org', 'Muccilaw.com Massachusetts Med Mal'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 2: MEDICAL MALPRACTICE TRIBUNAL (MANDATORY PRE-TRIAL)
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, specialization, document_type,
    jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status,
    is_active, is_template, created_at, updated_at
)
VALUES (
    'MA-MED-MAL-TRIBUNAL-REQUIREMENT', 5,
    'MA Medical Malpractice: Mandatory Tribunal Pre-Trial Screening (MGL c. 231 § 60B)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'MA',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'hard_rule',
        'statute', 'MGL c. 231 § 60B',
        'requirement', 'After complaint is filed, case is referred to a 3-member tribunal for pre-trial screening',
        'tribunal_composition', jsonb_build_array(
            'Superior Court Justice (presiding)',
            'A physician from the relevant medical specialty (chosen from Mass. Medical Society list)',
            'An attorney (chosen from bar association list)',
            'Physician must practice outside the county of the defendant'
        ),
        'tribunal_standard', 'Plaintiff must present substantial evidence that raises a legitimate question of liability sufficient to send case to jury',
        'offer_of_proof', 'Plaintiff submits written offer of proof including medical records, expert opinions, and other evidence',
        'failure_consequence', 'If tribunal finds insufficient evidence, plaintiff must post bond of $6,000 (or more) to proceed; otherwise case is dismissed',
        'timeline', 'Tribunal must convene within 15 days after defendant files answer',
        'does_not_decide_case', 'Tribunal determines only whether evidence is sufficient; does not decide ultimate liability',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('MGL c. 231 § 60B', 'MassMed.org Tribunal Standard', 'BrandonBroderick.com MA Tribunal Process'),
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
    'MA-MED-MAL-NO-DAMAGE-CAPS', 5,
    'MA Medical Malpractice: No Damage Caps — Full Recovery Available',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'MA',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'hard_rule',
        'current_rule', 'Massachusetts does not impose caps on compensatory damages in medical malpractice cases',
        'economic_damages', 'Fully recoverable (medical expenses, lost wages, future care)',
        'non_economic_damages', 'No statutory cap on pain and suffering, emotional distress, or loss of consortium',
        'punitive_damages', 'Punitive damages available under MGL c. 229 § 2 (wrongful death) and other theories for willful/reckless conduct',
        'cap_notes', jsonb_build_array(
            'No non-economic damage cap in Massachusetts',
            'No economic damage cap',
            'Full jury-determined compensatory damages recoverable',
            'Legislature has considered caps but none enacted'
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('MGL c. 260 § 4', 'Muccilaw.com Massachusetts Med Mal', 'BrandonBroderick.com MA Tribunal 2024'),
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
    'MA-MED-MAL-SOL-3-YEARS', 5,
    'MA Medical Malpractice: 3-Year SOL, 7-Year Repose (MGL c. 260 § 4)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'MA',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'hard_rule',
        'statute', 'MGL c. 260 § 4',
        'sol_period', '3 years from date of the alleged malpractice or from date of discovery',
        'repose_period', '7 years from date of negligent act — absolute bar (except foreign objects)',
        'discovery_rule', 'SOL runs from date plaintiff discovers or should have discovered the malpractice',
        'foreign_object_exception', 'No 7-year bar for foreign objects left in body; SOL runs from discovery',
        'minor_exception', 'Minors: SOL does not run until minor reaches majority (18)',
        'tolling', jsonb_build_array(
            'Foreign objects exception to 7-year repose',
            'Minor exception (SOL runs from age 18)',
            'Fraudulent concealment tolls SOL',
            'Mental incapacity may toll SOL'
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('MGL c. 260 § 4', 'Casetext MGL c. 260 § 4', 'Muccilaw.com Massachusetts Med Mal'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 5: PURE COMPARATIVE FAULT
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, specialization, document_type,
    jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status,
    is_active, is_template, created_at, updated_at
)
VALUES (
    'MA-MED-MAL-PURE-COMPARATIVE-FAULT', 5,
    'MA Medical Malpractice: Pure Comparative Fault (MGL c. 231 § 85)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'MA',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'contextual_rule',
        'statute', 'MGL c. 231 § 85',
        'negligence_model', 'pure_comparative',
        'bar_threshold', 'None — plaintiff may recover regardless of fault percentage',
        'rule_description', 'Plaintiff recovery reduced proportionally by their fault percentage; no bar at any level of plaintiff fault',
        'complete_bar', 'No — Massachusetts pure comparative fault; plaintiff always recovers their proportionate share',
        'joint_several', 'Massachusetts: modified joint and several liability; defendant with 10%+ fault jointly liable for economic damages',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('MGL c. 231 § 85', 'MassMed.org Tribunal Standard', 'Superior Court Rule 73'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();
