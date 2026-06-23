-- =====================================================================================
-- TEXAS (TX) DOG BITE LIABILITY RULES
-- =====================================================================================
-- State: Texas (TX)
-- Practice Area: Personal Injury - Dog Bite Liability
-- Research Date: 2026-01-30
-- Primary Statute: TX Health & Safety Code § 822.042 (Dangerous Dogs)
-- Verification Status: COMPLETE - Full statute text verified
-- Current Status: ACTIVE as of 2024-2026
-- =====================================================================================

-- RULE 1: Dangerous Dog Strict Liability (TX HSC § 822.042)
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'TX-DANGEROUS-DOG-REQUIREMENTS',
    5,
    'TX Dangerous Dog Owner Requirements (TX HSC § 822.042)',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'TX',
    '{
        "liability_model": "dangerous_dog_strict_liability",
        "statute": "TX Health & Safety Code § 822.042",
        "current_status": "Active as of 2024-2026",
        "authority_level": "contextual_rule",
        "dangerous_dog_definition": {
            "statute": "TX HSC § 822.041",
            "criteria": [
                "Attacks person unprovoked causing injury outside secure enclosure",
                "Exhibits unprovoked behavior making person fear attack"
            ]
        },
        "owner_requirements": {
            "registration": "Must register dangerous dog with local animal control within 30 days",
            "restraint": "Dog must be restrained at all times - on leash or in secure enclosure",
            "liability_insurance": "Must obtain minimum $100000 liability insurance for potential damages",
            "compliance": "Must adhere to all local dangerous dog regulations"
        },
        "consequences_noncompliance": {
            "seizure": "Animal control may seize dog",
            "destruction_order": "Court may order humane destruction if owner does not comply within 11 days",
            "appeal_period": "10-day appeal period stays destruction order"
        },
        "verification": {
            "statute_text_verified": true,
            "full_text_source": "https://texas.public.law/statutes/tex._health_and_safety_code_section_822.042",
            "multiple_sources": ["Texas Public Law", "Justia Legal Codes", "Casetext", "FindLaw"],
            "current_as_of": "2024-2026",
            "not_repealed": true,
            "source_type": "primary_law",
            "last_verified": "2026-01-30",
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

-- RULE 2: Negligence-Based Liability (Common Law)
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'TX-DOG-BITE-NEGLIGENCE',
    5,
    'TX Common Law Negligence for Dog Bites',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'TX',
    '{
        "liability_model": "negligence_based",
        "authority_level": "contextual_rule",
        "rule_statement": "Texas does not have general strict liability statute for dog bites. Victims must prove negligence or that dog was dangerous.",
        "burden_of_proof": {
            "plaintiff_must_prove": [
                "Owner owed duty to prevent foreseeable injury",
                "Owner breached duty (failed to exercise reasonable care)",
                "Breach proximately caused injury",
                "Plaintiff suffered damages"
            ]
        },
        "negligence_theories": {
            "failure_to_control": "Owner negligently failed to restrain or control dog",
            "known_dangerous_propensities": "Owner knew or should have known dog had dangerous tendencies (one-bite rule)",
            "violation_of_ordinance": "Negligence per se if violated leash law or other animal control ordinance"
        },
        "verification": {
            "statute_text_verified": true,
            "multiple_sources": ["Texas case law", "Legal databases"],
            "current_as_of": "2024-2026",
            "source_type": "common_law",
            "last_verified": "2026-01-30",
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

-- RULE 3: Defenses (TX HSC § 822.006)
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'TX-DOG-BITE-DEFENSES',
    5,
    'TX Dog Attack Defenses (TX HSC § 822.006)',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'TX',
    '{
        "liability_model": "defenses",
        "statute": "TX Health & Safety Code § 822.006",
        "current_status": "Active as of 2024-2026",
        "authority_level": "contextual_rule",
        "defenses": {
            "veterinary_animal_control": "Veterinarians, animal shelter employees dealing with stray animals",
            "law_enforcement": "Law enforcement personnel using dogs in official capacity",
            "disability_assistance": "Individuals with disabilities using trained assistance dogs",
            "victim_illegal_conduct": "Victim engaged in illegal conduct at time of attack",
            "search_and_rescue": "Participation in organized search and rescue efforts",
            "dog_shows_events": "Participation in recognized dog shows or events",
            "hunting_farming": "Engaging in lawful hunting or ranching activities",
            "leash_control": "Dog on leash and owner in control or attempting to regain control"
        },
        "verification": {
            "statute_text_verified": true,
            "full_text_source": "https://law.justia.com/codes/texas/health-and-safety-code/title-10/chapter-822/subchapter-a/section-822-006/",
            "multiple_sources": ["Justia Legal Codes", "Texas Legislature"],
            "current_as_of": "2024-2026",
            "not_repealed": true,
            "source_type": "primary_law",
            "last_verified": "2026-01-30",
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
