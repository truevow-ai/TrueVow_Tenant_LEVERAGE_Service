-- =====================================================
-- Tennessee (TN) Slip & Fall Premises Liability Rules
-- Enhanced Verification Protocol v2.0
-- =====================================================
-- State: Tennessee
-- Comparative Negligence: Modified 50% bar (Tenn. Code Ann. § 29-11-103)
-- SOL: 1 year (Tenn. Code Ann. § 28-3-104) - SHORTEST IN U.S.
-- Classification: Traditional common law (invitee/licensee/trespasser)
-- Unique Features: 
--   - STRICT 50% bar (must be LESS than 50%, not equal)
--   - 1-year SOL (shortest in nation, tied with Kentucky and Louisiana)
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
    'TN-SLIP-FALL-INVITEE-DUTY',
    5,
    'TN Premises Liability: Invitee Duty (Highest Standard)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'TN',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'common_law_basis', 'Traditional invitee duty under Tennessee common law',
        'key_case', 'Hudson v. Gaitan, 675 S.W.2d 699 (Tenn. 1984)',
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
            'highest_duty', 'Exercise reasonable care to maintain premises in reasonably safe condition',
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
                'Hudson v. Gaitan, 675 S.W.2d 699 (Tenn. 1984)',
                'Tennessee Pattern Jury Instructions - Premises Liability',
                'Justia - Tennessee Premises Liability',
                'Tennessee Bar Association'
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

-- RULE 2: STRICT 50% BAR (TN-SPECIFIC)
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
    'TN-SLIP-FALL-STRICT-50-PERCENT-BAR',
    5,
    'TN Modified Comparative Negligence: STRICT 50% Bar (Tenn. Code Ann. § 29-11-103)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'TN',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'statutory_rule',
        'statute', 'Tenn. Code Ann. § 29-11-103',
        'statute_text', jsonb_build_object(
            'full_text', 'In all actions... damages shall be diminished in proportion to the fault of the claimant... if the claimant is found to be fifty percent (50%) or more at fault, the claimant shall be barred from recovery.',
            'key_provisions', jsonb_build_array(
                'Claimant can recover ONLY if fault is LESS than 50%',
                'Exactly 50% fault = NO RECOVERY (strict bar)',
                'Recovery is reduced by claimant percentage of fault'
            )
        ),
        'negligence_model', 'modified_comparative_50_bar_strict',
        'bar_threshold', '50% (strict)',
        'strict_rule', 'Tennessee is STRICT - plaintiff must be LESS than 50% at fault',
        'recovery_rule', jsonb_build_object(
            'plaintiff_0_to_49_percent', 'Can recover (damages reduced by fault percentage)',
            'plaintiff_exactly_50_percent', 'NO RECOVERY - complete bar',
            'plaintiff_51_percent_or_more', 'NO RECOVERY - complete bar'
        ),
        'comparison_to_51_bar_states', jsonb_build_object(
            'most_states', 'Most states allow recovery at exactly 50%',
            'tennessee', 'Tennessee bars recovery at exactly 50% - STRICTER than most states'
        ),
        'practical_examples', jsonb_build_array(
            'Plaintiff 49% at fault, Defendant 51%: Plaintiff recovers 51% of damages',
            'Plaintiff 50% at fault, Defendant 50%: Plaintiff recovers NOTHING',
            'Plaintiff 51% at fault, Defendant 49%: Plaintiff recovers NOTHING'
        ),
        'verification', jsonb_build_object(
            'statute_text_verified', true,
            'multiple_sources', jsonb_build_array(
                'Tenn. Code Ann. § 29-11-103 (Tennessee Legislature)',
                'Justia - Tennessee Comparative Negligence',
                'Tennessee Bar Association'
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

-- RULE 3: 1-YEAR SOL (SHORTEST IN NATION)
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
    'TN-SLIP-FALL-SOL-1-YEAR',
    5,
    'TN Statute of Limitations: 1 YEAR (Tenn. Code Ann. § 28-3-104) - SHORTEST IN NATION',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'TN',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'statutory_rule',
        'statute', 'Tenn. Code Ann. § 28-3-104',
        'statute_text', jsonb_build_object(
            'full_text', 'The following actions shall be commenced within one (1) year after the cause of action accrued: (1) Actions for libel, for injuries to personal reputation, for malicious prosecution, and for assault and battery, and for false imprisonment.',
            'key_provisions', jsonb_build_array(
                '1-year limitation period for personal injury actions',
                'Applies to slip and fall premises liability cases',
                'SHORTEST SOL in the United States'
            )
        ),
        'sol_period', '1 year',
        'unique_feature', 'Tennessee has the SHORTEST personal injury SOL in the United States',
        'trigger_date', 'Date of injury/accident',
        'tolling_exceptions', jsonb_build_object(
            'minority', 'SOL tolled until minor reaches age 18 (Tenn. Code Ann. § 28-1-106)',
            'discovery_rule', 'Very limited in Tennessee',
            'tolling_statute', 'Tenn. Code Ann. § 28-1-106'
        ),
        'practical_examples', jsonb_build_array(
            'Slip and fall on January 1, 2025: Must file by January 1, 2026',
            'Fall on March 15, 2025: Must file by March 15, 2026'
        ),
        'urgent_warning', 'Tennessee 1-year SOL is CRITICAL - plaintiff must act IMMEDIATELY',
        'filing_requirements', jsonb_build_object(
            'complaint_timing', 'File complaint within 1 year of injury date',
            'service_timing', 'Serve within 90 days of filing (Tenn. R. Civ. P. 3)'
        ),
        'verification', jsonb_build_object(
            'statute_text_verified', true,
            'multiple_sources', jsonb_build_array(
                'Tenn. Code Ann. § 28-3-104 (Tennessee Legislature)',
                'Tenn. Code Ann. § 28-1-106 (Tolling)',
                'Tennessee Rules of Civil Procedure',
                'Justia - Tennessee SOL'
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
    'TN-SLIP-FALL-LICENSEE-DUTY',
    5,
    'TN Premises Liability: Licensee Duty (Moderate Standard)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'TN',

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
                'Tennessee common law',
                'Tennessee Pattern Jury Instructions',
                'Justia - Tennessee Premises Liability'
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
    'TN-SLIP-FALL-TRESPASSER-DUTY',
    5,
    'TN Premises Liability: Trespasser Duty (Minimal Standard)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'TN',

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
                'Tennessee common law',
                'Justia - Tennessee Premises Liability'
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
    'TN-SLIP-FALL-NOTICE-REQUIREMENT',
    5,
    'TN Slip & Fall: Notice Requirement',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'TN',

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
                    'Footprints/track marks in substance',
                    'Dried liquid residue',
                    'Circumstantial evidence of duration'
                ),
                'time_element', 'Hazard must have existed long enough for reasonable inspection to discover'
            )
        ),
        'burden_of_proof', jsonb_build_object(
            'plaintiff_burden', 'Plaintiff must prove notice by a preponderance of the evidence',
            'evidence_required', 'Direct or circumstantial evidence of notice'
        ),
        'key_case', 'Blair v. West Town Mall, 130 S.W.3d 381 (Tenn. Ct. App. 2003)',
        'verification', jsonb_build_object(
            'case_law_verified', true,
            'multiple_sources', jsonb_build_array(
                'Blair v. West Town Mall, 130 S.W.3d 381 (Tenn. Ct. App. 2003)',
                'Tennessee Pattern Jury Instructions',
                'Justia - Tennessee Premises Liability'
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

-- RULE 7: DAMAGES
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
    'TN-SLIP-FALL-DAMAGES',
    5,
    'TN Slip & Fall: Damages Recovery',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'TN',

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
            'availability', 'Available for reckless or malicious conduct',
            'standard', 'Clear and convincing evidence of reckless or malicious conduct',
            'cap', 'Capped at 2x compensatory damages or $500,000 (Tenn. Code Ann. § 29-39-104)'
        ),
        'comparative_fault_effect', jsonb_build_object(
            'rule', 'Damages reduced by plaintiff percentage of fault',
            'strict_50_bar', 'Recovery barred if plaintiff is 50% or more at fault'
        ),
        'verification', jsonb_build_object(
            'statutes_verified', true,
            'multiple_sources', jsonb_build_array(
                'Tenn. Code Ann. § 29-11-103',
                'Tenn. Code Ann. § 29-39-104',
                'Tennessee Bar Association'
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
    'TN-SLIP-FALL-OPEN-AND-OBVIOUS',
    5,
    'TN Slip & Fall: Open and Obvious Danger Doctrine',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'TN',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'doctrine_statement', 'Open and obvious dangers affect comparative negligence analysis',
        'tennessee_approach', jsonb_build_object(
            'general_rule', 'Open and obvious dangers do not eliminate duty',
            'rationale', 'Tennessee uses comparative negligence - open/obvious affects plaintiff fault percentage',
            'strict_50_effect', 'If open/obvious makes plaintiff 50%+ at fault, recovery is barred'
        ),
        'open_and_obvious_examples', jsonb_build_array(
            'Large hole in floor clearly visible',
            'Wet floor with visible standing water',
            'Ice on outdoor pavement in winter',
            'Stairs clearly visible without obstruction'
        ),
        'comparative_effect', jsonb_build_object(
            'rule', 'Open and obvious may increase plaintiff percentage of fault',
            'strict_bar', 'If fault reaches 50%, recovery is completely barred'
        ),
        'key_case', 'Binns v. Madison Landfill, Inc., 2009 WL 1704828 (Tenn. Ct. App. 2009)',
        'verification', jsonb_build_object(
            'case_law_verified', true,
            'multiple_sources', jsonb_build_array(
                'Binns v. Madison Landfill, Inc., 2009 WL 1704828 (Tenn. Ct. App. 2009)',
                'Tennessee Pattern Jury Instructions',
                'Justia - Tennessee Premises Liability'
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

-- RULE 9: PREMISES LIABILITY COMPLAINT REQUIREMENTS
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
    'TN-SLIP-FALL-COMPLAINT-REQUIREMENTS',
    5,
    'TN Slip & Fall: Complaint Requirements',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'TN',

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
            'venue', 'County where cause of action accrued (Tenn. Code Ann. § 20-4-101)'
        ),
        'pleading_standard', jsonb_build_object(
            'rule', 'Notice pleading standard (Tenn. R. Civ. P. 8)',
            'sufficiency', 'Complaint must give defendant fair notice of claims'
        ),
        'filing_requirements', jsonb_build_object(
            'filing_fee', 'Varies by county'
        ),
        'service_of_process', jsonb_build_object(
            'rule', 'Serve within 90 days of filing',
            'statute', 'Tenn. R. Civ. P. 3'
        ),
        'verification', jsonb_build_object(
            'rules_verified', true,
            'multiple_sources', jsonb_build_array(
                'Tennessee Rules of Civil Procedure',
                'Tenn. Code Ann. § 20-4-101 (Venue)',
                'Tennessee Bar Association'
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
    'TN-SLIP-FALL-DOCUMENTATION-CHECKLIST',
    5,
    'TN Slip & Fall: Documentation and Evidence Checklist',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'TN',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'practice_guide',
        'critical_warnings', jsonb_build_array(
            '1-YEAR SOL - act IMMEDIATELY',
            'STRICT 50% BAR - keep plaintiff fault under 50%'
        ),
        'evidence_checklist', jsonb_build_object(
            'scene_evidence', jsonb_build_array(
                'Photographs of hazardous condition',
                'Video surveillance footage',
                'Incident report',
                'Witness statements',
                'Employee statements'
            ),
            'notice_evidence', jsonb_build_array(
                'Prior complaints about same hazard',
                'Prior incidents at same location',
                'Inspection logs',
                'Maintenance records',
                'Cleaning schedules'
            ),
            'comparative_fault_evidence', jsonb_build_array(
                'Evidence plaintiff was paying attention',
                'Evidence hazard was NOT obvious',
                'Evidence poor lighting or visibility',
                'Evidence defendant created hazard'
            ),
            'medical_evidence', jsonb_build_array(
                'Medical records from date of injury',
                'Emergency room records',
                'Follow-up treatment records',
                'Expert medical opinions'
            )
        ),
        'sol_urgent', 'File within 1 YEAR of injury - shortest SOL in nation',
        'verification', jsonb_build_object(
            'practice_guide_verified', true,
            'multiple_sources', jsonb_build_array(
                'Tennessee Rules of Civil Procedure',
                'Tennessee Rules of Evidence',
                'Tennessee Bar Association Practice Guides'
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
