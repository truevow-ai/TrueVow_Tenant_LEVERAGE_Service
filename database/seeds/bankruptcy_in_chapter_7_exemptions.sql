
-- Bankruptcy chapter_7_exemptions rule for IN
-- Generated: 2026-03-06T04:28:03.323845+00:00

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'IN-BANKRUPTCY-CHAPTER-7-EXEMPTIONS', 5, 'IN Bankruptcy - Chapter 7 Exemptions', 'content_check', 'bankruptcy',
    'chapter_7_exemptions', 'general', 'state', 'IN',
    '{"opt_out_of_federal_exemptions": true, "homestead_exemption_usd": 19300, "vehicle_exemption_usd": 10250, "wildcard_exemption_usd": 0, "statutory_citation": "Ind. Code \u00a7 34-55-10-2 (no wildcard \u2014 combined real/personal $19,300)", "authority_level": "hard_rule"}'::jsonb, 'error', 'needs_review', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config   = EXCLUDED.validator_config,
    review_status      = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at         = NOW();
