
-- Immigration daca_state_policy rule for OK
-- Generated: 2026-03-05T03:46:12.745979+00:00

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'OK-IMMIGRATION-DACA-STATE-POLICY', 5, 'OK Immigration - Daca State Policy', 'content_check', 'immigration',
    'daca_state_policy', 'general', 'state', 'OK',
    '{"drivers_license_eligible": false, "in_state_tuition_eligible": false, "professional_license_eligible": false, "statutory_citation": "51 Okl. St. \u00a7 40.1 (prohibits state benefits to DACA); 47 Okl. St. \u00a7 6-101.1", "authority_level": "hard_rule"}'::jsonb, 'error', 'needs_review', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config   = EXCLUDED.validator_config,
    review_status      = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at         = NOW();
