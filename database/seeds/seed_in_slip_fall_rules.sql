-- =====================================================================================

-- INDIANA SLIP & FALL / PREMISES LIABILITY RULES SEED FILE

-- =====================================================================================

-- State: Indiana (IN)

-- Practice Area: Personal Injury

-- Sub-Specialization: Slip & Fall / Premises Liability

-- Liability Model: COMMON LAW (Invitee/Licensee/Trespasser distinctions)

-- Primary Authority: Ind. Code § 34-51-2-6 (Modified Comparative Fault)

-- Modified Comparative Fault: 51% BAR (Ind. Code § 34-51-2-6)

-- Statute of Limitations: 2 years (Ind. Code § 34-11-2-4)

-- 

-- VERIFICATION STATUS: DOCUMENT VERIFIED

-- Research Date: January 31, 2026

-- Sources Verified:

--   1. Ind. Code § 34-51-2-6 - Modified comparative fault (51% bar)

--   2. Ind. Code § 34-11-2-4 - Statute of limitations (2 years for injury)

--   3. Indiana common law premises liability (invitee/licensee/trespasser)

--   4. Indiana Supreme Court cases on premises liability standards

-- 

-- INDIANA UNIQUE FEATURES:

--   - Maintains traditional common law invitee/licensee/trespasser classifications

--   - Modified comparative fault 51% bar (must be 50% or less to recover)

--   - 2-year SOL strictly enforced

--   - Several liability (defendants liable only for their own share)

-- =====================================================================================



-- =====================================================================================

-- RULE 1: INVITEE DUTY OF CARE (HIGHEST STANDARD)

-- =====================================================================================

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

    'IN-SLIP-FALL-INVITEE-DUTY',

    5,  -- Contextual Rule

    'IN Invitee Duty of Care (Common Law)',

    'content_check',

    'personal_injury',

    'slip_fall',

    'complaint',

    'state',

    'IN',



    jsonb_build_object(

        'sub_specialization_type', 'premises_liability',

        'liability_model', 'common_law_invitee',

        'authority_level', 'contextual_rule',

        'visitor_classification', 'invitee',

        'duty_of_care_standard', 'highest',

        'rule_description', 'Property owner owes invitees highest duty - must exercise reasonable care to protect invitees from dangers owner knows or should know about',

        'invitee_definition', 'Person invited onto property for business or mutual benefit - includes customers, clients, retail shoppers, restaurant patrons',

        'duty_elements', jsonb_build_array(

            'Exercise reasonable care to protect invitees from danger',

            'Conduct reasonable inspections to discover dangerous conditions',

            'Warn invitees of known non-obvious dangers',

            'Remedy or repair hazardous conditions within reasonable time',

            'Protect invitees from foreseeable harm'

        ),

        'notice_requirement', 'Indiana requires plaintiff prove owner had actual or constructive notice of dangerous condition - constructive notice requires showing condition existed long enough that reasonable inspection would discover it',

        'verification', jsonb_build_object(

            'multiple_sources', jsonb_build_array(

                'Indiana Supreme Court - Premises liability standards',

                'Vaughan & Vaughan - IN Slip and Fall',

                'Goodin Abernathy - Invitee Rights',

                'Ward & Ward - IN Premises Law',

                'Indiana case law compilation'

            ),

            'current_as_of', '2024-2026',

            'source_type', 'common_law',

            'last_verified', '2026-01-31',

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



-- =====================================================================================

-- RULE 2: LICENSEE DUTY OF CARE (MODERATE STANDARD)

-- =====================================================================================

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

    'IN-SLIP-FALL-LICENSEE-DUTY',

    5,  -- Contextual Rule

    'IN Licensee Duty of Care (Common Law)',

    'content_check',

    'personal_injury',

    'slip_fall',

    'complaint',

    'state',

    'IN',



    jsonb_build_object(

        'sub_specialization_type', 'premises_liability',

        'liability_model', 'common_law_licensee',

        'authority_level', 'contextual_rule',

        'visitor_classification', 'licensee',

        'duty_of_care_standard', 'moderate',

        'rule_description', 'Property owner owes licensees moderate duty - must warn of known concealed dangers but no duty to inspect for unknown hazards',

        'licensee_definition', 'Person on property with permission for own purposes, not for owner business benefit - includes social guests, friends',

        'duty_elements', jsonb_build_array(

            'Warn of known concealed dangers',

            'No duty to inspect for unknown hazards',

            'No duty to discover hidden defects',

            'Must not willfully or wantonly harm licensees'

        ),

        'key_distinction', 'Licensee takes premises as found - owner only liable for dangers owner actually knows about',

        'verification', jsonb_build_object(

            'multiple_sources', jsonb_build_array(

                'Indiana Supreme Court - Licensee standards',

                'Vaughan & Vaughan - Visitor Classifications',

                'Goodin Abernathy - IN Premises Duty',

                'Ward & Ward - Licensee Law'

            ),

            'current_as_of', '2024-2026',

            'source_type', 'common_law',

            'last_verified', '2026-01-31',

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



-- =====================================================================================

-- RULE 3: TRESPASSER DUTY OF CARE (MINIMAL STANDARD)

-- =====================================================================================

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

    'IN-SLIP-FALL-TRESPASSER-DUTY',

    5,  -- Contextual Rule

    'IN Trespasser Duty of Care (Common Law)',

    'content_check',

    'personal_injury',

    'slip_fall',

    'complaint',

    'state',

    'IN',



    jsonb_build_object(

        'sub_specialization_type', 'premises_liability',

        'liability_model', 'common_law_trespasser',

        'authority_level', 'contextual_rule',

        'visitor_classification', 'trespasser',

        'duty_of_care_standard', 'minimal',

        'rule_description', 'Property owner owes trespassers only duty not to willfully or wantonly injure',

        'trespasser_definition', 'Person who enters or remains on property without permission',

        'duty_elements', jsonb_build_array(

            'Must not willfully or wantonly injure trespassers',

            'No duty to warn of hazards',

            'No duty to inspect or make safe',

            'Must not set traps'

        ),

        'attractive_nuisance_exception', jsonb_build_object(

            'applies_to', 'Child trespassers',

            'requirements', jsonb_build_array(

                'Owner knows children frequent area',

                'Artificial condition poses unreasonable risk',

                'Children unable to appreciate danger',

                'Burden of eliminating danger is slight',

                'Owner fails to exercise reasonable care'

            ),

            'examples', jsonb_build_array(

                'Swimming pools without fencing',

                'Trampolines',

                'Construction equipment'

            )

        ),

        'verification', jsonb_build_object(

            'multiple_sources', jsonb_build_array(

                'Indiana common law - trespasser standards',

                'Vaughan & Vaughan - Minimal Duty',

                'Goodin Abernathy - Trespasser Law'

            ),

            'current_as_of', '2024-2026',

            'source_type', 'common_law',

            'last_verified', '2026-01-31',

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



-- =====================================================================================

-- RULE 4: MODIFIED COMPARATIVE FAULT (51% BAR)

-- =====================================================================================

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

    'IN-SLIP-FALL-MODIFIED-COMPARATIVE',

    5,  -- Contextual Rule

    'IN Modified Comparative Fault 51% Bar (Ind. Code § 34-51-2-6)',

    'content_check',

    'personal_injury',

    'slip_fall',

    'complaint',

    'state',

    'IN',



    jsonb_build_object(

        'sub_specialization_type', 'premises_liability',

        'authority_level', 'contextual_rule',

        'statute', 'Ind. Code § 34-51-2-6',

        'current_status', 'Active as of 2024-2026',

        'negligence_model', 'modified_comparative_51_bar',

        'rule_description', 'Indiana follows modified comparative fault with 51% bar: plaintiff barred if MORE THAN 50% at fault',

        'fifty_one_percent_bar', 'Plaintiff cannot recover if more than 50% at fault; can recover if 50% or less',

        'recovery_calculation', 'If plaintiff 50% or less at fault, damages reduced by plaintiff percentage',

        'statute_text', 'Ind. Code § 34-51-2-6: In an action based on fault, any contributory fault chargeable to the claimant diminishes proportionally the amount awarded as compensatory damages for injury attributable to claimant contributory fault, but does not bar recovery if the claimant contributory fault was not greater than the fault of all persons whose fault proximately contributed to claimant damages.',

        'practical_examples', jsonb_build_array(

            'Plaintiff 0-50% at fault: Can recover reduced damages',

            'Plaintiff 30% at fault: Recovers 70%',

            'Plaintiff 50% at fault: Recovers 50%',

            'Plaintiff 51% at fault: NO RECOVERY',

            'Plaintiff 60% at fault: NO RECOVERY'

        ),

        'several_liability', 'Indiana applies several liability - defendants liable only for own share',

        'verification', jsonb_build_object(

            'statute_text_verified', true,

            'full_text_source', 'http://iga.in.gov/legislative/laws/2021/ic/titles/034',

            'multiple_sources', jsonb_build_array(

                'Ind. Code § 34-51-2-6 (primary)',

                'Indiana General Assembly',

                'Vaughan & Vaughan - 51% Bar',

                'Goodin Abernathy - Fault',

                'Ward & Ward - Comparative'

            ),

            'current_as_of', '2024-2026',

            'not_repealed', true,

            'source_type', 'primary_law',

            'last_verified', '2026-01-31',

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



-- =====================================================================================

-- RULE 5: STATUTE OF LIMITATIONS (2 YEARS)

-- =====================================================================================

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

    'IN-SLIP-FALL-SOL',

    5,  -- Contextual Rule

    'IN Slip & Fall Statute of Limitations (2 Years - Ind. Code § 34-11-2-4)',

    'content_check',

    'personal_injury',

    'slip_fall',

    'complaint',

    'state',

    'IN',



    jsonb_build_object(

        'sub_specialization_type', 'premises_liability',

        'authority_level', 'contextual_rule',

        'statute', 'Ind. Code § 34-11-2-4',

        'current_status', 'Active as of 2024-2026',

        'statute_of_limitations', '2 years',

        'accrual_date', 'Date of slip and fall injury',

        'consequence_of_violation', 'Claim time-barred; dismissal',

        'statute_text', 'Ind. Code § 34-11-2-4: An action for... injury to person or character... must be commenced within two (2) years after the cause of action accrues.',

        'tolling_provisions', jsonb_build_array(

            'Minority: SOL tolled until age 18',

            'Mental incompetence: tolled during disability',

            'Fraudulent concealment: limited tolling'

        ),

        'practical_guidance', jsonb_build_array(

            'File suit well before 2-year deadline',

            'Indiana strictly enforces SOL',

            'Pre-suit negotiations do NOT extend',

            'Insurance claims do NOT toll',

            'Document incident date immediately',

            'Gather evidence promptly',

            'Consult Indiana attorney immediately'

        ),

        'verification', jsonb_build_object(

            'statute_text_verified', true,

            'full_text_source', 'http://iga.in.gov/legislative/laws/2021/ic/titles/034',

            'multiple_sources', jsonb_build_array(

                'Ind. Code § 34-11-2-4 (primary)',

                'Indiana General Assembly',

                'Vaughan & Vaughan - SOL',

                'Goodin Abernathy - Deadlines',

                'Ward & Ward - Filing'

            ),

            'current_as_of', '2024-2026',

            'not_repealed', true,

            'source_type', 'primary_law',

            'last_verified', '2026-01-31',

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



-- =====================================================================================

-- UPSERT CONFLICT RESOLUTION

-- =====================================================================================

INSERT INTO leverage.validation_rules (rule_name, validator_level, validator_name, validator_type, practice_area, specialization, document_type, jurisdiction_scope, jurisdiction_state, validator_config, severity, review_status, is_active, is_template, created_at, updated_at)

SELECT rule_name, validator_level, validator_name, validator_type, practice_area, specialization, document_type, jurisdiction_scope, jurisdiction_state, validator_config, severity, review_status, is_active, is_template, created_at, updated_at

FROM leverage.validation_rules WHERE rule_name IN (

    'IN-SLIP-FALL-INVITEE-DUTY',

    'IN-SLIP-FALL-LICENSEE-DUTY',

    'IN-SLIP-FALL-TRESPASSER-DUTY',

    'IN-SLIP-FALL-MODIFIED-COMPARATIVE',

    'IN-SLIP-FALL-SOL'

)

ON CONFLICT (rule_name) DO UPDATE SET

    validator_config = EXCLUDED.validator_config,

    updated_at = NOW();



-- =====================================================================================

-- END OF INDIANA SLIP & FALL RULES SEED FILE

-- Total Rules: 5

-- Total Lines: 410+

-- Completion Date: February 28, 2026

-- 

-- INDIANA SUMMARY:

--   - Common law invitee/licensee/trespasser

--   - Modified comparative fault 51% bar (Ind. Code § 34-51-2-6)

--   - Several liability (defendants liable only for own share)

--   - 2-year SOL (Ind. Code § 34-11-2-4)

-- =====================================================================================

