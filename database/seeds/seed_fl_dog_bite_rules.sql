-- =====================================================================================
-- FLORIDA DOG BITE LIABILITY RULES SEED FILE
-- =====================================================================================
-- State: Florida (FL)
-- Sub-Specialization: Dog Bite (Personal Injury)
-- Liability Model: STRICT LIABILITY (Statutory)
-- Legal Standard: Owner liable for damages regardless of former viciousness or owner's knowledge
-- Primary Authority: Fla. Stat. § 767.04
-- Statute of Limitations: 2 years (Fla. Stat. § 95.11 as amended by HB 837, effective March 24, 2023)
-- 
-- VERIFICATION STATUS: DOCUMENT VERIFIED
-- Research Date: January 30, 2026
-- Sources Verified:
--   1. Fla. Stat. § 767.04 (2025) - Verified from leg.state.fl.us
--   2. Fla. Stat. § 95.11 as amended by HB 837 (2023) - Reduced from 4 years to 2 years
--   3. http://www.leg.state.fl.us/statutes/index.cfm?App_mode=Display_Statute&URL=0700-0799/0767/0767.html
-- =====================================================================================

-- =====================================================================================
-- PART 1: LEGAL SOURCES
-- =====================================================================================

-- Source 1: Florida Dog Bite Strict Liability Statute (Fla. Stat. § 767.04)
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
    'FL',
    NULL,
    NULL,
    'Florida Dog Bite Strict Liability Statute',
    'Florida Legislature',
    'Fla. Stat. § 767.04',
    'http://www.leg.state.fl.us/statutes/index.cfm?App_mode=Display_Statute&URL=0700-0799/0767/0767.html',
    'statute',
    'high',
    'Fla. Stat. § 767.04 - Dog owner''s liability for damages to persons bitten:

The owner of any dog that bites any person while such person is on or in a public place, or lawfully on or in a private place, including the property of the owner of the dog, is liable for damages suffered by persons bitten, regardless of the former viciousness of the dog or the owners'' knowledge of such viciousness.

However, any negligence on the part of the person bitten that is a proximate cause of the biting incident reduces the liability of the owner of the dog by the percentage that the bitten person''s negligence contributed to the biting incident.

A person is lawfully upon private property of such owner within the meaning of this act when the person is on such property in the performance of any duty imposed upon him or her by the laws of this state or by the laws or postal regulations of the United States, or when the person is on such property upon invitation, expressed or implied, of the owner.

However, the owner is not liable, except as to a person under the age of 6, or unless the damages are proximately caused by a negligent act or omission of the owner, if at the time of any such injury the owner had displayed in a prominent place on his or her premises a sign easily readable including the words "Bad Dog."

The remedy provided by this section is in addition to and cumulative with any other remedy provided by statute or common law.

KEY PROVISIONS:
- STRICT LIABILITY: Owner liable regardless of dog''s former viciousness or owner''s knowledge
- NO ONE-BITE RULE: Liability attaches even on first bite
- PUBLIC OR PRIVATE PROPERTY: Applies to bites occurring on public places OR lawfully on private property (including owner''s property)
- LAWFULLY ON PROPERTY INCLUDES:
  * Performance of duty imposed by state/federal law (mail carriers, police, inspectors)
  * Upon invitation, express or implied, of owner
- COMPARATIVE NEGLIGENCE: Victim''s negligence reduces owner''s liability proportionally
- "BAD DOG" SIGN DEFENSE:
  * Sign must be prominently displayed and easily readable with words "Bad Dog"
  * Defense does NOT apply to: (1) children under age 6, OR (2) when damages proximately caused by owner''s negligent act or omission
- CUMULATIVE REMEDY: Strict liability remedy is IN ADDITION TO common law negligence remedies

DOCUMENT VERIFIED from Florida Legislature (2025 Florida Statutes).'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET
    base_url = EXCLUDED.base_url,
    notes = EXCLUDED.notes;

-- Source 2: Florida Statute of Limitations - Personal Injury (Fla. Stat. § 95.11, as amended 2023)
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
    'FL',
    NULL,
    NULL,
    'Florida Statute of Limitations - Personal Injury (Dog Bite)',
    'Florida Legislature',
    'Fla. Stat. § 95.11 (as amended by HB 837, 2023)',
    'https://www.flsenate.gov/Session/Bill/2023/837',
    'statute',
    'high',
    'Fla. Stat. § 95.11 - Statute of limitations for negligence actions (as amended by HB 837, 2023):

Personal injury actions, including dog bite claims, must be brought within TWO YEARS from the date the cause of action accrues.

CRITICAL AMENDMENT - HB 837 (2023):
- EFFECTIVE DATE: March 24, 2023
- CHANGED FROM: 4 years to 2 years
- APPLIES TO: All causes of action accruing on or after March 24, 2023
- PREVIOUS LAW: For injuries occurring before March 24, 2023, the 4-year statute of limitations still applies

APPLICATION TO DOG BITES:
Claims brought under Fla. Stat. § 767.04 (strict liability statute) are subject to this TWO YEAR statute of limitations. The two-year period begins on the date of the dog bite injury.

TOLLING PROVISIONS:
- Discovery rule: Limited tolling if injury is inherently unknowable
- Minors: Statute tolled until minor reaches age 18
- Defendant absence/concealment: Time may be tolled
- Incapacitated persons: May receive extensions

STRATEGIC NOTES:
- 2-year deadline is MUCH SHORTER than previous 4-year deadline
- Florida shifted from pure comparative negligence to modified comparative negligence (HB 837): Plaintiff cannot recover if more than 50% at fault
- Early legal consultation critical to preserve rights

DOCUMENT VERIFIED from Florida Legislature (HB 837, 2023).'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET
    base_url = EXCLUDED.base_url,
    notes = EXCLUDED.notes;

-- Source 3: Florida Dangerous Dogs Statute (Fla. Stat. § 767.11-767.16)
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
    'FL',
    NULL,
    NULL,
    'Florida Dangerous Dogs Statute',
    'Florida Legislature',
    'Fla. Stat. § 767.11',
    'http://www.leg.state.fl.us/statutes/index.cfm?App_mode=Display_Statute&URL=0700-0799/0767/0767.html',
    'statute',
    'high',
    'Fla. Stat. § 767.11 - Definition of "dangerous dog":

A dog is classified as "dangerous" if according to records of the appropriate authority:
(a) Has aggressively bitten, attacked, or endangered or has inflicted severe injury on a human being on public or private property;
(b) Has more than once severely injured or killed a domestic animal while off the owner''s property; or
(c) Has, when unprovoked, chased or approached a person upon the streets, sidewalks, or any public grounds in a menacing fashion or apparent attitude of attack, provided that such actions are attested to in a sworn statement by one or more persons and dutifully investigated by the appropriate authority.

"SEVERE INJURY" DEFINED (Fla. Stat. § 767.11(6)):
Any physical injury that results in broken bones, multiple bites, or disfiguring lacerations requiring sutures or reconstructive surgery.

"UNPROVOKED" DEFINED (Fla. Stat. § 767.11(7)):
That the victim who has been conducting himself or herself peacefully and lawfully has been bitten or chased in a menacing fashion or attacked by a dog.

STRATEGIC SIGNIFICANCE:
- Classification as "dangerous dog" has significant consequences for owner
- Owners of dangerous dogs must comply with strict confinement, insurance, and registration requirements
- Enhanced liability and potential criminal penalties for violations
- Prior "dangerous dog" classification strengthens strict liability case under § 767.04

DOCUMENT VERIFIED from Florida Legislature (2025 Florida Statutes).'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET
    base_url = EXCLUDED.base_url,
    notes = EXCLUDED.notes;

-- =====================================================================================
-- PART 2: VALIDATION RULES
-- =====================================================================================

-- Rule 1: Florida Strict Liability (Fla. Stat. § 767.04)
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
    'FL-PI-DOG-BITE-STRICT-LIABILITY',
    5,
    'FL Dog Bite Strict Liability (Fla. Stat. § 767.04)',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'FL',
    NULL,
    NULL,
    '{
        "liability_model": "strict_liability",
        "statute": "Fla. Stat. § 767.04",
        "legal_standard": "Owner liable regardless of former viciousness or owner''s knowledge",
        "key_requirements": [
            "Dog bit plaintiff",
            "Defendant was owner of dog",
            "Plaintiff was on or in a public place, OR lawfully on or in a private place",
            "Owner is liable regardless of dog''s former viciousness",
            "Owner is liable regardless of owner''s knowledge of viciousness"
        ],
        "lawfully_on_private_property_includes": [
            "Performance of duty imposed by state law (police, inspectors)",
            "Performance of duty imposed by federal law or postal regulations (mail carriers)",
            "Upon express invitation of owner",
            "Upon implied invitation of owner"
        ],
        "comparative_negligence": "Victim''s negligence reduces owner''s liability proportionally (modified comparative negligence post-HB 837: plaintiff cannot recover if >50% at fault)",
        "bad_dog_sign_defense": {
            "requirements": [
                "Sign displayed in prominent place on owner''s premises",
                "Sign easily readable",
                "Sign includes words ''Bad Dog''"
            ],
            "exceptions_no_defense": [
                "Victim under age 6 (sign defense does NOT apply)",
                "Damages proximately caused by owner''s negligent act or omission (sign defense does NOT apply)"
            ]
        },
        "no_one_bite_rule": "Florida does NOT follow one-bite rule; strict liability on first bite",
        "cumulative_remedy": "Strict liability remedy is IN ADDITION TO common law negligence remedies",
        "damages_recoverable": [
            "Medical expenses",
            "Lost wages",
            "Pain and suffering",
            "Permanent scarring/disfigurement",
            "Emotional trauma",
            "Property damage"
        ]
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

-- Rule 2: Florida Statute of Limitations - 2 Years (Post-HB 837)
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
    'FL-PI-DOG-BITE-SOL-2-YEARS',
    5,
    'FL Dog Bite Statute of Limitations (2 Years)',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'FL',
    NULL,
    NULL,
    '{
        "statute": "Fla. Stat. § 95.11 (as amended by HB 837, 2023)",
        "statute_of_limitations": "2 years",
        "effective_date": "March 24, 2023",
        "changed_from": "4 years to 2 years",
        "accrual_date": "Date the cause of action accrues (date of dog bite injury)",
        "key_requirements": [
            "Complaint must be filed within 2 years of date of dog bite",
            "Applies to all causes of action accruing on or after March 24, 2023",
            "For injuries before March 24, 2023, the old 4-year SOL still applies",
            "Applies to strict liability claims under Fla. Stat. § 767.04",
            "Applies to common law negligence claims",
            "Failure to file within 2 years bars recovery"
        ],
        "tolling_provisions": [
            "Discovery rule: Limited tolling if injury inherently unknowable",
            "Minors: Statute tolled until minor reaches age 18",
            "Defendant absence or concealment: Time may be tolled",
            "Incapacitated persons: May receive extensions"
        ],
        "strategic_note": "HB 837 DRASTICALLY shortened SOL from 4 years to 2 years. Early legal consultation critical.",
        "hb_837_additional_changes": [
            "Modified comparative negligence: Plaintiff cannot recover if >50% at fault",
            "Changes to medical damages calculation and presentation",
            "Restrictions on evidence of medical expenses"
        ],
        "consequence_of_violation": "Claim time-barred; court will dismiss case; no recovery possible"
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

-- Rule 3: Florida Dangerous Dog Classification - Enhanced Liability
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
    'FL-PI-DOG-BITE-DANGEROUS-DOG',
    5,
    'FL Dangerous Dog Classification - Enhanced Liability',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'FL',
    NULL,
    NULL,
    '{
        "statute": "Fla. Stat. § 767.11",
        "liability_theory": "dangerous_dog_classification",
        "dangerous_dog_definition": [
            "Has aggressively bitten, attacked, or endangered or inflicted severe injury on human",
            "Has more than once severely injured or killed domestic animal while off owner''s property",
            "Has, when unprovoked, chased or approached person in menacing fashion or apparent attitude of attack (attested in sworn statement and investigated)"
        ],
        "severe_injury_definition": "Physical injury resulting in broken bones, multiple bites, or disfiguring lacerations requiring sutures or reconstructive surgery",
        "unprovoked_definition": "Victim conducting self peacefully and lawfully has been bitten or chased in menacing fashion or attacked",
        "strategic_significance": [
            "Prior dangerous dog classification strengthens strict liability case under § 767.04",
            "Shows owner had knowledge of dog''s dangerous propensities",
            "Defeats ''bad dog'' sign defense (owner negligence shown)",
            "May support punitive damages if owner violated dangerous dog requirements",
            "Enhanced owner duties: proper enclosure, liability insurance, registration, warning signs"
        ],
        "owner_violations_support_negligence": [
            "Failure to securely confine dangerous dog (§ 767.12)",
            "Failure to obtain liability insurance",
            "Failure to register dangerous dog",
            "Allowing dangerous dog to run at large"
        ]
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

-- Rule 4: Florida "Bad Dog" Sign Defense - Limited Application
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
    'FL-PI-DOG-BITE-BAD-DOG-SIGN',
    5,
    'FL "Bad Dog" Sign Defense - Limited Application',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'FL',
    NULL,
    NULL,
    '{
        "statute": "Fla. Stat. § 767.04",
        "defense_type": "bad_dog_sign_defense",
        "requirements_for_defense": [
            "Sign displayed in prominent place on owner''s premises",
            "Sign easily readable",
            "Sign includes words ''Bad Dog''"
        ],
        "defense_does_not_apply_if": [
            "Victim is under age 6 (strict liability applies regardless of sign)",
            "Damages were proximately caused by owner''s negligent act or omission"
        ],
        "owner_negligence_defeats_defense": [
            "Owner allowed dog to escape despite sign",
            "Owner failed to properly confine dog",
            "Owner violated dangerous dog requirements",
            "Owner knew dog was dangerous but took inadequate precautions"
        ],
        "strategic_drafting": [
            "If victim under age 6, explicitly allege to defeat sign defense",
            "If owner negligence shown, explicitly allege to defeat sign defense",
            "Argue sign does NOT eliminate duty to exercise reasonable care",
            "Argue negligence theory alongside strict liability to defeat sign defense"
        ]
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
-- END OF FLORIDA DOG BITE RULES SEED FILE
-- =====================================================================================
