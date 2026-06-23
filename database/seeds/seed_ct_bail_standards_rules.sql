-- Criminal Defense Bail Standards Rules for Connecticut
-- Generated: 2026-03-04T10:51:02.450004+00:00

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'CT-CRIMINAL-BAIL-RIGHT', 5, 'Connecticut Bail Standards', 'content_check', 'criminal_defense',
    'bail_standards', 'motion', 'state', 'CT',
    '{"bail_standard": "constitutional_right", "statute": "Conn. Const. Art. I, \u00a7 8", "authority_level": "constitutional_right"}'::jsonb, 'error', 'needs_review', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    review_status = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at = NOW();
