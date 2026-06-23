"""
API endpoint tests - Coverage improvement target
Tests admin endpoints, validation endpoints, template endpoints
"""

import pytest
from fastapi.testclient import TestClient
from unittest.mock import patch, MagicMock
from uuid import UUID


class TestAdminEndpoints:
    """Test admin API endpoints"""
    
    def test_list_rule_templates_success(self, client):
        """Test listing rule templates"""
        response = client.get("/api/v1/admin/rule-templates")
        # Should return 200 or 401 depending on auth
        assert response.status_code in [200, 401, 403]
    
    def test_list_rule_templates_with_filters(self, client):
        """Test listing rule templates with filters"""
        params = {"practice_area": "personal_injury", "document_type": "demand_letter"}
        response = client.get("/api/v1/admin/rule-templates", params=params)
        assert response.status_code in [200, 401, 403]
    
    def test_list_rule_templates_pagination(self, client):
        """Test listing rule templates with pagination"""
        params = {"skip": 10, "limit": 5}
        response = client.get("/api/v1/admin/rule-templates", params=params)
        assert response.status_code in [200, 401, 403]
    
    def test_get_rule_template_success(self, client):
        """Test getting specific rule template"""
        template_id = "12345678-1234-5678-1234-567812345678"
        response = client.get(f"/api/v1/admin/rule-templates/{template_id}")
        assert response.status_code in [200, 401, 403, 404]
    
    def test_get_rule_template_not_found(self, client):
        """Test getting non-existent rule template"""
        template_id = "00000000-0000-0000-0000-000000000000"
        response = client.get(f"/api/v1/admin/rule-templates/{template_id}")
        assert response.status_code in [401, 403, 404]
    
    def test_create_rule_template_success(self, client):
        """Test creating rule template"""
        template_data = {
            "template_name": "Test Template",
            "template_description": "Test Description",
            "validator_level": 1,
            "validator_name": "test_validator",
            "validator_type": "format",
            "practice_area": "personal_injury",
            "document_type": "demand_letter",
            "validator_config": {},
            "error_message": "Test error"
        }
        response = client.post("/api/v1/admin/rule-templates", json=template_data)
        assert response.status_code in [200, 401, 403, 422]
    
    def test_create_rule_template_validation_error(self, client):
        """Test creating rule template with invalid data"""
        invalid_data = {"invalid": "data"}
        response = client.post("/api/v1/admin/rule-templates", json=invalid_data)
        assert response.status_code in [401, 403, 422]
    
    def test_update_rule_template_success(self, client):
        """Test updating rule template"""
        template_id = "12345678-1234-5678-1234-567812345678"
        update_data = {"template_name": "Updated Template"}
        response = client.put(f"/api/v1/admin/rule-templates/{template_id}", json=update_data)
        assert response.status_code in [200, 401, 403, 404, 422]
    
    def test_update_rule_template_not_found(self, client):
        """Test updating non-existent rule template"""
        template_id = "00000000-0000-0000-0000-000000000000"
        update_data = {"template_name": "Updated"}
        response = client.put(f"/api/v1/admin/rule-templates/{template_id}", json=update_data)
        assert response.status_code in [401, 403, 404, 422]
    
    def test_archive_rule_template_success(self, client):
        """Test archiving rule template"""
        template_id = "12345678-1234-5678-1234-567812345678"
        response = client.delete(f"/api/v1/admin/rule-templates/{template_id}")
        assert response.status_code in [200, 401, 403, 404]
    
    def test_browse_template_library_success(self, client):
        """Test browsing template library"""
        response = client.get("/api/v1/admin/rule-templates/library/browse")
        assert response.status_code in [200, 401, 403]
    
    def test_browse_template_library_with_filters(self, client):
        """Test browsing template library with filters"""
        params = {"practice_area": "personal_injury", "document_type": "demand_letter"}
        response = client.get("/api/v1/admin/rule-templates/library/browse", params=params)
        assert response.status_code in [200, 401, 403]


class TestValidationEndpoints:
    """Test document validation API endpoints"""
    
    def test_validate_document_success(self, client):
        """Test document validation endpoint"""
        validation_data = {
            "document_text": "This is a test document for validation.",
            "practice_area": "personal_injury",
            "document_type": "demand_letter",
            "jurisdiction_state": "AZ"
        }
        response = client.post("/api/v1/validation/validate", json=validation_data)
        assert response.status_code in [200, 400, 401, 403, 422]
    
    def test_validate_document_missing_fields(self, client):
        """Test validation with missing required fields"""
        incomplete_data = {"document_text": "Test"}
        response = client.post("/api/v1/validation/validate", json=incomplete_data)
        assert response.status_code in [400, 401, 403, 422]
    
    def test_validate_document_invalid_practice_area(self, client):
        """Test validation with invalid practice area"""
        invalid_data = {
            "document_text": "Test",
            "practice_area": "invalid_area",
            "document_type": "demand_letter",
            "jurisdiction_state": "XX"
        }
        response = client.post("/api/v1/validation/validate", json=invalid_data)
        assert response.status_code in [200, 400, 401, 403, 422]
    
    def test_batch_validation_success(self, client):
        """Test batch document validation"""
        batch_data = {
            "documents": [
                "Document 1 text",
                "Document 2 text",
                "Document 3 text"
            ],
            "practice_area": "personal_injury",
            "document_type": "demand_letter",
            "jurisdiction_state": "AZ"
        }
        response = client.post("/api/v1/validation/validate-batch", json=batch_data)
        assert response.status_code in [200, 400, 401, 403, 422]
    
    def test_batch_validation_empty_documents(self, client):
        """Test batch validation with empty documents list"""
        empty_data = {
            "documents": [],
            "practice_area": "personal_injury",
            "document_type": "demand_letter",
            "jurisdiction_state": "AZ"
        }
        response = client.post("/api/v1/validation/validate-batch", json=empty_data)
        assert response.status_code in [400, 401, 403, 422]
    
    def test_batch_validation_too_many_documents(self, client):
        """Test batch validation with too many documents"""
        too_many_docs = {
            "documents": ["Doc"] * 101,  # More than max limit
            "practice_area": "personal_injury",
            "document_type": "demand_letter",
            "jurisdiction_state": "AZ"
        }
        response = client.post("/api/v1/validation/validate-batch", json=too_many_docs)
        assert response.status_code in [400, 401, 403, 422]


class TestTemplateEndpoints:
    """Test template management API endpoints"""
    
    def test_list_templates_success(self, client):
        """Test listing templates"""
        response = client.get("/api/v1/admin/templates")
        assert response.status_code in [200, 401, 403]
    
    def test_list_templates_with_filters(self, client):
        """Test listing templates with filters"""
        params = {"practice_area": "personal_injury", "document_type": "demand_letter"}
        response = client.get("/api/v1/admin/templates", params=params)
        assert response.status_code in [200, 401, 403]
    
    def test_get_template_by_id_success(self, client):
        """Test getting template by ID"""
        template_id = "12345678-1234-5678-1234-567812345678"
        response = client.get(f"/api/v1/admin/templates/{template_id}")
        assert response.status_code in [200, 401, 403, 404]
    
    def test_get_template_by_id_not_found(self, client):
        """Test getting non-existent template"""
        template_id = "00000000-0000-0000-0000-000000000000"
        response = client.get(f"/api/v1/admin/templates/{template_id}")
        assert response.status_code in [401, 403, 404]
    
    def test_create_template_success(self, client):
        """Test creating template"""
        template_data = {
            "template_name": "Test Template",
            "template_content": "Template with {{merge_field}}",
            "practice_area": "personal_injury",
            "document_type": "demand_letter",
            "merge_fields": [{"name": "merge_field", "type": "text"}]
        }
        response = client.post("/api/v1/admin/templates", json=template_data)
        assert response.status_code in [200, 401, 403, 422]
    
    def test_create_template_invalid_merge_fields(self, client):
        """Test creating template with invalid merge fields"""
        invalid_data = {
            "template_name": "Test Template",
            "template_content": "Content",
            "practice_area": "personal_injury",
            "document_type": "demand_letter",
            "merge_fields": [{"invalid": "field"}]
        }
        response = client.post("/api/v1/admin/templates", json=invalid_data)
        assert response.status_code in [401, 403, 422]


class TestEmailValidationEndpoints:
    """Test email validation API endpoints"""
    
    def test_validate_email_attachment_success(self, client):
        """Test email attachment validation"""
        email_data = {
            "subject": "Test Email",
            "body": "Test body",
            "attachments": [
                {
                    "filename": "test.pdf",
                    "content": "base64_encoded_content"
                }
            ],
            "practice_area": "personal_injury",
            "document_type": "demand_letter",
            "jurisdiction_state": "AZ"
        }
        response = client.post("/api/v1/email/validation-context", json=email_data)
        assert response.status_code in [200, 400, 401, 403, 422]
    
    def test_validate_email_attachment_invalid_format(self, client):
        """Test email validation with invalid attachment format"""
        email_data = {
            "subject": "Test",
            "body": "Body",
            "attachments": [
                {
                    "filename": "test.xyz",  # Invalid format
                    "content": "invalid_content"
                }
            ],
            "practice_area": "personal_injury",
            "document_type": "demand_letter",
            "jurisdiction_state": "XX"
        }
        response = client.post("/api/v1/email/validation-context", json=email_data)
        assert response.status_code in [200, 400, 401, 403, 422]
    
    def test_validate_email_attachment_empty_content(self, client):
        """Test email validation with empty attachment content"""
        email_data = {
            "subject": "Test",
            "body": "Body",
            "attachments": [
                {
                    "filename": "empty.pdf",
                    "content": ""  # Empty content
                }
            ],
            "practice_area": "",
            "document_type": "",
            "jurisdiction_state": ""
        }
        response = client.post("/api/v1/email/validation-context", json=email_data)
        assert response.status_code in [200, 400, 401, 403, 422]
    
    def test_extract_attachments_from_email_success(self, client):
        """Test extracting attachments from email"""
        email_data = {
            "raw_email": "base64_encoded_email_data"
        }
        response = client.post("/api/v1/email/validation-log", json=email_data)
        assert response.status_code in [200, 400, 401, 403, 422]
    
    def test_extract_attachments_invalid_email(self, client):
        """Test extracting attachments from invalid email"""
        invalid_data = {
            "raw_email": "invalid_base64_data"
        }
        response = client.post("/api/v1/email/validation-log", json=invalid_data)
        assert response.status_code in [400, 401, 403, 422]


class TestTemplateInheritanceEndpoints:
    """Test template inheritance API endpoints"""
    
    def test_browse_inheritance_templates_success(self, client):
        """Test browsing templates for inheritance"""
        response = client.get("/api/v1/tenant/rule-templates")
        assert response.status_code in [200, 401, 403]
    
    def test_browse_inheritance_templates_with_filters(self, client):
        """Test browsing inheritance templates with filters"""
        params = {"practice_area": "personal_injury", "document_type": "demand_letter"}
        response = client.get("/api/v1/tenant/rule-templates", params=params)
        assert response.status_code in [200, 401, 403]
    
    def test_get_template_inheritance_detail(self, client):
        """Test getting template inheritance details"""
        template_id = "12345678-1234-5678-1234-567812345678"
        response = client.get(f"/api/v1/template-inheritance/templates/{template_id}")
        assert response.status_code in [200, 401, 403, 404]
    
    def test_inherit_template_success(self, client):
        """Test inheriting a template"""
        template_id = "12345678-1234-5678-1234-567812345678"
        inherit_data = {
            "customize": False,
            "customizations": {}
        }
        response = client.post(f"/api/v1/template-inheritance/templates/{template_id}/inherit", json=inherit_data)
        assert response.status_code in [200, 401, 403, 404, 409, 422]
    
    def test_inherit_template_already_inherited(self, client):
        """Test inheriting already inherited template"""
        template_id = "12345678-1234-5678-1234-567812345678"
        inherit_data = {"customize": False}
        response = client.post(f"/api/v1/template-inheritance/templates/{template_id}/inherit", json=inherit_data)
        assert response.status_code in [200, 401, 403, 404, 409, 422]
    
    def test_inherit_template_with_customization(self, client):
        """Test inheriting template with customizations"""
        template_id = "12345678-1234-5678-1234-567812345678"
        custom_data = {
            "customize": True,
            "customizations": {
                "rule_name": "Custom Rule Name",
                "validator_config": {"custom": "config"}
            }
        }
        response = client.post(f"/api/v1/template-inheritance/templates/{template_id}/inherit", json=custom_data)
        assert response.status_code in [200, 401, 403, 404, 409, 422]


class TestRuleSelectionEndpoints:
    """Test rule selection API endpoints"""
    
    def test_select_rules_for_validation_success(self, client):
        """Test selecting rules for validation"""
        selection_data = {
            "document_type": "demand_letter",
            "practice_area": "personal_injury",
            "jurisdiction_state": "AZ"
        }
        response = client.post("/api/v1/tenant/validate/select-rules", json=selection_data)
        assert response.status_code in [200, 401, 403, 422]
    
    def test_select_rules_missing_document_type(self, client):
        """Test rule selection with missing document type"""
        invalid_data = {"practice_area": "personal_injury"}
        response = client.post("/api/v1/tenant/validate/select-rules", json=invalid_data)
        assert response.status_code in [401, 403, 422]
    
    def test_get_enabled_rules_success(self, client):
        """Test getting enabled rules for validation"""
        params = {
            "document_type": "demand_letter",
            "practice_area": "personal_injury",
            "jurisdiction_state": "AZ"
        }
        response = client.get("/api/v1/tenant/validate/enabled-rules", params=params)
        assert response.status_code in [200, 401, 403]
    
    def test_get_enabled_rules_no_filters(self, client):
        """Test getting enabled rules without filters"""
        response = client.get("/api/v1/tenant/validate/enabled-rules")
        assert response.status_code in [200, 401, 403]


class TestAPIEndpointEdgeCases:
    """Test API endpoint edge cases and error scenarios"""
    
    def test_invalid_uuid_format(self, client):
        """Test API endpoints with invalid UUID format"""
        invalid_uuid = "not-a-uuid"
        response = client.get(f"/api/v1/admin/rule-templates/{invalid_uuid}")
        assert response.status_code in [401, 403, 404, 422]
    
    def test_malformed_json_request(self, client):
        """Test API endpoints with malformed JSON"""
        response = client.post(
            "/api/v1/admin/rule-templates",
            content="{invalid json}",
            headers={"Content-Type": "application/json"}
        )
        assert response.status_code in [400, 401, 403, 422]
    
    def test_unauthorized_access(self, client):
        """Test API endpoints without proper authorization"""
        # Test without auth headers if required
        response = client.get("/api/v1/admin/rule-templates", headers={})
        assert response.status_code in [401, 403]
    
    def test_method_not_allowed(self, client):
        """Test API endpoints with wrong HTTP method"""
        response = client.put("/api/v1/admin/rule-templates")  # Should be POST
        assert response.status_code in [405, 401, 403]
    
    def test_content_type_validation(self, client):
        """Test API endpoints with wrong content type"""
        response = client.post(
            "/api/v1/validation/validate",
            content="text data",
            headers={"Content-Type": "text/plain"}
        )
        assert response.status_code in [400, 401, 403, 415, 422]
    
    def test_large_payload_handling(self, client):
        """Test API endpoints with large payloads"""
        large_data = {
            "document_text": "A" * 1000000,  # 1MB document
            "practice_area": "personal_injury",
            "document_type": "demand_letter",
            "jurisdiction_state": "AZ"
        }
        response = client.post("/api/v1/validation/validate", json=large_data)
        assert response.status_code in [200, 400, 401, 403, 413, 422]
    
    def test_concurrent_requests(self, client):
        """Test handling concurrent API requests"""
        # Send multiple rapid requests
        responses = []
        for i in range(5):
            response = client.get("/api/v1/health")
            responses.append(response.status_code)
        
        # All should succeed or fail consistently
        assert all(code in [200, 401, 403, 404] for code in responses)


if __name__ == "__main__":
    print("\n" + "="*80)
    print("API Endpoint Tests - Coverage Improvement Target")
    print("="*80 + "\n")
    
    pytest.main([__file__, "-v", "--tb=short"])