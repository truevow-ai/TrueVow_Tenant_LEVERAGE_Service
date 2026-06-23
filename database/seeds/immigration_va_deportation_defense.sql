
-- Immigration deportation_defense rule for VA
-- Generated: 2026-03-05T03:46:13.352845+00:00

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'VA-IMMIGRATION-DEPORTATION-DEFENSE', 5, 'VA Immigration - Deportation Defense', 'content_check', 'immigration',
    'deportation_defense', 'general', 'state', 'VA',
    '{"sanctuary_policy_type": "full_sanctuary_law", "ice_detainer_compliance": false, "statutory_citation": "Va. Code \u00a7 9.1-214 (HB 1547, 2021)", "authority_level": "hard_rule"}'::jsonb, 'error', 'needs_review', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config   = EXCLUDED.validator_config,
    review_status      = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at         = NOW();
