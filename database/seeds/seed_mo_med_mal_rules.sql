-- =====================================================
-- Missouri (MO) Medical Malpractice Rules
-- Enhanced Verification Protocol v2.0
-- =====================================================
-- State: Missouri
-- Governing Law: RSMo Chapter 538 (Missouri Tort Reform Act)
-- Negligence Model: PURE COMPARATIVE FAULT — RSMo § 537.765
-- SOL: 2 years discovery rule; 10-year limit for minors (RSMo § 516.105)
-- Damage Caps: Non-economic caps indexed annually (RSMo § 538.210);
--              2025: ~$473,444 non-catastrophic; ~$828,529 catastrophic/wrongful death
--              Economic damages uncapped
-- Expert: Expert testimony required; affidavit of merit within 90 days (RSMo § 538.225)
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
    'MO-MED-MAL-STANDARD-OF-CARE', 5,
    'MO Medical Malpractice: Standard of Care (RSMo § 538.210)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'MO',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'contextual_rule',
        'statute', 'RSMo § 538.210',
        'standard_text', 'A healthcare provider shall use that degree of care and skill which is ordinarily used under the same or similar circumstances by a reasonably careful, skillful, and prudent health care provider',
        'key_elements', jsonb_build_array(
            'Duty: provider-patient relationship established',
            'Breach: failure to meet reasonably careful, skillful, prudent provider standard',
            'Causation: breach was the proximate cause of harm (RSMo § 538.210(1))',
            'Damages: economic and/or non-economic harm resulted'
        ),
        'causation_standard', 'Proximate cause required; Missouri applies the "but for" causation test in most med_mal cases',
        'res_ipsa', 'Available in Missouri where injury speaks for itself (e.g., foreign objects, wrong-site surgery)',
        'informed_consent', 'Separate theory under RSMo § 431.058; provider must disclose material risks a reasonable patient would want to know',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('RSMo § 538.210', 'Missouri Tort Reform Act', 'Justia Missouri'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 2: AFFIDAVIT OF MERIT / EXPERT REQUIREMENTS
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, specialization, document_type,
    jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status,
    is_active, is_template, created_at, updated_at
)
VALUES (
    'MO-MED-MAL-AFFIDAVIT-OF-MERIT', 5,
    'MO Medical Malpractice: Affidavit of Merit Requirement (RSMo § 538.225)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'MO',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'filing_requirement',
        'statute', 'RSMo § 538.225',
        'requirement', 'Plaintiff must file an affidavit stating that the plaintiff has obtained the written opinion of a legally qualified health care provider stating that the defendant failed to use such care as a reasonably careful and prudent health care provider would have under similar circumstances',
        'deadline', '90 days after filing the petition; court may grant one 90-day extension for good cause',
        'qualified_expert', jsonb_build_object(
            'same_or_similar_specialty', true,
            'licensed_requirement', 'Must be licensed in Missouri or a contiguous state, or be otherwise qualified',
            'active_practice', 'Must be in active practice or recently retired'
        ),
        'failure_consequence', 'Failure to file dismissal of the action',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('RSMo § 538.225', 'Missouri Courts', 'Justia Missouri'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 3: DAMAGE CAPS (NON-ECONOMIC, ANNUALLY INDEXED)
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, specialization, document_type,
    jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status,
    is_active, is_template, created_at, updated_at
)
VALUES (
    'MO-MED-MAL-DAMAGE-CAPS', 5,
    'MO Medical Malpractice: Non-Economic Damage Caps (RSMo § 538.210)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'MO',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'damages_rule',
        'statute', 'RSMo § 538.210(2)',
        'caps_apply', true,
        'non_economic_cap_non_catastrophic', 473444,
        'non_economic_cap_catastrophic', 828529,
        'cap_year', 2025,
        'annual_adjustment', true,
        'adjustment_basis', 'Indexed to Consumer Price Index (CPI) annually beginning January 1, 2016',
        'catastrophic_definition', 'Quadriplegia, paraplegia, loss of two or more limbs, significant and permanent cognitive impairment',
        'wrongful_death_cap', 828529,
        'economic_damages', 'No cap — medical expenses, lost wages, future care costs fully recoverable',
        'cap_notes', 'Non-economic caps were declared unconstitutional in 2012 (Watts v. Cox Medical Centers) but reinstated by legislature via RSMo § 538.210 amendment effective August 28, 2015',
        'multiple_defendants', 'Cap applies per plaintiff, not per defendant; 50% fault threshold for joint/several liability',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('RSMo § 538.210', 'Watts v. Cox Medical Centers (Mo. 2012)', 'Missouri legislature 2015 amendment'),
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
    'MO-MED-MAL-SOL-2-YEARS', 5,
    'MO Medical Malpractice: Statute of Limitations 2 Years (RSMo § 516.105)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'MO',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'timeliness_rule',
        'statute', 'RSMo § 516.105',
        'sol_period', '2 years',
        'trigger', 'Date of alleged act of negligence OR date plaintiff discovered or by reasonable diligence could have discovered the injury',
        'discovery_rule', true,
        'repose_period', '10 years for minors; no general repose period for adults',
        'minor_rule', 'If injury occurs to a minor, claim may be brought until the minor reaches age 20 (10-year limit from act)',
        'foreign_object', 'If foreign object left in body, 2 years from discovery of the object',
        'wrongful_death', '3 years from date of death (RSMo § 537.100)',
        'tolling', jsonb_build_array(
            'Legal disability (minority, mental incapacity)',
            'Fraudulent concealment by defendant',
            'Continuous treatment doctrine (recognized in some contexts)'
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('RSMo § 516.105', 'RSMo § 537.100', 'Justia Missouri'),
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
    'MO-MED-MAL-PURE-COMPARATIVE-FAULT', 5,
    'MO Medical Malpractice: Pure Comparative Fault (RSMo § 537.765)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'MO',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'negligence_model',
        'statute', 'RSMo § 537.765',
        'negligence_model', 'pure_comparative',
        'complete_bar', false,
        'bar_threshold', 'none',
        'rule_description', 'Missouri follows pure comparative fault — plaintiff may recover even if 99% at fault, but damages are reduced proportionally by plaintiff''s degree of fault',
        'joint_several_liability', 'Defendant found 51% or more at fault is jointly and severally liable; defendant found 50% or less liable only for proportionate share (RSMo § 537.067)',
        'multiple_defendants', 'Fault apportioned among all negligent parties; jury assigns percentages',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('RSMo § 537.765', 'RSMo § 537.067', 'Missouri comparative fault case law'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();
