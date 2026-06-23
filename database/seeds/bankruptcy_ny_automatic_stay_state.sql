
-- Bankruptcy automatic_stay_state rule for NY
-- Generated: 2026-03-06T04:28:03.818300+00:00

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'NY-BANKRUPTCY-AUTOMATIC-STAY-STATE', 5, 'NY Bankruptcy - Automatic Stay State', 'content_check', 'bankruptcy',
    'automatic_stay_state', 'general', 'state', 'NY',
    '{"utility_shutoff_stay_days": 30, "eviction_stay_applies": true, "state_stay_statute": "NY Pub. Serv. Law \u00a7 32(1)", "statutory_citation": "11 U.S.C. \u00a7 362(a); NY Pub. Serv. Law \u00a7 32(1) (30-day utility protection)", "authority_level": "hard_rule"}'::jsonb, 'error', 'needs_review', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config   = EXCLUDED.validator_config,
    review_status      = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at         = NOW();
