
-- Estate Planning trust_formation rule for OH
-- Generated: 2026-03-05T01:57:39.816283+00:00

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'OH-ESTATE-PLANNING-TRUST-FORMATION', 5, 'OH Estate Planning - Trust Formation', 'content_check', 'estate_planning',
    'trust_formation', 'general', 'state', 'OH',
    '{"trust_act": "UTC", "requires_written_instrument": true, "statutory_citation": "Ohio Rev. Code \u00a7 5804.02", "authority_level": "hard_rule"}'::jsonb, 'error', 'needs_review', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config   = EXCLUDED.validator_config,
    review_status      = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at         = NOW();
