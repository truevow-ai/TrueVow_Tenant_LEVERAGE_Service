-- =====================================================
-- Kentucky (KY) Medical Malpractice Rules
-- Enhanced Verification Protocol v2.0
-- =====================================================
-- State: Kentucky
-- Governing Law: KRS Chapter 413 (SOL), common law malpractice
-- Negligence Model: PURE COMPARATIVE FAULT — KRS § 411.182
-- SOL: 1 year from discovery (KRS § 413.140(1)(e))
-- Damage Caps: NO caps on damages in medical malpractice
-- Expert: Certificate of merit / expert affidavit required
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
    'KY-MED-MAL-STANDARD-OF-CARE', 5,
    'KY Medical Malpractice: Standard of Care (KRS § 304.40-330, common law)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'KY',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'contextual_rule',
        'statute', 'KRS § 304.40-330 and common law',
        'standard_text', 'A healthcare provider must exercise the degree of care and skill of a reasonably competent provider in the same or similar medical specialty, practicing in similar circumstances',
        'key_elements', jsonb_build_array(
            'Duty: provider-patient relationship',
            'Breach: failure to meet standard of care of a reasonably competent provider in the specialty',
            'Causation: breach proximately caused injury',
            'Damages: actual injury resulted'
        ),
        'locality_rule', 'Kentucky applies a statewide or national standard for specialists; not a strict locality rule',
        'informed_consent', 'Separate theory; must show failure to disclose material risk using reasonable patient standard',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('KRS § 304.40-330', 'Expertise.com Kentucky Med Mal 2024', 'Gilman Bedigian Kentucky Med Mal Laws'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 2: EXPERT AFFIDAVIT REQUIREMENT
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, specialization, document_type,
    jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status,
    is_active, is_template, created_at, updated_at
)
VALUES (
    'KY-MED-MAL-EXPERT-AFFIDAVIT', 5,
    'KY Medical Malpractice: Expert Affidavit / Certificate of Merit Required',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'KY',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'hard_rule',
        'statute', 'KRS § 411.167 (certificate of merit)',
        'requirement', 'Before or at time of filing, plaintiff must file certificate of merit from qualified expert confirming negligence',
        'qualifications', jsonb_build_array(
            'Expert must be licensed in same or substantially similar healthcare field',
            'Must have knowledge of applicable standard of care',
            'Must confirm that provider failed to meet standard of care',
            'Certificate must be filed with or shortly after the complaint'
        ),
        'panel_history', 'Prior medical review panel requirement (KRS § 216C) was struck down as unconstitutional; replaced by certificate of merit requirement',
        'consequence_of_failure', 'Failure to file certificate may result in dismissal without prejudice',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('KRS § 411.167', 'Alllaw.com Kentucky Med Mal Laws', 'McCoy Hiestand Kentucky SOL'),
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
    'KY-MED-MAL-NO-DAMAGE-CAPS', 5,
    'KY Medical Malpractice: No Damage Caps on Medical Malpractice Claims',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'KY',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'hard_rule',
        'current_rule', 'Kentucky does not impose statutory caps on compensatory damages in medical malpractice cases',
        'economic_damages', 'Fully recoverable without cap (medical expenses, lost wages, future care)',
        'non_economic_damages', 'No statutory cap on pain and suffering, emotional distress, loss of consortium',
        'punitive_damages', 'Available for gross negligence, fraud, or oppression; jury determines amount subject to Kentucky Const. § 54',
        'constitutional_basis', 'Kentucky Constitution § 54 protects right to jury-determined damages; caps have been challenged as unconstitutional',
        'cap_notes', jsonb_build_array(
            'No currently effective non-economic damage cap in Kentucky med mal cases',
            'Prior legislative caps were opposed on constitutional grounds',
            'Plaintiffs can seek full compensatory and punitive damages as warranted'
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('Gilman Bedigian Kentucky Med Mal Laws', 'Alllaw.com Kentucky Med Mal', 'Expertise.com Kentucky 2024'),
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
    'KY-MED-MAL-SOL-1-YEAR', 5,
    'KY Medical Malpractice: 1-Year SOL from Discovery (KRS § 413.140(1)(e))',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'KY',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'hard_rule',
        'statute', 'KRS § 413.140(1)(e)',
        'sol_period', '1 year from the date the cause of action accrued (date of discovery)',
        'discovery_rule', 'SOL runs from date plaintiff discovers or should have discovered the malpractice and its causal connection to injury',
        'repose_period', 'Kentucky had a 5-year statute of repose which has been deemed unconstitutional; effectively only 1-year SOL applies from discovery',
        'minor_exception', 'Minors: SOL tolled until minor reaches majority (18); then 1-year period begins',
        'tolling', jsonb_build_array(
            'Fraudulent concealment tolls SOL',
            'Mental incapacity may toll SOL',
            'Continuous treatment doctrine may extend SOL in some circumstances'
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('KRS § 413.140(1)(e)', 'Alllaw.com Kentucky Med Mal Laws', 'McCoy Hiestand Kentucky SOL'),
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
    'KY-MED-MAL-PURE-COMPARATIVE-FAULT', 5,
    'KY Medical Malpractice: Pure Comparative Fault (KRS § 411.182)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'KY',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'contextual_rule',
        'statute', 'KRS § 411.182',
        'negligence_model', 'pure_comparative',
        'bar_threshold', 'None — plaintiff may recover regardless of fault percentage',
        'rule_description', 'Plaintiff may recover even if 99% at fault; damages reduced proportionally by plaintiff fault percentage',
        'complete_bar', 'No — Kentucky pure comparative fault has no bar; recovery reduced only',
        'joint_several', 'Kentucky: proportionate liability; each defendant liable for their share of fault',
        'example', 'If plaintiff 70% at fault and defendant 30% at fault: plaintiff recovers 30% of total damages',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('KRS § 411.182', 'Rittgers Law Firm Kentucky Comparative Fault 2025', 'Expertise.com Kentucky 2024'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();
