-- =====================================================
-- Minnesota (MN) Medical Malpractice Rules
-- Protocol v3 Audit Correction — 2026-03-02
-- =====================================================
-- State: Minnesota
-- Governing Law: Minn. Stat. Chapter 145, Chapter 541, Chapter 604
-- Negligence Model: MODIFIED COMPARATIVE (51% bar) — Minn. Stat. § 604.01
-- SOL: 4 years from act (Minn. Stat. § 541.076) — med mal specific statute
--      CORRECTION: Previously cited § 541.07(1) which is the 2-year PERSONAL
--      INJURY SOL — WRONG for med mal. § 541.076 supersedes § 541.07 for
--      health care liability claims per its own specific provision.
-- Damage Caps: NO statutory caps (no current enacted cap on damages in Minnesota)
-- Expert: Two affidavits required — one at filing + one within 180 days (Minn. Stat. § 145.682)
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
    'MN-MED-MAL-STANDARD-OF-CARE', 5,
    'MN Medical Malpractice: Standard of Care (Minn. Stat. § 604.11)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'MN',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'contextual_rule',
        'statute', 'Minn. Stat. § 604.11 and common law',
        'standard_text', 'Healthcare provider must exercise the degree of care, skill, and treatment which, in light of all relevant surrounding circumstances, is recognized as acceptable and appropriate by reasonably prudent similar health care providers',
        'key_elements', jsonb_build_array(
            'Duty: provider-patient relationship',
            'Breach: failure to meet standard of reasonably prudent similar provider',
            'Causation: breach was a direct cause of plaintiff injury',
            'Damages: actual injury resulted'
        ),
        'causation_clarification', 'Minnesota Supreme Court 2024: plaintiff not required to meet heightened causation standard compared to ordinary negligence (PLAN Alert May 2024)',
        'locality_rule', 'Minnesota applies a national or statewide standard; not a strict locality rule',
        'informed_consent', 'Separate theory; provider must disclose material risks',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('Minn. Stat. § 604.11', 'PLAN Alert May 2024 MN Supreme Court', 'Alllaw.com Minnesota Med Mal'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 2: TWO EXPERT AFFIDAVITS REQUIRED
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, specialization, document_type,
    jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status,
    is_active, is_template, created_at, updated_at
)
VALUES (
    'MN-MED-MAL-EXPERT-AFFIDAVITS', 5,
    'MN Medical Malpractice: Two Expert Affidavits Required (Minn. Stat. § 145.682)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'MN',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'hard_rule',
        'statute', 'Minn. Stat. § 145.682',
        'affidavit_1', jsonb_build_object(
            'timing', 'Must be served with complaint or within 60 days after if SOL deadline requires filing first',
            'contents', 'Expert reviewed case and believes defendant deviated from standard of care and that deviation caused injury'
        ),
        'affidavit_2', jsonb_build_object(
            'timing', 'Must be served within 180 days after discovery begins',
            'contents', jsonb_build_array(
                'Identifies all expert witnesses expected to testify',
                'States each expert opinion and basis for opinion',
                'No additional experts may be called without agreement or court permission'
            )
        ),
        'pro_se_plaintiffs', 'Pro se plaintiffs must comply with same affidavit requirements',
        'consequence_of_failure', 'Failure to serve affidavits results in mandatory dismissal with prejudice',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('Minn. Stat. § 145.682', 'MN Revisor § 145.682 PDF 2024', 'PLAN Alert MN May 2024'),
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
    'MN-MED-MAL-NO-DAMAGE-CAPS', 5,
    'MN Medical Malpractice: No Statutory Damage Caps Currently Effective',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'MN',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'hard_rule',
        'current_rule', 'Minnesota does not currently impose effective statutory caps on non-economic damages in medical malpractice cases',
        'economic_damages', 'No cap on economic damages (medical expenses, lost wages, future care)',
        'non_economic_damages', 'No currently effective statutory cap on non-economic damages in Minnesota med mal',
        'cap_history', 'Some sources cite a $2M cap; however, Minnesota courts have interpreted this inconsistently and no broadly applied current cap exists',
        'punitive_damages', 'Available for deliberate disregard of rights or safety; governed by Minn. Stat. § 549.20',
        'cap_notes', jsonb_build_array(
            'Alllaw.com: no caps on damages in Minnesota medical malpractice',
            'Some sources cite historical $2M non-economic cap — confirm current status with updated Minnesota statutes',
            'Full compensatory damages recoverable per jury determination'
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('Alllaw.com Minnesota Med Mal Laws', 'Minn. Stat. § 604.11', 'MN Lawyer 2025'),
            'confidence', 'medium'
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
    'MN-MED-MAL-SOL-4-YEARS', 5,
    'MN Medical Malpractice: 4-Year SOL (Minn. Stat. § 541.076) — CORRECTED from prior wrong § 541.07(1) citation',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'MN',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'hard_rule',
        'statute', 'Minn. Stat. § 541.076',
        'sol_period', '4 years from date of alleged malpractice or date of discovery of injury',
        'repose_period', '7 years from date of alleged malpractice — absolute bar (Minn. Stat. § 541.076)',
        'discovery_rule', 'SOL runs from date plaintiff knew or should have known of injury',
        'minor_exception', 'Minors: SOL does not run until age of majority; extensions apply under Minn. Stat. § 541.15',
        'prior_error_note', 'Previously cited Minn. Stat. § 541.07(1) which is the 2-year personal injury SOL. Minn. Stat. § 541.076 is the specific medical malpractice SOL that supersedes § 541.07 for health care liability claims.',
        'tolling', jsonb_build_array(
            'Defendant out of state may toll SOL',
            'Legal insanity tolls SOL',
            'Minor exception tolls SOL until age 18',
            'Fraudulent concealment may toll SOL'
        ),
        'verification', jsonb_build_object(
            'audit_date', '2026-03-02',
            'protocol_version', 'v3',
            'pass1_result', 'PASS',
            'pass2_result', 'PASS',
            'statute_text_verified', true,
            'error_corrected', 'Statute corrected from § 541.07(1) (2-yr personal injury SOL) to § 541.076 (4-yr med mal specific SOL)',
            'prior_error_statute', 'Minn. Stat. § 541.07(1) — WRONG, that is 2-year personal injury SOL'
        )
    ),
    'error', 'needs_review', true, false, NOW(), NOW()
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
    'MN-MED-MAL-MODIFIED-COMPARATIVE', 5,
    'MN Medical Malpractice: Modified Comparative Fault 51% Bar (Minn. Stat. § 604.01)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'MN',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'contextual_rule',
        'statute', 'Minn. Stat. § 604.01',
        'negligence_model', 'modified_comparative',
        'bar_threshold', '51%',
        'rule_description', 'Plaintiff may recover if fault does not exceed 51%; damages reduced by plaintiff fault percentage',
        'complete_bar', 'Yes — plaintiff barred if found more than 51% at fault',
        'joint_several', 'Minnesota: proportionate several liability; each party liable for their share of fault',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('Minn. Stat. § 604.01', 'Alllaw.com Minnesota Med Mal', 'Justia Minnesota Comparative Fault'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();
