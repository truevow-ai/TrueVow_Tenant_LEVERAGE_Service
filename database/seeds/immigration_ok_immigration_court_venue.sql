
-- Immigration immigration_court_venue rule for OK
-- Generated: 2026-03-05T03:46:12.752497+00:00

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'OK-IMMIGRATION-IMMIGRATION-COURT-VENUE', 5, 'OK Immigration - Immigration Court Venue', 'content_check', 'immigration',
    'immigration_court_venue', 'general', 'state', 'OK',
    '{"court_city": "Dallas", "court_jurisdiction_notes": "Oklahoma cases heard at Dallas Immigration Court", "statutory_citation": "8 C.F.R. \u00a7 1003.14; Dallas IJ, 1100 Commerce St., Dallas TX 75242", "authority_level": "hard_rule"}'::jsonb, 'error', 'needs_review', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config   = EXCLUDED.validator_config,
    review_status      = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at         = NOW();
