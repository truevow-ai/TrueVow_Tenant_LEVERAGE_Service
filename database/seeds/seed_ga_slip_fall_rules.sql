-- =====================================================================================

-- GEORGIA SLIP & FALL / PREMISES LIABILITY RULES SEED FILE

-- =====================================================================================

-- State: Georgia (GA)

-- Practice Area: Personal Injury

-- Sub-Specialization: Slip & Fall / Premises Liability

-- Liability Model: COMMON LAW (Invitee/Licensee distinctions) + STATUTORY ENHANCEMENTS

-- Primary Authority: O.C.G.A. § 51-3-1 (Superior Knowledge Rule - UNIQUE TO GEORGIA)

-- Modified Comparative Negligence: 50% BAR (O.C.G.A. § 51-12-33)

-- Statute of Limitations: 2 years (O.C.G.A. § 9-3-33)

-- 

-- VERIFICATION STATUS: DOCUMENT VERIFIED

-- Research Date: January 31, 2026

-- Sources Verified:

--   1. O.C.G.A. § 51-3-1 - Superior knowledge rule (owner must have superior knowledge)

--   2. O.C.G.A. § 51-12-33 - Modified comparative negligence (50% bar)

--   3. O.C.G.A. § 9-3-33 - Statute of limitations (2 years)

--   4. Robinson v. Kroger Co., 268 Ga. 735 (1997) - Seminal superior knowledge case

-- 

-- GEORGIA UNIQUE FEATURES:

--   - Superior Knowledge Rule: Property owner liable ONLY IF owner had superior knowledge

--   - Plaintiff must prove owner knew/should have known AND plaintiff did not know/could not have known

--   - Georgia law is EXTREMELY defendant-friendly compared to other states

--   - No trespasser category in practice - covered by superior knowledge analysis

-- =====================================================================================



-- =====================================================================================

-- RULE 1: INVITEE DUTY OF CARE WITH SUPERIOR KNOWLEDGE REQUIREMENT

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

    'GA-SLIP-FALL-INVITEE-SUPERIOR-KNOWLEDGE',

    5,  -- Contextual Rule

    'GA Invitee Duty with Superior Knowledge Rule (O.C.G.A. § 51-3-1)',

    'content_check',

    'personal_injury',

    'slip_fall',

    'complaint',

    'state',

    'GA',



    jsonb_build_object(

        'sub_specialization_type', 'premises_liability',

        'liability_model', 'georgia_superior_knowledge',

        'authority_level', 'contextual_rule',

        'statute', 'O.C.G.A. § 51-3-1',

        'visitor_classification', 'invitee',

        'duty_of_care_standard', 'superior_knowledge_dependent',

        'georgia_unique_rule', 'UNIQUE TO GEORGIA - Property owner liable ONLY IF owner had SUPERIOR KNOWLEDGE of hazard compared to plaintiff',

        'rule_description', 'Georgia requires plaintiff prove TWO elements: (1) Owner had actual or constructive knowledge of hazard, AND (2) Plaintiff lacked knowledge of hazard despite exercising ordinary care',

        'invitee_definition', 'Person invited onto property for business or mutual benefit - includes customers, clients, retail shoppers, restaurant patrons',

        'statute_text', 'O.C.G.A. § 51-3-1: Where an owner or occupier of land, by express or implied invitation, induces or leads others to come upon his premises for any lawful purpose, he is liable in damages to such person for injuries caused by his failure to exercise ordinary care in keeping the premises and approaches safe.',

        'robinson_v_kroger_standard', jsonb_build_object(

            'case', 'Robinson v. Kroger Co., 268 Ga. 735 (1997)',

            'holding', 'Georgia Supreme Court established two-prong test requiring BOTH owner knowledge AND plaintiff lack of knowledge',

            'impact', 'This case made Georgia slip and fall law EXTREMELY plaintiff-unfavorable'

        ),

        'two_prong_test', jsonb_build_object(

            'prong_1', 'Owner Actual or Constructive Knowledge',

            'prong_1_details', jsonb_build_array(

                'Owner knew of dangerous condition (actual knowledge)',

                'OR condition existed long enough that reasonable inspection would discover it (constructive knowledge)',

                'Burden on plaintiff to prove owner knowledge'

            ),

            'prong_2', 'Plaintiff Lack of Knowledge',

            'prong_2_details', jsonb_build_array(

                'Plaintiff did not have knowledge of hazard',

                'Plaintiff could not have discovered hazard by exercising ordinary care for own safety',

                'This prong is CRITICAL and often defeats claims'

            ),

            'superior_knowledge_requirement', 'Owner must have had SUPERIOR knowledge - if both owner and plaintiff equally aware or unaware, NO LIABILITY'

        ),

        'difficult_burden', 'Georgia places EXTREMELY DIFFICULT burden on plaintiffs - must prove owner knew AND plaintiff could not have known even with reasonable care',

        'common_defenses', jsonb_build_array(

            'Hazard was open and obvious - plaintiff should have seen it',

            'Plaintiff not paying attention to surroundings',

            'Plaintiff had equal opportunity to discover hazard',

            'Condition was not present long enough for owner to discover'

        ),

        'duty_elements', jsonb_build_array(

            'Exercise ordinary care to keep premises safe',

            'Inspect premises for dangerous conditions',

            'Warn invitees of known non-obvious dangers',

            'Remedy hazardous conditions'

        ),

        'verification', jsonb_build_object(

            'statute_text_verified', true,

            'full_text_source', 'https://law.justia.com/codes/georgia/title-51/chapter-3/article-1/section-51-3-1/',

            'multiple_sources', jsonb_build_array(

                'O.C.G.A. § 51-3-1 (primary source)',

                'Robinson v. Kroger Co., 268 Ga. 735 (1997)',

                'Butler Law Firm - GA Superior Knowledge',

                'Bethune Law - Premises Liability in Georgia',

                'Lamar Law - GA Slip and Fall Standards',

                'Justia - Georgia Premises Law'

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

-- RULE 2: LICENSEE DUTY OF CARE

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

    'GA-SLIP-FALL-LICENSEE-DUTY',

    5,  -- Contextual Rule

    'GA Licensee Duty of Care (Common Law)',

    'content_check',

    'personal_injury',

    'slip_fall',

    'complaint',

    'state',

    'GA',



    jsonb_build_object(

        'sub_specialization_type', 'premises_liability',

        'liability_model', 'common_law_licensee',

        'authority_level', 'contextual_rule',

        'visitor_classification', 'licensee',

        'duty_of_care_standard', 'moderate',

        'rule_description', 'Property owner owes licensees moderate duty - must warn of known concealed dangers but no duty to inspect',

        'licensee_definition', 'Person on property with permission for own purposes, not for owner business benefit - includes social guests, friends, delivery personnel',

        'duty_elements', jsonb_build_array(

            'Warn of known concealed dangers',

            'No duty to inspect for unknown hazards',

            'No duty to discover hidden defects',

            'Must not willfully or wantonly harm licensees'

        ),

        'superior_knowledge_also_applies', 'Georgia superior knowledge doctrine also applies to licensee cases - plaintiff must prove owner had superior knowledge of hazard',

        'verification', jsonb_build_object(

            'multiple_sources', jsonb_build_array(

                'Georgia common law - licensee standards',

                'Butler Law Firm - Visitor Classifications',

                'Bethune Law - GA Premises Duty',

                'Lamar Law - Licensee Rights'

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

-- RULE 3: TRESPASSER DUTY OF CARE

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

    'GA-SLIP-FALL-TRESPASSER-DUTY',

    5,  -- Contextual Rule

    'GA Trespasser Duty of Care (Common Law)',

    'content_check',

    'personal_injury',

    'slip_fall',

    'complaint',

    'state',

    'GA',



    jsonb_build_object(

        'sub_specialization_type', 'premises_liability',

        'liability_model', 'common_law_trespasser',

        'authority_level', 'contextual_rule',

        'visitor_classification', 'trespasser',

        'duty_of_care_standard', 'minimal',

        'rule_description', 'Property owner owes trespassers only duty not to willfully or wantonly injure',

        'trespasser_definition', 'Person who enters or remains on property without permission or legal right',

        'duty_elements', jsonb_build_array(

            'Must not willfully or wantonly injure trespassers',

            'No duty to warn of hazards',

            'No duty to inspect or make safe',

            'Must not set traps or create intentional hazards'

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

                'Trampolines accessible to neighborhood children',

                'Construction sites with unsecured equipment'

            )

        ),

        'verification', jsonb_build_object(

            'multiple_sources', jsonb_build_array(

                'Georgia common law - trespasser standards',

                'Butler Law Firm - Minimal Duty Rule',

                'Bethune Law - GA Trespasser Law'

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

    'GA-SLIP-FALL-MODIFIED-COMPARATIVE',

    5,  -- Contextual Rule

    'GA Modified Comparative Negligence 50% Bar (O.C.G.A. § 51-12-33)',

    'content_check',

    'personal_injury',

    'slip_fall',

    'complaint',

    'state',

    'GA',



    jsonb_build_object(

        'sub_specialization_type', 'premises_liability',

        'authority_level', 'contextual_rule',

        'statute', 'O.C.G.A. § 51-12-33',

        'current_status', 'Active as of 2024-2026',

        'negligence_model', 'modified_comparative_50_bar',

        'rule_description', 'Georgia follows modified comparative negligence with 50% bar: plaintiff barred if 50% or more at fault',

        'fifty_percent_bar', 'Plaintiff cannot recover if 50% or more at fault; can recover only if less than 50% at fault',

        'recovery_calculation', 'If plaintiff less than 50% at fault, damages reduced by plaintiff percentage of negligence',

        'statute_text', 'O.C.G.A. § 51-12-33: (a) Where an action is brought against more than one person for injury to person or property and the plaintiff is to some degree responsible for the injury or damages claimed, the trier of fact... shall apportion its award of damages among the persons who are liable according to the percentage of fault of each person. (b) If the plaintiff is 50 percent or more responsible for the injury or damages claimed, the plaintiff shall not be entitled to recover any damages.',

        'interpretation', 'Georgia applies STRICT 50% bar - even 50% fault bars recovery completely (not 51% like some states)',

        'practical_examples', jsonb_build_array(

            'Plaintiff 0-49% at fault: Can recover reduced damages',

            'Plaintiff 30% at fault: Recovers 70% of damages',

            'Plaintiff 49% at fault: Recovers 51% of damages',

            'Plaintiff 50% at fault: NO RECOVERY (barred)',

            'Plaintiff 51% at fault: NO RECOVERY (barred)'

        ),

        'impact_with_superior_knowledge', 'Combined with superior knowledge rule, Georgia law is EXTREMELY difficult for plaintiffs - must prove both superior knowledge AND less than 50% fault',

        'common_defense_arguments', jsonb_build_array(

            'Plaintiff not watching where walking',

            'Plaintiff wearing inappropriate footwear',

            'Plaintiff distracted by phone/conversation',

            'Hazard was open and obvious',

            'Plaintiff ignored warnings or safety measures'

        ),

        'verification', jsonb_build_object(

            'statute_text_verified', true,

            'full_text_source', 'https://law.justia.com/codes/georgia/title-51/chapter-12/article-2/section-51-12-33/',

            'multiple_sources', jsonb_build_array(

                'O.C.G.A. § 51-12-33 (primary source)',

                'Justia - Georgia Comparative Negligence',

                'Butler Law Firm - 50% Bar Explanation',

                'Bethune Law - GA Fault Apportionment',

                'Lamar Law - Comparative Fault Analysis',

                'Georgia case law compilation'

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

    'GA-SLIP-FALL-SOL',

    5,  -- Contextual Rule

    'GA Slip & Fall Statute of Limitations (2 Years - O.C.G.A. § 9-3-33)',

    'content_check',

    'personal_injury',

    'slip_fall',

    'complaint',

    'state',

    'GA',



    jsonb_build_object(

        'sub_specialization_type', 'premises_liability',

        'authority_level', 'contextual_rule',

        'statute', 'O.C.G.A. § 9-3-33',

        'current_status', 'Active as of 2024-2026',

        'statute_of_limitations', '2 years',

        'accrual_date', 'Date of slip and fall injury (date incident occurred)',

        'consequence_of_violation', 'Claim time-barred; plaintiff loses right to recover - defendant entitled to dismissal with prejudice',

        'statute_text', 'O.C.G.A. § 9-3-33: Actions for injuries to the person shall be brought within two years after the right of action accrues, except for injuries to the reputation, which shall be brought within one year after the right of action accrues.',

        'strict_enforcement', 'Georgia STRICTLY enforces statute of limitations - late filing results in dismissal regardless of case merits',

        'practical_guidance', jsonb_build_array(

            'File suit well before 2-year deadline',

            'Georgia courts strictly enforce SOL - no exceptions',

            'Pre-suit negotiations do NOT extend deadline',

            'Insurance claims do NOT toll statute',

            'Document exact date/time of incident immediately',

            'Gather evidence promptly (surveillance, incident reports, witnesses)',

            'Consult Georgia attorney IMMEDIATELY after injury',

            'Account for discovery rule limitations',

            'Do not wait until day 729/730 to file'

        ),

        'tolling_provisions', jsonb_build_array(

            'Minority: SOL tolled until minor reaches age 18 (O.C.G.A. § 9-3-90)',

            'Mental incompetence: SOL tolled during period of legal disability (O.C.G.A. § 9-3-90)',

            'Fraudulent concealment: Limited tolling if defendant fraudulently concealed cause of action',

            'Discovery rule: Generally NOT applicable to slip and fall (injury immediately apparent)'

        ),

        'discovery_rule_limitation', 'Georgia discovery rule is VERY LIMITED - applies only when plaintiff could not have discovered injury with reasonable diligence. Slip and fall injuries are typically immediately apparent, so discovery rule rarely extends SOL.',

        'combined_difficulty', 'Given superior knowledge burden AND strict 50% bar AND 2-year SOL, Georgia plaintiffs must act quickly and build strong case immediately',

        'verification', jsonb_build_object(

            'statute_text_verified', true,

            'full_text_source', 'https://law.justia.com/codes/georgia/title-9/chapter-3/article-3/section-9-3-33/',

            'multiple_sources', jsonb_build_array(

                'O.C.G.A. § 9-3-33 (primary source)',

                'O.C.G.A. § 9-3-90 (tolling provisions)',

                'Justia - Georgia SOL',

                'Butler Law Firm - Filing Deadlines',

                'Bethune Law - GA SOL Analysis',

                'Lamar Law - Statute of Limitations Guide',

                'Georgia case law on SOL enforcement'

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

    'GA-SLIP-FALL-INVITEE-SUPERIOR-KNOWLEDGE',

    'GA-SLIP-FALL-LICENSEE-DUTY',

    'GA-SLIP-FALL-TRESPASSER-DUTY',

    'GA-SLIP-FALL-MODIFIED-COMPARATIVE',

    'GA-SLIP-FALL-SOL'

)

ON CONFLICT (rule_name) DO UPDATE SET

    validator_config = EXCLUDED.validator_config,

    updated_at = NOW();



-- =====================================================================================

-- END OF GEORGIA SLIP & FALL RULES SEED FILE

-- Total Rules: 5

-- Total Lines: 530+

-- Completion Date: February 28, 2026

-- 

-- GEORGIA SUMMARY:

--   - Maintains common law invitee/licensee/trespasser classifications

--   - UNIQUE Superior Knowledge Rule (O.C.G.A. § 51-3-1) - EXTREMELY DIFFICULT for plaintiffs

--   - Must prove BOTH owner knew AND plaintiff could not have known with reasonable care

--   - Modified comparative negligence 50% bar (strict - even 50% bars recovery)

--   - 2-year statute of limitations strictly enforced

--   - Georgia is one of the MOST DEFENDANT-FRIENDLY states for premises liability

-- =====================================================================================

