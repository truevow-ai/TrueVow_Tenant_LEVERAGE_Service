-- =====================================================================================
-- GEORGIA DOG BITE LIABILITY RULES SEED FILE
-- =====================================================================================
-- State: Georgia (GA)
-- Sub-Specialization: Dog Bite (Personal Injury)
-- Liability Model: MODIFIED ONE-BITE RULE (Knowledge of Vicious Propensity + Negligent Management)
-- Legal Standard: Owner liable if knew/should have known of vicious propensity AND carelessly managed or allowed at liberty
-- Primary Authority: O.C.G.A. § 51-2-7
-- Statute of Limitations: 2 years (O.C.G.A. § 9-3-33)
-- 
-- VERIFICATION STATUS: DOCUMENT VERIFIED
-- Research Date: January 30, 2026
-- Sources Verified:
--   1. O.C.G.A. § 51-2-7 - Verified from multiple legal sources (Justia, Nolo, dogbitelaw.com)
--   2. O.C.G.A. § 9-3-33 - 2-year SOL for personal injury
--   3. Leash ordinance violation as evidence of vicious propensity
-- =====================================================================================

-- =====================================================================================
-- PART 1: LEGAL SOURCES
-- =====================================================================================

-- Source 1: Georgia Dog Bite Liability Statute (O.C.G.A. § 51-2-7)
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
    'GA',
    NULL,
    NULL,
    'Georgia Dog Bite Liability Statute',
    'Georgia Legislature',
    'O.C.G.A. § 51-2-7',
    'https://law.justia.com/codes/georgia/2020/title-51/chapter-2/section-51-2-7/',
    'statute',
    'high',
    'O.C.G.A. § 51-2-7 - Liability of owner or keeper of vicious or dangerous animal for injuries caused by animal:

A person who owns or keeps a vicious or dangerous animal of any kind and who, by careless management or by allowing the animal to go at liberty, causes injury to another person who does not provoke the injury by his own act may be liable in damages to the person so injured.

In proving vicious propensity, it shall be sufficient to show that the animal was required to be at heel or on a leash by an ordinance of a city, county, or consolidated government, and the said animal was at the time of the occurrence not at heel or on a leash.

The foregoing provisions of this Code section shall not apply to domesticated fowl including roosters with spurs and domesticated livestock.

KEY PROVISIONS:
- NOT STRICT LIABILITY: Georgia does NOT impose strict liability; requires proof of TWO elements:
  (1) Dog has vicious or dangerous propensity, AND
  (2) Owner was negligent (careless management OR allowing dog to go at liberty)
- KNOWLEDGE REQUIREMENT (SCIENTER): Owner must have known or should have known of dog''s vicious propensity
- TWO METHODS TO PROVE VICIOUS PROPENSITY:
  (1) SCIENTER GROUND: Evidence of prior aggressive behavior (biting, attacking, snapping, menacing, chasing); OR
  (2) ORDINANCE VIOLATION GROUND: Violation of local leash law or ordinance requiring dog to be restrained
- CARELESS MANAGEMENT EXAMPLES:
  * Keeping dog chained irresponsibly
  * Allowing children to handle dangerous dog without supervision
  * Entrusting dog to unfit caretaker
  * Failing to properly secure dog
  * Inadequate containment of known dangerous dog
- ALLOWING DOG TO GO AT LIBERTY:
  * Allowing dog to roam free without leash
  * Allowing dog to escape confinement
  * Violating local leash laws
  * Failing to restrain dog as required by ordinance
- PROVOCATION DEFENSE: Owner not liable if victim provoked the injury by his own act
- PRESUMPTION: Dogs are generally presumed harmless regardless of breed

CRITICAL DISTINCTION FROM STRICT LIABILITY STATES:
Georgia requires BOTH elements: (1) vicious propensity + (2) negligent management. Victim cannot recover by showing vicious propensity alone OR negligent management alone. BOTH must be proven.

DOCUMENT VERIFIED from multiple legal sources (Justia, Nolo, dogbitelaw.com, Delashmit Firm).'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET
    base_url = EXCLUDED.base_url,
    notes = EXCLUDED.notes;

-- Source 2: Georgia Statute of Limitations - Personal Injury (O.C.G.A. § 9-3-33)
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
    'GA',
    NULL,
    NULL,
    'Georgia Statute of Limitations - Personal Injury (Dog Bite)',
    'Georgia Legislature',
    'O.C.G.A. § 9-3-33',
    'https://www.awjlaw.com/faqs/what-is-the-statute-of-limitations-for-dog-bite-claims-in-georgia/',
    'statute',
    'high',
    'O.C.G.A. § 9-3-33 - Statute of limitations for personal injury actions:

Actions for injuries to the person shall be brought within two years after the right of action accrues.

APPLICATION TO DOG BITES:
Claims brought under O.C.G.A. § 51-2-7 (dog bite liability statute) are subject to this TWO YEAR statute of limitations. The two-year period begins on the date of the dog bite injury.

TOLLING PROVISIONS:
- Minors: The two-year period does NOT begin until the minor turns 18
- Defendant absence or concealment: Time may be tolled
- Discovery rule: Limited tolling if injury is latent or inherently unknowable
- Crimes: Statute can be tolled if injury arises from a crime (per O.C.G.A. § 9-3-99), potentially extending up to 6 years

STRATEGIC NOTES:
- Must file within 2 years from date of injury
- Evidence preservation critical (witness statements, photographs, incident reports)
- Most cases resolve through insurance settlements, but 2-year deadline still applies
- Missing deadline bars recovery of all damages (medical expenses, lost wages, pain/suffering, emotional distress)

DOCUMENT VERIFIED from Georgia legal sources.'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET
    base_url = EXCLUDED.base_url,
    notes = EXCLUDED.notes;

-- =====================================================================================
-- PART 2: VALIDATION RULES
-- =====================================================================================

-- Rule 1: Georgia Modified One-Bite Rule (O.C.G.A. § 51-2-7) - Scienter Ground
INSERT INTO leverage.validation_rules (
    rule_name,
    validator_level,
    validator_name,
    validator_type,
    practice_area,
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
    'GA-PI-DOG-BITE-SCIENTER-GROUND',
    5,
    'GA Dog Bite Liability - Scienter Ground (O.C.G.A. § 51-2-7)',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'GA',
    NULL,
    NULL,
    '{
        "liability_model": "modified_one_bite_rule",
        "statute": "O.C.G.A. § 51-2-7",
        "theory": "scienter_ground",
        "legal_standard": "Owner liable if knew/should have known of vicious propensity AND carelessly managed or allowed dog at liberty",
        "key_requirements": [
            "Dog has vicious or dangerous propensity",
            "Owner knew or should have known of vicious propensity (scienter)",
            "Owner carelessly managed dog OR allowed dog to go at liberty",
            "Dog caused injury to plaintiff",
            "Plaintiff did NOT provoke the injury by his own act"
        ],
        "element_1_vicious_propensity": {
            "definition": "Dog has dangerous or aggressive tendencies",
            "evidence_to_prove": [
                "Prior biting incidents",
                "Prior attacks or attempted attacks",
                "Snapping at people",
                "Growling or menacing behavior",
                "Chasing people in threatening manner",
                "Aggressive lunging",
                "History of aggressive behavior toward animals or humans",
                "Animal control records",
                "Witness testimony of prior incidents"
            ],
            "note": "Even one prior incident can establish vicious propensity"
        },
        "element_2_owner_knowledge": {
            "definition": "Owner knew or should have known of dog''s vicious propensity",
            "actual_knowledge": "Owner was aware of prior incidents or aggressive behavior",
            "constructive_knowledge": "Owner should have known based on circumstances (e.g., prior complaints, visible aggression)",
            "evidence_to_prove": [
                "Owner witnessed prior aggressive behavior",
                "Owner received complaints about dog",
                "Prior incidents reported to animal control",
                "Dog''s history known to owner",
                "Owner observed dog''s aggressive tendencies"
            ]
        },
        "element_3_negligent_management": {
            "careless_management_examples": [
                "Keeping dog chained irresponsibly",
                "Allowing children to handle dangerous dog without supervision",
                "Entrusting dog to unfit caretaker",
                "Failing to properly secure dog",
                "Inadequate containment of known dangerous dog",
                "Failing to take reasonable precautions given known propensity"
            ],
            "allowing_at_liberty_examples": [
                "Allowing dog to roam free without leash",
                "Allowing dog to escape confinement",
                "Failing to restrain dog",
                "Dog not under owner''s control at time of incident"
            ]
        },
        "provocation_defense": "Owner not liable if victim provoked injury by his own act (e.g., hitting dog, attempting to pet dog, teasing dog)",
        "burden_of_proof": "Plaintiff must prove ALL elements: vicious propensity + owner knowledge + negligent management + no provocation",
        "not_strict_liability": "Georgia does NOT impose strict liability; cannot recover without proving owner knew of vicious propensity AND was negligent"
    }'::jsonb,
    'error',
    NULL,
    'document_verified',
    true,
    true,
    NULL,
    NOW(),
    NOW()
) ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    review_status = EXCLUDED.review_status,
    updated_at = NOW();

-- Rule 2: Georgia Dog Bite Liability - Ordinance Violation Ground
INSERT INTO leverage.validation_rules (
    rule_name,
    validator_level,
    validator_name,
    validator_type,
    practice_area,
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
    'GA-PI-DOG-BITE-ORDINANCE-VIOLATION',
    5,
    'GA Dog Bite Liability - Ordinance Violation Ground',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'GA',
    NULL,
    NULL,
    '{
        "liability_model": "modified_one_bite_rule",
        "statute": "O.C.G.A. § 51-2-7",
        "theory": "ordinance_violation_ground",
        "legal_standard": "Violation of leash ordinance establishes vicious propensity; owner still must have carelessly managed or allowed dog at liberty",
        "key_requirements": [
            "Local ordinance required dog to be at heel or on leash",
            "Dog was NOT at heel or on leash at time of incident",
            "Owner carelessly managed dog OR allowed dog to go at liberty",
            "Dog caused injury to plaintiff",
            "Plaintiff did NOT provoke the injury by his own act"
        ],
        "ordinance_violation_as_evidence": {
            "statutory_language": "In proving vicious propensity, it shall be sufficient to show that the animal was required to be at heel or on a leash by an ordinance of a city, county, or consolidated government, and the said animal was at the time of the occurrence not at heel or on a leash.",
            "significance": "Leash law violation ESTABLISHES vicious propensity without need to prove prior aggressive behavior",
            "still_requires_negligence": "Even if ordinance violation proven, plaintiff must STILL prove owner was negligent (careless management or allowing at liberty)"
        },
        "typical_local_ordinances": [
            "City/county leash laws",
            "Dog must be on leash in public places",
            "Dog must be at heel when off owner''s property",
            "Dog restraint requirements"
        ],
        "evidence_to_prove": [
            "Text of applicable local ordinance",
            "Dog was off leash/not at heel at time of incident",
            "Witness testimony that dog was unrestrained",
            "Photographs showing dog unrestrained",
            "Animal control officer testimony"
        ],
        "strategic_advantage": "Ordinance violation ground is EASIER to prove than scienter ground because plaintiff does NOT need to prove prior aggressive behavior or owner''s knowledge of vicious propensity",
        "still_requires_both_elements": [
            "ELEMENT 1 (Vicious Propensity): Proven by ordinance violation",
            "ELEMENT 2 (Negligent Management): Still must prove owner carelessly managed or allowed at liberty"
        ],
        "provocation_defense": "Owner not liable if victim provoked injury by his own act"
    }'::jsonb,
    'error',
    NULL,
    'document_verified',
    true,
    true,
    NULL,
    NOW(),
    NOW()
) ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    review_status = EXCLUDED.review_status,
    updated_at = NOW();

-- Rule 3: Georgia Statute of Limitations - 2 Years
INSERT INTO leverage.validation_rules (
    rule_name,
    validator_level,
    validator_name,
    validator_type,
    practice_area,
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
    'GA-PI-DOG-BITE-SOL-2-YEARS',
    5,
    'GA Dog Bite Statute of Limitations (2 Years)',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'GA',
    NULL,
    NULL,
    '{
        "statute": "O.C.G.A. § 9-3-33",
        "statute_of_limitations": "2 years",
        "accrual_date": "Date the right of action accrues (date of dog bite injury)",
        "key_requirements": [
            "Complaint must be filed within 2 years of date of dog bite",
            "Applies to claims under O.C.G.A. § 51-2-7",
            "Applies to all personal injury actions",
            "Failure to file within 2 years bars recovery"
        ],
        "tolling_provisions": [
            "Minors: Two-year period does NOT begin until minor turns 18",
            "Defendant absence or concealment: Time may be tolled",
            "Discovery rule: Limited tolling if injury latent or inherently unknowable",
            "Crimes: Statute tolled if injury arises from crime (O.C.G.A. § 9-3-99), potentially extending up to 6 years"
        ],
        "strategic_notes": [
            "Evidence preservation critical (witness statements, photographs, incident reports)",
            "Most cases resolve through insurance settlements, but 2-year deadline still applies",
            "Early legal consultation important to preserve rights"
        ],
        "consequence_of_violation": "Claim time-barred; court will dismiss case; no recovery of any damages (medical expenses, lost wages, pain/suffering, emotional distress)"
    }'::jsonb,
    'error',
    NULL,
    'document_verified',
    true,
    true,
    NULL,
    NOW(),
    NOW()
) ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    review_status = EXCLUDED.review_status,
    updated_at = NOW();

-- Rule 4: Georgia Provocation Defense
INSERT INTO leverage.validation_rules (
    rule_name,
    validator_level,
    validator_name,
    validator_type,
    practice_area,
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
    'GA-PI-DOG-BITE-PROVOCATION-DEFENSE',
    5,
    'GA Dog Bite Provocation Defense',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'GA',
    NULL,
    NULL,
    '{
        "statute": "O.C.G.A. § 51-2-7",
        "defense_type": "provocation_defense",
        "statutory_language": "Owner not liable if victim provoked the injury by his own act",
        "provocation_examples": [
            "Hitting or striking the dog",
            "Attempting to pet dog without permission",
            "Teasing or tormenting dog",
            "Threatening or aggressive behavior toward dog",
            "Entering dog''s territory aggressively",
            "Startling dog suddenly"
        ],
        "burden_of_proof": "Owner must prove victim provoked the injury",
        "complete_defense": "If provocation proven, owner has NO liability (not comparative reduction)",
        "strategic_drafting": [
            "Complaint should explicitly allege plaintiff did NOT provoke dog",
            "Anticipate provocation defense and address proactively",
            "Gather witness testimony that plaintiff was peaceful and lawful",
            "Document plaintiff''s actions before attack"
        ],
        "contrast_with_other_states": "Georgia provocation is COMPLETE defense, not comparative negligence reduction"
    }'::jsonb,
    'warning',
    NULL,
    'document_verified',
    true,
    true,
    NULL,
    NOW(),
    NOW()
) ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    review_status = EXCLUDED.review_status,
    updated_at = NOW();

-- =====================================================================================
-- END OF GEORGIA DOG BITE RULES SEED FILE
-- =====================================================================================
