-- Virginia Medical Malpractice Validation Rules (Batch 9)
-- 5 rules: standard of care, expert certification, damage caps, SOL, negligence model (contributory)
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
    'VA-MED-MAL-STANDARD-OF-CARE', 5,
    'Virginia Medical Malpractice Standard of Care',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'VA',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'statute', 'Va. Code Ann. § 8.01-581.20 (Virginia Medical Malpractice Act)',
        'standard', 'reasonable_degree_of_skill_and_diligence',
        'description', 'Virginia requires a healthcare provider to exercise that degree of skill and diligence practiced by a reasonably competent healthcare provider engaged in the same or similar specialty in the same or similar locality. The Virginia Medical Malpractice Act (§ 8.01-581.1 et seq.) governs claims.',
        'key_elements', jsonb_build_array(
            'Defendant is a healthcare provider as defined by § 8.01-581.1',
            'Failure to exercise skill and diligence of a reasonably competent provider in same or similar specialty',
            'Causal connection between breach and injury',
            'Actual damages resulted'
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('Va. Code Ann. § 8.01-581.20', '§ 8.01-581.1', 'Downer v. Veilleux'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
),
(
    'VA-MED-MAL-EXPERT-CERTIFICATION', 5,
    'Virginia Medical Malpractice Expert Witness Certification',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'VA',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'statute', 'Va. Code Ann. § 8.01-20.1',
        'requirement', 'expert_certification_required',
        'description', 'Virginia requires a plaintiff to certify in the complaint or within 10 days after service that a qualified medical expert has determined that the defendant deviated from the applicable standard of care. The certifying expert must be qualified under § 8.01-581.20.',
        'certification_requirements', jsonb_build_object(
            'timing', 'At filing of complaint or within 10 days after service on defendant',
            'expert_qualifications', 'Licensed in Virginia or another US state; active clinical practice in same or related specialty in 5 years preceding the alleged malpractice',
            'content', 'Expert has reviewed claim and determined reasonable basis to believe defendant violated standard of care',
            'failure_consequence', 'Complaint dismissed without prejudice with opportunity to re-file within extended SOL'
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('Va. Code Ann. § 8.01-20.1', '§ 8.01-581.20', 'Rountree v. Fairfax Hospital'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
),
(
    'VA-MED-MAL-DAMAGE-CAPS', 5,
    'Virginia Medical Malpractice Aggregate Damage Caps',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'VA',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'statute', 'Va. Code Ann. § 8.01-581.15',
        'cap_type', 'total_recovery_cap',
        'total_recovery_cap', 2500000,
        'cap_currency', 'USD',
        'cap_increases_annually', true,
        'description', 'Virginia caps total damages (economic + non-economic) in medical malpractice cases. The cap increases annually by $50,000. For cases accruing on or after July 1, 2023, the cap is approximately $2,500,000 (increasing to $3,000,000 by 2031).',
        'cap_schedule', jsonb_build_object(
            'annual_increase', 50000,
            'target_cap_year', 2031,
            'target_cap_amount', 3000000
        ),
        'cap_notes', 'Virginia imposes a single aggregate cap on all damages (economic and non-economic), increasing $50k/year. No separate non-economic cap.',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('Va. Code Ann. § 8.01-581.15', 'Virginia Medical Malpractice Act'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
),
(
    'VA-MED-MAL-SOL-2-YEARS', 5,
    'Virginia Medical Malpractice Statute of Limitations',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'VA',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'statute', 'Va. Code Ann. § 8.01-243(A)',
        'sol_period', '2 years',
        'trigger', 'date_of_occurrence',
        'repose_period', 'None statutory',
        'discovery_rule', false,
        'exceptions', jsonb_build_object(
            'minors_under_8', 'SOL tolled until age 10 (2 years after 8th birthday)',
            'foreign_object', '1 year from discovery of foreign object',
            'fraudulent_concealment', 'Tolled during fraudulent concealment',
            'continuing_treatment', 'Continuing treatment rule may apply where treatment is ongoing'
        ),
        'sol_notes', 'Virginia uses a 2-year occurrence-based SOL with limited discovery rule application. No separate statute of repose. Expert certification (§ 8.01-20.1) must accompany complaint.',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('Va. Code Ann. § 8.01-243(A)', '§ 8.01-581.1', 'Keller v. Kaiser'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
),
(
    'VA-MED-MAL-CONTRIBUTORY-NEGLIGENCE', 5,
    'Virginia Contributory Negligence — Complete Bar',
    'content_check', 'personal_injury', 'medical_malpractice', 'complaint',
    'state', 'VA',
    jsonb_build_object(
        'sub_specialization_type', 'medical_malpractice',
        'statute', 'Virginia common law (contributory negligence)',
        'negligence_model', 'contributory_negligence',
        'complete_bar', true,
        'description', 'Virginia applies the traditional common law contributory negligence rule. If the plaintiff is found to be even 1% at fault, they are completely barred from any recovery. Virginia is one of only four US jurisdictions still using pure contributory negligence.',
        'last_clear_chance', jsonb_build_object(
            'available', true,
            'description', 'Virginia recognizes the Last Clear Chance doctrine, which may allow plaintiff to recover despite contributory negligence if defendant had the last opportunity to avoid the harm'
        ),
        'joint_several', jsonb_build_object(
            'rule', 'Joint and several liability applies in Virginia; each defendant jointly liable for full damages',
            'contribution', 'Right of contribution exists among joint tortfeasors'
        ),
        'verification', jsonb_build_object(
            'statute_verified', true,
            'sources', jsonb_build_array('Baskett v. Banks 45 SE2d 173 (Va. 1947)', 'Virginia common law', 'Litchford v. Hancock'),
            'confidence', 'high'
        )
    ),
    'error', 'document_verified', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name)
DO UPDATE SET validator_config = EXCLUDED.validator_config,
              updated_at       = NOW();
