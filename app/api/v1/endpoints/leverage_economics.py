"""
TrueVow LEVERAGE™ — Group B: Case Economics Calculators

Stateless calculation tools (no data stored) PLUS persistence endpoints
for saving and retrieving worksheets per case.

Calculation endpoints (stateless, zero-knowledge):
  POST /leverage/damages      — PI damages worksheet
  POST /leverage/disbursement — Case disbursement / costs calculator

Persistence endpoints (save/retrieve for portal display):
  POST /leverage/case/{case_id}/damages/save      — Save a damages worksheet
  GET  /leverage/case/{case_id}/damages            — Retrieve saved damages
  GET  /leverage/case/{case_id}/damages/{ws_id}   — Get specific worksheet
  POST /leverage/case/{case_id}/disbursement/save  — Save a disbursement worksheet
  GET  /leverage/case/{case_id}/disbursement       — Retrieve saved disbursements
  GET  /leverage/case/{case_id}/disbursement/{ws_id} — Get specific worksheet

Portal workflow: calculate (stateless) → review → save to case.
Worksheets are versioned (append-only); old versions are never deleted.

These tools quantify leverage before negotiation:
  damages     → tells the attorney what the case is worth
  disbursement → tells the attorney what the firm has invested
  Together    → defines the settlement floor and negotiation range
"""

from datetime import datetime
from typing import Optional, List
from uuid import UUID

from fastapi import APIRouter, Depends, status
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session
from sqlalchemy import text
import logging

from app.core.database import get_db

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/leverage", tags=["LEVERAGE - Case Economics"])


# ============================================================================
# DAMAGES CALCULATOR
# ============================================================================

class MedicalExpenses(BaseModel):
    """Medical expense line items"""
    emergency_room: float = Field(0.0, ge=0)
    hospitalization: float = Field(0.0, ge=0)
    surgery: float = Field(0.0, ge=0)
    physical_therapy: float = Field(0.0, ge=0)
    specialist_visits: float = Field(0.0, ge=0)
    medications: float = Field(0.0, ge=0)
    future_medical_estimate: float = Field(0.0, ge=0, description="Estimated future medical costs")
    other_medical: float = Field(0.0, ge=0)


class LostIncome(BaseModel):
    """Lost income line items"""
    weekly_wage: float = Field(0.0, ge=0, description="Weekly wage before injury")
    weeks_missed: float = Field(0.0, ge=0, description="Weeks of work missed")
    future_lost_earning_capacity: float = Field(0.0, ge=0, description="Estimated future lost earnings")


class DamagesRequest(BaseModel):
    """
    PI damages worksheet input.
    All monetary values in USD. All fields optional — calculator uses what is provided.
    """
    tenant_id: str = Field(..., description="Tenant UUID")
    case_reference: Optional[str] = Field(None, description="Internal case reference (not stored)")

    medical: MedicalExpenses = Field(default_factory=MedicalExpenses)
    lost_income: LostIncome = Field(default_factory=LostIncome)

    pain_suffering_multiplier: float = Field(
        3.0,
        ge=1.0,
        le=10.0,
        description="Pain & suffering multiplier applied to medical specials (1–10). Typical PI range: 1.5–5."
    )
    property_damage: float = Field(0.0, ge=0, description="Property damage (vehicle, personal property)")
    out_of_pocket_expenses: float = Field(0.0, ge=0, description="Other out-of-pocket expenses")

    class Config:
        json_schema_extra = {
            "example": {
                "tenant_id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
                "case_reference": "case-2024-001",
                "medical": {
                    "emergency_room": 8500,
                    "hospitalization": 22000,
                    "physical_therapy": 4800,
                    "medications": 600,
                    "future_medical_estimate": 15000
                },
                "lost_income": {
                    "weekly_wage": 1200,
                    "weeks_missed": 8,
                    "future_lost_earning_capacity": 0
                },
                "pain_suffering_multiplier": 3.5,
                "property_damage": 12000,
                "out_of_pocket_expenses": 750
            }
        }


class DamagesBreakdown(BaseModel):
    total_medical_specials: float
    total_lost_income: float
    pain_and_suffering: float
    property_damage: float
    out_of_pocket_expenses: float
    total_economic_damages: float
    total_non_economic_damages: float
    gross_damages: float
    notes: List[str]


class DamagesResponse(BaseModel):
    """
    Damages worksheet result.
    Gross damages = economic + non-economic. Does not account for liability percentage.
    """
    breakdown: DamagesBreakdown
    gross_damages: float
    settlement_range_low: float
    settlement_range_high: float
    multiplier_used: float
    disclaimer: str


@router.post(
    "/damages",
    response_model=DamagesResponse,
    status_code=status.HTTP_200_OK,
    summary="Calculate PI case damages worksheet",
)
async def calculate_damages(request: DamagesRequest):
    """
    **LEVERAGE Damages Calculator**

    Stateless PI damages worksheet — no data is stored.

    Calculates:
    - Total medical specials (past + future)
    - Total lost income (past + future earning capacity)
    - Pain & suffering (multiplier × medical specials)
    - Gross damages = economic + non-economic

    Settlement range:
    - Low:  60% of gross damages (conservative liability discount)
    - High: 85% of gross damages (strong liability position)

    The multiplier (1–10) represents pain & suffering severity.
    Typical PI range is 1.5–5. Catastrophic injuries may justify higher.
    """
    notes: List[str] = []

    # Medical specials
    m = request.medical
    past_medical = (
        m.emergency_room +
        m.hospitalization +
        m.surgery +
        m.physical_therapy +
        m.specialist_visits +
        m.medications +
        m.other_medical
    )
    total_medical = past_medical + m.future_medical_estimate
    if m.future_medical_estimate > 0:
        notes.append("Future medical estimate included — consider expert support for large values.")

    # Lost income
    li = request.lost_income
    past_lost_income = li.weekly_wage * li.weeks_missed
    total_lost_income = past_lost_income + li.future_lost_earning_capacity
    if li.future_lost_earning_capacity > 0:
        notes.append("Future lost earning capacity included — vocational expert may strengthen this claim.")

    # Economic damages
    total_economic = total_medical + total_lost_income + request.property_damage + request.out_of_pocket_expenses

    # Non-economic (pain & suffering)
    pain_suffering = total_medical * request.pain_suffering_multiplier
    if request.pain_suffering_multiplier >= 5.0:
        notes.append(f"Multiplier of {request.pain_suffering_multiplier}× is high — ensure injury severity supports this.")

    # Gross
    gross = total_economic + pain_suffering

    # Settlement range
    settlement_low = round(gross * 0.60, 2)
    settlement_high = round(gross * 0.85, 2)

    if gross == 0:
        notes.append("All inputs are zero — enter expense values to see a meaningful calculation.")

    return DamagesResponse(
        breakdown=DamagesBreakdown(
            total_medical_specials=round(total_medical, 2),
            total_lost_income=round(total_lost_income, 2),
            pain_and_suffering=round(pain_suffering, 2),
            property_damage=round(request.property_damage, 2),
            out_of_pocket_expenses=round(request.out_of_pocket_expenses, 2),
            total_economic_damages=round(total_economic, 2),
            total_non_economic_damages=round(pain_suffering, 2),
            gross_damages=round(gross, 2),
            notes=notes,
        ),
        gross_damages=round(gross, 2),
        settlement_range_low=settlement_low,
        settlement_range_high=settlement_high,
        multiplier_used=request.pain_suffering_multiplier,
        disclaimer=(
            "This is a calculation tool only. It does not constitute legal advice. "
            "Settlement range estimates assume general liability. "
            "Actual outcomes depend on jurisdiction, evidence, and negotiation."
        ),
    )


# ============================================================================
# DISBURSEMENT CALCULATOR
# ============================================================================

class DisbursementItem(BaseModel):
    description: str = Field(..., description="Description of cost item")
    amount: float = Field(..., ge=0, description="Amount in USD")


class DisbursementRequest(BaseModel):
    """
    Case disbursement / costs calculator.
    Tracks what the firm has spent on the case (out-of-pocket costs).
    """
    tenant_id: str = Field(..., description="Tenant UUID")
    case_reference: Optional[str] = Field(None, description="Internal case reference (not stored)")

    # Standard PI disbursement categories
    filing_fees: float = Field(0.0, ge=0)
    medical_records: float = Field(0.0, ge=0)
    expert_witness_fees: float = Field(0.0, ge=0)
    deposition_costs: float = Field(0.0, ge=0)
    investigation_costs: float = Field(0.0, ge=0)
    process_server_fees: float = Field(0.0, ge=0)
    travel_expenses: float = Field(0.0, ge=0)
    postage_copies: float = Field(0.0, ge=0)

    # Contingency fee percentage (for net-to-client calculation)
    contingency_fee_pct: float = Field(
        33.33,
        ge=0,
        le=50,
        description="Attorney contingency fee percentage (0–50). Default: 33.33%"
    )

    # Optional: gross settlement amount for net-to-client calculation
    gross_settlement: Optional[float] = Field(
        None,
        ge=0,
        description="If provided, calculates net-to-client after fees and disbursements"
    )

    custom_items: List[DisbursementItem] = Field(
        default_factory=list,
        description="Additional cost items not in standard categories"
    )

    class Config:
        json_schema_extra = {
            "example": {
                "tenant_id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
                "case_reference": "case-2024-001",
                "filing_fees": 450,
                "medical_records": 320,
                "expert_witness_fees": 3500,
                "deposition_costs": 1200,
                "investigation_costs": 800,
                "process_server_fees": 150,
                "contingency_fee_pct": 33.33,
                "gross_settlement": 75000,
                "custom_items": [
                    {"description": "Accident reconstruction", "amount": 2500}
                ]
            }
        }


class DisbursementBreakdown(BaseModel):
    filing_fees: float
    medical_records: float
    expert_witness_fees: float
    deposition_costs: float
    investigation_costs: float
    process_server_fees: float
    travel_expenses: float
    postage_copies: float
    custom_items_total: float
    total_disbursements: float


class DisbursementResponse(BaseModel):
    breakdown: DisbursementBreakdown
    total_disbursements: float
    contingency_fee_pct: float

    # Only present if gross_settlement was provided
    gross_settlement: Optional[float] = None
    attorney_fee: Optional[float] = None
    net_to_client: Optional[float] = None
    minimum_settlement_to_break_even: float

    disclaimer: str


@router.post(
    "/disbursement",
    response_model=DisbursementResponse,
    status_code=status.HTTP_200_OK,
    summary="Calculate case disbursements and net-to-client projection",
)
async def calculate_disbursement(request: DisbursementRequest):
    """
    **LEVERAGE Disbursement Calculator**

    Stateless case cost tracker — no data is stored.

    Calculates:
    - Total out-of-pocket firm disbursements
    - Attorney contingency fee on gross settlement
    - Net-to-client after fees and costs
    - Minimum settlement needed to break even (cover disbursements)

    This tells the attorney the settlement floor:
    any settlement below the break-even point costs the firm money.
    """
    custom_total = sum(item.amount for item in request.custom_items)

    total_disb = (
        request.filing_fees +
        request.medical_records +
        request.expert_witness_fees +
        request.deposition_costs +
        request.investigation_costs +
        request.process_server_fees +
        request.travel_expenses +
        request.postage_copies +
        custom_total
    )

    fee_pct = request.contingency_fee_pct / 100.0

    # Break-even: settlement where attorney fee + disbursements = settlement
    # gross × fee_pct + disbursements = gross
    # disbursements = gross × (1 - fee_pct)
    # gross = disbursements / (1 - fee_pct)
    if fee_pct < 1.0:
        break_even = round(total_disb / (1.0 - fee_pct), 2)
    else:
        break_even = 0.0

    # Net-to-client if settlement provided
    attorney_fee = None
    net_to_client = None
    gross_settlement = None

    if request.gross_settlement is not None and request.gross_settlement > 0:
        gross_settlement = request.gross_settlement
        attorney_fee = round(gross_settlement * fee_pct, 2)
        net_to_client = round(gross_settlement - attorney_fee - total_disb, 2)

    return DisbursementResponse(
        breakdown=DisbursementBreakdown(
            filing_fees=round(request.filing_fees, 2),
            medical_records=round(request.medical_records, 2),
            expert_witness_fees=round(request.expert_witness_fees, 2),
            deposition_costs=round(request.deposition_costs, 2),
            investigation_costs=round(request.investigation_costs, 2),
            process_server_fees=round(request.process_server_fees, 2),
            travel_expenses=round(request.travel_expenses, 2),
            postage_copies=round(request.postage_copies, 2),
            custom_items_total=round(custom_total, 2),
            total_disbursements=round(total_disb, 2),
        ),
        total_disbursements=round(total_disb, 2),
        contingency_fee_pct=request.contingency_fee_pct,
        gross_settlement=gross_settlement,
        attorney_fee=attorney_fee,
        net_to_client=net_to_client,
        minimum_settlement_to_break_even=break_even,
        disclaimer=(
            "This is a calculation tool only. It does not constitute legal or financial advice. "
            "Actual fee arrangements and costs may vary. "
            "Consult your retainer agreement for the applicable contingency percentage."
        ),
    )


# ============================================================================
# DAMAGES PERSISTENCE (save / retrieve worksheets per case)
# ============================================================================

class SaveDamagesRequest(BaseModel):
    """Save a damages worksheet result to a case."""
    tenant_id: str = Field(..., description="Tenant UUID")
    input_data: dict = Field(..., description="Full DamagesRequest payload that was used")
    result_data: dict = Field(..., description="Full DamagesResponse payload from the calculator")


class SavedWorksheetHeader(BaseModel):
    """Header for a saved worksheet in list view."""
    id: str
    case_id: str
    tenant_id: str
    version: int
    gross_damages: Optional[float] = None
    created_at: Optional[str] = None


class SavedDamagesDetail(BaseModel):
    """Full saved damages worksheet with input and result."""
    id: str
    case_id: str
    tenant_id: str
    version: int
    input_data: dict
    result_data: dict
    created_at: Optional[str] = None


class SavedDamagesListResponse(BaseModel):
    case_id: str
    tenant_id: str
    worksheets: List[SavedWorksheetHeader]
    total_versions: int


@router.post(
    "/case/{case_id}/damages/save",
    response_model=SavedDamagesDetail,
    status_code=status.HTTP_201_CREATED,
    summary="Save a damages worksheet to a case",
)
async def save_damages_worksheet(
    case_id: UUID,
    request: SaveDamagesRequest,
    db: Session = Depends(get_db),
):
    """
    **Save Damages Worksheet**

    Saves a PI damages worksheet result to a case for later retrieval.
    The worksheet is versioned — each save creates a new version.
    Old versions are never deleted (append-only).

    Portal workflow: calculate (POST /leverage/damages) → review → save.
    """
    case_id_str = str(case_id)

    try:
        # Get next version number
        version_row = db.execute(text("""
            SELECT COALESCE(MAX(version), 0) + 1
            FROM leverage.leverage_damages_worksheets
            WHERE case_id = :cid AND tenant_id = :tid
        """), {"cid": case_id_str, "tid": request.tenant_id}).fetchone()
        next_version = version_row[0] if version_row else 1

        # Insert
        import json
        result = db.execute(text("""
            INSERT INTO leverage.leverage_damages_worksheets
                (case_id, tenant_id, version, input_json, result_json)
            VALUES (:cid, :tid, :ver, :inp, :res)
            RETURNING id, created_at
        """), {
            "cid": case_id_str,
            "tid": request.tenant_id,
            "ver": next_version,
            "inp": json.dumps(request.input_data),
            "res": json.dumps(request.result_data),
        })
        row = result.fetchone()
        db.commit()

        return SavedDamagesDetail(
            id=str(row[0]),
            case_id=case_id_str,
            tenant_id=request.tenant_id,
            version=next_version,
            input_data=request.input_data,
            result_data=request.result_data,
            created_at=row[1].isoformat() if row[1] else None,
        )

    except Exception as exc:
        db.rollback()
        logger.error("leverage/damages/save: DB error for %s/%s — %s", request.tenant_id, case_id_str, exc)
        raise


@router.get(
    "/case/{case_id}/damages",
    response_model=SavedDamagesListResponse,
    summary="Retrieve saved damages worksheets for a case",
)
async def get_saved_damages(
    case_id: UUID,
    tenant_id: str,
    db: Session = Depends(get_db),
    limit: int = 20,
    offset: int = 0,
):
    """
    **Get Saved Damages Worksheets**

    Returns all saved damages worksheets for a case, ordered by version.
    Called by the Customer Portal to display saved worksheet history.
    """
    case_id_str = str(case_id)
    limit = min(max(limit, 1), 100)

    try:
        # Count total
        count_row = db.execute(text("""
            SELECT COUNT(*) FROM leverage.leverage_damages_worksheets
            WHERE case_id = :cid AND tenant_id = :tid
        """), {"cid": case_id_str, "tid": tenant_id}).fetchone()
        total = count_row[0] if count_row else 0

        # Fetch worksheets
        rows = db.execute(text("""
            SELECT id, case_id, tenant_id, version, result_json, created_at
            FROM leverage.leverage_damages_worksheets
            WHERE case_id = :cid AND tenant_id = :tid
            ORDER BY version DESC
            LIMIT :lim OFFSET :off
        """), {"cid": case_id_str, "tid": tenant_id, "lim": limit, "off": offset}).fetchall()

        import json as _json
        worksheets = []
        for row in rows:
            result_data = _json.loads(row[4]) if isinstance(row[4], str) else (row[4] or {})
            gross = result_data.get("gross_damages")
            worksheets.append(SavedWorksheetHeader(
                id=str(row[0]),
                case_id=str(row[1]),
                tenant_id=row[2],
                version=row[3],
                gross_damages=gross,
                created_at=row[5].isoformat() if row[5] else None,
            ))

    except Exception as exc:
        logger.warning("leverage/damages/list: DB error for %s/%s — %s", tenant_id, case_id_str, exc)
        return SavedDamagesListResponse(case_id=case_id_str, tenant_id=tenant_id, worksheets=[], total_versions=0)

    return SavedDamagesListResponse(
        case_id=case_id_str,
        tenant_id=tenant_id,
        worksheets=worksheets,
        total_versions=total,
    )


@router.get(
    "/case/{case_id}/damages/{worksheet_id}",
    response_model=SavedDamagesDetail,
    summary="Get a specific saved damages worksheet",
)
async def get_damages_worksheet(
    case_id: UUID,
    worksheet_id: UUID,
    tenant_id: str,
    db: Session = Depends(get_db),
):
    """
    **Get Specific Damages Worksheet**

    Returns the full input and result data for a specific saved worksheet.
    """
    import json as _json

    try:
        row = db.execute(text("""
            SELECT id, case_id, tenant_id, version, input_json, result_json, created_at
            FROM leverage.leverage_damages_worksheets
            WHERE id = :wsid AND case_id = :cid AND tenant_id = :tid
        """), {"wsid": str(worksheet_id), "cid": str(case_id), "tid": tenant_id}).fetchone()

        if not row:
            from fastapi import HTTPException
            raise HTTPException(status_code=404, detail="Damages worksheet not found")

        input_data = _json.loads(row[4]) if isinstance(row[4], str) else (row[4] or {})
        result_data = _json.loads(row[5]) if isinstance(row[5], str) else (row[5] or {})

        return SavedDamagesDetail(
            id=str(row[0]),
            case_id=str(row[1]),
            tenant_id=row[2],
            version=row[3],
            input_data=input_data,
            result_data=result_data,
            created_at=row[6].isoformat() if row[6] else None,
        )

    except Exception as exc:
        if isinstance(exc, Exception) and hasattr(exc, 'status_code') and exc.status_code == 404:
            raise
        logger.warning("leverage/damages/get: DB error — %s", exc)
        raise


# ============================================================================
# DISBURSEMENT PERSISTENCE (save / retrieve worksheets per case)
# ============================================================================

class SaveDisbursementRequest(BaseModel):
    """Save a disbursement worksheet result to a case."""
    tenant_id: str = Field(..., description="Tenant UUID")
    input_data: dict = Field(..., description="Full DisbursementRequest payload that was used")
    result_data: dict = Field(..., description="Full DisbursementResponse payload from the calculator")


class SavedDisbursementDetail(BaseModel):
    """Full saved disbursement worksheet with input and result."""
    id: str
    case_id: str
    tenant_id: str
    version: int
    input_data: dict
    result_data: dict
    created_at: Optional[str] = None


class SavedDisbursementListResponse(BaseModel):
    case_id: str
    tenant_id: str
    worksheets: List[SavedWorksheetHeader]
    total_versions: int


@router.post(
    "/case/{case_id}/disbursement/save",
    response_model=SavedDisbursementDetail,
    status_code=status.HTTP_201_CREATED,
    summary="Save a disbursement worksheet to a case",
)
async def save_disbursement_worksheet(
    case_id: UUID,
    request: SaveDisbursementRequest,
    db: Session = Depends(get_db),
):
    """
    **Save Disbursement Worksheet**

    Saves a disbursement worksheet result to a case for later retrieval.
    The worksheet is versioned — each save creates a new version.
    Old versions are never deleted (append-only).

    Portal workflow: calculate (POST /leverage/disbursement) → review → save.
    """
    case_id_str = str(case_id)

    try:
        # Get next version number
        version_row = db.execute(text("""
            SELECT COALESCE(MAX(version), 0) + 1
            FROM leverage.leverage_disbursement_worksheets
            WHERE case_id = :cid AND tenant_id = :tid
        """), {"cid": case_id_str, "tid": request.tenant_id}).fetchone()
        next_version = version_row[0] if version_row else 1

        # Insert
        import json
        result = db.execute(text("""
            INSERT INTO leverage.leverage_disbursement_worksheets
                (case_id, tenant_id, version, input_json, result_json)
            VALUES (:cid, :tid, :ver, :inp, :res)
            RETURNING id, created_at
        """), {
            "cid": case_id_str,
            "tid": request.tenant_id,
            "ver": next_version,
            "inp": json.dumps(request.input_data),
            "res": json.dumps(request.result_data),
        })
        row = result.fetchone()
        db.commit()

        return SavedDisbursementDetail(
            id=str(row[0]),
            case_id=case_id_str,
            tenant_id=request.tenant_id,
            version=next_version,
            input_data=request.input_data,
            result_data=request.result_data,
            created_at=row[1].isoformat() if row[1] else None,
        )

    except Exception as exc:
        db.rollback()
        logger.error("leverage/disbursement/save: DB error for %s/%s — %s", request.tenant_id, case_id_str, exc)
        raise


@router.get(
    "/case/{case_id}/disbursement",
    response_model=SavedDisbursementListResponse,
    summary="Retrieve saved disbursement worksheets for a case",
)
async def get_saved_disbursements(
    case_id: UUID,
    tenant_id: str,
    db: Session = Depends(get_db),
    limit: int = 20,
    offset: int = 0,
):
    """
    **Get Saved Disbursement Worksheets**

    Returns all saved disbursement worksheets for a case, ordered by version.
    Called by the Customer Portal to display saved worksheet history.
    """
    case_id_str = str(case_id)
    limit = min(max(limit, 1), 100)

    try:
        # Count total
        count_row = db.execute(text("""
            SELECT COUNT(*) FROM leverage.leverage_disbursement_worksheets
            WHERE case_id = :cid AND tenant_id = :tid
        """), {"cid": case_id_str, "tid": tenant_id}).fetchone()
        total = count_row[0] if count_row else 0

        # Fetch worksheets
        rows = db.execute(text("""
            SELECT id, case_id, tenant_id, version, result_json, created_at
            FROM leverage.leverage_disbursement_worksheets
            WHERE case_id = :cid AND tenant_id = :tid
            ORDER BY version DESC
            LIMIT :lim OFFSET :off
        """), {"cid": case_id_str, "tid": tenant_id, "lim": limit, "off": offset}).fetchall()

        import json as _json
        worksheets = []
        for row in rows:
            result_data = _json.loads(row[4]) if isinstance(row[4], str) else (row[4] or {})
            gross = result_data.get("total_disbursements")
            worksheets.append(SavedWorksheetHeader(
                id=str(row[0]),
                case_id=str(row[1]),
                tenant_id=row[2],
                version=row[3],
                gross_damages=gross,
                created_at=row[5].isoformat() if row[5] else None,
            ))

    except Exception as exc:
        logger.warning("leverage/disbursement/list: DB error for %s/%s — %s", tenant_id, case_id_str, exc)
        return SavedDisbursementListResponse(case_id=case_id_str, tenant_id=tenant_id, worksheets=[], total_versions=0)

    return SavedDisbursementListResponse(
        case_id=case_id_str,
        tenant_id=tenant_id,
        worksheets=worksheets,
        total_versions=total,
    )


@router.get(
    "/case/{case_id}/disbursement/{worksheet_id}",
    response_model=SavedDisbursementDetail,
    summary="Get a specific saved disbursement worksheet",
)
async def get_disbursement_worksheet(
    case_id: UUID,
    worksheet_id: UUID,
    tenant_id: str,
    db: Session = Depends(get_db),
):
    """
    **Get Specific Disbursement Worksheet**

    Returns the full input and result data for a specific saved worksheet.
    """
    import json as _json

    try:
        row = db.execute(text("""
            SELECT id, case_id, tenant_id, version, input_json, result_json, created_at
            FROM leverage.leverage_disbursement_worksheets
            WHERE id = :wsid AND case_id = :cid AND tenant_id = :tid
        """), {"wsid": str(worksheet_id), "cid": str(case_id), "tid": tenant_id}).fetchone()

        if not row:
            from fastapi import HTTPException
            raise HTTPException(status_code=404, detail="Disbursement worksheet not found")

        input_data = _json.loads(row[4]) if isinstance(row[4], str) else (row[4] or {})
        result_data = _json.loads(row[5]) if isinstance(row[5], str) else (row[5] or {})

        return SavedDisbursementDetail(
            id=str(row[0]),
            case_id=str(row[1]),
            tenant_id=row[2],
            version=row[3],
            input_data=input_data,
            result_data=result_data,
            created_at=row[6].isoformat() if row[6] else None,
        )

    except Exception as exc:
        if isinstance(exc, Exception) and hasattr(exc, 'status_code') and exc.status_code == 404:
            raise
        logger.warning("leverage/disbursement/get: DB error — %s", exc)
        raise


# ============================================================================
# COMBINED CASE ECONOMICS (merged damages + disbursement view)
# ============================================================================

class CaseEconomicsResponse(BaseModel):
    """Combined case economics view: latest damages + latest disbursement."""
    case_id: str
    tenant_id: str
    # Latest damages
    damages_version: Optional[int] = None
    gross_damages: Optional[float] = None
    settlement_range_low: Optional[float] = None
    settlement_range_high: Optional[float] = None
    total_economic_damages: Optional[float] = None
    total_non_economic_damages: Optional[float] = None
    # Latest disbursement
    disbursement_version: Optional[int] = None
    total_disbursements: Optional[float] = None
    attorney_fee: Optional[float] = None
    net_to_client: Optional[float] = None
    gross_settlement: Optional[float] = None
    contingency_fee_pct: Optional[float] = None
    minimum_settlement_to_break_even: Optional[float] = None
    # Combined
    net_after_fees_and_costs: Optional[float] = None
    disclaimer: str = ""


@router.get(
    "/case/{case_id}/economics",
    response_model=CaseEconomicsResponse,
    summary="Combined case economics: latest damages + disbursement",
)
async def get_case_economics(
    case_id: UUID,
    tenant_id: str,
    db: Session = Depends(get_db),
):
    """
    **Combined Case Economics**

    Returns the latest saved damages and disbursement worksheets merged into
    a single view. Also computes the net-after-fees-and-costs projection.

    Called by the Customer Portal to display the Case Economics card.
    If no saved worksheets exist, returns null values for the relevant fields.
    """
    import json

    case_id_str = str(case_id)

    try:
        # Latest damages worksheet
        damages_row = db.execute(text("""
            SELECT version, result_json
            FROM leverage.leverage_damages_worksheets
            WHERE case_id = :cid AND tenant_id = :tid
            ORDER BY version DESC LIMIT 1
        """), {"cid": case_id_str, "tid": tenant_id}).fetchone()

        # Latest disbursement worksheet
        disb_row = db.execute(text("""
            SELECT version, result_json
            FROM leverage.leverage_disbursement_worksheets
            WHERE case_id = :cid AND tenant_id = :tid
            ORDER BY version DESC LIMIT 1
        """), {"cid": case_id_str, "tid": tenant_id}).fetchone()

        # Parse damages
        damages_version = None
        gross_damages = None
        settlement_range_low = None
        settlement_range_high = None
        total_economic_damages = None
        total_non_economic_damages = None

        if damages_row:
            damages_version = damages_row[0]
            dr = json.loads(damages_row[1]) if isinstance(damages_row[1], str) else (damages_row[1] or {})
            gross_damages = dr.get("gross_damages")
            settlement_range_low = dr.get("settlement_range_low")
            settlement_range_high = dr.get("settlement_range_high")
            breakdown = dr.get("breakdown", {})
            total_economic_damages = breakdown.get("total_economic_damages")
            total_non_economic_damages = breakdown.get("total_non_economic_damages")

        # Parse disbursement
        disbursement_version = None
        total_disbursements = None
        attorney_fee = None
        net_to_client = None
        gross_settlement = None
        contingency_fee_pct = None
        minimum_settlement_to_break_even = None

        if disb_row:
            disbursement_version = disb_row[0]
            dr = json.loads(disb_row[1]) if isinstance(disb_row[1], str) else (disb_row[1] or {})
            total_disbursements = dr.get("total_disbursements")
            attorney_fee = dr.get("attorney_fee")
            net_to_client = dr.get("net_to_client")
            gross_settlement = dr.get("gross_settlement")
            contingency_fee_pct = dr.get("contingency_fee_pct")
            minimum_settlement_to_break_even = dr.get("minimum_settlement_to_break_even")

        # Combined: net after fees and costs
        # If both gross_damages and total_disbursements are available,
        # compute the projection: gross_damages - attorney_fee - disbursements
        net_after_fees_and_costs = None
        if gross_damages is not None and total_disbursements is not None:
            fee_pct = (contingency_fee_pct or 33.33) / 100.0
            projected_fee = gross_damages * fee_pct
            net_after_fees_and_costs = round(gross_damages - projected_fee - total_disbursements, 2)

    except Exception as exc:
        logger.warning("leverage/case/economics: DB error for %s/%s — %s", tenant_id, case_id_str, exc)
        return CaseEconomicsResponse(
            case_id=case_id_str,
            tenant_id=tenant_id,
            disclaimer="Error retrieving case economics data.",
        )

    return CaseEconomicsResponse(
        case_id=case_id_str,
        tenant_id=tenant_id,
        damages_version=damages_version,
        gross_damages=gross_damages,
        settlement_range_low=settlement_range_low,
        settlement_range_high=settlement_range_high,
        total_economic_damages=total_economic_damages,
        total_non_economic_damages=total_non_economic_damages,
        disbursement_version=disbursement_version,
        total_disbursements=total_disbursements,
        attorney_fee=attorney_fee,
        net_to_client=net_to_client,
        gross_settlement=gross_settlement,
        contingency_fee_pct=contingency_fee_pct,
        minimum_settlement_to_break_even=minimum_settlement_to_break_even,
        net_after_fees_and_costs=net_after_fees_and_costs,
        disclaimer=(
            "This is a calculation tool only. It does not constitute legal or financial advice. "
            "Actual outcomes depend on jurisdiction, evidence, and negotiation. "
            "Net projection assumes the contingency percentage from the disbursement worksheet."
        ),
    )


# ============================================================================
# PI VALUATION MULTIPLIER
# ============================================================================

class ValuationMultiplierEntry(BaseModel):
    """A single state's valuation multiplier config."""
    state: str
    medical_multiplier_low: float
    medical_multiplier_high: float
    comparative_fault_rule: str
    typical_contingency_pct: float
    notes: Optional[str] = None
    source: Optional[str] = None


class ValuationMultiplierListResponse(BaseModel):
    """List of all state multiplier configs."""
    multipliers: List[ValuationMultiplierEntry]
    total: int


class ValuationCalculateRequest(BaseModel):
    """Calculate jurisdiction-aware PI valuation using multipliers."""
    state: str = Field(..., description="Two-letter state code")
    medical_specials_total: float = Field(..., ge=0, description="Total medical specials")
    lost_wages_total: float = Field(0.0, ge=0, description="Total lost wages")
    other_economic_damages: float = Field(0.0, ge=0, description="Other economic damages")
    comparative_fault_pct: float = Field(0.0, ge=0, le=100, description="Plaintiff % fault (if assessed)")
    use_multiplier: Optional[str] = Field("low", description="Which multiplier to use: low | high | both")

    class Config:
        json_schema_extra = {
            "example": {
                "state": "CA",
                "medical_specials_total": 25000,
                "lost_wages_total": 8000,
                "other_economic_damages": 2000,
                "comparative_fault_pct": 0,
                "use_multiplier": "both",
            }
        }


class ValuationRange(BaseModel):
    """Valuation at one multiplier level."""
    multiplier_used: float
    non_economic_damages: float
    total_damages: float
    after_comparative_fault: Optional[float] = None
    after_contingency: Optional[float] = None


class ValuationCalculateResponse(BaseModel):
    """Jurisdiction-aware PI valuation result."""
    state: str
    comparative_fault_rule: str
    medical_specials_total: float
    lost_wages_total: float
    other_economic_damages: float
    total_economic_damages: float
    low_estimate: Optional[ValuationRange] = None
    high_estimate: Optional[ValuationRange] = None
    notes: Optional[str] = None
    disclaimer: str


class CaseValuationResponse(BaseModel):
    """Valuation for a specific case using saved damages + state multiplier."""
    case_id: str
    tenant_id: str
    state: Optional[str] = None
    multiplier: Optional[ValuationMultiplierEntry] = None
    total_economic_damages: Optional[float] = None
    low_estimate: Optional[ValuationRange] = None
    high_estimate: Optional[ValuationRange] = None
    disclaimer: str


@router.get(
    "/valuation/multipliers",
    response_model=ValuationMultiplierListResponse,
    summary="List all state PI valuation multiplier configs",
)
async def list_valuation_multipliers(
    state: Optional[str] = None,
    comparative_fault_rule: Optional[str] = None,
    db: Session = Depends(get_db),
):
    """
    **List Valuation Multipliers**

    Returns all jurisdiction-aware PI valuation multiplier configs.
    Optionally filter by state or comparative_fault_rule.
    """
    try:
        where_clauses = []
        params = {}

        if state:
            where_clauses.append("state = :st")
            params["st"] = state.upper()
        if comparative_fault_rule:
            where_clauses.append("comparative_fault_rule = :cfr")
            params["cfr"] = comparative_fault_rule

        where_sql = " WHERE " + " AND ".join(where_clauses) if where_clauses else ""

        rows = db.execute(text(f"""
            SELECT state, medical_multiplier_low, medical_multiplier_high,
                   comparative_fault_rule, typical_contingency_pct, notes, source
            FROM leverage.leverage_valuation_multipliers
            {where_sql}
            ORDER BY state
        """), params).fetchall()

        multipliers = [
            ValuationMultiplierEntry(
                state=r[0],
                medical_multiplier_low=r[1],
                medical_multiplier_high=r[2],
                comparative_fault_rule=r[3],
                typical_contingency_pct=r[4],
                notes=r[5],
                source=r[6],
            )
            for r in rows
        ]

    except Exception as exc:
        logger.warning("list_valuation_multipliers: DB error — %s", exc)
        return ValuationMultiplierListResponse(multipliers=[], total=0)

    return ValuationMultiplierListResponse(multipliers=multipliers, total=len(multipliers))


@router.get(
    "/valuation/multiplier/{state}",
    response_model=ValuationMultiplierEntry,
    summary="Get PI valuation multiplier for a specific state",
)
async def get_valuation_multiplier(
    state: str,
    db: Session = Depends(get_db),
):
    """
    **Get Valuation Multiplier for a State**

    Returns the jurisdiction-aware PI valuation multiplier config for a state.
    """
    try:
        row = db.execute(text("""
            SELECT state, medical_multiplier_low, medical_multiplier_high,
                   comparative_fault_rule, typical_contingency_pct, notes, source
            FROM leverage.leverage_valuation_multipliers
            WHERE state = :st
        """), {"st": state.upper()}).fetchone()

        if not row:
            raise HTTPException(status_code=404, detail=f"No valuation multiplier found for state {state.upper()}")

    except HTTPException:
        raise
    except Exception as exc:
        logger.warning("get_valuation_multiplier: DB error — %s", exc)
        raise HTTPException(status_code=500, detail="Database error")

    return ValuationMultiplierEntry(
        state=row[0],
        medical_multiplier_low=row[1],
        medical_multiplier_high=row[2],
        comparative_fault_rule=row[3],
        typical_contingency_pct=row[4],
        notes=row[5],
        source=row[6],
    )


@router.post(
    "/valuation/calculate",
    response_model=ValuationCalculateResponse,
    summary="Calculate jurisdiction-aware PI valuation",
)
async def calculate_valuation(
    request: ValuationCalculateRequest,
    db: Session = Depends(get_db),
):
    """
    **Calculate Jurisdiction-Aware PI Valuation**

    Uses the state's valuation multiplier to compute a settlement range:
    - Non-economic damages = medical_specials x multiplier
    - Total damages = economic + non-economic
    - Adjusts for comparative fault if provided
    - Shows net after contingency fee

    The multiplier range (low/high) gives attorneys an evidence-based
    valuation range instead of guessing.
    """
    from fastapi import HTTPException

    # Look up multiplier for this state
    multiplier_entry = None
    try:
        row = db.execute(text("""
            SELECT state, medical_multiplier_low, medical_multiplier_high,
                   comparative_fault_rule, typical_contingency_pct, notes
            FROM leverage.leverage_valuation_multipliers
            WHERE state = :st
        """), {"st": request.state.upper()}).fetchone()

        if row:
            multiplier_entry = {
                "state": row[0],
                "medical_multiplier_low": row[1],
                "medical_multiplier_high": row[2],
                "comparative_fault_rule": row[3],
                "typical_contingency_pct": row[4],
                "notes": row[5],
            }
    except Exception as exc:
        logger.warning("calculate_valuation: DB lookup error — %s", exc)

    total_economic = request.medical_specials_total + request.lost_wages_total + request.other_economic_damages

    if not multiplier_entry:
        return ValuationCalculateResponse(
            state=request.state.upper(),
            comparative_fault_rule="unknown",
            medical_specials_total=request.medical_specials_total,
            lost_wages_total=request.lost_wages_total,
            other_economic_damages=request.other_economic_damages,
            total_economic_damages=total_economic,
            notes="No valuation multiplier found for this state. Cannot compute non-economic estimate.",
            disclaimer="This is a calculation tool only. It does not constitute legal or financial advice.",
        )

    fault_pct = request.comparative_fault_pct / 100.0
    contingency_pct = multiplier_entry["typical_contingency_pct"] / 100.0

    low_mult = multiplier_entry["medical_multiplier_low"]
    high_mult = multiplier_entry["medical_multiplier_high"]

    # Calculate non-economic damages
    low_ne = round(request.medical_specials_total * low_mult, 2)
    high_ne = round(request.medical_specials_total * high_mult, 2)

    # Total damages
    low_total = total_economic + low_ne
    high_total = total_economic + high_ne

    # Adjust for comparative fault
    low_after_fault = round(low_total * (1 - fault_pct), 2) if fault_pct > 0 else low_total
    high_after_fault = round(high_total * (1 - fault_pct), 2) if fault_pct > 0 else high_total

    # After contingency
    low_after_contingency = round(low_after_fault * (1 - contingency_pct), 2)
    high_after_contingency = round(high_after_fault * (1 - contingency_pct), 2)

    low_estimate = ValuationRange(
        multiplier_used=low_mult,
        non_economic_damages=low_ne,
        total_damages=low_total,
        after_comparative_fault=low_after_fault if fault_pct > 0 else None,
        after_contingency=low_after_contingency,
    )

    high_estimate = ValuationRange(
        multiplier_used=high_mult,
        non_economic_damages=high_ne,
        total_damages=high_total,
        after_comparative_fault=high_after_fault if fault_pct > 0 else None,
        after_contingency=high_after_contingency,
    )

    return ValuationCalculateResponse(
        state=request.state.upper(),
        comparative_fault_rule=multiplier_entry["comparative_fault_rule"],
        medical_specials_total=request.medical_specials_total,
        lost_wages_total=request.lost_wages_total,
        other_economic_damages=request.other_economic_damages,
        total_economic_damages=total_economic,
        low_estimate=low_estimate,
        high_estimate=high_estimate,
        notes=multiplier_entry["notes"],
        disclaimer=(
            "This is a calculation tool only. It does not constitute legal or financial advice. "
            "Multiplier ranges are derived from comparative fault rules and industry settlement data. "
            "Actual outcomes depend on evidence, liability strength, and negotiation. "
            f"{multiplier_entry['comparative_fault_rule'].replace('_', ' ').title()} fault rule applies in {request.state.upper()}."
        ),
    )


@router.get(
    "/case/{case_id}/valuation",
    response_model=CaseValuationResponse,
    summary="Get PI valuation for a case using saved damages + state multiplier",
)
async def get_case_valuation(
    case_id: UUID,
    tenant_id: str,
    db: Session = Depends(get_db),
):
    """
    **Case Valuation**

    Retrieves the latest saved damages worksheet for a case, looks up the
    state's valuation multiplier from the case profile, and computes a
    jurisdiction-aware settlement valuation range.

    If no saved damages or case state exists, returns null estimates.
    """
    import json
    from fastapi import HTTPException

    case_id_str = str(case_id)

    try:
        # Get case state from profile
        profile = db.execute(text("""
            SELECT state FROM leverage.leverage_case_profiles
            WHERE case_id = :cid AND tenant_id = :tid
        """), {"cid": case_id_str, "tid": tenant_id}).fetchone()

        case_state = profile[0] if profile else None

        # Get latest damages worksheet
        damages_row = db.execute(text("""
            SELECT result_json
            FROM leverage.leverage_damages_worksheets
            WHERE case_id = :cid AND tenant_id = :tid
            ORDER BY version DESC LIMIT 1
        """), {"cid": case_id_str, "tid": tenant_id}).fetchone()

        if not damages_row or not case_state:
            return CaseValuationResponse(
                case_id=case_id_str,
                tenant_id=tenant_id,
                state=case_state,
                disclaimer="Cannot compute valuation: missing case state or saved damages worksheet.",
            )

        # Parse damages
        dr = json.loads(damages_row[0]) if isinstance(damages_row[0], str) else (damages_row[0] or {})
        breakdown = dr.get("breakdown", {})
        total_economic = breakdown.get("total_economic_damages", 0) or 0
        medical_specials = 0
        # Try to get medical total from the breakdown
        if breakdown.get("medical_expenses"):
            medical_specials = sum(v for v in breakdown["medical_expenses"].values() if isinstance(v, (int, float)))
        else:
            # Fallback: use total_economic as approximation
            medical_specials = total_economic * 0.7  # Medical typically 60-80% of economic

        # Get multiplier for state
        mult_row = db.execute(text("""
            SELECT state, medical_multiplier_low, medical_multiplier_high,
                   comparative_fault_rule, typical_contingency_pct, notes, source
            FROM leverage.leverage_valuation_multipliers
            WHERE state = :st
        """), {"st": case_state}).fetchone()

        if not mult_row:
            return CaseValuationResponse(
                case_id=case_id_str,
                tenant_id=tenant_id,
                state=case_state,
                total_economic_damages=total_economic,
                disclaimer=f"No valuation multiplier found for state {case_state}.",
            )

        multiplier = ValuationMultiplierEntry(
            state=mult_row[0],
            medical_multiplier_low=mult_row[1],
            medical_multiplier_high=mult_row[2],
            comparative_fault_rule=mult_row[3],
            typical_contingency_pct=mult_row[4],
            notes=mult_row[5],
            source=mult_row[6],
        )

        # Compute valuation
        low_ne = round(medical_specials * multiplier.medical_multiplier_low, 2)
        high_ne = round(medical_specials * multiplier.medical_multiplier_high, 2)
        low_total = total_economic + low_ne
        high_total = total_economic + high_ne
        contingency_pct = multiplier.typical_contingency_pct / 100.0

        low_estimate = ValuationRange(
            multiplier_used=multiplier.medical_multiplier_low,
            non_economic_damages=low_ne,
            total_damages=low_total,
            after_contingency=round(low_total * (1 - contingency_pct), 2),
        )
        high_estimate = ValuationRange(
            multiplier_used=multiplier.medical_multiplier_high,
            non_economic_damages=high_ne,
            total_damages=high_total,
            after_contingency=round(high_total * (1 - contingency_pct), 2),
        )

    except Exception as exc:
        logger.warning("get_case_valuation: error for %s/%s — %s", tenant_id, case_id_str, exc)
        return CaseValuationResponse(
            case_id=case_id_str,
            tenant_id=tenant_id,
            disclaimer="Error computing case valuation.",
        )

    return CaseValuationResponse(
        case_id=case_id_str,
        tenant_id=tenant_id,
        state=case_state,
        multiplier=multiplier,
        total_economic_damages=total_economic,
        low_estimate=low_estimate,
        high_estimate=high_estimate,
        disclaimer=(
            "This is a calculation tool only. It does not constitute legal or financial advice. "
            "Multiplier ranges are derived from comparative fault rules and industry settlement data. "
            "Actual outcomes depend on evidence, liability strength, and negotiation."
        ),
    )

