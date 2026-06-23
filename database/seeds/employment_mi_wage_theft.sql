
-- Employment wage_theft rule for MI
-- Generated: 2026-03-05T02:18:18.593924+00:00

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'MI-EMPLOYMENT-WAGE-THEFT', 5, 'MI Employment - Wage Theft', 'content_check', 'employment',
    'wage_theft', 'general', 'state', 'MI',
    '{"state_min_wage_usd": 10.33, "overtime_statute": "MCL 408.934a", "statutory_citation": "MCL 408.934", "authority_level": "hard_rule"}'::jsonb, 'error', 'needs_review', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config   = EXCLUDED.validator_config,
    review_status      = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at         = NOW();
