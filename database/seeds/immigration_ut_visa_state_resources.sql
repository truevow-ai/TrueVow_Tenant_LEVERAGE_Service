
-- Immigration visa_state_resources rule for UT
-- Generated: 2026-03-05T03:46:13.326337+00:00

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'UT-IMMIGRATION-VISA-STATE-RESOURCES', 5, 'UT Immigration - Visa State Resources', 'content_check', 'immigration',
    'visa_state_resources', 'general', 'state', 'UT',
    '{"primary_immigrant_services_agency": "Utah DWS \u2013 Refugee Services; Utah Office of New Americans", "eb5_regional_center_active": true, "statutory_citation": "Utah Code \u00a7 35A-3-102", "authority_level": "hard_rule"}'::jsonb, 'error', 'needs_review', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config   = EXCLUDED.validator_config,
    review_status      = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at         = NOW();
