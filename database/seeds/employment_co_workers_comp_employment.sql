
-- Employment workers_comp_employment rule for CO
-- Generated: 2026-03-05T02:18:18.440875+00:00

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'CO-EMPLOYMENT-WORKERS-COMP-EMPLOYMENT', 5, 'CO Employment - Workers Comp Employment', 'content_check', 'employment',
    'workers_comp_employment', 'general', 'state', 'CO',
    '{"wc_system_type": "state_fund_private", "exclusive_remedy": true, "statutory_citation": "C.R.S. \u00a7 8-41-102", "authority_level": "hard_rule"}'::jsonb, 'error', 'needs_review', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config   = EXCLUDED.validator_config,
    review_status      = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at         = NOW();
