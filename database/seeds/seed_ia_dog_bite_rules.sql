-- =====================================================================================
-- IOWA DOG BITE LIABILITY RULES SEED FILE
-- =====================================================================================
-- State: Iowa (IA)
-- Sub-Specialization: Dog Bite (Personal Injury)
-- Liability Model: STRICT LIABILITY (Statutory)
-- Legal Standard: Owner liable for damages caused by dog regardless of prior viciousness
-- Primary Authority: Iowa Code § 351.28
-- Statute of Limitations: 2 years (Iowa Code § 614.1)
-- 
-- VERIFICATION STATUS: DOCUMENT VERIFIED
-- Research Date: January 30, 2026
-- Sources Verified:
--   1. Iowa Code § 351.28 - Verified from Iowa Legislature and multiple legal sources
--   2. Iowa Code § 614.1 - 2-year SOL for personal injury
--   3. Strict liability - no proof of negligence or prior viciousness required
-- =====================================================================================

-- =====================================================================================
-- PART 1: LEGAL SOURCES
-- =====================================================================================

-- Source 1: Iowa Dog Bite Strict Liability Statute (Iowa Code § 351.28)
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
    'IA',
    NULL,
    NULL,
    'Iowa Dog Bite Strict Liability Statute',
    'Iowa Legislature',
    'Iowa Code § 351.28',
    'https://www.legis.iowa.gov/docs/code/351.28.pdf',
    'statute',
    'high',
    'Iowa Code § 351.28 - Liability for damages:

Any person owning or harboring a dog shall be liable for damages to any person who is injured by the dog, except if the person injured was doing any unlawful act directly contributing to the injury.

A person shall also be liable if a dog worries, maims, kills, or is caught worrying, maiming, or killing a domestic animal belonging to another.

However, if a dog has hydrophobia (rabies) and the owner or keeper did not know of the condition, and the owner or keeper could not have known of the condition, and the owner or keeper could not have prevented the injury by use of ordinary care, the owner or keeper is not liable.

KEY PROVISIONS:
- STRICT LIABILITY: Owner liable for damages regardless of negligence or prior knowledge of viciousness
- NO ONE-BITE RULE: Liability attaches even on first bite without prior aggressive behavior
- BROAD SCOPE: Applies to ANY person injured by dog (not limited to specific categories)
- OWNER OR HARBORER: Liability extends to anyone owning OR harboring dog
- EXCEPTION - UNLAWFUL ACT: Owner NOT liable if injured person was doing unlawful act directly contributing to injury
- EXCEPTION - RABIES (LIMITED): Owner not liable if dog had rabies AND owner did not/could not know AND could not have prevented with ordinary care
- APPLIES TO DOMESTIC ANIMALS: Owner also liable if dog worries, maims, or kills domestic animal

UNLAWFUL ACT DEFENSE:
- Injured person must have been doing "unlawful act"
- Unlawful act must have been "directly contributing" to injury
- Examples: Trespassing, provoking dog, committing crime
- Burden on owner to prove unlawful act

ABSOLUTE LIABILITY (with narrow exceptions):
- Iowa imposes strict, absolute liability on dog owners
- Owner liable regardless of dog''s history or owner''s knowledge
- Only defense: Injured person''s unlawful act directly contributing to injury

DOCUMENT VERIFIED from Iowa Legislature and multiple legal sources (dogbitelaw.com, JS Berry Law, Hauptman-O''Brien).'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET
    base_url = EXCLUDED.base_url,
    notes = EXCLUDED.notes;

-- Source 2: Iowa Statute of Limitations - Personal Injury (Iowa Code § 614.1)
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
    'IA',
    NULL,
    NULL,
    'Iowa Statute of Limitations - Personal Injury (Dog Bite)',
    'Iowa Legislature',
    'Iowa Code § 614.1',
    'https://www.legis.iowa.gov/docs/code/614.1.pdf',
    'statute',
    'high',
    'Iowa Code § 614.1(2) - Statute of limitations for personal injury actions:

Actions for injuries to persons or reputation shall be brought within two years from the time the cause of action accrues.

APPLICATION TO DOG BITES:
Claims brought under Iowa Code § 351.28 (strict liability statute) are subject to this TWO YEAR statute of limitations. The two-year period begins on the date of the dog bite injury.

TOLLING PROVISIONS (Iowa Code § 614.1(8)):
- Minors: If injured person was minor at time of injury, statute extended by one year after person turns 18
- Mental illness: If injured person had mental illness at time of injury, statute extended by one year after mental health issue ends
- Discovery rule: Time may be tolled if injury not immediately apparent until discovered
- Defendant leaves Iowa: Time defendant out of state may be tolled

GOVERNMENT CLAIMS:
- Claims against government entities may have shorter deadlines
- Special notice requirements apply

STRATEGIC NOTES:
- Must file within 2 years from date of dog bite (general rule)
- Evidence preservation critical
- Prompt medical attention and reporting essential

DOCUMENT VERIFIED from Iowa Legislature and multiple legal sources.'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET
    base_url = EXCLUDED.base_url,
    notes = EXCLUDED.notes;

-- =====================================================================================
-- PART 2: VALIDATION RULES
-- =====================================================================================

-- Rule 1: Iowa Strict Liability (Iowa Code § 351.28)
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
    'IA-PI-DOG-BITE-STRICT-LIABILITY',
    5,
    'IA Dog Bite Strict Liability (Iowa Code § 351.28)',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'IA',
    '{
        "liability_model": "strict_liability",
        "statute": "Iowa Code § 351.28",
        "legal_standard": "Owner liable for damages to any person injured by dog regardless of negligence or prior viciousness",
        "key_requirements": [
            "Dog injured plaintiff",
            "Defendant was owner or harborer of dog",
            "Plaintiff was NOT doing unlawful act directly contributing to injury",
            "Owner is liable for damages"
        ],
        "no_one_bite_rule": "Iowa does NOT follow one-bite rule; strict liability on first bite",
        "no_prior_knowledge_required": "Owner liable regardless of lack of knowledge of dog''s vicious propensities",
        "absolute_liability": "Iowa imposes strict, absolute liability on dog owners (with narrow exceptions)",
        "owner_or_harborer": "Liability extends to anyone owning OR harboring dog",
        "broad_scope": "Applies to ANY person injured by dog (not limited to specific categories like postal workers)",
        "exception_unlawful_act": {
            "requirement": "Injured person was doing unlawful act",
            "directly_contributing": "Unlawful act must have been directly contributing to injury",
            "examples": [
                "Trespassing",
                "Provoking dog",
                "Committing crime",
                "Engaging in other unlawful conduct"
            ],
            "burden": "Owner must prove injured person''s unlawful act directly contributed to injury",
            "complete_defense": "If proven, owner has NO liability"
        },
        "exception_rabies": {
            "narrow_exception": "Owner not liable if dog had rabies (hydrophobia) AND owner did not/could not know of condition AND owner could not have prevented injury with ordinary care",
            "rarely_applies": "This exception is rarely applicable in practice"
        },
        "damages_recoverable": [
            "Medical expenses",
            "Future medical care",
            "Lost wages",
            "Lost earning capacity",
            "Pain and suffering",
            "Emotional distress",
            "Permanent scarring/disfigurement",
            "Loss of quality of life"
        ],
        "domestic_animals": "Owner also liable if dog worries, maims, or kills domestic animal belonging to another"
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

-- Rule 2: Iowa Statute of Limitations - 2 Years
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
    'IA-PI-DOG-BITE-SOL-2-YEARS',
    5,
    'IA Dog Bite Statute of Limitations (2 Years)',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'IA',
    '{
        "statute": "Iowa Code § 614.1(2)",
        "statute_of_limitations": "2 years",
        "accrual_date": "Date cause of action accrues (date of dog bite injury)",
        "key_requirements": [
            "Action must be brought within 2 years from date of dog bite",
            "Applies to claims under Iowa Code § 351.28 (strict liability)",
            "Applies to all personal injury actions",
            "Failure to file timely bars recovery"
        ],
        "tolling_provisions": [
            "Minors: Statute extended by one year after person turns 18 (Iowa Code § 614.1(8))",
            "Mental illness: Statute extended by one year after mental health issue ends (Iowa Code § 614.1(8))",
            "Discovery rule: Time may be tolled if injury not immediately apparent",
            "Defendant leaves Iowa: Time defendant out of state may be tolled"
        ],
        "government_claims": {
            "shorter_deadlines": "Claims against government entities may have shorter deadlines",
            "special_notice": "Special notice requirements apply"
        },
        "strategic_notes": [
            "Evidence preservation critical (photographs, witness statements, medical records)",
            "Prompt medical attention and reporting essential",
            "Document injuries and treatment immediately",
            "Identify dog owner and witnesses promptly"
        ],
        "consequence_of_violation": "Claim time-barred; court will dismiss case; no recovery of any damages"
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
-- END OF IOWA DOG BITE RULES SEED FILE
-- =====================================================================================
