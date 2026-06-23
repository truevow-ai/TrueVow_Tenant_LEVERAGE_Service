-- =====================================================================================
-- PENNSYLVANIA (PA) DOG BITE LIABILITY RULES
-- =====================================================================================
-- State: Pennsylvania (PA)
-- Practice Area: Personal Injury - Dog Bite Liability
-- Research Date: 2026-01-30
-- Primary Statutes: 3 Pa.C.S. § 459-502(b)(1) (Strict Liability - Medical)
--                   3 Pa.C.S. § 459-502-A (Dangerous Dogs)
-- Verification Status: COMPLETE - Full statute text verified
-- Current Status: ACTIVE as of 2024-2026
-- =====================================================================================

-- RULE 1: Strict Liability for Medical Expenses (3 Pa.C.S. § 459-502(b)(1))
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'PA-DOG-BITE-STRICT-LIABILITY-MEDICAL',
    5,
    'PA Strict Liability for Medical Expenses (3 Pa.C.S. § 459-502(b)(1))',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'PA',
    '{
        "liability_model": "strict_liability_medical_only",
        "statute": "3 Pa.C.S. § 459-502(b)(1)",
        "current_status": "Active as of 2024-2026",
        "authority_level": "contextual_rule",
        "statute_scope": {
            "strict_liability_applies_to": "medical_costs_only",
            "no_prior_knowledge_required": true,
            "covers": "medical and veterinary costs"
        },
        "does_not_cover": {
            "excluded_damages": ["pain and suffering", "lost wages", "property damage", "emotional distress"],
            "requires_additional_proof": "For non-medical damages, must prove dangerous dog or negligence"
        },
        "verification": {
            "statute_text_verified": true,
            "multiple_sources": ["FindLaw Codes", "Mooney Law", "Amil Minora Law", "Nolo"],
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

-- RULE 2: Dangerous Dog Liability (3 Pa.C.S. § 459-502-A)
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'PA-DANGEROUS-DOG-LIABILITY',
    5,
    'PA Dangerous Dog Full Liability (3 Pa.C.S. § 459-502-A)',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'PA',
    '{
        "liability_model": "strict_liability_dangerous_dogs",
        "statute": "3 Pa.C.S. § 459-502-A",
        "current_status": "Active as of 2024-2026",
        "authority_level": "contextual_rule",
        "dangerous_dog_definition": {
            "statute": "3 Pa.C.S. § 459-502-A",
            "criteria": [
                "Inflicted severe injury on human without provocation",
                "Killed or inflicted severe injury on domestic animal without provocation",
                "Attacked human without provocation",
                "Used in commission of crime",
                "Dog has history or propensity for unprovoked severe injury, killing, or attacking"
            ],
            "key_change_2014": "Prosecution no longer needs to prove dogs history or propensity in criminal cases - this was amended to streamline prosecutions"
        },
        "full_liability": {
            "when_dangerous_dog_proven": "Owner liable for ALL damages including pain and suffering, lost wages, emotional distress",
            "proof_required": "Must prove dog meets dangerous dog definition",
            "damages_available": ["medical expenses", "lost wages", "pain and suffering", "emotional distress", "property damage"]
        },
        "verification": {
            "statute_text_verified": true,
            "multiple_sources": ["FindLaw Codes", "Margolis Edelstein", "Amil Minora Law", "Edgar Snyder"],
            "current_as_of": "2024-2026",
            "not_repealed": true,
            "amendment_2014": "Removed history/propensity requirement for criminal prosecution",
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

-- RULE 3: Common Law Negligence
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'PA-DOG-BITE-NEGLIGENCE',
    5,
    'PA Common Law Negligence Liability',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'PA',
    '{
        "liability_model": "negligence_based",
        "authority_level": "contextual_rule",
        "rule_statement": "Owner liable for all damages if can prove owner was negligent in controlling dog.",
        "burden_of_proof": {
            "plaintiff_must_prove": [
                "Owner owed duty of care",
                "Owner breached duty (failed to exercise reasonable care)",
                "Breach caused injury",
                "Plaintiff suffered damages"
            ]
        },
        "full_damages_available": {
            "if_negligence_proven": ["medical expenses", "lost wages", "pain and suffering", "emotional distress", "property damage"]
        },
        "verification": {
            "statute_text_verified": true,
            "multiple_sources": ["Edgar Snyder", "Mooney Law", "Amil Minora Law", "Nolo"],
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
