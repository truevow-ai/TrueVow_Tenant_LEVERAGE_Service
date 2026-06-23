-- =====================================================
-- North Carolina (NC) Medical Malpractice Rules
-- Enhanced Verification Protocol v2.0
-- =====================================================
-- State: North Carolina
-- Governing Law: NCGS Chapter 90, Article 1B (Medical Malpractice Actions)
-- Negligence Model: CONTRIBUTORY NEGLIGENCE (complete bar) — NCGS § 1-139
-- SOL: 3 years from injury/discovery; 4-year repose (NCGS § 1-15(c))
-- Damage Caps: Non-economic cap $500,000 indexed every 3 years by CPI (NCGS § 90-21.19)
--              Cap lifted for gross negligence, intentional conduct, wrongful death w/ disfigurement
-- Expert: Rule 9(j) affidavit must be filed with complaint (NCGS § 1A-1, Rule 9(j))
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
    'NC-MED-MAL-STANDARD-OF-CARE', 5,
    'NC Medical Malpractice: Standard of Care (NCGS § 90-21.12)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'NC',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'contextual_rule',
        'statute', 'NCGS § 90-21.12',
        'standard_text', 'A health care provider is not liable for the personal injury or death of a patient unless the evidence establishes that the health care provider performed or failed to perform a procedure in a manner that is not in accordance with the standards of practice among members of the same health care profession with similar training and experience situated in the same or similar communities at the time of the alleged act',
        'key_elements', jsonb_build_array(
            'Duty: provider-patient relationship must be established',
            'Breach: failure to meet standards of practice of similar providers in same or similar communities',
            'Causation: breach must be the proximate cause of plaintiff''s injury',
            'Damages: actual physical, economic, or non-economic harm resulted'
        ),
        'locality_rule', 'NC applies a modified locality rule — "same or similar communities" standard; not strictly statewide',
        'informed_consent', 'Available under NCGS § 90-21.13; provider must obtain informed consent and disclose material risks',
        'res_ipsa', 'Doctrine available in NC medical malpractice cases where negligence is apparent from the facts',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('NCGS § 90-21.12', 'NCGS § 90-21.13', 'NC Courts'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 2: RULE 9(j) EXPERT AFFIDAVIT (MANDATORY)
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, specialization, document_type,
    jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status,
    is_active, is_template, created_at, updated_at
)
VALUES (
    'NC-MED-MAL-RULE-9J-AFFIDAVIT', 5,
    'NC Medical Malpractice: Rule 9(j) Expert Affidavit (NCGS § 1A-1, Rule 9(j))',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'NC',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'filing_requirement',
        'statute', 'NCGS § 1A-1, Rule 9(j)',
        'requirement', 'Every medical malpractice complaint must be accompanied by a Rule 9(j) certification stating that the alleged negligent acts have been reviewed by a person who is reasonably expected to qualify as an expert witness and who is willing to testify that the medical care did not comply with the applicable standard of care',
        'filing_deadline', 'Must be filed contemporaneously with the complaint; no separate deadline',
        'expert_qualifications', jsonb_build_object(
            'same_specialty', 'Must specialize in the same specialty as the defendant or a similar specialty',
            'active_practice', 'Must devote a majority of professional time to active clinical practice in the specialty, or teaching in the specialty at an accredited educational institution',
            'NC_or_contiguous', 'Expert may be from any state but must meet NC qualification standards'
        ),
        'failure_consequence', 'Complaint is subject to dismissal with prejudice; no cure after filing',
        'extension_available', 'Court may allow 30-day extension on motion before filing if additional time needed to locate expert',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('NCGS § 1A-1 Rule 9(j)', 'NC Court of Appeals precedent', 'NC Courts'),
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
    'NC-MED-MAL-DAMAGE-CAP', 5,
    'NC Medical Malpractice: Non-Economic Damage Cap (NCGS § 90-21.19)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'NC',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'damages_rule',
        'statute', 'NCGS § 90-21.19',
        'caps_apply', true,
        'non_economic_cap_base', 500000,
        'annual_adjustment', true,
        'adjustment_basis', 'Adjusted every 3 years based on Consumer Price Index; Office of State Budget and Management publishes updated cap',
        'cap_notes', 'Cap applies to non-economic damages (pain and suffering, emotional distress, loss of consortium) arising from the same professional services regardless of number of defendants; jury NOT informed of the cap',
        'cap_exceptions', jsonb_build_array(
            'No cap if defendant engaged in gross negligence, wanton conduct, or intentional misconduct',
            'No cap if injury includes significant permanent disfigurement',
            'No cap if injury results in death due to gross negligence or intentional conduct'
        ),
        'economic_damages', 'No cap — medical expenses, lost wages, future economic losses fully recoverable',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('NCGS § 90-21.19', 'Justia North Carolina 2023', 'NC OSBM'),
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
    'NC-MED-MAL-SOL-3-YEARS', 5,
    'NC Medical Malpractice: Statute of Limitations 3 Years (NCGS § 1-15(c))',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'NC',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'timeliness_rule',
        'statute', 'NCGS § 1-15(c)',
        'sol_period', '3 years',
        'trigger', 'Date the injury occurred; or if not immediately discoverable, date plaintiff discovered or reasonably should have discovered the injury',
        'discovery_rule', true,
        'repose_period', '4 years from the last act of the defendant giving rise to the claim (absolute bar)',
        'foreign_object', 'Discovery rule applies; SOL runs from date foreign object discovered',
        'minor_rule', 'If injured party is a minor, SOL does not begin to run until the minor reaches age 18, but is subject to the 10-year outer limit from the last act',
        'wrongful_death', '2 years from date of death (NCGS § 1-53)',
        'tolling', jsonb_build_array(
            'Legal disability (minority, incompetency)',
            'Fraudulent concealment by defendant',
            'Failure to discover injury despite reasonable diligence'
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('NCGS § 1-15(c)', 'NCGS § 1-53', 'NC Courts'),
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
    'NC-MED-MAL-CONTRIBUTORY-NEGLIGENCE', 5,
    'NC Medical Malpractice: Contributory Negligence Complete Bar (NCGS § 1-139)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'NC',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'negligence_model',
        'statute', 'NCGS § 1-139',
        'negligence_model', 'contributory_negligence',
        'complete_bar', true,
        'bar_threshold', 'any fault',
        'rule_description', 'North Carolina is one of the few remaining states applying pure contributory negligence — if plaintiff is found even 1% at fault, recovery is COMPLETELY BARRED regardless of defendant''s degree of fault',
        'last_clear_chance', 'Last clear chance doctrine available to mitigate contributory negligence bar in limited circumstances',
        'critical_note', 'This is a critical pleading consideration — allegations must not inadvertently suggest plaintiff fault; defendant will assert contributory negligence as complete defense',
        'nc_unique', 'Only 5 jurisdictions apply contributory negligence: NC, VA, MD, AL, DC',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('NCGS § 1-139', 'NC contributory negligence case law', 'Sorrells v. M.Y.B. Hospitality Ventures'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();
