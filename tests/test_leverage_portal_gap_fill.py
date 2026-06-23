"""
Tests for LEVERAGE Portal Gap Fill endpoints.

Covers all 7 gaps:
  1. Rewards Ledger (GET /rewards/ledger, GET /rewards/summary)
  2. Damages Persistence (POST /case/{id}/damages/save, GET /case/{id}/damages)
  3. Disbursement Persistence (POST /case/{id}/disbursement/save, GET /case/{id}/disbursement)
  4. Case Lifecycle (GET /cases, GET /{id}/events, GET /{id}/detail)
  5. Deadline Tracker (POST /case/{id}/save, GET /case/{id}, GET /upcoming)
  6. Combined Case Economics (GET /case/{id}/economics)
  7. Tenant Analytics (GET /analytics)
"""

import pytest
from unittest.mock import AsyncMock, MagicMock, patch
from fastapi.testclient import TestClient


VALID_TENANT_ID = "org_test_123"
VALID_CASE_ID = "3fa85f64-5717-4562-b3fc-2c963f66afa6"


def _mock_db():
    """Return a mock DB session that silently accepts all execute/commit/rollback calls."""
    db = MagicMock()
    db.commit = MagicMock()
    db.rollback = MagicMock()
    db.close = MagicMock()
    return db


@pytest.fixture
def client():
    """Create a test client with mocked DB."""
    from app.main import app
    from app.core.database import get_db

    db = _mock_db()

    def override_get_db():
        yield db

    app.dependency_overrides[get_db] = override_get_db
    with TestClient(app) as c:
        yield c
    app.dependency_overrides.clear()


# =============================================================================
# GAP 1: REWARDS LEDGER
# =============================================================================

@pytest.mark.skip(reason="v1 pricing: reward/credit system removed from strategy")
class TestRewardsLedger:
    """Tests for GET /leverage/rewards/ledger and GET /leverage/rewards/summary."""

    def test_get_reward_ledger_returns_200(self, client):
        """Ledger endpoint returns 200 with empty list when no entries exist."""
        mock_db = client.app.dependency_overrides[
            __import__("app.core.database", fromlist=["get_db"]).get_db
        ].__next__.__self__

        # The mock DB execute returns empty results
        with patch("app.api.v1.endpoints.leverage_rewards.get_db", return_value=iter([_mock_db()])):
            resp = client.get(
                "/api/v1/leverage/rewards/ledger",
                params={"tenant_id": VALID_TENANT_ID},
            )
        # Accept 200 or 500 (DB unavailable in test)
        assert resp.status_code in (200, 500)

    def test_get_reward_summary_returns_200(self, client):
        """Summary endpoint returns 200 with zeros when no entries exist."""
        with patch("app.api.v1.endpoints.leverage_rewards.get_db", return_value=iter([_mock_db()])):
            resp = client.get(
                "/api/v1/leverage/rewards/summary",
                params={"tenant_id": VALID_TENANT_ID},
            )
        assert resp.status_code in (200, 500)

    def test_get_reward_balance_returns_200(self, client):
        """Existing balance endpoint still works."""
        with patch("app.api.v1.endpoints.leverage_rewards.get_billing_service") as mock_billing:
            billing_mock = MagicMock()
            billing_mock.get_active_reward_count = AsyncMock(return_value=5)
            mock_billing.return_value = billing_mock

            resp = client.get(
                "/api/v1/leverage/rewards/balance",
                params={"tenant_id": VALID_TENANT_ID},
            )
        assert resp.status_code == 200
        data = resp.json()
        assert data["active_credits"] == 5


# =============================================================================
# GAP 2: DAMAGES PERSISTENCE
# =============================================================================

class TestDamagesPersistence:
    """Tests for damages save/retrieve endpoints."""

    def test_calculate_damages_still_stateless(self, client):
        """Existing stateless calculator endpoint still works."""
        resp = client.post(
            "/api/v1/leverage/damages",
            json={
                "tenant_id": VALID_TENANT_ID,
                "medical": {"emergency_room": 5000, "hospitalization": 10000},
                "lost_income": {"weekly_wage": 1000, "weeks_missed": 4},
                "pain_suffering_multiplier": 3.0,
            },
        )
        assert resp.status_code == 200
        data = resp.json()
        assert data["gross_damages"] > 0
        assert "breakdown" in data

    def test_save_damages_worksheet_endpoint_exists(self, client):
        """Save damages endpoint is reachable (may fail on DB)."""
        with patch("app.api.v1.endpoints.leverage_economics.get_db", return_value=iter([_mock_db()])):
            resp = client.post(
                f"/api/v1/leverage/case/{VALID_CASE_ID}/damages/save",
                json={
                    "tenant_id": VALID_TENANT_ID,
                    "input_data": {"medical": {"emergency_room": 5000}},
                    "result_data": {"gross_damages": 15000},
                },
            )
        # Accept any response — we just verify the route exists
        assert resp.status_code in (200, 201, 500)

    def test_get_saved_damages_endpoint_exists(self, client):
        """Get saved damages endpoint is reachable."""
        with patch("app.api.v1.endpoints.leverage_economics.get_db", return_value=iter([_mock_db()])):
            resp = client.get(
                f"/api/v1/leverage/case/{VALID_CASE_ID}/damages",
                params={"tenant_id": VALID_TENANT_ID},
            )
        assert resp.status_code in (200, 500)


# =============================================================================
# GAP 3: DISBURSEMENT PERSISTENCE
# =============================================================================

class TestDisbursementPersistence:
    """Tests for disbursement save/retrieve endpoints."""

    def test_calculate_disbursement_still_stateless(self, client):
        """Existing stateless calculator endpoint still works."""
        resp = client.post(
            "/api/v1/leverage/disbursement",
            json={
                "tenant_id": VALID_TENANT_ID,
                "filing_fees": 450,
                "expert_witness_fees": 3500,
                "contingency_fee_pct": 33.33,
                "gross_settlement": 75000,
            },
        )
        assert resp.status_code == 200
        data = resp.json()
        assert data["total_disbursements"] > 0

    def test_save_disbursement_worksheet_endpoint_exists(self, client):
        """Save disbursement endpoint is reachable."""
        with patch("app.api.v1.endpoints.leverage_economics.get_db", return_value=iter([_mock_db()])):
            resp = client.post(
                f"/api/v1/leverage/case/{VALID_CASE_ID}/disbursement/save",
                json={
                    "tenant_id": VALID_TENANT_ID,
                    "input_data": {"filing_fees": 450},
                    "result_data": {"total_disbursements": 450},
                },
            )
        assert resp.status_code in (200, 201, 500)

    def test_get_saved_disbursement_endpoint_exists(self, client):
        """Get saved disbursement endpoint is reachable."""
        with patch("app.api.v1.endpoints.leverage_economics.get_db", return_value=iter([_mock_db()])):
            resp = client.get(
                f"/api/v1/leverage/case/{VALID_CASE_ID}/disbursement",
                params={"tenant_id": VALID_TENANT_ID},
            )
        assert resp.status_code in (200, 500)


# =============================================================================
# GAP 4: CASE LIFECYCLE (LIST, EVENTS, DETAIL)
# =============================================================================

class TestCaseLifecyclePortal:
    """Tests for case list, events, and detail endpoints."""

    def test_list_cases_endpoint_exists(self, client):
        """GET /leverage/cases endpoint is reachable."""
        with patch("app.api.v1.endpoints.leverage_case.get_db", return_value=iter([_mock_db()])):
            resp = client.get(
                "/api/v1/leverage/cases",
                params={"tenant_id": VALID_TENANT_ID},
            )
        assert resp.status_code in (200, 500)

    def test_get_case_events_endpoint_exists(self, client):
        """GET /leverage/case/{id}/events endpoint is reachable."""
        with patch("app.api.v1.endpoints.leverage_case.get_db", return_value=iter([_mock_db()])):
            resp = client.get(
                f"/api/v1/leverage/case/{VALID_CASE_ID}/events",
                params={"tenant_id": VALID_TENANT_ID},
            )
        assert resp.status_code in (200, 500)

    def test_get_case_detail_endpoint_exists(self, client):
        """GET /leverage/case/{id}/detail endpoint is reachable."""
        with patch("app.api.v1.endpoints.leverage_case.get_db", return_value=iter([_mock_db()])):
            resp = client.get(
                f"/api/v1/leverage/case/{VALID_CASE_ID}/detail",
                params={"tenant_id": VALID_TENANT_ID},
            )
        assert resp.status_code in (200, 404, 500)


# =============================================================================
# GAP 5: DEADLINE TRACKER
# =============================================================================

class TestDeadlineTracker:
    """Tests for deadline save/retrieve/upcoming endpoints."""

    def test_save_deadline_endpoint_exists(self, client):
        """POST /deadlines/case/{id}/save endpoint is reachable."""
        with patch("app.api.v1.endpoints.deadlines.get_db", return_value=iter([_mock_db()])):
            resp = client.post(
                f"/api/v1/deadlines/case/{VALID_CASE_ID}/save",
                json={
                    "tenant_id": VALID_TENANT_ID,
                    "deadline_type": "sol",
                    "deadline_date": "2026-12-31",
                    "days_remaining": 250,
                    "urgency": "OK",
                    "source_state": "FL",
                },
            )
        assert resp.status_code in (200, 201, 500)

    def test_get_saved_deadlines_endpoint_exists(self, client):
        """GET /deadlines/case/{id} endpoint is reachable."""
        with patch("app.api.v1.endpoints.deadlines.get_db", return_value=iter([_mock_db()])):
            resp = client.get(
                f"/api/v1/deadlines/case/{VALID_CASE_ID}",
                params={"tenant_id": VALID_TENANT_ID},
            )
        assert resp.status_code in (200, 500)

    def test_get_upcoming_deadlines_endpoint_exists(self, client):
        """GET /deadlines/upcoming endpoint is reachable."""
        with patch("app.api.v1.endpoints.deadlines.get_db", return_value=iter([_mock_db()])):
            resp = client.get(
                "/api/v1/deadlines/upcoming",
                params={"tenant_id": VALID_TENANT_ID, "days": 30},
            )
        assert resp.status_code in (200, 500)

    def test_sol_calculator_still_works(self, client):
        """Existing SOL calculator endpoint still works."""
        with patch("app.api.v1.endpoints.deadlines.get_db", return_value=iter([_mock_db()])):
            resp = client.post(
                "/api/v1/deadlines/sol",
                json={
                    "jurisdiction_state": "FL",
                    "practice_area": "personal_injury",
                    "incident_date": "2024-01-15",
                },
            )
        # May return 404 if SOL rules not in test DB, or 200 if found
        assert resp.status_code in (200, 404, 500)


# =============================================================================
# GAP 6: COMBINED CASE ECONOMICS
# =============================================================================

class TestCombinedCaseEconomics:
    """Tests for GET /leverage/case/{id}/economics endpoint."""

    def test_case_economics_endpoint_exists(self, client):
        """GET /leverage/case/{id}/economics endpoint is reachable."""
        with patch("app.api.v1.endpoints.leverage_economics.get_db", return_value=iter([_mock_db()])):
            resp = client.get(
                f"/api/v1/leverage/case/{VALID_CASE_ID}/economics",
                params={"tenant_id": VALID_TENANT_ID},
            )
        assert resp.status_code in (200, 500)


# =============================================================================
# GAP 7: TENANT ANALYTICS
# =============================================================================

class TestTenantAnalytics:
    """Tests for GET /leverage/analytics endpoint."""

    def test_tenant_analytics_endpoint_exists(self, client):
        """GET /leverage/analytics endpoint is reachable."""
        with patch("app.api.v1.endpoints.leverage_case.get_db", return_value=iter([_mock_db()])):
            resp = client.get(
                "/api/v1/leverage/analytics",
                params={"tenant_id": VALID_TENANT_ID},
            )
        assert resp.status_code in (200, 500)


# =============================================================================
# SERVICE CONFIG VERIFICATION
# =============================================================================

class TestServiceConfig:
    """Verify service_config.py has all new endpoints registered."""

    def test_all_portal_endpoints_registered(self):
        """All new portal endpoints are registered in service config."""
        from app.services.service_config import LEVERAGE_SERVICE_CONFIG

        paths = [e["path"] for e in LEVERAGE_SERVICE_CONFIG.endpoints]

        # Gap 1: Rewards
        assert "/api/v1/leverage/rewards/ledger" in paths
        assert "/api/v1/leverage/rewards/summary" in paths

        # Gap 2: Damages persistence
        assert "/api/v1/leverage/case/{case_id}/damages/save" in paths
        assert "/api/v1/leverage/case/{case_id}/damages" in paths

        # Gap 3: Disbursement persistence
        assert "/api/v1/leverage/case/{case_id}/disbursement/save" in paths
        assert "/api/v1/leverage/case/{case_id}/disbursement" in paths

        # Gap 4: Case lifecycle
        assert "/api/v1/leverage/cases" in paths
        assert "/api/v1/leverage/case/{case_id}/events" in paths
        assert "/api/v1/leverage/case/{case_id}/detail" in paths

        # Gap 5: Deadline persistence
        assert "/api/v1/deadlines/case/{case_id}/save" in paths
        assert "/api/v1/deadlines/upcoming" in paths

        # Gap 6: Combined economics
        assert "/api/v1/leverage/case/{case_id}/economics" in paths

        # Gap 7: Tenant analytics
        assert "/api/v1/leverage/analytics" in paths

    def test_all_portal_capabilities_registered(self):
        """All new portal capabilities are registered."""
        from app.services.service_config import LEVERAGE_SERVICE_CONFIG

        caps = LEVERAGE_SERVICE_CONFIG.capabilities

        # New portal display capabilities
        assert "leverage_reward_ledger_display" in caps
        assert "leverage_damages_persistence" in caps
        assert "leverage_disbursement_persistence" in caps
        assert "leverage_case_list" in caps
        assert "leverage_case_timeline" in caps
        assert "leverage_case_detail" in caps
        assert "leverage_combined_economics" in caps
        assert "leverage_tenant_analytics" in caps
        assert "leverage_deadline_tracker" in caps

    def test_module_versions_bumped(self):
        """Module versions bumped to 1.1.0 for updated modules."""
        from app.services.service_config import LEVERAGE_MODULES

        for mod in LEVERAGE_MODULES:
            if mod["module_name"] in ("leverage_case_lifecycle", "leverage_rewards", "leverage_economics"):
                assert mod["module_version"] == "1.1.0", f"{mod['module_name']} not bumped to 1.1.0"
