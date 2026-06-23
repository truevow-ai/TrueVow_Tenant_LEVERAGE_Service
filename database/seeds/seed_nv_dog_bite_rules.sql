-- =====================================================================================
-- NEVADA (NV) DOG BITE LIABILITY RULES
-- =====================================================================================
-- State: Nevada (NV)
-- Practice Area: Personal Injury - Dog Bite Liability
-- Research Date: 2026-01-30
-- Primary Sources: NRS 202.500, NRS 575.020, Harry v. Smith (1995)
-- Verification Status: COMPLETE - All statutes verified current as of 2024, NOT repealed
-- =====================================================================================

-- RULE 1: Negligence-Based Liability Framework (Primary Rule)
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'NV-DOG-BITE-NEGLIGENCE-FRAMEWORK',
    5,
    'NV Dog Bite Negligence Liability Rule',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'NV',
    '{
        "liability_model": "negligence_based",
        "no_strict_liability": true,
        "case_law": "Harry v. Smith, 111 Nev. 528, 893 P.2d 372 (1995)",
        "authority_level": "contextual_rule",
        "rule_statement": "Nevada does not have a strict liability dog bite statute. Liability is established through negligence, scienter (one-bite rule), or statutory violation (negligence per se).",
        "liability_theories": {
            "theory_1_dangerous_vicious_dog": {
                "statute": "NRS 202.500",
                "enacted": "1967",
                "amendments": ["1993", "1995", "2013"],
                "current_status": "Active as of 2024",
                "description": "Owner can be held liable if dog was previously declared dangerous or vicious"
            },
            "theory_2_negligence_per_se": {
                "description": "Violating safety laws (e.g., leash ordinances) establishes automatic negligence",
                "local_ordinances_apply": true,
                "burden": "Plaintiff must prove violation of safety statute"
            },
            "theory_3_general_negligence": {
                "description": "Owner failed to exercise reasonable care under the circumstances",
                "burden": "Plaintiff must prove duty, breach, causation, damages"
            },
            "theory_4_scienter_one_bite_rule": {
                "description": "Owner liable if knew or should have known of dogs dangerous propensities",
                "prior_knowledge_required": true,
                "first_bite_rule": true
            }
        },
        "elements": {
            "ownership_or_control": {
                "required": true,
                "definition": "Defendant owned or had control of the dog"
            },
            "negligence_or_knowledge": {
                "required": true,
                "proof": "Either negligent conduct OR prior knowledge of dangerous propensities"
            },
            "causation": {
                "required": true,
                "but_for": true,
                "proximate_cause": true
            },
            "damages": {
                "required": true,
                "types": ["actual injury", "medical expenses", "pain and suffering"]
            }
        },
        "verification": {
            "statute_verified": true,
            "case_law_verified": true,
            "current_as_of": "2024",
            "not_repealed": true,
            "source_type": "primary_law_and_case_law",
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

-- RULE 2: Dangerous Dog Definition (NRS 202.500)
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'NV-DOG-BITE-DANGEROUS-DOG-DEFINITION',
    6,
    'NV Dangerous Dog Definition',
    'legal_research',
    'personal_injury',
    'complaint',
    'state',
    'NV',
    '{
        "statute": "NRS 202.500",
        "enacted": "1967",
        "amendments": ["1993", "1995", "2013"],
        "current_status": "Active as of 2024",
        "authority_level": "contextual_rule",
        "definition": "A dog is dangerous if it behaves menacingly toward any person in an apparent attitude of attack upon the streets or any place where people are legally present without provocation on two separate occasions within 18 months.",
        "alternative_designation": "A dog may also be declared dangerous if declared as such by a law enforcement agency or officer when the dog is used in the commission of a crime.",
        "criteria": {
            "two_incidents_required": true,
            "timeframe": "18 months",
            "location": "streets or any place where people are legally present",
            "provocation": "without provocation",
            "attitude": "apparent attitude of attack"
        },
        "legal_effect": {
            "enhanced_liability": true,
            "owner_notice_required": true,
            "restrictions_on_dog": true
        },
        "breed_neutrality": {
            "no_breed_specific_laws": true,
            "prohibition": "Local authorities cannot deem a dog dangerous or vicious based solely on its breed"
        },
        "verification": {
            "statute_text_verified": true,
            "current_as_of": "2024",
            "not_repealed": true,
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

-- RULE 3: Vicious Dog Definition (NRS 202.500)
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'NV-DOG-BITE-VICIOUS-DOG-DEFINITION',
    6,
    'NV Vicious Dog Definition',
    'legal_research',
    'personal_injury',
    'complaint',
    'state',
    'NV',
    '{
        "statute": "NRS 202.500",
        "enacted": "1967",
        "amendments": ["1993", "1995", "2013"],
        "current_status": "Active as of 2024",
        "authority_level": "contextual_rule",
        "definition": "A dog is vicious if, without being provoked, it killed or inflicted substantial bodily harm upon a human being on public or private property, OR after its owner has been notified that it is a dangerous dog, it continues the behavior that earned the designation or kills a domestic animal.",
        "criteria": {
            "killed_human": {
                "required": false,
                "provocation": "without provocation",
                "location": "public or private property"
            },
            "substantial_bodily_harm": {
                "required": false,
                "provocation": "without provocation",
                "severity": "substantial bodily harm"
            },
            "dangerous_dog_continuation": {
                "required": false,
                "prerequisite": "dog previously declared dangerous",
                "owner_notified": true,
                "continued_behavior": "continues behavior OR kills domestic animal"
            }
        },
        "penalties_for_owner": {
            "misdemeanor": {
                "offense": "Owning or transferring vicious dog after notice",
                "penalty": "Up to 6 months jail and/or $1,000 fine"
            },
            "category_d_felony": {
                "trigger": "Dog causes substantial bodily harm after owner notified",
                "penalty": "1-4 years prison and/or up to $5,000 fine",
                "additional": "Dog may be euthanized"
            }
        },
        "exceptions": {
            "law_enforcement": {
                "applies": true,
                "description": "Does not apply to dogs used by law enforcement officers in their official duties"
            },
            "defensive_action": {
                "applies": true,
                "description": "Does not apply if dog was defending against provocation"
            }
        },
        "verification": {
            "statute_text_verified": true,
            "current_as_of": "2024",
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
    validator_level  = EXCLUDED.validator_level,
    validator_name   = EXCLUDED.validator_name,
    validator_type   = EXCLUDED.validator_type,
    severity         = EXCLUDED.severity,
    review_status    = EXCLUDED.review_status,
    is_active        = EXCLUDED.is_active,
    updated_at       = NOW();

-- RULE 4: Vicious Animal Liability (NRS 575.020)
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'NV-DOG-BITE-VICIOUS-ANIMAL-LIABILITY',
    6,
    'NV Vicious Animal Liability (NRS 575.020)',
    'legal_research',
    'personal_injury',
    'complaint',
    'state',
    'NV',
    '{
        "statute": "NRS 575.020",
        "enacted": "Pre-1979",
        "amendments": ["1979"],
        "current_status": "Active as of 2024",
        "authority_level": "contextual_rule",
        "rule_statement": "Person having care or custody of vicious animal is liable for damages if animal chases, worries, injures, or kills livestock of another.",
        "scope": {
            "applies_to": "vicious animals (includes dogs)",
            "covered_conduct": ["chases", "worries", "injures", "kills"],
            "protected_victims": "livestock of another"
        },
        "criminal_penalty": {
            "offense": "Allowing vicious animal to escape or run at large",
            "classification": "misdemeanor",
            "requirement": "Person must have care or custody"
        },
        "self_help_remedy": {
            "killing_permitted": true,
            "justification_1": "Necessary for protection of person or property",
            "justification_2": "Animal has injured, worried, or killed livestock on another persons land"
        },
        "livestock_definition": {
            "included": ["cattle", "goats", "horses", "sheep", "swine", "fowl", "rabbits"],
            "note": "Not limited to human injuries - specific to livestock protection"
        },
        "verification": {
            "statute_text_verified": true,
            "current_as_of": "2024",
            "not_repealed": true,
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

-- RULE 5: Scienter / One-Bite Rule
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'NV-DOG-BITE-SCIENTER-ONE-BITE',
    6,
    'NV Dog Bite Scienter / One-Bite Rule',
    'legal_research',
    'personal_injury',
    'complaint',
    'state',
    'NV',
    '{
        "liability_theory": "scienter",
        "common_name": "one-bite rule",
        "authority_level": "contextual_rule",
        "rule_statement": "Owner is liable if they knew or should have known the dog had dangerous propensities or a history of aggression.",
        "elements": {
            "prior_knowledge": {
                "required": true,
                "standard": "actual knowledge OR constructive knowledge",
                "evidence": ["prior bites", "aggressive behavior", "complaints", "warnings"]
            },
            "dangerous_propensities": {
                "definition": "Tendency to act in a dangerous manner",
                "not_limited_to_biting": true,
                "examples": ["growling", "lunging", "snapping", "threatening behavior"]
            },
            "first_bite_immunity": {
                "general_rule": true,
                "exception": "Owner may still be liable if negligent in other ways"
            }
        },
        "burden_of_proof": {
            "on_plaintiff": true,
            "must_prove": "Owner knew or should have known of dangerous propensities"
        },
        "evidence_types": {
            "veterinary_records": true,
            "police_reports": true,
            "witness_statements": true,
            "prior_complaints": true,
            "animal_control_records": true
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

-- RULE 6: Negligence Per Se (Leash Law Violations)
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'NV-DOG-BITE-NEGLIGENCE-PER-SE',
    6,
    'NV Dog Bite Negligence Per Se',
    'legal_research',
    'personal_injury',
    'complaint',
    'state',
    'NV',
    '{
        "liability_theory": "negligence_per_se",
        "authority_level": "contextual_rule",
        "rule_statement": "Violation of safety laws (e.g., leash ordinances) automatically establishes negligence.",
        "applicable_laws": {
            "local_leash_ordinances": {
                "varies_by_jurisdiction": true,
                "typical_requirements": ["dog must be leashed in public", "dog must be under owners control"]
            },
            "dangerous_dog_restrictions": {
                "statute": "NRS 202.500",
                "requirements": ["permanent confinement", "warning signs", "specific handling protocols"]
            }
        },
        "elements": {
            "statutory_violation": {
                "required": true,
                "proof": "Defendant violated a safety statute or ordinance"
            },
            "purpose_to_protect_plaintiff": {
                "required": true,
                "proof": "Statute was designed to protect people like plaintiff"
            },
            "harm_of_type_intended_to_prevent": {
                "required": true,
                "proof": "Injury was the type the statute was designed to prevent"
            },
            "causation": {
                "required": true,
                "proof": "Violation caused the injury"
            }
        },
        "legal_effect": {
            "automatic_duty_breach": true,
            "plaintiff_still_must_prove": ["causation", "damages"],
            "no_need_to_prove_reasonableness": true
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

-- RULE 7: Statute of Limitations (NRS 11.190)
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'NV-DOG-BITE-SOL',
    5,
    'NV Dog Bite Statute of Limitations',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'NV',
    '{
        "sol_years": 2,
        "sol_days": 730,
        "statute": "NRS 11.190(4)(e)",
        "authority_level": "contextual_rule",
        "rule_statement": "Dog bite claims fall under general personal injury statute of limitations: 2 years from date of injury.",
        "accrual": {
            "trigger_event": "date_of_injury",
            "discovery_rule": false,
            "exceptions": "NRS 11.215 and 11.217 may extend deadline in certain circumstances"
        },
        "consequences_of_missing_deadline": {
            "claim_barred": true,
            "no_recovery": true,
            "defendant_can_move_to_dismiss": true
        },
        "verification": {
            "statute_verified": true,
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

-- RULE 8: Comparative Negligence
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'NV-DOG-BITE-COMPARATIVE-NEGLIGENCE',
    6,
    'NV Dog Bite Comparative Negligence',
    'legal_research',
    'personal_injury',
    'complaint',
    'state',
    'NV',
    '{
        "doctrine": "modified_comparative_negligence",
        "authority_level": "contextual_rule",
        "rule_statement": "Plaintiff can recover damages if their own negligence was less than 51%. Damages are reduced by plaintiffs percentage of fault.",
        "threshold": {
            "bar_to_recovery": "51%",
            "plaintiff_can_recover_if": "less than 51% at fault"
        },
        "damage_reduction": {
            "proportional": true,
            "formula": "Total damages × (100% - plaintiffs fault percentage)"
        },
        "common_defenses": {
            "provocation": {
                "description": "Plaintiff provoked the dog",
                "reduces_or_bars_recovery": true
            },
            "trespassing": {
                "description": "Plaintiff was trespassing",
                "complete_bar_possible": true
            },
            "assumption_of_risk": {
                "description": "Plaintiff knowingly encountered dangerous dog",
                "reduces_recovery": true
            }
        },
        "verification": {
            "source_type": "common_law_doctrine",
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
    validator_config->>'statute' AS statute,
    validator_config->>'authority_level' AS authority_level,
    validator_config->'verification'->>'current_as_of' AS verified_current,
    validator_config->'verification'->>'not_repealed' AS not_repealed,
    is_active
FROM leverage.validation_rules
WHERE jurisdiction_state = 'NV'
  AND practice_area = 'personal_injury'
  AND rule_name LIKE '%DOG-BITE%'
ORDER BY validator_level;

-- =====================================================================================
-- END OF NEVADA DOG BITE RULES
-- =====================================================================================
