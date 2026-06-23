"""
TrueVow DRAFT™ Service - Email Attachment Validation Service
Provides validation rules and analytics for email attachment validation
"""

from typing import Dict, Any, Optional, List
from datetime import datetime
from uuid import UUID
import hashlib

from sqlalchemy.orm import Session

from app.models.analytics_v2 import ValidationAnalytics
from app.models.validation_rule_v2 import ValidationRule
from app.services.validation_rules_sync import ValidationRulesSyncService


class EmailAttachmentValidationService:
    """
    Email Attachment Validation Service
    
    PURPOSE:
    - Provide validation rules for client-side email attachment validation
    - Log validation metadata (NO CONTENT)
    - Track email attachment validation analytics
    
    ZERO-KNOWLEDGE ARCHITECTURE:
    - NEVER processes document content server-side
    - ONLY provides encrypted validation rules for client-side validation
    - ONLY logs privacy-preserving metadata (no content, no PII/PHI)
    
    Usage:
    1. Client requests validation context (get_validation_context)
    2. Client downloads email attachment to browser memory
    3. Client runs validation engine locally (zero-knowledge)
    4. Client logs validation metadata only (log_email_attachment_validation)
    """
    
    def __init__(self, db: Session):
        self.db = db
        self.sync_service = ValidationRulesSyncService(db)
    
    async def get_validation_context(
        self,
        practice_area: str,
        specialization: Optional[str],
        document_type: str,
        jurisdiction_state: str,
        jurisdiction_county: Optional[str] = None,
        tenant_id: Optional[UUID] = None
    ) -> Dict[str, Any]:
        """
        Get validation rules for client-side email attachment validation.
        
        Returns encrypted validation rules (same as browser extension sync).
        
        Args:
            practice_area: Practice area (e.g., 'personal_injury')
            specialization: Specialization (e.g., 'car_accident')
            document_type: Document type (e.g., 'demand_letter')
            jurisdiction_state: State code (e.g., 'AZ')
            jurisdiction_county: County name (optional)
            tenant_id: Tenant UUID (optional, for tenant-specific rules)
        
        Returns:
            {
                "rules": [...encrypted rules...],
                "context": {
                    "practice_area": "...",
                    "specialization": "...",
                    "document_type": "...",
                    "jurisdiction_state": "...",
                    "jurisdiction_county": "..."
                },
                "encryption": {
                    "algorithm": "AES-256-GCM",
                    "key_version": 1
                }
            }
        """
        # Fetch validation rules using existing sync service
        rules = await self.sync_service.get_rules_for_sync(
            practice_area=practice_area,
            specialization=specialization,
            document_type=document_type,
            jurisdiction_state=jurisdiction_state,
            jurisdiction_county=jurisdiction_county,
            tenant_id=tenant_id
        )
        
        return {
            "rules": rules,
            "context": {
                "practice_area": practice_area,
                "specialization": specialization,
                "document_type": document_type,
                "jurisdiction_state": jurisdiction_state,
                "jurisdiction_county": jurisdiction_county
            },
            "encryption": {
                "algorithm": "AES-256-GCM",
                "key_version": 1
            },
            "source": "email_attachment"
        }
    
    async def log_email_attachment_validation(
        self,
        tenant_id: UUID,
        user_id: Optional[UUID],
        practice_area: str,
        document_type: str,
        jurisdiction_state: str,
        validation_passed: bool,
        validation_result: Dict[str, Any],
        email_metadata: Dict[str, Any],
        client_info: Optional[Dict[str, Any]] = None
    ) -> None:
        """
        Log email attachment validation metadata (NO CONTENT).
        
        PRIVACY-PRESERVING ANALYTICS:
        - NEVER logs document content
        - ONLY logs validation results (passed/failed, error counts)
        - Email subject is hashed (SHA-256) for privacy
        - NO PII/PHI data logged
        
        Args:
            tenant_id: Tenant UUID
            user_id: User UUID (optional)
            practice_area: Practice area
            document_type: Document type
            jurisdiction_state: Jurisdiction state
            validation_passed: Whether validation passed
            validation_result: Validation result summary (errors, warnings counts only)
            email_metadata: Email metadata (sender, date, subject) - subject will be hashed
            client_info: Client information (type, version) - optional
        
        Email Metadata:
            {
                "sender": "client@lawfirm.com",  # Email sender (for context)
                "date": "2025-12-08T10:00:00Z",   # Email date
                "subject": "RE: Demand Letter Draft"  # Will be hashed (SHA-256)
            }
        
        Validation Result:
            {
                "errors": ["error1", "error2"],  # Error messages only (no content)
                "warnings": ["warning1"],        # Warning messages only (no content)
                "rules_checked": 25,
                "rules_passed": 22,
                "rules_failed": 3,
                "duration_ms": 450
            }
        """
        # Hash email subject for privacy (never store raw subject)
        email_subject_hash = None
        if email_metadata.get("subject"):
            email_subject_hash = self._hash_email_subject(email_metadata["subject"])
        
        # Parse email date
        email_date = None
        if email_metadata.get("date"):
            try:
                if isinstance(email_metadata["date"], str):
                    email_date = datetime.fromisoformat(email_metadata["date"].replace('Z', '+00:00'))
                elif isinstance(email_metadata["date"], datetime):
                    email_date = email_metadata["date"]
            except Exception:
                pass  # Skip if date parsing fails
        
        # Extract failed rule IDs (if provided)
        failed_rule_ids = []
        if "failed_rule_ids" in validation_result:
            failed_rule_ids = [
                UUID(rule_id) if isinstance(rule_id, str) else rule_id
                for rule_id in validation_result["failed_rule_ids"]
            ]
        
        # Create analytics entry
        analytics_entry = ValidationAnalytics(
            event_type="email_attachment_validation",
            tenant_id=tenant_id,
            user_id=user_id,
            
            # Document classification (metadata only)
            practice_area=practice_area,
            specialization=validation_result.get("specialization"),
            document_type=document_type,
            jurisdiction_state=jurisdiction_state,
            jurisdiction_county=validation_result.get("jurisdiction_county"),
            
            # Validation results (aggregated - NO content)
            total_rules_checked=validation_result.get("rules_checked", 0),
            rules_passed=validation_result.get("rules_passed", 0),
            rules_failed=validation_result.get("rules_failed", 0),
            rules_warned=len(validation_result.get("warnings", [])),
            failed_rule_ids=failed_rule_ids if failed_rule_ids else None,
            
            # Validation performance
            validation_duration_ms=validation_result.get("duration_ms"),
            
            # Client information
            client_type=client_info.get("client_type", "customer_portal") if client_info else "customer_portal",
            client_version=client_info.get("client_version") if client_info else None,
            
            # Validation source (email attachment)
            source="email_attachment",
            
            # Email metadata (privacy-preserving)
            email_sender=email_metadata.get("sender"),
            email_date=email_date,
            email_subject_hash=email_subject_hash,
            
            # Compliance flags
            is_compliance_issue=(not validation_passed and validation_result.get("rules_failed", 0) > 0),
            
            # Event timestamp
            event_timestamp=datetime.utcnow()
        )
        
        self.db.add(analytics_entry)
        self.db.commit()
    
    async def get_email_validation_history(
        self,
        tenant_id: UUID,
        limit: int = 50,
        offset: int = 0,
        filters: Optional[Dict[str, Any]] = None
    ) -> List[Dict[str, Any]]:
        """
        Get email attachment validation history (metadata only, no content).
        
        Args:
            tenant_id: Tenant UUID
            limit: Maximum number of records to return
            offset: Number of records to skip
            filters: Optional filters (practice_area, document_type, date_range, etc.)
        
        Returns:
            List of validation history entries (metadata only)
        """
        query = self.db.query(ValidationAnalytics).filter(
            ValidationAnalytics.tenant_id == tenant_id,
            ValidationAnalytics.source == "email_attachment"
        )
        
        # Apply filters
        if filters:
            if "practice_area" in filters:
                query = query.filter(ValidationAnalytics.practice_area == filters["practice_area"])
            
            if "document_type" in filters:
                query = query.filter(ValidationAnalytics.document_type == filters["document_type"])
            
            if "jurisdiction_state" in filters:
                query = query.filter(ValidationAnalytics.jurisdiction_state == filters["jurisdiction_state"])
            
            if "start_date" in filters:
                query = query.filter(ValidationAnalytics.event_timestamp >= filters["start_date"])
            
            if "end_date" in filters:
                query = query.filter(ValidationAnalytics.event_timestamp <= filters["end_date"])
            
            if "validation_passed" in filters:
                if filters["validation_passed"]:
                    query = query.filter(ValidationAnalytics.rules_failed == 0)
                else:
                    query = query.filter(ValidationAnalytics.rules_failed > 0)
        
        # Order by most recent first
        query = query.order_by(ValidationAnalytics.event_timestamp.desc())
        
        # Apply pagination
        query = query.limit(limit).offset(offset)
        
        # Execute query and convert to dict
        history = query.all()
        return [entry.to_dict() for entry in history]
    
    async def get_email_validation_stats(
        self,
        tenant_id: UUID,
        start_date: Optional[datetime] = None,
        end_date: Optional[datetime] = None
    ) -> Dict[str, Any]:
        """
        Get email attachment validation statistics for dashboard.
        
        Args:
            tenant_id: Tenant UUID
            start_date: Start date for stats (optional)
            end_date: End date for stats (optional)
        
        Returns:
            {
                "total_validations": 150,
                "passed": 120,
                "failed": 30,
                "pass_rate": 0.80,
                "avg_duration_ms": 450,
                "most_common_document_type": "demand_letter",
                "most_common_practice_area": "personal_injury",
                "validations_by_day": [...]
            }
        """
        query = self.db.query(ValidationAnalytics).filter(
            ValidationAnalytics.tenant_id == tenant_id,
            ValidationAnalytics.source == "email_attachment"
        )
        
        # Apply date filters
        if start_date:
            query = query.filter(ValidationAnalytics.event_timestamp >= start_date)
        if end_date:
            query = query.filter(ValidationAnalytics.event_timestamp <= end_date)
        
        all_validations = query.all()
        
        if not all_validations:
            return {
                "total_validations": 0,
                "passed": 0,
                "failed": 0,
                "pass_rate": 0.0,
                "avg_duration_ms": 0,
            }
        
        # Calculate stats
        total = len(all_validations)
        passed = sum(1 for v in all_validations if v.rules_failed == 0)
        failed = total - passed
        pass_rate = passed / total if total > 0 else 0.0
        
        # Average duration
        durations = [v.validation_duration_ms for v in all_validations if v.validation_duration_ms]
        avg_duration_ms = sum(durations) / len(durations) if durations else 0
        
        # Most common document type
        doc_types = [v.document_type for v in all_validations if v.document_type]
        most_common_doc = max(set(doc_types), key=doc_types.count) if doc_types else None
        
        # Most common practice area
        practice_areas = [v.practice_area for v in all_validations if v.practice_area]
        most_common_pa = max(set(practice_areas), key=practice_areas.count) if practice_areas else None
        
        return {
            "total_validations": total,
            "passed": passed,
            "failed": failed,
            "pass_rate": round(pass_rate, 2),
            "avg_duration_ms": round(avg_duration_ms),
            "most_common_document_type": most_common_doc,
            "most_common_practice_area": most_common_pa,
        }
    
    @staticmethod
    def _hash_email_subject(subject: str) -> str:
        """
        Hash email subject for privacy (SHA-256).
        
        Args:
            subject: Raw email subject
        
        Returns:
            SHA-256 hash (first 32 characters)
        """
        return hashlib.sha256(subject.encode('utf-8')).hexdigest()[:32]

