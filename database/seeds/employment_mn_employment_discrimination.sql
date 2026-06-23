
-- Employment employment_discrimination rule for MN
-- Generated: 2026-03-05T02:18:18.600052+00:00

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'MN-EMPLOYMENT-EMPLOYMENT-DISCRIMINATION', 5, 'MN Employment - Employment Discrimination', 'content_check', 'employment',
    'employment_discrimination', 'general', 'state', 'MN',
    '{"state_agency": "MDHR", "state_law_name": "Minnesota Human Rights Act", "statutory_citation": "Minn. Stat. \u00a7 363A.08", "authority_level": "hard_rule"}'::jsonb, 'error', 'needs_review', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config   = EXCLUDED.validator_config,
    review_status      = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at         = NOW();
