
-- Immigration asylum_state_policy rule for DE
-- Generated: 2026-03-05T03:46:08.658278+00:00

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'DE-IMMIGRATION-ASYLUM-STATE-POLICY', 5, 'DE Immigration - Asylum State Policy', 'content_check', 'immigration',
    'asylum_state_policy', 'general', 'state', 'DE',
    '{"state_refugee_agency": "Delaware DHSS \u2013 Division of Social Services", "state_protection_level": "full_state_resettlement", "statutory_citation": "29 Del. Code \u00a7 7901", "authority_level": "hard_rule"}'::jsonb, 'error', 'needs_review', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config   = EXCLUDED.validator_config,
    review_status      = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at         = NOW();
