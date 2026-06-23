-- =====================================================================================
-- COLORADO DOG BITE LIABILITY RULES SEED FILE
-- =====================================================================================
-- State: Colorado (CO)
-- Sub-Specialization: Dog Bite (Personal Injury)
-- Liability Model: STRICT LIABILITY (Limited - Serious Bodily Injury Only)
-- Legal Standard: Owner liable for serious bodily injury regardless of viciousness/knowledge
-- Primary Authority: C.R.S. § 13-21-124
-- Statute of Limitations: 2 years (C.R.S. § 13-80-102)
-- 
-- VERIFICATION STATUS: DOCUMENT VERIFIED
-- Research Date: January 30, 2026
-- Sources Verified:
--   1. C.R.S. § 13-21-124 - Full statute text verified
--   2. C.R.S. § 18-1-901(3)(p) - Serious bodily injury definition
--   3. C.R.S. § 13-80-102 - 2-year SOL for personal injury
--   4. https://colorado.public.law/statutes/crs_13-21-124
--   5. https://leg.colorado.gov/sites/default/files/images/olls/crs2024-title-18.pdf
-- =====================================================================================

-- =====================================================================================
-- PART 1: LEGAL SOURCES
-- =====================================================================================

-- Source 1: Colorado Limited Strict Liability Statute (C.R.S. § 13-21-124)
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
    'CO',
    NULL,
    NULL,
    'Colorado Dog Bite Limited Strict Liability Statute',
    'Colorado Legislature',
    'C.R.S. § 13-21-124',
    'https://colorado.public.law/statutes/crs_13-21-124',
    'statute',
    'high',
    'C.R.S. § 13-21-124 - Civil actions against dog owners:

(1) Definitions:
(a) "Bodily injury" means any physical injury that results in severe bruising, muscle tears, or skin lacerations requiring professional medical treatment or any physical injury that requires corrective or cosmetic surgery.
(b) "Dog" means any domesticated animal related to the fox, wolf, coyote, or jackal.
(c) "Dog owner" means a person, firm, corporation, or organization owning, possessing, harboring, keeping, having financial or property interest in, or having control or custody of, a dog.
(d) "Serious bodily injury" has the same meaning as set forth in section 18-1-901(3)(p), C.R.S.

(2) STRICT LIABILITY FOR SERIOUS BODILY INJURY: A person or a personal representative of a person who suffers serious bodily injury or death from being bitten by a dog while lawfully on public or private property shall be entitled to bring a civil action to recover economic damages against the dog owner regardless of the viciousness or dangerous propensities of the dog or the dog owner''s knowledge or lack of knowledge of the dog''s viciousness or dangerous propensities.

(3) EUTHANASIA: In any case described in subsection (2) in which it is alleged and proved that the dog owner had knowledge or notice of the dog''s viciousness or dangerous propensities, the court, upon a motion made by the victim or the personal representative of the victim, may enter an order that the dog be euthanized by a licensed veterinarian or licensed shelter at the expense of the dog owner.

(4) LAWFULLY ON PROPERTY: For purposes of this section, a person shall be deemed to be lawfully on public or private property if he or she is in the performance of a duty imposed upon him or her by local, state, or federal laws or regulations or if he or she is on property upon express or implied invitation of the owner of the property or is on his or her own property.

(5) EXCEPTIONS - NO LIABILITY IF:
(a) While the person is unlawfully on public or private property;
(b) While the person is on property of the dog owner and the property is clearly and conspicuously marked with one or more posted signs stating "no trespassing" or "beware of dog";
(c) While the dog is being used by a peace officer or military personnel in the performance of peace officer or military personnel duties;
(d) As a result of the person knowingly provoking the dog;
(e) If the person is a veterinary health-care worker, dog groomer, humane agency staff person, professional dog handler, trainer, or dog show judge acting in the performance of his or her respective duties; or
(f) While the dog is working as a hunting dog, herding dog, farm or ranch dog, or predator control dog on the property of or under the control of the dog''s owner.

(6) OTHER CLAIMS PRESERVED: Nothing in this section shall be construed to:
(a) Affect any other cause of action predicated on other negligence, intentional tort, outrageous conduct, or other theories;
(b) Affect the provisions of any other criminal or civil statute governing the regulation of dogs; or
(c) Abrogate any provision of the "Colorado Governmental Immunity Act", article 10 of title 24, C.R.S.

IMPORTANT: This statute provides LIMITED strict liability - applies ONLY to SERIOUS BODILY INJURY. For injuries not meeting "serious bodily injury" definition, victim must pursue common law negligence claim. DOCUMENT VERIFIED.'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET
    base_url = EXCLUDED.base_url,
    notes = EXCLUDED.notes;

-- Source 2: Colorado Definition of Serious Bodily Injury (C.R.S. § 18-1-901(3)(p))
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
    'CO',
    NULL,
    NULL,
    'Colorado Definition of Serious Bodily Injury',
    'Colorado Legislature',
    'C.R.S. § 18-1-901(3)(p)',
    'https://leg.colorado.gov/sites/default/files/images/olls/crs2024-title-18.pdf',
    'statute',
    'high',
    'C.R.S. § 18-1-901(3)(p) - Definitions (Serious bodily injury):

"Serious bodily injury" means bodily injury that, at the time of the injury or later, involves:
- A substantial risk of death;
- A substantial risk of serious permanent disfigurement;
- A substantial risk of protracted loss or impairment of the function of any part or organ of the body; or
- Breaks, fractures, a penetrating knife or penetrating gunshot wound, or burns of the second or third degree.

EFFECTIVE DATE: Definition expanded by Senate Bill 23-034, effective July 1, 2023, to explicitly include penetrating gunshot wounds and penetrating knife wounds.

APPLICATION TO DOG BITES: This definition determines whether C.R.S. § 13-21-124 strict liability applies. If injury meets this definition, strict liability applies and victim can recover economic damages without proving owner negligence. If injury does NOT meet this definition, victim must pursue common law negligence claim. DOCUMENT VERIFIED.'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET
    base_url = EXCLUDED.base_url,
    notes = EXCLUDED.notes;

-- Source 3: Colorado Statute of Limitations - Personal Injury (C.R.S. § 13-80-102)
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
    'CO',
    NULL,
    NULL,
    'Colorado Statute of Limitations - Personal Injury (Dog Bite)',
    'Colorado Legislature',
    'C.R.S. § 13-80-102',
    'https://law.justia.com/codes/colorado/title-13/limitation-of-actions/article-80/section-13-80-102/',
    'statute',
    'high',
    'C.R.S. § 13-80-102 - General limitation of actions - two years:

All civil actions, whether for damages for personal injury or otherwise, except as otherwise provided by law, shall be commenced within two years after the cause of action accrues.

APPLICATION TO DOG BITES: Claims brought under C.R.S. § 13-21-124 (strict liability for serious bodily injury) and common law negligence claims are subject to this TWO YEAR statute of limitations. The two-year period begins on the date of the dog bite injury. DOCUMENT VERIFIED.'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET
    base_url = EXCLUDED.base_url,
    notes = EXCLUDED.notes;

-- =====================================================================================
-- PART 2: VALIDATION RULES
-- =====================================================================================

-- Rule 1: Colorado Limited Strict Liability (Serious Bodily Injury Only)
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
    'CO-PI-DOG-BITE-LIMITED-STRICT-LIABILITY',
    5,
    'CO Dog Bite Limited Strict Liability (C.R.S. § 13-21-124)',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'CO',
    NULL,
    NULL,
    '{
        "liability_model": "limited_strict_liability",
        "statute": "C.R.S. § 13-21-124",
        "legal_standard": "Owner liable for serious bodily injury regardless of viciousness/knowledge",
        "critical_limitation": "Applies ONLY to SERIOUS BODILY INJURY - not minor injuries",
        "key_requirements": [
            "Dog bite occurred",
            "Victim suffered SERIOUS BODILY INJURY or death (see C.R.S. § 18-1-901(3)(p))",
            "Victim was lawfully on public or private property",
            "Owner is liable regardless of dog''s viciousness or dangerous propensities",
            "Owner is liable regardless of owner''s knowledge of viciousness"
        ],
        "serious_bodily_injury_definition": [
            "Substantial risk of death",
            "Substantial risk of serious permanent disfigurement",
            "Substantial risk of protracted loss/impairment of function of body part/organ",
            "Breaks, fractures",
            "Penetrating knife or penetrating gunshot wound",
            "Burns of second or third degree"
        ],
        "lawfully_on_property_includes": [
            "Person performing duty imposed by local, state, or federal laws/regulations",
            "Person on property with express or implied invitation of owner",
            "Person on his or her own property"
        ],
        "damages_recoverable": "ECONOMIC DAMAGES ONLY (medical expenses, lost wages, future medical costs, etc.)",
        "damages_NOT_recoverable": "Non-economic damages (pain and suffering, emotional distress) NOT covered by strict liability - must pursue negligence claim",
        "exceptions_no_liability": [
            "Victim unlawfully on public or private property",
            "Property clearly marked with \"no trespassing\" or \"beware of dog\" signs",
            "Dog used by peace officer or military personnel in performance of duties",
            "Victim knowingly provoked the dog",
            "Victim is veterinary worker, dog groomer, humane agency staff, professional handler, trainer, or dog show judge acting in performance of duties",
            "Dog working as hunting, herding, farm/ranch, or predator control dog on owner''s property or under owner''s control"
        ],
        "euthanasia_provision": "If owner had knowledge/notice of dog''s viciousness and serious injury occurred, court may order dog euthanized at owner''s expense",
        "strategic_note": "Colorado''s strict liability is LIMITED - applies only to serious bodily injury. For minor injuries, must prove negligence under common law."
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

-- Rule 2: Colorado Negligence (For Non-Serious Injuries)
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
    'CO-PI-DOG-BITE-NEGLIGENCE',
    5,
    'CO Dog Bite Negligence (Common Law)',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'CO',
    NULL,
    NULL,
    '{
        "liability_theory": "common_law_negligence",
        "when_to_use": [
            "Injury does NOT meet serious bodily injury definition (C.R.S. § 18-1-901(3)(p))",
            "Victim wants to recover non-economic damages (pain and suffering)",
            "Non-bite injuries (e.g., dog knocked victim over)",
            "Alternative theory to pursue alongside strict liability"
        ],
        "elements_to_prove": [
            "Owner owed a duty of care",
            "Owner breached that duty (failed to control or restrain dog)",
            "Owner knew or should have known of dog''s dangerous propensities (one-bite rule)",
            "Breach proximately caused plaintiff''s injury",
            "Plaintiff suffered damages"
        ],
        "damages_recoverable": [
            "Economic damages (medical expenses, lost wages)",
            "Non-economic damages (pain and suffering, emotional distress)",
            "Non-economic damages capped at $350,000 per C.R.S. § 13-21-102.5"
        ],
        "comparison_to_strict_liability": [
            "Strict liability: easier to prove but limited to serious bodily injury + economic damages only",
            "Negligence: harder to prove (must show owner knowledge) but covers all injuries + allows non-economic damages",
            "Strategic: Always plead both strict liability (if serious injury) and negligence to maximize recovery"
        ],
        "note": "C.R.S. § 13-21-124(6)(a) explicitly preserves negligence claims alongside strict liability"
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

-- Rule 3: Colorado Statute of Limitations - 2 Years
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
    'CO-PI-DOG-BITE-SOL-2-YEARS',
    5,
    'CO Dog Bite Statute of Limitations (2 Years)',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'CO',
    NULL,
    NULL,
    '{
        "statute": "C.R.S. § 13-80-102",
        "statute_of_limitations": "2 years",
        "accrual_date": "Date of dog bite injury",
        "key_requirements": [
            "Complaint must be filed within 2 years of the date of the dog bite",
            "Applies to strict liability claims under C.R.S. § 13-21-124",
            "Applies to negligence claims and other dog bite theories",
            "Failure to file within 2 years bars recovery"
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

-- Rule 4: Colorado Working Dog Exception
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
    'CO-PI-DOG-BITE-WORKING-DOG-EXCEPTION',
    5,
    'CO Dog Bite Working Dog Exception',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'CO',
    NULL,
    NULL,
    '{
        "statute": "C.R.S. § 13-21-124(5)(c), (f)",
        "exception_applies": "Working dogs (police, military, hunting, herding, farm/ranch, predator control)",
        "categories": [
            "Police or military dogs in performance of peace officer or military duties (subsection 5(c))",
            "Hunting dogs, herding dogs, farm or ranch dogs, predator control dogs on property of or under control of owner (subsection 5(f))"
        ],
        "requirements_for_exception": [
            "Dog was actively working in specified capacity",
            "Police/military: during performance of official duties",
            "Hunting/herding/farm/ranch/predator control: on owner''s property OR under owner''s control"
        ],
        "practical_effect": "Owner not liable if dog was performing legitimate working function at time of bite",
        "note": "Working dog exception is broader than most states - includes farm/ranch/predator control dogs"
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
-- END OF COLORADO DOG BITE RULES SEED FILE
-- =====================================================================================
