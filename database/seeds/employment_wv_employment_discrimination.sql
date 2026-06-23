
-- Employment employment_discrimination rule for WV
-- Generated: 2026-03-05T02:18:18.861417+00:00

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'WV-EMPLOYMENT-EMPLOYMENT-DISCRIMINATION', 5, 'WV Employment - Employment Discrimination', 'content_check', 'employment',
    'employment_discrimination', 'general', 'state', 'WV',
    '{"state_agency": "WVHRC", "state_law_name": "West Virginia Human Rights Act", "statutory_citation": "W. Va. Code \u00a7 5-11-9", "authority_level": "hard_rule"}'::jsonb, 'error', 'needs_review', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config   = EXCLUDED.validator_config,
    review_status      = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at         = NOW();
