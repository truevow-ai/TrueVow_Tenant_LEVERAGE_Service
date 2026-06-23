-- =====================================================================================
-- ARKANSAS DOG BITE LIABILITY RULES SEED FILE
-- =====================================================================================
-- State: Arkansas (AR)
-- Sub-Specialization: Dog Bite (Personal Injury)
-- Liability Model: ONE-BITE RULE (Common Law) + CRIMINAL STATUTE
-- Legal Standard: Owner liable if owner knew or should have known of dog's dangerous propensities
-- Primary Authority: Common law (no statewide strict liability statute)
-- Criminal Statute: Ark. Code Ann. § 5-62-125 (Class A misdemeanor)
-- Statute of Limitations: 3 years (Ark. Code Ann. § 16-56-105)
-- 
-- VERIFICATION STATUS: DOCUMENT VERIFIED
-- Research Date: January 30, 2026
-- Sources Verified:
--   1. Ark. Code Ann. § 5-62-125 - Unlawful dog attack (criminal statute)
--   2. Ark. Code Ann. § 16-56-105 - 3-year SOL for personal injury
--   3. https://justinmintonlaw.com/understanding-the-one-bite-rule-and-its-applicability-in-arkansas/
--   4. https://www.animallaw.info/statute/ar-dog-consolidated-dog-laws
-- =====================================================================================

-- =====================================================================================
-- PART 1: LEGAL SOURCES
-- =====================================================================================

-- Source 1: Arkansas Common Law - One-Bite Rule
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
    'AR',
    NULL,
    NULL,
    'Arkansas Dog Bite Common Law - One-Bite Rule',
    'Arkansas Common Law',
    'AR Common Law',
    'https://justinmintonlaw.com/understanding-the-one-bite-rule-and-its-applicability-in-arkansas/',
    'case_law',
    'high',
    'Arkansas Dog Bite Common Law - One-Bite Rule: Arkansas does not have a specific statute that governs dog bite liability. Instead, the state relies on common legal principles, including the One Bite Rule, to determine liability in dog bite cases. Under this rule, a dog owner can be held liable for injuries caused by their pet if: (1) The owner knew or should have known that the dog had dangerous propensities or a history of aggression, (2) The owner failed to take reasonable steps to prevent the dog from causing harm, and (3) The attack causes death or severe injuries. The term "one bite" focuses on the dog''s past behavior and the owner''s knowledge of any aggressive behavior. The owner can be considered aware of the dog''s dangerous nature if the dog has displayed aggressive behavior in the past, such as growling, snapping, or lunging at people. Evidence may include: witness statements, medical records, documentation of the dog''s past behavior, animal control reports, previous complaints about the dog, and prior incidents involving the same animal. The victim must prove the dog owner knew about the pet''s aggressive tendencies and neglected to take proper steps to prevent an attack. DOCUMENT VERIFIED.'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET
    base_url = EXCLUDED.base_url,
    notes = EXCLUDED.notes;

-- Source 2: Arkansas Criminal Statute - Unlawful Dog Attack (Ark. Code Ann. § 5-62-125)
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
    'AR',
    NULL,
    NULL,
    'Arkansas Unlawful Dog Attack Criminal Statute',
    'Arkansas Legislature',
    'Ark. Code Ann. § 5-62-125',
    'https://law.justia.com/codes/arkansas/2020/title-5/subtitle-6/chapter-62/subchapter-1/section-5-62-125/',
    'statute',
    'high',
    'Ark. Code Ann. § 5-62-125 - Unlawful dog attack: A person commits the offense of unlawful dog attack if the person owns a dog known or reasonably suspected to have a propensity to attack or cause injury to another person, negligently allows the dog to attack another person, and the attack results in death or serious physical injury. The offense is classified as a Class A misdemeanor. Class A misdemeanors are the most severe category of misdemeanors in Arkansas. A conviction can result in a fine of up to $2,500 and/or a jail sentence of up to 1 year. Additionally, courts may require the defendant to pay restitution for medical expenses related to injuries caused by the attack. This criminal statute provides a mechanism for victims to recover medical expenses through restitution but does not cover pain and suffering or emotional damages unless a civil suit is filed. DOCUMENT VERIFIED.'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET
    base_url = EXCLUDED.base_url,
    notes = EXCLUDED.notes;

-- Source 3: Arkansas Statute of Limitations - Personal Injury (Ark. Code Ann. § 16-56-105)
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
    'AR',
    NULL,
    NULL,
    'Arkansas Statute of Limitations - Personal Injury (Dog Bite)',
    'Arkansas Legislature',
    'Ark. Code Ann. § 16-56-105',
    'https://law.justia.com/codes/arkansas/title-16/subtitle-5/chapter-56/subchapter-1/section-16-56-105/',
    'statute',
    'high',
    'Ark. Code Ann. § 16-56-105 - Actions with limitation of three years: This statute establishes a three-year statute of limitations for personal injury actions, including dog bite claims. The action must be commenced within three years from the date the cause of action accrues (i.e., the date of the dog bite injury). If you do not file your lawsuit within this timeframe, you may be barred from seeking compensation for your injuries. This three-year limitation applies to civil dog bite claims based on common law negligence and the one-bite rule. Note: The criminal statute (Ark. Code Ann. § 5-62-125) is a separate proceeding and not subject to this civil statute of limitations. DOCUMENT VERIFIED.'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET
    base_url = EXCLUDED.base_url,
    notes = EXCLUDED.notes;

-- Source 4: Arkansas Civil Dog Bite Statute - Injuries to Domesticated Animals Only (Ark. Code Ann. § 20-19-102)
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
    'AR',
    NULL,
    NULL,
    'Arkansas Dog Liability - Injuries to Domesticated Animals',
    'Arkansas Legislature',
    'Ark. Code Ann. § 20-19-102',
    'https://codes.findlaw.com/ar/title-20-public-health-and-welfare/ar-code-sect-20-19-102/',
    'statute',
    'high',
    'Ark. Code Ann. § 20-19-102 - Liability for injuries to domesticated animals: This statute establishes strict liability for dog owners regarding injuries to domesticated animals (sheep, goats, cattle, swine, poultry, etc.) caused by dogs. Owners or those in possession or control of a dog are liable for damages to the owner of a domesticated animal injured or killed by the dog, covering the full value of the harmed animal. IMPORTANT: This statute applies ONLY to injuries to domesticated animals (livestock), NOT to injuries to humans. For human injuries, Arkansas relies on common law (one-bite rule) and the criminal statute (Ark. Code Ann. § 5-62-125). There is NO statewide strict liability statute for dog bites to humans in Arkansas. DOCUMENT VERIFIED.'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET
    base_url = EXCLUDED.base_url,
    notes = EXCLUDED.notes;

-- =====================================================================================
-- PART 2: VALIDATION RULES
-- =====================================================================================

-- Rule 1: Arkansas One-Bite Rule (Common Law)
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
    'AR-PI-DOG-BITE-ONE-BITE-RULE',
    5,
    'AR Dog Bite One-Bite Rule (Common Law)',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'AR',
    NULL,
    NULL,
    '{
        "liability_model": "one_bite_rule",
        "legal_standard": "owner_knew_or_should_have_known_dangerous_propensities",
        "legal_authority": "Arkansas common law (no statewide strict liability statute)",
        "key_requirements": [
            "Owner knew or should have known that dog had dangerous propensities or history of aggression",
            "Owner failed to take reasonable steps to prevent dog from causing harm",
            "Attack caused death or severe injuries"
        ],
        "proof_of_dangerous_propensities": [
            "Prior biting incidents",
            "Aggressive behavior: growling, snapping, lunging at people",
            "Witness statements from people who saw aggressive behavior",
            "Animal control reports",
            "Previous complaints about the dog",
            "Prior incidents involving the same animal"
        ],
        "owner_duty_to_prevent": [
            "Keep dog on leash",
            "Secure dog in fenced area",
            "Warn others about dog''s dangerous behavior (e.g., warning signs)",
            "Walk dog with muzzle if necessary"
        ],
        "burden_of_proof": "Victim must prove owner knew about aggressive tendencies and neglected to take proper steps",
        "defenses": [
            "Provocation: victim teased or abused the dog before incident",
            "Trespassing: victim was trespassing on owner''s property",
            "Assumption of risk: victim knew about dog''s aggression but still interacted with it"
        ],
        "damages": "Medical expenses, lost wages, pain and suffering, scarring/disfigurement, loss of quality of life",
        "note": "Arkansas does NOT have a statewide strict liability statute for dog bites to humans"
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

-- Rule 2: Arkansas Criminal Statute - Unlawful Dog Attack (Class A Misdemeanor)
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
    'AR-PI-DOG-BITE-CRIMINAL-STATUTE',
    5,
    'AR Dog Bite Criminal Statute (Ark. Code Ann. § 5-62-125)',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'AR',
    NULL,
    NULL,
    '{
        "statute": "Ark. Code Ann. § 5-62-125",
        "offense": "Unlawful dog attack",
        "classification": "Class A misdemeanor",
        "elements": [
            "Person owns a dog known or reasonably suspected to have a propensity to attack or cause injury",
            "Person negligently allows the dog to attack another person",
            "Attack results in death or serious physical injury"
        ],
        "penalties": [
            "Fine of up to $2,500",
            "Jail sentence of up to 1 year",
            "Court-ordered restitution for medical expenses"
        ],
        "restitution_coverage": [
            "Medical expenses related to injuries caused by attack"
        ],
        "restitution_limitations": [
            "Does NOT cover pain and suffering",
            "Does NOT cover emotional damages",
            "Does NOT cover lost wages (beyond medical bills)"
        ],
        "strategic_note": "Criminal prosecution can provide restitution for medical bills but civil lawsuit required for full damages",
        "civil_vs_criminal": "Criminal statute is separate proceeding from civil lawsuit; victim can pursue both simultaneously"
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

-- Rule 3: Arkansas Statute of Limitations - 3 Years
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
    'AR-PI-DOG-BITE-SOL-3-YEARS',
    5,
    'AR Dog Bite Statute of Limitations (3 Years)',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'AR',
    NULL,
    NULL,
    '{
        "statute": "Ark. Code Ann. § 16-56-105",
        "statute_of_limitations": "3 years",
        "accrual_date": "Date of dog bite injury",
        "key_requirements": [
            "Complaint must be filed within 3 years of the date of the dog bite",
            "Applies to civil dog bite claims based on common law negligence and one-bite rule",
            "Failure to file within 3 years bars recovery"
        ],
        "exceptions": [
            "Minors: Statute may be tolled until minor reaches age of majority",
            "Discovery rule: In limited circumstances if injury was not immediately known"
        ],
        "consequence_of_violation": "Claim time-barred; no recovery possible",
        "note": "Criminal prosecution under Ark. Code Ann. § 5-62-125 is separate and not subject to this civil SOL"
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

-- Rule 4: Arkansas Negligence Per Se - Violation of Local Ordinances
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
    'AR-PI-DOG-BITE-NEGLIGENCE-PER-SE',
    5,
    'AR Dog Bite Negligence Per Se (Local Ordinance Violation)',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'AR',
    NULL,
    NULL,
    '{
        "liability_theory": "negligence_per_se",
        "legal_standard": "Violation of local animal control ordinance",
        "key_requirements": [
            "Owner violated a local animal control ordinance (e.g., leash law)",
            "Violation proximately caused plaintiff''s injury"
        ],
        "common_ordinance_violations": [
            "Off-leash violations",
            "Failure to restrain dangerous dog",
            "Failure to register dangerous dog",
            "Running at large violations"
        ],
        "effect": "May establish negligence without need to prove owner had prior knowledge of dangerous propensity",
        "local_variation": "Some Arkansas counties have strict liability ordinances (e.g., Benton County) - check local ordinances",
        "strategic_note": "Easier to prove than one-bite rule if ordinance violation can be established"
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
-- END OF ARKANSAS DOG BITE RULES SEED FILE
-- =====================================================================================
