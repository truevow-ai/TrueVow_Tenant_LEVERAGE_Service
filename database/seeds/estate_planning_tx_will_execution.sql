
-- Estate Planning will_execution rule for TX
-- Generated: 2026-03-05T01:57:39.949457+00:00

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'TX-ESTATE-PLANNING-WILL-EXECUTION', 5, 'TX Estate Planning - Will Execution', 'content_check', 'estate_planning',
    'will_execution', 'general', 'state', 'TX',
    '{"witnesses_required": 2, "notarization_required": false, "statutory_citation": "Tex. Est. Code \u00a7 251.051", "authority_level": "hard_rule"}'::jsonb, 'error', 'needs_review', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config   = EXCLUDED.validator_config,
    review_status      = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at         = NOW();
