-- =====================================================================================
-- NEW JERSEY (NJ) DOG BITE LIABILITY RULES
-- =====================================================================================
-- State: New Jersey (NJ)
-- Practice Area: Personal Injury - Dog Bite Liability
-- Research Date: 2026-01-30
-- Primary Source: N.J.S.A. 4:19-16 (P.L.1959, c.33)
-- Verification Status: COMPLETE - Statute text verified from multiple legal databases
-- Current Status: ACTIVE as of 2024-2025, NOT repealed
-- Note: S3172 (2024) proposed veterinary facility exception but NOT YET ENACTED
-- =====================================================================================

-- RULE 1: Strict Liability Statute (N.J.S.A. 4:19-16)
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'NJ-DOG-BITE-STRICT-LIABILITY',
    5,
    'NJ Dog Bite Strict Liability Rule',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'NJ',
    '{
        "liability_model": "strict_liability",
        "statute": "N.J.S.A. 4:19-16",
        "enacted": "1959",
        "public_law": "P.L.1959, c.33",
        "current_status": "Active as of 2024-2025",
        "authority_level": "contextual_rule",
        "statute_text": "The owner of any dog which shall bite a person while such person is on or in a public place, or lawfully on or in a private place, including the property of the owner of the dog, shall be liable for such damages as may be suffered by the person bitten, regardless of the former viciousness of such dog or the owners knowledge of such viciousness.",
        "rule_statement": "Dog owners strictly liable for bites in public places or when victim lawfully on private property, regardless of dogs prior viciousness or owners knowledge.",
        "elements": {
            "ownership": {
                "required": true,
                "definition": "Person who owns the dog",
                "burden_of_proof": "Plaintiff must prove ownership"
            },
            "bite_occurred": {
                "required": true,
                "must_be_actual_bite": true,
                "note": "Statute requires actual bite, unlike some states covering all injuries"
            },
            "location_requirement": {
                "public_place": true,
                "private_place_lawfully": true,
                "includes_owners_property": "Yes, if victim lawfully present"
            },
            "lawfully_present_definition": {
                "includes": [
                    "performing duty imposed by laws of state or federal government",
                    "performing duty imposed by postal regulations of United States",
                    "on property upon invitation, express or implied, of owner"
                ],
                "invitation_types": ["express invitation", "implied invitation"]
            },
            "no_prior_knowledge_required": {
                "strict_liability": true,
                "first_bite_rule": false,
                "former_viciousness_irrelevant": true,
                "owners_knowledge_irrelevant": true
            }
        },
        "verification": {
            "statute_text_verified": true,
            "multiple_sources": ["Justia Legal Codes", "Cooper Levenson", "King Law Firm", "Animal Law Info"],
            "current_as_of": "2024-2025",
            "not_repealed": true,
            "proposed_amendment": "S3172 (2024) - veterinary facility exception NOT ENACTED as of Jan 2026",
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

-- RULE 2: Trespass/Unlawful Presence Defense
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'NJ-DOG-BITE-TRESPASS-DEFENSE',
    6,
    'NJ Dog Bite Trespass Defense',
    'legal_research',
    'personal_injury',
    'complaint',
    'state',
    'NJ',
    '{
        "defense_type": "trespass_unlawful_presence",
        "statute": "N.J.S.A. 4:19-16",
        "authority_level": "contextual_rule",
        "rule_statement": "Strict liability does NOT apply if victim was not lawfully on public or private property.",
        "trespass_defense": {
            "complete_bar": true,
            "burden_of_proof": "Defendant must prove plaintiff was trespassing or unlawfully present",
            "public_place": "No trespass defense in public places (all have lawful right to be present)",
            "private_place": "Defense applies if victim not lawfully on private property"
        },
        "not_lawfully_present": {
            "trespasser": true,
            "no_invitation": "Person not invited (express or implied) by owner",
            "exceeded_scope_of_invitation": "Person exceeded scope of invitation or permission"
        },
        "lawfully_present_examples": {
            "postal_worker": "Performing duty under postal regulations",
            "utility_worker": "Performing duty under state/federal law",
            "invited_guest": "Express or implied invitation from owner",
            "social_visitor": "Implied invitation to approach house"
        },
        "verification": {
            "statute_text_verified": true,
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

-- RULE 3: Modified Comparative Negligence
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'NJ-DOG-BITE-COMPARATIVE-NEGLIGENCE',
    6,
    'NJ Dog Bite Comparative Negligence',
    'legal_research',
    'personal_injury',
    'complaint',
    'state',
    'NJ',
    '{
        "comparative_fault_rule": "modified_comparative_negligence",
        "authority_level": "contextual_rule",
        "rule_statement": "Victims recovery reduced by percentage of fault; barred if victim more than 50% at fault.",
        "modified_comparative_negligence": {
            "threshold": "50%",
            "rule": "Plaintiff barred from recovery if more than 50% at fault",
            "reduction": "Recovery reduced by plaintiffs percentage of fault if 50% or less"
        },
        "plaintiff_fault_examples": {
            "provocation": "Victim provoked dog (teasing, hitting, threatening)",
            "assumption_of_risk": "Victim knowingly approached dangerous dog",
            "contributory_negligence": "Victim failed to exercise reasonable care for own safety",
            "professional_handler": "Professional dog handler/veterinarian aware of risks (see Goldhagen v. Pasmowitz)"
        },
        "case_law": {
            "Goldhagen_v_Pasmowitz": {
                "holding": "Comparative Negligence Act applies to dog bite statute",
                "note": "Professional dog handlers experience relevant to fault allocation"
            }
        },
        "practical_application": {
            "jury_question": "Percentage of fault is jury question",
            "burden": "Defendant must prove plaintiffs fault",
            "damages_reduction": "Damages reduced proportionally by plaintiffs fault percentage"
        },
        "verification": {
            "case_law_verified": true,
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

-- RULE 4: Dangerous Dog Act (N.J.S.A. 4:19-22 et seq.)
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'NJ-DANGEROUS-DOG-ACT',
    6,
    'NJ Dangerous Dog Act',
    'legal_research',
    'personal_injury',
    'complaint',
    'state',
    'NJ',
    '{
        "statute": "N.J.S.A. 4:19-22 et seq.",
        "authority_level": "contextual_rule",
        "rule_statement": "Separate liability framework for dogs with prior aggressive history declared potentially dangerous or vicious.",
        "potentially_dangerous_dog": {
            "definition": "Dog that has engaged in behavior requiring formal declaration",
            "declaration_process": "Court or municipal authority declaration",
            "owner_requirements": [
                "Maintain liability insurance",
                "Confine dog securely",
                "Display warning signs",
                "Muzzle and leash in public"
            ]
        },
        "vicious_dog": {
            "definition": "Dog that has killed or seriously injured person without provocation, or has been previously declared potentially dangerous and repeats aggressive behavior",
            "enhanced_requirements": "Stricter confinement and control requirements"
        },
        "relevance_to_litigation": {
            "punitive_damages": "Prior dangerous dog declaration may support punitive damages",
            "evidence_of_knowledge": "Declaration proves owner knew of dangerous propensities",
            "enhanced_liability": "Violation of Dangerous Dog Act requirements strengthens plaintiffs case"
        },
        "verification": {
            "statute_verified": true,
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

-- RULE 5: Common Law Negligence (Alternative Theory)
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'NJ-DOG-BITE-COMMON-LAW-NEGLIGENCE',
    6,
    'NJ Dog Bite Common Law Negligence',
    'legal_research',
    'personal_injury',
    'complaint',
    'state',
    'NJ',
    '{
        "liability_theory": "common_law_negligence",
        "authority_level": "contextual_rule",
        "rule_statement": "Alternative liability theory available in addition to or instead of strict liability.",
        "elements": {
            "duty": {
                "required": true,
                "standard": "Owner has duty to exercise reasonable care to control dog and prevent harm"
            },
            "breach": {
                "required": true,
                "examples": [
                    "Failing to restrain known aggressive dog",
                    "Violating leash laws",
                    "Allowing dog to roam free",
                    "Ignoring prior incidents"
                ]
            },
            "causation": {
                "required": true,
                "but_for": true,
                "proximate_cause": true
            },
            "damages": {
                "required": true,
                "actual_injury": true
            }
        },
        "when_to_use": {
            "no_bite": "If injury did not involve bite (strict liability requires bite)",
            "non_bite_injuries": "Dog knocked victim down, scratched, or caused fear",
            "additional_damages": "Support for punitive damages in egregious cases",
            "backup_theory": "Alternative if strict liability defenses successful"
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
    validator_config->>'statute' AS statute,
    validator_config->>'authority_level' AS authority_level,
    validator_config->'verification'->>'current_as_of' AS verified_current,
    validator_config->'verification'->>'not_repealed' AS not_repealed,
    is_active
FROM leverage.validation_rules
WHERE jurisdiction_state = 'NJ'
  AND practice_area = 'personal_injury'
  AND rule_name LIKE '%DOG%'
ORDER BY validator_level;

-- =====================================================================================
-- END OF NEW JERSEY DOG BITE RULES
-- =====================================================================================
