
-- Bankruptcy discharge_exceptions_state rule for UT
-- Generated: 2026-03-06T04:28:04.068636+00:00

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'UT-BANKRUPTCY-DISCHARGE-EXCEPTIONS-STATE', 5, 'UT Bankruptcy - Discharge Exceptions State', 'content_check', 'bankruptcy',
    'discharge_exceptions_state', 'general', 'state', 'UT',
    '{"state_alimony_non_dischargeable": true, "state_tax_lien_survives": true, "state_specific_exception": "Restitution (Utah Code \u00a7 77-38a-302)", "statutory_citation": "11 U.S.C. \u00a7 523(a); Utah Code \u00a7 77-38a-302", "authority_level": "hard_rule"}'::jsonb, 'error', 'needs_review', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config   = EXCLUDED.validator_config,
    review_status      = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at         = NOW();
