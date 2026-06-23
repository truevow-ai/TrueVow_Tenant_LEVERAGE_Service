-- West Virginia Medical Malpractice Validation Rules (Batch 10)
-- 5 rules: standard of care, expert requirements, damage caps, SOL, negligence model
-- Schema: leverage.validation_rules (no physical sub_specialization_type / jurisdiction_code columns)

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, specialization, document_type,
    jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status,
    is_active, is_template, created_at, updated_at
)
VALUES
(
    'WV-MED-MAL-STANDARD-OF-CARE', 5,
    'West Virginia Medical Malpractice Standard of Care',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'WV',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'statute', 'W. Va. Code § 55-7B-3',
        'standard', 'reasonable_and_prudent_healthcare_provider',
        'description', 'West Virginia requires that a healthcare provider exercise the degree of care, skill, and treatment which, in light of all relevant surrounding circumstances, is recognized as acceptable and appropriate by reasonably prudent similar healthcare providers. Governed by the West Virginia Medical Professional Liability Act.',
        'key_elements', jsonb_build_array(
            'Defendant is a healthcare provider as defined by W. Va. Code § 55-7B-2',
            'Failure to meet the standard of care for the specialty',
            'Causal connection between breach and injury',
            'Actual damages resulted'
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('W. Va. Code § 55-7B-3', '§ 55-7B-2', 'Gerver v. Benavides'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
),
(
    'WV-MED-MAL-SCREENING-CERTIFICATE', 5,
    'West Virginia Screening Certificate of Merit Requirement',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'WV',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'statute', 'W. Va. Code § 55-7B-6',
        'requirement', 'screening_certificate_of_merit',
        'description', 'West Virginia requires a plaintiff to provide pre-suit notice and a screening certificate of merit at least 30 days before filing suit. The certificate must be signed by a qualified expert who attests that the defendant deviated from the applicable standard of care.',
        'certificate_requirements', jsonb_build_object(
            'timing', 'At least 30 days before filing complaint',
            'expert_qualifications', 'Licensed in same or related specialty; active clinical practice',
            'content', 'Expert must identify specific acts of negligence and causation basis',
            'failure_consequence', 'Complaint subject to dismissal without prejudice'
        ),
        'sol_tolling', '30-day pre-suit notice period tolls the SOL',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('W. Va. Code § 55-7B-6', 'Hinchman v. Gillette'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
),
(
    'WV-MED-MAL-DAMAGE-CAPS', 5,
    'West Virginia Medical Malpractice Non-Economic Damage Cap',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'WV',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'statute', 'W. Va. Code § 55-7B-8',
        'non_economic_cap', 250000,
        'non_economic_cap_catastrophic', 500000,
        'cap_currency', 'USD',
        'description', 'West Virginia caps non-economic damages in medical malpractice cases at $250,000 for standard injuries and $500,000 for catastrophic injuries such as wrongful death, permanent physical deformity, or loss of use of a bodily organ.',
        'catastrophic_injuries', jsonb_build_array(
            'Wrongful death',
            'Permanent and substantial physical deformity or loss of use of a limb',
            'Permanent physical injury requiring continuous or long-term care'
        ),
        'punitive_damages', jsonb_build_object(
            'available', true,
            'standard', 'Actual malice or conscious, reckless indifference',
            'cap', 'None statutory'
        ),
        'cap_notes', 'WV: $250k standard non-economic cap; $500k catastrophic; both inflation-adjusted under § 55-7B-8(c).',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('W. Va. Code § 55-7B-8', 'MacDonald v. City Hospital'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
),
(
    'WV-MED-MAL-SOL-2-YEARS', 5,
    'West Virginia Medical Malpractice Statute of Limitations',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'WV',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'statute', 'W. Va. Code § 55-7B-4',
        'sol_period', '2 years',
        'trigger', 'date_of_injury_or_discovery',
        'repose_period', '10 years from negligent act or omission',
        'discovery_rule', true,
        'exceptions', jsonb_build_object(
            'minors', 'SOL tolled until age 20 (2 years after majority); 10-year repose still applies',
            'fraudulent_concealment', 'Tolled during fraudulent concealment',
            'foreign_object', '2 years from discovery'
        ),
        'sol_notes', 'West Virginia uses a 2-year discovery SOL with a 10-year statute of repose from the negligent act. Pre-suit notice (§ 55-7B-6) tolls SOL for 30 days.',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('W. Va. Code § 55-7B-4', 'Courtney v. Craig'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
),
(
    'WV-MED-MAL-MODIFIED-COMPARATIVE-FAULT', 5,
    'West Virginia Modified Comparative Fault (51% Bar)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'WV',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'statute', 'W. Va. Code § 55-7-13a',
        'negligence_model', 'modified_comparative',
        'bar_threshold', 51,
        'complete_bar', true,
        'description', 'West Virginia follows modified comparative fault with a 51% bar. Plaintiff may recover if their fault does not exceed 50%; plaintiff is barred from all recovery if 51% or more at fault. Damages are reduced by plaintiff share of fault.',
        'joint_several', jsonb_build_object(
            'rule', 'Each defendant severally liable for proportionate share of non-economic damages; joint and several for economic damages',
            'statute', 'W. Va. Code § 55-7-13c'
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('W. Va. Code § 55-7-13a', '§ 55-7-13c', 'Riffe v. Armstrong'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config,
              updated_at       = NOW();
