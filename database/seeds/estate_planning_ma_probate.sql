
-- Estate Planning probate rule for MA
-- Generated: 2026-03-05T01:57:39.585443+00:00

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'MA-ESTATE-PLANNING-PROBATE', 5, 'MA Estate Planning - Probate', 'content_check', 'estate_planning',
    'probate', 'general', 'state', 'MA',
    '{"probate_code": "non_UPC", "small_estate_threshold_usd": 25000, "statutory_citation": "Mass. Gen. Laws ch. 190B, \u00a7 3-1201", "authority_level": "hard_rule"}'::jsonb, 'error', 'needs_review', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config   = EXCLUDED.validator_config,
    review_status      = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at         = NOW();
