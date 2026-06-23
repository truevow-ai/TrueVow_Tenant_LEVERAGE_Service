
-- Bankruptcy chapter_7_exemptions rule for AR
-- Generated: 2026-03-06T04:28:02.931366+00:00

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'AR-BANKRUPTCY-CHAPTER-7-EXEMPTIONS', 5, 'AR Bankruptcy - Chapter 7 Exemptions', 'content_check', 'bankruptcy',
    'chapter_7_exemptions', 'general', 'state', 'AR',
    '{"opt_out_of_federal_exemptions": true, "homestead_exemption_usd": null, "vehicle_exemption_usd": 1200, "wildcard_exemption_usd": 500, "statutory_citation": "Ark. Const. Art. 9, \u00a7\u00a7 3-6 (unlimited homestead for rural); Ark. Code Ann. \u00a7 16-66-218", "authority_level": "hard_rule"}'::jsonb, 'error', 'needs_review', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config   = EXCLUDED.validator_config,
    review_status      = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at         = NOW();
