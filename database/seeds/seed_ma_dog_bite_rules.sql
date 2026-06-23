-- =====================================================================================
-- MASSACHUSETTS DOG BITE LIABILITY RULES SEED FILE
-- =====================================================================================
-- State: Massachusetts (MA)
-- Sub-Specialization: Dog Bite (Personal Injury)
-- Liability Model: STRICT LIABILITY (Statutory)
-- Legal Standard: Owner/keeper liable for all damages caused by dog
-- Primary Authority: M.G.L. Chapter 140, Section 155
-- Statute of Limitations: 3 years (M.G.L. Chapter 260, Section 2A)
-- 
-- VERIFICATION STATUS: DOCUMENT VERIFIED
-- Research Date: January 30, 2026
-- Sources Verified:
--   1. M.G.L. Chapter 140, Section 155 - Verified from multiple legal sources
--   2. M.G.L. Chapter 260, Section 2A - 3-year SOL
--   3. Strict liability with defenses confirmed
-- =====================================================================================

-- =====================================================================================
-- PART 1: LEGAL SOURCES
-- =====================================================================================

-- Source 1: Massachusetts Dog Bite Strict Liability Statute (M.G.L. Chapter 140, Section 155)
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
    'MA',
    NULL,
    NULL,
    'Massachusetts Dog Bite Strict Liability Statute',
    'Massachusetts Legislature',
    'M.G.L. c. 140, § 155',
    'https://malegislature.gov/Laws/GeneralLaws/PartI/TitleXX/Chapter140/Section155',
    'statute',
    'high',
    'M.G.L. Chapter 140, Section 155 - Liability for dog damage:

If any dog shall do any damage to either the body or property of any person, the owner or keeper, or if the owner or keeper be a minor, the parent or guardian of such minor, shall be liable for such damage, unless such damage shall have been occasioned to the body or property of a person who, at the time such damage was sustained, was committing a trespass or other tort, or was teasing, tormenting or abusing such dog.

If such minor shall be under the age of seven years, it shall be presumed that such minor was not committing a trespass or tort, and was not teasing, tormenting or abusing such dog, and the burden of proof thereof shall be upon the defendant in any action brought under this section.

KEY PROVISIONS:

1. STRICT LIABILITY:
   - Owner or keeper liable for ALL damages caused by dog to body or property
   - NO requirement to prove owner knew dog was dangerous
   - NO one-bite rule
   - Liability regardless of dog''s prior viciousness
   - Liability regardless of owner''s negligence

2. OWNER/KEEPER DEFINITION:
   - "Owner": Legal owner of dog
   - "Keeper": Person who harbors, controls, or has custody of dog (even temporarily)
   - If owner/keeper is minor → parent/guardian liable

3. DEFENSES (Owner NOT liable if):
   - Trespass: Victim was trespassing on property
   - Other tort: Victim was committing another tort
   - Teasing, tormenting, or abusing: Victim was provoking dog

4. SPECIAL PROTECTION FOR CHILDREN UNDER 7:
   - Presumption: Child under 7 was NOT trespassing, committing tort, or provoking dog
   - Burden of proof: Defendant (owner) must prove child WAS trespassing/provoking
   - This is VERY protective of young children

5. SCOPE:
   - Applies to damage to BODY (personal injury)
   - Applies to damage to PROPERTY
   - No requirement that injury occur off-premises
   - No requirement of bite (includes other dog-caused injuries)

6. NO COMPARATIVE NEGLIGENCE:
   - Massachusetts is contributory negligence state for other torts
   - However, M.G.L. 140 § 155 does NOT explicitly apply contributory negligence
   - If victim not trespassing/provoking, strict liability applies

DOCUMENT VERIFIED from Massachusetts General Laws and multiple legal sources (dogbitelaw.com, BWG Law, Bellotti Law, d''Oliveira & Associates).'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET
    base_url = EXCLUDED.base_url,
    notes = EXCLUDED.notes;

-- Source 2: Massachusetts Statute of Limitations - Personal Injury (M.G.L. Chapter 260, Section 2A)
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
    'MA',
    NULL,
    NULL,
    'Massachusetts Statute of Limitations - Personal Injury (Dog Bite)',
    'Massachusetts Legislature',
    'M.G.L. c. 260, § 2A',
    'https://malegislature.gov/Laws/GeneralLaws/PartIII/TitleV/Chapter260/Section2a',
    'statute',
    'high',
    'M.G.L. Chapter 260, Section 2A - Statute of limitations for tort actions:

Except as otherwise provided, actions of tort, actions of contract for personal injuries, and actions of replevin shall be commenced only within three years next after the cause of action accrues.

APPLICATION TO DOG BITES:
Claims brought under M.G.L. Chapter 140, Section 155 (strict liability statute) are subject to this THREE YEAR statute of limitations. The three-year period begins on the date of the dog bite injury.

TOLLING PROVISIONS:
- Minors: Statute tolled until minor reaches age 18
- Discovery rule: May apply in limited circumstances if injury not immediately discoverable
- Defendant leaves Massachusetts: Time may be tolled
- Mental incapacity: Statute may be tolled

PROPERTY DAMAGE:
Same 3-year SOL applies to property damage claims under M.G.L. 140 § 155.

STRATEGIC NOTES:
- 3-year filing period is moderate (not shortest, not longest)
- Evidence preservation important
- Prompt medical attention and reporting recommended
- Legal consultation advised within reasonable time after bite

DOCUMENT VERIFIED from Massachusetts General Laws and multiple legal sources.'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET
    base_url = EXCLUDED.base_url,
    notes = EXCLUDED.notes;

-- =====================================================================================
-- PART 2: VALIDATION RULES
-- =====================================================================================

-- Rule 1: Massachusetts Strict Liability (M.G.L. c. 140, § 155)
INSERT INTO leverage.validation_rules (
    rule_name,
    validator_level,
    validator_name,
    validator_type,
    practice_area,
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
    'MA-PI-DOG-BITE-STRICT-LIABILITY',
    5,
    'MA Dog Bite Strict Liability (M.G.L. c. 140, § 155)',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'MA',
    '{
        "liability_model": "strict_liability",
        "statute": "M.G.L. c. 140, § 155",
        "legal_standard": "Owner or keeper liable for all damages caused by dog to body or property",
        "key_requirements": [
            "Dog caused damage to plaintiff''s body or property",
            "Defendant was owner or keeper of dog (or parent/guardian if minor)",
            "Plaintiff was NOT trespassing",
            "Plaintiff was NOT committing other tort",
            "Plaintiff was NOT teasing, tormenting, or abusing dog"
        ],
        "no_one_bite_rule": "Massachusetts does NOT follow one-bite rule; strict liability on first bite",
        "no_prior_knowledge_required": "Owner liable regardless of lack of knowledge of dog''s dangerous propensities",
        "owner_keeper_definition": {
            "owner": "Legal owner of dog",
            "keeper": "Person who harbors, controls, or has custody of dog (even temporarily)",
            "minor_owner": "If owner/keeper is minor, parent/guardian is liable"
        },
        "defenses": {
            "trespass": "Victim was trespassing on property",
            "other_tort": "Victim was committing another tort",
            "provocation": "Victim was teasing, tormenting, or abusing dog"
        },
        "special_protection_children_under_7": {
            "presumption": "Child under 7 presumed NOT trespassing, committing tort, or provoking dog",
            "burden_of_proof": "Defendant must prove child WAS trespassing/provoking",
            "very_protective": "This is VERY protective of young children"
        },
        "broad_scope": {
            "body_damage": "Applies to personal injury",
            "property_damage": "Applies to property damage",
            "no_location_requirement": "No requirement that injury occur off-premises",
            "includes_non_bite": "Includes other dog-caused injuries (not just bites)"
        },
        "damages_recoverable": [
            "Medical expenses",
            "Lost wages",
            "Pain and suffering",
            "Emotional distress",
            "Permanent scarring/disfigurement",
            "Property damage",
            "Wrongful death"
        ]
    }'::jsonb,
    'error',
    'doc_verified',
    true,
    true,
    NOW(),
    NOW()
) ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    review_status = EXCLUDED.review_status,
    updated_at = NOW();

-- Rule 2: Massachusetts Statute of Limitations - 3 YEARS
INSERT INTO leverage.validation_rules (
    rule_name,
    validator_level,
    validator_name,
    validator_type,
    practice_area,
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
    'MA-PI-DOG-BITE-SOL-3-YEARS',
    5,
    'MA Dog Bite Statute of Limitations (3 Years)',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'MA',
    '{
        "statute": "M.G.L. c. 260, § 2A",
        "statute_of_limitations": "3 years",
        "sol_years": 3,
        "sol_days": 1095,
        "accrual_date": "Date cause of action accrues (date of dog bite injury)",
        "key_requirements": [
            "Action must be commenced within 3 YEARS of dog bite",
            "Applies to personal injury claims under M.G.L. c. 140, § 155",
            "Applies to property damage claims under M.G.L. c. 140, § 155",
            "Failure to file within 3 years bars recovery"
        ],
        "tolling_provisions": [
            "Minors: Statute tolled until minor reaches age 18",
            "Discovery rule: May apply in limited circumstances if injury not immediately discoverable",
            "Defendant leaves Massachusetts: Time may be tolled",
            "Mental incapacity: Statute may be tolled"
        ],
        "strategic_notes": [
            "3-year period is moderate (not shortest, not longest)",
            "Evidence preservation important (photographs, medical records, witness statements)",
            "Prompt medical attention and reporting recommended",
            "Legal consultation advised within reasonable time after bite",
            "Homeowner insurance often covers dog bite claims"
        ],
        "consequence_of_violation": "Claim time-barred; court will dismiss; NO RECOVERY POSSIBLE"
    }'::jsonb,
    'error',
    'doc_verified',
    true,
    true,
    NOW(),
    NOW()
) ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    review_status = EXCLUDED.review_status,
    updated_at = NOW();

-- =====================================================================================
-- END OF MASSACHUSETTS DOG BITE RULES SEED FILE
-- =====================================================================================
