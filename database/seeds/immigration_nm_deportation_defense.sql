
-- Immigration deportation_defense rule for NM
-- Generated: 2026-03-05T03:46:12.370686+00:00

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'NM-IMMIGRATION-DEPORTATION-DEFENSE', 5, 'NM Immigration - Deportation Defense', 'content_check', 'immigration',
    'deportation_defense', 'general', 'state', 'NM',
    '{"sanctuary_policy_type": "full_sanctuary_law", "ice_detainer_compliance": false, "statutory_citation": "NMSA 1978, \u00a7 29-19-1 (New Mexico Immigrant''s Rights Act, SB 196 2023)", "authority_level": "hard_rule"}'::jsonb, 'error', 'needs_review', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config   = EXCLUDED.validator_config,
    review_status      = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at         = NOW();
