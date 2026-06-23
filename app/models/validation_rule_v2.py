"""
TrueVow DRAFT™ Service - Validation Rules Models v2.0 (CORRECT ARCHITECTURE)

This version implements the correct architecture:
- Global Rule Templates (managed by SaaS Admin): is_template=TRUE, tenant_id=NULL
- Tenant-Specific Rules (managed by law firms): is_template=FALSE, tenant_id=UUID
- Template Inheritance: Tenants can inherit from global templates
- Rule Selection: Tenants select which rules to validate against

Zero-Knowledge Architecture:
- Rules contain NO document content
- Rules contain NO client data  
- Document validation happens client-side
- Only validation metadata is logged
"""

from datetime import datetime
from typing import List, Optional, Dict, Any
from uuid import UUID, uuid4

from sqlalchemy import (
    Boolean, Integer, String, Text, DateTime, CheckConstraint, Index, 
    ForeignKey, UniqueConstraint
)
from sqlalchemy.dialects.postgresql import UUID as PG_UUID, ARRAY, JSONB
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.sql import func

from app.core.database import Base


class ValidationRule(Base):
    """
    Validation Rule Model - Supports both Global Templates and Tenant-Specific Rules
    
    Architecture:
    1. Global Rule Templates (SaaS Admin):
       - is_template = TRUE
       - tenant_id = NULL
       - Available for inheritance by all tenants
       
    2. Tenant-Specific Rules (Law Firms):
       - is_template = FALSE  
       - tenant_id = UUID
       - Can inherit from global templates
       - Can be customized after inheritance
    
    Zero-Knowledge Compliance:
    - Rules define validation logic only
    - NO document content stored
    - NO client data stored
    """
    
    __tablename__ = "validation_rules"
    __table_args__ = (
        # Level constraints
        CheckConstraint(
            "validator_level BETWEEN 1 AND 5",
            name="check_validator_level"
        ),
        CheckConstraint(
            "severity IN ('error', 'warning', 'info')",
            name="check_severity"
        ),
        
        # Template business logic
        CheckConstraint(
            "(is_template = TRUE AND template_name IS NOT NULL) OR is_template = FALSE",
            name="check_template_has_template_name"
        ),
        CheckConstraint(
            "(is_template = TRUE AND tenant_id IS NULL) OR is_template = FALSE",
            name="check_template_has_no_tenant"
        ),
        CheckConstraint(
            "(is_template = FALSE AND tenant_id IS NOT NULL) OR is_template = TRUE",
            name="check_tenant_rule_has_tenant"
        ),
        
        # Indexes
        Index("idx_validation_rules_tenant_id", "tenant_id"),
        Index("idx_validation_rules_is_template", "is_template"),
        Index("idx_validation_rules_inherited_from", "inherited_from_template_id"),
        Index("idx_validation_rules_level", "validator_level"),
        Index("idx_validation_rules_practice_area", "practice_area"),
        Index("idx_validation_rules_specialization", "specialization"),
        Index("idx_validation_rules_document_type", "document_type"),
        Index("idx_validation_rules_jurisdiction_state", "jurisdiction_state"),
        Index("idx_validation_rules_active", "is_active"),
        Index("idx_validation_rules_enabled", "is_enabled_for_validation"),
        Index("idx_validation_rules_created_at", "created_at"),
        Index("idx_validation_rules_updated_at", "updated_at"),
        Index("idx_validation_rules_tenant_document_type", "tenant_id", "document_type"),
        Index("idx_validation_rules_template_practice_area", "is_template", "practice_area"),
        
        {"schema": "leverage", "extend_existing": True}
    )
    
    # ========================================================================
    # PRIMARY KEY
    # ========================================================================
    
    id: Mapped[UUID] = mapped_column(
        PG_UUID(as_uuid=True), 
        primary_key=True, 
        default=uuid4
    )
    
    # ========================================================================
    # TENANT SCOPING & TEMPLATE FLAGS
    # ========================================================================
    
    tenant_id: Mapped[Optional[str]] = mapped_column(
        String(255),
        nullable=True,
        comment="Clerk org ID e.g. org_2abc123 — VARCHAR(255), never a UUID. NULL = global template."
    )
    
    is_template: Mapped[bool] = mapped_column(
        Boolean, 
        nullable=False, 
        default=False,
        comment="TRUE = global template (SaaS Admin), FALSE = tenant rule"
    )
    
    # ========================================================================
    # TEMPLATE METADATA (for global templates only)
    # ========================================================================
    
    template_name: Mapped[Optional[str]] = mapped_column(
        String(200), 
        nullable=True,
        comment="Template name (required if is_template=TRUE)"
    )
    
    template_description: Mapped[Optional[str]] = mapped_column(
        Text, 
        nullable=True,
        comment="Template description"
    )
    
    # ========================================================================
    # RULE METADATA (for all rules)
    # ========================================================================
    
    rule_name: Mapped[str] = mapped_column(
        String(200), 
        nullable=False,
        comment="Rule name (user-facing)"
    )
    
    # ========================================================================
    # TEMPLATE INHERITANCE
    # ========================================================================
    
    inherited_from_template_id: Mapped[Optional[UUID]] = mapped_column(
        PG_UUID(as_uuid=True),
        ForeignKey("leverage.validation_rules.id", ondelete="SET NULL"),
        nullable=True,
        comment="If tenant rule was inherited from a global template, this is the template ID"
    )
    
    is_customized: Mapped[bool] = mapped_column(
        Boolean, 
        nullable=False, 
        default=False,
        comment="TRUE if inherited rule was customized after inheritance"
    )
    
    template_version: Mapped[Optional[int]] = mapped_column(
        Integer, 
        nullable=True,
        comment="Version of template at time of inheritance"
    )
    
    # ========================================================================
    # VALIDATOR HIERARCHY (5 Levels)
    # ========================================================================
    
    validator_level: Mapped[int] = mapped_column(
        Integer, 
        nullable=False,
        comment="1=Universal, 2=Practice Area, 3=Specialization, 4=Document Type, 5=Jurisdiction"
    )
    
    validator_name: Mapped[str] = mapped_column(
        String(100), 
        nullable=False,
        comment="Validator identifier (e.g., 'required_fields_validator')"
    )
    
    validator_type: Mapped[str] = mapped_column(
        String(50), 
        nullable=False,
        comment="Validator type (e.g., 'format', 'content', 'structure')"
    )
    
    # Level 2: Practice Area
    practice_area: Mapped[Optional[str]] = mapped_column(
        String(100), 
        nullable=True
    )
    
    # Level 3: Specialization
    specialization: Mapped[Optional[str]] = mapped_column(
        String(100), 
        nullable=True
    )
    
    # Level 4: Document Type
    document_type: Mapped[Optional[str]] = mapped_column(
        String(100), 
        nullable=True
    )
    
    # Level 5: Jurisdiction
    jurisdiction_state: Mapped[Optional[str]] = mapped_column(
        String(2), 
        nullable=True
    )
    
    jurisdiction_county: Mapped[Optional[str]] = mapped_column(
        String(100), 
        nullable=True
    )
    
    jurisdiction_court: Mapped[Optional[str]] = mapped_column(
        String(200), 
        nullable=True
    )
    
    # ========================================================================
    # VALIDATOR CONFIGURATION
    # ========================================================================
    
    validator_config: Mapped[dict] = mapped_column(
        JSONB, 
        nullable=False, 
        default=dict,
        comment="Validator configuration (JSON)"
    )
    
    # ========================================================================
    # VALIDATION MESSAGES
    # ========================================================================
    
    error_message: Mapped[Optional[str]] = mapped_column(
        Text, 
        nullable=True
    )
    
    warning_message: Mapped[Optional[str]] = mapped_column(
        Text, 
        nullable=True
    )
    
    info_message: Mapped[Optional[str]] = mapped_column(
        Text, 
        nullable=True
    )
    
    severity: Mapped[str] = mapped_column(
        String(20), 
        nullable=False, 
        default="error"
    )
    
    # ========================================================================
    # RULE STATUS
    # ========================================================================
    
    is_active: Mapped[bool] = mapped_column(
        Boolean, 
        nullable=False, 
        default=True,
        comment="TRUE if rule is active"
    )
    
    is_required: Mapped[bool] = mapped_column(
        Boolean, 
        nullable=False, 
        default=True,
        comment="TRUE if rule is required (cannot be disabled)"
    )
    
    is_enabled_for_validation: Mapped[bool] = mapped_column(
        Boolean, 
        nullable=False, 
        default=True,
        comment="TRUE if rule should be used when validating documents"
    )
    
    # ========================================================================
    # VERSIONING
    # ========================================================================
    
    version: Mapped[int] = mapped_column(
        Integer, 
        nullable=False, 
        default=1
    )
    
    # ========================================================================
    # RULE DEPENDENCIES
    # ========================================================================
    
    depends_on_rule_ids: Mapped[Optional[List[UUID]]] = mapped_column(
        ARRAY(PG_UUID(as_uuid=True)), 
        nullable=True
    )
    
    # ========================================================================
    # ADMINISTRATIVE
    # ========================================================================
    
    created_by: Mapped[Optional[UUID]] = mapped_column(
        PG_UUID(as_uuid=True), 
        nullable=True
    )
    
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), 
        nullable=False, 
        server_default=func.now()
    )

    # Workflow / verification status (see Protocol v3)
    review_status: Mapped[str] = mapped_column(
        String(50),
        nullable=False,
        default="draft",
        server_default="draft",
        comment="Workflow status for this rule (e.g., draft, needs_review, document_verified, ai_verified_pending_attorney, flagged_error)."
    )
    
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), 
        nullable=False, 
        server_default=func.now(), 
        onupdate=func.now()
    )
    
    archived_at: Mapped[Optional[datetime]] = mapped_column(
        DateTime(timezone=True),
        nullable=True
    )

    updated_by: Mapped[Optional[str]] = mapped_column(
        String(255),
        nullable=True,
        comment="Clerk user/org ID of last editor"
    )

    deleted_at: Mapped[Optional[datetime]] = mapped_column(
        DateTime(timezone=True),
        nullable=True,
        index=True,
        comment="Soft-delete timestamp. NULL = active record. All queries must filter WHERE deleted_at IS NULL."
    )

    deleted_by: Mapped[Optional[str]] = mapped_column(
        String(255),
        nullable=True,
        comment="Clerk user/org ID who deleted this record. Set by soft_delete(), NOT updated_by."
    )

    notes: Mapped[Optional[str]] = mapped_column(
        Text,
        nullable=True
    )

    # ========================================================================
    # RELATIONSHIPS
    # ========================================================================
    
    # Template inheritance relationship
    inherited_from_template: Mapped[Optional["ValidationRule"]] = relationship(
        "ValidationRule",
        remote_side=[id],
        backref="inherited_rules"
    )
    
    # ========================================================================
    # METHODS
    # ========================================================================
    
    def __repr__(self) -> str:
        if self.is_template:
            return f"<GlobalRuleTemplate(id={self.id}, name={self.template_name})>"
        else:
            return f"<TenantRule(id={self.id}, tenant_id={self.tenant_id}, name={self.rule_name})>"
    
    def to_dict(self, include_relationships: bool = False) -> Dict[str, Any]:
        """Convert to dictionary for API responses"""
        data = {
            "id": str(self.id),
            "tenant_id": str(self.tenant_id) if self.tenant_id else None,
            "is_template": self.is_template,
            "template_name": self.template_name,
            "template_description": self.template_description,
            "rule_name": self.rule_name,
            "inherited_from_template_id": str(self.inherited_from_template_id) if self.inherited_from_template_id else None,
            "is_customized": self.is_customized,
            "template_version": self.template_version,
            "validator_level": self.validator_level,
            "validator_name": self.validator_name,
            "validator_type": self.validator_type,
            "practice_area": self.practice_area,
            "specialization": self.specialization,
            "document_type": self.document_type,
            "jurisdiction_state": self.jurisdiction_state,
            "jurisdiction_county": self.jurisdiction_county,
            "jurisdiction_court": self.jurisdiction_court,
            "validator_config": self.validator_config,
            "error_message": self.error_message,
            "warning_message": self.warning_message,
            "info_message": self.info_message,
            "severity": self.severity,
            "is_active": self.is_active,
            "is_required": self.is_required,
            "is_enabled_for_validation": self.is_enabled_for_validation,
            "version": self.version,
            "depends_on_rule_ids": [str(rid) for rid in self.depends_on_rule_ids] if self.depends_on_rule_ids else [],
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "review_status": getattr(self, "review_status", None),
            "updated_at": self.updated_at.isoformat() if self.updated_at else None,
            "updated_by": self.updated_by,
            "archived_at": self.archived_at.isoformat() if self.archived_at else None,
            "deleted_at": self.deleted_at.isoformat() if self.deleted_at else None,
            "deleted_by": self.deleted_by,
        }
        
        if include_relationships and self.inherited_from_template:
            data["inherited_from_template"] = {
                "id": str(self.inherited_from_template.id),
                "template_name": self.inherited_from_template.template_name,
                "version": self.inherited_from_template.version,
            }
        
        return data
    
    def soft_delete(self, deleted_by: Optional[str] = None) -> None:
        """
        Soft-delete this record.
        Writes deleted_at + deleted_by. Does NOT touch updated_by.
        Caller must db.commit() after calling this.
        All queries must include: WHERE deleted_at IS NULL.
        """
        from datetime import timezone
        self.deleted_at = datetime.now(timezone.utc)
        self.deleted_by = deleted_by

    @classmethod
    def is_global_template(cls, rule) -> bool:
        """Check if this is a global template"""
        return rule.is_template and rule.tenant_id is None
    
    @classmethod
    def is_tenant_rule(cls, rule) -> bool:
        """Check if this is a tenant-specific rule"""
        return not rule.is_template and rule.tenant_id is not None
    
    @classmethod
    def is_inherited_rule(cls, rule) -> bool:
        """Check if this rule was inherited from a template"""
        return rule.inherited_from_template_id is not None


class APIKey(Base):
    """
    API Key Model
    
    Stores hashed API keys for authentication and authorization.
    Keys are hashed with bcrypt (NOT encrypted).
    
    Access Levels:
    - tenant: Tenant access (manage tenant-specific rules)
    - admin: SaaS Admin management (manage global templates)
    - external: Non-customers (pay-per-use)
    """
    
    __tablename__ = "api_keys"
    __table_args__ = (
        CheckConstraint(
            "access_level IN ('tenant', 'admin', 'external')",
            name="check_access_level"
        ),
        CheckConstraint(
            "(access_level = 'tenant' AND tenant_id IS NOT NULL) OR access_level != 'tenant'",
            name="check_tenant_key_has_tenant"
        ),
        CheckConstraint(
            "(access_level = 'admin' AND tenant_id IS NULL) OR access_level != 'admin'",
            name="check_admin_key_no_tenant"
        ),
        Index("idx_api_keys_tenant_id", "tenant_id"),
        Index("idx_api_keys_active", "is_active"),
        Index("idx_api_keys_access_level", "access_level"),
        Index("idx_api_keys_expires_at", "expires_at"),
        Index("idx_api_keys_key_prefix", "key_prefix"),
        {"schema": "leverage", "extend_existing": True}
    )
    
    # Primary Key
    id: Mapped[UUID] = mapped_column(PG_UUID(as_uuid=True), primary_key=True, default=uuid4)
    
    # API Key (hashed with bcrypt)
    key_hash: Mapped[str] = mapped_column(Text, nullable=False, unique=True)
    key_prefix: Mapped[str] = mapped_column(String(10), nullable=False)  # First 8 chars for identification
    
    # Access Level
    access_level: Mapped[str] = mapped_column(String(20), nullable=False)
    
    # Tenant Association (NULL for admin keys) -- Clerk org ID e.g. org_2abc123, VARCHAR(255)
    tenant_id: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)
    
    # Key Metadata
    description: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    
    # Status
    is_active: Mapped[bool] = mapped_column(Boolean, nullable=False, default=True)
    
    # Expiration
    expires_at: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True), nullable=True)
    
    # Usage Tracking
    last_used_at: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True), nullable=True)
    usage_count: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    
    # Rate Limiting
    rate_limit_per_minute: Mapped[int] = mapped_column(Integer, nullable=False, default=60)
    rate_limit_per_hour: Mapped[int] = mapped_column(Integer, nullable=False, default=1000)
    
    # Administrative
    created_by: Mapped[Optional[UUID]] = mapped_column(PG_UUID(as_uuid=True), nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, server_default=func.now()
    )
    revoked_at: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True), nullable=True)

    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, server_default=func.now(), onupdate=func.now()
    )
    updated_by: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)

    deleted_at: Mapped[Optional[datetime]] = mapped_column(
        DateTime(timezone=True), nullable=True, index=True,
        comment="Soft-delete timestamp. NULL = active. All queries must filter WHERE deleted_at IS NULL."
    )
    deleted_by: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)

    def soft_delete(self, deleted_by: Optional[str] = None) -> None:
        """Soft-delete this API key. Writes deleted_at + deleted_by, NOT updated_by."""
        from datetime import timezone
        self.deleted_at = datetime.now(timezone.utc)
        self.deleted_by = deleted_by

    def __repr__(self) -> str:
        return (
            f"<APIKey(id={self.id}, access_level={self.access_level}, "
            f"tenant_id={self.tenant_id})>"
        )
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary for API responses (exclude sensitive data)"""
        return {
            "id": str(self.id),
            "key_prefix": self.key_prefix,
            "access_level": self.access_level,
            "tenant_id": str(self.tenant_id) if self.tenant_id else None,
            "description": self.description,
            "is_active": self.is_active,
            "expires_at": self.expires_at.isoformat() if self.expires_at else None,
            "last_used_at": self.last_used_at.isoformat() if self.last_used_at else None,
            "usage_count": self.usage_count,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "updated_at": self.updated_at.isoformat() if self.updated_at else None,
            "deleted_at": self.deleted_at.isoformat() if self.deleted_at else None,
            # key_hash is intentionally excluded for security
        }

