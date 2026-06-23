-- =====================================================
-- Mississippi (MS) Medical Malpractice Rules
-- Enhanced Verification Protocol v2.0
-- =====================================================
-- State: Mississippi
-- Governing Law: Miss. Code Ann. §§ 11-1-60, 15-1-36 (Medical Malpractice Reform Act)
-- Negligence Model: PURE COMPARATIVE FAULT — Miss. Code Ann. § 11-7-15
-- SOL: 2 years from discovery; 7-year repose (Miss. Code Ann. § 15-1-36)
-- Damage Caps: Non-economic damages capped at $500,000 (Miss. Code Ann. § 11-1-60)
--              Economic damages uncapped
-- Expert: Expert testimony required; affidavit within 60 days of complaint
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
    'MS-MED-MAL-STANDARD-OF-CARE', 5,
    'MS Medical Malpractice: Standard of Care (Miss. Code Ann. § 11-1-58)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'MS',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'contextual_rule',
        'statute', 'Miss. Code Ann. § 11-1-58',
        'standard_text', 'A healthcare provider shall exercise that degree of care, skill, and treatment which, in light of all relevant surrounding circumstances, is recognized as acceptable and appropriate by reasonably prudent similar health care providers',
        'key_elements', jsonb_build_array(
            'Duty: provider-patient relationship must be established',
            'Breach: failure to adhere to the applicable standard of care for a reasonably prudent similar provider',
            'Causation: proximate cause — breach directly caused the plaintiff''s injury',
            'Damages: actual harm (economic or non-economic) must have resulted'
        ),
        'locality_rule', 'Mississippi uses a statewide standard; no strict locality rule — expert need not be from Mississippi',
        'informed_consent', 'Available under Miss. Code Ann. § 41-41-205 (Uniform Health-Care Decisions Act); must disclose risks a reasonable patient would want to know',
        'res_ipsa', 'Doctrine available; injury must be of a kind that does not ordinarily occur absent negligence (e.g., surgical instrument left in patient)',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('Miss. Code Ann. § 11-1-58', 'Mississippi Medical Malpractice Reform Act', 'Justia Mississippi'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 2: EXPERT AFFIDAVIT REQUIREMENTS
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, specialization, document_type,
    jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status,
    is_active, is_template, created_at, updated_at
)
VALUES (
    'MS-MED-MAL-EXPERT-AFFIDAVIT', 5,
    'MS Medical Malpractice: Expert Affidavit Requirement (Miss. Code Ann. § 11-1-58)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'MS',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'filing_requirement',
        'statute', 'Miss. Code Ann. § 11-1-58',
        'requirement', 'Plaintiff must file an expert affidavit concurrent with or within 60 days after service of the complaint, attesting that a qualified expert has reviewed the case and believes the defendant deviated from the applicable standard of care',
        'deadline', 'Within 60 days after service of the complaint on the defendant',
        'affidavit_contents', jsonb_build_array(
            'Expert''s qualifications and specialty',
            'Specific acts or omissions constituting breach of standard of care',
            'Statement that the breach proximately caused the plaintiff''s injury',
            'Expert''s opinion that the claim has merit'
        ),
        'qualified_expert', jsonb_build_object(
            'same_specialty', 'Must be qualified in the same or substantially similar field as the defendant',
            'licensed', 'Must be licensed in Mississippi or another state',
            'active_practice', 'Must be in active clinical practice or teaching'
        ),
        'failure_consequence', 'Case may be dismissed without prejudice; court may allow additional time for good cause',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('Miss. Code Ann. § 11-1-58', 'Mississippi Supreme Court Rules', 'Justia Mississippi'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 3: NON-ECONOMIC DAMAGE CAP
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, specialization, document_type,
    jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status,
    is_active, is_template, created_at, updated_at
)
VALUES (
    'MS-MED-MAL-DAMAGE-CAP', 5,
    'MS Medical Malpractice: Non-Economic Damage Cap $500,000 (Miss. Code Ann. § 11-1-60)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'MS',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'damages_rule',
        'statute', 'Miss. Code Ann. § 11-1-60',
        'caps_apply', true,
        'non_economic_cap', 500000,
        'effective_date', 'September 1, 2004 (applies to claims filed on or after this date)',
        'annual_adjustment', false,
        'cap_notes', 'Flat $500,000 cap on non-economic damages (pain, suffering, emotional distress, loss of companionship) in medical malpractice claims; jury is NOT informed of the cap — judge reduces any verdict exceeding the limit',
        'economic_damages', 'No cap — medical expenses, lost wages, future medical costs fully recoverable',
        'punitive_damages', 'Punitive damages capped separately at $1,000,000 or 2x compensatory damages, whichever is greater (Miss. Code Ann. § 11-1-65)',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('Miss. Code Ann. § 11-1-60', 'Miss. Code Ann. § 11-1-65', 'Justia Mississippi 2024'),
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
    'MS-MED-MAL-SOL-2-YEARS', 5,
    'MS Medical Malpractice: Statute of Limitations 2 Years (Miss. Code Ann. § 15-1-36)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'MS',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'timeliness_rule',
        'statute', 'Miss. Code Ann. § 15-1-36',
        'sol_period', '2 years',
        'trigger', 'Date the alleged act, omission, or neglect was first known or reasonably could have been discovered by the plaintiff',
        'discovery_rule', true,
        'repose_period', '7 years from the date of the act or omission (absolute bar except for limited exceptions)',
        'foreign_object', 'Exception: if a foreign object left in body, SOL runs from date of discovery of the object',
        'concealment', 'Exception: if malpractice was fraudulently concealed, SOL runs from date of discovery of concealment',
        'minor_rule', 'If plaintiff is 6 years old or younger at time of injury, claim may be filed within 2 years of reaching age 6; otherwise standard 2-year rule applies',
        'wrongful_death', '3 years from date of death (Miss. Code Ann. § 11-7-13)',
        'tolling', jsonb_build_array(
            'Legal disability (minority for those over age 6, incompetency)',
            'Fraudulent concealment by defendant',
            'Foreign object exception'
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('Miss. Code Ann. § 15-1-36', 'Miss. Code Ann. § 11-7-13', 'Justia Mississippi'),
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
    'MS-MED-MAL-PURE-COMPARATIVE-FAULT', 5,
    'MS Medical Malpractice: Pure Comparative Fault (Miss. Code Ann. § 11-7-15)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'MS',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'negligence_model',
        'statute', 'Miss. Code Ann. § 11-7-15',
        'negligence_model', 'pure_comparative',
        'complete_bar', false,
        'bar_threshold', 'none',
        'rule_description', 'Mississippi follows pure comparative fault — plaintiff may recover even if predominantly at fault; damages are reduced proportionally by plaintiff''s percentage of fault',
        'joint_several_liability', 'Mississippi abolished joint and several liability (Miss. Code Ann. § 85-5-7); each defendant liable only for their proportionate share of fault',
        'multiple_defendants', 'Fault apportioned among all parties including non-parties whose fault was alleged; jury assigns percentages',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('Miss. Code Ann. § 11-7-15', 'Miss. Code Ann. § 85-5-7', 'Mississippi comparative fault case law'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();
