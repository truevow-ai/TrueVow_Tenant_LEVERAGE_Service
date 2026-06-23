-- Family Law Child Support Rules for New York
-- Generated: 2026-03-04T09:45:06.040285+00:00

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
    'NY-FAMILY-SUPPORT-GUIDELINE',
    5,
    'New York Child Support Guidelines',
    'content_check',
    'family_law',
    'child_support',
    'petition',
    'state',
    'NY',
    '{"guideline_model": "income_shares", "statute": "Dom. Rel. Law \u00a7 240", "authority_level": "hard_rule"}'::jsonb,
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
