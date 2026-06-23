
-- Employment fmla_state rule for AL
-- Generated: 2026-03-05T02:18:18.405344+00:00

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'AL-EMPLOYMENT-FMLA-STATE', 5, 'AL Employment - Fmla State', 'content_check', 'employment',
    'fmla_state', 'general', 'state', 'AL',
    '{"leave_law_name": "No state expansion", "paid_leave_available": false, "max_weeks": 0, "statutory_citation": "29 U.S.C. \u00a7 2601 (federal FMLA only)", "authority_level": "hard_rule"}'::jsonb, 'error', 'needs_review', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config   = EXCLUDED.validator_config,
    review_status      = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at         = NOW();
