-- =====================================================
-- Maryland (MD) Medical Malpractice Rules
-- Enhanced Verification Protocol v2.0
-- =====================================================
-- State: Maryland
-- Governing Law: Md. Code, Courts & Judicial Proceedings (CJ) § 3-2A et seq.
-- Negligence Model: CONTRIBUTORY NEGLIGENCE — common law (one of 4 remaining states)
-- SOL: 5 years from incident OR 3 years from discovery, whichever is shorter (CJ § 5-109)
-- Damage Caps: Non-economic cap ~$920,000 (2024-2025, adjusted annually) (CJ § 3-2A-09)
-- Expert: Certificate of Qualified Expert required within 90 days of filing (CJ § 3-2C-02)
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
    'MD-MED-MAL-STANDARD-OF-CARE', 5,
    'MD Medical Malpractice: Standard of Care (Md. CJ § 3-2A-01)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'MD',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'contextual_rule',
        'statute', 'Md. CJ § 3-2A-01 and common law',
        'standard_text', 'A healthcare provider must exercise that degree of care and skill expected of a reasonably competent practitioner in the same specialty under the circumstances',
        'key_elements', jsonb_build_array(
            'Duty: provider-patient relationship',
            'Breach: failure to meet standard of reasonably competent provider in same specialty',
            'Causation: breach proximately caused injury',
            'Damages: actual injury resulted'
        ),
        'locality_rule', 'Maryland applies a national standard; not a strict locality rule for most specialties',
        'informed_consent', 'Separate theory; reasonable patient standard applies',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('Md. CJ § 3-2A-01', 'Nolo Maryland Med Mal Laws', 'Frank Spector Law Maryland SOL'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 2: CERTIFICATE OF QUALIFIED EXPERT
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, specialization, document_type,
    jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status,
    is_active, is_template, created_at, updated_at
)
VALUES (
    'MD-MED-MAL-CERTIFICATE-QUALIFIED-EXPERT', 5,
    'MD Medical Malpractice: Certificate of Qualified Expert Required (Md. CJ § 3-2C-02)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'MD',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'hard_rule',
        'statute', 'Md. CJ § 3-2C-02',
        'requirement', 'Plaintiff must file a Certificate of Qualified Expert within 90 days of filing the claim',
        'certificate_contents', jsonb_build_array(
            'Expert must be a qualified expert in the same specialty as defendant',
            'Must state that defendant did not meet the standard of care',
            'Must state that the failure to meet standard caused the claimed injury',
            'Must be filed within 90 days of complaint (extension for good cause)'
        ),
        'documentary_evidence_request', 'Plaintiff may request documentary evidence from defendant within 30 days of claim being served',
        'waiver', 'Court may waive or modify requirement upon claimant request for good cause',
        'dismissal', 'Failure to file certificate results in dismissal without prejudice',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('Md. CJ § 3-2C-02', 'Justia Maryland 2024', 'Nolo Maryland Med Mal'),
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
    'MD-MED-MAL-DAMAGE-CAPS', 5,
    'MD Medical Malpractice: Non-Economic Damage Cap ~$920k Inflation-Adjusted (Md. CJ § 3-2A-09)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'MD',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'hard_rule',
        'statute', 'Md. CJ § 3-2A-09',
        'non_economic_cap_base', '$650,000 base (for claims arising January 1, 2005)',
        'annual_increase', '$15,000 per year starting January 1, 2009',
        'non_economic_cap_approximate_2024', 'Approximately $895,000 to $920,000 for claims arising in 2024',
        'economic_damages', 'No cap on economic damages (medical expenses, lost wages, future care)',
        'wrongful_death_multiple', 'In wrongful death with multiple beneficiaries, total non-economic damages cannot exceed 125% of established cap',
        'jury_not_informed', 'Jury is not informed of the cap; court reduces award if it exceeds cap',
        'cap_applies_per_claim', 'Cap applies collectively to all claims arising from same medical injury regardless of number of claimants or defendants',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('Md. CJ § 3-2A-09', 'Justia Maryland 2024', 'Frank Spector Law Maryland SOL 2024'),
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
    'MD-MED-MAL-SOL-5-YEARS', 5,
    'MD Medical Malpractice: 5-Year/3-Year SOL (Md. CJ § 5-109)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'MD',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'hard_rule',
        'statute', 'Md. CJ § 5-109',
        'sol_period', '5 years from date of malpractice OR 3 years from date of discovery, whichever is earlier',
        'discovery_rule', 'Discovery rule: SOL runs from date plaintiff discovers or should have discovered the injury',
        'outer_limit', '5-year outer limit from date of negligent act regardless of discovery',
        'minor_exception', 'Minors: SOL does not begin until age 18; must file by age 21 (3 years after majority)',
        'wrongful_death', 'Wrongful death: must file within 3 years of date of death',
        'out_of_state', 'Out-of-state residents may have extended timeframes based on discovery date',
        'tolling', jsonb_build_array(
            'Minor exception (SOL runs from age 18)',
            'Fraudulent concealment tolls SOL',
            'Continuous treatment doctrine may extend SOL'
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('Md. CJ § 5-109', 'Frank Spector Law Maryland SOL', '410TheFirm.com Maryland Med Mal'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 5: CONTRIBUTORY NEGLIGENCE (COMPLETE BAR)
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, specialization, document_type,
    jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status,
    is_active, is_template, created_at, updated_at
)
VALUES (
    'MD-MED-MAL-CONTRIBUTORY-NEGLIGENCE', 5,
    'MD Medical Malpractice: Contributory Negligence — Complete Bar (Common Law)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'MD',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'hard_rule',
        'statute', 'Maryland common law (one of 4 remaining contributory negligence states)',
        'negligence_model', 'contributory_negligence',
        'bar_threshold', 'Any fault — even 1% contributory negligence bars recovery',
        'rule_description', 'If plaintiff is found even slightly at fault for their own injury, they are completely barred from any recovery',
        'complete_bar', 'Yes — any contributory negligence by plaintiff is a complete bar to recovery',
        'states_with_contributory', jsonb_build_array(
            'Maryland', 'Alabama', 'North Carolina', 'Virginia', 'District of Columbia'
        ),
        'last_clear_chance', 'Doctrine of last clear chance may allow recovery despite contributory negligence if defendant had final opportunity to avoid injury',
        'practical_impact', 'Defense frequently asserts patient failed to follow medical advice, delayed seeking care, or failed to disclose medical history',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('Nolo Maryland Med Mal Laws', 'Maryland common law', 'Justia Maryland 2024'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();
