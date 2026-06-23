"""
TrueVow DRAFT™ Service - Tenant Rules API

Tenant-Specific Rules Management (Law Firms)

Endpoints:
1. GET /api/v1/tenant/rules - List tenant rules
2. GET /api/v1/tenant/rules/{id} - Get rule details
3. POST /api/v1/tenant/rules - Create tenant rule
4. PUT /api/v1/tenant/rules/{id} - Update rule
5. DELETE /api/v1/tenant/rules/{id} - Archive rule
6. GET /api/v1/tenant/rules/by-document-type - List rules by document type
"""

from typing import Optional
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, status, Query
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.auth_v2 import require_tenant_access
from app.services.rules_service_v2 import TenantRulesService


router = APIRouter(prefix="/tenant/rules", tags=["Tenant - Rules Management"])


# ============================================================================
# PYDANTIC SCHEMAS
# ============================================================================

class CreateTenantRuleRequest(BaseModel):
    """Request schema for creating a tenant-specific rule"""
    rule_name: str = Field(..., description="Rule name", max_length=200)
    validator_level: int = Field(..., description="Validator level (1-5)", ge=1, le=5)
    validator_name: str = Field(..., description="Validator identifier", max_length=100)
    validator_type: str = Field(..., description="Validator type", max_length=50)
    practice_area: Optional[str] = Field(None, description="Practice area", max_length=100)
    specialization: Optional[str] = Field(None, description="Specialization", max_length=100)
    document_type: Optional[str] = Field(None, description="Document type", max_length=100)
    jurisdiction_state: Optional[str] = Field(None, description="State (2 letters)", max_length=2)
    jurisdiction_county: Optional[str] = Field(None, description="County", max_length=100)
    jurisdiction_court: Optional[str] = Field(None, description="Court", max_length=200)
    validator_config: dict = Field(default_factory=dict, description="Validator configuration")
    error_message: Optional[str] = Field(None, description="Error message")
    warning_message: Optional[str] = Field(None, description="Warning message")
    info_message: Optional[str] = Field(None, description="Info message")
    severity: str = Field("error", description="Severity", pattern="^(error|warning|info)$")


class UpdateTenantRuleRequest(BaseModel):
    """Request schema for updating a tenant-specific rule"""
    rule_name: Optional[str] = Field(None, description="Rule name", max_length=200)
    validator_config: Optional[dict] = Field(None, description="Validator configuration")
    error_message: Optional[str] = Field(None, description="Error message")
    warning_message: Optional[str] = Field(None, description="Warning message")
    info_message: Optional[str] = Field(None, description="Info message")
    severity: Optional[str] = Field(None, description="Severity", pattern="^(error|warning|info)$")
    is_active: Optional[bool] = Field(None, description="Active status")
    is_enabled_for_validation: Optional[bool] = Field(None, description="Enable for validation")


class ApproveTenantRuleRequest(BaseModel):
    """Request schema for attorney approval of a tenant rule.

    This is the ONLY way to promote a tenant rule to review_status='document_verified'.
    Flagged-error rules are blocked until their issues are resolved.
    """
    approved_by: Optional[str] = Field(
        None,
        description="Clerk user/org ID of the approving attorney",
        max_length=255,
    )


# ============================================================================
# API ENDPOINTS
# ============================================================================

@router.get(
    "",
    summary="List tenant-specific rules",
    description="""
    List all validation rules for the current tenant (law firm).
    
    **Filters:**
    - document_type: Filter by document type
    - practice_area: Filter by practice area
    - status: Filter by status (active/archived)
    
    **Pagination:**
    - skip: Offset (default: 0)
    - limit: Number of results (default: 100)
    
    **Tenant Isolation:**
    - Only returns rules for the authenticated tenant
    - Cannot access other tenants' rules
    """
)
async def list_tenant_rules(
    document_type: Optional[str] = Query(None, description="Filter by document type"),
    practice_area: Optional[str] = Query(None, description="Filter by practice area"),
    status: Optional[str] = Query(None, description="Filter by status (active/archived)"),
    skip: int = Query(0, description="Pagination offset", ge=0),
    limit: int = Query(100, description="Number of results", ge=1, le=500),
    api_key_data: dict = Depends(require_tenant_access),
    db: Session = Depends(get_db)
):
    """List tenant-specific rules"""
    service = TenantRulesService(db, tenant_id=api_key_data["tenant_id"])
    
    is_active = None
    if status == "active":
        is_active = True
    elif status == "archived":
        is_active = False
    
    result = service.list_rules(
        document_type=document_type,
        practice_area=practice_area,
        is_active=is_active,
        skip=skip,
        limit=limit
    )
    
    return result


@router.get(
    "/{id}",
    summary="Get tenant-specific rule",
    description="""
    Get a specific validation rule by ID (tenant-specific).
    
    **Tenant Isolation:**
    - Only returns rule if it belongs to the authenticated tenant
    - Returns 404 if rule not found or belongs to another tenant
    
    **Response includes:**
    - Rule metadata
    - Validator configuration
    - Inheritance information (if inherited from template)
    """
)
async def get_tenant_rule(
    id: UUID,
    api_key_data: dict = Depends(require_tenant_access),
    db: Session = Depends(get_db)
):
    """Get tenant-specific rule"""
    service = TenantRulesService(db, tenant_id=api_key_data["tenant_id"])
    rule = service.get_rule(id)
    
    return rule.to_dict(include_relationships=True)


@router.post(
    "",
    status_code=status.HTTP_201_CREATED,
    summary="Create tenant-specific rule",
    description="""
    Create a new validation rule for the current tenant (law firm).
    
    **Zero-Knowledge Compliance:**
    - Rule contains validation logic only
    - NO document content
    - NO client data
    
    **Tenant Isolation:**
    - Rule is automatically scoped to the authenticated tenant
    - Rule only applies to tenant's documents
    """
)
async def create_tenant_rule(
    request: CreateTenantRuleRequest,
    api_key_data: dict = Depends(require_tenant_access),
    db: Session = Depends(get_db)
):
    """Create tenant-specific rule"""
    service = TenantRulesService(db, tenant_id=api_key_data["tenant_id"])
    
    rule = service.create_rule(
        rule_data=request.dict(),
        created_by=None  # TODO: Get user ID from api_key_data
    )
    
    return {
        "id": str(rule.id),
        "rule_name": rule.rule_name,
        "created_at": rule.created_at.isoformat()
    }


@router.put(
    "/{id}",
    summary="Update tenant-specific rule",
    description="""
    Update a validation rule for the current tenant (law firm).
    
    **Customization Tracking:**
    - If rule was inherited from template, updating validator_config marks it as customized
    - is_customized flag is automatically set to true
    
    **Tenant Isolation:**
    - Can only update rules belonging to the authenticated tenant
    - Returns 404 if rule not found or belongs to another tenant
    """
)
async def update_tenant_rule(
    id: UUID,
    request: UpdateTenantRuleRequest,
    api_key_data: dict = Depends(require_tenant_access),
    db: Session = Depends(get_db)
):
    """Update tenant-specific rule"""
    service = TenantRulesService(db, tenant_id=api_key_data["tenant_id"])
    
    rule = service.update_rule(
        rule_id=id,
        rule_data=request.dict(exclude_unset=True)
    )
    
    return {
        "id": str(rule.id),
        "updated_at": rule.updated_at.isoformat()
    }


@router.delete(
    "/{id}",
    summary="Archive tenant-specific rule",
    description="""
    Archive a validation rule for the current tenant (law firm).
    
    **Archive Behavior:**
    - Rule is marked as inactive
    - Rule is no longer used for validation
    - Rule can be reactivated by updating is_active=true
    
    **Tenant Isolation:**
    - Can only archive rules belonging to the authenticated tenant
    - Returns 404 if rule not found or belongs to another tenant
    """
)
async def archive_tenant_rule(
    id: UUID,
    api_key_data: dict = Depends(require_tenant_access),
    db: Session = Depends(get_db)
):
    """Archive tenant-specific rule"""
    service = TenantRulesService(db, tenant_id=api_key_data["tenant_id"])
    
    rule = service.archive_rule(id)
    
    return {
        "id": str(rule.id),
        "archived_at": rule.archived_at.isoformat()
    }


@router.get(
    "/by-document-type",
    summary="List rules by document type",
    description="""
    List validation rules organized by document type.
    
    **Use Case:**
    - Get all rules applicable to a specific document type
    - Organize rules by document type in UI
    - Select rules for validation
    
    **Filters:**
    - document_type: Required - Document type to filter by
    - practice_area: Filter by practice area
    - jurisdiction_state: Filter by jurisdiction
    
    **Tenant Isolation:**
    - Only returns rules for the authenticated tenant
    """
)
async def list_rules_by_document_type(
    document_type: str = Query(..., description="Document type (required)"),
    practice_area: Optional[str] = Query(None, description="Filter by practice area"),
    jurisdiction_state: Optional[str] = Query(None, description="Filter by jurisdiction"),
    api_key_data: dict = Depends(require_tenant_access),
    db: Session = Depends(get_db)
):
    """List rules by document type"""
    service = TenantRulesService(db, tenant_id=api_key_data["tenant_id"])
    
    result = service.list_rules_by_document_type(
        document_type=document_type,
        practice_area=practice_area,
        jurisdiction_state=jurisdiction_state
    )
    
    return result


@router.post(
    "/{id}/approve",
    summary="Attorney approval — promote tenant rule to document_verified",
    description="""
    Attorney sign-off on a tenant-specific rule.

    **This is the ONLY way to set review_status='document_verified' for tenant rules.**

    Workflow:
    1. Rule created → needs_review
    2. Protocol v3 verifier run → ai_verified_pending_attorney or flagged_error
    3. Attorney reviews and calls this endpoint → document_verified

    Flagged-error rules cannot be approved until the flagged issue is resolved.
    """
)
async def approve_tenant_rule(
    id: UUID,
    request: ApproveTenantRuleRequest,
    api_key_data: dict = Depends(require_tenant_access),
    db: Session = Depends(get_db)
):
    """Approve tenant rule (attorney sign-off)"""
    service = TenantRulesService(db, tenant_id=api_key_data["tenant_id"])
    rule = service.approve_rule(
        rule_id=id,
        approved_by=request.approved_by or api_key_data.get("user_id"),
    )
    return {
        "id": str(rule.id),
        "rule_name": rule.rule_name,
        "review_status": rule.review_status,
        "reviewed_by": rule.reviewed_by,
        "reviewed_at": rule.reviewed_at.isoformat() if rule.reviewed_at else None,
    }


@router.get(
    "/health",
    summary="Health check",
    description="Health check endpoint for tenant rules service"
)
async def health_check():
    """Health check"""
    return {
        "status": "healthy",
        "service": "tenant_rules",
        "tenant_scoped": True
    }

