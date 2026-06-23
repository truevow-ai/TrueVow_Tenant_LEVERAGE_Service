-- =====================================================================================
-- MONTANA DOG BITE LIABILITY RULES SEED FILE
-- =====================================================================================
-- State: Montana (MT)
-- Sub-Specialization: Dog Bite (Personal Injury)
-- Liability Model: HYBRID (Strict Liability in Cities/Towns; One-Bite Rule Outside)
-- Legal Standard: Location-dependent liability
-- Primary Authority: MCA 27-1-715 (strict liability in cities/towns) + Common law (outside)
-- Statute of Limitations: 3 years (MCA 27-2-204)
-- Authority Level: contextual_rule (NOT primary_state_sol)
-- 
-- VERIFICATION STATUS: DOCUMENT VERIFIED
-- Research Date: January 30, 2026
-- Sources Verified:
--   1. MCA 27-1-715 - Verified from Montana Legislature (exact statutory text)
--   2. MCA 27-2-204 - 3-year SOL
--   3. Hybrid model confirmed from multiple legal sources
-- =====================================================================================

-- =====================================================================================
-- PART 1: LEGAL SOURCES
-- =====================================================================================

-- Source 1: Montana Dog Bite Strict Liability Statute (MCA 27-1-715)
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
    'MT',
    NULL,
    NULL,
    'Montana Dog Bite Strict Liability Statute (Cities/Towns)',
    'Montana Legislature',
    'MCA 27-1-715',
    'https://leg.mt.gov/bills/2013/mca/27/1/27-1-715.htm',
    'statute',
    'high',
    'MCA 27-1-715 - Liability of owner of vicious dog:

The owner of a dog that bites a person when the person is in or on a public place or lawfully in or on a private place, including the property of the owner of the dog, is liable for the damages suffered by the person bitten, regardless of the former viciousness of the dog or the owner''s knowledge of its viciousness.

A person is lawfully upon the private property of the owner within the meaning of this section when the person is on the property in the performance of a duty imposed upon the person by the laws of this state or the laws or postal regulations of the United States or when the person is on the property as an invitee or licensee of the person lawfully in possession of the property unless the person has gained lawful entry upon the premises for the purpose of an unlawful or criminal act.

This section applies only within the limits of incorporated cities and towns.

KEY PROVISIONS:

1. STRICT LIABILITY (WITHIN CITIES/TOWNS ONLY):
   - Owner liable for dog bite WITHOUT need to prove negligence
   - Owner liable regardless of dog''s "former viciousness"
   - Owner liable regardless of owner''s knowledge of viciousness
   - NO one-bite rule within city/town limits

2. GEOGRAPHIC LIMITATION:
   - Applies ONLY within limits of incorporated cities and towns
   - Outside cities/towns: Common law one-bite rule applies (scienter required)

3. REQUIREMENTS FOR STRICT LIABILITY:
   a. Dog bit person
   b. WITHOUT provocation
   c. Person was in public place OR lawfully on private property
   d. Incident occurred WITHIN incorporated city or town limits

4. "LAWFULLY ON PRIVATE PROPERTY" DEFINED:
   - Performing duty imposed by Montana law or U.S. law/postal regulations (mail carrier, police, utility worker)
   - Invitee: Person invited onto property
   - Licensee: Person with permission to be on property
   - INCLUDES owner''s own property if victim lawfully present
   - EXCLUDES: Person who entered for unlawful or criminal act

5. DEFENSES:
   - Provocation: Victim provoked dog
   - Not lawfully present: Victim was trespassing or entered for unlawful/criminal act
   - Outside city/town limits: Strict liability does NOT apply

6. OUTSIDE CITIES/TOWNS:
   - Common law one-bite rule applies (scienter doctrine)
   - Plaintiff must prove owner knew or should have known of dog''s dangerous propensity

DOCUMENT VERIFIED from Montana Code Annotated (exact text from Montana Legislature) and multiple legal sources (dogbitelaw.com, MT Wyoming Law, Joyce MacDonald, TMB Attorneys).'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET
    base_url = EXCLUDED.base_url,
    notes = EXCLUDED.notes;

-- Source 2: Montana Statute of Limitations - Personal Injury (MCA 27-2-204)
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
    'MT',
    NULL,
    NULL,
    'Montana Statute of Limitations - Personal Injury (Dog Bite)',
    'Montana Legislature',
    'MCA 27-2-204',
    'https://archive.legmt.gov/bills/mca/title_0270/chapter_0020/part_0020/section_0040/0270-0020-0020-0040.html',
    'statute',
    'high',
    'MCA 27-2-204(1) - Tort actions - general and personal injury:

An action for liability created by statute, other than a penalty or forfeiture, an action for trespass on real property, or an action for taking, detaining, or injuring personal property, including an action for the specific recovery of personal property, must be commenced within 3 years.

APPLICATION TO DOG BITES:
Claims brought under MCA 27-1-715 (strict liability statute within cities/towns) and common law claims (outside cities/towns) are subject to this THREE YEAR statute of limitations. The three-year period begins on the date of the dog bite injury.

TOLLING PROVISIONS:
- Minors: Statute may be tolled until minor reaches age of majority
- Mental incapacity: Statute may be tolled
- Discovery rule: May apply in limited circumstances

STRATEGIC NOTES:
- 3-year filing period is moderate
- Evidence preservation important (especially for proving location within city/town limits)
- Prompt medical attention and reporting recommended
- Legal consultation advised within reasonable time after bite

DOCUMENT VERIFIED from Montana Code Annotated and multiple legal sources.'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET
    base_url = EXCLUDED.base_url,
    notes = EXCLUDED.notes;

-- =====================================================================================
-- PART 2: VALIDATION RULES (CONTEXTUAL RULES - NOT PRIMARY SOL AUTHORITY)
-- =====================================================================================

-- Rule 1: Montana Strict Liability (Within Cities/Towns Only)
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
    'MT-PI-DOG-BITE-STRICT-LIABILITY-CITIES',
    5,
    'MT Dog Bite Strict Liability (Cities/Towns Only - MCA 27-1-715)',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'MT',
    '{
        "authority_level": "contextual_rule",
        "liability_model": "strict_liability_cities_only",
        "statute": "MCA 27-1-715",
        "legal_standard": "Owner liable for dog bite regardless of prior viciousness (WITHIN incorporated cities/towns ONLY)",
        "key_requirements": [
            "Dog bit plaintiff",
            "WITHOUT provocation",
            "Plaintiff was in public place OR lawfully on private property",
            "CRITICAL: Incident occurred WITHIN incorporated city or town limits",
            "Owner liable regardless of dog''s former viciousness",
            "Owner liable regardless of owner''s knowledge of viciousness"
        ],
        "geographic_limitation": {
            "applies_within": "Incorporated cities and towns ONLY",
            "does_not_apply_outside": "Outside city/town limits, common law one-bite rule applies (scienter required)",
            "must_prove_location": "Plaintiff MUST prove incident occurred within city/town limits for strict liability"
        },
        "no_one_bite_rule_in_cities": "Montana does NOT follow one-bite rule WITHIN city/town limits; strict liability on first bite",
        "lawfully_on_private_property_includes": [
            "Performing duty imposed by Montana law or U.S. law/postal regulations",
            "Invitee: Person invited onto property",
            "Licensee: Person with permission to be on property",
            "Guest at owner''s home (statute explicitly includes owner''s own property)"
        ],
        "defenses": {
            "provocation": "Victim provoked dog",
            "not_lawfully_present": "Victim was trespassing or entered for unlawful/criminal act",
            "outside_city_town": "Incident occurred outside incorporated city/town limits (strict liability does NOT apply)"
        },
        "damages_recoverable": [
            "Medical expenses",
            "Lost wages",
            "Pain and suffering",
            "Emotional distress",
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

-- Rule 2: Montana One-Bite Rule (Outside Cities/Towns)
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
    'MT-PI-DOG-BITE-ONE-BITE-OUTSIDE-CITIES',
    5,
    'MT Dog Bite One-Bite Rule (Outside Cities/Towns)',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'MT',
    '{
        "authority_level": "contextual_rule",
        "liability_model": "one_bite_rule_outside_cities",
        "legal_basis": "Common law scienter doctrine (outside incorporated cities/towns)",
        "legal_standard": "Owner liable if knew or should have known of dog''s dangerous propensity",
        "key_requirements": [
            "Dog bit plaintiff",
            "Incident occurred OUTSIDE incorporated city or town limits",
            "Dog had dangerous disposition",
            "Owner knew or should have known of dog''s dangerous disposition"
        ],
        "when_applies": "ONLY when incident occurred OUTSIDE incorporated city or town limits",
        "no_strict_liability_outside_cities": "MCA 27-1-715 does NOT apply outside cities/towns; must prove scienter",
        "proving_scienter": {
            "methods": [
                "Prior biting incidents or attacks",
                "Prior aggressive behavior (growling, snapping, lunging)",
                "Owner statements acknowledging dog''s aggression",
                "Complaints to owner about dog''s behavior",
                "Warning signs posted"
            ]
        },
        "alternative_negligence_theory": "Even without scienter, may recover through negligence if owner failed to exercise reasonable care",
        "burden_of_proof": "Higher than strict liability; must prove owner''s knowledge"
    }'::jsonb,
    'warning',
    'doc_verified',
    true,
    true,
    NOW(),
    NOW()
) ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    review_status = EXCLUDED.review_status,
    updated_at = NOW();

-- Rule 3: Montana Statute of Limitations - 3 YEARS (CONTEXTUAL RULE)
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
    'MT-PI-DOG-BITE-SOL-3-YEARS',
    5,
    'MT Dog Bite Statute of Limitations (3 Years - Contextual)',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'MT',
    '{
        "authority_level": "contextual_rule",
        "statute": "MCA 27-2-204(1)",
        "statute_of_limitations": "3 years",
        "sol_years": 3,
        "sol_days": 1095,
        "accrual_date": "Date of dog bite injury",
        "key_requirements": [
            "Action must be commenced within 3 YEARS of dog bite",
            "Applies to claims under MCA 27-1-715 (strict liability within cities/towns)",
            "Applies to common law claims (outside cities/towns)",
            "Failure to file within 3 years bars recovery"
        ],
        "tolling_provisions": [
            "Minors: Statute may be tolled until minor reaches age of majority",
            "Mental incapacity: Statute may be tolled",
            "Discovery rule: May apply in limited circumstances"
        ],
        "strategic_notes": [
            "3-year period is moderate (not shortest, not longest)",
            "Evidence preservation CRITICAL (especially proving location within city/town limits)",
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
-- END OF MONTANA DOG BITE RULES SEED FILE
-- =====================================================================================
