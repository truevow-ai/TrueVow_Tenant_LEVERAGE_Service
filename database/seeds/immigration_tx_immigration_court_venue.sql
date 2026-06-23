
-- Immigration immigration_court_venue rule for TX
-- Generated: 2026-03-05T03:46:13.295183+00:00

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'TX-IMMIGRATION-IMMIGRATION-COURT-VENUE', 5, 'TX Immigration - Immigration Court Venue', 'content_check', 'immigration',
    'immigration_court_venue', 'general', 'state', 'TX',
    '{"court_city": "Houston", "court_jurisdiction_notes": "Texas cases heard at Houston, Dallas, San Antonio, or Harlingen IJ", "statutory_citation": "8 C.F.R. \u00a7 1003.14; Houston IJ, 126 Northpoint Dr., Houston TX 77060", "authority_level": "hard_rule"}'::jsonb, 'error', 'needs_review', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config   = EXCLUDED.validator_config,
    review_status      = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at         = NOW();
