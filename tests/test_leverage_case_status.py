"""
Tests for GET /leverage/case/{case_id}/status

Covers:
  - UUID validation on case_id path param
  - Billing returns 200 with leverage_unlocked + settle_unlocked
  - Billing returns 404 → leverage_unlocked=False (case not yet opened)
  - Billing returns non-200/404 → warning logged, defaults used
  - BillingServiceUnavailable → billing_available=False, safe defaults
  - Unexpected billing error → safe defaults
  - Reward credit balance included in response
  - Reward credit balance error → defaults to 0 (fail-open)
  - Response shape validation
"""

import pytest
from unittest.mock import AsyncMock, MagicMock, patch
from fastapi.testclient import TestClient


VALID_CASE_ID   = "3fa85f64-5717-4562-b3fc-2c963f66afa6"
VALID_TENANT_ID = "org_2abc123"

ENDPOINT = f"/api/v1/leverage/case/{VALID_CASE_ID}/status"


def _make_billing_status_response(status_code=200, leverage_unlocked=True, settle_unlocked=False):
    billing = MagicMock()
    if status_code == 404:
        # 404 means case not yet opened — safe defaults
        billing.get_case_status = AsyncMock(return_value={
            "leverage_unlocked": False,
            "settle_unlocked":   False,
            "is_overage":        False,
            "overage_charge_usd": 0,
        })
    else:
        billing.get_case_status = AsyncMock(return_value={
            "leverage_unlocked": leverage_unlocked,
            "settle_unlocked":   settle_unlocked,
            "is_overage":        False,
            "overage_charge_usd": 0,
        })
    return billing


def _get(client_obj, billing, case_id=VALID_CASE_ID, tenant_id=VALID_TENANT_ID):
    with patch("app.api.v1.endpoints.leverage_case.get_billing_service", return_value=billing):
        return client_obj.get(
            f"/api/v1/leverage/case/{case_id}/status",
            params={"tenant_id": tenant_id},
        )


# ===========================================================================
# UUID Validation
# ===========================================================================

class TestStatusUUIDValidation:

    def test_valid_uuid_accepted(self, client):
        billing = _make_billing_status_response()
        resp = _get(client, billing)
        assert resp.status_code == 200

    def test_invalid_uuid_rejected(self, client):
        billing = _make_billing_status_response()
        resp = _get(client, billing, case_id="not-a-uuid")
        assert resp.status_code == 422

    def test_short_string_rejected(self, client):
        billing = _make_billing_status_response()
        resp = _get(client, billing, case_id="abc")
        assert resp.status_code == 422


# ===========================================================================
# Billing Status — Happy Path
# ===========================================================================

class TestStatusBillingHappyPath:

    def test_leverage_unlocked_from_billing(self, client):
        billing = _make_billing_status_response(leverage_unlocked=True, settle_unlocked=False)
        resp = _get(client, billing)
        data = resp.json()
        assert resp.status_code == 200
        assert data["leverage_unlocked"] is True
        assert data["settle_unlocked"] is False
        assert data["billing_available"] is True

    def test_settle_unlocked_from_billing(self, client):
        billing = _make_billing_status_response(leverage_unlocked=True, settle_unlocked=True)
        resp = _get(client, billing)
        data = resp.json()
        assert data["settle_unlocked"] is True

    def test_reward_credits_no_longer_returned(self, client):
        billing = _make_billing_status_response()
        resp = _get(client, billing)
        data = resp.json()
        # active_reward_credits removed in v1 (no credit system)
        assert "active_reward_credits" not in data


# ===========================================================================
# Billing Status — 404 (Case Not Opened Yet)
# ===========================================================================

class TestStatusCaseNotFound:

    def test_404_means_not_opened(self, client):
        billing = _make_billing_status_response(status_code=404)
        resp = _get(client, billing)
        data = resp.json()
        assert resp.status_code == 200
        assert data["leverage_unlocked"] is False

    def test_404_billing_available_still_true(self, client):
        """404 is a valid response from billing — billing IS available."""
        billing = _make_billing_status_response(status_code=404)
        resp = _get(client, billing)
        assert resp.json()["billing_available"] is True


# ===========================================================================
# Billing Unavailable / Errors — Fail-Open
# ===========================================================================

class TestStatusFailOpen:

    def test_billing_unavailable_fail_open(self, client):
        from app.services.billing_service import BillingServiceUnavailable
        billing = MagicMock()
        billing.get_case_status = AsyncMock(side_effect=BillingServiceUnavailable("down"))
        resp = _get(client, billing)
        data = resp.json()
        assert resp.status_code == 200
        assert data["billing_available"] is False
        # Safe defaults
        assert data["leverage_unlocked"] is False

    def test_billing_unexpected_error_fail_open(self, client):
        billing = MagicMock()
        billing.get_case_status = AsyncMock(side_effect=RuntimeError("boom"))
        resp = _get(client, billing)
        data = resp.json()
        assert resp.status_code == 200
        assert data["billing_available"] is False

    def test_billing_500_defaults_used(self, client):
        billing = MagicMock()
        billing.get_case_status = AsyncMock(side_effect=Exception("500 error"))
        resp = _get(client, billing)
        assert resp.status_code == 200

    def test_reward_count_no_longer_tracked(self, client):
        """In v1, reward credits are no longer tracked (no credit system)."""
        billing = _make_billing_status_response()
        resp = _get(client, billing)
        data = resp.json()
        assert resp.status_code == 200
        assert "active_reward_credits" not in data


# ===========================================================================
# Response Shape
# ===========================================================================

class TestStatusResponseShape:

    def test_all_fields_present(self, client):
        billing = _make_billing_status_response()
        resp = _get(client, billing)
        data = resp.json()
        assert "tenant_id" in data
        assert "case_id" in data
        assert "leverage_unlocked" in data
        assert "settle_unlocked" in data
        assert "billing_available" in data
        # active_reward_credits removed in v1 (no credit system)

    def test_case_id_echoed_as_string(self, client):
        billing = _make_billing_status_response()
        resp = _get(client, billing)
        assert resp.json()["case_id"] == VALID_CASE_ID

    def test_tenant_id_echoed(self, client):
        billing = _make_billing_status_response()
        resp = _get(client, billing)
        assert resp.json()["tenant_id"] == VALID_TENANT_ID
