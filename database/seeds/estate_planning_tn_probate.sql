
-- Estate Planning probate rule for TN
-- Generated: 2026-03-05T01:57:39.935289+00:00

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'TN-ESTATE-PLANNING-PROBATE', 5, 'TN Estate Planning - Probate', 'content_check', 'estate_planning',
    'probate', 'general', 'state', 'TN',
    '{"probate_code": "non_UPC", "small_estate_threshold_usd": 50000, "statutory_citation": "Tenn. Code Ann. \u00a7 30-4-102", "authority_level": "hard_rule"}'::jsonb, 'error', 'needs_review', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config   = EXCLUDED.validator_config,
    review_status      = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at         = NOW();
