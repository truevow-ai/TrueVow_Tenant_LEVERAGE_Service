
-- Immigration daca_state_policy rule for WI
-- Generated: 2026-03-05T03:46:13.401664+00:00

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'WI-IMMIGRATION-DACA-STATE-POLICY', 5, 'WI Immigration - Daca State Policy', 'content_check', 'immigration',
    'daca_state_policy', 'general', 'state', 'WI',
    '{"drivers_license_eligible": true, "in_state_tuition_eligible": true, "professional_license_eligible": false, "statutory_citation": "Wis. Stat. \u00a7 343.14(2)(es) (DACA license 2016); \u00a7 36.27(2)(a) (in-state eligible); professional licenses vary", "authority_level": "hard_rule"}'::jsonb, 'error', 'needs_review', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config   = EXCLUDED.validator_config,
    review_status      = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at         = NOW();
