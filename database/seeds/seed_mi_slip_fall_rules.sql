-- =====================================================
-- Michigan (MI) Slip & Fall Premises Liability Rules
-- Enhanced Verification Protocol v2.0
-- =====================================================
-- State: Michigan
-- Comparative Negligence: Modified 51% bar (M.C.L. § 600.2959)
-- SOL: 3 years (M.C.L. § 600.5805(10))
-- Classification: Traditional common law (invitee/licensee/trespasser)
-- Unique Features: Open and obvious danger doctrine (strong defense)
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
    'MI-SLIP-FALL-INVITEE-DUTY',
    5,
    'MI Premises Liability: Invitee Duty with Open & Obvious Defense',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'MI',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'common_law_basis', 'Traditional invitee/licensee/trespasser classifications',
        'key_case', 'Lugo v. Ameritech Corp., 464 Mich. 512 (2001)',
        'invitee_definition', jsonb_build_object(
            'business_invitee', 'Person invited onto property for business purposes benefiting owner',
            'public_invitee', 'Person invited as member of public for purposes property is held open',
            'examples', jsonb_build_array(
                'Customer in retail store',
                'Restaurant patron',
                'Hotel guest',
                'Bank customer',
                'Visitor to public facility'
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
        'open_and_obvious_doctrine', jsonb_build_object(
            'michigan_strong_defense', 'Michigan has STRONG open and obvious danger doctrine - major defense against premises liability claims',
            'lugo_standard', 'Lugo v. Ameritech Corp., 464 Mich. 512 (2001)',
            'rule', 'Owner generally owes NO DUTY to warn or protect against open and obvious dangers',
            'definition', 'Danger is open and obvious if average person of ordinary intelligence would discover it upon casual inspection',
            'exceptions', jsonb_build_array(
                'Special aspects exception: danger has unique characteristic making harm especially likely despite obviousness',
                'Effectively unavoidable exception: plaintiff had no reasonable alternative but to encounter danger'
            )
        ),
        'practical_examples', jsonb_build_array(
            'Slip on visible ice - likely open and obvious (owner may have no duty)',
            'Fall on wet floor with NO warning sign - may be open and obvious if puddle visible',
            'Trip on raised sidewalk in daylight - likely open and obvious',
            'Slip on wet floor with warning sign - definitely open and obvious'
        ),
        'plaintiff_must_prove', jsonb_build_array(
            'Plaintiff was invitee',
            'Dangerous condition existed',
            'Owner had actual or constructive notice',
            'Danger was NOT open and obvious (or exception applies)',
            'Owner failed to warn or repair',
            'Condition caused injury'
        ),
        'defense_strategies', jsonb_build_array(
            'Prove open and obvious danger (STRONGEST defense in Michigan)',
            'Challenge special aspects or unavoidability exceptions',
            'Show no actual or constructive notice',
            'Demonstrate reasonable inspection procedures',
            'Prove condition arose immediately before accident'
        ),
        'michigan_plaintiff_challenge', 'Michigan open and obvious doctrine makes slip/fall cases SIGNIFICANTLY HARDER for plaintiffs than most states',
        'verification', jsonb_build_object(
            'statute_text_verified', false,
            'common_law_verified', true,
            'multiple_sources', jsonb_build_array(
                'Lugo v. Ameritech Corp., 464 Mich. 512 (2001)',
                'Justia - Michigan Premises Liability',
                'Michigan Bar Association - Premises Liability Guide',
                'Legal treatises on Michigan tort law',
                'Michigan Court of Appeals decisions on open and obvious'
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
    'MI-SLIP-FALL-LICENSEE-DUTY',
    5,
    'MI Premises Liability: Licensee Duty (Moderate Standard)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'MI',

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
            'multiple_sources', jsonb_build_array(
                'Michigan common law',
                'Justia - Michigan Premises Liability'
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
    'MI-SLIP-FALL-TRESPASSER-DUTY',
    5,
    'MI Premises Liability: Trespasser Duty (Minimal Standard)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'MI',

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

-- RULE 4: MODIFIED COMPARATIVE 51% BAR
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
    'MI-SLIP-FALL-MODIFIED-COMPARATIVE',
    5,
    'MI Modified Comparative Negligence 51% Bar (M.C.L. § 600.2959)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'MI',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'statute', 'M.C.L. § 600.2959',
        'negligence_model', 'modified_comparative_51_bar',
        'fifty_one_percent_bar', 'Plaintiff cannot recover if MORE than 50% at fault; can recover if 50% or less',
        'statute_text', 'M.C.L. § 600.2959(1): ...the liability of each defendant for damages shall be... the percentage of the total fault of all persons that caused the injury.',
        'practical_examples', jsonb_build_array(
            'Plaintiff 0-50% at fault: Can recover reduced damages',
            'Plaintiff 50% at fault: Recovers 50% (AT THRESHOLD)',
            'Plaintiff 51% at fault: NO RECOVERY (barred)'
        ),
        'verification', jsonb_build_object(
            'statute_text_verified', true,
            'multiple_sources', jsonb_build_array(
                'M.C.L. § 600.2959 (primary source)',
                'Michigan Legislature',
                'Justia - Michigan Comparative Negligence'
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

-- RULE 5: SOL 3 YEARS
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
    'MI-SLIP-FALL-SOL-3-YEARS',
    5,
    'MI Statute of Limitations: 3 YEARS (M.C.L. § 600.5805(10))',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'MI',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'statute', 'M.C.L. § 600.5805(10)',
        'sol_period', '3 years',
        'statute_text', 'M.C.L. § 600.5805(10): ...a person shall not bring... an action to recover damages for injuries to persons or property unless... commenced within 3 years after the claim accrues.',
        'trigger_date', 'SOL begins on date of injury',
        'practical_examples', jsonb_build_array(
            'Fall on Jan 1, 2024 → Must file by Jan 1, 2027'
        ),
        'verification', jsonb_build_object(
            'statute_text_verified', true,
            'multiple_sources', jsonb_build_array(
                'M.C.L. § 600.5805(10)',
                'Michigan Legislature',
                'Justia - Michigan SOL'
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
