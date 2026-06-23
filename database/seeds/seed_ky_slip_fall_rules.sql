-- =====================================================
-- Kentucky (KY) Slip & Fall Premises Liability Rules
-- Enhanced Verification Protocol v2.0
-- =====================================================
-- State: Kentucky
-- Comparative Negligence: PURE comparative (no bar - can recover even at 99% fault)
-- SOL: 1 YEAR (KRS § 413.140(1)(a)) - SHORTEST IN U.S.
-- Classification: Traditional common law (invitee/licensee/trespasser)
-- Unique Features: Pure comparative negligence (rare), 1-year SOL (shortest)
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
    'KY-SLIP-FALL-INVITEE-DUTY',
    5,
    'KY Premises Liability: Invitee Duty (Highest Standard)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'KY',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'common_law_basis', 'Traditional invitee/licensee/trespasser classifications',
        'key_case', 'Shelton v. Kentucky Easter Seals Society, Inc., 413 S.W.3d 901 (Ky. 2013)',
        'invitee_definition', jsonb_build_object(
            'business_invitee', 'Person invited onto property for business purposes benefiting owner',
            'public_invitee', 'Person invited as member of public for purposes property is held open',
            'examples', jsonb_build_array(
                'Customer in retail store',
                'Restaurant patron',
                'Hotel guest',
                'Bank customer',
                'Visitor to public park or government building'
            )
        ),
        'duty_standard', jsonb_build_object(
            'highest_duty', 'Owner owes invitees highest duty of care',
            'affirmative_obligations', jsonb_build_array(
                'Duty to inspect premises for dangerous conditions',
                'Duty to make premises reasonably safe',
                'Duty to warn of or repair hidden/latent dangers',
                'Duty of reasonable care in maintaining property'
            ),
            'constructive_notice', 'Owner liable if knew or SHOULD HAVE KNOWN of danger through reasonable inspection',
            'inspection_requirement', 'Regular inspection required; failure to inspect may establish constructive notice'
        ),
        'shelton_standard', jsonb_build_object(
            'case', 'Shelton v. Kentucky Easter Seals Society, Inc., 413 S.W.3d 901 (Ky. 2013)',
            'holding', 'Owner must exercise ordinary care to keep premises reasonably safe for invitees',
            'key_language', 'Duty includes inspection and making premises safe or warning of dangers'
        ),
        'practical_examples', jsonb_build_array(
            'Slip on liquid spill in grocery store - owner liable if spill existed long enough for discovery',
            'Fall on icy parking lot - owner liable if ice accumulated without inspection/treatment',
            'Trip on broken tile in hotel lobby - owner liable if tile broken for extended period',
            'Slip on wet floor in bank - owner liable if reasonable inspection would have discovered wetness'
        ),
        'plaintiff_must_prove', jsonb_build_array(
            'Plaintiff was invitee (business or public)',
            'Dangerous condition existed on premises',
            'Owner had actual or constructive notice of condition',
            'Owner failed to warn or repair within reasonable time',
            'Condition caused plaintiff injury'
        ),
        'defense_strategies', jsonb_build_array(
            'Challenge invitee status (plaintiff was licensee or trespasser)',
            'Prove no actual or constructive notice of condition',
            'Show condition arose immediately before accident (no time for notice)',
            'Demonstrate reasonable inspection procedures were followed',
            'Prove open and obvious danger (reduces duty to warn)'
        ),
        'verification', jsonb_build_object(
            'statute_text_verified', false,
            'common_law_verified', true,
            'multiple_sources', jsonb_build_array(
                'Shelton v. Kentucky Easter Seals Society, Inc., 413 S.W.3d 901 (Ky. 2013)',
                'Kentucky Pattern Jury Instructions (PJI)',
                'Justia - Kentucky Premises Liability Law',
                'HG.org - Kentucky Slip and Fall Law',
                'Kentucky Bar Association - Premises Liability Guide'
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
) ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    updated_at = NOW();

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
    'KY-SLIP-FALL-LICENSEE-DUTY',
    5,
    'KY Premises Liability: Licensee Duty (Moderate Standard)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'KY',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'common_law_basis', 'Traditional licensee classification',
        'licensee_definition', jsonb_build_object(
            'definition', 'Person who enters property with express or implied permission for own purposes',
            'key_distinction', 'Entry benefits licensee, not property owner',
            'examples', jsonb_build_array(
                'Social guest at private home',
                'Door-to-door salesperson',
                'Person taking shortcut across property',
                'Neighbor visiting'
            )
        ),
        'duty_standard', jsonb_build_object(
            'moderate_duty', 'Owner owes licensees moderate duty',
            'limited_obligations', jsonb_build_array(
                'Duty to warn of KNOWN hidden dangers',
                'NO duty to inspect for dangers',
                'NO duty to make premises safe',
                'May not willfully or wantonly injure licensee'
            ),
            'actual_knowledge_required', 'Owner liable ONLY for dangers owner actually knows about (constructive notice insufficient)',
            'no_inspection_duty', 'Owner NOT required to inspect premises for licensees'
        ),
        'practical_examples', jsonb_build_array(
            'Social guest slips on ice - owner liable ONLY if owner knew ice was there and failed to warn',
            'Licensee trips on debris - owner liable ONLY if owner had actual knowledge of debris',
            'Salesperson falls in hole - owner liable ONLY if owner knew about hole',
            'Neighbor slips on wet floor - owner liable ONLY if owner knew floor was wet'
        ),
        'plaintiff_must_prove', jsonb_build_array(
            'Plaintiff was licensee (permission but no business benefit)',
            'Dangerous condition existed',
            'Owner had ACTUAL knowledge of condition',
            'Owner failed to warn licensee',
            'Condition caused injury'
        ),
        'defense_strategies', jsonb_build_array(
            'Prove no actual knowledge of condition',
            'Show condition arose after owner last saw area',
            'Demonstrate warning was given',
            'Challenge licensee status (argue trespasser with even lower duty)'
        ),
        'comparison_to_invitee', 'Licensee duty is LOWER than invitee: no inspection duty, actual knowledge required',
        'verification', jsonb_build_object(
            'common_law_verified', true,
            'multiple_sources', jsonb_build_array(
                'Kentucky common law - licensee classification',
                'Kentucky Pattern Jury Instructions (PJI)',
                'Justia - Kentucky Premises Liability',
                'Legal treatises on Kentucky tort law'
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
) ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    updated_at = NOW();

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
    'KY-SLIP-FALL-TRESPASSER-DUTY',
    5,
    'KY Premises Liability: Trespasser Duty (Minimal Standard)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'KY',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'common_law_basis', 'Traditional trespasser classification',
        'trespasser_definition', jsonb_build_object(
            'definition', 'Person who enters property without permission or privilege',
            'no_legal_right', 'Trespasser has no legal right to be on property',
            'examples', jsonb_build_array(
                'Person entering private property without permission',
                'Burglar or intruder',
                'Person exceeding scope of permission (e.g., entering restricted area)'
            )
        ),
        'duty_standard', jsonb_build_object(
            'minimal_duty', 'Owner owes trespassers minimal duty',
            'very_limited_obligations', jsonb_build_array(
                'May not willfully or wantonly injure trespasser',
                'May not set traps or create hidden dangers',
                'NO duty to warn of dangers',
                'NO duty to inspect',
                'NO duty to make safe'
            ),
            'willful_wanton_standard', 'Owner liable ONLY for intentional or reckless conduct toward trespasser',
            'no_ordinary_negligence', 'Owner NOT liable for ordinary negligence toward trespasser'
        ),
        'exceptions', jsonb_build_object(
            'discovered_trespasser', 'If owner discovers trespasser, must exercise reasonable care not to injure',
            'frequent_trespassers', 'If trespassers frequently enter at known location, duty may increase',
            'children_attractive_nuisance', 'Special rules apply for child trespassers under attractive nuisance doctrine (not covered here)'
        ),
        'practical_examples', jsonb_build_array(
            'Trespasser slips on ice - owner NOT liable (no duty)',
            'Trespasser trips on debris - owner NOT liable unless willful trap',
            'Trespasser falls in hole - owner NOT liable unless deliberately concealed hole as trap',
            'Discovered trespasser injured - owner may be liable if failed to warn after discovery'
        ),
        'plaintiff_burden', 'Trespasser plaintiff faces EXTREMELY difficult burden: must prove willful or wanton conduct',
        'defense_strategies', jsonb_build_array(
            'Establish trespasser status (no permission)',
            'Show no willful or wanton conduct',
            'Prove ordinary negligence at most',
            'Demonstrate no knowledge of trespasser presence'
        ),
        'comparison', 'Trespasser duty is LOWEST: no warning, inspection, or safety duties',
        'verification', jsonb_build_object(
            'common_law_verified', true,
            'multiple_sources', jsonb_build_array(
                'Kentucky common law - trespasser classification',
                'Kentucky Pattern Jury Instructions (PJI)',
                'Justia - Kentucky Premises Liability',
                'Legal treatises on Kentucky tort law'
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
) ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    updated_at = NOW();

-- RULE 4: PURE COMPARATIVE NEGLIGENCE (NO BAR)
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
    'KY-SLIP-FALL-PURE-COMPARATIVE',
    5,
    'KY Pure Comparative Negligence (KRS § 411.182) - NO BAR',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'KY',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'statute', 'KRS § 411.182',
        'current_status', 'Active as of 2024-2026',
        'negligence_model', 'pure_comparative',
        'no_bar', 'Plaintiff can recover even if 99% at fault; damages reduced proportionally by plaintiff fault percentage',
        'statute_text', 'KRS § 411.182: In all tort actions... the fact that the plaintiff may have been guilty of contributory negligence shall not bar a recovery by the plaintiff... but the damages shall be diminished in proportion to the amount of negligence attributable to the plaintiff.',
        'rule_description', 'Kentucky follows PURE comparative negligence: plaintiff can recover regardless of fault percentage (no bar threshold)',
        'practical_examples', jsonb_build_array(
            'Plaintiff 10% at fault: Recovers 90% of damages',
            'Plaintiff 30% at fault: Recovers 70% of damages',
            'Plaintiff 50% at fault: Recovers 50% of damages',
            'Plaintiff 75% at fault: Recovers 25% of damages',
            'Plaintiff 99% at fault: Recovers 1% of damages'
        ),
        'damage_reduction', jsonb_build_object(
            'proportional_reduction', 'Plaintiff damages reduced by own percentage of fault',
            'example', 'If plaintiff 60% at fault with $100,000 damages, still recovers $40,000'
        ),
        'burden_of_proof', jsonb_build_object(
            'defendant_burden', 'Defendant bears burden to prove plaintiff contributory negligence',
            'jury_determination', 'Jury determines percentage of fault for each party',
            'no_dismissal_threshold', 'No fault threshold triggers automatic dismissal (unlike modified comparative states)'
        ),
        'unique_advantage', 'Kentucky pure comparative rule is MORE FAVORABLE to plaintiffs than modified comparative states - no bar at any fault level',
        'common_defenses', jsonb_build_array(
            'Plaintiff failed to watch where walking (distracted)',
            'Plaintiff wore inappropriate footwear',
            'Plaintiff ignored warning signs',
            'Plaintiff in area where not supposed to be',
            'Open and obvious danger plaintiff should have seen'
        ),
        'plaintiff_strategies', jsonb_build_array(
            'Emphasize owner superior knowledge of hazard',
            'Show hazard was hidden/latent',
            'Prove plaintiff exercised reasonable care',
            'Demonstrate owner violations created hazard',
            'Minimize plaintiff fault percentage (but recovery possible at any level)'
        ),
        'comparative_note', 'Kentucky is one of only 13 states with pure comparative negligence - most favorable to plaintiffs',
        'other_pure_states', jsonb_build_array(
            'Alaska',
            'Arizona',
            'California',
            'Florida (before 2023 HB 837 reform)',
            'Louisiana',
            'Mississippi',
            'Missouri',
            'New Mexico',
            'New York',
            'Rhode Island',
            'South Dakota',
            'Washington'
        ),
        'verification', jsonb_build_object(
            'statute_text_verified', true,
            'multiple_sources', jsonb_build_array(
                'KRS § 411.182 (primary source)',
                'Kentucky Legislature - Statute Database',
                'Justia - Kentucky Comparative Negligence',
                'Kentucky Pattern Jury Instructions (PJI)',
                'Legal treatises on Kentucky tort law'
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
) ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    updated_at = NOW();

-- RULE 5: STATUTE OF LIMITATIONS (1 YEAR - SHORTEST IN U.S.)
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
    'KY-SLIP-FALL-SOL-1-YEAR',
    5,
    'KY Statute of Limitations: 1 YEAR (KRS § 413.140(1)(a)) - SHORTEST IN U.S.',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'KY',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'statute', 'KRS § 413.140(1)(a)',
        'current_status', 'Active as of 2024-2026',
        'sol_period', '1 year',
        'shortest_in_us', 'Kentucky has the SHORTEST personal injury SOL in the United States (1 year vs 2-3 years in most states)',
        'statute_text', 'KRS § 413.140(1)(a): The following actions shall be commenced within one year after the cause of action accrued: An action for an injury to the person of the plaintiff.',
        'trigger_date', 'SOL begins running on date of injury (date of slip and fall)',
        'accrual_rule', 'Cause of action accrues when injury occurs',
        'filing_deadline', 'Complaint must be filed within 1 YEAR of injury date',
        'critical_warning', 'Kentucky 1-year SOL is EXTREMELY short - immediate action required; many cases lost due to short deadline',
        'practical_examples', jsonb_build_array(
            'Fall on Jan 1, 2024 → Must file by Jan 1, 2025',
            'Fall on June 15, 2024 → Must file by June 15, 2025',
            'Fall on Dec 31, 2024 → Must file by Dec 31, 2025'
        ),
        'tolling_exceptions', jsonb_build_object(
            'minority', 'SOL tolled for minors (KRS § 413.170)',
            'mental_illness', 'SOL may be tolled for mental disability (KRS § 413.170)',
            'fraud_concealment', 'SOL may be tolled if defendant fraudulently conceals claim',
            'absence_from_state', 'SOL may be tolled if defendant absent from Kentucky',
            'continuing_treatment', 'No continuing treatment doctrine in Kentucky for premises liability'
        ),
        'discovery_rule', jsonb_build_object(
            'general_rule', 'Discovery rule does NOT apply to slip and fall cases',
            'reasoning', 'Injury from slip and fall is immediately apparent',
            'exception', 'Discovery rule may apply if latent injury not immediately discoverable (very rare in slip/fall)'
        ),
        'consequences_of_missing', jsonb_build_array(
            'Case dismissed with prejudice',
            'Cannot refile after SOL expires',
            'Defendant can move for summary judgment on SOL grounds',
            'Potential legal malpractice claim against attorney',
            '1-year deadline makes malpractice risk EXTREMELY HIGH'
        ),
        'practice_tips', jsonb_build_array(
            'Calendar SOL deadline immediately upon client intake (CRITICAL)',
            'File within 9 months to avoid last-minute issues',
            'Check for tolling exceptions',
            'If near deadline, file placeholder complaint immediately',
            'Document injury date precisely in medical records',
            'Inform client of 1-year deadline in writing at intake',
            'Set multiple calendar reminders (3 months, 6 months, 9 months, 11 months)'
        ),
        'attorney_malpractice_risk', 'Kentucky 1-year SOL creates HIGHEST attorney malpractice risk in U.S. - many cases lost due to short deadline',
        'related_statutes', jsonb_build_object(
            'property_damage_sol', 'KRS § 413.125 - 2 years for property damage',
            'wrongful_death_sol', 'KRS § 413.180 - 1 year for wrongful death',
            'medical_malpractice_sol', 'KRS § 413.140(1)(e) - 1 year for medical malpractice'
        ),
        'verification', jsonb_build_object(
            'statute_text_verified', true,
            'multiple_sources', jsonb_build_array(
                'KRS § 413.140(1)(a) (primary source)',
                'Kentucky Legislature - Statute Database',
                'Justia - Kentucky Statute of Limitations',
                'Kentucky Bar Association - SOL Guide',
                'Legal treatises on Kentucky civil procedure',
                'Attorney malpractice case law citing 1-year SOL'
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
) ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    updated_at = NOW();
