
-- Estate Planning healthcare_directive rule for ND
-- Generated: 2026-03-05T01:57:39.713647+00:00

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'ND-ESTATE-PLANNING-HEALTHCARE-DIRECTIVE', 5, 'ND Estate Planning - Healthcare Directive', 'content_check', 'estate_planning',
    'healthcare_directive', 'general', 'state', 'ND',
    '{"directive_type": "advance_directive", "witnesses_required": 2, "statutory_citation": "N.D. Cent. Code \u00a7 23-06.5-03", "authority_level": "hard_rule"}'::jsonb, 'error', 'needs_review', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config   = EXCLUDED.validator_config,
    review_status      = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at         = NOW();
