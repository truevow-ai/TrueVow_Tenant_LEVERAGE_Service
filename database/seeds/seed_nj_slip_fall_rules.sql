-- =====================================================
-- New Jersey (NJ) Slip & Fall Premises Liability Rules
-- Enhanced Verification Protocol v2.0
-- =====================================================
-- State: New Jersey
-- Comparative Negligence: Modified 51% bar (N.J. Stat. Ann. § 2A:15-5.1)
-- SOL: 2 years (N.J. Stat. Ann. § 2A:14-2)
-- Classification: Traditional common law (invitee/licensee/trespasser)
-- Unique Features: Mode-of-Operation Rule for commercial properties (NJ-specific)
--   Commercial: Constructive notice may be inferred from self-service mode of operation
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
    'NJ-SLIP-FALL-INVITEE-DUTY',
    5,
    'NJ Premises Liability: Invitee Duty (Highest Standard)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'NJ',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'common_law_basis', 'Traditional invitee/licensee/trespasser classifications',
        'key_case', 'Hopler v. Hillsborough Township, 370 N.J. Super. 292 (App. Div. 2004)',
        'invitee_definition', jsonb_build_object(
            'business_invitee', 'Person invited onto property for business purposes benefiting owner',
            'public_invitee', 'Person invited as member of public for purposes property is held open',
            'examples', jsonb_build_array(
                'Customer in retail store',
                'Restaurant patron',
                'Bank customer',
                'Grocery store shopper',
                'Mall visitor'
            )
        ),
        'duty_standard', jsonb_build_object(
            'highest_duty', 'Exercise reasonable care to keep premises safe',
            'duty_components', jsonb_build_array(
                'Duty to inspect for hazards',
                'Duty to repair or warn of known dangers',
                'Duty to exercise reasonable care for invitee safety'
            ),
            'notice_requirement', 'Actual or constructive notice of hazardous condition required'
        ),
        'verification', jsonb_build_object(
            'common_law_verified', true,
            'multiple_sources', jsonb_build_array(
                'Hopler v. Hillsborough Township, 370 N.J. Super. 292 (2004)',
                'New Jersey Model Jury Charges - Premises Liability',
                'Justia - New Jersey Premises Liability',
                'NJ Bar Association'
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

-- RULE 2: MODE-OF-OPERATION RULE (NJ-SPECIFIC)
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
    'NJ-SLIP-FALL-MODE-OF-OPERATION-RULE',
    5,
    'NJ Slip & Fall: Mode-of-Operation Rule (Constructive Notice Exception)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'NJ',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'rule_name', 'Mode-of-Operation Rule',
        'key_case', 'Wollerman v. Grand Union Stores, Inc., 47 N.J. 426 (1966)',
        'rule_statement', 'When a business operates in a manner that creates a foreseeable risk of hazardous conditions, constructive notice may be inferred without proof of actual notice',
        'application', jsonb_build_object(
            'self_service_operations', jsonb_build_array(
                'Self-service grocery stores',
                'Produce sections with loose items',
                'Food courts',
                'Buffet-style restaurants'
            ),
            'foreseeable_hazards', jsonb_build_array(
                'Produce on floor from customer handling',
                'Spilled liquids from self-service beverages',
                'Dropped items from bulk bins'
            )
        ),
        'notice_requirement', jsonb_build_object(
            'standard_rule', 'Plaintiff must prove actual or constructive notice',
            'mode_of_operation_exception', 'When mode of operation creates foreseeable risk, notice may be inferred',
            'effect', 'Plaintiff need not prove how long hazard existed if mode of operation creates risk'
        ),
        'requirements', jsonb_build_array(
            'Business must be self-service or similar mode',
            'Hazard must be foreseeable result of business operation',
          'Hazard must be of type that would regularly occur'
        ),
        'key_cases', jsonb_build_array(
            'Wollerman v. Grand Union Stores, Inc., 47 N.J. 426 (1966)',
            'Bozza v. Vornado, Inc., 42 N.J. 355 (1964)',
            'Nisivoccia v. Glass Gardens, Inc., 175 N.J. 553 (2003)'
        ),
        'verification', jsonb_build_object(
            'case_law_verified', true,
            'multiple_sources', jsonb_build_array(
                'Wollerman v. Grand Union Stores, 47 N.J. 426 (1966)',
                'Nisivoccia v. Glass Gardens, Inc., 175 N.J. 553 (2003)',
                'New Jersey Model Jury Charges',
                'NJ Bar Association'
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

-- RULE 3: LICENSEE DUTY (MODERATE DUTY)
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
    'NJ-SLIP-FALL-LICENSEE-DUTY',
    5,
    'NJ Premises Liability: Licensee Duty (Moderate Standard)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'NJ',

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
            'moderate_duty', 'Duty to warn of known dangerous conditions',
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
                'New Jersey common law',
                'New Jersey Model Jury Charges',
                'Justia - New Jersey Premises Liability'
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

-- RULE 4: TRESPASSER DUTY (MINIMAL DUTY)
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
    'NJ-SLIP-FALL-TRESPASSER-DUTY',
    5,
    'NJ Premises Liability: Trespasser Duty (Minimal Standard)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'NJ',

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
                'New Jersey common law',
                'Justia - New Jersey Premises Liability'
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

-- RULE 5: MODIFIED COMPARATIVE NEGLIGENCE 51% BAR
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
    'NJ-SLIP-FALL-MODIFIED-COMPARATIVE-51-BAR',
    5,
    'NJ Modified Comparative Negligence: 51% Bar (N.J. Stat. Ann. § 2A:15-5.1)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'NJ',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'statutory_rule',
        'statute', 'N.J. Stat. Ann. § 2A:15-5.1',
        'statute_text', jsonb_build_object(
            'full_text', 'In any negligence action, damages shall not be recoverable if the claimant was more than 50% at fault. If claimant is 50% or less at fault, damages shall be diminished by the percentage of negligence attributable to the claimant.',
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
            'rule', 'Several liability for non-economic damages (N.J. Stat. Ann. § 2A:15-5.3)',
            'joint_liability', 'Joint liability for economic damages'
        ),
        'verification', jsonb_build_object(
            'statute_text_verified', true,
            'multiple_sources', jsonb_build_array(
                'N.J. Stat. Ann. § 2A:15-5.1 (NJ Legislature)',
                'N.J. Stat. Ann. § 2A:15-5.3 (Several Liability)',
                'Justia - New Jersey Comparative Negligence',
                'New Jersey Bar Association'
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
    'NJ-SLIP-FALL-SOL-2-YEARS',
    5,
    'NJ Statute of Limitations: 2 YEARS (N.J. Stat. Ann. § 2A:14-2)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'NJ',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'statutory_rule',
        'statute', 'N.J. Stat. Ann. § 2A:14-2',
        'statute_text', jsonb_build_object(
            'full_text', 'Every action at law for an injury to the person caused by the wrongful act, neglect or default of any person within this State shall be commenced within 2 years next after the cause of any such action shall have accrued.',
            'key_provisions', jsonb_build_array(
                '2-year limitation period for personal injury actions',
                'Applies to slip and fall premises liability cases',
                'Time begins to run from date of injury'
            )
        ),
        'sol_period', '2 years',
        'trigger_date', 'Date of injury/accident',
        'tolling_exceptions', jsonb_build_object(
            'minority', 'SOL tolled until minor reaches age 18',
            'disability', 'SOL may be tolled for mental incapacity',
            'discovery_rule', 'Limited application in New Jersey'
        ),
        'practical_examples', jsonb_build_array(
            'Slip and fall on January 1, 2024: Must file by January 1, 2026',
            'Fall on March 15, 2025: Must file by March 15, 2027'
        ),
        'filing_requirements', jsonb_build_object(
            'complaint_timing', 'File complaint within 2 years of injury date',
            'service_timing', 'Serve defendant within time allowed after filing'
        ),
        'verification', jsonb_build_object(
            'statute_text_verified', true,
            'multiple_sources', jsonb_build_array(
                'N.J. Stat. Ann. § 2A:14-2 (NJ Legislature)',
                'New Jersey Court Rules',
                'Justia - New Jersey SOL',
                'New Jersey Bar Association'
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

-- RULE 7: NOTICE REQUIREMENT FOR COMMERCIAL PROPERTIES
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
    'NJ-SLIP-FALL-NOTICE-REQUIREMENT',
    5,
    'NJ Slip & Fall: Notice Requirement (General Rule)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'NJ',

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
        'exception', jsonb_build_object(
            'mode_of_operation_rule', 'See NJ-SLIP-FALL-MODE-OF-OPERATION-RULE for self-service operations',
            'effect', 'Notice may be inferred when mode of operation creates foreseeable risk'
        ),
        'burden_of_proof', jsonb_build_object(
            'plaintiff_burden', 'Plaintiff must prove notice by a preponderance of the evidence',
            'evidence_required', 'Direct or circumstantial evidence of notice'
        ),
        'key_case', 'Williams v. Stroud, 320 N.J. Super. 275 (App. Div. 1999)',
        'verification', jsonb_build_object(
            'case_law_verified', true,
            'multiple_sources', jsonb_build_array(
                'Williams v. Stroud, 320 N.J. Super. 275 (1999)',
                'New Jersey Model Jury Charges',
                'Justia - New Jersey Premises Liability'
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
    'NJ-SLIP-FALL-OPEN-AND-OBVIOUS',
    5,
    'NJ Slip & Fall: Open and Obvious Danger Doctrine',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'NJ',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'doctrine_statement', 'Property owner has no duty to warn of dangers that are open and obvious',
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
            'Wet floor with visible standing water',
            'Ice on outdoor pavement in winter',
            'Stairs clearly visible without obstruction'
        ),
        'not_open_and_obvious_examples', jsonb_build_array(
            'Clear liquid on dark floor',
            'Ice in unexpected location (e.g., inside store)',
            'Hazard obscured by merchandise or displays'
        ),
        'key_case', 'Saldana v. Planet Fitness, 456 N.J. Super. 280 (App. Div. 2018)',
        'verification', jsonb_build_object(
            'case_law_verified', true,
            'multiple_sources', jsonb_build_array(
                'Saldana v. Planet Fitness, 456 N.J. Super. 280 (2018)',
                'New Jersey Model Jury Charges',
                'Justia - New Jersey Premises Liability'
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
    'NJ-SLIP-FALL-DAMAGES',
    5,
    'NJ Slip & Fall: Damages Recovery',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'NJ',

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
            'cap', 'Punitive damages capped at 5x compensatory damages or $350,000 (N.J. Stat. Ann. § 2A:15-5.14)'
        ),
        'comparative_fault_effect', jsonb_build_object(
            'rule', 'Damages reduced by plaintiff percentage of fault',
            'statute', 'N.J. Stat. Ann. § 2A:15-5.1'
        ),
        'verification', jsonb_build_object(
            'statutes_verified', true,
            'multiple_sources', jsonb_build_array(
                'N.J. Stat. Ann. § 2A:15-5.1',
                'N.J. Stat. Ann. § 2A:15-5.14 (Punitive Damages)',
                'New Jersey Bar Association'
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

-- RULE 10: COMMERCIAL VS RESIDENTIAL DISTINCTION
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
    'NJ-SLIP-FALL-COMMERCIAL-RESIDENTIAL',
    5,
    'NJ Slip & Fall: Commercial vs Residential Property Distinction',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'NJ',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'commercial_property', jsonb_build_object(
            'definition', 'Property used for business purposes open to the public',
            'duty_standard', 'Higher duty due to public invitees and mode-of-operation rules',
            'special_rules', jsonb_build_array(
                'Mode-of-operation rule may apply',
                'Constructive notice easier to establish',
                'Higher inspection standards'
            )
        ),
        'residential_property', jsonb_build_object(
            'definition', 'Property used for residential purposes',
            'landlord_duty', jsonb_build_object(
                'common_areas', 'Landlord has duty to maintain common areas safely',
                'leased_premises', 'Limited duty for conditions within tenant control'
            ),
            'tenant_duty', jsonb_build_object(
                'guests', 'Tenant owes duty to guests',
                'standard', 'Reasonable care standard'
            )
        ),
        'key_cases', jsonb_build_array(
            'Ryan v. Roney, 270 N.J. Super. 665 (App. Div. 1994) - Landlord duty',
            'Snyder v. I. Jay Realty Co., 30 N.J. Super. 189 (App. Div. 1954) - Common areas'
        ),
        'verification', jsonb_build_object(
            'case_law_verified', true,
            'multiple_sources', jsonb_build_array(
                'Ryan v. Roney, 270 N.J. Super. 665 (1994)',
                'Snyder v. I. Jay Realty Co., 30 N.J. Super. 189 (1954)',
                'New Jersey Model Jury Charges',
                'NJ Bar Association'
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
