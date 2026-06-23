-- =====================================================================================
-- NEW MEXICO (NM) DOG BITE LIABILITY RULES
-- =====================================================================================
-- State: New Mexico (NM)
-- Practice Area: Personal Injury - Dog Bite Liability
-- Research Date: 2026-01-30
-- Primary Framework: NEGLIGENCE + SCIENTER ("One Bite Rule")
-- NO STRICT LIABILITY STATUTE
-- Dangerous Dog Act: NMSA 77-1A (enacted 2005)
-- Verification Status: COMPLETE - Multiple legal sources verified
-- Current Status: ACTIVE as of 2024-2025
-- =====================================================================================

-- RULE 1: Negligence-Based Liability (Primary Theory)
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'NM-DOG-BITE-NEGLIGENCE',
    5,
    'NM Dog Bite Negligence Liability Rule',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'NM',
    '{
        "liability_model": "negligence_based",
        "no_strict_liability_statute": true,
        "authority_level": "contextual_rule",
        "rule_statement": "New Mexico does not have a dog bite strict liability statute. Liability based on negligence or scienter.",
        "negligence_theory": {
            "elements": {
                "duty": {
                    "required": true,
                    "standard": "Owner has duty to exercise reasonable care to control dog and prevent foreseeable harm"
                },
                "breach": {
                    "required": true,
                    "examples": [
                        "Failing to restrain dog with known aggressive tendencies",
                        "Violating leash laws or local ordinances",
                        "Allowing dog to roam free in populated area",
                        "Inadequate containment or supervision"
                    ]
                },
                "causation": {
                    "required": true,
                    "but_for_cause": true,
                    "proximate_cause": true
                },
                "damages": {
                    "required": true,
                    "actual_injury": true
                }
            }
        },
        "burden_of_proof": {
            "plaintiff_must_prove": [
                "Owner owed duty of care",
                "Owner breached that duty",
                "Breach caused plaintiffs injuries",
                "Plaintiff suffered actual damages"
            ]
        },
        "verification": {
            "statute_verified": true,
            "no_strict_liability_confirmed": true,
            "multiple_sources": ["SalamPC", "DogBiteLaw.com", "Sutten Law", "Ring Jimenez", "Ferguson Law"],
            "current_as_of": "2024-2025",
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
    validator_level  = EXCLUDED.validator_level,
    validator_name   = EXCLUDED.validator_name,
    validator_type   = EXCLUDED.validator_type,
    severity         = EXCLUDED.severity,
    review_status    = EXCLUDED.review_status,
    is_active        = EXCLUDED.is_active,
    updated_at       = NOW();

-- RULE 2: Scienter / "One Bite Rule"
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'NM-DOG-BITE-SCIENTER-ONE-BITE',
    5,
    'NM Dog Bite Scienter/One Bite Rule',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'NM',
    '{
        "liability_theory": "scienter_one_bite_rule",
        "authority_level": "contextual_rule",
        "rule_statement": "Owner liable if knew or should have known dog had dangerous propensities or vicious tendencies.",
        "scienter_elements": {
            "knowledge_of_dangerousness": {
                "required": true,
                "types": ["actual_knowledge", "constructive_knowledge"],
                "actual_knowledge": "Owner actually knew dog was dangerous or vicious",
                "constructive_knowledge": "Owner should have known based on dogs behavior or history"
            },
            "dangerous_propensity": {
                "definition": "Dogs tendency or inclination to act in manner endangering safety of persons or property",
                "evidence": [
                    "Prior biting incidents",
                    "Prior aggressive behavior (growling, lunging, snapping)",
                    "Threats or menacing behavior",
                    "Training for aggressive behavior"
                ]
            }
        },
        "one_bite_rule": {
            "description": "Owner may not be liable for FIRST bite if no prior knowledge of dogs dangerous tendencies",
            "rationale": "Owner cannot know dog is dangerous until dog demonstrates dangerous behavior",
            "exception": "Rule does not apply if owner had other evidence of dangerous propensities"
        },
        "burden_of_proof": {
            "plaintiff_must_prove": [
                "Dog had dangerous or vicious propensities",
                "Owner knew or should have known of these propensities",
                "Propensity caused plaintiffs injuries"
            ]
        },
        "verification": {
            "multiple_sources_verified": true,
            "current_as_of": "2024-2025",
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
    validator_level  = EXCLUDED.validator_level,
    validator_name   = EXCLUDED.validator_name,
    validator_type   = EXCLUDED.validator_type,
    severity         = EXCLUDED.severity,
    review_status    = EXCLUDED.review_status,
    is_active        = EXCLUDED.is_active,
    updated_at       = NOW();

-- RULE 3: Dangerous Dog Act (NMSA 77-1A)
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'NM-DANGEROUS-DOG-ACT',
    6,
    'NM Dangerous Dog Act',
    'legal_research',
    'personal_injury',
    'complaint',
    'state',
    'NM',
    '{
        "statute": "NMSA 77-1A",
        "enacted": "2005",
        "current_status": "Active as of 2024",
        "authority_level": "contextual_rule",
        "rule_statement": "Separate regulatory framework for dangerous and potentially dangerous dogs with enhanced owner requirements and criminal penalties.",
        "dangerous_dog_definition": {
            "statute": "NMSA 77-1A-2",
            "definition": "Dog that has inflicted severe injury on or killed a human being without provocation; or killed a domestic animal without provocation while off owners property; or been previously declared potentially dangerous and exhibits dangerous behavior again"
        },
        "potentially_dangerous_dog_definition": {
            "statute": "NMSA 77-1A-2",
            "definition": "Dog that without provocation has bitten a human being; or when unprovoked, has chased or approached a person in menacing fashion or apparent attitude of attack; or has history of attacking domestic animals"
        },
        "registration_requirements": {
            "statute": "NMSA 77-1A-5",
            "potentially_dangerous": [
                "Demonstrate ability to control dog",
                "Current dog license and rabies vaccination",
                "Proper enclosure",
                "Annual registration fee",
                "Spay/neuter dog",
                "Microchip implantation",
                "Enroll in socialization program"
            ],
            "dangerous": [
                "All potentially dangerous requirements PLUS",
                "Written property owner permission",
                "Keep exclusively on owners property",
                "Cage or muzzle when off property with 4-foot lead",
                "Post warning sign"
            ]
        },
        "prohibited_acts_and_penalties": {
            "statute": "NMSA 77-1A-6",
            "misdemeanor_violations": [
                "No valid registration",
                "Violation of handling requirements",
                "Failure to report escape or attack",
                "Failure to notify authorities of death or sale"
            ],
            "felony_violations": {
                "fourth_degree_felony": "Dog causes serious injury to domestic animal without provocation",
                "third_degree_felony": "Dog causes serious injury or death to human without provocation"
            },
            "prosecution_requirement": "State must prove owner knew of dogs dangerous propensities OR dog previously declared dangerous by court"
        },
        "relevance_to_civil_litigation": {
            "evidentiary_value": "Prior dangerous dog declaration is strong evidence of owners knowledge",
            "negligence_per_se": "Violation of Dangerous Dog Act requirements may constitute negligence per se",
            "punitive_damages": "Willful violation may support punitive damages claim"
        },
        "verification": {
            "statute_verified": true,
            "official_source": "NMSA 77-1A",
            "current_as_of": "2024",
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

-- RULE 4: Negligence Per Se
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'NM-DOG-BITE-NEGLIGENCE-PER-SE',
    6,
    'NM Dog Bite Negligence Per Se',
    'legal_research',
    'personal_injury',
    'complaint',
    'state',
    'NM',
    '{
        "liability_theory": "negligence_per_se",
        "authority_level": "contextual_rule",
        "rule_statement": "Violation of statute or ordinance designed to protect public safety establishes automatic breach of duty.",
        "statutory_violations": {
            "examples": [
                "Violation of leash laws",
                "Violation of local animal control ordinances",
                "Violation of Dangerous Dog Act (NMSA 77-1A)",
                "Violation of rabies vaccination requirements"
            ]
        },
        "elements": {
            "statute_or_ordinance_violated": {
                "required": true,
                "must_be_safety_statute": true
            },
            "plaintiff_in_protected_class": {
                "required": true,
                "description": "Plaintiff must be member of class statute intended to protect"
            },
            "violation_caused_harm": {
                "required": true,
                "causation": "Violation must be proximate cause of injury"
            }
        },
        "legal_effect": {
            "duty_and_breach_established": "Violation automatically establishes duty and breach",
            "plaintiff_still_must_prove": ["causation", "damages"]
        },
        "verification": {
            "source_type": "common_law_doctrine",
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

-- RULE 5: Intentional Tort
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'NM-DOG-BITE-INTENTIONAL-TORT',
    6,
    'NM Dog Bite Intentional Tort',
    'legal_research',
    'personal_injury',
    'complaint',
    'state',
    'NM',
    '{
        "liability_theory": "intentional_tort",
        "authority_level": "contextual_rule",
        "rule_statement": "Owner may be liable for assault, battery, or intentional infliction of emotional distress if used dog as weapon or intentionally caused attack.",
        "intentional_torts": {
            "assault": {
                "definition": "Intentional act creating reasonable apprehension of imminent harmful or offensive contact",
                "example": "Owner threatens to release dog on victim"
            },
            "battery": {
                "definition": "Intentional harmful or offensive contact with another person",
                "example": "Owner intentionally directs dog to attack victim"
            },
            "intentional_infliction_of_emotional_distress": {
                "definition": "Extreme and outrageous conduct intentionally or recklessly causing severe emotional distress",
                "example": "Owner deliberately uses dog to terrorize victim"
            }
        },
        "elements": {
            "intent": {
                "required": true,
                "types": ["purpose to cause harm", "substantial certainty harm would occur"]
            },
            "act": {
                "required": true,
                "owner_action": "Owner must have directed or encouraged dog to attack"
            },
            "causation": {
                "required": true
            },
            "damages": {
                "required": true,
                "may_include_punitive": true
            }
        },
        "practical_application": {
            "rare_but_available": "Intentional tort claims rare but available in egregious cases",
            "punitive_damages": "Strong theory for punitive damages",
            "criminal_charges": "May overlap with criminal charges"
        },
        "verification": {
            "source_type": "common_law",
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

-- =====================================================================================
-- VERIFICATION QUERY
-- =====================================================================================

SELECT 
    rule_name,
    validator_config->>'liability_model' AS liability_model,
    validator_config->>'liability_theory' AS liability_theory,
    validator_config->>'statute' AS statute,
    validator_config->>'authority_level' AS authority_level,
    validator_config->'verification'->>'current_as_of' AS verified_current,
    is_active
FROM leverage.validation_rules
WHERE jurisdiction_state = 'NM'
  AND practice_area = 'personal_injury'
  AND rule_name LIKE '%DOG%'
ORDER BY validator_level;

-- =====================================================================================
-- END OF NEW MEXICO DOG BITE RULES
-- =====================================================================================
