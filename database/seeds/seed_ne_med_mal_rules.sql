-- =====================================================
-- Nebraska (NE) Medical Malpractice Rules
-- Enhanced Verification Protocol v2.0
-- =====================================================
-- State: Nebraska
-- Governing Law: Neb. Rev. Stat. §§ 44-2825 to 44-2840 (Hospital-Medical Liability Act)
-- Negligence Model: MODIFIED COMPARATIVE (50% bar) — Neb. Rev. Stat. § 25-21,185.09
-- SOL: 2 years from discovery; 10-year repose (Neb. Rev. Stat. § 25-222)
-- Damage Caps: Total recovery cap $2.25 million (for occurrences on/after Dec 31, 2014)
--              (Neb. Rev. Stat. § 44-2825)
-- Expert: Certificate of expert review required before filing
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
    'NE-MED-MAL-STANDARD-OF-CARE', 5,
    'NE Medical Malpractice: Standard of Care (Neb. Rev. Stat. § 44-2810)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'NE',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'contextual_rule',
        'statute', 'Neb. Rev. Stat. § 44-2810',
        'standard_text', 'A health care provider shall be deemed to have acted in accordance with the standard of care if the provider acted in good faith and with that degree of care, skill, and treatment which, in light of all relevant surrounding circumstances, is recognized as acceptable and appropriate by reasonably prudent similar health care providers',
        'key_elements', jsonb_build_array(
            'Duty: provider-patient relationship must be established',
            'Breach: failure to act in accordance with the standard of a reasonably prudent similar provider',
            'Causation: breach was proximate cause of plaintiff''s injury',
            'Damages: actual harm (economic or non-economic) resulted'
        ),
        'informed_consent', 'Available; provider must obtain informed consent and disclose material risks to patient',
        'res_ipsa', 'Recognized in Nebraska; available where injury ordinarily does not occur absent negligence',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('Neb. Rev. Stat. § 44-2810', 'Nebraska Hospital-Medical Liability Act', 'Justia Nebraska'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 2: CERTIFICATE OF EXPERT REVIEW
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, specialization, document_type,
    jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status,
    is_active, is_template, created_at, updated_at
)
VALUES (
    'NE-MED-MAL-EXPERT-CERTIFICATE', 5,
    'NE Medical Malpractice: Certificate of Expert Review (Neb. Rev. Stat. § 44-2840)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'NE',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'filing_requirement',
        'statute', 'Neb. Rev. Stat. § 44-2840',
        'requirement', 'A plaintiff must file a certificate of merit executed by a qualified expert before proceeding with a medical malpractice action; the certificate must attest that the expert has reviewed the case and believes a reasonable basis exists for the claim',
        'certificate_contents', jsonb_build_array(
            'Expert''s qualifications in the relevant specialty',
            'Statement that expert reviewed pertinent medical records and other case materials',
            'Statement that the expert believes there is a reasonable basis for the claim',
            'Description of the specific acts or omissions alleged to constitute negligence'
        ),
        'qualified_expert', jsonb_build_object(
            'same_or_similar_specialty', 'Must practice in the same or a substantially similar specialty as the defendant',
            'licensed', 'Must be licensed in Nebraska or another state',
            'active_practice', 'Must be in active clinical practice or recently retired'
        ),
        'failure_consequence', 'Failure to file required certificate may result in dismissal of the claim',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('Neb. Rev. Stat. § 44-2840', 'Expertise.com Nebraska summary', 'Justia Nebraska'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 3: TOTAL RECOVERY CAP
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, specialization, document_type,
    jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status,
    is_active, is_template, created_at, updated_at
)
VALUES (
    'NE-MED-MAL-TOTAL-RECOVERY-CAP', 5,
    'NE Medical Malpractice: Total Recovery Cap $2.25 Million (Neb. Rev. Stat. § 44-2825)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'NE',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'damages_rule',
        'statute', 'Neb. Rev. Stat. § 44-2825',
        'caps_apply', true,
        'total_recovery_cap', 2250000,
        'cap_type', 'total_recovery',
        'cap_history', jsonb_build_object(
            'pre_1985', 500000,
            '1985_to_1992', 1000000,
            '1993_to_2003', 1250000,
            '2004_to_2014', 1750000,
            '2015_present', 2250000
        ),
        'cap_notes', 'Nebraska caps TOTAL recovery (economic + non-economic combined) in medical malpractice at $2.25 million for occurrences on or after December 31, 2014; this is distinct from states that cap only non-economic damages',
        'cap_covers', 'All damages including economic (medical expenses, lost wages) and non-economic (pain, suffering); punitive damages not available in Nebraska',
        'punitive_damages', 'Not available in Nebraska medical malpractice cases',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('Neb. Rev. Stat. § 44-2825', 'Knowles Law Firm analysis', 'Justia Nebraska'),
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
    'NE-MED-MAL-SOL-2-YEARS', 5,
    'NE Medical Malpractice: Statute of Limitations 2 Years (Neb. Rev. Stat. § 25-222)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'NE',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'timeliness_rule',
        'statute', 'Neb. Rev. Stat. § 25-222',
        'sol_period', '2 years',
        'trigger', 'Date of the alleged negligent act or omission; if not discovered within 2 years, then 1 year from date of discovery',
        'discovery_rule', true,
        'discovery_extension', '1 additional year from date of discovery when injury could not reasonably have been discovered within the initial 2-year period',
        'repose_period', '10 years from the date the professional service was rendered or failed to be rendered (absolute bar)',
        'minor_rule', 'Standard 2-year SOL applies; no special minor exception beyond legal disability tolling',
        'wrongful_death', '2 years from date of death',
        'tolling', jsonb_build_array(
            'Legal disability',
            'Fraudulent concealment by defendant',
            'Discovery extension available (1 year from discovery, capped at 10-year repose)'
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('Neb. Rev. Stat. § 25-222', 'Nebraska Legislature website', 'Friedman Law analysis'),
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
    'NE-MED-MAL-MODIFIED-COMPARATIVE', 5,
    'NE Medical Malpractice: Modified Comparative Fault 50% Bar (Neb. Rev. Stat. § 25-21,185.09)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'NE',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'negligence_model',
        'statute', 'Neb. Rev. Stat. § 25-21,185.09',
        'negligence_model', 'modified_comparative',
        'complete_bar', true,
        'bar_threshold', '50%',
        'rule_description', 'Nebraska follows modified comparative fault with a 50% bar — plaintiff may recover only if their fault is 50% or less; if plaintiff is more than 50% at fault, recovery is completely barred',
        'damages_reduction', 'If plaintiff is 50% or less at fault, damages are reduced proportionally by plaintiff''s percentage of fault',
        'joint_several_liability', 'Nebraska retains joint and several liability for defendants found 50% or more at fault; defendants less than 50% at fault are liable only for their proportionate share',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('Neb. Rev. Stat. § 25-21,185.09', 'Justia Nebraska'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();
