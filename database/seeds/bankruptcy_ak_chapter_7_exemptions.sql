
-- Bankruptcy chapter_7_exemptions rule for AK
-- Generated: 2026-03-06T04:28:02.810513+00:00

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'AK-BANKRUPTCY-CHAPTER-7-EXEMPTIONS', 5, 'AK Bankruptcy - Chapter 7 Exemptions', 'content_check', 'bankruptcy',
    'chapter_7_exemptions', 'general', 'state', 'AK',
    '{"opt_out_of_federal_exemptions": false, "homestead_exemption_usd": 72900, "vehicle_exemption_usd": 3750, "wildcard_exemption_usd": 1348, "statutory_citation": "Alaska Stat. \u00a7 09.38.010; \u00a7 09.38.020; \u00a7 09.38.030", "authority_level": "hard_rule"}'::jsonb, 'error', 'needs_review', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config   = EXCLUDED.validator_config,
    review_status      = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at         = NOW();
