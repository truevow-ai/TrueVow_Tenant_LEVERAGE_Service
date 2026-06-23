-- =====================================================
-- Iowa (IA) Medical Malpractice Rules
-- Enhanced Verification Protocol v2.0
-- =====================================================
-- State: Iowa
-- Governing Law: Iowa Code Chapter 147, Chapter 668
-- Negligence Model: MODIFIED COMPARATIVE (51% bar) — Iowa Code § 668.3
-- SOL: 2 years from discovery (Iowa Code § 614.1(9))
-- Damage Caps: Non-economic caps per § 147.136A: $250k standard; $1M substantial impairment/death; $2M if hospital
-- Expert: Active license required per § 147.139 (Hummel v. Smith 2024)
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
    'IA-MED-MAL-STANDARD-OF-CARE', 5,
    'IA Medical Malpractice: Standard of Care (Iowa Code § 147.136)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'IA',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'contextual_rule',
        'statute', 'Iowa Code § 147.136',
        'standard_text', 'Healthcare provider must exercise the degree of care, skill, and treatment expected of a reasonably competent and skilled provider in the same specialty under similar circumstances',
        'key_elements', jsonb_build_array(
            'Duty: provider-patient relationship',
            'Breach: failure to meet standard of similarly competent provider',
            'Causation: breach was proximate cause of injury',
            'Damages: actual damages resulted'
        ),
        'locality_rule', 'Iowa applies a statewide standard; not a strict locality rule',
        'informed_consent', 'Separate theory available under Iowa common law',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('Iowa Code § 147.136', 'Expertise.com Iowa Medical Malpractice Laws 2024'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 2: EXPERT WITNESS REQUIREMENTS
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, specialization, document_type,
    jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status,
    is_active, is_template, created_at, updated_at
)
VALUES (
    'IA-MED-MAL-EXPERT-WITNESS', 5,
    'IA Medical Malpractice: Expert Witness Active License Requirement (Iowa Code § 147.139)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'IA',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'hard_rule',
        'statute', 'Iowa Code § 147.139',
        'requirement', 'Expert witness must hold a current, active medical license; inactive license disqualifies expert',
        'key_case', 'Hummel v. Smith (Iowa Supreme Court 2024) — clarified that inactive license disqualifies expert under 2017 amendment',
        'qualifications', jsonb_build_array(
            'Current, active medical license required (§ 147.139 amended 2017)',
            'Must be in same or similar specialty as defendant',
            'Must be able to establish standard of care applicable to defendant',
            'Inactive or lapsed license renders expert testimony inadmissible'
        ),
        'no_presuit_certificate', 'Iowa does not require a pre-filing certificate of merit',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('Iowa Code § 147.139', 'Hummel v. Smith (2024)', 'Grefe & Sidney Law 2024'),
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
    'IA-MED-MAL-DAMAGE-CAPS', 5,
    'IA Medical Malpractice: Non-Economic Damage Caps (Iowa Code § 147.136A)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'IA',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'hard_rule',
        'statute', 'Iowa Code § 147.136A',
        'non_economic_cap_standard', '$250,000 — standard cases (pain, suffering, non-pecuniary losses)',
        'non_economic_cap_impairment', '$1,000,000 — if plaintiff suffers substantial permanent impairment or wrongful death',
        'non_economic_cap_hospital', '$2,000,000 — if a hospital is a defendant in substantial impairment/death case',
        'economic_damages', 'No cap on economic damages (medical expenses, lost wages, future care)',
        'annual_adjustment', 'Caps increase 2.1% annually starting January 1, 2028',
        'malice_exception', 'Caps do not apply if defendant acted with actual malice',
        'effective_date', 'Applies to causes of action accruing on or after July 1, 2017; amended February 16, 2023',
        'cap_notes', jsonb_build_array(
            'Noneconomic damages defined as damages other than economic damages',
            'Excludes loss of dependent care from non-economic category',
            'Cap applies per occurrence regardless of number of defendants',
            'Constitutional challenges to caps ongoing in Iowa courts'
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('Iowa Code § 147.136A', 'legis.iowa.gov/docs/code/147.136A.pdf', 'Iowa Journal of Corporate Law 2025'),
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
    'IA-MED-MAL-SOL-2-YEARS', 5,
    'IA Medical Malpractice: 2-Year SOL (Iowa Code § 614.1(9))',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'IA',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'hard_rule',
        'statute', 'Iowa Code § 614.1(9)',
        'sol_period', '2 years from date of discovery or when injury should have been discovered',
        'repose_period', 'No separate statute of repose in Iowa for medical malpractice',
        'discovery_rule', 'Claim accrues when plaintiff knew or should have known of injury',
        'minor_exception', 'Minors: SOL does not run until minor reaches age of majority (18)',
        'tolling', jsonb_build_array(
            'Fraudulent concealment tolls statute',
            'Mental incapacity may toll SOL',
            'Continuous treatment doctrine may apply in some circumstances'
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('Iowa Code § 614.1(9)', 'Rosenfeld Injury Lawyers Iowa'),
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
    'IA-MED-MAL-MODIFIED-COMPARATIVE', 5,
    'IA Medical Malpractice: Modified Comparative Fault 51% Bar (Iowa Code § 668.3)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'IA',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'contextual_rule',
        'statute', 'Iowa Code § 668.3',
        'negligence_model', 'modified_comparative',
        'bar_threshold', '51%',
        'rule_description', 'Plaintiff may recover if fault does not exceed 51%; damages reduced by plaintiff fault percentage',
        'complete_bar', 'Yes — plaintiff barred if found more than 51% at fault',
        'joint_several', 'Iowa modified joint and several liability; defendants assessed proportionate share of fault',
        'fault_allocation', 'Jury must apportion fault among all parties including non-party tortfeasors in some cases',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('Iowa Code § 668.3', 'Lawsuit Information Center Iowa'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();
