
-- Immigration daca_state_policy rule for VA
-- Generated: 2026-03-05T03:46:13.354900+00:00

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'VA-IMMIGRATION-DACA-STATE-POLICY', 5, 'VA Immigration - Daca State Policy', 'content_check', 'immigration',
    'daca_state_policy', 'general', 'state', 'VA',
    '{"drivers_license_eligible": true, "in_state_tuition_eligible": true, "professional_license_eligible": true, "statutory_citation": "Va. Code \u00a7 46.2-328.1 (DACA license 2020); \u00a7 23.1-505 (in-state eligible); \u00a7 54.1-111.1", "authority_level": "hard_rule"}'::jsonb, 'error', 'needs_review', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config   = EXCLUDED.validator_config,
    review_status      = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at         = NOW();
