-- =====================================================================================
-- CALIFORNIA DOG BITE LIABILITY RULES SEED FILE
-- =====================================================================================
-- State: California (CA)
-- Sub-Specialization: Dog Bite (Personal Injury)
-- Liability Model: STRICT LIABILITY (Statutory)
-- Legal Standard: Owner liable regardless of former viciousness or owner's knowledge
-- Primary Authority: Cal. Civ. Code § 3342
-- Statute of Limitations: 2 years (Cal. Code Civ. Proc. § 335.1)
-- Effective Date: Cal. Civ. Code § 3342 added by Stats. 1931, Ch. 329
-- 
-- VERIFICATION STATUS: DOCUMENT VERIFIED
-- Research Date: January 30, 2026
-- Sources Verified:
--   1. Cal. Civ. Code § 3342 - Full statute text verified
--   2. Cal. Code Civ. Proc. § 335.1 - 2-year SOL for personal injury
--   3. https://leginfo.legislature.ca.gov/faces/codes_displaySection.xhtml?lawCode=CIV&sectionNum=3342.
--   4. https://www.dogbitelaw.com/liability-based-on-the-dog-bite-statute-in-california/
-- =====================================================================================

-- =====================================================================================
-- PART 1: LEGAL SOURCES
-- =====================================================================================

-- Source 1: California Strict Liability Statute (Cal. Civ. Code § 3342)
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
    'CA',
    NULL,
    NULL,
    'California Dog Bite Strict Liability Statute',
    'California Legislature',
    'Cal. Civ. Code § 3342',
    'https://leginfo.legislature.ca.gov/faces/codes_displaySection.xhtml?lawCode=CIV&sectionNum=3342.',
    'statute',
    'high',
    'Cal. Civ. Code § 3342 - Liability for dog bite:

(a) The owner of any dog is liable for the damages suffered by any person who is bitten by the dog while in a public place or lawfully in a private place, including the property of the owner of the dog, regardless of the former viciousness of the dog or the owner''s knowledge of such viciousness. A person is lawfully upon the private property of such owner within the meaning of this section when he is on such property in the performance of any duty imposed upon him by the laws of this state or by the laws or postal regulations of the United States, or when he is on such property upon the invitation, express or implied, of the owner.

(b) Nothing in this section shall authorize the bringing of an action pursuant to subdivision (a) against any governmental agency using a dog in military or police work if the bite or bites occurred while the dog was defending itself from an annoying, harassing, or provoking act, or assisting an employee of the agency in any of the following:
(1) In the apprehension or holding of a suspect where the employee has a reasonable suspicion of the suspect''s involvement in criminal activity.
(2) In the investigation of a crime or possible crime.
(3) In the execution of a warrant.
(4) In the defense of a peace officer or another person.

(c) Subdivision (b) shall not apply in any case where the victim of the bite or bites was not a party to, nor a participant in, nor suspected to be a party to or a participant in, the act or acts that prompted the use of the dog in the military or police work.

(d) Subdivision (b) shall apply only where a governmental agency using a dog in military or police work has adopted a written policy on the necessary and appropriate use of a dog for the police or military work enumerated in subdivision (b).

EFFECTIVE DATE: Cal. Civ. Code § 3342 was added by Stats. 1931, Ch. 329. DOCUMENT VERIFIED.'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET
    base_url = EXCLUDED.base_url,
    notes = EXCLUDED.notes;

-- Source 2: California Statute of Limitations - Personal Injury (CCP 335.1)
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
    'CA',
    NULL,
    NULL,
    'California Statute of Limitations - Personal Injury (Dog Bite)',
    'California Legislature',
    'Cal. Code Civ. Proc. § 335.1',
    'https://leginfo.legislature.ca.gov/faces/codes_displaySection.xhtml?lawCode=CCP&sectionNum=335.1',
    'statute',
    'high',
    'Cal. Code Civ. Proc. § 335.1 - Within two years:

Within two years: An action for assault, battery, or injury to, or for the death of, an individual caused by the wrongful act or neglect of another.

APPLICATION TO DOG BITES: Claims brought under Cal. Civ. Code § 3342 (strict liability statute) are subject to this TWO YEAR statute of limitations. The two-year period begins on the date of the dog bite injury. This statute was added by Stats. 2002, Ch. 448, Sec. 1, effective January 1, 2003.

TOLLING FOR MINORS: For minors (under 18 years of age) injured by a dog bite, the statute of limitations is tolled until they turn 18, giving them until age 20 to file a lawsuit. DOCUMENT VERIFIED.'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET
    base_url = EXCLUDED.base_url,
    notes = EXCLUDED.notes;

-- =====================================================================================
-- PART 2: VALIDATION RULES
-- =====================================================================================

-- Rule 1: California Strict Liability (Cal. Civ. Code § 3342)
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
    'CA-PI-DOG-BITE-STRICT-LIABILITY',
    5,
    'CA Dog Bite Strict Liability (Cal. Civ. Code § 3342)',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'CA',
    NULL,
    NULL,
    '{
        "liability_model": "strict_liability",
        "statute": "Cal. Civ. Code § 3342",
        "effective_date": "Added by Stats. 1931, Ch. 329",
        "legal_standard": "Owner liable regardless of former viciousness or owner''s knowledge",
        "key_requirements": [
            "Dog bite occurred",
            "Victim was in a public place OR lawfully in a private place",
            "Victim includes property of owner of the dog",
            "Owner is liable regardless of dog''s former viciousness",
            "Owner is liable regardless of owner''s knowledge of viciousness"
        ],
        "lawfully_on_private_property_includes": [
            "Person performing duty imposed by state laws",
            "Person performing duty imposed by federal laws or postal regulations",
            "Person on property with owner''s invitation (express or implied)",
            "Mail carriers, delivery persons, meter readers, repair workers",
            "Social guests, invited visitors"
        ],
        "no_proof_required": [
            "No proof of prior vicious behavior required",
            "No proof of owner negligence required",
            "No proof of owner knowledge required",
            "California does NOT follow the one-bite rule"
        ],
        "defenses": [
            "Victim was trespassing (not lawfully on private property)",
            "Victim provoked the dog",
            "Victim assumed the risk (limited defense)",
            "Military/police dog exception (if all conditions met)"
        ],
        "provocation_note": "Provocation defense does NOT apply to children under 5 or those following parental instructions",
        "damages": "Full compensatory damages (economic + non-economic); punitive damages if owner acted maliciously",
        "advantages": "Easiest strict liability standard in U.S. - no need to show prior knowledge or negligence"
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

-- Rule 2: California Statute of Limitations - 2 Years
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
    'CA-PI-DOG-BITE-SOL-2-YEARS',
    5,
    'CA Dog Bite Statute of Limitations (2 Years)',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'CA',
    NULL,
    NULL,
    '{
        "statute": "Cal. Code Civ. Proc. § 335.1",
        "effective_date": "Added by Stats. 2002, Ch. 448, Sec. 1, effective January 1, 2003",
        "statute_of_limitations": "2 years",
        "accrual_date": "Date of dog bite injury",
        "key_requirements": [
            "Complaint must be filed within 2 years of the date of the dog bite",
            "Applies to strict liability claims under Cal. Civ. Code § 3342",
            "Applies to negligence claims and other dog bite theories",
            "Failure to file within 2 years bars recovery"
        ],
        "tolling_for_minors": [
            "Statute tolled for minors (under 18 years of age)",
            "Tolling continues until minor turns 18",
            "Minor has until age 20 to file lawsuit (18 + 2 years)"
        ],
        "other_tolling_provisions": [
            "Delayed discovery of injury (limited circumstances)",
            "Mental incapacity",
            "Defendant''s absence from California"
        ],
        "consequence_of_violation": "Claim time-barred; court will dismiss case; no recovery possible",
        "strategic_note": "California has shorter SOL (2 years) than many states (3 years)"
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

-- Rule 3: California Military/Police Dog Exception
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
    'CA-PI-DOG-BITE-POLICE-DOG-EXCEPTION',
    5,
    'CA Dog Bite Military/Police Dog Exception',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'CA',
    NULL,
    NULL,
    '{
        "statute": "Cal. Civ. Code § 3342(b), (c), (d)",
        "exception_applies": "Governmental agency using dog in military or police work",
        "conditions_for_immunity": [
            "Dog was defending itself from annoying, harassing, or provoking act",
            "OR dog was assisting employee in: apprehending/holding suspect (reasonable suspicion), investigating crime, executing warrant, defending officer/person",
            "Agency must have written policy on necessary and appropriate use of dogs",
            "Victim was party to, participant in, or suspected party/participant in act that prompted dog use"
        ],
        "exception_does_NOT_apply_if": [
            "Victim was not a party to, participant in, nor suspected to be party/participant in the act that prompted dog use (Cal. Civ. Code § 3342(c))",
            "Agency does not have written policy on dog use (Cal. Civ. Code § 3342(d))"
        ],
        "practical_effect": "Police/military dogs have immunity if victim was suspect or involved in criminal activity AND agency has written policy",
        "innocent_bystanders": "Exception does NOT apply to innocent bystanders - they retain full right to sue under Cal. Civ. Code § 3342",
        "note": "Similar to Arizona exception but with additional written policy requirement"
    }'::jsonb,
    'info',
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

-- Rule 4: California Negligence (Alternative Theory)
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
    'CA-PI-DOG-BITE-NEGLIGENCE-ALTERNATIVE',
    5,
    'CA Dog Bite Negligence (Alternative Theory)',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'CA',
    NULL,
    NULL,
    '{
        "liability_theory": "common_law_negligence",
        "when_to_use": [
            "Victim was injured by dog but NOT bitten (e.g., knocked over, chased)",
            "Victim was trespassing (strict liability does not apply)",
            "Alternative theory to pursue alongside strict liability"
        ],
        "elements_to_prove": [
            "Owner owed a duty of care",
            "Owner breached that duty (failed to control or restrain dog)",
            "Breach proximately caused plaintiff''s injury",
            "Plaintiff suffered damages"
        ],
        "advantages_of_strict_liability": [
            "Cal. Civ. Code § 3342 strict liability is easier to prove (no need to prove negligence)",
            "Strict liability applies even if owner exercised reasonable care",
            "Negligence theory useful only when strict liability unavailable"
        ],
        "strategic_note": "Always plead both strict liability (Cal. Civ. Code § 3342) and negligence in complaint to maximize recovery options"
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
-- END OF CALIFORNIA DOG BITE RULES SEED FILE
-- =====================================================================================
