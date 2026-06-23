-- Criminal Defense Bail Standards Rules for Iowa
-- Generated: 2026-03-04T10:51:02.466218+00:00

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'IA-CRIMINAL-BAIL-RIGHT', 5, 'Iowa Bail Standards', 'content_check', 'criminal_defense',
    'bail_standards', 'motion', 'state', 'IA',
    '{"bail_standard": "constitutional_right", "statute": "Iowa Const. Art. I, \u00a7 12", "authority_level": "constitutional_right"}'::jsonb, 'error', 'needs_review', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    review_status = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at = NOW();
