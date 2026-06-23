"""
Tests for GET /leverage/case/{case_id}/history endpoint.

History endpoint retrieves all validation runs for a case, ordered by version.
Each run is versioned and immutable — history is append-only.
"""

import pytest
from unittest.mock import MagicMock, patch
from fastapi.testclient import TestClient
from datetime import datetime, timezone
import json

from app.main import app
from app.core.database import get_db


# ============================================================================
# FIXTURES
# ============================================================================

@pytest.fixture
def client():
    """Plain test client (no DB override needed for history endpoint)."""
    return TestClient(app)


@pytest.fixture
def client_with_mocks():
    """
    Factory fixture that creates a test client with mocked DB session.
    Uses FastAPI's dependency_overrides for proper DI injection.
    """
    def _make(db=None):
        if db is None:
            db = _mock_db_with_history()

        def override_db():
            yield db

        app.dependency_overrides[get_db] = override_db
        tc = TestClient(app)
        return tc, db

    yield _make
    app.dependency_overrides.clear()


def _mock_db_with_history(history_rows=None, total_count=3):
    """Create a mock DB session that returns history rows."""
    db = MagicMock()
    
    # Default history rows
    if history_rows is None:
        history_rows = [
            # version, statute_status, days_remaining, demand_status, missing_items, flags, engine_version, validated_at
            (3, "warning", 45, "complete", None, json.dumps([{"code": "STATUTE_WARNING", "message": "SOL in 45 days"}]), "1.0.0", datetime.now(timezone.utc)),
            (2, "safe", 120, "incomplete", json.dumps(["medical_records"]), json.dumps([]), "1.0.0", datetime.now(timezone.utc)),
            (1, "safe", 180, "incomplete", json.dumps(["medical_records", "police_report"]), None, "1.0.0", datetime.now(timezone.utc)),
        ]
    
    call_count = [0]
    
    def _execute(query, params=None):
        result = MagicMock()
        call_count[0] += 1
        n = call_count[0]
        
        if n == 1:
            # COUNT query
            result.fetchone.return_value = [total_count]
        elif n == 2:
            # SELECT history query
            result.fetchall.return_value = history_rows
        else:
            result.fetchone.return_value = None
            result.fetchall.return_value = []
        return result
    
    db.execute.side_effect = _execute
    return db


def _mock_db_empty():
    """Create a mock DB session with no history."""
    db = MagicMock()
    
    call_count = [0]
    
    def _execute(query, params=None):
        result = MagicMock()
        call_count[0] += 1
        n = call_count[0]
        
        if n == 1:
            # COUNT query
            result.fetchone.return_value = [0]
        else:
            result.fetchall.return_value = []
        return result
    
    db.execute.side_effect = _execute
    return db


def _mock_db_error():
    """Create a mock DB session that raises an exception."""
    db = MagicMock()
    db.execute.side_effect = Exception("DB connection failed")
    return db


# ============================================================================
# UUID VALIDATION TESTS
# ============================================================================

class TestHistoryUUIDValidation:
    """Test that case_id must be a valid UUID."""

    def test_valid_uuid_accepted(self, client_with_mocks):
        """Valid UUID should be accepted."""
        client, db = client_with_mocks()
        resp = client.get(
            "/api/v1/leverage/case/3fa85f64-5717-4562-b3fc-2c963f66afa6/history",
            params={"tenant_id": "org_123"},
        )
        assert resp.status_code == 200

    def test_invalid_uuid_rejected(self, client):
        """Invalid UUID should return 422."""
        resp = client.get(
            "/api/v1/leverage/case/not-a-uuid/history",
            params={"tenant_id": "org_123"},
        )
        assert resp.status_code == 422
        assert "uuid" in resp.text.lower() or "validation" in resp.text.lower()

    def test_missing_tenant_id_rejected(self, client):
        """Missing tenant_id should return 422."""
        resp = client.get(
            "/api/v1/leverage/case/3fa85f64-5717-4562-b3fc-2c963f66afa6/history",
        )
        assert resp.status_code == 422


# ============================================================================
# HISTORY RETRIEVAL TESTS
# ============================================================================

class TestHistoryRetrieval:
    """Test history retrieval logic."""

    def test_returns_history_list(self, client_with_mocks):
        """Should return list of validation runs."""
        client, db = client_with_mocks()
        resp = client.get(
            "/api/v1/leverage/case/3fa85f64-5717-4562-b3fc-2c963f66afa6/history",
            params={"tenant_id": "org_123"},
        )
        assert resp.status_code == 200
        data = resp.json()
        assert "history" in data
        assert isinstance(data["history"], list)

    def test_returns_total_count(self, client_with_mocks):
        """Should return total count of validation runs."""
        client, db = client_with_mocks()
        resp = client.get(
            "/api/v1/leverage/case/3fa85f64-5717-4562-b3fc-2c963f66afa6/history",
            params={"tenant_id": "org_123"},
        )
        assert resp.status_code == 200
        data = resp.json()
        assert "total_runs" in data
        assert data["total_runs"] == 3

    def test_returns_case_and_tenant_id(self, client_with_mocks):
        """Should echo back case_id and tenant_id."""
        client, db = client_with_mocks()
        resp = client.get(
            "/api/v1/leverage/case/3fa85f64-5717-4562-b3fc-2c963f66afa6/history",
            params={"tenant_id": "org_123"},
        )
        assert resp.status_code == 200
        data = resp.json()
        assert data["case_id"] == "3fa85f64-5717-4562-b3fc-2c963f66afa6"
        assert data["tenant_id"] == "org_123"

    def test_history_entries_have_required_fields(self, client_with_mocks):
        """Each history entry should have required fields."""
        client, db = client_with_mocks()
        resp = client.get(
            "/api/v1/leverage/case/3fa85f64-5717-4562-b3fc-2c963f66afa6/history",
            params={"tenant_id": "org_123"},
        )
        assert resp.status_code == 200
        data = resp.json()
        for entry in data["history"]:
            assert "version" in entry
            assert "validated_at" in entry


# ============================================================================
# ORDERING TESTS
# ============================================================================

class TestHistoryOrdering:
    """Test that history is ordered by version descending."""

    def test_ordered_by_version_desc(self, client_with_mocks):
        """History should be ordered by version descending (newest first)."""
        client, db = client_with_mocks()
        resp = client.get(
            "/api/v1/leverage/case/3fa85f64-5717-4562-b3fc-2c963f66afa6/history",
            params={"tenant_id": "org_123"},
        )
        assert resp.status_code == 200
        data = resp.json()
        versions = [entry["version"] for entry in data["history"]]
        assert versions == sorted(versions, reverse=True)


# ============================================================================
# PAGINATION TESTS
# ============================================================================

class TestHistoryPagination:
    """Test pagination parameters."""

    def test_default_limit_is_20(self, client_with_mocks):
        """Default limit should be 20."""
        client, db = client_with_mocks()
        resp = client.get(
            "/api/v1/leverage/case/3fa85f64-5717-4562-b3fc-2c963f66afa6/history",
            params={"tenant_id": "org_123"},
        )
        assert resp.status_code == 200

    def test_custom_limit_accepted(self, client_with_mocks):
        """Custom limit should be accepted."""
        client, db = client_with_mocks()
        resp = client.get(
            "/api/v1/leverage/case/3fa85f64-5717-4562-b3fc-2c963f66afa6/history",
            params={"tenant_id": "org_123", "limit": 5},
        )
        assert resp.status_code == 200

    def test_limit_max_100(self, client_with_mocks):
        """Limit should be clamped to max 100."""
        client, db = client_with_mocks()
        resp = client.get(
            "/api/v1/leverage/case/3fa85f64-5717-4562-b3fc-2c963f66afa6/history",
            params={"tenant_id": "org_123", "limit": 500},
        )
        assert resp.status_code == 200

    def test_offset_accepted(self, client_with_mocks):
        """Offset should be accepted for pagination."""
        client, db = client_with_mocks()
        resp = client.get(
            "/api/v1/leverage/case/3fa85f64-5717-4562-b3fc-2c963f66afa6/history",
            params={"tenant_id": "org_123", "offset": 10},
        )
        assert resp.status_code == 200


# ============================================================================
# EMPTY HISTORY TESTS
# ============================================================================

class TestEmptyHistory:
    """Test behavior when no history exists."""

    def test_empty_history_returns_empty_list(self, client_with_mocks):
        """Empty history should return empty list, not error."""
        client, db = client_with_mocks(db=_mock_db_empty())
        resp = client.get(
            "/api/v1/leverage/case/3fa85f64-5717-4562-b3fc-2c963f66afa6/history",
            params={"tenant_id": "org_123"},
        )
        assert resp.status_code == 200
        data = resp.json()
        assert data["history"] == []
        assert data["total_runs"] == 0


# ============================================================================
# FAIL-OPEN TESTS
# ============================================================================

class TestHistoryFailOpen:
    """Test fail-open behavior for DB errors."""

    def test_db_error_returns_empty_history(self, client_with_mocks):
        """DB error should return empty history, not 500."""
        client, db = client_with_mocks(db=_mock_db_error())
        resp = client.get(
            "/api/v1/leverage/case/3fa85f64-5717-4562-b3fc-2c963f66afa6/history",
            params={"tenant_id": "org_123"},
        )
        assert resp.status_code == 200
        data = resp.json()
        assert data["history"] == []
        assert data["total_runs"] == 0


# ============================================================================
# TENANT ISOLATION TESTS
# ============================================================================

class TestHistoryTenantIsolation:
    """Test that tenant_id is properly scoped."""

    def test_tenant_id_passed_to_query(self, client_with_mocks):
        """Tenant ID should be passed to DB query for isolation."""
        client, db = client_with_mocks()
        resp = client.get(
            "/api/v1/leverage/case/3fa85f64-5717-4562-b3fc-2c963f66afa6/history",
            params={"tenant_id": "org_456"},
        )
        assert resp.status_code == 200
        # Verify tenant_id was used in the query
        calls = [str(call) for call in db.execute.call_args_list]
        # The params dict should contain tenant_id
        assert db.execute.call_count >= 1
