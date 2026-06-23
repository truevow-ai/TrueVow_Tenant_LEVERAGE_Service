-- MEDICAL_MALPRACTICE_DETAILED RULE - North Dakota (ND)
-- Authority: N.D.C.C. § 28-01-18

INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
) VALUES (
    'state', 'ND', NULL, NULL,
    'North Dakota North Dakota Medical Malpractice Discovery Rule',
    'North Dakota Legislature',
    'N.D.C.C. § 28-01-18', '', 'statute', 'high',
    'North Dakota North Dakota medical malpractice follows discovery rule. Authority: N.D.C.C. § 28-01-18. NEEDS REVIEW.'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type)
DO UPDATE SET notes = EXCLUDED.notes, abbreviation = EXCLUDED.abbreviation;

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    jurisdiction_county, jurisdiction_court, validator_config, severity,
    citation_id, review_status, is_active, is_template, tenant_id, created_at, updated_at
) VALUES (
    'ND-MED-MAL-DISCOVERY-RULE', 5, 'North Dakota Medical Malpractice Discovery Rule', 'content_check', 'personal_injury',
    'medical_malpractice_detailed', 'complaint', 'state', 'ND', NULL, NULL,
    '{"discovery_rule_type": "discovery_rule", "statute": "N.D.C.C. § 28-01-18"}'::jsonb,
    'error', NULL, 'needs_review', true, true, NULL, NOW(), NOW()
) ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    specialization = EXCLUDED.specialization,
    review_status = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at = NOW();
