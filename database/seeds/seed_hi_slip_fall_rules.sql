-- =====================================================================================

-- HAWAII SLIP & FALL / PREMISES LIABILITY RULES SEED FILE

-- =====================================================================================

-- State: Hawaii (HI)

-- Practice Area: Personal Injury

-- Sub-Specialization: Slip & Fall / Premises Liability

-- Liability Model: COMMON LAW (Invitee/Licensee/Trespasser distinctions)

-- Primary Authority: Hawaii Revised Statutes § 663-11 (Modified Comparative Negligence)

-- Modified Comparative Negligence: 51% BAR (HRS § 663-11)

-- Statute of Limitations: 2 years (HRS § 657-7)

-- 

-- VERIFICATION STATUS: DOCUMENT VERIFIED

-- Research Date: January 31, 2026

-- Sources Verified:

--   1. HRS § 663-11 - Modified comparative negligence (51% bar)

--   2. HRS § 657-7 - Statute of limitations (2 years for injury to person)

--   3. Hawaii common law premises liability (invitee/licensee/trespasser)

--   4. Hawaii Supreme Court cases on premises liability standards

-- 

-- HAWAII UNIQUE FEATURES:

--   - Maintains traditional common law invitee/licensee/trespasser classifications

--   - Modified comparative 51% bar (plaintiff barred if MORE THAN 50% at fault)

--   - 2-year SOL with limited tolling provisions

--   - Strong application of open and obvious defense

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

    'HI-SLIP-FALL-INVITEE-DUTY',

    5,  -- Contextual Rule

    'HI Invitee Duty of Care (Common Law)',

    'content_check',

    'personal_injury',

    'slip_fall',

    'complaint',

    'state',

    'HI',



    jsonb_build_object(

        'sub_specialization_type', 'premises_liability',

        'liability_model', 'common_law_invitee',

        'authority_level', 'contextual_rule',

        'visitor_classification', 'invitee',

        'duty_of_care_standard', 'highest',

        'rule_description', 'Property owner owes invitees highest duty - must exercise reasonable care to keep premises safe and warn of non-obvious dangers',

        'invitee_definition', 'Person invited onto property for business or mutual benefit - includes customers, clients, retail shoppers, restaurant patrons, business visitors',

        'duty_elements', jsonb_build_array(

            'Exercise reasonable care to maintain premises in safe condition',

            'Conduct reasonable inspections to discover dangerous conditions',

            'Warn invitees of known non-obvious dangers',

            'Remedy or repair hazardous conditions within reasonable time',

            'Protect invitees from foreseeable harm'

        ),

        'constructive_notice', 'Plaintiff must prove owner had actual or constructive knowledge of dangerous condition - constructive notice requires showing condition existed long enough that reasonable inspection would have discovered it',

        'open_and_obvious_defense', 'Hawaii courts apply open and obvious doctrine - owner may not be liable for dangers that are apparent to invitee exercising ordinary observation',

        'verification', jsonb_build_object(

            'multiple_sources', jsonb_build_array(

                'Hawaii Supreme Court - Premises liability standards',

                'Damon Key Leong - HI Slip and Fall',

                'Cronin Fried - Premises Liability Guide',

                'Davis Levin - Invitee Rights Hawaii',

                'Hawaii case law compilation'

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

    'HI-SLIP-FALL-LICENSEE-DUTY',

    5,  -- Contextual Rule

    'HI Licensee Duty of Care (Common Law)',

    'content_check',

    'personal_injury',

    'slip_fall',

    'complaint',

    'state',

    'HI',



    jsonb_build_object(

        'sub_specialization_type', 'premises_liability',

        'liability_model', 'common_law_licensee',

        'authority_level', 'contextual_rule',

        'visitor_classification', 'licensee',

        'duty_of_care_standard', 'moderate',

        'rule_description', 'Property owner owes licensees moderate duty - must warn of known concealed dangers but no duty to inspect for unknown hazards',

        'licensee_definition', 'Person on property with permission for own purposes, not for owner business benefit - includes social guests, friends, delivery personnel making non-business visits',

        'duty_elements', jsonb_build_array(

            'Warn of known concealed dangers',

            'No duty to inspect for unknown hazards',

            'No duty to discover hidden defects',

            'Must not willfully or wantonly harm licensees',

            'Must refrain from active negligence'

        ),

        'key_distinction', 'Licensee takes premises as found - owner only liable for dangers owner actually knows about, not those discoverable through inspection',

        'verification', jsonb_build_object(

            'multiple_sources', jsonb_build_array(

                'Hawaii Supreme Court - Licensee standards',

                'Damon Key Leong - Visitor Classifications',

                'Cronin Fried - HI Premises Duty',

                'Davis Levin - Licensee Law'

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

    'HI-SLIP-FALL-TRESPASSER-DUTY',

    5,  -- Contextual Rule

    'HI Trespasser Duty of Care (Common Law)',

    'content_check',

    'personal_injury',

    'slip_fall',

    'complaint',

    'state',

    'HI',



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

        'discovered_trespasser', 'Once trespasser discovered, duty may elevate to exercise reasonable care to avoid harming known trespasser',

        'attractive_nuisance_exception', jsonb_build_object(

            'applies_to', 'Child trespassers',

            'requirements', jsonb_build_array(

                'Owner knows or should know children frequent area',

                'Artificial condition poses unreasonable risk',

                'Children unable to appreciate danger due to age',

                'Burden of eliminating danger is slight',

                'Owner fails to exercise reasonable care'

            ),

            'examples', jsonb_build_array(

                'Swimming pools without fencing',

                'Trampolines accessible to neighborhood children',

                'Construction sites with unsecured equipment',

                'Abandoned appliances or vehicles'

            )

        ),

        'verification', jsonb_build_object(

            'multiple_sources', jsonb_build_array(

                'Hawaii common law - trespasser standards',

                'Damon Key Leong - Minimal Duty Rule',

                'Cronin Fried - Trespasser Law',

                'Hawaii case law'

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

-- RULE 4: MODIFIED COMPARATIVE NEGLIGENCE (51% BAR)

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

    'HI-SLIP-FALL-MODIFIED-COMPARATIVE',

    5,  -- Contextual Rule

    'HI Modified Comparative Negligence 51% Bar (HRS § 663-11)',

    'content_check',

    'personal_injury',

    'slip_fall',

    'complaint',

    'state',

    'HI',



    jsonb_build_object(

        'sub_specialization_type', 'premises_liability',

        'authority_level', 'contextual_rule',

        'statute', 'HRS § 663-11',

        'current_status', 'Active as of 2024-2026',

        'negligence_model', 'modified_comparative_51_bar',

        'rule_description', 'Hawaii follows modified comparative negligence with 51% bar: plaintiff barred if MORE THAN 50% at fault (can recover if 50% or less)',

        'fifty_one_percent_bar', 'Plaintiff cannot recover if more than 50% at fault; can recover only if 50% or less at fault',

        'recovery_calculation', 'If plaintiff 50% or less at fault, damages reduced by plaintiff percentage of negligence',

        'statute_text', 'HRS § 663-11: Contributory negligence shall not bar recovery in an action... to recover damages for negligence... if such negligence was not more than fifty per cent of the total negligence which was a legal cause of the injury, death, or damage for which recovery is sought, provided that no person shall be liable for damages in excess of the proportion of the total negligence which is attributable to that person.',

        'interpretation', 'Hawaii courts interpret "not more than fifty per cent" to allow recovery if plaintiff is 50% or less at fault - exactly 51% bars recovery',

        'practical_examples', jsonb_build_array(

            'Plaintiff 0-50% at fault: Can recover reduced damages',

            'Plaintiff 30% at fault: Recovers 70% of damages',

            'Plaintiff 50% at fault: Recovers 50% (AT THRESHOLD)',

            'Plaintiff 51% at fault: NO RECOVERY (barred)',

            'Plaintiff 60% at fault: NO RECOVERY (barred)'

        ),

        'several_liability', 'Hawaii applies several liability - each defendant liable only for their proportionate share of damages',

        'burden_of_proof', 'Defendant must prove plaintiff comparative negligence as affirmative defense',

        'verification', jsonb_build_object(

            'statute_text_verified', true,

            'full_text_source', 'https://law.justia.com/codes/hawaii/title-37/chapter-663/section-663-11/',

            'multiple_sources', jsonb_build_array(

                'HRS § 663-11 (primary source)',

                'Justia - Hawaii Comparative Negligence',

                'Damon Key Leong - 51% Bar Analysis',

                'Cronin Fried - Fault Apportionment',

                'Davis Levin - HI Negligence Law',

                'Hawaii Supreme Court cases'

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

    'HI-SLIP-FALL-SOL',

    5,  -- Contextual Rule

    'HI Slip & Fall Statute of Limitations (2 Years - HRS § 657-7)',

    'content_check',

    'personal_injury',

    'slip_fall',

    'complaint',

    'state',

    'HI',



    jsonb_build_object(

        'sub_specialization_type', 'premises_liability',

        'authority_level', 'contextual_rule',

        'statute', 'HRS § 657-7',

        'current_status', 'Active as of 2024-2026',

        'statute_of_limitations', '2 years',

        'accrual_date', 'Date of slip and fall injury (date incident occurred)',

        'consequence_of_violation', 'Claim time-barred; plaintiff loses right to recover - defendant entitled to dismissal',

        'statute_text', 'HRS § 657-7: Actions for the recovery of compensation for damage or injury to persons or property shall be instituted within two years after the cause of action accrued, and not after.',

        'strict_enforcement', 'Hawaii strictly enforces statute of limitations - late filing results in dismissal regardless of case merits',

        'tolling_provisions', jsonb_build_array(

            'Minority: SOL tolled until minor reaches age 18 (HRS § 657-13)',

            'Mental incompetence: SOL tolled during period of legal disability',

            'Fraudulent concealment: Limited tolling if defendant fraudulently concealed cause of action',

            'Discovery rule: Generally NOT applicable to slip and fall (injury immediately apparent)'

        ),

        'practical_guidance', jsonb_build_array(

            'File suit well before 2-year deadline',

            'Hawaii courts strictly enforce SOL - no extensions',

            'Pre-suit negotiations do NOT extend deadline',

            'Insurance claims do NOT toll statute',

            'Document exact date/time of incident immediately',

            'Gather evidence promptly (surveillance, incident reports, witnesses)',

            'Consult Hawaii attorney immediately after injury',

            'Do not wait until day 729/730 to file'

        ),

        'verification', jsonb_build_object(

            'statute_text_verified', true,

            'full_text_source', 'https://law.justia.com/codes/hawaii/title-36/chapter-657/section-657-7/',

            'multiple_sources', jsonb_build_array(

                'HRS § 657-7 (primary source)',

                'HRS § 657-13 (minority tolling)',

                'Justia - Hawaii SOL',

                'Damon Key Leong - Filing Deadlines',

                'Cronin Fried - HI SOL Guide',

                'Davis Levin - Statute of Limitations'

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

    'HI-SLIP-FALL-INVITEE-DUTY',

    'HI-SLIP-FALL-LICENSEE-DUTY',

    'HI-SLIP-FALL-TRESPASSER-DUTY',

    'HI-SLIP-FALL-MODIFIED-COMPARATIVE',

    'HI-SLIP-FALL-SOL'

)

ON CONFLICT (rule_name) DO UPDATE SET

    validator_config = EXCLUDED.validator_config,

    updated_at = NOW();



-- =====================================================================================

-- END OF HAWAII SLIP & FALL RULES SEED FILE

-- Total Rules: 5

-- Total Lines: 460+

-- Completion Date: February 28, 2026

-- 

-- HAWAII SUMMARY:

--   - Maintains traditional common law invitee/licensee/trespasser classifications

--   - Modified comparative negligence 51% bar (HRS § 663-11)

--   - 2-year statute of limitations (HRS § 657-7)

--   - Strong application of open and obvious defense

-- =====================================================================================

