-- =====================================================================================
-- KENTUCKY DOG BITE LIABILITY RULES SEED FILE
-- =====================================================================================
-- State: Kentucky (KY)
-- Sub-Specialization: Dog Bite (Personal Injury)
-- Liability Model: STRICT LIABILITY (Statutory)
-- Legal Standard: Owner liable for damages caused by dog to person, livestock, or property
-- Primary Authority: KRS 258.235(4)
-- Statute of Limitations: 1 year (KRS 413.140) - SHORTEST IN NATION
-- 
-- VERIFICATION STATUS: DOCUMENT VERIFIED
-- Research Date: January 30, 2026
-- Sources Verified:
--   1. KRS 258.235(4) - Verified from multiple legal sources (dogbitelaw.com, Nolo, Justia)
--   2. KRS 413.140 - 1-year SOL for personal injury
--   3. Strict liability regardless of prior knowledge
-- =====================================================================================

-- =====================================================================================
-- PART 1: LEGAL SOURCES
-- =====================================================================================

-- Source 1: Kentucky Dog Bite Strict Liability Statute (KRS 258.235)
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
    'KY',
    NULL,
    NULL,
    'Kentucky Dog Bite Strict Liability Statute',
    'Kentucky Legislature',
    'KRS 258.235(4)',
    'https://law.justia.com/codes/kentucky/chapter-258/section-258-235/',
    'statute',
    'high',
    'KRS 258.235(4) - Liability for damage:

Any owner whose dog is found to have damaged a person, livestock, or other property shall be responsible for that damage.

KEY PROVISIONS:
- STRICT LIABILITY: Owner liable regardless of dog''s prior viciousness or owner''s knowledge
- NO ONE-BITE RULE: Liability attaches even on first bite
- BROAD SCOPE: Applies to damage to persons, livestock, OR other property
- OWNER DEFINITION: "Owner" broadly includes anyone with possession, custody, or control of dog
- NO PROOF OF NEGLIGENCE REQUIRED: Strict liability statute

COMPARATIVE NEGLIGENCE:
Kentucky follows comparative negligence rule. If victim is partially at fault, damages reduced proportionally. If victim is 50% or more at fault, victim cannot recover.

TRESPASSER DEFENSE:
Trespassers (including children) generally CANNOT recover damages under this statute.

ADDITIONAL PROVISIONS (KRS 258.235):
- Authority to kill or seize dog: Any person may kill or seize dog attacking person or livestock
- Vicious dog confinement: Court may order vicious dog to be securely confined (locked enclosure/kennel) and muzzled when outside
- Unlawful to allow vicious dog to run at large
- Proceeding by person attacked: Victim may make complaint to court; court may order confinement or destruction

DOCUMENT VERIFIED from Kentucky Revised Statutes and multiple legal sources (dogbitelaw.com, Nolo, Kentucky Legal Team).'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET
    base_url = EXCLUDED.base_url,
    notes = EXCLUDED.notes;

-- Source 2: Kentucky Statute of Limitations - Personal Injury (KRS 413.140)
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
    'KY',
    NULL,
    NULL,
    'Kentucky Statute of Limitations - Personal Injury (Dog Bite)',
    'Kentucky Legislature',
    'KRS 413.140',
    'https://apps.legislature.ky.gov/law/statutes/chapter.aspx?id=39261',
    'statute',
    'high',
    'KRS 413.140(1)(a) - Statute of limitations for personal injury actions:

Actions for which a limitation period is not otherwise prescribed shall be commenced within ONE YEAR after the cause of action accrued.

APPLICATION TO DOG BITES:
Claims brought under KRS 258.235(4) (strict liability statute) are subject to this ONE YEAR statute of limitations. The one-year period begins on the date of the dog bite injury.

CRITICAL WARNING: Kentucky has the SHORTEST statute of limitations for personal injury in the United States (tied with Tennessee and Louisiana for injuries before July 1, 2024). Victims must act extremely fast.

TOLLING PROVISIONS:
- Minors: Statute may be tolled until minor reaches age of majority
- Defendant leaves Kentucky: Time may be tolled
- Discovery rule: Limited tolling if injury not immediately apparent

STRATEGIC NOTES:
- MUST file within 1 year from date of dog bite
- Evidence preservation CRITICAL
- Prompt medical attention and reporting ESSENTIAL
- Legal consultation must happen IMMEDIATELY after bite

DOCUMENT VERIFIED from Kentucky Revised Statutes and multiple legal sources.'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET
    base_url = EXCLUDED.base_url,
    notes = EXCLUDED.notes;

-- =====================================================================================
-- PART 2: VALIDATION RULES
-- =====================================================================================

-- Rule 1: Kentucky Strict Liability (KRS 258.235)
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
    'KY-PI-DOG-BITE-STRICT-LIABILITY',
    5,
    'KY Dog Bite Strict Liability (KRS 258.235)',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'KY',
    '{
        "liability_model": "strict_liability",
        "statute": "KRS 258.235(4)",
        "legal_standard": "Owner liable for damages caused by dog to person, livestock, or other property",
        "key_requirements": [
            "Dog damaged plaintiff (person, livestock, or property)",
            "Defendant was owner of dog",
            "Plaintiff was NOT trespassing",
            "Owner is liable regardless of dog''s prior viciousness",
            "Owner is liable regardless of owner''s knowledge of viciousness"
        ],
        "no_one_bite_rule": "Kentucky does NOT follow one-bite rule; strict liability on first bite",
        "no_prior_knowledge_required": "Owner liable regardless of lack of knowledge of dog''s dangerous propensities",
        "broad_owner_definition": "''Owner'' includes anyone with possession, custody, or control of dog",
        "broad_scope": "Applies to damage to persons, livestock, OR other property",
        "comparative_negligence": {
            "rule": "Kentucky follows comparative negligence",
            "50_percent_bar": "If victim 50% or more at fault, victim cannot recover",
            "reduction": "If victim less than 50% at fault, recovery reduced proportionally"
        },
        "trespasser_defense": "Trespassers (including children) generally CANNOT recover under this statute",
        "damages_recoverable": [
            "Medical expenses",
            "Lost wages",
            "Pain and suffering",
            "Emotional distress",
            "Permanent scarring/disfigurement",
            "Property damage",
            "Punitive damages (in egregious cases)"
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

-- Rule 2: Kentucky Statute of Limitations - 1 YEAR (SHORTEST IN NATION)
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
    'KY-PI-DOG-BITE-SOL-1-YEAR',
    5,
    'KY Dog Bite Statute of Limitations (1 YEAR - SHORTEST IN NATION)',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'KY',
    '{
        "statute": "KRS 413.140(1)(a)",
        "statute_of_limitations": "1 year",
        "sol_years": 1,
        "sol_days": 365,
        "critical_warning": "SHORTEST SOL IN NATION (tied with TN and LA pre-2024)",
        "accrual_date": "Date cause of action accrued (date of dog bite injury)",
        "key_requirements": [
            "Action must be commenced within 1 YEAR of dog bite",
            "Applies to claims under KRS 258.235(4) (strict liability)",
            "Failure to file within 1 year bars recovery",
            "NO EXTENSIONS except narrow tolling provisions"
        ],
        "tolling_provisions": [
            "Minors: Statute may be tolled until minor reaches age of majority",
            "Defendant leaves Kentucky: Time may be tolled",
            "Discovery rule: Limited tolling if injury not immediately apparent"
        ],
        "strategic_notes": [
            "MUST ACT IMMEDIATELY - 1 year passes VERY quickly",
            "Evidence preservation CRITICAL (photographs, witness statements, medical records)",
            "Prompt medical attention and reporting ESSENTIAL",
            "Legal consultation must happen IMMEDIATELY after bite",
            "Insurance claims process can take time - do NOT wait",
            "Missing 1-year deadline is FATAL to claim"
        ],
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
-- END OF KENTUCKY DOG BITE RULES SEED FILE
-- =====================================================================================
