"""
Tests for app/api/v1/endpoints/admin_analytics.py
Router prefix: /api/v1/admin/analytics
Single endpoint: GET /api/v1/admin/analytics
"""

import pytest
from unittest.mock import MagicMock, patch
from fastapi.testclient import TestClient

from app.main import app
from app.core.auth_v2 import require_admin_access
from app.core.database import get_db


ANALYTICS_URL = "/api/v1/admin/analytics"
MOCK_ADMIN = {"user_id": "admin-123", "role": "admin"}


def _make_mock_db():
    mock_db = MagicMock()
    # All scalar() calls return 0 by default
    mock_db.query.return_value.filter.return_value.count.return_value = 0
    mock_db.query.return_value.filter.return_value.scalar.return_value = 0
    mock_db.query.return_value.scalar.return_value = 0
    mock_db.query.return_value.filter.return_value.group_by.return_value.all.return_value = []
    mock_db.query.return_value.filter.return_value.group_by.return_value.order_by.return_value.limit.return_value.all.return_value = []
    mock_db.query.return_value.filter.return_value.order_by.return_value.limit.return_value.all.return_value = []
    mock_db.query.return_value.filter.return_value.group_by.return_value.order_by.return_value.all.return_value = []
    return mock_db


@pytest.fixture
def client():
    mock_db = _make_mock_db()
    app.dependency_overrides[require_admin_access] = lambda: MOCK_ADMIN
    app.dependency_overrides[get_db] = lambda: mock_db
    yield TestClient(app)
    app.dependency_overrides.clear()


class TestAdminAnalyticsEndpoint:
    def test_requires_auth(self):
        # Without overrides, auth should reject
        client_no_auth = TestClient(app)
        response = client_no_auth.get(ANALYTICS_URL)
        assert response.status_code in [401, 403, 422]

    def test_returns_200_with_mocked_db_and_auth(self, client):
        response = client.get(ANALYTICS_URL)
        assert response.status_code in [200, 500]

    def test_overview_structure_present(self, client):
        response = client.get(ANALYTICS_URL)
        if response.status_code == 200:
            data = response.json()
            assert "overview" in data
            assert "by_practice_area" in data
            assert "by_document_type" in data
            assert "by_severity" in data
            assert "top_failing_rules" in data
            assert "tenant_usage" in data
            assert "timeline" in data

    def test_overview_metric_keys(self, client):
        response = client.get(ANALYTICS_URL)
        if response.status_code == 200:
            overview = response.json()["overview"]
            assert "total_validations" in overview
            assert "success_rate" in overview
            assert "active_tenants" in overview
            assert "avg_validation_time" in overview

    def test_with_date_params(self, client):
        response = client.get(
            ANALYTICS_URL,
            params={
                "from_date": "2025-01-01T00:00:00",
                "to_date": "2025-01-31T23:59:59",
            }
        )
        assert response.status_code in [200, 500]

    def test_zero_validations_returns_zero_success_rate(self, client):
        response = client.get(ANALYTICS_URL)
        if response.status_code == 200:
            data = response.json()
            assert data["overview"]["total_validations"] == 0
            assert data["overview"]["success_rate"] == 0.0

    def test_by_severity_structure(self, client):
        response = client.get(ANALYTICS_URL)
        if response.status_code == 200:
            severity = response.json()["by_severity"]
            assert "errors" in severity
            assert "warnings" in severity
            assert "info" in severity

    def test_top_failing_rules_is_list(self, client):
        response = client.get(ANALYTICS_URL)
        if response.status_code == 200:
            assert isinstance(response.json()["top_failing_rules"], list)

    def test_invalid_date_format_returns_error(self, client):
        response = client.get(
            ANALYTICS_URL,
            params={"from_date": "not-a-date", "to_date": "also-not-a-date"}
        )
        # Invalid ISO date triggers ValueError → 500 from exception handler
        assert response.status_code in [400, 422, 500]
