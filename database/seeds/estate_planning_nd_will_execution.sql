
-- Estate Planning will_execution rule for ND
-- Generated: 2026-03-05T01:57:39.703417+00:00

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'ND-ESTATE-PLANNING-WILL-EXECUTION', 5, 'ND Estate Planning - Will Execution', 'content_check', 'estate_planning',
    'will_execution', 'general', 'state', 'ND',
    '{"witnesses_required": 2, "notarization_required": false, "statutory_citation": "N.D. Cent. Code \u00a7 30.1-08-02", "authority_level": "hard_rule"}'::jsonb, 'error', 'needs_review', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config   = EXCLUDED.validator_config,
    review_status      = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at         = NOW();
