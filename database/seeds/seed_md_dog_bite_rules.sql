-- =====================================================================================
-- MARYLAND DOG BITE LIABILITY RULES SEED FILE
-- =====================================================================================
-- State: Maryland (MD)
-- Sub-Specialization: Dog Bite (Personal Injury)
-- Liability Model: MODIFIED ONE-BITE RULE + Statutory Presumption (2014 Statute)
-- Legal Standard: Owner liable if knew or should have known of dog's vicious propensity
-- Primary Authority: Common law + 2014 Dog Bite Statute (abrogating Tracey v. Solesky)
-- Statute of Limitations: 3 years (Md. Code Cts. & Jud. Proc. § 5-101)
-- 
-- VERIFICATION STATUS: DOCUMENT VERIFIED
-- Research Date: January 30, 2026
-- Sources Verified:
--   1. Tracey v. Solesky (2012) - Breed-specific strict liability (abrogated 2014)
--   2. 2014 Maryland Dog Bite Statute - Rebuttable presumption
--   3. Md. Code Cts. & Jud. Proc. § 5-101 - 3-year SOL
-- =====================================================================================

-- =====================================================================================
-- PART 1: LEGAL SOURCES
-- =====================================================================================

-- Source 1: Maryland Dog Bite Common Law (Modified One-Bite Rule)
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
    'MD',
    NULL,
    NULL,
    'Maryland Dog Bite Common Law',
    'Maryland Courts',
    'Common Law',
    'https://www.animallaw.info/case/tracey-v-solesky-0',
    'case_law',
    'high',
    'Maryland Dog Bite Law - Common Law (Modified One-Bite Rule):

HISTORICAL STANDARD (Pre-2012):
Maryland followed traditional common law: Owner liable ONLY if owner knew or should have known of dog''s dangerous propensities (vicious tendencies). Plaintiff must prove:
1. Dog had vicious propensities
2. Owner knew or should have known of those propensities
3. Dog caused injury

TRACEY V. SOLESKY (2012) - BREED-SPECIFIC STRICT LIABILITY:
On April 27, 2012, Maryland Court of Appeals decided *Tracey v. Solesky*, 427 Md. 627 (2012), establishing STRICT LIABILITY for pit bulls and pit bull cross-breeds:
- Pit bulls deemed "inherently dangerous"
- Owner/landlord strictly liable if knew or should have known dog was pit bull
- NO need to prove dog was vicious or owner knew of vicious propensities
- Breed identification alone sufficient for strict liability

LEGISLATIVE RESPONSE (2014) - ABROGATION OF TRACEY:
In 2014, Maryland Legislature enacted statute ABROGATING Tracey v. Solesky and returning to MODIFIED one-bite rule with statutory presumption:
- Eliminated breed-specific strict liability
- Created rebuttable presumption: If dog is pit bull, PRESUMPTION that owner knew or should have known dog was dangerous
- Presumption is REBUTTABLE - owner can present evidence to rebut
- For all other breeds, traditional one-bite rule applies

CURRENT STANDARD (2014 Statute):
Owner liable if knew or should have known of dog''s dangerous propensities, with REBUTTABLE PRESUMPTION for pit bulls.

EFFECTIVE PERIODS:
- Before April 27, 2012: Traditional one-bite rule (all breeds)
- April 27, 2012 - April 7, 2014: Tracey v. Solesky strict liability (pit bulls only)
- After April 7, 2014: 2014 Statute (rebuttable presumption for pit bulls; one-bite for others)

DOCUMENT VERIFIED from Maryland Court of Appeals opinion and multiple legal sources.'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET
    base_url = EXCLUDED.base_url,
    notes = EXCLUDED.notes;

-- Source 2: Maryland 2014 Dog Bite Statute (Abrogating Tracey v. Solesky)
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
    'MD',
    NULL,
    NULL,
    'Maryland Dog Bite Statute (2014)',
    'Maryland Legislature',
    '2014 Dog Bite Statute',
    'https://www.plaxenadler.com/aop/animal-attacks/',
    'statute',
    'high',
    'Maryland Dog Bite Statute (2014) - Abrogating Tracey v. Solesky:

ENACTED: 2014 (Effective April 7, 2014)

PURPOSE: Abrogate *Tracey v. Solesky* breed-specific strict liability and establish rebuttable presumption standard.

KEY PROVISIONS:
1. ABROGATION OF TRACEY: Statute explicitly abrogates *Tracey v. Solesky* holding that pit bulls are inherently dangerous and subject to strict liability.

2. REBUTTABLE PRESUMPTION FOR PIT BULLS:
   - If dog is pit bull → PRESUMPTION that owner knew or should have known dog was dangerous
   - Presumption is REBUTTABLE: Owner can present evidence to rebut presumption
   - Shifts burden to owner to prove did NOT know of dangerous propensity
   - NOT strict liability (unlike Tracey)

3. ONE-BITE RULE FOR OTHER BREEDS:
   - All other dog breeds subject to traditional one-bite rule
   - Plaintiff must prove owner knew or should have known of vicious propensity

PROVING KNOWLEDGE (VICIOUS PROPENSITY):
- Prior biting incidents or attacks
- Prior aggressive behavior (growling, snapping, lunging)
- Owner statements acknowledging dog''s aggression
- Complaints to owner about dog''s behavior
- Evidence dog previously injured person or animal

LANDLORD LIABILITY:
Landlords may be liable if:
- Knew or should have known of dog''s dangerous propensities
- Had control over premises to prevent attack
- Failed to take reasonable steps to prevent injury

COMPARATIVE NEGLIGENCE:
Maryland follows contributory negligence rule. If victim is even 1% at fault (e.g., provoked dog), victim CANNOT recover. This is HARSH standard for victims.

DOCUMENT VERIFIED from multiple legal sources discussing 2014 legislative changes.'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET
    base_url = EXCLUDED.base_url,
    notes = EXCLUDED.notes;

-- Source 3: Maryland Statute of Limitations - Civil Actions (Md. Code Cts. & Jud. Proc. § 5-101)
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
    'MD',
    NULL,
    NULL,
    'Maryland Statute of Limitations - Personal Injury (Dog Bite)',
    'Maryland Legislature',
    'Md. Code Cts. & Jud. Proc. § 5-101',
    'https://mgaleg.maryland.gov/mgawebsite/laws/StatuteText?article=gcj&section=5-101',
    'statute',
    'high',
    'Md. Code Cts. & Jud. Proc. § 5-101 - Statute of limitations for civil actions:

A civil action at law shall be filed within three years from the date it accrues unless another provision of the Code provides for a different period of time within which an action shall be commenced.

APPLICATION TO DOG BITES:
Claims for dog bite injuries are subject to this THREE YEAR statute of limitations. The three-year period begins on the date of the dog bite injury.

TOLLING PROVISIONS:
- Minors: Statute may be tolled until minor reaches age of majority
- Discovery rule: Limited tolling if injury not immediately discoverable
- Defendant leaves Maryland: Time may be tolled

STRATEGIC NOTES:
- 3-year filing period is moderate (shorter than ME/ND 6 years, longer than TN/KY 1 year)
- Evidence preservation important
- Prompt medical attention and reporting recommended
- Legal consultation advised within reasonable time after bite

DOCUMENT VERIFIED from Maryland Code and multiple legal sources.'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET
    base_url = EXCLUDED.base_url,
    notes = EXCLUDED.notes;

-- =====================================================================================
-- PART 2: VALIDATION RULES
-- =====================================================================================

-- Rule 1: Maryland Modified One-Bite Rule (2014 Statute)
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
    'MD-PI-DOG-BITE-MODIFIED-ONE-BITE',
    5,
    'MD Dog Bite Modified One-Bite Rule (2014 Statute)',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'MD',
    '{
        "liability_model": "modified_one_bite_rule",
        "statute": "2014 Dog Bite Statute",
        "legal_standard": "Owner liable if knew or should have known of dog''s dangerous propensity",
        "key_requirements": [
            "Dog bit or injured plaintiff",
            "Owner knew or should have known of dog''s dangerous propensity",
            "Plaintiff did NOT provoke dog (contributory negligence bar)",
            "Plaintiff was lawfully present"
        ],
        "rebuttable_presumption_pit_bulls": {
            "rule": "If dog is pit bull, PRESUMPTION that owner knew or should have known dog was dangerous",
            "rebuttable": true,
            "owner_can_rebut": "Owner can present evidence to rebut presumption",
            "not_strict_liability": "This is NOT strict liability (unlike Tracey v. Solesky)",
            "burden_shift": "Burden shifts to owner to prove did NOT know of dangerous propensity"
        },
        "one_bite_rule_other_breeds": {
            "rule": "For all other dog breeds, traditional one-bite rule applies",
            "plaintiff_must_prove": "Owner knew or should have known of vicious propensity"
        },
        "proving_knowledge": {
            "methods": [
                "Prior biting incidents or attacks",
                "Prior aggressive behavior (growling, snapping, lunging, menacing)",
                "Owner statements acknowledging dog''s aggression",
                "Complaints to owner about dog''s behavior",
                "Evidence dog previously injured person or animal"
            ]
        },
        "contributory_negligence_bar": {
            "rule": "Maryland follows HARSH contributory negligence rule",
            "complete_bar": "If victim is even 1% at fault (e.g., provoked dog), victim CANNOT recover",
            "no_comparative_fault": "Unlike most states, Maryland does NOT allow comparative fault reduction"
        },
        "landlord_liability": {
            "when_liable": [
                "Knew or should have known of dog''s dangerous propensities",
                "Had control over premises to prevent attack",
                "Failed to take reasonable steps to prevent injury"
            ]
        },
        "historical_note": "Tracey v. Solesky (2012) imposed breed-specific strict liability for pit bulls from April 27, 2012 to April 7, 2014; 2014 statute abrogated Tracey",
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

-- Rule 2: Maryland Statute of Limitations - 3 YEARS
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
    'MD-PI-DOG-BITE-SOL-3-YEARS',
    5,
    'MD Dog Bite Statute of Limitations (3 Years)',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'MD',
    '{
        "statute": "Md. Code Cts. & Jud. Proc. § 5-101",
        "statute_of_limitations": "3 years",
        "sol_years": 3,
        "sol_days": 1095,
        "accrual_date": "Date cause of action accrues (date of dog bite injury)",
        "key_requirements": [
            "Action must be commenced within 3 YEARS of dog bite",
            "Applies to all dog bite claims (regardless of breed)",
            "Failure to file within 3 years bars recovery"
        ],
        "tolling_provisions": [
            "Minors: Statute may be tolled until minor reaches age of majority",
            "Discovery rule: Limited tolling if injury not immediately discoverable",
            "Defendant leaves Maryland: Time may be tolled"
        ],
        "strategic_notes": [
            "3-year period is moderate (not shortest, not longest)",
            "Evidence preservation important (photographs, medical records, witness statements)",
            "Prompt medical attention and reporting recommended",
            "Legal consultation advised within reasonable time after bite"
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
-- END OF MARYLAND DOG BITE RULES SEED FILE
-- =====================================================================================
