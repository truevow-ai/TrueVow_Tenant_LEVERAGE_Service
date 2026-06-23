"""
TrueVow DRAFT™ Service - Validation Rules API Endpoints
Endpoints for syncing validation rules to client devices
"""

from typing import Optional
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, status, Header
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.auth import require_tenant_access
from app.services.validation_rules_sync import ValidationRulesSyncService

router = APIRouter(prefix="/validation-rules", tags=["Validation Rules"])


# ============================================================================
# PYDANTIC SCHEMAS
# ============================================================================

class ValidationRulesSyncRequest(BaseModel):
    """Request schema for validation rules sync"""
    practice_area: Optional[str] = Field(None, description="Practice area filter")
    specialization: Optional[str] = Field(None, description="Specialization filter")
    document_type: Optional[str] = Field(None, description="Document type filter")
    jurisdiction_state: Optional[str] = Field(None, max_length=2, description="State code (2 letters)")
    jurisdiction_county: Optional[str] = Field(None, description="County name")
    include_universal: bool = Field(True, description="Include Level 1 universal validators")
    client_type: Optional[str] = Field(None, description="Client type (browser_extension, desktop_app, word_addin)")
    client_version: Optional[str] = Field(None, description="Client version")
    device_id: Optional[str] = Field(None, description="Device identifier")
    session_id: Optional[UUID] = Field(None, description="Session ID")
    
    class Config:
        json_schema_extra = {
            "example": {
                "practice_area": "personal_injury",
                "specialization": "car_accident",
                "document_type": "demand_letter",
                "jurisdiction_state": "AZ",
                "jurisdiction_county": "Maricopa",
                "include_universal": True,
                "client_type": "browser_extension",
                "client_version": "1.0.0"
            }
        }


class ValidationRulesResponse(BaseModel):
    """Response schema for validation rules sync"""
    validation_rules: list
    rules_count: int
    rules_version: int
    sync_timestamp: str
    encrypted: bool
    encrypted_rules: str
    filters_applied: dict
    sync_metadata: dict


class CheckUpdatesRequest(BaseModel):
    """Request schema for checking rule updates"""
    current_version: int = Field(..., description="Client's current rules version")
    practice_area: Optional[str] = Field(None, description="Practice area filter")
    specialization: Optional[str] = Field(None, description="Specialization filter")
    document_type: Optional[str] = Field(None, description="Document type filter")
    jurisdiction_state: Optional[str] = Field(None, max_length=2, description="State code")


class CheckUpdatesResponse(BaseModel):
    """Response schema for checking rule updates"""
    updates_available: bool
    current_version: int
    latest_version: int
    updated_rules_count: int
    updated_rules: list


# ============================================================================
# API ENDPOINTS
# ============================================================================

@router.post(
    "/sync",
    response_model=ValidationRulesResponse,
    summary="Sync validation rules to client device",
    description="""
    Sync validation rules to client device (encrypted).
    
    **Zero-Knowledge Architecture:**
    - Rules are synced to client device
    - Document validation happens locally (client-side)
    - Document content never sent to TrueVow servers
    
    **Filtering:**
    - Filter by practice area, specialization, document type, jurisdiction
    - Universal validators (Level 1) always included by default
    
    **Response:**
    - Encrypted rules data (decrypt client-side)
    - Rules metadata and version
    - Sync performance metrics
    """
)
async def sync_validation_rules(
    request: ValidationRulesSyncRequest,
    api_key_data: dict = Depends(require_tenant_access),
    db: Session = Depends(get_db)
):
    """
    Sync validation rules to client device
    
    This endpoint returns encrypted validation rules that are synced to
    the attorney's device for local validation. Documents are NEVER uploaded
    to TrueVow servers (zero-knowledge architecture).
    """
    service = ValidationRulesSyncService(db)
    
    try:
        result = service.get_validation_rules(
            tenant_id=api_key_data["tenant_id"],
            practice_area=request.practice_area,
            specialization=request.specialization,
            document_type=request.document_type,
            jurisdiction_state=request.jurisdiction_state,
            jurisdiction_county=request.jurisdiction_county,
            include_universal=request.include_universal,
            user_id=api_key_data.get("user_id"),
            client_type=request.client_type,
            client_version=request.client_version,
            device_id=request.device_id,
            session_id=request.session_id,
        )
        
        return result
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to sync validation rules: {str(e)}"
        )


@router.get(
    "/{rule_id}",
    summary="Get validation rule by ID",
    description="Get a specific validation rule by its ID"
)
async def get_validation_rule(
    rule_id: UUID,
    api_key_data: dict = Depends(require_tenant_access),
    db: Session = Depends(get_db)
):
    """Get validation rule by ID"""
    service = ValidationRulesSyncService(db)
    
    rule = service.get_rule_by_id(rule_id)
    
    if not rule:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Validation rule {rule_id} not found"
        )
    
    return rule.to_dict()


@router.post(
    "/check-updates",
    response_model=CheckUpdatesResponse,
    summary="Check for rule updates",
    description="""
    Check if there are validation rule updates since client's current version.
    
    **Use Case:**
    - Client periodically checks for updates
    - If updates available, trigger incremental sync
    - Reduces bandwidth by only syncing changed rules
    """
)
async def check_for_updates(
    request: CheckUpdatesRequest,
    api_key_data: dict = Depends(require_tenant_access),
    db: Session = Depends(get_db)
):
    """Check for validation rule updates"""
    service = ValidationRulesSyncService(db)
    
    try:
        result = service.check_for_updates(
            tenant_id=api_key_data["tenant_id"],
            current_version=request.current_version,
            practice_area=request.practice_area,
            specialization=request.specialization,
            document_type=request.document_type,
            jurisdiction_state=request.jurisdiction_state,
        )
        
        return result
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to check for updates: {str(e)}"
        )


@router.get(
    "/health",
    summary="Health check",
    description="Health check endpoint for validation rules service"
)
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "service": "validation_rules",
        "zero_knowledge_compliant": True,
    }

