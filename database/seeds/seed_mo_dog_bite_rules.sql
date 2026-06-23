-- =====================================================================================
-- MISSOURI DOG BITE LIABILITY RULES SEED FILE
-- =====================================================================================
-- State: Missouri (MO)
-- Sub-Specialization: Dog Bite (Personal Injury)
-- Liability Model: STRICT LIABILITY (Statutory)
-- Legal Standard: Owner strictly liable for dog bite without provocation
-- Primary Authority: RSMo 273.036
-- Statute of Limitations: 5 years (RSMo 516.120) - ONE OF LONGEST IN NATION
-- PENDING CHANGE: HB1645 proposes 2-year SOL effective August 28, 2026
-- Authority Level: contextual_rule (NOT primary_state_sol)
-- 
-- VERIFICATION STATUS: DOCUMENT VERIFIED
-- Research Date: January 30, 2026
-- Sources Verified:
--   1. RSMo 273.036 - Verified from Missouri Revisor
--   2. RSMo 516.120 - 5-year SOL
--   3. HB1645 (pending) - 2-year SOL proposal (not yet enacted)
-- =====================================================================================

-- =====================================================================================
-- PART 1: LEGAL SOURCES
-- =====================================================================================

-- Source 1: Missouri Dog Bite Strict Liability Statute (RSMo 273.036)
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
    'MO',
    NULL,
    NULL,
    'Missouri Dog Bite Strict Liability Statute',
    'Missouri Legislature',
    'RSMo 273.036',
    'https://revisor.mo.gov/main/OneSection.aspx?section=273.036',
    'statute',
    'high',
    'RSMo 273.036 - Liability of owner or possessor of dog for damages to person, domestic animal, or property:

The owner or, if no owner can be found, the harborer or possessor of any dog, shall be liable for all damages done by such dog to any person, livestock, or property of any description; provided, that where a trespasser has provoked the dog or has committed or is committing a criminal or tortious act, the damage caused shall be reduced in proportion to the trespasser''s, provoker''s, or tort-feasor''s share of responsibility.

In no event shall this section apply to damage done by a dog to property or livestock of a person who shall have damaged the dog or who shall have teased, tormented, or abused it, or when the damage has occurred while the person or livestock was trespassing upon the property of the owner or possessor of the dog. Nothing in this section shall be construed to modify the provisions of section 273.020, regarding liability for damage done by dogs killing, worrying, or maiming sheep or other domestic animals or fowls.

Any person who has been damaged may bring suit against the owner or, if no owner can be found, the harborer or possessor of such dog. If the plaintiff prevails, the defendant shall be liable for a civil penalty not to exceed one thousand dollars in addition to any damages sustained by the plaintiff.

KEY PROVISIONS:

1. STRICT LIABILITY:
   - Owner (or harborer/possessor if no owner found) LIABLE for ALL damages done by dog
   - NO requirement to prove owner knew dog was dangerous
   - NO one-bite rule
   - Liability regardless of owner''s negligence or prior knowledge

2. REQUIREMENTS FOR LIABILITY:
   a. Dog damaged person, livestock, or property
   b. WITHOUT provocation
   c. Victim was NOT trespassing
   d. Victim did NOT commit criminal or tortious act

3. BROAD SCOPE:
   - Applies to damage to PERSON (personal injury)
   - Applies to damage to LIVESTOCK
   - Applies to damage to PROPERTY
   - Applies on PUBLIC property
   - Applies on PRIVATE property (including owner''s own property if victim lawfully present)

4. DEFENSES / DAMAGE REDUCTION:
   - Provocation: Damage reduced in proportion to victim''s share of responsibility
   - Trespassing: No liability if victim was trespassing
   - Criminal/tortious act: Damage reduced in proportion to victim''s share
   - Victim damaged dog or teased/tormented/abused dog: No liability
   
5. PURE COMPARATIVE NEGLIGENCE:
   Missouri applies PURE comparative negligence. Damages reduced proportionally based on victim''s fault, but victim can still recover even if >50% at fault.

6. CIVIL PENALTY:
   In addition to damages, defendant may be liable for civil penalty up to $1,000.

DOCUMENT VERIFIED from Missouri Revised Statutes (RSMo 273.036) and multiple legal sources (Sticklen Injury Law, Guirl Firm, House Law KC).'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET
    base_url = EXCLUDED.base_url,
    notes = EXCLUDED.notes;

-- Source 2: Missouri Statute of Limitations - Personal Injury (RSMo 516.120)
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
    'MO',
    NULL,
    NULL,
    'Missouri Statute of Limitations - Personal Injury (Dog Bite)',
    'Missouri Legislature',
    'RSMo 516.120',
    'https://revisor.mo.gov/main/OneSection.aspx?section=516.120',
    'statute',
    'high',
    'RSMo 516.120 - Five years limitation:

Within five years: ... (4) all actions for trespass on real estate; (5) all actions for taking, detaining or injuring any goods or chattels; and all actions for any injury to the person or rights of another, not arising on contract and not herein otherwise enumerated.

APPLICATION TO DOG BITES:
Claims brought under RSMo 273.036 (strict liability statute) are subject to this FIVE YEAR statute of limitations. The five-year period begins on the date of the dog bite injury.

ONE OF LONGEST SOLs IN NATION:
Missouri''s 5-year SOL is one of the LONGEST in the United States for personal injury claims. Most states have 2-3 year SOLs.

PENDING LEGISLATIVE CHANGE (NOT YET ENACTED):
HB1645 proposes to REDUCE the SOL from 5 years to 2 years for injuries occurring on or after August 28, 2026. As of January 30, 2026, this bill has NOT been enacted. If enacted, it would:
- Apply ONLY to injuries on/after August 28, 2026
- Injuries BEFORE August 28, 2026 would still have 5-year SOL
- Significantly shorten filing period

TOLLING PROVISIONS:
- Minors: Statute tolled until minor reaches age 18
- Mental incapacity: Statute may be tolled
- Discovery rule: May apply in limited circumstances

STRATEGIC ADVANTAGE (Current Law):
The lengthy 5-year SOL gives victims significant time to:
- Recover from injuries and assess long-term damages
- Negotiate with insurance companies
- Gather evidence and witness testimony
- Consult with attorneys
- Avoid rushed settlement decisions

DOCUMENT VERIFIED from Missouri Revised Statutes and multiple legal sources.'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET
    base_url = EXCLUDED.base_url,
    notes = EXCLUDED.notes;

-- =====================================================================================
-- PART 2: VALIDATION RULES (CONTEXTUAL RULES - NOT PRIMARY SOL AUTHORITY)
-- =====================================================================================

-- Rule 1: Missouri Strict Liability (RSMo 273.036)
INSERT INTO leverage.validation_rules (
    rule_name,
    validator_level,
    validator_name,
    validator_type,
    practice_area,
    document_type,
    jurisdiction_scope,
    jurisdiction_state,
    validator_config,
    severity,
    review_status,
    is_active,
    is_template,
    created_at,
    updated_at
) VALUES (
    'MO-PI-DOG-BITE-STRICT-LIABILITY',
    5,
    'MO Dog Bite Strict Liability (RSMo 273.036)',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'MO',
    '{
        "authority_level": "contextual_rule",
        "liability_model": "strict_liability",
        "statute": "RSMo 273.036",
        "legal_standard": "Owner/harborer/possessor liable for all damages done by dog",
        "key_requirements": [
            "Dog damaged plaintiff (person, livestock, or property)",
            "WITHOUT provocation",
            "Plaintiff was NOT trespassing",
            "Plaintiff did NOT commit criminal or tortious act",
            "Plaintiff did NOT damage, tease, torment, or abuse dog"
        ],
        "no_one_bite_rule": "Missouri does NOT follow one-bite rule; owner strictly liable on first bite",
        "no_prior_knowledge_required": "Owner liable regardless of lack of knowledge of dog''s dangerous propensities",
        "broad_owner_definition": {
            "owner": "Legal owner of dog (primarily liable)",
            "harborer": "If no owner found, harborer is liable",
            "possessor": "If no owner found, possessor is liable"
        },
        "broad_scope": {
            "person": "Applies to personal injury",
            "livestock": "Applies to damage to livestock",
            "property": "Applies to property damage",
            "public_property": "Applies on public property",
            "private_property": "Applies on private property (including owner''s if victim lawfully present)"
        },
        "pure_comparative_negligence": {
            "rule": "Missouri applies PURE comparative negligence",
            "damage_reduction": "Damages reduced proportionally based on victim''s fault",
            "can_recover_even_if_mostly_at_fault": "Victim can still recover even if >50% at fault"
        },
        "defenses_damage_reduction": {
            "provocation": "Damage reduced in proportion to victim''s share of responsibility",
            "trespassing": "No liability if victim was trespassing",
            "criminal_tortious_act": "Damage reduced in proportion to victim''s share",
            "victim_damaged_teased_dog": "No liability if victim damaged, teased, tormented, or abused dog"
        },
        "civil_penalty": "Defendant may be liable for civil penalty up to $1,000 in addition to damages",
        "damages_recoverable": [
            "Medical expenses",
            "Lost wages",
            "Pain and suffering",
            "Emotional distress",
            "Permanent scarring/disfigurement",
            "Property damage",
            "Livestock damage",
            "Civil penalty (up to $1,000)"
        ]
    }'::jsonb,
    'error',
    'doc_verified',
    true,
    true,
    NOW(),
    NOW()
) ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    review_status = EXCLUDED.review_status,
    updated_at = NOW();

-- Rule 2: Missouri Statute of Limitations - 5 YEARS (CONTEXTUAL RULE)
INSERT INTO leverage.validation_rules (
    rule_name,
    validator_level,
    validator_name,
    validator_type,
    practice_area,
    document_type,
    jurisdiction_scope,
    jurisdiction_state,
    validator_config,
    severity,
    review_status,
    is_active,
    is_template,
    created_at,
    updated_at
) VALUES (
    'MO-PI-DOG-BITE-SOL-5-YEARS',
    5,
    'MO Dog Bite Statute of Limitations (5 Years - Contextual)',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'MO',
    '{
        "authority_level": "contextual_rule",
        "statute": "RSMo 516.120",
        "statute_of_limitations": "5 years",
        "sol_years": 5,
        "sol_days": 1825,
        "one_of_longest": "Missouri has one of the LONGEST SOLs in nation (5 years)",
        "accrual_date": "Date of dog bite injury",
        "key_requirements": [
            "Action must be commenced within 5 YEARS of dog bite",
            "Applies to claims under RSMo 273.036 (strict liability)",
            "Failure to file within 5 years bars recovery"
        ],
        "pending_change_hb1645": {
            "status": "Proposed (NOT YET ENACTED as of January 30, 2026)",
            "proposed_sol": "2 years",
            "effective_date": "August 28, 2026 (if enacted)",
            "applies_to": "Injuries occurring ON OR AFTER August 28, 2026",
            "current_law_still_applies": "Injuries BEFORE August 28, 2026 still have 5-year SOL",
            "note": "Monitor HB1645 for enactment; if enacted, this is MAJOR CHANGE reducing SOL from 5 years to 2 years"
        },
        "tolling_provisions": [
            "Minors: Statute tolled until minor reaches age 18",
            "Mental incapacity: Statute may be tolled",
            "Discovery rule: May apply in limited circumstances"
        ],
        "strategic_advantages": [
            "GENEROUS 5-year filing period (one of longest in nation)",
            "Time to assess long-term damages and permanent scarring",
            "Time to negotiate with insurance companies without pressure",
            "Time to gather evidence and witness testimony",
            "Time to consult with attorneys and medical experts",
            "Avoid rushed settlement decisions"
        ],
        "comparison": "Compare to shortest SOLs: TN/KY (1 year), LA pre-2024 (1 year); If HB1645 enacted, MO would drop to 2 years",
        "consequence_of_violation": "Claim time-barred; court will dismiss; NO RECOVERY POSSIBLE"
    }'::jsonb,
    'error',
    'doc_verified',
    true,
    true,
    NOW(),
    NOW()
) ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    review_status = EXCLUDED.review_status,
    updated_at = NOW();

-- =====================================================================================
-- END OF MISSOURI DOG BITE RULES SEED FILE
-- =====================================================================================
