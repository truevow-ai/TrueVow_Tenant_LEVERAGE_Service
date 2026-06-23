-- South Carolina Medical Malpractice Validation Rules (Batch 8)
-- 5 rules: standard of care, notice of intent + expert affidavit, damage caps, SOL, negligence model
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
    'SC-MED-MAL-STANDARD-OF-CARE', 5,
    'South Carolina Medical Malpractice Standard of Care',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'SC',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'statute', 'S.C. Code Ann. § 15-79-110',
        'standard', 'same_or_similar_community',
        'description', 'South Carolina requires that a healthcare provider use the degree of care and skill that, under similar circumstances, is ordinarily employed by the medical profession. The standard is measured by what a reasonably competent healthcare provider in the same or similar community would do.',
        'key_elements', jsonb_build_array(
            'Defendant is a licensed healthcare provider',
            'Failure to exercise standard of care applicable in same or similar community',
            'Causal connection between breach and injury',
            'Actual damages resulted'
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('S.C. Code Ann. § 15-79-110', 'Burroughs v. Worsham'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
),
(
    'SC-MED-MAL-NOTICE-INTENT-AFFIDAVIT', 5,
    'South Carolina Notice of Intent and Expert Affidavit Requirement',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'SC',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'statute', 'S.C. Code Ann. § 15-79-125',
        'requirement', 'notice_of_intent_and_expert_affidavit',
        'description', 'South Carolina requires a plaintiff to file a Notice of Intent to File a Suit and an affidavit of a medical expert at least 90 days before filing the complaint. The notice must be served on each defendant healthcare provider.',
        'notice_requirements', jsonb_build_object(
            'timing', '90 days before filing complaint',
            'notice_contents', 'Names of defendants, nature of claim, allegations of negligence',
            'affidavit_required', true,
            'affidavit_contents', 'Expert must specify at least one negligent act or omission and the factual basis for the claim',
            'expert_qualifications', 'Must be licensed in same or related specialty',
            'mediation', 'ADR process triggered during the 90-day notice period',
            'failure_consequence', 'Complaint subject to dismissal; SOL tolled during 90-day period'
        ),
        'sol_tolling', '90-day notice period tolls the statute of limitations',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('S.C. Code Ann. § 15-79-125', '§ 15-79-120', 'Millmine v. Lowcountry Orthopaedics'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
),
(
    'SC-MED-MAL-DAMAGE-CAPS', 5,
    'South Carolina Medical Malpractice Non-Economic Damage Caps',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'SC',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'statute', 'S.C. Code Ann. § 15-32-220',
        'non_economic_cap', 350000,
        'non_economic_cap_per', 'per defendant',
        'non_economic_cap_total', 1050000,
        'cap_currency', 'USD',
        'description', 'South Carolina caps non-economic damages in medical malpractice cases at $350,000 per defendant and $1,050,000 in the aggregate against all defendants. Caps are adjusted annually for inflation.',
        'inflation_adjustment', true,
        'exceptions', jsonb_build_array(
            'Intentional acts',
            'Conduct with actual malice'
        ),
        'punitive_damages', jsonb_build_object(
            'available', true,
            'standard', 'Clear and convincing evidence of willful, wanton, or reckless conduct',
            'cap', '3x compensatory damages or $500,000, whichever is greater'
        ),
        'cap_notes', 'Caps apply per defendant ($350k) and in aggregate ($1.05M); adjusted annually for CPI inflation.',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('S.C. Code Ann. § 15-32-220', '§ 15-32-530'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
),
(
    'SC-MED-MAL-SOL-3-YEARS', 5,
    'South Carolina Medical Malpractice Statute of Limitations',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'SC',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'statute', 'S.C. Code Ann. § 15-3-545',
        'sol_period', '3 years',
        'trigger', 'date_of_discovery',
        'repose_period', '6 years from negligent act or omission',
        'discovery_rule', true,
        'exceptions', jsonb_build_object(
            'minors_under_7', 'Suits filed before age 13 (additional 3 years from discovery)',
            'foreign_object', '2 years from discovery; no repose for foreign objects',
            'fraudulent_concealment', 'Tolled during fraudulent concealment'
        ),
        'sol_notes', 'South Carolina uses a 3-year discovery rule with a 6-year repose from the negligent act. Notice of intent filing tolls the SOL for the 90-day pre-suit period.',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('S.C. Code Ann. § 15-3-545', '§ 15-3-740'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
),
(
    'SC-MED-MAL-MODIFIED-COMPARATIVE-FAULT', 5,
    'South Carolina Modified Comparative Fault (51% Bar)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'SC',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'statute', 'S.C. Code Ann. § 15-38-15',
        'negligence_model', 'modified_comparative',
        'bar_threshold', 51,
        'complete_bar', true,
        'description', 'South Carolina follows modified comparative fault with a 51% bar. Plaintiff may recover if their negligence does not exceed 50%; plaintiff is barred from recovery if 51% or more at fault. Recovery is reduced by plaintiff share of fault.',
        'joint_several', jsonb_build_object(
            'rule', 'Joint and several liability abolished (§ 15-38-15); defendants each severally liable for proportionate share only',
            'exception', 'Joint and several applies if defendant is more than 50% at fault for plaintiff damages'
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('S.C. Code Ann. § 15-38-15', 'Nelson v. Concrete Supply Co.'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config,
              updated_at       = NOW();
