-- Pennsylvania Medical Malpractice Validation Rules (Batch 8)
-- 5 rules: standard of care, certificate of merit, no compensatory caps, SOL, negligence model
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
    'PA-MED-MAL-STANDARD-OF-CARE', 5,
    'Pennsylvania Medical Malpractice Standard of Care',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'PA',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'statute', '40 P.S. § 1303.101 et seq. (MCARE Act)',
        'standard', 'specialty_specific',
        'description', 'Pennsylvania requires a healthcare provider to use the level of care, skill, and treatment that, in light of all relevant surrounding circumstances, is recognized as appropriate and accepted by reasonably prudent similar healthcare providers. Governed by the MCARE Act (40 P.S. § 1303.101 et seq.).',
        'key_elements', jsonb_build_array(
            'Defendant is a licensed healthcare provider',
            'Deviation from the applicable standard of care for the specialty',
            'Causal connection between deviation and injury',
            'Actual damages resulted'
        ),
        'venue_rule', 'Medical malpractice cases must be filed in the county where the cause of action arose (Pa.R.C.P. 1006(a.1))',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('40 P.S. § 1303.101', 'MCARE Act', 'Pa.R.C.P. 1006(a.1)'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
),
(
    'PA-MED-MAL-CERTIFICATE-OF-MERIT', 5,
    'Pennsylvania Certificate of Merit Requirement',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'PA',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'statute', 'Pa.R.C.P. 1042.3',
        'requirement', 'certificate_of_merit_required',
        'description', 'Pennsylvania requires a plaintiff to file a Certificate of Merit (COM) within 60 days of filing the complaint. The COM must be signed by an attorney or expert and certify that a licensed professional has provided a written statement that the defendant deviated from an acceptable professional standard.',
        'com_requirements', jsonb_build_object(
            'timing', 'Within 60 days of filing complaint',
            'signed_by', 'Attorney or plaintiff (pro se)',
            'content', 'Licensed professional has provided a written statement that there exists a reasonable probability that care fell outside acceptable professional standards',
            'extension', 'Up to 60-day extension may be requested before deadline',
            'failure_consequence', 'Praecipe to enter judgment of non pros on the complaint'
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('Pa.R.C.P. 1042.3', 'Womer v. Hilliker 908 A.2d 269 (Pa. 2006)'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
),
(
    'PA-MED-MAL-NO-COMPENSATORY-CAPS', 5,
    'Pennsylvania Medical Malpractice — No Compensatory Damage Caps',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'PA',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'caps_applicable', false,
        'description', 'Pennsylvania has no statutory cap on compensatory (economic or non-economic) damages in medical malpractice cases. Punitive damages are limited to 200% of compensatory damages under the MCARE Act.',
        'punitive_damages', jsonb_build_object(
            'available', true,
            'statute', '40 P.S. § 1303.505',
            'cap', '200% of compensatory damages',
            'standard', 'Outrageous conduct, malice, or willful/wanton disregard'
        ),
        'cap_notes', 'No non-economic or compensatory cap in Pennsylvania; punitive damages capped at 2x compensatory under MCARE Act.',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('40 P.S. § 1303.505', 'MCARE Act 2002'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
),
(
    'PA-MED-MAL-SOL-2-YEARS', 5,
    'Pennsylvania Medical Malpractice Statute of Limitations',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'PA',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'statute', '42 Pa.C.S. § 5524(2)',
        'sol_period', '2 years',
        'trigger', 'date_of_discovery',
        'repose_period', '7 years from negligent act or omission',
        'discovery_rule', true,
        'exceptions', jsonb_build_object(
            'minors', 'SOL tolled until age 20; 7-year repose still applies',
            'foreign_object', '2 years from discovery; no repose for foreign objects',
            'fraudulent_concealment', 'Tolled during period of fraudulent concealment'
        ),
        'sol_notes', 'Pennsylvania uses a 2-year discovery rule; clock runs from when plaintiff knows or reasonably should know of injury and cause. Seven-year statute of repose applies (42 Pa.C.S. § 5524). NOTE: Primary statute may need to be updated to 40 P.S. § 1303.513 (MCARE Act) — pending attorney confirmation.',
        'verification', jsonb_build_object(
            'statute_verified', false,
            'sources', jsonb_build_array('42 Pa.C.S. § 5524(2)', '40 P.S. § 1303.513', 'Reibstein v. Rite Aid Corp.'),
            'confidence', 'medium'
        ),
        'protocol_v3_flag', jsonb_build_object(
            'flagged_by',        'protocol_v3_dual_pass',
            'flag_date',         '2026-03-02',
            'pass1_result',      'INCONCLUSIVE - Primary statute field = 42 Pa.C.S. 5524(2) (general PI). PA med-mal has specific MCARE Act (40 P.S. 1303.513). Sources array includes 1303.513 but primary citation is wrong statute.',
            'pass2_result',      'INCONCLUSIVE - MCARE Act (Act 13 of 2002) at 40 P.S. 1303.513 governs health care liability. 7yr repose is also from 1303.513, not 5524. The 2yr period is correct but primary statute citation should be 1303.513.',
            'attorney_question', 'Confirm whether 40 P.S. 1303.513 (MCARE Act) is the correct primary citation for PA med-mal SOL (not 42 Pa.C.S. 5524). If yes, update primary statute field. Confirm 2yr period and 7yr repose are correct under MCARE Act.',
            'priority',          'HIGH'
        )
    ),
    'error', 'needs_review', true, false, NOW(), NOW()
),
(
    'PA-MED-MAL-MODIFIED-COMPARATIVE-FAULT', 5,
    'Pennsylvania Modified Comparative Fault (51% Bar)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'PA',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'statute', '42 Pa.C.S. § 7102',
        'negligence_model', 'modified_comparative',
        'bar_threshold', 51,
        'complete_bar', true,
        'description', 'Pennsylvania follows modified comparative fault with a 51% bar. Plaintiff may recover if their negligence is 50% or less; plaintiff is barred from all recovery if 51% or more at fault. Damages are reduced by plaintiff share of fault.',
        'joint_several', jsonb_build_object(
            'rule', 'Joint and several liability abolished for most purposes under 42 Pa.C.S. § 7102; defendants severally liable for their proportionate share',
            'exception', 'Joint and several applies if defendant is more than 60% at fault'
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('42 Pa.C.S. § 7102', 'Walton v. Avco Corp.'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    review_status    = EXCLUDED.review_status,
    updated_at       = NOW();
