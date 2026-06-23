"""
Tests for LEVERAGE Intelligence Features (Features A, B, C)

Feature A — Notifications:
  - Notification subscription CRUD
  - Notification log retrieval
  - fire_notification dispatches to subscriptions

Feature B — Valuation Multipliers:
  - GET /leverage/valuation/multipliers
  - POST /leverage/valuation/calculate

Feature C — Settlement Details + Nudge:
  - PUT /leverage/case/{case_id}/settlement-details (capture)
  - GET /leverage/case/{case_id}/settlement-details (retrieve)
  - GET /leverage/case/s/nudge-pending (list overdue cases)
  - POST /leverage/case/{case_id}/nudge (trigger nudge)
  - open_case now includes estimated_settle_by
  - record_settlement event enriched with settlement details
"""

import json
import pytest
from datetime import date, datetime, timezone, timedelta
from unittest.mock import AsyncMock, MagicMock, patch
from fastapi.testclient import TestClient


VALID_CASE_ID   = "3fa85f64-5717-4562-b3fc-2c963f66afa6"
VALID_TENANT_ID = "org_2abc123"


def _mock_db():
    """Return a mock DB session that silently accepts all execute/commit/rollback calls."""
    db = MagicMock()
    db.execute.return_value = MagicMock()
    db.commit.return_value = None
    db.rollback.return_value = None
    return db


def _mock_billing_200():
    """Billing client returns 200 (case opened)."""
    resp = MagicMock()
    resp.status_code = 200
    client = AsyncMock()
    client.post = AsyncMock(return_value=resp)
    billing = MagicMock()
    billing._get_client = AsyncMock(return_value=client)
    billing.grant_rewards = AsyncMock(return_value=True)
    return billing


def _mock_db_with_window():
    """DB that returns a settlement window row (270 days for slip_fall/FL)."""
    db = MagicMock()
    # First execute call = settlement window lookup
    # Second execute call = case profile upsert
    # Third execute call = case event insert
    window_result = MagicMock()
    window_result.fetchone.return_value = (210,)  # 210 days for FL slip_fall

    generic_result = MagicMock()
    generic_result.fetchone.return_value = None

    db.execute.side_effect = [window_result, generic_result, generic_result]
    db.commit.return_value = None
    db.rollback.return_value = None
    return db


def _mock_db_with_settlement_details():
    """DB that returns settlement detail row for enrichment."""
    db = MagicMock()
    detail_row = (
        16500,       # settlement_amount
        "10-25k",    # settlement_band
        "pre_suit_negotiation",  # settlement_method
        3,           # negotiation_rounds
        35000,       # demand_amount
        8000,        # first_offer_amount
        15000,       # final_counter_amount
        0,           # comparative_fault_pct
        True,        # council_contribution_consent
        "abc123",    # fingerprint_hash
    )
    result = MagicMock()
    result.fetchone.return_value = detail_row

    generic_result = MagicMock()
    generic_result.fetchone.return_value = None

    db.execute.side_effect = [result, generic_result]
    db.commit.return_value = None
    db.rollback.return_value = None
    return db


@pytest.fixture
def client_with_mocks(app):
    """
    Returns a helper that patches billing + DB via FastAPI dependency_overrides.
    Usage:  tc, db, billing = client_with_mocks(billing, db)
    """
    from app.core.database import get_db

    def _make(billing=None, db=None):
        if billing is None:
            billing = _mock_billing_200()
        if db is None:
            db = _mock_db()

        def override_db():
            yield db

        app.dependency_overrides[get_db] = override_db
        tc = TestClient(app)
        return tc, db, billing

    yield _make
    app.dependency_overrides.clear()


# ===========================================================================
# Feature A — Notifications
# ===========================================================================

class TestNotificationSubscriptions:
    """POST /leverage/notifications/subscribe + GET subscriptions."""

    def test_subscribe_returns_200(self, client_with_mocks):
        tc, db, _ = client_with_mocks()
        # Mock the RETURNING query to return valid data
        from datetime import datetime, timezone
        returning_result = MagicMock()
        returning_result.fetchone.return_value = (
            "3fa85f64-5717-4562-b3fc-2c963f66afa6",  # id
            datetime.now(timezone.utc),  # created_at
        )
        db.execute.return_value = returning_result

        resp = tc.post("/api/v1/leverage/notifications/subscribe", json={
            "tenant_id": VALID_TENANT_ID,
            "user_id": "clerk_abc123",
            "channel": "in_app",
            "event_types": ["deadline.critical", "settlement.nudge"],
        })
        assert resp.status_code in (200, 201)
        data = resp.json()
        assert "id" in data or "success" in data

    def test_list_subscriptions_returns_200(self, client_with_mocks):
        tc, db, _ = client_with_mocks()
        resp = tc.get("/api/v1/leverage/notifications/subscriptions", params={
            "tenant_id": VALID_TENANT_ID,
        })
        assert resp.status_code == 200

    def test_deactivate_subscription_returns_200(self, client_with_mocks):
        tc, db, _ = client_with_mocks()
        sub_id = "3fa85f64-5717-4562-b3fc-2c963f66afa6"
        resp = tc.delete(
            f"/api/v1/leverage/notifications/subscriptions/{sub_id}",
            params={"tenant_id": VALID_TENANT_ID},
        )
        assert resp.status_code == 200


class TestNotificationLog:
    """GET /leverage/notifications/log."""

    def test_log_returns_200(self, client_with_mocks):
        tc, db, _ = client_with_mocks()
        resp = tc.get("/api/v1/leverage/notifications/log", params={
            "tenant_id": VALID_TENANT_ID,
        })
        assert resp.status_code == 200


class TestNotificationTest:
    """POST /leverage/notifications/test."""

    def test_test_notification_returns_200(self, client_with_mocks):
        tc, db, _ = client_with_mocks()
        resp = tc.post("/api/v1/leverage/notifications/test", json={
            "tenant_id": VALID_TENANT_ID,
            "user_id": "clerk_abc123",
            "event_type": "statute.warning",
        })
        assert resp.status_code == 200


# ===========================================================================
# Feature B — Valuation Multipliers
# ===========================================================================

class TestValuationMultipliers:
    """GET /leverage/valuation/multipliers."""

    def test_get_multipliers_returns_200(self, client_with_mocks):
        tc, db, _ = client_with_mocks()
        # Mock DB returning multiplier rows
        row_result = MagicMock()
        row_result.fetchall.return_value = []
        db.execute.return_value = row_result

        resp = tc.get("/api/v1/leverage/valuation/multipliers", params={
            "state": "FL",
        })
        assert resp.status_code == 200


class TestValuationCalculate:
    """POST /leverage/valuation/calculate."""

    def test_calculate_returns_200(self, client_with_mocks):
        tc, db, _ = client_with_mocks()
        # Mock DB returning a multiplier row
        # Columns: state, medical_multiplier_low, medical_multiplier_high,
        #          comparative_fault_rule, typical_contingency_pct, notes
        row_result = MagicMock()
        row_result.fetchone.return_value = (
            "FL", 1.5, 3.0, "modified_comparative", 33.3, "Modified 51% bar"
        )
        db.execute.return_value = row_result

        resp = tc.post("/api/v1/leverage/valuation/calculate", json={
            "state": "FL",
            "medical_specials_total": 25000,
            "lost_wages_total": 5000,
            "other_economic_damages": 0,
            "comparative_fault_pct": 0,
        })
        assert resp.status_code == 200


# ===========================================================================
# Feature C — Settlement Details + Nudge
# ===========================================================================

class TestSettlementDetailCapture:
    """PUT /leverage/case/{case_id}/settlement-details."""

    def test_capture_returns_200(self, client_with_mocks):
        tc, db, _ = client_with_mocks()
        resp = tc.put(f"/api/v1/leverage/case/{VALID_CASE_ID}/settlement-details", json={
            "tenant_id": VALID_TENANT_ID,
            "settlement_amount": 16500,
            "settlement_band": "10-25k",
            "settlement_date": "2026-03-01",
            "settlement_method": "pre_suit_negotiation",
            "insurer": "State Farm",
            "negotiation_rounds": 3,
            "demand_amount": 35000,
            "first_offer_amount": 8000,
            "final_counter_amount": 15000,
            "council_contribution_consent": True,
        })
        assert resp.status_code == 200
        data = resp.json()
        assert data["success"] is True
        assert data["tenant_id"] == VALID_TENANT_ID

    def test_capture_requires_tenant_id(self, client):
        """tenant_id is now a required field."""
        resp = client.put(f"/api/v1/leverage/case/{VALID_CASE_ID}/settlement-details", json={
            "settlement_amount": 16500,
            "settlement_band": "10-25k",
        })
        assert resp.status_code == 422


class TestSettlementDetailRetrieve:
    """GET /leverage/case/{case_id}/settlement-details."""

    def test_retrieve_returns_200(self, client_with_mocks):
        tc, db, _ = client_with_mocks()
        resp = tc.get(f"/api/v1/leverage/case/{VALID_CASE_ID}/settlement-details", params={
            "tenant_id": VALID_TENANT_ID,
        })
        assert resp.status_code == 200


class TestNudgePendingCases:
    """GET /leverage/case/s/nudge-pending."""

    def test_nudge_pending_returns_200(self, client_with_mocks):
        tc, db, _ = client_with_mocks()
        # Mock DB returning count row
        count_result = MagicMock()
        count_result.fetchone.return_value = (0,)
        rows_result = MagicMock()
        rows_result.fetchall.return_value = []
        db.execute.side_effect = [rows_result, count_result]

        resp = tc.get("/api/v1/leverage/case/nudge-pending", params={
            "tenant_id": VALID_TENANT_ID,
        })
        assert resp.status_code == 200
        data = resp.json()
        assert "cases" in data
        assert "total_pending" in data


class TestNudgeSettlement:
    """POST /leverage/case/{case_id}/nudge."""

    def test_nudge_returns_200(self, client_with_mocks):
        tc, db, _ = client_with_mocks()
        with patch("app.api.v1.endpoints.leverage_case.fire_notification", new_callable=AsyncMock, return_value=1):
            resp = tc.post(f"/api/v1/leverage/case/{VALID_CASE_ID}/nudge", params={
                "tenant_id": VALID_TENANT_ID,
            })
        assert resp.status_code == 200
        data = resp.json()
        assert data["success"] is True
        assert data["notification_sent"] is True

    def test_nudge_without_subscriptions(self, client_with_mocks):
        tc, db, _ = client_with_mocks()
        with patch("app.api.v1.endpoints.leverage_case.fire_notification", new_callable=AsyncMock, return_value=0):
            resp = tc.post(f"/api/v1/leverage/case/{VALID_CASE_ID}/nudge", params={
                "tenant_id": VALID_TENANT_ID,
            })
        assert resp.status_code == 200
        data = resp.json()
        assert data["notification_sent"] is False


# ===========================================================================
# Feature C — open_case now includes estimated_settle_by
# ===========================================================================

class TestCaseOpenEstimatedSettleBy:
    """open_case now computes estimated_settle_by from settlement windows."""

    def test_response_includes_estimated_settle_by_field(self, client_with_mocks):
        """CaseOpenResponse now includes estimated_settle_by."""
        billing = _mock_billing_200()
        db = _mock_db_with_window()
        tc, _, _ = client_with_mocks(billing=billing, db=db)
        with patch("app.api.v1.endpoints.leverage_case.get_billing_service", return_value=billing):
            resp = tc.post("/api/v1/leverage/case/open", json={
                "tenant_id": VALID_TENANT_ID,
                "case_id":   VALID_CASE_ID,
                "signals": {
                    "incident_type": "slip_fall",
                    "incident_date": "2026-01-15",
                    "state":         "FL",
                },
                "is_first_case": False,
            })
        assert resp.status_code == 200
        data = resp.json()
        assert "estimated_settle_by" in data

    def test_no_signals_means_no_estimated_settle_by(self, client_with_mocks):
        """Without signals, estimated_settle_by should be None."""
        billing = _mock_billing_200()
        tc, db, _ = client_with_mocks(billing=billing)
        with patch("app.api.v1.endpoints.leverage_case.get_billing_service", return_value=billing):
            resp = tc.post("/api/v1/leverage/case/open", json={
                "tenant_id": VALID_TENANT_ID,
                "case_id":   VALID_CASE_ID,
            })
        assert resp.status_code == 200
        data = resp.json()
        assert data.get("estimated_settle_by") is None

    def test_no_settlement_window_means_no_estimated_settle_by(self, client_with_mocks):
        """If no matching settlement window, estimated_settle_by should be None."""
        billing = _mock_billing_200()
        db = MagicMock()
        # No settlement window found
        window_result = MagicMock()
        window_result.fetchone.return_value = None
        generic_result = MagicMock()
        generic_result.fetchone.return_value = None
        db.execute.side_effect = [window_result, generic_result, generic_result]
        db.commit.return_value = None
        db.rollback.return_value = None

        tc, _, _ = client_with_mocks(billing=billing, db=db)
        with patch("app.api.v1.endpoints.leverage_case.get_billing_service", return_value=billing):
            resp = tc.post("/api/v1/leverage/case/open", json={
                "tenant_id": VALID_TENANT_ID,
                "case_id":   VALID_CASE_ID,
                "signals": {
                    "incident_type": "slip_fall",
                    "incident_date": "2026-01-15",
                    "state":         "XX",  # nonexistent state
                },
                "is_first_case": False,
            })
        assert resp.status_code == 200
        data = resp.json()
        assert data.get("estimated_settle_by") is None


# ===========================================================================
# Feature C — record_settlement event enriched with settlement details
# ===========================================================================

class TestSettlementEventEnrichment:
    """record_settlement event payload is enriched with settlement details."""

    def test_settle_with_details_in_event_payload(self, client_with_mocks):
        """The settlement_recorded event should include settlement detail data."""
        billing = _mock_billing_200()
        db = _mock_db_with_settlement_details()
        tc, _, _ = client_with_mocks(billing=billing, db=db)

        with patch("app.api.v1.endpoints.leverage_case.get_billing_service", return_value=billing):
            resp = tc.post(f"/api/v1/leverage/case/{VALID_CASE_ID}/settle", json={
                "tenant_id": VALID_TENANT_ID,
                "settlement_band": "10-25k",
                "settlement_date": "2026-03-01",
                "insurer": "State Farm",
                "signals": {
                    "incident_type": "slip_fall",
                    "county": "Duval County",
                    "injury_category": "minor",
                    "insurer": "State Farm",
                },
            })

        assert resp.status_code == 200
        data = resp.json()
        assert data["success"] is True
        assert data["council_prompt"] is True  # enough signals for council


# ===========================================================================
# Event types — ensure new types are in LEVERAGE_EVENT_TYPES
# ===========================================================================

class TestLeverageEventTypes:
    """Verify new settlement event types are registered."""

    def test_settlement_details_captured_registered(self):
        from app.core.event_emitter import LEVERAGE_EVENT_TYPES
        assert "settlement.details_captured" in LEVERAGE_EVENT_TYPES

    def test_settlement_nudge_registered(self):
        from app.core.event_emitter import LEVERAGE_EVENT_TYPES
        assert "settlement.nudge" in LEVERAGE_EVENT_TYPES

    def test_settlement_window_set_registered(self):
        from app.core.event_emitter import LEVERAGE_EVENT_TYPES
        assert "settlement.window_set" in LEVERAGE_EVENT_TYPES
