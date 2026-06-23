-- =====================================================================================
-- OHIO (OH) DOG BITE LIABILITY RULES
-- =====================================================================================
-- State: Ohio (OH)
-- Practice Area: Personal Injury - Dog Bite Liability
-- Research Date: 2026-01-30
-- Primary Statute: Ohio Revised Code § 955.28 (Strict Liability)
-- Verification Status: COMPLETE - Statute verified from official OH codes
-- Current Status: ACTIVE as of 2024 (last amended 2008)
-- =====================================================================================

-- RULE 1: Strict Liability (ORC 955.28)
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'OH-DOG-BITE-STRICT-LIABILITY',
    5,
    'OH Dog Bite Strict Liability Rule',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'OH',
    '{
        "liability_model": "strict_liability",
        "statute": "Ohio Rev. Code § 955.28",
        "effective_date": "2008-09-30",
        "current_status": "Active as of 2024",
        "authority_level": "contextual_rule",
        "rule_statement": "Owner, keeper, or harborer of dog strictly liable for injury, death, or loss to person or property caused by dog.",
        "strict_liability_scope": {
            "no_prior_knowledge_required": true,
            "no_first_bite_rule": true,
            "applies_from_first_incident": true,
            "covers": ["personal_injury", "death", "property_damage"]
        },
        "liable_parties": {
            "owner": "Person who legally owns the dog",
            "keeper": "Person who has custody or possession of dog",
            "harborer": "Person who shelters or provides home for dog"
        },
        "exceptions": {
            "trespassing": {
                "applies": true,
                "description": "No liability if injured person was trespassing on owners property"
            },
            "committing_crime": {
                "applies": true,
                "description": "No liability if injured person was committing crime other than minor misdemeanor on owners property"
            },
            "teasing_tormenting_abusing": {
                "applies": true,
                "description": "No liability if injured person was teasing, tormenting, or abusing dog"
            }
        },
        "dog_killing_authorization": {
            "statute_provision": "Section permits killing dog if found chasing, injuring, or killing person or livestock",
            "no_liability_for_killing": "Person killing dog under these circumstances not liable to dog owner"
        },
        "verification": {
            "statute_text_verified": true,
            "official_source": "Ohio Codes Official Website",
            "multiple_sources": ["Ohio.gov", "KNR Legal", "Podor Law", "Rinehardt Law"],
            "current_as_of": "2024",
            "last_amended": "2008-09-30 (HB 71, 127th GA)",
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
    validator_config->'verification'->>'current_as_of' AS verified_current,
    is_active
FROM leverage.validation_rules
WHERE jurisdiction_state = 'OH'
  AND practice_area = 'personal_injury'
  AND rule_name LIKE '%DOG%'
ORDER BY validator_level;

-- =====================================================================================
-- END OF OHIO DOG BITE RULES
-- =====================================================================================
