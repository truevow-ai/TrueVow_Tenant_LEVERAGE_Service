-- =====================================================================================
-- NEW HAMPSHIRE (NH) DOG BITE LIABILITY RULES
-- =====================================================================================
-- State: New Hampshire (NH)
-- Practice Area: Personal Injury - Dog Bite Liability
-- Research Date: 2026-01-30
-- Primary Source: RSA 466:19 (effective Jan. 1, 1996)
-- Key Case Law: Bohan v. Ritzo, 141 N.H. 210 (1996)
-- Verification Status: COMPLETE - Statute text verified from official NH legislature site
-- Current Status: ACTIVE as of 2024-2025, NOT repealed
-- =====================================================================================

-- RULE 1: Strict Liability Statute (RSA 466:19)
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'NH-DOG-BITE-STRICT-LIABILITY',
    5,
    'NH Dog Bite Strict Liability Rule',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'NH',
    '{
        "liability_model": "strict_liability",
        "statute": "RSA 466:19",
        "enacted": "1851",
        "amendments": ["1989", "1991", "1995"],
        "effective_date": "1996-01-01",
        "current_status": "Active as of 2024-2025",
        "authority_level": "contextual_rule",
        "statute_text": "Any person to whom or to whose property, including sheep, lambs, fowl, or other domestic creatures, damage may be occasioned by a dog not owned or kept by such person shall be entitled to recover damages from the person who owns, keeps, or possesses the dog, unless the damage was occasioned to a person who was engaged in the commission of a trespass or other tort.",
        "rule_statement": "Dog owners, keepers, or possessors are strictly liable for damages caused by their dogs to persons or property.",
        "elements": {
            "ownership_keeper_possessor": {
                "required": true,
                "definition": "Person who owns, keeps, or possesses the dog",
                "includes": ["owner", "keeper", "possessor"],
                "minor_liability": "Parent or guardian liable if owner/keeper is a minor"
            },
            "damage_caused": {
                "required": true,
                "types": ["injury to person", "damage to property", "injury to livestock/domestic animals"],
                "no_physical_contact_required": true,
                "case_law": "Bohan v. Ritzo, 141 N.H. 210 (1996) - Liability exists even without bite or direct contact"
            },
            "no_prior_knowledge_required": {
                "strict_liability": true,
                "first_bite_rule": false,
                "scienter_not_required": true
            }
        },
        "exceptions": {
            "trespass_exception": {
                "applies": true,
                "statute_text": "unless the damage was occasioned to a person who was engaged in the commission of a trespass",
                "complete_bar": true
            },
            "tort_exception": {
                "applies": true,
                "statute_text": "or other tort",
                "complete_bar": true,
                "description": "No liability if victim was committing any tort at time of injury"
            }
        },
        "coverage": {
            "broad_scope": true,
            "includes_non_bite_injuries": true,
            "property_damage": true,
            "livestock_damage": true,
            "case_law_expansion": "Bohan v. Ritzo extended liability to mischievous or vicious acts without physical contact"
        },
        "verification": {
            "statute_text_verified": true,
            "official_source": "https://gencourt.state.nh.us/rsa/html/xlv/466/466-19.htm",
            "case_law_verified": true,
            "current_as_of": "2024-2025",
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
    validator_level  = EXCLUDED.validator_level,
    validator_name   = EXCLUDED.validator_name,
    validator_type   = EXCLUDED.validator_type,
    severity         = EXCLUDED.severity,
    review_status    = EXCLUDED.review_status,
    is_active        = EXCLUDED.is_active,
    updated_at       = NOW();

-- RULE 2: Trespass/Tort Exception
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'NH-DOG-BITE-TRESPASS-TORT-EXCEPTION',
    6,
    'NH Dog Bite Trespass/Tort Exception',
    'legal_research',
    'personal_injury',
    'complaint',
    'state',
    'NH',
    '{
        "exception_type": "trespass_and_tort_defense",
        "statute": "RSA 466:19",
        "authority_level": "contextual_rule",
        "rule_statement": "No liability if damage was occasioned to a person engaged in the commission of a trespass or other tort.",
        "trespass_defense": {
            "definition": "Unlawful entry on anothers property",
            "burden_of_proof": "On defendant to prove plaintiff was trespassing",
            "complete_bar": true
        },
        "tort_defense": {
            "definition": "Any tortious conduct by plaintiff at time of injury",
            "broad_scope": true,
            "examples": ["assault", "battery", "provocation of dog", "negligent conduct"],
            "complete_bar": true
        },
        "legal_effect": {
            "absolute_defense": true,
            "no_comparative_fault": "If trespass/tort proven, recovery completely barred",
            "no_partial_recovery": true
        },
        "verification": {
            "statute_text_verified": true,
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
    validator_level  = EXCLUDED.validator_level,
    validator_name   = EXCLUDED.validator_name,
    validator_type   = EXCLUDED.validator_type,
    severity         = EXCLUDED.severity,
    review_status    = EXCLUDED.review_status,
    is_active        = EXCLUDED.is_active,
    updated_at       = NOW();

-- RULE 3: Minor Owner Liability
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'NH-DOG-BITE-MINOR-OWNER-LIABILITY',
    6,
    'NH Dog Bite Minor Owner Liability',
    'legal_research',
    'personal_injury',
    'complaint',
    'state',
    'NH',
    '{
        "statute": "RSA 466:19",
        "authority_level": "contextual_rule",
        "rule_statement": "A parent or guardian shall be liable under this section if the owner or keeper of the dog is a minor.",
        "scope": {
            "applies_when": "Dog owner or keeper is a minor",
            "liable_party": ["parent", "guardian"],
            "vicarious_liability": true
        },
        "legal_effect": {
            "parent_guardian_jointly_liable": true,
            "minor_age_definition": "Under 18 years old",
            "strict_liability_applies": "Same strict liability standard applies to parent/guardian"
        },
        "verification": {
            "statute_text_verified": true,
            "source_type": "primary_law",
            "last_verified": "2026-01-30",
            "verified_by": "DRAFT_research_agent",
            "confidence": "high"
        }
    }'::jsonb,
    'info',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
) ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    validator_level  = EXCLUDED.validator_level,
    validator_name   = EXCLUDED.validator_name,
    validator_type   = EXCLUDED.validator_type,
    severity         = EXCLUDED.severity,
    review_status    = EXCLUDED.review_status,
    is_active        = EXCLUDED.is_active,
    updated_at       = NOW();

-- RULE 4: Bohan v. Ritzo - No Physical Contact Required
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'NH-DOG-BITE-NO-CONTACT-REQUIRED',
    6,
    'NH Dog Bite No Physical Contact Required',
    'legal_research',
    'personal_injury',
    'complaint',
    'state',
    'NH',
    '{
        "case_law": "Bohan v. Ritzo, 141 N.H. 210 (1996)",
        "authority_level": "contextual_rule",
        "rule_statement": "Strict liability under RSA 466:19 applies even without bite or direct physical contact with the dog.",
        "facts_of_bohan": {
            "scenario": "Bicyclist injured while trying to avoid dog",
            "no_physical_contact": true,
            "no_bite": true,
            "holding": "Dogs mischievous or vicious behavior sufficient for liability"
        },
        "legal_principle": {
            "mischievous_conduct": "Sufficient basis for liability",
            "vicious_conduct": "Sufficient basis for liability",
            "no_contact_needed": "Injury caused by avoiding dog covered by statute",
            "broad_interpretation": "Court broadly interprets occasioned by a dog"
        },
        "practical_application": {
            "examples": [
                "Dog chasing causing victim to fall",
                "Dog jumping causing victim to swerve",
                "Dog charging causing victim to flee and injure self",
                "Dog menacing causing fear and injury"
            ]
        },
        "verification": {
            "case_citation": "Bohan v. Ritzo, 141 N.H. 210 (1996)",
            "case_law_verified": true,
            "source_type": "case_law",
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
    validator_level  = EXCLUDED.validator_level,
    validator_name   = EXCLUDED.validator_name,
    validator_type   = EXCLUDED.validator_type,
    severity         = EXCLUDED.severity,
    review_status    = EXCLUDED.review_status,
    is_active        = EXCLUDED.is_active,
    updated_at       = NOW();

-- RULE 5: Statute of Limitations (RSA 508:4)
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'NH-DOG-BITE-SOL',
    5,
    'NH Dog Bite Statute of Limitations',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'NH',
    '{
        "sol_years": 3,
        "sol_days": 1095,
        "statute": "RSA 508:4",
        "authority_level": "contextual_rule",
        "rule_statement": "Dog bite claims fall under general personal injury statute of limitations: 3 years from date of act or omission.",
        "accrual": {
            "trigger_event": "date_of_act_or_omission",
            "discovery_rule": true,
            "discovery_rule_text": "If injury and causal relationship not discovered and could not reasonably be discovered, 3 years from when injury and cause were or should have been discovered"
        },
        "exceptions": {
            "discovery_rule": "Applies if injury not immediately obvious",
            "delayed_accrual": "SOL begins when injury and its cause discovered or should have been discovered"
        },
        "verification": {
            "statute_verified": true,
            "official_source": "https://gencourt.state.nh.us/rsa/html/LII/508/508-mrg.htm",
            "current_as_of": "2024-2025",
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
    validator_level  = EXCLUDED.validator_level,
    validator_name   = EXCLUDED.validator_name,
    validator_type   = EXCLUDED.validator_type,
    severity         = EXCLUDED.severity,
    review_status    = EXCLUDED.review_status,
    is_active        = EXCLUDED.is_active,
    updated_at       = NOW();

-- RULE 6: Common Law Liability (Alternative Basis)
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'NH-DOG-BITE-COMMON-LAW-LIABILITY',
    6,
    'NH Dog Bite Common Law Liability',
    'legal_research',
    'personal_injury',
    'complaint',
    'state',
    'NH',
    '{
        "liability_theory": "common_law_negligence",
        "authority_level": "contextual_rule",
        "rule_statement": "In addition to statutory strict liability, victims may pursue common law negligence claims.",
        "elements": {
            "duty": {
                "required": true,
                "standard": "Owner has duty to exercise reasonable care to prevent dog from injuring others"
            },
            "breach": {
                "required": true,
                "examples": ["failing to restrain dog", "ignoring prior aggressive behavior", "inadequate containment"]
            },
            "causation": {
                "required": true,
                "but_for": true,
                "proximate_cause": true
            },
            "damages": {
                "required": true,
                "actual_injury": true
            }
        },
        "when_to_use": {
            "trespass_defense_applies": "If victim was trespassing, strict liability barred but negligence may still apply",
            "additional_damages": "May support punitive damages in egregious cases",
            "alternative_theory": "Backup theory if strict liability defense successful"
        },
        "verification": {
            "source_type": "common_law",
            "last_verified": "2026-01-30",
            "verified_by": "DRAFT_research_agent",
            "confidence": "high"
        }
    }'::jsonb,
    'info',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
) ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    validator_level  = EXCLUDED.validator_level,
    validator_name   = EXCLUDED.validator_name,
    validator_type   = EXCLUDED.validator_type,
    severity         = EXCLUDED.severity,
    review_status    = EXCLUDED.review_status,
    is_active        = EXCLUDED.is_active,
    updated_at       = NOW();

-- =====================================================================================
-- VERIFICATION QUERY
-- =====================================================================================

SELECT 
    rule_name,
    validator_config->>'liability_model' AS liability_model,
    validator_config->>'statute' AS statute,
    validator_config->>'authority_level' AS authority_level,
    validator_config->'verification'->>'current_as_of' AS verified_current,
    validator_config->'verification'->>'not_repealed' AS not_repealed,
    is_active
FROM leverage.validation_rules
WHERE jurisdiction_state = 'NH'
  AND practice_area = 'personal_injury'
  AND rule_name LIKE '%DOG-BITE%'
ORDER BY validator_level;

-- =====================================================================================
-- END OF NEW HAMPSHIRE DOG BITE RULES
-- =====================================================================================
