
-- Employment wage_theft rule for KS
-- Generated: 2026-03-05T02:18:18.533781+00:00

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'KS-EMPLOYMENT-WAGE-THEFT', 5, 'KS Employment - Wage Theft', 'content_check', 'employment',
    'wage_theft', 'general', 'state', 'KS',
    '{"state_min_wage_usd": 7.25, "overtime_statute": "29 U.S.C. \u00a7 207", "statutory_citation": "K.S.A. \u00a7 44-1203", "authority_level": "hard_rule"}'::jsonb, 'error', 'needs_review', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config   = EXCLUDED.validator_config,
    review_status      = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at         = NOW();
