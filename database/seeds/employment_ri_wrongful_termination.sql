
-- Employment wrongful_termination rule for RI
-- Generated: 2026-03-05T02:18:18.753866+00:00

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'RI-EMPLOYMENT-WRONGFUL-TERMINATION', 5, 'RI Employment - Wrongful Termination', 'content_check', 'employment',
    'wrongful_termination', 'general', 'state', 'RI',
    '{"at_will_rule": "at_will", "public_policy_exception": true, "implied_contract_exception": true, "statutory_citation": "Centredale Manor v. Plant Constr., 482 F.3d 34 (1st Cir. 2007)", "authority_level": "hard_rule"}'::jsonb, 'error', 'needs_review', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config   = EXCLUDED.validator_config,
    review_status      = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at         = NOW();
