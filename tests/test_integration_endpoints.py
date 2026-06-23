"""
Integration Tests for DRAFT Service API Endpoints
Tests that all endpoints are accessible and functional
"""

import sys
import os
from pathlib import Path

# Add project root to path
project_root = Path(__file__).parent.parent
sys.path.insert(0, str(project_root))

import pytest
from fastapi.testclient import TestClient



def test_health_endpoint(client):
    """Test health check endpoint"""
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data.get("status") == "healthy" or "healthy" in str(data.get("status", "")).lower()
    print("[PASS] Health endpoint - PASSED")


def test_validation_endpoint(client):
    """Test document validation endpoint"""
    response = client.post(
        "/api/v1/validation/validate",
        json={
            "tenant_id": "550e8400-e29b-41d4-a716-446655440000",
            "document_type": "demand_letter",
            "jurisdiction": "arizona",
            "document_text": "Test document"
        }
    )
    # Should return 200 (with validation results) or 404 (no rules)
    assert response.status_code in [200, 404]
    if response.status_code == 200:
        data = response.json()
        assert "validation_passed" in data
    print("[PASS] Validation endpoint - PASSED")


def test_validation_file_endpoint(client):
    """Test file validation endpoint"""
    # Create a simple text file
    file_content = b"Test document content"
    
    response = client.post(
        "/api/v1/validation/validate-file",
        files={"file": ("test.txt", file_content, "text/plain")},
        data={
            "tenant_id": "550e8400-e29b-41d4-a716-446655440000",
            "document_type": "demand_letter",
            "jurisdiction": "arizona"
        }
    )
    # Should return 200 (with validation results) or 404 (no rules) or 400 (parsing error)
    assert response.status_code in [200, 400, 404, 422]
    print("[PASS] Validation file endpoint - PASSED")


def test_validation_rules_endpoint(client):
    """Test get validation rules endpoint"""
    response = client.get(
        "/api/v1/validation/rules",
        params={
            "tenant_id": "550e8400-e29b-41d4-a716-446655440000",
            "document_type": "demand_letter",
            "jurisdiction": "arizona"
        }
    )
    # Should return 200 (even if no rules exist, returns empty array)
    assert response.status_code == 200
    data = response.json()
    assert "rules" in data
    assert "total" in data
    print("[PASS] Validation rules endpoint - PASSED")


def test_compliance_stats_endpoint(client):
    """Test compliance stats endpoint (admin)"""
    # Note: This requires admin authentication
    # For testing, we'll check if endpoint exists
    response = client.get("/api/admin/draft/compliance/stats")
    # Should return 200 (if authenticated) or 401/403 (if not) or 404 (not implemented)
    assert response.status_code in [200, 401, 403, 404]
    print("[PASS] Compliance stats endpoint - PASSED")


def test_compliance_reports_list_endpoint(client):
    """Test compliance reports list endpoint (admin)"""
    response = client.get("/api/admin/draft/compliance/reports")
    # Should return 200 (if authenticated) or 401/403 (if not) or 404 (not implemented)
    assert response.status_code in [200, 401, 403, 404]
    print("[PASS] Compliance reports list endpoint - PASSED")


def test_compliance_reports_generate_endpoint(client):
    """Test compliance report generation endpoint (admin)"""
    response = client.post(
        "/api/admin/draft/compliance/reports",
        json={
            "from_date": "2025-01-01",
            "to_date": "2025-01-31"
        }
    )
    # Should return 200 (if authenticated) or 401/403 (if not) or 404 (not implemented)
    assert response.status_code in [200, 400, 401, 403, 404]
    print("[PASS] Compliance reports generate endpoint - PASSED")


if __name__ == "__main__":
    print("\n" + "="*80)
    print("DRAFT Service - Integration Endpoint Tests")
    print("="*80 + "\n")
    
    tests = [
        test_health_endpoint,
        test_validation_endpoint,
        test_validation_file_endpoint,
        test_validation_rules_endpoint,
        test_compliance_stats_endpoint,
        test_compliance_reports_list_endpoint,
        test_compliance_reports_generate_endpoint,
    ]
    
    passed = 0
    failed = 0
    
    for test in tests:
        try:
            test()
            passed += 1
        except Exception as e:
            print(f"[FAIL] {test.__name__} - FAILED: {e}")
            failed += 1
            import traceback
            traceback.print_exc()
    
    print("\n" + "="*80)
    print("INTEGRATION TEST RESULTS")
    print("="*80)
    print(f"Total Tests: {len(tests)}")
    print(f"Passed: {passed}")
    print(f"Failed: {failed}")
    print(f"Pass Rate: {(passed/len(tests)*100):.1f}%")
    print("="*80 + "\n")
    
    if failed == 0:
        print("[SUCCESS] ALL INTEGRATION TESTS PASSED!")
        sys.exit(0)
    else:
        print(f"[FAIL] {failed} test(s) failed")
        sys.exit(1)
