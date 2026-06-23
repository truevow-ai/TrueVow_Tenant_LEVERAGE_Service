
-- Bankruptcy discharge_exceptions_state rule for WY
-- Generated: 2026-03-06T04:28:04.244742+00:00

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'WY-BANKRUPTCY-DISCHARGE-EXCEPTIONS-STATE', 5, 'WY Bankruptcy - Discharge Exceptions State', 'content_check', 'bankruptcy',
    'discharge_exceptions_state', 'general', 'state', 'WY',
    '{"state_alimony_non_dischargeable": true, "state_tax_lien_survives": true, "state_specific_exception": "Restitution (Wyo. Stat. \u00a7 7-9-102)", "statutory_citation": "11 U.S.C. \u00a7 523(a); Wyo. Stat. \u00a7 7-9-102", "authority_level": "hard_rule"}'::jsonb, 'error', 'needs_review', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config   = EXCLUDED.validator_config,
    review_status      = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at         = NOW();
