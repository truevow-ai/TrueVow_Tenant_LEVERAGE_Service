"""
Service Configuration for TrueVow LEVERAGE™ Service

Defines this service's identity, modules, and integration contracts
for registration with the Service Registry (Internal Ops, port 3006).
"""

import os

from app.services.service_registry_client import ServiceConfig

# ── SERVICE IDENTITY ──────────────────────────────────────────────────────────

SERVICE_NAME = os.getenv("SERVICE_NAME", "leverage-service")
SERVICE_PORT = int(os.getenv("SERVICE_PORT", "3036"))
SERVICE_URL  = os.getenv("LEVERAGE_SERVICE_API_URL", f"http://localhost:{SERVICE_PORT}")
SERVICE_TYPE = "case_intelligence"

# ── SERVICE CONFIG OBJECT ─────────────────────────────────────────────────────

LEVERAGE_SERVICE_CONFIG = ServiceConfig(
    service_name=SERVICE_NAME,
    service_type=SERVICE_TYPE,
    service_url=SERVICE_URL,
    port=SERVICE_PORT,
    endpoints=[
        # ── DRAFT core ──────────────────────────────────────────────────────
        {"path": "/api/v1/validation-rules",        "method": "GET",  "description": "Fetch validation rules for client-side sync"},
        {"path": "/api/v1/validation-rules/sync",   "method": "POST", "description": "Sync validation rules to tenant device"},
        {"path": "/api/v1/templates",               "method": "GET",  "description": "Fetch global document templates"},
        {"path": "/api/v1/tenant-rules",            "method": "GET",  "description": "Fetch tenant-specific rule overrides"},
        {"path": "/api/v1/compliance",              "method": "POST", "description": "Run compliance check against rules"},
        {"path": "/health",                         "method": "GET",  "description": "Service health check"},
        # ── LEVERAGE — case lifecycle ────────────────────────────────────────
        {"path": "/api/v1/leverage/case/open",               "method": "POST", "description": "Open a case in LEVERAGE pillar (tier-aware billing gate)"},
        {"path": "/api/v1/leverage/case/{case_id}/status",   "method": "GET",  "description": "Case billing status + LEVERAGE unlock check"},
        {"path": "/api/v1/leverage/case/{case_id}/compliance", "method": "POST", "description": "Run compliance intelligence signals (SOL, demand, flags)"},
        {"path": "/api/v1/leverage/case/{case_id}/settle",   "method": "POST", "description": "Record settlement outcome"},
        {"path": "/api/v1/leverage/case/{case_id}/history",  "method": "GET",  "description": "Validation history for a case (versioned, append-only)"},
        {"path": "/api/v1/leverage/cases",                   "method": "GET",  "description": "List all LEVERAGE cases for a tenant"},
        {"path": "/api/v1/leverage/case/{case_id}/events",   "method": "GET",  "description": "Timeline / activity feed for a case"},
        {"path": "/api/v1/leverage/case/{case_id}/detail",   "method": "GET",  "description": "Combined case detail (status + compliance + economics)"},
        {"path": "/api/v1/leverage/analytics",               "method": "GET",  "description": "Tenant-level LEVERAGE analytics dashboard"},
        # ── LEVERAGE — rewards (DISABLED v1: no credit system) ──────────
        # {"path": "/api/v1/leverage/onboard",           "method": "POST", "description": "Grant 11-credit welcome bonus on first retained client"},
        # {"path": "/api/v1/leverage/settlement-reward", "method": "POST", "description": "Grant 1 settlement reward credit"},
        # {"path": "/api/v1/leverage/rewards/balance",   "method": "GET",  "description": "Active reward credit count"},
        # {"path": "/api/v1/leverage/rewards/ledger",    "method": "GET",  "description": "Full reward transaction history"},
        # {"path": "/api/v1/leverage/rewards/summary",   "method": "GET",  "description": "Enriched reward balance with breakdown + expiration"},
        # ── LEVERAGE — Group B calculators + persistence ──────────────────────
        {"path": "/api/v1/leverage/damages",                          "method": "POST", "description": "PI damages worksheet calculator (stateless)"},
        {"path": "/api/v1/leverage/disbursement",                     "method": "POST", "description": "Case disbursement + net-to-client projection (stateless)"},
        {"path": "/api/v1/leverage/case/{case_id}/damages/save",      "method": "POST", "description": "Save damages worksheet to a case"},
        {"path": "/api/v1/leverage/case/{case_id}/damages",           "method": "GET",  "description": "Retrieve saved damages worksheets for a case"},
        {"path": "/api/v1/leverage/case/{case_id}/damages/{ws_id}",   "method": "GET",  "description": "Get specific saved damages worksheet"},
        {"path": "/api/v1/leverage/case/{case_id}/disbursement/save", "method": "POST", "description": "Save disbursement worksheet to a case"},
        {"path": "/api/v1/leverage/case/{case_id}/disbursement",      "method": "GET",  "description": "Retrieve saved disbursement worksheets for a case"},
        {"path": "/api/v1/leverage/case/{case_id}/disbursement/{ws_id}", "method": "GET", "description": "Get specific saved disbursement worksheet"},
        {"path": "/api/v1/leverage/case/{case_id}/economics",        "method": "GET",  "description": "Combined case economics: latest damages + disbursement"},
        # ── Deadline calculators + persistence ─────────────────────────────────
        {"path": "/api/v1/deadlines/sol",                    "method": "POST", "description": "Statute of limitations deadline calculator"},
        {"path": "/api/v1/deadlines/eeoc",                   "method": "POST", "description": "EEOC filing deadline calculator"},
        {"path": "/api/v1/deadlines/demand-letter",           "method": "POST", "description": "Demand letter deadline calculator"},
        {"path": "/api/v1/deadlines/case/{case_id}/save",     "method": "POST", "description": "Save calculated deadline to a case"},
        {"path": "/api/v1/deadlines/case/{case_id}",          "method": "GET",  "description": "Retrieve saved deadlines for a case"},
        {"path": "/api/v1/deadlines/upcoming",                 "method": "GET",  "description": "Upcoming deadlines across all cases for a tenant"},
        # ── LEVERAGE notifications (Feature A) ──────────────────────────────────
        {"path": "/api/v1/leverage/notifications/subscribe",         "method": "POST",   "description": "Register a notification subscription (webhook/in-app)"},
        {"path": "/api/v1/leverage/notifications/subscriptions",     "method": "GET",    "description": "List notification subscriptions for a tenant/user"},
        {"path": "/api/v1/leverage/notifications/subscriptions/{id}","method": "DELETE", "description": "Deactivate a notification subscription"},
        {"path": "/api/v1/leverage/notifications/log",              "method": "GET",    "description": "View notification delivery log"},
        {"path": "/api/v1/leverage/notifications/test",             "method": "POST",   "description": "Send a test notification"},
        # ── LEVERAGE valuation multipliers (Feature B) ──────────────────────────
        {"path": "/api/v1/leverage/valuation/multipliers",          "method": "GET",    "description": "Get valuation multiplier configs for a state"},
        {"path": "/api/v1/leverage/valuation/calculate",            "method": "POST",   "description": "Apply jurisdiction-aware valuation multipliers to damages"},
        # ── LEVERAGE settlement details + nudge (Feature C) ─────────────────────
        {"path": "/api/v1/leverage/case/{case_id}/settlement-details", "method": "PUT",  "description": "Capture full settlement details for a case"},
        {"path": "/api/v1/leverage/case/{case_id}/settlement-details", "method": "GET",  "description": "Retrieve settlement details for a case"},
        {"path": "/api/v1/leverage/case/nudge-pending",           "method": "GET",    "description": "List cases past their estimated settlement window"},
        {"path": "/api/v1/leverage/case/{case_id}/nudge",           "method": "POST",   "description": "Manually trigger a settlement nudge for a case"},
    ],
    capabilities=[
        # DRAFT core
        "validation_rules_sync",
        "client_side_compliance",
        "zero_knowledge_document_check",
        "protocol_v3_verified_rules",
        "multi_practice_area",
        "50_state_coverage",
        # LEVERAGE pillar
        "leverage_case_lifecycle",
        "leverage_billing_gate",
        "leverage_compliance_intelligence",
        "leverage_sol_validation",
        "leverage_reward_ledger",
        "leverage_damages_calculator",
        "leverage_disbursement_calculator",
        "leverage_case_persistence",
        "leverage_event_store",
        # LEVERAGE portal display
        "leverage_reward_ledger_display",
        "leverage_damages_persistence",
        "leverage_disbursement_persistence",
        "leverage_case_list",
        "leverage_case_timeline",
        "leverage_case_detail",
        "leverage_combined_economics",
        "leverage_tenant_analytics",
        "leverage_deadline_tracker",
        # Deadline tools
        "sol_deadline_calculator",
        "eeoc_deadline_calculator",
        "demand_letter_deadline_calculator",
        # LEVERAGE notifications (Feature A)
        "leverage_notification_subscriptions",
        "leverage_notification_delivery",
        "leverage_sol_urgency_notifications",
        "leverage_settlement_nudge_notifications",
        # LEVERAGE valuation multipliers (Feature B)
        "leverage_valuation_multiplier_lookup",
        "leverage_jurisdiction_aware_valuation",
        # LEVERAGE settlement details + nudge (Feature C)
        "leverage_settlement_detail_capture",
        "leverage_settlement_window_estimation",
        "leverage_settlement_nudge_system",
        "leverage_settlement_intelligence_feed",
    ],
    agents=[],
)

# ── MODULES ───────────────────────────────────────────────────────────────────

LEVERAGE_MODULES = [
    {
        "module_name": "validation_rules",
        "module_version": "3.0.0",
        "description": (
            "Protocol v3 verified legal validation rules across all 50 US states. "
            "Covers personal_injury, family_law, and criminal_defense practice areas."
        ),
        "endpoints": [
            {"path": "/api/v1/validation-rules",      "method": "GET"},
            {"path": "/api/v1/validation-rules/sync", "method": "POST"},
        ],
        "events_published": [
            {"event": "validation_rules.updated", "description": "Fired when rules are promoted to ai_verified_pending_attorney"},
            {"event": "validation_rules.synced",  "description": "Fired when rules are synced to a tenant device"},
        ],
        "events_consumed": [],
    },
    {
        "module_name": "document_templates",
        "module_version": "1.0.0",
        "description": "Global and tenant-specific document templates for legal draft assembly.",
        "endpoints": [
            {"path": "/api/v1/templates",    "method": "GET"},
            {"path": "/api/v1/tenant-rules", "method": "GET"},
        ],
        "events_published": [
            {"event": "template.published", "description": "Fired when a new template is activated"},
        ],
        "events_consumed": [
            {"event": "tenant.onboarded", "description": "Triggers default template provisioning for new tenant"},
        ],
    },
    {
        "module_name": "compliance_engine",
        "module_version": "1.0.0",
        "description": (
            "Zero-knowledge document compliance check engine. "
            "Documents never leave client device — only validation results returned."
        ),
        "endpoints": [
            {"path": "/api/v1/compliance", "method": "POST"},
        ],
        "events_published": [
            {"event": "compliance.check_completed", "description": "Fired on compliance check completion"},
            {"event": "compliance.violation_found",  "description": "Fired when a hard violation is detected"},
        ],
        "events_consumed": [],
    },
    {
        "module_name": "rules_sync",
        "module_version": "2.0.0",
        "description": (
            "Encrypted validation rules sync to client devices. "
            "Rules filtered per tenant, jurisdiction, and practice area."
        ),
        "endpoints": [
            {"path": "/api/v1/validation-rules/sync", "method": "POST"},
        ],
        "events_published": [
            {"event": "rules_sync.completed", "description": "Fired when sync payload is delivered to client"},
        ],
        "events_consumed": [
            {"event": "validation_rules.updated", "description": "Triggers re-sync to affected tenants"},
        ],
    },
    # ── LEVERAGE modules ─────────────────────────────────────────────────────
    {
        "module_name": "leverage_case_lifecycle",
        "module_version": "1.1.0",
        "description": (
            "LEVERAGE pillar case lifecycle. "
            "Billing gate (tier-aware), compliance intelligence (SOL + demand + flags), "
            "settlement recording, case list, timeline, detail. "
            "All state changes persisted to leverage schema with append-only event store."
        ),
        "endpoints": [
            {"path": "/api/v1/leverage/case/open",                 "method": "POST"},
            {"path": "/api/v1/leverage/case/{case_id}/status",     "method": "GET"},
            {"path": "/api/v1/leverage/case/{case_id}/compliance", "method": "POST"},
            {"path": "/api/v1/leverage/case/{case_id}/settle",     "method": "POST"},
            {"path": "/api/v1/leverage/case/{case_id}/history",    "method": "GET"},
            {"path": "/api/v1/leverage/cases",                     "method": "GET"},
            {"path": "/api/v1/leverage/case/{case_id}/events",     "method": "GET"},
            {"path": "/api/v1/leverage/case/{case_id}/detail",     "method": "GET"},
            {"path": "/api/v1/leverage/analytics",                 "method": "GET"},
        ],
        "events_published": [
            {"event": "leverage.case_opened",       "description": "Fired when a case is opened and billed"},
            {"event": "leverage.validation_run",    "description": "Fired on every compliance intelligence run"},
            {"event": "leverage.settlement_recorded", "description": "Fired when a settlement is recorded"},
            {"event": "statute.warning",            "description": "Fired when SOL deadline is critical or overdue"},
            {"event": "compliance.cleared",         "description": "Fired when case compliance passes with no flags"},
        ],
        "events_consumed": [
            {"event": "mdm.case_retained", "description": "Triggers case open billing when attorney retains client"},
        ],
    },
    {
        "module_name": "leverage_rewards",  # DISABLED v1: no credit system
        "module_version": "1.1.0",
        "description": (
            "LEVERAGE reward credit triggers and ledger display. "
            "Welcome bonus (11 credits) on first retained client; "
            "settlement bonus (1 credit) per settled case. "
            "Ledger and summary endpoints for Customer Portal display. "
            "Fail-open — billing service unavailability never blocks the attorney."
        ),
        "endpoints": [
            {"path": "/api/v1/leverage/onboard",           "method": "POST"},
            {"path": "/api/v1/leverage/settlement-reward", "method": "POST"},
            {"path": "/api/v1/leverage/rewards/balance",   "method": "GET"},
            {"path": "/api/v1/leverage/rewards/ledger",    "method": "GET"},
            {"path": "/api/v1/leverage/rewards/summary",   "method": "GET"},
        ],
        "events_published": [
            {"event": "leverage.welcome_bonus_granted",    "description": "Fired when 11-credit welcome bonus is granted"},
            {"event": "leverage.settlement_reward_granted", "description": "Fired when 1-credit settlement reward is granted"},
        ],
        "events_consumed": [
            {"event": "mdm.first_client_retained", "description": "Triggers welcome bonus for new attorney"},
            {"event": "leverage.settlement_recorded", "description": "Triggers settlement reward credit"},
        ],
    },
    {
        "module_name": "leverage_economics",
        "module_version": "1.1.0",
        "description": (
            "LEVERAGE Group B calculators with persistence. "
            "PI damages worksheet, case disbursement / net-to-client projection. "
            "Save/retrieve worksheets per case, combined economics view. "
            "Stateless calculation remains zero-knowledge; saved worksheets store only "
            "structured financial signals (no PII or document content)."
        ),
        "endpoints": [
            {"path": "/api/v1/leverage/damages",                          "method": "POST"},
            {"path": "/api/v1/leverage/disbursement",                     "method": "POST"},
            {"path": "/api/v1/leverage/case/{case_id}/damages/save",      "method": "POST"},
            {"path": "/api/v1/leverage/case/{case_id}/damages",           "method": "GET"},
            {"path": "/api/v1/leverage/case/{case_id}/damages/{ws_id}",   "method": "GET"},
            {"path": "/api/v1/leverage/case/{case_id}/disbursement/save", "method": "POST"},
            {"path": "/api/v1/leverage/case/{case_id}/disbursement",      "method": "GET"},
            {"path": "/api/v1/leverage/case/{case_id}/disbursement/{ws_id}", "method": "GET"},
            {"path": "/api/v1/leverage/case/{case_id}/economics",        "method": "GET"},
        ],
        "events_published": [],
        "events_consumed": [],
    },
    {
        "module_name": "leverage_deadline_tracker",
        "module_version": "1.0.0",
        "description": (
            "LEVERAGE deadline calculation and persistence. "
            "SOL, EEOC, demand letter, and right-to-sue deadline calculators. "
            "Save calculated deadlines to cases and retrieve upcoming deadlines across all cases."
        ),
        "endpoints": [
            {"path": "/api/v1/deadlines/sol",                    "method": "POST"},
            {"path": "/api/v1/deadlines/eeoc",                   "method": "POST"},
            {"path": "/api/v1/deadlines/calculate",               "method": "POST"},
            {"path": "/api/v1/deadlines/case/{case_id}/save",     "method": "POST"},
            {"path": "/api/v1/deadlines/case/{case_id}",          "method": "GET"},
            {"path": "/api/v1/deadlines/upcoming",                 "method": "GET"},
        ],
        "events_published": [],
        "events_consumed": [],
    },
]

# ── INTEGRATION CONTRACTS ─────────────────────────────────────────────────────

LEVERAGE_INTEGRATIONS = [
    {
        "source_service": SERVICE_NAME,
        "target_service": "tenant-app",
        "integration_type": "rules_provider",
        "purpose": "Provides validated legal rules for client-side document compliance checking",
        "event_triggers": ["validation_rules.updated", "validation_rules.synced"],
    },
    {
        "source_service": SERVICE_NAME,
        "target_service": "saas-admin",
        "integration_type": "rules_management",
        "purpose": "Receives rule management commands and attorney verification decisions",
        "event_triggers": ["compliance.violation_found"],
    },
    # ── LEVERAGE integration contracts ────────────────────────────────────────
    {
        "source_service": "mdm",
        "target_service": SERVICE_NAME,
        "integration_type": "case_event_consumer",
        "purpose": (
            "MDM sends case lifecycle events (retained, status change) to DRAFT/LEVERAGE. "
            "DRAFT reads case_id and tenant_id from MDM events to open LEVERAGE billing gates "
            "and persist case snapshots."
        ),
        "event_triggers": ["mdm.case_retained", "mdm.first_client_retained"],
    },
    {
        "source_service": SERVICE_NAME,
        "target_service": "billing-service",
        "integration_type": "billing_consumer",
        "purpose": (
            "LEVERAGE calls the Billing Service for tier-aware case metering (SOLO/GROWTH/TEAM). "
            "Included cases are covered by subscription; overage cases are charged per tier. "
            "Validation runs are included in subscription (no per-use charge in v1). "
            "All billing calls are fail-open — billing unavailability never blocks attorney workflow."
        ),
        "event_triggers": [
            "leverage.case_opened",
            "leverage.validation_run",
        ],
    },
    {
        "source_service": SERVICE_NAME,
        "target_service": "settle-service",
        "integration_type": "settlement_data_provider",
        "purpose": (
            "DRAFT/LEVERAGE publishes settlement_recorded events that SETTLE consumes "
            "to trigger similarity scoring, Intelligence Council enrichment, and "
            "settlement estimate updates. "
            "LEVERAGE never calls SETTLE directly — event-driven loose coupling."
        ),
        "event_triggers": ["leverage.settlement_recorded"],
    },
]
