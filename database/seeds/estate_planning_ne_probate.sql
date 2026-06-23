
-- Estate Planning probate rule for NE
-- Generated: 2026-03-05T01:57:39.731553+00:00

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'NE-ESTATE-PLANNING-PROBATE', 5, 'NE Estate Planning - Probate', 'content_check', 'estate_planning',
    'probate', 'general', 'state', 'NE',
    '{"probate_code": "UPC", "small_estate_threshold_usd": 50000, "statutory_citation": "Neb. Rev. Stat. \u00a7 30-24,129", "authority_level": "hard_rule"}'::jsonb, 'error', 'needs_review', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config   = EXCLUDED.validator_config,
    review_status      = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at         = NOW();
