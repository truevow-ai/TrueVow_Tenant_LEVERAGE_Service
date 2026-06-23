
-- Immigration daca_state_policy rule for TN
-- Generated: 2026-03-05T03:46:13.277117+00:00

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'TN-IMMIGRATION-DACA-STATE-POLICY', 5, 'TN Immigration - Daca State Policy', 'content_check', 'immigration',
    'daca_state_policy', 'general', 'state', 'TN',
    '{"drivers_license_eligible": false, "in_state_tuition_eligible": false, "professional_license_eligible": false, "statutory_citation": "Tenn. Code Ann. \u00a7 55-50-321 (prohibits DACA licenses); \u00a7 49-7-152", "authority_level": "hard_rule"}'::jsonb, 'error', 'needs_review', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config   = EXCLUDED.validator_config,
    review_status      = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at         = NOW();
