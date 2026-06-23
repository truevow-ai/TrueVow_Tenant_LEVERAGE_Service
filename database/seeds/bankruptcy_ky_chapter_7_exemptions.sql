
-- Bankruptcy chapter_7_exemptions rule for KY
-- Generated: 2026-03-06T04:28:03.475676+00:00

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'KY-BANKRUPTCY-CHAPTER-7-EXEMPTIONS', 5, 'KY Bankruptcy - Chapter 7 Exemptions', 'content_check', 'bankruptcy',
    'chapter_7_exemptions', 'general', 'state', 'KY',
    '{"opt_out_of_federal_exemptions": true, "homestead_exemption_usd": 5000, "vehicle_exemption_usd": 2500, "wildcard_exemption_usd": 1000, "statutory_citation": "KRS \u00a7 427.060; \u00a7 427.010", "authority_level": "hard_rule"}'::jsonb, 'error', 'needs_review', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config   = EXCLUDED.validator_config,
    review_status      = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at         = NOW();
