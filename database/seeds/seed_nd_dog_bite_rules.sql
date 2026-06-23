-- =====================================================================================
-- NORTH DAKOTA (ND) DOG BITE LIABILITY RULES
-- =====================================================================================
-- State: North Dakota (ND)
-- Practice Area: Personal Injury - Dog Bite Liability  
-- Research Date: 2026-01-30
-- Primary Framework: NEGLIGENCE (NO STRICT LIABILITY)
-- Key Case Law: Sendelbach v. Grad, 246 N.W.2d 496 (N.D. 1976)
-- Verification Status: COMPLETE - Case law and statutes verified
-- Current Status: ACTIVE as of 2024-2026
-- =====================================================================================

-- RULE 1: Negligence-Based Liability (Sendelbach Standard)
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'ND-DOG-BITE-NEGLIGENCE',
    5,
    'ND Dog Bite Negligence Liability Rule',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'ND',
    '{
        "liability_model": "negligence_based",
        "no_strict_liability": true,
        "case_law": "Sendelbach v. Grad, 246 N.W.2d 496 (N.D. 1976)",
        "authority_level": "contextual_rule",
        "rule_statement": "Dog owner liable only if owner knew or should have known dog was dangerous or vicious AND owner failed to exercise reasonable care to prevent injuries.",
        "sendelbach_standard": {
            "rejected_strict_liability": "North Dakota Supreme Court explicitly rejected strict liability standard",
            "requires_both": "Plaintiff must prove BOTH knowledge of vicious propensity AND negligence"
        },
        "elements": {
            "knowledge_of_vicious_propensity": {
                "required": true,
                "standard": "Owner knew or reasonably should have known dog was dangerous or vicious",
                "types": ["actual_knowledge", "constructive_knowledge"],
                "evidence": [
                    "Prior biting incidents",
                    "Prior aggressive behavior",
                    "Growling, lunging, snapping",
                    "Menacing or threatening behavior",
                    "Warnings from others about dogs behavior"
                ]
            },
            "negligence": {
                "required": true,
                "duty": "Owner must exercise reasonable care to guard against and prevent injuries or damages",
                "breach": "Owner failed to exercise reasonable care",
                "examples": [
                    "Failing to restrain dog with known dangerous propensities",
                    "Inadequate containment or supervision",
                    "Ignoring prior warnings or incidents",
                    "Violating local ordinances"
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
        "vicious_propensity_definition": {
            "court_declined_specific_definition": "Sendelbach court declined to adopt specific definition",
            "fact_specific": "Determined on case-by-case basis",
            "includes": "Tendency to act in manner endangering persons or property"
        },
        "burden_of_proof": {
            "plaintiff_must_prove": [
                "Dog had vicious or dangerous propensity",
                "Owner knew or should have known of propensity",
                "Owner failed to exercise reasonable care",
                "Owners negligence caused plaintiffs injuries",
                "Plaintiff suffered actual damages"
            ]
        },
        "verification": {
            "case_law_verified": true,
            "case_citation": "Sendelbach v. Grad, 246 N.W.2d 496 (N.D. 1976)",
            "multiple_sources": ["Justia", "Casetext", "vLex", "MWL Law", "DogBiteLaw.com"],
            "current_as_of": "2024-2026",
            "source_type": "case_law",
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

-- RULE 2: Public Nuisance Dogs (NDCC 42-03)
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'ND-DOG-PUBLIC-NUISANCE',
    6,
    'ND Dog Public Nuisance',
    'legal_research',
    'personal_injury',
    'complaint',
    'state',
    'ND',
    '{
        "statute": "NDCC 42-03-01",
        "current_status": "Active as of 2024-2025",
        "authority_level": "contextual_rule",
        "rule_statement": "Dog that habitually molests persons traveling peaceably on public roads or streets deemed public nuisance and may be ordered destroyed.",
        "public_nuisance_definition": {
            "statute": "NDCC 42-03-01",
            "requirement": "Dog habitually molests person traveling peaceably on public road or street",
            "habitually": "Repeated pattern of behavior, not isolated incident",
            "location_requirement": "Must occur on public road or street"
        },
        "process": {
            "complaint": "Any person may file complaint with district court",
            "notice_to_owner": "Owner must be notified if known; if unknown, notice by publication",
            "hearing": "Judge hears evidence and determines if dog is public nuisance",
            "order": "If found to be nuisance, judge may order dog killed"
        },
        "costs": {
            "default": "Complainant typically pays costs",
            "if_nuisance_found": "Costs may be charged to dog owner if nuisance proven"
        },
        "relevance_to_civil_litigation": {
            "evidence_of_dangerous_propensity": "Public nuisance determination strong evidence of vicious propensity",
            "knowledge_established": "Proves owner knew or should have known of dogs dangerous behavior",
            "supports_negligence_claim": "Strengthens plaintiffs negligence case"
        },
        "verification": {
            "statute_verified": true,
            "official_source": "ND Legislature",
            "current_as_of": "2024-2025",
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
    validator_config->>'case_law' AS case_law,
    validator_config->>'statute' AS statute,
    validator_config->>'authority_level' AS authority_level,
    validator_config->'verification'->>'current_as_of' AS verified_current,
    is_active
FROM leverage.validation_rules
WHERE jurisdiction_state = 'ND'
  AND practice_area = 'personal_injury'
  AND rule_name LIKE '%DOG%'
ORDER BY validator_level;

-- =====================================================================================
-- END OF NORTH DAKOTA DOG BITE RULES
-- =====================================================================================
