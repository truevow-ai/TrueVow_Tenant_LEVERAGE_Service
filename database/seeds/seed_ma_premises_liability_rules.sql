-- =====================================================================================
-- PREMISES LIABILITY RULES SEED FILE
-- =====================================================================================
-- State: Massachusetts (MA)
-- Sub-Specialization: Premises Liability (Personal Injury)
-- Visitor Classification System: Modified Two-Tier (Merged Invitee/Licensee)
-- Primary Authority: Mounsey v. Ellard, 363 Mass. 693 (1973)
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
    'MA',
    NULL,
    NULL,
    'Massachusetts Premises Liability - Modified Two-Tier (Merged Invitee/Licensee)',
    'Massachusetts Courts',
    'Mounsey v. Ellard, 363 Mass. 693 (1973)',
    '',
    'case_law',
    'high',
    'Massachusetts follows the Modified Two-Tier (Merged Invitee/Licensee) for premises liability cases. Authority: Mounsey v. Ellard, 363 Mass. 693 (1973). NEEDS REVIEW - pending attorney verification.'
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
    'MA-PREM-LIAB-MOD-2-TIER',
    5,
    'MA Premises Liability Modified Two-Tier (Merged Invitee/Licensee)',
    'content_check',
    'personal_injury',
    'premises_liability',
    'complaint',
    'state',
    'MA',
    NULL,
    NULL,
    '{
        "visitor_classification_system": "modified_two_tier",
        "statute": "Mounsey v. Ellard, 363 Mass. 693 (1973)",
        "system_description": "Modified Two-Tier (Merged Invitee/Licensee)",
        "key_requirements": [
            "INVITEE and LICENSEE are merged: Owner owes the same reasonable care duty to both business visitors and social guests",
                "Traditional distinction between invitee and licensee is abolished",
                "TRESPASSER: Owner still owes lower duty - must not willfully or wantonly injure",
                "Attractive nuisance doctrine still applies for child trespassers",
                "Plaintiff must still establish entry was authorized to benefit from the higher merged duty"
        ],
        "defenses": [
            "Plaintiff was trespasser (reduces duty to avoid willful/wanton injury only)",
                "Open and obvious danger doctrine",
                "Comparative or contributory negligence by plaintiff",
                "Assumption of risk",
                "Lack of notice of hazard"
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
-- END OF MASSACHUSETTS PREMISES LIABILITY SEED FILE
-- =====================================================================================
