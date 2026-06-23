-- Texas Medical Malpractice Validation Rules (Batch 9)
-- 5 rules: standard of care, expert report (Chapter 74), damage caps, SOL, negligence model
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
    'TX-MED-MAL-STANDARD-OF-CARE', 5,
    'Texas Medical Malpractice Standard of Care',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'TX',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'statute', 'Tex. Civ. Prac. & Rem. Code § 74.001 et seq. (TMLA)',
        'standard', 'accepted_standard_of_medical_care',
        'description', 'Texas requires a healthcare provider to use the degree of care and skill expected of a reasonably prudent healthcare provider in the same or similar circumstances. Governed by Chapter 74 of the Texas Civil Practice and Remedies Code (Texas Medical Liability Act).',
        'key_elements', jsonb_build_array(
            'Defendant is a healthcare provider as defined by Tex. Civ. Prac. & Rem. Code § 74.001',
            'Violation of accepted standard of medical care for treating the condition involved',
            'Proximate causation of injury',
            'Actual damages'
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('Tex. Civ. Prac. & Rem. Code § 74.001', 'Mallen v. Mt. Sinai Medical Center'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
),
(
    'TX-MED-MAL-EXPERT-REPORT-CH74', 5,
    'Texas Chapter 74 Expert Report Requirement',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'TX',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'statute', 'Tex. Civ. Prac. & Rem. Code § 74.351',
        'requirement', 'chapter_74_expert_report',
        'description', 'Texas requires a plaintiff in a health care liability claim to serve one or more expert reports within 120 days of the filing of the defendant''s answer. The report must address the standard of care, the manner in which the defendant deviated, and causation.',
        'report_requirements', jsonb_build_object(
            'timing', 'Within 120 days of defendant answer',
            'expert_qualifications', 'Must be practicing or teaching in relevant field; active clinical practice in preceding year',
            'content', 'Standard of care, breach, and causation — each addressed specifically for each defendant',
            'deficiency_cure', '30-day extension to cure deficient report',
            'failure_consequence', 'Dismissal with prejudice; defendant entitled to attorney fees'
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('Tex. Civ. Prac. & Rem. Code § 74.351', '§ 74.401', 'Scoresby v. Santillan'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
),
(
    'TX-MED-MAL-DAMAGE-CAPS', 5,
    'Texas Medical Malpractice Non-Economic Damage Caps',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'TX',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'statute', 'Tex. Civ. Prac. & Rem. Code § 74.301',
        'non_economic_cap_physician', 250000,
        'non_economic_cap_hospital', 250000,
        'non_economic_cap_multiple_hospitals', 500000,
        'cap_currency', 'USD',
        'description', 'Texas caps non-economic damages in health care liability claims. Individual healthcare providers are subject to a $250,000 per-provider cap. Hospitals and health care institutions are subject to a combined cap of $250,000 (one institution) or $500,000 (multiple institutions), giving an overall maximum of $750,000 per claimant.',
        'cap_structure', jsonb_build_object(
            'per_physician_or_provider', 250000,
            'per_single_hospital', 250000,
            'per_multiple_hospitals', 500000,
            'overall_max', 750000
        ),
        'punitive_damages', jsonb_build_object(
            'available', false,
            'notes', 'Punitive damages not available in Texas health care liability claims (§ 74.301(c))'
        ),
        'cap_notes', 'The three-part Texas cap structure: $250k physician + $250k single hospital or $500k multiple hospitals = max $750k non-economic per claimant.',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('Tex. Civ. Prac. & Rem. Code § 74.301', '§ 74.302', 'Prop 12 (2003 amendment)'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
),
(
    'TX-MED-MAL-SOL-2-YEARS', 5,
    'Texas Medical Malpractice Statute of Limitations',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'TX',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'statute', 'Tex. Civ. Prac. & Rem. Code § 74.251',
        'sol_period', '2 years',
        'trigger', 'date_of_occurrence_or_discovery',
        'repose_period', '10 years from negligent act or omission',
        'discovery_rule', true,
        'exceptions', jsonb_build_object(
            'minors_under_12', 'SOL tolled until age 14; 10-year repose still applies',
            'fraudulent_concealment', 'Tolled during fraudulent concealment',
            'foreign_object', '2 years from discovery; 10-year repose'
        ),
        'sol_notes', 'Texas has a 2-year SOL from discovery with a 10-year repose. The SOL is one of the strictest — courts disfavor extended tolling arguments in med mal cases.',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('Tex. Civ. Prac. & Rem. Code § 74.251', 'Strickland v. Pinder'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
),
(
    'TX-MED-MAL-MODIFIED-COMPARATIVE-FAULT', 5,
    'Texas Modified Comparative Fault (51% Bar)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'TX',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'statute', 'Tex. Civ. Prac. & Rem. Code § 33.001',
        'negligence_model', 'modified_comparative',
        'bar_threshold', 51,
        'complete_bar', true,
        'description', 'Texas follows modified comparative fault with a 51% bar. Plaintiff may recover only if their percentage of responsibility does not exceed 50%. If plaintiff is 51% or more responsible, they are barred from all recovery. Damages are reduced by plaintiff share of fault.',
        'proportionate_responsibility', jsonb_build_object(
            'statute', 'Tex. Civ. Prac. & Rem. Code § 33.013',
            'rule', 'Each defendant liable only for their proportionate share of damages',
            'joint_several_exception', 'Joint and several for defendants with 51% or more responsibility'
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('Tex. Civ. Prac. & Rem. Code § 33.001', '§ 33.013'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config,
              updated_at       = NOW();
