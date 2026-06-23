
-- Immigration visa_state_resources rule for IA
-- Generated: 2026-03-05T03:46:09.272133+00:00

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'IA-IMMIGRATION-VISA-STATE-RESOURCES', 5, 'IA Immigration - Visa State Resources', 'content_check', 'immigration',
    'visa_state_resources', 'general', 'state', 'IA',
    '{"primary_immigrant_services_agency": "Iowa DHS \u2013 Bureau of Refugee Services", "eb5_regional_center_active": true, "statutory_citation": "Iowa Code \u00a7 249A.3", "authority_level": "hard_rule"}'::jsonb, 'error', 'needs_review', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config   = EXCLUDED.validator_config,
    review_status      = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at         = NOW();
