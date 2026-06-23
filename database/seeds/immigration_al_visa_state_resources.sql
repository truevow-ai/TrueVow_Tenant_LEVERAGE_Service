
-- Immigration visa_state_resources rule for AL
-- Generated: 2026-03-05T03:46:08.149570+00:00

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'AL-IMMIGRATION-VISA-STATE-RESOURCES', 5, 'AL Immigration - Visa State Resources', 'content_check', 'immigration',
    'visa_state_resources', 'general', 'state', 'AL',
    '{"primary_immigrant_services_agency": "Alabama DEC \u2013 Immigration & Refugee Services (no dedicated agency)", "eb5_regional_center_active": false, "statutory_citation": "Ala. Code \u00a7 41-9-200 (Alabama Development Office)", "authority_level": "hard_rule"}'::jsonb, 'error', 'needs_review', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config   = EXCLUDED.validator_config,
    review_status      = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at         = NOW();
