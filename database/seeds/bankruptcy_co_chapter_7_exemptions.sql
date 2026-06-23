
-- Bankruptcy chapter_7_exemptions rule for CO
-- Generated: 2026-03-06T04:28:03.050502+00:00

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'CO-BANKRUPTCY-CHAPTER-7-EXEMPTIONS', 5, 'CO Bankruptcy - Chapter 7 Exemptions', 'content_check', 'bankruptcy',
    'chapter_7_exemptions', 'general', 'state', 'CO',
    '{"opt_out_of_federal_exemptions": true, "homestead_exemption_usd": 250000, "vehicle_exemption_usd": 7500, "wildcard_exemption_usd": 0, "statutory_citation": "C.R.S. \u00a7 38-41-201; \u00a7 13-54-102 (no wildcard)", "authority_level": "hard_rule"}'::jsonb, 'error', 'needs_review', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config   = EXCLUDED.validator_config,
    review_status      = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at         = NOW();
