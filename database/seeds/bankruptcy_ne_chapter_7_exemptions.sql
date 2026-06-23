
-- Bankruptcy chapter_7_exemptions rule for NE
-- Generated: 2026-03-06T04:28:03.709871+00:00

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'NE-BANKRUPTCY-CHAPTER-7-EXEMPTIONS', 5, 'NE Bankruptcy - Chapter 7 Exemptions', 'content_check', 'bankruptcy',
    'chapter_7_exemptions', 'general', 'state', 'NE',
    '{"opt_out_of_federal_exemptions": true, "homestead_exemption_usd": 60000, "vehicle_exemption_usd": 3775, "wildcard_exemption_usd": 2500, "statutory_citation": "Neb. Rev. Stat. \u00a7 40-101; \u00a7 25-1552; \u00a7 25-1556", "authority_level": "hard_rule"}'::jsonb, 'error', 'needs_review', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config   = EXCLUDED.validator_config,
    review_status      = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at         = NOW();
