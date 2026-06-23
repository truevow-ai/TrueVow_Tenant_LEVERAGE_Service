-- WORKERS_COMPENSATION RULE - Ohio (OH)
-- Authority: ORC § 4123.74

INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
) VALUES (
    'state', 'OH', NULL, NULL,
    'Ohio Ohio Workers'' Compensation Exclusive Remedy',
    'Ohio Legislature',
    'ORC § 4123.74', '', 'statute', 'high',
    'Ohio Ohio workers'' compensation is the exclusive remedy for workplace injuries. Authority: ORC § 4123.74. NEEDS REVIEW.'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type)
DO UPDATE SET notes = EXCLUDED.notes, abbreviation = EXCLUDED.abbreviation;

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    jurisdiction_county, jurisdiction_court, validator_config, severity,
    citation_id, review_status, is_active, is_template, tenant_id, created_at, updated_at
) VALUES (
    'OH-WORKERS-COMP-EXCLUSIVE-REMEDY', 5, 'Ohio Workers'' Compensation Exclusive Remedy', 'content_check', 'personal_injury',
    'workers_compensation', 'complaint', 'state', 'OH', NULL, NULL,
    '{"remedy_type": "exclusive_remedy", "statute": "ORC § 4123.74"}'::jsonb,
    'error', NULL, 'needs_review', true, true, NULL, NOW(), NOW()
) ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    specialization = EXCLUDED.specialization,
    review_status = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at = NOW();
