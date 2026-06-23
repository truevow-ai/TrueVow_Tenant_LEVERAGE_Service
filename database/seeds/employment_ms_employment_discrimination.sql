
-- Employment employment_discrimination rule for MS
-- Generated: 2026-03-05T02:18:18.620243+00:00

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'MS-EMPLOYMENT-EMPLOYMENT-DISCRIMINATION', 5, 'MS Employment - Employment Discrimination', 'content_check', 'employment',
    'employment_discrimination', 'general', 'state', 'MS',
    '{"state_agency": "EEOC_only", "state_law_name": "No State FEPA", "statutory_citation": "42 U.S.C. \u00a7 2000e (federal only)", "authority_level": "hard_rule"}'::jsonb, 'error', 'needs_review', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config   = EXCLUDED.validator_config,
    review_status      = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at         = NOW();
