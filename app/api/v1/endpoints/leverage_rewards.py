"""
TrueVow LEVERAGE™ — Reward Credit Endpoints

Grant triggers:
1. POST /leverage/onboard           — 11 welcome-bonus credits on first retained client
2. POST /leverage/settlement-reward — 1 credit per settlement submitted

Portal display endpoints:
3. GET  /leverage/rewards/balance   — Active credit count (lightweight)
4. GET  /leverage/rewards/ledger    — Full transaction history
5. GET  /leverage/rewards/summary   — Enriched balance with breakdown + expiration

Both grant endpoints are fire-and-forget from the platform perspective.
They return success even if billing service is unavailable (fail-open).

The Billing Service owns the canonical reward ledger with FIFO expiration logic.
This service maintains a local projection (leverage.leverage_reward_ledger) so
the Customer Portal can display transaction history without calling Billing
on every page load. Grant endpoints write to the local ledger on success.
"""

from datetime import datetime, timezone, timedelta
from typing import Optional, List

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session
from sqlalchemy import text
import logging

from app.core.database import get_db
from app.services.billing_service import get_billing_service, BillingServiceUnavailable

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/leverage", tags=["LEVERAGE - Rewards"])

WELCOME_BONUS_CREDITS = 11   # Matches Growth tier included unlocks
SETTLEMENT_BONUS_CREDITS = 1  # One credit per settled case
CREDIT_EXPIRY_MONTHS = 3     # Credits expire 3 months from grant


# ============================================================================
# REQUEST / RESPONSE SCHEMAS
# ============================================================================

class OnboardRequest(BaseModel):
    """
    Trigger the LEVERAGE welcome bonus for a newly retained first client.
    Called by the platform when attorney marks first client as retained.
    """
    tenant_id: str = Field(..., description="Tenant UUID")
    user_id: Optional[str] = Field(None, description="Attorney user ID (optional)")

    class Config:
        json_schema_extra = {
            "example": {
                "tenant_id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
                "user_id": "clerk_abc123"
            }
        }


class SettlementRewardRequest(BaseModel):
    """
    Grant 1 LEVERAGE credit when a case settlement is submitted.
    Called by the platform when attorney records a settlement outcome.
    """
    tenant_id: str = Field(..., description="Tenant UUID")
    case_id: Optional[str] = Field(None, description="Case/matter reference (for audit)")
    user_id: Optional[str] = Field(None, description="Attorney user ID (optional)")

    class Config:
        json_schema_extra = {
            "example": {
                "tenant_id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
                "case_id": "case-2024-001",
                "user_id": "clerk_abc123"
            }
        }


class RewardGrantResponse(BaseModel):
    success: bool
    credits_granted: int
    source: str
    message: str
    billing_available: bool


# ============================================================================
# LEDGER / SUMMARY SCHEMAS
# ============================================================================

class RewardLedgerEntry(BaseModel):
    """A single reward transaction in the ledger."""
    id: str
    credits: int
    source: str
    status: str
    reference_case_id: Optional[str] = None
    granted_at: Optional[str] = None
    expires_at: Optional[str] = None
    consumed_at: Optional[str] = None


class RewardLedgerResponse(BaseModel):
    """Full transaction history for a tenant's reward credits."""
    tenant_id: str
    entries: List[RewardLedgerEntry]
    total_entries: int


class RewardSummaryResponse(BaseModel):
    """Enriched balance with breakdown and expiration info."""
    tenant_id: str
    active_credits: int
    total_granted: int
    total_used: int
    total_expired: int
    welcome_bonus_granted: bool
    welcome_bonus_granted_at: Optional[str] = None
    settlement_credits_earned: int
    next_expiration_date: Optional[str] = None
    next_expiration_credits: Optional[int] = None


# ============================================================================
# ENDPOINTS
# ============================================================================

@router.post(
    "/onboard",
    response_model=RewardGrantResponse,
    status_code=status.HTTP_200_OK,
    summary="Grant 11 welcome-bonus LEVERAGE credits on first retained client",
)
async def leverage_onboard(request: OnboardRequest):
    """
    **LEVERAGE Welcome Bonus**

    Called once when the attorney marks their first client as retained.
    Grants 11 reward credits — each valid for 3 months.

    - Idempotent: billing service deduplicates by `source='welcome_bonus'`
    - Fail-open: returns success even if billing service is unavailable
    - Unlocks the LEVERAGE sidebar in the portal
    """
    billing = get_billing_service()
    billing_available = True

    try:
        granted = await billing.grant_rewards(
            tenant_id=request.tenant_id,
            credits=WELCOME_BONUS_CREDITS,
            source="welcome_bonus",
        )
        if not granted:
            logger.warning(
                "leverage/onboard: billing returned false for tenant %s",
                request.tenant_id,
            )

    except BillingServiceUnavailable:
        billing_available = False
        logger.warning(
            "leverage/onboard: billing unavailable for %s — proceeding fail-open",
            request.tenant_id,
        )
    except Exception as exc:
        billing_available = False
        logger.warning(
            "leverage/onboard: unexpected error for %s — %s — proceeding fail-open",
            request.tenant_id, exc,
        )

    # Write to local reward ledger
    try:
        db = request._db if hasattr(request, '_db') else None
        if db is None:
            from app.core.database import SessionLocal
            db = SessionLocal()
            _close_db = True
        else:
            _close_db = False

        db.execute(text("""
            INSERT INTO leverage.leverage_reward_ledger
                (tenant_id, credits, source, status, expires_at)
            VALUES (:tid, :credits, 'welcome_bonus', 'active', NOW() + INTERVAL '3 months')
        """), {"tid": request.tenant_id, "credits": WELCOME_BONUS_CREDITS})
        db.commit()
        if _close_db:
            db.close()
    except Exception as ledger_exc:
        logger.warning("leverage/onboard: local ledger write failed for %s — %s", request.tenant_id, ledger_exc)
        # Non-fatal — the grant still succeeded via billing service

    return RewardGrantResponse(
        success=True,
        credits_granted=WELCOME_BONUS_CREDITS,
        source="welcome_bonus",
        message=(
            f"{WELCOME_BONUS_CREDITS} LEVERAGE credits granted. "
            "Each credit is valid for 3 months."
        ),
        billing_available=billing_available,
    )


@router.post(
    "/settlement-reward",
    response_model=RewardGrantResponse,
    status_code=status.HTTP_200_OK,
    summary="Grant 1 LEVERAGE credit when a settlement is submitted",
)
async def settlement_reward(request: SettlementRewardRequest):
    """
    **LEVERAGE Settlement Reward**

    Called when the attorney submits a settlement outcome via the platform.
    Grants 1 reward credit valid for 3 months.

    This creates the behavioral flywheel:
    - Attorney records settlement → earns free LEVERAGE credit
    - Uses LEVERAGE credit on next case → validates document
    - Validates document → platform captures more settlement data

    Fail-open: returns success even if billing service is unavailable.
    """
    billing = get_billing_service()
    billing_available = True

    try:
        granted = await billing.grant_rewards(
            tenant_id=request.tenant_id,
            credits=SETTLEMENT_BONUS_CREDITS,
            source="settlement",
        )
        if not granted:
            logger.warning(
                "leverage/settlement-reward: billing returned false for tenant %s (case %s)",
                request.tenant_id, request.case_id,
            )

    except BillingServiceUnavailable:
        billing_available = False
        logger.warning(
            "leverage/settlement-reward: billing unavailable for %s — proceeding fail-open",
            request.tenant_id,
        )
    except Exception as exc:
        billing_available = False
        logger.warning(
            "leverage/settlement-reward: unexpected error for %s — %s — proceeding fail-open",
            request.tenant_id, exc,
        )

    # Write to local reward ledger
    try:
        from app.core.database import SessionLocal
        db = SessionLocal()
        db.execute(text("""
            INSERT INTO leverage.leverage_reward_ledger
                (tenant_id, credits, source, status, reference_case_id, expires_at)
            VALUES (:tid, :credits, 'settlement', 'active', :case_id, NOW() + INTERVAL '3 months')
        """), {
            "tid": request.tenant_id,
            "credits": SETTLEMENT_BONUS_CREDITS,
            "case_id": request.case_id,
        })
        db.commit()
        db.close()
    except Exception as ledger_exc:
        logger.warning("leverage/settlement-reward: local ledger write failed for %s — %s", request.tenant_id, ledger_exc)

    logger.info(
        "leverage/settlement-reward: +%d credit for tenant %s (case %s)",
        SETTLEMENT_BONUS_CREDITS, request.tenant_id, request.case_id,
    )

    return RewardGrantResponse(
        success=True,
        credits_granted=SETTLEMENT_BONUS_CREDITS,
        source="settlement",
        message="1 LEVERAGE credit earned for submitting settlement. Valid for 3 months.",
        billing_available=billing_available,
    )


# ============================================================================
# REWARD BALANCE QUERY (used by Customer Portal proxy)
# ============================================================================

class RewardBalanceResponse(BaseModel):
    tenant_id: str
    active_credits: int


@router.get(
    "/rewards/balance",
    response_model=RewardBalanceResponse,
    summary="Return active LEVERAGE reward credits for a tenant",
)
async def get_reward_balance(tenant_id: str):
    """
    Returns the count of unexpired LEVERAGE reward credits.
    Called by the Customer Portal proxy route.
    Fails open — returns 0 if billing service unavailable.
    """
    billing = get_billing_service()
    try:
        count = await billing.get_active_reward_count(tenant_id)
        return RewardBalanceResponse(tenant_id=tenant_id, active_credits=count)
    except BillingServiceUnavailable:
        return RewardBalanceResponse(tenant_id=tenant_id, active_credits=0)
    except Exception as exc:
        logger.warning("leverage/rewards/balance: error for %s — %s", tenant_id, exc)
        return RewardBalanceResponse(tenant_id=tenant_id, active_credits=0)


# ============================================================================
# REWARD LEDGER (full transaction history)
# ============================================================================

@router.get(
    "/rewards/ledger",
    response_model=RewardLedgerResponse,
    summary="Return full reward transaction history for a tenant",
)
async def get_reward_ledger(
    tenant_id: str,
    db: Session = Depends(get_db),
    limit: int = 50,
    offset: int = 0,
):
    """
    **LEVERAGE Reward Ledger**

    Returns the full transaction history for a tenant's LEVERAGE reward credits.
    Each entry shows: credits, source, status, dates (granted, expires, consumed).

    Called by the Customer Portal to display the reward history card.
    Fails open — returns empty list if DB unavailable.
    """
    limit = min(max(limit, 1), 200)
    offset = max(offset, 0)

    try:
        # Count total
        count_row = db.execute(text("""
            SELECT COUNT(*) FROM leverage.leverage_reward_ledger
            WHERE tenant_id = :tid
        """), {"tid": tenant_id}).fetchone()
        total = count_row[0] if count_row else 0

        # Fetch entries
        rows = db.execute(text("""
            SELECT id, credits, source, status, reference_case_id,
                   granted_at, expires_at, consumed_at
            FROM leverage.leverage_reward_ledger
            WHERE tenant_id = :tid
            ORDER BY granted_at DESC
            LIMIT :lim OFFSET :off
        """), {"tid": tenant_id, "lim": limit, "off": offset}).fetchall()

        entries = [
            RewardLedgerEntry(
                id=str(row[0]),
                credits=row[1],
                source=row[2],
                status=row[3],
                reference_case_id=str(row[4]) if row[4] else None,
                granted_at=row[5].isoformat() if row[5] else None,
                expires_at=row[6].isoformat() if row[6] else None,
                consumed_at=row[7].isoformat() if row[7] else None,
            )
            for row in rows
        ]

    except Exception as exc:
        logger.warning("leverage/rewards/ledger: DB error for %s — %s", tenant_id, exc)
        return RewardLedgerResponse(tenant_id=tenant_id, entries=[], total_entries=0)

    return RewardLedgerResponse(
        tenant_id=tenant_id,
        entries=entries,
        total_entries=total,
    )


# ============================================================================
# REWARD SUMMARY (enriched balance with breakdown)
# ============================================================================

@router.get(
    "/rewards/summary",
    response_model=RewardSummaryResponse,
    summary="Return enriched reward balance with breakdown and expiration",
)
async def get_reward_summary(
    tenant_id: str,
    db: Session = Depends(get_db),
):
    """
    **LEVERAGE Reward Summary**

    Returns enriched balance information including:
    - Active, used, expired credit counts
    - Welcome bonus status (granted yes/no, date)
    - Settlement credits earned count
    - Next upcoming expiration date and credit count

    Called by the Customer Portal to display the reward balance card.
    Fails open — returns zeros if DB unavailable.
    """
    try:
        # Aggregate counts by status
        status_rows = db.execute(text("""
            SELECT status, SUM(credits) as total_credits
            FROM leverage.leverage_reward_ledger
            WHERE tenant_id = :tid
            GROUP BY status
        """), {"tid": tenant_id}).fetchall()

        active_credits = 0
        total_granted = 0
        total_used = 0
        total_expired = 0

        for row in status_rows:
            s, c = row[0], int(row[1] or 0)
            total_granted += c  # All grants regardless of status
            if s == "active":
                active_credits = c
            elif s == "used":
                total_used = c
            elif s == "expired":
                total_expired = c

        # Also count consumed entries (credits = -1 for consume events)
        consumed_row = db.execute(text("""
            SELECT COALESCE(SUM(ABS(credits)), 0)
            FROM leverage.leverage_reward_ledger
            WHERE tenant_id = :tid AND source = 'consumed'
        """), {"tid": tenant_id}).fetchone()
        if consumed_row and consumed_row[0]:
            total_used = max(total_used, int(consumed_row[0]))

        # Welcome bonus status
        wb_row = db.execute(text("""
            SELECT granted_at
            FROM leverage.leverage_reward_ledger
            WHERE tenant_id = :tid AND source = 'welcome_bonus'
            ORDER BY granted_at DESC LIMIT 1
        """), {"tid": tenant_id}).fetchone()
        welcome_bonus_granted = wb_row is not None
        welcome_bonus_granted_at = wb_row[0].isoformat() if wb_row else None

        # Settlement credits count
        settle_row = db.execute(text("""
            SELECT COALESCE(SUM(credits), 0)
            FROM leverage.leverage_reward_ledger
            WHERE tenant_id = :tid AND source = 'settlement' AND status = 'active'
        """), {"tid": tenant_id}).fetchone()
        settlement_credits_earned = int(settle_row[0] or 0) if settle_row else 0

        # Next expiration
        next_exp_row = db.execute(text("""
            SELECT expires_at, SUM(credits) as expiring_credits
            FROM leverage.leverage_reward_ledger
            WHERE tenant_id = :tid AND status = 'active' AND expires_at IS NOT NULL
            GROUP BY expires_at
            ORDER BY expires_at ASC
            LIMIT 1
        """), {"tid": tenant_id}).fetchone()
        next_expiration_date = next_exp_row[0].isoformat() if next_exp_row else None
        next_expiration_credits = int(next_exp_row[1] or 0) if next_exp_row else None

    except Exception as exc:
        logger.warning("leverage/rewards/summary: DB error for %s — %s", tenant_id, exc)
        return RewardSummaryResponse(
            tenant_id=tenant_id,
            active_credits=0,
            total_granted=0,
            total_used=0,
            total_expired=0,
            welcome_bonus_granted=False,
            settlement_credits_earned=0,
        )

    return RewardSummaryResponse(
        tenant_id=tenant_id,
        active_credits=active_credits,
        total_granted=total_granted,
        total_used=total_used,
        total_expired=total_expired,
        welcome_bonus_granted=welcome_bonus_granted,
        welcome_bonus_granted_at=welcome_bonus_granted_at,
        settlement_credits_earned=settlement_credits_earned,
        next_expiration_date=next_expiration_date,
        next_expiration_credits=next_expiration_credits,
    )
