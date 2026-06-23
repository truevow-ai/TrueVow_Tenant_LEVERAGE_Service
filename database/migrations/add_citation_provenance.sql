-- ============================================================================
-- CITATION-FIRST MIGRATION: Add Provenance Fields to Existing validation_rules
-- ============================================================================
-- Version: 1.0.0
-- Date: January 30, 2026
-- Purpose: Add citation/provenance tracking to EXISTING tenant database schema
-- Target: draft.validation_rules table (already exists in tenant DB)
-- ============================================================================
-- This migration ADDS to existing tables, not create new ones
-- ============================================================================

-- ============================================================================
-- STEP 1: Add Legal Source Reference Table (NEW)
-- ============================================================================
-- Supports multi-jurisdiction: state (CA, TX, NY), county (Miami-Dade, Los Angeles), court, federal

CREATE TABLE IF NOT EXISTS draft.legal_sources (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Authority Identification
    jurisdiction_type VARCHAR(20) NOT NULL CHECK (jurisdiction_type IN ('state', 'federal', 'county', 'court', 'municipal')),
    jurisdiction_state VARCHAR(2),  -- US state code: CA, TX, NY
    jurisdiction_county VARCHAR(100),  -- County name: Miami-Dade, Los Angeles
    jurisdiction_court VARCHAR(200),  -- Court name: Superior Court, District Court
    
    name VARCHAR(200) NOT NULL,
    publisher VARCHAR(200) NOT NULL,
    abbreviation VARCHAR(50),
    
    -- Access Information
    base_url TEXT,
    source_type VARCHAR(50) NOT NULL CHECK (source_type IN ('statute', 'court_rule', 'local_rule', 'form', 'case_law', 'admin_policy')),
    trust_level VARCHAR(20) NOT NULL DEFAULT 'high' CHECK (trust_level IN ('high', 'medium', 'low')),
    
    -- Metadata
    is_active BOOLEAN NOT NULL DEFAULT true,
    notes TEXT,
    
    -- Administrative
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    CONSTRAINT unique_legal_source UNIQUE (jurisdiction_type, jurisdiction_state, name, source_type)
);

-- Indexes for legal_sources (idempotent)
CREATE INDEX IF NOT EXISTS idx_legal_sources_jurisdiction ON draft.legal_sources(jurisdiction_type);
CREATE INDEX IF NOT EXISTS idx_legal_sources_state ON draft.legal_sources(jurisdiction_state);
CREATE INDEX IF NOT EXISTS idx_legal_sources_county ON draft.legal_sources(jurisdiction_county);
CREATE INDEX IF NOT EXISTS idx_legal_sources_type ON draft.legal_sources(source_type);
CREATE INDEX IF NOT EXISTS idx_legal_sources_active ON draft.legal_sources(is_active) WHERE is_active = true;

-- ============================================================================
-- STEP 2: Add Citations Table (NEW)
-- ============================================================================
-- Pure citation proof - NO jurisdiction (jurisdiction belongs in validation_rules)

CREATE TABLE IF NOT EXISTS draft.rule_citations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Link to legal source (FK-based, not text)
    legal_source_id UUID REFERENCES draft.legal_sources(id) ON DELETE RESTRICT,
    
    -- Citation Details (NO jurisdiction - that's in validation_rules)
    source_type VARCHAR(50) NOT NULL CHECK (source_type IN ('statute', 'court_rule', 'local_rule', 'form', 'case_law', 'admin_policy')),
    source_name VARCHAR(200) NOT NULL,  -- e.g., "California Rules of Court" (denormalized for display)
    citation VARCHAR(500) NOT NULL,     -- e.g., "CRC Rule 2.111"
    source_url TEXT,
    
    -- Excerpt (Core "Proof")
    excerpt TEXT NOT NULL,              -- The actual text the rule is based on
    locator VARCHAR(200),                -- Section/subsection, e.g., "2.111(b)"
    
    -- Temporal
    effective_date DATE,
    last_verified_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    verifier VARCHAR(100),              -- Who verified this citation
    
    -- Confidence
    confidence_level VARCHAR(20) NOT NULL DEFAULT 'high' CHECK (confidence_level IN ('high', 'medium', 'low')),
    
    -- Metadata
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Idempotency: unique citation by legal_source (FK-based, not text)
    CONSTRAINT uq_rule_citations_source_citation UNIQUE (legal_source_id, citation)
);

-- Indexes for rule_citations (idempotent)
CREATE INDEX IF NOT EXISTS idx_rule_citations_legal_source ON draft.rule_citations(legal_source_id);
CREATE INDEX IF NOT EXISTS idx_rule_citations_citation ON draft.rule_citations(citation);
CREATE INDEX IF NOT EXISTS idx_rule_citations_verified ON draft.rule_citations(last_verified_at);

-- ============================================================================
-- STEP 3: Add Provenance Columns to EXISTING validation_rules
-- ============================================================================
-- IMPORTANT: All new jurisdiction columns are NULLABLE (no NOT NULL on day 1)
-- Legacy 'jurisdiction' column is untouched - normalized fields take precedence

-- Add normalized jurisdiction scope (state vs federal - NOT mixing with specificity)
ALTER TABLE draft.validation_rules 
ADD COLUMN IF NOT EXISTS jurisdiction_scope VARCHAR(20) CHECK (jurisdiction_scope IN ('state', 'federal'));

-- Add jurisdiction specificity columns (all nullable)
ALTER TABLE draft.validation_rules 
ADD COLUMN IF NOT EXISTS jurisdiction_state VARCHAR(2);  -- CA, TX, NY
ALTER TABLE draft.validation_rules 
ADD COLUMN IF NOT EXISTS jurisdiction_county VARCHAR(100);  -- Los Angeles, Miami-Dade
ALTER TABLE draft.validation_rules 
ADD COLUMN IF NOT EXISTS jurisdiction_court VARCHAR(200);  -- Superior Court, District Court

-- Add CHECK constraints for consistency (enforce logical relationships)
ALTER TABLE draft.validation_rules DROP CONSTRAINT IF EXISTS chk_federal_no_state;
ALTER TABLE draft.validation_rules ADD CONSTRAINT chk_federal_no_state
    CHECK (jurisdiction_scope <> 'federal' OR jurisdiction_state IS NULL);

ALTER TABLE draft.validation_rules DROP CONSTRAINT IF EXISTS chk_county_requires_state;
ALTER TABLE draft.validation_rules ADD CONSTRAINT chk_county_requires_state
    CHECK (jurisdiction_county IS NULL OR jurisdiction_state IS NOT NULL);

ALTER TABLE draft.validation_rules DROP CONSTRAINT IF EXISTS chk_court_requires_state;
ALTER TABLE draft.validation_rules ADD CONSTRAINT chk_court_requires_state
    CHECK (jurisdiction_court IS NULL OR jurisdiction_state IS NOT NULL);

-- Add citation link column (WITHOUT FK first - will add FK after tables exist)
ALTER TABLE draft.validation_rules 
ADD COLUMN IF NOT EXISTS citation_id UUID;

-- Add status workflow columns (only workflow fields here, no provenance duplication)
ALTER TABLE draft.validation_rules 
ADD COLUMN IF NOT EXISTS review_status VARCHAR(20) DEFAULT 'draft';
ALTER TABLE draft.validation_rules 
ADD COLUMN IF NOT EXISTS reviewed_by VARCHAR(100);
ALTER TABLE draft.validation_rules 
ADD COLUMN IF NOT EXISTS reviewed_at TIMESTAMP WITH TIME ZONE;

-- Add version tracking for rules
ALTER TABLE draft.validation_rules 
ADD COLUMN IF NOT EXISTS rule_version INTEGER NOT NULL DEFAULT 1;
ALTER TABLE draft.validation_rules 
ADD COLUMN IF NOT EXISTS supersedes_rule_id UUID REFERENCES draft.validation_rules(id);

-- Add verification tracking (pointer to citation, not duplicated data)
ALTER TABLE draft.validation_rules 
ADD COLUMN IF NOT EXISTS last_verified_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE draft.validation_rules 
ADD COLUMN IF NOT EXISTS verifier VARCHAR(100);

-- Add indexes for jurisdiction filtering (idempotent)
CREATE INDEX IF NOT EXISTS idx_validation_rules_jurisdiction_scope ON draft.validation_rules(jurisdiction_scope);
CREATE INDEX IF NOT EXISTS idx_validation_rules_jurisdiction_state ON draft.validation_rules(jurisdiction_state);
CREATE INDEX IF NOT EXISTS idx_validation_rules_jurisdiction_county ON draft.validation_rules(jurisdiction_county);
CREATE INDEX IF NOT EXISTS idx_validation_rules_practice_jurisdiction ON draft.validation_rules(practice_area, jurisdiction_state);

-- Now add FK constraints (after both tables exist)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'fk_validation_rules_citation'
    ) THEN
        ALTER TABLE draft.validation_rules 
        ADD CONSTRAINT fk_validation_rules_citation 
        FOREIGN KEY (citation_id) REFERENCES draft.rule_citations(id) ON DELETE SET NULL;
    END IF;
END $$;

-- ============================================================================
-- STEP 4: Add Constraints
-- ============================================================================

-- Rule cannot be active without citation (checks only local column - citation_id)
-- Note: Using review_status='active' as the trigger, not is_active
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'chk_active_rule_needs_citation'
    ) THEN
        ALTER TABLE draft.validation_rules 
        ADD CONSTRAINT chk_active_rule_needs_citation 
        CHECK (
            (review_status = 'active' AND citation_id IS NOT NULL) 
            OR review_status != 'active'
        );
    END IF;
END $$;

-- ============================================================================
-- STEP 5: Seed Initial Legal Sources (CA PI)
-- ============================================================================

INSERT INTO draft.legal_sources (jurisdiction_type, jurisdiction_state, name, publisher, abbreviation, base_url, source_type, trust_level, notes)
VALUES 
    ('state', 'CA', 'California Rules of Court', 'Judicial Council of California', 'CRC', 'https://www.courts.ca.gov/rules/', 'court_rule', 'high', 'Official court rules published by Judicial Council'),
    ('state', 'CA', 'California Code of Civil Procedure', 'California Legislature', 'CCP', 'https://leginfo.legislature.ca.gov/faces/codesTOCSelected.xhtml?tocCode=CCP', 'statute', 'high', 'California statutes enacted by Legislature')
ON CONFLICT (jurisdiction_type, jurisdiction_state, name, source_type) DO NOTHING;

-- ============================================================================
-- STEP 6: Seed Initial Citations (CA PI Foundation Rules)
-- ============================================================================
-- Uses legal_source_id FK for uniqueness (not text-based source_name)

-- Get legal source IDs
DO $$
DECLARE
    crc_id UUID;
    ccp_id UUID;
BEGIN
    SELECT id INTO crc_id FROM draft.legal_sources WHERE abbreviation = 'CRC';
    SELECT id INTO ccp_id FROM draft.legal_sources WHERE abbreviation = 'CCP';
    
    -- CRC Rule 2.111 - Attorney Contact Block
    INSERT INTO draft.rule_citations (legal_source_id, source_type, source_name, citation, source_url, excerpt, locator, effective_date, last_verified_at, verifier, confidence_level)
    VALUES 
        (crc_id, 'court_rule', 'California Rules of Court', 'CRC Rule 2.111', 'https://www.courts.ca.gov/rules/', 'The first page of every paper filed must contain: (1) the name, address, telephone number, and email address of the attorney or party appearing without an attorney; (2) the name of the party or parties represented; (3) the title of the document.', 'Rule 2.111', '2026-01-01', NOW(), 'citation_seed', 'high')
    ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        last_verified_at = EXCLUDED.last_verified_at;

    -- CRC Rule 2.108 - Line Numbering
    INSERT INTO draft.rule_citations (legal_source_id, source_type, source_name, citation, source_url, excerpt, locator, effective_date, last_verified_at, verifier, confidence_level)
    VALUES 
        (crc_id, 'court_rule', 'California Rules of Court', 'CRC Rule 2.108', 'https://www.courts.ca.gov/rules/', 'Lines must be numbered consecutively and must be 1.5 or double spaced. Footnotes and citations in footnotes are single-spaced.', 'Rule 2.108', '2026-01-01', NOW(), 'citation_seed', 'high')
    ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        last_verified_at = EXCLUDED.last_verified_at;

    -- CCP § 425.10(a)(1) - Facts
    INSERT INTO draft.rule_citations (legal_source_id, source_type, source_name, citation, source_url, excerpt, locator, effective_date, last_verified_at, verifier, confidence_level)
    VALUES 
        (ccp_id, 'statute', 'California Code of Civil Procedure', 'CCP § 425.10(a)(1)', 'https://leginfo.legislature.ca.gov/', 'A complaint must contain: (1) A statement of the facts constituting the cause of action, in ordinary and concise language.', '425.10(a)(1)', '2026-01-01', NOW(), 'citation_seed', 'high')
    ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        last_verified_at = EXCLUDED.last_verified_at;

    -- CCP § 425.10(a)(2) - Demand
    INSERT INTO draft.rule_citations (legal_source_id, source_type, source_name, citation, source_url, excerpt, locator, effective_date, last_verified_at, verifier, confidence_level)
    VALUES 
        (ccp_id, 'statute', 'California Code of Civil Procedure', 'CCP § 425.10(a)(2)', 'https://leginfo.legislature.ca.gov/', 'A complaint must contain: (2) A demand for judgment for the relief to which the plaintiff claims to be entitled.', '425.10(a)(2)', '2026-01-01', NOW(), 'citation_seed', 'high')
    ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        last_verified_at = EXCLUDED.last_verified_at;

    -- CCP § 395 - Venue
    INSERT INTO draft.rule_citations (legal_source_id, source_type, source_name, citation, source_url, excerpt, locator, effective_date, last_verified_at, verifier, confidence_level)
    VALUES 
        (ccp_id, 'statute', 'California Code of Civil Procedure', 'CCP § 395', 'https://leginfo.legislature.ca.gov/', 'The county in which the defendants or some of them reside at the time the action is commenced is the proper county for the trial of the action.', '395', '2026-01-01', NOW(), 'citation_seed', 'high')
    ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        last_verified_at = EXCLUDED.last_verified_at;

    -- CCP § 412.20(a) - Summons
    INSERT INTO draft.rule_citations (legal_source_id, source_type, source_name, citation, source_url, excerpt, locator, effective_date, last_verified_at, verifier, confidence_level)
    VALUES 
        (ccp_id, 'statute', 'California Code of Civil Procedure', 'CCP § 412.20(a)', 'https://leginfo.legislature.ca.gov/', 'The summons must contain: (1) The name of the court and the names of the parties to the action; (2) A direction that the defendant appear and answer within 30 days; (3) A notice that unless the defendant appears, the plaintiff may take a default judgment.', '412.20(a)', '2026-01-01', NOW(), 'citation_seed', 'high')
    ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        last_verified_at = EXCLUDED.last_verified_at;

    -- CCP § 335.1 - SOL
    INSERT INTO draft.rule_citations (legal_source_id, source_type, source_name, citation, source_url, excerpt, locator, effective_date, last_verified_at, verifier, confidence_level)
    VALUES 
        (ccp_id, 'statute', 'California Code of Civil Procedure', 'CCP § 335.1', 'https://leginfo.legislature.ca.gov/', 'Within two years: An action for assault, battery, or injury to a person arising out of the professional negligence of a health care provider.', '335.1', '2026-01-01', NOW(), 'citation_seed', 'high')
    ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        last_verified_at = EXCLUDED.last_verified_at;

    -- CCP § 446 - Verification
    INSERT INTO draft.rule_citations (legal_source_id, source_type, source_name, citation, source_url, excerpt, locator, effective_date, last_verified_at, verifier, confidence_level)
    VALUES 
        (ccp_id, 'statute', 'California Code of Civil Procedure', 'CCP § 446', 'https://leginfo.legislature.ca.gov/', 'Whenever a party to an action files a pleading subscribed by him under oath, the party shall be deemed to have made the statements therein under penalty of perjury.', '446', '2026-01-01', NOW(), 'citation_seed', 'high')
    ON CONFLICT (legal_source_id, citation) DO UPDATE SET
        source_url = EXCLUDED.source_url,
        excerpt = EXCLUDED.excerpt,
        last_verified_at = EXCLUDED.last_verified_at;
END $$;

-- ============================================================================
-- STEP 7: Grant Permissions
-- ============================================================================

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA draft TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA draft TO service_role;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA draft TO authenticated;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA draft TO service_role;

-- ============================================================================
-- STEP 8: Verification
-- ============================================================================

DO $$
BEGIN
    RAISE NOTICE '========================================';
    RAISE NOTICE 'CITATION-FIRST MIGRATION COMPLETE';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Tables modified/created:';
    RAISE NOTICE '  - draft.legal_sources (NEW)';
    RAISE NOTICE '  - draft.rule_citations (NEW)';
    RAISE NOTICE '  - draft.validation_rules (MODIFIED - added citation FK + workflow)';
    RAISE NOTICE '';
    RAISE NOTICE 'New columns in validation_rules:';
    RAISE NOTICE '  - citation_id (FK to rule_citations - provenance there, not duplicated)';
    RAISE NOTICE '  - review_status, reviewed_by, reviewed_at (workflow)';
    RAISE NOTICE '  - rule_version, supersedes_rule_id (versioning)';
    RAISE NOTICE '  - last_verified_at, verifier (verification)';
    RAISE NOTICE '';
    RAISE NOTICE 'Constraints:';
    RAISE NOTICE '  - chk_active_rule_needs_citation (active = must have citation_id)';
    RAISE NOTICE '';
    RAISE NOTICE 'Provenance lives in rule_citations, NOT duplicated on rules';
END $$;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Show counts
SELECT 
    (SELECT COUNT(*) FROM draft.legal_sources) AS legal_sources_count,
    (SELECT COUNT(*) FROM draft.rule_citations) AS citations_count;

-- Verify citations have URL + excerpt
SELECT 
    COUNT(*) AS total_citations,
    COUNT(CASE WHEN source_url IS NOT NULL AND source_url != '' THEN 1 END) AS with_url,
    COUNT(CASE WHEN excerpt IS NOT NULL AND excerpt != '' THEN 1 END) AS with_excerpt,
    COUNT(CASE WHEN source_url IS NOT NULL AND excerpt IS NOT NULL THEN 1 END) AS complete_citations
FROM draft.rule_citations;

-- List all citations with proof
SELECT 
    citation,
    source_url,
    LEFT(excerpt, 80) AS excerpt_preview,
    confidence_level
FROM draft.rule_citations
ORDER BY citation;