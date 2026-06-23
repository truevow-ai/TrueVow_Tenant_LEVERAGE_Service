-- =====================================================================================
-- PREMISES LIABILITY RULES SEED FILE
-- =====================================================================================
-- State: Alaska (AK)
-- Sub-Specialization: Premises Liability (Personal Injury)
-- Visitor Classification System: Traditional Three-Tier Premises Liability
-- Primary Authority: Alaska common law; Vertecs Corp. v. Reichhold Chemicals, Inc.
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
    'AK',
    NULL,
    NULL,
    'Alaska Premises Liability - Traditional Three-Tier Premises Liability',
    'Alaska Courts',
    'Alaska common law; Vertecs Corp. v. Reichhold Chem',
    '',
    'case_law',
    'high',
    'Alaska follows the Traditional Three-Tier Premises Liability for premises liability cases. Authority: Alaska common law; Vertecs Corp. v. Reichhold Chemicals, Inc.. NEEDS REVIEW - pending attorney verification.'
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
    'AK-PREM-LIAB-TRAD-3-TIER',
    5,
    'AK Premises Liability Traditional Three-Tier Premises Liability',
    'content_check',
    'personal_injury',
    'premises_liability',
    'complaint',
    'state',
    'AK',
    NULL,
    NULL,
    '{
        "visitor_classification_system": "traditional_three_tier",
        "statute": "Alaska common law; Vertecs Corp. v. Reichhold Chemicals, Inc.",
        "system_description": "Traditional Three-Tier Premises Liability",
        "key_requirements": [
            "INVITEE (business or public): Owner owes highest duty - must exercise reasonable care to inspect, maintain, and warn of known AND discoverable dangers",
                "LICENSEE (social guest): Owner owes intermediate duty - must warn of known hidden dangers; no duty to inspect for unknown dangers",
                "TRESPASSER: Owner owes lowest duty - must not willfully or wantonly injure; attractive nuisance doctrine applies for child trespassers",
                "Plaintiff''s legal status on the premises at time of injury determines the applicable duty of care",
                "Owner must maintain premises in reasonably safe condition for the class of entrant"
        ],
        "defenses": [
            "Plaintiff was trespasser (reduces duty to avoid willful/wanton injury only)",
                "Open and obvious danger doctrine (no duty to warn of patent conditions)",
                "Contributory or comparative negligence by plaintiff",
                "Natural accumulation rule (no duty for natural weather conditions in some states)",
                "Assumption of risk"
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
-- END OF ALASKA PREMISES LIABILITY SEED FILE
-- =====================================================================================
