-- =====================================================
-- Wisconsin (WI) Slip & Fall Premises Liability Rules
-- Enhanced Verification Protocol v2.0
-- =====================================================
-- State: Wisconsin
-- Comparative Negligence: Modified 51% bar (Wis. Stat. § 895.045)
-- SOL: 3 years (Wis. Stat. § 893.54)
-- Classification: Traditional common law (invitee/licensee/trespasser)
-- Unique Features: Safe Place Statute (higher duty for employers/owners)
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
    'WI-SLIP-FALL-INVITEE-DUTY',
    5,
    'WI Premises Liability: Invitee Duty (Highest Standard)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'WI',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'common_law_basis', 'Traditional invitee duty under Wisconsin common law',
        'key_case', 'Antoniewicz v. Reszcynski, 70 Wis.2d 836 (1975)',
        'invitee_definition', jsonb_build_object(
            'business_invitee', 'Person invited onto property for business purposes benefiting owner',
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
            'notice_requirement', 'Actual or constructive notice of hazardous condition required'
        ),
        'verification', jsonb_build_object(
            'common_law_verified', true,
            'multiple_sources', jsonb_build_array(
                'Antoniewicz v. Reszcynski, 70 Wis.2d 836 (1975)',
                'Wisconsin Jury Instructions - Premises Liability',
                'Justia - Wisconsin Premises Liability',
                'Wisconsin Bar Association'
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

-- RULE 2: SAFE PLACE STATUTE (WI-SPECIFIC)
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
    'WI-SLIP-FALL-SAFE-PLACE-STATUTE',
    5,
    'WI Slip & Fall: Safe Place Statute (Wis. Stat. § 101.11)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'WI',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'statutory_rule',
        'statute', 'Wis. Stat. § 101.11',
        'statute_name', 'Safe Place Statute',
        'statute_text', jsonb_build_object(
            'full_text', 'Every employer and every owner of a place of employment or a public building now or hereafter constructed shall so construct, repair or maintain such place... as to render the same safe.',
            'key_provisions', jsonb_build_array(
                'Employers and owners must construct, repair, and maintain safe premises',
                'Higher standard than ordinary negligence',
                'Applies to places of employment and public buildings',
                'Strict liability for structural defects'
            )
        ),
        'scope', jsonb_build_object(
            'places_of_employment', 'Any place where work is performed',
            'public_buildings', jsonb_build_array(
                'Retail stores',
                'Restaurants',
                'Hotels',
                'Banks',
                'Office buildings',
                'Entertainment venues'
            )
        ),
        'two_categories', jsonb_build_object(
            'structural_defects', jsonb_build_object(
                'standard', 'Strict liability - no notice required',
                'examples', jsonb_build_array(
                    'Stairs not to code',
                    'Improper flooring',
                    'Building code violations'
                )
            ),
            'unsafe_conditions', jsonb_build_object(
                'standard', 'Notice required - similar to common law',
                'examples', jsonb_build_array(
                    'Spills',
                    'Debris',
                    'Temporary hazards'
                )
            )
        ),
        'enhanced_protection', 'Safe Place Statute provides HIGHER protection than common law',
        'verification', jsonb_build_object(
            'statute_text_verified', true,
            'multiple_sources', jsonb_build_array(
                'Wis. Stat. § 101.11 (Wisconsin Legislature)',
                'Kreuser v. Walker, 201 Wis.2d 299 (1996)',
                'Wisconsin Bar Association'
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

-- RULE 3: MODIFIED COMPARATIVE NEGLIGENCE 51% BAR
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
    'WI-SLIP-FALL-MODIFIED-COMPARATIVE-51-BAR',
    5,
    'WI Modified Comparative Negligence: 51% Bar (Wis. Stat. § 895.045)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'WI',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'statutory_rule',
        'statute', 'Wis. Stat. § 895.045',
        'statute_text', jsonb_build_object(
            'full_text', 'Contributory negligence is not a bar to recovery... if such negligence was not greater than the negligence of the person against whom recovery is sought, but any damages allowed shall be diminished in proportion to the amount of negligence attributable to the person recovering.',
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
        'verification', jsonb_build_object(
            'statute_text_verified', true,
            'multiple_sources', jsonb_build_array(
                'Wis. Stat. § 895.045 (Wisconsin Legislature)',
                'Justia - Wisconsin Comparative Negligence',
                'Wisconsin Bar Association'
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

-- RULE 4: STATUTE OF LIMITATIONS - 3 YEARS
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
    'WI-SLIP-FALL-SOL-3-YEARS',
    5,
    'WI Statute of Limitations: 3 YEARS (Wis. Stat. § 893.54)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'WI',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'statutory_rule',
        'statute', 'Wis. Stat. § 893.54',
        'statute_text', jsonb_build_object(
            'full_text', 'The following actions shall be commenced within 3 years: (1) An action to recover damages for injuries to the person.',
            'key_provisions', jsonb_build_array(
                '3-year limitation period for personal injury actions',
                'Applies to slip and fall premises liability cases',
                'Time begins to run from date of injury'
            )
        ),
        'sol_period', '3 years',
        'trigger_date', 'Date of injury/accident',
        'tolling_exceptions', jsonb_build_object(
            'minority', 'SOL tolled until minor reaches age 18 (Wis. Stat. § 893.16)',
            'discovery_rule', 'Limited application in Wisconsin'
        ),
        'practical_examples', jsonb_build_array(
            'Slip and fall on January 1, 2024: Must file by January 1, 2027',
            'Fall on March 15, 2025: Must file by March 15, 2028'
        ),
        'filing_requirements', jsonb_build_object(
            'complaint_timing', 'File complaint within 3 years of injury date',
            'service_timing', 'Serve within 90 days of filing (Wis. Stat. § 801.10)'
        ),
        'verification', jsonb_build_object(
            'statute_text_verified', true,
            'multiple_sources', jsonb_build_array(
                'Wis. Stat. § 893.54 (Wisconsin Legislature)',
                'Wis. Stat. § 893.16 (Tolling)',
                'Wisconsin Court Rules',
                'Justia - Wisconsin SOL'
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

-- RULE 5: LICENSEE DUTY
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
    'WI-SLIP-FALL-LICENSEE-DUTY',
    5,
    'WI Premises Liability: Licensee Duty (Moderate Standard)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'WI',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'common_law_basis', 'Traditional licensee classification',
        'licensee_definition', jsonb_build_object(
            'definition', 'Person who enters property with permission but for their own purposes',
            'examples', jsonb_build_array('Social guest', 'Friend visiting home', 'Neighbor')
        ),
        'duty_standard', jsonb_build_object(
            'moderate_duty', 'Duty to warn of known dangerous conditions not obvious to licensee',
            'duty_components', jsonb_build_array(
                'Duty to warn of known dangers',
                'No duty to inspect',
                'No duty to repair'
            )
        ),
        'verification', jsonb_build_object('common_law_verified', true, 'confidence', 'high')
    ),
    'error',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 6: TRESPASSER DUTY
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
    'WI-SLIP-FALL-TRESPASSER-DUTY',
    5,
    'WI Premises Liability: Trespasser Duty (Minimal Standard)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'WI',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'trespasser_definition', jsonb_build_object(
            'definition', 'Person who enters property without permission',
            'examples', jsonb_build_array('Person entering posted property', 'Person ignoring signs')
        ),
        'duty_standard', jsonb_build_object(
            'minimal_duty', 'Duty to refrain from willful or wanton injury',
            'duty_components', jsonb_build_array('No duty to warn', 'No duty to inspect', 'No duty to repair')
        ),
        'verification', jsonb_build_object('common_law_verified', true, 'confidence', 'high')
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
    'WI-SLIP-FALL-NOTICE-REQUIREMENT',
    5,
    'WI Slip & Fall: Notice Requirement',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'WI',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'legal_requirement', 'Plaintiff must prove actual or constructive notice',
        'notice_types', jsonb_build_object(
            'actual_notice', jsonb_build_object('definition', 'Owner had direct knowledge', 'evidence', jsonb_build_array('Prior complaints', 'Incident reports', 'Employee created hazard')),
            'constructive_notice', jsonb_build_object('definition', 'Hazard existed long enough to discover', 'evidence', jsonb_build_array('Worn appearance', 'Track marks', 'Dried residue'))
        ),
        'safe_place_exception', 'Structural defects under Safe Place Statute do NOT require notice',
        'key_case', 'Weber v. American Family Mut. Ins. Co., 2002 WI App 263',
        'verification', jsonb_build_object('case_law_verified', true, 'confidence', 'high')
    ),
    'warning',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 8: DAMAGES
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
    'WI-SLIP-FALL-DAMAGES',
    5,
    'WI Slip & Fall: Damages Recovery',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'WI',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'compensatory_damages', jsonb_build_object(
            'economic_damages', jsonb_build_array('Medical expenses', 'Lost wages', 'Future treatment'),
            'non_economic_damages', jsonb_build_array('Pain and suffering', 'Emotional distress', 'Loss of enjoyment'),
            'cap', 'No statutory cap on personal injury damages'
        ),
        'punitive_damages', jsonb_build_object('availability', 'Available for intentional or reckless conduct', 'cap', 'None'),
        'comparative_fault_effect', jsonb_build_object('rule', 'Damages reduced by plaintiff percentage of fault'),
        'verification', jsonb_build_object('statutes_verified', true, 'confidence', 'high')
    ),
    'info',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- RULE 9: OPEN AND OBVIOUS DOCTRINE
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
    'WI-SLIP-FALL-OPEN-AND-OBVIOUS',
    5,
    'WI Slip & Fall: Open and Obvious Danger Doctrine',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'WI',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'doctrine_statement', 'Open and obvious dangers do not eliminate duty but affect comparative negligence',
        'wisconsin_approach', jsonb_build_object(
            'general_rule', 'Does not eliminate duty',
            'effect', 'May increase plaintiff comparative fault percentage',
            'safe_place_interaction', 'Safe Place Statute may impose duty regardless of open/obvious nature'
        ),
        'key_case', 'Moyer v. Northland Congregational Church, 2012 WI App 84',
        'verification', jsonb_build_object('case_law_verified', true, 'confidence', 'high')
    ),
    'warning',
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
    'WI-SLIP-FALL-DOCUMENTATION-CHECKLIST',
    5,
    'WI Slip & Fall: Documentation and Evidence Checklist',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'WI',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'practice_guide',
        'safe_place_advantage', 'Check if Safe Place Statute applies - higher standard of care',
        'evidence_checklist', jsonb_build_object(
            'scene_evidence', jsonb_build_array('Photographs', 'Video', 'Incident report', 'Witness statements'),
            'safe_place_evidence', jsonb_build_array('Building code violations', 'Structural defects', 'Code inspection reports', 'Prior code violations'),
            'notice_evidence', jsonb_build_array('Prior complaints', 'Prior incidents', 'Inspection logs', 'Maintenance records'),
            'medical_evidence', jsonb_build_array('Medical records', 'ER records', 'Follow-up treatment', 'Expert opinions')
        ),
        'verification', jsonb_build_object('practice_guide_verified', true, 'confidence', 'high')
    ),
    'info',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();
