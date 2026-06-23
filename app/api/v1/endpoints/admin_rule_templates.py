"""
TrueVow DRAFT™ Service - Admin Rule Templates API

Global Rule Templates Management (SaaS Admin Only)

Endpoints:
1. GET /api/v1/admin/rule-templates - List global templates
2. GET /api/v1/admin/rule-templates/{id} - Get template details
3. POST /api/v1/admin/rule-templates - Create template
4. PUT /api/v1/admin/rule-templates/{id} - Update template
5. DELETE /api/v1/admin/rule-templates/{id} - Archive template
6. GET /api/v1/admin/rule-templates/library - Browse template library
"""

from typing import Optional
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, status, Query
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.auth_v2 import require_admin_access
from app.services.rules_service_v2 import GlobalRuleTemplatesService


router = APIRouter(prefix="/admin/rule-templates", tags=["Admin - Global Rule Templates"])


# ============================================================================
# PYDANTIC SCHEMAS
# ============================================================================

class CreateRuleTemplateRequest(BaseModel):
    """Request schema for creating a global rule template"""
    template_name: str = Field(..., description="Template name", max_length=200)
    template_description: Optional[str] = Field(None, description="Template description")
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


class UpdateRuleTemplateRequest(BaseModel):
    """Request schema for updating a global rule template"""
    template_name: Optional[str] = Field(None, description="Template name", max_length=200)
    template_description: Optional[str] = Field(None, description="Template description")
    validator_config: Optional[dict] = Field(None, description="Validator configuration")
    error_message: Optional[str] = Field(None, description="Error message")
    warning_message: Optional[str] = Field(None, description="Warning message")
    info_message: Optional[str] = Field(None, description="Info message")
    severity: Optional[str] = Field(None, description="Severity", pattern="^(error|warning|info)$")
    is_active: Optional[bool] = Field(None, description="Active status")


class ApproveRuleRequest(BaseModel):
    """Request schema for attorney approval of a rule template.

    This is the ONLY way to promote a rule to review_status='document_verified'.
    It must be called explicitly after the attorney has reviewed the rule.
    Flagged-error rules cannot be approved — they must be resolved first.
    """
    approved_by: Optional[str] = Field(
        None,
        description="Clerk user/org ID of the approving attorney (e.g. user_2abc123)",
        max_length=255,
    )


# ============================================================================
# API ENDPOINTS
# ============================================================================

@router.get(
    "",
    summary="List global rule templates",
    description="""
    List all global rule templates (SaaS Admin only).
    
    **Filters:**
    - validator_level: Filter by level (1-5)
    - practice_area: Filter by practice area
    - specialization: Filter by specialization
    - document_type: Filter by document type
    - jurisdiction_state: Filter by jurisdiction
    - status: Filter by status (active/archived)
    
    **Pagination:**
    - skip: Offset (default: 0)
    - limit: Number of results (default: 100)
    """
)
async def list_rule_templates(
    validator_level: Optional[int] = Query(None, description="Filter by validator level (1-5)", ge=1, le=5),
    practice_area: Optional[str] = Query(None, description="Filter by practice area"),
    specialization: Optional[str] = Query(None, description="Filter by specialization"),
    document_type: Optional[str] = Query(None, description="Filter by document type"),
    jurisdiction_state: Optional[str] = Query(None, description="Filter by jurisdiction (state)"),
    status: Optional[str] = Query(None, description="Filter by status (active/archived)"),
    skip: int = Query(0, description="Pagination offset", ge=0),
    limit: int = Query(100, description="Number of results", ge=1, le=500),
    api_key_data: dict = Depends(require_admin_access),
    db: Session = Depends(get_db)
):
    """List global rule templates"""
    service = GlobalRuleTemplatesService(db)
    
    is_active = None
    if status == "active":
        is_active = True
    elif status == "archived":
        is_active = False
    
    result = service.list_templates(
        validator_level=validator_level,
        practice_area=practice_area,
        specialization=specialization,
        document_type=document_type,
        jurisdiction_state=jurisdiction_state,
        is_active=is_active,
        skip=skip,
        limit=limit
    )
    
    return result


@router.get(
    "/{id}",
    summary="Get global rule template",
    description="""
    Get a specific global rule template by ID (SaaS Admin only).
    
    **Response includes:**
    - Template metadata
    - Validator configuration
    - Inheritance count (how many tenants inherited this template)
    """
)
async def get_rule_template(
    id: UUID,
    api_key_data: dict = Depends(require_admin_access),
    db: Session = Depends(get_db)
):
    """Get global rule template"""
    service = GlobalRuleTemplatesService(db)
    template = service.get_template(id)
    
    return template.to_dict(include_relationships=True)


@router.post(
    "",
    status_code=status.HTTP_201_CREATED,
    summary="Create global rule template",
    description="""
    Create a new global rule template (SaaS Admin only).
    
    **Zero-Knowledge Compliance:**
    - Template contains validation logic only
    - NO document content
    - NO client data
    
    **Template will be available for:**
    - Inheritance by all law firms
    - Customization after inheritance
    """
)
async def create_rule_template(
    request: CreateRuleTemplateRequest,
    api_key_data: dict = Depends(require_admin_access),
    db: Session = Depends(get_db)
):
    """Create global rule template"""
    service = GlobalRuleTemplatesService(db)
    
    template = service.create_template(
        template_data=request.dict(),
        created_by=None  # TODO: Get admin user ID from api_key_data
    )
    
    return {
        "id": str(template.id),
        "template_name": template.template_name,
        "version": template.version,
        "created_at": template.created_at.isoformat()
    }


@router.put(
    "/{id}",
    summary="Update global rule template",
    description="""
    Update a global rule template (SaaS Admin only).
    
    **Version Management:**
    - Version number is automatically incremented
    - Tenants who inherited this template will see old version
    - To update inherited rules, tenants must re-inherit
    """
)
async def update_rule_template(
    id: UUID,
    request: UpdateRuleTemplateRequest,
    api_key_data: dict = Depends(require_admin_access),
    db: Session = Depends(get_db)
):
    """Update global rule template"""
    service = GlobalRuleTemplatesService(db)
    
    template = service.update_template(
        template_id=id,
        template_data=request.dict(exclude_unset=True)
    )
    
    return {
        "id": str(template.id),
        "version": template.version,
        "updated_at": template.updated_at.isoformat()
    }


@router.delete(
    "/{id}",
    summary="Archive global rule template",
    description="""
    Archive a global rule template (SaaS Admin only).
    
    **Archive Behavior:**
    - Template is marked as inactive
    - Template is no longer available for new inheritance
    - Existing inherited rules are NOT affected
    - Template can be reactivated by updating is_active=true
    """
)
async def archive_rule_template(
    id: UUID,
    api_key_data: dict = Depends(require_admin_access),
    db: Session = Depends(get_db)
):
    """Archive global rule template"""
    service = GlobalRuleTemplatesService(db)
    
    template = service.archive_template(id)
    
    return {
        "id": str(template.id),
        "archived_at": template.archived_at.isoformat()
    }


@router.get(
    "/library/browse",
    summary="Browse template library",
    description="""
    Browse global rule template library (SaaS Admin only).
    
    **Categories:**
    - popular: Most inherited templates
    - recent: Recently created templates
    - recommended: Universal (Level 1) templates
    
    **Filters:**
    - practice_area: Filter by practice area
    - document_type: Filter by document type
    - jurisdiction_state: Filter by jurisdiction
    - category: Filter by category (popular/recent/recommended)
    """
)
async def browse_template_library(
    practice_area: Optional[str] = Query(None, description="Filter by practice area"),
    document_type: Optional[str] = Query(None, description="Filter by document type"),
    jurisdiction_state: Optional[str] = Query(None, description="Filter by jurisdiction"),
    category: Optional[str] = Query(None, description="Filter by category (popular/recent/recommended)"),
    api_key_data: dict = Depends(require_admin_access),
    db: Session = Depends(get_db)
):
    """Browse template library"""
    service = GlobalRuleTemplatesService(db)
    
    result = service.get_template_library(
        practice_area=practice_area,
        document_type=document_type,
        jurisdiction_state=jurisdiction_state,
        category=category
    )
    
    return result


@router.post(
    "/{id}/approve",
    summary="Attorney approval — promote rule to document_verified",
    description="""
    Attorney-only endpoint: marks a global rule template as document_verified.

    **This is the ONLY way to set review_status='document_verified'.**

    Rules must first pass the deterministic Protocol v3 verification gate
    (run protocol_v3_verifier.py) before an attorney can approve them.
    Flagged-error rules are blocked until their issues are resolved.

    **Workflow:**
    1. Rule created (review_status = needs_review)
    2. Protocol v3 verifier run → ai_verified_pending_attorney or flagged_error
    3. Attorney reviews and calls this endpoint → document_verified
    """
)
async def approve_rule_template(
    id: UUID,
    request: ApproveRuleRequest,
    api_key_data: dict = Depends(require_admin_access),
    db: Session = Depends(get_db)
):
    """Approve global rule template (attorney sign-off)"""
    service = GlobalRuleTemplatesService(db)
    template = service.approve_template(
        template_id=id,
        approved_by=request.approved_by or api_key_data.get("user_id"),
    )
    return {
        "id": str(template.id),
        "rule_name": template.rule_name,
        "review_status": template.review_status,
        "reviewed_by": template.reviewed_by,
        "reviewed_at": template.reviewed_at.isoformat() if template.reviewed_at else None,
    }


@router.get(
    "/health",
    summary="Health check",
    description="Health check endpoint for global rule templates service"
)
async def health_check():
    """Health check"""
    return {
        "status": "healthy",
        "service": "global_rule_templates",
        "admin_only": True
    }

