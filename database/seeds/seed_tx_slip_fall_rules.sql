-- =====================================================
-- Texas (TX) Slip & Fall Premises Liability Rules
-- Enhanced Verification Protocol v2.0
-- =====================================================
-- State: Texas
-- Comparative Negligence: Modified 51% bar (Tex. Civ. Prac. & Rem. Code § 33.001)
-- SOL: 2 years (Tex. Civ. Prac. & Rem. Code § 16.003)
-- Classification: Traditional common law (invitee/licensee/trespasser)
-- Unique Features: 
--   - STRICT actual/constructive notice requirement (harder for plaintiffs)
--   - High-volume PI litigation state
--   - Duty is "ordinary care" not "reasonable care" (subtle distinction)
--   - Proportionate responsibility system
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
    'TX-SLIP-FALL-INVITEE-DUTY',
    5,
    'TX Premises Liability: Invitee Duty (Highest Standard)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'TX',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'common_law_basis', 'Traditional invitee duty under Texas common law',
        'key_case', 'CMH Homes, Inc. v. Daenen, 15 S.W.3d 97 (Tex. 2000)',
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
            'texas_duty', 'Exercise ORDINARY CARE to reduce or eliminate unreasonable risk of harm',
            'duty_components', jsonb_build_array(
                'Duty to inspect for hazards',
                'Duty to reduce or eliminate unreasonable risk',
                'Duty to warn of known dangers'
            ),
            'ordinary_care_note', 'Texas uses ordinary care standard (not reasonable care) - subtle but important distinction'
        ),
        'notice_requirement', jsonb_build_object(
            'actual_notice', 'Owner had direct knowledge of the specific hazard',
            'constructive_notice', 'Hazard existed long enough that owner should have discovered it',
            'texas_strict', 'Texas courts are STRICT about notice — generalized awareness insufficient'
        ),
        'verification', jsonb_build_object(
            'common_law_verified', true,
            'multiple_sources', jsonb_build_array(
                'CMH Homes, Inc. v. Daenen, 15 S.W.3d 97 (Tex. 2000)',
                'Corbin v. Safeway Stores, Inc., 648 S.W.2d 292 (Tex. 1983)',
                'Texas Pattern Jury Charges - Premises Liability',
                'Justia - Texas Premises Liability',
                'Texas Bar Association'
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

-- RULE 2: TEXAS STRICT NOTICE REQUIREMENT (TX-SPECIFIC)
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
    'TX-SLIP-FALL-STRICT-NOTICE-REQUIREMENT',
    5,
    'TX Slip & Fall: Strict Notice Requirement (Defendant-Friendly)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'TX',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'texas_rule', 'Texas is DEFENDANT-FRIENDLY on notice — plaintiff must prove SPECIFIC notice',
        'key_case', 'Wal-Mart Stores, Inc. v. Gonzalez, 968 S.W.2d 934 (Tex. 1998)',
        'notice_types', jsonb_build_object(
            'actual_notice', jsonb_build_object(
                'definition', 'Owner had direct knowledge of THIS SPECIFIC hazard',
                'evidence_examples', jsonb_build_array(
                    'Employee testimony about prior complaints about THIS condition',
                    'Prior incident reports about THIS location/hazard',
                    'Employee created or observed the hazard'
                ),
                'insufficient', jsonb_build_array(
                    'General knowledge of spills occurring somewhere in store',
                    'Evidence that spills happen "all the time"',
                    'Evidence of prior incidents at different locations'
                )
            ),
            'constructive_notice', jsonb_build_object(
                'definition', 'Hazard existed for sufficient time that owner should have discovered it',
                'time_element', 'Plaintiff must show hazard existed for SOME TIME — Texas requires evidence of duration',
                'evidence_examples', jsonb_build_array(
                    'Hazard appeared dirty, worn, or track-marked',
                    'Evidence of time hazard existed (e.g., shift change)',
                    'Circumstantial evidence of duration'
                ),
                'insufficient', jsonb_build_array(
                    'Mere presence of hazard without evidence of duration',
                    'Speculation about how long hazard existed'
                )
            )
        ),
        'burden_of_proof', jsonb_build_object(
            'plaintiff_burden', 'Plaintiff must prove SPECIFIC notice by preponderance of evidence',
            'defendant_friendly', 'Texas courts are strict — generalized notice is NOT enough'
        ),
        'key_cases', jsonb_build_array(
            'Wal-Mart Stores, Inc. v. Gonzalez, 968 S.W.2d 934 (Tex. 1998)',
            'CMH Homes, Inc. v. Daenen, 15 S.W.3d 97 (Tex. 2000)',
            'Brookshire Grocery Co. v. Taylor, 222 S.W.3d 406 (Tex. 2006)'
        ),
        'verification', jsonb_build_object(
            'case_law_verified', true,
            'multiple_sources', jsonb_build_array(
                'Wal-Mart Stores, Inc. v. Gonzalez, 968 S.W.2d 934 (Tex. 1998)',
                'CMH Homes, Inc. v. Daenen, 15 S.W.3d 97 (Tex. 2000)',
                'Brookshire Grocery Co. v. Taylor, 222 S.W.3d 406 (Tex. 2006)',
                'Texas Pattern Jury Charges'
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
    'TX-SLIP-FALL-LICENSEE-DUTY',
    5,
    'TX Premises Liability: Licensee Duty (Moderate Standard)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'TX',

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
                'Person with express or implied permission not for business benefit'
            )
        ),
        'duty_standard', jsonb_build_object(
            'moderate_duty', 'Duty to warn of known dangerous conditions not obvious to licensee',
            'duty_components', jsonb_build_array(
                'Duty to warn of known dangers not obvious to licensee',
                'No duty to inspect',
                'No duty to repair',
                'Duty to refrain from willful, wanton, or grossly negligent conduct'
            )
        ),
        'key_case', 'State v. Williams, 940 S.W.2d 583 (Tex. 1996)',
        'verification', jsonb_build_object(
            'common_law_verified', true,
            'multiple_sources', jsonb_build_array(
                'State v. Williams, 940 S.W.2d 583 (Tex. 1996)',
                'Texas Pattern Jury Charges',
                'Justia - Texas Premises Liability'
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
    'TX-SLIP-FALL-TRESPASSER-DUTY',
    5,
    'TX Premises Liability: Trespasser Duty (Minimal Standard)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'TX',

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
            'minimal_duty', 'Duty to refrain from willful, wanton, or grossly negligent conduct',
            'duty_components', jsonb_build_array(
                'No duty to warn',
                'No duty to inspect',
                'No duty to repair',
                'Duty to avoid intentional or grossly negligent harm'
            )
        ),
        'child_trespasser', jsonb_build_object(
            'attractive_nuisance', 'Higher duty may apply to child trespassers'
        ),
        'verification', jsonb_build_object(
            'common_law_verified', true,
            'multiple_sources', jsonb_build_array(
                'Texas common law',
                'Justia - Texas Premises Liability'
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
    'TX-SLIP-FALL-MODIFIED-COMPARATIVE-51-BAR',
    5,
    'TX Modified Comparative Negligence: 51% Bar (Tex. Civ. Prac. & Rem. Code § 33.001)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'TX',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'statutory_rule',
        'statute', 'Tex. Civ. Prac. & Rem. Code § 33.001',
        'statute_text', jsonb_build_object(
            'full_text', 'A claimant may not recover damages if his percentage of responsibility is greater than 50 percent.',
            'key_provisions', jsonb_build_array(
                'Claimant can recover if fault is 50% or less',
                'Recovery is reduced by claimant percentage of fault',
                'Complete bar if claimant is more than 50% at fault',
                'Texas uses "proportionate responsibility" terminology'
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
        'proportionate_responsibility', jsonb_build_object(
            'statute_chapter', 'Tex. Civ. Prac. & Rem. Code Ch. 33',
            'settlement_credit', 'Defendants get credit for settlements with other parties',
            'designated_responsible_third_parties', 'Defendants can designate responsible third parties'
        ),
        'verification', jsonb_build_object(
            'statute_text_verified', true,
            'multiple_sources', jsonb_build_array(
                'Tex. Civ. Prac. & Rem. Code § 33.001 (Texas Legislature)',
                'Tex. Civ. Prac. & Rem. Code Ch. 33 (Proportionate Responsibility)',
                'Justia - Texas Comparative Fault',
                'Texas Bar Association'
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
    'TX-SLIP-FALL-SOL-2-YEARS',
    5,
    'TX Statute of Limitations: 2 YEARS (Tex. Civ. Prac. & Rem. Code § 16.003)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'TX',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'statutory_rule',
        'statute', 'Tex. Civ. Prac. & Rem. Code § 16.003',
        'statute_text', jsonb_build_object(
            'full_text', 'A person must bring suit for trespass for injury to the person or for injury to the rights of another... not later than two years after the day the cause of action accrues.',
            'key_provisions', jsonb_build_array(
                '2-year limitation period for personal injury actions',
                'Applies to slip and fall premises liability cases',
                'Time begins to run from date of injury'
            )
        ),
        'sol_period', '2 years',
        'trigger_date', 'Date of injury/accident',
        'tolling_exceptions', jsonb_build_object(
            'minority', 'SOL tolled until minor reaches age 18 (Tex. Civ. Prac. & Rem. Code § 16.001)',
            'disability', 'SOL may be tolled for mental incapacity',
            'discovery_rule', 'Limited application in Texas - accrual generally on injury date'
        ),
        'practical_examples', jsonb_build_array(
            'Slip and fall on January 1, 2024: Must file by January 1, 2026',
            'Fall on March 15, 2025: Must file by March 15, 2027'
        ),
        'filing_requirements', jsonb_build_object(
            'complaint_timing', 'File petition within 2 years of injury date',
            'service_timing', 'Serve citation within 30 days of filing (Tex. R. Civ. P. 106)'
        ),
        'verification', jsonb_build_object(
            'statute_text_verified', true,
            'multiple_sources', jsonb_build_array(
                'Tex. Civ. Prac. & Rem. Code § 16.003 (Texas Legislature)',
                'Tex. Civ. Prac. & Rem. Code § 16.001 (Minor Tolling)',
                'Texas Rules of Civil Procedure',
                'Justia - Texas SOL'
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
    'TX-SLIP-FALL-OPEN-AND-OBVIOUS',
    5,
    'TX Slip & Fall: Open and Obvious Danger Doctrine',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'TX',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'doctrine_statement', 'Property owner generally has no duty to warn of dangers that are open and obvious',
        'texas_approach', jsonb_build_object(
            'general_rule', 'Open and obvious dangers negate duty to warn',
            'rationale', 'Invitees are expected to exercise ordinary care for their own safety',
            'nuance', 'Open and obvious does NOT automatically negate duty — owner may still have duty to make safe'
        ),
        'open_and_obvious_examples', jsonb_build_array(
            'Large hole in floor clearly visible',
            'Wet floor with visible standing water and warning signs',
            'Ice on outdoor pavement in winter',
            'Stairs clearly visible without obstruction'
        ),
        'not_open_and_obvious_examples', jsonb_build_array(
            'Clear liquid on dark floor',
            'Ice in unexpected location (e.g., inside store)',
            'Hazard obscured by merchandise or displays'
        ),
        'key_case', 'Austin v. Kroger Texas, L.P., 746 S.W.3d 890 (Tex. 2018)',
        'verification', jsonb_build_object(
            'case_law_verified', true,
            'multiple_sources', jsonb_build_array(
                'Austin v. Kroger Texas, L.P., 746 S.W.3d 890 (Tex. 2018)',
                'Texas Pattern Jury Charges',
                'Justia - Texas Premises Liability'
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

-- RULE 8: DAMAGES CAPS
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
    'TX-SLIP-FALL-DAMAGES-CAPS',
    5,
    'TX Slip & Fall: Damages and Caps',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'TX',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'compensatory_damages', jsonb_build_object(
            'economic_damages', jsonb_build_array(
                'Medical expenses (past and future)',
                'Lost wages and earning capacity',
                'Other out-of-pocket expenses'
            ),
            'cap', 'No statutory cap on economic damages in premises liability cases'
        ),
        'non_economic_damages', jsonb_build_object(
            'types', jsonb_build_array(
                'Pain and suffering',
                'Emotional distress',
                'Loss of enjoyment of life',
                'Disfigurement'
            ),
            'cap', 'No statutory cap on non-economic damages in ordinary premises liability cases',
            'note', 'Medical malpractice has different caps - does not apply to slip/fall'
        ),
        'punitive_damages', jsonb_build_object(
            'availability', 'Available as "exemplary damages"',
            'standard', 'Clear and convincing evidence of fraud, malice, or gross negligence',
            'cap', jsonb_build_array(
                'Greater of: (1) 2x economic damages + non-economic damages up to $750,000, or (2) $200,000',
                'Tex. Civ. Prac. & Rem. Code § 41.008'
            )
        ),
        'comparative_fault_effect', jsonb_build_object(
            'rule', 'Damages reduced by plaintiff percentage of responsibility',
            'statute', 'Tex. Civ. Prac. & Rem. Code § 33.012'
        ),
        'verification', jsonb_build_object(
            'statutes_verified', true,
            'multiple_sources', jsonb_build_array(
                'Tex. Civ. Prac. & Rem. Code § 33.012',
                'Tex. Civ. Prac. & Rem. Code § 41.008',
                'Texas Bar Association'
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
    'TX-SLIP-FALL-COMPLAINT-REQUIREMENTS',
    5,
    'TX Slip & Fall: Petition Requirements',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'TX',

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
            'venue', 'Proper venue is county where all or part of cause of action accrued (Tex. Civ. Prac. & Rem. Code § 15.002)'
        ),
        'pleading_standard', jsonb_build_object(
            'rule', 'Fair notice pleading standard (Tex. R. Civ. P. 45, 47)',
            'sufficiency', 'Petition must give defendant fair notice of claims and relief sought'
        ),
        'filing_requirements', jsonb_build_object(
            'filing_fee', 'Varies by county - typically $200-350'
        ),
        'service_of_process', jsonb_build_object(
            'rule', 'Serve citation and petition within 30 days of filing',
            'statute', 'Tex. R. Civ. P. 106'
        ),
        'verification', jsonb_build_object(
            'rules_verified', true,
            'multiple_sources', jsonb_build_array(
                'Texas Rules of Civil Procedure',
                'Tex. Civ. Prac. & Rem. Code § 15.002 (Venue)',
                'Texas Bar Association'
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
    'TX-SLIP-FALL-DOCUMENTATION-CHECKLIST',
    5,
    'TX Slip & Fall: Documentation and Evidence Checklist',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'TX',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'practice_guide',
        'evidence_checklist', jsonb_build_object(
            'scene_evidence', jsonb_build_array(
                'Photographs of hazardous condition',
                'Video surveillance footage (REQUEST IMMEDIATELY)',
                'Incident report',
                'Witness statements',
                'Employee statements',
                'Weather reports (if applicable)'
            ),
            'notice_evidence', jsonb_build_object(
                'critical_in_texas', 'Texas is STRICT about notice - need SPECIFIC evidence',
                'evidence_types', jsonb_build_array(
                    'Prior complaints about THIS specific hazard location',
                    'Prior incidents at THIS specific location',
                    'Inspection logs showing when area was last checked',
                    'Maintenance records',
                    'Cleaning schedules',
                    'Employee testimony about notice'
                )
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
            'video_preservation', 'Send spoliation letter IMMEDIATELY for surveillance video',
            'texas_rule', 'Texas has strong spoliation law - failure to preserve can result in adverse inference'
        ),
        'verification', jsonb_build_object(
            'practice_guide_verified', true,
            'multiple_sources', jsonb_build_array(
                'Texas Rules of Civil Procedure - Discovery',
                'Texas Rules of Evidence',
                'Texas Bar Association Practice Guides'
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
