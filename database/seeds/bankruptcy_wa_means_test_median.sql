
-- Bankruptcy means_test_median rule for WA
-- Generated: 2026-03-06T04:28:04.100181+00:00

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'WA-BANKRUPTCY-MEANS-TEST-MEDIAN', 5, 'WA Bankruptcy - Means Test Median', 'content_check', 'bankruptcy',
    'means_test_median', 'general', 'state', 'WA',
    '{"median_income_1person_usd_annual": 76140, "census_period": "UST April 2024", "statutory_citation": "11 U.S.C. \u00a7 707(b)(7); UST Means Test Data WA Apr. 2024", "authority_level": "hard_rule"}'::jsonb, 'error', 'needs_review', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config   = EXCLUDED.validator_config,
    review_status      = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at         = NOW();
