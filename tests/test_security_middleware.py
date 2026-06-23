"""
Tests for app/core/security_middleware.py
Covers: is_valid_uuid, validate_uuid_strict, get_api_key_from_request,
        sanitize_error, get_size_limit_for_path, get_timeout_for_path,
        log_audit_entry, AuditLogEntry, is_url_allowed, validate_url,
        add_rate_limit_headers, validate_path_uuid, validate_query_uuid,
        SecurityMiddleware (X-API-Key, size limit, error handler).
"""

import pytest
import asyncio
from unittest.mock import AsyncMock, MagicMock, patch
from uuid import UUID, uuid4

from fastapi import HTTPException
from fastapi.responses import Response
from fastapi.testclient import TestClient

from app.core.security_middleware import (
    is_valid_uuid,
    validate_uuid_strict,
    get_size_limit_for_path,
    get_timeout_for_path,
    sanitize_error,
    log_audit_entry,
    AuditLogEntry,
    is_url_allowed,
    validate_url,
    add_rate_limit_headers,
    validate_path_uuid,
    validate_query_uuid,
    get_api_key_from_request,
    MAX_REQUEST_SIZE,
    DEFAULT_TIMEOUT,
    ENDPOINT_SIZE_LIMITS,
    ENDPOINT_TIMEOUTS,
)


# ─── is_valid_uuid ────────────────────────────────────────────────────────────

class TestIsValidUuid:
    def test_valid_uuid_lowercase(self):
        assert is_valid_uuid("550e8400-e29b-41d4-a716-446655440000") is True

    def test_valid_uuid_uppercase(self):
        assert is_valid_uuid("550E8400-E29B-41D4-A716-446655440000") is True

    def test_invalid_uuid_too_short(self):
        assert is_valid_uuid("550e8400") is False

    def test_invalid_uuid_no_dashes(self):
        assert is_valid_uuid("550e8400e29b41d4a716446655440000") is False

    def test_empty_string(self):
        assert is_valid_uuid("") is False

    def test_none_like_empty(self):
        assert is_valid_uuid(None) is False

    def test_random_string(self):
        assert is_valid_uuid("not-a-uuid-at-all") is False

    def test_uuid4_generated(self):
        assert is_valid_uuid(str(uuid4())) is True


# ─── validate_uuid_strict ─────────────────────────────────────────────────────

class TestValidateUuidStrict:
    def test_valid_uuid_returns_uuid_object(self):
        s = str(uuid4())
        result = validate_uuid_strict(s)
        assert isinstance(result, UUID)

    def test_invalid_raises_400(self):
        with pytest.raises(HTTPException) as exc_info:
            validate_uuid_strict("not-a-uuid")
        assert exc_info.value.status_code == 400

    def test_custom_field_name_in_error(self):
        with pytest.raises(HTTPException) as exc_info:
            validate_uuid_strict("bad", field_name="template_id")
        assert "template_id" in exc_info.value.detail


# ─── get_size_limit_for_path ──────────────────────────────────────────────────

class TestGetSizeLimitForPath:
    def test_default_path_returns_max(self):
        result = get_size_limit_for_path("/api/v1/unknown")
        assert result == MAX_REQUEST_SIZE

    def test_validation_rules_sync_has_lower_limit(self):
        result = get_size_limit_for_path("/api/v1/validation-rules/sync")
        assert result < MAX_REQUEST_SIZE

    def test_email_validation_log_limit(self):
        result = get_size_limit_for_path("/api/v1/email/validation-log")
        assert result < MAX_REQUEST_SIZE

    def test_admin_templates_limit(self):
        result = get_size_limit_for_path("/api/v1/admin/templates")
        assert result == ENDPOINT_SIZE_LIMITS["/api/v1/admin/templates"]


# ─── get_timeout_for_path ─────────────────────────────────────────────────────

class TestGetTimeoutForPath:
    def test_unknown_path_returns_default(self):
        result = get_timeout_for_path("/api/v1/random")
        assert result == DEFAULT_TIMEOUT

    def test_analytics_has_higher_timeout(self):
        result = get_timeout_for_path("/api/v1/admin/analytics")
        assert result > DEFAULT_TIMEOUT

    def test_compliance_report_has_highest_timeout(self):
        result = get_timeout_for_path("/api/v1/admin/compliance/report")
        assert result >= 60

    def test_sync_endpoint_timeout(self):
        result = get_timeout_for_path("/api/v1/validation-rules/sync")
        assert result == ENDPOINT_TIMEOUTS["/api/v1/validation-rules/sync"]


# ─── sanitize_error ───────────────────────────────────────────────────────────

class TestSanitizeError:
    def test_database_error_sanitized(self):
        result = sanitize_error(Exception("database connection failed"))
        assert result["error_code"] == "DATABASE_ERROR"
        assert "database" not in result["detail"].lower() or "try again" in result["detail"].lower()

    def test_connection_error_sanitized(self):
        result = sanitize_error(Exception("connection timeout"))
        assert result["error_code"] == "SERVICE_UNAVAILABLE"

    def test_auth_error_sanitized(self):
        result = sanitize_error(Exception("unauthorized access"))
        assert result["error_code"] == "AUTH_ERROR"

    def test_permission_error_sanitized(self):
        result = sanitize_error(Exception("forbidden by permission"))
        assert result["error_code"] == "PERMISSION_DENIED"

    def test_validation_error_passes_through(self):
        result = sanitize_error(Exception("validation failed"))
        assert result["error_code"] == "VALIDATION_ERROR"

    def test_unknown_error_development_mode(self):
        """In non-production, detail is the actual error string."""
        result = sanitize_error(Exception("some random error"))
        assert result["error_code"] == "INTERNAL_ERROR"

    def test_unknown_error_production_mode(self, monkeypatch):
        """In production, detail is generic."""
        from app.core import security_middleware as sm_module
        monkeypatch.setattr(sm_module.settings, "APP_ENVIRONMENT", "production")
        result = sanitize_error(Exception("sensitive internal error"))
        assert "sensitive" not in result["detail"]
        monkeypatch.setattr(sm_module.settings, "APP_ENVIRONMENT", "development")


# ─── log_audit_entry ─────────────────────────────────────────────────────────

class TestLogAuditEntry:
    def test_success_log_runs_without_error(self):
        entry = AuditLogEntry(
            timestamp="2025-01-01T00:00:00",
            request_id="req-123",
            method="GET",
            path="/api/v1/test",
            status_code=200,
            duration_ms=42,
        )
        asyncio.get_event_loop().run_until_complete(log_audit_entry(entry))

    def test_error_log_runs_without_error(self):
        entry = AuditLogEntry(
            timestamp="2025-01-01T00:00:00",
            request_id="req-456",
            method="POST",
            path="/api/v1/test",
            status_code=500,
            duration_ms=100,
            error="Something went wrong",
        )
        asyncio.get_event_loop().run_until_complete(log_audit_entry(entry))

    def test_entry_with_all_optional_fields(self):
        entry = AuditLogEntry(
            timestamp="2025-01-01T00:00:00",
            request_id="req-789",
            method="PUT",
            path="/api/v1/test",
            tenant_id="tenant-abc",
            user_id="user-xyz",
            api_key_prefix="draft_live_",
            status_code=201,
            duration_ms=55,
            client_ip="127.0.0.1",
            user_agent="pytest/1.0",
        )
        asyncio.get_event_loop().run_until_complete(log_audit_entry(entry))


# ─── is_url_allowed / validate_url ───────────────────────────────────────────

class TestUrlAllowlist:
    def test_allowed_url(self):
        assert is_url_allowed("http://localhost:8000/api/test") is True

    def test_disallowed_url(self):
        assert is_url_allowed("https://evil.com/attack") is False

    def test_validate_url_allowed_passes(self):
        validate_url("http://localhost:8000/something")  # No exception

    def test_validate_url_disallowed_raises(self):
        with pytest.raises(HTTPException) as exc_info:
            validate_url("https://attacker.com/hack")
        assert exc_info.value.status_code == 400


# ─── add_rate_limit_headers ───────────────────────────────────────────────────

class TestAddRateLimitHeaders:
    def test_headers_added_to_response(self):
        resp = Response()
        add_rate_limit_headers(resp, limit=100, remaining=95, reset_time=9999999)
        assert resp.headers["X-RateLimit-Limit"] == "100"
        assert resp.headers["X-RateLimit-Remaining"] == "95"
        assert resp.headers["X-RateLimit-Reset"] == "9999999"


# ─── validate_path_uuid / validate_query_uuid ────────────────────────────────

class TestValidatePathUuid:
    def test_valid_returns_uuid(self):
        s = str(uuid4())
        result = validate_path_uuid(s)
        assert isinstance(result, UUID)

    def test_invalid_raises_400(self):
        with pytest.raises(HTTPException):
            validate_path_uuid("bad-value")


class TestValidateQueryUuid:
    def test_none_returns_none(self):
        assert validate_query_uuid(None) is None

    def test_valid_returns_uuid(self):
        s = str(uuid4())
        result = validate_query_uuid(s)
        assert isinstance(result, UUID)

    def test_invalid_raises_400(self):
        with pytest.raises(HTTPException):
            validate_query_uuid("not-uuid")


# ─── get_api_key_from_request ─────────────────────────────────────────────────

class TestGetApiKeyFromRequest:
    def _make_request(self, headers: dict):
        req = MagicMock()
        req.headers = headers
        return req

    def test_authorization_bearer_extracted(self):
        req = self._make_request({"Authorization": "Bearer draft_live_testkey"})
        result = asyncio.get_event_loop().run_until_complete(
            get_api_key_from_request(req)
        )
        assert result == "draft_live_testkey"

    def test_x_api_key_extracted(self):
        req = self._make_request({"X-API-Key": "draft_live_xapikey"})
        result = asyncio.get_event_loop().run_until_complete(
            get_api_key_from_request(req)
        )
        assert result == "draft_live_xapikey"

    def test_no_headers_returns_none(self):
        req = self._make_request({})
        result = asyncio.get_event_loop().run_until_complete(
            get_api_key_from_request(req)
        )
        assert result is None

    def test_authorization_takes_priority_over_x_api_key(self):
        req = self._make_request({
            "Authorization": "Bearer bearer_key",
            "X-API-Key": "xapi_key",
        })
        result = asyncio.get_event_loop().run_until_complete(
            get_api_key_from_request(req)
        )
        assert result == "bearer_key"


# ─── SecurityMiddleware via TestClient ────────────────────────────────────────

class TestSecurityMiddleware:
    """Test SecurityMiddleware via real FastAPI TestClient."""

    def _get_client(self):
        from app.main import app
        return TestClient(app, raise_server_exceptions=False)

    def test_security_headers_present_on_200(self):
        """Response includes X-Request-ID and security headers."""
        client = self._get_client()
        resp = client.get("/health")
        assert "X-Request-ID" in resp.headers
        assert resp.headers.get("X-Content-Type-Options") == "nosniff"
        assert resp.headers.get("X-Frame-Options") == "DENY"
        assert resp.headers.get("X-XSS-Protection") == "1; mode=block"

    def test_x_api_key_converted_to_authorization(self):
        """X-API-Key header is converted to Authorization: Bearer by middleware."""
        client = self._get_client()
        # A request with X-API-Key should reach auth (and return 401 not 422)
        resp = client.get(
            "/api/v1/admin/analytics",
            headers={"X-API-Key": "draft_live_fakekey123456789012345678901"}
        )
        # Middleware converted X-API-Key → Authorization; auth gets called → 401
        assert resp.status_code in [401, 403]

    def test_oversized_post_returns_413(self):
        """POST with content-length > limit returns 413."""
        client = self._get_client()
        # Override content-length header to simulate large body
        resp = client.post(
            "/api/v1/email/validation-log",
            headers={
                "Content-Length": str(200 * 1024),  # 200KB > 100KB limit
                "Authorization": "Bearer draft_live_fakekey123456789012345678901",
            },
            content=b"x",  # actual body doesn't matter; middleware checks header
        )
        assert resp.status_code == 413

    def test_normal_get_request_passes_middleware(self):
        """GET request to root passes through middleware without error."""
        client = self._get_client()
        resp = client.get("/")
        assert resp.status_code == 200
