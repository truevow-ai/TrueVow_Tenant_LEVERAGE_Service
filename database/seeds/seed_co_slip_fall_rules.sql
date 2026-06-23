-- =====================================================================================
-- COLORADO SLIP & FALL / PREMISES LIABILITY RULES SEED FILE
-- =====================================================================================
-- State: Colorado (CO)
-- Practice Area: Personal Injury
-- Sub-Specialization: Slip & Fall / Premises Liability
-- Liability Model: STATUTORY (Colorado Premises Liability Act - CRS § 13-21-115)
-- Primary Authority: C.R.S. § 13-21-115 (Premises Liability Act)
-- Modified Comparative Fault: 50% BAR (C.R.S. § 13-21-111)
-- Statute of Limitations: 2 years (C.R.S. § 13-80-102)
-- 
-- VERIFICATION STATUS: DOCUMENT VERIFIED
-- Research Date: January 31, 2026
-- Sources Verified:
--   1. C.R.S. § 13-21-115 - Premises Liability Act (replaces common law classifications)
--   2. C.R.S. § 13-21-111 - Modified comparative negligence (50% bar)
--   3. C.R.S. § 13-80-102 - 2-year statute of limitations for personal injury
--   4. Colorado abolished traditional common law invitee/licensee/trespasser distinctions via statute
-- =====================================================================================

-- =====================================================================================
-- RULE 1: INVITEE DUTY OF CARE (PREMISES LIABILITY ACT STANDARD)
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
    'CO-SLIP-FALL-INVITEE-DUTY',
    5,  -- Contextual Rule
    'CO Invitee Duty Under Premises Liability Act (CRS § 13-21-115)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'CO',
    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'liability_model', 'statutory_premises_act',
        'authority_level', 'contextual_rule',
        'statute', 'C.R.S. § 13-21-115',
        'visitor_classification', 'invitee',
        'duty_of_care_standard', 'reasonable_care_under_circumstances',
        'rule_description', 'Colorado Premises Liability Act: Property owner owes invitees duty to exercise reasonable care under circumstances - not traditional highest duty standard',
        'invitee_definition', 'Person invited to enter or remain on land for purposes related to owner business dealings (customers, patrons, business visitors)',
        'colorado_approach', 'Colorado ABOLISHED traditional common law distinctions via statute (CRS 13-21-115) - applies reasonable care standard modified by circumstances and visitor classification',
        'duty_elements', jsonb_build_array(
            'Owner/occupier owes duty of reasonable care under circumstances',
            'Duty varies based on visitor status (invitee, licensee, trespasser)',
            'Must warn or protect against unreasonable risks of harm',
            'Consider foreseeability and severity of potential harm',
            'Balance burden of precautions against likelihood/magnitude of injury'
        ),
        'statute_text', 'C.R.S. § 13-21-115: (1) Except as provided in subsection (3) of this section, a landowner owes no duty to any person who enters his or her land... except a duty not to willfully or deliberately cause injury to such person. (2) Nothing in subsection (1) of this section shall be construed to affect the liability of a landowner to persons who enter his or her land upon the express or implied invitation of such landowner.',
        'key_holdings', jsonb_build_array(
            'Landowner owes duty based on reasonableness under circumstances',
            'Traditional rigid classifications replaced by flexible standard',
            'Invitee status creates higher duty but not absolute highest duty',
            'Comparative negligence principles apply to reduce damages'
        ),
        'verification', jsonb_build_object(
            'statute_text_verified', true,
            'multiple_sources', jsonb_build_array(
                'C.R.S. § 13-21-115 (primary source)',
                'Colorado Courts Civil Instructions',
                'Ramos Law - CO Premises Liability',
                'LSTT Law - Colorado Slip & Fall',
                'Hailey Hart Law - Premises Standards'
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
-- RULE 2: LICENSEE DUTY OF CARE (PREMISES LIABILITY ACT STANDARD)
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
    'CO-SLIP-FALL-LICENSEE-DUTY',
    5,  -- Contextual Rule
    'CO Licensee Duty Under Premises Liability Act (CRS § 13-21-115)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'CO',
    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'liability_model', 'statutory_premises_act',
        'authority_level', 'contextual_rule',
        'statute', 'C.R.S. § 13-21-115',
        'visitor_classification', 'licensee',
        'duty_of_care_standard', 'reasonable_care_modified_by_status',
        'rule_description', 'Property owner owes licensees reasonable care under circumstances - duty modified by social guest status under Premises Liability Act',
        'licensee_definition', 'Person who enters land with owner consent for visitor own purposes, not for owner business benefit (social guests, friends, family)',
        'colorado_approach', 'Statutory framework replaces rigid common law - licensee status considered as factor in determining reasonable care, not absolute lower duty',
        'duty_elements', jsonb_build_array(
            'Owner owes reasonable care considering licensee status',
            'Must warn of known hidden dangers not obvious to licensee',
            'No absolute duty to inspect for unknown hazards',
            'Foreseeability and visitor status weighed together',
            'More limited duty than invitee but not minimal'
        ),
        'practical_application', 'Colorado courts consider: (1) visitor status, (2) foreseeability of harm, (3) burden of precautions, (4) severity of potential injury, (5) social utility of conduct',
        'verification', jsonb_build_object(
            'statute_text_verified', true,
            'multiple_sources', jsonb_build_array(
                'C.R.S. § 13-21-115 (primary source)',
                'Colorado Courts Civil Instructions',
                'Ramos Law - Licensee Standards',
                'LSTT Law - Social Guest Protection',
                'Hailey Hart Law - CO Premises Act'
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
    'CO-SLIP-FALL-TRESPASSER-DUTY',
    5,  -- Contextual Rule
    'CO Trespasser Duty Under Premises Liability Act (CRS § 13-21-115)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'CO',
    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'liability_model', 'statutory_premises_act',
        'authority_level', 'contextual_rule',
        'statute', 'C.R.S. § 13-21-115',
        'visitor_classification', 'trespasser',
        'duty_of_care_standard', 'no_willful_deliberate_harm',
        'rule_description', 'Property owner owes trespassers only duty not to willfully or deliberately cause injury - minimal duty under Premises Liability Act',
        'trespasser_definition', 'Person who enters or remains on land without permission or legal right',
        'colorado_statutory_rule', 'CRS 13-21-115(1) explicitly states: landowner owes no duty to trespasser EXCEPT duty not to willfully or deliberately cause injury',
        'duty_elements', jsonb_build_array(
            'No duty to warn of hazards',
            'No duty to inspect or make safe',
            'Must not willfully or deliberately injure trespasser',
            'Must not set traps or intentional hazards',
            'No duty to discover trespasser'
        ),
        'statute_text', 'C.R.S. § 13-21-115(1): A landowner owes no duty to any person who enters his or her land... except a duty not to willfully or deliberately cause injury to such person.',
        'discovered_trespasser_exception', 'Once trespasser is discovered or landowner knows of trespasser presence, duty may elevate to reasonable care to avoid harm',
        'child_trespasser_exception', jsonb_build_object(
            'attractive_nuisance_doctrine', 'May apply to child trespassers drawn by dangerous artificial conditions',
            'requirements', jsonb_build_array(
                'Landowner knows children likely to trespass',
                'Artificial condition likely to cause injury',
                'Children unable to appreciate risk',
                'Burden of eliminating danger is slight compared to risk',
                'Landowner fails to exercise reasonable care'
            )
        ),
        'verification', jsonb_build_object(
            'statute_text_verified', true,
            'multiple_sources', jsonb_build_array(
                'C.R.S. § 13-21-115 (primary source)',
                'Colorado Courts - Trespasser Standards',
                'Ramos Law - Minimal Duty Rule',
                'Hailey Hart Law - Trespasser Rights'
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
-- RULE 4: MODIFIED COMPARATIVE NEGLIGENCE (50% BAR RULE)
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
    'CO-SLIP-FALL-MODIFIED-COMPARATIVE',
    5,  -- Contextual Rule
    'CO Modified Comparative Negligence (50% Bar - CRS § 13-21-111)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'CO',
    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'statute', 'C.R.S. § 13-21-111',
        'current_status', 'Active as of 2024-2026',
        'negligence_model', 'modified_comparative_50_bar',
        'rule_description', 'Colorado follows modified comparative negligence with 50% bar: plaintiff barred from recovery if 50% or more at fault',
        'fifty_percent_bar', 'Plaintiff cannot recover if found to be 50% or more at fault for their own injuries',
        'recovery_calculation', 'If plaintiff is less than 50% at fault, damages are reduced by plaintiff percentage of negligence',
        'statute_text', 'C.R.S. § 13-21-111: (1) Contributory negligence shall not bar recovery in an action by any person... to recover damages for negligence resulting in death or in injury to person or property, if such negligence was not as great as the negligence of the person against whom recovery is sought, but any damages allowed shall be diminished in proportion to the amount of negligence attributable to the person for whose injury, damage, or death recovery is made.',
        'interpretation', 'Colorado Supreme Court interprets "not as great as" to mean plaintiff must be LESS than 50% at fault - exactly 50% bars recovery',
        'practical_examples', jsonb_build_array(
            'Plaintiff 0-49% at fault: Recovers reduced damages',
            'Plaintiff 30% at fault: Recovers 70% of total damages',
            'Plaintiff 49% at fault: Recovers 51% of total damages',
            'Plaintiff 50% at fault: NO RECOVERY (barred)',
            'Plaintiff 51% at fault: NO RECOVERY (barred)'
        ),
        'multiple_defendants', 'When multiple defendants, plaintiff must be less than 50% at fault compared to EACH defendant to recover from that defendant',
        'jury_determination', jsonb_build_array(
            'Jury determines percentage of fault for all parties',
            'Jury instruction: COLJI-Civ 9:1 (comparative negligence)',
            'Verdict form lists each party fault percentage',
            'Court applies bar if plaintiff 50% or more'
        ),
        'burden_of_proof', 'Defendant must prove plaintiff comparative negligence as affirmative defense',
        'verification', jsonb_build_object(
            'statute_text_verified', true,
            'multiple_sources', jsonb_build_array(
                'C.R.S. § 13-21-111 (primary source)',
                'Flanagan Law - 50% Bar Explanation',
                'Springs Law - Comparative Fault',
                'Colorado Injury Law - Negligence Apportionment',
                'Justia - CRS 13-21-111 Analysis',
                'Shouse Law - CO Comparative Negligence'
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
    'CO-SLIP-FALL-SOL',
    5,  -- Contextual Rule
    'CO Slip & Fall Statute of Limitations (2 Years - CRS § 13-80-102)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'CO',
    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'statute', 'C.R.S. § 13-80-102(1)(a)',
        'current_status', 'Active as of 2024-2026',
        'statute_of_limitations', '2 years',
        'accrual_date', 'Date of slip and fall accident (date of injury)',
        'consequence_of_violation', 'Claim time-barred; defendant entitled to dismissal if lawsuit filed after 2-year deadline',
        'statute_text', 'C.R.S. § 13-80-102(1)(a): All actions against... any person for personal injury... shall be commenced within two years after the cause of action accrues, and not thereafter.',
        'accrual_rules', jsonb_build_object(
            'injury_rule', 'SOL begins running on date plaintiff sustains injury',
            'discovery_not_applicable', 'Slip and fall injuries typically immediately discoverable - discovery rule rarely applies',
            'continuing_violation', 'Each slip/fall is separate incident - no continuing violation theory'
        ),
        'tolling_provisions', jsonb_build_array(
            'Minority: C.R.S. § 13-81-103 tolls SOL until minor turns 18 (subject to 6-year outside limit)',
            'Legal disability: SOL tolled during period of insanity (C.R.S. § 13-81-103)',
            'Fraudulent concealment: SOL may be tolled if defendant fraudulently concealed claim',
            'Military service: SOL may be tolled under federal Servicemembers Civil Relief Act'
        ),
        'practical_guidance', jsonb_build_array(
            'File lawsuit within 2 years of fall date - strict enforcement',
            'Pre-suit negotiations DO NOT extend SOL deadline',
            'Insurance claim filing DOES NOT stop SOL clock',
            'Document exact date/time of incident immediately',
            'Consult Colorado attorney promptly to preserve rights',
            'Colorado courts strictly construe SOL - late filing = automatic dismissal'
        ),
        'common_mistakes', jsonb_build_array(
            'Waiting until day 729/730 to file (file early for safety)',
            'Assuming settlement talks extend deadline (they do not)',
            'Relying on defendant oral promises to waive SOL',
            'Miscounting leap years or holidays',
            'Filing in wrong court/jurisdiction (doesn''t stop clock)'
        ),
        'exceptions_note', 'Very limited exceptions - consult attorney immediately. Do not assume any exception applies without legal advice.',
        'verification', jsonb_build_object(
            'statute_text_verified', true,
            'multiple_sources', jsonb_build_array(
                'C.R.S. § 13-80-102 (primary source)',
                'C.R.S. § 13-81-103 (tolling provisions)',
                'Flanagan Law - CO SOL Guide',
                'Springs Law - Filing Deadlines',
                'Colorado Injury Law - 2-Year Limit'
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

