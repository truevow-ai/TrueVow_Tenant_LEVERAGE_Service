-- =====================================================================================
-- HAWAII DOG BITE LIABILITY RULES SEED FILE
-- =====================================================================================
-- State: Hawaii (HI)
-- Sub-Specialization: Dog Bite (Personal Injury)
-- Liability Model: STRICT LIABILITY (Statutory - regardless of prior viciousness)
-- Legal Standard: Owner/harborer liable for damages regardless of knowledge of viciousness
-- Primary Authority: HRS § 663-9 (liability) and § 663-9.1 (exceptions)
-- Statute of Limitations: 2 years (HRS § 657-7)
-- 
-- VERIFICATION STATUS: DOCUMENT VERIFIED
-- Research Date: January 30, 2026
-- Sources Verified:
--   1. HRS § 663-9 - Verified from multiple legal sources (Justia, animallaw.info, dogbitelaw.com)
--   2. HRS § 663-9.1 - Exception provisions verified
--   3. HRS § 657-7 - 2-year SOL for personal injury
-- =====================================================================================

-- =====================================================================================
-- PART 1: LEGAL SOURCES
-- =====================================================================================

-- Source 1: Hawaii Animal Owner Strict Liability Statute (HRS § 663-9)
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
    'HI',
    NULL,
    NULL,
    'Hawaii Animal Owner Strict Liability Statute',
    'Hawaii Legislature',
    'HRS § 663-9',
    'https://law.justia.com/codes/hawaii/title-36/chapter-663/section-663-9/',
    'statute',
    'high',
    'HRS § 663-9 - Liability of animal owners:

(a) The owner or harborer of an animal, if the animal proximately causes either personal or property damage to any person, shall be liable in damages to the person injured, regardless of the owner''s or harborer''s lack of scienter or knowledge of, or the animal''s lack of, vicious or dangerous tendencies or propensities.

(b) If the animal is by nature or species and by its own specific nature dangerous, wild, or vicious, the owner or harborer thereof shall be absolutely liable for any and all damage proximately caused by the animal.

KEY PROVISIONS:
- STRICT LIABILITY: Owner or harborer liable REGARDLESS of lack of knowledge of vicious or dangerous tendencies
- NO ONE-BITE RULE: Liability attaches even on first bite without prior aggressive behavior
- APPLIES TO ALL ANIMALS: Not limited to dogs (includes any animal)
- PROXIMATE CAUSE REQUIREMENT: Animal must proximately cause the damage
- TWO TIERS OF LIABILITY:
  (a) GENERAL STRICT LIABILITY: Liable for damages regardless of lack of scienter (knowledge)
  (b) ABSOLUTE LIABILITY: If animal is dangerous/wild/vicious by nature or species, owner is ABSOLUTELY liable
- OWNER OR HARBORER: Liability extends to anyone who owns OR harbors the animal
- COVERS PERSONAL INJURY AND PROPERTY DAMAGE

INTERPRETATION NOTES:
- Some sources (dogbitelaw.com) argue Hawaii is actually a "one-bite" state based on case law interpretation
- However, statutory text clearly states "regardless of...lack of scienter or knowledge"
- HRS § 663-9.1 provides exceptions (trespassing, teasing/tormenting)
- Most Hawaii courts and attorneys treat this as strict liability statute

DOCUMENT VERIFIED from multiple legal sources (Justia, animallaw.info, Davis Levin, Lowenthal).'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET
    base_url = EXCLUDED.base_url,
    notes = EXCLUDED.notes;

-- Source 2: Hawaii Exceptions to Animal Owner Liability (HRS § 663-9.1)
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
    'HI',
    NULL,
    NULL,
    'Hawaii Exceptions to Animal Owner Liability',
    'Hawaii Legislature',
    'HRS § 663-9.1',
    'https://law.justia.com/codes/hawaii/title-36/chapter-663/section-663-9-1/',
    'statute',
    'high',
    'HRS § 663-9.1 - Exception of liability of animal owners or harborers:

Notwithstanding section 663-9, an owner or harborer of any animal is not liable in damages for injury suffered by any other person if the injury is proximately caused by:

(1) The person suffering the injury being unlawfully on the premises; or
(2) The animal being teased, tormented, or abused by the person suffering the injury, and the owner or harborer of the animal did not allow or assist in such teasing, tormenting, or abusing.

DEFINITIONS (from HRS § 663-9.1):
- "Enter or remain unlawfully": A person enters or remains unlawfully on the premises when the person is not licensed, invited, or otherwise privileged to do so
- "Premises": Includes any building and any real property

KEY EXCEPTIONS - NO LIABILITY IF:
(1) TRESPASSING: Victim was unlawfully on the premises (not licensed, invited, or privileged to be there)
(2) TEASING/TORMENTING/ABUSING: Animal was teased, tormented, or abused by victim AND owner did not allow or assist in such conduct

BURDEN OF PROOF: Owner must prove exception applies (affirmative defense)

CRITICAL DISTINCTION:
- Strict liability under § 663-9 is DEFAULT rule
- Exceptions under § 663-9.1 are AFFIRMATIVE DEFENSES
- Owner bears burden to prove victim was trespassing or teasing/tormenting

DOCUMENT VERIFIED from Justia and animallaw.info.'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET
    base_url = EXCLUDED.base_url,
    notes = EXCLUDED.notes;

-- Source 3: Hawaii Statute of Limitations - Personal Injury (HRS § 657-7)
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
    'HI',
    NULL,
    NULL,
    'Hawaii Statute of Limitations - Personal Injury (Dog Bite)',
    'Hawaii Legislature',
    'HRS § 657-7',
    'https://www.capitol.hawaii.gov/hrscurrent/Vol13_Ch0601-0676/HRS0657/HRS_0657-0007.htm',
    'statute',
    'high',
    'HRS § 657-7 - Actions for injury to person or property; statutory liability:

Actions for injury or damage to persons or property shall be instituted within two years after the cause of action accrued, and not after.

APPLICATION TO DOG BITES:
Claims brought under HRS § 663-9 (strict liability statute) are subject to this TWO YEAR statute of limitations. The two-year period begins on the date of the dog bite injury.

ACCRUAL: Cause of action generally accrues when the injured party discovers or should have discovered the injury, the negligent act or omission, and the causal connection between the act or omission and the injury.

TOLLING PROVISIONS:
- Minors: Statute may be tolled until minor reaches age of majority
- Disability: Tolling may apply for mental incapacity
- Defendant absence: Time may be tolled
- Discovery rule: Limited tolling if injury is latent

STRATEGIC NOTES:
- Must file within 2 years from date of injury
- Evidence preservation critical
- Prompt reporting and documentation essential

DOCUMENT VERIFIED from Hawaii Legislature and multiple legal sources.'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET
    base_url = EXCLUDED.base_url,
    notes = EXCLUDED.notes;

-- =====================================================================================
-- PART 2: VALIDATION RULES
-- =====================================================================================

-- Rule 1: Hawaii Strict Liability (HRS § 663-9)
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
    'HI-PI-DOG-BITE-STRICT-LIABILITY',
    5,
    'HI Dog Bite Strict Liability (HRS § 663-9)',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'HI',
    NULL,
    NULL,
    '{
        "liability_model": "strict_liability",
        "statute": "HRS § 663-9",
        "legal_standard": "Owner/harborer liable regardless of lack of knowledge of vicious or dangerous tendencies",
        "key_requirements": [
            "Animal proximately caused personal injury or property damage",
            "Defendant was owner or harborer of animal",
            "Owner/harborer liable REGARDLESS of lack of scienter (knowledge)",
            "Owner/harborer liable REGARDLESS of animal''s lack of vicious or dangerous tendencies",
            "No proof of prior aggressive behavior required",
            "No proof of owner negligence required"
        ],
        "two_tiers_of_liability": {
            "tier_1_general_strict_liability": {
                "statute": "HRS § 663-9(a)",
                "standard": "Liable regardless of lack of scienter or knowledge",
                "applies_to": "All animals that proximately cause damage"
            },
            "tier_2_absolute_liability": {
                "statute": "HRS § 663-9(b)",
                "standard": "ABSOLUTELY liable for any and all damage",
                "applies_to": "Animals dangerous, wild, or vicious by nature or species"
            }
        },
        "no_one_bite_rule": "Hawaii does NOT follow one-bite rule; strict liability on first bite",
        "owner_or_harborer": "Liability extends to anyone who owns OR harbors the animal",
        "damages_recoverable": [
            "Personal injury damages",
            "Property damage",
            "Medical expenses",
            "Lost wages",
            "Pain and suffering",
            "Emotional trauma",
            "Permanent scarring/disfigurement"
        ],
        "exceptions_see_rule": "HI-PI-DOG-BITE-EXCEPTIONS (HRS § 663-9.1)"
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

-- Rule 2: Hawaii Exceptions to Strict Liability (HRS § 663-9.1)
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
    'HI-PI-DOG-BITE-EXCEPTIONS',
    5,
    'HI Dog Bite Exceptions to Strict Liability (HRS § 663-9.1)',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'HI',
    NULL,
    NULL,
    '{
        "statute": "HRS § 663-9.1",
        "defense_type": "exceptions_to_strict_liability",
        "owner_not_liable_if": [
            "(1) Person suffering injury was unlawfully on premises (trespassing), OR",
            "(2) Animal was teased, tormented, or abused by person suffering injury AND owner did not allow or assist in such conduct"
        ],
        "exception_1_trespassing": {
            "definition": "Person enters or remains unlawfully when not licensed, invited, or otherwise privileged to be on premises",
            "premises_includes": "Any building and any real property",
            "burden_of_proof": "Owner must prove victim was trespassing",
            "affirmative_defense": "Trespassing is affirmative defense; owner bears burden"
        },
        "exception_2_teasing_tormenting_abusing": {
            "requirements": [
                "Animal was teased, tormented, or abused by victim",
                "Owner did NOT allow such conduct",
                "Owner did NOT assist in such conduct"
            ],
            "burden_of_proof": "Owner must prove victim teased/tormented/abused animal",
            "affirmative_defense": "Teasing/tormenting is affirmative defense; owner bears burden",
            "examples": [
                "Hitting or striking animal",
                "Taunting or provoking animal",
                "Intentionally frightening animal",
                "Causing pain or distress to animal"
            ]
        },
        "strategic_drafting": [
            "Complaint should explicitly allege plaintiff was lawfully on premises",
            "Complaint should explicitly allege plaintiff did NOT tease, torment, or abuse animal",
            "Anticipate affirmative defenses and address proactively",
            "Gather witness testimony that plaintiff was lawful and peaceful",
            "Document plaintiff''s lawful status (invited guest, mail carrier, etc.)"
        ],
        "default_rule": "Strict liability under § 663-9 is DEFAULT; exceptions are AFFIRMATIVE DEFENSES with burden on owner"
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

-- Rule 3: Hawaii Statute of Limitations - 2 Years
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
    'HI-PI-DOG-BITE-SOL-2-YEARS',
    5,
    'HI Dog Bite Statute of Limitations (2 Years)',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'HI',
    NULL,
    NULL,
    '{
        "statute": "HRS § 657-7",
        "statute_of_limitations": "2 years",
        "accrual_date": "Date the cause of action accrued (generally date of dog bite injury)",
        "key_requirements": [
            "Action must be instituted within 2 years after cause of action accrued",
            "Applies to claims under HRS § 663-9 (strict liability)",
            "Applies to injury or damage to persons or property",
            "Failure to file within 2 years bars recovery"
        ],
        "accrual_rule": "Cause of action generally accrues when injured party discovers or should have discovered: (1) the injury, (2) the negligent act or omission, and (3) the causal connection",
        "tolling_provisions": [
            "Minors: Statute may be tolled until minor reaches age of majority",
            "Disability: Tolling may apply for mental incapacity",
            "Defendant absence: Time may be tolled",
            "Discovery rule: Limited tolling if injury is latent"
        ],
        "strategic_notes": [
            "Evidence preservation critical (photographs, witness statements, medical records)",
            "Prompt reporting to authorities important",
            "Early legal consultation preserves rights"
        ],
        "consequence_of_violation": "Claim time-barred; court will dismiss case; no recovery of any damages"
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

-- =====================================================================================
-- END OF HAWAII DOG BITE RULES SEED FILE
-- =====================================================================================
