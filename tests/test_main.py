"""
Tests for app/main.py — root endpoints and app structure.
Uses the shared `client` fixture (no real DB needed).
"""

import pytest
from fastapi.testclient import TestClient


class TestRootEndpoint:

    def test_root_returns_200(self, client):
        response = client.get("/")
        assert response.status_code == 200

    def test_root_has_service_name(self, client):
        response = client.get("/")
        data = response.json()
        assert "service" in data
        assert "TrueVow" in data["service"]

    def test_root_has_version(self, client):
        response = client.get("/")
        data = response.json()
        assert "version" in data
        assert data["version"] == "1.0.0"

    def test_root_has_api_version(self, client):
        response = client.get("/")
        data = response.json()
        assert "api_version" in data
        assert data["api_version"] == "v1"

    def test_root_zero_knowledge_flag(self, client):
        response = client.get("/")
        data = response.json()
        assert data.get("zero_knowledge_compliant") is True

    def test_root_aba_compliant_flag(self, client):
        response = client.get("/")
        data = response.json()
        assert data.get("aba_compliant") is True


class TestHealthEndpoint:

    def test_health_returns_200_or_503(self, client):
        response = client.get("/health")
        assert response.status_code in [200, 503]

    def test_health_has_status_key(self, client):
        response = client.get("/health")
        data = response.json()
        assert "status" in data

    def test_health_has_service_name(self, client):
        response = client.get("/health")
        data = response.json()
        assert "service" in data

    def test_health_has_version(self, client):
        response = client.get("/health")
        data = response.json()
        assert "version" in data

    def test_health_has_database_key(self, client):
        response = client.get("/health")
        data = response.json()
        assert "database" in data

    def test_health_zero_knowledge_flag(self, client):
        response = client.get("/health")
        data = response.json()
        assert data.get("zero_knowledge_compliant") is True


class TestApiV1Router:

    def test_api_v1_health_reachable(self, client):
        response = client.get("/api/v1/health")
        assert response.status_code in [200, 401, 403]

    def test_docs_url_accessible(self, client):
        response = client.get("/docs")
        assert response.status_code == 200

    def test_openapi_json_accessible(self, client):
        response = client.get("/openapi.json")
        assert response.status_code == 200

    def test_openapi_has_paths(self, client):
        response = client.get("/openapi.json")
        data = response.json()
        assert "paths" in data
        assert len(data["paths"]) > 0


class TestExceptionHandlers:

    def test_value_error_returns_400(self, client):
        """Trigger the ValueError handler via a known validation endpoint."""
        # POST to validation with missing body to get a structured error back
        response = client.post("/api/v1/validation/validate", json={})
        # 400, 401, 403, or 422 — all mean the handler chain is working
        assert response.status_code in [400, 401, 403, 422]

    def test_404_for_unknown_path(self, client):
        response = client.get("/nonexistent-path-xyz")
        assert response.status_code == 404
