"""
TrueVow DRAFT™ Service - Template Inheritance API

Template Inheritance (Law Firms)

Law firms browse global templates and inherit them as tenant-specific rules.

Endpoints:
1. GET /api/v1/tenant/rule-templates - Browse available global templates
2. GET /api/v1/tenant/rule-templates/{id} - Get template detail
3. POST /api/v1/tenant/rule-templates/{id}/inherit - Inherit template
"""

from typing import Optional
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, status, Query
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.auth_v2 import require_tenant_access
from app.services.rules_service_v2 import TemplateInheritanceService


router = APIRouter(prefix="/tenant/rule-templates", tags=["Tenant - Template Inheritance"])


# ============================================================================
# PYDANTIC SCHEMAS
# ============================================================================

class InheritTemplateRequest(BaseModel):
    """Request schema for inheriting a global template"""
    customize: bool = Field(False, description="Whether to customize the inherited rule")
    customizations: Optional[dict] = Field(None, description="Customization data")
    
    class Config:
        json_schema_extra = {
            "example": {
                "customize": True,
                "customizations": {
                    "rule_name": "Custom Arizona Demand Letter Format",
                    "validator_config": {
                        "required_sections": ["header", "facts", "liability", "damages", "settlement_demand", "custom_section"],
                        "font_size_min": 11,
                        "font_size_max": 14,
                        "margin_inches": 1.0
                    },
                    "error_message": "Custom error message for our firm",
                    "warning_message": "Custom warning message"
                }
            }
        }


# ============================================================================
# API ENDPOINTS
# ============================================================================

@router.get(
    "",
    summary="Browse available global templates",
    description="""
    Browse global rule templates available for inheritance.
    
    **Shows:**
    - All active global templates
    - Whether tenant has already inherited each template
    - Inherited rule ID (if inherited)
    
    **Filters:**
    - practice_area: Filter by practice area
    - document_type: Filter by document type
    - jurisdiction_state: Filter by jurisdiction
    
    **Pagination:**
    - skip: Offset (default: 0)
    - limit: Number of results (default: 100)
    
    **Use Case:**
    - Law firms browse global templates
    - Select templates to inherit
    - See which templates are already inherited
    """
)
async def browse_global_templates(
    practice_area: Optional[str] = Query(None, description="Filter by practice area"),
    document_type: Optional[str] = Query(None, description="Filter by document type"),
    jurisdiction_state: Optional[str] = Query(None, description="Filter by jurisdiction"),
    skip: int = Query(0, description="Pagination offset", ge=0),
    limit: int = Query(100, description="Number of results", ge=1, le=500),
    api_key_data: dict = Depends(require_tenant_access),
    db: Session = Depends(get_db)
):
    """Browse available global templates"""
    service = TemplateInheritanceService(db, tenant_id=api_key_data["tenant_id"])
    
    result = service.browse_templates(
        practice_area=practice_area,
        document_type=document_type,
        jurisdiction_state=jurisdiction_state,
        skip=skip,
        limit=limit
    )
    
    return result


@router.get(
    "/{id}",
    summary="Get global template detail",
    description="""
    Get detailed information about a global template.
    
    **Shows:**
    - Template metadata
    - Validator configuration
    - Whether tenant has already inherited this template
    - Inherited rule ID (if inherited)
    
    **Use Case:**
    - Preview template before inheriting
    - View template configuration
    - Check inheritance status
    """
)
async def get_template_detail(
    id: UUID,
    api_key_data: dict = Depends(require_tenant_access),
    db: Session = Depends(get_db)
):
    """Get global template detail"""
    service = TemplateInheritanceService(db, tenant_id=api_key_data["tenant_id"])
    
    template_detail = service.get_template_detail(id)
    
    return template_detail


@router.post(
    "/{id}/inherit",
    status_code=status.HTTP_201_CREATED,
    summary="Inherit global template",
    description="""
    Inherit a global template as a tenant-specific rule.
    
    **Process:**
    1. Template is copied to tenant's rules
    2. Rule is scoped to tenant (tenant_id set)
    3. Rule can be customized during inheritance
    4. Rule can be modified after inheritance
    
    **Customization:**
    - customize=false: Inherit template as-is
    - customize=true: Customize during inheritance
    
    **Customizable Fields:**
    - rule_name: Custom rule name
    - validator_config: Custom validator configuration
    - error_message: Custom error message
    - warning_message: Custom warning message
    
    **Restrictions:**
    - Cannot inherit same template twice
    - Template must be active
    
    **Zero-Knowledge Compliance:**
    - Template contains validation logic only
    - NO document content
    - NO client data
    """
)
async def inherit_template(
    id: UUID,
    request: InheritTemplateRequest,
    api_key_data: dict = Depends(require_tenant_access),
    db: Session = Depends(get_db)
):
    """Inherit global template"""
    service = TemplateInheritanceService(db, tenant_id=api_key_data["tenant_id"])
    
    rule = service.inherit_template(
        template_id=id,
        customize=request.customize,
        customizations=request.customizations,
        created_by=None  # TODO: Get user ID from api_key_data
    )
    
    return {
        "rule_id": str(rule.id),
        "template_id": str(rule.inherited_from_template_id),
        "inherited_at": rule.created_at.isoformat(),
        "is_customized": rule.is_customized
    }


@router.get(
    "/health",
    summary="Health check",
    description="Health check endpoint for template inheritance service"
)
async def health_check():
    """Health check"""
    return {
        "status": "healthy",
        "service": "template_inheritance",
        "tenant_scoped": True
    }

