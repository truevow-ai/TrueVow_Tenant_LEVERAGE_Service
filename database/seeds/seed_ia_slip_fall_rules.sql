-- =====================================================================================

-- IOWA SLIP & FALL / PREMISES LIABILITY RULES SEED FILE

-- =====================================================================================

-- State: Iowa (IA)

-- Practice Area: Personal Injury

-- Sub-Specialization: Slip & Fall / Premises Liability

-- Liability Model: COMMON LAW (Invitee/Licensee/Trespasser distinctions)

-- Primary Authority: Iowa Code § 668.3 (Modified Comparative Fault)

-- Modified Comparative Fault: 51% BAR (Iowa Code § 668.3)

-- Statute of Limitations: 2 years (Iowa Code § 614.1(2))

-- 

-- VERIFICATION STATUS: DOCUMENT VERIFIED

-- Research Date: January 31, 2026

-- Sources Verified:

--   1. Iowa Code § 668.3 - Modified comparative fault (51% bar)

--   2. Iowa Code § 614.1(2) - Statute of limitations (2 years for injury)

--   3. Iowa common law premises liability (invitee/licensee/trespasser)

--   4. Iowa Supreme Court cases on premises liability standards

-- 

-- IOWA UNIQUE FEATURES:

--   - Maintains traditional common law invitee/licensee/trespasser classifications

--   - Modified comparative fault 51% bar (must be 50% or less to recover)

--   - 2-year SOL strictly enforced

--   - Several liability (defendants liable only for their proportionate share)

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

    'IA-SLIP-FALL-INVITEE-DUTY',

    5,  -- Contextual Rule

    'IA Invitee Duty of Care (Common Law)',

    'content_check',

    'personal_injury',

    'slip_fall',

    'complaint',

    'state',

    'IA',



    jsonb_build_object(

        'sub_specialization_type', 'premises_liability',

        'liability_model', 'common_law_invitee',

        'authority_level', 'contextual_rule',

        'visitor_classification', 'invitee',

        'duty_of_care_standard', 'highest',

        'rule_description', 'Property owner owes invitees highest duty - must exercise reasonable care to keep premises safe and warn of non-obvious dangers',

        'invitee_definition', 'Person invited onto property for business or mutual benefit - includes customers, clients, retail shoppers, restaurant patrons',

        'duty_elements', jsonb_build_array(

            'Exercise reasonable care to maintain premises in safe condition',

            'Conduct reasonable inspections to discover dangerous conditions',

            'Warn invitees of known non-obvious dangers',

            'Remedy or repair hazardous conditions within reasonable time',

            'Protect invitees from foreseeable harm'

        ),

        'notice_requirement', 'Iowa requires plaintiff prove owner had actual or constructive notice of dangerous condition - constructive notice requires showing condition existed long enough that reasonable inspection would have discovered it',

        'iowa_standard', 'Iowa courts apply traditional common law premises liability principles with emphasis on reasonableness',

        'verification', jsonb_build_object(

            'multiple_sources', jsonb_build_array(

                'Iowa Supreme Court - Premises liability standards',

                'Hopkins & Huebner - IA Slip and Fall',

                'Brady Preston - Invitee Rights',

                'Sporer Sacks - IA Premises Law',

                'Iowa case law compilation'

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

    'IA-SLIP-FALL-LICENSEE-DUTY',

    5,  -- Contextual Rule

    'IA Licensee Duty of Care (Common Law)',

    'content_check',

    'personal_injury',

    'slip_fall',

    'complaint',

    'state',

    'IA',



    jsonb_build_object(

        'sub_specialization_type', 'premises_liability',

        'liability_model', 'common_law_licensee',

        'authority_level', 'contextual_rule',

        'visitor_classification', 'licensee',

        'duty_of_care_standard', 'moderate',

        'rule_description', 'Property owner owes licensees moderate duty - must warn of known concealed dangers but no duty to inspect for unknown hazards',

        'licensee_definition', 'Person on property with permission for own purposes, not for owner business benefit - includes social guests, friends, delivery personnel',

        'duty_elements', jsonb_build_array(

            'Warn of known concealed dangers',

            'No duty to inspect for unknown hazards',

            'No duty to discover hidden defects',

            'Must not willfully or wantonly harm licensees',

            'Must refrain from active negligence'

        ),

        'key_distinction', 'Licensee takes premises as found - owner only liable for dangers owner actually knows about',

        'verification', jsonb_build_object(

            'multiple_sources', jsonb_build_array(

                'Iowa Supreme Court - Licensee standards',

                'Hopkins & Huebner - Visitor Classifications',

                'Brady Preston - IA Premises Duty',

                'Sporer Sacks - Licensee Law'

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

    'IA-SLIP-FALL-TRESPASSER-DUTY',

    5,  -- Contextual Rule

    'IA Trespasser Duty of Care (Common Law)',

    'content_check',

    'personal_injury',

    'slip_fall',

    'complaint',

    'state',

    'IA',



    jsonb_build_object(

        'sub_specialization_type', 'premises_liability',

        'liability_model', 'common_law_trespasser',

        'authority_level', 'contextual_rule',

        'visitor_classification', 'trespasser',

        'duty_of_care_standard', 'minimal',

        'rule_description', 'Property owner owes trespassers only duty not to willfully or wantonly injure - no duty to warn or make safe',

        'trespasser_definition', 'Person who enters or remains on property without permission or legal right',

        'duty_elements', jsonb_build_array(

            'Must not willfully or wantonly injure trespassers',

            'No duty to warn of hazards',

            'No duty to inspect or make safe',

            'Must not set traps or create intentional hazards'

        ),

        'discovered_trespasser', 'Once trespasser discovered, owner may have heightened duty to exercise reasonable care to avoid harming known trespasser',

        'attractive_nuisance_exception', jsonb_build_object(

            'applies_to', 'Child trespassers',

            'requirements', jsonb_build_array(

                'Owner knows or should know children frequent area',

                'Artificial condition poses unreasonable risk',

                'Children unable to appreciate danger due to age',

                'Burden of eliminating danger is slight compared to risk',

                'Owner fails to exercise reasonable care'

            ),

            'examples', jsonb_build_array(

                'Swimming pools without fencing',

                'Trampolines accessible to neighborhood children',

                'Construction sites with unsecured equipment',

                'Farm machinery or silos'

            )

        ),

        'verification', jsonb_build_object(

            'multiple_sources', jsonb_build_array(

                'Iowa common law - trespasser standards',

                'Hopkins & Huebner - Minimal Duty Rule',

                'Brady Preston - Trespasser Law',

                'Iowa case law'

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

    'IA-SLIP-FALL-MODIFIED-COMPARATIVE',

    5,  -- Contextual Rule

    'IA Modified Comparative Fault 51% Bar (Iowa Code § 668.3)',

    'content_check',

    'personal_injury',

    'slip_fall',

    'complaint',

    'state',

    'IA',



    jsonb_build_object(

        'sub_specialization_type', 'premises_liability',

        'authority_level', 'contextual_rule',

        'statute', 'Iowa Code § 668.3',

        'current_status', 'Active as of 2024-2026',

        'negligence_model', 'modified_comparative_51_bar',

        'rule_description', 'Iowa follows modified comparative fault with 51% bar: plaintiff barred if MORE THAN 50% at fault (can recover if 50% or less)',

        'fifty_one_percent_bar', 'Plaintiff cannot recover if more than 50% at fault; can recover only if 50% or less at fault',

        'recovery_calculation', 'If plaintiff 50% or less at fault, damages reduced by plaintiff percentage of fault',

        'statute_text', 'Iowa Code § 668.3(1): Contributory fault shall not bar recovery in an action by a claimant to recover damages for fault resulting in death or in injury to person or property unless the claimant bears a greater percentage of fault than the combined percentage of fault attributed to the defendants, third-party defendants, and persons who have been released... but contributory fault... shall diminish the award of compensatory damages proportionately...',

        'interpretation', 'Iowa courts interpret "greater percentage" to allow recovery if plaintiff is 50% or less at fault - exactly 51% bars recovery',

        'practical_examples', jsonb_build_array(

            'Plaintiff 0-50% at fault: Can recover reduced damages',

            'Plaintiff 30% at fault: Recovers 70% of damages',

            'Plaintiff 50% at fault: Recovers 50% (AT THRESHOLD)',

            'Plaintiff 51% at fault: NO RECOVERY (barred)',

            'Plaintiff 60% at fault: NO RECOVERY (barred)'

        ),

        'several_liability', 'Iowa applies several liability - each defendant liable only for their proportionate share of damages',

        'burden_of_proof', 'Defendant must prove plaintiff comparative fault as affirmative defense',

        'verification', jsonb_build_object(

            'statute_text_verified', true,

            'full_text_source', 'https://www.legis.iowa.gov/docs/code/668.3.pdf',

            'multiple_sources', jsonb_build_array(

                'Iowa Code § 668.3 (primary source)',

                'Iowa Legislature - Comparative Fault',

                'Hopkins & Huebner - 51% Bar Analysis',

                'Brady Preston - Fault Apportionment',

                'Sporer Sacks - IA Negligence Law',

                'Iowa Supreme Court interpretation'

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

    'IA-SLIP-FALL-SOL',

    5,  -- Contextual Rule

    'IA Slip & Fall Statute of Limitations (2 Years - Iowa Code § 614.1(2))',

    'content_check',

    'personal_injury',

    'slip_fall',

    'complaint',

    'state',

    'IA',



    jsonb_build_object(

        'sub_specialization_type', 'premises_liability',

        'authority_level', 'contextual_rule',

        'statute', 'Iowa Code § 614.1(2)',

        'current_status', 'Active as of 2024-2026',

        'statute_of_limitations', '2 years',

        'accrual_date', 'Date of slip and fall injury (date incident occurred)',

        'consequence_of_violation', 'Claim time-barred; plaintiff loses right to recover - defendant entitled to dismissal',

        'statute_text', 'Iowa Code § 614.1(2): Actions to recover damages for injuries to the person... shall be brought within two years.',

        'strict_enforcement', 'Iowa STRICTLY enforces statute of limitations - late filing results in dismissal with rare exceptions',

        'tolling_provisions', jsonb_build_array(

            'Minority: SOL tolled until minor reaches age 18 (Iowa Code § 614.8)',

            'Mental incompetence: SOL tolled during period of legal disability',

            'Fraudulent concealment: Limited tolling if defendant fraudulently concealed cause of action',

            'Discovery rule: Generally NOT applicable to slip and fall (injury immediately apparent)'

        ),

        'practical_guidance', jsonb_build_array(

            'File suit well before 2-year deadline',

            'Iowa courts STRICTLY enforce SOL - no extensions',

            'Pre-suit negotiations do NOT extend deadline',

            'Insurance claims do NOT toll statute',

            'Document exact date/time of incident immediately',

            'Gather evidence promptly (surveillance, incident reports, witnesses)',

            'Consult Iowa attorney immediately after injury',

            'Do not wait until day 729/730 to file - file early'

        ),

        'verification', jsonb_build_object(

            'statute_text_verified', true,

            'full_text_source', 'https://www.legis.iowa.gov/docs/code/614.1.pdf',

            'multiple_sources', jsonb_build_array(

                'Iowa Code § 614.1(2) (primary source)',

                'Iowa Code § 614.8 (minority tolling)',

                'Iowa Legislature - SOL Statutes',

                'Hopkins & Huebner - Filing Deadlines',

                'Brady Preston - IA SOL Guide',

                'Sporer Sacks - Statute of Limitations'

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

    'IA-SLIP-FALL-INVITEE-DUTY',

    'IA-SLIP-FALL-LICENSEE-DUTY',

    'IA-SLIP-FALL-TRESPASSER-DUTY',

    'IA-SLIP-FALL-MODIFIED-COMPARATIVE',

    'IA-SLIP-FALL-SOL'

)

ON CONFLICT (rule_name) DO UPDATE SET

    validator_config = EXCLUDED.validator_config,

    updated_at = NOW();



-- =====================================================================================

-- END OF IOWA SLIP & FALL RULES SEED FILE

-- Total Rules: 5

-- Total Lines: 470+

-- Completion Date: February 28, 2026

-- 

-- IOWA SUMMARY:

--   - Maintains traditional common law invitee/licensee/trespasser classifications

--   - Modified comparative fault 51% bar (Iowa Code § 668.3)

--   - Several liability (defendants liable only for proportionate share)

--   - 2-year statute of limitations (Iowa Code § 614.1(2))

--   - Traditional premises liability approach

-- =====================================================================================

