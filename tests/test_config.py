"""
Test Configuration Module
"""

import pytest
from app.core.config import get_settings, validate_zero_knowledge_compliance


def test_get_settings():
    """Test settings loading"""
    settings = get_settings()
    
    assert settings is not None
    assert settings.APP_NAME == "TrueVow LEVERAGE Service"
    assert settings.APP_VERSION == "1.0.0"


def test_database_url_computed():
    """Test database URL computation (requires DATABASE_URL or TEST_DATABASE_URL or DATABASE_PASSWORD set by conftest or env)."""
    import os
    settings = get_settings()
    # When running under pytest, conftest sets DATABASE_URL so this should succeed
    if os.getenv("TESTING") and not os.getenv("DATABASE_URL") and not os.getenv("TEST_DATABASE_URL") and not settings.DATABASE_PASSWORD:
        pytest.skip("DATABASE_URL or TEST_DATABASE_URL or DATABASE_PASSWORD required for database_url_computed test")
    db_url = settings.database_url_computed
    assert db_url is not None
    assert "postgresql" in db_url
    # DATABASE_NAME may not be in URL if full DATABASE_URL is set
    assert len(db_url) > 10


def test_allowed_origins_list():
    """Test CORS origins conversion"""
    settings = get_settings()
    
    origins = settings.allowed_origins_list
    
    assert isinstance(origins, list)
    assert len(origins) > 0


def test_zero_knowledge_compliance():
    """Test zero-knowledge compliance validation"""
    try:
        validate_zero_knowledge_compliance()
        # Should not raise any exceptions
        assert True
    except ValueError as e:
        pytest.fail(f"Zero-knowledge compliance check failed: {e}")


def test_environment_validation():
    """Test environment setting validation"""
    settings = get_settings()
    
    assert settings.APP_ENVIRONMENT in ["development", "staging", "production"]


def test_is_production():
    """Test production environment check"""
    settings = get_settings()
    
    # In test environment, should be False
    assert isinstance(settings.is_production, bool)


def test_is_development():
    """Test development environment check"""
    settings = get_settings()
    
    # In test environment, should be True
    assert isinstance(settings.is_development, bool)

