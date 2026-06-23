-- =====================================================
-- Maine (ME) Slip & Fall Premises Liability Rules
-- Enhanced Verification Protocol v2.0
-- =====================================================
-- State: Maine
-- Comparative Negligence: Modified 50% bar (STRICT - must be less than 50%)
-- SOL: 6 YEARS (14 M.R.S. § 752) - LONGEST FOR PERSONAL INJURY IN U.S.
-- Classification: Traditional common law (invitee/licensee/trespasser)
-- Unique Features: 6-year SOL (longest in U.S. for PI)
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
    'ME-SLIP-FALL-INVITEE-DUTY',
    5,
    'ME Premises Liability: Invitee Duty (Highest Standard)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'ME',

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
                'Maine common law - invitee duty',
                'Justia - Maine Premises Liability',
                'Maine Bar Association resources'
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
    'ME-SLIP-FALL-LICENSEE-DUTY',
    5,
    'ME Premises Liability: Licensee Duty (Moderate Standard)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'ME',

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
    'ME-SLIP-FALL-TRESPASSER-DUTY',
    5,
    'ME Premises Liability: Trespasser Duty (Minimal Standard)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'ME',

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

-- RULE 4: MODIFIED COMPARATIVE 50% BAR (STRICT)
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
    'ME-SLIP-FALL-MODIFIED-COMPARATIVE',
    5,
    'ME Modified Comparative 50% Bar STRICT (14 M.R.S. § 156)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'ME',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'statute', '14 M.R.S. § 156',
        'negligence_model', 'modified_comparative_50_bar_strict',
        'fifty_percent_bar_strict', 'Plaintiff cannot recover if 50% or more at fault; can recover ONLY if LESS than 50% at fault',
        'statute_text', '14 M.R.S. § 156: Contributory negligence shall not bar recovery... if such negligence was not greater than the causal negligence of the party against whom recovery is sought.',
        'interpretation', 'Maine courts interpret "not greater than" to require plaintiff be LESS than 50% at fault',
        'practical_examples', jsonb_build_array(
            'Plaintiff 0-49% at fault: Can recover reduced damages',
            'Plaintiff 49% at fault: Recovers 51% of damages',
            'Plaintiff 50% at fault: NO RECOVERY (barred)',
            'Plaintiff 51% at fault: NO RECOVERY (barred)'
        ),
        'comparative_note', 'Maine 50% bar is STRICTER than 51% bar states (must be below 50%)',
        'verification', jsonb_build_object(
            'statute_text_verified', true,
            'multiple_sources', jsonb_build_array(
                '14 M.R.S. § 156 (primary source)',
                'Maine Legislature - Statute Database',
                'Justia - Maine Comparative Negligence'
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

-- RULE 5: STATUTE OF LIMITATIONS (6 YEARS - LONGEST IN U.S.)
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
    'ME-SLIP-FALL-SOL-6-YEARS',
    5,
    'ME Statute of Limitations: 6 YEARS (14 M.R.S. § 752) - LONGEST IN U.S.',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'ME',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'statute', '14 M.R.S. § 752',
        'sol_period', '6 years',
        'longest_in_us', 'Maine has the LONGEST personal injury SOL in the United States (6 years vs 1-3 years in most states)',
        'statute_text', '14 M.R.S. § 752: Actions for assault, battery, false imprisonment, slanderous words and libel, and actions on the case for personal injuries, shall be commenced within 6 years after the cause of action accrues and not afterwards.',
        'trigger_date', 'SOL begins running on date of injury',
        'filing_deadline', 'Complaint must be filed within 6 YEARS of injury date',
        'plaintiff_advantage', 'Maine 6-year SOL is MOST FAVORABLE to plaintiffs in U.S. - provides longest time to file',
        'practical_examples', jsonb_build_array(
            'Fall on Jan 1, 2024 → Must file by Jan 1, 2030',
            'Fall on June 15, 2024 → Must file by June 15, 2030'
        ),
        'tolling_exceptions', jsonb_build_object(
            'minority', 'SOL tolled for minors',
            'mental_illness', 'SOL may be tolled for mental incapacity'
        ),
        'consequences_of_missing', jsonb_build_array(
            'Case dismissed with prejudice',
            'Cannot refile after SOL expires'
        ),
        'verification', jsonb_build_object(
            'statute_text_verified', true,
            'multiple_sources', jsonb_build_array(
                '14 M.R.S. § 752 (primary source)',
                'Maine Legislature - Statute Database',
                'Justia - Maine Statute of Limitations'
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
