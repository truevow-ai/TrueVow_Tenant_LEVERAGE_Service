-- =====================================================
-- Michigan (MI) Medical Malpractice Rules
-- Enhanced Verification Protocol v2.0
-- =====================================================
-- State: Michigan
-- Governing Law: MCL Chapter 600 (Revised Judicature Act)
-- Negligence Model: MODIFIED COMPARATIVE (51% bar) — MCL § 600.2957/600.2959
-- SOL: 2 years from act OR 6 months from discovery, whichever comes later (MCL § 600.5805(8))
-- Damage Caps: 2024: lower $569k; upper $1,016k catastrophic (MCL § 600.1483)
-- Expert: Notice of Intent 182 days before filing (MCL § 600.2912b) + Affidavit of Merit (MCL § 600.2912d)
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
    'MI-MED-MAL-STANDARD-OF-CARE', 5,
    'MI Medical Malpractice: Standard of Care (MCL § 600.2912a)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'MI',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'contextual_rule',
        'statute', 'MCL § 600.2912a',
        'standard_text', 'In an action alleging malpractice, the plaintiff has the burden of proving that in light of the state of the art existing at the time of the alleged malpractice: (a) the defendant, if a general practitioner, failed to provide the plaintiff the recognized standard of acceptable professional practice or care in the community in which the defendant practices; (b) the defendant, if a specialist, failed to provide the recognized standard of practice or care within that specialty',
        'key_elements', jsonb_build_array(
            'Duty: provider-patient relationship',
            'Breach: failure to meet community standard (general practitioner) or specialty standard',
            'Causation: breach proximately caused injury',
            'Damages: actual injury resulted'
        ),
        'locality_rule', 'General practitioners: community standard. Specialists: national specialty standard.',
        'res_ipsa', 'Doctrine of res ipsa loquitur available in limited circumstances',
        'informed_consent', 'Separate theory; must show failure to disclose material risk (MCL § 600.2912b)',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('MCL § 600.2912a', 'Michigan Courts Bench Book — Medical Malpractice 2024'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 2: NOTICE OF INTENT + AFFIDAVIT OF MERIT
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, specialization, document_type,
    jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status,
    is_active, is_template, created_at, updated_at
)
VALUES (
    'MI-MED-MAL-NOI-AND-AFFIDAVIT', 5,
    'MI Medical Malpractice: 182-Day Notice of Intent + Affidavit of Merit (MCL § 600.2912b/d)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'MI',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'hard_rule',
        'statute', 'MCL § 600.2912b (NOI) and MCL § 600.2912d (Affidavit)',
        'notice_of_intent', jsonb_build_object(
            'requirement', 'Written notice must be served on defendant at least 182 days before filing complaint',
            'contents', jsonb_build_array(
                'Factual basis for each claim',
                'Applicable standard of care',
                'How standard was allegedly breached',
                'Identification of each healthcare provider involved',
                'Manner in which breach caused injury'
            ),
            'shortened_notice', '91-day notice period available if plaintiff previously filed against related parties',
            'medical_records_access', 'Plaintiff must provide access to medical records within 56 days of notice',
            'response_period', 'Defendant has 154 days to respond; failure may support inference of negligence'
        ),
        'affidavit_of_merit', jsonb_build_object(
            'requirement', 'Must be filed with complaint; signed by qualified expert',
            'contents', jsonb_build_array(
                'Expert must be licensed in same specialty as defendant',
                'Must state opinion as to applicable standard of care',
                'Must state how defendant failed to meet that standard',
                'Must state how breach caused injury'
            )
        ),
        'consequence_of_failure', 'Failure to file NOI or affidavit bars the action',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('MCL § 600.2912b', 'MCL § 600.2912d', 'Sommers PC Michigan Med Mal Blog 2024'),
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
    'MI-MED-MAL-DAMAGE-CAPS', 5,
    'MI Medical Malpractice: Non-Economic Damage Caps 2024 (MCL § 600.1483)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'MI',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'hard_rule',
        'statute', 'MCL § 600.1483',
        'non_economic_cap_lower_2024', '$569,000 — standard non-economic damages (pain, suffering, non-monetary losses)',
        'non_economic_cap_upper_2024', '$1,016,000 — for catastrophic injuries: permanent severe cognitive impairment, paralysis, loss of reproductive capacity, permanent severe disfigurement',
        'economic_damages', 'No cap on economic damages (medical expenses, lost wages, future care)',
        'annual_adjustment', 'Caps adjusted annually for inflation per statutory formula',
        'jury_not_informed', 'Jury is not informed of caps; court reduces award if it exceeds applicable cap',
        'cap_category_determination', 'Court determines which cap applies based on nature of injury',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('MCL § 600.1483', 'Buchanan Firm Michigan Med Mal Caps 2024', 'Buckfire Law Michigan Med Mal'),
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
    'MI-MED-MAL-SOL-2-YEARS', 5,
    'MI Medical Malpractice: 2-Year SOL / 6-Month Discovery (MCL § 600.5805(8))',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'MI',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'hard_rule',
        'statute', 'MCL § 600.5805(8)',
        'sol_period', '2 years from date of alleged act or omission',
        'discovery_extension', '6 months from date of discovery if not discovered within 2-year period',
        'accrual_rule', 'Claim accrues on the date of the specific act or omission — not the date of injury or damage',
        'repose_period', '6-year statute of repose from date of last treatment by same provider (MCL § 600.5838a)',
        'foreign_object_exception', 'Foreign object: SOL runs from discovery',
        'minor_exception', 'Minors: at least 10 years from the date of the act or 1 year from majority, whichever is later',
        'tolling', jsonb_build_array(
            'NOI filing tolls SOL during notice period',
            'Minor and mental disability exceptions',
            'Discovery extension for unknown injuries'
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('MCL § 600.5805(8)', 'MCL § 600.5838a', 'Buckfire Law Michigan Med Mal'),
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
    'MI-MED-MAL-MODIFIED-COMPARATIVE', 5,
    'MI Medical Malpractice: Modified Comparative Fault 51% Bar (MCL § 600.2957/600.2959)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'MI',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'contextual_rule',
        'statute', 'MCL § 600.2957 / 600.2959',
        'negligence_model', 'modified_comparative',
        'bar_threshold', '51%',
        'rule_description', 'Plaintiff may recover if fault does not exceed 51%; damages reduced by plaintiff fault percentage',
        'complete_bar', 'Yes — plaintiff barred if found more than 51% at fault',
        'joint_several', 'Michigan: proportionate several liability; each defendant liable for their percentage of fault',
        'fault_allocation', 'Jury must allocate fault among all parties including non-parties in some circumstances',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('MCL § 600.2957', 'MCL § 600.2959', 'Buckfire Law Michigan Med Mal'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();
