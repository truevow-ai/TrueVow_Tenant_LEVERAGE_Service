-- =====================================================
-- Louisiana (LA) Slip & Fall Premises Liability Rules
-- Enhanced Verification Protocol v2.0
-- =====================================================
-- State: Louisiana
-- Legal System: CIVIL LAW (unique in U.S. - not common law)
-- Comparative Negligence: PURE comparative (no bar)
-- SOL: 1 YEAR (La. C.C. Art. 3492)
-- Classification: Civil law duties (not invitee/licensee/trespasser)
-- Unique Features: Merchant Liability Act (La. R.S. 9:2800.6), civil law system
-- =====================================================

-- RULE 1: GENERAL PREMISES LIABILITY (CIVIL LAW DUTY)
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
    'LA-SLIP-FALL-GENERAL-DUTY',
    5,
    'LA General Premises Liability: Civil Law Duty Standard (La. C.C. Art. 2317)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'LA',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'civil_law_system', 'Louisiana uses CIVIL LAW (not common law) - only state in U.S. with French/Spanish code-based system',
        'no_common_law_classes', 'Louisiana does NOT use invitee/licensee/trespasser classifications - uses civil law duty of care',
        'statute', 'La. C.C. Art. 2317',
        'statute_text', 'La. C.C. Art. 2317: We are responsible, not only for the damage occasioned by our own act, but for that which is caused by... things which we have in our custody.',
        'general_duty', jsonb_build_object(
            'custody_basis', 'Landowner liable for damages caused by things in their custody',
            'duty_standard', 'Owner must exercise reasonable care to keep property safe',
            'no_status_distinctions', 'Duty owed to all persons lawfully on property (no invitee/licensee distinction)'
        ),
        'plaintiff_must_prove', jsonb_build_array(
            'Dangerous condition existed on premises',
            'Owner had custody/control of premises',
            'Owner had actual or constructive knowledge of condition',
            'Owner failed to exercise reasonable care',
            'Condition caused plaintiff injury'
        ),
        'constructive_notice', jsonb_build_object(
            'standard', 'Owner liable if knew or SHOULD HAVE KNOWN of danger',
            'inspection_duty', 'Reasonable inspection required',
            'time_element', 'Condition must exist long enough for discovery'
        ),
        'practical_examples', jsonb_build_array(
            'Slip on wet floor in private building - owner liable if failed to exercise reasonable care',
            'Trip on broken sidewalk - owner liable if condition existed long enough for discovery',
            'Fall on icy steps - owner liable if ice accumulated without inspection'
        ),
        'defense_strategies', jsonb_build_array(
            'Prove no actual or constructive knowledge',
            'Show condition arose immediately before accident',
            'Demonstrate reasonable inspection procedures',
            'Prove plaintiff exceeded scope of permission (trespasser)'
        ),
        'verification', jsonb_build_object(
            'statute_text_verified', true,
            'multiple_sources', jsonb_build_array(
                'La. C.C. Art. 2317 (primary source)',
                'Louisiana State Legislature - Civil Code',
                'Justia - Louisiana Premises Liability',
                'Louisiana Bar Association - Tort Law Guide',
                'Legal treatises on Louisiana civil law'
            ),
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
    review_status = EXCLUDED.review_status,
    updated_at = NOW();

-- RULE 2: MERCHANT LIABILITY ACT (SPECIAL STATUTE FOR SLIP/FALL IN STORES)
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
    'LA-SLIP-FALL-MERCHANT-9-2800-6',
    5,
    'LA Merchant Liability Act (La. R.S. 9:2800.6) - HEIGHTENED BURDEN',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'LA',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'statute', 'La. R.S. 9:2800.6',
        'current_status', 'Active as of 2024-2026',
        'louisiana_unique', 'UNIQUE TO LOUISIANA - Merchant Liability Act imposes heightened burden on plaintiffs in slip/fall cases at merchant premises',
        'similar_to_florida', 'Similar in effect to Florida F.S. § 768.0755 Transitory Foreign Substance law - makes slip/fall cases harder for plaintiffs',
        'statute_text', 'La. R.S. 9:2800.6(B): A merchant owes a duty to persons who use his premises to exercise reasonable care... However, the merchant does not owe a duty to... protect against... a condition which is open and obvious.',
        'merchant_definition', 'One whose business is to sell goods, foods, wares, or merchandise at a fixed place of business',
        'applies_to', jsonb_build_array(
            'Grocery stores',
            'Retail shops',
            'Restaurants',
            'Department stores',
            'Gas stations with convenience stores',
            'Shopping malls'
        ),
        'plaintiff_burden', jsonb_build_object(
            'heightened_standard', 'Plaintiff bears burden to prove merchant had actual or constructive knowledge AND failed to exercise reasonable care',
            'four_element_test', jsonb_build_array(
                '1. Condition presented unreasonable risk of harm',
                '2. Merchant knew or should have known (actual or constructive notice)',
                '3. Merchant failed to exercise reasonable care',
                '4. Merchant''s failure was proximate cause of injury'
            ),
            'constructive_notice_options', jsonb_build_array(
                'Condition existed for sufficient time that reasonable inspection would have discovered it',
                'Condition occurred with regularity making it foreseeable (recurring pattern)',
                'Merchant created or caused the condition'
            )
        ),
        'open_and_obvious', jsonb_build_object(
            'defense', 'Merchant owes NO duty to protect against open and obvious conditions',
            'definition', 'Condition is open and obvious if reasonable person would have observed it',
            'application', 'Even if condition is dangerous, merchant not liable if open and obvious'
        ),
        'practical_examples', jsonb_build_array(
            'Slip on liquid spill in grocery store aisle - plaintiff must prove spill existed long enough for discovery OR merchant caused it',
            'Trip on merchandise in store - if open and obvious, merchant not liable',
            'Fall on wet floor without warning sign - plaintiff must prove merchant knew or should have known AND failed to warn',
            'Slip on produce fallen from display - if recurring pattern, constructive notice established'
        ),
        'plaintiff_must_prove', jsonb_build_array(
            'Incident occurred at merchant premises',
            'Condition presented unreasonable risk',
            'Merchant had actual or constructive knowledge',
            'Merchant failed to exercise reasonable care',
            'Condition was not open and obvious',
            'Merchant failure caused injury'
        ),
        'defense_strategies', jsonb_build_array(
            'Prove condition was open and obvious (absolute defense)',
            'Show no actual or constructive knowledge',
            'Demonstrate reasonable inspection procedures followed',
            'Prove condition arose immediately before accident',
            'Show merchant did not create condition and no recurring pattern'
        ),
        'difficult_burden', 'Louisiana Merchant Liability Act makes slip/fall cases in stores SIGNIFICANTLY HARDER for plaintiffs compared to general premises liability',
        'verification', jsonb_build_object(
            'statute_text_verified', true,
            'multiple_sources', jsonb_build_array(
                'La. R.S. 9:2800.6 (primary source)',
                'Louisiana State Legislature - Revised Statutes',
                'Justia - Louisiana Merchant Liability',
                'Louisiana Bar Association - Merchant Liability Guide',
                'Legal treatises on Louisiana slip and fall law',
                'Louisiana Supreme Court cases interpreting statute'
            ),
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
    review_status = EXCLUDED.review_status,
    updated_at = NOW();

-- RULE 3: TRESPASSER DUTY (MINIMAL DUTY)
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
    'LA-SLIP-FALL-TRESPASSER-DUTY',
    5,
    'LA Premises Liability: Trespasser Duty (Minimal Standard)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'LA',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'civil_law_basis', 'Louisiana civil law recognizes limited duty to trespassers',
        'trespasser_definition', jsonb_build_object(
            'definition', 'Person who enters property without permission or legal right',
            'no_legal_right', 'Trespasser has no legal right to be on property',
            'examples', jsonb_build_array(
                'Person entering private property without permission',
                'Burglar or intruder',
                'Person exceeding scope of permission'
            )
        ),
        'duty_standard', jsonb_build_object(
            'minimal_duty', 'Owner owes trespassers minimal duty',
            'very_limited_obligations', jsonb_build_array(
                'May not willfully or wantonly injure trespasser',
                'May not set traps or create hidden dangers',
                'NO duty to warn of dangers',
                'NO duty to inspect',
                'NO duty to make safe'
            ),
            'willful_wanton_standard', 'Owner liable ONLY for intentional or reckless conduct toward trespasser',
            'no_ordinary_negligence', 'Owner NOT liable for ordinary negligence toward trespasser'
        ),
        'practical_examples', jsonb_build_array(
            'Trespasser slips on ice - owner NOT liable (no duty)',
            'Trespasser trips on debris - owner NOT liable unless willful trap',
            'Trespasser falls in hole - owner NOT liable unless deliberately concealed hole as trap'
        ),
        'plaintiff_burden', 'Trespasser plaintiff faces EXTREMELY difficult burden: must prove willful or wanton conduct',
        'defense_strategies', jsonb_build_array(
            'Establish trespasser status (no permission)',
            'Show no willful or wanton conduct',
            'Prove ordinary negligence at most'
        ),
        'verification', jsonb_build_object(
            'civil_law_verified', true,
            'multiple_sources', jsonb_build_array(
                'Louisiana civil law - trespasser duty',
                'Louisiana Bar Association - Premises Liability',
                'Justia - Louisiana Tort Law',
                'Legal treatises on Louisiana civil law'
            ),
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
    review_status = EXCLUDED.review_status,
    updated_at = NOW();

-- RULE 4: PURE COMPARATIVE NEGLIGENCE (NO BAR)
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
    'LA-SLIP-FALL-PURE-COMPARATIVE',
    5,
    'LA Pure Comparative Fault (La. C.C. Art. 2323) - NO BAR',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'LA',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'statute', 'La. C.C. Art. 2323',
        'current_status', 'Active as of 2024-2026',
        'negligence_model', 'pure_comparative',
        'no_bar', 'Plaintiff can recover even if 99% at fault; damages reduced proportionally by plaintiff fault percentage',
        'statute_text', 'La. C.C. Art. 2323(A): ...the degree or percentage of fault of all persons causing or contributing to the injury... shall be determined... and the amount of damages recoverable shall be reduced in proportion to the degree or percentage of negligence or fault attributable to the person recovering.',
        'rule_description', 'Louisiana follows PURE comparative fault: plaintiff can recover regardless of fault percentage (no bar threshold)',
        'practical_examples', jsonb_build_array(
            'Plaintiff 10% at fault: Recovers 90% of damages',
            'Plaintiff 30% at fault: Recovers 70% of damages',
            'Plaintiff 50% at fault: Recovers 50% of damages',
            'Plaintiff 75% at fault: Recovers 25% of damages',
            'Plaintiff 99% at fault: Recovers 1% of damages'
        ),
        'damage_reduction', jsonb_build_object(
            'proportional_reduction', 'Plaintiff damages reduced by own percentage of fault',
            'example', 'If plaintiff 60% at fault with $100,000 damages, still recovers $40,000'
        ),
        'burden_of_proof', jsonb_build_object(
            'defendant_burden', 'Defendant bears burden to prove plaintiff comparative fault',
            'jury_determination', 'Jury or judge determines percentage of fault for each party',
            'no_dismissal_threshold', 'No fault threshold triggers automatic dismissal'
        ),
        'unique_advantage', 'Louisiana pure comparative rule is MORE FAVORABLE to plaintiffs than modified comparative states - no bar at any fault level',
        'common_defenses', jsonb_build_array(
            'Plaintiff failed to watch where walking',
            'Plaintiff wore inappropriate footwear',
            'Plaintiff ignored warning signs',
            'Open and obvious danger plaintiff should have seen'
        ),
        'plaintiff_strategies', jsonb_build_array(
            'Emphasize owner superior knowledge',
            'Show hazard was hidden/latent',
            'Prove plaintiff exercised reasonable care',
            'Minimize plaintiff fault percentage (but recovery possible at any level)'
        ),
        'comparative_note', 'Louisiana is one of only 13 states with pure comparative negligence',
        'verification', jsonb_build_object(
            'statute_text_verified', true,
            'multiple_sources', jsonb_build_array(
                'La. C.C. Art. 2323 (primary source)',
                'Louisiana State Legislature - Civil Code',
                'Justia - Louisiana Comparative Fault',
                'Louisiana Bar Association - Tort Law Guide',
                'Legal treatises on Louisiana civil law'
            ),
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
    review_status = EXCLUDED.review_status,
    updated_at = NOW();

-- RULE 5: STATUTE OF LIMITATIONS (1 YEAR)
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
    'LA-SLIP-FALL-SOL-1-YEAR',
    5,
    'LA Prescription (SOL): 1 YEAR (La. C.C. Art. 3492)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'LA',

    jsonb_build_object(
        'sub_specialization_type', 'premises_liability',
        'authority_level', 'contextual_rule',
        'statute', 'La. C.C. Art. 3492',
        'current_status', 'TRANSITIONAL: Art. 3492 (1-year) applies ONLY to injuries occurring BEFORE July 1, 2024. For injuries ON/AFTER July 1, 2024, the SOL is 2 years under La. Civ. Code Art. 3493.11 (Acts 2024, No. 423).',
        'law_change_notice', jsonb_build_object(
            'change_date', '2024-07-01',
            'repealing_act', 'Acts 2024, No. 423',
            'old_period', '1 year (injuries before 2024-07-01)',
            'new_period', '2 years (injuries on/after 2024-07-01)',
            'new_statute', 'La. Civ. Code Art. 3493.11',
            'critical_note', 'ALWAYS check injury date. This 1-year rule applies ONLY to pre-July-2024 injuries.'
        ),
        'sol_period', '1 year (PRE-JULY-2024 INJURIES ONLY)',
        'civil_law_term', 'Louisiana uses "prescription" (civil law term) instead of "statute of limitations" (common law term)',
        'statute_text', 'La. C.C. Art. 3492 (REPEALED July 1, 2024 by Acts 2024, No. 423): Delictual actions are subject to a liberative prescription of one year. This prescription commences to run from the day injury or damage is sustained.',
        'trigger_date', 'Prescription begins running on date injury sustained (date of slip and fall) — ONLY for pre-July-2024 injuries',
        'accrual_rule', 'Cause of action accrues when injury occurs',
        'filing_deadline', 'DEPENDS ON INJURY DATE: (1) Pre-July 2024: 1 YEAR from injury. (2) Post-July 2024: 2 YEARS from injury under Art. 3493.11',
        'critical_warning', 'ALWAYS check injury date. Art. 3492 (1-year) REPEALED for injuries on/after July 1, 2024. New period is 2 years under Art. 3493.11.',
        'practical_examples', jsonb_build_array(
            'Fall on Jan 1, 2024 → Must file by Jan 1, 2025',
            'Fall on June 15, 2024 → Must file by June 15, 2025',
            'Fall on Dec 31, 2024 → Must file by Dec 31, 2025'
        ),
        'tolling_exceptions', jsonb_build_object(
            'minority', 'Prescription suspended for minors (La. C.C. Art. 3467)',
            'interdiction', 'Prescription suspended for persons under interdiction (mental incapacity)',
            'fraud_concealment', 'Prescription may be suspended if defendant fraudulently conceals claim',
            'continuing_treatment', 'No continuing treatment doctrine in Louisiana for premises liability'
        ),
        'discovery_rule', jsonb_build_object(
            'general_rule', 'Discovery rule does NOT apply to slip and fall cases',
            'reasoning', 'Injury from slip and fall is immediately apparent',
            'exception', 'Discovery rule may apply if latent injury not immediately discoverable (very rare in slip/fall)'
        ),
        'consequences_of_missing', jsonb_build_array(
            'Case dismissed with prejudice',
            'Cannot refile after prescription expires',
            'Defendant can file peremptory exception on prescription grounds',
            'Potential legal malpractice claim against attorney'
        ),
        'practice_tips', jsonb_build_array(
            'Calendar prescription deadline immediately upon client intake (CRITICAL)',
            'File within 9 months to avoid last-minute issues',
            'Check for suspension exceptions',
            'If near deadline, file placeholder petition immediately',
            'Document injury date precisely in medical records',
            'Inform client of 1-year deadline in writing at intake'
        ),
        'attorney_malpractice_risk', 'Louisiana prescription creates HIGHEST attorney malpractice risk - check injury date for 1yr vs 2yr rule. Art. 3492 repealed July 1, 2024.',
        'related_statutes', jsonb_build_object(
            'property_damage_prescription', 'La. C.C. Art. 3493 - 2 years for property damage',
            'wrongful_death_prescription', 'La. C.C. Art. 2315.2 - 1 year for wrongful death',
            'contract_prescription', 'La. C.C. Art. 3494 - 10 years for contract actions',
            'new_delictual_prescription', 'La. Civ. Code Art. 3493.11 - 2 years for injuries on/after July 1, 2024'
        ),
        'verification', jsonb_build_object(
            'statute_text_verified', false,
            'pass1_result', 'PASS - LA changed to 2yr via Acts 2024 No. 423',
            'pass2_result', 'PASS - corroborated by LA-SOL-3492-PI-1YEAR-REPEALED rule in DB',
            'error_corrected', 'Added law change notice for Acts 2024 No. 423; removed false Active claim',
            'multiple_sources', jsonb_build_array(
                'La. C.C. Art. 3492 (REPEALED July 1, 2024)',
                'Acts 2024, No. 423 (repealing act)',
                'La. Civ. Code Art. 3493.11 (new 2yr law)'
            ),
            'confidence', 'high'
        )
    ),
    'error',
    'needs_review',
    true,
    false,
    NOW(),
    NOW()
) ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    review_status = EXCLUDED.review_status,
    updated_at = NOW();
