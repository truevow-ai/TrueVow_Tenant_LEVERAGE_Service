-- =====================================================================================
-- ALASKA SLIP & FALL / PREMISES LIABILITY RULES SEED FILE
-- =====================================================================================
-- State: Alaska (AK)
-- Practice Area: Personal Injury
-- Sub-Specialization: Slip & Fall / Premises Liability
-- Liability Model: COMMON LAW (General Duty of Reasonable Care - No Invitee/Licensee/Trespasser Distinctions)
-- Primary Authority: AS 09.17.080 (Comparative Negligence), AS 09.10.070 (SOL)
-- Statute of Limitations: 2 years (AS 09.10.070)
-- Comparative Negligence: PURE COMPARATIVE (can recover even if 99% at fault)
-- 
-- VERIFICATION STATUS: DOCUMENT VERIFIED
-- Research Date: January 31, 2026
-- Sources Verified:
--   1. AS 09.17.080 - Pure comparative negligence apportionment of damages
--   2. AS 09.10.070 - 2-year statute of limitations for torts/personal injury
--   3. Alaska abandons invitee/licensee/trespasser distinctions (general duty standard)
--   4. Pure comparative negligence rule verified from multiple Alaska legal sources
-- =====================================================================================

-- =====================================================================================
-- RULE 1: GENERAL DUTY OF REASONABLE CARE (ALL VISITORS)
-- =====================================================================================
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
    validator_config,
    severity,
    review_status,
    is_active,
    is_template,
    created_at,
    updated_at
) VALUES (
    'AK-SLIP-FALL-GENERAL-DUTY',
    5,
    'AK General Duty of Reasonable Care (All Visitors)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'AK',
    '{
        "sub_specialization_type": "premises_liability",
        "liability_model": "general_duty_reasonable_care",
        "authority_level": "contextual_rule",
        "unique_characteristic": "Alaska does NOT distinguish between invitees, licensees, and trespassers - applies single duty of reasonable care standard",
        "duty_of_care_standard": "uniform",
        "duty_description": "Property owner owes all lawful visitors a duty of reasonable care to maintain premises in safe condition, regardless of visitor classification",
        "uniform_standard": {
            "no_classifications": "Alaska does not follow traditional invitee/licensee/trespasser classifications",
            "single_duty": "All lawful visitors owed same duty of reasonable care",
            "focus": "Emphasis on property owners duty rather than visitors status",
            "rationale": "Alaska law prioritizes reasonableness and foreseeability over rigid visitor categories"
        },
        "property_owner_duties": {
            "reasonable_care": "Must exercise reasonable care to maintain premises in safe condition",
            "inspection": "Must conduct reasonable inspections for hazards",
            "remedy_hazards": "Must take reasonable steps to remedy known and discoverable hazards",
            "warn_of_dangers": "Must provide adequate warnings of non-obvious dangers",
            "foreseeability": "Duty extends to reasonably foreseeable risks of harm"
        },
        "key_elements_to_prove": [
            "Defendant owned, possessed, or controlled the property",
            "Defendant owed plaintiff a duty of reasonable care",
            "Defendant breached that duty (failed to exercise reasonable care)",
            "Dangerous condition existed on property",
            "Breach of duty was proximate cause of plaintiffs injury",
            "Plaintiff suffered damages"
        ],
        "notice_requirement": {
            "actual_notice": "Owner liable if had actual knowledge of dangerous condition",
            "constructive_notice": "Owner liable if should have known of condition through reasonable inspection",
            "foreseeability": "Focus on whether harm was reasonably foreseeable"
        },
        "defenses_available": [
            "No breach of duty of reasonable care",
            "No dangerous condition existed",
            "Condition was not reasonably foreseeable",
            "Comparative negligence (reduces recovery by plaintiffs fault percentage)",
            "Open and obvious danger",
            "Assumption of risk"
        ],
        "verification": {
            "doctrine_verified": true,
            "multiple_sources": [
                "Farnsworth & Vance Personal Injury Lawyers - Alaska Premises Liability",
                "Johnson Law, P.C. - Proving Fault in Premises Liability",
                "Alaska Injury Claims - Premise Liability Overview",
                "907 Attorney Jason Skala - Slip and Fall Accidents",
                "Nicholson v. MGM Corp., 555 P.2d 39 (Alaska 1976) - Invitee duty case law"
            ],
            "current_as_of": "2024-2026",
            "source_type": "common_law",
            "last_verified": "2026-01-31",
            "verified_by": "DRAFT_research_agent",
            "confidence": "high"
        }
    }'::jsonb,
    'error',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
) ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    validator_name = EXCLUDED.validator_name,
    severity = EXCLUDED.severity,
    review_status = EXCLUDED.review_status,
    updated_at = NOW();

-- =====================================================================================
-- RULE 2: PURE COMPARATIVE NEGLIGENCE - AS 09.17.080
-- =====================================================================================
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
    validator_config,
    severity,
    review_status,
    is_active,
    is_template,
    created_at,
    updated_at
) VALUES (
    'AK-SLIP-FALL-PURE-COMPARATIVE',
    5,
    'AK Pure Comparative Negligence (AS 09.17.080)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'AK',
    '{
        "sub_specialization_type": "premises_liability",
        "authority_level": "contextual_rule",
        "statute": "AS 09.17.080",
        "enactment_date": "Verified as active 2024-2026",
        "current_status": "Active as of 2024-2026",
        "not_repealed": true,
        "rule_type": "pure_comparative_negligence",
        "negligence_model": "pure_comparative",
        "rule_description": "Alaska follows pure comparative negligence: plaintiff can recover even if 99% at fault, with recovery reduced by percentage of fault",
        "pure_comparative_rule": {
            "recovery_allowed": "Plaintiff can recover damages even if predominantly at fault",
            "fault_threshold": "No threshold - recovery allowed up to 99% plaintiff fault",
            "reduction_calculation": "Recovery reduced by plaintiffs percentage of fault",
            "example": "If plaintiff 70% at fault and damages are $100,000, plaintiff recovers $30,000 (30% of damages)"
        },
        "apportionment_process": {
            "jury_determination": "Jury (or court if no jury) determines total damages and percentage of fault for each party",
            "several_liability": "Each party liable only for their respective percentage of fault",
            "non_party_fault": "Fault can be assigned to non-parties for percentage calculation purposes",
            "no_joint_liability": "Liability is several, not joint - each party pays only their share"
        },
        "fault_assessment_factors": {
            "nature_of_conduct": "Court considers nature of each partys conduct",
            "causal_relationship": "Extent to which conduct relates causally to damages claimed",
            "comparative_responsibility": "All parties fault compared and apportioned"
        },
        "key_elements": [
            "Jury determines total damages without considering fault",
            "Jury allocates percentage of fault to each party (including plaintiff)",
            "Judgment entered reducing plaintiffs recovery by plaintiffs percentage of fault",
            "Each defendant liable only for their proportionate share"
        ],
        "strategic_considerations": [
            "Plaintiff can recover even if primarily at fault (unlike contributory negligence states)",
            "Defense will aggressively pursue comparative fault arguments to reduce damages",
            "Evidence preservation critical to minimize plaintiffs assigned fault percentage",
            "Expert testimony often crucial for fault apportionment",
            "Plaintiffs should document reasonable behavior to minimize fault allocation"
        ],
        "verification": {
            "statute_text_verified": true,
            "full_text_source": "https://www.touchngo.com/lglcntr/akstats/statutes/title09/chapter17/section080.htm",
            "multiple_sources": [
                "Alaska Statutes AS 09.17.080",
                "Crowson Law - Alaska Comparative Negligence Calculator",
                "Crowson Law Wasilla - Comparative Negligence in Car Claims",
                "907 Attorney - Understanding Right to Compensation",
                "Eric Derleth Trial Guy - Comparative Negligence Overview"
            ],
            "current_as_of": "2024-2026",
            "not_repealed": true,
            "source_type": "primary_law",
            "last_verified": "2026-01-31",
            "verified_by": "DRAFT_research_agent",
            "confidence": "high"
        }
    }'::jsonb,
    'error',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
) ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    validator_name = EXCLUDED.validator_name,
    severity = EXCLUDED.severity,
    review_status = EXCLUDED.review_status,
    updated_at = NOW();

-- =====================================================================================
-- RULE 3: STATUTE OF LIMITATIONS - 2 YEARS (AS 09.10.070)
-- =====================================================================================
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
    validator_config,
    severity,
    review_status,
    is_active,
    is_template,
    created_at,
    updated_at
) VALUES (
    'AK-SLIP-FALL-SOL',
    5,
    'AK Slip & Fall Statute of Limitations (2 Years - AS 09.10.070)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'AK',
    '{
        "sub_specialization_type": "premises_liability",
        "authority_level": "contextual_rule",
        "statute": "AS 09.10.070",
        "statute_title": "Actions for torts, for injury to personal property, for certain statutory liabilities, and against peace officers and coroners to be brought in two years",
        "enactment_date": "Verified as active 2024-2026",
        "current_status": "Active as of 2024-2026",
        "not_repealed": true,
        "statute_of_limitations": "2 years",
        "accrual_date": "Date of slip and fall accident (date cause of action accrues)",
        "deadline_rule": "Action must be commenced within 2 years from date of injury",
        "consequence_of_violation": "Claim time-barred; court will dismiss case; no recovery possible",
        "statute_scope": {
            "covers": [
                "Personal injury actions (including slip and fall)",
                "Torts not arising from contract",
                "Libel and slander",
                "Assault and battery",
                "Injury to personal property",
                "Certain statutory liabilities"
            ]
        },
        "tolling_provisions": {
            "minors": "Statute tolled for minors until they reach age of majority (18), then 2-year period begins",
            "mental_incapacity": "Statute may be tolled for individuals with legal disabilities (mental incapacitation)",
            "discovery_rule": "Limited application - if injury not immediately apparent, SOL may begin when injury discovered or should have been discovered",
            "defendant_absence": "Statute may be tolled if defendant absent from state"
        },
        "key_requirements": [
            "Lawsuit must be filed within 2 years of slip and fall accident",
            "Filing complaint with court constitutes commencement of action",
            "Statute generally runs from date of injury, not date of discovery",
            "No recovery possible if lawsuit filed after 2-year deadline (absent tolling)"
        ],
        "strategic_considerations": [
            "Act promptly to preserve evidence (photographs, surveillance footage, witness statements)",
            "Document injuries and medical treatment immediately",
            "Identify property owner and all responsible parties quickly",
            "Do not wait until deadline approaches - evidence degrades over time",
            "Witness memories fade; snow/ice conditions change seasonally",
            "Insurance claim does not extend statute of limitations"
        ],
        "verification": {
            "statute_text_verified": true,
            "full_text_source": "https://www.touchngo.com/lglcntr/akstats/statutes/title09/chapter10/section070.htm",
            "multiple_sources": [
                "Alaska Statutes AS 09.10.070",
                "FindLaw - Alaska Statutes § 09.10.070",
                "Super Lawyers - Slip and Fall Statute of Limitations",
                "Crowson Law - Alaska Personal Injury Lawsuit Guide",
                "Nolo - Alaska Personal Injury Laws and Statutes"
            ],
            "current_as_of": "2024-2026",
            "not_repealed": true,
            "source_type": "primary_law",
            "last_verified": "2026-01-31",
            "verified_by": "DRAFT_research_agent",
            "confidence": "high"
        }
    }'::jsonb,
    'error',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
) ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    validator_name = EXCLUDED.validator_name,
    severity = EXCLUDED.severity,
    review_status = EXCLUDED.review_status,
    updated_at = NOW();

-- =====================================================================================
-- RULE 4: NON-ECONOMIC DAMAGES CAP
-- =====================================================================================
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
    validator_config,
    severity,
    review_status,
    is_active,
    is_template,
    created_at,
    updated_at
) VALUES (
    'AK-SLIP-FALL-DAMAGES-CAP',
    5,
    'AK Non-Economic Damages Cap (Pain & Suffering)',
    'content_check',
    'personal_injury',
    'slip_fall',
    'complaint',
    'state',
    'AK',
    '{
        "sub_specialization_type": "premises_liability",
        "authority_level": "contextual_rule",
        "rule_type": "damages_cap",
        "damage_type": "non_economic",
        "cap_description": "Alaska imposes caps on non-economic damages (pain and suffering) in personal injury cases",
        "standard_cap": {
            "amount": "$400,000",
            "applies_to": "Non-economic damages (pain and suffering, emotional distress, loss of enjoyment of life)",
            "excludes": "Economic damages (medical expenses, lost wages, property damage) - no cap"
        },
        "enhanced_cap": {
            "amount": "$1,000,000",
            "applies_when": "Victim has severe permanent physical impairment, severe disfigurement, or loss of use of body part",
            "criteria": [
                "Severe permanent physical impairment",
                "Severe permanent disfigurement",
                "Loss of use of body part or organ"
            ]
        },
        "economic_damages": {
            "no_cap": "No cap on economic damages",
            "includes": [
                "Past and future medical expenses",
                "Lost wages and earning capacity",
                "Property damage",
                "Cost of future care",
                "Rehabilitation costs"
            ]
        },
        "strategic_considerations": [
            "Maximize documentation of economic damages (no cap)",
            "If severe permanent injury, document thoroughly to qualify for $1M cap",
            "Medical expert testimony critical for severe injury determination",
            "Consider damages cap when evaluating settlement offers",
            "Caps apply per person, not per defendant"
        ],
        "verification": {
            "doctrine_verified": true,
            "multiple_sources": [
                "Eric Derleth Trial Guy - Comparative Negligence and Damages Caps",
                "Nolo - Alaska Personal Injury Laws",
                "Alaska case law and statutes on damages caps"
            ],
            "current_as_of": "2024-2026",
            "source_type": "statutory",
            "last_verified": "2026-01-31",
            "verified_by": "DRAFT_research_agent",
            "confidence": "high"
        }
    }'::jsonb,
    'warning',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
) ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    validator_name = EXCLUDED.validator_name,
    severity = EXCLUDED.severity,
    review_status = EXCLUDED.review_status,
    updated_at = NOW();

-- =====================================================================================
-- END OF ALASKA SLIP & FALL RULES SEED FILE
-- Total Rules: 4
-- =====================================================================================
