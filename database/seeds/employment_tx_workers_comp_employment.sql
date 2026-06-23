
-- Employment workers_comp_employment rule for TX
-- Generated: 2026-03-05T02:18:18.799249+00:00

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'TX-EMPLOYMENT-WORKERS-COMP-EMPLOYMENT', 5, 'TX Employment - Workers Comp Employment', 'content_check', 'employment',
    'workers_comp_employment', 'general', 'state', 'TX',
    '{"wc_system_type": "private_optional", "exclusive_remedy": false, "statutory_citation": "Tex. Lab. Code \u00a7 406.034 (non-subscriber system \u2014 unique)", "authority_level": "hard_rule"}'::jsonb, 'error', 'needs_review', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config   = EXCLUDED.validator_config,
    review_status      = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at         = NOW();
