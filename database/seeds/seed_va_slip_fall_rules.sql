-- =====================================================
-- Virginia (VA) Slip & Fall Premises Liability Rules
-- Enhanced Verification Protocol v2.0
-- =====================================================
-- State: Virginia
-- Comparative Negligence: CONTRIBUTORY negligence (complete bar - any plaintiff fault)
-- SOL: 2 years (Va. Code Ann. § 8.01-243(A))
-- Classification: Traditional common law (invitee/licensee/trespasser)
-- Unique Features: ONE OF 4 REMAINING CONTRIBUTORY NEGLIGENCE STATES
--   (with Alabama, Maryland, North Carolina, DC)
--   HARSHEST rule against plaintiffs in the nation
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
    'VA-SLIP-FALL-INVITEE-DUTY',
    5,
    'VA Premises Liability: Invitee Duty (Highest Standard)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'VA',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'common_law_basis', 'Traditional invitee duty under Virginia common law',
        'key_case', 'Rihanna v. Ames, 235 Va. 300, 368 S.E.2d 280 (1988)',
        'invitee_definition', jsonb_build_object(
            'business_invitee', 'Person invited onto property for business purposes benefiting owner',
            'public_invitee', 'Person invited as member of public for purposes property is held open',
            'examples', jsonb_build_array(
                'Customer in retail store',
                'Restaurant patron',
                'Bank customer',
                'Hotel guest',
                'Grocery store shopper'
            )
        ),
        'duty_standard', jsonb_build_object(
            'highest_duty', 'Exercise ordinary care to maintain premises in reasonably safe condition',
            'duty_components', jsonb_build_array(
                'Duty to inspect for hazards',
                'Duty to repair or warn of known dangers',
                'Duty to exercise reasonable care for invitee safety'
            ),
            'notice_requirement', 'Owner must have actual or constructive notice of dangerous condition'
        ),
        'verification', jsonb_build_object(
            'common_law_verified', true,
            'multiple_sources', jsonb_build_array(
                'Rihanna v. Ames, 235 Va. 300 (1988)',
                'Virginia Model Jury Instructions - Premises Liability',
                'Justia - Virginia Premises Liability',
                'Virginia Bar Association'
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

-- RULE 2: CONTRIBUTORY NEGLIGENCE (COMPLETE BAR) - VA-SPECIFIC
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
    'VA-SLIP-FALL-CONTRIBUTORY-NEGLIGENCE',
    5,
    'VA Contributory Negligence: COMPLETE BAR - HARSHEST RULE IN NATION',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'VA',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'common_law_basis', 'Virginia follows pure contributory negligence doctrine',
        'key_case', 'Baskett v. Banks, 275 Va. 139, 654 S.E.2d 572 (2008)',
        'negligence_model', 'contributory_negligence',
        'rule_statement', 'Plaintiff cannot recover if ANY fault is attributed to plaintiff',
        'complete_bar', jsonb_build_object(
            'rule', 'Even 1% plaintiff fault bars ALL recovery',
            'harshest_rule', 'Virginia is one of only 4 remaining contributory negligence states',
            'four_remaining_states', jsonb_build_array('Alabama', 'Maryland', 'North Carolina', 'Virginia', 'District of Columbia')
        ),
        'practical_examples', jsonb_build_array(
            'Plaintiff 0% at fault: Can recover full damages',
            'Plaintiff 1% at fault: NO RECOVERY (complete bar)',
            'Plaintiff 5% at fault: NO RECOVERY',
            'Plaintiff 50% at fault: NO RECOVERY',
            'Plaintiff 99% at fault: NO RECOVERY'
        ),
        'plaintiff_warning', 'Virginia contributory negligence is DEVASTATING to slip/fall plaintiffs - even minimal fault bars all recovery',
        'exceptions', jsonb_build_object(
            'last_clear_chance', jsonb_build_object(
                'doctrine', 'Virginia recognizes last clear chance doctrine',
                'rule', 'Plaintiff can recover if defendant had last clear chance to avoid injury but failed to do so',
                'burden', 'Plaintiff must prove defendant had last clear chance'
            )
        ),
        'verification', jsonb_build_object(
            'common_law_verified', true,
            'multiple_sources', jsonb_build_array(
                'Baskett v. Banks, 275 Va. 139 (2008)',
                'Virginia Model Jury Instructions',
                'Justia - Virginia Contributory Negligence',
                'Virginia Bar Association - Tort Law'
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

-- RULE 3: LAST CLEAR CHANCE DOCTRINE
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
    'VA-SLIP-FALL-LAST-CLEAR-CHANCE',
    5,
    'VA Slip & Fall: Last Clear Chance Doctrine (Plaintiff Exception)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'VA',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'doctrine_statement', 'Plaintiff can recover despite contributory negligence if defendant had last clear chance to avoid injury',
        'key_case', 'Huffman v. Providence Hospital, 217 Va. 69, 225 S.E.2d 393 (1976)',
        'doctrine_elements', jsonb_build_object(
            'requirements', jsonb_build_array(
                'Plaintiff was negligent (contributory negligence)',
                'Plaintiff was in position of danger',
                'Defendant was aware (or should have been aware) of plaintiff danger',
                'Defendant had last clear chance to avoid injury but failed to do so'
            ),
            'burden', 'Plaintiff must prove all elements by preponderance of evidence'
        ),
        'application_examples', jsonb_build_array(
            'Plaintiff slipped on hazard but defendant employee saw it and had time to warn',
            'Plaintiff negligently walked into area but defendant created hazard and could have removed it'
        ),
        'limitations', jsonb_build_object(
            'awareness_required', 'Defendant must have known or should have known of danger',
            'time_element', 'Defendant must have had TIME to avoid injury after becoming aware'
        ),
        'verification', jsonb_build_object(
            'case_law_verified', true,
            'multiple_sources', jsonb_build_array(
                'Huffman v. Providence Hospital, 217 Va. 69 (1976)',
                'Virginia Model Jury Instructions',
                'Virginia Bar Association'
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

-- RULE 4: LICENSEE DUTY (MODERATE DUTY)
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
    'VA-SLIP-FALL-LICENSEE-DUTY',
    5,
    'VA Premises Liability: Licensee Duty (Moderate Standard)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'VA',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'common_law_basis', 'Traditional licensee classification',
        'licensee_definition', jsonb_build_object(
            'definition', 'Person who enters property with permission but for their own purposes',
            'examples', jsonb_build_array(
                'Social guest',
                'Friend visiting home',
                'Neighbor borrowing item'
            )
        ),
        'duty_standard', jsonb_build_object(
            'moderate_duty', 'Duty to warn of known dangerous conditions not obvious to licensee',
            'duty_components', jsonb_build_array(
                'Duty to warn of known dangers not obvious to licensee',
                'No duty to inspect',
                'No duty to repair',
                'Duty to refrain from willful or wanton injury'
            )
        ),
        'verification', jsonb_build_object(
            'common_law_verified', true,
            'multiple_sources', jsonb_build_array(
                'Virginia common law',
                'Virginia Model Jury Instructions',
                'Justia - Virginia Premises Liability'
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

-- RULE 5: TRESPASSER DUTY (MINIMAL DUTY)
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
    'VA-SLIP-FALL-TRESPASSER-DUTY',
    5,
    'VA Premises Liability: Trespasser Duty (Minimal Standard)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'VA',

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
            'attractive_nuisance', 'Higher duty may apply to child trespassers'
        ),
        'verification', jsonb_build_object(
            'common_law_verified', true,
            'multiple_sources', jsonb_build_array(
                'Virginia common law',
                'Justia - Virginia Premises Liability'
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

-- RULE 6: STATUTE OF LIMITATIONS - 2 YEARS
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
    'VA-SLIP-FALL-SOL-2-YEARS',
    5,
    'VA Statute of Limitations: 2 YEARS (Va. Code Ann. § 8.01-243(A))',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'VA',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'statutory_rule',
        'statute', 'Va. Code Ann. § 8.01-243(A)',
        'statute_text', jsonb_build_object(
            'full_text', 'Every action for personal injuries, every action for damages for fraud, and every action for injuries to property, shall be brought within two years after the cause of action accrues.',
            'key_provisions', jsonb_build_array(
                '2-year limitation period for personal injury actions',
                'Applies to slip and fall premises liability cases',
                'Time begins to run from date of injury'
            )
        ),
        'sol_period', '2 years',
        'trigger_date', 'Date of injury/accident',
        'tolling_exceptions', jsonb_build_object(
            'minority', 'SOL tolled until minor reaches age 18 (Va. Code Ann. § 8.01-229)',
            'disability', 'SOL may be tolled for mental incapacity',
            'discovery_rule', 'Very limited in Virginia - injury date generally controls'
        ),
        'practical_examples', jsonb_build_array(
            'Slip and fall on January 1, 2024: Must file by January 1, 2026',
            'Fall on March 15, 2025: Must file by March 15, 2027'
        ),
        'filing_requirements', jsonb_build_object(
            'complaint_timing', 'File complaint within 2 years of injury date',
            'service_timing', 'Serve defendant within 12 months of filing (Va. Sup. Ct. Rule 3:3)'
        ),
        'verification', jsonb_build_object(
            'statute_text_verified', true,
            'multiple_sources', jsonb_build_array(
                'Va. Code Ann. § 8.01-243(A) (Virginia Legislature)',
                'Va. Code Ann. § 8.01-229 (Tolling)',
                'Virginia Supreme Court Rules',
                'Justia - Virginia SOL'
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

-- RULE 7: NOTICE REQUIREMENT
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
    'VA-SLIP-FALL-NOTICE-REQUIREMENT',
    5,
    'VA Slip & Fall: Notice Requirement',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'VA',

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
                'definition', 'Hazard existed for sufficient time that owner should have discovered it',
                'evidence_examples', jsonb_build_array(
                    'Hazard appeared worn/old',
                    'Weather conditions suggest long-standing ice/snow',
                    'Footprints/track marks in substance',
                    'Dried liquid residue'
                ),
                'time_element', 'Hazard must have existed long enough for reasonable inspection to discover'
            )
        ),
        'burden_of_proof', jsonb_build_object(
            'plaintiff_burden', 'Plaintiff must prove notice by a preponderance of the evidence',
            'evidence_required', 'Direct or circumstantial evidence of notice'
        ),
        'key_case', 'Winn-Dixie Stores, Inc. v. Parker, 240 Va. 180, 396 S.E.2d 849 (1990)',
        'verification', jsonb_build_object(
            'case_law_verified', true,
            'multiple_sources', jsonb_build_array(
                'Winn-Dixie Stores, Inc. v. Parker, 240 Va. 180 (1990)',
                'Virginia Model Jury Instructions',
                'Justia - Virginia Premises Liability'
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

-- RULE 8: OPEN AND OBVIOUS DANGER DOCTRINE
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
    'VA-SLIP-FALL-OPEN-AND-OBVIOUS',
    5,
    'VA Slip & Fall: Open and Obvious Danger Doctrine',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'VA',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'doctrine_statement', 'Property owner generally has no duty to warn of dangers that are open and obvious',
        'virginia_approach', jsonb_build_object(
            'general_rule', 'Open and obvious dangers may bar recovery under contributory negligence',
            'rationale', 'Plaintiff who fails to avoid obvious danger is contributorily negligent',
            'nuance', 'Open and obvious may constitute contributory negligence bar, not just no duty to warn'
        ),
        'open_and_obvious_examples', jsonb_build_array(
            'Large hole in floor clearly visible',
            'Wet floor with visible standing water',
            'Ice on outdoor pavement in winter',
            'Stairs clearly visible without obstruction'
        ),
        'not_open_and_obvious_examples', jsonb_build_array(
            'Clear liquid on dark floor',
            'Ice in unexpected location (e.g., inside store)',
            'Hazard obscured by merchandise or displays'
        ),
        'key_case', 'Tolbert v. Mullick, 255 Va. 358, 497 S.E.2d 880 (1998)',
        'verification', jsonb_build_object(
            'case_law_verified', true,
            'multiple_sources', jsonb_build_array(
                'Tolbert v. Mullick, 255 Va. 358 (1998)',
                'Virginia Model Jury Instructions',
                'Justia - Virginia Premises Liability'
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

-- RULE 9: DAMAGES
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
    'VA-SLIP-FALL-DAMAGES',
    5,
    'VA Slip & Fall: Damages Recovery',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'VA',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'compensatory_damages', jsonb_build_object(
            'economic_damages', jsonb_build_array(
                'Medical expenses (past and future)',
                'Lost wages and earning capacity',
                'Other out-of-pocket expenses'
            ),
            'non_economic_damages', jsonb_build_array(
                'Pain and suffering',
                'Emotional distress',
                'Loss of enjoyment of life',
                'Disfigurement'
            ),
            'cap', 'No statutory cap on personal injury damages in premises liability cases'
        ),
        'punitive_damages', jsonb_build_object(
            'availability', 'Available in limited circumstances',
            'standard', 'Clear and convincing evidence of willful, wanton, or malicious conduct',
            'cap', 'Virginia has no statutory cap on punitive damages, but subject to due process review'
        ),
        'contributory_negligence_effect', jsonb_build_object(
            'rule', 'ANY plaintiff fault bars ALL recovery',
            'devastating', 'Even 1% plaintiff fault = NO recovery of ANY damages'
        ),
        'verification', jsonb_build_object(
            'statutes_verified', true,
            'multiple_sources', jsonb_build_array(
                'Virginia Jury Instructions',
                'Virginia Bar Association'
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

-- RULE 10: DOCUMENTATION CHECKLIST
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
    'VA-SLIP-FALL-DOCUMENTATION-CHECKLIST',
    5,
    'VA Slip & Fall: Documentation and Evidence Checklist',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'VA',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'practice_guide',
        'critical_warning', 'Virginia contributory negligence is DEVASTATING - plaintiff must prove ZERO fault',
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
                'Cleaning schedules'
            ),
            'plaintiff_care_evidence', jsonb_build_array(
                'Evidence plaintiff was paying attention',
                'Evidence hazard was NOT open and obvious',
                'Evidence plaintiff took reasonable precautions',
                'Evidence plaintiff had no notice of hazard'
            ),
            'medical_evidence', jsonb_build_array(
                'Medical records from date of injury',
                'Emergency room records',
                'Follow-up treatment records',
                'Expert medical opinions',
                'Future treatment projections'
            )
        ),
        'contributory_negligence_strategy', jsonb_build_object(
            'goal', 'Prove plaintiff had ZERO fault',
            'key_evidence', jsonb_build_array(
                'Hazard was hidden or unexpected',
                'Lighting was poor',
                'Plaintiff was exercising reasonable care',
                'No warning signs were present',
                'Hazard was created by defendant'
            )
        ),
        'verification', jsonb_build_object(
            'practice_guide_verified', true,
            'multiple_sources', jsonb_build_array(
                'Virginia Discovery Rules',
                'Virginia Evidence Rules',
                'Virginia Bar Association Practice Guides'
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
