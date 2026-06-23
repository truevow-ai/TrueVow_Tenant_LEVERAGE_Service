-- =====================================================================================
-- MICHIGAN DOG BITE LIABILITY RULES SEED FILE
-- =====================================================================================
-- State: Michigan (MI)
-- Sub-Specialization: Dog Bite (Personal Injury)
-- Liability Model: STRICT LIABILITY (Statutory)
-- Legal Standard: Owner liable for dog bite without provocation on public/lawful private property
-- Primary Authority: MCL 287.351
-- Statute of Limitations: 3 years (MCL 600.5805)
-- 
-- VERIFICATION STATUS: DOCUMENT VERIFIED
-- Research Date: January 30, 2026
-- Sources Verified:
--   1. MCL 287.351 - Verified from Michigan Legislature and multiple legal sources
--   2. MCL 600.5805 - 3-year SOL
--   3. Strict liability confirmed from multiple sources
-- =====================================================================================

-- =====================================================================================
-- PART 1: LEGAL SOURCES
-- =====================================================================================

-- Source 1: Michigan Dog Bite Strict Liability Statute (MCL 287.351)
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
    'MI',
    NULL,
    NULL,
    'Michigan Dog Bite Strict Liability Statute',
    'Michigan Legislature',
    'MCL 287.351',
    'https://www.legislature.mi.gov/Laws/MCL?objectName=MCL-287-351',
    'statute',
    'high',
    'MCL 287.351 - Liability for dog bite:

If a dog bites a person, without provocation while the person is on public property, or lawfully on private property, including the property of the owner of the dog, the owner of the dog shall be liable for any damages suffered by the person bitten, regardless of the former viciousness of the dog or the owner''s knowledge of such viciousness.

A person is lawfully on the private property of the owner of the dog within the meaning of this act if the person is on the owner''s property in the performance of any duty imposed upon him or her by the laws of this state or by the laws or postal regulations of the United States, or if the person is on the owner''s property as an invitee or licensee of the person lawfully in possession of the property unless said person has gained lawful entry upon the premises for the purpose of an unlawful or criminal act.

KEY PROVISIONS:

1. STRICT LIABILITY:
   - Owner liable for dog bite WITHOUT need to prove negligence
   - Owner liable regardless of dog''s "former viciousness"
   - Owner liable regardless of owner''s knowledge of viciousness
   - NO one-bite rule in Michigan

2. REQUIREMENTS FOR LIABILITY:
   a. Dog bit person
   b. WITHOUT provocation
   c. Person was on PUBLIC property OR lawfully on PRIVATE property

3. "LAWFULLY ON PRIVATE PROPERTY" DEFINED:
   - Performing duty imposed by Michigan law or U.S. law/postal regulations (e.g., mail carrier, police officer)
   - Invitee: Person invited onto property (social guest, business visitor)
   - Licensee: Person with permission to be on property
   - INCLUDES owner''s own property (e.g., invited guest bitten at owner''s home)

4. DEFENSES (Owner NOT liable if):
   - Provocation: Victim provoked dog (even accidental provocation can be defense)
   - Trespass: Victim was NOT lawfully on property
   - Criminal act: Victim entered property for unlawful/criminal purpose

5. BROAD SCOPE:
   - Applies to ANY dog (no breed restrictions)
   - Applies on owner''s own property (not just public places)
   - Applies to first bite (no one-bite rule)
   - Does NOT require prior knowledge or warning

6. ADDITIONAL LIABILITY (Common Law):
   - Even if statutory strict liability does NOT apply, owner may be liable under common law negligence if:
     * Owner knew or should have known dog had vicious propensities
     * Owner failed to exercise reasonable care

DOCUMENT VERIFIED from Michigan Legislature (MCL 287.351) and multiple legal sources (Mike Morse Law, Macomb Injury Lawyers, Sam Bernstein Law).'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET
    base_url = EXCLUDED.base_url,
    notes = EXCLUDED.notes;

-- Source 2: Michigan Statute of Limitations - Personal Injury (MCL 600.5805)
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
    'MI',
    NULL,
    NULL,
    'Michigan Statute of Limitations - Personal Injury (Dog Bite)',
    'Michigan Legislature',
    'MCL 600.5805',
    'https://www.legislature.mi.gov/Laws/MCL?objectName=mcl-600-5805',
    'statute',
    'high',
    'MCL 600.5805 - Injuries to persons or property; period of limitations:

Except as otherwise expressly provided, the period of limitations is 3 years for all actions to recover damages for injuries to persons or property.

APPLICATION TO DOG BITES:
Claims brought under MCL 287.351 (strict liability statute) are subject to this THREE YEAR statute of limitations. The three-year period begins on the date of the dog bite injury.

EXCEPTIONS (Different SOLs):
- Assault, battery, false imprisonment: 2 years
- Medical malpractice: 2 years
- Claims against government entities: 2 years with notice requirements
- Domestic violence/criminal sexual conduct: Longer periods (5-10 years)

TOLLING PROVISIONS:
- Minors: Statute may be tolled until minor reaches age 18
- Mental incapacity: Statute may be tolled
- Discovery rule: May apply in limited circumstances

STRATEGIC NOTES:
- 3-year filing period is moderate
- Evidence preservation important
- Prompt medical attention and reporting recommended
- Owner must report bite to authorities within 24 hours
- Legal consultation advised within reasonable time after bite

DOCUMENT VERIFIED from Michigan Legislature (MCL 600.5805) and multiple legal sources.'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET
    base_url = EXCLUDED.base_url,
    notes = EXCLUDED.notes;

-- =====================================================================================
-- PART 2: VALIDATION RULES
-- =====================================================================================

-- Rule 1: Michigan Strict Liability (MCL 287.351)
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
    'MI-PI-DOG-BITE-STRICT-LIABILITY',
    5,
    'MI Dog Bite Strict Liability (MCL 287.351)',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'MI',
    '{
        "liability_model": "strict_liability",
        "statute": "MCL 287.351",
        "legal_standard": "Owner liable for dog bite without provocation while person on public property or lawfully on private property",
        "key_requirements": [
            "Dog bit plaintiff",
            "Bite was WITHOUT provocation",
            "Plaintiff was on public property OR lawfully on private property",
            "Owner is liable regardless of dog''s former viciousness",
            "Owner is liable regardless of owner''s knowledge of viciousness"
        ],
        "no_one_bite_rule": "Michigan does NOT follow one-bite rule; owner liable on first bite",
        "lawfully_on_private_property_includes": [
            "Performing duty imposed by Michigan law or U.S. law/postal regulations (mail carrier, police, utility worker)",
            "Invitee: Person invited onto property (social guest, business visitor)",
            "Licensee: Person with permission to be on property",
            "Guest at owner''s home (statute explicitly includes owner''s own property)"
        ],
        "defenses": {
            "provocation": "Victim provoked dog (even accidental provocation can be defense)",
            "trespass": "Victim was NOT lawfully on property",
            "criminal_act": "Victim entered property for unlawful or criminal purpose"
        },
        "provocation_note": "Provocation is subjective and fact-specific; can include teasing, aggressive behavior, stepping on dog, sudden movements, etc.",
        "broad_scope": {
            "any_breed": "Applies to ANY dog (no breed restrictions)",
            "owner_property": "Applies on owner''s own property (invited guests protected)",
            "first_bite": "Applies to first bite (no one-bite rule)",
            "no_prior_knowledge": "Does NOT require prior knowledge or warning"
        },
        "alternative_common_law_liability": {
            "when_applicable": "If statutory strict liability does NOT apply (e.g., provocation proven)",
            "standard": "Owner may still be liable under common law negligence",
            "requirements": [
                "Owner knew or should have known dog had vicious propensities",
                "Owner failed to exercise reasonable care"
            ]
        },
        "damages_recoverable": [
            "Medical expenses (emergency, surgery, therapy, future care)",
            "Lost wages",
            "Pain and suffering",
            "Emotional distress/mental anguish",
            "Permanent scarring/disfigurement"
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

-- Rule 2: Michigan Statute of Limitations - 3 YEARS
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
    'MI-PI-DOG-BITE-SOL-3-YEARS',
    5,
    'MI Dog Bite Statute of Limitations (3 Years)',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'MI',
    '{
        "statute": "MCL 600.5805",
        "statute_of_limitations": "3 years",
        "sol_years": 3,
        "sol_days": 1095,
        "accrual_date": "Date of dog bite injury",
        "key_requirements": [
            "Action must be commenced within 3 YEARS of dog bite",
            "Applies to claims under MCL 287.351 (strict liability)",
            "Applies to common law negligence claims",
            "Failure to file within 3 years bars recovery"
        ],
        "exceptions_different_sols": [
            "Assault, battery, false imprisonment: 2 years",
            "Medical malpractice: 2 years",
            "Claims against government entities: 2 years with notice requirements",
            "Domestic violence/criminal sexual conduct: 5-10 years"
        ],
        "tolling_provisions": [
            "Minors: Statute may be tolled until minor reaches age 18",
            "Mental incapacity: Statute may be tolled",
            "Discovery rule: May apply in limited circumstances if injury not immediately discoverable"
        ],
        "owner_reporting_requirement": "Owner must report dog bite to authorities within 24 hours (separate requirement)",
        "strategic_notes": [
            "3-year period is moderate (not shortest, not longest)",
            "Evidence preservation CRITICAL (photographs, medical records, witness statements)",
            "Prompt medical attention for health AND legal documentation",
            "Report bite to animal control/police",
            "Legal consultation advised within reasonable time"
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
-- END OF MICHIGAN DOG BITE RULES SEED FILE
-- =====================================================================================
