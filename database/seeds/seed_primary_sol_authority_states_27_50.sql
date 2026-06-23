-- =====================================================================================
-- PRIMARY SOL AUTHORITY SEED FILE: STATES 27-50
-- =====================================================================================
-- Purpose: Create canonical intake authority rows for tenant-app routing
-- States Covered:
--   27: NE, 28: NV, 29: NH, 30: NJ, 31: NM, 32: NY, 33: NC, 34: ND, 35: OH, 36: OK,
--   37: OR, 38: PA, 39: RI, 40: SC, 41: SD, 42: TN, 43: TX, 44: UT, 45: VT, 46: VA,
--   47: WA, 48: WV, 49: WI, 50: WY
--
-- ARCHITECTURE:
--   - PRIMARY SOL AUTHORITY rows (authority_level = "primary_state_sol")
--   - One active version per state+practice (valid_to = null)
--   - Versioned for legal defensibility (sol_version, valid_from, valid_to)
--
-- CONFLICT RESOLUTION:
--   - Uses (jurisdiction_state, practice_area) as conflict target
--   - Updates existing primary_state_sol rows with canonical versioned config
-- =====================================================================================


-- =====================================================================================
-- STATE 27: NEBRASKA (NE)
-- =====================================================================================
-- SOL: 4 years (Neb. Rev. Stat. § 25-207) – personal injury
-- =====================================================================================

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'NE-PI-PRIMARY-SOL',
    5,
    'NE Personal Injury Primary SOL Authority',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'NE',
    '{
        "sol_years": 4,
        "sol_days": 1460,
        "statute": "Neb. Rev. Stat. § 25-207",
        "effective_date": "1873-01-01",
        "discovery_rule": false,
        "authority_level": "primary_state_sol",
        "sol_version": "1.0.0",
        "valid_from": "1873-01-01",
        "valid_to": null
    }'::jsonb,
    'error',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
) ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    validator_level  = EXCLUDED.validator_level,
    validator_name   = EXCLUDED.validator_name,
    validator_type   = EXCLUDED.validator_type,
    severity         = EXCLUDED.severity,
    review_status    = EXCLUDED.review_status,
    is_active        = EXCLUDED.is_active,
    updated_at       = NOW();


-- =====================================================================================
-- STATE 28: NEVADA (NV)
-- =====================================================================================

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'NV-PI-PRIMARY-SOL',
    5,
    'NV Personal Injury Primary SOL Authority',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'NV',
    '{
        "sol_years": 2,
        "sol_days": 730,
        "statute": "NRS 11.190(4)(e)",
        "effective_date": "1953-01-01",
        "discovery_rule": false,
        "authority_level": "primary_state_sol",
        "sol_version": "1.0.0",
        "valid_from": "1953-01-01",
        "valid_to": null
    }'::jsonb,
    'error',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
) ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    validator_level  = EXCLUDED.validator_level,
    validator_name   = EXCLUDED.validator_name,
    validator_type   = EXCLUDED.validator_type,
    severity         = EXCLUDED.severity,
    review_status    = EXCLUDED.review_status,
    is_active        = EXCLUDED.is_active,
    updated_at       = NOW();


-- =====================================================================================
-- STATE 29: NEW HAMPSHIRE (NH)
-- =====================================================================================

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'NH-PI-PRIMARY-SOL',
    5,
    'NH Personal Injury Primary SOL Authority',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'NH',
    '{
        "sol_years": 3,
        "sol_days": 1095,
        "statute": "RSA 508:4",
        "effective_date": "1963-01-01",
        "discovery_rule": true,
        "authority_level": "primary_state_sol",
        "sol_version": "1.0.0",
        "valid_from": "1963-01-01",
        "valid_to": null
    }'::jsonb,
    'error',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
) ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    validator_level  = EXCLUDED.validator_level,
    validator_name   = EXCLUDED.validator_name,
    validator_type   = EXCLUDED.validator_type,
    severity         = EXCLUDED.severity,
    review_status    = EXCLUDED.review_status,
    is_active        = EXCLUDED.is_active,
    updated_at       = NOW();


-- =====================================================================================
-- STATE 30: NEW JERSEY (NJ)
-- =====================================================================================

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'NJ-PI-PRIMARY-SOL',
    5,
    'NJ Personal Injury Primary SOL Authority',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'NJ',
    '{
        "sol_years": 2,
        "sol_days": 730,
        "statute": "N.J. Stat. § 2A:14-2",
        "effective_date": "1951-01-01",
        "discovery_rule": false,
        "authority_level": "primary_state_sol",
        "sol_version": "1.0.0",
        "valid_from": "1951-01-01",
        "valid_to": null
    }'::jsonb,
    'error',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
) ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    validator_level  = EXCLUDED.validator_level,
    validator_name   = EXCLUDED.validator_name,
    validator_type   = EXCLUDED.validator_type,
    severity         = EXCLUDED.severity,
    review_status    = EXCLUDED.review_status,
    is_active        = EXCLUDED.is_active,
    updated_at       = NOW();


-- =====================================================================================
-- STATE 31: NEW MEXICO (NM)
-- =====================================================================================

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'NM-PI-PRIMARY-SOL',
    5,
    'NM Personal Injury Primary SOL Authority',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'NM',
    '{
        "sol_years": 3,
        "sol_days": 1095,
        "statute": "N.M. Stat. § 37-1-8",
        "effective_date": "1880-01-01",
        "discovery_rule": true,
        "authority_level": "primary_state_sol",
        "sol_version": "1.0.0",
        "valid_from": "1880-01-01",
        "valid_to": null
    }'::jsonb,
    'error',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
) ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    validator_level  = EXCLUDED.validator_level,
    validator_name   = EXCLUDED.validator_name,
    validator_type   = EXCLUDED.validator_type,
    severity         = EXCLUDED.severity,
    review_status    = EXCLUDED.review_status,
    is_active        = EXCLUDED.is_active,
    updated_at       = NOW();


-- =====================================================================================
-- STATE 32: NEW YORK (NY)
-- =====================================================================================

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'NY-PI-PRIMARY-SOL',
    5,
    'NY Personal Injury Primary SOL Authority',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'NY',
    '{
        "sol_years": 3,
        "sol_days": 1095,
        "statute": "CPLR 214(5)",
        "effective_date": "1962-09-01",
        "discovery_rule": false,
        "authority_level": "primary_state_sol",
        "sol_version": "1.0.0",
        "valid_from": "1962-09-01",
        "valid_to": null
    }'::jsonb,
    'error',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
) ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    validator_level  = EXCLUDED.validator_level,
    validator_name   = EXCLUDED.validator_name,
    validator_type   = EXCLUDED.validator_type,
    severity         = EXCLUDED.severity,
    review_status    = EXCLUDED.review_status,
    is_active        = EXCLUDED.is_active,
    updated_at       = NOW();


-- =====================================================================================
-- STATE 33: NORTH CAROLINA (NC)
-- =====================================================================================

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'NC-PI-PRIMARY-SOL',
    5,
    'NC Personal Injury Primary SOL Authority',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'NC',
    '{
        "sol_years": 3,
        "sol_days": 1095,
        "statute": "N.C. Gen. Stat. § 1-52(5)",
        "effective_date": "1868-01-01",
        "discovery_rule": false,
        "authority_level": "primary_state_sol",
        "sol_version": "1.0.0",
        "valid_from": "1868-01-01",
        "valid_to": null
    }'::jsonb,
    'error',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
) ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    validator_level  = EXCLUDED.validator_level,
    validator_name   = EXCLUDED.validator_name,
    validator_type   = EXCLUDED.validator_type,
    severity         = EXCLUDED.severity,
    review_status    = EXCLUDED.review_status,
    is_active        = EXCLUDED.is_active,
    updated_at       = NOW();


-- =====================================================================================
-- STATE 34: NORTH DAKOTA (ND)
-- =====================================================================================

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'ND-PI-PRIMARY-SOL',
    5,
    'ND Personal Injury Primary SOL Authority',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'ND',
    '{
        "sol_years": 6,
        "sol_days": 2190,
        "statute": "N.D. Cent. Code § 28-01-16(5)",
        "effective_date": "1895-01-01",
        "discovery_rule": false,
        "authority_level": "primary_state_sol",
        "sol_version": "1.0.0",
        "valid_from": "1895-01-01",
        "valid_to": null
    }'::jsonb,
    'error',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
) ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    validator_level  = EXCLUDED.validator_level,
    validator_name   = EXCLUDED.validator_name,
    validator_type   = EXCLUDED.validator_type,
    severity         = EXCLUDED.severity,
    review_status    = EXCLUDED.review_status,
    is_active        = EXCLUDED.is_active,
    updated_at       = NOW();


-- =====================================================================================
-- STATE 35: OHIO (OH)
-- =====================================================================================

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'OH-PI-PRIMARY-SOL',
    5,
    'OH Personal Injury Primary SOL Authority',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'OH',
    '{
        "sol_years": 2,
        "sol_days": 730,
        "statute": "Ohio Rev. Code § 2305.10(A)",
        "effective_date": "2004-04-09",
        "discovery_rule": false,
        "authority_level": "primary_state_sol",
        "sol_version": "1.0.0",
        "valid_from": "2004-04-09",
        "valid_to": null
    }'::jsonb,
    'error',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
) ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    validator_level  = EXCLUDED.validator_level,
    validator_name   = EXCLUDED.validator_name,
    validator_type   = EXCLUDED.validator_type,
    severity         = EXCLUDED.severity,
    review_status    = EXCLUDED.review_status,
    is_active        = EXCLUDED.is_active,
    updated_at       = NOW();


-- =====================================================================================
-- STATE 36: OKLAHOMA (OK)
-- =====================================================================================

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'OK-PI-PRIMARY-SOL',
    5,
    'OK Personal Injury Primary SOL Authority',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'OK',
    '{
        "sol_years": 2,
        "sol_days": 730,
        "statute": "12 O.S. § 95(A)(3)",
        "effective_date": "1984-11-01",
        "discovery_rule": false,
        "authority_level": "primary_state_sol",
        "sol_version": "1.0.0",
        "valid_from": "1984-11-01",
        "valid_to": null
    }'::jsonb,
    'error',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
) ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    validator_level  = EXCLUDED.validator_level,
    validator_name   = EXCLUDED.validator_name,
    validator_type   = EXCLUDED.validator_type,
    severity         = EXCLUDED.severity,
    review_status    = EXCLUDED.review_status,
    is_active        = EXCLUDED.is_active,
    updated_at       = NOW();


-- =====================================================================================
-- STATE 37: OREGON (OR)
-- =====================================================================================

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'OR-PI-PRIMARY-SOL',
    5,
    'OR Personal Injury Primary SOL Authority',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'OR',
    '{
        "sol_years": 2,
        "sol_days": 730,
        "statute": "ORS 12.110(1)",
        "effective_date": "1961-01-01",
        "discovery_rule": true,
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
) ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    validator_level  = EXCLUDED.validator_level,
    validator_name   = EXCLUDED.validator_name,
    validator_type   = EXCLUDED.validator_type,
    severity         = EXCLUDED.severity,
    review_status    = EXCLUDED.review_status,
    is_active        = EXCLUDED.is_active,
    updated_at       = NOW();


-- =====================================================================================
-- STATE 38: PENNSYLVANIA (PA)
-- =====================================================================================

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'PA-PI-PRIMARY-SOL',
    5,
    'PA Personal Injury Primary SOL Authority',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'PA',
    '{
        "sol_years": 2,
        "sol_days": 730,
        "statute": "42 Pa. C.S. § 5524(2)",
        "effective_date": "1978-06-27",
        "discovery_rule": false,
        "authority_level": "primary_state_sol",
        "sol_version": "1.0.0",
        "valid_from": "1978-06-27",
        "valid_to": null
    }'::jsonb,
    'error',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
) ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    validator_level  = EXCLUDED.validator_level,
    validator_name   = EXCLUDED.validator_name,
    validator_type   = EXCLUDED.validator_type,
    severity         = EXCLUDED.severity,
    review_status    = EXCLUDED.review_status,
    is_active        = EXCLUDED.is_active,
    updated_at       = NOW();


-- =====================================================================================
-- STATE 39: RHODE ISLAND (RI)
-- =====================================================================================

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'RI-PI-PRIMARY-SOL',
    5,
    'RI Personal Injury Primary SOL Authority',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'RI',
    '{
        "sol_years": 3,
        "sol_days": 1095,
        "statute": "R.I. Gen. Laws § 9-1-14(b)",
        "effective_date": "1971-01-01",
        "discovery_rule": true,
        "authority_level": "primary_state_sol",
        "sol_version": "1.0.0",
        "valid_from": "1971-01-01",
        "valid_to": null
    }'::jsonb,
    'error',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
) ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    validator_level  = EXCLUDED.validator_level,
    validator_name   = EXCLUDED.validator_name,
    validator_type   = EXCLUDED.validator_type,
    severity         = EXCLUDED.severity,
    review_status    = EXCLUDED.review_status,
    is_active        = EXCLUDED.is_active,
    updated_at       = NOW();


-- =====================================================================================
-- STATE 40: SOUTH CAROLINA (SC)
-- =====================================================================================

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'SC-PI-PRIMARY-SOL',
    5,
    'SC Personal Injury Primary SOL Authority',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'SC',
    '{
        "sol_years": 3,
        "sol_days": 1095,
        "statute": "S.C. Code § 15-3-530(5)",
        "effective_date": "1988-01-01",
        "discovery_rule": true,
        "authority_level": "primary_state_sol",
        "sol_version": "1.0.0",
        "valid_from": "1988-01-01",
        "valid_to": null
    }'::jsonb,
    'error',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
) ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    validator_level  = EXCLUDED.validator_level,
    validator_name   = EXCLUDED.validator_name,
    validator_type   = EXCLUDED.validator_type,
    severity         = EXCLUDED.severity,
    review_status    = EXCLUDED.review_status,
    is_active        = EXCLUDED.is_active,
    updated_at       = NOW();


-- =====================================================================================
-- STATE 41: SOUTH DAKOTA (SD)
-- =====================================================================================

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'SD-PI-PRIMARY-SOL',
    5,
    'SD Personal Injury Primary SOL Authority',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'SD',
    '{
        "sol_years": 3,
        "sol_days": 1095,
        "statute": "S.D. Codified Laws § 15-2-14(3)",
        "effective_date": "1966-01-01",
        "discovery_rule": false,
        "authority_level": "primary_state_sol",
        "sol_version": "1.0.0",
        "valid_from": "1966-01-01",
        "valid_to": null
    }'::jsonb,
    'error',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
) ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    validator_level  = EXCLUDED.validator_level,
    validator_name   = EXCLUDED.validator_name,
    validator_type   = EXCLUDED.validator_type,
    severity         = EXCLUDED.severity,
    review_status    = EXCLUDED.review_status,
    is_active        = EXCLUDED.is_active,
    updated_at       = NOW();


-- =====================================================================================
-- STATE 42: TENNESSEE (TN)
-- =====================================================================================

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'TN-PI-PRIMARY-SOL',
    5,
    'TN Personal Injury Primary SOL Authority',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'TN',
    '{
        "sol_years": 1,
        "sol_days": 365,
        "statute": "Tenn. Code Ann. § 28-3-104(a)(1)",
        "effective_date": "1972-01-01",
        "discovery_rule": false,
        "note": "ONE OF THE SHORTEST SOLs IN NATION",
        "authority_level": "primary_state_sol",
        "sol_version": "1.0.0",
        "valid_from": "1972-01-01",
        "valid_to": null
    }'::jsonb,
    'error',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
) ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    validator_level  = EXCLUDED.validator_level,
    validator_name   = EXCLUDED.validator_name,
    validator_type   = EXCLUDED.validator_type,
    severity         = EXCLUDED.severity,
    review_status    = EXCLUDED.review_status,
    is_active        = EXCLUDED.is_active,
    updated_at       = NOW();


-- =====================================================================================
-- STATE 43: TEXAS (TX)
-- =====================================================================================

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'TX-PI-PRIMARY-SOL',
    5,
    'TX Personal Injury Primary SOL Authority',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'TX',
    '{
        "sol_years": 2,
        "sol_days": 730,
        "statute": "Tex. Civ. Prac. & Rem. Code § 16.003(a)",
        "effective_date": "1985-09-01",
        "discovery_rule": false,
        "authority_level": "primary_state_sol",
        "sol_version": "1.0.0",
        "valid_from": "1985-09-01",
        "valid_to": null
    }'::jsonb,
    'error',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
) ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    validator_level  = EXCLUDED.validator_level,
    validator_name   = EXCLUDED.validator_name,
    validator_type   = EXCLUDED.validator_type,
    severity         = EXCLUDED.severity,
    review_status    = EXCLUDED.review_status,
    is_active        = EXCLUDED.is_active,
    updated_at       = NOW();


-- =====================================================================================
-- STATE 44: UTAH (UT)
-- =====================================================================================

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'UT-PI-PRIMARY-SOL',
    5,
    'UT Personal Injury Primary SOL Authority',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'UT',
    '{
        "sol_years": 4,
        "sol_days": 1460,
        "statute": "Utah Code Ann. § 78B-2-307(3)",
        "effective_date": "2008-02-07",
        "discovery_rule": false,
        "authority_level": "primary_state_sol",
        "sol_version": "1.0.0",
        "valid_from": "2008-02-07",
        "valid_to": null
    }'::jsonb,
    'error',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
) ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    validator_level  = EXCLUDED.validator_level,
    validator_name   = EXCLUDED.validator_name,
    validator_type   = EXCLUDED.validator_type,
    severity         = EXCLUDED.severity,
    review_status    = EXCLUDED.review_status,
    is_active        = EXCLUDED.is_active,
    updated_at       = NOW();


-- =====================================================================================
-- STATE 45: VERMONT (VT)
-- =====================================================================================

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'VT-PI-PRIMARY-SOL',
    5,
    'VT Personal Injury Primary SOL Authority',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'VT',
    '{
        "sol_years": 3,
        "sol_days": 1095,
        "statute": "12 V.S.A. § 512(4)",
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
) ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    validator_level  = EXCLUDED.validator_level,
    validator_name   = EXCLUDED.validator_name,
    validator_type   = EXCLUDED.validator_type,
    severity         = EXCLUDED.severity,
    review_status    = EXCLUDED.review_status,
    is_active        = EXCLUDED.is_active,
    updated_at       = NOW();


-- =====================================================================================
-- STATE 46: VIRGINIA (VA)
-- =====================================================================================

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'VA-PI-PRIMARY-SOL',
    5,
    'VA Personal Injury Primary SOL Authority',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'VA',
    '{
        "sol_years": 2,
        "sol_days": 730,
        "statute": "Va. Code § 8.01-243(A)",
        "effective_date": "1977-10-01",
        "discovery_rule": false,
        "authority_level": "primary_state_sol",
        "sol_version": "1.0.0",
        "valid_from": "1977-10-01",
        "valid_to": null
    }'::jsonb,
    'error',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
) ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    validator_level  = EXCLUDED.validator_level,
    validator_name   = EXCLUDED.validator_name,
    validator_type   = EXCLUDED.validator_type,
    severity         = EXCLUDED.severity,
    review_status    = EXCLUDED.review_status,
    is_active        = EXCLUDED.is_active,
    updated_at       = NOW();


-- =====================================================================================
-- STATE 47: WASHINGTON (WA)
-- =====================================================================================

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'WA-PI-PRIMARY-SOL',
    5,
    'WA Personal Injury Primary SOL Authority',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'WA',
    '{
        "sol_years": 3,
        "sol_days": 1095,
        "statute": "RCW 4.16.080(2)",
        "effective_date": "1959-03-23",
        "discovery_rule": false,
        "authority_level": "primary_state_sol",
        "sol_version": "1.0.0",
        "valid_from": "1959-03-23",
        "valid_to": null
    }'::jsonb,
    'error',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
) ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    validator_level  = EXCLUDED.validator_level,
    validator_name   = EXCLUDED.validator_name,
    validator_type   = EXCLUDED.validator_type,
    severity         = EXCLUDED.severity,
    review_status    = EXCLUDED.review_status,
    is_active        = EXCLUDED.is_active,
    updated_at       = NOW();


-- =====================================================================================
-- STATE 48: WEST VIRGINIA (WV)
-- =====================================================================================

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'WV-PI-PRIMARY-SOL',
    5,
    'WV Personal Injury Primary SOL Authority',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'WV',
    '{
        "sol_years": 2,
        "sol_days": 730,
        "statute": "W. Va. Code § 55-2-12(b)",
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
) ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    validator_level  = EXCLUDED.validator_level,
    validator_name   = EXCLUDED.validator_name,
    validator_type   = EXCLUDED.validator_type,
    severity         = EXCLUDED.severity,
    review_status    = EXCLUDED.review_status,
    is_active        = EXCLUDED.is_active,
    updated_at       = NOW();


-- =====================================================================================
-- STATE 49: WISCONSIN (WI)
-- =====================================================================================

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'WI-PI-PRIMARY-SOL',
    5,
    'WI Personal Injury Primary SOL Authority',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'WI',
    '{
        "sol_years": 3,
        "sol_days": 1095,
        "statute": "Wis. Stat. § 893.54(1m)(a)",
        "effective_date": "1980-01-01",
        "discovery_rule": false,
        "authority_level": "primary_state_sol",
        "sol_version": "1.0.0",
        "valid_from": "1980-01-01",
        "valid_to": null
    }'::jsonb,
    'error',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
) ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    validator_level  = EXCLUDED.validator_level,
    validator_name   = EXCLUDED.validator_name,
    validator_type   = EXCLUDED.validator_type,
    severity         = EXCLUDED.severity,
    review_status    = EXCLUDED.review_status,
    is_active        = EXCLUDED.is_active,
    updated_at       = NOW();


-- =====================================================================================
-- STATE 50: WYOMING (WY)
-- =====================================================================================

INSERT INTO leverage.validation_rules (
    rule_name, validator_level, validator_name, validator_type,
    practice_area, document_type, jurisdiction_scope, jurisdiction_state,
    validator_config, severity, review_status, is_active, is_template,
    created_at, updated_at
) VALUES (
    'WY-PI-PRIMARY-SOL',
    5,
    'WY Personal Injury Primary SOL Authority',
    'threshold_check',
    'personal_injury',
    'complaint',
    'state',
    'WY',
    '{
        "sol_years": 4,
        "sol_days": 1460,
        "statute": "Wyo. Stat. § 1-3-105(a)(iv)(C)",
        "effective_date": "1977-01-01",
        "discovery_rule": false,
        "authority_level": "primary_state_sol",
        "sol_version": "1.0.0",
        "valid_from": "1977-01-01",
        "valid_to": null
    }'::jsonb,
    'error',
    'document_verified',
    true,
    false,
    NOW(),
    NOW()
) ON CONFLICT (rule_name) DO UPDATE SET
    validator_config = EXCLUDED.validator_config,
    validator_level  = EXCLUDED.validator_level,
    validator_name   = EXCLUDED.validator_name,
    validator_type   = EXCLUDED.validator_type,
    severity         = EXCLUDED.severity,
    review_status    = EXCLUDED.review_status,
    is_active        = EXCLUDED.is_active,
    updated_at       = NOW();


-- =====================================================================================
-- END OF PRIMARY SOL AUTHORITY SEED FILE: STATES 27-50
-- =====================================================================================
