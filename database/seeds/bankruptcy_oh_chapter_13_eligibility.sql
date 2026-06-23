
-- Bankruptcy chapter_13_eligibility rule for OH
-- Generated: 2026-03-06T04:28:03.825571+00:00

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'OH-BANKRUPTCY-CHAPTER-13-ELIGIBILITY', 5, 'OH Bankruptcy - Chapter 13 Eligibility', 'content_check', 'bankruptcy',
    'chapter_13_eligibility', 'general', 'state', 'OH',
    '{"secured_debt_limit_usd": 2750000, "unsecured_debt_limit_usd": 1375000, "plan_length_years_standard": 5, "statutory_citation": "11 U.S.C. \u00a7 1325(b)(4)", "authority_level": "hard_rule"}'::jsonb, 'error', 'needs_review', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config   = EXCLUDED.validator_config,
    review_status      = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at         = NOW();
