-- Criminal Defense Speedy Trial Rules for Vermont
-- Generated: 2026-03-04T10:51:02.378000+00:00

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'VT-CRIMINAL-SPEEDY-TRIAL', 5, 'Vermont Speedy Trial Right', 'content_check', 'criminal_defense',
    'speedy_trial', 'motion', 'state', 'VT',
    '{"speedy_trial_days": 90, "statute": "Vt. R. Crim. P. 48", "authority_level": "hard_rule"}'::jsonb, 'error', 'needs_review', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    review_status = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at = NOW();
