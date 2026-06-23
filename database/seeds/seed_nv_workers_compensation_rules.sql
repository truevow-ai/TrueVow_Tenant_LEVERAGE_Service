-- WORKERS_COMPENSATION RULE - Nevada (NV)
-- Authority: NRS § 616A.010

INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
) VALUES (
    'state', 'NV', NULL, NULL,
    'Nevada Nevada Workers'' Compensation Exclusive Remedy',
    'Nevada Legislature',
    'NRS § 616A.010', '', 'statute', 'high',
    'Nevada Nevada workers'' compensation is the exclusive remedy for workplace injuries. Authority: NRS § 616A.010. NEEDS REVIEW.'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type)
DO UPDATE SET notes = EXCLUDED.notes, abbreviation = EXCLUDED.abbreviation;

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    jurisdiction_county, jurisdiction_court, validator_config, severity,
    citation_id, review_status, is_active, is_template, tenant_id, created_at, updated_at
) VALUES (
    'NV-WORKERS-COMP-EXCLUSIVE-REMEDY', 5, 'Nevada Workers'' Compensation Exclusive Remedy', 'content_check', 'personal_injury',
    'workers_compensation', 'complaint', 'state', 'NV', NULL, NULL,
    '{"remedy_type": "exclusive_remedy", "statute": "NRS § 616A.010"}'::jsonb,
    'error', NULL, 'needs_review', true, true, NULL, NOW(), NOW()
) ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    specialization = EXCLUDED.specialization,
    review_status = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at = NOW();
