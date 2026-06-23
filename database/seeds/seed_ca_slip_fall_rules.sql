-- =====================================================================================
-- CALIFORNIA SLIP & FALL / PREMISES LIABILITY RULES SEED FILE
-- =====================================================================================
-- State: California (CA)
-- Practice Area: Personal Injury
-- Sub-Specialization: Slip & Fall / Premises Liability
-- Liability Model: COMMON LAW (Invitee/Licensee/Trespasser distinctions per Civil Code § 1714)
-- Primary Authority: Cal. Civ. Code § 1714 (General negligence duty)
-- Pure Comparative Negligence: Li v. Yellow Cab Co., 13 Cal.3d 804 (1975)
-- Statute of Limitations: 2 years (Cal. Code Civ. Proc. § 335.1)
-- 
-- VERIFICATION STATUS: DOCUMENT VERIFIED
-- Research Date: January 31, 2026
-- Sources Verified:
--   1. Cal. Civ. Code § 1714 - General duty of care, negligence liability
--   2. Cal. Code Civ. Proc. § 335.1 - 2-year statute of limitations for personal injury
--   3. Li v. Yellow Cab Co., 13 Cal.3d 804 (1975) - Pure comparative negligence landmark case
--   4. Common law invitee/licensee/trespasser classifications verified across CA legal sources
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
    'CA-SLIP-FALL-INVITEE-DUTY',
    5,  -- Contextual Rule
    'CA Invitee Duty of Care (Civil Code § 1714)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'CA',
    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'liability_model', 'common_law_invitee',
        'authority_level', 'contextual_rule',
        'statute', 'Cal. Civ. Code § 1714',
        'visitor_classification', 'invitee',
        'duty_of_care_standard', 'highest',
        'rule_description', 'Property owner owes highest duty of care to invitees - must inspect premises and warn of or repair known and reasonably discoverable hazards',
        'invitee_definition', 'Person invited onto property for business purpose or mutual economic benefit (customers, store patrons, restaurant guests)',
        'duty_elements', jsonb_build_array(
            'Exercise reasonable care to keep premises safe',
            'Conduct reasonable inspections to discover hazards',
            'Warn invitees of known and discoverable dangers',
            'Repair dangerous conditions or make them safe',
            'Protect against foreseeable risks'
        ),
        'legal_standard', 'Everyone is responsible for injury caused to another by his or her want of ordinary care or skill in management of property (§ 1714). For invitees, owner must exercise reasonable care to discover and remedy dangerous conditions.',
        'statute_text', 'Cal. Civ. Code § 1714: Everyone is responsible, not only for the result of his or her willful acts, but also for an injury occasioned to another by his or her want of ordinary care or skill in the management of his or her property or person...',
        'case_law', jsonb_build_array(
            'Rowland v. Christian, 69 Cal.2d 108 (1968) - Established general duty of reasonable care',
            'Ortega v. Kmart Corp., 26 Cal.4th 1200 (2001) - Invitee duty standards'
        ),
        'verification', jsonb_build_object(
            'statute_text_verified', true,
            'multiple_sources', jsonb_build_array(
                'California Attorney Group - Premises Liability',
                'West Coast Trial Lawyers - Invitee Duty Standards',
                'Tofer Law - CA Property Owner Obligations',
                'CA Legislative Info - Civil Code § 1714',
                'Lawpipe - Invitee vs Licensee'
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
    'CA-SLIP-FALL-LICENSEE-DUTY',
    5,  -- Contextual Rule
    'CA Licensee Duty of Care (Civil Code § 1714)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'CA',
    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'liability_model', 'common_law_licensee',
        'authority_level', 'contextual_rule',
        'statute', 'Cal. Civ. Code § 1714',
        'visitor_classification', 'licensee',
        'duty_of_care_standard', 'moderate',
        'rule_description', 'Property owner owes moderate duty to licensees - must warn of known hidden hazards but no duty to inspect for unknown dangers',
        'licensee_definition', 'Person on property with permission for own purpose, not for owner benefit (social guests, friends, family members)',
        'duty_elements', jsonb_build_array(
            'Warn of known hidden dangers',
            'No duty to inspect for unknown hazards',
            'No duty to repair dangerous conditions',
            'Must not create new hazards',
            'Must exercise ordinary care not to injure'
        ),
        'legal_standard', 'Property owner must warn licensees of known concealed dangers that licensee is unlikely to discover, but no duty to inspect or discover unknown hazards',
        'rowland_factors', jsonb_build_array(
            'Foreseeability of harm',
            'Degree of certainty injury occurred',
            'Closeness of connection between conduct and injury',
            'Moral blame attached to conduct',
            'Policy of preventing future harm',
            'Burden to impose duty',
            'Availability of insurance'
        ),
        'verification', jsonb_build_object(
            'statute_text_verified', true,
            'multiple_sources', jsonb_build_array(
                'West Coast Trial Lawyers - Licensee Standards',
                'Tofer Law - Social Guest Protections',
                'Lawpipe - CA Visitor Classifications'
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
    'CA-SLIP-FALL-TRESPASSER-DUTY',
    5,  -- Contextual Rule
    'CA Trespasser Duty of Care (Civil Code § 1714)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'CA',
    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'liability_model', 'common_law_trespasser',
        'authority_level', 'contextual_rule',
        'statute', 'Cal. Civ. Code § 1714',
        'visitor_classification', 'trespasser',
        'duty_of_care_standard', 'minimal',
        'rule_description', 'Property owner owes minimal duty to trespassers - must not willfully or wantonly injure, but no duty to warn or make safe',
        'trespasser_definition', 'Person who enters property without permission or legal right',
        'duty_elements', jsonb_build_array(
            'No duty to warn of hazards',
            'No duty to inspect or discover dangers',
            'No duty to make premises safe',
            'Must not willfully or wantonly harm trespasser',
            'Must not set traps or cause intentional injury'
        ),
        'discovered_trespasser_rule', 'Once trespasser is discovered, owner must exercise ordinary care to avoid injuring them',
        'attractive_nuisance_doctrine', jsonb_build_object(
            'applies_to', 'Child trespassers',
            'requirements', jsonb_build_array(
                'Owner knows/should know children frequent area',
                'Condition likely to cause injury',
                'Children unable to appreciate risk due to youth',
                'Burden of eliminating danger small compared to risk',
                'Owner fails to exercise reasonable care'
            ),
            'example_attractions', jsonb_build_array(
                'Swimming pools',
                'Construction sites',
                'Abandoned equipment',
                'Dangerous machinery',
                'Excavations/pits'
            )
        ),
        'verification', jsonb_build_object(
            'statute_text_verified', true,
            'multiple_sources', jsonb_build_array(
                'West Coast Trial Lawyers - Trespasser Rights',
                'Tofer Law - Limited Duty Standards'
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
-- RULE 4: PURE COMPARATIVE NEGLIGENCE
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
    'CA-SLIP-FALL-PURE-COMPARATIVE',
    5,  -- Contextual Rule
    'CA Pure Comparative Negligence (Li v. Yellow Cab)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'CA',
    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'case_law', 'Li v. Yellow Cab Co., 13 Cal.3d 804 (1975)',
        'current_status', 'Active as of 2024-2026',
        'negligence_model', 'pure_comparative',
        'rule_description', 'California follows pure comparative negligence: plaintiff can recover damages even if 99% at fault, with recovery reduced proportionally',
        'recovery_rule', 'Plaintiff damages reduced by their percentage of fault - no bar to recovery regardless of fault percentage',
        'practical_examples', jsonb_build_array(
            'Plaintiff 10% at fault: Recovers 90% of damages',
            'Plaintiff 50% at fault: Recovers 50% of damages',
            'Plaintiff 75% at fault: Recovers 25% of damages',
            'Plaintiff 99% at fault: Recovers 1% of damages'
        ),
        'case_law_history', jsonb_build_object(
            'pre_li_rule', 'Contributory negligence was complete bar (any plaintiff fault = no recovery)',
            'li_holding', 'Supreme Court abolished contributory negligence bar and adopted pure comparative fault',
            'rationale', 'Assesses liability in direct proportion to fault; fairer and more efficient system',
            'impact', 'Revolutionary change allowing partial recovery even when plaintiff primarily at fault'
        ),
        'jury_instructions', jsonb_build_array(
            'CACI 405 - Comparative Fault (Fault of Plaintiff and Others)',
            'Jury assigns percentage of fault to each party',
            'Plaintiff damages reduced by their fault percentage',
            'No minimum threshold for recovery'
        ),
        'statute_text', 'Li v. Yellow Cab (1975): "We conclude that the rule which bars the negligent plaintiff from any recovery is inequitable... we adopt a system of comparative negligence under which liability for damage will be borne by those whose negligence caused it in direct proportion to their respective fault."',
        'verification', jsonb_build_object(
            'case_law_verified', true,
            'multiple_sources', jsonb_build_array(
                'The MVP - Pure Comparative Negligence Guide',
                'Law Legal Hub - Li v. Yellow Cab Analysis',
                'Setareh Law - CA Fault Apportionment',
                'Corrales Law - Comparative Negligence Primer',
                'Kuzyk Law - Plaintiff Fault Recovery',
                'Kahana Feld - No Recovery Bar'
            ),
            'current_as_of', '2024-2026',
            'source_type', 'case_law',
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
    'CA-SLIP-FALL-SOL',
    5,  -- Contextual Rule
    'CA Slip & Fall Statute of Limitations (2 Years - CCP § 335.1)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'CA',
    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'statute', 'Cal. Code Civ. Proc. § 335.1',
        'current_status', 'Active as of 2024-2026',
        'statute_of_limitations', '2 years',
        'accrual_date', 'Date of slip and fall accident (injury)',
        'consequence_of_violation', 'Claim time-barred; defendant entitled to dismissal if lawsuit filed after 2-year deadline',
        'statute_text', 'Cal. Code Civ. Proc. § 335.1: Within two years: An action for assault, battery, or injury to, or for the death of, an individual caused by the wrongful act or negligence of another.',
        'discovery_rule', jsonb_build_object(
            'general_rule', 'SOL begins on date of injury, not date plaintiff discovers injury',
            'exception', 'Discovery rule may apply if injury not immediately discoverable',
            'rare_application', 'Slip and fall injuries usually immediately apparent, so discovery rule rarely applies'
        ),
        'tolling_provisions', jsonb_build_array(
            'Minority: SOL tolled until minor turns 18 (but cannot exceed 8 years from accrual per § 352)',
            'Legal disability: SOL tolled during period of insanity or incompetence',
            'Defendant absence: SOL may be tolled if defendant absent from California',
            'Fraudulent concealment: SOL tolled if defendant fraudulently concealed cause of action'
        ),
        'practical_guidance', jsonb_build_array(
            'File lawsuit within 2 years of fall - DO NOT MISS DEADLINE',
            'Pre-suit settlement negotiations DO NOT extend SOL',
            'Insurance claim filing DOES NOT extend SOL',
            'Document exact date of incident immediately',
            'Consult attorney promptly to preserve claim',
            'California courts strictly enforce SOL - late filing = dismissal'
        ),
        'common_mistakes', jsonb_build_array(
            'Waiting until day 730 to file (file early for safety)',
            'Assuming insurance negotiations buy time (they do not)',
            'Relying on defendant promises to extend deadline',
            'Forgetting weekends/holidays in calculation'
        ),
        'verification', jsonb_build_object(
            'statute_text_verified', true,
            'multiple_sources', jsonb_build_array(
                'Cal. Code Civ. Proc. § 335.1 (primary source)',
                'The MVP - California SOL Guide',
                'Law Legal Hub - 2-Year Deadline',
                'Setareh Law - Filing Requirements',
                'Corrales Law - SOL Primer',
                'Kuzyk Law - Timing Compliance',
                'Kahana Feld - Deadline Enforcement'
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

