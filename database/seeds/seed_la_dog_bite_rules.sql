-- =====================================================================================
-- LOUISIANA DOG BITE LIABILITY RULES SEED FILE
-- =====================================================================================
-- State: Louisiana (LA)
-- Sub-Specialization: Dog Bite (Personal Injury)
-- Liability Model: STRICT LIABILITY (Statutory)
-- Legal Standard: Owner liable for damages caused by dog if could have prevented and not provoked
-- Primary Authority: La. Civ. Code Art. 2321
-- Statute of Limitations: 2 years (La. Civ. Code Art. 3493.1) - Changed July 1, 2024
-- Former SOL: 1 year (La. Civ. Code Art. 3492) - For injuries BEFORE July 1, 2024
-- 
-- VERIFICATION STATUS: DOCUMENT VERIFIED
-- Research Date: January 30, 2026
-- Sources Verified:
--   1. La. Civ. Code Art. 2321 - Verified from Justia and animallaw.info
--   2. La. Civ. Code Art. 3493.1 - 2-year SOL (effective July 1, 2024)
--   3. Act No. 423 (2024) - Legislative amendment extending SOL from 1 year to 2 years
-- =====================================================================================

-- =====================================================================================
-- PART 1: LEGAL SOURCES
-- =====================================================================================

-- Source 1: Louisiana Dog Bite Strict Liability Statute (La. Civ. Code Art. 2321)
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
    'LA',
    NULL,
    NULL,
    'Louisiana Dog Bite Strict Liability Statute',
    'Louisiana Legislature',
    'La. Civ. Code Art. 2321',
    'https://law.justia.com/codes/louisiana/civil-code/article-2321/',
    'statute',
    'high',
    'La. Civ. Code Art. 2321 - Damage caused by animals; livestock:

The owner of an animal is answerable for the damage caused by the animal. However, he is answerable for the damage only upon a showing that he knew or, in the exercise of reasonable care, should have known that his animal''s behavior would cause damage, that the damage could have been prevented by the exercise of reasonable care, and that he failed to exercise such reasonable care.

SUBSECTION ON DOGS (STRICT LIABILITY):
The owner of a dog is strictly liable for damages for injuries to persons or property caused by the dog and which the owner could have prevented and which did not result from the injured person''s provocation of the dog.

INTERPRETATION (PEPPER V. TRIPLET):
The Louisiana Supreme Court in *Pepper v. Triplet*, 864 So. 2d 181 (La. 2004), clarified that to establish liability under Art. 2321, the plaintiff must prove:
1. The dog caused the damage
2. The owner could have prevented the injury
3. The injury was NOT caused by the plaintiff''s provocation

UNREASONABLE RISK OF HARM:
If the dog posed an "unreasonable risk of harm" (the risk outweighed the dog''s utility), the owner is presumed liable unless owner proves otherwise.

NO "ONE-BITE RULE":
Louisiana does NOT follow the traditional "one-bite rule." Owner liable regardless of dog''s prior viciousness or owner''s knowledge of prior aggressive behavior.

DEFENSES:
- Provocation: If plaintiff provoked dog, no liability
- Trespass: Trespassers generally cannot recover
- Could not have prevented: If owner could not have prevented injury despite reasonable care, no liability

RES IPSA LOQUITUR:
Courts may apply doctrine of res ipsa loquitur (the thing speaks for itself) in appropriate cases to shift burden of proof.

NEGLIGENCE THEORY (ALTERNATIVE):
Even if strict liability does not apply, owner may be liable under negligence theory if:
- Owner owed duty of care
- Owner breached duty (e.g., violated leash law)
- Breach caused injury
- Damages resulted

DOCUMENT VERIFIED from Louisiana Civil Code and multiple legal sources (dogbitelaw.com, animallaw.info, Delphin Law).'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET
    base_url = EXCLUDED.base_url,
    notes = EXCLUDED.notes;

-- Source 2: Louisiana Statute of Limitations - NEW (2 Years) - La. Civ. Code Art. 3493.1
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
    'LA',
    NULL,
    NULL,
    'Louisiana Statute of Limitations - Delictual Actions (2 Years - NEW)',
    'Louisiana Legislature',
    'La. Civ. Code Art. 3493.1',
    'https://keoghcox.com/louisiana-legislature-sets-new-prescription-period-for-tort-claims/',
    'statute',
    'high',
    'La. Civ. Code Art. 3493.1 - Delictual action (NEW - Effective July 1, 2024):

Delictual actions are subject to a liberative prescription of TWO YEARS. This prescription commences to run from the day injury or damage is sustained.

LEGISLATIVE HISTORY:
- Enacted by Act No. 423 of 2024
- Effective Date: July 1, 2024
- PROSPECTIVE ONLY: Applies ONLY to injuries occurring ON OR AFTER July 1, 2024
- Supersedes prior La. Civ. Code Art. 3492 (1-year SOL)

APPLICATION TO DOG BITES:
Claims brought under La. Civ. Code Art. 2321 (strict liability for dog bites) are subject to this TWO YEAR statute of limitations FOR INJURIES ON OR AFTER July 1, 2024. The two-year period begins on the date of the dog bite injury.

CRITICAL NOTE: This represents a MAJOR CHANGE extending Louisiana''s SOL from 1 year to 2 years. Louisiana previously had one of the SHORTEST SOLs in the nation (tied with Tennessee and Kentucky at 1 year).

IMPORTANT TIMING:
- Injury on or after July 1, 2024 → 2-year SOL applies (La. Civ. Code Art. 3493.1)
- Injury BEFORE July 1, 2024 → 1-year SOL applies (La. Civ. Code Art. 3492)

DOCUMENT VERIFIED from Louisiana Civil Code, Act No. 423 (2024), and multiple legal sources.'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET
    base_url = EXCLUDED.base_url,
    notes = EXCLUDED.notes;

-- Source 3: Louisiana Statute of Limitations - OLD (1 Year) - La. Civ. Code Art. 3492
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
    'LA',
    NULL,
    NULL,
    'Louisiana Statute of Limitations - Delictual Actions (1 Year - OLD)',
    'Louisiana Legislature',
    'La. Civ. Code Art. 3492',
    'https://ricekendig.com/blog/change-to-louisiana-personal-injury-statute-of-limitations',
    'statute',
    'high',
    'La. Civ. Code Art. 3492 - Delictual action (OLD - Repealed for injuries on/after July 1, 2024):

Delictual actions are subject to a liberative prescription of ONE YEAR. This prescription commences to run from the day injury or damage is sustained.

EFFECTIVE PERIOD: This statute applied to ALL personal injury claims in Louisiana until July 1, 2024.

REPEAL/SUPERSESSION: For injuries occurring ON OR AFTER July 1, 2024, this article was superseded by La. Civ. Code Art. 3493.1 (2-year SOL).

CONTINUED APPLICATION: For injuries occurring BEFORE July 1, 2024, this 1-YEAR SOL still applies.

APPLICATION TO DOG BITES:
Claims for dog bites occurring BEFORE July 1, 2024 must be filed within ONE YEAR of the dog bite injury.

CRITICAL WARNING: Louisiana had one of the SHORTEST SOLs in the nation (tied with Tennessee and Kentucky) at 1 year. Victims of dog bites before July 1, 2024 must act IMMEDIATELY.

DOCUMENT VERIFIED from Louisiana Civil Code and multiple legal sources.'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET
    base_url = EXCLUDED.base_url,
    notes = EXCLUDED.notes;

-- =====================================================================================
-- PART 2: VALIDATION RULES
-- =====================================================================================

-- Rule 1: Louisiana Strict Liability (La. Civ. Code Art. 2321)
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
    'LA-PI-DOG-BITE-STRICT-LIABILITY',
    5,
    'LA Dog Bite Strict Liability (La. Civ. Code Art. 2321)',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'LA',
    '{
        "liability_model": "strict_liability",
        "statute": "La. Civ. Code Art. 2321",
        "legal_standard": "Owner strictly liable for damages caused by dog if owner could have prevented and injury did not result from provocation",
        "key_requirements": [
            "Dog caused damage to plaintiff (person or property)",
            "Owner could have prevented the injury",
            "Injury did NOT result from plaintiff''s provocation",
            "Plaintiff was NOT trespassing"
        ],
        "no_one_bite_rule": "Louisiana does NOT follow one-bite rule; owner liable regardless of prior viciousness",
        "pepper_v_triplet_test": {
            "case": "Pepper v. Triplet, 864 So. 2d 181 (La. 2004)",
            "three_element_test": [
                "Dog caused the damage",
                "Owner could have prevented the injury",
                "Injury was NOT caused by plaintiff''s provocation"
            ]
        },
        "unreasonable_risk_of_harm": "If dog posed unreasonable risk of harm (risk outweighed dog''s utility), owner presumed liable unless proven otherwise",
        "defenses": [
            "Provocation: Plaintiff provoked dog",
            "Trespass: Plaintiff was trespassing",
            "Could not prevent: Owner could not have prevented injury despite reasonable care"
        ],
        "res_ipsa_loquitur": "Courts may apply doctrine of res ipsa loquitur to shift burden of proof",
        "alternative_negligence_theory": {
            "when_to_use": "If strict liability does not apply",
            "elements": [
                "Owner owed duty of care",
                "Owner breached duty (e.g., violated leash law)",
                "Breach caused injury",
                "Damages resulted"
            ]
        },
        "damages_recoverable": [
            "Medical expenses",
            "Lost wages",
            "Pain and suffering",
            "Emotional distress",
            "Property damage"
        ],
        "punitive_damages_not_allowed": "Louisiana does NOT permit punitive damages"
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

-- Rule 2: Louisiana Statute of Limitations - 2 YEARS (NEW - Injuries on/after July 1, 2024)
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
    'LA-PI-DOG-BITE-SOL-2-YEARS-NEW',
    5,
    'LA Dog Bite Statute of Limitations (2 Years - NEW)',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'LA',
    '{
        "statute": "La. Civ. Code Art. 3493.1",
        "statute_of_limitations": "2 years",
        "sol_years": 2,
        "sol_days": 730,
        "effective_date": "July 1, 2024",
        "enacted_by": "Act No. 423 of 2024",
        "applies_to": "Injuries occurring ON OR AFTER July 1, 2024",
        "prospective_only": true,
        "accrual_date": "Date injury or damage is sustained (date of dog bite)",
        "key_requirements": [
            "Action must be commenced within 2 YEARS of dog bite",
            "Applies ONLY to injuries on or after July 1, 2024",
            "For injuries BEFORE July 1, 2024, 1-year SOL applies (La. Civ. Code Art. 3492)",
            "Failure to file within 2 years bars recovery"
        ],
        "major_change": "This is a MAJOR CHANGE extending Louisiana''s SOL from 1 year to 2 years",
        "historical_note": "Louisiana previously had one of the SHORTEST SOLs in nation (1 year, tied with TN and KY)",
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

-- Rule 3: Louisiana Statute of Limitations - 1 YEAR (OLD - Injuries BEFORE July 1, 2024)
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
    'LA-PI-DOG-BITE-SOL-1-YEAR-OLD',
    5,
    'LA Dog Bite Statute of Limitations (1 Year - OLD)',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'LA',
    '{
        "statute": "La. Civ. Code Art. 3492",
        "statute_of_limitations": "1 year",
        "sol_years": 1,
        "sol_days": 365,
        "applies_to": "Injuries occurring BEFORE July 1, 2024",
        "superseded_by": "La. Civ. Code Art. 3493.1 (for injuries on/after July 1, 2024)",
        "accrual_date": "Date injury or damage is sustained (date of dog bite)",
        "critical_warning": "SHORTEST SOL IN NATION (tied with TN and KY)",
        "key_requirements": [
            "Action must be commenced within 1 YEAR of dog bite",
            "Applies ONLY to injuries BEFORE July 1, 2024",
            "For injuries ON OR AFTER July 1, 2024, 2-year SOL applies",
            "Failure to file within 1 year bars recovery"
        ],
        "strategic_notes": [
            "MUST ACT IMMEDIATELY - 1 year passes VERY quickly",
            "Evidence preservation CRITICAL",
            "Prompt medical attention and reporting ESSENTIAL",
            "Legal consultation must happen IMMEDIATELY after bite"
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
-- END OF LOUISIANA DOG BITE RULES SEED FILE
-- =====================================================================================
