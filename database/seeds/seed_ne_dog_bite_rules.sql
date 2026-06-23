-- =====================================================================================
-- NEBRASKA (NE) DOG BITE LIABILITY RULES
-- =====================================================================================
-- State: Nebraska (NE)
-- Practice Area: Personal Injury - Dog Bite Liability
-- Research Date: 2026-01-30
-- Source: Neb. Rev. Stat. § 54-601 (2024)
-- =====================================================================================

-- RULE 1: Primary Strict Liability Statute
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'NE-DOG-BITE-STRICT-LIABILITY',
    5,
    'NE Dog Bite Strict Liability Rule',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'NE',
    '{
        "liability_model": "strict_liability",
        "statute": "Neb. Rev. Stat. § 54-601",
        "authority_level": "contextual_rule",
        "rule_statement": "Dogs are personal property. The owner of a dog shall be liable for any damages sustained by any person by being bitten, or the killing, wounding, injuring, worrying, or chasing of any person or any domestic animal.",
        "elements": {
            "ownership": {
                "required": true,
                "definition": "Any person having control of the dog",
                "proof_standard": "Ownership or control at time of incident"
            },
            "injury_caused": {
                "required": true,
                "types": ["bitten", "killed", "wounded", "injured", "worried", "chased"],
                "applies_to": ["any person", "any domestic animal"]
            },
            "no_prior_knowledge_required": {
                "strict_liability": true,
                "first_bite_rule": false,
                "scienter_not_required": true
            }
        },
        "exceptions": {
            "trespasser_exception": {
                "applies": true,
                "description": "Owner not liable for damages to trespassers"
            },
            "governmental_exception": {
                "applies": true,
                "description": "Exception for governmental agencies using dogs in military or police work under specific conditions"
            },
            "playfulness_defense": {
                "controversial": true,
                "description": "Statute may not apply if dog actions were due to playfulness or mischievousness",
                "note": "This limitation is considered ambiguous and may be challenged"
            }
        },
        "damages_covered": {
            "medical_expenses": true,
            "lost_wages": true,
            "pain_and_suffering": true,
            "property_damage": true,
            "emotional_distress": true
        },
        "verification": {
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
    validator_level  = EXCLUDED.validator_level,
    validator_name   = EXCLUDED.validator_name,
    validator_type   = EXCLUDED.validator_type,
    severity         = EXCLUDED.severity,
    review_status    = EXCLUDED.review_status,
    is_active        = EXCLUDED.is_active,
    updated_at       = NOW();

-- RULE 2: Trespasser Exception
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'NE-DOG-BITE-TRESPASSER-EXCEPTION',
    6,
    'NE Dog Bite Trespasser Exception',
    'legal_research',
    'personal_injury',
    'complaint',
    'state',
    'NE',
    '{
        "exception_type": "trespasser_defense",
        "statute": "Neb. Rev. Stat. § 54-601",
        "authority_level": "contextual_rule",
        "rule_statement": "The owner of a dog shall not be liable for damages to any person who is a trespasser.",
        "trespasser_definition": {
            "unlawful_presence": true,
            "without_permission": true,
            "on_private_property": true
        },
        "burden_of_proof": {
            "on_defendant": true,
            "must_prove": "Plaintiff was trespassing at time of incident"
        },
        "scope": {
            "applies_to": "strict_liability_claims",
            "complete_bar": true,
            "no_comparative_fault": "Defense is absolute if proven"
        },
        "verification": {
            "source_type": "primary_law",
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
    validator_level  = EXCLUDED.validator_level,
    validator_name   = EXCLUDED.validator_name,
    validator_type   = EXCLUDED.validator_type,
    severity         = EXCLUDED.severity,
    review_status    = EXCLUDED.review_status,
    is_active        = EXCLUDED.is_active,
    updated_at       = NOW();

-- RULE 3: Playfulness/Mischievousness Defense (Controversial)
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'NE-DOG-BITE-PLAYFULNESS-DEFENSE',
    6,
    'NE Dog Bite Playfulness Defense',
    'legal_research',
    'personal_injury',
    'complaint',
    'state',
    'NE',
    '{
        "defense_type": "playfulness_mischievousness",
        "statute": "Neb. Rev. Stat. § 54-601 (judicial interpretation)",
        "authority_level": "contextual_rule",
        "rule_statement": "The strict liability statute may not apply if the dog actions were due to playfulness or mischievousness.",
        "controversy": {
            "ambiguous": true,
            "subjective_standard": true,
            "difficult_to_determine_intent": true,
            "criticism": "This limitation is considered flawed due to ambiguity in determining a dogs intent"
        },
        "factors_considered": {
            "witness_statements": true,
            "injury_severity": true,
            "dog_behavior_during_incident": true,
            "prior_behavior_history": true,
            "context_of_interaction": true
        },
        "burden_of_proof": {
            "on_defendant": true,
            "must_prove": "Dog was acting playfully or mischievously, not aggressively"
        },
        "practical_application": {
            "fact_intensive": true,
            "jury_question": true,
            "outcome_unpredictable": true
        },
        "verification": {
            "source_type": "case_law_interpretation",
            "last_verified": "2026-01-30",
            "verified_by": "DRAFT_research_agent",
            "confidence": "medium"
        }
    }'::jsonb,
    'info',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
) ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    validator_level  = EXCLUDED.validator_level,
    validator_name   = EXCLUDED.validator_name,
    validator_type   = EXCLUDED.validator_type,
    severity         = EXCLUDED.severity,
    review_status    = EXCLUDED.review_status,
    is_active        = EXCLUDED.is_active,
    updated_at       = NOW();

-- RULE 4: Governmental/Police Dog Exception
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'NE-DOG-BITE-GOVERNMENT-EXCEPTION',
    6,
    'NE Dog Bite Government Exception',
    'legal_research',
    'personal_injury',
    'complaint',
    'state',
    'NE',
    '{
        "exception_type": "governmental_immunity",
        "statute": "Neb. Rev. Stat. § 54-601",
        "authority_level": "contextual_rule",
        "rule_statement": "Exception to liability for governmental agencies using dogs in military or police work under specific conditions.",
        "scope": {
            "applies_to": ["military_dogs", "police_dogs"],
            "agency_type": "governmental",
            "conditions_required": true
        },
        "requirements": {
            "official_duty": true,
            "proper_training": true,
            "authorized_use": true,
            "specific_conditions_met": true
        },
        "verification": {
            "source_type": "primary_law",
            "last_verified": "2026-01-30",
            "verified_by": "DRAFT_research_agent",
            "confidence": "high"
        }
    }'::jsonb,
    'info',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
) ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    validator_level  = EXCLUDED.validator_level,
    validator_name   = EXCLUDED.validator_name,
    validator_type   = EXCLUDED.validator_type,
    severity         = EXCLUDED.severity,
    review_status    = EXCLUDED.review_status,
    is_active        = EXCLUDED.is_active,
    updated_at       = NOW();

-- RULE 5: Statute of Limitations (Personal Injury)
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'NE-DOG-BITE-SOL',
    5,
    'NE Dog Bite Statute of Limitations',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'NE',
    '{
        "sol_years": 4,
        "sol_days": 1460,
        "statute": "Neb. Rev. Stat. § 25-207",
        "authority_level": "contextual_rule",
        "rule_statement": "Dog bite claims fall under general personal injury statute of limitations: 4 years from date of injury.",
        "accrual": {
            "trigger_event": "date_of_injury",
            "discovery_rule": false
        },
        "verification": {
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
    validator_level  = EXCLUDED.validator_level,
    validator_name   = EXCLUDED.validator_name,
    validator_type   = EXCLUDED.validator_type,
    severity         = EXCLUDED.severity,
    review_status    = EXCLUDED.review_status,
    is_active        = EXCLUDED.is_active,
    updated_at       = NOW();

-- =====================================================================================
-- VERIFICATION QUERY
-- =====================================================================================

SELECT 
    rule_name,
    validator_config->>'liability_model' AS liability_model,
    validator_config->>'statute' AS statute,
    validator_config->>'authority_level' AS authority_level,
    is_active
FROM leverage.validation_rules
WHERE jurisdiction_state = 'NE'
  AND practice_area = 'personal_injury'
  AND rule_name LIKE '%DOG-BITE%'
ORDER BY validator_level;

-- =====================================================================================
-- END OF NEBRASKA DOG BITE RULES
-- =====================================================================================
