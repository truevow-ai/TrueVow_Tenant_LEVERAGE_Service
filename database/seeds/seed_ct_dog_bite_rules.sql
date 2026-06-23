-- =====================================================================================
-- CONNECTICUT DOG BITE LIABILITY RULES SEED FILE
-- =====================================================================================
-- State: Connecticut (CT)
-- Sub-Specialization: Dog Bite (Personal Injury)
-- Liability Model: STRICT LIABILITY (Statutory)
-- Legal Standard: Owner/keeper liable regardless of viciousness or knowledge
-- Primary Authority: Conn. Gen. Stat. § 22-357
-- Statute of Limitations: 3 years (Conn. Gen. Stat. § 52-577)
-- 
-- VERIFICATION STATUS: DOCUMENT VERIFIED
-- Research Date: January 30, 2026
-- Sources Verified:
--   1. Conn. Gen. Stat. § 22-357 - Statute description verified from multiple sources
--   2. Conn. Gen. Stat. § 52-577 - 3-year SOL for tort actions
--   3. https://www.cga.ct.gov/2012/rpt/2012-R-0459.htm (Connecticut General Assembly)
--   4. https://www.cga.ct.gov/2025/pub/chap_926.htm (Statute of Limitations)
-- =====================================================================================

-- =====================================================================================
-- PART 1: LEGAL SOURCES
-- =====================================================================================

-- Source 1: Connecticut Strict Liability Statute (CGS § 22-357)
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
    'CT',
    NULL,
    NULL,
    'Connecticut Dog Bite Strict Liability Statute',
    'Connecticut Legislature',
    'Conn. Gen. Stat. § 22-357',
    'https://www.cga.ct.gov/2012/rpt/2012-R-0459.htm',
    'statute',
    'high',
    'Conn. Gen. Stat. § 22-357 - Damage by dogs to person or property:

A dog''s owner or keeper is liable for any damage caused by his or her dog to a person''s body or property, unless the damage was sustained while the person was committing a trespass or other tort or was teasing, abusing, or tormenting the dog.

KEY PROVISIONS:
- STRICT LIABILITY: Owner or keeper liable regardless of dog''s viciousness or owner''s knowledge of viciousness
- EXCEPTIONS: No liability if damage occurred while victim was (1) committing trespass or other tort, OR (2) teasing, abusing, or tormenting the dog
- MINOR OWNERS: If the owner or keeper is a minor, their parent or guardian is liable
- PRESUMPTION FOR YOUNG CHILDREN: For anyone under age 7, it is presumed they were NOT committing trespass or teasing the dog unless defendant proves otherwise
- MULTIPLE DOGS: If damage caused by two or more dogs at same time kept by different persons, owners are jointly and severally liable (CGS § 22-356)
- DAMAGES INCLUDE: Veterinary expenses, fair value of dog (including training and burial costs), and other related expenses

CASE LAW INTERPRETATION:
- "Trespass" exception requires more than mere technical trespass of uninvited entry; requires something serious that would naturally arouse an ordinary dog to protect owner''s property or family (Verrilli v. Damilowski, 140 Conn. 358, 363 (1953))
- Teasing, abusing, or tormenting must be substantial; e.g., two-and-a-half year-old throwing rubber bone for dog to retrieve was NOT teasing (Weingartner v. Bielak, 142 Conn. 516 (1955))

COMMON LAW ALTERNATIVE: Victim can also pursue common law negligence by proving owner knew or should have known dog was vicious

LANDLORD LIABILITY: Landlord can be liable under common law premises liability if landlord knew of tenant''s dog''s dangerous tendencies and failed to take reasonable steps to alleviate known danger (Giacalone v. Housing Authority of Town of Wallingford, 306 Conn. 399 (2012))

DOCUMENT VERIFIED from Connecticut General Assembly Office of Legislative Research Report 2012-R-0459.'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET
    base_url = EXCLUDED.base_url,
    notes = EXCLUDED.notes;

-- Source 2: Connecticut Statute of Limitations - Tort Actions (CGS § 52-577)
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
    'CT',
    NULL,
    NULL,
    'Connecticut Statute of Limitations - Tort Actions (Dog Bite)',
    'Connecticut Legislature',
    'Conn. Gen. Stat. § 52-577',
    'https://www.cga.ct.gov/2025/pub/chap_926.htm',
    'statute',
    'high',
    'Conn. Gen. Stat. § 52-577 - Actions founded upon a tort:

Actions based on a tort must be brought within three years from the date of the act or omission that is being complained about.

APPLICATION TO DOG BITES: Claims brought under CGS § 22-357 (strict liability statute) and common law negligence claims are subject to this THREE YEAR statute of limitations. The three-year period begins on the date of the dog bite injury. DOCUMENT VERIFIED from Connecticut General Assembly Chapter 926 (Statute of Limitations).'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET
    base_url = EXCLUDED.base_url,
    notes = EXCLUDED.notes;

-- =====================================================================================
-- PART 2: VALIDATION RULES
-- =====================================================================================

-- Rule 1: Connecticut Strict Liability (CGS § 22-357)
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
    'CT-PI-DOG-BITE-STRICT-LIABILITY',
    5,
    'CT Dog Bite Strict Liability (CGS § 22-357)',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'CT',
    NULL,
    NULL,
    '{
        "liability_model": "strict_liability",
        "statute": "Conn. Gen. Stat. § 22-357",
        "legal_standard": "Owner/keeper liable regardless of dog''s viciousness or owner''s knowledge",
        "key_requirements": [
            "Dog caused damage to person''s body or property",
            "Defendant was owner or keeper of dog",
            "Victim was not committing trespass or other tort",
            "Victim was not teasing, abusing, or tormenting dog",
            "Owner/keeper is liable regardless of dog''s prior viciousness",
            "Owner/keeper is liable regardless of owner''s knowledge of viciousness"
        ],
        "keeper_definition": "Person (other than owner) who harbors or exercises control over dog, such as feeding or sheltering it",
        "no_proof_required": [
            "No proof of prior vicious behavior required",
            "No proof of owner negligence required",
            "No proof of owner knowledge required",
            "Connecticut does NOT follow the one-bite rule for statutory claims"
        ],
        "damages_recoverable": [
            "Bodily injuries",
            "Property damage",
            "Veterinary expenses (if victim''s pet injured)",
            "Fair value of dog (including training and burial costs)",
            "Medical expenses, lost wages, pain and suffering (all recoverable)"
        ],
        "exceptions_no_liability": [
            "Victim was committing trespass (must be more than mere technical trespass - must be conduct that would naturally arouse dog to protect property/family)",
            "Victim was committing other tort",
            "Victim was teasing, abusing, or tormenting dog (must be substantial provocation)"
        ],
        "presumption_for_minors": "For children under age 7: presumed they were NOT trespassing or teasing dog; burden on defendant to prove otherwise",
        "minor_owner_liability": "If owner or keeper is a minor, their parent or guardian is liable",
        "multiple_dogs": "If damage caused by multiple dogs kept by different persons, owners are jointly and severally liable (CGS § 22-356)",
        "case_law_notes": [
            "Verrilli v. Damilowski (1953): Trespass exception requires more than uninvited entry",
            "Weingartner v. Bielak (1955): 2.5-year-old throwing rubber bone for dog NOT teasing"
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

-- Rule 2: Connecticut Common Law Negligence (Alternative Theory)
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
    'CT-PI-DOG-BITE-NEGLIGENCE',
    5,
    'CT Dog Bite Common Law Negligence',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'CT',
    NULL,
    NULL,
    '{
        "liability_theory": "common_law_negligence",
        "when_to_use": [
            "Alternative theory to pursue alongside strict liability",
            "May provide additional damages",
            "Can be used if statutory exceptions apply (e.g., victim was trespassing)"
        ],
        "elements_to_prove": [
            "Owner or keeper owed a duty of care",
            "Owner or keeper knew or should have known dog was vicious",
            "Owner or keeper breached that duty",
            "Breach proximately caused plaintiff''s injury",
            "Plaintiff suffered damages"
        ],
        "advantages_of_strict_liability": [
            "CGS § 22-357 strict liability is easier to prove (no need to prove owner knew dog was vicious)",
            "Strict liability applies even if owner exercised reasonable care",
            "Negligence theory useful as alternative when strict liability defenses may apply"
        ],
        "strategic_note": "Always plead both strict liability (CGS § 22-357) and common law negligence to maximize recovery options"
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

-- Rule 3: Connecticut Landlord Liability
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
    'CT-PI-DOG-BITE-LANDLORD-LIABILITY',
    5,
    'CT Dog Bite Landlord Liability (Premises Liability)',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'CT',
    NULL,
    NULL,
    '{
        "liability_theory": "common_law_premises_liability",
        "case_law": "Giacalone v. Housing Authority of Town of Wallingford, 306 Conn. 399 (2012)",
        "key_requirements": [
            "Landlord knew or should have known of tenant''s dog''s vicious tendencies",
            "Dog bite occurred on common part of property over which landlord retains control",
            "Landlord failed to take reasonable steps to alleviate known danger"
        ],
        "reasonable_steps_may_include": [
            "Warning victim that dangerous animal was present",
            "Ensuring dog was removed after landlord ordered removal",
            "Taking action to protect tenants and visitors from known dangerous dog"
        ],
        "liable_parties": [
            "Landlords",
            "Housing authorities",
            "Property management companies",
            "Anyone with control over common areas where dog is present"
        ],
        "strategic_note": "Landlord liability is under common law premises liability, NOT under CGS § 22-357 strict liability statute"
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

-- Rule 4: Connecticut Statute of Limitations - 3 Years
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
    'CT-PI-DOG-BITE-SOL-3-YEARS',
    5,
    'CT Dog Bite Statute of Limitations (3 Years)',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'CT',
    NULL,
    NULL,
    '{
        "statute": "Conn. Gen. Stat. § 52-577",
        "statute_of_limitations": "3 years",
        "accrual_date": "Date of the act or omission (dog bite injury)",
        "key_requirements": [
            "Complaint must be filed within 3 years of the date of the dog bite",
            "Applies to strict liability claims under CGS § 22-357",
            "Applies to common law negligence claims",
            "Failure to file within 3 years bars recovery"
        ],
        "tolling_provisions": [
            "Defendant''s absence from Connecticut may extend deadline to 7 years",
            "Minority or legal incapacity may toll statute",
            "Fraudulent concealment may toll statute"
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

-- =====================================================================================
-- END OF CONNECTICUT DOG BITE RULES SEED FILE
-- =====================================================================================
