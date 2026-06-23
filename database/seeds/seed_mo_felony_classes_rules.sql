-- Criminal Defense Felony Classes Rules for Missouri
-- Generated: 2026-03-04T10:51:01.548186+00:00

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'MO-CRIMINAL-FELONY-CLASSIFICATION', 5, 'Missouri Felony Classification', 'content_check', 'criminal_defense',
    'felony_classes', 'motion', 'state', 'MO',
    '{"classification_system": "class_a_b_c_d", "statute": "V.A.M.S. \u00a7 556.016", "authority_level": "hard_rule"}'::jsonb, 'error', 'needs_review', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    review_status = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at = NOW();
