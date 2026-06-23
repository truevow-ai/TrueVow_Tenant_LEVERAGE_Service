-- =====================================================
-- New Mexico (NM) Medical Malpractice Rules
-- Enhanced Verification Protocol v2.0
-- =====================================================
-- State: New Mexico
-- Governing Law: NMSA §§ 41-5-1 to 41-5-29 (New Mexico Medical Malpractice Act)
-- Negligence Model: PURE COMPARATIVE FAULT — NMSA § 41-3A-1
-- SOL: 3 years from occurrence (occurrence statute) — NMSA § 41-5-13
-- Damage Caps: Tiered recovery caps per occurrence (NMSA § 41-5-6):
--   Independent providers: $750,000 (2023+, CPI-adjusted)
--   Independent outpatient facilities: $1,000,000 (2024+, CPI-adjusted)
--   Hospitals: escalating caps (not including punitive or medical care benefits)
-- Pre-Litigation: Patient's Compensation Fund/Medical Review Commission review
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
    'NM-MED-MAL-STANDARD-OF-CARE', 5,
    'NM Medical Malpractice: Standard of Care (NMSA § 41-5-3)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'NM',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'contextual_rule',
        'statute', 'NMSA § 41-5-3',
        'standard_text', 'A health care provider is not liable for personal injury or death arising out of health care unless it is established that the health care provider failed to act in accordance with the recognized standard of health care',
        'key_elements', jsonb_build_array(
            'Duty: provider-patient relationship must be established',
            'Breach: failure to act in accordance with recognized standard of health care',
            'Causation: failure was the proximate cause of plaintiff''s injury or death',
            'Damages: actual harm resulted'
        ),
        'recognized_standard', 'Expert testimony required to establish the recognized standard of health care in the community',
        'informed_consent', 'Available; provider must obtain informed consent prior to treatment or procedure',
        'res_ipsa', 'Doctrine available in NM where injury is of the kind that does not ordinarily occur without negligence',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('NMSA § 41-5-3', 'New Mexico Medical Malpractice Act', 'Justia New Mexico'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 2: MEDICAL REVIEW COMMISSION (PRE-LITIGATION PANEL)
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, specialization, document_type,
    jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status,
    is_active, is_template, created_at, updated_at
)
VALUES (
    'NM-MED-MAL-MEDICAL-REVIEW-COMMISSION', 5,
    'NM Medical Malpractice: Medical Review Commission (NMSA § 41-5-14)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'NM',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'filing_requirement',
        'statute', 'NMSA § 41-5-14',
        'requirement', 'For claims against providers participating in the Patient''s Compensation Fund, plaintiff must submit the claim to the Medical Review Commission (MRC) before proceeding to court; MRC review is mandatory for qualifying health care providers',
        'panel_composition', 'Consists of physicians, attorneys, and lay members; reviews submitted medical records and expert opinions',
        'panel_process', jsonb_build_array(
            'Claimant submits application to MRC with supporting materials',
            'MRC panel reviews evidence from both parties',
            'Panel issues advisory opinion (not binding on court)',
            'Either party may proceed to district court after MRC opinion'
        ),
        'patient_compensation_fund', 'Qualifying providers must participate in NM Patient''s Compensation Fund; Fund pays damages above provider''s retained limit up to statutory cap',
        'non_qualifying_providers', 'Independent providers and facilities not in PCF are subject to direct suit without MRC review',
        'tolling', 'SOL is tolled during MRC proceedings',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('NMSA § 41-5-14', 'NMSA § 41-5-25', 'Fine Law Firm NM analysis 2024'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 3: TIERED DAMAGE CAPS
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, specialization, document_type,
    jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status,
    is_active, is_template, created_at, updated_at
)
VALUES (
    'NM-MED-MAL-DAMAGE-CAPS', 5,
    'NM Medical Malpractice: Tiered Recovery Caps (NMSA § 41-5-6)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'NM',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'damages_rule',
        'statute', 'NMSA § 41-5-6',
        'caps_apply', true,
        'cap_structure', 'tiered_by_provider_type',
        'independent_provider_cap_2023_plus', 750000,
        'independent_outpatient_facility_cap_2024_plus', 1000000,
        'hospital_cap_2022', 4000000,
        'hospital_cap_2023', 4500000,
        'annual_adjustment', true,
        'adjustment_basis', 'Consumer Price Index adjustment starting 2025 for independent providers; 2026 for hospitals',
        'cap_notes', 'Caps apply per occurrence regardless of number of claimants or defendants; caps DO NOT include punitive damages or past/future medical care and related benefits — those are recoverable in addition to the cap',
        'punitive_damages', 'Not included in cap; separately recoverable if defendant acted with conscious disregard of patient safety',
        'medical_care_benefits', 'Past and future medical care costs excluded from cap; fully recoverable separately',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('NMSA § 41-5-6', 'Fine Law Firm NM 2024 analysis', 'Justia New Mexico 2024'),
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
    'NM-MED-MAL-SOL-3-YEARS', 5,
    'NM Medical Malpractice: Statute of Limitations 3 Years (NMSA § 41-5-13)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'NM',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'timeliness_rule',
        'statute', 'NMSA § 41-5-13',
        'sol_period', '3 years',
        'trigger', 'Date of the occurrence (act or omission) — NM uses an OCCURRENCE-BASED statute, NOT a discovery rule for the primary period',
        'discovery_rule', false,
        'occurrence_based', true,
        'minor_rule', 'If plaintiff is a minor or incapacitated, SOL extended to 1 year after reaching majority or regaining competency',
        'wrongful_death', '3 years from date of death',
        'tolling', jsonb_build_array(
            'MRC proceedings: SOL tolled during Medical Review Commission review',
            'Legal disability (minority, incompetency)',
            'Fraudulent concealment by defendant'
        ),
        'sol_notes', 'NM Medical Malpractice Act creates an occurrence-based SOL, which is generally stricter than discovery-rule states; adding new parties does not relate back to original filing date',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('NMSA § 41-5-13', 'Branch Law Firm NM analysis', 'Justia New Mexico 2024'),
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
    'NM-MED-MAL-PURE-COMPARATIVE-FAULT', 5,
    'NM Medical Malpractice: Pure Comparative Fault (NMSA § 41-3A-1)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'NM',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'negligence_model',
        'statute', 'NMSA § 41-3A-1',
        'negligence_model', 'pure_comparative',
        'complete_bar', false,
        'bar_threshold', 'none',
        'rule_description', 'New Mexico follows pure comparative fault — plaintiff may recover even if predominantly at fault; damages are reduced proportionally by plaintiff''s percentage of fault',
        'joint_several_liability', 'New Mexico abolished joint and several liability; each defendant liable only for their proportionate share of fault (NMSA § 41-3A-1)',
        'multiple_defendants', 'Fault apportioned among all parties including settling and immune parties; jury assigns percentages',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('NMSA § 41-3A-1', 'New Mexico comparative fault case law', 'Justia New Mexico'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();
