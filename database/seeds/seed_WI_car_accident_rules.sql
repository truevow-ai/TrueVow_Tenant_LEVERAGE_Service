-- =====================================================================================
-- CAR ACCIDENT NEGLIGENCE RULES SEED FILE
-- =====================================================================================
-- State: Wisconsin (WI)
-- Sub-Specialization: Car Accident (Personal Injury)
-- Negligence System: Modified Comparative Negligence (51% Bar Rule)
-- Primary Authority: Wis. Stat. § 895.045
-- 
-- VERIFICATION STATUS: NEEDS_REVIEW (AI-Generated, Pending Attorney Review)
-- Research Date: March 2, 2026
-- Protocol v3: Deterministic verification against authoritative negligence table
-- =====================================================================================

-- =====================================================================================
-- PART 1: LEGAL SOURCES
-- =====================================================================================

-- Source: Wisconsin Negligence System for Auto Accidents
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
    'WI',
    NULL,
    NULL,
    'Wisconsin Car Accident Negligence System - Modified Comparative Negligence (51% Bar Rule)',
    'Wisconsin Legislature',
    'Wis. Stat. § 895.045',
    '',
    'statute',
    'high',
    'Wisconsin follows the Modified Comparative Negligence (51% Bar Rule) system for determining fault in car accident cases. Citation: Wis. Stat. § 895.045. NEEDS REVIEW.'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type)
DO UPDATE SET
    notes = EXCLUDED.notes,
    abbreviation = EXCLUDED.abbreviation;

-- =====================================================================================
-- PART 2: VALIDATION RULES
-- =====================================================================================

-- Rule: Wisconsin Car Accident Negligence System
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
    'WI-PI-CAR-ACCDT-MOD-COMP-51',
    5,
    'WI Car Accident Modified Comparative Negligence (51% Bar Rule)',
    'content_check',
    'personal_injury',
    'car_accident',
    'complaint',
    'state',
    'WI',
    NULL,
    NULL,
    '{
        "negligence_system": "modified_comparative_51",
        "statute": "Wis. Stat. § 895.045",
        "system_description": "Modified Comparative Negligence (51% Bar Rule)",
        "key_requirements": [
            "Plaintiff can recover only if plaintiff''s fault is 50% or less (i.e., less than defendant''s)",
                "If plaintiff is 51% or more at fault, plaintiff is completely barred from recovery",
                "Plaintiff must be less than 51% at fault to recover",
                "Damages reduced by plaintiff''s percentage of fault",
                "Jury must allocate fault; plaintiff barred if at or above 51% fault"
        ],
        "defenses": [
            "Plaintiff''s comparative fault at 51% or more (complete bar)",
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
-- END OF WISCONSIN CAR ACCIDENT RULES SEED FILE
-- =====================================================================================
