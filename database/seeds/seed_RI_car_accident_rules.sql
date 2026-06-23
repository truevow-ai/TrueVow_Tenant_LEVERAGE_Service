-- =====================================================================================
-- CAR ACCIDENT NEGLIGENCE RULES SEED FILE
-- =====================================================================================
-- State: Rhode Island (RI)
-- Sub-Specialization: Car Accident (Personal Injury)
-- Negligence System: Pure Comparative Negligence
-- Primary Authority: Gen. Laws § 9-20-0.1
-- 
-- VERIFICATION STATUS: NEEDS_REVIEW (AI-Generated, Pending Attorney Review)
-- Research Date: March 2, 2026
-- Protocol v3: Deterministic verification against authoritative negligence table
-- =====================================================================================

-- =====================================================================================
-- PART 1: LEGAL SOURCES
-- =====================================================================================

-- Source: Rhode Island Negligence System for Auto Accidents
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
    'RI',
    NULL,
    NULL,
    'Rhode Island Car Accident Negligence System - Pure Comparative Negligence',
    'Rhode Island Legislature',
    'Gen. Laws § 9-20-0.1',
    '',
    'statute',
    'high',
    'Rhode Island follows the Pure Comparative Negligence system for determining fault in car accident cases. Citation: Gen. Laws § 9-20-0.1. NEEDS REVIEW.'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type)
DO UPDATE SET
    notes = EXCLUDED.notes,
    abbreviation = EXCLUDED.abbreviation;

-- =====================================================================================
-- PART 2: VALIDATION RULES
-- =====================================================================================

-- Rule: Rhode Island Car Accident Negligence System
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
    'RI-PI-CAR-ACCDT-PURE-COMP',
    5,
    'RI Car Accident Pure Comparative Negligence',
    'content_check',
    'personal_injury',
    'car_accident',
    'complaint',
    'state',
    'RI',
    NULL,
    NULL,
    '{
        "negligence_system": "pure_comparative",
        "statute": "Gen. Laws § 9-20-0.1",
        "system_description": "Pure Comparative Negligence",
        "key_requirements": [
            "Plaintiff can recover even if 99% at fault, but damages are reduced by plaintiff''s percentage of fault",
                "Damages are apportioned based on each party''s degree of fault",
                "No bar to recovery regardless of plaintiff''s percentage of fault",
                "Jury must allocate fault among all parties including plaintiff",
                "Net damages = total damages multiplied by (1 - plaintiff''s fault percentage)"
        ],
        "defenses": [
            "Plaintiff''s own negligence (reduces damages proportionally)",
                "Assumption of risk",
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
-- END OF RHODE ISLAND CAR ACCIDENT RULES SEED FILE
-- =====================================================================================
