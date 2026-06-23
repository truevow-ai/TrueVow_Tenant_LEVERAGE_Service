-- =====================================================================================
-- DELAWARE DOG BITE LIABILITY RULES SEED FILE
-- =====================================================================================
-- State: Delaware (DE)
-- Sub-Specialization: Dog Bite (Personal Injury)
-- Liability Model: STRICT LIABILITY (Statutory - since 1770)
-- Legal Standard: Owner liable for injury/death/property damage without proof of negligence
-- Primary Authority: 16 Del. C. § 3053F
-- Statute of Limitations: 2 years (10 Del. C. § 8119)
-- 
-- VERIFICATION STATUS: DOCUMENT VERIFIED
-- Research Date: January 30, 2026
-- Sources Verified:
--   1. 16 Del. C. § 3053F - Strict liability statute verified from multiple sources
--   2. 10 Del. C. § 8119 - 2-year SOL for personal injury
--   3. https://delcode.delaware.gov/title16/c030f/sc04/ (Delaware Code Online)
--   4. Riad v. Brandywine Valley SPCA case law
-- =====================================================================================

-- =====================================================================================
-- PART 1: LEGAL SOURCES
-- =====================================================================================

-- Source 1: Delaware Strict Liability Statute (16 Del. C. § 3053F)
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
    'DE',
    NULL,
    NULL,
    'Delaware Dog Bite Strict Liability Statute',
    'Delaware Legislature',
    '16 Del. C. § 3053F',
    'https://delcode.delaware.gov/title16/c030f/sc04/',
    'statute',
    'high',
    '16 Del. C. § 3053F - Liability of owner for injury, death, or property damage:

A dog owner is liable for any injury, death, or property damage caused by their dog UNLESS the owner can prove that the injury was caused while the victim was:
(1) Trespassing or attempting to commit a criminal offense, OR
(2) Teasing, tormenting, or abusing the dog.

KEY PROVISIONS:
- STRICT LIABILITY: Owner liable without proof of negligence or prior knowledge of dog''s viciousness
- NO ONE-BITE RULE: Delaware does NOT require proof of prior dangerous behavior
- BROAD DEFINITION OF "OWNER": Includes any person who owns, keeps, harbors, or is the custodian of a dog (16 Del. C. § 3041F(7))
- COVERS ALL INJURIES: Not limited to bites - includes injuries from jumping, knocking down, or any other dog-caused harm
- HISTORICAL NOTE: Delaware has imposed strict liability on dog owners since 1770

CASE LAW INTERPRETATION:
- Riad v. Brandywine Valley SPCA: Delaware Supreme Court held that "owner" broadly includes animal shelters and welfare organizations that keep, harbor, or have custody of dogs. The statute applies to any entity meeting the definition of "owner" under 16 Del. C. § 3041F(7). Expert testimony NOT required to establish standard of care for controlling aggressive dogs (within common knowledge of laypersons).

EXCEPTION FOR ANIMAL SHELTERS: Although animal shelters can be "owners" under the statute, liability depends on whether they were the keeper or custodian at time of bite.

RELATED PROVISIONS:
- 16 Del. C. § 3048F: Dogs running at large - owner fined $100-$500 (first offense) if dog bites without provocation while at large
- 16 Del. C. § 3079F: Dangerous/potentially dangerous dogs - violations and penalties

DOCUMENT VERIFIED from Delaware Code Online and Delaware Supreme Court case law.'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET
    base_url = EXCLUDED.base_url,
    notes = EXCLUDED.notes;

-- Source 2: Delaware Statute of Limitations - Personal Injury (10 Del. C. § 8119)
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
    'DE',
    NULL,
    NULL,
    'Delaware Statute of Limitations - Personal Injury (Dog Bite)',
    'Delaware Legislature',
    '10 Del. C. § 8119',
    'https://delcode.delaware.gov/title10/c081/',
    'statute',
    'high',
    '10 Del. C. § 8119 - Statute of limitations for tort actions:

Personal injury actions, including dog bite claims, must be brought within TWO YEARS from the date the injury was sustained.

APPLICATION TO DOG BITES: Claims brought under 16 Del. C. § 3053F (strict liability statute) are subject to this TWO YEAR statute of limitations. The two-year period begins on the date of the dog bite injury.

TOLLING PROVISIONS:
- Inherently unknowable injuries: Statute tolled if injury is inherently unknowable and claimant is blamelessly ignorant of wrongful act and injury; clock begins once facts are discoverable
- Minors: Limitation period is 3 years from minor''s 18th birthday
- Government claims: Must be filed within 1 year of injury
- Non-resident plaintiff: Time plaintiff resides outside Delaware does NOT count toward limitations period

DOCUMENT VERIFIED from Delaware Code Online.'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET
    base_url = EXCLUDED.base_url,
    notes = EXCLUDED.notes;

-- =====================================================================================
-- PART 2: VALIDATION RULES
-- =====================================================================================

-- Rule 1: Delaware Strict Liability (16 Del. C. § 3053F)
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
    'DE-PI-DOG-BITE-STRICT-LIABILITY',
    5,
    'DE Dog Bite Strict Liability (16 Del. C. § 3053F)',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'DE',
    NULL,
    NULL,
    '{
        "liability_model": "strict_liability",
        "statute": "16 Del. C. § 3053F",
        "historical_note": "Delaware has imposed strict liability on dog owners since 1770",
        "legal_standard": "Owner liable without proof of negligence or prior knowledge of viciousness",
        "key_requirements": [
            "Dog caused injury, death, or property damage",
            "Defendant was owner, keeper, harborer, or custodian of dog",
            "Victim was NOT trespassing or attempting to commit criminal offense",
            "Victim was NOT teasing, tormenting, or abusing dog",
            "Owner is liable regardless of dog''s prior viciousness",
            "Owner is liable regardless of owner''s knowledge of viciousness"
        ],
        "owner_definition": "Any person who owns, keeps, harbors, or is the custodian of a dog (16 Del. C. § 3041F(7))",
        "broad_coverage": [
            "Not limited to bites - covers ALL dog-caused injuries",
            "Includes injuries from jumping, knocking down, chasing, or any dog behavior",
            "Covers injury to persons and property damage"
        ],
        "no_proof_required": [
            "No proof of prior vicious behavior required",
            "No proof of owner negligence required",
            "No proof of owner knowledge required",
            "Delaware does NOT follow the one-bite rule"
        ],
        "exceptions_no_liability": [
            "Victim was trespassing at time of injury",
            "Victim was attempting to commit a criminal offense",
            "Victim was teasing, tormenting, or abusing the dog"
        ],
        "burden_of_proof": "Owner must PROVE exception applies (not victim''s burden)",
        "damages_recoverable": [
            "Medical expenses, lost wages, pain and suffering",
            "Property damage",
            "Permanent scarring or disfigurement",
            "Death damages (wrongful death)",
            "Emotional trauma"
        ],
        "liable_parties": [
            "Dog owners",
            "Dog keepers",
            "Dog harborers",
            "Dog custodians",
            "Animal shelters (if keeper/custodian at time of bite - see Riad v. Brandywine Valley SPCA)"
        ],
        "case_law_notes": [
            "Riad v. Brandywine Valley SPCA: Animal shelters can be liable as owners/custodians",
            "Expert testimony NOT required to establish standard of care (within common knowledge)"
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

-- Rule 2: Delaware Statute of Limitations - 2 Years
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
    'DE-PI-DOG-BITE-SOL-2-YEARS',
    5,
    'DE Dog Bite Statute of Limitations (2 Years)',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'DE',
    NULL,
    NULL,
    '{
        "statute": "10 Del. C. § 8119",
        "statute_of_limitations": "2 years",
        "accrual_date": "Date the injury was sustained (dog bite injury)",
        "key_requirements": [
            "Complaint must be filed within 2 years of the date of the dog bite",
            "Applies to strict liability claims under 16 Del. C. § 3053F",
            "Applies to all personal injury tort actions",
            "Failure to file within 2 years bars recovery"
        ],
        "tolling_provisions": [
            "Inherently unknowable injuries: Statute tolled if injury unknowable and claimant blamelessly ignorant; clock starts when facts discoverable",
            "Minors: 3 years from 18th birthday",
            "Government claims: 1 year (shorter deadline)",
            "Non-resident plaintiff: Time outside Delaware does NOT count toward limitations period"
        ],
        "strategic_note": "Government claims have shorter 1-year deadline",
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

-- Rule 3: Delaware Dogs Running at Large (16 Del. C. § 3048F)
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
    'DE-PI-DOG-BITE-RUNNING-AT-LARGE',
    5,
    'DE Dog Running at Large - Enhanced Liability',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'DE',
    NULL,
    NULL,
    '{
        "statute": "16 Del. C. § 3048F",
        "liability_theory": "running_at_large_violation",
        "key_requirements": [
            "Dog was running at large (off owner''s property without leash/control)",
            "Dog bit person without provocation",
            "Owner or custodian can be fined $100-$500 (first offense)",
            "Subsequent offenses: $750-$1,500"
        ],
        "running_at_large_definition": "Dog outside owner''s property unless: (1) in designated off-leash area, OR (2) working dog performing specific tasks",
        "enhanced_penalties": "Fines are IN ADDITION to civil liability under 16 Del. C. § 3053F",
        "strategic_note": "Running at large violation provides additional evidence of owner negligence and establishes violation of Delaware law"
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
-- END OF DELAWARE DOG BITE RULES SEED FILE
-- =====================================================================================
