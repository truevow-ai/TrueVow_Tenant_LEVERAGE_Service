"""
TrueVow DRAFT™ Service - Rule Selection API

Rule Selection for Validation (Law Firms)

Law firms select which rules to validate against when validating documents.

Endpoints:
1. POST /api/v1/tenant/validate/select-rules - Select rules for validation
2. GET /api/v1/tenant/validate/enabled-rules - Get enabled rules for validation
"""

from typing import Optional, List
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, status, Query
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.auth_v2 import require_tenant_access
from app.services.rules_service_v2 import RuleSelectionService


router = APIRouter(prefix="/tenant/validate", tags=["Tenant - Rule Selection"])


# ============================================================================
# PYDANTIC SCHEMAS
# ============================================================================

class SelectRulesRequest(BaseModel):
    """Request schema for selecting rules for validation"""
    document_type: str = Field(..., description="Document type", max_length=100)
    practice_area: Optional[str] = Field(None, description="Practice area", max_length=100)
    jurisdiction_state: Optional[str] = Field(None, description="State (2 letters)", max_length=2)
    
    class Config:
        json_schema_extra = {
            "example": {
                "document_type": "demand_letter",
                "practice_area": "personal_injury",
                "jurisdiction_state": "AZ"
            }
        }


class SelectRulesResponse(BaseModel):
    """Response schema for rule selection"""
    available_rules: List[dict]
    recommended_rules: List[dict]


# ============================================================================
# API ENDPOINTS
# ============================================================================

@router.post(
    "/select-rules",
    response_model=SelectRulesResponse,
    summary="Select rules for validation",
    description="""
    Get available rules for validation selection.
    
    **Purpose:**
    - Show available rules to validate against
    - Recommend rules based on document type/practice area/jurisdiction
    - Allow attorneys to select which rules to apply
    
    **Returns:**
    - available_rules: All rules applicable to the document
    - recommended_rules: Recommended rules (Universal + Required)
    
    **Use Case:**
    1. Attorney uploads document
    2. Attorney selects document type
    3. System shows available rules
    4. Attorney selects which rules to validate against
    5. Client-side validation runs with selected rules
    
    **Filtering:**
    - document_type: Required - Filters rules by document type
    - practice_area: Optional - Filters by practice area (includes universal rules)
    - jurisdiction_state: Optional - Filters by jurisdiction (includes non-jurisdiction-specific)
    
    **Zero-Knowledge Compliance:**
    - Document content is NOT sent to server
    - Only rule selection metadata is logged
    - Validation happens client-side
    """
)
async def select_rules_for_validation(
    request: SelectRulesRequest,
    api_key_data: dict = Depends(require_tenant_access),
    db: Session = Depends(get_db)
):
    """Select rules for validation"""
    service = RuleSelectionService(db, tenant_id=api_key_data["tenant_id"])
    
    result = service.select_rules_for_validation(
        document_type=request.document_type,
        practice_area=request.practice_area,
        jurisdiction_state=request.jurisdiction_state
    )
    
    return result


@router.get(
    "/enabled-rules",
    summary="Get enabled rules for validation",
    description="""
    Get all enabled rules for validation (for actual validation).
    
    **Purpose:**
    - Get rules that are enabled for validation
    - Used for client-side validation engine
    - Filters to only active, enabled rules
    
    **Query Parameters:**
    - document_type: Required - Document type
    - practice_area: Optional - Practice area
    - jurisdiction_state: Optional - Jurisdiction
    
    **Returns:**
    - List of enabled validation rules
    - Ordered by validator level (1-5)
    
    **Use Case:**
    - Client-side validation engine fetches rules
    - Rules are validated in order (Level 1 → Level 5)
    - Only enabled rules are applied
    
    **Zero-Knowledge Compliance:**
    - Rules contain validation logic only
    - NO document content in rules
    - Document validation happens client-side
    """
)
async def get_enabled_rules(
    document_type: str = Query(..., description="Document type (required)"),
    practice_area: Optional[str] = Query(None, description="Practice area"),
    jurisdiction_state: Optional[str] = Query(None, description="Jurisdiction (state)"),
    api_key_data: dict = Depends(require_tenant_access),
    db: Session = Depends(get_db)
):
    """Get enabled rules for validation"""
    service = RuleSelectionService(db, tenant_id=api_key_data["tenant_id"])
    
    rules = service.get_enabled_rules_for_validation(
        document_type=document_type,
        practice_area=practice_area,
        jurisdiction_state=jurisdiction_state
    )
    
    return {
        "rules": [r.to_dict() for r in rules],
        "total": len(rules)
    }


@router.get(
    "/health",
    summary="Health check",
    description="Health check endpoint for rule selection service"
)
async def health_check():
    """Health check"""
    return {
        "status": "healthy",
        "service": "rule_selection",
        "tenant_scoped": True
    }

