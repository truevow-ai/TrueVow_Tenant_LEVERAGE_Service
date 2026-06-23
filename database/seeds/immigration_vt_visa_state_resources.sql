
-- Immigration visa_state_resources rule for VT
-- Generated: 2026-03-05T03:46:13.377464+00:00

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'VT-IMMIGRATION-VISA-STATE-RESOURCES', 5, 'VT Immigration - Visa State Resources', 'content_check', 'immigration',
    'visa_state_resources', 'general', 'state', 'VT',
    '{"primary_immigrant_services_agency": "Vermont AHS \u2013 Refugee Resettlement; Office of Racial Equity", "eb5_regional_center_active": false, "statutory_citation": "33 V.S.A. \u00a7 103", "authority_level": "hard_rule"}'::jsonb, 'error', 'needs_review', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config   = EXCLUDED.validator_config,
    review_status      = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at         = NOW();
