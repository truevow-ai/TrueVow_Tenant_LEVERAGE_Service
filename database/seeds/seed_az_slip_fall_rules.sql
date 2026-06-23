-- =====================================================================================
-- ARIZONA SLIP & FALL / PREMISES LIABILITY RULES SEED FILE
-- =====================================================================================
-- State: Arizona (AZ)
-- Practice Area: Personal Injury
-- Sub-Specialization: Slip & Fall / Premises Liability
-- Liability Model: COMMON LAW (Invitee/Licensee/Trespasser distinctions)
-- Primary Authority: ARS 12-557 (Trespasser liability), ARS 12-2505 (Comparative negligence)
-- Statute of Limitations: 2 years (ARS 12-542)
-- Comparative Negligence: PURE COMPARATIVE (can recover even if 99% at fault)
-- 
-- VERIFICATION STATUS: DOCUMENT VERIFIED
-- Research Date: January 31, 2026
-- Sources Verified:
--   1. ARS 12-557 - Possessors of land; limited liability for trespasser harm
--   2. ARS 12-2505 - Pure comparative negligence statute
--   3. ARS 12-542 - 2-year statute of limitations for personal injury
--   4. Common law invitee/licensee/trespasser distinctions verified from multiple sources
-- =====================================================================================

-- =====================================================================================
-- RULE 1: INVITEE DUTY OF CARE (HIGHEST STANDARD)
-- =====================================================================================
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'AZ-SLIP-FALL-INVITEE-DUTY', 5, 'AZ Invitee Duty of Care (Highest Standard)', 'content_check',
    'personal_injury', 'slip_fall', 'complaint', 'state', 'AZ',
    '{
        "sub_specialization_type": "premises_liability",
        "liability_model": "common_law_invitee",
        "authority_level": "contextual_rule",
        "visitor_classification": "invitee",
        "duty_of_care_standard": "highest",
        "invitee_definition": "Person invited onto property for mutual benefit or business purposes",
        "property_owner_duties": {
            "reasonable_care": "Must exercise reasonable care to maintain premises in safe condition",
            "active_inspection": "Must regularly inspect for hazards",
            "remedy_hazards": "Must remedy known and discoverable hazards",
            "warn_of_dangers": "Must warn of hidden or non-obvious dangers"
        },
        "verification": {
            "multiple_sources": ["Bleaman Law Firm - AZ Premises Liability", "JSH Reference Guide - Chapter 14", "AZ Legal - Premises Liability Rights", "Burg Simpson - Understanding Premises Liability"],
            "current_as_of": "2024-2026",
            "source_type": "common_law",
            "last_verified": "2026-01-31",
            "confidence": "high"
        }
    }'::jsonb,
    'error', 'document_verified', true, false, NOW(), NOW()
) ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- =====================================================================================
-- RULE 2: LICENSEE DUTY OF CARE (MODERATE STANDARD)
-- =====================================================================================
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'AZ-SLIP-FALL-LICENSEE-DUTY', 5, 'AZ Licensee Duty of Care (Moderate Standard)', 'content_check',
    'personal_injury', 'slip_fall', 'complaint', 'state', 'AZ',
    '{
        "sub_specialization_type": "premises_liability",
        "liability_model": "common_law_licensee",
        "authority_level": "contextual_rule",
        "visitor_classification": "licensee",
        "duty_of_care_standard": "moderate",
        "licensee_definition": "Person on property with permission for own purposes (social guests)",
        "property_owner_duties": {
            "warn_known_dangers": "Must warn of known dangerous conditions",
            "no_inspection_duty": "No duty to inspect for unknown hazards",
            "no_willful_harm": "Must not willfully harm licensee"
        },
        "verification": {
            "multiple_sources": ["Bleaman Law Firm", "JSH Reference Guide", "AZ Legal", "Disability Arizona"],
            "current_as_of": "2024-2026",
            "source_type": "common_law",
            "last_verified": "2026-01-31",
            "confidence": "high"
        }
    }'::jsonb,
    'error', 'document_verified', true, false, NOW(), NOW()
) ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- =====================================================================================
-- RULE 3: TRESPASSER DUTY (ARS 12-557)
-- =====================================================================================
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'AZ-SLIP-FALL-TRESPASSER-DUTY', 5, 'AZ Trespasser Duty (ARS 12-557)', 'content_check',
    'personal_injury', 'slip_fall', 'complaint', 'state', 'AZ',
    '{
        "sub_specialization_type": "premises_liability",
        "liability_model": "statutory_trespasser",
        "authority_level": "contextual_rule",
        "statute": "ARS 12-557",
        "current_status": "Active as of 2024-2026",
        "visitor_classification": "trespasser",
        "duty_of_care_standard": "minimal",
        "trespasser_definition": "Person who enters property without permission",
        "property_owner_duties": {
            "no_general_duty": "No duty of care owed to trespassers",
            "avoid_intentional_harm": "Must avoid intentional or willful harm only"
        },
        "verification": {
            "statute_text_verified": true,
            "full_text_source": "https://law.justia.com/codes/arizona/title-12/section-12-557/",
            "multiple_sources": ["Justia - ARS 12-557", "JSH Reference Guide"],
            "current_as_of": "2024-2026",
            "source_type": "primary_law",
            "last_verified": "2026-01-31",
            "confidence": "high"
        }
    }'::jsonb,
    'error', 'document_verified', true, false, NOW(), NOW()
) ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- =====================================================================================
-- RULE 4: PURE COMPARATIVE NEGLIGENCE (ARS 12-2505)
-- =====================================================================================
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'AZ-SLIP-FALL-PURE-COMPARATIVE', 5, 'AZ Pure Comparative Negligence (ARS 12-2505)', 'content_check',
    'personal_injury', 'slip_fall', 'complaint', 'state', 'AZ',
    '{
        "sub_specialization_type": "premises_liability",
        "authority_level": "contextual_rule",
        "statute": "ARS 12-2505",
        "current_status": "Active as of 2024-2026",
        "negligence_model": "pure_comparative",
        "rule_description": "Arizona follows pure comparative negligence: plaintiff can recover even if 99% at fault",
        "recovery_rule": "Recovery reduced by plaintiffs percentage of fault",
        "several_liability": "Each defendant liable only for their proportionate share of fault",
        "verification": {
            "statute_text_verified": true,
            "multiple_sources": ["Jensen Phelan Law", "West Coast Trial Lawyers", "Runion Injury Law", "Wesbrooks Law", "FindLaw - ARS 12-2505"],
            "current_as_of": "2024-2026",
            "source_type": "primary_law",
            "last_verified": "2026-01-31",
            "confidence": "high"
        }
    }'::jsonb,
    'error', 'document_verified', true, false, NOW(), NOW()
) ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- =====================================================================================
-- RULE 5: STATUTE OF LIMITATIONS (ARS 12-542)
-- =====================================================================================
INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, specialization, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template, created_at, updated_at
) VALUES (
    'AZ-SLIP-FALL-SOL', 5, 'AZ Slip & Fall Statute of Limitations (2 Years - ARS 12-542)', 'content_check',
    'personal_injury', 'slip_fall', 'complaint', 'state', 'AZ',
    '{
        "sub_specialization_type": "premises_liability",
        "authority_level": "contextual_rule",
        "statute": "ARS 12-542",
        "current_status": "Active as of 2024-2026",
        "statute_of_limitations": "2 years",
        "accrual_date": "Date of slip and fall accident",
        "consequence_of_violation": "Claim time-barred; no recovery possible",
        "verification": {
            "statute_text_verified": true,
            "full_text_source": "https://www.azleg.gov/ars/12/00542.htm",
            "multiple_sources": ["Glazer Hammond", "Al-Sayyed Law", "Queen Creek Law", "Friedl Richardson", "FindLaw - ARS 12-542"],
            "current_as_of": "2024-2026",
            "source_type": "primary_law",
            "last_verified": "2026-01-31",
            "confidence": "high"
        }
    }'::jsonb,
    'error', 'document_verified', true, false, NOW(), NOW()
) ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config, updated_at = NOW();

-- =====================================================================================
-- END OF ARIZONA SLIP & FALL RULES SEED FILE
-- Total Rules: 5
-- =====================================================================================
