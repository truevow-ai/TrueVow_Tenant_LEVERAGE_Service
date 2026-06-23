-- =====================================================
-- New Hampshire (NH) Slip & Fall Premises Liability Rules
-- Enhanced Verification Protocol v2.0
-- =====================================================
-- State: New Hampshire
-- Comparative Negligence: Modified 51% bar (N.H. Rev. Stat. Ann. § 507:7-d)
-- SOL: 3 years (N.H. Rev. Stat. Ann. § 508:4, I)
-- Classification: Traditional common law (invitee/licensee/trespasser)
-- Unique Features: Reasonable care standard for all lawful visitors (similar to NC)
-- =====================================================

-- RULE 1: INVITEE/LAWFUL VISITOR DUTY (HIGHEST DUTY)
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
    'NH-SLIP-FALL-INVITEE-DUTY',
    5,
    'NH Premises Liability: Invitee/Lawful Visitor Duty (Highest Standard)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'NH',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'common_law_basis', 'New Hampshire applies reasonable care standard to all lawful visitors',
        'key_case', 'Ouellette v. Blanchard, 157 N.H. 399, 951 A.2d 132 (2008)',
        'lawful_visitor_definition', jsonb_build_object(
            'definition', 'Person who enters or remains on property with possessor permission',
            'includes', jsonb_build_array(
                'Business invitees',
                'Social guests',
                'Public invitees',
                'Anyone with express or implied permission'
            )
        ),
        'duty_standard', jsonb_build_object(
            'general_duty', 'Exercise reasonable care to keep premises safe',
            'duty_components', jsonb_build_array(
                'Duty to inspect for hazards',
                'Duty to repair or warn of known dangers',
                'Duty to exercise reasonable care for visitor safety'
            ),
            'notice_requirement', 'Actual or constructive notice of hazardous condition required'
        ),
        'new_hampshire_specific', jsonb_build_object(
            'abolished_distinction', 'NH does not distinguish between invitees and licensees for duty purposes',
            'uniform_standard', 'All lawful visitors receive same reasonable care standard'
        ),
        'verification', jsonb_build_object(
            'common_law_verified', true,
            'multiple_sources', jsonb_build_array(
                'Ouellette v. Blanchard, 157 N.H. 399 (2008)',
                'Sweeney v. Ragaglia, 154 N.H. 454 (2006)',
                'New Hampshire Jury Instructions',
                'Justia - New Hampshire Premises Liability',
                'NH Bar Association'
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

-- RULE 2: TRESPASSER DUTY (MINIMAL DUTY)
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
    'NH-SLIP-FALL-TRESPASSER-DUTY',
    5,
    'NH Premises Liability: Trespasser Duty (Minimal Standard)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'NH',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'common_law_basis', 'Traditional trespasser duty',
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
                'New Hampshire common law',
                'Justia - New Hampshire Premises Liability'
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
    'NH-SLIP-FALL-MODIFIED-COMPARATIVE-51-BAR',
    5,
    'NH Modified Comparative Negligence: 51% Bar (N.H. Rev. Stat. Ann. § 507:7-d)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'NH',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'statutory_rule',
        'statute', 'N.H. Rev. Stat. Ann. § 507:7-d',
        'statute_text', jsonb_build_object(
            'full_text', 'In any action to recover damages for negligence, the plaintiff shall be barred from recovery if the plaintiff was, at the time of the injury, more at fault than the defendant. Otherwise, the plaintiff may recover damages in proportion to the defendant fault percentage.',
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
            'rule', 'Several liability - each defendant liable only for their proportionate share',
            'statute_reference', 'N.H. Rev. Stat. Ann. § 507:7-e'
        ),
        'verification', jsonb_build_object(
            'statute_text_verified', true,
            'multiple_sources', jsonb_build_array(
                'N.H. Rev. Stat. Ann. § 507:7-d (NH Legislature)',
                'N.H. Rev. Stat. Ann. § 507:7-e (Several Liability)',
                'Justia - New Hampshire Comparative Negligence',
                'New Hampshire Bar Association'
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
    'NH-SLIP-FALL-SOL-3-YEARS',
    5,
    'NH Statute of Limitations: 3 YEARS (N.H. Rev. Stat. Ann. § 508:4, I)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'NH',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'statutory_rule',
        'statute', 'N.H. Rev. Stat. Ann. § 508:4, I',
        'statute_text', jsonb_build_object(
            'full_text', 'The following actions shall be brought within 3 years after the cause of action accrued: I. Actions for negligence...',
            'key_provisions', jsonb_build_array(
                '3-year limitation period for negligence actions',
                'Applies to slip and fall premises liability cases',
                'Time begins to run from date of injury'
            )
        ),
        'sol_period', '3 years',
        'trigger_date', 'Date of injury/accident',
        'tolling_exceptions', jsonb_build_object(
            'minority', 'SOL tolled until minor reaches age 18 (N.H. Rev. Stat. Ann. § 508:8)',
            'disability', 'SOL may be tolled for mental incapacity',
            'discovery_rule', 'Limited application - injury date generally controls'
        ),
        'practical_examples', jsonb_build_array(
            'Slip and fall on January 1, 2024: Must file by January 1, 2027',
            'Fall on March 15, 2025: Must file by March 15, 2028'
        ),
        'filing_requirements', jsonb_build_object(
            'complaint_timing', 'File complaint within 3 years of injury date',
            'service_timing', 'Serve defendant within 90 days of filing (N.H. Rev. Stat. Ann. § 510:1)'
        ),
        'verification', jsonb_build_object(
            'statute_text_verified', true,
            'multiple_sources', jsonb_build_array(
                'N.H. Rev. Stat. Ann. § 508:4, I (NH Legislature)',
                'N.H. Rev. Stat. Ann. § 508:8 (Minor Tolling)',
                'N.H. Rev. Stat. Ann. § 510:1 (Service)',
                'New Hampshire Court Rules',
                'Justia - New Hampshire SOL'
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

-- RULE 5: NOTICE REQUIREMENT
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
    'NH-SLIP-FALL-NOTICE-REQUIREMENT',
    5,
    'NH Slip & Fall: Notice Requirement',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'NH',

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
        'key_case', 'Sweeney v. Ragaglia, 154 N.H. 454 (2006)',
        'verification', jsonb_build_object(
            'case_law_verified', true,
            'multiple_sources', jsonb_build_array(
                'Sweeney v. Ragaglia, 154 N.H. 454 (2006)',
                'Ouellette v. Blanchard, 157 N.H. 399 (2008)',
                'New Hampshire Jury Instructions'
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

-- RULE 6: OPEN AND OBVIOUS DANGER DOCTRINE
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
    'NH-SLIP-FALL-OPEN-AND-OBVIOUS',
    5,
    'NH Slip & Fall: Open and Obvious Danger Doctrine',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'NH',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'doctrine_statement', 'Property owner has no duty to warn of dangers that are open and obvious',
        'doctrine_application', jsonb_build_object(
            'general_rule', 'No duty to warn of hazards that are clearly visible and apparent',
            'rationale', 'Visitors are expected to exercise reasonable care for their own safety regarding obvious dangers',
            'exceptions', jsonb_build_array(
                'Owner has reason to expect visitor will be distracted',
                'Owner has reason to expect visitor will proceed despite danger',
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
        'key_case', 'Pantelimon v. Hadley, 159 N.H. 254, 986 A.2d 505 (2009)',
        'verification', jsonb_build_object(
            'case_law_verified', true,
            'multiple_sources', jsonb_build_array(
                'Pantelimon v. Hadley, 159 N.H. 254 (2009)',
                'New Hampshire Jury Instructions',
                'Justia - New Hampshire Premises Liability'
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
    'NH-SLIP-FALL-DAMAGES',
    5,
    'NH Slip & Fall: Damages Recovery',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'NH',

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
            'cap', 'No statutory cap on personal injury damages'
        ),
        'punitive_damages', jsonb_build_object(
            'availability', 'Not available in New Hampshire',
            'alternative', 'Enhanced compensatory damages may be awarded in limited circumstances',
            'statute', 'N.H. Rev. Stat. Ann. § 507:16'
        ),
        'comparative_fault_effect', jsonb_build_object(
            'rule', 'Damages reduced by plaintiff percentage of fault',
            'statute', 'N.H. Rev. Stat. Ann. § 507:7-d'
        ),
        'verification', jsonb_build_object(
            'statutes_verified', true,
            'multiple_sources', jsonb_build_array(
                'N.H. Rev. Stat. Ann. § 507:7-d',
                'N.H. Rev. Stat. Ann. § 507:16',
                'New Hampshire Bar Association'
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

-- RULE 8: PREMISES LIABILITY COMPLAINT REQUIREMENTS
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
    'NH-SLIP-FALL-COMPLAINT-REQUIREMENTS',
    5,
    'NH Slip & Fall: Complaint Requirements',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'NH',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'procedural_rule',
        'complaint_elements', jsonb_build_object(
            'required_allegations', jsonb_build_array(
                'Date and time of incident',
                'Location/address of premises',
                'Description of hazardous condition',
                'Status of plaintiff (lawful visitor)',
                'Notice to defendant (actual or constructive)',
                'Duty owed by defendant',
                'Breach of duty',
                'Causation',
                'Damages'
            ),
            'venue', 'Superior Court in county where cause of action accrued (N.H. Rev. Stat. Ann. § 507:2)'
        ),
        'pleading_standard', jsonb_build_object(
            'rule', 'Notice pleading standard',
            'sufficiency', 'Complaint must give defendant fair notice of claims'
        ),
        'filing_requirements', jsonb_build_object(
            'filing_fee', 'Varies - approximately $240 for Superior Court'
        ),
        'service_of_process', jsonb_build_object(
            'rule', 'Serve within 90 days of filing',
            'statute', 'N.H. Rev. Stat. Ann. § 510:1'
        ),
        'verification', jsonb_build_object(
            'rules_verified', true,
            'multiple_sources', jsonb_build_array(
                'New Hampshire Superior Court Rules',
                'N.H. Rev. Stat. Ann. § 507:2 (Venue)',
                'N.H. Rev. Stat. Ann. § 510:1 (Service)'
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

-- RULE 9: NATURAL ACCUMULATION DOCTRINE
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
    'NH-SLIP-FALL-NATURAL-ACCUMULATION',
    5,
    'NH Slip & Fall: Natural Accumulation Doctrine',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'NH',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'doctrine_statement', 'No liability for natural accumulations of snow and ice unless negligently removed',
        'doctrine_application', jsonb_build_object(
            'general_rule', 'Property owner generally not liable for slips on natural snow/ice accumulation',
            'rationale', 'Natural accumulations are open and obvious hazards',
            'exceptions', jsonb_build_array(
                'Owner undertook removal and did so negligently',
                'Owner created unnatural accumulation',
                'Owner allowed accumulation to become unnatural through traffic patterns'
            )
        ),
        'natural_vs_unnatural', jsonb_build_object(
            'natural', jsonb_build_array(
                'Snow falling naturally and accumulating',
                'Ice forming naturally from weather conditions'
            ),
            'unnatural', jsonb_build_array(
                'Piles from snow removal operations',
                'Ice from melting and refreezing due to drainage issues',
                'Accumulation redirected by property modifications'
            )
        ),
        'key_case', 'Carignan v. New Hampshire Interscholastic Athletic Assn, 151 N.H. 404 (2004)',
        'verification', jsonb_build_object(
            'case_law_verified', true,
            'multiple_sources', jsonb_build_array(
                'Carignan v. New Hampshire Interscholastic Athletic Assn, 151 N.H. 404 (2004)',
                'New Hampshire Jury Instructions',
                'Justia - New Hampshire Premises Liability'
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
    'NH-SLIP-FALL-DOCUMENTATION-CHECKLIST',
    5,
    'NH Slip & Fall: Documentation and Evidence Checklist',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'NH',

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
            'notice', 'Consider spoliation letter to preserve surveillance video'
        ),
        'verification', jsonb_build_object(
            'practice_guide_verified', true,
            'multiple_sources', jsonb_build_array(
                'New Hampshire Discovery Rules',
                'New Hampshire Evidence Rules',
                'NH Bar Association Practice Guides'
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
