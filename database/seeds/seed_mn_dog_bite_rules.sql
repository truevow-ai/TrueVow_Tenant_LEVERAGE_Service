-- =====================================================================================
-- MINNESOTA DOG BITE LIABILITY RULES SEED FILE
-- =====================================================================================
-- State: Minnesota (MN)
-- Sub-Specialization: Dog Bite (Personal Injury)
-- Liability Model: STRICT LIABILITY (Statutory)
-- Legal Standard: Owner liable for dog attack/injury without provocation
-- Primary Authority: Minn. Stat. § 347.22
-- Statute of Limitations: 6 years (Minn. Stat. § 541.05, Subd. 1(5)) - ONE OF LONGEST IN NATION
-- Authority Level: contextual_rule (NOT primary_state_sol)
-- 
-- VERIFICATION STATUS: DOCUMENT VERIFIED
-- Research Date: January 30, 2026
-- Sources Verified:
--   1. Minn. Stat. § 347.22 - Verified from Minnesota Revisor (exact statutory text)
--   2. Minn. Stat. § 541.05, Subd. 1(5) - 6-year SOL
--   3. Strict liability confirmed from multiple legal sources
-- =====================================================================================

-- =====================================================================================
-- PART 1: LEGAL SOURCES
-- =====================================================================================

-- Source 1: Minnesota Dog Bite Strict Liability Statute (Minn. Stat. § 347.22)
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
    'MN',
    NULL,
    NULL,
    'Minnesota Dog Bite Strict Liability Statute',
    'Minnesota Legislature',
    'Minn. Stat. § 347.22',
    'https://www.revisor.mn.gov/statutes/cite/347.22',
    'statute',
    'high',
    'Minn. Stat. § 347.22 - DAMAGES, OWNER LIABLE:

If a dog, without provocation, attacks or injures any person who is acting peaceably in any place where the person may lawfully be, the owner of the dog is liable in damages to the person so attacked or injured to the full amount of the injury sustained.

The term "owner" includes any person harboring or keeping a dog but the owner shall be primarily liable.

The term "dog" includes both male and female of the canine species.

KEY PROVISIONS:

1. STRICT LIABILITY:
   - Owner liable for "full amount of injury sustained"
   - NO requirement to prove owner knew dog was dangerous
   - NO one-bite rule
   - Liability regardless of owner''s negligence or prior knowledge

2. REQUIREMENTS FOR LIABILITY:
   a. Dog attacked or injured person (includes non-bite injuries)
   b. WITHOUT provocation
   c. Person was acting peaceably
   d. Person was in place where person may lawfully be

3. "OWNER" BROADLY DEFINED:
   - Includes legal owner
   - Includes "any person harboring or keeping a dog"
   - Primary liability on actual owner
   - Harborer/keeper can be secondarily liable

4. "ATTACKS OR INJURES" (BROAD SCOPE):
   - Includes bites
   - Includes non-bite attacks (jumping, knocking down, scratching)
   - Even if dog does NOT attack, liability if dog "injures" (e.g., bumps into person causing fall)

5. DEFENSES (Owner NOT liable if):
   - Provocation: Victim provoked dog
   - Not acting peaceably: Victim was NOT acting peaceably
   - Not lawfully present: Victim was trespassing or NOT lawfully in place

6. NO COMPARATIVE FAULT:
   - Minnesota does NOT apply comparative fault to dog bite claims under § 347.22
   - This is MORE favorable to victims than most states

DOCUMENT VERIFIED from Minnesota Statutes (exact text from Minnesota Revisor 2025) and multiple legal sources (Patterson Dahlberg, Goss Law, Nolo).'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET
    base_url = EXCLUDED.base_url,
    notes = EXCLUDED.notes;

-- Source 2: Minnesota Statute of Limitations - Personal Injury (Minn. Stat. § 541.05)
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
    'MN',
    NULL,
    NULL,
    'Minnesota Statute of Limitations - Personal Injury (Dog Bite)',
    'Minnesota Legislature',
    'Minn. Stat. § 541.05, Subd. 1(5)',
    'https://www.revisor.mn.gov/statutes/cite/541.05',
    'statute',
    'high',
    'Minn. Stat. § 541.05, Subd. 1(5) - Six years limitations:

Except where the uniform commercial code otherwise prescribes, the following actions shall be commenced within six years: ... (5) for any other injury to the person or rights of another, not arising on contract, and not hereinafter enumerated.

APPLICATION TO DOG BITES:
Claims brought under Minn. Stat. § 347.22 (strict liability statute) are subject to this SIX YEAR statute of limitations. The six-year period begins on the date of the dog bite injury.

ONE OF LONGEST SOLs IN NATION:
Minnesota''s 6-year SOL is one of the LONGEST in the United States for personal injury claims. Only Maine and North Dakota also have 6-year SOLs. Most states have 2-3 year SOLs.

TOLLING PROVISIONS:
- Minors: Statute tolled until minor reaches age 18
- Mental incapacity: Statute may be tolled
- Discovery rule: May apply in limited circumstances

STRATEGIC ADVANTAGE:
The lengthy 6-year SOL gives victims significant time to:
- Recover from injuries and assess long-term damages
- Negotiate with insurance companies
- Gather evidence and witness testimony
- Consult with attorneys
- Avoid rushed settlement decisions

DOCUMENT VERIFIED from Minnesota Statutes and multiple legal sources.'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET
    base_url = EXCLUDED.base_url,
    notes = EXCLUDED.notes;

-- =====================================================================================
-- PART 2: VALIDATION RULES (CONTEXTUAL RULES - NOT PRIMARY SOL AUTHORITY)
-- =====================================================================================

-- Rule 1: Minnesota Strict Liability (Minn. Stat. § 347.22)
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
    'MN-PI-DOG-BITE-STRICT-LIABILITY',
    5,
    'MN Dog Bite Strict Liability (Minn. Stat. § 347.22)',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'MN',
    '{
        "authority_level": "contextual_rule",
        "liability_model": "strict_liability",
        "statute": "Minn. Stat. § 347.22",
        "legal_standard": "Owner liable for dog attack/injury without provocation while person acting peaceably in lawful place",
        "key_requirements": [
            "Dog attacked or injured plaintiff",
            "Attack/injury was WITHOUT provocation",
            "Plaintiff was acting peaceably",
            "Plaintiff was in place where plaintiff may lawfully be",
            "Owner is liable for FULL amount of injury sustained"
        ],
        "no_one_bite_rule": "Minnesota does NOT follow one-bite rule; owner liable on first bite/injury",
        "no_prior_knowledge_required": "Owner liable regardless of lack of knowledge of dog''s dangerous propensities",
        "broad_owner_definition": {
            "owner": "Legal owner of dog (primarily liable)",
            "harborer": "Any person harboring dog (secondarily liable)",
            "keeper": "Any person keeping dog (secondarily liable)"
        },
        "attacks_or_injures_broad_scope": {
            "includes_bites": true,
            "includes_non_bite_attacks": "Jumping, knocking down, scratching",
            "includes_injuries_without_attack": "Even if dog does NOT attack, liability if dog injures (e.g., bumps into person causing fall)"
        },
        "defenses": {
            "provocation": "Victim provoked dog",
            "not_acting_peaceably": "Victim was NOT acting peaceably",
            "not_lawfully_present": "Victim was trespassing or NOT lawfully in place"
        },
        "no_comparative_fault": "Minnesota does NOT apply comparative fault to dog bite claims under § 347.22 (MORE favorable to victims)",
        "full_amount_of_injury": "Owner liable for FULL amount of injury sustained (no reduction)",
        "damages_recoverable": [
            "Medical expenses",
            "Lost wages",
            "Pain and suffering",
            "Emotional distress",
            "Permanent scarring/disfigurement",
            "Loss of enjoyment of life"
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

-- Rule 2: Minnesota Statute of Limitations - 6 YEARS (CONTEXTUAL RULE)
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
    'MN-PI-DOG-BITE-SOL-6-YEARS',
    5,
    'MN Dog Bite Statute of Limitations (6 Years - Contextual)',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'MN',
    '{
        "authority_level": "contextual_rule",
        "statute": "Minn. Stat. § 541.05, Subd. 1(5)",
        "statute_of_limitations": "6 years",
        "sol_years": 6,
        "sol_days": 2190,
        "one_of_longest": "Minnesota has one of the LONGEST SOLs in nation (tied with Maine and North Dakota at 6 years)",
        "accrual_date": "Date of dog bite injury",
        "key_requirements": [
            "Action must be commenced within 6 YEARS of dog bite",
            "Applies to claims under Minn. Stat. § 347.22 (strict liability)",
            "Failure to file within 6 years bars recovery"
        ],
        "tolling_provisions": [
            "Minors: Statute tolled until minor reaches age 18",
            "Mental incapacity: Statute may be tolled",
            "Discovery rule: May apply in limited circumstances if injury not immediately discoverable"
        ],
        "strategic_advantages": [
            "GENEROUS 6-year filing period (longest in nation)",
            "Time to assess long-term damages and permanent scarring",
            "Time to negotiate with insurance companies without pressure",
            "Time to gather evidence and witness testimony",
            "Time to consult with attorneys and medical experts",
            "Avoid rushed settlement decisions"
        ],
        "comparison": "Compare to shortest SOLs: TN/KY (1 year), LA pre-2024 (1 year)",
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
-- END OF MINNESOTA DOG BITE RULES SEED FILE
-- =====================================================================================
