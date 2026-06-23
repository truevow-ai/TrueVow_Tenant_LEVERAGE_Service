-- =====================================================================================
-- PRODUCT LIABILITY RULES SEED FILE
-- =====================================================================================
-- State: Utah (UT)
-- Sub-Specialization: Product Liability
-- Product Liability Theory: Strict Liability (Restatement 402A)
-- Primary Authority: Utah Code Ann. § 78B-6-703; Billings v. Atkinson
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
    'UT',
    NULL,
    NULL,
    'Utah Product Liability - Strict Liability (Restatement 402A)',
    'Utah Courts',
    'Utah Code Ann. § 78B-6-703; Billings v. Atkinson',
    '',
    'case_law',
    'high',
    'Utah follows the Strict Liability (Restatement 402A) for product liability cases. Authority: Utah Code Ann. § 78B-6-703; Billings v. Atkinson. NEEDS REVIEW - pending attorney verification.'
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
    'UT-PROD-LIAB-STRICT-402A',
    5,
    'UT Product Liability Strict Liability (Restatement 402A)',
    'content_check',
    'personal_injury',
    'product_liability',
    'complaint',
    'state',
    'UT',
    NULL,
    NULL,
    '{
        "product_liability_theory": "strict_liability_402a",
        "statute": "Utah Code Ann. § 78B-6-703; Billings v. Atkinson",
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
-- END OF UTAH PRODUCT LIABILITY SEED FILE
-- =====================================================================================
