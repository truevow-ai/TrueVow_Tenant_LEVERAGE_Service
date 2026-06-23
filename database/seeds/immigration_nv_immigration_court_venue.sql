
-- Immigration immigration_court_venue rule for NV
-- Generated: 2026-03-05T03:46:12.700868+00:00

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'NV-IMMIGRATION-IMMIGRATION-COURT-VENUE', 5, 'NV Immigration - Immigration Court Venue', 'content_check', 'immigration',
    'immigration_court_venue', 'general', 'state', 'NV',
    '{"court_city": "Las Vegas", "court_jurisdiction_notes": "Nevada cases heard at Las Vegas or Reno Immigration Court", "statutory_citation": "8 C.F.R. \u00a7 1003.14; Las Vegas IJ, 3373 Pepper Lane, Las Vegas NV 89120", "authority_level": "hard_rule"}'::jsonb, 'error', 'needs_review', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config   = EXCLUDED.validator_config,
    review_status      = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at         = NOW();
