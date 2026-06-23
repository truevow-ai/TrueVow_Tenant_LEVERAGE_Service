-- Criminal Defense Felony Classes Rules for New Mexico
-- Generated: 2026-03-04T10:51:01.616601+00:00

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'NM-CRIMINAL-FELONY-CLASSIFICATION', 5, 'New Mexico Felony Classification', 'content_check', 'criminal_defense',
    'felony_classes', 'motion', 'state', 'NM',
    '{"classification_system": "capital_first_second_third_fourth", "statute": "NMSA 1978, \u00a7 31-18-15", "authority_level": "hard_rule"}'::jsonb, 'error', 'needs_review', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    review_status = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at = NOW();
