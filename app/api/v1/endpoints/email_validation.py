"""
TrueVow DRAFT™ Service - Email Attachment Validation API Endpoints
Provides validation rules and analytics for email attachment validation
"""

from fastapi import APIRouter, Depends, HTTPException, status
from typing import Optional, List, Dict, Any
from uuid import UUID
from datetime import datetime
from pydantic import BaseModel, Field

from app.core.database import get_db
from app.core.auth import require_tenant_access
from app.services.email_validation import EmailAttachmentValidationService
from sqlalchemy.orm import Session


router = APIRouter(prefix="/email", tags=["email-validation"])


# Request/Response Models

class EmailValidationContextRequest(BaseModel):
    """Request model for email validation context"""
    practice_area: str = Field(..., description="Practice area (e.g., 'personal_injury')")
    specialization: Optional[str] = Field(None, description="Specialization (e.g., 'car_accident')")
    document_type: str = Field(..., description="Document type (e.g., 'demand_letter')")
    jurisdiction_state: str = Field(..., description="State code (e.g., 'AZ')")
    jurisdiction_county: Optional[str] = Field(None, description="County name (optional)")
    tenant_id: Optional[UUID] = Field(None, description="Tenant UUID (optional, for tenant-specific rules)")


class EmailValidationContextResponse(BaseModel):
    """Response model for email validation context"""
    rules: List[Dict[str, Any]] = Field(..., description="Encrypted validation rules")
    context: Dict[str, Any] = Field(..., description="Validation context")
    encryption: Dict[str, Any] = Field(..., description="Encryption information")
    source: str = Field(..., description="Source identifier")


class EmailMetadata(BaseModel):
    """Email metadata for validation logging"""
    sender: Optional[str] = Field(None, description="Email sender address")
    date: Optional[str] = Field(None, description="Email date (ISO format)")
    subject: Optional[str] = Field(None, description="Email subject (will be hashed)")


class ValidationResult(BaseModel):
    """Validation result summary"""
    errors: List[str] = Field(default_factory=list, description="Error messages")
    warnings: List[str] = Field(default_factory=list, description="Warning messages")
    rules_checked: int = Field(..., description="Total rules checked")
    rules_passed: int = Field(..., description="Rules passed")
    rules_failed: int = Field(..., description="Rules failed")
    duration_ms: Optional[int] = Field(None, description="Validation duration in milliseconds")
    failed_rule_ids: Optional[List[str]] = Field(None, description="Failed rule IDs")
    specialization: Optional[str] = Field(None, description="Specialization")
    jurisdiction_county: Optional[str] = Field(None, description="Jurisdiction county")


class ClientInfo(BaseModel):
    """Client information"""
    client_type: Optional[str] = Field(None, description="Client type (e.g., 'customer_portal')")
    client_version: Optional[str] = Field(None, description="Client version")


class EmailValidationLogRequest(BaseModel):
    """Request model for logging email validation"""
    tenant_id: UUID = Field(..., description="Tenant UUID")
    user_id: Optional[UUID] = Field(None, description="User UUID")
    practice_area: str = Field(..., description="Practice area")
    document_type: str = Field(..., description="Document type")
    jurisdiction_state: str = Field(..., description="Jurisdiction state")
    validation_passed: bool = Field(..., description="Whether validation passed")
    validation_result: ValidationResult = Field(..., description="Validation result summary")
    email_metadata: EmailMetadata = Field(..., description="Email metadata")
    client_info: Optional[ClientInfo] = Field(None, description="Client information")


class EmailValidationHistoryResponse(BaseModel):
    """Response model for email validation history"""
    id: str
    event_type: str
    event_timestamp: str
    tenant_id: str
    user_id: Optional[str]
    practice_area: Optional[str]
    document_type: Optional[str]
    jurisdiction_state: Optional[str]
    total_rules_checked: Optional[int]
    rules_passed: Optional[int]
    rules_failed: Optional[int]
    rules_warned: Optional[int]
    validation_duration_ms: Optional[int]
    email_sender: Optional[str]
    email_date: Optional[str]
    source: Optional[str]


class EmailValidationStatsResponse(BaseModel):
    """Response model for email validation statistics"""
    total_validations: int
    passed: int
    failed: int
    pass_rate: float
    avg_duration_ms: int
    most_common_document_type: Optional[str]
    most_common_practice_area: Optional[str]


# API Endpoints

@router.post("/validation-context", response_model=EmailValidationContextResponse)
async def get_email_validation_context(
    request: EmailValidationContextRequest,
    db: Session = Depends(get_db),
    api_key_data: dict = Depends(require_tenant_access)
):
    """
    Get validation rules for client-side email attachment validation.
    
    Returns encrypted validation rules (same as browser extension sync).
    
    **ZERO-KNOWLEDGE ARCHITECTURE:**
    - NEVER processes document content server-side
    - ONLY returns encrypted validation rules for client-side validation
    - Client downloads attachment to browser memory
    - Client runs validation engine locally
    - Client logs metadata only (no content)
    
    **Usage:**
    1. Client calls this endpoint to get validation rules
    2. Client downloads email attachment to browser memory (encrypted transfer)
    3. Client decrypts validation rules locally
    4. Client runs validation engine in browser (zero-knowledge)
    5. Client displays results (never sent to server)
    6. Client logs metadata only (optional)
    """
    try:
        service = EmailAttachmentValidationService(db)
        
        context = await service.get_validation_context(
            practice_area=request.practice_area,
            specialization=request.specialization,
            document_type=request.document_type,
            jurisdiction_state=request.jurisdiction_state,
            jurisdiction_county=request.jurisdiction_county,
            tenant_id=request.tenant_id
        )
        
        return EmailValidationContextResponse(**context)
    
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get validation context: {str(e)}"
        )


@router.post("/validation-log")
async def log_email_validation(
    request: EmailValidationLogRequest,
    db: Session = Depends(get_db),
    api_key_data: dict = Depends(require_tenant_access)
):
    """
    Log email attachment validation metadata (NO CONTENT).
    
    **PRIVACY-PRESERVING ANALYTICS:**
    - NEVER logs document content
    - ONLY logs validation results (passed/failed, error counts)
    - Email subject is hashed (SHA-256) for privacy
    - NO PII/PHI data logged
    
    **What Gets Logged:**
    - ✅ Practice area, document type, jurisdiction
    - ✅ Validation result (passed/failed)
    - ✅ Error count, warning count
    - ✅ Email sender (for context)
    - ✅ Email date
    - ✅ Hashed email subject (for deduplication)
    
    **What NEVER Gets Logged:**
    - ❌ Document content
    - ❌ Attachment file data
    - ❌ Email body
    - ❌ Client names, case details
    - ❌ Any sensitive information
    """
    try:
        service = EmailAttachmentValidationService(db)
        
        await service.log_email_attachment_validation(
            tenant_id=request.tenant_id,
            user_id=request.user_id,
            practice_area=request.practice_area,
            document_type=request.document_type,
            jurisdiction_state=request.jurisdiction_state,
            validation_passed=request.validation_passed,
            validation_result=request.validation_result.dict(),
            email_metadata=request.email_metadata.dict(),
            client_info=request.client_info.dict() if request.client_info else None
        )
        
        return {"success": True, "message": "Validation metadata logged successfully"}
    
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to log validation metadata: {str(e)}"
        )


@router.get("/validation-history", response_model=List[EmailValidationHistoryResponse])
async def get_email_validation_history(
    tenant_id: UUID,
    limit: int = 50,
    offset: int = 0,
    practice_area: Optional[str] = None,
    document_type: Optional[str] = None,
    jurisdiction_state: Optional[str] = None,
    start_date: Optional[str] = None,
    end_date: Optional[str] = None,
    validation_passed: Optional[bool] = None,
    db: Session = Depends(get_db),
    api_key_data: dict = Depends(require_tenant_access)
):
    """
    Get email attachment validation history (metadata only, no content).
    
    Returns list of validation history entries with:
    - Practice area, document type, jurisdiction
    - Validation results (passed/failed, error counts)
    - Email metadata (sender, date, hashed subject)
    - Performance metrics (duration)
    
    **NO DOCUMENT CONTENT** is ever stored or returned.
    """
    try:
        service = EmailAttachmentValidationService(db)
        
        # Build filters
        filters = {}
        if practice_area:
            filters["practice_area"] = practice_area
        if document_type:
            filters["document_type"] = document_type
        if jurisdiction_state:
            filters["jurisdiction_state"] = jurisdiction_state
        if start_date:
            filters["start_date"] = datetime.fromisoformat(start_date.replace('Z', '+00:00'))
        if end_date:
            filters["end_date"] = datetime.fromisoformat(end_date.replace('Z', '+00:00'))
        if validation_passed is not None:
            filters["validation_passed"] = validation_passed
        
        history = await service.get_email_validation_history(
            tenant_id=tenant_id,
            limit=limit,
            offset=offset,
            filters=filters if filters else None
        )
        
        return [EmailValidationHistoryResponse(**entry) for entry in history]
    
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to retrieve validation history: {str(e)}"
        )


@router.get("/validation-stats", response_model=EmailValidationStatsResponse)
async def get_email_validation_stats(
    tenant_id: UUID,
    start_date: Optional[str] = None,
    end_date: Optional[str] = None,
    db: Session = Depends(get_db),
    api_key_data: dict = Depends(require_tenant_access)
):
    """
    Get email attachment validation statistics for dashboard.
    
    Returns aggregated statistics:
    - Total validations
    - Pass/fail counts and rate
    - Average validation duration
    - Most common document types and practice areas
    
    **PRIVACY-PRESERVING:** Only aggregated statistics, no individual document data.
    """
    try:
        service = EmailAttachmentValidationService(db)
        
        # Parse dates
        parsed_start_date = None
        parsed_end_date = None
        if start_date:
            parsed_start_date = datetime.fromisoformat(start_date.replace('Z', '+00:00'))
        if end_date:
            parsed_end_date = datetime.fromisoformat(end_date.replace('Z', '+00:00'))
        
        stats = await service.get_email_validation_stats(
            tenant_id=tenant_id,
            start_date=parsed_start_date,
            end_date=parsed_end_date
        )
        
        return EmailValidationStatsResponse(**stats)
    
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to retrieve validation statistics: {str(e)}"
        )


@router.get("/health")
async def email_validation_health_check():
    """Health check endpoint for email validation service"""
    return {
        "status": "healthy",
        "service": "email_validation",
        "timestamp": datetime.utcnow().isoformat()
    }

