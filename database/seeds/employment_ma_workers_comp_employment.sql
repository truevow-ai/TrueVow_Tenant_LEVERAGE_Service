
-- Employment workers_comp_employment rule for MA
-- Generated: 2026-03-05T02:18:18.567117+00:00

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'MA-EMPLOYMENT-WORKERS-COMP-EMPLOYMENT', 5, 'MA Employment - Workers Comp Employment', 'content_check', 'employment',
    'workers_comp_employment', 'general', 'state', 'MA',
    '{"wc_system_type": "private_only", "exclusive_remedy": true, "statutory_citation": "Mass. Gen. Laws ch. 152, \u00a7 23", "authority_level": "hard_rule"}'::jsonb, 'error', 'needs_review', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config   = EXCLUDED.validator_config,
    review_status      = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at         = NOW();
