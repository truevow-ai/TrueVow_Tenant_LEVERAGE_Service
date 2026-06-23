-- =====================================================
-- Indiana (IN) Medical Malpractice Rules
-- Enhanced Verification Protocol v2.0
-- =====================================================
-- State: Indiana
-- Governing Law: Indiana Medical Malpractice Act (IC Title 34 Article 18)
-- Negligence Model: MODIFIED COMPARATIVE (51% bar) — IC § 34-51-2
-- SOL: 2 years from act of malpractice (IC § 34-18-7-1)
-- Damage Caps: Total $1.8M; provider liability capped $500k (IC § 34-18-14-3 post-June 2019)
-- Expert: Medical Review Panel mandatory pre-suit (IC § 34-18-8)
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
    'IN-MED-MAL-STANDARD-OF-CARE', 5,
    'IN Medical Malpractice: Standard of Care (IC § 34-18-2-14)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'IN',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'contextual_rule',
        'statute', 'IC § 34-18-2-14',
        'standard_text', 'Malpractice means any tort or breach of contract based on health care or professional services rendered, or that should have been rendered, by a health care provider, to a patient',
        'key_elements', jsonb_build_array(
            'Duty: provider-patient relationship',
            'Breach: failure to exercise the level of care, skill, and treatment expected of a reasonable prudent health care provider in the specialty',
            'Causation: breach proximately caused injury',
            'Damages: actual harm resulted'
        ),
        'locality_rule', 'Indiana applies a statewide national standard for specialists; local standard may apply for general practitioners',
        'informed_consent', 'Separate theory; must prove failure to disclose material risk',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('IC § 34-18-2-14', 'Indiana Medical Malpractice Act', 'Justia Indiana 2024'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 2: MEDICAL REVIEW PANEL (MANDATORY PRE-SUIT)
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, specialization, document_type,
    jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status,
    is_active, is_template, created_at, updated_at
)
VALUES (
    'IN-MED-MAL-MEDICAL-REVIEW-PANEL', 5,
    'IN Medical Malpractice: Mandatory Medical Review Panel Pre-Suit (IC § 34-18-8)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'IN',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'hard_rule',
        'statute', 'IC § 34-18-8-1',
        'requirement', 'Before filing suit in court, claimant must submit proposed complaint to Medical Review Panel for evaluation',
        'panel_composition', jsonb_build_array(
            'Three healthcare providers from same specialty as defendant',
            'One neutral attorney chairperson',
            'Panel reviews medical evidence and issues advisory opinion'
        ),
        'panel_opinion', 'Panel issues opinion on whether evidence supports conclusion that defendant failed to meet standard of care',
        'admissibility', 'Panel opinion is admissible at trial but not conclusive; either party may call panel members as witnesses',
        'sol_tolling', 'SOL is tolled from date proposed complaint is filed with Medical Review Panel until 90 days after panel opinion',
        'exceptions', jsonb_build_array(
            'Emergency injunctive relief may be sought without prior panel review',
            'Small claims excluded in certain circumstances'
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('IC § 34-18-8-1', 'Powless Law Indiana Medical Review Panel', 'Justia Indiana 2024'),
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
    'IN-MED-MAL-DAMAGE-CAPS', 5,
    'IN Medical Malpractice: Damage Caps — Total $1.8M, Provider $500k (IC § 34-18-14-3)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'IN',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'hard_rule',
        'statute', 'IC § 34-18-14-3',
        'total_cap', '$1,800,000 total maximum recovery for occurrences after June 30, 2019',
        'provider_liability_cap', '$500,000 maximum direct liability against health care provider (occurrences after June 30, 2019)',
        'patients_compensation_fund', 'Patient Compensation Fund pays excess above provider cap up to total $1.8M cap',
        'historical_caps', jsonb_build_array(
            'Before July 1, 2017: provider cap $250,000; total cap $1,250,000',
            'July 1, 2017 through June 30, 2019: provider cap $400,000; total cap $1,600,000',
            'After June 30, 2019: provider cap $500,000; total cap $1,800,000'
        ),
        'minor_exception', 'Minors under 6: SOL runs until 8th birthday (IC § 34-18-7-1)',
        'cap_applies_to', 'Cap applies to all damages — economic and non-economic combined',
        'punitive_damages', 'Punitive damages not available in most medical malpractice cases; Act generally limits recovery',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('IC § 34-18-14-3', 'MedMalPractice.law Indiana Caps 2025', 'Justia Indiana 2024'),
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
    'IN-MED-MAL-SOL-2-YEARS', 5,
    'IN Medical Malpractice: 2-Year SOL (IC § 34-18-7-1)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'IN',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'hard_rule',
        'statute', 'IC § 34-18-7-1',
        'sol_period', '2 years from the date of the alleged act, omission, or neglect',
        'occurrence_rule', 'Indiana uses an occurrence rule — SOL runs from date of malpractice, not discovery',
        'minor_exception', 'Minors under 6: SOL does not expire before minor reaches age 8',
        'panel_tolling', 'SOL tolled from filing proposed complaint with Medical Review Panel until 90 days after panel opinion',
        'tolling', jsonb_build_array(
            'Medical Review Panel tolling (IC § 34-18-7-3)',
            'Minor exception for children under 6',
            'Fraudulent concealment: limited application under Indiana law'
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('IC § 34-18-7-1', 'Justia Indiana Title 34 Article 18', 'MedMalPractice.law Indiana 2025'),
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
    'IN-MED-MAL-MODIFIED-COMPARATIVE', 5,
    'IN Medical Malpractice: Modified Comparative Fault 51% Bar (IC § 34-51-2-6)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'IN',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'contextual_rule',
        'statute', 'IC § 34-51-2-6',
        'negligence_model', 'modified_comparative',
        'bar_threshold', '51%',
        'rule_description', 'Plaintiff may recover if fault does not exceed 51%; damages reduced by plaintiff fault percentage',
        'complete_bar', 'Yes — plaintiff barred if found more than 51% (more than 50%) at fault',
        'joint_several', 'Indiana: proportionate liability; defendants liable for their individual share of fault',
        'fault_allocation', 'Jury apportions fault among all parties; total damages then reduced by plaintiff percentage',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('IC § 34-51-2-6', 'Justia Indiana Title 34 Article 51', 'Indiana Personal Injury Law — Lawsuit Information Center'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();
