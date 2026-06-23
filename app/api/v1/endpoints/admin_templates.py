"""
Admin Template Management Endpoints
Handles CRUD operations for global validation rule templates
"""

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from sqlalchemy import func, and_
from typing import List, Optional
from uuid import UUID
import logging

from app.core.database import get_db
from app.core.auth_v2 import require_admin_access
from app.models.validation_rule_v2 import ValidationRule

logger = logging.getLogger(__name__)

router = APIRouter()


@router.get("/stats")
async def get_template_stats(
    db: Session = Depends(get_db),
    _: dict = Depends(require_admin_access)
):
    """
    Get template statistics for dashboard
    
    Returns:
        - total_templates: Total number of templates
        - active_templates: Number of active templates
        - practice_areas: Number of unique practice areas
        - total_rules: Total rules across all templates
        - most_inherited: Most popular template name
    """
    try:
        # Total templates
        total_templates = db.query(ValidationRule).filter(
            ValidationRule.is_template == True
        ).count()
        
        # Active templates
        active_templates = db.query(ValidationRule).filter(
            ValidationRule.is_template == True,
            ValidationRule.is_active == True
        ).count()
        
        # Unique practice areas
        practice_areas = db.query(
            func.count(func.distinct(ValidationRule.practice_area))
        ).filter(
            ValidationRule.is_template == True
        ).scalar() or 0
        
        # Total rules (templates are rules too)
        total_rules = total_templates
        
        # Most inherited template
        most_inherited_query = db.query(
            ValidationRule.template_name,
            func.count(ValidationRule.inherited_from_template_id).label('count')
        ).filter(
            ValidationRule.inherited_from_template_id.isnot(None)
        ).group_by(
            ValidationRule.template_name
        ).order_by(
            func.count(ValidationRule.inherited_from_template_id).desc()
        ).first()
        
        most_inherited = most_inherited_query[0] if most_inherited_query else "N/A"
        
        return {
            "total_templates": total_templates,
            "active_templates": active_templates,
            "practice_areas": practice_areas,
            "total_rules": total_rules,
            "most_inherited": most_inherited
        }
        
    except Exception as e:
        logger.error(f"Error getting template stats: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to get template stats: {str(e)}")


@router.get("")
async def list_templates(
    practice_area: Optional[str] = Query(None, description="Filter by practice area"),
    document_type: Optional[str] = Query(None, description="Filter by document type"),
    severity: Optional[str] = Query(None, description="Filter by severity"),
    is_active: Optional[bool] = Query(None, description="Filter by active status"),
    db: Session = Depends(get_db),
    _: dict = Depends(require_admin_access)
):
    """
    List all global templates with optional filters
    
    Query Parameters:
        - practice_area: Filter by practice area
        - document_type: Filter by document type
        - severity: Filter by severity (error, warning, info)
        - is_active: Filter by active status
    
    Returns:
        List of templates with inheritance counts
    """
    try:
        # Base query for templates
        query = db.query(ValidationRule).filter(
            ValidationRule.is_template == True
        )
        
        # Apply filters
        if practice_area:
            query = query.filter(ValidationRule.practice_area == practice_area)
        if document_type:
            query = query.filter(ValidationRule.document_type == document_type)
        if severity:
            query = query.filter(ValidationRule.severity == severity)
        if is_active is not None:
            query = query.filter(ValidationRule.is_active == is_active)
        
        # Get templates
        templates = query.order_by(ValidationRule.created_at.desc()).all()
        
        # Add inheritance count for each template
        result = []
        for template in templates:
            template_dict = {
                "id": str(template.id),
                "template_name": template.template_name,
                "template_description": template.template_description,
                "rule_name": template.rule_name,
                "practice_area": template.practice_area,
                "document_type": template.document_type,
                "jurisdiction_state": template.jurisdiction_state,
                "validator_level": template.validator_level,
                "validator_name": template.validator_name,
                "validator_type": template.validator_type,
                "validator_config": template.validator_config,
                "severity": template.severity,
                "is_active": template.is_active,
                "is_template": template.is_template,
                "created_at": template.created_at.isoformat() if template.created_at else None,
                "updated_at": template.updated_at.isoformat() if template.updated_at else None,
            }
            
            # Count how many tenants inherited this template
            inheritance_count = db.query(ValidationRule).filter(
                ValidationRule.inherited_from_template_id == template.id
            ).count()
            
            template_dict["inheritance_count"] = inheritance_count
            result.append(template_dict)
        
        return {"templates": result}
        
    except Exception as e:
        logger.error(f"Error listing templates: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to list templates: {str(e)}")


@router.post("")
async def create_template(
    template_data: dict,
    db: Session = Depends(get_db),
    admin: dict = Depends(require_admin_access)
):
    """
    Create a new global template
    
    Request Body:
        - template_name: Name of the template (required)
        - template_description: Description (optional)
        - rule_name: Name of the validation rule (required)
        - practice_area: Practice area (required)
        - document_type: Document type (required)
        - jurisdiction_state: State code (optional)
        - validator_level: Level 1-5 (required)
        - validator_name: Validator name (required)
        - validator_type: Type of validator (required)
        - validator_config: Configuration JSON (required)
        - severity: error/warning/info (required)
        - is_active: Active status (default: true)
    
    Returns:
        Created template object
    """
    try:
        # Validate required fields
        required_fields = [
            "template_name", "rule_name", "practice_area", "document_type",
            "validator_level", "validator_name", "validator_type", 
            "validator_config", "severity"
        ]
        
        for field in required_fields:
            if field not in template_data:
                raise HTTPException(
                    status_code=400,
                    detail=f"Missing required field: {field}"
                )
        
        # Create new template
        new_template = ValidationRule(
            template_name=template_data["template_name"],
            template_description=template_data.get("template_description"),
            rule_name=template_data["rule_name"],
            practice_area=template_data["practice_area"],
            document_type=template_data["document_type"],
            jurisdiction_state=template_data.get("jurisdiction_state"),
            jurisdiction_county=template_data.get("jurisdiction_county"),
            jurisdiction_court=template_data.get("jurisdiction_court"),
            validator_level=template_data["validator_level"],
            validator_name=template_data["validator_name"],
            validator_type=template_data["validator_type"],
            validator_config=template_data["validator_config"],
            severity=template_data["severity"],
            error_message=template_data.get("error_message"),
            warning_message=template_data.get("warning_message"),
            info_message=template_data.get("info_message"),
            is_active=template_data.get("is_active", True),
            is_required=template_data.get("is_required", True),
            is_enabled_for_validation=template_data.get("is_enabled_for_validation", True),
            is_template=True,  # This is a template
            tenant_id=None,  # Templates have no tenant
            created_by=admin.get("user_id"),
            notes=template_data.get("notes")
        )
        
        db.add(new_template)
        db.commit()
        db.refresh(new_template)
        
        logger.info(f"Created template: {new_template.template_name} (ID: {new_template.id})")
        
        return {
            "id": str(new_template.id),
            "template_name": new_template.template_name,
            "template_description": new_template.template_description,
            "rule_name": new_template.rule_name,
            "practice_area": new_template.practice_area,
            "document_type": new_template.document_type,
            "jurisdiction_state": new_template.jurisdiction_state,
            "validator_level": new_template.validator_level,
            "validator_name": new_template.validator_name,
            "validator_type": new_template.validator_type,
            "validator_config": new_template.validator_config,
            "severity": new_template.severity,
            "is_active": new_template.is_active,
            "created_at": new_template.created_at.isoformat() if new_template.created_at else None
        }
        
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        logger.error(f"Error creating template: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to create template: {str(e)}")


@router.put("/{template_id}")
async def update_template(
    template_id: str,
    template_data: dict,
    db: Session = Depends(get_db),
    admin: dict = Depends(require_admin_access)
):
    """
    Update an existing template
    
    Path Parameters:
        - template_id: UUID of the template
    
    Request Body:
        Any fields from the template that need updating
    
    Returns:
        Updated template object
    """
    try:
        # Find template
        template = db.query(ValidationRule).filter(
            ValidationRule.id == template_id,
            ValidationRule.is_template == True
        ).first()
        
        if not template:
            raise HTTPException(status_code=404, detail="Template not found")
        
        # Update fields
        updateable_fields = [
            "template_name", "template_description", "rule_name",
            "practice_area", "document_type", "jurisdiction_state",
            "jurisdiction_county", "jurisdiction_court",
            "validator_level", "validator_name", "validator_type",
            "validator_config", "severity", "error_message",
            "warning_message", "info_message", "is_active",
            "is_required", "is_enabled_for_validation", "notes"
        ]
        
        for field in updateable_fields:
            if field in template_data:
                setattr(template, field, template_data[field])
        
        db.commit()
        db.refresh(template)
        
        logger.info(f"Updated template: {template.template_name} (ID: {template.id})")
        
        return {
            "id": str(template.id),
            "template_name": template.template_name,
            "template_description": template.template_description,
            "rule_name": template.rule_name,
            "practice_area": template.practice_area,
            "document_type": template.document_type,
            "jurisdiction_state": template.jurisdiction_state,
            "validator_level": template.validator_level,
            "validator_name": template.validator_name,
            "validator_type": template.validator_type,
            "validator_config": template.validator_config,
            "severity": template.severity,
            "is_active": template.is_active,
            "updated_at": template.updated_at.isoformat() if template.updated_at else None
        }
        
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        logger.error(f"Error updating template: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to update template: {str(e)}")


@router.delete("/{template_id}")
async def delete_template(
    template_id: str,
    db: Session = Depends(get_db),
    admin: dict = Depends(require_admin_access)
):
    """
    Delete a template
    
    Path Parameters:
        - template_id: UUID of the template
    
    Returns:
        Success message
    
    Note:
        This will also affect any rules that inherited from this template
    """
    try:
        # Find template
        template = db.query(ValidationRule).filter(
            ValidationRule.id == template_id,
            ValidationRule.is_template == True
        ).first()
        
        if not template:
            raise HTTPException(status_code=404, detail="Template not found")
        
        # Check if any rules inherited from this template
        inherited_count = db.query(ValidationRule).filter(
            ValidationRule.inherited_from_template_id == template.id
        ).count()
        
        template_name = template.template_name
        
        # Delete template
        db.delete(template)
        db.commit()
        
        logger.info(f"Deleted template: {template_name} (ID: {template_id})")
        logger.info(f"Affected {inherited_count} inherited rules")
        
        return {
            "message": "Template deleted successfully",
            "template_name": template_name,
            "affected_rules": inherited_count
        }
        
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        logger.error(f"Error deleting template: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to delete template: {str(e)}")


@router.get("/{template_id}")
async def get_template(
    template_id: str,
    db: Session = Depends(get_db),
    _: dict = Depends(require_admin_access)
):
    """
    Get a specific template by ID
    
    Path Parameters:
        - template_id: UUID of the template
    
    Returns:
        Template object with inheritance details
    """
    try:
        template = db.query(ValidationRule).filter(
            ValidationRule.id == template_id,
            ValidationRule.is_template == True
        ).first()
        
        if not template:
            raise HTTPException(status_code=404, detail="Template not found")
        
        # Get inheritance count
        inheritance_count = db.query(ValidationRule).filter(
            ValidationRule.inherited_from_template_id == template.id
        ).count()
        
        return {
            "id": str(template.id),
            "template_name": template.template_name,
            "template_description": template.template_description,
            "rule_name": template.rule_name,
            "practice_area": template.practice_area,
            "document_type": template.document_type,
            "jurisdiction_state": template.jurisdiction_state,
            "jurisdiction_county": template.jurisdiction_county,
            "jurisdiction_court": template.jurisdiction_court,
            "validator_level": template.validator_level,
            "validator_name": template.validator_name,
            "validator_type": template.validator_type,
            "validator_config": template.validator_config,
            "severity": template.severity,
            "error_message": template.error_message,
            "warning_message": template.warning_message,
            "info_message": template.info_message,
            "is_active": template.is_active,
            "is_required": template.is_required,
            "is_enabled_for_validation": template.is_enabled_for_validation,
            "created_at": template.created_at.isoformat() if template.created_at else None,
            "updated_at": template.updated_at.isoformat() if template.updated_at else None,
            "inheritance_count": inheritance_count,
            "notes": template.notes
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting template: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to get template: {str(e)}")


