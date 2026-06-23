
-- Bankruptcy automatic_stay_state rule for CT
-- Generated: 2026-03-06T04:28:03.076751+00:00

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'CT-BANKRUPTCY-AUTOMATIC-STAY-STATE', 5, 'CT Bankruptcy - Automatic Stay State', 'content_check', 'bankruptcy',
    'automatic_stay_state', 'general', 'state', 'CT',
    '{"utility_shutoff_stay_days": 20, "eviction_stay_applies": true, "state_stay_statute": "No state-specific extension", "statutory_citation": "11 U.S.C. \u00a7 362(a); \u00a7 366 (federal only)", "authority_level": "hard_rule"}'::jsonb, 'error', 'needs_review', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config   = EXCLUDED.validator_config,
    review_status      = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at         = NOW();
