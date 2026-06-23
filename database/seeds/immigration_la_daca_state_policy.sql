
-- Immigration daca_state_policy rule for LA
-- Generated: 2026-03-05T03:46:09.835334+00:00

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'LA-IMMIGRATION-DACA-STATE-POLICY', 5, 'LA Immigration - Daca State Policy', 'content_check', 'immigration',
    'daca_state_policy', 'general', 'state', 'LA',
    '{"drivers_license_eligible": true, "in_state_tuition_eligible": false, "professional_license_eligible": false, "statutory_citation": "La. Rev. Stat. \u00a7 32:409.1(A)(1); no in-state tuition provision for DACA", "authority_level": "hard_rule"}'::jsonb, 'error', 'needs_review', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config   = EXCLUDED.validator_config,
    review_status      = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at         = NOW();
