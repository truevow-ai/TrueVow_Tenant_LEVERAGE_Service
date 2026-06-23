-- =====================================================================================
-- MISSISSIPPI DOG BITE LIABILITY RULES SEED FILE
-- =====================================================================================
-- State: Mississippi (MS)
-- Sub-Specialization: Dog Bite (Personal Injury)
-- Liability Model: ONE-BITE RULE (Common Law Scienter)
-- Legal Standard: Owner liable if knew or should have known of dog's dangerous propensity
-- Primary Authority: Common law
-- Statute of Limitations: 3 years (Miss. Code Ann. § 15-1-49)
-- Authority Level: contextual_rule (NOT primary_state_sol)
-- 
-- VERIFICATION STATUS: DOCUMENT VERIFIED
-- Research Date: January 30, 2026
-- Sources Verified:
--   1. Common law one-bite rule - Verified from multiple legal sources
--   2. Miss. Code Ann. § 15-1-49 - 3-year SOL
--   3. Scienter requirement confirmed
-- =====================================================================================

-- =====================================================================================
-- PART 1: LEGAL SOURCES
-- =====================================================================================

-- Source 1: Mississippi Dog Bite Common Law (One-Bite Rule)
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
    'MS',
    NULL,
    NULL,
    'Mississippi Dog Bite Common Law - One-Bite Rule',
    'Mississippi Courts',
    'Common Law Scienter Doctrine',
    'https://www.mtlawms.com/blog/dog-bites-in-mississippi-one-bite-everybody-know/',
    'case_law',
    'high',
    'Mississippi Dog Bite Law - Common Law One-Bite Rule (Scienter Doctrine):

Mississippi does NOT have a specific dog bite statute. Instead, Mississippi follows the common law "ONE-BITE RULE."

LEGAL STANDARD:
Owner is liable for dog bite injuries ONLY IF the owner knew or should have known of the dog''s dangerous propensity (SCIENTER).

KEY REQUIREMENTS TO PROVE LIABILITY:
1. Dog had a dangerous disposition
2. Owner knew of this dangerous disposition
3. Owner knew or should have known the dog could attack

NO STRICT LIABILITY:
Mississippi does NOT impose strict liability. Plaintiff must prove owner had prior knowledge of dog''s viciousness.

PROVING OWNER KNOWLEDGE (SCIENTER):
Evidence that can establish owner''s knowledge:
- Prior biting incidents or attacks
- Prior aggressive behavior (growling, snapping, lunging, snarling)
- Complaints to owner about dog''s behavior
- Owner statements acknowledging dog''s aggression
- Warnings posted ("Beware of Dog" signs)
- Dog''s breed reputation (limited weight, not dispositive alone)
- Veterinary records showing aggression
- Prior animal control complaints

ALTERNATIVE THEORIES OF LIABILITY:
Even without scienter, plaintiff may recover through:
1. NEGLIGENCE: Owner failed to exercise reasonable care in controlling dog
2. NEGLIGENCE PER SE: Owner violated animal control ordinance (e.g., leash law, confinement requirement)
3. LOCAL ORDINANCES: Violation of Southaven, DeSoto County, or other local animal control laws

COMPARATIVE NEGLIGENCE:
Mississippi follows comparative negligence rule. If plaintiff''s fault contributed to injury, recovery may be reduced proportionally.

DOCUMENT VERIFIED from multiple legal sources (MT Law MS, Stroud Flechas & Dalton, Boyce Holleman, King Law Firm).'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET
    base_url = EXCLUDED.base_url,
    notes = EXCLUDED.notes;

-- Source 2: Mississippi Statute of Limitations - Personal Injury (Miss. Code Ann. § 15-1-49)
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
    'MS',
    NULL,
    NULL,
    'Mississippi Statute of Limitations - Personal Injury (Dog Bite)',
    'Mississippi Legislature',
    'Miss. Code Ann. § 15-1-49',
    'https://law.justia.com/codes/mississippi/title-15/chapter-1/section-15-1-49/',
    'statute',
    'high',
    'Miss. Code Ann. § 15-1-49 - Limitations applicable to actions not otherwise provided for:

All actions for which no other period of limitation is prescribed shall be commenced within three (3) years next after the cause of action accrued, and not after.

In actions for which no other period of limitation is prescribed and which involve latent injury or disease, the cause of action does not accrue until the plaintiff has discovered, or by reasonable diligence should have discovered, the injury.

APPLICATION TO DOG BITES:
Claims for dog bite injuries (based on common law scienter or negligence) are subject to this THREE YEAR statute of limitations. The three-year period begins on the date of the dog bite injury.

DISCOVERY RULE:
Mississippi applies the discovery rule for latent injuries. If injury was not immediately discoverable, the SOL may begin when plaintiff discovers or reasonably should have discovered the injury.

TOLLING PROVISIONS:
- Minors: Statute may be tolled until minor reaches age of majority
- Mental incapacity: Statute may be tolled
- Defendant leaves Mississippi: Time may be tolled

STRATEGIC NOTES:
- 3-year filing period is moderate
- Evidence preservation important (especially for proving scienter)
- Prompt medical attention and reporting recommended
- Legal consultation advised within reasonable time after bite

DOCUMENT VERIFIED from Mississippi Code and multiple legal sources.'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET
    base_url = EXCLUDED.base_url,
    notes = EXCLUDED.notes;

-- =====================================================================================
-- PART 2: VALIDATION RULES (CONTEXTUAL RULES - NOT PRIMARY SOL AUTHORITY)
-- =====================================================================================

-- Rule 1: Mississippi One-Bite Rule (Common Law Scienter)
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
    'MS-PI-DOG-BITE-ONE-BITE-RULE',
    5,
    'MS Dog Bite One-Bite Rule (Common Law Scienter)',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'MS',
    '{
        "authority_level": "contextual_rule",
        "liability_model": "one_bite_rule",
        "legal_basis": "Common law scienter doctrine",
        "legal_standard": "Owner liable if knew or should have known of dog''s dangerous propensity",
        "key_requirements": [
            "Dog bit plaintiff",
            "Dog had dangerous disposition",
            "Owner knew of dog''s dangerous disposition",
            "Owner knew or should have known dog could attack"
        ],
        "no_strict_liability": "Mississippi does NOT impose strict liability; owner must have prior knowledge",
        "scienter_required": "Plaintiff must prove owner knew or should have known of dog''s vicious propensity",
        "proving_scienter": {
            "methods": [
                "Prior biting incidents or attacks",
                "Prior aggressive behavior (growling, snapping, lunging, snarling)",
                "Complaints to owner about dog''s behavior",
                "Owner statements acknowledging dog''s aggression",
                "Warnings posted (''Beware of Dog'' signs)",
                "Dog''s breed reputation (limited weight, not dispositive alone)",
                "Veterinary records showing aggression",
                "Prior animal control complaints"
            ]
        },
        "alternative_liability_theories": [
            "NEGLIGENCE: Owner failed to exercise reasonable care in controlling dog",
            "NEGLIGENCE PER SE: Owner violated animal control ordinance (leash law, confinement)",
            "LOCAL ORDINANCES: Violation of Southaven, DeSoto County, or other local animal control laws"
        ],
        "comparative_negligence": {
            "rule": "Mississippi follows comparative negligence",
            "reduction": "If plaintiff''s fault contributed to injury, recovery reduced proportionally"
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

-- Rule 2: Mississippi Negligence Theory (Alternative to Scienter)
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
    'MS-PI-DOG-BITE-NEGLIGENCE',
    5,
    'MS Dog Bite Negligence Theory (Alternative)',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'MS',
    '{
        "authority_level": "contextual_rule",
        "liability_model": "negligence",
        "when_to_use": "When cannot prove scienter (owner knowledge of dangerous propensity)",
        "legal_standard": "Owner liable if failed to exercise reasonable care in controlling dog",
        "key_requirements": [
            "Owner owed duty of care to plaintiff",
            "Owner breached duty (unreasonable conduct)",
            "Breach proximately caused plaintiff''s injury",
            "Plaintiff suffered damages"
        ],
        "unreasonable_conduct_examples": [
            "Failed to restrain dog known to be aggressive",
            "Violated leash law or confinement ordinance (negligence per se)",
            "Failed to warn of known danger",
            "Allowed dog to roam free",
            "Failed to properly secure dog"
        ],
        "negligence_per_se": "Violation of animal control ordinance (leash law, local ordinances) is evidence of negligence",
        "comparative_negligence_applies": "Same comparative negligence rule applies to negligence claims",
        "burden_of_proof": "Lower than proving scienter but requires proof of unreasonable conduct"
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

-- Rule 3: Mississippi Statute of Limitations - 3 YEARS (CONTEXTUAL RULE)
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
    'MS-PI-DOG-BITE-SOL-3-YEARS',
    5,
    'MS Dog Bite Statute of Limitations (3 Years - Contextual)',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'MS',
    '{
        "authority_level": "contextual_rule",
        "statute": "Miss. Code Ann. § 15-1-49",
        "statute_of_limitations": "3 years",
        "sol_years": 3,
        "sol_days": 1095,
        "accrual_date": "Date cause of action accrued (date of dog bite injury)",
        "key_requirements": [
            "Action must be commenced within 3 YEARS of dog bite",
            "Applies to scienter claims",
            "Applies to negligence claims",
            "Failure to file within 3 years bars recovery"
        ],
        "discovery_rule": {
            "applies": true,
            "standard": "For latent injuries, SOL begins when plaintiff discovers or by reasonable diligence should have discovered the injury"
        },
        "tolling_provisions": [
            "Minors: Statute may be tolled until minor reaches age of majority",
            "Mental incapacity: Statute may be tolled",
            "Defendant leaves Mississippi: Time may be tolled"
        ],
        "strategic_notes": [
            "3-year period is moderate (not shortest, not longest)",
            "Evidence preservation CRITICAL for proving scienter",
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
-- END OF MISSISSIPPI DOG BITE RULES SEED FILE
-- =====================================================================================
