-- ============================================================================
-- ALABAMA DOG BITE LIABILITY RULES SEED FILE
-- ============================================================================
-- State: Alabama (AL)
-- Sub-Specialization: Dog Bite (Personal Injury)
-- Legal Model: HYBRID (Strict Liability on Property + Mitigation + One-Bite Off-Property)
-- Primary Statute: Ala. Code § 3-6-1 (Acts 1953, No. 320)
-- Verified: January 2025
-- Source: https://www.animallaw.info/statute/al-dog-bitedangerous-animal-liability-owners-dogs-biting-or-injuring-persons
-- ============================================================================

BEGIN;

-- ============================================================================
-- PART 1: LEGAL SOURCES
-- ============================================================================

-- Source 1: Alabama Code § 3-6-1 (Strict Liability on Owner's Property)
INSERT INTO leverage.legal_sources (
    jurisdiction_type,
    jurisdiction_state,
    jurisdiction_county,
    jurisdiction_court,
    name,
    publisher,
    abbreviation,
    base_url,
    source_type,
    trust_level,
    notes
) VALUES (
    'state',
    'AL',
    NULL,
    NULL,
    'Alabama Dog Bite Statute - Strict Liability on Property',
    'Alabama Legislature',
    'Ala. Code',
    'https://www.animallaw.info/statute/al-dog-bitedangerous-animal-liability-owners-dogs-biting-or-injuring-persons',
    'statute',
    'high',
    'Ala. Code § 3-6-1: If any dog shall, without provocation, bite or injure any person who is at the time at a place where he or she has a legal right to be, the owner of such dog shall be liable in damages to the person so bitten or injured, but such liability shall arise only when the person so bitten or injured is upon property owned or controlled by the owner of such dog at the time such bite or injury occurs or when such person has been immediately prior to such time on such property and has been pursued therefrom by such dog. DOCUMENT VERIFIED.'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET
    base_url = EXCLUDED.base_url,
    notes = EXCLUDED.notes;

-- Source 2: Alabama Code § 3-6-3 (Mitigation of Damages)
INSERT INTO leverage.legal_sources (
    jurisdiction_type,
    jurisdiction_state,
    jurisdiction_county,
    jurisdiction_court,
    name,
    publisher,
    abbreviation,
    base_url,
    source_type,
    trust_level,
    notes
) VALUES (
    'state',
    'AL',
    NULL,
    NULL,
    'Alabama Dog Bite Statute - Mitigation Provision',
    'Alabama Legislature',
    'Ala. Code',
    'https://www.animallaw.info/statute/al-dog-bitedangerous-animal-liability-owners-dogs-biting-or-injuring-persons',
    'statute',
    'high',
    'Ala. Code § 3-6-3: The owner of such dog shall, however, be entitled to plead and prove in mitigation of damages that he had no knowledge of any circumstances indicating such dog to be or to have been vicious or dangerous or mischievous, and, if he does so, he shall be liable only to the extent of the actual expenses incurred by the person so bitten or injured as a result of the bite or injury. DOCUMENT VERIFIED.'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET
    base_url = EXCLUDED.base_url,
    notes = EXCLUDED.notes;

-- Source 3: Alabama Code § 3-1-3 (Dangerous Animal - Off Property)
INSERT INTO leverage.legal_sources (
    jurisdiction_type,
    jurisdiction_state,
    jurisdiction_county,
    jurisdiction_court,
    name,
    publisher,
    abbreviation,
    base_url,
    source_type,
    trust_level,
    notes
) VALUES (
    'state',
    'AL',
    NULL,
    NULL,
    'Alabama Dangerous Animal Statute - General Liability',
    'Alabama Legislature',
    'Ala. Code',
    'https://www.animallaw.info/statute/al-dog-bitedangerous-animal-liability-owners-dogs-biting-or-injuring-persons',
    'statute',
    'high',
    'Ala. Code § 3-1-3: When any person owns or keeps a vicious or dangerous animal of any kind and, as a result of his careless management of the same or his allowing the same to go at liberty, and another person, without fault on his part, is injured thereby, such owner or keeper shall be liable in damages for such injury. DOCUMENT VERIFIED.'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET
    base_url = EXCLUDED.base_url,
    notes = EXCLUDED.notes;

-- ============================================================================
-- PART 2: RULE CITATIONS (Optional - for future reference)
-- ============================================================================
-- Note: Citations are embedded in validation_rules.validator_config
-- Separate citation tracking can be added later if needed

-- ============================================================================
-- PART 3: VALIDATION RULES
-- ============================================================================

-- Rule 1: On-Property Strict Liability
INSERT INTO leverage.validation_rules (
    rule_name,
    validator_level,
    validator_name,
    validator_type,
    practice_area,
    document_type,
    jurisdiction_scope,
    jurisdiction_state,
    jurisdiction_county,
    jurisdiction_court,
    validator_config,
    severity,
    citation_id,
    review_status,
    is_active,
    is_template,
    tenant_id,
    created_at,
    updated_at
) VALUES (
    'AL-PI-DOG-BITE-ON-PROPERTY-STRICT-LIABILITY',
    5,
    'AL Dog Bite On-Property Strict Liability',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'AL',
    NULL,
    NULL,
    '{
        "liability_model": "strict_liability_on_property",
        "statute": "Ala. Code § 3-6-1",
        "key_requirements": [
            "Dog bite or injury occurred without provocation",
            "Victim was lawfully on owner''s property",
            "Injury occurred on property owned or controlled by dog owner",
            "OR victim was pursued from property by dog immediately prior to injury"
        ],
        "defenses": ["provocation", "trespassing"],
        "applies_to": "owner only (not keepers or handlers)",
        "damages": "Full damages if owner had prior knowledge; economic only if no prior knowledge (see § 3-6-3)"
    }'::jsonb,
    'error',
    NULL,
    'document_verified',
    true,
    true,
    NULL,
    NOW(),
    NOW()
) ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    review_status = EXCLUDED.review_status,
    updated_at = NOW();

-- Rule 2: Mitigation - Economic Damages Only
INSERT INTO leverage.validation_rules (
    rule_name,
    validator_level,
    validator_name,
    validator_type,
    practice_area,
    document_type,
    jurisdiction_scope,
    jurisdiction_state,
    jurisdiction_county,
    jurisdiction_court,
    validator_config,
    severity,
    citation_id,
    review_status,
    is_active,
    is_template,
    tenant_id,
    created_at,
    updated_at
) VALUES (
    'AL-PI-DOG-BITE-MITIGATION-ECONOMIC-ONLY',
    5,
    'AL Dog Bite Mitigation - No Prior Knowledge',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'AL',
    NULL,
    NULL,
    '{
        "liability_model": "mitigation_provision",
        "statute": "Ala. Code § 3-6-3",
        "rule": "Owner may prove no prior knowledge of dog''s dangerous propensity to limit damages",
        "effect": "If owner proves no prior knowledge, liable only for economic losses (actual expenses)",
        "economic_damages_only": ["medical bills", "lost wages", "other actual expenses"],
        "non_economic_excluded": ["pain and suffering", "emotional distress", "punitive damages"],
        "burden_of_proof": "Owner must plead and prove lack of knowledge"
    }'::jsonb,
    'warning',
    NULL,
    'document_verified',
    true,
    true,
    NULL,
    NOW(),
    NOW()
) ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    review_status = EXCLUDED.review_status,
    updated_at = NOW();

-- Rule 3: Off-Property One-Bite Rule
INSERT INTO leverage.validation_rules (
    rule_name,
    validator_level,
    validator_name,
    validator_type,
    practice_area,
    document_type,
    jurisdiction_scope,
    jurisdiction_state,
    jurisdiction_county,
    jurisdiction_court,
    validator_config,
    severity,
    citation_id,
    review_status,
    is_active,
    is_template,
    tenant_id,
    created_at,
    updated_at
) VALUES (
    'AL-PI-DOG-BITE-OFF-PROPERTY-ONE-BITE',
    5,
    'AL Dog Bite Off-Property One-Bite Rule',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'AL',
    NULL,
    NULL,
    '{
        "liability_model": "one_bite_rule",
        "statute": "Ala. Code § 3-1-3",
        "applies_when": "Dog bite occurred OFF owner''s property",
        "required_proof": [
            "Owner owned or kept a vicious or dangerous animal",
            "Owner carelessly managed the animal OR allowed it to go at liberty",
            "Victim was without fault",
            "Animal''s actions caused injury"
        ],
        "key_element": "Must prove owner knew or should have known of dog''s dangerous propensity",
        "evidence_types": ["prior bites", "prior attacks", "complaints", "aggressive behavior", "breed reputation"]
    }'::jsonb,
    'error',
    NULL,
    'document_verified',
    true,
    true,
    NULL,
    NOW(),
    NOW()
) ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    review_status = EXCLUDED.review_status,
    updated_at = NOW();

COMMIT;

-- Verification Notice
DO $$
BEGIN
    RAISE NOTICE '============================================================================';
    RAISE NOTICE 'ALABAMA (AL) DOG BITE LIABILITY RULES SEEDED SUCCESSFULLY';
    RAISE NOTICE '============================================================================';
    RAISE NOTICE 'Legal Model: HYBRID (Strict Liability on Property + Mitigation + One-Bite Off-Property)';
    RAISE NOTICE 'Primary Statute: Ala. Code § 3-6-1 (1953)';
    RAISE NOTICE 'Mitigation: Ala. Code § 3-6-3 (economic damages only if no prior knowledge)';
    RAISE NOTICE 'Off-Property: Ala. Code § 3-1-3 (one-bite rule applies)';
    RAISE NOTICE 'Statute of Limitations: 2 years (general PI SOL)';
    RAISE NOTICE '============================================================================';
    RAISE NOTICE 'STATE 1 OF 50 COMPLETE - DOG BITE SUB-SPECIALIZATION';
    RAISE NOTICE '============================================================================';
END $$;
