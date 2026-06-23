-- =====================================================================================
-- PRODUCT LIABILITY RULES SEED FILE
-- =====================================================================================
-- State: West Virginia (WV)
-- Sub-Specialization: Product Liability
-- Product Liability Theory: Strict Liability (Restatement 402A)
-- Primary Authority: W. Va. Code § 55-7-8; Morningstar v. Black & Decker Mfg. Co.
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
    'WV',
    NULL,
    NULL,
    'West Virginia Product Liability - Strict Liability (Restatement 402A)',
    'West Virginia Courts',
    'W. Va. Code § 55-7-8; Morningstar v. Black & Decke',
    '',
    'case_law',
    'high',
    'West Virginia follows the Strict Liability (Restatement 402A) for product liability cases. Authority: W. Va. Code § 55-7-8; Morningstar v. Black & Decker Mfg. Co.. NEEDS REVIEW - pending attorney verification.'
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
    'WV-PROD-LIAB-STRICT-402A',
    5,
    'WV Product Liability Strict Liability (Restatement 402A)',
    'content_check',
    'personal_injury',
    'product_liability',
    'complaint',
    'state',
    'WV',
    NULL,
    NULL,
    '{
        "product_liability_theory": "strict_liability_402a",
        "statute": "W. Va. Code § 55-7-8; Morningstar v. Black & Decker Mfg. Co.",
        "theory_description": "Strict Liability (Restatement 402A)",
        "key_requirements": [
            "Plaintiff must prove: (1) product was defective, (2) defect existed when product left defendant''s control, (3) defect caused plaintiff''s injury",
                "No need to prove negligence or fault - strict liability applies",
                "Seller is liable even if all possible care was exercised in preparation and sale",
                "Defect can be manufacturing defect, design defect, or failure to warn",
                "Applies to sellers in the business of selling such products"
        ],
        "defenses": [
            "Product misuse or abnormal use",
                "Alteration or modification of product after sale",
                "Assumption of risk by plaintiff",
                "Comparative/contributory negligence (in some states)",
                "Statute of limitations/repose",
                "Sophisticated user/purchaser doctrine",
                "Learned intermediary doctrine (prescription drugs)"
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
-- END OF WEST VIRGINIA PRODUCT LIABILITY SEED FILE
-- =====================================================================================
