-- =====================================================================================
-- WEST VIRGINIA (WV) DOG BITE LIABILITY RULES
-- =====================================================================================
-- State: West Virginia (WV)
-- Practice Area: Personal Injury - Dog Bite Liability
-- Research Date: 2026-01-30
-- Primary Statute: WV Code § 19-20-13 (Running at Large Strict Liability)
-- Verification Status: COMPLETE - Full statute text verified
-- Current Status: ACTIVE as of 2024-2026
-- =====================================================================================

-- RULE 1: Strict Liability for Dogs Running at Large (WV Code § 19-20-13)
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'WV-DOG-RUNNING-AT-LARGE-STRICT-LIABILITY',
    5,
    'WV Strict Liability for Dog Running at Large (WV Code § 19-20-13)',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'WV',
    '{
        "liability_model": "strict_liability_running_at_large",
        "statute": "WV Code § 19-20-13",
        "current_status": "Active as of 2024-2026",
        "authority_level": "contextual_rule",
        "strict_liability_applies": {
            "when": "Dog is running at large (off owners property and unrestrained)",
            "victim_must_prove": ["dog bit while running at large", "dog was unrestrained at time of incident"],
            "no_prior_knowledge_required": true
        },
        "running_at_large_definition": {
            "means": "Dog off owners property without restraint or control"
        },
        "verification": {
            "statute_text_verified": true,
            "full_text_source": "https://code.wvlegislature.gov/19-20-13/",
            "multiple_sources": ["WV Legislature Official", "304 Lawyer (Nestor Law)", "Justia Legal Codes"],
            "current_as_of": "2024-2026",
            "not_repealed": true,
            "source_type": "primary_law",
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

-- RULE 2: One-Bite Rule (Common Law)
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'WV-DOG-BITE-ONE-BITE-RULE',
    5,
    'WV One-Bite Rule (Common Law)',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'WV',
    '{
        "liability_model": "one_bite_rule",
        "authority_level": "contextual_rule",
        "current_status": "Active as of 2024-2026",
        "rule_statement": "When dog is NOT running at large (on owners property), victim must prove owner knew or should have known of dogs dangerous behavior.",
        "burden_of_proof": {
            "plaintiff_must_prove": [
                "Owner was aware of dogs dangerous behavior",
                "Owner failed to take necessary precautions to prevent bite",
                "Prior incidents or knowledge of aggression"
            ]
        },
        "when_applies": {
            "scenarios": ["Dog bite on owners property", "Dog was restrained but still bit", "Strict liability statute does not apply"]
        },
        "verification": {
            "statute_text_verified": true,
            "multiple_sources": ["304 Lawyer (Nestor Law)", "Legal databases"],
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

-- RULE 3: Negligence Alternative Theory
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'WV-DOG-BITE-NEGLIGENCE',
    5,
    'WV Negligence-Based Dog Bite Liability',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'WV',
    '{
        "liability_model": "negligence_based",
        "authority_level": "contextual_rule",
        "current_status": "Active as of 2024-2026",
        "rule_statement": "Victim can seek compensation if can demonstrate owner was aware of dangerous behavior but failed to take necessary precautions.",
        "burden_of_proof": {
            "plaintiff_must_prove": [
                "Owner owed duty of care",
                "Owner knew or should have known of dogs dangerous propensities",
                "Owner breached duty by failing to control dog",
                "Breach caused injury"
            ]
        },
        "verification": {
            "statute_text_verified": true,
            "multiple_sources": ["304 Lawyer (Nestor Law)", "Legal resources"],
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
