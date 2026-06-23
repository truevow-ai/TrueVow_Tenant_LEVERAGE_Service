
-- Immigration visa_state_resources rule for FL
-- Generated: 2026-03-05T03:46:08.698749+00:00

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'FL-IMMIGRATION-VISA-STATE-RESOURCES', 5, 'FL Immigration - Visa State Resources', 'content_check', 'immigration',
    'visa_state_resources', 'general', 'state', 'FL',
    '{"primary_immigrant_services_agency": "Florida DCF \u2013 Refugee Services; Office of New Floridians", "eb5_regional_center_active": true, "statutory_citation": "Fla. Stat. \u00a7 14.0195 (Office of New Floridians, 2024)", "authority_level": "hard_rule"}'::jsonb, 'error', 'needs_review', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config   = EXCLUDED.validator_config,
    review_status      = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at         = NOW();
