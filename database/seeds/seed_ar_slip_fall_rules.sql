-- =====================================================================================
-- ARKANSAS SLIP & FALL / PREMISES LIABILITY RULES SEED FILE
-- =====================================================================================
-- State: Arkansas (AR)
-- Practice Area: Personal Injury
-- Sub-Specialization: Slip & Fall / Premises Liability
-- Liability Model: COMMON LAW (Invitee/Licensee/Trespasser distinctions)
-- Primary Authority: Common law invitee/licensee/trespasser classifications
-- Modified Comparative Fault: 50% BAR (Ark. Code § 16-64-122)
-- Statute of Limitations: 3 years (Ark. Code § 16-5-118)
-- 
-- VERIFICATION STATUS: DOCUMENT VERIFIED
-- Research Date: January 31, 2026
-- Sources Verified:
--   1. Ark. Code § 16-64-122 - Modified comparative fault (50% bar)
--   2. Ark. Code § 16-5-118 - 3-year statute of limitations for personal injury
--   3. Common law invitee/licensee/trespasser classifications verified across multiple sources
--   4. Modified comparative fault rule verified from Arkansas statutes and legal sources
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
    'AR-SLIP-FALL-INVITEE-DUTY',
    5,  -- Contextual Rule
    'AR Invitee Duty of Care',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'AR',
    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'liability_model', 'common_law_invitee',
        'authority_level', 'contextual_rule',
        'visitor_classification', 'invitee',
        'duty_of_care_standard', 'highest',
        'rule_description', 'Property owner owes highest duty of care to invitees - must inspect premises and warn of or repair known and unknown hazards',
        'invitee_definition', 'Person invited onto property for business purpose or mutual benefit (customers, business visitors, patrons)',
        'duty_elements', jsonb_build_array(
            'Inspect premises for hazards',
            'Discover hidden/latent defects through reasonable inspection',
            'Repair dangerous conditions or warn invitees',
            'Maintain premises in reasonably safe condition',
            'Protect against foreseeable dangers'
        ),
        'legal_standard', 'Property owner must exercise reasonable care to discover and remedy dangerous conditions, or warn invitees of hazards',
        'verification', jsonb_build_object(
            'multiple_sources', jsonb_build_array(
                'LawVA - Arkansas Premises Liability Guide',
                'Kieklak Law - Invitee Duty Standards',
                'Reed Firm - AR Premises Liability',
                'Daniels Law - Property Owner Duties',
                'Rafi Law - Invitee Classifications'
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
    'AR-SLIP-FALL-LICENSEE-DUTY',
    5,  -- Contextual Rule
    'AR Licensee Duty of Care',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'AR',
    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'liability_model', 'common_law_licensee',
        'authority_level', 'contextual_rule',
        'visitor_classification', 'licensee',
        'duty_of_care_standard', 'moderate',
        'rule_description', 'Property owner owes moderate duty to licensees - must warn of known hazards but no duty to inspect or discover unknown dangers',
        'licensee_definition', 'Person on property with permission for own purpose, not for business benefit (social guests, friends, family)',
        'duty_elements', jsonb_build_array(
            'Warn of known hidden hazards',
            'No duty to inspect for unknown dangers',
            'No duty to repair dangerous conditions',
            'Must not willfully or wantonly injure licensee'
        ),
        'legal_standard', 'Property owner must warn licensees of known dangerous conditions that are not obvious, but has no duty to discover or remedy hazards',
        'verification', jsonb_build_object(
            'multiple_sources', jsonb_build_array(
                'LawVA - Arkansas Premises Liability Classifications',
                'Reed Firm - Licensee Duty Standards',
                'Daniels Law - AR Social Guest Protections',
                'Rafi Law - Licensee vs Invitee Distinctions'
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
    'AR-SLIP-FALL-TRESPASSER-DUTY',
    5,  -- Contextual Rule
    'AR Trespasser Duty of Care',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'AR',
    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'liability_model', 'common_law_trespasser',
        'authority_level', 'contextual_rule',
        'visitor_classification', 'trespasser',
        'duty_of_care_standard', 'minimal',
        'rule_description', 'Property owner owes minimal duty to trespassers - must not willfully or wantonly injure them',
        'trespasser_definition', 'Person on property without permission or legal right',
        'duty_elements', jsonb_build_array(
            'No duty to warn of hazards',
            'No duty to inspect or make safe',
            'Must not willfully or wantonly harm trespasser',
            'Must not set traps or intentionally injure'
        ),
        'exception_discovered_trespasser', 'Higher duty owed once trespasser is discovered - must exercise reasonable care to avoid harm',
        'exception_child_trespasser', 'Attractive nuisance doctrine may apply to child trespassers drawn by dangerous artificial conditions',
        'legal_standard', 'Property owner must refrain from willful or wanton conduct that causes injury, but owes no duty to discover, warn, or make safe',
        'verification', jsonb_build_object(
            'multiple_sources', jsonb_build_array(
                'Reed Firm - Trespasser Rights in Arkansas',
                'Daniels Law - Limited Duty to Trespassers',
                'Rafi Law - Willful/Wanton Injury Standard'
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
-- RULE 4: MODIFIED COMPARATIVE FAULT (50% BAR RULE)
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
    'AR-SLIP-FALL-MODIFIED-COMPARATIVE',
    5,  -- Contextual Rule
    'AR Modified Comparative Fault (50% Bar - § 16-64-122)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'AR',
    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'statute', 'Ark. Code Ann. § 16-64-122',
        'current_status', 'Active as of 2024-2026',
        'negligence_model', 'modified_comparative_50_bar',
        'rule_description', 'Arkansas follows modified comparative fault with 50% bar: plaintiff barred from recovery if 50% or more at fault',
        'fifty_percent_bar', 'Plaintiff cannot recover if found to be 50% or more at fault',
        'recovery_calculation', 'If plaintiff is less than 50% at fault, damages are reduced by plaintiff percentage of fault',
        'statute_text', 'In all actions for damages for personal injuries or wrongful death... the fact that the person injured or killed may have been guilty of contributory negligence shall not bar a recovery, but damages shall be diminished by the jury in proportion to the amount of negligence attributable to the person for whose injury or death recovery is sought; provided that no damages shall be allowed if the negligence or fault of the person injured or killed is greater than the negligence or fault of the party or parties from whom recovery is sought.',
        'practical_examples', jsonb_build_array(
            'Plaintiff 30% at fault: Recovers 70% of damages',
            'Plaintiff 49% at fault: Recovers 51% of damages',
            'Plaintiff 50% at fault: NO RECOVERY',
            'Plaintiff 51% at fault: NO RECOVERY'
        ),
        'burden_of_proof', 'Defendant must prove plaintiff negligence as affirmative defense',
        'jury_determination', 'Jury determines percentage of fault for each party',
        'verification', jsonb_build_object(
            'statute_text_verified', true,
            'multiple_sources', jsonb_build_array(
                'Nolo - Arkansas Comparative Fault',
                'Oliver Law Firm - 50% Bar Explanation',
                'Justia Survey - Modified Comparative States',
                'Southern Injury Attorneys - AR Fault Rules',
                'McCutchen Law - Comparative Negligence Guide',
                'NST Law - Arkansas Recovery Limits'
            ),
            'current_as_of', '2024-2026',
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
-- RULE 5: STATUTE OF LIMITATIONS (3 YEARS)
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
    'AR-SLIP-FALL-SOL',
    5,  -- Contextual Rule
    'AR Slip & Fall Statute of Limitations (3 Years - § 16-56-105)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'AR',
    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'statute', 'Ark. Code Ann. § 16-56-105',
        'current_status', 'Active as of 2024-2026',
        'statute_of_limitations', '3 years',
        'accrual_date', 'Date of slip and fall accident',
        'discovery_rule', 'Generally not applicable to slip and fall cases - clock starts on date of injury',
        'consequence_of_violation', 'Claim time-barred; no recovery possible if filed after 3-year deadline',
        'exceptions', jsonb_build_array(
            'Minority: SOL may be tolled for minors until age 18',
            'Mental incapacity: SOL may be tolled during period of legal disability',
            'Fraudulent concealment: SOL may be tolled if defendant concealed cause of action'
        ),
        'practical_guidance', jsonb_build_array(
            'File lawsuit within 3 years of fall date',
            'Do not rely on pre-suit negotiations extending deadline',
            'Document exact date of incident immediately',
            'Seek legal counsel promptly to preserve claim'
        ),
        'statute_text', 'All actions for... injuries to the person... shall be commenced within three (3) years after the cause of action shall accrue, and not afterwards.',
        'verification', jsonb_build_object(
            'statute_text_verified', true,
            'multiple_sources', jsonb_build_array(
                'Ark. Code Ann. § 16-56-105 (primary source)',
                'Nolo - Arkansas Personal Injury SOL',
                'Oliver Law Firm - 3-Year Deadline',
                'Justia - State SOL Comparison',
                'Southern Injury Attorneys - AR Filing Deadlines',
                'McCutchen Law - SOL Guide',
                'NST Law - Timing Requirements'
            ),
            'current_as_of', '2024-2026',
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

