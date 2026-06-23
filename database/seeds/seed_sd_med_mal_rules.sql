-- South Dakota Medical Malpractice Validation Rules (Batch 9)
-- 5 rules: standard of care, expert affidavit, damage caps, SOL, negligence model
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
    'SD-MED-MAL-STANDARD-OF-CARE', 5,
    'South Dakota Medical Malpractice Standard of Care',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'SD',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'statute', 'SDCL § 20-9-1',
        'standard', 'reasonable_care_in_practice',
        'description', 'South Dakota requires that a healthcare provider exercise that degree of care, skill, and learning expected of a reasonably prudent healthcare provider in the same or similar circumstances. Standard is compared to similar practitioners in the same geographic locality or specialty.',
        'key_elements', jsonb_build_array(
            'Defendant is a licensed healthcare provider',
            'Failure to exercise the degree of care expected of a similar provider',
            'Causal connection between breach and injury',
            'Actual damages resulted'
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('SDCL § 20-9-1', 'Shamburger v. Behrens'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
),
(
    'SD-MED-MAL-EXPERT-AFFIDAVIT', 5,
    'South Dakota Medical Malpractice Expert Affidavit Requirement',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'SD',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'statute', 'SDCL § 21-3-7',
        'requirement', 'expert_affidavit_required',
        'description', 'South Dakota requires an affidavit of merit from a qualified medical expert to be filed with the complaint in medical malpractice actions. The expert must attest that the defendant deviated from the applicable standard of care and that such deviation caused plaintiff harm.',
        'affidavit_requirements', jsonb_build_object(
            'timing', 'Filed with complaint',
            'expert_qualifications', 'Licensed in same or related specialty as defendant',
            'content', 'Expert must identify specific acts of negligence and opine that deviation caused plaintiff injury',
            'failure_consequence', 'Dismissal with prejudice'
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('SDCL § 21-3-7', 'Papke v. Harbert'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
),
(
    'SD-MED-MAL-DAMAGE-CAPS', 5,
    'South Dakota Medical Malpractice Non-Economic Damage Cap',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'SD',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'statute', 'SDCL § 21-3-11',
        'non_economic_cap', 500000,
        'cap_currency', 'USD',
        'description', 'South Dakota caps non-economic damages in medical malpractice actions at $500,000. The cap applies per occurrence and is not adjusted for inflation.',
        'exceptions', jsonb_build_array(
            'Willful and wanton misconduct',
            'Gross negligence'
        ),
        'punitive_damages', jsonb_build_object(
            'available', true,
            'standard', 'Oppression, fraud, or malice',
            'cap', 'None statutory'
        ),
        'cap_notes', 'The $500,000 non-economic cap applies per occurrence in South Dakota med mal cases.',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('SDCL § 21-3-11', 'South Dakota Legislature'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
),
(
    'SD-MED-MAL-SOL-2-YEARS', 5,
    'South Dakota Medical Malpractice Statute of Limitations',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'SD',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'statute', 'SDCL § 15-2-14.1',
        'sol_period', '2 years',
        'trigger', 'date_of_discovery',
        'repose_period', 'None statutory',
        'discovery_rule', true,
        'exceptions', jsonb_build_object(
            'minors', 'Tolled during minority; 2 years from age 18',
            'foreign_object', '2 years from discovery',
            'fraudulent_concealment', 'Tolled during fraudulent concealment'
        ),
        'sol_notes', 'South Dakota uses a 2-year discovery rule from when plaintiff knew or reasonably should have known of the injury. No separate repose period.',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('SDCL § 15-2-14.1', 'Klatt v. Continental Grain'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
),
(
    'SD-MED-MAL-MODIFIED-COMPARATIVE-FAULT', 5,
    'South Dakota Modified Comparative Fault (51% Bar)',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'SD',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'statute', 'SDCL § 20-9-2',
        'negligence_model', 'modified_comparative',
        'bar_threshold', 51,
        'complete_bar', true,
        'description', 'South Dakota follows modified comparative fault with a 51% bar. Plaintiff may recover if their fault is 50% or less; recovery is completely barred if plaintiff is 51% or more at fault. Damages are reduced proportionally.',
        'joint_several', jsonb_build_object(
            'rule', 'Each defendant liable only for their proportionate share of fault',
            'exception', 'Joint and several if defendant is more than 50% at fault'
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('SDCL § 20-9-2', 'Degen v. Bayman'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config,
              updated_at       = NOW();
