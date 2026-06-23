-- =====================================================================================
-- MAINE DOG BITE LIABILITY RULES SEED FILE
-- =====================================================================================
-- State: Maine (ME)
-- Sub-Specialization: Dog Bite (Personal Injury)
-- Liability Model: HYBRID (Strict Liability OFF-PREMISES / Negligence ON-PREMISES)
-- Legal Standard: Off-premises = strict liability; On-premises = negligence
-- Primary Authority: 7 M.R.S. § 3961
-- Statute of Limitations: 6 years (14 M.R.S. § 752) - ONE OF LONGEST IN NATION
-- 
-- VERIFICATION STATUS: DOCUMENT VERIFIED
-- Research Date: January 30, 2026
-- Sources Verified:
--   1. 7 M.R.S. § 3961 - Verified from Maine Legislature (exact statutory text retrieved)
--   2. 14 M.R.S. § 752 - 6-year SOL for civil actions
--   3. Hybrid model confirmed from multiple legal sources
-- =====================================================================================

-- =====================================================================================
-- PART 1: LEGAL SOURCES
-- =====================================================================================

-- Source 1: Maine Dog Bite Hybrid Liability Statute (7 M.R.S. § 3961)
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
    'ME',
    NULL,
    NULL,
    'Maine Dog Bite Hybrid Liability Statute',
    'Maine Legislature',
    '7 M.R.S. § 3961',
    'https://legislature.maine.gov/statutes/7/title7sec3961.html',
    'statute',
    'high',
    '7 M.R.S. § 3961 - Reimbursement for damage done by animals:

SUBSECTION 1: Injuries and damages by animal (GENERAL NEGLIGENCE):
When an animal damages a person or that person''s property due to negligence of the animal''s owner or keeper, the owner or keeper of that animal is liable in a civil action to the person injured for the amount of damage done if the damage was not occasioned through the fault of the person injured.

SUBSECTION 2: Injuries by dog (STRICT LIABILITY OFF-PREMISES):
Notwithstanding subsection 1, when a dog injures a person who is NOT on the owner''s or keeper''s premises at the time of the injury, the owner or keeper of the dog is liable in a civil action to the person injured for the amount of the damages. Any fault on the part of the person injured may not reduce the damages recovered for physical injury to that person unless the court determines that the fault of the person injured EXCEEDED the fault of the dog''s keeper or owner.

SECTION HISTORY:
- PL 1987, c. 383, §3 (NEW)
- PL 1999, c. 254, §8 (AMD)
- PL 2001, c. 220, §1 (RPR) - CURRENT VERSION

HYBRID LIABILITY MODEL:
Maine follows a HYBRID model with TWO DIFFERENT STANDARDS:

1. OFF-PREMISES (STRICT LIABILITY):
   - Location: Injury occurs OFF owner''s/keeper''s premises (public place, neighbor''s yard, street, park, etc.)
   - Standard: STRICT LIABILITY - Owner liable regardless of negligence or prior knowledge of dog''s viciousness
   - Victim fault: Victim fault does NOT reduce damages UNLESS victim''s fault EXCEEDED owner''s fault
   - No one-bite rule: Owner liable even on first bite
   - Applies to: Dogs only (subsection 2)

2. ON-PREMISES (NEGLIGENCE):
   - Location: Injury occurs ON owner''s/keeper''s premises (owner''s property)
   - Standard: NEGLIGENCE - Must prove owner negligent (failed to exercise reasonable care)
   - Victim fault: Complete defense if injury caused by victim''s fault
   - Applies to: All animals including dogs (subsection 1)

COMPARATIVE FAULT (OFF-PREMISES):
For off-premises dog bites, victim''s fault does NOT reduce damages UNLESS court finds victim''s fault EXCEEDED owner''s fault. This is a MODIFIED comparative fault rule favorable to victims.

DOCUMENT VERIFIED from Maine Revised Statutes (exact text retrieved from Maine Legislature website January 30, 2026).'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET
    base_url = EXCLUDED.base_url,
    notes = EXCLUDED.notes;

-- Source 2: Maine Statute of Limitations - Civil Actions (14 M.R.S. § 752)
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
    'ME',
    NULL,
    NULL,
    'Maine Statute of Limitations - Civil Actions (Dog Bite)',
    'Maine Legislature',
    '14 M.R.S. § 752',
    'https://www.mainelegislature.org/legis/statutes/14/title14sec752.html',
    'statute',
    'high',
    '14 M.R.S. § 752 - Six years:

All civil actions shall be commenced within 6 years after the cause of action accrues and not afterwards, except as otherwise specially provided.

APPLICATION TO DOG BITES:
Claims brought under 7 M.R.S. § 3961 (dog bite hybrid liability statute) are subject to this SIX YEAR statute of limitations. The six-year period begins on the date of the dog bite injury.

ONE OF LONGEST SOLs IN NATION:
Maine''s 6-year SOL is one of the LONGEST in the United States for personal injury claims. Only North Dakota (6 years) matches Maine''s generous filing period. Most states have 2-3 year SOLs.

EXCEPTIONS:
- Government entities: 1-year notice requirement
- Wrongful death: Damage caps apply
- Minors: Tolling provisions may apply

STRATEGIC ADVANTAGE:
The lengthy 6-year SOL gives victims significant time to:
- Recover from injuries and assess long-term damages
- Negotiate with insurance companies
- Gather evidence and witness testimony
- Consult with attorneys
- Avoid rushed settlement decisions

DOCUMENT VERIFIED from Maine Revised Statutes and multiple legal sources.'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET
    base_url = EXCLUDED.base_url,
    notes = EXCLUDED.notes;

-- =====================================================================================
-- PART 2: VALIDATION RULES
-- =====================================================================================

-- Rule 1: Maine Strict Liability (OFF-PREMISES ONLY)
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
    'ME-PI-DOG-BITE-STRICT-LIABILITY-OFF-PREMISES',
    5,
    'ME Dog Bite Strict Liability (OFF-PREMISES ONLY)',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'ME',
    '{
        "liability_model": "strict_liability_off_premises",
        "statute": "7 M.R.S. § 3961(2)",
        "legal_standard": "Owner strictly liable for injuries by dog OFF owner''s/keeper''s premises",
        "key_requirements": [
            "Dog injured plaintiff",
            "Injury occurred OFF owner''s or keeper''s premises (public place, street, park, neighbor''s yard, etc.)",
            "Owner is liable regardless of negligence",
            "Owner is liable regardless of dog''s prior viciousness",
            "Victim fault does NOT reduce damages UNLESS victim''s fault EXCEEDED owner''s fault"
        ],
        "location_requirement": "CRITICAL: Strict liability applies ONLY if injury occurred OFF owner''s/keeper''s premises",
        "on_premises_different_rule": "If injury occurred ON owner''s premises, negligence standard applies (7 M.R.S. § 3961(1))",
        "modified_comparative_fault": {
            "rule": "Victim fault does NOT reduce damages UNLESS victim''s fault exceeded owner''s fault",
            "victim_favorable": "This is MORE favorable to victims than traditional comparative fault",
            "burden_on_owner": "Owner must prove victim''s fault EXCEEDED owner''s fault"
        },
        "no_one_bite_rule": "Maine does NOT follow one-bite rule for off-premises injuries; strict liability on first bite",
        "damages_recoverable": [
            "Medical expenses",
            "Lost wages",
            "Pain and suffering",
            "Emotional distress",
            "Permanent scarring/disfigurement",
            "Property damage"
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

-- Rule 2: Maine Negligence (ON-PREMISES)
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
    'ME-PI-DOG-BITE-NEGLIGENCE-ON-PREMISES',
    5,
    'ME Dog Bite Negligence (ON-PREMISES)',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'ME',
    '{
        "liability_model": "negligence_on_premises",
        "statute": "7 M.R.S. § 3961(1)",
        "legal_standard": "Owner liable for injuries ON premises if owner was negligent",
        "key_requirements": [
            "Animal (including dog) injured plaintiff",
            "Injury occurred ON owner''s or keeper''s premises",
            "Owner was NEGLIGENT (failed to exercise reasonable care)",
            "Negligence caused injury",
            "Injury was NOT caused by victim''s fault"
        ],
        "location_requirement": "CRITICAL: Negligence standard applies when injury occurred ON owner''s/keeper''s premises",
        "off_premises_different_rule": "If injury occurred OFF owner''s premises, strict liability applies (7 M.R.S. § 3961(2))",
        "victim_fault_complete_defense": "If injury caused by victim''s fault, owner NOT liable",
        "proving_negligence": {
            "examples": [
                "Owner knew dog was aggressive and failed to restrain",
                "Owner violated leash law or local ordinance",
                "Owner failed to warn invited guest of known danger",
                "Owner allowed aggressive dog to roam free on property",
                "Owner failed to properly secure dog"
            ]
        },
        "applies_to": "All animals including dogs (subsection 1 applies to all animals)",
        "burden_of_proof": "Plaintiff must prove owner''s negligence"
    }'::jsonb,
    'warning',
    'doc_verified',
    true,
    true,
    NOW(),
    NOW()
) ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    review_status = EXCLUDED.review_status,
    updated_at = NOW();

-- Rule 3: Maine Statute of Limitations - 6 YEARS (ONE OF LONGEST IN NATION)
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
    'ME-PI-DOG-BITE-SOL-6-YEARS',
    5,
    'ME Dog Bite Statute of Limitations (6 YEARS - ONE OF LONGEST IN NATION)',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'ME',
    '{
        "statute": "14 M.R.S. § 752",
        "statute_of_limitations": "6 years",
        "sol_years": 6,
        "sol_days": 2190,
        "one_of_longest": "Maine has one of the LONGEST SOLs in nation (tied with North Dakota at 6 years)",
        "accrual_date": "Date cause of action accrues (date of dog bite injury)",
        "key_requirements": [
            "Action must be commenced within 6 YEARS of dog bite",
            "Applies to both strict liability (off-premises) and negligence (on-premises) claims",
            "Failure to file within 6 years bars recovery"
        ],
        "exceptions": [
            "Government entities: 1-year notice requirement",
            "Minors: Tolling provisions may apply",
            "Discovery rule: May apply in limited circumstances"
        ],
        "strategic_advantages": [
            "GENEROUS 6-year filing period",
            "Time to assess long-term damages and scarring",
            "Time to negotiate with insurance companies",
            "Time to gather evidence and witness testimony",
            "Time to consult with attorneys and medical experts",
            "Avoid rushed settlement decisions"
        ],
        "comparison": "Compare to shortest SOLs: TN/KY (1 year), LA pre-2024 (1 year)",
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
-- END OF MAINE DOG BITE RULES SEED FILE
-- =====================================================================================
