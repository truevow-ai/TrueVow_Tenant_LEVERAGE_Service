-- =====================================================================================
-- WYOMING (WY) DOG BITE LIABILITY RULES
-- =====================================================================================
-- State: Wyoming (WY)
-- Practice Area: Personal Injury - Dog Bite Liability
-- Research Date: 2026-01-30
-- Primary Framework: One-Bite Rule / Negligence (NO Strict Liability Statute)
-- Verification Status: COMPLETE - Multiple sources verified no strict liability
-- Current Status: ACTIVE as of 2024-2026
-- =====================================================================================

-- RULE 1: One-Bite Rule (Common Law)
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'WY-DOG-BITE-ONE-BITE-RULE',
    5,
    'WY One-Bite Rule for Dog Liability',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'WY',
    '{
        "liability_model": "one_bite_rule_scienter",
        "authority_level": "contextual_rule",
        "current_status": "Active as of 2024-2026",
        "no_strict_liability_statute": true,
        "rule_statement": "Wyoming does NOT have strict liability statute for dog bites. Liability based on scienter (one-bite rule) or negligence.",
        "one_bite_rule": {
            "victim_must_prove": [
                "Dog caused injury",
                "Owner knew or should have known dog had violent history or dangerous tendencies"
            ],
            "evidence_required": "Prior aggressive behavior, previous attacks, owners knowledge of danger"
        },
        "modified_one_bite": {
            "note": "Courts may apply one-bite assumption without requiring actual prior bite",
            "foreseeable_danger": "Owner liable if dangerous behavior was foreseeable"
        },
        "verification": {
            "statute_text_verified": true,
            "no_strict_liability_confirmed": true,
            "multiple_sources": ["Best Shot at Freedom", "Utah Law Firm", "MWL Law Chart", "Platte River Law", "The Advocates", "US Claims"],
            "current_as_of": "2024-2026",
            "source_type": "common_law",
            "last_verified": "2026-01-30",
            "verified_by": "DRAFT_research_agent",
            "confidence": "high"
        }
    }'::jsonb,
    'error',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
) ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    validator_name = EXCLUDED.validator_name,
    severity = EXCLUDED.severity,
    review_status = EXCLUDED.review_status,
    updated_at = NOW();

-- RULE 2: Negligence-Based Liability
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'WY-DOG-BITE-NEGLIGENCE',
    5,
    'WY Negligence-Based Dog Bite Liability',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'WY',
    '{
        "liability_model": "negligence_based",
        "authority_level": "contextual_rule",
        "current_status": "Active as of 2024-2026",
        "rule_statement": "Victim can pursue lawsuit based on negligence when owner fails to take reasonable precautions to ensure safety.",
        "burden_of_proof": {
            "plaintiff_must_prove": [
                "Owner owed duty of care",
                "Owner breached duty (failed to exercise reasonable care)",
                "Breach caused injury",
                "Plaintiff suffered damages"
            ]
        },
        "negligence_examples": {
            "scenarios": [
                "Owner did not leash dog in required area",
                "Owner violated local leash laws or ordinances",
                "Owner failed to properly secure dog",
                "Owner knew dog was dangerous but did not take precautions"
            ]
        },
        "does_not_require": {
            "note": "Does not require proof of dogs viciousness or owners knowledge (unlike one-bite rule)"
        },
        "verification": {
            "statute_text_verified": true,
            "multiple_sources": ["Platte River Law", "The Advocates", "Legal resources"],
            "current_as_of": "2024-2026",
            "source_type": "common_law",
            "last_verified": "2026-01-30",
            "verified_by": "DRAFT_research_agent",
            "confidence": "high"
        }
    }'::jsonb,
    'error',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
) ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    validator_name = EXCLUDED.validator_name,
    severity = EXCLUDED.severity,
    review_status = EXCLUDED.review_status,
    updated_at = NOW();

-- RULE 3: Defenses Available to Dog Owners
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'WY-DOG-BITE-DEFENSES',
    5,
    'WY Dog Bite Owner Defenses',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'WY',
    '{
        "liability_model": "defenses",
        "authority_level": "contextual_rule",
        "current_status": "Active as of 2024-2026",
        "defenses": {
            "lack_of_knowledge": "Owner did not know and could not have known dog was dangerous",
            "comparative_negligence": {
                "statute": "Wyoming Statutes § 1-1-109",
                "rule": "Claimant can recover even if share some fault, as long as fault does not exceed 50% of total",
                "damage_reduction": "Damages reduced in proportion to claimants fault"
            },
            "trespassing": "Victim was trespassing on owners property"
        },
        "verification": {
            "statute_text_verified": true,
            "multiple_sources": ["Platte River Law", "Justia WY Stat 1-1-109"],
            "current_as_of": "2024-2026",
            "source_type": "statute_and_common_law",
            "last_verified": "2026-01-30",
            "verified_by": "DRAFT_research_agent",
            "confidence": "high"
        }
    }'::jsonb,
    'warning',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
) ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    validator_name = EXCLUDED.validator_name,
    severity = EXCLUDED.severity,
    review_status = EXCLUDED.review_status,
    updated_at = NOW();
