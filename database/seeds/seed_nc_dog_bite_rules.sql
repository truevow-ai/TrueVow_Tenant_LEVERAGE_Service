-- =====================================================================================
-- NORTH CAROLINA (NC) DOG BITE LIABILITY RULES
-- =====================================================================================
-- State: North Carolina (NC)
-- Practice Area: Personal Injury - Dog Bite Liability
-- Research Date: 2026-01-30
-- Primary Framework: MIXED (Strict Liability for Dangerous Dogs + Negligence)
-- Primary Statutes: G.S. 67-4.4 (Strict Liability), G.S. 67-12 (Running at Large)
-- Verification Status: COMPLETE - Multiple legal sources verified
-- Current Status: ACTIVE as of 2024
-- =====================================================================================

-- RULE 1: Strict Liability for Dangerous Dogs (G.S. 67-4.4)
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'NC-DOG-BITE-DANGEROUS-DOG-STRICT-LIABILITY',
    5,
    'NC Dangerous Dog Strict Liability Rule',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'NC',
    '{
        "liability_model": "strict_liability_dangerous_dogs",
        "statute": "N.C. Gen. Stat. § 67-4.4",
        "current_status": "Active as of 2024",
        "authority_level": "contextual_rule",
        "rule_statement": "Owner of dangerous dog strictly liable for any injuries or property damage dog inflicts, regardless of owners prior knowledge or negligence.",
        "dangerous_dog_definition": {
            "statute": "N.C. Gen. Stat. § 67-4.1(a)(1)",
            "criteria": [
                "Without provocation killed or inflicted severe injury on person",
                "Without provocation killed or inflicted severe injury on domestic animal when not on owners property",
                "Approached person when not on owners property in vicious or terrorizing manner in apparent attitude of attack",
                "Owned or harbored primarily for dog fighting"
            ],
            "severe_injury_definition": "Injury resulting in broken bones, disfiguring lacerations requiring cosmetic surgery, or requiring hospitalization"
        },
        "strict_liability_scope": {
            "covers": [
                "Personal injuries",
                "Property damage",
                "Injuries to other animals"
            ],
            "no_prior_knowledge_required": true,
            "no_negligence_required": true
        },
        "elements": {
            "dangerous_dog": {
                "required": true,
                "formal_declaration_not_required": "Dog need only meet statutory definition; formal dangerous dog declaration not prerequisite for strict liability"
            },
            "injury_or_damage": {
                "required": true,
                "types": ["personal injury", "property damage", "injury to animals"]
            },
            "no_provocation": {
                "required": true,
                "burden": "Defendant must prove provocation as defense"
            }
        },
        "defenses": {
            "provocation": "If victim provoked dog, strict liability may not apply",
            "trespass": "If victim was trespassing on owners property",
            "crime": "If victim was committing crime on owners property"
        },
        "verification": {
            "statute_text_verified": true,
            "multiple_sources": ["NC Legislature", "DogBiteLaw.com", "LawyerNC", "CSHLaw", "Nolo"],
            "current_as_of": "2024",
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

-- RULE 2: Strict Liability for Dogs Running at Large (G.S. 67-12)
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'NC-DOG-RUNNING-AT-LARGE-LIABILITY',
    5,
    'NC Dog Running at Large Strict Liability',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'NC',
    '{
        "liability_model": "strict_liability_running_at_large",
        "statute": "N.C. Gen. Stat. § 67-12",
        "current_status": "Active as of 2024",
        "authority_level": "contextual_rule",
        "rule_statement": "Owner liable for damages if dog over 6 months runs at large at night without owner supervision.",
        "running_at_large_definition": {
            "age_requirement": "Dog must be over 6 months old",
            "time_requirement": "During nighttime hours",
            "supervision_requirement": "Without owner or owners agent supervision"
        },
        "criminal_penalty": {
            "violation": "Class 3 misdemeanor",
            "applies_to": "Allowing dog to run at large at night"
        },
        "civil_liability": {
            "strict_liability": true,
            "damages": "Owner liable for any injuries to person or property caused by dog running at large",
            "no_knowledge_required": true
        },
        "practical_application": {
            "easier_to_prove": "Plaintiff need only show dog was running at large at night, not that dog was dangerous",
            "no_prior_incidents_required": true,
            "automatic_liability": "Violation of statute establishes liability"
        },
        "verification": {
            "statute_text_verified": true,
            "official_source": "NC Legislature",
            "current_as_of": "2024",
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

-- RULE 3: One Bite Rule / Negligence
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'NC-DOG-BITE-NEGLIGENCE-ONE-BITE',
    6,
    'NC Dog Bite Negligence/One Bite Rule',
    'legal_research',
    'personal_injury',
    'complaint',
    'state',
    'NC',
    '{
        "liability_theory": "negligence_one_bite_rule",
        "authority_level": "contextual_rule",
        "rule_statement": "If dog does not qualify as dangerous or running at large, owner may still be liable under common law negligence or one-bite rule.",
        "one_bite_rule": {
            "description": "Owner liable if knew or should have known dog had vicious propensities",
            "elements": {
                "vicious_propensity": {
                    "required": true,
                    "evidence": [
                        "Prior biting incidents",
                        "Prior aggressive behavior",
                        "Menacing or threatening behavior",
                        "Owners knowledge of dangerous tendencies"
                    ]
                },
                "owner_knowledge": {
                    "required": true,
                    "types": ["actual_knowledge", "constructive_knowledge"]
                },
                "causation": {
                    "required": true
                },
                "damages": {
                    "required": true
                }
            }
        },
        "negligence_theory": {
            "elements": {
                "duty": "Owner has duty to exercise reasonable care to control dog",
                "breach": "Owner failed to exercise reasonable care",
                "causation": "Breach caused plaintiffs injuries",
                "damages": "Plaintiff suffered actual damages"
            },
            "examples_of_negligence": [
                "Failing to restrain dog with known aggressive tendencies",
                "Inadequate containment or supervision",
                "Violating leash laws",
                "Ignoring prior warnings or incidents"
            ]
        },
        "when_to_use": {
            "dog_not_dangerous": "When dog does not meet statutory dangerous dog definition",
            "not_running_at_large": "When dog was not running at large at night",
            "alternative_theory": "As backup theory to strict liability claims"
        },
        "verification": {
            "source_type": "common_law",
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

-- RULE 4: Potentially Dangerous Dog Regulations (G.S. 67-4.1)
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'NC-POTENTIALLY-DANGEROUS-DOG-REGULATIONS',
    6,
    'NC Potentially Dangerous Dog Regulations',
    'legal_research',
    'personal_injury',
    'complaint',
    'state',
    'NC',
    '{
        "statute": "N.C. Gen. Stat. § 67-4.1",
        "current_status": "Active as of 2024",
        "authority_level": "contextual_rule",
        "rule_statement": "Separate classification and regulatory framework for potentially dangerous dogs with less severe behavior than dangerous dogs.",
        "potentially_dangerous_dog_definition": {
            "criteria": [
                "Has bitten person causing serious injury but not severe injury",
                "Has killed or severely injured domestic animal when not on owners property",
                "Has approached person aggressively in apparent attitude of attack when not on owners property"
            ],
            "serious_injury": "Injury requiring medical treatment but not rising to level of severe injury"
        },
        "determination_process": {
            "initial_determination": "Animal control or law enforcement makes initial assessment",
            "owner_notification": "Owner notified in writing of potentially dangerous designation",
            "appeal_process": "Owner may appeal to designated board within 3 days",
            "final_review": "Superior court has jurisdiction for final review"
        },
        "owner_requirements": {
            "registration": "Must register dog with animal control",
            "confinement": "Must keep dog in secure enclosure or on leash",
            "insurance": "May be required to obtain liability insurance",
            "warning_signs": "May be required to post warning signs"
        },
        "relevance_to_litigation": {
            "evidence_of_knowledge": "Potentially dangerous designation proves owner knew of aggressive tendencies",
            "negligence_per_se": "Violation of requirements may constitute negligence per se",
            "stricter_duty_of_care": "Owner held to higher standard of care"
        },
        "verification": {
            "statute_verified": true,
            "official_source": "NC Legislature",
            "current_as_of": "2024",
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
WHERE jurisdiction_state = 'NC'
  AND practice_area = 'personal_injury'
  AND rule_name LIKE '%DOG%'
ORDER BY validator_level;

-- =====================================================================================
-- END OF NORTH CAROLINA DOG BITE RULES
-- =====================================================================================
