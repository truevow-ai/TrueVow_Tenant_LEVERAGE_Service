
-- Estate Planning power_of_attorney rule for NC
-- Generated: 2026-03-05T01:57:39.697679+00:00

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'NC-ESTATE-PLANNING-POWER-OF-ATTORNEY', 5, 'NC Estate Planning - Power Of Attorney', 'content_check', 'estate_planning',
    'power_of_attorney', 'general', 'state', 'NC',
    '{"poa_act": "UPOAA", "requires_notarization": true, "statutory_citation": "N.C. Gen. Stat. \u00a7 32C-1-105", "authority_level": "hard_rule"}'::jsonb, 'error', 'needs_review', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config   = EXCLUDED.validator_config,
    review_status      = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at         = NOW();
