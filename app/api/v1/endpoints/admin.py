"""
TrueVow DRAFT™ Service - Admin API Endpoints
Endpoints for SaaS Admin to manage validation rules and templates
"""

from typing import Optional
from uuid import UUID
from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.auth import require_admin_access
from app.models.validation_rule_v2 import ValidationRule
from app.models.template import Template
from app.services.compliance import ComplianceService
from app.services.analytics import AnalyticsService

router = APIRouter(prefix="/admin", tags=["Admin"])


# ============================================================================
# PYDANTIC SCHEMAS - VALIDATION RULES
# ============================================================================

class CreateValidationRuleRequest(BaseModel):
    """Request schema for creating validation rule"""
    validator_level: int = Field(..., ge=1, le=5, description="Validator level (1-5)")
    validator_name: str = Field(..., max_length=100, description="Validator name")
    practice_area: Optional[str] = Field(None, max_length=100, description="Practice area")
    specialization: Optional[str] = Field(None, max_length=100, description="Specialization")
    document_type: Optional[str] = Field(None, max_length=100, description="Document type")
    jurisdiction_state: Optional[str] = Field(None, max_length=2, description="State code")
    jurisdiction_county: Optional[str] = Field(None, max_length=100, description="County name")
    jurisdiction_court: Optional[str] = Field(None, max_length=200, description="Court name/type")
    validator_config: dict = Field(default_factory=dict, description="Validator configuration")
    error_message: Optional[str] = Field(None, description="Error message")
    warning_message: Optional[str] = Field(None, description="Warning message")
    info_message: Optional[str] = Field(None, description="Info message")
    severity: str = Field("error", description="Severity (error/warning/info)")
    is_required: bool = Field(True, description="Is required validator")
    notes: Optional[str] = Field(None, description="Internal notes")


class UpdateValidationRuleRequest(BaseModel):
    """Request schema for updating validation rule"""
    validator_config: Optional[dict] = None
    error_message: Optional[str] = None
    warning_message: Optional[str] = None
    info_message: Optional[str] = None
    severity: Optional[str] = None
    is_active: Optional[bool] = None
    is_required: Optional[bool] = None
    notes: Optional[str] = None


# ============================================================================
# PYDANTIC SCHEMAS - TEMPLATES
# ============================================================================

class CreateTemplateRequest(BaseModel):
    """Request schema for creating template"""
    template_name: str = Field(..., max_length=200, description="Template name")
    template_content: str = Field(..., description="Template content with merge fields")
    practice_area: str = Field(..., max_length=100, description="Practice area")
    document_type: str = Field(..., max_length=100, description="Document type")
    merge_fields: list = Field(..., description="Merge field definitions")
    template_description: Optional[str] = Field(None, description="Template description")
    specialization: Optional[str] = Field(None, max_length=100, description="Specialization")
    jurisdiction_state: Optional[str] = Field(None, max_length=2, description="State code")
    jurisdiction_county: Optional[str] = Field(None, max_length=100, description="County name")
    template_format: str = Field("docx", description="Template format")
    is_public: bool = Field(False, description="Is public template")
    notes: Optional[str] = Field(None, description="Internal notes")


# ============================================================================
# VALIDATION RULES MANAGEMENT ENDPOINTS
# ============================================================================

@router.post(
    "/validation-rules",
    summary="Create validation rule",
    description="Create a new validation rule (SaaS Admin only)"
)
async def create_validation_rule(
    request: CreateValidationRuleRequest,
    api_key_data: dict = Depends(require_admin_access),
    db: Session = Depends(get_db)
):
    """Create new validation rule"""
    try:
        rule = ValidationRule(
            validator_level=request.validator_level,
            validator_name=request.validator_name,
            practice_area=request.practice_area,
            specialization=request.specialization,
            document_type=request.document_type,
            jurisdiction_state=request.jurisdiction_state,
            jurisdiction_county=request.jurisdiction_county,
            jurisdiction_court=request.jurisdiction_court,
            validator_config=request.validator_config,
            error_message=request.error_message,
            warning_message=request.warning_message,
            info_message=request.info_message,
            severity=request.severity,
            is_required=request.is_required,
            created_by=api_key_data.get("api_key_id"),
            notes=request.notes,
        )
        
        db.add(rule)
        db.commit()
        db.refresh(rule)
        
        return rule.to_dict()
        
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to create validation rule: {str(e)}"
        )


@router.get(
    "/validation-rules",
    summary="List all validation rules",
    description="List all validation rules with filtering (SaaS Admin only)"
)
async def list_validation_rules(
    practice_area: Optional[str] = None,
    validator_level: Optional[int] = None,
    is_active: Optional[bool] = None,
    skip: int = 0,
    limit: int = 100,
    api_key_data: dict = Depends(require_admin_access),
    db: Session = Depends(get_db)
):
    """List all validation rules"""
    query = db.query(ValidationRule)
    
    # Apply filters
    if practice_area:
        query = query.filter(ValidationRule.practice_area == practice_area)
    
    if validator_level:
        query = query.filter(ValidationRule.validator_level == validator_level)
    
    if is_active is not None:
        query = query.filter(ValidationRule.is_active == is_active)
    
    # Get total count
    total_count = query.count()
    
    # Apply pagination
    rules = query.order_by(ValidationRule.created_at.desc()).offset(skip).limit(limit).all()
    
    return {
        "rules": [rule.to_dict() for rule in rules],
        "total_count": total_count,
        "skip": skip,
        "limit": limit,
        "has_more": (skip + limit) < total_count,
    }


@router.put(
    "/validation-rules/{rule_id}",
    summary="Update validation rule",
    description="Update existing validation rule (SaaS Admin only)"
)
async def update_validation_rule(
    rule_id: UUID,
    request: UpdateValidationRuleRequest,
    api_key_data: dict = Depends(require_admin_access),
    db: Session = Depends(get_db)
):
    """Update validation rule"""
    rule = db.query(ValidationRule).filter(ValidationRule.id == rule_id).first()
    
    if not rule:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Validation rule {rule_id} not found"
        )
    
    # Update fields
    update_data = request.dict(exclude_unset=True)
    for field, value in update_data.items():
        setattr(rule, field, value)
    
    # Increment version
    rule.version += 1
    
    db.commit()
    db.refresh(rule)
    
    return rule.to_dict()


@router.delete(
    "/validation-rules/{rule_id}",
    summary="Archive validation rule",
    description="Archive (soft delete) validation rule (SaaS Admin only)"
)
async def archive_validation_rule(
    rule_id: UUID,
    api_key_data: dict = Depends(require_admin_access),
    db: Session = Depends(get_db)
):
    """Archive validation rule"""
    rule = db.query(ValidationRule).filter(ValidationRule.id == rule_id).first()
    
    if not rule:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Validation rule {rule_id} not found"
        )
    
    rule.is_active = False
    rule.archived_at = datetime.utcnow()
    
    db.commit()
    
    return {"message": "Validation rule archived successfully", "rule_id": str(rule_id)}


# ============================================================================
# TEMPLATES MANAGEMENT ENDPOINTS
# ============================================================================

@router.post(
    "/templates",
    summary="Create template",
    description="Create a new legal document template (SaaS Admin only)"
)
async def create_template(
    request: CreateTemplateRequest,
    api_key_data: dict = Depends(require_admin_access),
    db: Session = Depends(get_db)
):
    """Create new template"""
    try:
        template = Template(
            template_name=request.template_name,
            template_content=request.template_content,
            template_description=request.template_description,
            practice_area=request.practice_area,
            specialization=request.specialization,
            document_type=request.document_type,
            jurisdiction_state=request.jurisdiction_state,
            jurisdiction_county=request.jurisdiction_county,
            template_format=request.template_format,
            merge_fields=request.merge_fields,
            is_public=request.is_public,
            created_by=api_key_data.get("api_key_id"),
            notes=request.notes,
        )
        
        db.add(template)
        db.commit()
        db.refresh(template)
        
        return template.to_dict(include_content=True)
        
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to create template: {str(e)}"
        )


@router.get(
    "/templates",
    summary="List all templates",
    description="List all templates with filtering (SaaS Admin only)"
)
async def list_templates(
    practice_area: Optional[str] = None,
    document_type: Optional[str] = None,
    is_public: Optional[bool] = None,
    skip: int = 0,
    limit: int = 100,
    api_key_data: dict = Depends(require_admin_access),
    db: Session = Depends(get_db)
):
    """List all templates"""
    query = db.query(Template).filter(
        Template.is_active == True,  # noqa: E712
        Template.archived_at.is_(None)
    )
    
    # Apply filters
    if practice_area:
        query = query.filter(Template.practice_area == practice_area)
    
    if document_type:
        query = query.filter(Template.document_type == document_type)
    
    if is_public is not None:
        query = query.filter(Template.is_public == is_public)
    
    # Get total count
    total_count = query.count()
    
    # Apply pagination
    templates = query.order_by(Template.created_at.desc()).offset(skip).limit(limit).all()
    
    return {
        "templates": [template.to_dict(include_content=False) for template in templates],
        "total_count": total_count,
        "skip": skip,
        "limit": limit,
        "has_more": (skip + limit) < total_count,
    }


# ============================================================================
# COMPLIANCE & ANALYTICS ENDPOINTS
# ============================================================================

@router.get(
    "/compliance/report",
    summary="Generate compliance report",
    description="Generate comprehensive compliance report (SaaS Admin only)"
)
async def get_compliance_report(
    tenant_id: Optional[UUID] = None,
    api_key_data: dict = Depends(require_admin_access),
    db: Session = Depends(get_db)
):
    """Generate compliance report"""
    service = ComplianceService(db)
    
    try:
        report = service.generate_compliance_report(tenant_id=tenant_id)
        return report
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to generate compliance report: {str(e)}"
        )


@router.get(
    "/compliance/aba-status",
    summary="Get ABA compliance status",
    description="Get ABA Model Rules compliance status (SaaS Admin only)"
)
async def get_aba_compliance_status(
    tenant_id: Optional[UUID] = None,
    api_key_data: dict = Depends(require_admin_access),
    db: Session = Depends(get_db)
):
    """Get ABA compliance status"""
    service = ComplianceService(db)
    
    try:
        status_data = service.get_aba_compliance_status(tenant_id=tenant_id)
        return status_data
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get ABA compliance status: {str(e)}"
        )


@router.get(
    "/analytics/validation-usage",
    summary="Get validation usage analytics",
    description="Get validation usage statistics (SaaS Admin only)"
)
async def get_validation_usage(
    tenant_id: Optional[UUID] = None,
    api_key_data: dict = Depends(require_admin_access),
    db: Session = Depends(get_db)
):
    """Get validation usage analytics"""
    service = AnalyticsService(db)
    
    try:
        stats = service.get_validation_usage_stats(tenant_id=tenant_id)
        return stats
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get validation usage analytics: {str(e)}"
        )

