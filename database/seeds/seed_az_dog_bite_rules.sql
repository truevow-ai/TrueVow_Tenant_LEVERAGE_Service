-- =====================================================================================
-- ARIZONA DOG BITE LIABILITY RULES SEED FILE
-- =====================================================================================
-- State: Arizona (AZ)
-- Sub-Specialization: Dog Bite (Personal Injury)
-- Liability Model: STRICT LIABILITY (Statutory)
-- Legal Standard: Owner liable regardless of dog's prior viciousness or owner's knowledge
-- Primary Authority: ARS § 11-1025
-- Statute of Limitations: 1 year (ARS § 12-541 - statutory liability)
--                        2 years (ARS § 12-542 - negligence claims)
-- 
-- VERIFICATION STATUS: DOCUMENT VERIFIED
-- Research Date: January 30, 2026
-- Sources Verified:
--   1. ARS § 11-1025 - Liability for dog bites (full text retrieved)
--   2. ARS § 12-541 - One year limitation for liability created by statute
--   3. ARS § 12-542 - Two year limitation for personal injury (negligence)
--   4. https://www.azleg.gov/ars/11/01025.htm (official Arizona Legislature website)
--   5. https://www.azleg.gov/ars/12/00541.htm (official Arizona Legislature website)
-- =====================================================================================

-- =====================================================================================
-- PART 1: LEGAL SOURCES
-- =====================================================================================

-- Source 1: Arizona Strict Liability Statute (ARS 11-1025)
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
    'AZ',
    NULL,
    NULL,
    'Arizona Dog Bite Strict Liability Statute',
    'Arizona Legislature',
    'ARS § 11-1025',
    'https://www.azleg.gov/ars/11/01025.htm',
    'statute',
    'high',
    'ARS § 11-1025 - Liability for dog bites; owner information; military and police work; definitions

A. The owner of a dog that bites a person when the person is in or on a public place or lawfully in or on a private place, including the property of the owner of the dog, is liable for damages suffered by the person bitten, regardless of the former viciousness of the dog or the owner''s knowledge of its viciousness.

B. A person who owns or is responsible for the care of a dog that bites a person when the person is in or on a public place or lawfully in or on a private place, including the property of the owner of the dog, shall provide the owner''s contact information to the person who suffered the dog bite.

C. The breed of a dog may not be considered in findings of facts or conclusions of law entered by a court, administrative law judge, hearing officer, arbitrator or other legal decision-maker regarding whether a dog is aggressive or vicious or has created liability.

D. This section and section 11-1020 do not allow the bringing of an action for damages against any governmental agency using a dog in military or police work if the bite occurred while the dog was defending itself from a harassing or provoking act or assisting an employee of the agency in: (1) Apprehending or holding a suspect if the employee had a reasonable suspicion of the suspect''s involvement in criminal activity; (2) Investigating a crime or possible crime; (3) Executing a warrant; (4) Defending a peace officer or another person.

E. Subsection D does not apply if the victim was not a party to, participant in, nor suspected to be a party to or participant in, the act that prompted the use of the dog.

F. Subsection D applies only if a governmental agency using a dog in military or police work has adopted a written policy on the necessary and appropriate use of a dog.

G. Definitions: (1) "Aggressive" means that a dog has bitten a person or domestic animal without provocation or has a known history of attacking persons or domestic animals without provocation. (2) "Breed" means the actual or perceived breed or mixture of breeds of a dog. (3) "Provocation" means tormenting, attacking or inciting a dog and includes the standard for determining provocation prescribed in section 11-1027. (4) "Vicious" means that a dog has a propensity to attack, to cause injury to or to otherwise endanger the safety of human beings without provocation or has been found to have any of these traits after a hearing. DOCUMENT VERIFIED.'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET
    base_url = EXCLUDED.base_url,
    notes = EXCLUDED.notes;

-- Source 2: Arizona Statute of Limitations - Statutory Liability (ARS 12-541)
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
    'AZ',
    NULL,
    NULL,
    'Arizona Statute of Limitations - Dog Bite (Statutory Liability)',
    'Arizona Legislature',
    'ARS § 12-541',
    'https://www.azleg.gov/ars/12/00541.htm',
    'statute',
    'high',
    'ARS § 12-541 - Malicious prosecution; false imprisonment; libel or slander; seduction or breach of promise of marriage; breach of employment contract; wrongful termination; liability created by statute; one year limitation

There shall be commenced and prosecuted within one year after the cause of action accrues, and not afterward, the following actions:

1. For malicious prosecution, or for false imprisonment, or for injuries done to the character or reputation of another by libel or slander.
2. For damages for seduction or breach of promise of marriage.
3. For breach of an oral or written employment contract including contract actions based on employee handbooks or policy manuals that do not specify a time period in which to bring an action.
4. For damages for wrongful termination.
5. Upon a liability created by statute, other than a penalty or forfeiture.

APPLICATION TO DOG BITES: Claims brought under ARS § 11-1025 (strict liability statute) are subject to this ONE YEAR statute of limitations because ARS § 11-1025 creates a statutory liability. The one-year period begins on the date of the dog bite injury. DOCUMENT VERIFIED.'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET
    base_url = EXCLUDED.base_url,
    notes = EXCLUDED.notes;

-- Source 3: Arizona Statute of Limitations - Negligence Claims (ARS 12-542)
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
    'AZ',
    NULL,
    NULL,
    'Arizona Statute of Limitations - Dog Bite (Negligence)',
    'Arizona Legislature',
    'ARS § 12-542',
    'https://www.azleg.gov/ars/12/00542.htm',
    'statute',
    'high',
    'ARS § 12-542 - Injury to person; injury when death ensues; injury to property; conversion of property; forcible entry and forcible detainer; two year limitation

There shall be commenced and prosecuted within two years after the cause of action accrues all actions for: injury to person, injury when death ensues, injury to property, conversion of property, and forcible entry or detainer.

APPLICATION TO DOG BITES: If a plaintiff brings a negligence claim (not under ARS § 11-1025 strict liability), the TWO YEAR statute of limitations applies. Negligence claims require proof that the owner failed to exercise reasonable care in controlling or restraining the dog. The two-year period begins on the date of the dog bite injury. Note: Strict liability claims under ARS § 11-1025 are preferable because they have a lower burden of proof, but they must be filed within ONE YEAR (ARS § 12-541). DOCUMENT VERIFIED.'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET
    base_url = EXCLUDED.base_url,
    notes = EXCLUDED.notes;

-- =====================================================================================
-- PART 2: VALIDATION RULES
-- =====================================================================================

-- Rule 1: Arizona Strict Liability (ARS 11-1025)
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
    'AZ-PI-DOG-BITE-STRICT-LIABILITY',
    5,
    'AZ Dog Bite Strict Liability (ARS 11-1025)',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'AZ',
    NULL,
    NULL,
    '{
        "liability_model": "strict_liability",
        "statute": "ARS § 11-1025",
        "legal_standard": "Owner liable regardless of former viciousness or owner''s knowledge",
        "key_requirements": [
            "Dog bite occurred",
            "Victim was in or on a public place OR lawfully in or on a private place",
            "Victim includes property of owner of the dog",
            "Owner is liable regardless of dog''s prior viciousness",
            "Owner is liable regardless of owner''s knowledge of viciousness"
        ],
        "no_proof_required": [
            "No proof of prior vicious behavior required",
            "No proof of owner negligence required",
            "No proof of owner knowledge required"
        ],
        "location_coverage": [
            "Public places",
            "Private places where victim was lawfully present",
            "Owner''s own property (if victim lawfully present)"
        ],
        "defenses": [
            "Provocation: tormenting, attacking or inciting the dog (see ARS § 11-1027)",
            "Victim was trespassing (not lawfully on private property)",
            "Military/police dog exception (if victim was suspect or participant in crime and agency has written policy)"
        ],
        "breed_neutrality": "Dog breed may NOT be considered in determining liability",
        "damages": "Full compensatory damages (economic + non-economic)",
        "advantages": "Easiest to prove - no need to show prior knowledge or negligence"
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

-- Rule 2: Arizona Statute of Limitations - Strict Liability Claims (1 Year)
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
    'AZ-PI-DOG-BITE-SOL-1-YEAR-STATUTORY',
    5,
    'AZ Dog Bite SOL - 1 Year (Strict Liability Claims)',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'AZ',
    NULL,
    NULL,
    '{
        "statute": "ARS § 12-541(5)",
        "statute_of_limitations": "1 year",
        "applies_to": "Claims brought under ARS § 11-1025 (strict liability statute)",
        "accrual_date": "Date of dog bite injury",
        "key_requirements": [
            "Complaint must be filed within 1 year of the date of the dog bite",
            "Applies to statutory liability claims under ARS § 11-1025",
            "One year is shorter than general personal injury SOL (2 years)"
        ],
        "rationale": "ARS § 11-1025 creates a statutory liability, so ARS § 12-541(5) applies",
        "strategic_note": "Strict liability claims are easier to prove but must be filed faster (1 year vs 2 years for negligence)",
        "consequence_of_violation": "Claim time-barred; no recovery possible under strict liability statute",
        "alternative": "If 1-year deadline missed, may still pursue negligence claim if within 2 years (ARS § 12-542)"
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

-- Rule 3: Arizona Statute of Limitations - Negligence Claims (2 Years)
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
    'AZ-PI-DOG-BITE-SOL-2-YEARS-NEGLIGENCE',
    5,
    'AZ Dog Bite SOL - 2 Years (Negligence Claims)',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'AZ',
    NULL,
    NULL,
    '{
        "statute": "ARS § 12-542",
        "statute_of_limitations": "2 years",
        "applies_to": "Common law negligence claims (not strict liability under ARS § 11-1025)",
        "accrual_date": "Date of dog bite injury",
        "key_requirements": [
            "Complaint must be filed within 2 years of the date of the dog bite",
            "Applies to negligence claims (owner failed to exercise reasonable care)",
            "Higher burden of proof than strict liability but longer deadline"
        ],
        "elements_to_prove": [
            "Owner owed a duty of care",
            "Owner breached that duty (failed to control or restrain dog)",
            "Breach proximately caused plaintiff''s injury",
            "Plaintiff suffered damages"
        ],
        "strategic_note": "Less favorable than strict liability (higher burden) but useful if 1-year strict liability deadline missed",
        "consequence_of_violation": "Claim time-barred; no recovery possible"
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

-- Rule 4: Arizona Military/Police Dog Exception
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
    'AZ-PI-DOG-BITE-POLICE-DOG-EXCEPTION',
    5,
    'AZ Dog Bite Military/Police Dog Exception',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'AZ',
    NULL,
    NULL,
    '{
        "statute": "ARS § 11-1025(D), (E), (F)",
        "exception_applies": "Governmental agency using dog in military or police work",
        "conditions_for_immunity": [
            "Dog was defending itself from harassing or provoking act",
            "OR dog was assisting employee in: apprehending/holding suspect, investigating crime, executing warrant, defending officer/person",
            "Agency must have written policy on necessary and appropriate use of dogs",
            "Victim was party to, participant in, or suspected party/participant in act that prompted use of dog"
        ],
        "exception_does_NOT_apply_if": [
            "Victim was not a party to, participant in, nor suspected to be party/participant in the act that prompted dog use",
            "Agency does not have written policy on dog use"
        ],
        "practical_effect": "Police/military dogs have immunity if victim was suspect or involved in criminal activity AND agency has written policy",
        "innocent_bystanders": "Exception does NOT apply to innocent bystanders - they retain full right to sue under ARS § 11-1025"
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

-- =====================================================================================
-- END OF ARIZONA DOG BITE RULES SEED FILE
-- =====================================================================================
