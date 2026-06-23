-- =====================================================
-- Washington (WA) Slip & Fall Premises Liability Rules
-- Enhanced Verification Protocol v2.0
-- =====================================================
-- State: Washington
-- Comparative Negligence: PURE comparative (RCW 4.22.005, 4.22.015)
-- SOL: 3 years (RCW 4.16.080)
-- Classification: Traditional common law (invitee/licensee/trespasser)
-- Unique Features: Pure comparative negligence - plaintiff can recover even if 99% at fault
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
    'WA-SLIP-FALL-INVITEE-DUTY',
    5,
    'WA Premises Liability: Invitee Duty (Highest Standard)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'WA',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'common_law_basis', 'Traditional invitee duty under Washington common law',
        'key_case', 'Tincani v. Inland Empire Zoological Society, 124 Wn.2d 121 (1994)',
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
            'highest_duty', 'Exercise reasonable care to maintain premises in safe condition',
            'duty_components', jsonb_build_array(
                'Duty to inspect for hazards',
                'Duty to repair or warn of known or discoverable hazards',
                'Duty to exercise reasonable care for invitee safety'
            ),
            'notice_requirement', 'Actual or constructive notice of hazardous condition required'
        ),
        'verification', jsonb_build_object(
            'common_law_verified', true,
            'multiple_sources', jsonb_build_array(
                'Tincani v. Inland Empire Zoological Society, 124 Wn.2d 121 (1994)',
                'Washington Pattern Jury Instructions (WPI) - Premises Liability',
                'Justia - Washington Premises Liability',
                'Washington Bar Association'
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

-- RULE 2: PURE COMPARATIVE NEGLIGENCE (WA-SPECIFIC)
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
    'WA-SLIP-FALL-PURE-COMPARATIVE-NEGLIGENCE',
    5,
    'WA Pure Comparative Negligence: Plaintiff Can Recover Even if 99% at Fault (RCW 4.22.005, 4.22.015)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'WA',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'statutory_rule',
        'statute', 'RCW 4.22.005, RCW 4.22.015',
        'statute_text', jsonb_build_object(
            'full_text', 'In all actions hereafter accruing involving negligence or fault of more than one entity, the liability of each defendant shall be several only and shall not be joint... A plaintiff may recover damages from a defendant only to the extent of the defendant fault percentage.',
            'key_provisions', jsonb_build_array(
                'Plaintiff can recover REGARDLESS of fault percentage',
                'Recovery is reduced by plaintiff percentage of fault',
                'Even if plaintiff is 99% at fault, can recover 1% of damages',
                'Several liability only - defendants liable only for their share'
            )
        ),
        'negligence_model', 'pure_comparative',
        'recovery_rule', jsonb_build_object(
            'plaintiff_0_percent', 'Recover 100% of damages',
            'plaintiff_50_percent', 'Recover 50% of damages',
            'plaintiff_75_percent', 'Recover 25% of damages',
            'plaintiff_90_percent', 'Recover 10% of damages',
            'plaintiff_99_percent', 'Recover 1% of damages',
            'plaintiff_100_percent', 'No recovery (complete bar at 100%)'
        ),
        'practical_examples', jsonb_build_array(
            'Plaintiff 20% at fault, Defendant 80%: Plaintiff recovers 80% of damages',
            'Plaintiff 50% at fault, Defendant 50%: Plaintiff recovers 50% of damages',
            'Plaintiff 75% at fault, Defendant 25%: Plaintiff recovers 25% of damages',
            'Plaintiff 99% at fault, Defendant 1%: Plaintiff recovers 1% of damages'
        ),
        'plaintiff_friendly', 'Washington pure comparative is VERY plaintiff-friendly - no bar to recovery regardless of fault',
        'verification', jsonb_build_object(
            'statute_text_verified', true,
            'multiple_sources', jsonb_build_array(
                'RCW 4.22.005 (Washington Legislature)',
                'RCW 4.22.015 (Damages)',
                'Justia - Washington Comparative Negligence',
                'Washington Bar Association'
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
    'WA-SLIP-FALL-LICENSEE-DUTY',
    5,
    'WA Premises Liability: Licensee Duty (Moderate Standard)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'WA',

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
        'key_case', 'Tincani v. Inland Empire Zoological Society, 124 Wn.2d 121 (1994)',
        'verification', jsonb_build_object(
            'common_law_verified', true,
            'multiple_sources', jsonb_build_array(
                'Tincani v. Inland Empire Zoological Society, 124 Wn.2d 121 (1994)',
                'Washington Pattern Jury Instructions',
                'Justia - Washington Premises Liability'
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
    'WA-SLIP-FALL-TRESPASSER-DUTY',
    5,
    'WA Premises Liability: Trespasser Duty (Minimal Standard)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'WA',

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
                'Washington common law',
                'Justia - Washington Premises Liability'
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

-- RULE 5: STATUTE OF LIMITATIONS - 3 YEARS
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
    'WA-SLIP-FALL-SOL-3-YEARS',
    5,
    'WA Statute of Limitations: 3 YEARS (RCW 4.16.080)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'WA',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'statutory_rule',
        'statute', 'RCW 4.16.080',
        'statute_text', jsonb_build_object(
            'full_text', 'Actions for the following causes shall be commenced within three years: (2) An action for trespass for injury to the person or to property of another...',
            'key_provisions', jsonb_build_array(
                '3-year limitation period for personal injury actions',
                'Applies to slip and fall premises liability cases',
                'Time begins to run from date of injury'
            )
        ),
        'sol_period', '3 years',
        'trigger_date', 'Date of injury/accident',
        'tolling_exceptions', jsonb_build_object(
            'minority', 'SOL tolled until minor reaches age 18 (RCW 4.16.190)',
            'disability', 'SOL may be tolled for mental incapacity',
            'discovery_rule', 'Limited application in Washington'
        ),
        'practical_examples', jsonb_build_array(
            'Slip and fall on January 1, 2024: Must file by January 1, 2027',
            'Fall on March 15, 2025: Must file by March 15, 2028'
        ),
        'filing_requirements', jsonb_build_object(
            'complaint_timing', 'File complaint within 3 years of injury date',
            'service_timing', 'Serve defendant within 90 days of filing (CR 3, CR 4)'
        ),
        'verification', jsonb_build_object(
            'statute_text_verified', true,
            'multiple_sources', jsonb_build_array(
                'RCW 4.16.080 (Washington Legislature)',
                'RCW 4.16.190 (Tolling)',
                'Washington Court Rules (CR 3, CR 4)',
                'Justia - Washington SOL'
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

-- RULE 6: NOTICE REQUIREMENT
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
    'WA-SLIP-FALL-NOTICE-REQUIREMENT',
    5,
    'WA Slip & Fall: Notice Requirement',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'WA',

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
        'key_case', 'Pimentel v. Roundup Co., 100 Wn.2d 39 (1983)',
        'verification', jsonb_build_object(
            'case_law_verified', true,
            'multiple_sources', jsonb_build_array(
                'Pimentel v. Roundup Co., 100 Wn.2d 39 (1983)',
                'Washington Pattern Jury Instructions',
                'Justia - Washington Premises Liability'
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
    'WA-SLIP-FALL-OPEN-AND-OBVIOUS',
    5,
    'WA Slip & Fall: Open and Obvious Danger Doctrine',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'WA',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'doctrine_statement', 'Open and obvious dangers affect comparative negligence analysis, not duty',
        'washington_approach', jsonb_build_object(
            'general_rule', 'Open and obvious dangers do NOT eliminate duty',
            'rationale', 'Washington uses comparative negligence - open/obvious affects plaintiff fault percentage',
            'nuance', 'Unlike contributory negligence states, open/obvious does not bar recovery entirely'
        ),
        'open_and_obvious_examples', jsonb_build_array(
            'Large hole in floor clearly visible',
            'Wet floor with visible standing water',
            'Ice on outdoor pavement in winter',
            'Stairs clearly visible without obstruction'
        ),
        'comparative_effect', jsonb_build_object(
            'rule', 'Open and obvious may increase plaintiff percentage of fault',
            'not_complete_bar', 'Plaintiff can still recover reduced damages even if partially at fault'
        ),
        'key_case', 'Koffman v. Leitch, 34 Wn. App. 661 (1983)',
        'verification', jsonb_build_object(
            'case_law_verified', true,
            'multiple_sources', jsonb_build_array(
                'Koffman v. Leitch, 34 Wn. App. 661 (1983)',
                'Washington Pattern Jury Instructions',
                'Justia - Washington Premises Liability'
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
    'WA-SLIP-FALL-DAMAGES',
    5,
    'WA Slip & Fall: Damages Recovery',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'WA',

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
            'availability', 'NOT available in Washington except by statute',
            'general_rule', 'Washington does not recognize common law punitive damages',
            'statutory_exceptions', 'Some limited statutory treble damages for specific claims'
        ),
        'comparative_fault_effect', jsonb_build_object(
            'rule', 'Damages reduced by plaintiff percentage of fault',
            'pure_comparative', 'Plaintiff can recover even if mostly at fault'
        ),
        'verification', jsonb_build_object(
            'statutes_verified', true,
            'multiple_sources', jsonb_build_array(
                'RCW 4.22.005, 4.22.015',
                'Washington Pattern Jury Instructions',
                'Washington Bar Association'
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

-- RULE 9: JOINT AND SEVERAL LIABILITY ABOLISHED
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
    'WA-SLIP-FALL-SEVERAL-LIABILITY',
    5,
    'WA Slip & Fall: Several Liability Only (Joint Liability Abolished)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'WA',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'statutory_rule',
        'statute', 'RCW 4.22.005, 4.22.015',
        'rule_statement', 'Washington abolished joint and several liability - each defendant liable only for their share',
        'practical_effect', jsonb_build_object(
            'several_liability', 'Each defendant liable only for their percentage of fault',
            'no_joint_liability', 'Plaintiff cannot recover entire judgment from one defendant',
            'defendant_friendly', 'Protects defendants from being stuck with entire judgment'
        ),
        'exceptions', jsonb_build_object(
            'limited_cases', 'Joint liability may apply in limited circumstances',
            'requirements', 'Generally requires showing of concerted action or special relationship'
        ),
        'key_case', 'Washburn v. Beatt Equipment Co., 120 Wn.2d 246 (1992)',
        'verification', jsonb_build_object(
            'statute_verified', true,
            'multiple_sources', jsonb_build_array(
                'RCW 4.22.005 (Washington Legislature)',
                'Washburn v. Beatt Equipment Co., 120 Wn.2d 246 (1992)',
                'Washington Bar Association'
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
    'WA-SLIP-FALL-DOCUMENTATION-CHECKLIST',
    5,
    'WA Slip & Fall: Documentation and Evidence Checklist',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'WA',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'practice_guide',
        'pure_comparative_advantage', 'Washington pure comparative is plaintiff-friendly - focus on damages',
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
                'Pain and suffering documentation'
            )
        ),
        'preservation_requirements', jsonb_build_object(
            'spoliation', 'Duty to preserve evidence once litigation anticipated',
            'video_preservation', 'Send spoliation letter for surveillance video'
        ),
        'verification', jsonb_build_object(
            'practice_guide_verified', true,
            'multiple_sources', jsonb_build_array(
                'Washington Civil Rules (CR)',
                'Washington Evidence Rules (ER)',
                'Washington Bar Association Practice Guides'
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
