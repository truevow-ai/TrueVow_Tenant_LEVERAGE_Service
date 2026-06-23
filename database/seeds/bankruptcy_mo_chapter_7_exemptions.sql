
-- Bankruptcy chapter_7_exemptions rule for MO
-- Generated: 2026-03-06T04:28:03.615061+00:00

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'MO-BANKRUPTCY-CHAPTER-7-EXEMPTIONS', 5, 'MO Bankruptcy - Chapter 7 Exemptions', 'content_check', 'bankruptcy',
    'chapter_7_exemptions', 'general', 'state', 'MO',
    '{"opt_out_of_federal_exemptions": true, "homestead_exemption_usd": 15000, "vehicle_exemption_usd": 3000, "wildcard_exemption_usd": 1250, "statutory_citation": "V.A.M.S. \u00a7 513.430; \u00a7 513.475", "authority_level": "hard_rule"}'::jsonb, 'error', 'needs_review', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config   = EXCLUDED.validator_config,
    review_status      = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at         = NOW();
