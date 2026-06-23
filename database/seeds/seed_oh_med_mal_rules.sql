-- =====================================================
-- Ohio (OH) Medical Malpractice Rules
-- Enhanced Verification Protocol v2.0
-- =====================================================
-- State: Ohio
-- Governing Law: ORC § 2305.113 (SOL); ORC § 2323.43 (Damage Caps);
--                Ohio Civ. R. 10(D)(2) (Affidavit of Merit)
-- Negligence Model: MODIFIED COMPARATIVE (51% bar) — ORC § 2315.33
-- SOL: 1 year from discovery; 4-year repose (ORC § 2305.113)
-- Damage Caps: Non-economic cap $250,000 or 3x economic (max $350,000 per plaintiff)
--              Catastrophic injury: $500,000 or 3x economic (ORC § 2323.43)
-- Expert: Affidavit of Merit required with complaint (Ohio Civ. R. 10(D)(2))
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
    'OH-MED-MAL-STANDARD-OF-CARE', 5,
    'OH Medical Malpractice: Standard of Care (ORC § 2305.113; common law)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'OH',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'contextual_rule',
        'statute', 'ORC § 2305.113; common law',
        'standard_text', 'A physician is required to use the care and skill of a physician of ordinary care, diligence, and skill; in a specialist''s case, the standard is that of a reasonably careful, skillful, and prudent specialist in the same specialty',
        'key_elements', jsonb_build_array(
            'Duty: provider-patient relationship must be established',
            'Breach: failure to meet standard of ordinary care, diligence, and skill',
            'Causation: breach was a proximate cause of plaintiff''s injury',
            'Damages: actual harm (economic or non-economic) resulted'
        ),
        'locality_rule', 'Ohio abolished the strict locality rule; applies a national standard for specialists',
        'informed_consent', 'Available; provider must disclose information a reasonable patient would consider material to their decision',
        'res_ipsa', 'Doctrine recognized in Ohio; available where negligence is inferred from the circumstances',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('ORC § 2305.113', 'Ohio Supreme Court precedent', 'Justia Ohio 2024'),
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
    'OH-MED-MAL-AFFIDAVIT-OF-MERIT', 5,
    'OH Medical Malpractice: Affidavit of Merit Required (Ohio Civ. R. 10(D)(2))',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'OH',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'filing_requirement',
        'statute', 'Ohio Rules of Civil Procedure, Rule 10(D)(2)',
        'requirement', 'A complaint that contains a medical claim must include an affidavit of merit signed by a competent expert witness, attesting to the standard of care and the plaintiff''s right to bring the claim',
        'affidavit_contents', jsonb_build_array(
            'Expert''s qualifications to testify in the matter',
            'Expert''s familiarity with the applicable standard of care',
            'Statement that the standard of care was breached by one or more of the named defendants',
            'Statement that the breach caused plaintiff''s injury, loss, or wrongful death'
        ),
        'filing_deadline', 'Filed contemporaneously with the complaint',
        'expert_qualifications', jsonb_build_object(
            'same_specialty', 'Must specialize in the same or similar specialty as the defendant',
            'active_practice', 'Must be actively practicing or have recently practiced in the same specialty',
            'licensed', 'Must be licensed to practice medicine'
        ),
        'failure_consequence', 'Failure to file affidavit of merit with the complaint is grounds for dismissal without prejudice; plaintiff may re-file within SOL',
        'extension', 'Court may grant extension for good cause; if SOL would expire, court may grant additional time to obtain the affidavit',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('Ohio Civ. R. 10(D)(2)', 'ORC § 2305.113', 'Nolo Ohio guide'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 3: NON-ECONOMIC DAMAGE CAPS
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, specialization, document_type,
    jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status,
    is_active, is_template, created_at, updated_at
)
VALUES (
    'OH-MED-MAL-DAMAGE-CAPS', 5,
    'OH Medical Malpractice: Non-Economic Damage Caps (ORC § 2323.43)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'OH',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'damages_rule',
        'statute', 'ORC § 2323.43',
        'caps_apply', true,
        'non_economic_cap_standard', 250000,
        'non_economic_cap_alternative', '3x economic damages',
        'non_economic_cap_max', 350000,
        'catastrophic_cap', 500000,
        'catastrophic_cap_alternative', '3x economic damages',
        'catastrophic_definition', 'Permanent and substantial physical deformity, loss of use of a limb, or loss of a bodily organ system; permanent physical functional injury that permanently prevents performance of any employable tasks',
        'cap_notes', 'Cap = $250,000 OR 3x economic damages, whichever is greater, but not to exceed $350,000 per plaintiff; for catastrophic injuries: $500,000 OR 3x economic damages, whichever is greater',
        'economic_damages', 'No cap — medical expenses, lost wages, future economic losses fully recoverable',
        'cap_constitutionality', 'Note: Some Ohio courts have challenged constitutionality; Ohio Supreme Court upheld caps in Arbino v. Johnson & Johnson; caps remain statutory law as of 2024',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('ORC § 2323.43', 'Arbino v. Johnson & Johnson (2007)', 'Nolo Ohio guide', 'Justia Ohio 2024'),
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
    'OH-MED-MAL-SOL-1-YEAR', 5,
    'OH Medical Malpractice: Statute of Limitations 1 Year (ORC § 2305.113)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'OH',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'timeliness_rule',
        'statute', 'ORC § 2305.113',
        'sol_period', '1 year',
        'trigger', 'Date the cause of action accrued (date of injury or last date in a continuous course of treatment for the same condition)',
        'discovery_rule', true,
        'discovery_extension', 'If injury not discovered within 3 years, plaintiff has 1 year from discovery to file (but within the 4-year repose)',
        'repose_period', '4 years from date of act or omission (absolute bar)',
        'notice_extension', 'Written notice of intent to sue filed before 1-year SOL gives additional 180 days to file',
        'minor_rule', 'For minors under age 18, SOL tolled; action may be brought within 1 year after reaching age 18 but not after 4-year repose (except for minors under age 10: action may be brought until age 14)',
        'wrongful_death', '2 years from date of death (ORC § 2125.02)',
        'continuous_treatment', 'Ohio recognizes continuous treatment tolling; SOL begins running from last date in a continuous course of treatment for the same condition',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('ORC § 2305.113', 'ORC § 2125.02', 'Justia Ohio 2024'),
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
    'OH-MED-MAL-MODIFIED-COMPARATIVE', 5,
    'OH Medical Malpractice: Modified Comparative Fault 51% Bar (ORC § 2315.33)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'OH',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'negligence_model',
        'statute', 'ORC § 2315.33',
        'negligence_model', 'modified_comparative',
        'complete_bar', true,
        'bar_threshold', '51%',
        'rule_description', 'Ohio follows modified comparative fault with a 51% bar — plaintiff may recover only if their fault is 50% or less; if plaintiff is 51% or more at fault, recovery is completely barred',
        'damages_reduction', 'If plaintiff is 50% or less at fault, damages are reduced proportionally by plaintiff''s percentage of fault',
        'joint_several_liability', 'Ohio generally applies proportionate liability; joint and several liability limited to defendants who are more than 50% at fault (ORC § 2307.22)',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('ORC § 2315.33', 'ORC § 2307.22', 'Justia Ohio 2024'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();
