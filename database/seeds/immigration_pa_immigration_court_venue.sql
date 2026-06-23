
-- Immigration immigration_court_venue rule for PA
-- Generated: 2026-03-05T03:46:13.071298+00:00

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'PA-IMMIGRATION-IMMIGRATION-COURT-VENUE', 5, 'PA Immigration - Immigration Court Venue', 'content_check', 'immigration',
    'immigration_court_venue', 'general', 'state', 'PA',
    '{"court_city": "Philadelphia", "court_jurisdiction_notes": "Pennsylvania cases heard at Philadelphia Immigration Court", "statutory_citation": "8 C.F.R. \u00a7 1003.14; Philadelphia IJ, 1600 Callowhill St., Philadelphia PA 19130", "authority_level": "hard_rule"}'::jsonb, 'error', 'needs_review', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config   = EXCLUDED.validator_config,
    review_status      = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at         = NOW();
