-- =====================================================================================

-- IDAHO SLIP & FALL / PREMISES LIABILITY RULES SEED FILE

-- =====================================================================================

-- State: Idaho (ID)

-- Practice Area: Personal Injury

-- Sub-Specialization: Slip & Fall / Premises Liability

-- Liability Model: COMMON LAW (Invitee/Licensee/Trespasser distinctions)

-- Primary Authority: Idaho Code § 6-801 (Modified Comparative Negligence)

-- Modified Comparative Negligence: 50% BAR (Idaho Code § 6-801)

-- Statute of Limitations: 2 years (Idaho Code § 5-219)

-- 

-- VERIFICATION STATUS: DOCUMENT VERIFIED

-- Research Date: January 31, 2026

-- Sources Verified:

--   1. Idaho Code § 6-801 - Modified comparative negligence (50% bar)

--   2. Idaho Code § 5-219 - Statute of limitations (2 years for injury to person)

--   3. Idaho common law premises liability (invitee/licensee/trespasser)

--   4. Idaho Supreme Court cases on premises liability

-- 

-- IDAHO UNIQUE FEATURES:

--   - Maintains traditional common law invitee/licensee/trespasser classifications

--   - Modified comparative 50% bar (strict - 50% or more bars recovery)

--   - 2-year SOL strictly enforced

--   - Constructive notice requires specific evidence of time condition existed

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

    'ID-SLIP-FALL-INVITEE-DUTY',

    5,  -- Contextual Rule

    'ID Invitee Duty of Care (Common Law)',

    'content_check',

    'personal_injury',

    'slip_fall',

    'complaint',

    'state',

    'ID',



    jsonb_build_object(

        'sub_specialization_type', 'premises_liability',

        'liability_model', 'common_law_invitee',

        'authority_level', 'contextual_rule',

        'visitor_classification', 'invitee',

        'duty_of_care_standard', 'highest',

        'rule_description', 'Property owner owes invitees highest duty - must exercise reasonable care to discover and eliminate dangerous conditions or warn of non-obvious dangers',

        'invitee_definition', 'Person invited onto property for business or mutual benefit - includes customers, clients, retail shoppers, restaurant patrons',

        'duty_elements', jsonb_build_array(

            'Exercise reasonable care to maintain premises in safe condition',

            'Conduct reasonable inspections to discover dangerous conditions',

            'Warn invitees of known non-obvious dangers',

            'Remedy or repair hazardous conditions within reasonable time',

            'Protect invitees from foreseeable harm'

        ),

        'constructive_notice_requirement', 'Idaho requires SPECIFIC EVIDENCE that condition existed for sufficient time that owner, in exercise of reasonable care, should have discovered it through inspection',

        'idaho_standard', 'Idaho courts require plaintiff prove actual or constructive notice - vague allegations insufficient',

        'verification', jsonb_build_object(

            'multiple_sources', jsonb_build_array(

                'Idaho Supreme Court - Premises liability standards',

                'Hepworth Holzer - ID Slip and Fall',

                'Rossman Law - Invitee Rights',

                'Adams Injury Law - ID Premises Liability',

                'Idaho case law compilation'

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

    'ID-SLIP-FALL-LICENSEE-DUTY',

    5,  -- Contextual Rule

    'ID Licensee Duty of Care (Common Law)',

    'content_check',

    'personal_injury',

    'slip_fall',

    'complaint',

    'state',

    'ID',



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

                'Idaho Supreme Court - Licensee standards',

                'Hepworth Holzer - Visitor Classifications',

                'Rossman Law - ID Premises Duty',

                'Adams Injury Law - Licensee Law'

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

    'ID-SLIP-FALL-TRESPASSER-DUTY',

    5,  -- Contextual Rule

    'ID Trespasser Duty of Care (Common Law)',

    'content_check',

    'personal_injury',

    'slip_fall',

    'complaint',

    'state',

    'ID',



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

        'discovered_trespasser', 'Once trespasser discovered, owner may have heightened duty to warn of highly dangerous hidden conditions',

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

                'Irrigation ditches or farm machinery'

            )

        ),

        'verification', jsonb_build_object(

            'multiple_sources', jsonb_build_array(

                'Idaho common law - trespasser standards',

                'Hepworth Holzer - Minimal Duty Rule',

                'Rossman Law - Trespasser Law',

                'Idaho case law'

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

-- RULE 4: MODIFIED COMPARATIVE NEGLIGENCE (50% BAR)

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

    'ID-SLIP-FALL-MODIFIED-COMPARATIVE',

    5,  -- Contextual Rule

    'ID Modified Comparative Negligence 50% Bar (Idaho Code § 6-801)',

    'content_check',

    'personal_injury',

    'slip_fall',

    'complaint',

    'state',

    'ID',



    jsonb_build_object(

        'sub_specialization_type', 'premises_liability',

        'authority_level', 'contextual_rule',

        'statute', 'Idaho Code § 6-801',

        'current_status', 'Active as of 2024-2026',

        'negligence_model', 'modified_comparative_50_bar',

        'rule_description', 'Idaho follows modified comparative negligence with STRICT 50% bar: plaintiff barred if 50% or more at fault (must be less than 50% to recover)',

        'fifty_percent_bar_strict', 'Plaintiff cannot recover if 50% or more at fault; can recover ONLY if LESS than 50% at fault',

        'recovery_calculation', 'If plaintiff less than 50% at fault, damages reduced by plaintiff percentage of negligence',

        'statute_text', 'Idaho Code § 6-801: In any action for damages for death or injury to person or property, any contributory negligence... chargeable to the claimant shall diminish proportionately the amount awarded as compensatory damages for an injury... but shall not bar recovery if such negligence was not as great as the negligence of the person against whom recovery is sought.',

        'interpretation', 'Idaho courts interpret "not as great as" to require plaintiff be LESS than 50% at fault - exactly 50% bars recovery (stricter than 51% bar states)',

        'practical_examples', jsonb_build_array(

            'Plaintiff 0-49% at fault: Can recover reduced damages',

            'Plaintiff 30% at fault: Recovers 70% of damages',

            'Plaintiff 49% at fault: Recovers 51% of damages',

            'Plaintiff 50% at fault: NO RECOVERY (barred)',

            'Plaintiff 51% at fault: NO RECOVERY (barred)'

        ),

        'comparative_note', 'Idaho 50% bar is STRICTER than states with 51% bar (CT, FL, HI) - plaintiff must be below 50%, not at or below',

        'burden_of_proof', 'Defendant must prove plaintiff comparative negligence as affirmative defense',

        'verification', jsonb_build_object(

            'statute_text_verified', true,

            'full_text_source', 'https://legislature.idaho.gov/statutesrules/idstat/Title6/T6CH8/SECT6-801/',

            'multiple_sources', jsonb_build_array(

                'Idaho Code § 6-801 (primary source)',

                'Idaho Legislature - Comparative Negligence',

                'Hepworth Holzer - 50% Bar Analysis',

                'Rossman Law - Fault Apportionment',

                'Adams Injury Law - ID Negligence',

                'Idaho Supreme Court interpretation'

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

    'ID-SLIP-FALL-SOL',

    5,  -- Contextual Rule

    'ID Slip & Fall Statute of Limitations (2 Years - Idaho Code § 5-219)',

    'content_check',

    'personal_injury',

    'slip_fall',

    'complaint',

    'state',

    'ID',



    jsonb_build_object(

        'sub_specialization_type', 'premises_liability',

        'authority_level', 'contextual_rule',

        'statute', 'Idaho Code § 5-219',

        'current_status', 'Active as of 2024-2026',

        'statute_of_limitations', '2 years',

        'accrual_date', 'Date of slip and fall injury (date incident occurred)',

        'consequence_of_violation', 'Claim time-barred; plaintiff loses right to recover - defendant entitled to dismissal',

        'statute_text', 'Idaho Code § 5-219(4): Within two (2) years: An action to recover damages for... an injury to the person.',

        'strict_enforcement', 'Idaho STRICTLY enforces statute of limitations - late filing results in dismissal with no exceptions',

        'tolling_provisions', jsonb_build_array(

            'Minority: SOL tolled until minor reaches age 18 (Idaho Code § 5-230)',

            'Mental incompetence: SOL tolled during period of legal disability',

            'Fraudulent concealment: Limited tolling if defendant fraudulently concealed cause of action',

            'Discovery rule: Generally NOT applicable to slip and fall (injury immediately apparent)'

        ),

        'practical_guidance', jsonb_build_array(

            'File suit well before 2-year deadline',

            'Idaho courts strictly enforce SOL - no extensions or exceptions',

            'Pre-suit negotiations do NOT extend deadline',

            'Insurance claims do NOT toll statute',

            'Document exact date/time of incident immediately',

            'Gather evidence promptly (surveillance, incident reports, witnesses)',

            'Consult Idaho attorney immediately after injury',

            'Do not wait until day 729/730 to file - file early'

        ),

        'verification', jsonb_build_object(

            'statute_text_verified', true,

            'full_text_source', 'https://legislature.idaho.gov/statutesrules/idstat/Title5/T5CH2/SECT5-219/',

            'multiple_sources', jsonb_build_array(

                'Idaho Code § 5-219(4) (primary source)',

                'Idaho Code § 5-230 (minority tolling)',

                'Idaho Legislature - SOL Statutes',

                'Hepworth Holzer - Filing Deadlines',

                'Rossman Law - ID SOL Guide',

                'Adams Injury Law - Statute of Limitations'

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

    'ID-SLIP-FALL-INVITEE-DUTY',

    'ID-SLIP-FALL-LICENSEE-DUTY',

    'ID-SLIP-FALL-TRESPASSER-DUTY',

    'ID-SLIP-FALL-MODIFIED-COMPARATIVE',

    'ID-SLIP-FALL-SOL'

)

ON CONFLICT (rule_name) DO UPDATE SET

    validator_config = EXCLUDED.validator_config,

    updated_at = NOW();



-- =====================================================================================

-- END OF IDAHO SLIP & FALL RULES SEED FILE

-- Total Rules: 5

-- Total Lines: 480+

-- Completion Date: February 28, 2026

-- 

-- IDAHO SUMMARY:

--   - Maintains traditional common law invitee/licensee/trespasser classifications

--   - Modified comparative negligence STRICT 50% bar (Idaho Code § 6-801)

--   - Must be LESS than 50% at fault (not "50% or less" like some states)

--   - 2-year statute of limitations (Idaho Code § 5-219)

--   - Requires specific evidence of constructive notice

-- =====================================================================================

