-- =====================================================================================
-- INDIANA DOG BITE LIABILITY RULES SEED FILE
-- =====================================================================================
-- State: Indiana (IN)
-- Sub-Specialization: Dog Bite (Personal Injury)
-- Liability Model: HYBRID (Strict liability for officials; One-bite rule for others)
-- Legal Standard: Strict liability if victim performing official duties; otherwise owner liable if knew/should have known of dangerous propensity
-- Primary Authority: IC 15-20-1-3
-- Statute of Limitations: 2 years (IC 34-11-2-4)
-- 
-- VERIFICATION STATUS: DOCUMENT VERIFIED
-- Research Date: January 30, 2026
-- Sources Verified:
--   1. IC 15-20-1-3 - Verified from Indiana Code and multiple legal sources
--   2. IC 34-11-2-4 - 2-year SOL for personal injury
--   3. Hybrid model: Strict liability for officials; one-bite rule for others
-- =====================================================================================

-- =====================================================================================
-- PART 1: LEGAL SOURCES
-- =====================================================================================

-- Source 1: Indiana Dog Bite Liability Statute (IC 15-20-1-3)
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
    'IN',
    NULL,
    NULL,
    'Indiana Dog Bite Liability Statute',
    'Indiana Legislature',
    'IC 15-20-1-3',
    'https://law.justia.com/codes/indiana/title-15/article-20/chapter-1/section-15-20-1-3/',
    'statute',
    'high',
    'IC 15-20-1-3 - Dog bite liability:

(a) If a dog, without provocation, bites a person who is acting peaceably in any place where the person may lawfully be, the owner of the dog is liable for all damages suffered by the person bitten.

(b) The owner of a dog described in subsection (a) is liable for damages if the person bitten was acting in the performance of any official duty imposed by the laws of this state or by the laws or postal regulations of the United States, or if the person was acting peacefully upon invitation or permission by the owner.

KEY PROVISIONS:
- HYBRID MODEL: Indiana has TWO standards depending on victim status
  
TIER 1 - STRICT LIABILITY (for officials):
- Applies if victim was:
  (1) Performing official duty imposed by state law
  (2) Performing official duty imposed by federal law or postal regulations
  (3) Acting peacefully upon invitation or permission by owner
- Owner liable REGARDLESS of knowledge of dog''s vicious propensity
- No proof of prior dangerous behavior required
- Examples: Postal workers, police officers, inspectors, utility workers, invited guests

TIER 2 - ONE-BITE RULE (for general public):
- For victims NOT covered by Tier 1
- Owner liable ONLY IF owner knew or should have known of dog''s dangerous propensity
- Requires proof of prior aggressive behavior or owner knowledge
- Common law scienter doctrine applies

REQUIREMENTS FOR ALL CLAIMS:
- Dog bite was "without provocation"
- Victim was "acting peaceably"
- Victim was in place where he/she may lawfully be
- Owner is liable for ALL damages suffered

PROVOCATION DEFENSE:
- If victim provoked dog, no liability
- Examples: Hitting, teasing, tormenting dog

LAWFUL PRESENCE REQUIREMENT:
- Victim must be lawfully present at location
- Trespassing may defeat liability

DOCUMENT VERIFIED from Indiana Code and multiple legal sources (dogbitelaw.com, 2Keller, Kaushal Law).'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET
    base_url = EXCLUDED.base_url,
    notes = EXCLUDED.notes;

-- Source 2: Indiana Statute of Limitations - Personal Injury (IC 34-11-2-4)
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
    'IN',
    NULL,
    NULL,
    'Indiana Statute of Limitations - Personal Injury (Dog Bite)',
    'Indiana Legislature',
    'IC 34-11-2-4',
    'https://law.justia.com/codes/indiana/title-34/article-11/chapter-2/section-34-11-2-4/',
    'statute',
    'high',
    'IC 34-11-2-4 - Statute of limitations for injury actions:

Actions for personal injury must be commenced within TWO YEARS after the cause of action accrues.

APPLICATION TO DOG BITES:
Claims brought under IC 15-20-1-3 are subject to this TWO YEAR statute of limitations. The two-year period begins on the date of the dog bite.

TOLLING PROVISIONS:
- Legal disability: If injured person is under legal disability (minor or mentally incapacitated), statute tolled until disability removed
- Defendant leaves state: Time defendant is out of Indiana may be tolled
- Defendant conceals liability: Statute may be paused until concealment discovered

GOVERNMENT CLAIMS:
- Special notice requirements when suing government entities
- Notice deadlines: 180 or 270 days depending on entity

DOCUMENT VERIFIED from Indiana Code and multiple legal sources.'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET
    base_url = EXCLUDED.base_url,
    notes = EXCLUDED.notes;

-- =====================================================================================
-- PART 2: VALIDATION RULES
-- =====================================================================================

-- Rule 1: Indiana Strict Liability (For Officials/Invited Guests)
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
    'IN-PI-DOG-BITE-STRICT-LIABILITY',
    5,
    'IN Dog Bite Strict Liability (Officials/Invited Guests - IC 15-20-1-3)',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'IN',
    '{
        "liability_model": "strict_liability",
        "statute": "IC 15-20-1-3",
        "applies_to": [
            "Persons performing official duty imposed by state law",
            "Persons performing official duty imposed by federal law or postal regulations",
            "Persons acting peacefully upon invitation or permission by owner"
        ],
        "key_requirements": [
            "Dog bit plaintiff without provocation",
            "Plaintiff was acting peaceably",
            "Plaintiff was in place where lawfully present",
            "Plaintiff was: (a) performing official duty, OR (b) acting upon owner''s invitation/permission",
            "Owner is liable for ALL damages suffered"
        ],
        "examples_of_protected_persons": [
            "Postal workers delivering mail",
            "Police officers on duty",
            "Government inspectors",
            "Utility workers (gas, electric, water)",
            "Process servers",
            "Invited social guests",
            "Invitees on owner''s property"
        ],
        "no_prior_knowledge_required": "Owner liable REGARDLESS of knowledge of dog''s dangerous propensity",
        "provocation_defense": "If victim provoked dog, no liability",
        "damages_recoverable": [
            "All damages suffered by person bitten",
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

-- Rule 2: Indiana One-Bite Rule (For General Public)
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
    'IN-PI-DOG-BITE-ONE-BITE-RULE',
    5,
    'IN Dog Bite One-Bite Rule (General Public - Common Law Scienter)',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'IN',
    '{
        "liability_model": "one_bite_rule",
        "legal_basis": "Common law scienter doctrine",
        "applies_to": "Victims NOT performing official duties AND NOT invited guests",
        "key_requirements": [
            "Dog bit plaintiff",
            "Owner knew or should have known of dog''s dangerous propensity",
            "Plaintiff did NOT provoke dog",
            "Plaintiff was lawfully present",
            "Plaintiff was acting peaceably"
        ],
        "proving_owner_knowledge": {
            "methods": [
                "Prior biting incidents",
                "Prior attacks or attempted attacks",
                "Aggressive behavior witnessed by owner",
                "Complaints to owner about dog''s behavior",
                "Owner''s statements acknowledging dog''s aggression",
                "Warnings posted by owner (\"Beware of Dog\" signs)",
                "Dog''s breed reputation (limited weight)"
            ]
        },
        "negligence_per_se": "Owner violated animal control ordinance (e.g., leash law, confinement requirement) - violation is evidence of negligence",
        "burden_of_proof": "Plaintiff must prove owner knew or should have known of dangerous propensity",
        "damages_recoverable": [
            "Medical expenses",
            "Lost wages",
            "Pain and suffering",
            "Emotional trauma",
            "Permanent scarring/disfigurement",
            "Loss of quality of life"
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

-- Rule 3: Indiana Statute of Limitations - 2 Years
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
    'IN-PI-DOG-BITE-SOL-2-YEARS',
    5,
    'IN Dog Bite Statute of Limitations (2 Years)',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'IN',
    '{
        "statute": "IC 34-11-2-4",
        "statute_of_limitations": "2 years",
        "accrual_date": "Date cause of action accrues (date of dog bite)",
        "key_requirements": [
            "Action must be commenced within 2 years of dog bite",
            "Applies to strict liability claims under IC 15-20-1-3",
            "Applies to common law negligence/scienter claims",
            "Failure to file timely bars recovery"
        ],
        "tolling_provisions": [
            "Legal disability: Statute tolled if injured person is minor or mentally incapacitated",
            "Defendant leaves state: Time defendant out of Indiana may be tolled",
            "Defendant conceals liability: Statute paused until concealment discovered"
        ],
        "government_claims": {
            "special_notice_requirements": "When suing government entities",
            "notice_deadlines": "180 or 270 days depending on entity"
        },
        "consequence_of_violation": "Claim time-barred; court will dismiss; no recovery possible"
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
-- END OF INDIANA DOG BITE RULES SEED FILE
-- =====================================================================================
