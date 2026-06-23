
-- Bankruptcy chapter_7_exemptions rule for MT
-- Generated: 2026-03-06T04:28:03.678908+00:00

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'MT-BANKRUPTCY-CHAPTER-7-EXEMPTIONS', 5, 'MT Bankruptcy - Chapter 7 Exemptions', 'content_check', 'bankruptcy',
    'chapter_7_exemptions', 'general', 'state', 'MT',
    '{"opt_out_of_federal_exemptions": true, "homestead_exemption_usd": 350000, "vehicle_exemption_usd": 4000, "wildcard_exemption_usd": 800, "statutory_citation": "Mont. Code Ann. \u00a7 70-32-101; \u00a7 25-13-608", "authority_level": "hard_rule"}'::jsonb, 'error', 'needs_review', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config   = EXCLUDED.validator_config,
    review_status      = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at         = NOW();
