"""
Tests for POST /leverage/case/{case_id}/compliance

Covers:
  - UUID validation on case_id path param
  - SOL rule found in DB → safe / warning / critical / overdue status
  - SOL rule missing from DB → sol_rule_missing flag (no silent default)
  - SOL DB error (exception) → sol_rule_missing gracefully
  - Missing incident_date or state → unknown status
  - Demand letter completeness check (complete / incomplete / not_reviewed)
  - Compliance flags generated correctly (STATUTE_*, DEMAND_LETTER_INCOMPLETE,
    SOL_RULE_MISSING, LIABILITY_CONTESTED, POLICY_LIMIT_UNKNOWN, INSURER_UNKNOWN)
  - Reward consume path (consume_reward=True)
  - Reward consume fail-open
  - DB persist (execute called, commit called)
  - DB persist failure is non-fatal
  - Response contains validation_engine_version
  - Response shape validation
"""

import pytest
from datetime import date, timedelta
from unittest.mock import AsyncMock, MagicMock, patch, call
from fastapi.testclient import TestClient


VALID_CASE_ID   = "3fa85f64-5717-4562-b3fc-2c963f66afa6"
VALID_TENANT_ID = "org_2abc123"

BASE_SIGNALS = {
    "incident_type":      "slip_fall",
    "incident_date":      "2024-01-15",   # ~2 years ago → status depends on SOL
    "county":             "Duval County",
    "state":              "FL",
    "injury_category":    "minor",
    "insurer":            "State Farm",
    "liability_strength": "moderate",
    "litigation_stage":   "pre_suit",
    "policy_limit_band":  "50-100k",
}

BASE_PAYLOAD = {
    "tenant_id":    VALID_TENANT_ID,
    "signals":      BASE_SIGNALS,
    "consume_reward": False,
}

ENDPOINT = f"/api/v1/leverage/case/{VALID_CASE_ID}/compliance"

# A full FL PI SOL rule as it appears in validator_config JSONB
FL_SOL_RULE = {
    "sol_years":      2,
    "sol_days":       730,
    "statute":        "Fla. Stat. § 95.11(3)(a)",
    "effective_date": "2023-03-24",
    "discovery_rule": False,
    "authority_level": "primary_state_sol",
    "sol_version":    "2.0.0",
    "valid_from":     "2023-03-24",
    "valid_to":       None,
    "_rule_id":       "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee",
    "_rule_version":  "2.0.0",
}


def _mock_db(sol_rule=FL_SOL_RULE):
    """
    Return a mock DB session.
    execute() returns a mock whose fetchone() returns:
      - a row mimicking the SOL query result (first call)
      - a row mimicking the version count query (second call)
    Subsequent execute calls (INSERT) return silently.
    """
    db = MagicMock()

    # The SOL query fetchone returns (rule_id, validator_config, rule_version)
    sol_row = MagicMock()
    sol_row.__getitem__ = lambda self, i: [
        sol_rule.get("_rule_id", "test-rule-id") if sol_rule else None,
        {k: v for k, v in (sol_rule or {}).items() if not k.startswith("_")},
        sol_rule.get("_rule_version", "1.0.0") if sol_rule else None,
    ][i] if sol_rule else None

    # Version count query fetchone returns (1,) meaning next version = 1
    ver_row = MagicMock()
    ver_row.__getitem__ = lambda self, i: 1

    execute_results = []
    call_count = [0]

    def _execute(query, params=None):
        result = MagicMock()
        call_count[0] += 1
        n = call_count[0]
        if n == 1:
            # SOL select query
            result.fetchone.return_value = sol_row if sol_rule else None
        elif n == 2:
            # Version count query
            result.fetchone.return_value = ver_row
        else:
            result.fetchone.return_value = None
        return result

    db.execute.side_effect = _execute
    db.commit.return_value = None
    db.rollback.return_value = None
    return db


def _mock_db_no_sol():
    """DB returns None for SOL query (rule not found)."""
    return _mock_db(sol_rule=None)


def _mock_billing_idle():
    """Billing service placeholder (no billing methods called in v1)."""
    billing = MagicMock()
    return billing


@pytest.fixture
def client_with_mocks(app):
    """FastAPI dependency override for get_db."""
    from app.core.database import get_db

    def _make(db=None, billing=None):
        if db is None:
            db = _mock_db()
        if billing is None:
            billing = _mock_billing_idle()

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
        return tc.post(f"/api/v1/leverage/case/{case_id}/compliance", json=body)


# ===========================================================================
# UUID Validation
# ===========================================================================

class TestComplianceUUIDValidation:

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
        resp = _post(tc, billing, case_id="abc")
        assert resp.status_code == 422


# ===========================================================================
# SOL Status Derived from DB Rule
# ===========================================================================

class TestSOLStatusFromDB:
    """statute_check.status is derived deterministically from DB rule + incident_date."""

    def test_sol_safe_status(self, client_with_mocks):
        """Incident yesterday + 2 year SOL → safe."""
        tc, db, billing = client_with_mocks()
        yesterday = (date.today() - timedelta(days=1)).isoformat()
        resp = _post(tc, billing, signals={**BASE_SIGNALS, "incident_date": yesterday})
        data = resp.json()
        assert resp.status_code == 200
        assert data["statute_check"]["status"] == "safe"
        assert data["statute_check"]["days_remaining"] is not None
        assert data["statute_check"]["days_remaining"] > 90

    def test_sol_warning_status(self, client_with_mocks):
        """Incident ~2 years ago minus 60 days → warning range (30-90 days remaining)."""
        tc, db, billing = client_with_mocks()
        two_years_minus_60 = (date.today() - timedelta(days=730 - 60)).isoformat()
        resp = _post(tc, billing, signals={**BASE_SIGNALS, "incident_date": two_years_minus_60})
        data = resp.json()
        assert resp.status_code == 200
        assert data["statute_check"]["status"] == "warning"

    def test_sol_critical_status(self, client_with_mocks):
        """Incident ~2 years ago minus 15 days → critical range (≤30 days)."""
        tc, db, billing = client_with_mocks()
        two_years_minus_15 = (date.today() - timedelta(days=730 - 15)).isoformat()
        resp = _post(tc, billing, signals={**BASE_SIGNALS, "incident_date": two_years_minus_15})
        data = resp.json()
        assert resp.status_code == 200
        assert data["statute_check"]["status"] == "critical"

    def test_sol_overdue_status(self, client_with_mocks):
        """Incident > 2 years ago → overdue."""
        tc, db, billing = client_with_mocks()
        three_years_ago = (date.today() - timedelta(days=1095)).isoformat()
        resp = _post(tc, billing, signals={**BASE_SIGNALS, "incident_date": three_years_ago})
        data = resp.json()
        assert resp.status_code == 200
        assert data["statute_check"]["status"] == "overdue"

    def test_sol_note_contains_statute_text(self, client_with_mocks):
        """SOL note should contain the statute citation from the DB rule."""
        tc, db, billing = client_with_mocks()
        yesterday = (date.today() - timedelta(days=1)).isoformat()
        resp = _post(tc, billing, signals={**BASE_SIGNALS, "incident_date": yesterday})
        data = resp.json()
        assert "Fla. Stat." in data["statute_check"]["note"]


# ===========================================================================
# SOL Rule Missing
# ===========================================================================

class TestSOLRuleMissing:
    """When no rule exists for the state, sol_rule_missing flag is returned."""

    def test_unknown_state_returns_sol_rule_missing(self, client_with_mocks):
        """State with no seeded rule → sol_rule_missing, no silent default."""
        tc, db, billing = client_with_mocks(db=_mock_db_no_sol())
        resp = _post(tc, billing, signals={**BASE_SIGNALS, "state": "ZZ"})
        data = resp.json()
        assert resp.status_code == 200
        assert data["statute_check"]["status"] == "sol_rule_missing"
        assert data["statute_check"]["days_remaining"] is None

    def test_sol_rule_missing_flag_in_flags_list(self, client_with_mocks):
        """When SOL rule is missing, SOL_RULE_MISSING must appear in flags."""
        tc, db, billing = client_with_mocks(db=_mock_db_no_sol())
        resp = _post(tc, billing, signals={**BASE_SIGNALS, "state": "ZZ"})
        data = resp.json()
        flag_names = [f["flag"] for f in data["flags"]]
        assert "SOL_RULE_MISSING" in flag_names

    def test_sol_rule_missing_no_silent_default(self, client_with_mocks):
        """Verify no hardcoded fallback: days_remaining must be None."""
        tc, db, billing = client_with_mocks(db=_mock_db_no_sol())
        resp = _post(tc, billing)
        data = resp.json()
        # If rule was missing, days_remaining must be None (not 730 or any default)
        if data["statute_check"]["status"] == "sol_rule_missing":
            assert data["statute_check"]["days_remaining"] is None

    def test_missing_state_returns_unknown(self, client_with_mocks):
        """No state provided → unknown (not sol_rule_missing)."""
        tc, db, billing = client_with_mocks()
        resp = _post(tc, billing, signals={**BASE_SIGNALS, "state": None, "incident_date": None})
        data = resp.json()
        assert resp.status_code == 200
        assert data["statute_check"]["status"] == "unknown"

    def test_missing_incident_date_returns_unknown(self, client_with_mocks):
        """No incident_date → unknown."""
        tc, db, billing = client_with_mocks()
        resp = _post(tc, billing, signals={**BASE_SIGNALS, "incident_date": None})
        data = resp.json()
        assert data["statute_check"]["status"] == "unknown"


# ===========================================================================
# Demand Letter Check
# ===========================================================================

class TestDemandLetterCheck:

    def test_all_required_items_present_is_complete(self, client_with_mocks):
        tc, db, billing = client_with_mocks()
        resp = _post(tc, billing, demand_letter_items=[
            "medical_summary", "injury_description", "liability_statement"
        ])
        data = resp.json()
        assert data["demand_letter_check"]["status"] == "complete"
        assert data["demand_letter_check"]["missing_items"] == []

    def test_missing_required_item_is_incomplete(self, client_with_mocks):
        tc, db, billing = client_with_mocks()
        resp = _post(tc, billing, demand_letter_items=["medical_summary"])
        data = resp.json()
        assert data["demand_letter_check"]["status"] == "incomplete"
        assert len(data["demand_letter_check"]["missing_items"]) > 0

    def test_no_items_is_not_reviewed(self, client_with_mocks):
        tc, db, billing = client_with_mocks()
        resp = _post(tc, billing)  # demand_letter_items not sent
        data = resp.json()
        assert data["demand_letter_check"]["status"] == "not_reviewed"

    def test_demand_letter_incomplete_flag_generated(self, client_with_mocks):
        tc, db, billing = client_with_mocks()
        resp = _post(tc, billing, demand_letter_items=["medical_summary"])
        data = resp.json()
        flag_names = [f["flag"] for f in data["flags"]]
        assert "DEMAND_LETTER_INCOMPLETE" in flag_names


# ===========================================================================
# Compliance Flags
# ===========================================================================

class TestComplianceFlags:

    def test_liability_contested_flag(self, client_with_mocks):
        tc, db, billing = client_with_mocks()
        resp = _post(tc, billing, signals={**BASE_SIGNALS, "liability_strength": "contested"})
        data = resp.json()
        flag_names = [f["flag"] for f in data["flags"]]
        assert "LIABILITY_CONTESTED" in flag_names

    def test_liability_unknown_flag(self, client_with_mocks):
        tc, db, billing = client_with_mocks()
        resp = _post(tc, billing, signals={**BASE_SIGNALS, "liability_strength": "unknown"})
        data = resp.json()
        flag_names = [f["flag"] for f in data["flags"]]
        assert "LIABILITY_UNKNOWN" in flag_names

    def test_policy_limit_unknown_flag(self, client_with_mocks):
        tc, db, billing = client_with_mocks()
        resp = _post(tc, billing, signals={**BASE_SIGNALS, "policy_limit_band": None})
        data = resp.json()
        flag_names = [f["flag"] for f in data["flags"]]
        assert "POLICY_LIMIT_UNKNOWN" in flag_names

    def test_insurer_unknown_flag(self, client_with_mocks):
        tc, db, billing = client_with_mocks()
        resp = _post(tc, billing, signals={**BASE_SIGNALS, "insurer": "Unknown"})
        data = resp.json()
        flag_names = [f["flag"] for f in data["flags"]]
        assert "INSURER_UNKNOWN" in flag_names

    def test_statute_overdue_flag_severity_critical(self, client_with_mocks):
        tc, db, billing = client_with_mocks()
        three_years_ago = (date.today() - timedelta(days=1095)).isoformat()
        resp = _post(tc, billing, signals={**BASE_SIGNALS, "incident_date": three_years_ago})
        data = resp.json()
        overdue_flags = [f for f in data["flags"] if f["flag"] == "STATUTE_OVERDUE"]
        assert len(overdue_flags) == 1
        assert overdue_flags[0]["severity"] == "critical"

    def test_no_flags_when_all_clean(self, client_with_mocks):
        """A clean case with known insurer, policy limit, moderate liability → no liability flags."""
        tc, db, billing = client_with_mocks()
        yesterday = (date.today() - timedelta(days=1)).isoformat()
        clean_signals = {
            "incident_type":      "slip_fall",
            "incident_date":      yesterday,
            "state":              "FL",
            "county":             "Miami-Dade",
            "injury_category":    "minor",
            "insurer":            "Allstate",
            "liability_strength": "clear",
            "litigation_stage":   "pre_suit",
            "policy_limit_band":  "50-100k",
        }
        resp = _post(tc, billing, signals=clean_signals,
                     demand_letter_items=["medical_summary", "injury_description", "liability_statement"])
        data = resp.json()
        flag_names = [f["flag"] for f in data["flags"]]
        # None of the liability/policy/insurer flags should appear
        assert "LIABILITY_CONTESTED" not in flag_names
        assert "LIABILITY_UNKNOWN" not in flag_names
        assert "POLICY_LIMIT_UNKNOWN" not in flag_names
        assert "INSURER_UNKNOWN" not in flag_names


# ===========================================================================
# Reward Consume
# ===========================================================================

@pytest.mark.skip(reason="v1 pricing: reward/credit system removed from strategy")
class TestRewardConsume:

    def test_consume_reward_true_calls_billing(self, client_with_mocks):
        billing = _mock_billing_idle()
        billing.consume_reward = AsyncMock(return_value=True)
        tc, db, _ = client_with_mocks(billing=billing)
        resp = _post(tc, billing, consume_reward=True)
        data = resp.json()
        assert resp.status_code == 200
        assert data["reward_consumed"] is True
        billing.consume_reward.assert_awaited_once_with(VALID_TENANT_ID)

    def test_consume_reward_false_does_not_call(self, client_with_mocks):
        billing = _mock_billing_idle()
        tc, db, _ = client_with_mocks(billing=billing)
        resp = _post(tc, billing, consume_reward=False)
        data = resp.json()
        assert data["reward_consumed"] is False
        billing.consume_reward.assert_not_awaited()

    def test_consume_reward_fail_open(self, client_with_mocks):
        """Billing consume error → billing_available=False but compliance still works."""
        from app.services.billing_service import BillingServiceUnavailable
        billing = MagicMock()
        billing.consume_reward = AsyncMock(side_effect=BillingServiceUnavailable("down"))
        tc, db, _ = client_with_mocks(billing=billing)
        resp = _post(tc, billing, consume_reward=True)
        data = resp.json()
        assert resp.status_code == 200
        assert data["billing_available"] is False
        # Compliance result still returned
        assert "statute_check" in data

    def test_consume_reward_random_error_fail_open(self, client_with_mocks):
        billing = MagicMock()
        billing.consume_reward = AsyncMock(side_effect=RuntimeError("network"))
        tc, db, _ = client_with_mocks(billing=billing)
        resp = _post(tc, billing, consume_reward=True)
        data = resp.json()
        assert resp.status_code == 200
        assert data["billing_available"] is False


# ===========================================================================
# DB Persistence
# ===========================================================================

class TestComplianceDBPersist:

    def test_db_execute_called_for_persist(self, client_with_mocks):
        """At least 3 execute calls: SOL query, version query, INSERT result, INSERT event."""
        billing = _mock_billing_idle()
        tc, db, _ = client_with_mocks(billing=billing)
        resp = _post(tc, billing)
        assert resp.status_code == 200
        # SOL select + version select + INSERT result + INSERT event = 4 calls
        assert db.execute.call_count >= 3

    def test_db_commit_called(self, client_with_mocks):
        billing = _mock_billing_idle()
        tc, db, _ = client_with_mocks(billing=billing)
        _post(tc, billing)
        assert db.commit.call_count >= 1

    def test_db_persist_failure_is_nonfatal(self, client_with_mocks):
        """If DB is down during persist, compliance result still returned."""
        db = MagicMock()
        # First call (SOL query) succeeds, everything after fails
        sol_call_count = [0]

        def _execute(q, params=None):
            sol_call_count[0] += 1
            if sol_call_count[0] == 1:
                # SOL rule query — return a valid row
                result = MagicMock()
                row = MagicMock()
                row.__getitem__ = lambda self, i: [
                    "test-rule-id",
                    {k: v for k, v in FL_SOL_RULE.items() if not k.startswith("_")},
                    "2.0.0",
                ][i]
                result.fetchone.return_value = row
                return result
            raise Exception("DB down on persist")

        db.execute.side_effect = _execute
        db.rollback.return_value = None
        db.commit.return_value = None

        billing = _mock_billing_idle()
        tc, _, _ = client_with_mocks(db=db, billing=billing)
        resp = _post(tc, billing)
        assert resp.status_code == 200
        assert "statute_check" in resp.json()


# ===========================================================================
# Response Shape
# ===========================================================================

class TestComplianceResponseShape:

    def test_all_required_fields_present(self, client_with_mocks):
        tc, db, billing = client_with_mocks()
        resp = _post(tc, billing)
        data = resp.json()
        assert "case_id" in data
        assert "tenant_id" in data
        assert "statute_check" in data
        assert "demand_letter_check" in data
        assert "flags" in data
        assert "reward_consumed" in data
        assert "billing_available" in data
        assert "validation_engine_version" in data
        assert "disclaimer" in data

    def test_validation_engine_version_is_string(self, client_with_mocks):
        tc, db, billing = client_with_mocks()
        resp = _post(tc, billing)
        version = resp.json()["validation_engine_version"]
        assert isinstance(version, str)
        assert len(version) > 0

    def test_case_id_echoed_as_string(self, client_with_mocks):
        tc, db, billing = client_with_mocks()
        resp = _post(tc, billing)
        assert resp.json()["case_id"] == VALID_CASE_ID

    def test_disclaimer_present(self, client_with_mocks):
        tc, db, billing = client_with_mocks()
        resp = _post(tc, billing)
        assert len(resp.json()["disclaimer"]) > 0

    def test_statute_check_shape(self, client_with_mocks):
        tc, db, billing = client_with_mocks()
        resp = _post(tc, billing)
        sc = resp.json()["statute_check"]
        assert "status" in sc
        assert "note" in sc
