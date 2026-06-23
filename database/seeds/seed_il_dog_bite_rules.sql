-- =====================================================================================
-- ILLINOIS DOG BITE LIABILITY RULES SEED FILE
-- =====================================================================================
-- State: Illinois (IL)
-- Sub-Specialization: Dog Bite (Personal Injury)
-- Liability Model: STRICT LIABILITY (Statutory - Animal Control Act)
-- Legal Standard: Owner liable for full amount of injury if animal attacks without provocation
-- Primary Authority: 510 ILCS 5/16 (Animal Control Act)
-- Statute of Limitations: 2 years (735 ILCS 5/13-202)
-- 
-- VERIFICATION STATUS: DOCUMENT VERIFIED
-- Research Date: January 30, 2026
-- Sources Verified:
--   1. 510 ILCS 5/16 - Verified from Illinois Legislature and multiple legal sources
--   2. 735 ILCS 5/13-202 - 2-year SOL for personal injury
--   3. Minors: SOL extended until age 20 (2 years after reaching majority)
-- =====================================================================================

-- =====================================================================================
-- PART 1: LEGAL SOURCES
-- =====================================================================================

-- Source 1: Illinois Animal Control Act - Strict Liability (510 ILCS 5/16)
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
    'IL',
    NULL,
    NULL,
    'Illinois Animal Control Act - Dog Bite Strict Liability',
    'Illinois General Assembly',
    '510 ILCS 5/16',
    'https://www.ilga.gov/legislation/ilcs/fulltext.asp?DocName=051000050K16',
    'statute',
    'high',
    '510 ILCS 5/16 - Liability for injury caused by animal:

If a dog or other animal, without provocation, attacks, attempts to attack, or injures any person who is peaceably conducting himself or herself in any place where he or she may lawfully be, the owner of such dog or other animal is liable in civil damages to such person for the full amount of the injury proximately caused thereby.

KEY PROVISIONS:
- STRICT LIABILITY: Owner liable regardless of negligence or prior knowledge of vicious propensities
- NO ONE-BITE RULE: Liability attaches even on first bite without prior aggressive behavior
- "WITHOUT PROVOCATION": Attack must be unprovoked by victim
- LAWFUL PRESENCE REQUIREMENT: Victim must be "peaceably conducting himself or herself in any place where he or she may lawfully be"
- BROAD DEFINITION OF "OWNER": Includes anyone with property rights, care, or custody of animal (even temporary caretakers like dog-sitters)
- FULL AMOUNT OF INJURY: Owner liable for full amount of injury proximately caused by animal
- APPLIES TO ALL ANIMALS: Not limited to dogs (includes any animal)

PROVOCATION (COMPLETE DEFENSE):
- Provocation is a COMPLETE DEFENSE (not comparative reduction)
- If owner proves victim provoked animal, NO liability
- Examples: Hitting, teasing, tormenting, threatening animal

LAWFUL PRESENCE:
- Victim must be lawfully present at location of attack
- Trespassing defeats strict liability
- "Peaceably conducting" requires lawful, non-threatening conduct

DOCUMENTS VERIFIED from Illinois General Assembly website and multiple legal sources (Pullano Law, BC Firm, Malm Legal).'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET
    base_url = EXCLUDED.base_url,
    notes = EXCLUDED.notes;

-- Source 2: Illinois Statute of Limitations - Personal Injury (735 ILCS 5/13-202)
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
    'IL',
    NULL,
    NULL,
    'Illinois Statute of Limitations - Personal Injury (Dog Bite)',
    'Illinois General Assembly',
    '735 ILCS 5/13-202',
    'https://www.ilga.gov/legislation/ilcs/ilcs3.asp?ActID=2017&ChapterID=56',
    'statute',
    'high',
    '735 ILCS 5/13-202 - Statute of limitations for personal injury actions:

Actions for injury to the person shall be commenced within two years next after the cause of action accrued.

APPLICATION TO DOG BITES:
Claims brought under 510 ILCS 5/16 (strict liability statute) are subject to this TWO YEAR statute of limitations. The two-year period begins on the date of the dog bite/attack.

SPECIAL RULE FOR MINORS:
If victim is under age 18 at time of attack, the two-year period does NOT begin until victim''s 18th birthday. Thus, minor victims have until their 20th birthday to file suit.

ACCRUAL: Cause of action accrues on date of injury (date of dog bite/attack).

TOLLING PROVISIONS:
- Minors: Statute tolled until age 18 (effectively gives until age 20)
- Discovery rule: Limited tolling if injury latent or inherently unknowable
- Defendant absence: Time may be tolled

STRATEGIC NOTES:
- Must file within 2 years from date of attack (adults)
- Must file by age 20 (if minor at time of attack)
- Evidence preservation critical
- Prompt reporting and medical documentation essential

DOCUMENT VERIFIED from Illinois statutes and multiple legal sources.'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET
    base_url = EXCLUDED.base_url,
    notes = EXCLUDED.notes;

-- =====================================================================================
-- PART 2: VALIDATION RULES
-- =====================================================================================

-- Rule 1: Illinois Strict Liability (510 ILCS 5/16)
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
        'IL-DOG-BITE-STRICT-LIABILITY',
    5,
    'IL Dog Bite Strict Liability (510 ILCS 5/16)',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'IL',
    NULL,
    NULL,
    '{
        "liability_model": "strict_liability",
        "statute": "510 ILCS 5/16",
        "authority_level": "contextual_rule",
        "legal_standard": "Owner liable for full amount of injury if animal attacks, attempts to attack, or injures person without provocation",
        "key_requirements": [
            "Dog or other animal attacked, attempted to attack, or injured plaintiff",
            "Attack was without provocation",
            "Plaintiff was peaceably conducting himself/herself",
            "Plaintiff was in place where he/she may lawfully be",
            "Defendant was owner of such animal",
            "Owner is liable for full amount of injury proximately caused"
        ],
        "no_one_bite_rule": "Illinois does NOT follow one-bite rule; strict liability on first bite",
        "no_prior_knowledge_required": "Owner liable regardless of lack of knowledge of animal''s vicious propensities",
        "broad_owner_definition": "''Owner'' includes anyone with property rights, care, or custody of animal, including temporary caretakers (dog-sitters, relatives)",
        "without_provocation": {
            "requirement": "Attack must be unprovoked by victim",
            "complete_defense": "Provocation is COMPLETE DEFENSE (not comparative reduction)",
            "burden": "Owner must prove victim provoked animal",
            "examples": [
                "Hitting or striking animal",
                "Teasing or tormenting animal",
                "Threatening animal",
                "Aggressive behavior toward animal"
            ]
        },
        "lawful_presence": {
            "requirement": "Victim must be peaceably conducting himself/herself in place where lawfully present",
            "trespassing_defeats_liability": "If victim trespassing, strict liability does NOT apply (may still pursue negligence claim)",
            "peaceably_conducting": "Victim must be conducting himself/herself in lawful, peaceful manner"
        },
        "applies_to_all_animals": "Statute applies to dogs AND other animals",
        "damages_recoverable": [
            "Full amount of injury proximately caused",
            "Medical expenses",
            "Future medical care",
            "Lost wages",
            "Lost earning capacity",
            "Pain and suffering",
            "Emotional distress",
            "Permanent scarring/disfigurement",
            "Wrongful death damages"
        ]
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

-- Rule 2: Illinois Statute of Limitations - 2 Years (Adults) / Age 20 (Minors)
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
    'IL-DOG-BITE-SOL',
    5,
    'IL Dog Bite Statute of Limitations (2 Years / Age 20 for Minors)',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'IL',
    NULL,
    NULL,
    '{
        "statute": "735 ILCS 5/13-202",
        "authority_level": "contextual_rule",
        "statute_of_limitations": "2 years (adults); until age 20 (minors)",
        "accrual_date": "Date cause of action accrued (date of dog bite/attack)",
        "key_requirements": [
            "Action must be commenced within 2 years of dog bite (for adults)",
            "Action must be commenced by age 20 (if minor at time of attack)",
            "Applies to claims under 510 ILCS 5/16 (strict liability)",
            "Failure to file timely bars recovery"
        ],
        "adult_victims": {
            "deadline": "2 years from date of dog bite/attack",
            "accrual": "Begins on date of injury",
            "consequence": "If not filed within 2 years, claim time-barred"
        },
        "minor_victims": {
            "deadline": "Until victim''s 20th birthday",
            "tolling": "2-year period does NOT begin until victim reaches age 18",
            "example": "If bitten at age 10, must file by age 20 (10 years to file)",
            "strategic_note": "Minors have significantly more time to file than adults"
        },
        "tolling_provisions": [
            "Minors: Statute tolled until age 18 (effectively gives until age 20)",
            "Discovery rule: Limited tolling if injury latent or inherently unknowable",
            "Defendant absence: Time may be tolled"
        ],
        "strategic_notes": [
            "Evidence preservation critical (photographs, witness statements, medical records)",
            "Prompt medical attention and reporting important",
            "Document injuries and treatment immediately",
            "Identify dog owner and witnesses promptly",
            "Minor victims should still act promptly despite extended deadline"
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

-- Rule 3: Illinois Alternative Negligence Theory (When Strict Liability Unavailable)
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
    'IL-DOG-BITE-NEGLIGENCE',
    5,
    'IL Dog Bite Negligence Theory (Alternative to Strict Liability)',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'IL',
    NULL,
    NULL,
    '{
        "liability_model": "negligence",
        "authority_level": "contextual_rule",
        "when_to_use": "When strict liability under 510 ILCS 5/16 is unavailable (e.g., victim provoked dog OR victim was trespassing)",
        "legal_standard": "Owner liable if owner''s unreasonable conduct caused injury",
        "key_requirements": [
            "Owner owed duty of care to plaintiff",
            "Owner breached that duty (unreasonable conduct)",
            "Breach proximately caused plaintiff''s injury",
            "Plaintiff suffered damages"
        ],
        "unreasonable_conduct_examples": [
            "Owner knew or should have known of dog''s dangerous propensities and failed to take reasonable precautions",
            "Owner violated leash law or local ordinance",
            "Owner failed to properly restrain known aggressive dog",
            "Owner failed to warn of known danger",
            "Owner allowed dog to roam free despite knowledge of aggression"
        ],
        "comparative_fault": "Illinois follows modified comparative negligence; plaintiff cannot recover if more than 50% at fault",
        "strategic_use": [
            "Plead strict liability (510 ILCS 5/16) as primary claim",
            "Plead negligence as alternative theory in case provocation/trespassing defeats strict liability",
            "Negligence allows recovery even if provocation/trespassing shown, if owner''s conduct was unreasonable"
        ],
        "burden_of_proof": "Plaintiff must prove all elements of negligence (higher burden than strict liability)"
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

-- =====================================================================================
-- END OF ILLINOIS DOG BITE RULES SEED FILE
-- =====================================================================================
