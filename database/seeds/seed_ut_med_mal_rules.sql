-- Utah Medical Malpractice Validation Rules (Batch 9)
-- 5 rules: standard of care, pre-litigation panel, damage caps, SOL, negligence model
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
    'UT-MED-MAL-STANDARD-OF-CARE', 5,
    'Utah Medical Malpractice Standard of Care',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'UT',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'statute', 'Utah Code Ann. § 78B-3-403 (Health Care Malpractice Act)',
        'standard', 'national_standard',
        'description', 'Utah requires a healthcare provider to exercise that degree of care, skill, and learning expected of a reasonably prudent healthcare provider in the class to which the healthcare provider belongs, acting in the same or similar circumstances. Utah uses a national standard of care.',
        'key_elements', jsonb_build_array(
            'Defendant is a healthcare provider as defined by Utah Code § 78B-3-403',
            'Failure to exercise the nationally recognized standard of care for the specialty',
            'Causal connection between breach and injury',
            'Actual damages resulted'
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('Utah Code Ann. § 78B-3-403', '§ 78B-3-404', 'Pearce v. Olsen'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
),
(
    'UT-MED-MAL-PRE-LITIGATION-PANEL', 5,
    'Utah Health Care Malpractice Pre-Litigation Panel',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'UT',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'statute', 'Utah Code Ann. § 78B-3-416 through § 78B-3-426',
        'requirement', 'pre_litigation_panel_required',
        'description', 'Utah requires that all medical malpractice claims be submitted to the Division of Occupational and Professional Licensing (DOPL) pre-litigation panel before filing suit. The panel reviews the claim and issues a non-binding opinion on liability.',
        'panel_requirements', jsonb_build_object(
            'administered_by', 'Division of Occupational and Professional Licensing (DOPL)',
            'composition', 'Panel of healthcare providers, attorney, and layperson',
            'timing', 'Must be requested before filing; SOL tolled during review',
            'opinion', 'Non-binding; parties may proceed to trial regardless of panel opinion',
            'failure_consequence', 'Complaint subject to dismissal for failure to follow pre-litigation process'
        ),
        'sol_tolling', 'SOL is tolled during the pre-litigation panel review period',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('Utah Code Ann. § 78B-3-416', '§ 78B-3-418', 'Mower v. Baird'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
),
(
    'UT-MED-MAL-DAMAGE-CAPS', 5,
    'Utah Medical Malpractice Non-Economic Damage Cap',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'UT',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'statute', 'Utah Code Ann. § 78B-3-410',
        'non_economic_cap', 450000,
        'cap_currency', 'USD',
        'inflation_adjustment', true,
        'description', 'Utah caps non-economic damages in medical malpractice cases at $450,000 (adjusted periodically for inflation). The cap applies per occurrence.',
        'exceptions', jsonb_build_array(
            'Intentional misconduct may allow punitive damages beyond cap'
        ),
        'punitive_damages', jsonb_build_object(
            'available', true,
            'standard', 'Willful and malicious or intentionally fraudulent conduct',
            'cap', 'Greater of $50,000 or 3x compensatory damages'
        ),
        'cap_notes', 'Utah non-economic cap is $450,000 per occurrence, subject to adjustment for inflation.',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('Utah Code Ann. § 78B-3-410', 'Utah State Legislature'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
),
(
    'UT-MED-MAL-SOL-2-YEARS', 5,
    'Utah Medical Malpractice Statute of Limitations',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'UT',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'statute', 'Utah Code Ann. § 78B-3-404',
        'sol_period', '2 years',
        'trigger', 'date_of_discovery',
        'repose_period', '4 years from negligent act or omission',
        'discovery_rule', true,
        'exceptions', jsonb_build_object(
            'minors', 'SOL tolled until age 18; 4-year repose still applies',
            'fraudulent_concealment', 'Tolled during fraudulent concealment',
            'foreign_object', '2 years from discovery; 4-year repose does not apply'
        ),
        'sol_notes', 'Utah uses a 2-year discovery rule from when plaintiff knew or reasonably should have known, with a 4-year repose from the act/omission. Pre-litigation panel tolls the SOL.',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('Utah Code Ann. § 78B-3-404', '§ 78B-3-416'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
),
(
    'UT-MED-MAL-MODIFIED-COMPARATIVE-FAULT', 5,
    'Utah Modified Comparative Fault (50% Bar)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'UT',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'statute', 'Utah Code Ann. § 78B-5-818',
        'negligence_model', 'modified_comparative',
        'bar_threshold', 50,
        'complete_bar', true,
        'description', 'Utah follows modified comparative fault with a 50% bar. Plaintiff may recover only if their fault is less than 50%; if plaintiff is 50% or more at fault, they are barred from all recovery. Damages are reduced by plaintiff share of fault.',
        'joint_several', jsonb_build_object(
            'rule', 'Joint and several liability abolished; each defendant liable only for proportionate share',
            'exception', 'Retained for intentional torts'
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('Utah Code Ann. § 78B-5-818', 'Harline v. Barker'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config,
              updated_at       = NOW();
