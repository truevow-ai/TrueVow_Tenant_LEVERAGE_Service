"""
TrueVow DRAFT™ Service - Validation Analytics Models v2.0

Zero-Knowledge Architecture:
- Stores validation METADATA only (NO DOCUMENT CONTENT)
- content_uploaded MUST ALWAYS BE FALSE
- Email subjects are hashed (SHA-256), never stored raw
- No client names, case details, or any PII/PHI

IMMUTABLE / APPEND-ONLY:
- ValidationAnalytics is a write-once audit log. It intentionally has NO
  updated_at, NO soft-delete, and NO deleted_by. Rows must never be updated
  or deleted. Do NOT extend this model with update/delete helpers.
"""

from datetime import datetime
from typing import List, Optional, Dict, Any
from uuid import UUID, uuid4

from sqlalchemy import (
    Boolean, Integer, String, Text, DateTime, BigInteger,
    CheckConstraint, Index
)
from sqlalchemy.dialects.postgresql import UUID as PG_UUID, ARRAY
from sqlalchemy.orm import Mapped, mapped_column
from sqlalchemy.sql import func

from app.core.database import Base


class ValidationAnalytics(Base):
    """
    Validation Analytics Model
    
    Stores validation metadata for analytics and compliance monitoring.
    
    ZERO-KNOWLEDGE COMPLIANCE:
    - NO document content stored
    - NO email body content  
    - NO client names or case details
    - Email subjects are SHA-256 hashed, never raw
    - content_uploaded MUST ALWAYS BE FALSE (enforced by constraint)
    
    Purpose:
    - Track validation usage
    - Monitor compliance trends
    - Identify common validation errors
    - Generate analytics dashboards
    - Audit validation history (metadata only)
    """
    
    __tablename__ = "validation_analytics"
    __table_args__ = (
        # Zero-knowledge enforcement
        CheckConstraint(
            "content_uploaded = FALSE",
            name="check_content_never_uploaded"
        ),
        CheckConstraint(
            "source_type IN ('browser_extension', 'desktop_app', 'word_addin', 'email_attachment', 'api')",
            name="check_source_type"
        ),
        
        # Indexes
        Index("idx_validation_analytics_tenant_id", "tenant_id"),
        Index("idx_validation_analytics_user_id", "user_id"),
        Index("idx_validation_analytics_document_type", "document_type"),
        Index("idx_validation_analytics_practice_area", "practice_area"),
        Index("idx_validation_analytics_validated_at", "validated_at"),
        Index("idx_validation_analytics_source_type", "source_type"),
        Index("idx_validation_analytics_validation_passed", "validation_passed"),
        Index("idx_validation_analytics_tenant_date", "tenant_id", "validated_at"),
        Index("idx_validation_analytics_tenant_document_type", "tenant_id", "document_type"),
        
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
    # TENANT SCOPING
    # ========================================================================
    
    tenant_id: Mapped[str] = mapped_column(
        String(255),
        nullable=False,
        comment="Clerk org ID e.g. org_2abc123. VARCHAR(255), never a UUID."
    )
    
    user_id: Mapped[Optional[UUID]] = mapped_column(
        PG_UUID(as_uuid=True), 
        nullable=True,
        comment="User (attorney) who performed the validation"
    )
    
    # ========================================================================
    # VALIDATION CONTEXT
    # ========================================================================
    
    practice_area: Mapped[Optional[str]] = mapped_column(
        String(100), 
        nullable=True
    )
    
    specialization: Mapped[Optional[str]] = mapped_column(
        String(100), 
        nullable=True
    )
    
    document_type: Mapped[str] = mapped_column(
        String(100), 
        nullable=False
    )
    
    jurisdiction_state: Mapped[Optional[str]] = mapped_column(
        String(2), 
        nullable=True
    )
    
    jurisdiction_county: Mapped[Optional[str]] = mapped_column(
        String(100), 
        nullable=True
    )
    
    # ========================================================================
    # VALIDATION SOURCE
    # ========================================================================
    
    source_type: Mapped[str] = mapped_column(
        String(50), 
        nullable=False,
        comment="browser_extension | desktop_app | word_addin | email_attachment | api"
    )
    
    # ========================================================================
    # VALIDATION RESULT (Metadata Only)
    # ========================================================================
    
    validation_passed: Mapped[bool] = mapped_column(
        Boolean, 
        nullable=False,
        comment="TRUE if validation passed, FALSE if errors found"
    )
    
    errors_count: Mapped[int] = mapped_column(
        Integer, 
        nullable=False, 
        default=0,
        comment="Number of validation errors"
    )
    
    warnings_count: Mapped[int] = mapped_column(
        Integer, 
        nullable=False, 
        default=0,
        comment="Number of validation warnings"
    )
    
    info_count: Mapped[int] = mapped_column(
        Integer, 
        nullable=False, 
        default=0,
        comment="Number of informational messages"
    )
    
    # ========================================================================
    # RULES USED
    # ========================================================================
    
    selected_rule_ids: Mapped[Optional[List[UUID]]] = mapped_column(
        ARRAY(PG_UUID(as_uuid=True)), 
        nullable=True,
        comment="IDs of rules that were selected for validation"
    )
    
    rules_checked: Mapped[int] = mapped_column(
        Integer, 
        nullable=False, 
        default=0,
        comment="Number of rules checked"
    )
    
    rules_passed: Mapped[int] = mapped_column(
        Integer, 
        nullable=False, 
        default=0,
        comment="Number of rules that passed"
    )
    
    rules_failed: Mapped[int] = mapped_column(
        Integer, 
        nullable=False, 
        default=0,
        comment="Number of rules that failed"
    )
    
    # ========================================================================
    # VALIDATION METADATA (NO CONTENT)
    # ========================================================================
    
    validation_duration_ms: Mapped[Optional[int]] = mapped_column(
        Integer, 
        nullable=True,
        comment="Validation duration in milliseconds"
    )
    
    document_size_bytes: Mapped[Optional[int]] = mapped_column(
        BigInteger, 
        nullable=True,
        comment="Document size in bytes (NOT document content)"
    )
    
    document_format: Mapped[Optional[str]] = mapped_column(
        String(50), 
        nullable=True,
        comment="Document format (e.g., 'docx', 'pdf')"
    )
    
    # ========================================================================
    # EMAIL-SPECIFIC METADATA (for email attachments)
    # ========================================================================
    
    email_message_id: Mapped[Optional[str]] = mapped_column(
        String(255), 
        nullable=True,
        comment="Email message ID (Gmail/Outlook ID)"
    )
    
    email_subject_hash: Mapped[Optional[str]] = mapped_column(
        String(64), 
        nullable=True,
        comment="SHA-256 hash of email subject (NEVER raw subject)"
    )
    
    attachment_filename: Mapped[Optional[str]] = mapped_column(
        String(255), 
        nullable=True,
        comment="Attachment filename (NO content)"
    )
    
    attachment_mime_type: Mapped[Optional[str]] = mapped_column(
        String(100), 
        nullable=True,
        comment="Attachment MIME type"
    )
    
    attachment_size_bytes: Mapped[Optional[int]] = mapped_column(
        BigInteger, 
        nullable=True,
        comment="Attachment size in bytes (NOT attachment content)"
    )
    
    # ========================================================================
    # CLIENT INFORMATION
    # ========================================================================
    
    client_type: Mapped[Optional[str]] = mapped_column(
        String(50), 
        nullable=True,
        comment="Client type (e.g., 'browser_extension', 'desktop_app')"
    )
    
    client_version: Mapped[Optional[str]] = mapped_column(
        String(20), 
        nullable=True,
        comment="Client version"
    )
    
    device_id: Mapped[Optional[str]] = mapped_column(
        String(255), 
        nullable=True,
        comment="Device identifier (hashed)"
    )
    
    session_id: Mapped[Optional[UUID]] = mapped_column(
        PG_UUID(as_uuid=True), 
        nullable=True,
        comment="Session identifier"
    )
    
    # ========================================================================
    # TIMESTAMPS
    # ========================================================================
    
    validated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), 
        nullable=False, 
        server_default=func.now(),
        comment="When the validation was performed"
    )
    
    # ========================================================================
    # ZERO-KNOWLEDGE COMPLIANCE FLAG
    # ========================================================================
    
    content_uploaded: Mapped[bool] = mapped_column(
        Boolean, 
        nullable=False, 
        default=False,
        comment="MUST ALWAYS BE FALSE - zero-knowledge architecture"
    )
    
    # ========================================================================
    # NOTES
    # ========================================================================
    
    notes: Mapped[Optional[str]] = mapped_column(
        Text, 
        nullable=True,
        comment="Additional notes (NO document content)"
    )
    
    # ========================================================================
    # METHODS
    # ========================================================================
    
    def __repr__(self) -> str:
        return (
            f"<ValidationAnalytics(id={self.id}, tenant_id={self.tenant_id}, "
            f"document_type={self.document_type}, passed={self.validation_passed})>"
        )
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary for API responses"""
        return {
            "id": str(self.id),
            "tenant_id": str(self.tenant_id),
            "user_id": str(self.user_id) if self.user_id else None,
            "practice_area": self.practice_area,
            "specialization": self.specialization,
            "document_type": self.document_type,
            "jurisdiction_state": self.jurisdiction_state,
            "jurisdiction_county": self.jurisdiction_county,
            "source_type": self.source_type,
            "validation_passed": self.validation_passed,
            "errors_count": self.errors_count,
            "warnings_count": self.warnings_count,
            "info_count": self.info_count,
            "selected_rule_ids": [str(rid) for rid in self.selected_rule_ids] if self.selected_rule_ids else [],
            "rules_checked": self.rules_checked,
            "rules_passed": self.rules_passed,
            "rules_failed": self.rules_failed,
            "validation_duration_ms": self.validation_duration_ms,
            "document_size_bytes": self.document_size_bytes,
            "document_format": self.document_format,
            "email_message_id": self.email_message_id,
            "email_subject_hash": self.email_subject_hash,
            "attachment_filename": self.attachment_filename,
            "attachment_mime_type": self.attachment_mime_type,
            "attachment_size_bytes": self.attachment_size_bytes,
            "client_type": self.client_type,
            "client_version": self.client_version,
            "device_id": self.device_id,
            "session_id": str(self.session_id) if self.session_id else None,
            "validated_at": self.validated_at.isoformat() if self.validated_at else None,
            "content_uploaded": self.content_uploaded,
            # notes intentionally excluded (may contain sensitive info)
        }
    
    @property
    def validation_pass_rate(self) -> float:
        """Calculate validation pass rate"""
        if self.rules_checked == 0:
            return 0.0
        return (self.rules_passed / self.rules_checked) * 100
    
    @property
    def is_email_validation(self) -> bool:
        """Check if this was an email attachment validation"""
        return self.source_type == 'email_attachment' and self.email_message_id is not None

