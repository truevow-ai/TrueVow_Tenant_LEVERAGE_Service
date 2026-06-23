
-- Bankruptcy chapter_7_exemptions rule for KS
-- Generated: 2026-03-06T04:28:03.335359+00:00

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'KS-BANKRUPTCY-CHAPTER-7-EXEMPTIONS', 5, 'KS Bankruptcy - Chapter 7 Exemptions', 'content_check', 'bankruptcy',
    'chapter_7_exemptions', 'general', 'state', 'KS',
    '{"opt_out_of_federal_exemptions": true, "homestead_exemption_usd": null, "vehicle_exemption_usd": 20000, "wildcard_exemption_usd": 0, "statutory_citation": "K.S.A. \u00a7 60-2301 (unlimited homestead); \u00a7 60-2304 (no wildcard)", "authority_level": "hard_rule"}'::jsonb, 'error', 'needs_review', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config   = EXCLUDED.validator_config,
    review_status      = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at         = NOW();
