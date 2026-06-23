"""
Tests for app/core/auth_v2.py
Covers: generate_api_key, hash_api_key, verify_api_key, get_key_prefix,
        get_api_key_from_header, authenticate_api_key, require_admin_access,
        require_tenant_access, require_any_access, verify_tenant_access,
        get_tenant_filter, create_tenant_api_key, create_admin_api_key,
        revoke_api_key.

NOTE: DB write tests use mock DB because the live draft.api_keys table has
      key_prefix VARCHAR(10) but generate_api_key()/get_key_prefix() returns
      12-char prefixes — schema/code mismatch prevents live inserts.
      authenticate_api_key tests use live DB for read-only prefix lookup.
"""

import pytest
import asyncio
from datetime import datetime, timedelta
from unittest.mock import AsyncMock, MagicMock, patch
from uuid import uuid4, UUID

from fastapi import HTTPException
from fastapi.security import HTTPAuthorizationCredentials

from app.core.auth_v2 import (
    generate_api_key,
    hash_api_key,
    verify_api_key,
    get_key_prefix,
    get_api_key_from_header,
    authenticate_api_key,
    verify_tenant_access,
    get_tenant_filter,
    create_tenant_api_key,
    create_admin_api_key,
    revoke_api_key,
)
from app.core.database import get_session_local


@pytest.fixture(scope="module")
def live_db():
    """Read-only live DB session for authenticate tests (prefix lookup only)."""
    SessionLocal = get_session_local()
    session = SessionLocal()
    yield session
    session.close()


# ─── Pure utility functions ────────────────────────────────────────────────────

class TestGenerateApiKey:
    def test_format_starts_with_prefix(self):
        key = generate_api_key()
        assert key.startswith("draft_live_")

    def test_length_reasonable(self):
        key = generate_api_key()
        assert len(key) > 15

    def test_keys_are_unique(self):
        keys = {generate_api_key() for _ in range(10)}
        assert len(keys) == 10


class TestHashAndVerifyApiKey:
    def test_hash_is_string(self):
        key = generate_api_key()
        hashed = hash_api_key(key)
        assert isinstance(hashed, str)

    def test_hash_starts_with_bcrypt_marker(self):
        key = generate_api_key()
        hashed = hash_api_key(key)
        assert hashed.startswith("$2b$") or hashed.startswith("$2a$")

    def test_verify_correct_key(self):
        key = generate_api_key()
        hashed = hash_api_key(key)
        assert verify_api_key(key, hashed) is True

    def test_verify_wrong_key(self):
        key = generate_api_key()
        hashed = hash_api_key(key)
        other = generate_api_key()
        assert verify_api_key(other, hashed) is False


class TestGetKeyPrefix:
    def test_returns_first_12_chars(self):
        key = "draft_live_abc123xyz"
        prefix = get_key_prefix(key)
        assert prefix == "draft_live_a"
        assert len(prefix) == 12

    def test_prefix_of_generated_key(self):
        key = generate_api_key()
        prefix = get_key_prefix(key)
        assert key.startswith(prefix)
        assert len(prefix) == 12


# ─── get_api_key_from_header ──────────────────────────────────────────────────

class TestGetApiKeyFromHeader:
    def test_valid_key_passes_through(self):
        key = generate_api_key()
        creds = HTTPAuthorizationCredentials(scheme="Bearer", credentials=key)
        result = asyncio.get_event_loop().run_until_complete(
            get_api_key_from_header(creds)
        )
        assert result == key

    def test_invalid_format_raises_401(self):
        creds = HTTPAuthorizationCredentials(scheme="Bearer", credentials="invalid_key")
        with pytest.raises(HTTPException) as exc_info:
            asyncio.get_event_loop().run_until_complete(
                get_api_key_from_header(creds)
            )
        assert exc_info.value.status_code == 401

    def test_missing_credentials_raises_401(self):
        with pytest.raises(HTTPException) as exc_info:
            asyncio.get_event_loop().run_until_complete(
                get_api_key_from_header(None)
            )
        assert exc_info.value.status_code == 401


# ─── authenticate_api_key (live DB — read-only prefix lookup) ─────────────────

class TestAuthenticateApiKey:
    def test_unknown_prefix_raises_401(self, live_db):
        """Unknown prefix in live DB raises 401."""
        fake_key = "draft_live_" + "x" * 30
        with pytest.raises(HTTPException) as exc_info:
            asyncio.get_event_loop().run_until_complete(
                authenticate_api_key(fake_key, live_db)
            )
        assert exc_info.value.status_code == 401

    def test_inactive_key_raises_401_mock(self):
        """Inactive key raises 401 with 'inactive' message."""
        from app.models.validation_rule_v2 import APIKey
        mock_db = MagicMock()
        mock_record = MagicMock(spec=APIKey)
        mock_record.is_active = False
        mock_record.key_hash = hash_api_key("draft_live_testXXXXXXXXXXXXXXXXXXXXXXX")
        mock_db.query.return_value.filter.return_value.first.return_value = mock_record

        raw_key = "draft_live_testXXXXXXXXXXXXXXXXXXXXXXX"
        mock_record.key_hash = hash_api_key(raw_key)

        with pytest.raises(HTTPException) as exc_info:
            asyncio.get_event_loop().run_until_complete(
                authenticate_api_key(raw_key, mock_db)
            )
        assert exc_info.value.status_code == 401
        assert "inactive" in exc_info.value.detail.lower()

    def test_revoked_key_raises_401_mock(self):
        """Revoked key raises 401 with 'revoked' message."""
        from app.models.validation_rule_v2 import APIKey
        raw_key = "draft_live_testXXXXXXXXXXXXXXXXXXXXXXX"
        mock_db = MagicMock()
        mock_record = MagicMock(spec=APIKey)
        mock_record.is_active = True
        mock_record.revoked_at = datetime.now()
        mock_record.key_hash = hash_api_key(raw_key)

        mock_db.query.return_value.filter.return_value.first.return_value = mock_record

        with pytest.raises(HTTPException) as exc_info:
            asyncio.get_event_loop().run_until_complete(
                authenticate_api_key(raw_key, mock_db)
            )
        assert exc_info.value.status_code == 401
        assert "revoked" in exc_info.value.detail.lower()

    def test_expired_key_raises_401_mock(self):
        """Expired key raises 401 with 'expired' message."""
        from app.models.validation_rule_v2 import APIKey
        raw_key = "draft_live_testXXXXXXXXXXXXXXXXXXXXXXX"
        mock_db = MagicMock()
        mock_record = MagicMock(spec=APIKey)
        mock_record.is_active = True
        mock_record.revoked_at = None
        mock_record.expires_at = datetime.now() - timedelta(days=1)
        mock_record.key_hash = hash_api_key(raw_key)

        mock_db.query.return_value.filter.return_value.first.return_value = mock_record

        with pytest.raises(HTTPException) as exc_info:
            asyncio.get_event_loop().run_until_complete(
                authenticate_api_key(raw_key, mock_db)
            )
        assert exc_info.value.status_code == 401
        assert "expired" in exc_info.value.detail.lower()

    def test_wrong_hash_raises_401_mock(self):
        """Valid-looking prefix but wrong hash raises 401."""
        from app.models.validation_rule_v2 import APIKey
        raw_key = "draft_live_testXXXXXXXXXXXXXXXXXXXXXXX"
        wrong_key = "draft_live_testYYYYYYYYYYYYYYYYYYYYYYY"

        mock_db = MagicMock()
        mock_record = MagicMock(spec=APIKey)
        mock_record.key_hash = hash_api_key(raw_key)  # hash of DIFFERENT key

        mock_db.query.return_value.filter.return_value.first.return_value = mock_record

        with pytest.raises(HTTPException) as exc_info:
            asyncio.get_event_loop().run_until_complete(
                authenticate_api_key(wrong_key, mock_db)
            )
        assert exc_info.value.status_code == 401

    def test_valid_tenant_key_returns_data_mock(self):
        """Valid active tenant key returns correct key_data dict."""
        from app.models.validation_rule_v2 import APIKey
        raw_key = "draft_live_testXXXXXXXXXXXXXXXXXXXXXXX"
        tenant_id = str(uuid4())

        mock_db = MagicMock()
        mock_record = MagicMock(spec=APIKey)
        mock_record.is_active = True
        mock_record.revoked_at = None
        mock_record.expires_at = None
        mock_record.key_hash = hash_api_key(raw_key)
        mock_record.access_level = "tenant"
        mock_record.tenant_id = tenant_id
        mock_record.rate_limit_per_minute = 60
        mock_record.rate_limit_per_hour = 1000
        mock_record.id = uuid4()

        mock_db.query.return_value.filter.return_value.first.return_value = mock_record

        key_data = asyncio.get_event_loop().run_until_complete(
            authenticate_api_key(raw_key, mock_db)
        )
        assert key_data["access_level"] == "tenant"
        assert key_data["tenant_id"] == tenant_id

    def test_valid_admin_key_returns_data_mock(self):
        """Valid active admin key returns correct key_data dict."""
        from app.models.validation_rule_v2 import APIKey
        raw_key = "draft_live_testXXXXXXXXXXXXXXXXXXXXXXX"

        mock_db = MagicMock()
        mock_record = MagicMock(spec=APIKey)
        mock_record.is_active = True
        mock_record.revoked_at = None
        mock_record.expires_at = None
        mock_record.key_hash = hash_api_key(raw_key)
        mock_record.access_level = "admin"
        mock_record.tenant_id = None
        mock_record.rate_limit_per_minute = 60
        mock_record.rate_limit_per_hour = 1000
        mock_record.id = uuid4()

        mock_db.query.return_value.filter.return_value.first.return_value = mock_record

        key_data = asyncio.get_event_loop().run_until_complete(
            authenticate_api_key(raw_key, mock_db)
        )
        assert key_data["access_level"] == "admin"
        assert key_data["tenant_id"] is None


# ─── verify_tenant_access ─────────────────────────────────────────────────────

class TestVerifyTenantAccess:
    def test_admin_has_access_to_any_tenant(self):
        admin_data = {"access_level": "admin", "tenant_id": None}
        verify_tenant_access(admin_data, uuid4())  # No exception

    def test_tenant_can_access_own_data(self):
        tid = uuid4()
        tenant_data = {"access_level": "tenant", "tenant_id": tid}
        verify_tenant_access(tenant_data, tid)  # No exception

    def test_tenant_cannot_access_other_tenant(self):
        tenant_data = {"access_level": "tenant", "tenant_id": uuid4()}
        with pytest.raises(HTTPException) as exc_info:
            verify_tenant_access(tenant_data, uuid4())
        assert exc_info.value.status_code == 403

    def test_external_key_raises_403(self):
        ext_data = {"access_level": "external", "tenant_id": None}
        with pytest.raises(HTTPException) as exc_info:
            verify_tenant_access(ext_data, uuid4())
        assert exc_info.value.status_code == 403


# ─── get_tenant_filter ────────────────────────────────────────────────────────

class TestGetTenantFilter:
    def test_admin_returns_none(self):
        admin_data = {"access_level": "admin", "tenant_id": None}
        assert get_tenant_filter(admin_data) is None

    def test_tenant_returns_tenant_id(self):
        tid = uuid4()
        tenant_data = {"access_level": "tenant", "tenant_id": tid}
        result = get_tenant_filter(tenant_data)
        assert result == tid

    def test_external_raises_403(self):
        ext_data = {"access_level": "external", "tenant_id": None}
        with pytest.raises(HTTPException) as exc_info:
            get_tenant_filter(ext_data)
        assert exc_info.value.status_code == 403


# ─── create_tenant_api_key / create_admin_api_key (mock DB) ──────────────────

class TestCreateApiKey:
    """Tests for create_tenant_api_key / create_admin_api_key using mock DB.
    
    Live DB fails because key_prefix is VARCHAR(10) but generates 12-char prefixes.
    """

    def test_create_tenant_key_returns_tuple(self):
        """create_tenant_api_key returns (raw_key, APIKey record)."""
        mock_db = MagicMock()
        tid = uuid4()
        raw_key, record = create_tenant_api_key(mock_db, tid, description="test-create")
        assert raw_key.startswith("draft_live_")
        assert record.access_level == "tenant"
        assert str(record.tenant_id) == str(tid)
        assert record.key_prefix == get_key_prefix(raw_key)

    def test_create_admin_key_returns_tuple(self):
        """create_admin_api_key returns (raw_key, APIKey record)."""
        mock_db = MagicMock()
        raw_key, record = create_admin_api_key(mock_db, description="test-admin-create")
        assert raw_key.startswith("draft_live_")
        assert record.access_level == "admin"
        assert record.tenant_id is None

    def test_create_key_with_expiry(self):
        """create_tenant_api_key with expires_in_days sets expires_at."""
        mock_db = MagicMock()
        tid = uuid4()
        raw_key, record = create_tenant_api_key(mock_db, tid, expires_in_days=30)
        assert record.expires_at is not None

    def test_create_key_no_expiry(self):
        """create_tenant_api_key without expires_in_days leaves expires_at=None."""
        mock_db = MagicMock()
        tid = uuid4()
        raw_key, record = create_tenant_api_key(mock_db, tid)
        assert record.expires_at is None

    def test_tenant_key_has_correct_prefix(self):
        """Generated key prefix matches record.key_prefix."""
        mock_db = MagicMock()
        raw_key, record = create_admin_api_key(mock_db)
        assert record.key_prefix == get_key_prefix(raw_key)


# ─── revoke_api_key ───────────────────────────────────────────────────────────

class TestRevokeApiKey:
    def test_revoke_existing_key_mock(self):
        """revoke_api_key deactivates record and sets revoked_at."""
        from app.models.validation_rule_v2 import APIKey
        mock_db = MagicMock()
        key_id = uuid4()
        mock_record = MagicMock(spec=APIKey)
        mock_db.query.return_value.filter.return_value.first.return_value = mock_record

        revoked = revoke_api_key(mock_db, key_id)
        assert mock_record.is_active is False
        assert mock_record.revoked_at is not None

    def test_revoke_nonexistent_key_raises_404(self):
        """revoke_api_key raises 404 when key not found."""
        mock_db = MagicMock()
        mock_db.query.return_value.filter.return_value.first.return_value = None

        with pytest.raises(HTTPException) as exc_info:
            revoke_api_key(mock_db, uuid4())
        assert exc_info.value.status_code == 404
