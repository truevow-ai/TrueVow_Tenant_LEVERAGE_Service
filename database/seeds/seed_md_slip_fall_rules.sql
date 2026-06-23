-- =====================================================
-- Maryland (MD) Slip & Fall Premises Liability Rules
-- Enhanced Verification Protocol v2.0
-- =====================================================
-- State: Maryland
-- Comparative Negligence: CONTRIBUTORY NEGLIGENCE (complete bar if ANY fault)
-- SOL: 3 YEARS (Md. Code Ann., Cts. & Jud. Proc. § 5-101)
-- Classification: Traditional common law (invitee/licensee/trespasser)
-- Unique Features: One of 4 remaining contributory negligence states (harshest rule)
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
    'MD-SLIP-FALL-INVITEE-DUTY',
    5,
    'MD Premises Liability: Invitee Duty (Highest Standard)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'MD',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'common_law_basis', 'Traditional invitee/licensee/trespasser classifications',
        'invitee_definition', jsonb_build_object(
            'business_invitee', 'Person invited onto property for business purposes benefiting owner',
            'public_invitee', 'Person invited as member of public for purposes property is held open',
            'examples', jsonb_build_array(
                'Customer in retail store',
                'Restaurant patron',
                'Hotel guest',
                'Bank customer',
                'Visitor to public park'
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
            'constructive_notice', 'Owner liable if knew or SHOULD HAVE KNOWN of danger through reasonable inspection'
        ),
        'practical_examples', jsonb_build_array(
            'Slip on liquid spill in grocery store - owner liable if spill existed long enough for discovery',
            'Fall on icy parking lot - owner liable if ice accumulated without inspection',
            'Trip on broken tile - owner liable if tile broken for extended period'
        ),
        'verification', jsonb_build_object(
            'common_law_verified', true,
            'multiple_sources', jsonb_build_array(
                'Maryland common law - invitee duty',
                'Justia - Maryland Premises Liability',
                'Maryland Bar Association resources'
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

-- RULE 2: LICENSEE DUTY
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
    'MD-SLIP-FALL-LICENSEE-DUTY',
    5,
    'MD Premises Liability: Licensee Duty (Moderate Standard)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'MD',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'licensee_definition', 'Person who enters property with permission for own purposes',
        'duty_standard', jsonb_build_object(
            'moderate_duty', 'Owner owes moderate duty',
            'limited_obligations', jsonb_build_array(
                'Duty to warn of KNOWN hidden dangers',
                'NO duty to inspect',
                'NO duty to make safe'
            ),
            'actual_knowledge_required', 'Owner liable ONLY for dangers actually known'
        ),
        'verification', jsonb_build_object(
            'common_law_verified', true,
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

-- RULE 3: TRESPASSER DUTY
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
    'MD-SLIP-FALL-TRESPASSER-DUTY',
    5,
    'MD Premises Liability: Trespasser Duty (Minimal Standard)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'MD',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'trespasser_definition', 'Person who enters property without permission',
        'duty_standard', jsonb_build_object(
            'minimal_duty', 'Owner owes minimal duty',
            'very_limited_obligations', jsonb_build_array(
                'May not willfully or wantonly injure',
                'NO duty to warn, inspect, or make safe'
            )
        ),
        'verification', jsonb_build_object(
            'common_law_verified', true,
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

-- RULE 4: CONTRIBUTORY NEGLIGENCE (COMPLETE BAR - HARSHEST RULE)
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
    'MD-SLIP-FALL-CONTRIBUTORY-NEGLIGENCE',
    5,
    'MD Contributory Negligence - COMPLETE BAR (Common Law)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'MD',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'common_law_basis', 'Maryland follows pure contributory negligence doctrine',
        'negligence_model', 'contributory_negligence',
        'complete_bar', 'Plaintiff cannot recover if ANY fault attributed to plaintiff - even 1% fault bars all recovery',
        'harshest_rule', 'Maryland is one of only 4 remaining contributory negligence states - HARSHEST rule against plaintiffs in U.S.',
        'rule_description', 'Maryland follows CONTRIBUTORY negligence: any plaintiff fault (even 1%) completely bars recovery',
        'practical_examples', jsonb_build_array(
            'Plaintiff 0% at fault: Can recover full damages',
            'Plaintiff 1% at fault: NO RECOVERY (complete bar)',
            'Plaintiff 5% at fault: NO RECOVERY (complete bar)',
            'Plaintiff 30% at fault: NO RECOVERY (complete bar)',
            'Plaintiff 99% at fault: NO RECOVERY (complete bar)'
        ),
        'all_or_nothing', 'Contributory negligence is all-or-nothing: either plaintiff recovers 100% or 0%',
        'four_remaining_states', jsonb_build_array(
            'Maryland',
            'Virginia',
            'North Carolina',
            'Alabama',
            'District of Columbia'
        ),
        'burden_of_proof', jsonb_build_object(
            'defendant_burden', 'Defendant bears burden to prove plaintiff contributory negligence',
            'affirmative_defense', 'Contributory negligence is affirmative defense',
            'jury_determination', 'Jury determines if plaintiff had any fault - if yes, plaintiff barred'
        ),
        'extremely_difficult_for_plaintiffs', 'Maryland contributory negligence rule is MOST DIFFICULT for plaintiffs - any fault bars recovery',
        'common_defenses', jsonb_build_array(
            'Plaintiff failed to watch where walking (even momentary distraction bars recovery)',
            'Plaintiff wore inappropriate footwear',
            'Plaintiff ignored warning signs',
            'Open and obvious danger plaintiff should have seen',
            'ANY plaintiff carelessness bars recovery'
        ),
        'plaintiff_strategies', jsonb_build_array(
            'Emphasize plaintiff exercised reasonable care at all times',
            'Show hazard was hidden/latent with no opportunity to discover',
            'Prove owner had superior knowledge',
            'Demonstrate owner violations created hazard',
            'CRITICAL: Plaintiff must prove ZERO fault to recover'
        ),
        'last_clear_chance', jsonb_build_object(
            'doctrine', 'Last clear chance doctrine may allow recovery even with plaintiff contributory negligence',
            'application', 'If defendant had last clear chance to avoid harm but failed, plaintiff may still recover',
            'rare', 'Last clear chance doctrine rarely applied in slip/fall cases'
        ),
        'comparative_note', 'Maryland contributory negligence is HARSHEST against plaintiffs - most other states allow recovery even at 50% fault',
        'verification', jsonb_build_object(
            'common_law_verified', true,
            'multiple_sources', jsonb_build_array(
                'Maryland common law - contributory negligence',
                'Justia - Maryland Contributory Negligence',
                'Maryland Bar Association - Tort Law Guide',
                'Legal treatises on Maryland tort law',
                'Analysis of four remaining contributory negligence states'
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

-- RULE 5: STATUTE OF LIMITATIONS (3 YEARS)
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
    'MD-SLIP-FALL-SOL-3-YEARS',
    5,
    'MD Statute of Limitations: 3 YEARS (Md. Code Ann., Cts. & Jud. Proc. § 5-101)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'MD',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'statute', 'Md. Code Ann., Cts. & Jud. Proc. § 5-101',
        'sol_period', '3 years',
        'statute_text', 'Md. Code Ann., Cts. & Jud. Proc. § 5-101: A civil action at law shall be filed within three years from the date it accrues unless another provision of the Code provides... a different period of time.',
        'trigger_date', 'SOL begins running on date of injury',
        'filing_deadline', 'Complaint must be filed within 3 YEARS of injury date',
        'practical_examples', jsonb_build_array(
            'Fall on Jan 1, 2024 → Must file by Jan 1, 2027',
            'Fall on June 15, 2024 → Must file by June 15, 2027'
        ),
        'tolling_exceptions', jsonb_build_object(
            'minority', 'SOL tolled for minors',
            'mental_illness', 'SOL may be tolled for mental disability'
        ),
        'consequences_of_missing', jsonb_build_array(
            'Case dismissed with prejudice',
            'Cannot refile after SOL expires'
        ),
        'verification', jsonb_build_object(
            'statute_text_verified', true,
            'multiple_sources', jsonb_build_array(
                'Md. Code Ann., Cts. & Jud. Proc. § 5-101 (primary source)',
                'Maryland Legislature - Statute Database',
                'Justia - Maryland Statute of Limitations'
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
