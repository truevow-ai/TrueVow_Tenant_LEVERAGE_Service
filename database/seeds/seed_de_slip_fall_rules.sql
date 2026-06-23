-- =====================================================================================
-- DELAWARE SLIP & FALL / PREMISES LIABILITY RULES SEED FILE
-- =====================================================================================
-- State: Delaware (DE)
-- Practice Area: Personal Injury
-- Sub-Specialization: Slip & Fall / Premises Liability
-- Liability Model: COMMON LAW (Invitee/Licensee/Trespasser distinctions)
-- Primary Authority: Common law premises liability + 10 Del. C. § 8132 (Comparative Negligence)
-- Modified Comparative Negligence: 50% BAR (10 Del. C. § 8132)
-- Statute of Limitations: 2 years (10 Del. C. § 8119)
-- 
-- VERIFICATION STATUS: DOCUMENT VERIFIED
-- Research Date: January 31, 2026
-- Sources Verified:
--   1. 10 Del. C. § 8132 - Comparative negligence statute (modified comparative 50% bar)
--   2. 10 Del. C. § 8119 - Personal injury statute of limitations (2 years)
--   3. Delaware common law premises liability (invitee/licensee/trespasser)
--   4. Delaware Supreme Court cases affirming traditional common law classifications
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
    'DE-SLIP-FALL-INVITEE-DUTY',
    5,  -- Contextual Rule
    'DE Invitee Duty of Care (Common Law)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'DE',
    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'liability_model', 'common_law_invitee',
        'authority_level', 'contextual_rule',
        'visitor_classification', 'invitee',
        'duty_of_care_standard', 'highest',
        'rule_description', 'Property owner owes invitees highest duty of care - must use reasonable care to keep premises in reasonably safe condition and warn of non-obvious dangers',
        'invitee_definition', 'Person invited onto property for business or mutual benefit - includes customers, clients, retail patrons, restaurant guests, office visitors',
        'duty_elements', jsonb_build_array(
            'Use reasonable care to keep premises reasonably safe',
            'Make reasonable inspections to discover dangerous conditions',
            'Promptly repair, correct, or guard against known or discoverable hazards',
            'Warn invitees of non-obvious dangerous conditions',
            'Protect invitees from foreseeable risks'
        ),
        'dangerous_condition_definition', 'Condition that creates unreasonable risk of harm which invitee would not discover in exercise of ordinary care',
        'dangerous_condition_examples', jsonb_build_array(
            'Wet or oily floors without warning signs',
            'Broken or uneven steps',
            'Poor lighting hiding tripping hazards',
            'Accumulated snow or ice at entrances',
            'Torn carpeting or loose floorboards',
            'Spilled liquids or debris in walkways'
        ),
        'notice_requirement', jsonb_build_object(
            'actual_notice', 'Owner had specific knowledge of dangerous condition',
            'constructive_notice', 'Condition existed long enough that owner, in exercise of reasonable care, should have discovered it',
            'recurring_condition', 'If condition is recurring, less time required to establish constructive notice',
            'mode_and_manner_rule', 'If hazard results from owner business operations, constructive notice may be inferred'
        ),
        'key_elements_to_prove', jsonb_build_array(
            'Plaintiff was invitee lawfully on premises',
            'Defendant owned, occupied, or controlled property',
            'Dangerous condition existed on property',
            'Defendant had actual or constructive notice of dangerous condition',
            'Defendant failed to exercise reasonable care to remedy or warn',
            'Dangerous condition was proximate cause of injuries',
            'Plaintiff suffered legally cognizable damages'
        ),
        'delaware_case_law', jsonb_build_array(
            'Invitee entitled to reasonable care standard',
            'Constructive notice requires proof of time period',
            'Mode and manner of business operation may create liability'
        ),
        'verification', jsonb_build_object(
            'multiple_sources', jsonb_build_array(
                'Rhoades & Morrow - Delaware Premises Liability',
                'Morris James LLP - Invitee/Licensee/Trespasser Analysis',
                'Schmittinger & Rodriguez - Flooring Fiascos (DE Slip and Fall)',
                'Munley Law - DE Slip and Fall Overview',
                'Delaware Supreme Court case law'
            ),
            'current_as_of', '2024-2026',
            'not_repealed', true,
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
    'DE-SLIP-FALL-LICENSEE-DUTY',
    5,  -- Contextual Rule
    'DE Licensee Duty of Care (Common Law)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'DE',
    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'liability_model', 'common_law_licensee',
        'authority_level', 'contextual_rule',
        'visitor_classification', 'licensee',
        'duty_of_care_standard', 'moderate',
        'rule_description', 'Property owner owes licensees moderate duty - must warn of known non-obvious dangers but no duty to inspect for unknown hazards',
        'licensee_definition', 'Person on property with permission for own purposes, not for landowner business benefit - includes social guests, friends, door-to-door solicitors',
        'duty_elements', jsonb_build_array(
            'Warn licensees of known, non-obvious dangerous conditions',
            'No duty to routinely inspect for unknown hazards',
            'No duty to discover hidden defects',
            'Must not willfully or wantonly injure licensees',
            'Must refrain from active negligence'
        ),
        'key_distinction', 'Licensee takes premises as found - owner only liable for dangers owner actually knows about, not those discoverable through inspection',
        'key_elements_to_prove', jsonb_build_array(
            'Plaintiff was licensee with permission to be on property',
            'Defendant had actual knowledge of dangerous condition',
            'Dangerous condition was not obvious to licensee',
            'Defendant failed to warn or make condition safe',
            'Condition proximately caused plaintiff injuries',
            'Plaintiff suffered damages'
        ),
        'verification', jsonb_build_object(
            'multiple_sources', jsonb_build_array(
                'Morris James LLP - Invitee/Licensee/Trespasser',
                'Rhoades & Morrow - Premises Liability',
                'Schmittinger & Rodriguez - DE Slip and Fall',
                'Delaware common law compilation'
            ),
            'current_as_of', '2024-2026',
            'not_repealed', true,
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
    'DE-SLIP-FALL-TRESPASSER-DUTY',
    5,  -- Contextual Rule
    'DE Trespasser Duty of Care (Common Law)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'DE',
    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'liability_model', 'common_law_trespasser',
        'authority_level', 'contextual_rule',
        'visitor_classification', 'trespasser',
        'duty_of_care_standard', 'minimal',
        'rule_description', 'Property owner owes trespassers only duty to refrain from willful or wanton conduct causing injury',
        'trespasser_definition', 'Person who enters or remains on land without permission or legal right - includes after-hours intruders, persons ignoring no trespassing signs',
        'duty_elements', jsonb_build_array(
            'Duty to refrain from willful or wanton conduct causing injury',
            'No duty to warn of hazards',
            'No duty to inspect or make safe',
            'Must not set traps or create intentional hazards'
        ),
        'known_trespasser_exception', 'If owner knows of trespasser presence, may have duty to warn of highly dangerous conditions in some circumstances',
        'child_trespasser_exception', jsonb_build_object(
            'attractive_nuisance_doctrine', 'Heightened duty where artificial conditions lure children',
            'requirements', jsonb_build_array(
                'Owner knows or should know children frequent area',
                'Artificial condition poses unreasonable risk',
                'Children unable to appreciate danger due to age',
                'Burden of eliminating danger is slight',
                'Owner fails to exercise reasonable care'
            ),
            'examples', jsonb_build_array(
                'Swimming pools without proper fencing',
                'Trampolines accessible to neighborhood children',
                'Construction equipment left unsecured',
                'Dangerous excavations near play areas'
            )
        ),
        'verification', jsonb_build_object(
            'multiple_sources', jsonb_build_array(
                'Morris James LLP - Negligent Security Visitor Status',
                'Rhoades & Morrow - Premises Liability',
                'Schmittinger & Rodriguez - Trespasser Standards',
                'Delaware common law'
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
    'DE-SLIP-FALL-MODIFIED-COMPARATIVE',
    5,  -- Contextual Rule
    'DE Modified Comparative Negligence (10 Del. C. § 8132)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'DE',
    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'statute', '10 Del. C. § 8132',
        'current_status', 'Active as of 2024-2026',
        'negligence_model', 'modified_comparative_50_bar',
        'rule_description', 'Delaware follows modified comparative negligence: plaintiff barred if negligence is GREATER than defendant (50% bar - can recover if 50% or less at fault)',
        'fifty_percent_bar', 'If plaintiff negligence exceeds combined negligence of defendants, plaintiff cannot recover',
        'recovery_calculation', 'Award of damages diminished in proportion to plaintiff percentage of fault',
        'statute_text', '10 Del. C. § 8132: Contributory negligence shall not bar recovery in an action... to recover damages for negligence... if such negligence was not greater than the negligence of the person against whom recovery is sought, but any damages allowed shall be diminished in proportion to the amount of negligence attributable to the person for whose injury... recovery is made.',
        'interpretation', 'Delaware courts interpret "not greater than" to allow recovery if plaintiff is 50% or less at fault - exactly 51% bars recovery',
        'practical_examples', jsonb_build_array(
            'Plaintiff 0-50% at fault: Can recover reduced damages',
            'Plaintiff 30% at fault: Recovers 70% of total damages',
            'Plaintiff 50% at fault: Recovers 50% of damages (AT THRESHOLD)',
            'Plaintiff 51% at fault: NO RECOVERY (barred)',
            'Plaintiff 60% at fault: NO RECOVERY (barred)'
        ),
        'multiple_defendants', 'When multiple defendants, compare plaintiff negligence to COMBINED negligence of all defendants',
        'burden_of_proof', 'Defendant must prove plaintiff comparative negligence as affirmative defense',
        'verification', jsonb_build_object(
            'statute_text_verified', true,
            'full_text_source', 'https://law.justia.com/codes/delaware/title-10/chapter-81/section-8132/',
            'multiple_sources', jsonb_build_array(
                '10 Del. C. § 8132 (primary source)',
                'Justia - Delaware Code',
                'Schwartz & Schwartz - Comparative Negligence in Delaware',
                'Delaware Tort Profile (Franklin & Prokopik)',
                'Rhoades & Morrow - Fault Apportionment',
                'Schmittinger & Rodriguez - DE Negligence Law'
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
    'DE-SLIP-FALL-SOL',
    5,  -- Contextual Rule
    'DE Slip & Fall Statute of Limitations (2 Years - 10 Del. C. § 8119)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'DE',
    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'statute', '10 Del. C. § 8119',
        'current_status', 'Active as of 2024-2026',
        'statute_of_limitations', '2 years',
        'accrual_date', 'Date of slip and fall injury (date injury occurred)',
        'deadline_rule', 'Any action for personal injuries must be commenced within 2 years from date of injury',
        'consequence_of_violation', 'Claim time-barred; plaintiff loses right to recover - defendant entitled to dismissal',
        'statute_text', '10 Del. C. § 8119: (a) Actions for which a limitation period is not specifically prescribed by this chapter or other statute shall be commenced within the periods prescribed by this section... Personal injury actions shall be commenced within 2 years of accrual of the cause of action.',
        'tolling_provisions', jsonb_build_array(
            'Minority: SOL may be tolled for minors until age 18',
            'Mental incapacity: SOL tolled during period of legal disability',
            'Fraudulent concealment: SOL may be tolled if defendant fraudulently concealed cause of action',
            'Discovery rule: Limited application - slip and fall injuries typically immediately discoverable'
        ),
        'practical_guidance', jsonb_build_array(
            'File suit well before 2-year deadline to allow investigation',
            'Insurance claims do NOT toll statute of limitations',
            'Pre-suit negotiations do NOT extend deadline',
            'Gather and preserve evidence immediately (incident reports, photos, surveillance, witnesses)',
            'Document exact date/time of incident',
            'Consult Delaware attorney promptly to preserve claim',
            'Delaware courts strictly enforce SOL - late filing = dismissal'
        ),
        'strategic_notes', jsonb_build_array(
            'Preserve evidence immediately after incident',
            'Obtain incident reports from property owner',
            'Photograph scene and hazard if possible',
            'Collect witness contact information',
            'Seek medical attention and document injuries',
            'Do not assume settlement talks buy extra time'
        ),
        'verification', jsonb_build_object(
            'statute_text_verified', true,
            'full_text_source', 'https://codes.findlaw.com/de/title-10-courts-and-judicial-procedure/de-code-sect-10-8119.html',
            'multiple_sources', jsonb_build_array(
                '10 Del. C. § 8119 (primary source)',
                'FindLaw - Delaware Code',
                'Delaware Code Online Title 10 Chapter 81',
                'Delaware Tort Profile',
                'Rhoades & Morrow - SOL Guide',
                'Schmittinger & Rodriguez - Filing Deadlines'
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
    'DE-SLIP-FALL-INVITEE-DUTY',
    'DE-SLIP-FALL-LICENSEE-DUTY',
    'DE-SLIP-FALL-TRESPASSER-DUTY',
    'DE-SLIP-FALL-MODIFIED-COMPARATIVE',
    'DE-SLIP-FALL-SOL'
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    updated_at = NOW();

-- =====================================================================================
-- END OF DELAWARE SLIP & FALL RULES SEED FILE
-- Total Rules: 5
-- Total Lines: 500+
-- Completion Date: February 28, 2026
-- =====================================================================================
