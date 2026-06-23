-- =====================================================================================
-- NEW YORK (NY) DOG BITE LIABILITY RULES
-- =====================================================================================
-- State: New York (NY)
-- Practice Area: Personal Injury - Dog Bite Liability
-- Research Date: 2026-01-30
-- Primary Framework: MIXED APPROACH (Limited Strict Liability + One Bite Rule)
-- Primary Statute: Agriculture & Markets Law § 123 (Dangerous Dogs)
-- Verification Status: COMPLETE - Multiple legal sources verified
-- Current Status: ACTIVE as of 2024-2026
-- =====================================================================================

-- RULE 1: Limited Strict Liability (Medical Costs Only)
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'NY-DOG-BITE-LIMITED-STRICT-LIABILITY',
    5,
    'NY Dog Bite Limited Strict Liability (Medical Costs)',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'NY',
    '{
        "liability_model": "mixed_limited_strict_liability",
        "statute": "Agriculture & Markets Law § 123",
        "current_status": "Active as of 2024-2026",
        "authority_level": "contextual_rule",
        "rule_statement": "Owner of dangerous dog strictly liable for medical and veterinary costs resulting from injuries caused by dog. Other damages require proof of owners knowledge of vicious propensities.",
        "strict_liability_scope": {
            "limited_to": "medical_and_veterinary_costs_only",
            "does_not_cover": [
                "pain and suffering",
                "lost wages",
                "property damage",
                "emotional distress"
            ]
        },
        "dangerous_dog_definition": {
            "statute": "Agric. & Mkts. Law § 108(24)",
            "definition": "Dog that: (a) without justification attacks person causing physical injury or death; (b) behaves in manner that reasonable person would believe poses serious and unjustified imminent threat of serious physical injury or death; or (c) without justification attacks domestic animal causing physical injury or death"
        },
        "elements": {
            "dangerous_dog_declared": {
                "required": true,
                "process": "Formal judicial determination under § 123 OR behavior meeting statutory definition",
                "note": "Strict liability applies once dog deemed dangerous under statute"
            },
            "medical_or_veterinary_costs": {
                "required": true,
                "includes": [
                    "Emergency treatment",
                    "Hospitalization",
                    "Surgery",
                    "Follow-up care",
                    "Rehabilitation",
                    "Veterinary costs if animal injured"
                ]
            }
        },
        "exceptions": {
            "not_liable_when": [
                "Person was trespassing",
                "Person was committing or attempting to commit crime",
                "Person was tormenting, abusing, or assaulting dog",
                "Person was assaulting dog owner or member of household",
                "Dog was protecting itself or puppies from attack or harassment"
            ]
        },
        "verification": {
            "statute_text_verified": true,
            "multiple_sources": ["Porter Law Group", "Brandon J Broderick", "Finz Firm", "Raphaelson Levine", "NYSBA Q&A"],
            "current_as_of": "2024-2026",
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

-- RULE 2: One Bite Rule (For Non-Medical Damages)
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'NY-DOG-BITE-ONE-BITE-RULE',
    5,
    'NY Dog Bite One Bite Rule (Non-Medical Damages)',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'NY',
    '{
        "liability_theory": "one_bite_rule_scienter",
        "authority_level": "contextual_rule",
        "rule_statement": "To recover damages beyond medical costs, plaintiff must prove owner knew or should have known dog had vicious propensities.",
        "damages_covered": {
            "requires_proof_of_knowledge": [
                "Pain and suffering",
                "Lost wages",
                "Loss of earning capacity",
                "Emotional distress",
                "Scarring and disfigurement",
                "Property damage"
            ]
        },
        "elements": {
            "vicious_propensity": {
                "required": true,
                "definition": "Dogs tendency to act in manner that endangers safety of persons or property",
                "evidence": [
                    "Prior biting incidents",
                    "Prior aggressive behavior (growling, lunging, snapping)",
                    "Menacing or threatening behavior",
                    "Training for aggressive behavior",
                    "Breed reputation (limited evidentiary value)"
                ]
            },
            "owner_knowledge": {
                "required": true,
                "types": ["actual_knowledge", "constructive_knowledge"],
                "actual_knowledge": "Owner knew dog was vicious or dangerous",
                "constructive_knowledge": "Owner should have known based on dogs behavior or circumstances"
            },
            "causation": {
                "required": true,
                "vicious_propensity_caused_injury": true
            },
            "damages": {
                "required": true,
                "actual_damages": true
            }
        },
        "one_bite_rule_application": {
            "first_bite_may_be_free": "Owner may not be liable for first bite if no prior knowledge of dangerous propensities",
            "exception": "No free bite if owner had other evidence of vicious propensities",
            "burden_of_proof": "Plaintiff must prove owners knowledge"
        },
        "verification": {
            "multiple_sources_verified": true,
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
    validator_level  = EXCLUDED.validator_level,
    validator_name   = EXCLUDED.validator_name,
    validator_type   = EXCLUDED.validator_type,
    severity         = EXCLUDED.severity,
    review_status    = EXCLUDED.review_status,
    is_active        = EXCLUDED.is_active,
    updated_at       = NOW();

-- RULE 3: Dangerous Dog Act (Agric. & Markets § 123)
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'NY-DANGEROUS-DOG-ACT',
    6,
    'NY Dangerous Dog Act',
    'legal_research',
    'personal_injury',
    'complaint',
    'state',
    'NY',
    '{
        "statute": "Agriculture & Markets Law § 123",
        "current_status": "Active as of 2024-2026",
        "authority_level": "contextual_rule",
        "rule_statement": "Comprehensive dangerous dog regulatory framework with judicial determination process, owner requirements, and civil/criminal penalties.",
        "judicial_determination_process": {
            "complaint": "Any person witnessing attack or threatened attack may report to dog control or police officer",
            "petition": "Officer informs complainant of right to initiate proceeding; officer may initiate if believes dog is dangerous",
            "seizure": "Judge may order dog seized pending hearing if probable cause exists",
            "hearing": "Held within 5 business days of seizure; petitioner must prove dog is dangerous by clear and convincing evidence",
            "standard_of_proof": "clear_and_convincing_evidence"
        },
        "orders_for_dangerous_dogs": {
            "basic_requirements": [
                "Neutering or spaying",
                "Microchip identification",
                "Behavioral evaluation and training",
                "Proper confinement when on owners property",
                "Leash and muzzle requirements when off property",
                "Liability insurance (up to $100,000)"
            ],
            "aggravating_circumstances_orders": {
                "applies_when": [
                    "Dog attacked person causing serious injury or death without justification",
                    "Dog has known vicious propensity as evidenced by prior attack",
                    "Dog caused serious injury or death to domestic animal without justification"
                ],
                "potential_orders": [
                    "Humane euthanasia",
                    "Permanent confinement"
                ]
            }
        },
        "justification_defenses": {
            "dog_not_declared_dangerous_when": [
                "Person was committing crime against owner or property",
                "Person was trespassing",
                "Person was tormenting, abusing, or assaulting dog",
                "Person was assaulting owner or household member",
                "Dog was protecting itself or puppies",
                "Dog was trained law enforcement or military animal performing duties"
            ]
        },
        "civil_and_criminal_penalties": {
            "civil_penalty": {
                "first_offense": "$400 if dog bites person causing physical injury",
                "serious_injury": "$1,500 if dog causes serious physical injury",
                "second_dangerous_determination": "Up to $2,000",
                "third_determination": "Up to $3,000"
            },
            "criminal_penalty": {
                "misdemeanor": "If dog causes serious physical injury or death to person",
                "applies_when": "Owner knew or should have known of dogs vicious propensities OR dog previously adjudicated dangerous"
            }
        },
        "appeals": {
            "timeframe": "30 days from dangerous dog determination or court order",
            "scope": "Appeal determination and/or courts order"
        },
        "verification": {
            "statute_verified": true,
            "official_sources": ["NY Senate", "FindLaw", "NYSBA"],
            "current_as_of": "2024-2026",
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

-- RULE 4: Negligence (Alternative Theory)
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'NY-DOG-BITE-NEGLIGENCE',
    6,
    'NY Dog Bite Negligence',
    'legal_research',
    'personal_injury',
    'complaint',
    'state',
    'NY',
    '{
        "liability_theory": "common_law_negligence",
        "authority_level": "contextual_rule",
        "rule_statement": "Alternative liability theory based on failure to exercise reasonable care in controlling dog.",
        "elements": {
            "duty": {
                "required": true,
                "standard": "Owner has duty to exercise reasonable care to control dog and prevent foreseeable harm"
            },
            "breach": {
                "required": true,
                "examples": [
                    "Failing to restrain dog with known aggressive tendencies",
                    "Violating leash laws (e.g., NYC leash law)",
                    "Allowing dog to roam free",
                    "Inadequate supervision or containment",
                    "Ignoring prior incidents or warnings"
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
        },
        "when_to_use": {
            "no_vicious_propensity_proven": "If cannot prove dog had vicious propensities",
            "owner_negligence_clear": "When owner clearly breached duty of care",
            "violations_of_ordinances": "Violation of local leash laws or ordinances",
            "alternative_theory": "Backup theory to one-bite rule"
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
WHERE jurisdiction_state = 'NY'
  AND practice_area = 'personal_injury'
  AND rule_name LIKE '%DOG%'
ORDER BY validator_level;

-- =====================================================================================
-- END OF NEW YORK DOG BITE RULES
-- =====================================================================================
