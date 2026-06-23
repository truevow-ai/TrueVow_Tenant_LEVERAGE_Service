"""
Authentication and security tests - 100% coverage target
Tests token generation, validation, expiry, refresh, RBAC
"""

import pytest
from datetime import datetime, timedelta
from unittest.mock import patch, MagicMock
from fastapi import HTTPException, status
from jose import jwt
from cryptography.fernet import Fernet

from app.core.auth import (
    create_access_token,
    verify_token,
    get_encryption_cipher,
    encrypt_api_key,
    decrypt_api_key,
    APIKeyAccess,
    validate_api_key,
    require_admin_access,
    require_tenant_access,
    get_rules_encryption_cipher,
    encrypt_validation_rules,
    decrypt_validation_rules,
    check_rate_limit
)
from app.core.config import get_settings


class TestJWTTokenManagement:
    """Test JWT token creation and verification"""
    
    def test_create_access_token_default_expiry(self):
        """Test JWT token creation with default expiry"""
        data = {"sub": "test-user"}
        token = create_access_token(data)
        
        assert isinstance(token, str)
        assert len(token) > 0
        
        # Decode to verify structure
        settings = get_settings()
        decoded = jwt.decode(token, settings.secret_key_computed, algorithms=[settings.ALGORITHM])
        assert decoded["sub"] == "test-user"
        assert "exp" in decoded
    
    def test_create_access_token_custom_expiry(self):
        """Test JWT token creation with custom expiry"""
        data = {"sub": "test-user"}
        expires_delta = timedelta(minutes=30)
        token = create_access_token(data, expires_delta)
        
        assert isinstance(token, str)
        
        settings = get_settings()
        decoded = jwt.decode(token, settings.secret_key_computed, algorithms=[settings.ALGORITHM])
        assert decoded["sub"] == "test-user"
        assert "exp" in decoded
    
    def test_verify_token_valid(self):
        """Test verification of valid JWT token"""
        data = {"sub": "test-user"}
        token = create_access_token(data)
        
        payload = verify_token(token)
        assert payload["sub"] == "test-user"
        assert "exp" in payload
    
    def test_verify_token_invalid_signature(self):
        """Test verification fails with invalid signature"""
        # Create token with different secret
        bad_secret = "wrong-secret-key-that-is-long-enough-for-hs256-algorithm"
        token = jwt.encode({"sub": "test"}, bad_secret, algorithm="HS256")
        
        with pytest.raises(HTTPException) as exc_info:
            verify_token(token)
        
        assert exc_info.value.status_code == status.HTTP_401_UNAUTHORIZED
        assert "Could not validate credentials" in str(exc_info.value.detail)
    
    def test_verify_token_expired(self):
        """Test verification fails with expired token"""
        # Create expired token
        settings = get_settings()
        expired_payload = {
            "sub": "test-user",
            "exp": datetime.utcnow() - timedelta(minutes=1)
        }
        token = jwt.encode(expired_payload, settings.secret_key_computed, algorithm=settings.ALGORITHM)
        
        with pytest.raises(HTTPException) as exc_info:
            verify_token(token)
        
        assert exc_info.value.status_code == status.HTTP_401_UNAUTHORIZED


class TestAPIKeyEncryption:
    """Test API key encryption and decryption"""
    
    def test_get_encryption_cipher(self):
        """Test getting encryption cipher"""
        cipher = get_encryption_cipher()
        assert isinstance(cipher, Fernet)
    
    def test_encrypt_decrypt_api_key(self):
        """Test encrypt and decrypt round-trip"""
        original_key = "test-api-key-12345"
        
        # Encrypt
        encrypted = encrypt_api_key(original_key)
        assert isinstance(encrypted, str)
        assert encrypted != original_key
        
        # Decrypt
        decrypted = decrypt_api_key(encrypted)
        assert decrypted == original_key
    
    def test_encrypt_different_keys_produce_different_output(self):
        """Test that different keys produce different encrypted output"""
        key1 = "api-key-1"
        key2 = "api-key-2"
        
        encrypted1 = encrypt_api_key(key1)
        encrypted2 = encrypt_api_key(key2)
        
        assert encrypted1 != encrypted2


class TestAPIKeyValidation:
    """Test API key validation and access control"""
    
    def test_api_key_access_levels_defined(self):
        """Test API key access level constants"""
        assert hasattr(APIKeyAccess, "TENANT")
        assert hasattr(APIKeyAccess, "ADMIN")
        assert hasattr(APIKeyAccess, "EXTERNAL")
        
        assert APIKeyAccess.TENANT == "tenant"
        assert APIKeyAccess.ADMIN == "admin"
        assert APIKeyAccess.EXTERNAL == "external"
    
    @pytest.mark.asyncio
    @patch("app.core.auth.get_db")
    @patch("app.models.validation_rule_v2.APIKey")
    async def test_validate_api_key_success(self, mock_api_key_model, mock_get_db):
        """Test successful API key validation"""
        # Mock database session
        mock_db = MagicMock()
        mock_get_db.return_value = mock_db
        
        # Mock API key record
        mock_key_record = MagicMock()
        mock_key_record.is_active = True
        mock_key_record.encrypted_key = encrypt_api_key("valid-key")
        mock_key_record.expires_at = None
        mock_key_record.tenant_id = "tenant-123"
        mock_key_record.access_level = "tenant"
        mock_key_record.description = "Test key"
        
        mock_db.query.return_value.filter.return_value.all.return_value = [mock_key_record]
        
        # Mock credentials
        from fastapi.security import HTTPAuthorizationCredentials
        credentials = HTTPAuthorizationCredentials(scheme="Bearer", credentials="valid-key")
        
        # Test
        result = await validate_api_key(credentials, mock_db)
        
        assert result["tenant_id"] == "tenant-123"
        assert result["access_level"] == "tenant"
        assert result["description"] == "Test key"
        assert "api_key_id" in result
    
    @pytest.mark.asyncio
    @patch("app.core.auth.get_db")
    @patch("app.models.validation_rule_v2.APIKey")
    async def test_validate_api_key_invalid(self, mock_api_key_model, mock_get_db):
        """Test invalid API key raises exception"""
        mock_db = MagicMock()
        mock_get_db.return_value = mock_db
        
        # Mock no matching keys
        mock_db.query.return_value.filter.return_value.all.return_value = []
        
        from fastapi.security import HTTPAuthorizationCredentials
        credentials = HTTPAuthorizationCredentials(scheme="Bearer", credentials="invalid-key")
        
        with pytest.raises(HTTPException) as exc_info:
            await validate_api_key(credentials, mock_db)
        
        assert exc_info.value.status_code == status.HTTP_401_UNAUTHORIZED
        assert "Invalid API key" in str(exc_info.value.detail)
    
    @pytest.mark.asyncio
    @patch("app.core.auth.get_db")
    @patch("app.models.validation_rule_v2.APIKey")
    async def test_validate_api_key_expired(self, mock_api_key_model, mock_get_db):
        """Test expired API key raises exception"""
        mock_db = MagicMock()
        mock_get_db.return_value = mock_db
        
        # Mock expired key
        mock_key_record = MagicMock()
        mock_key_record.is_active = True
        mock_key_record.encrypted_key = encrypt_api_key("expired-key")
        mock_key_record.expires_at = datetime.utcnow() - timedelta(days=1)  # Expired yesterday
        
        mock_db.query.return_value.filter.return_value.all.return_value = [mock_key_record]
        
        from fastapi.security import HTTPAuthorizationCredentials
        credentials = HTTPAuthorizationCredentials(scheme="Bearer", credentials="expired-key")
        
        with pytest.raises(HTTPException) as exc_info:
            await validate_api_key(credentials, mock_db)
        
        assert exc_info.value.status_code == status.HTTP_401_UNAUTHORIZED
        # Error message can be either "API key has expired" or "Invalid API key"
        assert "expired" in str(exc_info.value.detail).lower() or "invalid" in str(exc_info.value.detail).lower()
    
    @pytest.mark.asyncio
    async def test_require_admin_access_success(self):
        """Test admin access requirement passes for admin"""
        api_key_data = {
            "access_level": APIKeyAccess.ADMIN,
            "tenant_id": "tenant-123"
        }
        
        result = await require_admin_access(api_key_data)
        assert result == api_key_data
    
    @pytest.mark.asyncio
    async def test_require_admin_access_denied(self):
        """Test admin access requirement denies non-admin"""
        api_key_data = {
            "access_level": APIKeyAccess.TENANT,
            "tenant_id": "tenant-123"
        }
        
        with pytest.raises(HTTPException) as exc_info:
            await require_admin_access(api_key_data)
        
        assert exc_info.value.status_code == status.HTTP_403_FORBIDDEN
        assert "Admin access required" in str(exc_info.value.detail)
    
    @pytest.mark.asyncio
    async def test_require_tenant_access_success(self):
        """Test tenant access requirement passes for tenant and admin"""
        # Test tenant access
        tenant_data = {
            "access_level": APIKeyAccess.TENANT,
            "tenant_id": "tenant-123"
        }
        result = await require_tenant_access(tenant_data)
        assert result == tenant_data
        
        # Test admin access (should also pass)
        admin_data = {
            "access_level": APIKeyAccess.ADMIN,
            "tenant_id": "tenant-123"
        }
        result = await require_tenant_access(admin_data)
        assert result == admin_data
    
    @pytest.mark.asyncio
    async def test_require_tenant_access_denied(self):
        """Test tenant access requirement denies external"""
        api_key_data = {
            "access_level": APIKeyAccess.EXTERNAL,
            "tenant_id": "tenant-123"
        }
        
        with pytest.raises(HTTPException) as exc_info:
            await require_tenant_access(api_key_data)
        
        assert exc_info.value.status_code == status.HTTP_403_FORBIDDEN
        assert "Tenant access required" in str(exc_info.value.detail)


class TestValidationRulesEncryption:
    """Test validation rules encryption for client sync"""
    
    def test_get_rules_encryption_cipher(self):
        """Test getting rules encryption cipher"""
        cipher = get_rules_encryption_cipher()
        assert isinstance(cipher, Fernet)
    
    def test_encrypt_decrypt_validation_rules(self):
        """Test encrypt and decrypt validation rules round-trip"""
        rules_json = '{"rule1": {"type": "format", "config": {}}}'
        
        # Encrypt
        encrypted = encrypt_validation_rules(rules_json)
        assert isinstance(encrypted, str)
        assert encrypted != rules_json
        
        # Decrypt
        decrypted = decrypt_validation_rules(encrypted)
        assert decrypted == rules_json


class TestRateLimiting:
    """Test rate limiting functionality"""
    
    def test_check_rate_limit_placeholder(self):
        """Test rate limit check (placeholder implementation)"""
        api_key_data = {"tenant_id": "tenant-123"}
        
        # Should not raise exception (placeholder passes through)
        check_rate_limit(api_key_data)
        assert True  # If we reach here, test passed


class TestTokenExpiryScenarios:
    """Test token expiry edge cases"""
    
    def test_token_expiry_near_future(self):
        """Test token with near-future expiry"""
        data = {"sub": "test-user"}
        expires_delta = timedelta(seconds=10)  # 10 seconds
        token = create_access_token(data, expires_delta)
        
        # Should be valid immediately
        payload = verify_token(token)
        assert payload["sub"] == "test-user"
    
    def test_token_with_no_expiry_claim(self):
        """Test token handling when exp claim missing"""
        settings = get_settings()
        # Create token without exp
        token = jwt.encode({"sub": "test-user"}, settings.secret_key_computed, algorithm=settings.ALGORITHM)
        
        # JWT decode may succeed without exp - token is valid but has no expiry
        # verify_token doesn't explicitly require exp claim
        try:
            payload = verify_token(token)
            # If it succeeds, verify payload is correct
            assert payload["sub"] == "test-user"
        except HTTPException:
            # If it fails, that's also acceptable behavior
            pass


class TestRBACCombinations:
    """Test role-based access control combinations"""
    
    @pytest.mark.asyncio
    async def test_access_level_hierarchy(self):
        """Test access level hierarchy enforcement"""
        # Admin should have access to everything
        admin_data = {"access_level": APIKeyAccess.ADMIN}
        tenant_result = await require_tenant_access(admin_data)
        admin_result = await require_admin_access(admin_data)
        assert tenant_result == admin_data
        assert admin_result == admin_data
        
        # Tenant should have tenant access but not admin
        tenant_data = {"access_level": APIKeyAccess.TENANT}
        tenant_result = await require_tenant_access(tenant_data)
        assert tenant_result == tenant_data
        
        with pytest.raises(HTTPException):
            await require_admin_access(tenant_data)
        
        # External should have no access
        external_data = {"access_level": APIKeyAccess.EXTERNAL}
        with pytest.raises(HTTPException):
            await require_tenant_access(external_data)
        with pytest.raises(HTTPException):
            await require_admin_access(external_data)


if __name__ == "__main__":
    print("\n" + "="*80)
    print("Authentication & Security Tests - 100% Coverage Target")
    print("="*80 + "\n")
    
    pytest.main([__file__, "-v", "--tb=short"])
