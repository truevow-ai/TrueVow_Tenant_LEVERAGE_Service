-- =====================================================
-- New Jersey (NJ) Medical Malpractice Rules
-- Enhanced Verification Protocol v2.0
-- =====================================================
-- State: New Jersey
-- Governing Law: N.J.S.A. § 2A:53A-27 (Affidavit of Merit); N.J.S.A. § 2A:14-2 (SOL)
-- Negligence Model: MODIFIED COMPARATIVE (51% bar) — N.J.S.A. § 2A:15-5.1
-- SOL: 2 years from discovery; minors until age 20 (N.J.S.A. § 2A:14-2)
-- Damage Caps: NO caps on compensatory damages; punitive capped at $350,000 or 5x comp
-- Expert: Affidavit of Merit within 60 days of defendant's answer (N.J.S.A. § 2A:53A-27)
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
    'NJ-MED-MAL-STANDARD-OF-CARE', 5,
    'NJ Medical Malpractice: Standard of Care',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'NJ',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'contextual_rule',
        'statute', 'N.J.S.A. § 2A:53A-27; common law',
        'standard_text', 'A physician is required to exercise the degree of care, knowledge, and skill ordinarily possessed and exercised in similar situations by the average member of the profession practicing in the field',
        'key_elements', jsonb_build_array(
            'Duty: provider-patient relationship must be established',
            'Breach: failure to exercise degree of care of average member of profession',
            'Causation: breach was proximate cause of plaintiff''s injury',
            'Damages: actual harm (economic or non-economic) resulted'
        ),
        'locality_rule', 'NJ applies a national/professional standard — not a strict locality rule; expert must be in same or related specialty',
        'informed_consent', 'Available under NJ informed consent case law; provider must disclose risks a reasonable patient would want to know',
        'res_ipsa', 'Doctrine recognized in NJ medical malpractice cases (e.g., foreign objects, wrong-site surgery)',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('N.J.S.A. § 2A:53A-27', 'NJ Courts', 'Justia New Jersey'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 2: AFFIDAVIT OF MERIT
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, specialization, document_type,
    jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status,
    is_active, is_template, created_at, updated_at
)
VALUES (
    'NJ-MED-MAL-AFFIDAVIT-OF-MERIT', 5,
    'NJ Medical Malpractice: Affidavit of Merit (N.J.S.A. § 2A:53A-27)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'NJ',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'filing_requirement',
        'statute', 'N.J.S.A. § 2A:53A-27',
        'requirement', 'Plaintiff must serve an Affidavit of Merit on each defendant within 60 days of the defendant''s answer, signed by an appropriately licensed expert who attests there exists a reasonable probability that the defendant''s care fell outside acceptable professional standards',
        'deadline', '60 days after service of defendant''s answer; court may grant a single 60-day extension for good cause',
        'expert_qualifications', jsonb_build_object(
            'board_certification', 'Must be board certified or have significant experience in the same specialty as the defendant',
            'active_practice', 'Must devote a majority of professional time to active clinical practice or teaching in the relevant specialty',
            'licensed', 'Must be licensed in New Jersey or another US jurisdiction'
        ),
        'failure_consequence', 'Failure to serve timely affidavit results in dismissal with prejudice (Ferreira Conference exception exists)',
        'extraordinary_circumstances', 'Case may proceed without affidavit if plaintiff can demonstrate extraordinary circumstances',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('N.J.S.A. § 2A:53A-27', 'Justia NJ 2024', 'NJ Courts'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 3: NO COMPENSATORY DAMAGE CAPS
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, specialization, document_type,
    jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status,
    is_active, is_template, created_at, updated_at
)
VALUES (
    'NJ-MED-MAL-NO-DAMAGE-CAPS', 5,
    'NJ Medical Malpractice: No Caps on Compensatory Damages',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'NJ',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'damages_rule',
        'caps_apply', false,
        'non_economic_cap', null,
        'economic_cap', null,
        'cap_notes', 'New Jersey imposes NO caps on compensatory damages (economic or non-economic) in medical malpractice cases; exception: $250,000 limit on damages against charitable/nonprofit hospitals',
        'nonprofit_hospital_cap', 250000,
        'punitive_damages', 'Capped at $350,000 or 5 times compensatory damages, whichever is greater (N.J.S.A. § 2A:15-5.14); rarely awarded',
        'economic_damages', 'Fully recoverable without limitation',
        'non_economic_damages', 'Fully recoverable without limitation (except nonprofit hospital exception)',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('N.J.S.A. § 2A:15-5.14', 'AskLaw NJ damages summary 2025', 'VanWey NJ guide'),
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
    'NJ-MED-MAL-SOL-2-YEARS', 5,
    'NJ Medical Malpractice: Statute of Limitations 2 Years (N.J.S.A. § 2A:14-2)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'NJ',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'timeliness_rule',
        'statute', 'N.J.S.A. § 2A:14-2',
        'sol_period', '2 years',
        'trigger', 'Date plaintiff knew or should have known of the injury and its causal connection to defendant''s care (discovery rule)',
        'discovery_rule', true,
        'repose_period', 'No general statute of repose in NJ for medical malpractice',
        'minor_rule', 'For minors, SOL tolled until age 18; may file until age 20; birth injury claims may be brought until minor''s 13th birthday (special birth injury rule)',
        'foreign_object', 'Discovery rule applies; SOL runs from date of discovery or reasonable discovery',
        'wrongful_death', '2 years from date of death (N.J.S.A. § 2A:31-3)',
        'continuous_treatment', 'Continuous treatment doctrine recognized; SOL tolled during continuous course of treatment for same condition',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('N.J.S.A. § 2A:14-2', 'N.J.S.A. § 2A:31-3', 'Sarna Law NJ analysis'),
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
    'NJ-MED-MAL-MODIFIED-COMPARATIVE', 5,
    'NJ Medical Malpractice: Modified Comparative Fault 51% Bar (N.J.S.A. § 2A:15-5.1)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'NJ',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'negligence_model',
        'statute', 'N.J.S.A. § 2A:15-5.1',
        'negligence_model', 'modified_comparative',
        'complete_bar', true,
        'bar_threshold', '51%',
        'rule_description', 'New Jersey follows modified comparative fault with a 51% bar — plaintiff may recover only if their fault is 50% or less; if plaintiff is 51% or more at fault, recovery is completely barred',
        'damages_reduction', 'If plaintiff is 50% or less at fault, damages are reduced proportionally by plaintiff''s percentage of fault',
        'joint_several_liability', 'New Jersey retains joint and several liability for defendants found 60% or more at fault; defendants less than 60% at fault are liable only for their proportionate share',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('N.J.S.A. § 2A:15-5.1', 'Justia New Jersey', 'NJ comparative fault case law'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();
