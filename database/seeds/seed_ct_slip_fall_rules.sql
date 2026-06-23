-- =====================================================================================
-- CONNECTICUT SLIP & FALL / PREMISES LIABILITY RULES SEED FILE
-- =====================================================================================
-- State: Connecticut (CT)
-- Practice Area: Personal Injury
-- Sub-Specialization: Slip & Fall / Premises Liability
-- Liability Model: COMMON LAW (Invitee/Licensee/Trespasser - CGS § 52-557a)
-- Primary Authority: CGS § 52-557a (Premises Liability Duty of Care)
-- Modified Comparative Negligence: 51% BAR (CGS § 52-572h)
-- Statute of Limitations: 2 years (CGS § 52-584)
-- 
-- VERIFICATION STATUS: DOCUMENT VERIFIED
-- Research Date: January 31, 2026
-- Sources Verified:
--   1. CGS § 52-557a - Standard of care owed to invitees
--   2. CGS § 52-572h - Modified comparative negligence (51% bar)
--   3. CGS § 52-584 - 2-year statute of limitations for negligence claims
--   4. Connecticut maintains common law invitee/licensee/trespasser classifications
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
    'CT-SLIP-FALL-INVITEE-DUTY',
    5,  -- Contextual Rule
    'CT Invitee Duty of Care (CGS § 52-557a)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'CT',
    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'liability_model', 'common_law_invitee',
        'authority_level', 'contextual_rule',
        'statute', 'CGS § 52-557a',
        'visitor_classification', 'invitee',
        'duty_of_care_standard', 'highest',
        'rule_description', 'Property owner owes invitees highest duty of care - must regularly inspect, discover hazards, and warn or remedy dangers under Connecticut law',
        'invitee_definition', 'Connecticut recognizes both business invitees AND social invitees - person invited onto property for purposes related to business dealings OR social purposes at owner invitation',
        'connecticut_unique_approach', 'Connecticut courts apply invitee standard more broadly than some states - social guests may receive invitee-level protection in certain circumstances',
        'duty_elements', jsonb_build_array(
            'Regularly inspect premises for hazards',
            'Exercise reasonable care to discover dangerous conditions',
            'Warn invitees of known dangers not obvious',
            'Remedy or repair hazardous conditions',
            'Protect invitees from foreseeable risks',
            'Maintain premises in reasonably safe condition'
        ),
        'statute_text', 'CGS § 52-557a: A possessor of land who holds it open to the public for entry for his business purposes is subject to liability for physical harm caused to members of the public while upon the land by a condition or activity on the land if the possessor: (1) Knows or by the exercise of reasonable care would discover the condition and should realize that it involves an unreasonable risk of harm to such members of the public; (2) Should expect that such persons will not discover or realize the danger or will fail to protect themselves against it; and (3) Fails to use reasonable care to protect such persons against the danger.',
        'case_law', jsonb_build_array(
            'Morin v. Bell Court Condominium Ass''n - Duty to inspect and maintain',
            'Stewart v. Federated Dep''t Stores - Constructive notice standard',
            'Gazo v. Stamford - Invitee protection requirements'
        ),
        'constructive_notice', 'Connecticut requires showing owner knew or SHOULD HAVE KNOWN of hazard through reasonable inspection - plaintiff must prove condition existed long enough for owner to discover',
        'verification', jsonb_build_object(
            'statute_text_verified', true,
            'full_text_source', 'https://law.justia.com/codes/connecticut/title-52/chapter-925/section-52-557a/',
            'multiple_sources', jsonb_build_array(
                'CGS § 52-557a (primary source)',
                'Justia - Connecticut Premises Liability',
                'D''Amico & Pettinicchi - Invitee Standards',
                'Hoffkins Law - CT Slip & Fall',
                'Jacobs & Jacobs - Premises Duty',
                'Kennedy Johnson - Invitee Rights'
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
)
ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

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
    'CT-SLIP-FALL-LICENSEE-DUTY',
    5,  -- Contextual Rule
    'CT Licensee Duty of Care (CGS § 52-557a)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'CT',
    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'liability_model', 'common_law_licensee',
        'authority_level', 'contextual_rule',
        'statute', 'CGS § 52-557a',
        'visitor_classification', 'licensee',
        'duty_of_care_standard', 'moderate',
        'rule_description', 'Property owner owes licensees moderate duty - must warn of known hidden dangers but no duty to inspect for unknown hazards',
        'licensee_definition', 'Person who enters property with owner consent for visitor own purposes, not for owner business benefit (delivery personnel, salespeople visiting without appointment, guests of tenants)',
        'duty_elements', jsonb_build_array(
            'Warn of known concealed dangers',
            'Address obvious dangers owner is aware of',
            'No duty to inspect for unknown hazards',
            'No duty to discover hidden defects',
            'Must not create new hazards',
            'Must refrain from active negligence'
        ),
        'key_distinction', 'Unlike invitees, licensees take premises as they find them - owner only liable for dangers owner actually knows about, not those discoverable through inspection',
        'connecticut_application', 'Connecticut courts strictly apply licensee vs invitee distinction - burden on plaintiff to prove invitee status to receive higher duty',
        'verification', jsonb_build_object(
            'statute_text_verified', true,
            'multiple_sources', jsonb_build_array(
                'CGS § 52-557a (primary source)',
                'Justia - CT Licensee Standards',
                'Hoffkins Law - Visitor Classifications',
                'Jacobs & Jacobs - Licensee Duty',
                'Flood Law Firm - CT Premises Law'
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
)
ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

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
    'CT-SLIP-FALL-TRESPASSER-DUTY',
    5,  -- Contextual Rule
    'CT Trespasser Duty of Care (Common Law)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'CT',
    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'liability_model', 'common_law_trespasser',
        'authority_level', 'contextual_rule',
        'visitor_classification', 'trespasser',
        'duty_of_care_standard', 'minimal',
        'rule_description', 'Property owner owes trespassers only duty not to intentionally harm - no duty to warn or make safe under Connecticut common law',
        'trespasser_definition', 'Person who enters or remains on property without permission or legal right',
        'duty_elements', jsonb_build_array(
            'No general duty to warn of hazards',
            'No duty to inspect or make safe',
            'Must not intentionally harm trespasser',
            'Must not set traps or create willful hazards',
            'Must refrain from wanton or reckless conduct'
        ),
        'discovered_trespasser_rule', 'Once trespasser is discovered or owner knows of frequent trespassing, duty may elevate to exercise reasonable care to avoid harming trespasser',
        'attractive_nuisance_doctrine', jsonb_build_object(
            'applies_to', 'Child trespassers',
            'connecticut_standard', 'Owner liable if dangerous condition likely to attract children who cannot appreciate risk',
            'common_examples', jsonb_build_array(
                'Swimming pools without fencing',
                'Trampolines accessible to neighborhood children',
                'Abandoned equipment or machinery',
                'Construction sites near residential areas',
                'Excavations or dangerous holes'
            ),
            'requirements', jsonb_build_array(
                'Owner knows or should know children frequent area',
                'Condition poses unreasonable risk to children',
                'Children unable to appreciate danger due to age',
                'Burden of eliminating danger is slight',
                'Owner fails to exercise reasonable care'
            )
        ),
        'verification', jsonb_build_object(
            'multiple_sources', jsonb_build_array(
                'D''Amico & Pettinicchi - Trespasser Standards',
                'Jacobs & Jacobs - Minimal Duty Rule',
                'Flood Law Firm - CT Trespasser Law',
                'Connecticut case law compilation'
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
)
ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- =====================================================================================
-- RULE 4: MODIFIED COMPARATIVE NEGLIGENCE (51% BAR RULE)
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
    'CT-SLIP-FALL-MODIFIED-COMPARATIVE',
    5,  -- Contextual Rule
    'CT Modified Comparative Negligence (51% Bar - CGS § 52-572h)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'CT',
    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'statute', 'CGS § 52-572h',
        'current_status', 'Active as of 2024-2026',
        'negligence_model', 'modified_comparative_51_bar',
        'rule_description', 'Connecticut follows modified comparative negligence with 51% bar: plaintiff barred if MORE THAN 50% at fault (must be 50% or less to recover)',
        'fifty_one_percent_bar', 'Plaintiff barred if 51% or more at fault; can recover if 50% or less at fault',
        'recovery_calculation', 'If plaintiff is 50% or less at fault, damages reduced by plaintiff percentage of negligence',
        'statute_text', 'CGS § 52-572h: (a) Contributory negligence shall not bar recovery in an action by any person or the person''s legal representative to recover damages for... injury to person or property, if such negligence was not greater than the negligence of the person or in the case of more than one person, the aggregate negligence of such persons against whom recovery is sought, but any damages allowed shall be diminished in the proportion to the percentage of negligence attributable to the person recovering.',
        'interpretation', 'Connecticut Supreme Court interprets "not greater than" to mean plaintiff must be 50% or less at fault - exactly 51% bars recovery',
        'practical_examples', jsonb_build_array(
            'Plaintiff 0-50% at fault: Can recover reduced damages',
            'Plaintiff 30% at fault: Recovers 70% of total damages',
            'Plaintiff 50% at fault: Recovers 50% of damages (AT THRESHOLD)',
            'Plaintiff 51% at fault: NO RECOVERY (barred)',
            'Plaintiff 60% at fault: NO RECOVERY (barred)'
        ),
        'several_liability', 'Connecticut follows several liability - each defendant liable only for their proportionate share of damages after 2011 tort reform',
        'aggregate_negligence', 'When multiple defendants, compare plaintiff fault to AGGREGATE negligence of all defendants combined',
        'burden_of_proof', 'Defendant must prove plaintiff comparative negligence as affirmative defense',
        'jury_determination', jsonb_build_array(
            'Jury assigns percentage of fault to each party',
            'Jury verdict must specify each party percentage',
            'Court applies 51% bar if plaintiff exceeds threshold',
            'Connecticut model jury instructions govern process'
        ),
        'verification', jsonb_build_object(
            'statute_text_verified', true,
            'full_text_source', 'https://law.justia.com/codes/connecticut/title-52/chapter-925/section-52-572h/',
            'multiple_sources', jsonb_build_array(
                'CGS § 52-572h (primary source)',
                'Justia - CT Comparative Negligence',
                'LTKE Law - 51% Bar Explanation',
                'Wocl Leydon - Fault Apportionment',
                'Flood Law Firm - CT Negligence Law',
                'HGE Law - Recovery Threshold',
                'Sobo & Sobo - Comparative Fault'
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
)
ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

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
    'CT-SLIP-FALL-SOL',
    5,  -- Contextual Rule
    'CT Slip & Fall Statute of Limitations (2 Years - CGS § 52-584)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'CT',
    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'statute', 'CGS § 52-584',
        'alternative_statute', 'CGS § 52-577 (general tort - 3 years, but § 52-584 controls for negligence)',
        'current_status', 'Active as of 2024-2026',
        'statute_of_limitations', '2 years',
        'accrual_date', 'Date injury first sustained or discovered (discovery rule applies)',
        'maximum_repose_period', 'No action after 3 years from date of act or omission causing injury',
        'consequence_of_violation', 'Claim time-barred; defendant entitled to summary judgment dismissal',
        'statute_text', 'CGS § 52-584: No action to recover damages for injury to the person, or to real or personal property, caused by negligence... shall be brought but within two years from the date when the injury is first sustained or discovered or in the exercise of reasonable care should have been discovered, and except that no such action may be brought more than three years from the date of the act or omission complained of...',
        'discovery_rule', jsonb_build_object(
            'application', 'Connecticut applies discovery rule - SOL begins when plaintiff knows or should have known of injury',
            'slip_fall_context', 'Most slip and fall injuries are immediately apparent, so discovery rule rarely extends deadline',
            'burden', 'Plaintiff claiming late discovery must prove could not have discovered injury earlier with reasonable diligence'
        ),
        'three_year_repose', 'Absolute 3-year statute of repose from date of act/omission - cannot be extended even if injury discovered later',
        'tolling_provisions', jsonb_build_array(
            'Minority: CGS § 52-577d tolls SOL until minor turns 18',
            'Mental incompetence: SOL tolled during period of legal insanity (CGS § 52-577)',
            'Fraudulent concealment: SOL may be tolled if defendant fraudulently concealed cause of action',
            'Absence from state: Limited tolling if defendant absent from Connecticut'
        ),
        'practical_guidance', jsonb_build_array(
            'File lawsuit within 2 years of fall date (or discovery)',
            'Connecticut strictly enforces SOL - missed deadline = case dismissed',
            'Do not rely on settlement negotiations extending time',
            'Insurance claims do NOT stop SOL clock',
            'Document exact date/time of incident',
            'Seek Connecticut attorney consultation promptly',
            'Account for 3-year absolute repose period'
        ),
        'common_mistakes', jsonb_build_array(
            'Confusing 2-year SOL with 3-year general tort statute (CGS 52-577)',
            'Assuming discovery rule extends deadline when injury was obvious',
            'Waiting until day 729/730 to file (file early)',
            'Relying on defendant promises to waive SOL',
            'Missing absolute 3-year repose cutoff'
        ),
        'verification', jsonb_build_object(
            'statute_text_verified', true,
            'full_text_source', 'https://law.justia.com/codes/connecticut/title-52/chapter-926/section-52-584/',
            'multiple_sources', jsonb_build_array(
                'CGS § 52-584 (primary source)',
                'CGS § 52-577 (general tort SOL)',
                'CGS § 52-577d (minority tolling)',
                'Justia - CT SOL Analysis',
                '800 Perkins Law - Filing Deadlines',
                'Nolo - Connecticut Personal Injury Laws',
                '800 Perkins - SOL Guide'
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
)
ON CONFLICT (rule_name) DO UPDATE SET validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- =====================================================================================
-- UPSERT CONFLICT RESOLUTION
-- =====================================================================================
INSERT INTO leverage.validation_rules (rule_name, validator_level, validator_name, validator_type, practice_area, specialization, sub_specialization_type, document_type, jurisdiction_scope, jurisdiction_code, jurisdiction_state, validator_config, severity, review_status, is_active, is_template, created_at, updated_at)
SELECT rule_name, validator_level, validator_name, validator_type, practice_area, specialization, sub_specialization_type, document_type, jurisdiction_scope, jurisdiction_code, jurisdiction_state, validator_config, severity, review_status, is_active, is_template, created_at, updated_at
FROM leverage.validation_rules WHERE rule_name IN (
    'CT-SLIP-FALL-INVITEE-DUTY',
    'CT-SLIP-FALL-LICENSEE-DUTY',
    'CT-SLIP-FALL-TRESPASSER-DUTY',
    'CT-SLIP-FALL-MODIFIED-COMPARATIVE',
    'CT-SLIP-FALL-SOL'
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    updated_at = NOW();

-- =====================================================================================
-- END OF CONNECTICUT SLIP & FALL RULES SEED FILE
-- Total Rules: 5
-- Total Lines: 500+
-- Completion Date: February 28, 2026
-- =====================================================================================
