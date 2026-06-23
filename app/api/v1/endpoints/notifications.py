"""
TrueVow LEVERAGE -- Notification System Endpoints

SOL/compliance urgency notification system for the Customer Portal.
Scope: Only deadline urgency and compliance flag alerts.
NOT a general-purpose case management notification system.

Endpoints:
  POST /leverage/notifications/subscribe         -- Register a notification subscription
  GET  /leverage/notifications/subscriptions       -- List subscriptions for a tenant/user
  DELETE /leverage/notifications/subscriptions/{id} -- Deactivate a subscription
  GET  /leverage/notifications/log                  -- View notification delivery log
  POST /leverage/notifications/test                 -- Send a test notification

Event types:
  - deadline.critical   : SOL deadline within 30 days
  - deadline.overdue    : SOL deadline has passed
  - compliance.flag_added : New compliance flag detected (e.g., liability contested)
  - settlement.nudge    : Case past estimated settlement window, prompt for details

Architecture:
  - Webhooks are fire-and-forget (fail-open, same as billing service).
  - In-app notifications are persisted to leverage_notification_log.
  - Subscriptions are per (tenant_id, user_id) -- Clerk user ID.
"""

import json
from datetime import datetime, timezone
from typing import Optional, List
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session
from sqlalchemy import text
import httpx
import logging

from app.core.database import get_db

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/leverage/notifications", tags=["LEVERAGE - Notifications"])


# ============================================================================
# REQUEST / RESPONSE SCHEMAS
# ============================================================================

class NotificationSubscribeRequest(BaseModel):
    """Register a notification subscription for SOL/compliance alerts."""
    tenant_id: str = Field(..., description="Tenant UUID")
    user_id: str = Field(..., description="Clerk user ID")
    channel: str = Field("in_app", description="webhook | in_app")
    webhook_url: Optional[str] = Field(None, description="Required when channel=webhook")
    event_types: List[str] = Field(
        default=["deadline.critical", "deadline.overdue", "compliance.flag_added", "settlement.nudge"],
        description="List of event types to subscribe to",
    )

    class Config:
        json_schema_extra = {
            "example": {
                "tenant_id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
                "user_id": "clerk_abc123",
                "channel": "webhook",
                "webhook_url": "https://hooks.slack.com/services/T00/B00/xxx",
                "event_types": ["deadline.critical", "deadline.overdue", "settlement.nudge"],
            }
        }


class NotificationSubscriptionResponse(BaseModel):
    id: str
    tenant_id: str
    user_id: str
    channel: str
    webhook_url: Optional[str] = None
    event_types: List[str]
    is_active: bool
    created_at: Optional[str] = None


class NotificationLogEntry(BaseModel):
    id: str
    tenant_id: str
    user_id: Optional[str] = None
    case_id: Optional[str] = None
    event_type: str
    severity: str
    payload: Optional[dict] = None
    channel: str
    delivery_status: str
    created_at: Optional[str] = None
    delivered_at: Optional[str] = None


class TestNotificationRequest(BaseModel):
    tenant_id: str = Field(..., description="Tenant UUID")
    user_id: str = Field(..., description="Clerk user ID")
    channel: str = Field("in_app", description="webhook | in_app")
    webhook_url: Optional[str] = None


class TestNotificationResponse(BaseModel):
    success: bool
    message: str
    subscription_id: Optional[str] = None


# ============================================================================
# VALIDATION
# ============================================================================

VALID_EVENT_TYPES = {
    "deadline.critical",
    "deadline.overdue",
    "compliance.flag_added",
    "settlement.nudge",
}

VALID_CHANNELS = {"webhook", "in_app"}


# ============================================================================
# HELPER: Fire a notification to all matching subscriptions
# ============================================================================

async def fire_notification(
    tenant_id: str,
    event_type: str,
    severity: str,
    payload: dict,
    case_id: Optional[str] = None,
    db: Optional[Session] = None,
) -> int:
    """
    Fire a notification to all active subscriptions matching this event type.
    Returns the number of notifications dispatched.

    This is called from leverage_case.py and deadlines.py when urgency events occur.
    Webhook delivery is fire-and-forget (fail-open).
    """
    if db is None:
        return 0

    dispatched = 0

    try:
        # Find all active subscriptions for this tenant that include this event_type
        rows = db.execute(text("""
            SELECT id, user_id, channel, webhook_url, event_types
            FROM leverage.leverage_notification_subscriptions
            WHERE tenant_id = :tid AND is_active = TRUE
        """), {"tid": tenant_id}).fetchall()

        for row in rows:
            sub_id = str(row[0])
            user_id = row[1]
            channel = row[2]
            webhook_url = row[3]
            subscribed_events = row[4]

            # Check if this subscription includes the event type
            if subscribed_events:
                try:
                    events_list = json.loads(subscribed_events) if isinstance(subscribed_events, str) else subscribed_events
                except (json.JSONDecodeError, TypeError):
                    events_list = []
                if event_type not in events_list:
                    continue

            # Log the notification
            delivery_status = "pending"

            if channel == "webhook" and webhook_url:
                # Fire-and-forget webhook delivery
                try:
                    async with httpx.AsyncClient(timeout=5.0) as client:
                        resp = await client.post(
                            webhook_url,
                            json={
                                "event_type": event_type,
                                "severity": severity,
                                "tenant_id": tenant_id,
                                "case_id": case_id,
                                "payload": payload,
                                "timestamp": datetime.now(timezone.utc).isoformat(),
                            },
                        )
                        delivery_status = "sent" if resp.status_code < 400 else "failed"
                except Exception as exc:
                    delivery_status = "failed"
                    logger.warning("fire_notification: webhook failed for %s — %s", webhook_url, exc)
            elif channel == "in_app":
                # In-app notifications are just logged; portal reads the log
                delivery_status = "sent"

            # Persist to notification log
            db.execute(text("""
                INSERT INTO leverage.leverage_notification_log (
                    tenant_id, user_id, case_id, event_type, severity,
                    payload, channel, delivery_status, created_at, delivered_at
                ) VALUES (
                    :tid, :uid, :cid, :etype, :sev,
                    :payload, :channel, :dstatus, :created, :delivered
                )
            """), {
                "tid": tenant_id,
                "uid": user_id,
                "cid": case_id,
                "etype": event_type,
                "sev": severity,
                "payload": json.dumps(payload),
                "channel": channel,
                "dstatus": delivery_status,
                "created": datetime.now(timezone.utc),
                "delivered": datetime.now(timezone.utc) if delivery_status == "sent" else None,
            })

            dispatched += 1

        db.commit()

    except Exception as exc:
        db.rollback()
        logger.warning("fire_notification: DB error for tenant %s — %s (non-fatal)", tenant_id, exc)

    return dispatched


# ============================================================================
# ENDPOINTS
# ============================================================================

@router.post(
    "/subscribe",
    response_model=NotificationSubscriptionResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Register a notification subscription",
)
async def subscribe_notifications(
    request: NotificationSubscribeRequest,
    db: Session = Depends(get_db),
):
    """
    **Subscribe to LEVERAGE Notifications**

    Register a webhook or in-app notification subscription for SOL urgency,
    compliance flags, or settlement nudges.

    - channel=webhook: requires webhook_url; LEVERAGE POSTs JSON events to the URL
    - channel=in_app: notifications are logged; portal reads the log endpoint
    - event_types: filter which events you receive
    """
    # Validate channel
    if request.channel not in VALID_CHANNELS:
        raise HTTPException(status_code=400, detail=f"Invalid channel. Must be one of: {VALID_CHANNELS}")

    # Validate webhook_url requirement
    if request.channel == "webhook" and not request.webhook_url:
        raise HTTPException(status_code=400, detail="webhook_url is required when channel=webhook")

    # Validate event types
    invalid = set(request.event_types) - VALID_EVENT_TYPES
    if invalid:
        raise HTTPException(status_code=400, detail=f"Invalid event types: {invalid}. Valid: {VALID_EVENT_TYPES}")

    try:
        row = db.execute(text("""
            INSERT INTO leverage.leverage_notification_subscriptions (
                tenant_id, user_id, channel, webhook_url, event_types
            ) VALUES (
                :tid, :uid, :channel, :url, :events
            )
            RETURNING id, created_at
        """), {
            "tid": request.tenant_id,
            "uid": request.user_id,
            "channel": request.channel,
            "url": request.webhook_url,
            "events": json.dumps(request.event_types),
        }).fetchone()

        db.commit()

        return NotificationSubscriptionResponse(
            id=str(row[0]),
            tenant_id=request.tenant_id,
            user_id=request.user_id,
            channel=request.channel,
            webhook_url=request.webhook_url,
            event_types=request.event_types,
            is_active=True,
            created_at=row[1].isoformat() if row[1] else None,
        )

    except Exception as exc:
        db.rollback()
        logger.error("subscribe_notifications: DB error — %s", exc)
        raise HTTPException(status_code=500, detail="Failed to create subscription")


@router.get(
    "/subscriptions",
    response_model=List[NotificationSubscriptionResponse],
    summary="List notification subscriptions for a tenant/user",
)
async def list_subscriptions(
    tenant_id: str,
    user_id: Optional[str] = None,
    db: Session = Depends(get_db),
):
    """List all notification subscriptions for a tenant, optionally filtered by user_id."""
    try:
        if user_id:
            rows = db.execute(text("""
                SELECT id, tenant_id, user_id, channel, webhook_url, event_types, is_active, created_at
                FROM leverage.leverage_notification_subscriptions
                WHERE tenant_id = :tid AND user_id = :uid
                ORDER BY created_at DESC
            """), {"tid": tenant_id, "uid": user_id}).fetchall()
        else:
            rows = db.execute(text("""
                SELECT id, tenant_id, user_id, channel, webhook_url, event_types, is_active, created_at
                FROM leverage.leverage_notification_subscriptions
                WHERE tenant_id = :tid
                ORDER BY created_at DESC
            """), {"tid": tenant_id}).fetchall()

        return [
            NotificationSubscriptionResponse(
                id=str(r[0]),
                tenant_id=r[1],
                user_id=r[2],
                channel=r[3],
                webhook_url=r[4],
                event_types=json.loads(r[5]) if r[5] else [],
                is_active=r[6],
                created_at=r[7].isoformat() if r[7] else None,
            )
            for r in rows
        ]

    except Exception as exc:
        logger.warning("list_subscriptions: DB error — %s", exc)
        return []


@router.delete(
    "/subscriptions/{sub_id}",
    summary="Deactivate a notification subscription",
)
async def deactivate_subscription(
    sub_id: str,
    tenant_id: str,
    db: Session = Depends(get_db),
):
    """Deactivate a notification subscription (soft delete)."""
    try:
        result = db.execute(text("""
            UPDATE leverage.leverage_notification_subscriptions
            SET is_active = FALSE, updated_at = now()
            WHERE id = :sid AND tenant_id = :tid AND is_active = TRUE
        """), {"sid": sub_id, "tid": tenant_id})

        if result.rowcount == 0:
            raise HTTPException(status_code=404, detail="Active subscription not found")

        db.commit()
        return {"success": True, "message": "Subscription deactivated"}

    except HTTPException:
        raise
    except Exception as exc:
        db.rollback()
        logger.error("deactivate_subscription: DB error — %s", exc)
        raise HTTPException(status_code=500, detail="Failed to deactivate subscription")


@router.get(
    "/log",
    response_model=List[NotificationLogEntry],
    summary="View notification delivery log for a tenant",
)
async def get_notification_log(
    tenant_id: str,
    case_id: Optional[str] = None,
    event_type: Optional[str] = None,
    limit: int = 50,
    offset: int = 0,
    db: Session = Depends(get_db),
):
    """
    View notification delivery log for a tenant.

    Query params:
        tenant_id: Required — tenant scope
        case_id: Optional — filter to a specific case
        event_type: Optional — filter to a specific event type
        limit: Max results (default 50, max 200)
        offset: Pagination offset
    """
    limit = min(max(limit, 1), 200)
    offset = max(offset, 0)

    try:
        where_clauses = ["tenant_id = :tid"]
        params = {"tid": tenant_id}

        if case_id:
            where_clauses.append("case_id = :cid")
            params["cid"] = case_id
        if event_type:
            where_clauses.append("event_type = :etype")
            params["etype"] = event_type

        where_sql = " AND ".join(where_clauses)

        rows = db.execute(text(f"""
            SELECT id, tenant_id, user_id, case_id, event_type, severity,
                   payload, channel, delivery_status, created_at, delivered_at
            FROM leverage.leverage_notification_log
            WHERE {where_sql}
            ORDER BY created_at DESC
            LIMIT :lim OFFSET :off
        """), {**params, "lim": limit, "off": offset}).fetchall()

        return [
            NotificationLogEntry(
                id=str(r[0]),
                tenant_id=r[1],
                user_id=r[2],
                case_id=str(r[3]) if r[3] else None,
                event_type=r[4],
                severity=r[5],
                payload=json.loads(r[6]) if r[6] else None,
                channel=r[7],
                delivery_status=r[8],
                created_at=r[9].isoformat() if r[9] else None,
                delivered_at=r[10].isoformat() if r[10] else None,
            )
            for r in rows
        ]

    except Exception as exc:
        logger.warning("get_notification_log: DB error — %s", exc)
        return []


@router.post(
    "/test",
    response_model=TestNotificationResponse,
    summary="Send a test notification to verify webhook",
)
async def test_notification(
    request: TestNotificationRequest,
    db: Session = Depends(get_db),
):
    """
    **Test Notification**

    Send a test notification to verify webhook delivery or in-app logging.
    Creates a temporary subscription if one doesn't exist, fires a test event,
    then reports the result.
    """
    if request.channel == "webhook" and not request.webhook_url:
        raise HTTPException(status_code=400, detail="webhook_url is required when channel=webhook")

    # Create or reuse a subscription
    try:
        existing = db.execute(text("""
            SELECT id FROM leverage.leverage_notification_subscriptions
            WHERE tenant_id = :tid AND user_id = :uid AND channel = :channel AND is_active = TRUE
            LIMIT 1
        """), {
            "tid": request.tenant_id,
            "uid": request.user_id,
            "channel": request.channel,
        }).fetchone()

        if existing:
            sub_id = str(existing[0])
        else:
            row = db.execute(text("""
                INSERT INTO leverage.leverage_notification_subscriptions (
                    tenant_id, user_id, channel, webhook_url, event_types
                ) VALUES (:tid, :uid, :channel, :url, :events)
                RETURNING id
            """), {
                "tid": request.tenant_id,
                "uid": request.user_id,
                "channel": request.channel,
                "url": request.webhook_url,
                "events": json.dumps(["deadline.critical"]),
            }).fetchone()
            sub_id = str(row[0])

        db.commit()

    except Exception as exc:
        db.rollback()
        logger.error("test_notification: subscription create error — %s", exc)
        return TestNotificationResponse(success=False, message=f"Failed to create subscription: {exc}")

    # Fire test notification
    test_payload = {
        "test": True,
        "message": "This is a test notification from LEVERAGE",
        "event_type": "deadline.critical",
        "severity": "warning",
    }

    dispatched = await fire_notification(
        tenant_id=request.tenant_id,
        event_type="deadline.critical",
        severity="warning",
        payload=test_payload,
        db=db,
    )

    return TestNotificationResponse(
        success=dispatched > 0,
        message=f"Test notification {'delivered' if dispatched > 0 else 'failed — no matching subscriptions'}",
        subscription_id=sub_id,
    )
