-- =====================================================================================
-- UTAH (UT) DOG BITE LIABILITY RULES
-- =====================================================================================
-- State: Utah (UT)
-- Practice Area: Personal Injury - Dog Bite Liability
-- Research Date: 2026-01-30
-- Primary Statute: Utah Code 18-1-1 (Owner Liability)
-- Verification Status: COMPLETE - Full statute text verified from official UT legislature
-- Current Status: ACTIVE as of 2024-2026 (Enacted 1990, Last Amended 2025)
-- =====================================================================================

-- RULE 1: Strict Liability for All Dog Injuries (Utah Code 18-1-1)
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'UT-DOG-BITE-STRICT-LIABILITY',
    5,
    'UT Strict Liability for Dog Injuries (Utah Code 18-1-1)',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'UT',
    '{
        "liability_model": "strict_liability",
        "statute": "Utah Code 18-1-1",
        "enacted": "1990",
        "last_amended": "2025 General Session",
        "current_status": "Active as of 2024-2026",
        "authority_level": "contextual_rule",
        "strict_liability_scope": {
            "applies_to": "All dog injuries - including first bite",
            "no_prior_knowledge_required": true,
            "liable_parties": ["owner", "third-party keeper"],
            "damages_determined_by": "Utah Code 78B-5-818"
        },
        "multiple_dogs": {
            "joint_liability": "If multiple dogs owned by different individuals cause injury, all owners can be joined in lawsuit",
            "apportionment": "Damages apportioned among owners"
        },
        "verification": {
            "statute_text_verified": true,
            "full_text_source": "https://le.utah.gov/xcode/Title18/C18_1800010118000101.pdf",
            "multiple_sources": ["Utah Legislature Official PDF", "Utah Legislature Website", "DogBiteLaw.com", "Justia"],
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

-- RULE 2: Law Enforcement Dog Exception (Utah Code 18-1-1)
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'UT-LAW-ENFORCEMENT-DOG-EXCEPTION',
    5,
    'UT Law Enforcement Dog Exception (Utah Code 18-1-1)',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'UT',
    '{
        "liability_model": "law_enforcement_exception",
        "statute": "Utah Code 18-1-1",
        "current_status": "Active as of 2024-2026",
        "authority_level": "contextual_rule",
        "exception": {
            "applies_to": "Government entities and peace officers",
            "conditions": [
                "Dog is trained law enforcement animal",
                "Dog acting within policy during official duties"
            ],
            "effect": "Government entities and peace officers not liable for injuries by law enforcement dogs when acting within policy"
        },
        "verification": {
            "statute_text_verified": true,
            "full_text_source": "https://le.utah.gov/xcode/Title18/C18_1800010118000101.pdf",
            "multiple_sources": ["Utah Legislature Official", "DogBiteLaw.com"],
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

-- RULE 3: Trespass and Property Defense Exception (Utah Code 18-1-1)
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'UT-TRESPASS-DEFENSE-EXCEPTION',
    5,
    'UT Trespass and Property Defense Exception (Utah Code 18-1-1)',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'UT',
    '{
        "liability_model": "trespass_exception",
        "statute": "Utah Code 18-1-1",
        "current_status": "Active as of 2024-2026",
        "authority_level": "contextual_rule",
        "exceptions": {
            "injury_to_another_animal": "Owner not liable if dog injures another animal on owners property while dog is secured",
            "trespass": "Owner not liable if victim is trespasser on owners property and dog is secured"
        },
        "secured_requirement": {
            "definition": "Dog must be properly secured on owners property for exception to apply"
        },
        "verification": {
            "statute_text_verified": true,
            "full_text_source": "https://le.utah.gov/xcode/Title18/C18_1800010118000101.pdf",
            "multiple_sources": ["Utah Legislature Official", "DogBiteLaw.com"],
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
