
-- Employment wrongful_termination rule for UT
-- Generated: 2026-03-05T02:18:18.804109+00:00

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'UT-EMPLOYMENT-WRONGFUL-TERMINATION', 5, 'UT Employment - Wrongful Termination', 'content_check', 'employment',
    'wrongful_termination', 'general', 'state', 'UT',
    '{"at_will_rule": "at_will", "public_policy_exception": true, "implied_contract_exception": true, "statutory_citation": "Berube v. Fashion Centre, 771 P.2d 1033 (Utah 1989)", "authority_level": "hard_rule"}'::jsonb, 'error', 'needs_review', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config   = EXCLUDED.validator_config,
    review_status      = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at         = NOW();
