-- =====================================================
-- New York (NY) Medical Malpractice Rules
-- Enhanced Verification Protocol v2.0
-- =====================================================
-- State: New York
-- Governing Law: CPLR § 214-a (SOL); CPLR § 3012-a (Attorney Certificate)
-- Negligence Model: PURE COMPARATIVE FAULT — CPLR § 1411
-- SOL: 2.5 years (30 months) from act or last treatment; 1 year for foreign objects (CPLR § 214-a)
-- Damage Caps: NO CAPS on damages in NY medical malpractice
-- Expert: CPLR § 3012-a attorney certificate of merit required with complaint
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
    'NY-MED-MAL-STANDARD-OF-CARE', 5,
    'NY Medical Malpractice: Standard of Care (common law; Education Law § 6530)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'NY',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'contextual_rule',
        'statute', 'NY Education Law § 6530; common law',
        'standard_text', 'A physician must possess and apply the knowledge and use the skill and care that is ordinarily possessed and exercised by practitioners of the medical profession in good standing; in a medical specialist''s case, the standard is that of a reasonably prudent specialist in the same field',
        'key_elements', jsonb_build_array(
            'Duty: provider-patient relationship must be established',
            'Breach: failure to meet standard of a reasonably prudent similar physician or specialist',
            'Causation: departure must be a proximate cause of plaintiff''s injury (NY "substantial factor" causation test)',
            'Damages: actual injury (economic or non-economic) resulted'
        ),
        'causation_standard', 'NY uses "substantial factor" causation test — departure must be a substantial factor in bringing about the harm',
        'locality_rule', 'NY does not apply a strict locality rule; standard is that of a reasonably prudent physician nationwide in same specialty',
        'informed_consent', 'Separate cause of action under PHL § 2805-d; provider must disclose alternatives, foreseeable risks, and benefits a reasonable patient would want to know',
        'res_ipsa', 'Doctrine of res ipsa loquitur available in NY medical malpractice where injury speaks for itself',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('NY Education Law § 6530', 'PHL § 2805-d', 'NY Court of Appeals precedent'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 2: CPLR § 3012-a CERTIFICATE OF MERIT
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, specialization, document_type,
    jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status,
    is_active, is_template, created_at, updated_at
)
VALUES (
    'NY-MED-MAL-CERTIFICATE-OF-MERIT', 5,
    'NY Medical Malpractice: Attorney Certificate of Merit (CPLR § 3012-a)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'NY',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'filing_requirement',
        'statute', 'CPLR § 3012-a',
        'requirement', 'The complaint in a medical malpractice action must be accompanied by a certificate of merit signed by the attorney, stating that the attorney has reviewed the facts of the case and has consulted with at least one physician licensed to practice medicine, and that the attorney has concluded there is a reasonable basis for the commencement of the action',
        'filing_deadline', 'Filed concurrently with the complaint',
        'attorney_certification', 'Attorney (not expert) must certify; they must consult with a licensed physician who is knowledgeable about the relevant medical issues',
        'physician_consulted', 'Attorney must consult with at least one qualified physician; physician does not need to sign the certificate',
        'alternative', 'If unable to consult with physician before filing due to SOL expiration, attorney may file a certificate stating this; must cure within 90 days',
        'failure_consequence', 'Failure to file certificate may result in dismissal of action',
        'note', 'This is an attorney certificate, not a medical expert affidavit; the expert affidavit is required later during the litigation process',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('CPLR § 3012-a', 'NY Courts', 'Justia New York'),
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
    'NY-MED-MAL-NO-DAMAGE-CAPS', 5,
    'NY Medical Malpractice: No Statutory Damage Caps',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'NY',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'damages_rule',
        'caps_apply', false,
        'non_economic_cap', null,
        'economic_cap', null,
        'cap_notes', 'New York imposes NO statutory cap on damages in medical malpractice cases — neither economic nor non-economic damages are limited; juries may award full compensation for all provable losses',
        'structured_judgments', 'CPLR Article 50-A requires periodic payment (structured settlement) of future damages exceeding $250,000 in medical malpractice cases; this does not cap the total award but structures payment over time',
        'economic_damages', 'Fully recoverable without limitation (medical expenses, lost wages, future care)',
        'non_economic_damages', 'Fully recoverable without limitation (pain, suffering, loss of enjoyment of life)',
        'cplr_50a', 'Periodic payment of future damages over $250,000 may be required under CPLR § 5031 in medical malpractice',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('CPLR Article 50-A', 'NY Court of Appeals', '1800LionLaw NY summary'),
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
    'NY-MED-MAL-SOL-30-MONTHS', 5,
    'NY Medical Malpractice: Statute of Limitations 30 Months (CPLR § 214-a)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'NY',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'timeliness_rule',
        'statute', 'CPLR § 214-a',
        'sol_period', '30 months (2.5 years)',
        'trigger', 'Date of the alleged malpractice act or omission; OR date of last treatment if continuous treatment doctrine applies',
        'discovery_rule', false,
        'occurrence_based', true,
        'sol_notes', 'NY uses an occurrence-based SOL (NOT a discovery rule for general cases); 30-month period begins at the time of the alleged wrongful act',
        'continuous_treatment', 'Continuous treatment doctrine: SOL tolled and begins running from date of last treatment for same condition — very important in NY practice',
        'foreign_object', '1 year from date of discovery of foreign object left in body (special exception under CPLR § 214-a)',
        'minor_rule', 'For children under age 18, SOL is tolled; action may be brought within 30 months after child turns 18, but no later than 10 years after the act',
        'wrongful_death', '2 years from date of death (EPTL § 5-4.1)',
        'repose_period', 'No general statute of repose beyond the 30-month period in NY',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('CPLR § 214-a', 'EPTL § 5-4.1', 'NY Court of Appeals continuous treatment doctrine cases'),
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
    'NY-MED-MAL-PURE-COMPARATIVE-FAULT', 5,
    'NY Medical Malpractice: Pure Comparative Fault (CPLR § 1411)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint', 'state', 'NY',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'authority_level', 'negligence_model',
        'statute', 'CPLR § 1411',
        'negligence_model', 'pure_comparative',
        'complete_bar', false,
        'bar_threshold', 'none',
        'rule_description', 'New York follows pure comparative fault — plaintiff may recover even if predominantly at fault; damages are reduced proportionally by plaintiff''s percentage of fault with no bar to recovery',
        'joint_several_liability', 'CPLR § 1601: joint and several liability modified; defendants less than 50% at fault are liable only for their equitable share of non-economic damages; full joint and several liability for defendants 51%+ at fault',
        'multiple_defendants', 'Fault apportioned among all parties; each defendant responsible for their proportionate share of non-economic damages based on fault percentage (CPLR § 1601)',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('CPLR § 1411', 'CPLR § 1601', 'NY Court of Appeals comparative fault cases'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();
