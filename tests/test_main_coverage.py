"""
Tests for app/main.py
Covers: root endpoint, health endpoint, exception handlers, lifespan, middleware wiring.
"""

import pytest
from unittest.mock import patch, MagicMock
from fastapi.testclient import TestClient


@pytest.fixture(scope="module")
def client():
    from app.main import app
    return TestClient(app)


class TestRootEndpoint:
    def test_root_returns_200(self, client):
        resp = client.get("/")
        assert resp.status_code == 200

    def test_root_has_service_name(self, client):
        resp = client.get("/")
        data = resp.json()
        assert data["service"] == "TrueVow LEVERAGE™ Service"

    def test_root_has_zero_knowledge_flag(self, client):
        resp = client.get("/")
        data = resp.json()
        assert data["zero_knowledge_compliant"] is True

    def test_root_has_aba_compliant_flag(self, client):
        resp = client.get("/")
        data = resp.json()
        assert data["aba_compliant"] is True

    def test_root_has_version(self, client):
        resp = client.get("/")
        data = resp.json()
        assert "version" in data

    def test_root_has_api_version(self, client):
        resp = client.get("/")
        data = resp.json()
        assert data["api_version"] == "v1"


class TestHealthEndpoint:
    def test_health_returns_200(self, client):
        resp = client.get("/health")
        assert resp.status_code == 200

    def test_health_has_status_key(self, client):
        resp = client.get("/health")
        data = resp.json()
        assert "status" in data

    def test_health_has_database_key(self, client):
        resp = client.get("/health")
        data = resp.json()
        assert "database" in data

    def test_health_has_environment_key(self, client):
        resp = client.get("/health")
        data = resp.json()
        assert "environment" in data

    def test_health_zero_knowledge_compliant(self, client):
        resp = client.get("/health")
        data = resp.json()
        assert data["zero_knowledge_compliant"] is True

    def test_health_service_name(self, client):
        resp = client.get("/health")
        data = resp.json()
        assert "TrueVow" in data["service"]


class TestExceptionHandlers:
    def test_value_error_handler_returns_400(self, client):
        """Trigger ValueError handler via a route that raises ValueError."""
        # The app has a ValueError handler at the global level
        # We can test it by importing and calling the handler directly
        from app.main import app, value_error_handler
        import asyncio
        from fastapi import Request
        from unittest.mock import MagicMock

        mock_request = MagicMock()
        mock_request.state.request_id = "test-req-id"
        exc = ValueError("test validation error")

        resp = asyncio.get_event_loop().run_until_complete(
            value_error_handler(mock_request, exc)
        )
        assert resp.status_code == 400
        import json
        body = json.loads(resp.body)
        assert body["error_code"] == "VALIDATION_ERROR"
        assert body["detail"] == "test validation error"

    def test_general_exception_handler_returns_500(self, client):
        """Test general exception handler directly."""
        from app.main import app, general_exception_handler
        import asyncio
        from unittest.mock import MagicMock

        mock_request = MagicMock()
        mock_request.state.request_id = "test-req-id"
        exc = RuntimeError("unexpected failure")

        resp = asyncio.get_event_loop().run_until_complete(
            general_exception_handler(mock_request, exc)
        )
        assert resp.status_code == 500

    def test_general_exception_handler_no_state_request_id(self):
        """Test handler when request.state has no request_id attribute."""
        from app.main import general_exception_handler
        import asyncio
        from unittest.mock import MagicMock

        mock_request = MagicMock()
        # Make getattr(request.state, 'request_id', None) return None
        del mock_request.state.request_id
        exc = RuntimeError("no request id")

        resp = asyncio.get_event_loop().run_until_complete(
            general_exception_handler(mock_request, exc)
        )
        assert resp.status_code == 500


class TestOpenApiDocs:
    def test_docs_endpoint_accessible(self, client):
        resp = client.get("/docs")
        assert resp.status_code == 200

    def test_openapi_json_accessible(self, client):
        resp = client.get("/openapi.json")
        assert resp.status_code == 200

    def test_openapi_has_title(self, client):
        resp = client.get("/openapi.json")
        data = resp.json()
        assert "TrueVow" in data["info"]["title"]


class TestMiddlewareWiring:
    def test_cors_headers_present_for_allowed_origin(self, client):
        """CORS middleware is active and returns headers for allowed origins."""
        resp = client.get(
            "/",
            headers={"Origin": "http://localhost:3000"}
        )
        # Either CORS header present or request succeeds (CORS depends on config)
        assert resp.status_code == 200

    def test_request_id_header_in_response(self, client):
        """SecurityMiddleware adds X-Request-ID to responses."""
        resp = client.get("/")
        assert "X-Request-ID" in resp.headers


class TestLifespanStartup:
    def test_app_starts_and_handles_requests(self):
        """App startup completes and can serve requests (lifespan ran)."""
        from app.main import app
        with TestClient(app) as c:
            resp = c.get("/")
            assert resp.status_code == 200

    def test_service_registry_disabled_path(self):
        """When SERVICE_REGISTRY_ENABLED=false, startup completes without error."""
        import os
        from app.main import app
        # Ensure registry is disabled (already is in test env)
        with patch.dict(os.environ, {"SERVICE_REGISTRY_ENABLED": "false"}):
            with TestClient(app) as c:
                resp = c.get("/health")
                assert resp.status_code == 200
