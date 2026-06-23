"""
TrueVow DRAFT™ Service - SaaS Admin Adapter Endpoints

These endpoints are specifically designed for SaaS Admin integration.
They accept tenant_id as a query parameter or in the request body,
allowing SaaS Admin to manage rules for any tenant using an admin API key.

All endpoints:
- Accept admin API keys (access_level == "admin")
- Accept tenant_id as query param or in body
- Forward requests to tenant-specific endpoints internally
"""

from typing import Optional, List
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, status, Query, Body
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.auth_v2 import require_admin_access, verify_tenant_access
from app.services.rules_service_v2 import TenantRulesService
from app.models.validation_rule_v2 import ValidationRule


router = APIRouter(prefix="/tenant", tags=["SaaS Admin - Tenant Rules"])


# ============================================================================
# PYDANTIC SCHEMAS
# ============================================================================

class CreateRuleRequest(BaseModel):
    """Request schema for creating a rule (SaaS Admin format)"""
    tenant_id: UUID = Field(..., description="Tenant ID")
    rule_name: str = Field(..., description="Rule name", max_length=200)
    rule_type: str = Field(..., description="Rule type: ai, regex, or keyword")
    severity: str = Field(..., description="Severity: critical, high, medium, low")
    category: str = Field(..., description="Category")
    is_active: bool = Field(True, description="Active status")
    description: Optional[str] = Field(None, description="Description")
    regex_pattern: Optional[str] = Field(None, description="Regex pattern (for regex type)")
    ai_prompt: Optional[str] = Field(None, description="AI prompt (for ai type)")
    keywords: Optional[List[str]] = Field(None, description="Keywords (for keyword type)")


class UpdateRuleRequest(BaseModel):
    """Request schema for updating a rule (SaaS Admin format)"""
    rule_name: Optional[str] = Field(None, description="Rule name", max_length=200)
    rule_type: Optional[str] = Field(None, description="Rule type")
    severity: Optional[str] = Field(None, description="Severity")
    category: Optional[str] = Field(None, description="Category")
    is_active: Optional[bool] = Field(None, description="Active status")
    description: Optional[str] = Field(None, description="Description")
    regex_pattern: Optional[str] = Field(None, description="Regex pattern")
    ai_prompt: Optional[str] = Field(None, description="AI prompt")
    keywords: Optional[List[str]] = Field(None, description="Keywords")


class RuleResponse(BaseModel):
    """Response schema for a rule (SaaS Admin format)"""
    rule_id: str
    tenant_id: str
    rule_name: str
    rule_type: str
    severity: str
    category: str
    is_active: bool
    description: Optional[str] = None
    regex_pattern: Optional[str] = None
    ai_prompt: Optional[str] = None
    keywords: Optional[List[str]] = None
    created_at: Optional[str] = None
    updated_at: Optional[str] = None


# ============================================================================
# API ENDPOINTS
# ============================================================================

@router.get(
    "/rules",
    response_model=List[RuleResponse],
    summary="List tenant rules (SaaS Admin)",
    description="""
    List all validation rules for a specific tenant.
    
    **Authentication:** Admin API key required
    **Tenant ID:** Provided as query parameter
    """
)
async def list_rules(
    tenant_id: UUID = Query(..., description="Tenant ID"),
    api_key_data: dict = Depends(require_admin_access),
    db: Session = Depends(get_db)
):
    """List rules for a tenant (SaaS Admin)"""
    # Verify admin has access (admin keys have access to all tenants)
    verify_tenant_access(api_key_data, tenant_id)
    
    service = TenantRulesService(db, tenant_id=tenant_id)
    result = service.list_rules(skip=0, limit=500)
    
    # Convert to SaaS Admin format
    rules = []
    for rule_dict in result.get("rules", []):
        rule_obj = rule_dict if isinstance(rule_dict, dict) else rule_dict
        rules.append(RuleResponse(
            rule_id=str(rule_obj.get("id", "")),
            tenant_id=str(tenant_id),
            rule_name=rule_obj.get("rule_name", ""),
            rule_type=rule_obj.get("validator_type", "regex"),
            severity=rule_obj.get("severity", "medium"),
            category=rule_obj.get("practice_area", ""),
            is_active=rule_obj.get("is_active", True),
            description=rule_obj.get("error_message"),
            regex_pattern=rule_obj.get("validator_config", {}).get("pattern"),
            ai_prompt=rule_obj.get("validator_config", {}).get("prompt"),
            keywords=rule_obj.get("validator_config", {}).get("keywords", []),
            created_at=rule_obj.get("created_at"),
            updated_at=rule_obj.get("updated_at")
        ))
    
    return {"rules": rules}


@router.post(
    "/rules",
    status_code=status.HTTP_201_CREATED,
    response_model=RuleResponse,
    summary="Create tenant rule (SaaS Admin)",
    description="""
    Create a new validation rule for a specific tenant.
    
    **Authentication:** Admin API key required
    **Tenant ID:** Provided in request body
    """
)
async def create_rule(
    request: CreateRuleRequest,
    api_key_data: dict = Depends(require_admin_access),
    db: Session = Depends(get_db)
):
    """Create rule for a tenant (SaaS Admin)"""
    # Verify admin has access
    verify_tenant_access(api_key_data, request.tenant_id)
    
    service = TenantRulesService(db, tenant_id=request.tenant_id)
    
    # Convert SaaS Admin format to DRAFT service format
    rule_data = {
        "rule_name": request.rule_name,
        "validator_level": 1,  # Default level
        "validator_name": request.rule_name.lower().replace(" ", "_"),
        "validator_type": request.rule_type,
        "practice_area": request.category,
        "severity": request.severity,
        "is_active": request.is_active,
        "error_message": request.description,
        "validator_config": {}
    }
    
    # Add type-specific config
    if request.rule_type == "regex" and request.regex_pattern:
        rule_data["validator_config"]["pattern"] = request.regex_pattern
    elif request.rule_type == "ai" and request.ai_prompt:
        rule_data["validator_config"]["prompt"] = request.ai_prompt
    elif request.rule_type == "keyword" and request.keywords:
        rule_data["validator_config"]["keywords"] = request.keywords
    
    rule = service.create_rule(rule_data=rule_data, created_by=None)
    
    # Convert to SaaS Admin format
    rule_response = RuleResponse(
        rule_id=str(rule.id),
        tenant_id=str(request.tenant_id),
        rule_name=rule.rule_name,
        rule_type=rule.validator_type,
        severity=rule.severity or "medium",
        category=rule.practice_area or "",
        is_active=rule.is_active,
        description=rule.error_message,
        regex_pattern=rule.validator_config.get("pattern") if isinstance(rule.validator_config, dict) else None,
        ai_prompt=rule.validator_config.get("prompt") if isinstance(rule.validator_config, dict) else None,
        keywords=rule.validator_config.get("keywords", []) if isinstance(rule.validator_config, dict) else [],
        created_at=rule.created_at.isoformat() if rule.created_at else None,
        updated_at=rule.updated_at.isoformat() if rule.updated_at else None
    )
    return {"rule": rule_response.dict()}


@router.get(
    "/rules/{rule_id}",
    response_model=RuleResponse,
    summary="Get tenant rule (SaaS Admin)",
    description="""
    Get a specific validation rule by ID.
    
    **Authentication:** Admin API key required
    **Tenant ID:** Extracted from rule (must belong to tenant)
    """
)
async def get_rule(
    rule_id: UUID,
    tenant_id: UUID = Query(..., description="Tenant ID"),
    api_key_data: dict = Depends(require_admin_access),
    db: Session = Depends(get_db)
):
    """Get rule for a tenant (SaaS Admin)"""
    # Verify admin has access
    verify_tenant_access(api_key_data, tenant_id)
    
    service = TenantRulesService(db, tenant_id=tenant_id)
    rule = service.get_rule(rule_id)
    
    # Verify rule belongs to tenant
    if str(rule.tenant_id) != str(tenant_id):
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Rule not found"
        )
    
    # Convert to SaaS Admin format
    return RuleResponse(
        rule_id=str(rule.id),
        tenant_id=str(rule.tenant_id),
        rule_name=rule.rule_name,
        rule_type=rule.validator_type,
        severity=rule.severity or "medium",
        category=rule.practice_area or "",
        is_active=rule.is_active,
        description=rule.error_message,
        regex_pattern=rule.validator_config.get("pattern") if isinstance(rule.validator_config, dict) else None,
        ai_prompt=rule.validator_config.get("prompt") if isinstance(rule.validator_config, dict) else None,
        keywords=rule.validator_config.get("keywords", []) if isinstance(rule.validator_config, dict) else [],
        created_at=rule.created_at.isoformat() if rule.created_at else None,
        updated_at=rule.updated_at.isoformat() if rule.updated_at else None
    )


@router.put(
    "/rules/{rule_id}",
    response_model=RuleResponse,
    summary="Update tenant rule (SaaS Admin)",
    description="""
    Update a validation rule for a specific tenant.
    
    **Authentication:** Admin API key required
    **Tenant ID:** Provided as query parameter
    """
)
async def update_rule(
    rule_id: UUID,
    request: UpdateRuleRequest,
    tenant_id: UUID = Query(..., description="Tenant ID"),
    api_key_data: dict = Depends(require_admin_access),
    db: Session = Depends(get_db)
):
    """Update rule for a tenant (SaaS Admin)"""
    # Verify admin has access
    verify_tenant_access(api_key_data, tenant_id)
    
    service = TenantRulesService(db, tenant_id=tenant_id)
    
    # Convert SaaS Admin format to DRAFT service format
    rule_data = {}
    if request.rule_name is not None:
        rule_data["rule_name"] = request.rule_name
    if request.rule_type is not None:
        rule_data["validator_type"] = request.rule_type
    if request.severity is not None:
        rule_data["severity"] = request.severity
    if request.category is not None:
        rule_data["practice_area"] = request.category
    if request.is_active is not None:
        rule_data["is_active"] = request.is_active
    if request.description is not None:
        rule_data["error_message"] = request.description
    
    # Update validator_config if needed
    validator_config = {}
    if request.regex_pattern is not None:
        validator_config["pattern"] = request.regex_pattern
    if request.ai_prompt is not None:
        validator_config["prompt"] = request.ai_prompt
    if request.keywords is not None:
        validator_config["keywords"] = request.keywords
    
    if validator_config:
        rule_data["validator_config"] = validator_config
    
    rule = service.update_rule(rule_id=rule_id, rule_data=rule_data)
    
    # Convert to SaaS Admin format
    return RuleResponse(
        rule_id=str(rule.id),
        tenant_id=str(rule.tenant_id),
        rule_name=rule.rule_name,
        rule_type=rule.validator_type,
        severity=rule.severity or "medium",
        category=rule.practice_area or "",
        is_active=rule.is_active,
        description=rule.error_message,
        regex_pattern=rule.validator_config.get("pattern") if isinstance(rule.validator_config, dict) else None,
        ai_prompt=rule.validator_config.get("prompt") if isinstance(rule.validator_config, dict) else None,
        keywords=rule.validator_config.get("keywords", []) if isinstance(rule.validator_config, dict) else [],
        created_at=rule.created_at.isoformat() if rule.created_at else None,
        updated_at=rule.updated_at.isoformat() if rule.updated_at else None
    )


@router.delete(
    "/rules/{rule_id}",
    status_code=status.HTTP_200_OK,
    summary="Delete tenant rule (SaaS Admin)",
    description="""
    Delete (archive) a validation rule for a specific tenant.
    
    **Authentication:** Admin API key required
    **Tenant ID:** Provided as query parameter
    """
)
async def delete_rule(
    rule_id: UUID,
    tenant_id: UUID = Query(..., description="Tenant ID"),
    api_key_data: dict = Depends(require_admin_access),
    db: Session = Depends(get_db)
):
    """Delete rule for a tenant (SaaS Admin)"""
    # Verify admin has access
    verify_tenant_access(api_key_data, tenant_id)
    
    service = TenantRulesService(db, tenant_id=tenant_id)
    rule = service.archive_rule(rule_id)
    
    return {
        "message": "Rule deleted successfully",
        "rule_id": str(rule.id)
    }

