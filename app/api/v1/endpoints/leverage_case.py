"""
TrueVow LEVERAGE™ — Case Lifecycle Endpoints

Implements the case-level workflow that connects Benjamin → LEVERAGE → SETTLE
into a single continuous experience.

Endpoints:
  POST /leverage/case/open               — Open a case (billing gate, tier-aware pricing)
  GET  /leverage/case/{case_id}/status   — Case billing status + unlock check
  POST /leverage/case/{case_id}/compliance  — Run compliance intelligence signals
  POST /leverage/case/{case_id}/settle   — Record settlement outcome

Architecture:
  - case_id is a UUID issued by MDM (the canonical identity authority).
  - tenant_id scopes all operations per law firm (Clerk org ID).
  - Billing gate is idempotent — opening the same case_id twice is safe.
  - Compliance runs persist results to leverage.leverage_validation_results.
  - SOL rules are read from leverage.validation_rules (primary_state_sol rows).
    If a state rule is missing → sol_rule_missing warning flag (no silent defaults).
  - Every state change emits a row to leverage.leverage_case_events (append-only).
  - Settlement recording persists the outcome and emits settlement_recorded event.

Case status progression (mirrors INTAKE):
  lead → consult_scheduled → retained → active → negotiation → settled → closed

Fail-open policy:
  Billing errors never block the attorney workflow.
  DB persistence errors are logged but do not fail the response.
  The portal degrades gracefully if billing service or DB is unavailable.

Validation engine version (bump when compliance logic changes):
  VALIDATION_ENGINE_VERSION = "1.0.0"
"""

import hashlib
import json
from datetime import date, datetime, timezone
from typing import Optional, List, Any
from uuid import UUID
from enum import Enum

from fastapi import APIRouter, Depends, status
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session
from sqlalchemy import text
import logging

from app.core.database import get_db
from app.core.event_emitter import LeverageEventEmitter
from app.services.billing_service import get_billing_service, BillingServiceUnavailable
from app.api.v1.endpoints.notifications import fire_notification

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/leverage/case", tags=["LEVERAGE - Case Lifecycle"])

VALIDATION_ENGINE_VERSION = "1.0.0"

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

# Pricing is now tier-aware — see billing_service.TIER_CONFIGS
# SOLO: $49/extra case, GROWTH: $39/extra, TEAM: $29/extra
# Included cases: 5/20/50 per tier
SETTLE_CASE_PRICE_USD   = 399         # Informational — SETTLE charges its own pillar


# ---------------------------------------------------------------------------
# Enums
# ---------------------------------------------------------------------------

class CaseStatus(str, Enum):
    lead               = "lead"
    consult_scheduled  = "consult_scheduled"
    retained           = "retained"
    active             = "active"
    negotiation        = "negotiation"
    settled            = "settled"
    closed             = "closed"


class LiabilityStrength(str, Enum):
    clear     = "clear"
    moderate  = "moderate"
    contested = "contested"
    unknown   = "unknown"


class LitigationStage(str, Enum):
    pre_suit    = "pre_suit"
    suit_filed  = "suit_filed"
    mediation   = "mediation"
    trial       = "trial"


# ---------------------------------------------------------------------------
# Shared case metadata (structured signals from Benjamin / INTAKE)
# ---------------------------------------------------------------------------

class CaseSignals(BaseModel):
    """
    Structured case signals populated by Benjamin (INTAKE) and confirmed by attorney.
    These drive compliance checks and SETTLE's similarity scoring.
    All fields are optional — the system works with whatever is available.
    """
    incident_type:         Optional[str]   = Field(None, description="slip_fall, auto_accident, dog_bite, premises_liability, wrongful_death, other")
    incident_date:         Optional[date]  = Field(None, description="Date of incident (for SOL calculation)")
    county:                Optional[str]   = Field(None, description="County name, e.g. Duval County")
    state:                 Optional[str]   = Field(None, description="Two-letter state code, e.g. FL")
    injury_category:       Optional[str]   = Field(None, description="minor, moderate, fracture, spinal, tbi, catastrophic")
    medical_specials_band: Optional[str]   = Field(None, description="0-5k, 5-15k, 15-30k, 30-75k, 75-150k, 150k+")
    policy_limit_band:     Optional[str]   = Field(None, description="unknown, under-25k, 25-50k, 50-100k, 100-250k, 250k+")
    insurer:               Optional[str]   = Field(None, description="Insurer name or 'Unknown'")
    liability_strength:    Optional[LiabilityStrength] = Field(None)
    litigation_stage:      Optional[LitigationStage]   = Field(LitigationStage.pre_suit)


# ===========================================================================
# POST /leverage/case/open
# ===========================================================================

class CaseOpenRequest(BaseModel):
    """
    Opens a case in the LEVERAGE pillar and records the billing charge.

    Called when the attorney marks a client as RETAINED.
    This is the monetization moment for the LEVERAGE pillar.

    Idempotent: calling with the same (tenant_id, case_id) a second time
    is safe — the billing service deduplicates by idempotency key.
    """
    tenant_id:    str              = Field(..., description="Tenant UUID (Clerk org ID)")
    case_id:      UUID             = Field(..., description="Case UUID issued by MDM")
    user_id:      Optional[str]    = Field(None, description="Attorney user ID (optional audit)")
    signals:      Optional[CaseSignals] = Field(None, description="Structured case signals from Benjamin")
    is_first_case: bool            = Field(False, description="True if this is the attorney's first retained client")

    class Config:
        json_schema_extra = {
            "example": {
                "tenant_id": "org_2abc123",
                "case_id":   "3fa85f64-5717-4562-b3fc-2c963f66afa6",
                "user_id":   "clerk_abc123",
                "is_first_case": False,
                "signals": {
                    "incident_type":   "slip_fall",
                    "incident_date":   "2026-01-15",
                    "county":          "Duval County",
                    "state":           "FL",
                    "injury_category": "minor",
                    "insurer":         "Unknown",
                    "liability_strength": "moderate",
                    "litigation_stage":   "pre_suit",
                }
            }
        }


class CaseOpenResponse(BaseModel):
    success:          bool
    case_id:          str   # UUID serialized as string for portal
    tenant_id:        str
    leverage_unlocked: bool
    billing_available: bool
    is_overage:       bool  = False
    overage_charge_usd: int = 0
    estimated_settle_by: Optional[str] = Field(None, description="Estimated settlement date (from settlement windows)")
    message:          str


@router.post(
    "/open",
    response_model=CaseOpenResponse,
    status_code=status.HTTP_200_OK,
    summary="Open a case in the LEVERAGE pillar (billing gate)",
)
async def open_case(request: CaseOpenRequest, db: Session = Depends(get_db)):
    """
    **LEVERAGE Case Open**

    Records the LEVERAGE case charge via the Billing Service (tier-aware pricing) and
    unlocks the Compliance Intelligence tab for this case in the portal.

    - Idempotent: duplicate case_id for the same tenant is a no-op
    - Fail-open: billing errors do not block the attorney
    - If `is_first_case=True`: also fires the 11-credit welcome bonus
    - SETTLE pillar unlock happens when attorney sends the first demand
      (see POST /leverage/case/{case_id}/settle)
    - Persists case snapshot to leverage.leverage_case_profiles
    - Emits case_opened event to leverage.leverage_case_events

    Billing service endpoint:
        POST /api/v1/billing/tenants/{tenant_id}/leverage/cases/open
    """
    billing = get_billing_service()
    billing_available = True
    leverage_unlocked = True   # Fail-open — always unlock
    is_overage = False
    overage_charge_usd = 0
    case_id_str = str(request.case_id)

    # 1. Check case limit and record the case-open charge
    try:
        limit_check = await billing.check_case_limit(request.tenant_id, request.user_id)
        is_overage = limit_check.get("is_overage", False)
        overage_charge_usd = limit_check.get("overage_charge_usd", 0)

        recorded = await billing.record_case_open(
            tenant_id=request.tenant_id,
            case_id=case_id_str,
            is_overage=is_overage,
            overage_charge_usd=overage_charge_usd,
        )
        leverage_unlocked = recorded or limit_check.get("can_open", True)

        if not limit_check.get("can_open", True):
            logger.warning(
                "leverage/case/open: access denied for tenant %s case %s",
                request.tenant_id, case_id_str,
            )
    except BillingServiceUnavailable:
        billing_available = False
        logger.warning(
            "leverage/case/open: billing unavailable for tenant %s — fail-open",
            request.tenant_id,
        )
    except Exception as exc:
        billing_available = False
        logger.warning(
            "leverage/case/open: unexpected billing error for %s — %s — fail-open",
            request.tenant_id, exc,
        )

    # 2. Look up estimated settlement window (from leverage_settlement_windows)
    estimated_settle_by = None
    _signals = request.signals
    incident_type_val = _signals.incident_type if _signals else None
    state_val = _signals.state.upper() if _signals and _signals.state else None

    if incident_type_val and state_val:
        try:
            window_row = db.execute(text("""
                SELECT estimated_days_to_settle
                FROM leverage.leverage_settlement_windows
                WHERE incident_type = :itype AND state = :st
            """), {"itype": incident_type_val, "st": state_val}).fetchone()

            if window_row:
                # Compute estimated_settle_by from incident_date + estimated_days
                incident_dt = None
                if _signals and _signals.incident_date:
                    incident_dt = (
                        _signals.incident_date
                        if isinstance(_signals.incident_date, date)
                        else date.fromisoformat(str(_signals.incident_date))
                    )
                if incident_dt:
                    from datetime import timedelta
                    estimated_settle_by = incident_dt + timedelta(days=window_row[0])
        except Exception as exc:
            logger.debug(
                "leverage/case/open: settlement window lookup failed for %s/%s — %s (non-fatal)",
                incident_type_val, state_val, exc,
            )

    # 4. Persist case profile snapshot to leverage schema (fail-open)
    try:
        s = request.signals
        # Upsert: if case already opened, update the snapshot
        db.execute(text("""
            INSERT INTO leverage.leverage_case_profiles (
                case_id, tenant_id,
                incident_type, incident_date, county, state,
                injury_category, medical_specials_band, policy_limit_band,
                insurer, liability_strength, litigation_stage,
                estimated_settle_by,
                mdm_snapshot_version, snapshot_source_event
            ) VALUES (
                :case_id, :tenant_id,
                :incident_type, :incident_date, :county, :state,
                :injury_category, :medical_specials_band, :policy_limit_band,
                :insurer, :liability_strength, :litigation_stage,
                :estimated_settle_by,
                1, 'case.opened'
            )
            ON CONFLICT (case_id, tenant_id) DO UPDATE SET
                incident_type         = EXCLUDED.incident_type,
                incident_date         = EXCLUDED.incident_date,
                county                = EXCLUDED.county,
                state                 = EXCLUDED.state,
                injury_category       = EXCLUDED.injury_category,
                medical_specials_band = EXCLUDED.medical_specials_band,
                policy_limit_band     = EXCLUDED.policy_limit_band,
                insurer               = EXCLUDED.insurer,
                liability_strength    = EXCLUDED.liability_strength,
                litigation_stage      = EXCLUDED.litigation_stage,
                estimated_settle_by   = EXCLUDED.estimated_settle_by,
                snapshot_source_event = 'case.opened',
                updated_at            = now()
        """), {
            "case_id":              str(request.case_id),
            "tenant_id":            request.tenant_id,
            "incident_type":        s.incident_type if s else None,
            "incident_date":        s.incident_date if s else None,
            "county":               s.county if s else None,
            "state":                s.state.upper() if s and s.state else None,
            "injury_category":      s.injury_category if s else None,
            "medical_specials_band": s.medical_specials_band if s else None,
            "policy_limit_band":    s.policy_limit_band if s else None,
            "insurer":              s.insurer if s else None,
            "liability_strength":   s.liability_strength.value if s and s.liability_strength else None,
            "litigation_stage":     s.litigation_stage.value if s and s.litigation_stage else None,
            "estimated_settle_by":  estimated_settle_by,
        })
        # 5. Emit case_opened event + settlement.window_set (if estimated)
        db.execute(text("""
            INSERT INTO leverage.leverage_case_events (
                case_id, tenant_id, event_type, event_source, payload, occurred_at
            ) VALUES (
                :case_id, :tenant_id, 'case_opened', 'portal',
                :payload, :occurred_at
            )
        """), {
            "case_id":     str(request.case_id),
            "tenant_id":   request.tenant_id,
            "payload":     json.dumps({"billing_available": billing_available, "leverage_unlocked": leverage_unlocked, "estimated_settle_by": estimated_settle_by.isoformat() if estimated_settle_by else None}),
            "occurred_at": datetime.now(timezone.utc),
        })

        # If we have an estimated window, emit a settlement.window_set event
        if estimated_settle_by:
            emitter = LeverageEventEmitter(
                tenant_id=request.tenant_id,
                case_id=case_id_str,
            )
            await emitter.emit("settlement.window_set", metadata={
                "incident_type": incident_type_val,
                "state": state_val,
                "estimated_settle_by": estimated_settle_by.isoformat(),
            })

        db.commit()
    except Exception as exc:
        db.rollback()
        logger.warning(
            "leverage/case/open: DB persist failed for %s/%s — %s (non-fatal)",
            request.tenant_id, case_id_str, exc,
        )

    logger.info(
        "leverage/case/open: case %s opened for tenant %s (billing_available=%s)",
        case_id_str, request.tenant_id, billing_available,
    )

    return CaseOpenResponse(
        success=True,
        case_id=case_id_str,
        tenant_id=request.tenant_id,
        leverage_unlocked=leverage_unlocked,
        billing_available=billing_available,
        is_overage=is_overage,
        overage_charge_usd=overage_charge_usd,
        estimated_settle_by=estimated_settle_by.isoformat() if estimated_settle_by else None,
        message=(
            "LEVERAGE unlocked for this case. "
            "Compliance Intelligence and Case Economics are now active."
            + (f" Estimated settlement by {estimated_settle_by.isoformat()}." if estimated_settle_by else "")
            + (f" Overage charge: ${overage_charge_usd}." if is_overage else "")
        ),
    )


# ===========================================================================
# GET /leverage/case/{case_id}/status
# ===========================================================================

class CaseStatusResponse(BaseModel):
    """
    Portal uses this to decide what to show:
      - leverage_unlocked=True  → show Compliance Intelligence tab
      - settle_unlocked         → show Settlement Intelligence tab
      - is_overage              → show overage charge info
    """
    tenant_id:             str
    case_id:               str   # UUID as string
    leverage_unlocked:     bool
    settle_unlocked:       bool
    billing_available:     bool
    is_overage:            bool  = False
    overage_charge_usd:    int   = 0


@router.get(
    "/{case_id}/status",
    response_model=CaseStatusResponse,
    status_code=status.HTTP_200_OK,
    summary="Return LEVERAGE billing status for a case",
)
async def get_case_status(case_id: UUID, tenant_id: str):
    """
    **LEVERAGE Case Status**

    Called by the Customer Portal to determine what intelligence tabs to show
    and whether to display "Run Validation" or "Unlock LEVERAGE".

    Fail-open: returns safe defaults if billing service unavailable.
    """
    billing = get_billing_service()
    billing_available = True
    leverage_unlocked = False
    settle_unlocked   = False
    is_overage        = False
    overage_charge_usd = 0
    case_id_str = str(case_id)

    try:
        status_data = await billing.get_case_status(tenant_id, case_id_str)
        leverage_unlocked = status_data.get("leverage_unlocked", False)
        settle_unlocked   = status_data.get("settle_unlocked", False)
        is_overage        = status_data.get("is_overage", False)
        overage_charge_usd = status_data.get("overage_charge_usd", 0)
    except BillingServiceUnavailable:
        billing_available = False
    except Exception as exc:
        billing_available = False
        logger.warning("leverage/case/status: error for %s/%s — %s", tenant_id, case_id_str, exc)

    # Reward credit balance is no longer tracked (v1 strategy: no credit system)
    return CaseStatusResponse(
        tenant_id=tenant_id,
        case_id=case_id_str,
        leverage_unlocked=leverage_unlocked,
        settle_unlocked=settle_unlocked,
        billing_available=billing_available,
    )


# ===========================================================================
# POST /leverage/case/{case_id}/compliance
# ===========================================================================

class ComplianceRequest(BaseModel):
    """
    Runs deterministic compliance signals for a case.

    No document upload required. Uses structured case signals only.
    This is the LEVERAGE Compliance Intelligence tab output.
    """
    tenant_id: str             = Field(..., description="Tenant UUID (Clerk org ID)")
    signals:   CaseSignals     = Field(..., description="Structured case signals")
    demand_letter_items: Optional[List[str]] = Field(
        None,
        description="Items present in demand letter (for completeness check). "
                    "Allowed: medical_summary, injury_description, liability_statement, "
                    "witness_statement, police_report, medical_records, lost_income_docs"
    )
    consume_reward: bool = Field(
        False,
        description="Deprecated — kept for backward compatibility. No longer consumed."
    )

    class Config:
        json_schema_extra = {
            "example": {
                "tenant_id": "org_2abc123",
                "signals": {
                    "incident_type": "slip_fall",
                    "incident_date": "2026-01-15",
                    "state": "FL",
                    "county": "Duval County",
                    "injury_category": "minor",
                    "liability_strength": "moderate",
                    "litigation_stage": "pre_suit",
                },
                "demand_letter_items": ["medical_summary", "injury_description"],
                "consume_reward": False,
            }
        }


class StatuteCheck(BaseModel):
    status:        str           # "safe" | "warning" | "critical" | "overdue" | "unknown"
    days_remaining: Optional[int]
    filing_deadline: Optional[date]
    note:          str


class DemandLetterCheck(BaseModel):
    status:         str           # "complete" | "incomplete" | "not_reviewed"
    present_items:  List[str]
    missing_items:  List[str]


class ComplianceFlag(BaseModel):
    flag:      str
    severity:  str               # "info" | "warning" | "critical"
    detail:    str


class ComplianceResponse(BaseModel):
    case_id:             str
    tenant_id:           str
    statute_check:       StatuteCheck
    demand_letter_check: DemandLetterCheck
    flags:               List[ComplianceFlag]
    reward_consumed:     bool  = False   # Deprecated — always False in v1
    billing_available:   bool
    validation_engine_version: str
    disclaimer:          str


# ── Demand-letter completeness ────────────────────────────────────────────────

_REQUIRED_DEMAND_ITEMS = {
    "medical_summary",
    "injury_description",
    "liability_statement",
}

_OPTIONAL_DEMAND_ITEMS = {
    "witness_statement",
    "police_report",
    "medical_records",
    "lost_income_docs",
}

# ── SOL lookup — reads from leverage.validation_rules (primary_state_sol authority) ──────────────────

def _get_sol_rule_from_db(state: str, db: Session) -> Optional[dict]:
    """
    Read the active primary_state_sol rule for a state from leverage.validation_rules.
    Returns the full validator_config dict so it can be stored in rules_snapshot.
    Returns None if no active rule exists for that state — caller emits sol_rule_missing flag.

    Rules in leverage.validation_rules are legal artifacts (READ ONLY from LEVERAGE).
    LEVERAGE must never INSERT, UPDATE, or DELETE rows in leverage.validation_rules.
    """
    try:
        row = db.execute(text("""
            SELECT id::text, validator_config, rule_version
            FROM leverage.validation_rules
            WHERE validator_config->>'authority_level' = 'primary_state_sol'
              AND jurisdiction_state = :state
              AND practice_area = 'personal_injury'
              AND is_active = TRUE
              AND deleted_at IS NULL
            ORDER BY created_at DESC
            LIMIT 1
        """), {"state": state.upper()}).fetchone()
        if row:
            config = dict(row[1]) if row[1] else {}
            config["_rule_id"] = row[0]
            config["_rule_version"] = row[2]
            return config
    except Exception as exc:
        logger.warning("_get_sol_rule_from_db: DB error for state %s — %s", state, exc)
    return None


def _compute_statute_check(
    signals: CaseSignals,
    db: Optional[Session] = None,
) -> tuple[StatuteCheck, Optional[dict]]:
    """
    Deterministic SOL check using the seeded primary_state_sol table.

    Returns:
        (StatuteCheck, sol_rule_dict | None)

    If state or incident_date is missing: returns (unknown, None).
    If DB rule is missing for the state:  returns statute_check with
        status=sol_rule_missing flag and None for the rule dict.
    sol_rule_dict is stored in rules_snapshot for legal defensibility.
    """
    if not signals.incident_date or not signals.state:
        return (
            StatuteCheck(
                status="unknown",
                days_remaining=None,
                filing_deadline=None,
                note="Incident date or state not provided. Cannot calculate statute window.",
            ),
            None,
        )

    state = signals.state.upper()
    sol_rule: Optional[dict] = None

    if db is not None:
        sol_rule = _get_sol_rule_from_db(state, db)

    if sol_rule is None:
        # No DB rule found — return sol_rule_missing, do NOT silently default to 2 years
        return (
            StatuteCheck(
                status="sol_rule_missing",
                days_remaining=None,
                filing_deadline=None,
                note=(
                    f"No active primary_state_sol rule found for state {state}. "
                    "Verify jurisdiction or contact support to seed the SOL table."
                ),
            ),
            None,
        )

    sol_years = sol_rule.get("sol_years") or (sol_rule.get("sol_days", 730) / 365)
    statute_text = sol_rule.get("statute", "")
    from datetime import timedelta
    deadline = signals.incident_date.replace(
        year=signals.incident_date.year + int(sol_years)
    )
    days_remaining = (deadline - date.today()).days

    if days_remaining < 0:
        stat = "overdue"
    elif days_remaining <= 30:
        stat = "critical"
    elif days_remaining <= 90:
        stat = "warning"
    else:
        stat = "safe"

    return (
        StatuteCheck(
            status=stat,
            days_remaining=days_remaining,
            filing_deadline=deadline,
            note=(
                f"{state} PI statute of limitations: {int(sol_years)} years "
                f"({statute_text}). Filing deadline: {deadline.isoformat()}."
            ),
        ),
        sol_rule,
    )



def _compute_demand_check(items: Optional[List[str]]) -> DemandLetterCheck:
    """Check demand letter completeness against required items."""
    if items is None:
        return DemandLetterCheck(
            status="not_reviewed",
            present_items=[],
            missing_items=list(_REQUIRED_DEMAND_ITEMS),
        )
    present = set(items)
    missing = list(_REQUIRED_DEMAND_ITEMS - present)
    return DemandLetterCheck(
        status="complete" if not missing else "incomplete",
        present_items=sorted(present & (_REQUIRED_DEMAND_ITEMS | _OPTIONAL_DEMAND_ITEMS)),
        missing_items=sorted(missing),
    )


def _compute_flags(signals: CaseSignals, sol: StatuteCheck, demand: DemandLetterCheck) -> List[ComplianceFlag]:
    """Generate deterministic compliance flags from structured signals."""
    flags: List[ComplianceFlag] = []

    # Statute urgency
    if sol.status == "overdue":
        flags.append(ComplianceFlag(
            flag="STATUTE_OVERDUE",
            severity="critical",
            detail="Filing deadline has passed. Immediate review required.",
        ))
    elif sol.status == "critical":
        flags.append(ComplianceFlag(
            flag="STATUTE_CRITICAL",
            severity="critical",
            detail=f"Filing deadline in {sol.days_remaining} days. Prioritize immediately.",
        ))
    elif sol.status == "warning":
        flags.append(ComplianceFlag(
            flag="STATUTE_WARNING",
            severity="warning",
            detail=f"Filing deadline in {sol.days_remaining} days.",
        ))
    elif sol.status == "sol_rule_missing":
        flags.append(ComplianceFlag(
            flag="SOL_RULE_MISSING",
            severity="warning",
            detail=sol.note or "No active SOL rule found for this state. Attorney must verify deadline manually.",
        ))

    # Demand letter completeness
    if demand.status == "incomplete":
        flags.append(ComplianceFlag(
            flag="DEMAND_LETTER_INCOMPLETE",
            severity="warning",
            detail=f"Missing: {', '.join(demand.missing_items)}.",
        ))

    # Liability signals
    if signals.liability_strength == LiabilityStrength.contested:
        flags.append(ComplianceFlag(
            flag="LIABILITY_CONTESTED",
            severity="warning",
            detail="Contested liability may reduce settlement range. Document exposure carefully.",
        ))
    elif signals.liability_strength == LiabilityStrength.unknown:
        flags.append(ComplianceFlag(
            flag="LIABILITY_UNKNOWN",
            severity="info",
            detail="Liability strength not yet assessed. Confirm before demand.",
        ))

    # Policy limit unknown
    if signals.policy_limit_band == "unknown" or signals.policy_limit_band is None:
        flags.append(ComplianceFlag(
            flag="POLICY_LIMIT_UNKNOWN",
            severity="info",
            detail="Policy limit unknown. Consider sending a policy limit demand letter.",
        ))

    # Insurer unknown
    if not signals.insurer or signals.insurer.lower() == "unknown":
        flags.append(ComplianceFlag(
            flag="INSURER_UNKNOWN",
            severity="info",
            detail="Insurer not identified. Negotiation pattern analysis unavailable until confirmed.",
        ))

    return flags


@router.post(
    "/{case_id}/compliance",
    response_model=ComplianceResponse,
    status_code=status.HTTP_200_OK,
    summary="Run LEVERAGE compliance intelligence signals for a case",
)
async def run_compliance(
    case_id: UUID,
    request: ComplianceRequest,
    db: Session = Depends(get_db),
):
    """
    **LEVERAGE Compliance Intelligence**

    Runs deterministic compliance checks on structured case signals:
    - Statute of limitations window (using seeded primary_state_sol table)
    - Demand letter completeness check
    - Liability and documentation risk flags

    No document upload required. Operates entirely on structured signals.
    This is the Compliance Intelligence section of the case file view.

    If `consume_reward=True` it is ignored in v1 (no credit system).
    Fail-open: billing errors never block the compliance output.
    Results are persisted to leverage.leverage_validation_results.
    """
    billing = get_billing_service()
    billing_available = True
    reward_consumed = False
    case_id_str = str(case_id)

    # consume_reward is deprecated — no credit system in v1
    # All compliance runs are included in the subscription tier

    # Run deterministic checks (always succeeds — no billing dependency)
    statute_check, sol_rule = _compute_statute_check(request.signals, db)
    demand_check             = _compute_demand_check(request.demand_letter_items)
    flags                    = _compute_flags(request.signals, statute_check, demand_check)

    # Build rules_snapshot (full rule artifacts for legal defensibility)
    rules_snapshot: dict = {}
    if sol_rule:
        rules_snapshot["sol_rule"] = sol_rule

    # Compute rules_version_hash from rule IDs present in this run
    rule_ids = sorted(filter(None, [sol_rule.get("_rule_id") if sol_rule else None]))
    rules_version_hash = (
        hashlib.sha256(",".join(rule_ids).encode()).hexdigest() if rule_ids else None
    )

    # Persist validation result (fail-open)
    try:
        # Determine next version number for this (case_id, tenant_id)
        row = db.execute(text("""
            SELECT COALESCE(MAX(version), 0) + 1
            FROM leverage.leverage_validation_results
            WHERE case_id = :case_id AND tenant_id = :tenant_id
        """), {"case_id": case_id_str, "tenant_id": request.tenant_id}).fetchone()
        next_version = row[0] if row else 1

        db.execute(text("""
            INSERT INTO leverage.leverage_validation_results (
                case_id, tenant_id, version,
                statute_status, days_remaining,
                demand_status, missing_items, flags,
                rules_snapshot, validation_engine_version, rules_version_hash,
                validated_at
            ) VALUES (
                :case_id, :tenant_id, :version,
                :statute_status, :days_remaining,
                :demand_status, :missing_items, :flags,
                :rules_snapshot, :engine_version, :rules_hash,
                :validated_at
            )
        """), {
            "case_id":         case_id_str,
            "tenant_id":       request.tenant_id,
            "version":         next_version,
            "statute_status":  statute_check.status,
            "days_remaining":  statute_check.days_remaining,
            "demand_status":   demand_check.status,
            "missing_items":   json.dumps(demand_check.missing_items),
            "flags":           json.dumps([f.model_dump() for f in flags]),
            "rules_snapshot":  json.dumps(rules_snapshot) if rules_snapshot else None,
            "engine_version":  VALIDATION_ENGINE_VERSION,
            "rules_hash":      rules_version_hash,
            "validated_at":    datetime.now(timezone.utc),
        })

        # Emit validation_run event (append-only)
        db.execute(text("""
            INSERT INTO leverage.leverage_case_events (
                case_id, tenant_id, event_type, event_source, payload, occurred_at
            ) VALUES (
                :case_id, :tenant_id, 'validation_run', 'portal',
                :payload, :occurred_at
            )
        """), {
            "case_id":     case_id_str,
            "tenant_id":   request.tenant_id,
            "payload":     json.dumps({
                "version":             next_version,
                "statute_status":      statute_check.status,
                "demand_status":       demand_check.status,
                "flag_count":          len(flags),
                "engine_version":      VALIDATION_ENGINE_VERSION,
                "reward_consumed":     reward_consumed,
            }),
            "occurred_at": datetime.now(timezone.utc),
        })
        db.commit()

        # ── Platform event emission (fire-and-forget) ───────────────────────
        emitter = LeverageEventEmitter(
            tenant_id=request.tenant_id,
            case_id=case_id_str,
        )
        # Emit statute.warning for critical/overdue SOL
        if statute_check.status in ("critical", "overdue"):
            await emitter.emit("statute.warning", metadata={
                "days_remaining": statute_check.days_remaining,
                "statute_status": statute_check.status,
                "version": next_version,
            })
            # ── Fire SOL urgency notification ─────────────────────────────
            notif_event = "deadline.overdue" if statute_check.status == "overdue" else "deadline.critical"
            notif_severity = "critical"
            notif_payload = {
                "case_id": case_id_str,
                "statute_status": statute_check.status,
                "days_remaining": statute_check.days_remaining,
                "filing_deadline": statute_check.filing_deadline.isoformat() if statute_check.filing_deadline else None,
                "note": statute_check.note,
                "version": next_version,
            }
            await fire_notification(
                tenant_id=request.tenant_id,
                event_type=notif_event,
                severity=notif_severity,
                payload=notif_payload,
                case_id=case_id_str,
                db=db,
            )

        # Emit compliance.cleared for safe status with no flags
        elif statute_check.status == "safe" and len(flags) == 0:
            await emitter.emit("compliance.cleared", metadata={
                "version": next_version,
            })

        # Fire compliance.flag_added notifications for critical flags
        critical_flags = [f for f in flags if f.severity == "critical"]
        if critical_flags:
            for flag in critical_flags:
                await fire_notification(
                    tenant_id=request.tenant_id,
                    event_type="compliance.flag_added",
                    severity="critical",
                    payload={
                        "case_id": case_id_str,
                        "flag": flag.flag,
                        "detail": flag.detail,
                        "version": next_version,
                    },
                    case_id=case_id_str,
                    db=db,
                )
        # Always emit validation_run for analytics
        await emitter.emit("compliance.validation_run", metadata={
            "version": next_version,
            "statute_status": statute_check.status,
            "demand_status": demand_check.status,
            "flag_count": len(flags),
            "reward_consumed": reward_consumed,
        })

    except Exception as exc:
        db.rollback()
        logger.warning(
            "leverage/case/compliance: DB persist failed for %s/%s — %s (non-fatal)",
            request.tenant_id, case_id_str, exc,
        )

    logger.info(
        "leverage/case/compliance: ran for tenant %s case %s — %d flags (reward_consumed=%s)",
        request.tenant_id, case_id_str, len(flags), reward_consumed,
    )

    return ComplianceResponse(
        case_id=case_id_str,
        tenant_id=request.tenant_id,
        statute_check=statute_check,
        demand_letter_check=demand_check,
        flags=flags,
        reward_consumed=reward_consumed,
        billing_available=billing_available,
        validation_engine_version=VALIDATION_ENGINE_VERSION,
        disclaimer=(
            "Compliance signals are generated from structured case data only. "
            "This is not legal advice. Attorney must verify all statutory deadlines "
            "and document requirements independently."
        ),
    )


# ===========================================================================
# POST /leverage/case/{case_id}/settle
# ===========================================================================

class SettlementRecordRequest(BaseModel):
    """
    Records a settlement outcome.

    Called when the attorney marks a case as Settled in the portal.
    Triggers:
      1. Council data capture prompt (if tenant is a council member)
      2. SETTLE intelligence network contribution (via SETTLE service — handled separately)
    """
    tenant_id:        str              = Field(..., description="Tenant UUID")
    settlement_amount: Optional[float] = Field(None, ge=0, description="Actual settlement amount (optional — not stored persistently)")
    settlement_band:  Optional[str]    = Field(None, description="Banded amount: 0-10k, 10-25k, 25-50k, 50-100k, 100-250k, 250k+")
    settlement_date:  Optional[date]   = Field(None, description="Date of settlement")
    insurer:          Optional[str]    = Field(None, description="Insurer name")
    litigation_stage: Optional[LitigationStage] = Field(None, description="Stage at time of settlement")
    signals:          Optional[CaseSignals]      = Field(None, description="Final case signals for intelligence network")
    # Negotiation recap (for the post-settlement insight card)
    estimated_median: Optional[float]  = Field(None, description="SETTLE median estimate shown to attorney")
    negotiation_rounds: Optional[int]  = Field(None, ge=0, description="Number of offer/counter rounds")

    class Config:
        json_schema_extra = {
            "example": {
                "tenant_id":          "3fa85f64-5717-4562-b3fc-2c963f66afa6",
                "settlement_amount":  16500,
                "settlement_band":    "10-25k",
                "settlement_date":    "2026-03-01",
                "insurer":            "State Farm",
                "litigation_stage":   "pre_suit",
                "estimated_median":   14500,
                "negotiation_rounds": 3,
            }
        }


class NegotiationRecap(BaseModel):
    """
    Post-settlement intelligence card shown to the attorney.
    Reinforces trust in the SETTLE model.
    """
    estimated_median:      Optional[float]
    actual_settlement:     Optional[float]
    outcome_vs_model_pct:  Optional[float]   # +14% means settled 14% above median
    outcome_label:         Optional[str]     # "Above estimate", "Within estimate", "Below estimate"
    negotiation_rounds:    Optional[int]


class SettlementRecordResponse(BaseModel):
    success:             bool
    case_id:             str
    tenant_id:           str
    reward_granted:      bool  = False   # Deprecated - always False in v1 (no credit system)
    council_prompt:      bool      # True = show council contribution prompt
    billing_available:   bool
    recap:               Optional[NegotiationRecap]
    message:             str


def _build_recap(
    estimated_median: Optional[float],
    actual: Optional[float],
    rounds: Optional[int],
) -> Optional[NegotiationRecap]:
    if estimated_median is None or actual is None:
        return None
    if estimated_median == 0:
        return None
    diff_pct = round((actual - estimated_median) / estimated_median * 100, 1)
    if diff_pct > 5:
        label = "Above estimate"
    elif diff_pct < -5:
        label = "Below estimate"
    else:
        label = "Within estimate"
    return NegotiationRecap(
        estimated_median=estimated_median,
        actual_settlement=actual,
        outcome_vs_model_pct=diff_pct,
        outcome_label=label,
        negotiation_rounds=rounds,
    )


@router.post(
    "/{case_id}/settle",
    response_model=SettlementRecordResponse,
    status_code=status.HTTP_200_OK,
    summary="Record settlement outcome and emit settlement_recorded event",
)
async def record_settlement(
    case_id: UUID,
    request: SettlementRecordRequest,
    db: Session = Depends(get_db),
):
    """
    **LEVERAGE Settlement Record**

    Called when the attorney marks a case as Settled.

    Actions triggered:
    1. `council_prompt=True` returned if case has enough signals for council contribution
    2. Negotiation recap computed (actual vs SETTLE model estimate)
    3. `settlement_recorded` event emitted to leverage.leverage_case_events

    The SETTLE intelligence network contribution is handled separately by the
    SETTLE service when the attorney confirms the council data capture prompt.

    Fail-open: billing errors never block the settlement recording.
    """
    billing = get_billing_service()
    billing_available = True
    case_id_str = str(case_id)

    # No reward credit in v1 — settlement recording is included in subscription

    # Council prompt: show if we have enough signals for a meaningful contribution
    s = request.signals
    council_prompt = bool(
        s and s.county and s.incident_type and s.injury_category
        and s.insurer and request.settlement_band
    )

    # Build negotiation recap
    recap = _build_recap(
        request.estimated_median,
        request.settlement_amount,
        request.negotiation_rounds,
    )

    # Enrich event payload with settlement details if available
    settlement_detail_data = {}
    try:
        detail_row = db.execute(text("""
            SELECT settlement_amount, settlement_band, settlement_method,
                   negotiation_rounds, demand_amount, first_offer_amount,
                   final_counter_amount, comparative_fault_pct,
                   council_contribution_consent, fingerprint_hash
            FROM leverage.leverage_settlement_details
            WHERE case_id = :cid AND tenant_id = :tid
        """), {"cid": case_id_str, "tid": request.tenant_id}).fetchone()
        if detail_row:
            settlement_detail_data = {
                "settlement_amount":     detail_row[0],
                "settlement_band":       detail_row[1],
                "settlement_method":     detail_row[2],
                "negotiation_rounds":    detail_row[3],
                "demand_amount":         detail_row[4],
                "first_offer_amount":    detail_row[5],
                "final_counter_amount":  detail_row[6],
                "comparative_fault_pct": detail_row[7],
                "council_contribution_consent": detail_row[8],
                "fingerprint_hash":      detail_row[9],
            }
    except Exception as exc:
        logger.debug("record_settlement: settlement detail enrichment failed — %s (non-fatal)", exc)

    # Emit settlement_recorded event (append-only, fail-open)
    try:
        db.execute(text("""
            INSERT INTO leverage.leverage_case_events (
                case_id, tenant_id, event_type, event_source, payload, occurred_at
            ) VALUES (
                :case_id, :tenant_id, 'settlement_recorded', 'portal',
                :payload, :occurred_at
            )
        """), {
            "case_id":     case_id_str,
            "tenant_id":   request.tenant_id,
            "payload":     json.dumps({
                "settlement_band":    request.settlement_band,
                "settlement_date":    request.settlement_date.isoformat() if request.settlement_date else None,
                "insurer":            request.insurer,
                "litigation_stage":   request.litigation_stage.value if request.litigation_stage else None,
                "council_prompt":     council_prompt,
                "reward_granted":     False,  # Deprecated — no credit system in v1
                "negotiation_rounds": request.negotiation_rounds,
                **settlement_detail_data,
            }),
            "occurred_at": datetime.now(timezone.utc),
        })
        db.commit()
    except Exception as exc:
        db.rollback()
        logger.warning(
            "leverage/case/settle: DB event persist failed for %s/%s — %s (non-fatal)",
            request.tenant_id, case_id_str, exc,
        )

    logger.info(
        "leverage/case/settle: case %s settled for tenant %s "
        "(council_prompt=%s)",
        case_id_str, request.tenant_id, council_prompt,
    )

    return SettlementRecordResponse(
        success=True,
        case_id=case_id_str,
        tenant_id=request.tenant_id,
        reward_granted=False,  # Deprecated — no credit system in v1
        council_prompt=council_prompt,
        billing_available=billing_available,
        recap=recap,
        message=(
            "Settlement recorded. "
            + ("Confirm settlement data for the intelligence network." if council_prompt else "")
        ),
    )


# ===========================================================================
# GET /leverage/case/{case_id}/history
# ===========================================================================

class HistoryEntry(BaseModel):
    """Single validation run in the history."""
    version: int = Field(..., description="Version number (auto-incremented per case)")
    statute_status: Optional[str] = Field(None, description="safe, warning, critical, overdue, unknown, sol_rule_missing")
    days_remaining: Optional[int] = Field(None, description="Days until SOL deadline")
    demand_status: Optional[str] = Field(None, description="complete, incomplete")
    missing_items: Optional[List[str]] = Field(None, description="Missing demand letter items")
    flags: Optional[List[dict]] = Field(None, description="Compliance flags from this run")
    validation_engine_version: Optional[str] = Field(None, description="Engine version at run time")
    validated_at: datetime = Field(..., description="When this validation was run")


class HistoryResponse(BaseModel):
    """Validation history for a case."""
    case_id: str
    tenant_id: str
    total_runs: int
    history: List[HistoryEntry]


@router.get(
    "/{case_id}/history",
    response_model=HistoryResponse,
    status_code=status.HTTP_200_OK,
    summary="Get validation history for a case",
)
async def get_validation_history(
    case_id: UUID,
    tenant_id: str,
    db: Session = Depends(get_db),
    limit: int = 20,
    offset: int = 0,
):
    """
    **LEVERAGE Validation History**

    Retrieves all compliance validation runs for a case, ordered by version.
    Each run is versioned and immutable — history is append-only.

    Query params:
        tenant_id: Required — tenant scope for multi-tenant isolation
        limit: Max results (default 20, max 100)
        offset: Pagination offset

    Returns:
        case_id, tenant_id, total_runs, and list of history entries.
    """
    case_id_str = str(case_id)

    # Clamp limit
    limit = min(max(limit, 1), 100)

    try:
        # Count total
        count_row = db.execute(text("""
            SELECT COUNT(*)
            FROM leverage.leverage_validation_results
            WHERE case_id = :case_id AND tenant_id = :tenant_id
        """), {"case_id": case_id_str, "tenant_id": tenant_id}).fetchone()
        total_runs = count_row[0] if count_row else 0

        # Fetch history
        rows = db.execute(text("""
            SELECT version, statute_status, days_remaining, demand_status,
                   missing_items, flags, validation_engine_version, validated_at
            FROM leverage.leverage_validation_results
            WHERE case_id = :case_id AND tenant_id = :tenant_id
            ORDER BY version DESC
            LIMIT :limit OFFSET :offset
        """), {
            "case_id": case_id_str,
            "tenant_id": tenant_id,
            "limit": limit,
            "offset": offset,
        }).fetchall()

        history = [
            HistoryEntry(
                version=row[0],
                statute_status=row[1],
                days_remaining=row[2],
                demand_status=row[3],
                missing_items=json.loads(row[4]) if row[4] else None,
                flags=json.loads(row[5]) if row[5] else None,
                validation_engine_version=row[6],
                validated_at=row[7],
            )
            for row in rows
        ]

    except Exception as exc:
        logger.warning(
            "leverage/case/history: DB query failed for %s/%s — %s",
            tenant_id, case_id_str, exc,
        )
        # Return empty history on error (fail-open)
        return HistoryResponse(
            case_id=case_id_str,
            tenant_id=tenant_id,
            total_runs=0,
            history=[],
        )

    return HistoryResponse(
        case_id=case_id_str,
        tenant_id=tenant_id,
        total_runs=total_runs,
        history=history,
    )


# ===========================================================================
# GET /leverage/cases — List all cases for a tenant
# ===========================================================================

class CaseListItem(BaseModel):
    """A single case in the tenant's case list."""
    case_id: str
    tenant_id: str
    incident_type: Optional[str] = None
    state: Optional[str] = None
    injury_category: Optional[str] = None
    litigation_stage: Optional[str] = None
    leverage_unlocked: bool = False
    latest_compliance_status: Optional[str] = None
    latest_compliance_days_remaining: Optional[int] = None
    created_at: Optional[str] = None
    updated_at: Optional[str] = None


class CaseListResponse(BaseModel):
    """Paginated list of cases for a tenant."""
    tenant_id: str
    cases: List[CaseListItem]
    total_cases: int
    limit: int
    offset: int


@router.get(
    "s",
    response_model=CaseListResponse,
    summary="List all LEVERAGE cases for a tenant",
)
async def list_cases(
    tenant_id: str,
    db: Session = Depends(get_db),
    litigation_stage: Optional[str] = None,
    state: Optional[str] = None,
    limit: int = 20,
    offset: int = 0,
):
    """
    **LEVERAGE Case List**

    Returns all cases opened in the LEVERAGE pillar for a tenant.
    Supports filtering by litigation_stage and state.
    Called by the Customer Portal to display the case browser.
    """
    limit = min(max(limit, 1), 100)
    offset = max(offset, 0)

    try:
        # Build query with optional filters
        where_clauses = ["cp.tenant_id = :tid"]
        params = {"tid": tenant_id}

        if litigation_stage:
            where_clauses.append("cp.litigation_stage = :stage")
            params["stage"] = litigation_stage
        if state:
            where_clauses.append("cp.state = :st")
            params["st"] = state.upper()

        where_sql = " AND ".join(where_clauses)

        # Count total
        count_row = db.execute(
            text(f"SELECT COUNT(*) FROM leverage.leverage_case_profiles cp WHERE {where_sql}"),
            params,
        ).fetchone()
        total = count_row[0] if count_row else 0

        # Fetch cases with latest compliance status
        rows = db.execute(text(f"""
            SELECT cp.case_id, cp.tenant_id, cp.incident_type, cp.state,
                   cp.injury_category, cp.litigation_stage,
                   cp.created_at, cp.updated_at,
                   vr.statute_status, vr.days_remaining
            FROM leverage.leverage_case_profiles cp
            LEFT JOIN LATERAL (
                SELECT statute_status, days_remaining
                FROM leverage.leverage_validation_results vr
                WHERE vr.case_id = cp.case_id AND vr.tenant_id = cp.tenant_id
                ORDER BY version DESC LIMIT 1
            ) vr ON true
            WHERE {where_sql}
            ORDER BY cp.updated_at DESC
            LIMIT :lim OFFSET :off
        """), {**params, "lim": limit, "off": offset}).fetchall()

        # Check leverage_unlocked by seeing if the case has a profile (it was opened)
        cases = [
            CaseListItem(
                case_id=str(row[0]),
                tenant_id=row[1],
                incident_type=row[2],
                state=row[3],
                injury_category=row[4],
                litigation_stage=row[5],
                leverage_unlocked=True,  # If it has a profile, it was opened
                latest_compliance_status=row[8],
                latest_compliance_days_remaining=row[9],
                created_at=row[6].isoformat() if row[6] else None,
                updated_at=row[7].isoformat() if row[7] else None,
            )
            for row in rows
        ]

    except Exception as exc:
        logger.warning("leverage/cases: DB error for %s — %s", tenant_id, exc)
        return CaseListResponse(tenant_id=tenant_id, cases=[], total_cases=0, limit=limit, offset=offset)

    return CaseListResponse(
        tenant_id=tenant_id,
        cases=cases,
        total_cases=total,
        limit=limit,
        offset=offset,
    )


# ===========================================================================
# GET /leverage/case/{case_id}/events — Timeline / Activity Feed
# ===========================================================================

class CaseEventEntry(BaseModel):
    """A single event in the case timeline."""
    id: str
    case_id: str
    tenant_id: str
    event_type: str
    event_source: Optional[str] = None
    payload: Optional[dict] = None
    occurred_at: Optional[str] = None
    recorded_at: Optional[str] = None


class CaseEventsResponse(BaseModel):
    """Timeline / activity feed for a case."""
    case_id: str
    tenant_id: str
    events: List[CaseEventEntry]
    total_events: int


@router.get(
    "/{case_id}/events",
    response_model=CaseEventsResponse,
    summary="Timeline / activity feed for a case",
)
async def get_case_events(
    case_id: UUID,
    tenant_id: str,
    db: Session = Depends(get_db),
    limit: int = 50,
    offset: int = 0,
):
    """
    **LEVERAGE Case Timeline**

    Returns the append-only event log for a case.
    Events include: case_snapshot_updated, validation_run, settlement_recorded.
    Called by the Customer Portal to display the case activity feed.
    """
    case_id_str = str(case_id)
    limit = min(max(limit, 1), 200)
    offset = max(offset, 0)

    try:
        # Count total
        count_row = db.execute(text("""
            SELECT COUNT(*) FROM leverage.leverage_case_events
            WHERE case_id = :cid AND tenant_id = :tid
        """), {"cid": case_id_str, "tid": tenant_id}).fetchone()
        total = count_row[0] if count_row else 0

        # Fetch events
        rows = db.execute(text("""
            SELECT id, case_id, tenant_id, event_type, event_source, payload,
                   occurred_at, recorded_at
            FROM leverage.leverage_case_events
            WHERE case_id = :cid AND tenant_id = :tid
            ORDER BY occurred_at DESC
            LIMIT :lim OFFSET :off
        """), {"cid": case_id_str, "tid": tenant_id, "lim": limit, "off": offset}).fetchall()

        events = []
        for row in rows:
            payload = row[5]
            if isinstance(payload, str):
                import json
                payload = json.loads(payload)
            events.append(CaseEventEntry(
                id=str(row[0]),
                case_id=str(row[1]),
                tenant_id=row[2],
                event_type=row[3],
                event_source=row[4],
                payload=payload,
                occurred_at=row[6].isoformat() if row[6] else None,
                recorded_at=row[7].isoformat() if row[7] else None,
            ))

    except Exception as exc:
        logger.warning("leverage/case/events: DB error for %s/%s — %s", tenant_id, case_id_str, exc)
        return CaseEventsResponse(case_id=case_id_str, tenant_id=tenant_id, events=[], total_events=0)

    return CaseEventsResponse(
        case_id=case_id_str,
        tenant_id=tenant_id,
        events=events,
        total_events=total,
    )


# ===========================================================================
# GET /leverage/case/{case_id}/detail — Combined case detail
# ===========================================================================

class CaseDetailResponse(BaseModel):
    """Combined case detail for portal display."""
    case_id: str
    tenant_id: str
    # From case profile
    incident_type: Optional[str] = None
    state: Optional[str] = None
    injury_category: Optional[str] = None
    litigation_stage: Optional[str] = None
    insurer: Optional[str] = None
    # From billing status
    leverage_unlocked: bool = False
    active_reward_credits: int = 0
    settle_unlocked: bool = False
    # Latest compliance
    latest_compliance_status: Optional[str] = None
    latest_compliance_days_remaining: Optional[int] = None
    latest_compliance_flags_count: int = 0
    latest_compliance_run_at: Optional[str] = None
    # Counts
    total_compliance_runs: int = 0
    total_events: int = 0
    # Saved economics
    has_saved_damages: bool = False
    has_saved_disbursement: bool = False
    latest_damages_gross: Optional[float] = None
    latest_disbursement_total: Optional[float] = None
    # Timestamps
    created_at: Optional[str] = None
    updated_at: Optional[str] = None


@router.get(
    "/{case_id}/detail",
    response_model=CaseDetailResponse,
    summary="Combined case detail for portal display",
)
async def get_case_detail(
    case_id: UUID,
    tenant_id: str,
    db: Session = Depends(get_db),
):
    """
    **LEVERAGE Case Detail**

    Returns a combined view of case status, latest compliance, saved economics,
    and event counts. This is the single endpoint the Customer Portal needs
    to render the case detail page.

    Aggregates data from:
    - leverage_case_profiles (case snapshot)
    - leverage_validation_results (latest compliance)
    - leverage_case_events (event count)
    - leverage_damages_worksheets (saved damages)
    - leverage_disbursement_worksheets (saved disbursements)
    """
    case_id_str = str(case_id)

    try:
        # Case profile
        profile = db.execute(text("""
            SELECT incident_type, state, injury_category, litigation_stage, insurer,
                   created_at, updated_at
            FROM leverage.leverage_case_profiles
            WHERE case_id = :cid AND tenant_id = :tid
        """), {"cid": case_id_str, "tid": tenant_id}).fetchone()

        if not profile:
            from fastapi import HTTPException
            raise HTTPException(status_code=404, detail="Case not found in LEVERAGE")

        # Latest compliance
        compliance = db.execute(text("""
            SELECT statute_status, days_remaining, flags, validated_at
            FROM leverage.leverage_validation_results
            WHERE case_id = :cid AND tenant_id = :tid
            ORDER BY version DESC LIMIT 1
        """), {"cid": case_id_str, "tid": tenant_id}).fetchone()

        # Total compliance runs
        runs_count = db.execute(text("""
            SELECT COUNT(*) FROM leverage.leverage_validation_results
            WHERE case_id = :cid AND tenant_id = :tid
        """), {"cid": case_id_str, "tid": tenant_id}).fetchone()
        total_runs = runs_count[0] if runs_count else 0

        # Total events
        events_count = db.execute(text("""
            SELECT COUNT(*) FROM leverage.leverage_case_events
            WHERE case_id = :cid AND tenant_id = :tid
        """), {"cid": case_id_str, "tid": tenant_id}).fetchone()
        total_events = events_count[0] if events_count else 0

        # Latest saved damages
        damages_row = db.execute(text("""
            SELECT result_json FROM leverage.leverage_damages_worksheets
            WHERE case_id = :cid AND tenant_id = :tid
            ORDER BY version DESC LIMIT 1
        """), {"cid": case_id_str, "tid": tenant_id}).fetchone()

        has_saved_damages = damages_row is not None
        latest_damages_gross = None
        if damages_row:
            import json
            dr = json.loads(damages_row[0]) if isinstance(damages_row[0], str) else (damages_row[0] or {})
            latest_damages_gross = dr.get("gross_damages")

        # Latest saved disbursement
        disb_row = db.execute(text("""
            SELECT result_json FROM leverage.leverage_disbursement_worksheets
            WHERE case_id = :cid AND tenant_id = :tid
            ORDER BY version DESC LIMIT 1
        """), {"cid": case_id_str, "tid": tenant_id}).fetchone()

        has_saved_disbursement = disb_row is not None
        latest_disbursement_total = None
        if disb_row:
            import json
            dr = json.loads(disb_row[0]) if isinstance(disb_row[0], str) else (disb_row[0] or {})
            latest_disbursement_total = dr.get("total_disbursements")

        # Compliance flags count
        flags_count = 0
        if compliance and compliance[2]:
            import json
            flags_data = json.loads(compliance[2]) if isinstance(compliance[2], str) else compliance[2]
            flags_count = len(flags_data) if isinstance(flags_data, list) else 0

        # Reward balance
        active_credits = 0
        try:
            billing = get_billing_service()
            active_credits = await billing.get_active_reward_count(tenant_id)
        except Exception:
            pass

        return CaseDetailResponse(
            case_id=case_id_str,
            tenant_id=tenant_id,
            incident_type=profile[0],
            state=profile[1],
            injury_category=profile[2],
            litigation_stage=profile[3],
            insurer=profile[4],
            leverage_unlocked=True,
            active_reward_credits=active_credits,
            settle_unlocked=False,  # Would need SETTLE service integration
            latest_compliance_status=compliance[0] if compliance else None,
            latest_compliance_days_remaining=compliance[1] if compliance else None,
            latest_compliance_flags_count=flags_count,
            latest_compliance_run_at=compliance[3].isoformat() if compliance and compliance[3] else None,
            total_compliance_runs=total_runs,
            total_events=total_events,
            has_saved_damages=has_saved_damages,
            has_saved_disbursement=has_saved_disbursement,
            latest_damages_gross=latest_damages_gross,
            latest_disbursement_total=latest_disbursement_total,
            created_at=profile[5].isoformat() if profile[5] else None,
            updated_at=profile[6].isoformat() if profile[6] else None,
        )

    except Exception as exc:
        if isinstance(exc, Exception) and hasattr(exc, 'status_code') and exc.status_code == 404:
            raise
        logger.warning("leverage/case/detail: error for %s/%s — %s", tenant_id, case_id_str, exc)
        raise


# ===========================================================================
# GET /leverage/analytics — Tenant-level LEVERAGE analytics
# ===========================================================================

class TenantAnalyticsResponse(BaseModel):
    """Tenant-level LEVERAGE analytics for portal dashboard."""
    tenant_id: str
    # Case counts
    total_cases: int = 0
    active_cases: int = 0
    settled_cases: int = 0
    # Compliance
    total_compliance_runs: int = 0
    avg_compliance_flags_per_case: float = 0.0
    compliance_health_score: float = 0.0
    # Reward credits
    total_credits_granted: int = 0
    total_credits_used: int = 0
    total_credits_expired: int = 0
    active_credits: int = 0
    # Economics
    total_damages_calculated: float = 0.0
    average_case_value: float = 0.0
    # Deadlines
    upcoming_critical_deadlines: int = 0
    # Timestamp
    calculated_at: Optional[str] = None


@router.get(
    "/../analytics",
    response_model=TenantAnalyticsResponse,
    summary="Tenant-level LEVERAGE analytics",
)
async def get_tenant_analytics(
    tenant_id: str,
    db: Session = Depends(get_db),
):
    """
    **LEVERAGE Tenant Analytics**

    Returns aggregate metrics across all LEVERAGE cases for a tenant.
    Called by the Customer Portal to display the LEVERAGE dashboard card.

    Aggregates from:
    - leverage_case_profiles (case counts by stage)
    - leverage_validation_results (compliance runs, flags)
    - leverage_reward_ledger (credit breakdown)
    - leverage_damages_worksheets (case values)
    - leverage_case_deadlines (upcoming critical deadlines)
    """
    from datetime import datetime

    try:
        # Case counts
        case_rows = db.execute(text("""
            SELECT
                COUNT(*) as total,
                COUNT(*) FILTER (WHERE litigation_stage NOT IN ('settled', 'closed')) as active,
                COUNT(*) FILTER (WHERE litigation_stage = 'settled') as settled
            FROM leverage.leverage_case_profiles
            WHERE tenant_id = :tid
        """), {"tid": tenant_id}).fetchone()

        total_cases = int(case_rows[0] or 0) if case_rows else 0
        active_cases = int(case_rows[1] or 0) if case_rows else 0
        settled_cases = int(case_rows[2] or 0) if case_rows else 0

        # Compliance runs
        compliance_row = db.execute(text("""
            SELECT COUNT(DISTINCT (case_id, tenant_id)) as cases_with_runs,
                   COUNT(*) as total_runs
            FROM leverage.leverage_validation_results
            WHERE tenant_id = :tid
        """), {"tid": tenant_id}).fetchone()

        total_compliance_runs = int(compliance_row[1] or 0) if compliance_row else 0
        cases_with_runs = int(compliance_row[0] or 0) if compliance_row else 0

        # Average compliance flags per case
        flags_row = db.execute(text("""
            SELECT AVG(flag_count) FROM (
                SELECT jsonb_array_length(flags) as flag_count
                FROM leverage.leverage_validation_results
                WHERE tenant_id = :tid AND flags IS NOT NULL
                  AND flags != 'null'::jsonb
                  AND flags != '[]'::jsonb
            ) sub
        """), {"tid": tenant_id}).fetchone()
        avg_flags = float(flags_row[0] or 0) if flags_row else 0.0

        # Compliance health score: 100 - (avg_flags * 10), clamped to 0-100
        compliance_health_score = max(0.0, min(100.0, 100.0 - (avg_flags * 10)))

        # Reward credits
        reward_rows = db.execute(text("""
            SELECT status, COALESCE(SUM(credits), 0) as total
            FROM leverage.leverage_reward_ledger
            WHERE tenant_id = :tid
            GROUP BY status
        """), {"tid": tenant_id}).fetchall()

        total_granted = 0
        total_used = 0
        total_expired = 0
        active_credits = 0

        for row in reward_rows:
            s, c = row[0], int(row[1] or 0)
            if s == "active":
                active_credits = c
                total_granted += c
            elif s == "used":
                total_used += c
                total_granted += c
            elif s == "expired":
                total_expired = c
                total_granted += c

        # Also count consumed entries
        consumed_row = db.execute(text("""
            SELECT COALESCE(SUM(ABS(credits)), 0)
            FROM leverage.leverage_reward_ledger
            WHERE tenant_id = :tid AND source = 'consumed'
        """), {"tid": tenant_id}).fetchone()
        if consumed_row and consumed_row[0]:
            total_used = max(total_used, int(consumed_row[0]))

        # Economics - total damages calculated
        damages_row = db.execute(text("""
            SELECT COALESCE(SUM((result_json->>'gross_damages')::numeric), 0),
                   COUNT(DISTINCT (case_id, tenant_id))
            FROM leverage.leverage_damages_worksheets
            WHERE tenant_id = :tid
              AND result_json->>'gross_damages' IS NOT NULL
        """), {"tid": tenant_id}).fetchone()

        total_damages_calculated = float(damages_row[0] or 0) if damages_row else 0.0
        cases_with_damages = int(damages_row[1] or 0) if damages_row else 0

        # Average case value
        average_case_value = (
            round(total_damages_calculated / cases_with_damages, 2)
            if cases_with_damages > 0 else 0.0
        )

        # Upcoming critical deadlines (CRITICAL or OVERDUE)
        critical_row = db.execute(text("""
            SELECT COUNT(*)
            FROM leverage.leverage_case_deadlines
            WHERE tenant_id = :tid
              AND urgency IN ('CRITICAL', 'OVERDUE')
        """), {"tid": tenant_id}).fetchone()
        upcoming_critical = int(critical_row[0] or 0) if critical_row else 0

    except Exception as exc:
        logger.warning("leverage/analytics: DB error for %s — %s", tenant_id, exc)
        return TenantAnalyticsResponse(tenant_id=tenant_id)

    return TenantAnalyticsResponse(
        tenant_id=tenant_id,
        total_cases=total_cases,
        active_cases=active_cases,
        settled_cases=settled_cases,
        total_compliance_runs=total_compliance_runs,
        avg_compliance_flags_per_case=round(avg_flags, 1),
        compliance_health_score=round(compliance_health_score, 1),
        total_credits_granted=total_granted,
        total_credits_used=total_used,
        total_credits_expired=total_expired,
        active_credits=active_credits,
        total_damages_calculated=round(total_damages_calculated, 2),
        average_case_value=average_case_value,
        upcoming_critical_deadlines=upcoming_critical,
        calculated_at=datetime.now().isoformat(),
    )


# ===========================================================================
# FEATURE C: SETTLEMENT DETAIL CAPTURE + NUDGE
# ===========================================================================

class SettlementDetailRequest(BaseModel):
    """Full settlement detail capture form for the Customer Portal."""
    tenant_id: str = Field(..., description="Tenant UUID (Clerk org ID)")
    # Settlement outcome
    settlement_amount: Optional[float] = Field(None, ge=0, description="Actual settlement amount")
    settlement_band: Optional[str] = Field(None, description="0-10k | 10-25k | 25-50k | 50-100k | 100-250k | 250k+")
    settlement_date: Optional[date] = Field(None, description="Date of settlement")
    settlement_method: Optional[str] = Field(None, description="pre_suit_negotiation | mediation | arbitration | trial_verdict | other")
    # Case context
    insurer: Optional[str] = Field(None, description="Insurer name")
    adjuster_name: Optional[str] = Field(None, description="Adjuster name (for intelligence network)")
    litigation_stage: Optional[str] = Field(None, description="pre_suit | suit_filed | mediation | trial")
    negotiation_rounds: Optional[int] = Field(None, ge=0)
    demand_amount: Optional[float] = Field(None, ge=0, description="Initial demand amount")
    first_offer_amount: Optional[float] = Field(None, ge=0, description="Insurer's first offer")
    final_counter_amount: Optional[float] = Field(None, ge=0, description="Final counter before settlement")
    # Legal context
    comparative_fault_pct: Optional[float] = Field(None, ge=0, le=100, description="Plaintiff's % fault")
    policy_limit: Optional[float] = Field(None, ge=0)
    medical_specials_total: Optional[float] = Field(None, ge=0)
    lost_wages_total: Optional[float] = Field(None, ge=0)
    # Attorney assessment
    outcome_satisfaction: Optional[str] = Field(None, description="satisfied | neutral | dissatisfied")
    key_factors: Optional[str] = Field(None, description="Freeform key factors")
    # Intelligence network
    council_contribution_consent: bool = Field(False, description="Attorney consents to anonymous data sharing")

    class Config:
        json_schema_extra = {
            "example": {
                "settlement_amount": 16500,
                "settlement_band": "10-25k",
                "settlement_date": "2026-03-01",
                "settlement_method": "pre_suit_negotiation",
                "insurer": "State Farm",
                "litigation_stage": "pre_suit",
                "negotiation_rounds": 3,
                "demand_amount": 35000,
                "first_offer_amount": 8000,
                "final_counter_amount": 15000,
                "comparative_fault_pct": 0,
                "medical_specials_total": 12000,
                "lost_wages_total": 3000,
                "outcome_satisfaction": "satisfied",
                "key_factors": "Strong liability, clear causation",
                "council_contribution_consent": True,
            }
        }


class SettlementDetailResponse(BaseModel):
    success: bool
    case_id: str
    tenant_id: str
    council_contribution_consent: bool
    fingerprint_hash: Optional[str] = None
    message: str


class SettlementDetailRetrieveResponse(BaseModel):
    case_id: str
    tenant_id: str
    settlement_amount: Optional[float] = None
    settlement_band: Optional[str] = None
    settlement_date: Optional[date] = None
    settlement_method: Optional[str] = None
    insurer: Optional[str] = None
    adjuster_name: Optional[str] = None
    litigation_stage: Optional[str] = None
    negotiation_rounds: Optional[int] = None
    demand_amount: Optional[float] = None
    first_offer_amount: Optional[float] = None
    final_counter_amount: Optional[float] = None
    comparative_fault_pct: Optional[float] = None
    policy_limit: Optional[float] = None
    medical_specials_total: Optional[float] = None
    lost_wages_total: Optional[float] = None
    outcome_satisfaction: Optional[str] = None
    key_factors: Optional[str] = None
    council_contribution_consent: bool = False
    nudge_sent_at: Optional[str] = None
    captured_at: Optional[str] = None
    created_at: Optional[str] = None
    updated_at: Optional[str] = None


class NudgePendingCase(BaseModel):
    case_id: str
    tenant_id: str
    incident_type: Optional[str] = None
    state: Optional[str] = None
    estimated_settle_by: Optional[str] = None
    days_past_estimate: int = 0
    opened_at: Optional[str] = None


class NudgePendingResponse(BaseModel):
    tenant_id: str
    cases: List[NudgePendingCase]
    total_pending: int


class NudgeResponse(BaseModel):
    success: bool
    case_id: str
    tenant_id: str
    notification_sent: bool
    message: str


@router.put(
    "/{case_id}/settlement-details",
    response_model=SettlementDetailResponse,
    summary="Capture full settlement details for a case",
)
async def capture_settlement_details(
    case_id: UUID,
    request: SettlementDetailRequest,
    db: Session = Depends(get_db),
):
    """
    **Capture Settlement Details**

    Attorneys submit detailed settlement data after a case settles.
    This enriches the basic `record_settlement` with negotiation context,
    legal details, and attorney assessment.

    If `council_contribution_consent=True`, the data is shared anonymously
    with the SETTLE intelligence network via event emission.

    Upsert: if details already exist for this case, they are updated.
    """
    from app.services.billing_service import build_case_fingerprint

    case_id_str = str(case_id)
    fingerprint_hash = None

    # Build fingerprint hash if consent given and enough data
    if request.council_contribution_consent and request.settlement_band:
        settlement_month = (request.settlement_date.strftime("%Y-%m")
                           if request.settlement_date else None)
        fingerprint_hash = build_case_fingerprint(
            county=None,  # Would need case profile data
            incident_type=None,  # Would need case profile data
            injury_category=None,
            insurer=request.insurer,
            settlement_band=request.settlement_band,
            settlement_month=settlement_month,
        )

    try:
        # Upsert settlement details
        db.execute(text("""
            INSERT INTO leverage.leverage_settlement_details (
                case_id, tenant_id,
                settlement_amount, settlement_band, settlement_date, settlement_method,
                insurer, adjuster_name, litigation_stage, negotiation_rounds,
                demand_amount, first_offer_amount, final_counter_amount,
                comparative_fault_pct, policy_limit,
                medical_specials_total, lost_wages_total,
                outcome_satisfaction, key_factors,
                council_contribution_consent, fingerprint_hash,
                captured_at
            ) VALUES (
                :cid, :tid,
                :amt, :band, :sdate, :smethod,
                :ins, :adj, :lstg, :nrounds,
                :dem, :foffer, :fcounter,
                :cfpct, :plim,
                :medspec, :loswages,
                :sat, :kfactors,
                :consent, :fhash,
                :captured
            )
            ON CONFLICT (case_id, tenant_id) DO UPDATE SET
                settlement_amount = EXCLUDED.settlement_amount,
                settlement_band = EXCLUDED.settlement_band,
                settlement_date = EXCLUDED.settlement_date,
                settlement_method = EXCLUDED.settlement_method,
                insurer = EXCLUDED.insurer,
                adjuster_name = EXCLUDED.adjuster_name,
                litigation_stage = EXCLUDED.litigation_stage,
                negotiation_rounds = EXCLUDED.negotiation_rounds,
                demand_amount = EXCLUDED.demand_amount,
                first_offer_amount = EXCLUDED.first_offer_amount,
                final_counter_amount = EXCLUDED.final_counter_amount,
                comparative_fault_pct = EXCLUDED.comparative_fault_pct,
                policy_limit = EXCLUDED.policy_limit,
                medical_specials_total = EXCLUDED.medical_specials_total,
                lost_wages_total = EXCLUDED.lost_wages_total,
                outcome_satisfaction = EXCLUDED.outcome_satisfaction,
                key_factors = EXCLUDED.key_factors,
                council_contribution_consent = EXCLUDED.council_contribution_consent,
                fingerprint_hash = EXCLUDED.fingerprint_hash,
                captured_at = EXCLUDED.captured_at,
                updated_at = now()
        """), {
            "cid": case_id_str,
            "tid": request.tenant_id,
            "amt": request.settlement_amount,
            "band": request.settlement_band,
            "sdate": request.settlement_date,
            "smethod": request.settlement_method,
            "ins": request.insurer,
            "adj": request.adjuster_name,
            "lstg": request.litigation_stage,
            "nrounds": request.negotiation_rounds,
            "dem": request.demand_amount,
            "foffer": request.first_offer_amount,
            "fcounter": request.final_counter_amount,
            "cfpct": request.comparative_fault_pct,
            "plim": request.policy_limit,
            "medspec": request.medical_specials_total,
            "loswages": request.lost_wages_total,
            "sat": request.outcome_satisfaction,
            "kfactors": request.key_factors,
            "consent": request.council_contribution_consent,
            "fhash": fingerprint_hash,
            "captured": datetime.now(timezone.utc),
        })

        # Emit enriched settlement_recorded event (for SETTLE to consume)
        emitter = LeverageEventEmitter(
            tenant_id=request.tenant_id,
            case_id=case_id_str,
        )
        await emitter.emit("settlement.details_captured", metadata={
            "case_id": case_id_str,
            "council_contribution_consent": request.council_contribution_consent,
            "settlement_band": request.settlement_band,
            "settlement_method": request.settlement_method,
            "fingerprint_hash": fingerprint_hash,
        })

        db.commit()

    except Exception as exc:
        db.rollback()
        logger.error("capture_settlement_details: DB error for %s — %s", case_id_str, exc)
        raise HTTPException(status_code=500, detail="Failed to save settlement details")

    return SettlementDetailResponse(
        success=True,
        case_id=case_id_str,
        tenant_id=request.tenant_id,
        council_contribution_consent=request.council_contribution_consent,
        fingerprint_hash=fingerprint_hash,
        message=(
            "Settlement details captured. "
            + ("Council contribution consent granted — data will be shared anonymously with the intelligence network. "
                if request.council_contribution_consent else "")
        ),
    )


@router.get(
    "/{case_id}/settlement-details",
    response_model=SettlementDetailRetrieveResponse,
    summary="Retrieve settlement details for a case",
)
async def get_settlement_details(
    case_id: UUID,
    tenant_id: str,
    db: Session = Depends(get_db),
):
    """Retrieve the captured settlement details for a case."""
    case_id_str = str(case_id)

    try:
        row = db.execute(text("""
            SELECT case_id, tenant_id,
                   settlement_amount, settlement_band, settlement_date, settlement_method,
                   insurer, adjuster_name, litigation_stage, negotiation_rounds,
                   demand_amount, first_offer_amount, final_counter_amount,
                   comparative_fault_pct, policy_limit,
                   medical_specials_total, lost_wages_total,
                   outcome_satisfaction, key_factors,
                   council_contribution_consent,
                   nudge_sent_at, captured_at, created_at, updated_at
            FROM leverage.leverage_settlement_details
            WHERE case_id = :cid AND tenant_id = :tid
        """), {"cid": case_id_str, "tid": tenant_id}).fetchone()

        if not row:
            return SettlementDetailRetrieveResponse(
                case_id=case_id_str,
                tenant_id=tenant_id,
            )

        return SettlementDetailRetrieveResponse(
            case_id=str(row[0]),
            tenant_id=row[1],
            settlement_amount=row[2],
            settlement_band=row[3],
            settlement_date=row[4],
            settlement_method=row[5],
            insurer=row[6],
            adjuster_name=row[7],
            litigation_stage=row[8],
            negotiation_rounds=row[9],
            demand_amount=row[10],
            first_offer_amount=row[11],
            final_counter_amount=row[12],
            comparative_fault_pct=row[13],
            policy_limit=row[14],
            medical_specials_total=row[15],
            lost_wages_total=row[16],
            outcome_satisfaction=row[17],
            key_factors=row[18],
            council_contribution_consent=row[19] or False,
            nudge_sent_at=row[20].isoformat() if row[20] else None,
            captured_at=row[21].isoformat() if row[21] else None,
            created_at=row[22].isoformat() if row[22] else None,
            updated_at=row[23].isoformat() if row[23] else None,
        )

    except Exception as exc:
        logger.warning("get_settlement_details: DB error — %s", exc)
        return SettlementDetailRetrieveResponse(case_id=case_id_str, tenant_id=tenant_id)


@router.get(
    "/nudge-pending",
    response_model=NudgePendingResponse,
    summary="List cases past their estimated settlement window",
)
async def list_nudge_pending_cases(
    tenant_id: str,
    db: Session = Depends(get_db),
    limit: int = 20,
    offset: int = 0,
):
    """
    **Nudge-Pending Cases**

    Returns cases that have exceeded their estimated settlement window
    and don't have settlement details captured yet.
    These cases should be nudged to prompt the attorney for settlement data.
    """
    limit = min(max(limit, 1), 100)
    offset = max(offset, 0)

    try:
        rows = db.execute(text("""
            SELECT cp.case_id, cp.tenant_id, cp.incident_type, cp.state,
                   cp.estimated_settle_by, cp.created_at,
                   CURRENT_DATE - cp.estimated_settle_by AS days_past
            FROM leverage.leverage_case_profiles cp
            WHERE cp.tenant_id = :tid
              AND cp.estimated_settle_by IS NOT NULL
              AND cp.estimated_settle_by < CURRENT_DATE
              AND NOT EXISTS (
                  SELECT 1 FROM leverage.leverage_settlement_details sd
                  WHERE sd.case_id = cp.case_id AND sd.tenant_id = cp.tenant_id
              )
              AND NOT EXISTS (
                  SELECT 1 FROM leverage.leverage_case_events ce
                  WHERE ce.case_id = cp.case_id AND ce.tenant_id = cp.tenant_id
                    AND ce.event_type = 'settlement_recorded'
              )
            ORDER BY days_past DESC
            LIMIT :lim OFFSET :off
        """), {"tid": tenant_id, "lim": limit, "off": offset}).fetchall()

        count_row = db.execute(text("""
            SELECT COUNT(*)
            FROM leverage.leverage_case_profiles cp
            WHERE cp.tenant_id = :tid
              AND cp.estimated_settle_by IS NOT NULL
              AND cp.estimated_settle_by < CURRENT_DATE
              AND NOT EXISTS (
                  SELECT 1 FROM leverage.leverage_settlement_details sd
                  WHERE sd.case_id = cp.case_id AND sd.tenant_id = cp.tenant_id
              )
              AND NOT EXISTS (
                  SELECT 1 FROM leverage.leverage_case_events ce
                  WHERE ce.case_id = cp.case_id AND ce.tenant_id = cp.tenant_id
                    AND ce.event_type = 'settlement_recorded'
              )
        """), {"tid": tenant_id}).fetchone()

        total = count_row[0] if count_row else 0

        cases = [
            NudgePendingCase(
                case_id=str(r[0]),
                tenant_id=r[1],
                incident_type=r[2],
                state=r[3],
                estimated_settle_by=r[4].isoformat() if r[4] else None,
                days_past=int(r[5].days) if r[5] and hasattr(r[5], 'days') else 0,
                opened_at=r[6].isoformat() if r[6] else None,
            )
            for r in rows
        ]

    except Exception as exc:
        logger.warning("list_nudge_pending: DB error for %s — %s", tenant_id, exc)
        return NudgePendingResponse(tenant_id=tenant_id, cases=[], total_pending=0)

    return NudgePendingResponse(tenant_id=tenant_id, cases=cases, total_pending=total)


@router.post(
    "/{case_id}/nudge",
    response_model=NudgeResponse,
    summary="Manually trigger a settlement nudge for a case",
)
async def nudge_settlement(
    case_id: UUID,
    tenant_id: str,
    db: Session = Depends(get_db),
):
    """
    **Settlement Nudge**

    Sends a settlement nudge notification to the attorney for a case
    that has exceeded its estimated settlement window.
    Also records the nudge in the settlement details table.
    """
    case_id_str = str(case_id)

    # Fire notification via Feature A's notification system
    notification_sent = False
    try:
        dispatched = await fire_notification(
            tenant_id=tenant_id,
            event_type="settlement.nudge",
            severity="warning",
            payload={
                "case_id": case_id_str,
                "message": "This case has exceeded its estimated settlement window. Please record settlement details.",
                "action": "Record settlement details at /leverage/case/{}/settlement-details".format(case_id_str),
            },
            case_id=case_id_str,
            db=db,
        )
        notification_sent = dispatched > 0
    except Exception as exc:
        logger.warning("nudge_settlement: notification failed for %s — %s (non-fatal)", case_id_str, exc)

    # Record nudge in settlement details (create stub if not exists)
    try:
        db.execute(text("""
            INSERT INTO leverage.leverage_settlement_details (
                case_id, tenant_id, nudge_sent_at
            ) VALUES (:cid, :tid, :nudge_at)
            ON CONFLICT (case_id, tenant_id) DO UPDATE SET
                nudge_sent_at = EXCLUDED.nudge_sent_at,
                updated_at = now()
        """), {
            "cid": case_id_str,
            "tid": tenant_id,
            "nudge_at": datetime.now(timezone.utc),
        })

        # Emit nudge event
        emitter = LeverageEventEmitter(tenant_id=tenant_id, case_id=case_id_str)
        await emitter.emit("settlement.nudge", metadata={
            "case_id": case_id_str,
            "nudge_type": "settlement_window_exceeded",
        })

        db.commit()

    except Exception as exc:
        db.rollback()
        logger.warning("nudge_settlement: DB error for %s — %s (non-fatal)", case_id_str, exc)

    return NudgeResponse(
        success=True,
        case_id=case_id_str,
        tenant_id=tenant_id,
        notification_sent=notification_sent,
        message=(
            "Settlement nudge sent. "
            if notification_sent else "Nudge recorded but no active notification subscriptions found. "
        ),
    )

