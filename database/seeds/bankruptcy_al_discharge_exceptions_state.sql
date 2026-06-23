
-- Bankruptcy discharge_exceptions_state rule for AL
-- Generated: 2026-03-06T04:28:02.929897+00:00

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'AL-BANKRUPTCY-DISCHARGE-EXCEPTIONS-STATE', 5, 'AL Bankruptcy - Discharge Exceptions State', 'content_check', 'bankruptcy',
    'discharge_exceptions_state', 'general', 'state', 'AL',
    '{"state_alimony_non_dischargeable": true, "state_tax_lien_survives": true, "state_specific_exception": "Court-ordered fines under Ala. Code \u00a7 15-18-65", "statutory_citation": "11 U.S.C. \u00a7 523(a); Ala. Code \u00a7 15-18-65", "authority_level": "hard_rule"}'::jsonb, 'error', 'needs_review', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config   = EXCLUDED.validator_config,
    review_status      = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at         = NOW();
