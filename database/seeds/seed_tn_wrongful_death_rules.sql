-- WRONGFUL_DEATH RULE - Tennessee (TN)
-- Authority: Tenn. Code Ann. § 20-5-113

INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
) VALUES (
    'state', 'TN', NULL, NULL,
    'Tennessee Tennessee Wrongful Death SOL (1 years)',
    'Tennessee Legislature',
    'Tenn. Code Ann. § 20-5-113', '', 'statute', 'high',
    'Tennessee Tennessee wrongful death statute of limitations is 1 years from date of death. Authority: Tenn. Code Ann. § 20-5-113. NEEDS REVIEW.'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type)
DO UPDATE SET notes = EXCLUDED.notes, abbreviation = EXCLUDED.abbreviation;

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    jurisdiction_county, jurisdiction_court, validator_config, severity,
    citation_id, review_status, is_active, is_template, tenant_id, created_at, updated_at
) VALUES (
    'TN-WRONGFUL-DEATH-SOL-1Y', 5, 'Tennessee Wrongful Death SOL (1 years)', 'content_check', 'personal_injury',
    'wrongful_death', 'complaint', 'state', 'TN', NULL, NULL,
    '{"sol_years": "1", "statute": "Tenn. Code Ann. § 20-5-113"}'::jsonb,
    'error', NULL, 'needs_review', true, true, NULL, NOW(), NOW()
) ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    specialization = EXCLUDED.specialization,
    review_status = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at = NOW();
