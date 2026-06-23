-- =====================================================================================
-- TENNESSEE (TN) DOG BITE LIABILITY RULES
-- =====================================================================================
-- State: Tennessee (TN)
-- Practice Area: Personal Injury - Dog Bite Liability
-- Research Date: 2026-01-30
-- Primary Statute: TCA 44-8-413 (Dianna Acklen Act)
-- Verification Status: COMPLETE - Full statute text verified
-- Current Status: ACTIVE as of 2024-2026 (Enacted 2007)
-- =====================================================================================

-- RULE 1: Strict Liability Running at Large (TCA 44-8-413)
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'TN-DOG-BITE-STRICT-LIABILITY',
    5,
    'TN Strict Liability - Dianna Acklen Act (TCA 44-8-413)',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'TN',
    '{
        "liability_model": "strict_liability_public_property",
        "statute": "TCA 44-8-413",
        "enacted": "2007",
        "law_name": "Dianna Acklen Act",
        "current_status": "Active as of 2024-2026",
        "authority_level": "contextual_rule",
        "abolished_one_bite_rule": {
            "in_public_settings": true,
            "when_enacted": "2007",
            "trigger": "Fatal dog attack of Dianna Acklen"
        },
        "strict_liability_applies": {
            "when": "Dog owner failed to keep dog under reasonable control OR failed to prevent dog from running at large",
            "location": ["public place", "private property where victim lawfully present"],
            "no_prior_knowledge_required": true
        },
        "running_at_large_definition": {
            "includes": ["uncontrolled on anothers property without consent", "uncontrolled on public property"]
        },
        "proof_required": {
            "plaintiff_must_prove": ["injury caused by dog", "owner violated statute by failing reasonable control or allowing running at large"],
            "plaintiff_need_not_prove": ["owner knew dog was dangerous", "owner was negligent"]
        },
        "verification": {
            "statute_text_verified": true,
            "multiple_sources": ["Justia Legal Codes", "King Law Offices", "Darrell Castle", "Ponce Law", "Labrum Law", "Nolo", "DogBiteLaw.com"],
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

-- RULE 2: Residential Property Exception (TCA 44-8-413)
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'TN-DOG-BITE-RESIDENTIAL-EXCEPTION',
    5,
    'TN Residential Property Exception - Dangerous Propensities Required',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'TN',
    '{
        "liability_model": "one_bite_on_owners_property",
        "statute": "TCA 44-8-413",
        "current_status": "Active as of 2024-2026",
        "authority_level": "contextual_rule",
        "residential_exception": {
            "applies_when": "Injury occurs on owners residential or non-commercial property",
            "strict_liability_does_not_apply": true,
            "proof_required": "Claimant must prove owner knew or should have known of dogs dangerous tendencies"
        },
        "dangerous_propensities_proof": {
            "plaintiff_must_prove": ["dog had dangerous propensities", "owner knew or should have known of dangerous tendencies"],
            "evidence_types": ["prior attacks", "aggressive behavior", "warnings from others", "breed characteristics alone insufficient"]
        },
        "common_law_applies": {
            "on_owners_property": "Common law one-bite rule and negligence theories apply"
        },
        "verification": {
            "statute_text_verified": true,
            "multiple_sources": ["Justia Legal Codes", "King Law Offices", "DogBiteLaw.com", "Ponce Law"],
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
    validator_name = EXCLUDED.validator_name,
    severity = EXCLUDED.severity,
    review_status = EXCLUDED.review_status,
    updated_at = NOW();

-- RULE 3: Exemptions (TCA 44-8-413)
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'TN-DOG-BITE-EXEMPTIONS',
    5,
    'TN Dog Bite Liability Exemptions (TCA 44-8-413)',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'TN',
    '{
        "liability_model": "exemptions_and_defenses",
        "statute": "TCA 44-8-413",
        "current_status": "Active as of 2024-2026",
        "authority_level": "contextual_rule",
        "exemptions": {
            "police_military_dogs": "Owner not liable if dog is police or military dog acting in official capacity",
            "trespassing": "Owner not liable if injured person was trespassing",
            "protecting_owner": "Owner not liable if injury occurred while dog was protecting owner",
            "securely_confined": "Owner not liable if dog was securely confined",
            "provocation": "Owner not liable if injured person provoked dog"
        },
        "verification": {
            "statute_text_verified": true,
            "multiple_sources": ["Justia Legal Codes", "Nolo", "David Gordon Law"],
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
    validator_name = EXCLUDED.validator_name,
    severity = EXCLUDED.severity,
    review_status = EXCLUDED.review_status,
    updated_at = NOW();

-- RULE 4: Negligence Alternative Theory
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'TN-DOG-BITE-NEGLIGENCE',
    5,
    'TN Common Law Negligence for Dog Bites',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'TN',
    '{
        "liability_model": "negligence_based",
        "authority_level": "contextual_rule",
        "rule_statement": "Per Hudson v. Gravette, even when Acklen Act does not apply, negligence claims against dog owners are still possible.",
        "case_law": "Hudson v. Gravette",
        "burden_of_proof": {
            "plaintiff_must_prove": [
                "Owner owed duty of care",
                "Owner breached duty",
                "Breach caused injury",
                "Plaintiff suffered damages"
            ]
        },
        "when_applicable": {
            "scenarios": ["On owners property", "When Acklen Act exemptions apply", "Alternative theory alongside strict liability"]
        },
        "verification": {
            "statute_text_verified": true,
            "multiple_sources": ["Ponce Law Hudson v. Gravette analysis", "Nolo", "Labrum Law"],
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
