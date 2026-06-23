"""
Tests for POST /leverage/case/{case_id}/settle

Covers:
  - UUID validation on case_id path param
  - Reward grant happy path (+1 credit)
  - Billing unavailable → fail-open (credit promised anyway)
  - Billing unexpected error → fail-open
  - Council prompt logic (shows when sufficient signals present)
  - Council prompt absent when signals incomplete
  - Negotiation recap computed correctly (above / within / below estimate)
  - Recap absent when estimated_median or settlement_amount missing
  - Settlement event emitted to DB (execute called, commit called)
  - DB persist failure is non-fatal
  - Response shape validation
"""

import pytest
from unittest.mock import AsyncMock, MagicMock, patch
from fastapi.testclient import TestClient


VALID_CASE_ID   = "3fa85f64-5717-4562-b3fc-2c963f66afa6"
VALID_TENANT_ID = "org_2abc123"

BASE_PAYLOAD = {
    "tenant_id":          VALID_TENANT_ID,
    "settlement_amount":  16500.0,
    "settlement_band":    "10-25k",
    "settlement_date":    "2026-03-01",
    "insurer":            "State Farm",
    "litigation_stage":   "pre_suit",
    "estimated_median":   14500.0,
    "negotiation_rounds": 3,
    "signals": {
        "incident_type":      "slip_fall",
        "incident_date":      "2026-01-15",
        "county":             "Duval County",
        "state":              "FL",
        "injury_category":    "minor",
        "insurer":            "State Farm",
        "liability_strength": "moderate",
        "litigation_stage":   "pre_suit",
        "policy_limit_band":  "50-100k",
    },
}

ENDPOINT = f"/api/v1/leverage/case/{VALID_CASE_ID}/settle"


def _mock_db():
    db = MagicMock()
    result_mock = MagicMock()
    result_mock.fetchone.return_value = None  # No settlement detail enrichment
    db.execute.return_value = result_mock
    db.commit.return_value = None
    db.rollback.return_value = None
    return db


def _mock_billing_grant_ok():
    billing = MagicMock()
    # No reward methods in v1 — billing is a passthrough placeholder
    return billing


@pytest.fixture
def client_with_mocks(app):
    from app.core.database import get_db

    def _make(db=None, billing=None):
        if db is None:
            db = _mock_db()
        if billing is None:
            billing = _mock_billing_grant_ok()

        def override_db():
            yield db

        app.dependency_overrides[get_db] = override_db
        tc = TestClient(app)
        return tc, db, billing

    yield _make
    app.dependency_overrides.clear()


def _post(tc, billing, payload=None, case_id=VALID_CASE_ID, **overrides):
    body = dict(BASE_PAYLOAD)
    if payload:
        body.update(payload)
    body.update(overrides)
    with patch("app.api.v1.endpoints.leverage_case.get_billing_service", return_value=billing):
        return tc.post(f"/api/v1/leverage/case/{case_id}/settle", json=body)


# ===========================================================================
# UUID Validation
# ===========================================================================

class TestSettleUUIDValidation:

    def test_valid_uuid_accepted(self, client_with_mocks):
        tc, db, billing = client_with_mocks()
        resp = _post(tc, billing)
        assert resp.status_code == 200

    def test_invalid_uuid_rejected(self, client_with_mocks):
        tc, db, billing = client_with_mocks()
        resp = _post(tc, billing, case_id="not-a-uuid")
        assert resp.status_code == 422

    def test_short_string_rejected(self, client_with_mocks):
        tc, db, billing = client_with_mocks()
        resp = _post(tc, billing, case_id="abc123")
        assert resp.status_code == 422


# ===========================================================================
# Reward Grant
# ===========================================================================

@pytest.mark.skip(reason="v1 pricing: reward/credit system removed from strategy")
class TestSettleRewardGrant:

    def test_reward_granted_true_on_success(self, client_with_mocks):
        billing = _mock_billing_grant_ok()
        tc, db, _ = client_with_mocks(billing=billing)
        resp = _post(tc, billing)
        data = resp.json()
        assert resp.status_code == 200
        assert data["reward_granted"] is True

    def test_reward_grant_calls_billing_with_correct_args(self, client_with_mocks):
        billing = _mock_billing_grant_ok()
        tc, db, _ = client_with_mocks(billing=billing)
        _post(tc, billing)
        billing.grant_rewards.assert_awaited_once_with(
            tenant_id=VALID_TENANT_ID,
            credits=1,
            source="settlement",
        )

    def test_billing_unavailable_reward_still_promised(self, client_with_mocks):
        """BillingServiceUnavailable → reward_granted=True (promise), billing_available=False."""
        from app.services.billing_service import BillingServiceUnavailable
        billing = MagicMock()
        billing.grant_rewards = AsyncMock(side_effect=BillingServiceUnavailable("down"))
        tc, db, _ = client_with_mocks(billing=billing)
        resp = _post(tc, billing)
        data = resp.json()
        assert resp.status_code == 200
        assert data["reward_granted"] is True      # promised even though billing down
        assert data["billing_available"] is False

    def test_billing_unexpected_error_reward_still_promised(self, client_with_mocks):
        billing = MagicMock()
        billing.grant_rewards = AsyncMock(side_effect=RuntimeError("boom"))
        tc, db, _ = client_with_mocks(billing=billing)
        resp = _post(tc, billing)
        data = resp.json()
        assert resp.status_code == 200
        assert data["reward_granted"] is True
        assert data["billing_available"] is False


# ===========================================================================
# Council Prompt
# ===========================================================================

class TestCouncilPrompt:

    def test_council_prompt_true_when_signals_complete(self, client_with_mocks):
        """county + incident_type + injury_category + insurer + settlement_band → prompt."""
        tc, db, billing = client_with_mocks()
        resp = _post(tc, billing)
        data = resp.json()
        assert data["council_prompt"] is True

    def test_council_prompt_false_when_county_missing(self, client_with_mocks):
        tc, db, billing = client_with_mocks()
        signals = dict(BASE_PAYLOAD["signals"])
        signals["county"] = None
        resp = _post(tc, billing, signals=signals)
        assert resp.json()["council_prompt"] is False

    def test_council_prompt_false_when_no_signals(self, client_with_mocks):
        tc, db, billing = client_with_mocks()
        resp = _post(tc, billing, signals=None)
        assert resp.json()["council_prompt"] is False

    def test_council_prompt_false_when_no_settlement_band(self, client_with_mocks):
        tc, db, billing = client_with_mocks()
        resp = _post(tc, billing, settlement_band=None)
        assert resp.json()["council_prompt"] is False


# ===========================================================================
# Negotiation Recap
# ===========================================================================

class TestNegotiationRecap:

    def test_recap_above_estimate(self, client_with_mocks):
        """settled 14% above median → 'Above estimate'."""
        tc, db, billing = client_with_mocks()
        resp = _post(tc, billing, estimated_median=14500.0, settlement_amount=16530.0)
        recap = resp.json()["recap"]
        assert recap is not None
        assert recap["outcome_label"] == "Above estimate"
        assert recap["outcome_vs_model_pct"] > 5

    def test_recap_within_estimate(self, client_with_mocks):
        """settled within 5% of median → 'Within estimate'."""
        tc, db, billing = client_with_mocks()
        resp = _post(tc, billing, estimated_median=14500.0, settlement_amount=14600.0)
        recap = resp.json()["recap"]
        assert recap is not None
        assert recap["outcome_label"] == "Within estimate"

    def test_recap_below_estimate(self, client_with_mocks):
        """settled > 5% below median → 'Below estimate'."""
        tc, db, billing = client_with_mocks()
        resp = _post(tc, billing, estimated_median=20000.0, settlement_amount=10000.0)
        recap = resp.json()["recap"]
        assert recap is not None
        assert recap["outcome_label"] == "Below estimate"

    def test_recap_none_when_no_median(self, client_with_mocks):
        tc, db, billing = client_with_mocks()
        resp = _post(tc, billing, estimated_median=None)
        assert resp.json()["recap"] is None

    def test_recap_none_when_no_actual(self, client_with_mocks):
        tc, db, billing = client_with_mocks()
        resp = _post(tc, billing, settlement_amount=None)
        assert resp.json()["recap"] is None

    def test_recap_contains_negotiation_rounds(self, client_with_mocks):
        tc, db, billing = client_with_mocks()
        resp = _post(tc, billing, negotiation_rounds=5)
        recap = resp.json()["recap"]
        assert recap is not None
        assert recap["negotiation_rounds"] == 5


# ===========================================================================
# DB Event Persistence
# ===========================================================================

class TestSettleDBPersist:

    def test_db_execute_called(self, client_with_mocks):
        """settlement_recorded event should be inserted."""
        billing = _mock_billing_grant_ok()
        tc, db, _ = client_with_mocks(billing=billing)
        _post(tc, billing)
        assert db.execute.call_count >= 1

    def test_db_commit_called(self, client_with_mocks):
        billing = _mock_billing_grant_ok()
        tc, db, _ = client_with_mocks(billing=billing)
        _post(tc, billing)
        db.commit.assert_called_once()

    def test_db_persist_failure_is_nonfatal(self, client_with_mocks):
        """DB error on event insert must not block the settlement response."""
        db = MagicMock()
        db.execute.side_effect = Exception("DB down")
        db.rollback.return_value = None
        billing = _mock_billing_grant_ok()
        tc, _, _ = client_with_mocks(db=db, billing=billing)
        resp = _post(tc, billing)
        assert resp.status_code == 200
        assert resp.json()["reward_granted"] is False  # Deprecated in v1 — always False


# ===========================================================================
# Response Shape
# ===========================================================================

class TestSettleResponseShape:

    def test_all_fields_present(self, client_with_mocks):
        tc, db, billing = client_with_mocks()
        resp = _post(tc, billing)
        data = resp.json()
        assert "success" in data
        assert "case_id" in data
        assert "tenant_id" in data
        assert "reward_granted" in data
        assert "council_prompt" in data
        assert "billing_available" in data
        assert "recap" in data
        assert "message" in data

    def test_success_always_true(self, client_with_mocks):
        tc, db, billing = client_with_mocks()
        resp = _post(tc, billing)
        assert resp.json()["success"] is True

    def test_case_id_echoed_as_string(self, client_with_mocks):
        tc, db, billing = client_with_mocks()
        resp = _post(tc, billing)
        assert resp.json()["case_id"] == VALID_CASE_ID

    def test_message_contains_credit_info_when_granted(self, client_with_mocks):
        tc, db, billing = client_with_mocks()
        resp = _post(tc, billing)
        assert "credit" in resp.json()["message"].lower() or "settlement" in resp.json()["message"].lower()

    def test_minimal_payload_works(self, client_with_mocks):
        """Only tenant_id is required."""
        tc, db, billing = client_with_mocks()
        with patch("app.api.v1.endpoints.leverage_case.get_billing_service", return_value=billing):
            resp = tc.post(ENDPOINT, json={"tenant_id": VALID_TENANT_ID})
        assert resp.status_code == 200
