
-- Employment wage_theft rule for WI
-- Generated: 2026-03-05T02:18:18.854254+00:00

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'WI-EMPLOYMENT-WAGE-THEFT', 5, 'WI Employment - Wage Theft', 'content_check', 'employment',
    'wage_theft', 'general', 'state', 'WI',
    '{"state_min_wage_usd": 7.25, "overtime_statute": "Wis. Stat. \u00a7 103.02", "statutory_citation": "Wis. Stat. \u00a7 104.02", "authority_level": "hard_rule"}'::jsonb, 'error', 'needs_review', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config   = EXCLUDED.validator_config,
    review_status      = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at         = NOW();
