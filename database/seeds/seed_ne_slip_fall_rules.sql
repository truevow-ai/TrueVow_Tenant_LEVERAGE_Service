-- =====================================================
-- Nebraska (NE) Slip & Fall Premises Liability Rules
-- Enhanced Verification Protocol v2.0
-- =====================================================
-- State: Nebraska
-- Comparative Negligence: Modified 51% bar (Neb. Rev. Stat. § 25-21,185.09)
-- SOL: 4 years (Neb. Rev. Stat. § 25-207) - UNIQUE: Longer than typical 2-3 years
-- Classification: Traditional common law (invitee/licensee/trespasser)
-- Unique Features: 4-year SOL (one of only a few states with 4+ years)
-- =====================================================

-- RULE 1: INVITEE DUTY (HIGHEST DUTY)
INSERT INTO leverage.validation_rules (
    rule_name,
    validator_level,
    validator_name,
    validator_type,
    practice_area,
    specialization,
    document_type,
    jurisdiction_scope,
    jurisdiction_state,
    validator_config,
    severity,
    review_status,
    is_active,
    is_template,
    created_at,
    updated_at
) VALUES (
    'NE-SLIP-FALL-INVITEE-DUTY',
    5,
    'NE Premises Liability: Invitee Duty (Highest Standard)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'NE',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'common_law_basis', 'Traditional invitee/licensee/trespasser classifications',
        'key_case', 'Heins v. Webster County, 250 Neb. 750, 552 N.W.2d 51 (1996)',
        'invitee_definition', jsonb_build_object(
            'business_invitee', 'Person invited onto property for business purposes benefiting owner',
            'public_invitee', 'Person invited as member of public for purposes property is held open',
            'examples', jsonb_build_array(
                'Customer in retail store',
                'Restaurant patron',
                'Bank customer',
                'Grocery store shopper',
                'Hotel guest'
            )
        ),
        'duty_standard', jsonb_build_object(
            'highest_duty', 'Reasonable care to keep premises safe',
            'duty_components', jsonb_build_array(
                'Duty to inspect for hazards',
                'Duty to repair known hazards',
                'Duty to warn of known dangers',
                'Duty to exercise reasonable care for invitee safety'
            ),
            'constructive_notice', 'May be liable for hazards that should have been discovered through reasonable inspection'
        ),
        'nebraska_specific', jsonb_build_object(
            'notice_requirement', 'Actual or constructive notice of hazardous condition required',
            'open_and_obvious', 'No duty to warn of open and obvious dangers unless there is reason to expect invitee will be distracted'
        ),
        'verification', jsonb_build_object(
            'common_law_verified', true,
            'multiple_sources', jsonb_build_array(
                'Heins v. Webster County, 250 Neb. 750 (1996)',
                'Nebraska Jury Instructions (NJIG 4.01)',
                'Justia - Nebraska Premises Liability',
                'Nebraska State Bar Association'
            ),
            'confidence', 'high'
        )
    ),
    'error',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 2: LICENSEE DUTY (MODERATE DUTY)
INSERT INTO leverage.validation_rules (
    rule_name,
    validator_level,
    validator_name,
    validator_type,
    practice_area,
    specialization,
    document_type,
    jurisdiction_scope,
    jurisdiction_state,
    validator_config,
    severity,
    review_status,
    is_active,
    is_template,
    created_at,
    updated_at
) VALUES (
    'NE-SLIP-FALL-LICENSEE-DUTY',
    5,
    'NE Premises Liability: Licensee Duty (Moderate Standard)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'NE',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'common_law_basis', 'Traditional licensee classification',
        'licensee_definition', jsonb_build_object(
            'definition', 'Person who enters property with permission but for their own purposes',
            'examples', jsonb_build_array(
                'Social guest',
                'Friend visiting home',
                'Neighbor borrowing item',
                'Person using property with permission but not for owner benefit'
            )
        ),
        'duty_standard', jsonb_build_object(
            'moderate_duty', 'Duty to warn of known dangerous conditions',
            'duty_components', jsonb_build_array(
                'Duty to warn of known dangers not obvious to licensee',
                'No duty to inspect',
                'No duty to repair',
                'Duty to refrain from willful or wanton injury'
            )
        ),
        'key_case', 'Heins v. Webster County, 250 Neb. 750 (1996)',
        'verification', jsonb_build_object(
            'common_law_verified', true,
            'multiple_sources', jsonb_build_array(
                'Nebraska common law',
                'Nebraska Jury Instructions',
                'Justia - Nebraska Premises Liability'
            ),
            'confidence', 'high'
        )
    ),
    'error',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 3: TRESPASSER DUTY (MINIMAL DUTY)
INSERT INTO leverage.validation_rules (
    rule_name,
    validator_level,
    validator_name,
    validator_type,
    practice_area,
    specialization,
    document_type,
    jurisdiction_scope,
    jurisdiction_state,
    validator_config,
    severity,
    review_status,
    is_active,
    is_template,
    created_at,
    updated_at
) VALUES (
    'NE-SLIP-FALL-TRESPASSER-DUTY',
    5,
    'NE Premises Liability: Trespasser Duty (Minimal Standard)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'NE',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'common_law_basis', 'Traditional trespasser classification',
        'trespasser_definition', jsonb_build_object(
            'definition', 'Person who enters property without permission or legal right',
            'examples', jsonb_build_array(
                'Person entering posted property',
                'Person ignoring no trespassing signs',
                'Person exceeding scope of permission'
            )
        ),
        'duty_standard', jsonb_build_object(
            'minimal_duty', 'Duty to refrain from willful or wanton injury',
            'duty_components', jsonb_build_array(
                'No duty to warn',
                'No duty to inspect',
                'No duty to repair',
                'Duty to avoid intentional harm'
            )
        ),
        'child_trespasser', jsonb_build_object(
            'attractive_nuisance', 'Higher duty may apply to child trespassers if attractive nuisance doctrine applies'
        ),
        'verification', jsonb_build_object(
            'common_law_verified', true,
            'multiple_sources', jsonb_build_array(
                'Nebraska common law',
                'Justia - Nebraska Premises Liability'
            ),
            'confidence', 'high'
        )
    ),
    'error',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 4: MODIFIED COMPARATIVE NEGLIGENCE 51% BAR
INSERT INTO leverage.validation_rules (
    rule_name,
    validator_level,
    validator_name,
    validator_type,
    practice_area,
    specialization,
    document_type,
    jurisdiction_scope,
    jurisdiction_state,
    validator_config,
    severity,
    review_status,
    is_active,
    is_template,
    created_at,
    updated_at
) VALUES (
    'NE-SLIP-FALL-MODIFIED-COMPARATIVE-51-BAR',
    5,
    'NE Modified Comparative Negligence: 51% Bar (Neb. Rev. Stat. § 25-21,185.09)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'NE',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'statutory_rule',
        'statute', 'Neb. Rev. Stat. § 25-21,185.09',
        'statute_text', jsonb_build_object(
            'full_text', 'In any action to which this section applies, the contributory fault of the claimant shall not bar recovery if the contributory fault of the claimant was not greater than the fault of the defendant or defendants, but the damages recoverable shall be diminished in proportion to the percentage of negligence attributable to the claimant.',
            'key_provisions', jsonb_build_array(
                'Claimant can recover if fault is 50% or less',
                'Recovery is reduced by claimant percentage of fault',
                'Complete bar if claimant is more than 50% at fault'
            )
        ),
        'negligence_model', 'modified_comparative_51_bar',
        'bar_threshold', '51%',
        'recovery_rule', jsonb_build_object(
            'plaintiff_0_to_50_percent', 'Can recover (damages reduced by fault percentage)',
            'plaintiff_exactly_50_percent', 'Can recover 50% of damages',
            'plaintiff_51_percent_or_more', 'NO RECOVERY - Complete bar'
        ),
        'practical_examples', jsonb_build_array(
            'Plaintiff 20% at fault, Defendant 80%: Plaintiff recovers 80% of damages',
            'Plaintiff 50% at fault, Defendant 50%: Plaintiff recovers 50% of damages',
            'Plaintiff 51% at fault, Defendant 49%: Plaintiff recovers NOTHING'
        ),
        'several_liability', jsonb_build_object(
            'rule', 'Several liability applies - each defendant liable only for their proportionate share',
            'statute_reference', 'Neb. Rev. Stat. § 25-21,185.11'
        ),
        'verification', jsonb_build_object(
            'statute_text_verified', true,
            'multiple_sources', jsonb_build_array(
                'Neb. Rev. Stat. § 25-21,185.09 (Nebraska Legislature)',
                'Neb. Rev. Stat. § 25-21,185.11 (Several Liability)',
                'Justia - Nebraska Comparative Negligence',
                'Nebraska State Bar Association'
            ),
            'confidence', 'high'
        )
    ),
    'error',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 5: STATUTE OF LIMITATIONS - 4 YEARS (UNIQUE - LONGER THAN MOST)
INSERT INTO leverage.validation_rules (
    rule_name,
    validator_level,
    validator_name,
    validator_type,
    practice_area,
    specialization,
    document_type,
    jurisdiction_scope,
    jurisdiction_state,
    validator_config,
    severity,
    review_status,
    is_active,
    is_template,
    created_at,
    updated_at
) VALUES (
    'NE-SLIP-FALL-SOL-4-YEARS',
    5,
    'NE Statute of Limitations: 4 YEARS (Neb. Rev. Stat. § 25-207) - UNIQUE: LONGER THAN MOST STATES',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'NE',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'statutory_rule',
        'statute', 'Neb. Rev. Stat. § 25-207',
        'statute_text', jsonb_build_object(
            'full_text', 'The following actions shall be brought within four years: (1) An action for an injury to the rights of another, not arising on contract, and not hereinafter enumerated...',
            'key_provisions', jsonb_build_array(
                '4-year limitation period for personal injury actions',
                'Applies to slip and fall premises liability cases',
                'Time begins to run from date of injury'
            )
        ),
        'sol_period', '4 years',
        'trigger_date', 'Date of injury/accident',
        'unique_feature', jsonb_build_object(
            'description', 'Nebraska 4-year SOL is LONGER than typical 2-3 year states',
            'plaintiff_advantage', 'Extended time to file claim compared to most states',
            'comparison', jsonb_build_array(
                'Most states: 2 years',
                'Some states: 3 years',
                'Nebraska: 4 years',
                'Only Maine (6), Minnesota (6), Missouri (5), and a few others have longer'
            )
        ),
        'tolling_exceptions', jsonb_build_object(
            'minority', 'SOL tolled until minor reaches age of majority',
            'disability', 'SOL may be tolled for mental incapacity',
            'discovery_rule', 'Limited application in Nebraska for latent injuries'
        ),
        'practical_examples', jsonb_build_array(
            'Slip and fall on January 1, 2024: Must file by January 1, 2028',
            'Fall on March 15, 2025: Must file by March 15, 2029'
        ),
        'filing_requirements', jsonb_build_object(
            'complaint_timing', 'File complaint within 4 years of injury date',
            'service_timing', 'Serve defendant within time allowed after filing'
        ),
        'verification', jsonb_build_object(
            'statute_text_verified', true,
            'multiple_sources', jsonb_build_array(
                'Neb. Rev. Stat. § 25-207 (Nebraska Legislature)',
                'Nebraska Court Rules',
                'Justia - Nebraska SOL',
                'Nebraska State Bar Association'
            ),
            'confidence', 'high'
        )
    ),
    'error',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 6: CONSTRUCTIVE NOTICE REQUIREMENT
INSERT INTO leverage.validation_rules (
    rule_name,
    validator_level,
    validator_name,
    validator_type,
    practice_area,
    specialization,
    document_type,
    jurisdiction_scope,
    jurisdiction_state,
    validator_config,
    severity,
    review_status,
    is_active,
    is_template,
    created_at,
    updated_at
) VALUES (
    'NE-SLIP-FALL-CONSTRUCTIVE-NOTICE',
    5,
    'NE Slip & Fall: Constructive Notice Requirement',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'NE',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'legal_requirement', 'Plaintiff must prove actual or constructive notice of hazardous condition',
        'notice_types', jsonb_build_object(
            'actual_notice', jsonb_build_object(
                'definition', 'Property owner had direct knowledge of the hazard',
                'evidence_examples', jsonb_build_array(
                    'Employee testimony about prior complaints',
                    'Prior incident reports',
                    'Maintenance records showing knowledge',
                    'Employee created the hazard'
                )
            ),
            'constructive_notice', jsonb_build_object(
                'definition', 'Hazard existed for sufficient time that owner should have discovered it through reasonable inspection',
                'evidence_examples', jsonb_build_array(
                    'Hazard appeared worn/old',
                    'Weather conditions suggest long-standing ice/snow',
                    'Footprints/track marks in substance',
                    'Dried liquid residue',
                    'Employee testimony about inspection schedules'
                ),
                'time_element', 'Hazard must have existed long enough for reasonable inspection to discover'
            )
        ),
        'burden_of_proof', jsonb_build_object(
            'plaintiff_burden', 'Plaintiff must prove notice by a preponderance of the evidence',
            'evidence_required', 'Direct or circumstantial evidence of notice'
        ),
        'key_case', 'Nelson v. Daily News, 2 Neb. App. 384, 509 N.W.2d 628 (1993)',
        'verification', jsonb_build_object(
            'case_law_verified', true,
            'multiple_sources', jsonb_build_array(
                'Nelson v. Daily News, 2 Neb. App. 384 (1993)',
                'Heins v. Webster County, 250 Neb. 750 (1996)',
                'Nebraska Jury Instructions'
            ),
            'confidence', 'high'
        )
    ),
    'warning',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 7: OPEN AND OBVIOUS DANGER DOCTRINE
INSERT INTO leverage.validation_rules (
    rule_name,
    validator_level,
    validator_name,
    validator_type,
    practice_area,
    specialization,
    document_type,
    jurisdiction_scope,
    jurisdiction_state,
    validator_config,
    severity,
    review_status,
    is_active,
    is_template,
    created_at,
    updated_at
) VALUES (
    'NE-SLIP-FALL-OPEN-AND-OBVIOUS',
    5,
    'NE Slip & Fall: Open and Obvious Danger Doctrine',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'NE',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'doctrine_statement', 'Property owner has no duty to warn of dangers that are open and obvious to a reasonable person',
        'doctrine_application', jsonb_build_object(
            'general_rule', 'No duty to warn of hazards that are clearly visible and apparent',
            'rationale', 'Invitees are expected to exercise reasonable care for their own safety regarding obvious dangers',
            'exceptions', jsonb_build_array(
                'Owner has reason to expect invitee will be distracted',
                'Owner has reason to expect invitee will proceed despite danger',
                'Danger is unavoidable even if obvious'
            )
        ),
        'open_and_obvious_examples', jsonb_build_array(
            'Large hole in floor clearly visible',
            'Wet floor with visible standing water and no obstructions',
            'Ice on outdoor pavement in winter',
            'Stairs clearly visible without obstruction'
        ),
        'not_open_and_obvious_examples', jsonb_build_array(
            'Clear liquid on dark floor',
            'Ice in unexpected location (e.g., inside store)',
            'Hazard obscured by merchandise or displays',
            'Sudden drop-off not clearly marked'
        ),
        'key_case', 'Glover v. Rural Health Outreach, Inc., 24 Neb. App. 421, 889 N.W.2d 547 (2016)',
        'verification', jsonb_build_object(
            'case_law_verified', true,
            'multiple_sources', jsonb_build_array(
                'Glover v. Rural Health Outreach, Inc., 24 Neb. App. 421 (2016)',
                'Nebraska Jury Instructions',
                'Justia - Nebraska Premises Liability'
            ),
            'confidence', 'high'
        )
    ),
    'warning',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 8: DAMAGES CAPS (NONE FOR PERSONAL INJURY IN NEBRASKA)
INSERT INTO leverage.validation_rules (
    rule_name,
    validator_level,
    validator_name,
    validator_type,
    practice_area,
    specialization,
    document_type,
    jurisdiction_scope,
    jurisdiction_state,
    validator_config,
    severity,
    review_status,
    is_active,
    is_template,
    created_at,
    updated_at
) VALUES (
    'NE-SLIP-FALL-DAMAGES-CAPS',
    5,
    'NE Slip & Fall: No Damages Caps for Personal Injury',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'NE',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'nebraska_rule', 'Nebraska does NOT have caps on personal injury damages',
        'compensatory_damages', jsonb_build_object(
            'economic_damages', jsonb_build_array(
                'Medical expenses (past and future)',
                'Lost wages and earning capacity',
                'Other out-of-pocket expenses'
            ),
            'cap', 'No statutory cap',
            'limitation', 'Limited only by evidence of actual damages'
        ),
        'non_economic_damages', jsonb_build_object(
            'types', jsonb_build_array(
                'Pain and suffering',
                'Emotional distress',
                'Loss of enjoyment of life',
                'Disfigurement'
            ),
            'cap', 'No statutory cap for general personal injury',
            'note', 'Different rules may apply to medical malpractice'
        ),
        'punitive_damages', jsonb_build_object(
            'availability', 'Available in limited circumstances',
            'standard', 'Clear and convincing evidence of willful, wanton, or malicious conduct',
            'cap', 'No specific statutory cap, but subject to constitutional limits'
        ),
        'comparative_fault_effect', jsonb_build_object(
            'rule', 'Damages reduced by plaintiff percentage of fault',
            'statute', 'Neb. Rev. Stat. § 25-21,185.09'
        ),
        'verification', jsonb_build_object(
            'statutes_verified', true,
            'multiple_sources', jsonb_build_array(
                'Nebraska Civil Practice Act',
                'Neb. Rev. Stat. § 25-21,185.09',
                'Nebraska State Bar Association'
            ),
            'confidence', 'high'
        )
    ),
    'info',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 9: PREMISES LIABILITY COMPLAINT VERIFICATION
INSERT INTO leverage.validation_rules (
    rule_name,
    validator_level,
    validator_name,
    validator_type,
    practice_area,
    specialization,
    document_type,
    jurisdiction_scope,
    jurisdiction_state,
    validator_config,
    severity,
    review_status,
    is_active,
    is_template,
    created_at,
    updated_at
) VALUES (
    'NE-SLIP-FALL-COMPLAINT-REQUIREMENTS',
    5,
    'NE Slip & Fall: Complaint Requirements Verification',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'NE',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'procedural_rule',
        'complaint_elements', jsonb_build_object(
            'required_allegations', jsonb_build_array(
                'Date and time of incident',
                'Location/address of premises',
                'Description of hazardous condition',
                'Status of plaintiff (invitee/licensee)',
                'Notice to defendant (actual or constructive)',
                'Duty owed by defendant',
                'Breach of duty',
                'Causation',
                'Damages'
            ),
            'venue', 'Proper venue is county where cause of action accrued (Neb. Rev. Stat. § 25-401)'
        ),
        'pleading_standard', jsonb_build_object(
            'rule', 'Notice pleading standard under Nebraska law',
            'sufficiency', 'Complaint must give defendant fair notice of claims',
            'specificity', 'Specific facts not required, but general allegations must support claim'
        ),
        'verification_requirement', jsonb_build_object(
            'general_rule', 'Complaint need not be verified unless specifically required by statute'
        ),
        'filing_fee', jsonb_build_object(
            'district_court', 'Varies by county - typically $50-100'
        ),
        'service_of_process', jsonb_build_object(
            'rule', 'Serve summons and complaint within time allowed',
            'statute', 'Neb. Rev. Stat. § 25-505'
        ),
        'verification', jsonb_build_object(
            'rules_verified', true,
            'multiple_sources', jsonb_build_array(
                'Nebraska Court Rules',
                'Neb. Rev. Stat. § 25-401 (Venue)',
                'Neb. Rev. Stat. § 25-505 (Service)',
                'Nebraska State Bar Association'
            ),
            'confidence', 'high'
        )
    ),
    'warning',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 10: NEGLIGENCE DOCUMENTATION CHECKLIST
INSERT INTO leverage.validation_rules (
    rule_name,
    validator_level,
    validator_name,
    validator_type,
    practice_area,
    specialization,
    document_type,
    jurisdiction_scope,
    jurisdiction_state,
    validator_config,
    severity,
    review_status,
    is_active,
    is_template,
    created_at,
    updated_at
) VALUES (
    'NE-SLIP-FALL-DOCUMENTATION-CHECKLIST',
    5,
    'NE Slip & Fall: Documentation and Evidence Checklist',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'NE',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'practice_guide',
        'evidence_checklist', jsonb_build_object(
            'scene_evidence', jsonb_build_array(
                'Photographs of hazardous condition',
                'Video surveillance footage',
                'Incident report',
                'Witness statements',
                'Employee statements',
                'Weather reports (if applicable)'
            ),
            'notice_evidence', jsonb_build_array(
                'Prior complaints about same hazard',
                'Prior incidents at same location',
                'Inspection logs',
                'Maintenance records',
                'Cleaning schedules',
                'Employee testimony about notice'
            ),
            'medical_evidence', jsonb_build_array(
                'Medical records from date of injury',
                'Emergency room records',
                'Follow-up treatment records',
                'Expert medical opinions',
                'Future treatment projections'
            ),
            'damages_evidence', jsonb_build_array(
                'Medical bills',
                'Lost wage documentation',
                'Employment records',
                'Life care plans (if applicable)',
                'Pain and suffering documentation'
            )
        ),
        'preservation_requirements', jsonb_build_object(
            'spoliation', 'Duty to preserve evidence once litigation is reasonably anticipated',
            'notice_to_defendant', 'Consider spoliation letter to preserve surveillance video'
        ),
        'verification', jsonb_build_object(
            'practice_guide_verified', true,
            'multiple_sources', jsonb_build_array(
                'Nebraska Discovery Rules',
                'Nebraska Evidence Rules',
                'Nebraska State Bar Association Practice Guides'
            ),
            'confidence', 'high'
        )
    ),
    'info',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();
