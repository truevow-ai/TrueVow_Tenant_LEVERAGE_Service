-- WRONGFUL_DEATH RULE - Missouri (MO)
-- Authority: Mo. Rev. Stat. § 537.100

INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
) VALUES (
    'state', 'MO', NULL, NULL,
    'Missouri Missouri Wrongful Death SOL (3 years)',
    'Missouri Legislature',
    'Mo. Rev. Stat. § 537.100', '', 'statute', 'high',
    'Missouri Missouri wrongful death statute of limitations is 3 years from date of death. Authority: Mo. Rev. Stat. § 537.100. NEEDS REVIEW.'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type)
DO UPDATE SET notes = EXCLUDED.notes, abbreviation = EXCLUDED.abbreviation;

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    jurisdiction_county, jurisdiction_court, validator_config, severity,
    citation_id, review_status, is_active, is_template, tenant_id, created_at, updated_at
) VALUES (
    'MO-WRONGFUL-DEATH-SOL-3Y', 5, 'Missouri Wrongful Death SOL (3 years)', 'content_check', 'personal_injury',
    'wrongful_death', 'complaint', 'state', 'MO', NULL, NULL,
    '{"sol_years": "3", "statute": "Mo. Rev. Stat. § 537.100"}'::jsonb,
    'error', NULL, 'needs_review', true, true, NULL, NOW(), NOW()
) ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    specialization = EXCLUDED.specialization,
    review_status = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at = NOW();
