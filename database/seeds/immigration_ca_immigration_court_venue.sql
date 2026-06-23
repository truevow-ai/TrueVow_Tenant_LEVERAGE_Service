
-- Immigration immigration_court_venue rule for CA
-- Generated: 2026-03-05T03:46:08.371725+00:00

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'CA-IMMIGRATION-IMMIGRATION-COURT-VENUE', 5, 'CA Immigration - Immigration Court Venue', 'content_check', 'immigration',
    'immigration_court_venue', 'general', 'state', 'CA',
    '{"court_city": "Los Angeles", "court_jurisdiction_notes": "California cases heard at LA, SF, San Diego, or Sacramento IJ", "statutory_citation": "8 C.F.R. \u00a7 1003.14; LA IJ, 606 S. Olive St., Los Angeles CA 90014", "authority_level": "hard_rule"}'::jsonb, 'error', 'needs_review', true, false, NOW(), NOW()
)
ON CONFLICT (rule_name) DO UPDATE SET
    validator_config   = EXCLUDED.validator_config,
    review_status      = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at         = NOW();
