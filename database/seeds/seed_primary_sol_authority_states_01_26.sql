-- =====================================================================================
-- PRIMARY SOL AUTHORITY SEED FILE: STATES 1-26
-- =====================================================================================
-- Purpose: Create canonical intake authority rows for tenant-app routing
-- Created: January 30, 2026
-- States Covered: AL, AK, AZ, AR, CA, CO, CT, DE, FL, GA, HI, ID, IL, IN, IA,
--                 KS, KY, LA, ME, MD, MA, MI, MN, MS, MO, MT
-- 
-- ARCHITECTURE:
--   - These are PRIMARY SOL AUTHORITY rows (authority_level = "primary_state_sol")
--   - Tenant-app reads ONLY these rows for intake routing
--   - DRAFT-service maintains contextual rules separately
--   - One active version per state+practice (valid_to = null)
--   - Versioned for legal defensibility
-- 
-- VERSIONING:
--   - sol_version: "1.0.0" (initial version for all states)
--   - valid_from: Statute effective date (or earliest known date)
--   - valid_to: null (active version)
-- =====================================================================================

-- =====================================================================================
-- STATE 1: ALABAMA (AL)
-- =====================================================================================
-- Liability Model: HYBRID (Strict on-property / One-bite off-property)
-- SOL: 2 years (Ala. Code § 6-2-38)
-- =====================================================================================

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'AL-PI-PRIMARY-SOL',
    5,
    'AL Personal Injury Primary SOL Authority',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'AL',
    '{
        "sol_years": 2,
        "sol_days": 730,
        "statute": "Ala. Code § 6-2-38",
        "effective_date": "1975-01-01",
        "discovery_rule": false,
        "authority_level": "primary_state_sol",
        "sol_version": "1.0.0",
        "valid_from": "1975-01-01",
        "valid_to": null
    }'::jsonb,
    'error',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
) ON CONFLICT ON CONSTRAINT unique_active_state_sol DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    validator_level = EXCLUDED.validator_level,
    validator_name = EXCLUDED.validator_name,
    validator_type = EXCLUDED.validator_type,
    severity = EXCLUDED.severity,
    review_status = EXCLUDED.review_status,
    is_active = EXCLUDED.is_active,
    updated_at = NOW();

-- =====================================================================================
-- STATE 2: ALASKA (AK)
-- =====================================================================================
-- Liability Model: ONE-BITE RULE (Common law scienter)
-- SOL: 2 years (Alaska Stat. § 09.10.070)
-- =====================================================================================

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'AK-PI-PRIMARY-SOL',
    5,
    'AK Personal Injury Primary SOL Authority',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'AK',
    '{
        "sol_years": 2,
        "sol_days": 730,
        "statute": "Alaska Stat. § 09.10.070",
        "effective_date": "1962-01-01",
        "discovery_rule": true,
        "authority_level": "primary_state_sol",
        "sol_version": "1.0.0",
        "valid_from": "1962-01-01",
        "valid_to": null
    }'::jsonb,
    'error',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
) ON CONFLICT ON CONSTRAINT unique_active_state_sol DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    validator_level = EXCLUDED.validator_level,
    validator_name = EXCLUDED.validator_name,
    validator_type = EXCLUDED.validator_type,
    severity = EXCLUDED.severity,
    review_status = EXCLUDED.review_status,
    is_active = EXCLUDED.is_active,
    updated_at = NOW();

-- =====================================================================================
-- STATE 3: ARIZONA (AZ)
-- =====================================================================================
-- Liability Model: STRICT LIABILITY (ARS § 11-1025)
-- SOL: 1 year for strict liability (ARS § 12-541); 2 years for negligence (ARS § 12-542)
-- Note: Using 1-year for primary authority (strictest/shortest deadline)
-- =====================================================================================

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'AZ-PI-PRIMARY-SOL',
    5,
    'AZ Personal Injury Primary SOL Authority',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'AZ',
    '{
        "sol_years": 1,
        "sol_days": 365,
        "statute": "ARS § 12-541(5)",
        "effective_date": "1956-01-01",
        "discovery_rule": false,
        "note": "1 year for strict liability claims under ARS § 11-1025; 2 years for negligence claims under ARS § 12-542",
        "authority_level": "primary_state_sol",
        "sol_version": "1.0.0",
        "valid_from": "1956-01-01",
        "valid_to": null
    }'::jsonb,
    'error',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
) ON CONFLICT ON CONSTRAINT unique_active_state_sol DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    validator_level = EXCLUDED.validator_level,
    validator_name = EXCLUDED.validator_name,
    validator_type = EXCLUDED.validator_type,
    severity = EXCLUDED.severity,
    review_status = EXCLUDED.review_status,
    is_active = EXCLUDED.is_active,
    updated_at = NOW();

-- =====================================================================================
-- STATE 4: ARKANSAS (AR)
-- =====================================================================================
-- Liability Model: ONE-BITE RULE (Common law scienter)
-- SOL: 3 years (Ark. Code Ann. § 16-56-105)
-- =====================================================================================

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'AR-PI-PRIMARY-SOL',
    5,
    'AR Personal Injury Primary SOL Authority',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'AR',
    '{
        "sol_years": 3,
        "sol_days": 1095,
        "statute": "Ark. Code Ann. § 16-56-105",
        "effective_date": "1968-01-01",
        "discovery_rule": true,
        "authority_level": "primary_state_sol",
        "sol_version": "1.0.0",
        "valid_from": "1968-01-01",
        "valid_to": null
    }'::jsonb,
    'error',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
) ON CONFLICT ON CONSTRAINT unique_active_state_sol DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    validator_level = EXCLUDED.validator_level,
    validator_name = EXCLUDED.validator_name,
    validator_type = EXCLUDED.validator_type,
    severity = EXCLUDED.severity,
    review_status = EXCLUDED.review_status,
    is_active = EXCLUDED.is_active,
    updated_at = NOW();

-- =====================================================================================
-- STATE 5: CALIFORNIA (CA)
-- =====================================================================================
-- Liability Model: STRICT LIABILITY (Cal. Civ. Code § 3342)
-- SOL: 2 years (Cal. Code Civ. Proc. § 335.1)
-- =====================================================================================

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'CA-PI-PRIMARY-SOL',
    5,
    'CA Personal Injury Primary SOL Authority',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'CA',
    '{
        "sol_years": 2,
        "sol_days": 730,
        "statute": "Cal. Code Civ. Proc. § 335.1",
        "effective_date": "2003-01-01",
        "discovery_rule": true,
        "authority_level": "primary_state_sol",
        "sol_version": "1.0.0",
        "valid_from": "2003-01-01",
        "valid_to": null
    }'::jsonb,
    'error',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
) ON CONFLICT ON CONSTRAINT unique_active_state_sol DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    validator_level = EXCLUDED.validator_level,
    validator_name = EXCLUDED.validator_name,
    validator_type = EXCLUDED.validator_type,
    severity = EXCLUDED.severity,
    review_status = EXCLUDED.review_status,
    is_active = EXCLUDED.is_active,
    updated_at = NOW();

-- =====================================================================================
-- STATE 6: COLORADO (CO)
-- =====================================================================================
-- Liability Model: LIMITED STRICT LIABILITY (Serious bodily injury only)
-- SOL: 2 years (Colo. Rev. Stat. § 13-80-102)
-- =====================================================================================

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'CO-PI-PRIMARY-SOL',
    5,
    'CO Personal Injury Primary SOL Authority',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'CO',
    '{
        "sol_years": 2,
        "sol_days": 730,
        "statute": "Colo. Rev. Stat. § 13-80-102(1)(a)",
        "effective_date": "1986-07-01",
        "discovery_rule": true,
        "authority_level": "primary_state_sol",
        "sol_version": "1.0.0",
        "valid_from": "1986-07-01",
        "valid_to": null
    }'::jsonb,
    'error',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
) ON CONFLICT ON CONSTRAINT unique_active_state_sol DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    validator_level = EXCLUDED.validator_level,
    validator_name = EXCLUDED.validator_name,
    validator_type = EXCLUDED.validator_type,
    severity = EXCLUDED.severity,
    review_status = EXCLUDED.review_status,
    is_active = EXCLUDED.is_active,
    updated_at = NOW();

-- =====================================================================================
-- STATE 7: CONNECTICUT (CT)
-- =====================================================================================
-- Liability Model: STRICT LIABILITY (Conn. Gen. Stat. § 22-357)
-- SOL: 3 years (Conn. Gen. Stat. § 52-577)
-- =====================================================================================

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'CT-PI-PRIMARY-SOL',
    5,
    'CT Personal Injury Primary SOL Authority',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'CT',
    '{
        "sol_years": 3,
        "sol_days": 1095,
        "statute": "Conn. Gen. Stat. § 52-577",
        "effective_date": "1959-01-01",
        "discovery_rule": false,
        "authority_level": "primary_state_sol",
        "sol_version": "1.0.0",
        "valid_from": "1959-01-01",
        "valid_to": null
    }'::jsonb,
    'error',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
) ON CONFLICT ON CONSTRAINT unique_active_state_sol DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    validator_level = EXCLUDED.validator_level,
    validator_name = EXCLUDED.validator_name,
    validator_type = EXCLUDED.validator_type,
    severity = EXCLUDED.severity,
    review_status = EXCLUDED.review_status,
    is_active = EXCLUDED.is_active,
    updated_at = NOW();

-- =====================================================================================
-- STATE 8: DELAWARE (DE)
-- =====================================================================================
-- Liability Model: STRICT LIABILITY (7 Del. C. § 1711)
-- SOL: 2 years (10 Del. C. § 8119)
-- =====================================================================================

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'DE-PI-PRIMARY-SOL',
    5,
    'DE Personal Injury Primary SOL Authority',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'DE',
    '{
        "sol_years": 2,
        "sol_days": 730,
        "statute": "10 Del. C. § 8119",
        "effective_date": "1770-01-01",
        "discovery_rule": false,
        "note": "Strict liability statute dates from 1770; SOL codified in 10 Del. C. § 8119",
        "authority_level": "primary_state_sol",
        "sol_version": "1.0.0",
        "valid_from": "1770-01-01",
        "valid_to": null
    }'::jsonb,
    'error',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
) ON CONFLICT ON CONSTRAINT unique_active_state_sol DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    validator_level = EXCLUDED.validator_level,
    validator_name = EXCLUDED.validator_name,
    validator_type = EXCLUDED.validator_type,
    severity = EXCLUDED.severity,
    review_status = EXCLUDED.review_status,
    is_active = EXCLUDED.is_active,
    updated_at = NOW();

-- =====================================================================================
-- STATE 9: FLORIDA (FL)
-- =====================================================================================
-- Liability Model: STRICT LIABILITY (Fla. Stat. § 767.04)
-- SOL: 2 years (Fla. Stat. § 95.11) - Changed from 4 years on March 24, 2023
-- =====================================================================================

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'FL-PI-PRIMARY-SOL',
    5,
    'FL Personal Injury Primary SOL Authority',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'FL',
    '{
        "sol_years": 2,
        "sol_days": 730,
        "statute": "Fla. Stat. § 95.11(3)(o)",
        "effective_date": "2023-03-24",
        "discovery_rule": false,
        "note": "Changed from 4 years to 2 years effective March 24, 2023 (HB 837)",
        "authority_level": "primary_state_sol",
        "sol_version": "2.0.0",
        "valid_from": "2023-03-24",
        "valid_to": null
    }'::jsonb,
    'error',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
) ON CONFLICT ON CONSTRAINT unique_active_state_sol DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    validator_level = EXCLUDED.validator_level,
    validator_name = EXCLUDED.validator_name,
    validator_type = EXCLUDED.validator_type,
    severity = EXCLUDED.severity,
    review_status = EXCLUDED.review_status,
    is_active = EXCLUDED.is_active,
    updated_at = NOW();

-- =====================================================================================
-- STATE 10: GEORGIA (GA)
-- =====================================================================================
-- Liability Model: MODIFIED ONE-BITE RULE (Ordinance violation establishes propensity)
-- SOL: 2 years (O.C.G.A. § 9-3-33)
-- =====================================================================================

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'GA-PI-PRIMARY-SOL',
    5,
    'GA Personal Injury Primary SOL Authority',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'GA',
    '{
        "sol_years": 2,
        "sol_days": 730,
        "statute": "O.C.G.A. § 9-3-33",
        "effective_date": "1863-01-01",
        "discovery_rule": false,
        "authority_level": "primary_state_sol",
        "sol_version": "1.0.0",
        "valid_from": "1863-01-01",
        "valid_to": null
    }'::jsonb,
    'error',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
) ON CONFLICT ON CONSTRAINT unique_active_state_sol DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    validator_level = EXCLUDED.validator_level,
    validator_name = EXCLUDED.validator_name,
    validator_type = EXCLUDED.validator_type,
    severity = EXCLUDED.severity,
    review_status = EXCLUDED.review_status,
    is_active = EXCLUDED.is_active,
    updated_at = NOW();

-- =====================================================================================
-- STATE 11: HAWAII (HI)
-- =====================================================================================
-- Liability Model: STRICT LIABILITY (HRS § 663-9)
-- SOL: 2 years (HRS § 657-7)
-- =====================================================================================

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'HI-PI-PRIMARY-SOL',
    5,
    'HI Personal Injury Primary SOL Authority',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'HI',
    '{
        "sol_years": 2,
        "sol_days": 730,
        "statute": "HRS § 657-7",
        "effective_date": "1972-07-01",
        "discovery_rule": false,
        "authority_level": "primary_state_sol",
        "sol_version": "1.0.0",
        "valid_from": "1972-07-01",
        "valid_to": null
    }'::jsonb,
    'error',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
) ON CONFLICT ON CONSTRAINT unique_active_state_sol DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    validator_level = EXCLUDED.validator_level,
    validator_name = EXCLUDED.validator_name,
    validator_type = EXCLUDED.validator_type,
    severity = EXCLUDED.severity,
    review_status = EXCLUDED.review_status,
    is_active = EXCLUDED.is_active,
    updated_at = NOW();

-- =====================================================================================
-- STATE 12: IDAHO (ID)
-- =====================================================================================
-- Liability Model: STRICT LIABILITY (Idaho Code § 25-2810, enacted 2016)
-- SOL: 2 years (Idaho Code § 5-219)
-- =====================================================================================

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'ID-PI-PRIMARY-SOL',
    5,
    'ID Personal Injury Primary SOL Authority',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'ID',
    '{
        "sol_years": 2,
        "sol_days": 730,
        "statute": "Idaho Code § 5-219(4)",
        "effective_date": "2016-07-01",
        "discovery_rule": false,
        "authority_level": "primary_state_sol",
        "sol_version": "1.0.0",
        "valid_from": "2016-07-01",
        "valid_to": null
    }'::jsonb,
    'error',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
) ON CONFLICT ON CONSTRAINT unique_active_state_sol DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    validator_level = EXCLUDED.validator_level,
    validator_name = EXCLUDED.validator_name,
    validator_type = EXCLUDED.validator_type,
    severity = EXCLUDED.severity,
    review_status = EXCLUDED.review_status,
    is_active = EXCLUDED.is_active,
    updated_at = NOW();

-- =====================================================================================
-- STATE 13: ILLINOIS (IL)
-- =====================================================================================
-- Liability Model: STRICT LIABILITY (510 ILCS 5/16)
-- SOL: 2 years (735 ILCS 5/13-202)
-- =====================================================================================

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'IL-PI-PRIMARY-SOL',
    5,
    'IL Personal Injury Primary SOL Authority',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'IL',
    '{
        "sol_years": 2,
        "sol_days": 730,
        "statute": "735 ILCS 5/13-202",
        "effective_date": "1970-01-01",
        "discovery_rule": false,
        "note": "Minors have extended SOL: until age 20 (2 years after reaching majority at 18)",
        "authority_level": "primary_state_sol",
        "sol_version": "1.0.0",
        "valid_from": "1970-01-01",
        "valid_to": null
    }'::jsonb,
    'error',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
) ON CONFLICT ON CONSTRAINT unique_active_state_sol DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    validator_level = EXCLUDED.validator_level,
    validator_name = EXCLUDED.validator_name,
    validator_type = EXCLUDED.validator_type,
    severity = EXCLUDED.severity,
    review_status = EXCLUDED.review_status,
    is_active = EXCLUDED.is_active,
    updated_at = NOW();

-- =====================================================================================
-- STATE 14: INDIANA (IN)
-- =====================================================================================
-- Liability Model: HYBRID (Strict for officials/invited guests; One-bite for public)
-- SOL: 2 years (IC 34-11-2-4)
-- =====================================================================================

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'IN-PI-PRIMARY-SOL',
    5,
    'IN Personal Injury Primary SOL Authority',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'IN',
    '{
        "sol_years": 2,
        "sol_days": 730,
        "statute": "IC 34-11-2-4",
        "effective_date": "1998-07-01",
        "discovery_rule": false,
        "authority_level": "primary_state_sol",
        "sol_version": "1.0.0",
        "valid_from": "1998-07-01",
        "valid_to": null
    }'::jsonb,
    'error',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
) ON CONFLICT ON CONSTRAINT unique_active_state_sol DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    validator_level = EXCLUDED.validator_level,
    validator_name = EXCLUDED.validator_name,
    validator_type = EXCLUDED.validator_type,
    severity = EXCLUDED.severity,
    review_status = EXCLUDED.review_status,
    is_active = EXCLUDED.is_active,
    updated_at = NOW();

-- =====================================================================================
-- STATE 15: IOWA (IA)
-- =====================================================================================
-- Liability Model: STRICT LIABILITY (Iowa Code § 351.28 - absolute strict liability)
-- SOL: 2 years (Iowa Code § 614.1)
-- =====================================================================================

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'IA-PI-PRIMARY-SOL',
    5,
    'IA Personal Injury Primary SOL Authority',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'IA',
    '{
        "sol_years": 2,
        "sol_days": 730,
        "statute": "Iowa Code § 614.1(2)",
        "effective_date": "1851-01-01",
        "discovery_rule": false,
        "authority_level": "primary_state_sol",
        "sol_version": "1.0.0",
        "valid_from": "1851-01-01",
        "valid_to": null
    }'::jsonb,
    'error',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
) ON CONFLICT ON CONSTRAINT unique_active_state_sol DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    validator_level = EXCLUDED.validator_level,
    validator_name = EXCLUDED.validator_name,
    validator_type = EXCLUDED.validator_type,
    severity = EXCLUDED.severity,
    review_status = EXCLUDED.review_status,
    is_active = EXCLUDED.is_active,
    updated_at = NOW();

-- =====================================================================================
-- STATE 16: KANSAS (KS)
-- =====================================================================================
-- Liability Model: ONE-BITE RULE (Common law scienter since 1897)
-- SOL: 2 years (K.S.A. 60-513)
-- =====================================================================================

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'KS-PI-PRIMARY-SOL',
    5,
    'KS Personal Injury Primary SOL Authority',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'KS',
    '{
        "sol_years": 2,
        "sol_days": 730,
        "statute": "K.S.A. 60-513(a)(4)",
        "effective_date": "1970-01-01",
        "discovery_rule": true,
        "authority_level": "primary_state_sol",
        "sol_version": "1.0.0",
        "valid_from": "1970-01-01",
        "valid_to": null
    }'::jsonb,
    'error',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
) ON CONFLICT ON CONSTRAINT unique_active_state_sol DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    validator_level = EXCLUDED.validator_level,
    validator_name = EXCLUDED.validator_name,
    validator_type = EXCLUDED.validator_type,
    severity = EXCLUDED.severity,
    review_status = EXCLUDED.review_status,
    is_active = EXCLUDED.is_active,
    updated_at = NOW();

-- =====================================================================================
-- STATE 17: KENTUCKY (KY)
-- =====================================================================================
-- Liability Model: STRICT LIABILITY (KRS 258.235)
-- SOL: 1 year (KRS 413.140) - SHORTEST IN NATION
-- =====================================================================================

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'KY-PI-PRIMARY-SOL',
    5,
    'KY Personal Injury Primary SOL Authority',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'KY',
    '{
        "sol_years": 1,
        "sol_days": 365,
        "statute": "KRS 413.140(1)(a)",
        "effective_date": "1893-01-01",
        "discovery_rule": true,
        "note": "SHORTEST SOL IN NATION (tied with TN and LA pre-2024)",
        "authority_level": "primary_state_sol",
        "sol_version": "1.0.0",
        "valid_from": "1893-01-01",
        "valid_to": null
    }'::jsonb,
    'error',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
) ON CONFLICT ON CONSTRAINT unique_active_state_sol DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    validator_level = EXCLUDED.validator_level,
    validator_name = EXCLUDED.validator_name,
    validator_type = EXCLUDED.validator_type,
    severity = EXCLUDED.severity,
    review_status = EXCLUDED.review_status,
    is_active = EXCLUDED.is_active,
    updated_at = NOW();

-- =====================================================================================
-- STATE 18: LOUISIANA (LA)
-- =====================================================================================
-- Liability Model: STRICT LIABILITY (La. Civ. Code Art. 2321)
-- SOL: 2 years (La. Civ. Code Art. 3493.1) - Changed from 1 year on July 1, 2024
-- =====================================================================================

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'LA-PI-PRIMARY-SOL',
    5,
    'LA Personal Injury Primary SOL Authority',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'LA',
    '{
        "sol_years": 2,
        "sol_days": 730,
        "statute": "La. Civ. Code Art. 3493.1",
        "effective_date": "2024-07-01",
        "discovery_rule": false,
        "note": "Changed from 1 year to 2 years effective July 1, 2024 (Act No. 423)",
        "authority_level": "primary_state_sol",
        "sol_version": "2.0.0",
        "valid_from": "2024-07-01",
        "valid_to": null
    }'::jsonb,
    'error',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
) ON CONFLICT ON CONSTRAINT unique_active_state_sol DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    validator_level = EXCLUDED.validator_level,
    validator_name = EXCLUDED.validator_name,
    validator_type = EXCLUDED.validator_type,
    severity = EXCLUDED.severity,
    review_status = EXCLUDED.review_status,
    is_active = EXCLUDED.is_active,
    updated_at = NOW();

-- =====================================================================================
-- STATE 19: MAINE (ME)
-- =====================================================================================
-- Liability Model: HYBRID (Strict off-premises / Negligence on-premises)
-- SOL: 6 years (14 M.R.S. § 752) - LONGEST IN NATION
-- =====================================================================================

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'ME-PI-PRIMARY-SOL',
    5,
    'ME Personal Injury Primary SOL Authority',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'ME',
    '{
        "sol_years": 6,
        "sol_days": 2190,
        "statute": "14 M.R.S. § 752",
        "effective_date": "1821-01-01",
        "discovery_rule": true,
        "note": "LONGEST SOL IN NATION (tied with MN and ND at 6 years)",
        "authority_level": "primary_state_sol",
        "sol_version": "1.0.0",
        "valid_from": "1821-01-01",
        "valid_to": null
    }'::jsonb,
    'error',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
) ON CONFLICT ON CONSTRAINT unique_active_state_sol DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    validator_level = EXCLUDED.validator_level,
    validator_name = EXCLUDED.validator_name,
    validator_type = EXCLUDED.validator_type,
    severity = EXCLUDED.severity,
    review_status = EXCLUDED.review_status,
    is_active = EXCLUDED.is_active,
    updated_at = NOW();

-- =====================================================================================
-- STATE 20: MARYLAND (MD)
-- =====================================================================================
-- Liability Model: MODIFIED ONE-BITE RULE (2014 Statute with rebuttable presumption for pit bulls)
-- SOL: 3 years (Md. Code Cts. & Jud. Proc. § 5-101)
-- =====================================================================================

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'MD-PI-PRIMARY-SOL',
    5,
    'MD Personal Injury Primary SOL Authority',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'MD',
    '{
        "sol_years": 3,
        "sol_days": 1095,
        "statute": "Md. Code Cts. & Jud. Proc. § 5-101",
        "effective_date": "1973-01-01",
        "discovery_rule": true,
        "authority_level": "primary_state_sol",
        "sol_version": "1.0.0",
        "valid_from": "1973-01-01",
        "valid_to": null
    }'::jsonb,
    'error',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
) ON CONFLICT ON CONSTRAINT unique_active_state_sol DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    validator_level = EXCLUDED.validator_level,
    validator_name = EXCLUDED.validator_name,
    validator_type = EXCLUDED.validator_type,
    severity = EXCLUDED.severity,
    review_status = EXCLUDED.review_status,
    is_active = EXCLUDED.is_active,
    updated_at = NOW();

-- =====================================================================================
-- STATE 21: MASSACHUSETTS (MA)
-- =====================================================================================
-- Liability Model: STRICT LIABILITY (M.G.L. c. 140, § 155)
-- SOL: 3 years (M.G.L. c. 260, § 2A)
-- =====================================================================================

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'MA-PI-PRIMARY-SOL',
    5,
    'MA Personal Injury Primary SOL Authority',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'MA',
    '{
        "sol_years": 3,
        "sol_days": 1095,
        "statute": "M.G.L. c. 260, § 2A",
        "effective_date": "1978-01-01",
        "discovery_rule": true,
        "authority_level": "primary_state_sol",
        "sol_version": "1.0.0",
        "valid_from": "1978-01-01",
        "valid_to": null
    }'::jsonb,
    'error',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
) ON CONFLICT ON CONSTRAINT unique_active_state_sol DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    validator_level = EXCLUDED.validator_level,
    validator_name = EXCLUDED.validator_name,
    validator_type = EXCLUDED.validator_type,
    severity = EXCLUDED.severity,
    review_status = EXCLUDED.review_status,
    is_active = EXCLUDED.is_active,
    updated_at = NOW();

-- =====================================================================================
-- STATE 22: MICHIGAN (MI)
-- =====================================================================================
-- Liability Model: STRICT LIABILITY (MCL 287.351)
-- SOL: 3 years (MCL 600.5805)
-- =====================================================================================

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'MI-PI-PRIMARY-SOL',
    5,
    'MI Personal Injury Primary SOL Authority',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'MI',
    '{
        "sol_years": 3,
        "sol_days": 1095,
        "statute": "MCL 600.5805(10)",
        "effective_date": "1961-01-01",
        "discovery_rule": false,
        "authority_level": "primary_state_sol",
        "sol_version": "1.0.0",
        "valid_from": "1961-01-01",
        "valid_to": null
    }'::jsonb,
    'error',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
) ON CONFLICT ON CONSTRAINT unique_active_state_sol DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    validator_level = EXCLUDED.validator_level,
    validator_name = EXCLUDED.validator_name,
    validator_type = EXCLUDED.validator_type,
    severity = EXCLUDED.severity,
    review_status = EXCLUDED.review_status,
    is_active = EXCLUDED.is_active,
    updated_at = NOW();

-- =====================================================================================
-- STATE 23: MINNESOTA (MN)
-- =====================================================================================
-- Liability Model: STRICT LIABILITY (Minn. Stat. § 347.22)
-- SOL: 6 years (Minn. Stat. § 541.05) - LONGEST IN NATION
-- =====================================================================================

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'MN-PI-PRIMARY-SOL',
    5,
    'MN Personal Injury Primary SOL Authority',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'MN',
    '{
        "sol_years": 6,
        "sol_days": 2190,
        "statute": "Minn. Stat. § 541.05, Subd. 1(5)",
        "effective_date": "1957-01-01",
        "discovery_rule": true,
        "note": "LONGEST SOL IN NATION (tied with ME and ND at 6 years)",
        "authority_level": "primary_state_sol",
        "sol_version": "1.0.0",
        "valid_from": "1957-01-01",
        "valid_to": null
    }'::jsonb,
    'error',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
) ON CONFLICT ON CONSTRAINT unique_active_state_sol DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    validator_level = EXCLUDED.validator_level,
    validator_name = EXCLUDED.validator_name,
    validator_type = EXCLUDED.validator_type,
    severity = EXCLUDED.severity,
    review_status = EXCLUDED.review_status,
    is_active = EXCLUDED.is_active,
    updated_at = NOW();

-- =====================================================================================
-- STATE 24: MISSISSIPPI (MS)
-- =====================================================================================
-- Liability Model: ONE-BITE RULE (Common law scienter)
-- SOL: 3 years (Miss. Code Ann. § 15-1-49)
-- =====================================================================================

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'MS-PI-PRIMARY-SOL',
    5,
    'MS Personal Injury Primary SOL Authority',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'MS',
    '{
        "sol_years": 3,
        "sol_days": 1095,
        "statute": "Miss. Code Ann. § 15-1-49",
        "effective_date": "1892-01-01",
        "discovery_rule": true,
        "authority_level": "primary_state_sol",
        "sol_version": "1.0.0",
        "valid_from": "1892-01-01",
        "valid_to": null
    }'::jsonb,
    'error',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
) ON CONFLICT ON CONSTRAINT unique_active_state_sol DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    validator_level = EXCLUDED.validator_level,
    validator_name = EXCLUDED.validator_name,
    validator_type = EXCLUDED.validator_type,
    severity = EXCLUDED.severity,
    review_status = EXCLUDED.review_status,
    is_active = EXCLUDED.is_active,
    updated_at = NOW();

-- =====================================================================================
-- STATE 25: MISSOURI (MO)
-- =====================================================================================
-- Liability Model: STRICT LIABILITY (RSMo 273.036)
-- SOL: 5 years (RSMo 516.120) - ONE OF LONGEST IN NATION
-- Note: HB1645 proposes 2-year SOL effective Aug 28, 2026 (pending)
-- =====================================================================================

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'MO-PI-PRIMARY-SOL',
    5,
    'MO Personal Injury Primary SOL Authority',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'MO',
    '{
        "sol_years": 5,
        "sol_days": 1825,
        "statute": "RSMo 516.120(4)",
        "effective_date": "1939-01-01",
        "discovery_rule": false,
        "note": "5-year SOL is one of longest in nation; HB1645 proposes 2-year effective Aug 28, 2026 (pending)",
        "authority_level": "primary_state_sol",
        "sol_version": "1.0.0",
        "valid_from": "1939-01-01",
        "valid_to": null
    }'::jsonb,
    'error',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
) ON CONFLICT ON CONSTRAINT unique_active_state_sol DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    validator_level = EXCLUDED.validator_level,
    validator_name = EXCLUDED.validator_name,
    validator_type = EXCLUDED.validator_type,
    severity = EXCLUDED.severity,
    review_status = EXCLUDED.review_status,
    is_active = EXCLUDED.is_active,
    updated_at = NOW();

-- =====================================================================================
-- STATE 26: MONTANA (MT)
-- =====================================================================================
-- Liability Model: HYBRID (Strict in cities/towns; One-bite outside)
-- SOL: 3 years (MCA 27-2-204)
-- =====================================================================================

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'MT-PI-PRIMARY-SOL',
    5,
    'MT Personal Injury Primary SOL Authority',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'MT',
    '{
        "sol_years": 3,
        "sol_days": 1095,
        "statute": "MCA 27-2-204(1)",
        "effective_date": "1947-01-01",
        "discovery_rule": true,
        "authority_level": "primary_state_sol",
        "sol_version": "1.0.0",
        "valid_from": "1947-01-01",
        "valid_to": null
    }'::jsonb,
    'error',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
) ON CONFLICT ON CONSTRAINT unique_active_state_sol DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    validator_level = EXCLUDED.validator_level,
    validator_name = EXCLUDED.validator_name,
    validator_type = EXCLUDED.validator_type,
    severity = EXCLUDED.severity,
    review_status = EXCLUDED.review_status,
    is_active = EXCLUDED.is_active,
    updated_at = NOW();

-- =====================================================================================
-- VERIFICATION QUERY
-- =====================================================================================
-- Verify all 26 primary SOL authority rows have been created with proper version fields
-- =====================================================================================

DO $$
DECLARE
    primary_count INTEGER;
    missing_version INTEGER;
BEGIN
    -- Count total primary_state_sol rows
    SELECT COUNT(*) INTO primary_count
    FROM leverage.validation_rules
    WHERE validator_config->>'authority_level' = 'primary_state_sol'
    AND jurisdiction_state IN ('AL','AK','AZ','AR','CA','CO','CT','DE','FL','GA',
                               'HI','ID','IL','IN','IA','KS','KY','LA','ME','MD',
                               'MA','MI','MN','MS','MO','MT');
    
    -- Count rows missing version fields
    SELECT COUNT(*) INTO missing_version
    FROM leverage.validation_rules
    WHERE validator_config->>'authority_level' = 'primary_state_sol'
    AND jurisdiction_state IN ('AL','AK','AZ','AR','CA','CO','CT','DE','FL','GA',
                               'HI','ID','IL','IN','IA','KS','KY','LA','ME','MD',
                               'MA','MI','MN','MS','MO','MT')
    AND (
        validator_config->>'sol_version' IS NULL
        OR validator_config->>'valid_from' IS NULL
    );
    
    IF primary_count < 26 THEN
        RAISE WARNING '⚠️  Only % of 26 primary SOL rows created. Check for errors.', primary_count;
    ELSE
        RAISE NOTICE '✅ All 26 primary SOL authority rows created successfully.';
    END IF;
    
    IF missing_version > 0 THEN
        RAISE WARNING '⚠️  % primary SOL rows missing version fields (sol_version or valid_from).', missing_version;
    ELSE
        RAISE NOTICE '✅ All primary SOL rows have proper version fields.';
    END IF;
END $$;

-- Display created primary authorities with version info
SELECT 
    jurisdiction_state AS state,
    validator_config->>'sol_years' AS sol_years,
    validator_config->>'statute' AS statute,
    validator_config->>'sol_version' AS version,
    validator_config->>'valid_from' AS valid_from,
    validator_config->>'valid_to' AS valid_to,
    is_active
FROM leverage.validation_rules
WHERE validator_config->>'authority_level' = 'primary_state_sol'
AND jurisdiction_state IN ('AL','AK','AZ','AR','CA','CO','CT','DE','FL','GA',
                           'HI','ID','IL','IN','IA','KS','KY','LA','ME','MD',
                           'MA','MI','MN','MS','MO','MT')
ORDER BY jurisdiction_state;

-- =====================================================================================
-- END OF PRIMARY SOL AUTHORITY SEED FILE: STATES 1-26
-- =====================================================================================
