-- =====================================================
-- Nevada (NV) Medical Malpractice Rules
-- Enhanced Verification Protocol v2.0
-- =====================================================
-- State: Nevada
-- Governing Law: NRS Chapter 41A (Medical Malpractice)
-- Negligence Model: MODIFIED COMPARATIVE (51% bar) — NRS § 41.141
-- SOL: 2 years from discovery (for injuries on/after Oct 1, 2023); 3-year outer limit (NRS § 41A.097)
-- Damage Caps: Non-economic cap escalating annually: $430K (2024) → $750K (2028)
--              then 2.1% CPI annually (NRS § 41A.035, amended 2023)
-- Expert: Expert testimony required; affidavit of merit for merit screening
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
    'NV-MED-MAL-STANDARD-OF-CARE', 5,
    'NV Medical Malpractice: Standard of Care (NRS § 41A.100)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'NV',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'contextual_rule',
        'statute', 'NRS § 41A.100',
        'standard_text', 'A provider of health care is liable for negligence only if the provider failed to exercise the degree of care, skill, and treatment which, in light of all relevant surrounding circumstances, is recognized as acceptable and appropriate by reasonably prudent similar providers of health care',
        'key_elements', jsonb_build_array(
            'Duty: provider-patient relationship must be established',
            'Breach: failure to meet standard of a reasonably prudent similar provider',
            'Causation: breach was proximate cause of plaintiff''s injury',
            'Damages: actual harm (economic or non-economic) resulted'
        ),
        'locality_rule', 'Nevada applies a statewide professional standard; no strict locality rule',
        'informed_consent', 'Available; provider must disclose material risks a reasonable patient would want to know',
        'res_ipsa', 'Available under NRS § 41A.100(1)(b) — presumption of negligence applies in cases where negligence is obvious',
        'nrs_presumption', 'NRS § 41A.100 creates a rebuttable presumption of negligence in foreign body, wrong patient, wrong procedure, or wrong site cases',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('NRS § 41A.100', 'Nevada Medical Malpractice Act', 'Justia Nevada'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 2: EXPERT REQUIREMENTS / AFFIDAVIT
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, specialization, document_type,
    jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status,
    is_active, is_template, created_at, updated_at
)
VALUES (
    'NV-MED-MAL-EXPERT-REQUIREMENTS', 5,
    'NV Medical Malpractice: Expert Requirements (NRS § 41A.100)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'NV',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'filing_requirement',
        'statute', 'NRS § 41A.100',
        'requirement', 'Expert testimony is required to establish the applicable standard of care and its breach in medical malpractice cases; no separate mandatory pre-filing affidavit statute exists, but courts apply merit screening',
        'no_separate_prefiling_affidavit', true,
        'trial_expert_required', 'Expert testimony required at trial to establish: (1) applicable standard of care, (2) breach of that standard, and (3) causation of plaintiff''s injury',
        'expert_qualifications', jsonb_build_object(
            'same_specialty', 'Must practice in the same specialty or a substantially similar specialty as the defendant',
            'active_practice', 'Must be in active clinical practice or teaching in the relevant specialty',
            'licensed', 'Must be licensed in Nevada or another state'
        ),
        'res_ipsa_cases', 'In cases involving NRS § 41A.100(1)(b) presumptions (wrong-site, wrong patient, foreign body, wrong procedure), expert may not be required to establish negligence',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('NRS § 41A.100', 'Clark County Bar NV guide', 'Tavrn NV caps 2025'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 3: NON-ECONOMIC DAMAGE CAPS (ESCALATING)
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, specialization, document_type,
    jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status,
    is_active, is_template, created_at, updated_at
)
VALUES (
    'NV-MED-MAL-DAMAGE-CAPS', 5,
    'NV Medical Malpractice: Escalating Non-Economic Damage Caps (NRS § 41A.035)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'NV',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'damages_rule',
        'statute', 'NRS § 41A.035',
        'caps_apply', true,
        'cap_schedule', jsonb_build_object(
            '2024', 430000,
            '2025', 510000,
            '2026', 590000,
            '2027', 670000,
            '2028', 750000,
            '2029_onwards', 'Annual CPI adjustment of 2.1% from $750,000 base'
        ),
        'current_cap_2024', 430000,
        'annual_increase', 80000,
        'final_cap_2028', 750000,
        'post_2028_adjustment', '2.1% annual CPI adjustment',
        'cap_notes', 'Original 2004 voter initiative cap was $350,000; amended by 2023 legislature (AB 404) to escalate $80,000 annually from 2024 to 2028, then CPI-indexed; applies to non-economic damages only',
        'economic_damages', 'No cap — medical expenses, lost wages, future economic losses fully recoverable',
        'emergency_care', 'Separate lower cap may apply for emergency care providers',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('NRS § 41A.035', 'Clark County Bar NV 2024', 'Tavrn NV caps 2025'),
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
    'NV-MED-MAL-SOL-2-YEARS', 5,
    'NV Medical Malpractice: Statute of Limitations 2 Years (NRS § 41A.097)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'NV',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'timeliness_rule',
        'statute', 'NRS § 41A.097',
        'sol_period', '2 years',
        'trigger', 'Date plaintiff discovered or through reasonable diligence should have discovered the injury (discovery rule); applies to injuries occurring on or after October 1, 2023',
        'prior_law', 'For injuries before October 1, 2023: 1-year SOL from discovery (amended by 2023 legislature AB 404)',
        'discovery_rule', true,
        'repose_period', '3 years from date of the act or omission (absolute bar regardless of discovery)',
        'minor_rule', 'SOL tolled for minors until age 18; subject to 3-year repose from act',
        'foreign_object', 'Discovery rule applies; SOL runs from date foreign object discovered',
        'wrongful_death', '2 years from date of death',
        'verification', jsonb_build_object(
            'statute_verified', false,
            'sources', jsonb_build_array('NRS § 41A.097', 'Clark County Bar NV 2024', 'AB 404 Nevada 2023'),
            'confidence', 'medium'
        ),
        'protocol_v3_flag', jsonb_build_object(
            'flagged_by',        'protocol_v3_dual_pass',
            'flag_date',         '2026-03-02',
            'pass1_result',      'INCONCLUSIVE - NRS 41A.097 amended by AB 404 (2023). Seed claims 2yr from discovery + 3yr repose. Pre-2023 was 1yr. Need attorney confirmation that AB 404 changed SOL to 2yr from discovery.',
            'pass2_result',      'INCONCLUSIVE - AB 404 (2023) appears to extend SOL from 1yr to 2yr for injuries on/after Oct 1 2023. Corroboration limited to secondary sources. Primary statute text not independently verified.',
            'attorney_question', 'Confirm NRS 41A.097 post-AB 404 (2023): is SOL 2yr from discovery with 3yr absolute repose? Confirm effective date Oct 1 2023. If correct, update statute_verified=true and move to document_verified.',
            'priority',          'HIGH'
        )
    ),
    'error', 'needs_review', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    review_status    = EXCLUDED.review_status,
    updated_at       = NOW();

-- RULE 5: MODIFIED COMPARATIVE FAULT (51% BAR)
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, specialization, document_type,
    jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status,
    is_active, is_template, created_at, updated_at
)
VALUES (
    'NV-MED-MAL-MODIFIED-COMPARATIVE', 5,
    'NV Medical Malpractice: Modified Comparative Fault 51% Bar (NRS § 41.141)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'NV',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'negligence_model',
        'statute', 'NRS § 41.141',
        'negligence_model', 'modified_comparative',
        'complete_bar', true,
        'bar_threshold', '51%',
        'rule_description', 'Nevada follows modified comparative fault with a 51% bar — plaintiff may recover only if their fault is 50% or less; if plaintiff is 51% or more at fault, recovery is completely barred',
        'damages_reduction', 'If plaintiff is 50% or less at fault, damages are reduced proportionally by plaintiff''s percentage of fault',
        'joint_several_liability', 'Nevada generally allows proportionate liability; joint and several liability applies only in limited circumstances',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('NRS § 41.141', 'Justia Nevada', 'Nevada comparative fault case law'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();
