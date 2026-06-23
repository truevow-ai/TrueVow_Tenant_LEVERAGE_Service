
-- Immigration deportation_defense rule for NH
-- Generated: 2026-03-05T03:46:12.204167+00:00

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'NH-IMMIGRATION-DEPORTATION-DEFENSE', 5, 'NH Immigration - Deportation Defense', 'content_check', 'immigration',
    'deportation_defense', 'general', 'state', 'NH',
    '{"sanctuary_policy_type": "limited_cooperation", "ice_detainer_compliance": false, "statutory_citation": "RSA 106-L:5 (No statewide detainer mandate)", "authority_level": "hard_rule"}'::jsonb, 'error', 'needs_review', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config   = EXCLUDED.validator_config,
    review_status      = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at         = NOW();
