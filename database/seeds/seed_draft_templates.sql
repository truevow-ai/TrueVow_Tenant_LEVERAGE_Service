-- ==========================================
-- DRAFT Template Seeding Script
-- Seeds state-specific templates during tenant onboarding
-- ==========================================

-- Main seeding function
CREATE OR REPLACE FUNCTION seed_draft_templates_for_tenant(
    p_tenant_state TEXT, -- 'arizona', 'california', 'texas', etc.
    p_tenant_practice_areas TEXT[] DEFAULT ARRAY['personal_injury'], -- Practice areas
    p_created_by UUID DEFAULT NULL -- User ID for audit
)
RETURNS TABLE (
    templates_seeded INTEGER,
    state_templates INTEGER,
    federal_templates INTEGER,
    total_rules INTEGER
) AS $$
DECLARE
    templates_count INTEGER := 0;
    state_count INTEGER := 0;
    federal_count INTEGER := 0;
    rules_count INTEGER := 0;
    template_record RECORD;
BEGIN
    -- Validate state
    IF p_tenant_state IS NULL THEN
        RAISE EXCEPTION 'Tenant state cannot be NULL';
    END IF;
    
    -- Convert state to lowercase
    p_tenant_state := LOWER(p_tenant_state);
    
    RAISE NOTICE 'Seeding DRAFT templates for state: %', p_tenant_state;
    
    -- ==============================================
    -- SEED STATE-SPECIFIC TEMPLATES
    -- ==============================================
    
    CASE p_tenant_state
        
        -- ========================================
        -- ARIZONA TEMPLATES
        -- ========================================
        WHEN 'arizona' THEN
            RAISE NOTICE '  → Loading Arizona templates...';
            
            -- Arizona Demand Letter (Personal Injury)
            INSERT INTO leverage.template_library (
                template_name,
                template_description,
                template_category,
                state,
                jurisdiction_type,
                template_source,
                template_version,
                rules,
                created_by
            ) VALUES (
                'Arizona Demand Letter (Personal Injury)',
                'Arizona Bar-compliant demand letter format for personal injury cases. Includes Arizona-specific requirements for statute of limitations (A.R.S. § 12-542), demand amounts, and medical documentation.',
                'demand_letter',
                'arizona',
                'state',
                'truevow',
                '1.0',
                '[
                    {
                        "rule_name": "Arizona Statute of Limitations Section Required",
                        "rule_description": "Arizona demand letters must include a Statute of Limitations section citing A.R.S. § 12-542 (2-year limit for personal injury)",
                        "rule_type": "content_check",
                        "rule_config": {
                            "check_type": "section_exists",
                            "section_name": "Statute of Limitations",
                            "required": true,
                            "keywords": ["A.R.S. § 12-542", "statute of limitations", "two years", "2 years"],
                            "error_message": "Arizona demand letters must include Statute of Limitations section citing A.R.S. § 12-542"
                        },
                        "severity": "error"
                    },
                    {
                        "rule_name": "Total Demand Amount Required",
                        "rule_description": "Demand letter must state a specific total dollar amount being demanded",
                        "rule_type": "required_field",
                        "rule_config": {
                            "field_name": "Total Demand Amount",
                            "pattern": "\\$[0-9,]+(\\.[0-9]{2})?",
                            "required": true,
                            "error_message": "Demand letter must state a specific dollar amount (e.g., $100,000.00)"
                        },
                        "severity": "error"
                    },
                    {
                        "rule_name": "Client Full Name Required",
                        "rule_description": "Demand letter must include client''s full legal name",
                        "rule_type": "required_field",
                        "rule_config": {
                            "field_name": "Client Name",
                            "pattern": "[A-Z][a-z]+ [A-Z][a-z]+",
                            "required": true,
                            "error_message": "Demand letter must include client''s full name"
                        },
                        "severity": "error"
                    },
                    {
                        "rule_name": "Date of Incident Required",
                        "rule_description": "Demand letter must include the date of the incident",
                        "rule_type": "required_field",
                        "rule_config": {
                            "field_name": "Date of Incident",
                            "pattern": "(0?[1-9]|1[0-2])/(0?[1-9]|[12][0-9]|3[01])/\\d{4}",
                            "required": true,
                            "error_message": "Demand letter must include date of incident (MM/DD/YYYY format)"
                        },
                        "severity": "error"
                    },
                    {
                        "rule_name": "Medical Expenses Itemization",
                        "rule_description": "Arizona best practice: itemize medical expenses in demand letters",
                        "rule_type": "content_check",
                        "rule_config": {
                            "check_type": "section_exists",
                            "section_name": "Medical Expenses",
                            "required": true,
                            "keywords": ["medical expenses", "medical bills", "treatment costs"],
                            "error_message": "Arizona demand letters should itemize medical expenses"
                        },
                        "severity": "warning"
                    },
                    {
                        "rule_name": "Attorney Letterhead Check",
                        "rule_description": "Professional letterhead required per Arizona Bar Rule 7.1",
                        "rule_type": "format_check",
                        "rule_config": {
                            "check_type": "header_exists",
                            "required": true,
                            "error_message": "Professional letterhead required (Arizona Bar Rule 7.1)"
                        },
                        "severity": "warning"
                    }
                ]'::JSONB,
                p_created_by
            );
            state_count := state_count + 1;
            rules_count := rules_count + 6;
            
            -- Arizona Complaint (Superior Court)
            INSERT INTO leverage.template_library (
                template_name,
                template_description,
                template_category,
                state,
                jurisdiction_type,
                template_source,
                template_version,
                rules,
                created_by
            ) VALUES (
                'Arizona Complaint (Superior Court)',
                'Arizona Superior Court complaint format for civil cases, following Arizona Rules of Civil Procedure',
                'complaint',
                'arizona',
                'state',
                'truevow',
                '1.0',
                '[
                    {
                        "rule_name": "Caption Format (Arizona Superior Court)",
                        "rule_description": "Proper court caption format for Arizona Superior Court",
                        "rule_type": "format_check",
                        "rule_config": {
                            "check_type": "caption_format",
                            "required_elements": ["IN THE SUPERIOR COURT", "STATE OF ARIZONA", "COUNTY"],
                            "error_message": "Caption must include court name, state, and county"
                        },
                        "severity": "error"
                    },
                    {
                        "rule_name": "Jurisdiction and Venue Statement",
                        "rule_description": "Complaint must state jurisdiction and venue basis",
                        "rule_type": "content_check",
                        "rule_config": {
                            "check_type": "section_exists",
                            "section_name": "Jurisdiction and Venue",
                            "required": true,
                            "error_message": "Complaint must include jurisdiction and venue statement (Rule 8, Ariz. R. Civ. P.)"
                        },
                        "severity": "error"
                    },
                    {
                        "rule_name": "Parties Section Required",
                        "rule_description": "Complaint must identify all parties",
                        "rule_type": "content_check",
                        "rule_config": {
                            "check_type": "section_exists",
                            "section_name": "Parties",
                            "required": true,
                            "keywords": ["plaintiff", "defendant"],
                            "error_message": "Complaint must identify all parties (Rule 8, Ariz. R. Civ. P.)"
                        },
                        "severity": "error"
                    },
                    {
                        "rule_name": "Prayer for Relief",
                        "rule_description": "Complaint must include prayer for relief",
                        "rule_type": "content_check",
                        "rule_config": {
                            "check_type": "section_exists",
                            "section_name": "Prayer for Relief",
                            "required": true,
                            "keywords": ["prayer for relief", "wherefore", "demands"],
                            "error_message": "Complaint must include prayer for relief (Rule 8, Ariz. R. Civ. P.)"
                        },
                        "severity": "error"
                    }
                ]'::JSONB,
                p_created_by
            );
            state_count := state_count + 1;
            rules_count := rules_count + 4;
            
            RAISE NOTICE '  ✓ Arizona templates loaded: % templates, % rules', state_count, rules_count - federal_count;
            
        -- ========================================
        -- CALIFORNIA TEMPLATES
        -- ========================================
        WHEN 'california' THEN
            RAISE NOTICE '  → Loading California templates...';
            
            -- California Demand Letter (Personal Injury)
            INSERT INTO leverage.template_library (
                template_name,
                template_description,
                template_category,
                state,
                jurisdiction_type,
                template_source,
                template_version,
                rules,
                created_by
            ) VALUES (
                'California Demand Letter (Personal Injury)',
                'California Bar-compliant demand letter format for personal injury cases. Includes California-specific requirements for statute of limitations (CCP § 335.1), demand amounts, and medical documentation.',
                'demand_letter',
                'california',
                'state',
                'truevow',
                '1.0',
                '[
                    {
                        "rule_name": "California Statute of Limitations Section Required",
                        "rule_description": "California demand letters must reference statute of limitations (CCP § 335.1 - 2-year limit for personal injury)",
                        "rule_type": "content_check",
                        "rule_config": {
                            "check_type": "section_exists",
                            "section_name": "Statute of Limitations",
                            "required": true,
                            "keywords": ["CCP § 335.1", "Code of Civil Procedure", "statute of limitations", "two years"],
                            "error_message": "California demand letters must reference Statute of Limitations (CCP § 335.1)"
                        },
                        "severity": "error"
                    },
                    {
                        "rule_name": "Total Demand Amount Required",
                        "rule_description": "Demand letter must state a specific total dollar amount",
                        "rule_type": "required_field",
                        "rule_config": {
                            "field_name": "Total Demand Amount",
                            "pattern": "\\$[0-9,]+(\\.[0-9]{2})?",
                            "required": true,
                            "error_message": "Demand letter must state a specific dollar amount"
                        },
                        "severity": "error"
                    },
                    {
                        "rule_name": "Medical Specials Breakdown",
                        "rule_description": "California practice: detailed breakdown of medical specials",
                        "rule_type": "content_check",
                        "rule_config": {
                            "check_type": "section_exists",
                            "section_name": "Medical Specials",
                            "required": true,
                            "keywords": ["medical specials", "medical expenses"],
                            "error_message": "California demand letters should include medical specials breakdown"
                        },
                        "severity": "warning"
                    },
                    {
                        "rule_name": "General Damages Discussion",
                        "rule_description": "California practice: separate discussion of general damages",
                        "rule_type": "content_check",
                        "rule_config": {
                            "check_type": "section_exists",
                            "section_name": "General Damages",
                            "required": true,
                            "keywords": ["general damages", "pain and suffering"],
                            "error_message": "California demand letters should discuss general damages separately"
                        },
                        "severity": "warning"
                    }
                ]'::JSONB,
                p_created_by
            );
            state_count := state_count + 1;
            rules_count := rules_count + 4;
            
            RAISE NOTICE '  ✓ California templates loaded: % templates, % rules', state_count, rules_count - federal_count;
            
        -- ========================================
        -- TEXAS TEMPLATES
        -- ========================================
        WHEN 'texas' THEN
            RAISE NOTICE '  → Loading Texas templates...';
            
            -- Texas Demand Letter (Personal Injury)
            INSERT INTO leverage.template_library (
                template_name,
                template_description,
                template_category,
                state,
                jurisdiction_type,
                template_source,
                template_version,
                rules,
                created_by
            ) VALUES (
                'Texas Demand Letter (Personal Injury)',
                'Texas Bar-compliant demand letter format for personal injury cases. Includes Texas-specific requirements for statute of limitations (CPRC § 16.003).',
                'demand_letter',
                'texas',
                'state',
                'truevow',
                '1.0',
                '[
                    {
                        "rule_name": "Texas Statute of Limitations Reference",
                        "rule_description": "Texas demand letters should reference 2-year statute of limitations (CPRC § 16.003)",
                        "rule_type": "content_check",
                        "rule_config": {
                            "check_type": "section_exists",
                            "section_name": "Statute of Limitations",
                            "required": true,
                            "keywords": ["CPRC § 16.003", "Civil Practice and Remedies Code", "statute of limitations"],
                            "error_message": "Texas demand letters should reference statute of limitations (CPRC § 16.003)"
                        },
                        "severity": "error"
                    },
                    {
                        "rule_name": "Total Demand Amount Required",
                        "rule_description": "Demand letter must state specific settlement amount",
                        "rule_type": "required_field",
                        "rule_config": {
                            "field_name": "Settlement Demand",
                            "pattern": "\\$[0-9,]+(\\.[0-9]{2})?",
                            "required": true,
                            "error_message": "Demand letter must state specific settlement amount"
                        },
                        "severity": "error"
                    },
                    {
                        "rule_name": "Medical Treatment Summary",
                        "rule_description": "Texas practice: detailed medical treatment summary",
                        "rule_type": "content_check",
                        "rule_config": {
                            "check_type": "section_exists",
                            "section_name": "Medical Treatment",
                            "required": true,
                            "keywords": ["medical treatment", "medical expenses"],
                            "error_message": "Texas demand letters should include medical treatment summary"
                        },
                        "severity": "warning"
                    }
                ]'::JSONB,
                p_created_by
            );
            state_count := state_count + 1;
            rules_count := rules_count + 3;
            
            RAISE NOTICE '  ✓ Texas templates loaded: % templates, % rules', state_count, rules_count - federal_count;
            
        ELSE
            RAISE NOTICE '  ⚠ No state-specific templates for: % (will seed federal only)', p_tenant_state;
    END CASE;
    
    -- ==============================================
    -- SEED FEDERAL TEMPLATES (ALL STATES)
    -- ==============================================
    RAISE NOTICE '  → Loading Federal templates...';
    
    -- Federal Complaint (Civil Rights - 42 U.S.C. § 1983)
    INSERT INTO leverage.template_library (
        template_name,
        template_description,
        template_category,
        state,
        jurisdiction_type,
        template_source,
        template_version,
        rules,
        created_by
    ) VALUES (
        'Federal Complaint (Civil Rights - 42 U.S.C. § 1983)',
        'Federal court complaint format for civil rights cases under 42 U.S.C. § 1983, following Federal Rules of Civil Procedure',
        'complaint',
        NULL,
        'federal',
        'truevow',
        '1.0',
        '[
            {
                "rule_name": "Federal Court Caption Format",
                "rule_description": "Proper caption format for federal district court",
                "rule_type": "format_check",
                "rule_config": {
                    "check_type": "caption_format",
                    "required_elements": ["UNITED STATES DISTRICT COURT", "DISTRICT OF"],
                    "error_message": "Caption must include ''UNITED STATES DISTRICT COURT'' and district name"
                },
                "severity": "error"
            },
            {
                "rule_name": "Jurisdiction Statement Required",
                "rule_description": "Federal complaint must state basis for federal jurisdiction (FRCP 8(a))",
                "rule_type": "content_check",
                "rule_config": {
                    "check_type": "section_exists",
                    "section_name": "Jurisdiction",
                    "required": true,
                    "keywords": ["jurisdiction", "28 U.S.C. § 1331", "28 U.S.C. § 1343"],
                    "error_message": "Complaint must include jurisdiction statement (FRCP 8(a))"
                },
                "severity": "error"
            },
            {
                "rule_name": "Section 1983 Citation",
                "rule_description": "Civil rights complaint must cite 42 U.S.C. § 1983",
                "rule_type": "content_check",
                "rule_config": {
                    "check_type": "contains_citation",
                    "required_citation": "42 U.S.C. § 1983",
                    "error_message": "Civil rights complaint must cite 42 U.S.C. § 1983"
                },
                "severity": "error"
            },
            {
                "rule_name": "Prayer for Relief Required",
                "rule_description": "Complaint must include prayer for relief (FRCP 8(a))",
                "rule_type": "content_check",
                "rule_config": {
                    "check_type": "section_exists",
                    "section_name": "Prayer for Relief",
                    "required": true,
                    "error_message": "Complaint must include prayer for relief (FRCP 8(a)(3))"
                },
                "severity": "error"
            }
        ]'::JSONB,
        p_created_by
    );
    federal_count := federal_count + 1;
    rules_count := rules_count + 4;
    
    -- Federal Motion to Dismiss (FRCP 12(b)(6))
    INSERT INTO leverage.template_library (
        template_name,
        template_description,
        template_category,
        state,
        jurisdiction_type,
        template_source,
        template_version,
        rules,
        created_by
    ) VALUES (
        'Federal Motion to Dismiss (FRCP 12(b)(6))',
        'Motion to dismiss for failure to state a claim under FRCP 12(b)(6)',
        'motion',
        NULL,
        'federal',
        'truevow',
        '1.0',
        '[
            {
                "rule_name": "Grounds for Dismissal Clearly Stated",
                "rule_description": "Motion must clearly state why complaint fails to state a claim",
                "rule_type": "content_check",
                "rule_config": {
                    "check_type": "section_exists",
                    "section_name": "Argument",
                    "required": true,
                    "keywords": ["fails to state a claim", "plausible"],
                    "error_message": "Motion must clearly articulate why complaint fails to state a claim"
                },
                "severity": "error"
            },
            {
                "rule_name": "Prayer for Relief",
                "rule_description": "Motion must include specific relief requested",
                "rule_type": "content_check",
                "rule_config": {
                    "check_type": "section_exists",
                    "section_name": "Conclusion",
                    "required": true,
                    "keywords": ["wherefore", "respectfully requests", "dismiss"],
                    "error_message": "Motion must include prayer for specific relief"
                },
                "severity": "error"
            }
        ]'::JSONB,
        p_created_by
    );
    federal_count := federal_count + 1;
    rules_count := rules_count + 2;
    
    RAISE NOTICE '  ✓ Federal templates loaded: % templates, % rules', federal_count, rules_count - (rules_count - federal_count * 2);
    
    -- Total templates
    templates_count := state_count + federal_count;
    
    RAISE NOTICE '';
    RAISE NOTICE '✅ DRAFT templates seeded successfully';
    RAISE NOTICE '   - State-specific templates: %', state_count;
    RAISE NOTICE '   - Federal templates: %', federal_count;
    RAISE NOTICE '   - Total templates: %', templates_count;
    RAISE NOTICE '   - Total rules: %', rules_count;
    
    -- Return summary
    RETURN QUERY SELECT templates_count, state_count, federal_count, rules_count;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION seed_draft_templates_for_tenant IS 'Seeds state-specific and federal validation templates for a new tenant';


-- ==========================================
-- USAGE EXAMPLE
-- ==========================================
-- Called during tenant onboarding:
-- SELECT * FROM seed_draft_templates_for_tenant('arizona', ARRAY['personal_injury'], 'user-uuid-here');
-- SELECT * FROM seed_draft_templates_for_tenant('california', ARRAY['personal_injury', 'family_law'], 'user-uuid-here');
-- SELECT * FROM seed_draft_templates_for_tenant('texas', ARRAY['personal_injury'], 'user-uuid-here');

