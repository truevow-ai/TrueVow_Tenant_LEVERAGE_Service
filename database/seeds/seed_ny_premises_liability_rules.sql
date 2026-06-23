-- =====================================================================================
-- PREMISES LIABILITY RULES SEED FILE
-- =====================================================================================
-- State: New York (NY)
-- Sub-Specialization: Premises Liability (Personal Injury)
-- Visitor Classification System: Unified Reasonable Care Standard
-- Primary Authority: Basso v. Miller, 40 N.Y.2d 233 (1976)
--
-- VERIFICATION STATUS: NEEDS_REVIEW (AI-Generated, Pending Attorney Review)
-- Research Date: March 2, 2026
-- Protocol v3: Deterministic verification against authoritative premises liability table
-- =====================================================================================

-- =====================================================================================
-- PART 1: LEGAL SOURCES
-- =====================================================================================

INSERT INTO leverage.legal_sources (
    jurisdiction_type,
    jurisdiction_state,
    jurisdiction_county,
    jurisdiction_court,
    name,
    publisher,
    abbreviation,
    base_url,
    source_type,
    trust_level,
    notes
) VALUES (
    'state',
    'NY',
    NULL,
    NULL,
    'New York Premises Liability - Unified Reasonable Care Standard',
    'New York Courts',
    'Basso v. Miller, 40 N.Y.2d 233 (1976)',
    '',
    'case_law',
    'high',
    'New York follows the Unified Reasonable Care Standard for premises liability cases. Authority: Basso v. Miller, 40 N.Y.2d 233 (1976). NEEDS REVIEW - pending attorney verification.'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type)
DO UPDATE SET
    notes = EXCLUDED.notes,
    abbreviation = EXCLUDED.abbreviation;

-- =====================================================================================
-- PART 2: VALIDATION RULES
-- =====================================================================================

INSERT INTO leverage.validation_rules (
    rule_name,
    validator_level,
    validator_name,
    validator_type,
    practice_area,
    specialization,
    document_type,
    jurisdiction_scope,
    jurisdiction_state,
    jurisdiction_county,
    jurisdiction_court,
    validator_config,
    severity,
    citation_id,
    review_status,
    is_active,
    is_template,
    tenant_id,
    created_at,
    updated_at
) VALUES (
    'NY-PREM-LIAB-UNIFIED-CARE',
    5,
    'NY Premises Liability Unified Reasonable Care Standard',
    'content_check',
    'personal_injury',
    'premises_liability',
    'complaint',
    'state',
    'NY',
    NULL,
    NULL,
    '{
        "visitor_classification_system": "unified_reasonable_care",
        "statute": "Basso v. Miller, 40 N.Y.2d 233 (1976)",
        "system_description": "Unified Reasonable Care Standard",
        "key_requirements": [
            "Owner owes a single duty of reasonable care to ALL entrants regardless of invitee/licensee/trespasser classification",
                "Traditional classification system is abolished or substantially modified",
                "Foreseeability of harm is the primary consideration in determining duty",
                "Court balances: (1) foreseeability of harm, (2) owner''s burden, (3) owner''s policy interests, (4) closeness of connection between conduct and injury",
                "Trespassers may still receive different treatment in some jurisdictions under this standard"
        ],
        "defenses": [
            "Comparative negligence by plaintiff",
                "Assumption of risk",
                "Open and obvious danger doctrine (may reduce foreseeability)",
                "Lack of notice (owner did not know and could not reasonably have known of hazard)",
                "Reasonable precautions were taken"
        ],
        "burden_of_proof": "Plaintiff must prove: (1) defendant owed a duty of care, (2) defendant breached that duty, (3) breach proximately caused plaintiff''s injury, (4) plaintiff suffered damages",
        "notice_requirement": "For conditions not created by defendant, plaintiff must prove actual or constructive notice of the hazardous condition"
    }'::jsonb,
    'error',
    NULL,
    'needs_review',
    true,
    true,
    NULL,
    NOW(),
    NOW()
) ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    specialization = EXCLUDED.specialization,
    review_status = CASE
        WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified'
        ELSE EXCLUDED.review_status
    END,
    updated_at = NOW();

-- =====================================================================================
-- END OF NEW YORK PREMISES LIABILITY SEED FILE
-- =====================================================================================
