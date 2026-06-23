"""
TrueVow DRAFT™ Service - Deadline Calculator Endpoints

Standalone deadline tools for PI and Employment Law attorneys:
  - PI SOL filing deadline  (uses seeded primary_state_sol data)
  - EEOC charge deadline    (180 days non-deferral / 300 days deferral states)
  - Right-to-Sue 90-day court filing deadline

All calculations are date math only — no document required.
"""

from datetime import date, timedelta
from typing import List, Optional

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session
from sqlalchemy import text

from app.core.database import get_db
from app.api.v1.endpoints.notifications import fire_notification

import logging

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/deadlines", tags=["Deadline Calculator"])

# ============================================================================
# EEOC DEFERRAL STATE MAP  (federal law — hard-coded, no DB needed)
# ----------------------------------------------------------------------------
# Non-deferral states have NO state FEPA agency that enforces equivalent law.
# In these states the EEOC deadline is 180 calendar days from the discriminatory act.
# Every other state (+ DC) has a FEPA, so the deadline extends to 300 calendar days.
#
# Non-deferral states (as of 2024): AL, AR, GA, MS, NC
# Source: EEOC.gov + DOJ Employment Discrimination Jurisdiction guide (rev. March 2024)
# ============================================================================

EEOC_NON_DEFERRAL_STATES = {"AL", "AR", "GA", "MS", "NC"}


def _eeoc_deadline_days(state: str) -> int:
    """Return 180 or 300 based on whether the state has a FEPA agency."""
    return 180 if state.upper() in EEOC_NON_DEFERRAL_STATES else 300


def _days_remaining(deadline: date) -> int:
    """Return calendar days from today to the deadline (negative = overdue)."""
    return (deadline - date.today()).days


def _urgency(days: int) -> str:
    """Return a plain-English urgency label for UI colour-coding."""
    if days < 0:
        return "OVERDUE"
    if days <= 30:
        return "CRITICAL"
    if days <= 90:
        return "WARNING"
    return "OK"


# ============================================================================
# PYDANTIC SCHEMAS
# ============================================================================

class SOLDeadlineRequest(BaseModel):
    """Request to calculate a PI statute-of-limitations filing deadline."""
    jurisdiction_state: str = Field(..., description="Two-letter state code, e.g. AZ")
    practice_area: str = Field(
        default="personal_injury",
        description="Practice area — currently personal_injury supported"
    )
    incident_date: date = Field(..., description="Date the injury/incident occurred (YYYY-MM-DD)")

    class Config:
        json_schema_extra = {
            "example": {
                "jurisdiction_state": "AZ",
                "practice_area": "personal_injury",
                "incident_date": "2024-03-15"
            }
        }


class EEOCDeadlineRequest(BaseModel):
    """Request to calculate an EEOC charge filing deadline."""
    jurisdiction_state: str = Field(..., description="Two-letter state code, e.g. AZ")
    discrimination_date: date = Field(
        ...,
        description="Date the discriminatory act occurred (YYYY-MM-DD)"
    )

    class Config:
        json_schema_extra = {
            "example": {
                "jurisdiction_state": "AZ",
                "discrimination_date": "2024-06-01"
            }
        }


class RightToSueRequest(BaseModel):
    """Request to calculate the 90-day court filing deadline after receiving a Right-to-Sue letter."""
    right_to_sue_date: date = Field(
        ...,
        description="Date the Right-to-Sue letter was received (YYYY-MM-DD)"
    )

    class Config:
        json_schema_extra = {
            "example": {
                "right_to_sue_date": "2024-11-01"
            }
        }


class CombinedDeadlineRequest(BaseModel):
    """
    All-in-one request.  Fill in the fields that apply to the case.
    DRAFT will return every applicable deadline in a single response.
    """
    jurisdiction_state: str = Field(..., description="Two-letter state code, e.g. AZ")
    practice_area: str = Field(
        ...,
        description="personal_injury or employment_law"
    )
    incident_date: Optional[date] = Field(
        None,
        description="Injury/incident date — used for PI SOL calculation"
    )
    discrimination_date: Optional[date] = Field(
        None,
        description="Date discriminatory act occurred — used for EEOC deadline"
    )
    right_to_sue_date: Optional[date] = Field(
        None,
        description="Date Right-to-Sue letter received — used for 90-day court deadline"
    )

    class Config:
        json_schema_extra = {
            "example": {
                "jurisdiction_state": "AZ",
                "practice_area": "personal_injury",
                "incident_date": "2024-03-15",
                "discrimination_date": None,
                "right_to_sue_date": None
            }
        }


class DeadlineItem(BaseModel):
    """A single deadline with all the context an attorney needs."""
    deadline_type: str
    label: str
    deadline_date: date
    days_remaining: int
    urgency: str        # OK | WARNING | CRITICAL | OVERDUE
    statute: Optional[str] = None
    sol_years: Optional[float] = None
    eeoc_days: Optional[int] = None
    discovery_rule: Optional[bool] = None
    notes: Optional[str] = None


class DeadlineResponse(BaseModel):
    """Full deadline response for one case."""
    jurisdiction_state: str
    practice_area: str
    deadlines: list[DeadlineItem]
    calculated_on: date


# ============================================================================
# HELPERS
# ============================================================================

def _query_sol(db: Session, state: str, practice_area: str) -> Optional[dict]:
    """
    Fetch the primary_state_sol row from leverage.validation_rules for this state.
    Returns the validator_config dict or None if not found.
    """
    try:
        result = db.execute(
            text(
                """
                SELECT validator_config
                FROM leverage.validation_rules
                WHERE jurisdiction_state = :state
                  AND practice_area      = :practice_area
                  AND validator_config ->> 'authority_level' = 'primary_state_sol'
                  AND is_active = true
                  AND archived_at IS NULL
                  AND deleted_at  IS NULL
                ORDER BY updated_at DESC
                LIMIT 1
                """
            ),
            {"state": state.upper(), "practice_area": practice_area},
        ).fetchone()

        if result:
            cfg = result[0]
            return cfg if isinstance(cfg, dict) else dict(cfg)
        return None
    except Exception as exc:
        logger.warning("SOL query failed for state=%s: %s", state, exc)
        return None


def _build_sol_deadline(incident_date: date, sol_config: dict) -> DeadlineItem:
    sol_days: int = int(sol_config.get("sol_days", 0))
    sol_years: float = float(sol_config.get("sol_years", 0))
    statute: str = sol_config.get("statute", "")
    discovery_rule: bool = bool(sol_config.get("discovery_rule", False))

    deadline = incident_date + timedelta(days=sol_days)
    days_left = _days_remaining(deadline)

    notes = (
        "Discovery rule applies — SOL may start from date injury was discovered, "
        "not necessarily the incident date. Consult the applicable statute."
        if discovery_rule
        else None
    )

    return DeadlineItem(
        deadline_type="pi_sol",
        label=f"PI Filing Deadline ({sol_years:.0f}-Year SOL)",
        deadline_date=deadline,
        days_remaining=days_left,
        urgency=_urgency(days_left),
        statute=statute,
        sol_years=sol_years,
        discovery_rule=discovery_rule,
        notes=notes,
    )


def _build_eeoc_deadline(discrimination_date: date, state: str) -> DeadlineItem:
    eeoc_days = _eeoc_deadline_days(state)
    deadline = discrimination_date + timedelta(days=eeoc_days)
    days_left = _days_remaining(deadline)

    deferral_note = (
        f"{state.upper()} is a non-deferral state — deadline is 180 days (no state FEPA agency)."
        if state.upper() in EEOC_NON_DEFERRAL_STATES
        else f"{state.upper()} is a deferral state — deadline is 300 days (state FEPA agency exists)."
    )

    return DeadlineItem(
        deadline_type="eeoc_charge",
        label=f"EEOC Charge Deadline ({eeoc_days} days)",
        deadline_date=deadline,
        days_remaining=days_left,
        urgency=_urgency(days_left),
        statute="42 U.S.C. § 2000e-5(e)(1) — Title VII",
        eeoc_days=eeoc_days,
        notes=deferral_note,
    )


def _build_right_to_sue_deadline(right_to_sue_date: date) -> DeadlineItem:
    deadline = right_to_sue_date + timedelta(days=90)
    days_left = _days_remaining(deadline)

    return DeadlineItem(
        deadline_type="right_to_sue_court_filing",
        label="Court Filing Deadline after Right-to-Sue (90 days)",
        deadline_date=deadline,
        days_remaining=days_left,
        urgency=_urgency(days_left),
        statute="42 U.S.C. § 2000e-5(f)(1) — Title VII",
        notes=(
            "You have exactly 90 calendar days from the date you received the "
            "Right-to-Sue letter to file your federal lawsuit. Missing this deadline "
            "permanently bars the claim."
        ),
    )


# ============================================================================
# ENDPOINTS
# ============================================================================

@router.post(
    "/sol",
    response_model=DeadlineResponse,
    status_code=status.HTTP_200_OK,
    summary="PI Statute of Limitations deadline",
)
async def calculate_sol_deadline(
    request: SOLDeadlineRequest,
    db: Session = Depends(get_db),
):
    """
    Calculate the personal injury SOL filing deadline for a given state.

    Enter the incident date and state — DRAFT looks up the statute of limitations
    from the verified rules database and tells you exactly when you must file
    and how many days you have left.
    """
    state = request.jurisdiction_state.upper()
    sol_config = _query_sol(db, state, request.practice_area)

    if not sol_config:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=(
                f"No SOL data found for state={state}, "
                f"practice_area={request.practice_area}. "
                "Ensure the state SOL seed has been applied."
            ),
        )

    deadline_item = _build_sol_deadline(request.incident_date, sol_config)

    return DeadlineResponse(
        jurisdiction_state=state,
        practice_area=request.practice_area,
        deadlines=[deadline_item],
        calculated_on=date.today(),
    )


@router.post(
    "/eeoc",
    response_model=DeadlineResponse,
    status_code=status.HTTP_200_OK,
    summary="EEOC charge filing deadline",
)
async def calculate_eeoc_deadline(
    request: EEOCDeadlineRequest,
):
    """
    Calculate the EEOC charge filing deadline (180 or 300 days).

    Enter the date the discriminatory act occurred and the state.
    DRAFT automatically determines whether the state has a Fair Employment
    Practices Agency (FEPA) and applies the correct deadline (180 vs 300 days).

    Missing this deadline permanently bars the employee from suing under federal
    discrimination law — this is the most common malpractice trap in employment law.
    """
    state = request.jurisdiction_state.upper()
    deadline_item = _build_eeoc_deadline(request.discrimination_date, state)

    return DeadlineResponse(
        jurisdiction_state=state,
        practice_area="employment_law",
        deadlines=[deadline_item],
        calculated_on=date.today(),
    )


@router.post(
    "/right-to-sue",
    response_model=DeadlineResponse,
    status_code=status.HTTP_200_OK,
    summary="90-day court filing deadline after Right-to-Sue letter",
)
async def calculate_right_to_sue_deadline(
    request: RightToSueRequest,
):
    """
    Calculate the 90-day federal court filing deadline after receiving an EEOC Right-to-Sue letter.

    Enter the date the letter was received.  DRAFT tells you the exact deadline
    and how many days remain.  Missing this deadline permanently bars the lawsuit.
    """
    deadline_item = _build_right_to_sue_deadline(request.right_to_sue_date)

    return DeadlineResponse(
        jurisdiction_state="federal",
        practice_area="employment_law",
        deadlines=[deadline_item],
        calculated_on=date.today(),
    )


@router.post(
    "/calculate",
    response_model=DeadlineResponse,
    status_code=status.HTTP_200_OK,
    summary="All-in-one deadline calculator (PI + Employment Law)",
)
async def calculate_all_deadlines(
    request: CombinedDeadlineRequest,
    db: Session = Depends(get_db),
):
    """
    All-in-one deadline calculator.

    Pass in every date you have — DRAFT returns every applicable deadline
    in a single response:

    - **PI SOL** — requires `incident_date`
    - **EEOC charge** — requires `discrimination_date`
    - **Right-to-Sue court filing** — requires `right_to_sue_date`

    You can pass one, two, or all three dates in the same request.
    Any date you leave blank is simply skipped.
    """
    state = request.jurisdiction_state.upper()
    deadlines: list[DeadlineItem] = []

    # 1. PI SOL
    if request.incident_date and request.practice_area == "personal_injury":
        sol_config = _query_sol(db, state, "personal_injury")
        if sol_config:
            deadlines.append(_build_sol_deadline(request.incident_date, sol_config))
        else:
            logger.warning("SOL data missing for state=%s — skipping PI SOL deadline", state)

    # 2. EEOC charge deadline
    if request.discrimination_date:
        deadlines.append(_build_eeoc_deadline(request.discrimination_date, state))

    # 3. Right-to-Sue 90-day deadline
    if request.right_to_sue_date:
        deadlines.append(_build_right_to_sue_deadline(request.right_to_sue_date))

    if not deadlines:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=(
                "No dates provided. Supply at least one of: "
                "incident_date, discrimination_date, right_to_sue_date."
            ),
        )

    # Sort by urgency so the most critical deadline appears first
    deadlines.sort(key=lambda d: d.days_remaining)

    return DeadlineResponse(
        jurisdiction_state=state,
        practice_area=request.practice_area,
        deadlines=deadlines,
        calculated_on=date.today(),
    )


# ============================================================================
# DEADLINE PERSISTENCE (save / retrieve / upcoming)
# ============================================================================

class SaveDeadlineRequest(BaseModel):
    """Save a calculated deadline to a case."""
    tenant_id: str = Field(..., description="Tenant UUID")
    deadline_type: str = Field(..., description="sol | eeoc | demand_letter | right_to_sue")
    deadline_date: date = Field(..., description="Calculated deadline date")
    days_remaining: int = Field(..., description="Days remaining from today")
    urgency: str = Field(..., description="OK | WARNING | CRITICAL | OVERDUE")
    source_state: Optional[str] = Field(None, description="Two-letter state code")
    calculation_input: Optional[dict] = Field(None, description="Full request payload used")
    calculation_result: Optional[dict] = Field(None, description="Full DeadlineItem result")


class SavedDeadlineEntry(BaseModel):
    """A saved deadline entry."""
    id: str
    case_id: str
    tenant_id: str
    deadline_type: str
    deadline_date: date
    days_remaining: int
    urgency: str
    source_state: Optional[str] = None
    created_at: Optional[str] = None


class SaveDeadlineResponse(BaseModel):
    """Response after saving a deadline."""
    id: str
    case_id: str
    tenant_id: str
    deadline_type: str
    deadline_date: date
    days_remaining: int
    urgency: str
    created_at: Optional[str] = None


class SavedDeadlinesResponse(BaseModel):
    """All saved deadlines for a case."""
    case_id: str
    tenant_id: str
    deadlines: List[SavedDeadlineEntry]
    total_deadlines: int


class UpcomingDeadlineEntry(BaseModel):
    """An upcoming deadline across all cases."""
    id: str
    case_id: str
    tenant_id: str
    deadline_type: str
    deadline_date: date
    days_remaining: int
    urgency: str
    source_state: Optional[str] = None
    created_at: Optional[str] = None


class UpcomingDeadlinesResponse(BaseModel):
    """Upcoming deadlines across all cases for a tenant."""
    tenant_id: str
    deadlines: List[UpcomingDeadlineEntry]
    total_upcoming: int


@router.post(
    "/case/{case_id}/save",
    response_model=SaveDeadlineResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Save a calculated deadline to a case",
)
async def save_deadline(
    case_id: str,
    request: SaveDeadlineRequest,
    db: Session = Depends(get_db),
):
    """
    **Save Deadline to Case**

    Saves a calculated deadline to a case for later retrieval.
    If a deadline of the same type already exists for this case, it is replaced
    (upsert by case_id + tenant_id + deadline_type).

    Portal workflow: calculate (POST /deadlines/sol) → save to case.
    """
    import json

    try:
        # Upsert: delete existing deadline of same type for this case, then insert
        db.execute(text("""
            DELETE FROM leverage.leverage_case_deadlines
            WHERE case_id = :cid AND tenant_id = :tid AND deadline_type = :dtype
        """), {
            "cid": case_id,
            "tid": request.tenant_id,
            "dtype": request.deadline_type,
        })

        result = db.execute(text("""
            INSERT INTO leverage.leverage_case_deadlines
                (case_id, tenant_id, deadline_type, deadline_date, days_remaining,
                 urgency, source_state, calculation_input_json, calculation_result_json)
            VALUES (:cid, :tid, :dtype, :ddate, :drem, :urg, :sstate, :cinp, :cres)
            RETURNING id, created_at
        """), {
            "cid": case_id,
            "tid": request.tenant_id,
            "dtype": request.deadline_type,
            "ddate": request.deadline_date,
            "drem": request.days_remaining,
            "urg": request.urgency,
            "sstate": request.source_state,
            "cinp": json.dumps(request.calculation_input) if request.calculation_input else None,
            "cres": json.dumps(request.calculation_result) if request.calculation_result else None,
        })
        row = result.fetchone()
        db.commit()

        # ── Fire notification for CRITICAL/OVERDUE deadlines ─────────────────
        if request.urgency in ("CRITICAL", "OVERDUE"):
            notif_event = "deadline.overdue" if request.urgency == "OVERDUE" else "deadline.critical"
            notif_severity = "critical"
            notif_payload = {
                "case_id": case_id,
                "deadline_type": request.deadline_type,
                "deadline_date": request.deadline_date.isoformat() if hasattr(request.deadline_date, 'isoformat') else str(request.deadline_date),
                "days_remaining": request.days_remaining,
                "urgency": request.urgency,
                "source_state": request.source_state,
            }
            # Fire-and-forget — notification failure is non-fatal
            try:
                await fire_notification(
                    tenant_id=request.tenant_id,
                    event_type=notif_event,
                    severity=notif_severity,
                    payload=notif_payload,
                    case_id=case_id,
                    db=db,
                )
            except Exception as nexc:
                logger.warning("deadlines/save: notification fire failed (non-fatal) — %s", nexc)

        return SaveDeadlineResponse(
            id=str(row[0]),
            case_id=case_id,
            tenant_id=request.tenant_id,
            deadline_type=request.deadline_type,
            deadline_date=request.deadline_date,
            days_remaining=request.days_remaining,
            urgency=request.urgency,
            created_at=row[1].isoformat() if row[1] else None,
        )

    except Exception as exc:
        db.rollback()
        logger.error("deadlines/save: DB error for %s/%s — %s", request.tenant_id, case_id, exc)
        raise


@router.get(
    "/case/{case_id}",
    response_model=SavedDeadlinesResponse,
    summary="Retrieve saved deadlines for a case",
)
async def get_saved_deadlines(
    case_id: str,
    tenant_id: str,
    db: Session = Depends(get_db),
):
    """
    **Get Saved Deadlines for a Case**

    Returns all saved deadlines for a case.
    Called by the Customer Portal to display the deadlines card.
    """
    try:
        rows = db.execute(text("""
            SELECT id, case_id, tenant_id, deadline_type, deadline_date,
                   days_remaining, urgency, source_state, created_at
            FROM leverage.leverage_case_deadlines
            WHERE case_id = :cid AND tenant_id = :tid
            ORDER BY deadline_date ASC
        """), {"cid": case_id, "tid": tenant_id}).fetchall()

        deadlines = [
            SavedDeadlineEntry(
                id=str(row[0]),
                case_id=str(row[1]),
                tenant_id=row[2],
                deadline_type=row[3],
                deadline_date=row[4],
                days_remaining=row[5],
                urgency=row[6],
                source_state=row[7],
                created_at=row[8].isoformat() if row[8] else None,
            )
            for row in rows
        ]

    except Exception as exc:
        logger.warning("deadlines/case: DB error for %s/%s — %s", tenant_id, case_id, exc)
        return SavedDeadlinesResponse(case_id=case_id, tenant_id=tenant_id, deadlines=[], total_deadlines=0)

    return SavedDeadlinesResponse(
        case_id=case_id,
        tenant_id=tenant_id,
        deadlines=deadlines,
        total_deadlines=len(deadlines),
    )


@router.get(
    "/upcoming",
    response_model=UpcomingDeadlinesResponse,
    summary="Upcoming deadlines across all cases for a tenant",
)
async def get_upcoming_deadlines(
    tenant_id: str,
    db: Session = Depends(get_db),
    days: int = 30,
    limit: int = 50,
):
    """
    **Upcoming Deadlines**

    Returns all deadlines due within the specified number of days across all cases.
    Sorted by deadline date (most urgent first).

    Called by the Customer Portal to display the deadline alerts widget.
    """
    days = min(max(days, 1), 365)
    limit = min(max(limit, 1), 200)

    try:
        rows = db.execute(text("""
            SELECT id, case_id, tenant_id, deadline_type, deadline_date,
                   days_remaining, urgency, source_state, created_at
            FROM leverage.leverage_case_deadlines
            WHERE tenant_id = :tid
              AND deadline_date <= CURRENT_DATE + :days * INTERVAL '1 day'
            ORDER BY deadline_date ASC
            LIMIT :lim
        """), {"tid": tenant_id, "days": days, "lim": limit}).fetchall()

        deadlines = [
            UpcomingDeadlineEntry(
                id=str(row[0]),
                case_id=str(row[1]),
                tenant_id=row[2],
                deadline_type=row[3],
                deadline_date=row[4],
                days_remaining=row[5],
                urgency=row[6],
                source_state=row[7],
                created_at=row[8].isoformat() if row[8] else None,
            )
            for row in rows
        ]

    except Exception as exc:
        logger.warning("deadlines/upcoming: DB error for %s — %s", tenant_id, exc)
        return UpcomingDeadlinesResponse(tenant_id=tenant_id, deadlines=[], total_upcoming=0)

    return UpcomingDeadlinesResponse(
        tenant_id=tenant_id,
        deadlines=deadlines,
        total_upcoming=len(deadlines),
    )
