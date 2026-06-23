-- =====================================================================================
-- CAR ACCIDENT NEGLIGENCE RULES SEED FILE
-- =====================================================================================
-- State: Minnesota (MN)
-- Sub-Specialization: Car Accident (Personal Injury)
-- Negligence System: Modified Comparative Negligence (50% Bar Rule)
-- Primary Authority: Minn. Stat. § 604.01
-- 
-- VERIFICATION STATUS: NEEDS_REVIEW (AI-Generated, Pending Attorney Review)
-- Research Date: March 2, 2026
-- Protocol v3: Deterministic verification against authoritative negligence table
-- =====================================================================================

-- =====================================================================================
-- PART 1: LEGAL SOURCES
-- =====================================================================================

-- Source: Minnesota Negligence System for Auto Accidents
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
    'MN',
    NULL,
    NULL,
    'Minnesota Car Accident Negligence System - Modified Comparative Negligence (50% Bar Rule)',
    'Minnesota Legislature',
    'Minn. Stat. § 604.01',
    '',
    'statute',
    'high',
    'Minnesota follows the Modified Comparative Negligence (50% Bar Rule) system for determining fault in car accident cases. Citation: Minn. Stat. § 604.01. NEEDS REVIEW.'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type)
DO UPDATE SET
    notes = EXCLUDED.notes,
    abbreviation = EXCLUDED.abbreviation;

-- =====================================================================================
-- PART 2: VALIDATION RULES
-- =====================================================================================

-- Rule: Minnesota Car Accident Negligence System
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
    'MN-PI-CAR-ACCDT-MOD-COMP-50',
    5,
    'MN Car Accident Modified Comparative Negligence (50% Bar Rule)',
    'content_check',
    'personal_injury',
    'car_accident',
    'complaint',
    'state',
    'MN',
    NULL,
    NULL,
    '{
        "negligence_system": "modified_comparative_50",
        "statute": "Minn. Stat. § 604.01",
        "system_description": "Modified Comparative Negligence (50% Bar Rule)",
        "key_requirements": [
            "Plaintiff can recover only if plaintiff''s fault is 50% or less",
                "If plaintiff is MORE than 50% at fault, plaintiff is completely barred from recovery",
                "If plaintiff is exactly 50% at fault, plaintiff may still recover in most states",
                "Damages reduced by plaintiff''s percentage of fault",
                "Jury must allocate fault; plaintiff''s recovery is zero if fault exceeds 50%"
        ],
        "defenses": [
            "Plaintiff''s comparative fault exceeding 50% (complete bar)",
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
-- END OF MINNESOTA CAR ACCIDENT RULES SEED FILE
-- =====================================================================================
