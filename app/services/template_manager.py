"""
TrueVow DRAFT™ Service - Template Manager Service
Business logic for managing legal document templates
"""

from datetime import datetime
from typing import Dict, List, Optional
from uuid import UUID

from sqlalchemy.orm import Session
from sqlalchemy import and_, or_

from app.models.template import Template
from app.core.config import get_settings

settings = get_settings()


class TemplateManagerService:
    """
    Service for managing legal document templates
    
    Features:
    - Create, read, update, delete templates
    - Filter templates by practice area, document type, jurisdiction
    - Track template usage statistics
    - Support public and tenant-specific templates
    
    Zero-Knowledge Architecture:
    - Templates contain NO client data (only merge field placeholders)
    - Templates are attorney's work product
    - Document assembly is ephemeral (never stored)
    """
    
    def __init__(self, db: Session):
        self.db = db
    
    def create_template(
        self,
        template_name: str,
        template_content: str,
        practice_area: str,
        document_type: str,
        merge_fields: List[Dict],
        template_description: Optional[str] = None,
        specialization: Optional[str] = None,
        jurisdiction_state: Optional[str] = None,
        jurisdiction_county: Optional[str] = None,
        template_format: str = "docx",
        validation_rule_ids: Optional[List[UUID]] = None,
        is_public: bool = False,
        tenant_id: Optional[UUID] = None,
        created_by: Optional[UUID] = None,
        notes: Optional[str] = None,
    ) -> Template:
        """
        Create new template
        
        Args:
            template_name: Template name
            template_content: Template content with merge fields (e.g., {{client_name}})
            practice_area: Practice area
            document_type: Document type
            merge_fields: List of merge field definitions
            template_description: Template description (optional)
            specialization: Specialization (optional)
            jurisdiction_state: State code (optional)
            jurisdiction_county: County name (optional)
            template_format: Template format (default: docx)
            validation_rule_ids: Applicable validation rule IDs (optional)
            is_public: Is public template (default: False)
            tenant_id: Tenant ID for private templates (optional)
            created_by: Creator user ID (optional)
            notes: Internal notes (optional)
            
        Returns:
            Created Template object
        """
        template = Template(
            template_name=template_name,
            template_content=template_content,
            template_description=template_description,
            practice_area=practice_area,
            specialization=specialization,
            document_type=document_type,
            jurisdiction_state=jurisdiction_state,
            jurisdiction_county=jurisdiction_county,
            template_format=template_format,
            merge_fields=merge_fields,
            validation_rule_ids=validation_rule_ids,
            is_public=is_public,
            tenant_id=tenant_id,
            created_by=created_by,
            notes=notes,
        )
        
        self.db.add(template)
        self.db.commit()
        self.db.refresh(template)
        
        return template
    
    def get_template_by_id(
        self,
        template_id: UUID,
        tenant_id: Optional[UUID] = None
    ) -> Optional[Template]:
        """
        Get template by ID
        
        Args:
            template_id: Template ID
            tenant_id: Tenant ID (for access control)
            
        Returns:
            Template or None if not found
        """
        query = self.db.query(Template).filter(
            Template.id == template_id,
            Template.is_active == True,  # noqa: E712
            Template.archived_at.is_(None),
            Template.deleted_at.is_(None),
        )
        
        # Access control: tenant can only access public templates or their own
        if tenant_id:
            query = query.filter(
                or_(
                    Template.is_public == True,  # noqa: E712
                    Template.tenant_id == tenant_id
                )
            )
        
        return query.first()
    
    def list_templates(
        self,
        tenant_id: Optional[UUID] = None,
        practice_area: Optional[str] = None,
        specialization: Optional[str] = None,
        document_type: Optional[str] = None,
        jurisdiction_state: Optional[str] = None,
        is_public: Optional[bool] = None,
        skip: int = 0,
        limit: int = 100,
    ) -> Dict:
        """
        List templates with filtering
        
        Args:
            tenant_id: Tenant ID (for access control)
            practice_area: Filter by practice area (optional)
            specialization: Filter by specialization (optional)
            document_type: Filter by document type (optional)
            jurisdiction_state: Filter by state (optional)
            is_public: Filter by public status (optional)
            skip: Pagination offset (default: 0)
            limit: Pagination limit (default: 100)
            
        Returns:
            Dict with templates and pagination info
        """
        query = self.db.query(Template).filter(
            Template.is_active == True,  # noqa: E712
            Template.archived_at.is_(None),
            Template.deleted_at.is_(None),
        )

        # Access control
        if tenant_id:
            query = query.filter(
                or_(
                    Template.is_public == True,  # noqa: E712
                    Template.tenant_id == tenant_id
                )
            )

        # Apply filters
        if practice_area:
            query = query.filter(Template.practice_area == practice_area)
        
        if specialization:
            query = query.filter(Template.specialization == specialization)
        
        if document_type:
            query = query.filter(Template.document_type == document_type)
        
        if jurisdiction_state:
            query = query.filter(Template.jurisdiction_state == jurisdiction_state)
        
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
    
    def update_template(
        self,
        template_id: UUID,
        tenant_id: Optional[UUID] = None,
        **updates
    ) -> Optional[Template]:
        """
        Update template
        
        Args:
            template_id: Template ID
            tenant_id: Tenant ID (for access control)
            **updates: Fields to update
            
        Returns:
            Updated Template or None if not found
        """
        template = self.get_template_by_id(template_id, tenant_id)
        
        if not template:
            return None
        
        # Update fields
        for key, value in updates.items():
            if hasattr(template, key) and value is not None:
                setattr(template, key, value)
        
        # Increment version
        template.version += 1
        
        self.db.commit()
        self.db.refresh(template)
        
        return template
    
    def archive_template(
        self,
        template_id: UUID,
        tenant_id: Optional[UUID] = None
    ) -> bool:
        """
        Archive template (soft delete)
        
        Args:
            template_id: Template ID
            tenant_id: Tenant ID (for access control)
            
        Returns:
            True if archived successfully, False otherwise
        """
        template = self.get_template_by_id(template_id, tenant_id)
        
        if not template:
            return False
        
        template.is_active = False
        template.archived_at = datetime.utcnow()
        
        self.db.commit()
        
        return True
    
    def increment_usage(self, template_id: UUID) -> None:
        """
        Increment template usage count
        
        Args:
            template_id: Template ID
        """
        template = self.db.query(Template).filter(
            Template.id == template_id
        ).first()
        
        if template:
            template.increment_usage()
            self.db.commit()
    
    def get_popular_templates(
        self,
        tenant_id: Optional[UUID] = None,
        practice_area: Optional[str] = None,
        limit: int = 10
    ) -> List[Template]:
        """
        Get most popular templates
        
        Args:
            tenant_id: Tenant ID (for access control)
            practice_area: Filter by practice area (optional)
            limit: Number of templates to return (default: 10)
            
        Returns:
            List of popular templates
        """
        query = self.db.query(Template).filter(
            Template.is_active == True,  # noqa: E712
            Template.archived_at.is_(None),
            Template.deleted_at.is_(None),
        )

        # Access control
        if tenant_id:
            query = query.filter(
                or_(
                    Template.is_public == True,  # noqa: E712
                    Template.tenant_id == tenant_id
                )
            )

        # Filter by practice area
        if practice_area:
            query = query.filter(Template.practice_area == practice_area)
        
        # Order by usage count
        templates = query.order_by(Template.usage_count.desc()).limit(limit).all()
        
        return templates

