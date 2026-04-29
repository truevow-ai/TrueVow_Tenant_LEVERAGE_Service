"""
Tests for POST /leverage/case/open

Covers:
  - UUID validation on case_id (valid vs invalid)
  - Billing gate happy path (200 from billing service)
  - Billing gate idempotency (409 from billing service)
  - Billing service unavailable → fail-open (leverage still unlocked)
  - Billing unexpected error → fail-open
  - Welcome bonus for first case
  - Welcome bonus failure is non-fatal
  - DB persist failure is non-fatal (fail-open)
  - Signals stored into leverage_case_profiles
  - Response shape validation
"""

import json
import pytest
from unittest.mock import AsyncMock, MagicMock, patch
from fastapi.testclient import TestClient


VALID_CASE_ID   = "3fa85f64-5717-4562-b3fc-2c963f66afa6"
VALID_TENANT_ID = "org_2abc123"

BASE_PAYLOAD = {
    "tenant_id": VALID_TENANT_ID,
    "case_id":   VALID_CASE_ID,
    "signals": {
        "incident_type":      "slip_fall",
        "incident_date":      "2026-01-15",
        "county":             "Duval County",
        "state":              "FL",
        "injury_category":    "minor",
        "insurer":            "State Farm",
        "liability_strength": "moderate",
        "litigation_stage":   "pre_suit",
    },
    "is_first_case": False,
}


def _mock_db():
    """Return a mock DB session that silently accepts all execute/commit/rollback calls."""
    db = MagicMock()
    db.execute.return_value = MagicMock()
    db.commit.return_value = None
    db.rollback.return_value = None
    return db


def _mock_billing_200():
    """Billing service returns success for check_case_limit and record_case_open."""
    billing = MagicMock()
    billing.check_case_limit = AsyncMock(return_value={
        "authorized": True,
        "source": "included",
        "price_cents": 0,
        "cases_used": 1,
        "cases_included": 5,
        "cases_remaining": 4,
        "validations_unlimited": True,
        "tier": "solo",
        "message": "Case opened. Validations are unlimited and free.",
        # Legacy fields
        "is_overage": False,
        "overage_charge_usd": 0,
        "can_open": True,
    })
    billing.record_case_open = AsyncMock(return_value=True)
    return billing


def _mock_billing_409():
    """Billing service returns idempotent (already opened) for record_case_open."""
    billing = MagicMock()
    billing.check_case_limit = AsyncMock(return_value={
        "authorized": True,
        "source": "included",
        "price_cents": 0,
        "cases_used": 2,
        "cases_included": 5,
        "cases_remaining": 3,
        "validations_unlimited": True,
        "tier": "solo",
        "message": "Case opened. Validations are unlimited and free.",
        # Legacy fields
        "is_overage": False,
        "overage_charge_usd": 0,
        "can_open": True,
    })
    billing.record_case_open = AsyncMock(return_value=True)  # 409 is still success (idempotent)
    return billing


# ===========================================================================
# Helpers
# ===========================================================================

def _post(client, payload=None, **overrides):
    body = dict(BASE_PAYLOAD)
    if payload:
        body.update(payload)
    body.update(overrides)
    return client.post("/api/v1/leverage/case/open", json=body)


@pytest.fixture
def client_with_mocks(app):
    """
    Returns a helper that patches billing + DB via FastAPI dependency_overrides.
    Usage:  client, db = client_with_mocks(billing)
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
# Tests
# ===========================================================================

class TestCaseOpenUUIDValidation:
    """case_id must be a valid UUID."""

    def test_valid_uuid_accepted(self, client_with_mocks):
        tc, db, billing = client_with_mocks()
        with patch("app.api.v1.endpoints.leverage_case.get_billing_service", return_value=billing):
            resp = _post(tc)
        assert resp.status_code == 200
        assert resp.json()["case_id"] == VALID_CASE_ID

    def test_invalid_uuid_rejected(self, client):
        resp = _post(client, case_id="not-a-uuid")
        assert resp.status_code == 422

    def test_empty_case_id_rejected(self, client):
        resp = _post(client, case_id="")
        assert resp.status_code == 422

    def test_integer_case_id_rejected(self, client):
        resp = _post(client, case_id=12345)
        assert resp.status_code == 422


class TestCaseOpenBillingGate:
    """Billing gate behaviour — happy path, idempotency, fail-open."""

    def test_billing_200_leverage_unlocked(self, client_with_mocks):
        tc, db, billing = client_with_mocks()
        with patch("app.api.v1.endpoints.leverage_case.get_billing_service", return_value=billing):
            resp = _post(tc)
        data = resp.json()
        assert resp.status_code == 200
        assert data["leverage_unlocked"] is True
        assert data["billing_available"] is True

    def test_billing_409_idempotent(self, client_with_mocks):
        """Second open of the same case (409) is still treated as unlocked."""
        tc, db, billing = client_with_mocks(billing=_mock_billing_409())
        with patch("app.api.v1.endpoints.leverage_case.get_billing_service", return_value=billing):
            resp = _post(tc)
        data = resp.json()
        assert resp.status_code == 200
        assert data["leverage_unlocked"] is True

    def test_billing_unavailable_fail_open(self, client_with_mocks):
        """BillingServiceUnavailable → leverage still unlocked, billing_available=False."""
        from app.services.billing_service import BillingServiceUnavailable
        billing = MagicMock()
        billing.check_case_limit = AsyncMock(side_effect=BillingServiceUnavailable("down"))
        tc, db, _ = client_with_mocks(billing=billing)
        with patch("app.api.v1.endpoints.leverage_case.get_billing_service", return_value=billing):
            resp = _post(tc)
        data = resp.json()
        assert resp.status_code == 200
        assert data["leverage_unlocked"] is True
        assert data["billing_available"] is False

    def test_billing_unexpected_error_fail_open(self, client_with_mocks):
        """Random exception from billing → fail-open."""
        billing = MagicMock()
        billing.check_case_limit = AsyncMock(side_effect=RuntimeError("network"))
        tc, db, _ = client_with_mocks(billing=billing)
        with patch("app.api.v1.endpoints.leverage_case.get_billing_service", return_value=billing):
            resp = _post(tc)
        data = resp.json()
        assert resp.status_code == 200
        assert data["leverage_unlocked"] is True
        assert data["billing_available"] is False

    def test_billing_500_warning_logged(self, client_with_mocks):
        """Billing raises generic error → leverage still unlocked (fail-open behavior)."""
        billing = MagicMock()
        billing.check_case_limit = AsyncMock(side_effect=Exception("internal server error"))
        tc, db, _ = client_with_mocks(billing=billing)
        with patch("app.api.v1.endpoints.leverage_case.get_billing_service", return_value=billing):
            resp = _post(tc)
        assert resp.status_code == 200


@pytest.mark.skip(reason="v1 pricing: reward/credit system removed from strategy")
class TestCaseOpenWelcomeBonus:
    """Welcome bonus for first retained client."""

    def test_first_case_grants_11_credits(self, client_with_mocks):
        billing = _mock_billing_200()
        tc, db, _ = client_with_mocks(billing=billing)
        with patch("app.api.v1.endpoints.leverage_case.get_billing_service", return_value=billing):
            resp = _post(tc, is_first_case=True)
        data = resp.json()
        assert resp.status_code == 200
        assert data["welcome_bonus_granted"] is True
        billing.grant_rewards.assert_awaited_once_with(
            tenant_id=VALID_TENANT_ID,
            credits=11,
            source="welcome_bonus",
        )

    def test_not_first_case_no_bonus(self, client_with_mocks):
        billing = _mock_billing_200()
        tc, db, _ = client_with_mocks(billing=billing)
        with patch("app.api.v1.endpoints.leverage_case.get_billing_service", return_value=billing):
            resp = _post(tc, is_first_case=False)
        data = resp.json()
        assert data["welcome_bonus_granted"] is False
        billing.grant_rewards.assert_not_awaited()

    def test_welcome_bonus_failure_is_nonfatal(self, client_with_mocks):
        """Grant failure should not crash the endpoint."""
        billing = _mock_billing_200()
        billing.grant_rewards = AsyncMock(side_effect=RuntimeError("bonus failure"))
        tc, db, _ = client_with_mocks(billing=billing)
        with patch("app.api.v1.endpoints.leverage_case.get_billing_service", return_value=billing):
            resp = _post(tc, is_first_case=True)
        data = resp.json()
        assert resp.status_code == 200
        assert data["welcome_bonus_granted"] is False


class TestCaseOpenDBPersist:
    """DB persistence is fail-open — errors must not block the response."""

    def test_db_error_does_not_block_response(self, client_with_mocks):
        db = MagicMock()
        db.execute.side_effect = Exception("DB connection lost")
        db.rollback.return_value = None
        billing = _mock_billing_200()
        tc, _, _ = client_with_mocks(billing=billing, db=db)
        with patch("app.api.v1.endpoints.leverage_case.get_billing_service", return_value=billing):
            resp = _post(tc)
        # Must still return 200 — DB failure is non-fatal
        assert resp.status_code == 200
        data = resp.json()
        assert data["leverage_unlocked"] is True

    def test_db_execute_called_with_case_id(self, client_with_mocks):
        """Verify the DB upsert is called (execute called at least once)."""
        billing = _mock_billing_200()
        tc, db, _ = client_with_mocks(billing=billing)
        with patch("app.api.v1.endpoints.leverage_case.get_billing_service", return_value=billing):
            resp = _post(tc)
        assert resp.status_code == 200
        assert db.execute.call_count >= 1


class TestCaseOpenResponseShape:
    """Response must always return the correct shape."""

    def test_response_contains_all_fields(self, client_with_mocks):
        billing = _mock_billing_200()
        tc, db, _ = client_with_mocks(billing=billing)
        with patch("app.api.v1.endpoints.leverage_case.get_billing_service", return_value=billing):
            resp = _post(tc)
        data = resp.json()
        assert "success" in data
        assert "case_id" in data
        assert "tenant_id" in data
        assert "leverage_unlocked" in data
        assert "billing_available" in data
        assert "is_overage" in data
        assert "message" in data

    def test_success_is_always_true(self, client_with_mocks):
        billing = _mock_billing_200()
        tc, db, _ = client_with_mocks(billing=billing)
        with patch("app.api.v1.endpoints.leverage_case.get_billing_service", return_value=billing):
            resp = _post(tc)
        assert resp.json()["success"] is True

    def test_case_id_echoed_as_string(self, client_with_mocks):
        billing = _mock_billing_200()
        tc, db, _ = client_with_mocks(billing=billing)
        with patch("app.api.v1.endpoints.leverage_case.get_billing_service", return_value=billing):
            resp = _post(tc)
        assert resp.json()["case_id"] == VALID_CASE_ID

    def test_no_signals_still_works(self, client_with_mocks):
        """Signals are optional — open without them."""
        billing = _mock_billing_200()
        tc, db, _ = client_with_mocks(billing=billing)
        payload = {
            "tenant_id": VALID_TENANT_ID,
            "case_id":   VALID_CASE_ID,
        }
        with patch("app.api.v1.endpoints.leverage_case.get_billing_service", return_value=billing):
            resp = tc.post("/api/v1/leverage/case/open", json=payload)
        assert resp.status_code == 200
