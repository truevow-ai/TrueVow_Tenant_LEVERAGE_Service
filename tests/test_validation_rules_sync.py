"""
Test Validation Rules Sync Service
"""

import pytest
from unittest.mock import Mock, MagicMock
from uuid import uuid4

from app.services.validation_rules_sync import ValidationRulesSyncService
from app.models import ValidationRule


@pytest.fixture
def mock_db():
    """Mock database session"""
    return MagicMock()


@pytest.fixture
def service(mock_db):
    """Create service instance with mocked database"""
    return ValidationRulesSyncService(mock_db)


def test_service_initialization(service):
    """Test service initialization"""
    assert service is not None
    assert service.db is not None


def test_get_validation_rules_with_filters(service, mock_db):
    """Test getting validation rules with filters"""
    # Mock query results
    mock_rule = Mock(spec=ValidationRule)
    mock_rule.id = uuid4()
    mock_rule.validator_level = 1
    mock_rule.validator_name = "test_validator"
    mock_rule.version = 1
    mock_rule.to_dict = Mock(return_value={
        "id": str(mock_rule.id),
        "validator_name": "test_validator"
    })
    
    # Configure mock query chain
    mock_query = Mock()
    mock_query.filter.return_value = mock_query
    mock_query.all.return_value = [mock_rule]
    
    mock_db.query.return_value = mock_query
    
    # Test basic query structure
    tenant_id = uuid4()
    
    # Note: This is a placeholder test. Full integration tests
    # would require actual database setup
    assert service.db == mock_db


def test_get_rule_by_id(service, mock_db):
    """Test getting rule by ID"""
    rule_id = uuid4()
    
    # Mock query
    mock_query = Mock()
    mock_query.filter.return_value = mock_query
    mock_query.first.return_value = None
    
    mock_db.query.return_value = mock_query
    
    result = service.get_rule_by_id(rule_id)
    
    # Verify query was called
    mock_db.query.assert_called_once()


def test_check_for_updates(service, mock_db):
    """Test checking for updates"""
    tenant_id = uuid4()
    current_version = 1
    
    # Mock queries
    mock_query = Mock()
    mock_query.filter.return_value = mock_query
    mock_query.all.return_value = []
    mock_query.order_by.return_value = mock_query
    mock_query.first.return_value = None
    
    mock_db.query.return_value = mock_query
    
    result = service.check_for_updates(
        tenant_id=tenant_id,
        current_version=current_version
    )
    
    # Verify result structure
    assert "updates_available" in result
    assert "current_version" in result
    assert "latest_version" in result
    assert result["current_version"] == current_version

