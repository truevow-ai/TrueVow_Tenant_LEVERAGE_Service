
-- Immigration immigration_court_venue rule for NC
-- Generated: 2026-03-05T03:46:10.578781+00:00

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'NC-IMMIGRATION-IMMIGRATION-COURT-VENUE', 5, 'NC Immigration - Immigration Court Venue', 'content_check', 'immigration',
    'immigration_court_venue', 'general', 'state', 'NC',
    '{"court_city": "Charlotte", "court_jurisdiction_notes": "North Carolina cases heard at Charlotte Immigration Court", "statutory_citation": "8 C.F.R. \u00a7 1003.14; Charlotte IJ, 5701 Executive Ctr. Dr., Charlotte NC 28212", "authority_level": "hard_rule"}'::jsonb, 'error', 'needs_review', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config   = EXCLUDED.validator_config,
    review_status      = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at         = NOW();
