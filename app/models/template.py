"""
TrueVow DRAFT™ Service - Template Models
Database models for legal document templates
"""

from datetime import datetime
from typing import List, Optional
from uuid import UUID, uuid4

from sqlalchemy import Boolean, Integer, String, Text, DateTime, JSON, Index
from sqlalchemy.dialects.postgresql import UUID as PG_UUID, ARRAY
from sqlalchemy.orm import Mapped, mapped_column
from sqlalchemy.sql import func

from app.core.database import Base


class Template(Base):
    """
    Template Model
    
    Stores legal document templates (attorney's work product).
    Used for optional document assembly (ephemeral processing only).
    
    Zero-Knowledge Architecture:
    - Templates contain NO client data (only merge field placeholders)
    - Templates are attorney's work product (NOT client documents)
    - Document assembly is ephemeral (processed in memory, never stored)
    
    Example Template Content:
    "This demand letter is submitted on behalf of {{client_name}} regarding 
    the incident that occurred on {{incident_date}} at {{incident_location}}..."
    """
    
    __tablename__ = "templates"
    __table_args__ = (
        Index("idx_templates_practice_area", "practice_area"),
        Index("idx_templates_specialization", "specialization"),
        Index("idx_templates_document_type", "document_type"),
        Index("idx_templates_jurisdiction_state", "jurisdiction_state"),
        Index("idx_templates_active", "is_active"),
        Index("idx_templates_public", "is_public"),
        Index("idx_templates_tenant_id", "tenant_id"),
        Index("idx_templates_created_at", "created_at"),
        {"schema": "leverage", "extend_existing": True}
    )
    
    # Primary Key
    id: Mapped[UUID] = mapped_column(PG_UUID(as_uuid=True), primary_key=True, default=uuid4)
    
    # Template Identification
    template_name: Mapped[str] = mapped_column(String(200), nullable=False)
    template_description: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    
    # Template Classification
    practice_area: Mapped[str] = mapped_column(String(100), nullable=False)
    specialization: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)
    document_type: Mapped[str] = mapped_column(String(100), nullable=False)
    jurisdiction_state: Mapped[Optional[str]] = mapped_column(String(2), nullable=True)
    jurisdiction_county: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)
    
    # Template Content (attorney's work product - NOT client data)
    template_content: Mapped[str] = mapped_column(Text, nullable=False)
    template_format: Mapped[str] = mapped_column(String(50), nullable=False, default="docx")
    
    # Merge Fields (placeholders in template)
    merge_fields: Mapped[list] = mapped_column(JSON, nullable=False, default=list)
    # Example: [{"field_name": "client_name", "field_type": "text", "required": true}]
    
    # Validation Rules (link to validation_rules table)
    validation_rule_ids: Mapped[Optional[List[UUID]]] = mapped_column(
        ARRAY(PG_UUID(as_uuid=True)), nullable=True
    )
    
    # Template Metadata
    version: Mapped[int] = mapped_column(Integer, nullable=False, default=1)
    is_active: Mapped[bool] = mapped_column(Boolean, nullable=False, default=True)
    is_public: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)
    
    # Ownership (optional - for tenant-specific templates) -- Clerk org ID e.g. org_2abc123
    tenant_id: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)
    
    # Usage Statistics (metadata only - no document content)
    usage_count: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    last_used_at: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True), nullable=True)
    
    # Administrative
    created_by: Mapped[Optional[UUID]] = mapped_column(PG_UUID(as_uuid=True), nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, server_default=func.now()
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, server_default=func.now(), onupdate=func.now()
    )
    archived_at: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True), nullable=True)

    updated_by: Mapped[Optional[str]] = mapped_column(
        String(255), nullable=True, comment="Clerk user/org ID of last editor"
    )

    deleted_at: Mapped[Optional[datetime]] = mapped_column(
        DateTime(timezone=True), nullable=True, index=True,
        comment="Soft-delete timestamp. NULL = active. All queries must filter WHERE deleted_at IS NULL."
    )

    deleted_by: Mapped[Optional[str]] = mapped_column(
        String(255), nullable=True,
        comment="Clerk user/org ID who deleted this record. Set by soft_delete(), NOT updated_by."
    )

    # Notes
    notes: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    
    def soft_delete(self, deleted_by: Optional[str] = None) -> None:
        """Soft-delete this template. Writes deleted_at + deleted_by, NOT updated_by."""
        from datetime import timezone
        self.deleted_at = datetime.now(timezone.utc)
        self.deleted_by = deleted_by

    def __repr__(self) -> str:
        return (
            f"<Template(id={self.id}, name={self.template_name}, "
            f"document_type={self.document_type})>"
        )
    
    def to_dict(self, include_content: bool = False) -> dict:
        """
        Convert to dictionary for API responses
        
        Args:
            include_content: Include template content (default: False for list views)
        """
        result = {
            "id": str(self.id),
            "template_name": self.template_name,
            "template_description": self.template_description,
            "practice_area": self.practice_area,
            "specialization": self.specialization,
            "document_type": self.document_type,
            "jurisdiction_state": self.jurisdiction_state,
            "jurisdiction_county": self.jurisdiction_county,
            "template_format": self.template_format,
            "merge_fields": self.merge_fields,
            "validation_rule_ids": [str(rid) for rid in self.validation_rule_ids] if self.validation_rule_ids else [],
            "version": self.version,
            "is_active": self.is_active,
            "is_public": self.is_public,
            "tenant_id": str(self.tenant_id) if self.tenant_id else None,
            "usage_count": self.usage_count,
            "last_used_at": self.last_used_at.isoformat() if self.last_used_at else None,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "updated_at": self.updated_at.isoformat() if self.updated_at else None,
            "updated_by": self.updated_by,
            "deleted_at": self.deleted_at.isoformat() if self.deleted_at else None,
            "deleted_by": self.deleted_by,
        }
        
        # Only include content if explicitly requested (for detail views)
        if include_content:
            result["template_content"] = self.template_content
        
        return result
    
    def increment_usage(self) -> None:
        """Increment usage count and update last_used_at"""
        self.usage_count += 1
        self.last_used_at = datetime.utcnow()

