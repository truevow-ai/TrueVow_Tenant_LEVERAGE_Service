# app/core/event_emitter.py
"""
LEVERAGE Service — Behavioral Event Emitter

Fire-and-forget HTTP emitter that sends service-level behavioral events
to SaaS Admin's portal-events ingest endpoint.

Events emitted by LEVERAGE:
    compliance.validation_run — Compliance check completed
    statute.warning           — SOL deadline is critical or overdue
    compliance.cleared        — Case compliance passed with no flags

Architectural boundary:
    LEVERAGE emits DATA ONLY.  It never computes metrics, health scores,
    or recommendations.  Those belong to SaaS Admin (Layer 2).

Usage::

    emitter = LeverageEventEmitter(tenant_id=request.tenant_id, case_id=case_id)
    await emitter.emit("statute.warning", metadata={"days_remaining": 42})
"""

from __future__ import annotations

import logging
from datetime import datetime, timezone
from typing import Any, Dict, Optional

import httpx

from app.core.config import settings

logger = logging.getLogger(__name__)

DRAFT_EVENT_TYPES = frozenset({
    "document_validated",
    "document_validation_failed",
})

LEVERAGE_EVENT_TYPES = frozenset({
    "compliance.validation_run",
    "statute.warning",
    "compliance.cleared",
    # ── Settlement intelligence events (Feature C) ──────────────────────────
    "settlement.details_captured",
    "settlement.nudge",
    "settlement.window_set",
})


class DraftEventEmitter:
    """Fire-and-forget behavioral event emitter for the DRAFT Service.

    Never raises — a tracking failure must never break the main operation.
    """

    def __init__(self, tenant_id: Optional[str], user_id: Optional[str] = None) -> None:
        self.tenant_id = tenant_id or ""
        self.user_id = user_id or ""
        self._url: str = getattr(settings, "SAAS_ADMINISTRATION_SERVICE_URL", "http://localhost:3001")
        self._key: Optional[str] = getattr(settings, "SAAS_ADMINISTRATION_SERVICE_API_KEY", None)

    async def emit(self, event_type: str, metadata: Optional[Dict[str, Any]] = None) -> None:
        """Emit a behavioral event. Never raises."""
        if event_type not in DRAFT_EVENT_TYPES:
            logger.warning("draft-emitter: unknown event %r — skipped", event_type)
            return
        payload = {
            "event": {
                "event_type": event_type,
                "event_category": "FEATURE",
                "tenant_id": self.tenant_id or None,
                "user_id": self.user_id or None,
                "session_id": None,
                "page_path": None,
                "widget_name": None,
                "lead_id": None,
                "source": "draft-service",
                "metadata": metadata or {},
                "client_ts": datetime.now(timezone.utc).isoformat(),
            }
        }
        headers = {"Content-Type": "application/json"}
        if self._key:
            headers["X-API-Key"] = self._key
        try:
            async with httpx.AsyncClient(timeout=5.0) as client:
                r = await client.post(f"{self._url}/api/v1/analytics/portal-events", json=payload, headers=headers)
                if r.status_code not in (200, 201, 202):
                    logger.warning("draft-emitter: SaaS Admin returned %d for %r", r.status_code, event_type)
                else:
                    logger.debug("draft-emitter: emitted %r tenant=%s", event_type, self.tenant_id)
        except Exception as exc:
            logger.debug("draft-emitter: failed to emit %r — %s", event_type, exc)


class LeverageEventEmitter:
    """Fire-and-forget behavioral event emitter for the LEVERAGE pillar.

    Emits compliance intelligence events to the platform event bus.
    Never raises — a tracking failure must never break the main operation.
    """

    def __init__(self, tenant_id: Optional[str], case_id: Optional[str] = None, user_id: Optional[str] = None) -> None:
        self.tenant_id = tenant_id or ""
        self.case_id = case_id or ""
        self.user_id = user_id or ""
        self._url: str = getattr(settings, "SAAS_ADMINISTRATION_SERVICE_URL", "http://localhost:3001")
        self._key: Optional[str] = getattr(settings, "SAAS_ADMINISTRATION_SERVICE_API_KEY", None)

    async def emit(self, event_type: str, metadata: Optional[Dict[str, Any]] = None) -> None:
        """Emit a LEVERAGE behavioral event. Never raises."""
        if event_type not in LEVERAGE_EVENT_TYPES:
            logger.warning("leverage-emitter: unknown event %r — skipped", event_type)
            return
        payload = {
            "event": {
                "event_type": event_type,
                "event_category": "LEVERAGE",
                "tenant_id": self.tenant_id or None,
                "user_id": self.user_id or None,
                "session_id": None,
                "page_path": None,
                "widget_name": None,
                "lead_id": None,
                "source": "leverage-service",
                "metadata": {
                    "case_id": self.case_id or None,
                    **(metadata or {}),
                },
                "client_ts": datetime.now(timezone.utc).isoformat(),
            }
        }
        headers = {"Content-Type": "application/json"}
        if self._key:
            headers["X-API-Key"] = self._key
        try:
            async with httpx.AsyncClient(timeout=5.0) as client:
                r = await client.post(f"{self._url}/api/v1/analytics/portal-events", json=payload, headers=headers)
                if r.status_code not in (200, 201, 202):
                    logger.warning("leverage-emitter: SaaS Admin returned %d for %r", r.status_code, event_type)
                else:
                    logger.debug("leverage-emitter: emitted %r tenant=%s case=%s", event_type, self.tenant_id, self.case_id)
        except Exception as exc:
            logger.debug("leverage-emitter: failed to emit %r — %s", event_type, exc)
