-- =====================================================================================
-- PRODUCT LIABILITY RULES SEED FILE
-- =====================================================================================
-- State: Virginia (VA)
-- Sub-Specialization: Product Liability
-- Product Liability Theory: Negligence Only
-- Primary Authority: Virginia common law; Larrimore v. American National Ins. Co.
--
-- VERIFICATION STATUS: NEEDS_REVIEW (AI-Generated, Pending Attorney Review)
-- Research Date: March 2, 2026
-- Protocol v3: Deterministic verification against authoritative product liability table
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
    'VA',
    NULL,
    NULL,
    'Virginia Product Liability - Negligence Only',
    'Virginia Courts',
    'Virginia common law; Larrimore v. American Nationa',
    '',
    'case_law',
    'high',
    'Virginia follows the Negligence Only for product liability cases. Authority: Virginia common law; Larrimore v. American National Ins. Co.. NEEDS REVIEW - pending attorney verification.'
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
    'VA-PROD-LIAB-NEGLIGENCE',
    5,
    'VA Product Liability Negligence Only',
    'content_check',
    'personal_injury',
    'product_liability',
    'complaint',
    'state',
    'VA',
    NULL,
    NULL,
    '{
        "product_liability_theory": "negligence",
        "statute": "Virginia common law; Larrimore v. American National Ins. Co.",
        "theory_description": "Negligence Only",
        "key_requirements": [
            "Plaintiff must prove: (1) defendant owed a duty of care, (2) defendant breached that duty, (3) breach caused plaintiff''s injury",
                "Must show defendant failed to exercise reasonable care in design, manufacture, or warning",
                "Res ipsa loquitur may apply in some manufacturing defect cases",
                "More difficult to prove than strict liability",
                "Virginia is the only pure negligence state for product liability"
        ],
        "defenses": [
            "Plaintiff''s contributory or comparative negligence",
                "Assumption of risk",
                "Product misuse",
                "Superseding/intervening cause",
                "Statute of limitations"
        ],
        "burden_of_proof": "Plaintiff must prove: (1) product was in defective condition unreasonably dangerous, (2) defect existed when product left defendant''s control, (3) defect caused plaintiff''s injury",
        "damages": "Economic (medical, lost wages, property damage) + Non-economic (pain and suffering) + Punitive (for willful/reckless conduct)"
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
-- END OF VIRGINIA PRODUCT LIABILITY SEED FILE
-- =====================================================================================
