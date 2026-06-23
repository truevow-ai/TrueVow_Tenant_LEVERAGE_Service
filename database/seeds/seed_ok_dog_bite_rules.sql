-- =====================================================================================
-- OKLAHOMA (OK) DOG BITE LIABILITY RULES
-- =====================================================================================
-- State: Oklahoma (OK)
-- Practice Area: Personal Injury - Dog Bite Liability
-- Research Date: 2026-01-30
-- Primary Statute: Oklahoma Stat. Title 4 § 42.1 (Strict Liability)
-- Verification Status: COMPLETE - Statute verified from official OK codes
-- Current Status: ACTIVE as of 2024
-- =====================================================================================

-- RULE 1: Strict Liability (Title 4 § 42.1)
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'OK-DOG-BITE-STRICT-LIABILITY',
    5,
    'OK Dog Bite Strict Liability Rule',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'OK',
    '{
        "liability_model": "strict_liability",
        "statute": "Okla. Stat. tit. 4, § 42.1",
        "current_status": "Active as of 2024",
        "authority_level": "contextual_rule",
        "rule_statement": "Dog owner liable for damages if dog bites or injures person without provocation in place where person has lawful right to be.",
        "strict_liability_scope": {
            "no_prior_knowledge_required": true,
            "no_first_bite_rule": true,
            "applies_from_first_incident": true,
            "covers": ["bite", "injury", "other harm"]
        },
        "elements": {
            "dog_ownership": {
                "required": true,
                "definition": "Person who owns the dog"
            },
            "bite_or_injury": {
                "required": true,
                "types": ["bite", "injury", "other physical harm"],
                "note": "Statute covers bites AND other injuries"
            },
            "no_provocation": {
                "required": true,
                "burden": "Defendant must prove provocation as defense"
            },
            "lawful_presence": {
                "required": true,
                "statute_reference": "Okla. Stat. tit. 4, § 42.2",
                "lawfully_on_property": [
                    "Performing duties imposed by laws of state or federal government",
                    "Performing duties imposed by postal regulations",
                    "On property upon invitation, express or implied",
                    "In public place"
                ],
                "public_place_definition": "Any place open to public, including streets, sidewalks, parks, businesses open to public"
            }
        },
        "defenses": {
            "provocation": {
                "applies": true,
                "burden_on_defendant": true,
                "description": "Owner not liable if victim provoked dog"
            },
            "trespassing": {
                "applies": true,
                "description": "Owner not liable if victim not lawfully present on property"
            }
        },
        "verification": {
            "statute_text_verified": true,
            "official_source": "Oklahoma Statutes via Justia",
            "multiple_sources": ["Justia", "222 Injury Lawyers", "Dakota Low", "Graves McLain"],
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

-- RULE 2: Dangerous Dog Provisions (Title 4 § 42.4)
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'OK-DANGEROUS-DOG-PROVISIONS',
    6,
    'OK Dangerous Dog Enhanced Liability',
    'legal_research',
    'personal_injury',
    'complaint',
    'state',
    'OK',
    '{
        "statute": "Okla. Stat. tit. 4, § 42.4",
        "current_status": "Active as of 2024",
        "authority_level": "contextual_rule",
        "rule_statement": "Enhanced criminal penalties and liability for owners of dangerous dogs that bite, severely injure, or cause death.",
        "dangerous_dog_definition": {
            "criteria": [
                "Dog has bitten person and caused injury",
                "Dog has severely injured or killed person",
                "Dog has created imminent threat of severe injury or death"
            ]
        },
        "criminal_penalties": {
            "unlawful_to": [
                "Allow dangerous dog to run at large",
                "Allow dangerous dog to attack person without provocation"
            ],
            "misdemeanor": "Violation is misdemeanor",
            "felony": "If dangerous dog causes death of person, owner guilty of felony"
        },
        "civil_liability": {
            "strict_liability_under_42_1": "Owner liable under § 42.1 for damages",
            "enhanced_liability": "Additional criminal liability for dangerous dog violations"
        },
        "affirmative_defense": {
            "statute_provision": "Owner may have defense if dog used against person unlawfully on property",
            "note": "Similar to defenses under § 42.1"
        },
        "verification": {
            "statute_verified": true,
            "official_source": "Oklahoma Statutes via Justia",
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

-- =====================================================================================
-- VERIFICATION QUERY
-- =====================================================================================

SELECT 
    rule_name,
    validator_config->>'liability_model' AS liability_model,
    validator_config->>'statute' AS statute,
    validator_config->>'authority_level' AS authority_level,
    validator_config->'verification'->>'current_as_of' AS verified_current,
    is_active
FROM leverage.validation_rules
WHERE jurisdiction_state = 'OK'
  AND practice_area = 'personal_injury'
  AND rule_name LIKE '%DOG%'
ORDER BY validator_level;

-- =====================================================================================
-- END OF OKLAHOMA DOG BITE RULES
-- =====================================================================================
