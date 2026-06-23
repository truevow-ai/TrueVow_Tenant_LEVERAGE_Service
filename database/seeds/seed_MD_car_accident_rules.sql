-- =====================================================================================
-- CAR ACCIDENT NEGLIGENCE RULES SEED FILE
-- =====================================================================================
-- State: Maryland (MD)
-- Sub-Specialization: Car Accident (Personal Injury)
-- Negligence System: Contributory Negligence
-- Primary Authority: Maryland common law
-- 
-- VERIFICATION STATUS: NEEDS_REVIEW (AI-Generated, Pending Attorney Review)
-- Research Date: March 2, 2026
-- Protocol v3: Deterministic verification against authoritative negligence table
-- =====================================================================================

-- =====================================================================================
-- PART 1: LEGAL SOURCES
-- =====================================================================================

-- Source: Maryland Negligence System for Auto Accidents
INSERT INTO leverage.legal_sources (
    jurisdiction_type,
    jurisdiction_state,
    jurisdiction_county,
    jurisdiction_court,
    name,
    publisher,
    abbreviation,
    base_url,
    source_type,
    trust_level,
    notes
) VALUES (
    'state',
    'MD',
    NULL,
    NULL,
    'Maryland Car Accident Negligence System - Contributory Negligence',
    'Maryland Legislature',
    'Maryland common law',
    '',
    'statute',
    'high',
    'Maryland follows the Contributory Negligence system for determining fault in car accident cases. Citation: Maryland common law. NEEDS REVIEW.'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type)
DO UPDATE SET
    notes = EXCLUDED.notes,
    abbreviation = EXCLUDED.abbreviation;

-- =====================================================================================
-- PART 2: VALIDATION RULES
-- =====================================================================================

-- Rule: Maryland Car Accident Negligence System
INSERT INTO leverage.validation_rules (
    rule_name,
    validator_level,
    validator_name,
    validator_type,
    practice_area,
    specialization,
    document_type,
    jurisdiction_scope,
    jurisdiction_state,
    jurisdiction_county,
    jurisdiction_court,
    validator_config,
    severity,
    citation_id,
    review_status,
    is_active,
    is_template,
    tenant_id,
    created_at,
    updated_at
) VALUES (
    'MD-PI-CAR-ACCDT-CONTRIBUTORY',
    5,
    'MD Car Accident Contributory Negligence',
    'content_check',
    'personal_injury',
    'car_accident',
    'complaint',
    'state',
    'MD',
    NULL,
    NULL,
    '{
        "negligence_system": "contributory",
        "statute": "Maryland common law",
        "system_description": "Contributory Negligence",
        "key_requirements": [
            "If plaintiff contributed ANY negligence to the accident, plaintiff is completely barred from recovery",
                "Even 1% fault by plaintiff bars all recovery",
                "Pure contributory negligence is one of the harshest standards in tort law",
                "Last clear chance doctrine may provide exception in some states",
                "Plaintiff must prove defendant''s negligence was the sole proximate cause"
        ],
        "defenses": [
            "Plaintiff''s any contributory negligence (complete bar)",
                "Assumption of risk",
                "Last clear chance (plaintiff counterargument)",
                "Intervening/superseding cause",
                "Plaintiff violated traffic laws"
        ],
        "burden_of_proof": "Plaintiff must prove defendant''s negligence proximately caused damages",
        "damages": "Economic (medical bills, lost wages, property damage) + Non-economic (pain and suffering) + Punitive (in egregious cases)"
    }'::jsonb,
    'error',
    NULL,
    'needs_review',
    true,
    true,
    NULL,
    NOW(),
    NOW()
) ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    specialization = EXCLUDED.specialization,
    review_status = CASE
        WHEN leverage.validation_rules.review_status = 'document_verified' THEN 'document_verified'
        ELSE EXCLUDED.review_status
    END,
    updated_at = NOW();

-- =====================================================================================
-- END OF MARYLAND CAR ACCIDENT RULES SEED FILE
-- =====================================================================================
