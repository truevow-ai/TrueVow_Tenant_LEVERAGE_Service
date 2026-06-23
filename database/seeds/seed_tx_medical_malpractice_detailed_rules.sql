-- MEDICAL_MALPRACTICE_DETAILED RULE - Texas (TX)
-- Authority: Tex. Civ. Prac. & Rem. Code § 74.251; § 74.301

INSERT INTO leverage.legal_sources (
    jurisdiction_type, jurisdiction_state, jurisdiction_county, jurisdiction_court,
    name, publisher, abbreviation, base_url, source_type, trust_level, notes
) VALUES (
    'state', 'TX', NULL, NULL,
    'Texas Texas Medical Malpractice Discovery Rule With Cap',
    'Texas Legislature',
    'Tex. Civ. Prac. & Rem. Code § 74.251; § 74.301', '', 'statute', 'high',
    'Texas Texas medical malpractice follows discovery rule with cap. Authority: Tex. Civ. Prac. & Rem. Code § 74.251; § 74.301. NEEDS REVIEW.'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type)
DO UPDATE SET notes = EXCLUDED.notes, abbreviation = EXCLUDED.abbreviation;

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type, practice_area,
    specialization, document_type, jurisdiction_scope, jurisdiction_state,
    jurisdiction_county, jurisdiction_court, validator_config, severity,
    citation_id, review_status, is_active, is_template, tenant_id, created_at, updated_at
) VALUES (
    'TX-MED-MAL-DISCOVERY-RULE-WITH-CAP', 5, 'Texas Medical Malpractice Discovery Rule With Cap', 'content_check', 'personal_injury',
    'medical_malpractice_detailed', 'complaint', 'state', 'TX', NULL, NULL,
    '{"discovery_rule_type": "discovery_rule_with_cap", "statute": "Tex. Civ. Prac. & Rem. Code § 74.251; § 74.301"}'::jsonb,
    'error', NULL, 'needs_review', true, true, NULL, NOW(), NOW()
) ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    specialization = EXCLUDED.specialization,
    review_status = CASE WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified' ELSE EXCLUDED.review_status END,
    updated_at = NOW();
