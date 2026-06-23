
-- Bankruptcy chapter_7_exemptions rule for CA
-- Generated: 2026-03-06T04:28:02.946598+00:00

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'CA-BANKRUPTCY-CHAPTER-7-EXEMPTIONS', 5, 'CA Bankruptcy - Chapter 7 Exemptions', 'content_check', 'bankruptcy',
    'chapter_7_exemptions', 'general', 'state', 'CA',
    '{"opt_out_of_federal_exemptions": false, "homestead_exemption_usd": 626400, "vehicle_exemption_usd": 3625, "wildcard_exemption_usd": 1550, "statutory_citation": "Cal. Civ. Proc. Code \u00a7 704.730 (System 1); \u00a7 704.040; \u00a7 703.140(b)(5) (System 2 wildcard)", "authority_level": "hard_rule"}'::jsonb, 'error', 'needs_review', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config   = EXCLUDED.validator_config,
    review_status      = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at         = NOW();
