-- ============================================================================
-- TrueVow LEVERAGE Service - Complete Database Schema
-- ============================================================================
-- Version: 3.0.0
-- Date: April 2026
-- Description: Full schema for the LEVERAGE service with two schemas:
--   1. draft  - Validation rules and legal sources (document compliance)
--   2. leverage - Case intelligence, compliance, economics, rewards, notifications
--
-- Architecture:
--   - draft schema:  Global rule templates + tenant-specific rules + legal sources
--   - leverage schema: Case lifecycle, compliance intelligence, case economics,
--     settlement capture, deadline tracking, notifications, reward flywheel
--
-- Zero-Knowledge Architecture:
--   - NO document content stored anywhere
--   - NO client PII/PHI stored
--   - Only validation rules, structured signals, and metadata
-- ============================================================================

-- ============================================================================
-- SCHEMA 1: draft
-- ============================================================================

CREATE SCHEMA IF NOT EXISTS draft;

-- ============================================================================
-- TABLE: draft.legal_sources
-- Stores authoritative legal sources with citations
-- ============================================================================

CREATE TABLE draft.legal_sources (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Jurisdiction
    jurisdiction_type VARCHAR(50) NOT NULL,  -- 'state', 'federal', 'local'
    jurisdiction_state VARCHAR(2),
    jurisdiction_county VARCHAR(100),
    jurisdiction_court VARCHAR(200),

    -- Source identity
    name TEXT NOT NULL,
    publisher VARCHAR(255),
    abbreviation VARCHAR(100),
    base_url TEXT,
    source_type VARCHAR(50) NOT NULL,  -- 'statute', 'case_law', 'court_rule', 'regulation'
    trust_level VARCHAR(20) NOT NULL DEFAULT 'medium',  -- 'high', 'medium', 'low'

    -- Notes
    notes TEXT,

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Unique constraint (used by seed ON CONFLICT)
    CONSTRAINT uq_legal_sources_jurisdiction UNIQUE (jurisdiction_type, jurisdiction_state, name, source_type)
);

-- Indexes
CREATE INDEX idx_legal_sources_jurisdiction_state ON draft.legal_sources(jurisdiction_state) WHERE jurisdiction_state IS NOT NULL;
CREATE INDEX idx_legal_sources_jurisdiction_type ON draft.legal_sources(jurisdiction_type);
CREATE INDEX idx_legal_sources_source_type ON draft.legal_sources(source_type);
CREATE INDEX idx_legal_sources_trust_level ON draft.legal_sources(trust_level);

COMMENT ON TABLE draft.legal_sources IS 'Authoritative legal sources with citations for validation rules';

-- ============================================================================
-- TABLE: draft.validation_rules
-- Stores both global rule templates AND tenant-specific rules
-- ============================================================================

CREATE TABLE draft.validation_rules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Rule identity (UNIQUE - used by seed ON CONFLICT)
    rule_name VARCHAR(255) NOT NULL,

    -- 5-Level Validator Hierarchy
    validator_level INTEGER NOT NULL CHECK (validator_level BETWEEN 1 AND 5),
    validator_name VARCHAR(100) NOT NULL,
    validator_type VARCHAR(50) NOT NULL,  -- 'content_check', 'threshold_check', 'format_check', 'required_field', 'citation_check'

    -- Level 2: Practice Area
    practice_area VARCHAR(100),  -- 'personal_injury', 'family_law', 'bankruptcy', etc.

    -- Level 3: Specialization
    specialization VARCHAR(100),  -- 'car_accident', 'slip_fall', 'dog_bite', etc.

    -- Level 4: Document Type
    document_type VARCHAR(100),  -- 'complaint', 'demand_letter', 'general', etc.

    -- Level 5: Jurisdiction
    jurisdiction_scope VARCHAR(50),  -- 'state', 'federal', 'local'
    jurisdiction_state VARCHAR(2),
    jurisdiction_county VARCHAR(100),
    jurisdiction_court VARCHAR(200),

    -- Validator Configuration
    validator_config JSONB NOT NULL DEFAULT '{}'::jsonb,

    -- Validation Messages
    error_message TEXT,
    warning_message TEXT,
    info_message TEXT,

    -- Severity
    severity VARCHAR(20) NOT NULL DEFAULT 'error' CHECK (severity IN ('error', 'warning', 'info')),

    -- Citation (FK to legal_sources)
    citation_id UUID REFERENCES draft.legal_sources(id) ON DELETE SET NULL,

    -- Review Status (for attorney verification workflow)
    review_status VARCHAR(50) NOT NULL DEFAULT 'needs_review',
    -- 'needs_review', 'ai_generated', 'document_verified', 'attorney_verified'

    -- Status
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    is_template BOOLEAN NOT NULL DEFAULT FALSE,

    -- Tenant Scoping (NULL = global template, VARCHAR = Clerk org ID)
    tenant_id VARCHAR(255),

    -- Template Inheritance
    inherited_from_template_id UUID,
    is_customized BOOLEAN NOT NULL DEFAULT FALSE,
    template_name VARCHAR(200),
    template_description TEXT,
    is_enabled_for_validation BOOLEAN NOT NULL DEFAULT TRUE,

    -- Versioning
    version INTEGER NOT NULL DEFAULT 1,
    is_required BOOLEAN NOT NULL DEFAULT TRUE,

    -- Rule Dependencies
    depends_on_rule_ids UUID[],

    -- Administrative
    created_by UUID,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    archived_at TIMESTAMPTZ,

    -- Notes
    notes TEXT,

    -- Constraints
    CONSTRAINT uq_validation_rules_rule_name UNIQUE (rule_name)
);

-- Indexes for validation_rules
CREATE INDEX idx_vr_validator_level ON draft.validation_rules(validator_level);
CREATE INDEX idx_vr_practice_area ON draft.validation_rules(practice_area) WHERE practice_area IS NOT NULL;
CREATE INDEX idx_vr_specialization ON draft.validation_rules(specialization) WHERE specialization IS NOT NULL;
CREATE INDEX idx_vr_document_type ON draft.validation_rules(document_type) WHERE document_type IS NOT NULL;
CREATE INDEX idx_vr_jurisdiction_state ON draft.validation_rules(jurisdiction_state) WHERE jurisdiction_state IS NOT NULL;
CREATE INDEX idx_vr_jurisdiction_scope ON draft.validation_rules(jurisdiction_scope) WHERE jurisdiction_scope IS NOT NULL;
CREATE INDEX idx_vr_is_active ON draft.validation_rules(is_active) WHERE is_active = TRUE;
CREATE INDEX idx_vr_is_template ON draft.validation_rules(is_template) WHERE is_template = TRUE;
CREATE INDEX idx_vr_tenant_id ON draft.validation_rules(tenant_id) WHERE tenant_id IS NOT NULL;
CREATE INDEX idx_vr_review_status ON draft.validation_rules(review_status);
CREATE INDEX idx_vr_citation_id ON draft.validation_rules(citation_id) WHERE citation_id IS NOT NULL;
CREATE INDEX idx_vr_enabled ON draft.validation_rules(is_enabled_for_validation) WHERE is_enabled_for_validation = TRUE;
CREATE INDEX idx_vr_created_at ON draft.validation_rules(created_at DESC);
CREATE INDEX idx_vr_tenant_practice_area ON draft.validation_rules(tenant_id, practice_area) WHERE tenant_id IS NOT NULL;
CREATE INDEX idx_vr_template_practice ON draft.validation_rules(is_template, practice_area) WHERE is_template = TRUE;

COMMENT ON TABLE draft.validation_rules IS 'Validation rules library - 5-level hierarchy with template inheritance and zero-knowledge compliance';

-- ============================================================================
-- SCHEMA 2: leverage
-- ============================================================================

CREATE SCHEMA IF NOT EXISTS leverage;

-- ============================================================================
-- TABLE: leverage.leverage_case_profiles
-- Core case lifecycle data - one row per case per tenant
-- ============================================================================

CREATE TABLE leverage.leverage_case_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    case_id VARCHAR(36) NOT NULL,
    tenant_id VARCHAR(255) NOT NULL,

    -- Case signals (structured, no document content)
    incident_type VARCHAR(100),
    incident_date DATE,
    county VARCHAR(100),
    state VARCHAR(2),
    injury_category VARCHAR(50),
    medical_specials_band VARCHAR(50),
    policy_limit_band VARCHAR(50),
    insurer VARCHAR(200),
    liability_strength VARCHAR(50),
    litigation_stage VARCHAR(50),

    -- Settlement window
    estimated_settle_by DATE,

    -- MDM integration
    mdm_snapshot_version INTEGER DEFAULT 1,
    snapshot_source_event VARCHAR(100) DEFAULT 'case.opened',

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_case_profiles UNIQUE (case_id, tenant_id)
);

CREATE INDEX idx_lcp_tenant_id ON leverage.leverage_case_profiles(tenant_id);
CREATE INDEX idx_lcp_state ON leverage.leverage_case_profiles(state) WHERE state IS NOT NULL;
CREATE INDEX idx_lcp_litigation_stage ON leverage.leverage_case_profiles(litigation_stage);
CREATE INDEX idx_lcp_incident_type ON leverage.leverage_case_profiles(incident_type) WHERE incident_type IS NOT NULL;
CREATE INDEX idx_lcp_created_at ON leverage.leverage_case_profiles(created_at DESC);

COMMENT ON TABLE leverage.leverage_case_profiles IS 'Case lifecycle profiles - structured signals only, no document content';

-- ============================================================================
-- TABLE: leverage.leverage_case_events
-- Append-only event store for case timeline
-- ============================================================================

CREATE TABLE leverage.leverage_case_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    case_id VARCHAR(36) NOT NULL,
    tenant_id VARCHAR(255) NOT NULL,
    event_type VARCHAR(100) NOT NULL,
    event_source VARCHAR(50),
    payload JSONB,
    occurred_at TIMESTAMPTZ NOT NULL,
    recorded_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_lce_case_id ON leverage.leverage_case_events(case_id);
CREATE INDEX idx_lce_tenant_id ON leverage.leverage_case_events(tenant_id);
CREATE INDEX idx_lce_event_type ON leverage.leverage_case_events(event_type);
CREATE INDEX idx_lce_occurred_at ON leverage.leverage_case_events(occurred_at DESC);

COMMENT ON TABLE leverage.leverage_case_events IS 'Append-only case event store for timeline and audit trail';

-- ============================================================================
-- TABLE: leverage.leverage_validation_results
-- Compliance intelligence results - versioned and immutable
-- ============================================================================

CREATE TABLE leverage.leverage_validation_results (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    case_id VARCHAR(36) NOT NULL,
    tenant_id VARCHAR(255) NOT NULL,
    version INTEGER NOT NULL,

    -- Statute of limitations check
    statute_status VARCHAR(50),  -- 'safe', 'warning', 'critical', 'overdue', 'unknown', 'sol_rule_missing'
    days_remaining INTEGER,

    -- Demand letter check
    demand_status VARCHAR(50),  -- 'complete', 'incomplete'
    missing_items JSONB,

    -- Compliance flags
    flags JSONB,

    -- Legal defensibility
    rules_snapshot JSONB,
    validation_engine_version VARCHAR(50),
    rules_version_hash VARCHAR(64),

    -- Timestamp
    validated_at TIMESTAMPTZ NOT NULL
);

CREATE INDEX idx_lvr_case_id ON leverage.leverage_validation_results(case_id);
CREATE INDEX idx_lvr_tenant_id ON leverage.leverage_validation_results(tenant_id);
CREATE INDEX idx_lvr_version ON leverage.leverage_validation_results(version);
CREATE INDEX idx_lvr_statute_status ON leverage.leverage_validation_results(statute_status) WHERE statute_status IS NOT NULL;
CREATE INDEX idx_lvr_validated_at ON leverage.leverage_validation_results(validated_at DESC);

COMMENT ON TABLE leverage.leverage_validation_results IS 'Versioned compliance intelligence results - append-only, immutable';

-- ============================================================================
-- TABLE: leverage.leverage_settlement_windows
-- Estimated settlement duration by incident type and state
-- ============================================================================

CREATE TABLE leverage.leverage_settlement_windows (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    incident_type VARCHAR(100) NOT NULL,
    state VARCHAR(2) NOT NULL,
    estimated_days_to_settle INTEGER NOT NULL,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_settlement_windows UNIQUE (incident_type, state)
);

CREATE INDEX idx_lsw_incident_type ON leverage.leverage_settlement_windows(incident_type);
CREATE INDEX idx_lsw_state ON leverage.leverage_settlement_windows(state);

COMMENT ON TABLE leverage.leverage_settlement_windows IS 'Estimated settlement duration by incident type and jurisdiction';

-- ============================================================================
-- TABLE: leverage.leverage_settlement_details
-- Detailed settlement capture (Feature C) - upsert per case
-- ============================================================================

CREATE TABLE leverage.leverage_settlement_details (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    case_id VARCHAR(36) NOT NULL,
    tenant_id VARCHAR(255) NOT NULL,

    -- Settlement outcome
    settlement_amount NUMERIC,
    settlement_band VARCHAR(50),
    settlement_date DATE,
    settlement_method VARCHAR(50),  -- 'pre_suit', 'mediation', 'arbitration', 'trial'

    -- Parties
    insurer VARCHAR(200),
    adjuster_name VARCHAR(200),

    -- Negotiation details
    litigation_stage VARCHAR(50),
    negotiation_rounds INTEGER,
    demand_amount NUMERIC,
    first_offer_amount NUMERIC,
    final_counter_amount NUMERIC,
    comparative_fault_pct NUMERIC,
    policy_limit NUMERIC,

    -- Case economics
    medical_specials_total NUMERIC,
    lost_wages_total NUMERIC,

    -- Outcome
    outcome_satisfaction VARCHAR(50),
    key_factors JSONB,

    -- Intelligence network
    council_contribution_consent BOOLEAN DEFAULT FALSE,
    fingerprint_hash VARCHAR(64),

    -- Timestamps
    captured_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_settlement_details UNIQUE (case_id, tenant_id)
);

CREATE INDEX idx_lsd_tenant_id ON leverage.leverage_settlement_details(tenant_id);
CREATE INDEX idx_lsd_settlement_band ON leverage.leverage_settlement_details(settlement_band) WHERE settlement_band IS NOT NULL;
CREATE INDEX idx_lsd_council_consent ON leverage.leverage_settlement_details(council_contribution_consent) WHERE council_contribution_consent = TRUE;

COMMENT ON TABLE leverage.leverage_settlement_details IS 'Settlement detail capture for intelligence network - anonymized via fingerprinting';

-- ============================================================================
-- TABLE: leverage.leverage_damages_worksheets
-- PI damages calculator persistence - versioned append-only
-- ============================================================================

CREATE TABLE leverage.leverage_damages_worksheets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    case_id VARCHAR(36) NOT NULL,
    tenant_id VARCHAR(255) NOT NULL,
    version INTEGER NOT NULL,
    input_json JSONB,
    result_json JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_ldw_case_id ON leverage.leverage_damages_worksheets(case_id);
CREATE INDEX idx_ldw_tenant_id ON leverage.leverage_damages_worksheets(tenant_id);
CREATE INDEX idx_ldw_version ON leverage.leverage_damages_worksheets(version);

COMMENT ON TABLE leverage.leverage_damages_worksheets IS 'PI damages worksheet persistence - append-only, versioned';

-- ============================================================================
-- TABLE: leverage.leverage_disbursement_worksheets
-- Case disbursement/costs calculator persistence - versioned append-only
-- ============================================================================

CREATE TABLE leverage.leverage_disbursement_worksheets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    case_id VARCHAR(36) NOT NULL,
    tenant_id VARCHAR(255) NOT NULL,
    version INTEGER NOT NULL,
    input_json JSONB,
    result_json JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_lix_case_id ON leverage.leverage_disbursement_worksheets(case_id);
CREATE INDEX idx_lix_tenant_id ON leverage.leverage_disbursement_worksheets(tenant_id);
CREATE INDEX idx_lix_version ON leverage.leverage_disbursement_worksheets(version);

COMMENT ON TABLE leverage.leverage_disbursement_worksheets IS 'Case disbursement/costs worksheet persistence - append-only, versioned';

-- ============================================================================
-- TABLE: leverage.leverage_case_deadlines
-- Deadline tracking with urgency classification
-- ============================================================================

CREATE TABLE leverage.leverage_case_deadlines (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    case_id VARCHAR(36) NOT NULL,
    tenant_id VARCHAR(255) NOT NULL,
    deadline_type VARCHAR(50) NOT NULL,  -- 'sol', 'eeoc', 'demand_letter'
    deadline_date DATE NOT NULL,
    days_remaining INTEGER NOT NULL,
    urgency VARCHAR(20) NOT NULL,  -- 'SAFE', 'WARNING', 'CRITICAL', 'OVERDUE'
    source_state VARCHAR(2),
    calculation_input_json JSONB,
    calculation_result_json JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_lcd_case_id ON leverage.leverage_case_deadlines(case_id);
CREATE INDEX idx_lcd_tenant_id ON leverage.leverage_case_deadlines(tenant_id);
CREATE INDEX idx_lcd_deadline_type ON leverage.leverage_case_deadlines(deadline_type);
CREATE INDEX idx_lcd_urgency ON leverage.leverage_case_deadlines(urgency);
CREATE INDEX idx_lcd_deadline_date ON leverage.leverage_case_deadlines(deadline_date);
CREATE INDEX idx_lcd_source_state ON leverage.leverage_case_deadlines(source_state) WHERE source_state IS NOT NULL;

COMMENT ON TABLE leverage.leverage_case_deadlines IS 'Deadline tracking with urgency classification for SOL, EEOC, demand letter deadlines';

-- ============================================================================
-- TABLE: leverage.leverage_notification_subscriptions
-- User notification preferences for SOL/compliance alerts
-- ============================================================================

CREATE TABLE leverage.leverage_notification_subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id VARCHAR(255) NOT NULL,
    user_id VARCHAR(255) NOT NULL,
    channel VARCHAR(20) NOT NULL CHECK (channel IN ('webhook', 'in_app')),
    webhook_url TEXT,
    event_types JSONB NOT NULL,  -- ["deadline.critical", "deadline.overdue", "compliance.flag_added", "settlement.nudge"]
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_lns_tenant_id ON leverage.leverage_notification_subscriptions(tenant_id);
CREATE INDEX idx_lns_user_id ON leverage.leverage_notification_subscriptions(user_id);
CREATE INDEX idx_lns_is_active ON leverage.leverage_notification_subscriptions(is_active) WHERE is_active = TRUE;

COMMENT ON TABLE leverage.leverage_notification_subscriptions IS 'Notification subscription preferences for SOL urgency and compliance alerts';

-- ============================================================================
-- TABLE: leverage.leverage_notification_log
-- Notification delivery log for audit trail
-- ============================================================================

CREATE TABLE leverage.leverage_notification_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id VARCHAR(255) NOT NULL,
    user_id VARCHAR(255),
    case_id VARCHAR(36),
    event_type VARCHAR(100) NOT NULL,
    severity VARCHAR(20) NOT NULL,
    payload JSONB,
    channel VARCHAR(20) NOT NULL,
    delivery_status VARCHAR(20) NOT NULL,  -- 'pending', 'sent', 'failed'
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    delivered_at TIMESTAMPTZ
);

CREATE INDEX idx_lnl_tenant_id ON leverage.leverage_notification_log(tenant_id);
CREATE INDEX idx_lnl_user_id ON leverage.leverage_notification_log(user_id) WHERE user_id IS NOT NULL;
CREATE INDEX idx_lnl_event_type ON leverage.leverage_notification_log(event_type);
CREATE INDEX idx_lnl_created_at ON leverage.leverage_notification_log(created_at DESC);
CREATE INDEX idx_lnl_delivery_status ON leverage.leverage_notification_log(delivery_status);

COMMENT ON TABLE leverage.leverage_notification_log IS 'Notification delivery audit log - fire-and-forget with status tracking';

-- ============================================================================
-- TABLE: leverage.leverage_reward_ledger
-- LEVERAGE reward credit flywheel - welcome bonus + settlement credits
-- ============================================================================

CREATE TABLE leverage.leverage_reward_ledger (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id VARCHAR(255) NOT NULL,
    credits INTEGER NOT NULL,
    source VARCHAR(50) NOT NULL,  -- 'welcome_bonus', 'settlement'
    status VARCHAR(20) NOT NULL DEFAULT 'active',  -- 'active', 'used', 'expired'
    reference_case_id VARCHAR(36),
    expires_at TIMESTAMPTZ NOT NULL,
    used_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_lrl_tenant_id ON leverage.leverage_reward_ledger(tenant_id);
CREATE INDEX idx_lrl_status ON leverage.leverage_reward_ledger(status);
CREATE INDEX idx_lrl_source ON leverage.leverage_reward_ledger(source);
CREATE INDEX idx_lrl_expires_at ON leverage.leverage_reward_ledger(expires_at);
CREATE INDEX idx_lrl_tenant_status ON leverage.leverage_reward_ledger(tenant_id, status);

COMMENT ON TABLE leverage.leverage_reward_ledger IS 'LEVERAGE reward credit ledger - welcome bonus + settlement flywheel';

-- ============================================================================
-- TABLE: leverage.leverage_valuation_multipliers
-- Jurisdiction-aware PI valuation multiplier configurations per state
-- ============================================================================

CREATE TABLE leverage.leverage_valuation_multipliers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    state VARCHAR(2) NOT NULL,
    medical_multiplier_low NUMERIC NOT NULL,
    medical_multiplier_high NUMERIC NOT NULL,
    comparative_fault_rule VARCHAR(50) NOT NULL,  -- 'pure_comparative', 'modified_comparative_50', 'modified_comparative_51', 'contributory'
    typical_contingency_pct NUMERIC NOT NULL,
    notes TEXT,
    source VARCHAR(100),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_valuation_multipliers_state UNIQUE (state)
);

CREATE INDEX idx_lvm_comparative_fault ON leverage.leverage_valuation_multipliers(comparative_fault_rule);

COMMENT ON TABLE leverage.leverage_valuation_multipliers IS 'Jurisdiction-aware PI valuation multipliers - evidence-based settlement range estimation';

-- ============================================================================
-- TRIGGERS: Auto-update updated_at
-- ============================================================================

CREATE OR REPLACE FUNCTION draft.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION leverage.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- draft schema triggers
CREATE TRIGGER trigger_draft_legal_sources_updated_at
    BEFORE UPDATE ON draft.legal_sources
    FOR EACH ROW EXECUTE FUNCTION draft.update_updated_at_column();

CREATE TRIGGER trigger_draft_validation_rules_updated_at
    BEFORE UPDATE ON draft.validation_rules
    FOR EACH ROW EXECUTE FUNCTION draft.update_updated_at_column();

-- leverage schema triggers
CREATE TRIGGER trigger_leverage_case_profiles_updated_at
    BEFORE UPDATE ON leverage.leverage_case_profiles
    FOR EACH ROW EXECUTE FUNCTION leverage.update_updated_at_column();

CREATE TRIGGER trigger_leverage_settlement_details_updated_at
    BEFORE UPDATE ON leverage.leverage_settlement_details
    FOR EACH ROW EXECUTE FUNCTION leverage.update_updated_at_column();

-- ============================================================================
-- SCHEMA COMMENTS
-- ============================================================================

COMMENT ON SCHEMA draft IS 'TrueVow LEVERAGE Service - Document validation rules and legal sources (zero-knowledge architecture)';
COMMENT ON SCHEMA leverage IS 'TrueVow LEVERAGE Service - Case intelligence, compliance, economics, rewards, notifications, settlement';

-- ============================================================================
-- END OF SCHEMA
-- ============================================================================
