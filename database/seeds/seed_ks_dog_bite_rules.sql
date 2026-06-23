-- =====================================================================================
-- KANSAS DOG BITE LIABILITY RULES SEED FILE
-- =====================================================================================
-- State: Kansas (KS)
-- Sub-Specialization: Dog Bite (Personal Injury)
-- Liability Model: ONE-BITE RULE (Common Law Scienter - since 1897)
-- Legal Standard: Owner liable if knew or should have known of dog's dangerous propensity
-- Primary Authority: Common law scienter doctrine (adopted 1897)
-- Statute of Limitations: 2 years (K.S.A. 60-513)
-- 
-- VERIFICATION STATUS: DOCUMENT VERIFIED
-- Research Date: January 30, 2026
-- Sources Verified:
--   1. Common law one-bite rule - Verified from multiple legal sources (dogbitelaw.com, Nolo, Hollis Law)
--   2. K.S.A. 60-513 - 2-year SOL for personal injury
--   3. Henkel v. Jordan case law establishing liability standards
-- =====================================================================================

-- =====================================================================================
-- PART 1: LEGAL SOURCES
-- =====================================================================================

-- Source 1: Kansas Common Law One-Bite Rule (Scienter Doctrine)
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
    'KS',
    NULL,
    NULL,
    'Kansas Dog Bite Common Law - One-Bite Rule',
    'Kansas Courts',
    'Common Law Scienter Doctrine',
    'https://www.dogbitelaw.com/one-bite-state/kansas-dog-bite-law/',
    'case_law',
    'high',
    'Kansas Dog Bite Law - Common Law Scienter Doctrine (Adopted 1897):

Kansas does NOT have a specific dog bite statute. Instead, Kansas follows the common law "ONE-BITE RULE," which was adopted in 1897.

LEGAL STANDARD:
A dog owner is liable for injuries caused by their dog ONLY IF the owner knew or should have known of the dog''s dangerous propensity to bite (SCIENTER).

KEY PRINCIPLES:
- NO STRICT LIABILITY: Kansas does NOT impose strict liability; owner must have prior knowledge of dog''s dangerous propensity
- ONE-BITE RULE: Owner generally not liable for first bite unless owner was negligent
- SCIENTER REQUIRED: Plaintiff must prove owner knew or should have known of dog''s vicious propensity

METHODS TO PROVE OWNER KNOWLEDGE (SCIENTER):
1. PRIOR BITING INCIDENTS: Evidence of prior bites or attacks
2. AGGRESSIVE BEHAVIOR: Evidence of prior growling, snapping, lunging, menacing
3. OWNER STATEMENTS: Owner''s acknowledgment of dog''s aggression
4. COMPLAINTS: Prior complaints to owner about dog''s behavior
5. BREED REPUTATION: Limited weight (not dispositive alone)
6. WARNING SIGNS: "Beware of Dog" signs may evidence owner knowledge

ALTERNATIVE THEORIES OF LIABILITY:
Even without scienter, plaintiff may recover through:
1. NEGLIGENCE: Owner failed to exercise reasonable care in controlling dog
2. NEGLIGENCE PER SE: Owner violated animal control ordinance (e.g., leash law)
3. INTENTIONAL TORT: Owner intentionally sicced dog on plaintiff
4. DOG FRIGHT: Dog''s frightening behavior caused injury (Henkel v. Jordan case)

HENKEL V. JORDAN CASE:
Kansas recognizes liability for "dog fright" - injuries caused by dog''s frightening behavior even without physical contact.

COMPARATIVE NEGLIGENCE:
Kansas follows comparative fault rule. If plaintiff is 50% or more at fault, plaintiff cannot recover. If plaintiff less than 50% at fault, recovery reduced proportionally.

DOCUMENT VERIFIED from multiple legal sources (dogbitelaw.com, Nolo, Hollis Law Firm, DM Law USA).'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET
    base_url = EXCLUDED.base_url,
    notes = EXCLUDED.notes;

-- Source 2: Kansas Statute of Limitations - Personal Injury (K.S.A. 60-513)
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
    'KS',
    NULL,
    NULL,
    'Kansas Statute of Limitations - Personal Injury (Dog Bite)',
    'Kansas Legislature',
    'K.S.A. 60-513',
    'https://www.nolo.com/legal-encyclopedia/kansas-personal-injury-laws-and-statutes-of-limitations.html',
    'statute',
    'high',
    'K.S.A. 60-513(a)(4) - Statute of limitations for personal injury actions:

Personal injury actions, including dog bite claims, must be commenced within TWO YEARS from the date the cause of action accrues.

APPLICATION TO DOG BITES:
Dog bite claims (whether based on scienter, negligence, or other theories) are subject to this TWO YEAR statute of limitations. The two-year period begins on the date of the dog bite injury.

DISCOVERY RULE:
Kansas recognizes discovery rule - statute may be tolled if injury not immediately discoverable until plaintiff discovers or reasonably should have discovered injury.

TOLLING PROVISIONS:
- Minors: Minors have until one year after 18th birthday to file (but no more than 8 years from injury date)
- Mental incapacity: Statute may be tolled
- Defendant leaves Kansas: Time may be tolled
- Defendant hides: Statute may be paused

STATUTE OF REPOSE:
Maximum 10 years from injury date (4 years for medical malpractice)

DOCUMENT VERIFIED from Kansas statutes and multiple legal sources.'
) ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) 
DO UPDATE SET
    base_url = EXCLUDED.base_url,
    notes = EXCLUDED.notes;

-- =====================================================================================
-- PART 2: VALIDATION RULES
-- =====================================================================================

-- Rule 1: Kansas One-Bite Rule (Scienter Doctrine)
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
    'KS-PI-DOG-BITE-ONE-BITE-RULE',
    5,
    'KS Dog Bite One-Bite Rule (Common Law Scienter)',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'KS',
    '{
        "liability_model": "one_bite_rule",
        "legal_basis": "Common law scienter doctrine (adopted 1897)",
        "legal_standard": "Owner liable if knew or should have known of dog''s dangerous propensity",
        "key_requirements": [
            "Dog bit or injured plaintiff",
            "Owner knew or should have known of dog''s dangerous propensity",
            "Plaintiff did NOT provoke dog",
            "Plaintiff was lawfully present"
        ],
        "no_strict_liability": "Kansas does NOT impose strict liability; owner must have prior knowledge",
        "scienter_required": "Plaintiff must prove owner knew or should have known of dog''s vicious propensity",
        "proving_scienter": {
            "methods": [
                "Prior biting incidents",
                "Prior attacks or attempted attacks",
                "Aggressive behavior (growling, snapping, lunging, menacing)",
                "Owner statements acknowledging dog''s aggression",
                "Complaints to owner about dog''s behavior",
                "Warning signs posted (''Beware of Dog'')",
                "Breed reputation (limited weight, not dispositive alone)"
            ]
        },
        "alternative_liability_theories": [
            "NEGLIGENCE: Owner failed to exercise reasonable care in controlling dog",
            "NEGLIGENCE PER SE: Owner violated animal control ordinance (leash law, confinement)",
            "INTENTIONAL TORT: Owner intentionally sicced dog on plaintiff",
            "DOG FRIGHT: Dog''s frightening behavior caused injury (Henkel v. Jordan)"
        ],
        "comparative_negligence": {
            "rule": "Kansas follows comparative fault",
            "50_percent_bar": "If plaintiff 50% or more at fault, plaintiff cannot recover",
            "reduction": "If plaintiff less than 50% at fault, recovery reduced proportionally"
        },
        "damages_recoverable": [
            "Medical expenses",
            "Lost wages",
            "Pain and suffering",
            "Emotional distress",
            "Permanent scarring/disfigurement",
            "Loss of enjoyment of life"
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

-- Rule 2: Kansas Negligence Theory (Alternative to Scienter)
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
    'KS-PI-DOG-BITE-NEGLIGENCE',
    5,
    'KS Dog Bite Negligence Theory (Alternative)',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'KS',
    '{
        "liability_model": "negligence",
        "when_to_use": "When cannot prove scienter (owner knowledge of dangerous propensity)",
        "legal_standard": "Owner liable if failed to exercise reasonable care in controlling dog",
        "key_requirements": [
            "Owner owed duty of care to plaintiff",
            "Owner breached duty (unreasonable conduct)",
            "Breach proximately caused plaintiff''s injury",
            "Plaintiff suffered damages"
        ],
        "unreasonable_conduct_examples": [
            "Failed to restrain dog known to be aggressive",
            "Violated leash law or confinement ordinance (negligence per se)",
            "Failed to warn of known danger",
            "Allowed dog to roam free",
            "Failed to properly secure dog"
        ],
        "negligence_per_se": "Violation of animal control ordinance (leash law) is evidence of negligence",
        "comparative_fault_applies": "Same 50% bar rule applies to negligence claims",
        "burden_of_proof": "Lower than strict liability but higher than proving scienter alone"
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

-- Rule 3: Kansas Statute of Limitations - 2 Years
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
    'KS-PI-DOG-BITE-SOL-2-YEARS',
    5,
    'KS Dog Bite Statute of Limitations (2 Years)',
    'content_check',
    'personal_injury',
    'complaint',
    'state',
    'KS',
    '{
        "statute": "K.S.A. 60-513(a)(4)",
        "statute_of_limitations": "2 years",
        "accrual_date": "Date cause of action accrues (date of dog bite injury)",
        "key_requirements": [
            "Action must be commenced within 2 years of dog bite",
            "Applies to scienter claims",
            "Applies to negligence claims",
            "Applies to all personal injury actions",
            "Failure to file timely bars recovery"
        ],
        "discovery_rule": "Statute may be tolled if injury not immediately discoverable until plaintiff discovers or reasonably should have discovered",
        "tolling_provisions": [
            "Minors: Until one year after 18th birthday (but no more than 8 years from injury)",
            "Mental incapacity: Statute may be tolled",
            "Defendant leaves Kansas: Time may be tolled",
            "Defendant hides: Statute may be paused"
        ],
        "statute_of_repose": "Maximum 10 years from injury date (4 years for medical malpractice)",
        "consequence_of_violation": "Claim time-barred; court will dismiss; no recovery possible"
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
-- END OF KANSAS DOG BITE RULES SEED FILE
-- =====================================================================================
