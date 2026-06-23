
-- Employment fmla_state rule for HI
-- Generated: 2026-03-05T02:18:18.487242+00:00

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'HI-EMPLOYMENT-FMLA-STATE', 5, 'HI Employment - Fmla State', 'content_check', 'employment',
    'fmla_state', 'general', 'state', 'HI',
    '{"leave_law_name": "TDI + HFLL", "paid_leave_available": true, "max_weeks": 4, "statutory_citation": "HRS \u00a7 398-3", "authority_level": "hard_rule"}'::jsonb, 'error', 'needs_review', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config   = EXCLUDED.validator_config,
    review_status      = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at         = NOW();
