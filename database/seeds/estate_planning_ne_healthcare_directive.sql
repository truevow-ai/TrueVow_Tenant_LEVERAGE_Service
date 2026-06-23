
-- Estate Planning healthcare_directive rule for NE
-- Generated: 2026-03-05T01:57:39.730037+00:00

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'NE-ESTATE-PLANNING-HEALTHCARE-DIRECTIVE', 5, 'NE Estate Planning - Healthcare Directive', 'content_check', 'estate_planning',
    'healthcare_directive', 'general', 'state', 'NE',
    '{"directive_type": "advance_directive", "witnesses_required": 2, "statutory_citation": "Neb. Rev. Stat. \u00a7 30-3401", "authority_level": "hard_rule"}'::jsonb, 'error', 'needs_review', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config   = EXCLUDED.validator_config,
    review_status      = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at         = NOW();
