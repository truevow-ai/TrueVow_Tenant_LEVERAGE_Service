
-- Estate Planning probate rule for MT
-- Generated: 2026-03-05T01:57:39.688662+00:00

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'MT-ESTATE-PLANNING-PROBATE', 5, 'MT Estate Planning - Probate', 'content_check', 'estate_planning',
    'probate', 'general', 'state', 'MT',
    '{"probate_code": "UPC", "small_estate_threshold_usd": 50000, "statutory_citation": "MCA \u00a7 72-3-1101", "authority_level": "hard_rule"}'::jsonb, 'error', 'needs_review', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config   = EXCLUDED.validator_config,
    review_status      = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at         = NOW();
