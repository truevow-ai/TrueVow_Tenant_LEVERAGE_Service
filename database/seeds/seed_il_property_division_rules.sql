-- Family Law Property Division Rules for Illinois
-- Generated: 2026-03-04T09:45:06.539479+00:00

INSERT INTO leverage.validation_rules (
    rule_name,
    validator_level,
    validator_name,
    validator_type,
    practice_area,
    specialization,
    document_type,
    jurisdiction_scope,
    jurisdiction_state,
    validator_config,
    severity,
    review_status,
    is_active,
    is_template,
    created_at,
    updated_at
) VALUES (
    'IL-FAMILY-PROPERTY-SYSTEM',
    5,
    'Illinois Property Division System',
    'content_check',
    'family_law',
    'property_division',
    'petition',
    'state',
    'IL',
    '{"division_system": "equitable_distribution", "statute": "750 ILCS 5/503", "authority_level": "hard_rule"}'::jsonb,
    'error',
    'needs_review',
    true,
    false,
    NOW(),
    NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    review_status = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at = NOW();
