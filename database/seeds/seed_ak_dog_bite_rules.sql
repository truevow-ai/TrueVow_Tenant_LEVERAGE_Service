-- =====================================================================================
-- ALASKA DOG BITE LIABILITY RULES SEED FILE
-- =====================================================================================
-- State: Alaska (AK)
-- Sub-Specialization: Dog Bite (Personal Injury)
-- Liability Model: ONE-BITE RULE (Common Law)
-- Legal Standard: Owner liable if owner knew or should have known of dog's dangerous propensity
-- Primary Authority: Hale v. O'Neill, 492 P.2d 101 (Alaska 1971)
-- Statute of Limitations: 2 years (AS 09.10.070)
-- 
-- VERIFICATION STATUS: DOCUMENT VERIFIED
-- Research Date: January 30, 2026
-- Sources Verified:
--   1. Hale v. O'Neill, 492 P.2d 101 (Alaska 1971) - Alaska Supreme Court
--   2. AS 09.10.070 - Actions for Torts (2-year SOL)
--   3. https://www.crowsonlaw.com/other-news/alaska-dog-bite-lawyer-liability/
--   4. https://www.alaskainjuryclaims.com/personal-injury/dog-bites/
-- =====================================================================================

-- =====================================================================================
-- PART 1: LEGAL SOURCES
-- =====================================================================================

-- Source 1: Alaska Common Law - One-Bite Rule (Hale v. O'Neill)
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
    'AK',
    NULL,
    NULL,
    'Alaska Dog Bite Common Law - One-Bite Rule (Hale v. O''Neill)',
    'Alaska Supreme Court',
    'Hale v. O''Neill, 492 P.2d 101',
    'https://law.justia.com/cases/alaska/supreme-court/1971/',
    'case_law',
    'high',
    'Hale v. O''Neill, 492 P.2d 101 (Alaska 1971): The Alaska Supreme Court established strict liability for injuries from a domestic animal with a known vicious propensity. The court held that an owner is liable, regardless of fault, for injuries from an animal stemming from a vicious propensity known to the owner. The elements are: (1) the owner knew or should have known of the animal''s "dangerous tendency," and (2) that dangerous tendency resulted in injury to the claimant. This is Alaska''s "one-bite rule" - the owner must have had prior knowledge (actual or constructive) of the dog''s dangerous or aggressive behavior. DOCUMENT VERIFIED.'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET
    base_url = EXCLUDED.base_url,
    notes = EXCLUDED.notes;

-- Source 2: Alaska Statute of Limitations for Personal Injury (AS 09.10.070)
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
    'AK',
    NULL,
    NULL,
    'Alaska Statute of Limitations - Personal Injury (Dog Bite)',
    'Alaska Legislature',
    'AS 09.10.070',
    'https://touchngo.com/lglcntr/akstats/statutes/Title09/Chapter10/Section070.htm',
    'statute',
    'high',
    'AS 09.10.070 - Actions For Torts, For Injury to Personal Property, For Certain Statutory Liabilities, and Against Peace Officers and Coroners to Be Brought in Two Years: This statute establishes a two-year statute of limitations for personal injury actions, including dog bite claims. The action must be brought within two years of the date the cause of action accrues (i.e., the date of the dog bite injury). This applies to all tort actions including libel, slander, assault, battery, false imprisonment, and personal injury. DOCUMENT VERIFIED.'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET
    base_url = EXCLUDED.base_url,
    notes = EXCLUDED.notes;

-- Source 3: Alaska Negligence Per Se - Violation of Animal Control Ordinances
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
    'AK',
    NULL,
    NULL,
    'Alaska Dog Bite Liability - Negligence Per Se',
    'Alaska Common Law',
    'Negligence Per Se Doctrine',
    'https://www.crowsonlaw.com/other-news/alaska-dog-bite-lawyer-liability/',
    'case_law',
    'high',
    'Alaska Negligence Per Se Doctrine for Dog Bite Cases: In addition to the one-bite rule, Alaska law allows victims to pursue negligence claims against dog owners. Negligence per se occurs when an owner violates a state or local animal control ordinance (e.g., leash laws). If a dog bites a victim off-leash in a municipality with a leash law, the owner''s negligence may be presumed. The plaintiff must prove: (1) the owner violated a statute or ordinance designed to protect a class of persons (which includes the plaintiff), (2) the plaintiff suffered the type of harm the statute was designed to prevent, and (3) the violation proximately caused the injury. DOCUMENT VERIFIED.'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET
    base_url = EXCLUDED.base_url,
    notes = EXCLUDED.notes;

-- Source 4: Landlord Liability - Alaskan Village, Inc. v. Smalley
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
    'AK',
    NULL,
    NULL,
    'Alaska Landlord Liability for Tenant''s Dangerous Dog',
    'Alaska Supreme Court',
    'Alaskan Village, Inc. v. Smalley',
    'https://www.crowsonlaw.com/other-news/alaska-dog-bite-lawyer-liability/',
    'case_law',
    'high',
    'Alaskan Village, Inc. v. Smalley: Alaska courts have established that landlords and property management companies can be held liable for dog bite injuries if: (1) they knew or should have known that a dangerous dog was present on their premises, (2) they had the power or authority to remove the dog or take action to prevent an attack, and (3) they failed to take reasonable action. Third parties (non-owners) who are aware of a dog''s dangerous propensity and have control over the premises or situation can be held liable under Alaska law. DOCUMENT VERIFIED.'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET
    base_url = EXCLUDED.base_url,
    notes = EXCLUDED.notes;

-- =====================================================================================
-- PART 2: VALIDATION RULES
-- =====================================================================================

-- Rule 1: Alaska One-Bite Rule - Strict Liability with Prior Knowledge
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
    'AK-PI-DOG-BITE-ONE-BITE-RULE',
    5,
    'AK Dog Bite One-Bite Rule (Scienter)',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'AK',
    NULL,
    NULL,
    '{
        "liability_model": "one_bite_rule",
        "legal_standard": "strict_liability_with_prior_knowledge",
        "case_law": "Hale v. O''Neill, 492 P.2d 101 (Alaska 1971)",
        "key_requirements": [
            "Owner knew or should have known of dog''s dangerous propensity",
            "Dog''s dangerous tendency resulted in injury to plaintiff",
            "No requirement to prove owner negligence - strict liability once dangerous propensity established",
            "Prior knowledge can be actual or constructive"
        ],
        "proof_of_dangerous_propensity": [
            "Prior bite incidents",
            "Prior aggressive behavior (growling, lunging, snapping)",
            "Complaints from neighbors about dog''s behavior",
            "Owner''s own statements about dog being aggressive or dangerous",
            "Prior incidents of dog attacking other animals"
        ],
        "liable_parties": [
            "Dog owner (primary liability)",
            "Dog keeper (if keeper had knowledge of dangerous propensity)",
            "Landlord (if landlord knew of dangerous dog and had power to remove it)",
            "Third parties with control and knowledge"
        ],
        "defenses": [
            "No prior knowledge of dangerous propensity",
            "Plaintiff provoked the dog",
            "Plaintiff was trespassing",
            "Plaintiff assumed the risk"
        ],
        "damages": "Full compensatory damages (economic + non-economic); punitive damages in exceptional cases",
        "burden_of_proof": "Plaintiff must prove owner had prior knowledge (actual or constructive) of dangerous propensity"
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

-- Rule 2: Alaska Statute of Limitations - 2 Years
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
    'AK-PI-DOG-BITE-SOL-2-YEARS',
    5,
    'AK Dog Bite Statute of Limitations (2 Years)',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'AK',
    NULL,
    NULL,
    '{
        "statute": "AS 09.10.070",
        "statute_of_limitations": "2 years",
        "accrual_date": "Date of injury (dog bite)",
        "key_requirements": [
            "Complaint must be filed within 2 years of the date of the dog bite injury",
            "Statute applies to all personal injury tort actions, including dog bites",
            "Failure to file within 2 years may bar recovery"
        ],
        "exceptions": [
            "Minors: Statute may be tolled until minor reaches age of majority (AS 09.10.140)",
            "Fraudulent concealment: Statute may be tolled if defendant fraudulently concealed the claim",
            "Disabilities: Statute may be tolled for certain legal disabilities"
        ],
        "tolling_provisions": "See AS 09.10.140 (disabilities and minors)",
        "consequence_of_violation": "Claim time-barred; no recovery possible"
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

-- Rule 3: Alaska Negligence Per Se - Violation of Animal Control Ordinances
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
    'AK-PI-DOG-BITE-NEGLIGENCE-PER-SE',
    5,
    'AK Dog Bite Negligence Per Se (Ordinance Violation)',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'AK',
    NULL,
    NULL,
    '{
        "liability_theory": "negligence_per_se",
        "legal_standard": "Violation of statute or ordinance designed to protect class of persons",
        "key_requirements": [
            "Owner violated a state or local animal control ordinance (e.g., leash law)",
            "Plaintiff was a member of the class the ordinance was designed to protect",
            "Plaintiff suffered the type of harm the ordinance was designed to prevent",
            "Violation proximately caused the plaintiff''s injury"
        ],
        "common_ordinance_violations": [
            "Off-leash violations in areas requiring leashes",
            "Failure to restrain dangerous dog",
            "Failure to register dangerous dog",
            "Failure to maintain proper fencing or enclosure"
        ],
        "effect": "Negligence may be presumed; plaintiff does not need to prove owner had prior knowledge of dangerous propensity",
        "advantages": "Easier to prove than one-bite rule if ordinance violation can be established",
        "still_requires": "Proof of causation (violation proximately caused injury)"
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

-- Rule 4: Alaska Landlord Liability
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
    'AK-PI-DOG-BITE-LANDLORD-LIABILITY',
    5,
    'AK Dog Bite Landlord/Third-Party Liability',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'AK',
    NULL,
    NULL,
    '{
        "liability_theory": "third_party_liability",
        "case_law": "Alaskan Village, Inc. v. Smalley",
        "key_requirements": [
            "Landlord or third party knew or should have known of dangerous dog on premises",
            "Landlord or third party had power/authority to remove dog or take action to prevent attack",
            "Landlord or third party failed to take reasonable action",
            "Failure proximately caused plaintiff''s injury"
        ],
        "liable_parties": [
            "Landlords",
            "Property management companies",
            "Third parties with control over premises or situation"
        ],
        "defenses": [
            "No knowledge of dog''s dangerous propensity",
            "No power or authority to remove dog or control situation",
            "Reasonable action was taken"
        ],
        "practical_note": "Landlords can be liable even if they are not the dog owner, if they had knowledge and control"
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
-- END OF ALASKA DOG BITE RULES SEED FILE
-- =====================================================================================
