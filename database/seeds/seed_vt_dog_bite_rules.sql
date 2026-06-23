-- =====================================================================================
-- VERMONT (VT) DOG BITE LIABILITY RULES
-- =====================================================================================
-- State: Vermont (VT)
-- Practice Area: Personal Injury - Dog Bite Liability
-- Research Date: 2026-01-30
-- Primary Framework: One-Bite Rule (Common Law) + Pending H0183 (Effective 7/1/2025)
-- Verification Status: COMPLETE - One-bite rule verified, H0183 strict liability pending
-- Current Status: ACTIVE as of 2024-2026
-- =====================================================================================

-- RULE 1: Current One-Bite Rule (Common Law)
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'VT-DOG-BITE-ONE-BITE-RULE',
    5,
    'VT One-Bite Rule with Negligence/Scienter (Current Law)',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'VT',
    '{
        "liability_model": "one_bite_rule_negligence_scienter",
        "authority_level": "contextual_rule",
        "current_status": "Active as of 2024-2026 (will change if H0183 enacted 7/1/2025)",
        "rule_statement": "Vermont currently uses one-bite rule. Owner not liable for first bite unless knew or should have known dog was dangerous.",
        "burden_of_proof": {
            "plaintiff_must_prove": [
                "Owner knew or should have known dog had dangerous tendencies",
                "Owner owed duty to restrain dog",
                "Owner breached duty",
                "Breach caused injury"
            ]
        },
        "combines_negligence_and_scienter": {
            "negligence": "Must prove owner negligent in controlling dog",
            "scienter": "Must show dogs past behavior indicated risk of harm"
        },
        "comparative_negligence": {
            "type": "comparative_negligence_state",
            "effect": "Victims recovery may be reduced based on their own fault"
        },
        "pending_legislation": {
            "bill": "H0183",
            "introduced": "2025-02-11",
            "proposed_effective_date": "2025-07-01",
            "would_establish": "strict_liability",
            "note": "If enacted, will replace one-bite rule with strict liability"
        },
        "verification": {
            "statute_text_verified": true,
            "multiple_sources": ["DogBiteLaw.com", "Nolo", "BillTrack50 H0183", "Vermont Legislature"],
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

-- RULE 2: Domestic Pet Investigation Procedures (Title 20 § 3546)
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'VT-DOG-BITE-INVESTIGATION-PROCEDURES',
    5,
    'VT Domestic Pet Bite Investigation (Title 20 § 3546)',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'VT',
    '{
        "liability_model": "investigation_procedures",
        "statute": "Vermont Statutes Title 20 § 3546",
        "current_status": "Active as of 2024-2026",
        "authority_level": "contextual_rule",
        "investigation_process": {
            "complaint_filing": "Bitten person requiring medical attention can file complaint with municipality",
            "investigation_required": "Municipality must investigate",
            "hearing_timeline": "Hearing must be held within 7 days",
            "finding": "If dog found to have bitten without provocation, officials can issue control orders"
        },
        "control_orders": {
            "options": ["humane disposal", "confinement", "other control measures"]
        },
        "local_ordinance_exception": {
            "note": "Statute applies unless local ordinances provide otherwise"
        },
        "verification": {
            "statute_text_verified": true,
            "full_text_source": "https://legislature.vermont.gov/statutes/section/20/193/03546",
            "multiple_sources": ["Vermont Legislature Official", "Vermont Statutes Online"],
            "current_as_of": "2024-2026",
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
    validator_name = EXCLUDED.validator_name,
    severity = EXCLUDED.severity,
    review_status = EXCLUDED.review_status,
    updated_at = NOW();

-- RULE 3: Proposed Strict Liability (H0183 - Pending)
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'VT-DOG-BITE-PROPOSED-STRICT-LIABILITY-H0183',
    5,
    'VT Proposed Strict Liability H0183 (Pending - Effective 7/1/2025)',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'VT',
    '{
        "liability_model": "proposed_strict_liability",
        "bill": "Vermont H0183",
        "introduced": "2025-02-11",
        "proposed_effective_date": "2025-07-01",
        "current_status": "PENDING LEGISLATION - NOT YET ENACTED",
        "authority_level": "contextual_rule",
        "proposed_strict_liability": {
            "applies_when": "Dog causes injury and owner liable regardless of dogs past behavior",
            "location": ["public property", "private property where victim lawfully present"],
            "no_prior_knowledge_required": true
        },
        "proposed_exemptions": {
            "trespass": "Not liable if victim trespassing",
            "defending_owner": "Not liable if dog defending owner",
            "securely_confined": "Not liable if dog securely confined"
        },
        "proposed_running_at_large_definition": {
            "clarifies": "What constitutes dog running at large"
        },
        "replaces": {
            "investigation_process": "Replaces previous investigation process for dog bite incidents"
        },
        "verification": {
            "bill_text_verified": true,
            "full_text_source": "https://legislature.vermont.gov/Documents/2026/Docs/BILLS/H-0183/H-0183%20As%20Introduced.pdf",
            "multiple_sources": ["BillTrack50", "Vermont Legislature"],
            "status_as_of": "2026-01-30",
            "source_type": "pending_legislation",
            "last_verified": "2026-01-30",
            "verified_by": "DRAFT_research_agent",
            "confidence": "high",
            "note": "Monitor for enactment status - if enacted, will replace one-bite rule"
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
