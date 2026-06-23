
-- Immigration daca_state_policy rule for WA
-- Generated: 2026-03-05T03:46:13.384433+00:00

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'WA-IMMIGRATION-DACA-STATE-POLICY', 5, 'WA Immigration - Daca State Policy', 'content_check', 'immigration',
    'daca_state_policy', 'general', 'state', 'WA',
    '{"drivers_license_eligible": true, "in_state_tuition_eligible": true, "professional_license_eligible": true, "statutory_citation": "RCW 46.20.031(3) (DACA license); RCW 28B.15.012 (HB 1079, 2003)", "authority_level": "hard_rule"}'::jsonb, 'error', 'needs_review', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config   = EXCLUDED.validator_config,
    review_status      = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at         = NOW();
