"""
TrueVow DRAFT™ Service - Validation Rules Sync Service
Business logic for syncing validation rules to client devices
"""

import json
import logging
from datetime import datetime
from typing import Dict, List, Optional
from uuid import UUID

from sqlalchemy.orm import Session
from sqlalchemy import and_

from app.models.validation_rule_v2 import ValidationRule
from app.models.analytics_v2 import ValidationAnalytics
from app.core.auth import encrypt_validation_rules
from app.core.config import get_settings

logger = logging.getLogger(__name__)

settings = get_settings()

# Protocol v3 gate: review_status values that are allowed to be synced to clients.
# 'draft' and 'flagged_error' are NEVER synced.
SYNC_ALLOWED_STATUSES = (
    "document_verified",
    "ai_verified_pending_attorney",
    "needs_review",
    "web_verified",
)


class ValidationRulesSyncService:
    """
    Service for syncing validation rules to client devices
    
    Features:
    - Filter rules by practice area, specialization, document type, jurisdiction
    - Encrypt rules before sending to client
    - Track sync operations in sync_log
    - Support incremental sync (only changed rules)
    - Version control for conflict resolution
    """
    
    def __init__(self, db: Session):
        self.db = db
    
    def get_validation_rules(
        self,
        tenant_id: UUID,
        practice_area: Optional[str] = None,
        specialization: Optional[str] = None,
        document_type: Optional[str] = None,
        jurisdiction_state: Optional[str] = None,
        jurisdiction_county: Optional[str] = None,
        include_universal: bool = True,
        user_id: Optional[UUID] = None,
        client_type: Optional[str] = None,
        client_version: Optional[str] = None,
        device_id: Optional[str] = None,
        session_id: Optional[UUID] = None,
    ) -> Dict:
        """
        Get validation rules filtered by criteria
        
        Args:
            tenant_id: Tenant ID requesting sync
            practice_area: Filter by practice area (optional)
            specialization: Filter by specialization (optional)
            document_type: Filter by document type (optional)
            jurisdiction_state: Filter by state (optional)
            jurisdiction_county: Filter by county (optional)
            include_universal: Include Level 1 universal validators (default: True)
            user_id: User ID requesting sync (optional)
            client_type: Client type (browser_extension, desktop_app, word_addin)
            client_version: Client version
            device_id: Device identifier
            session_id: Session ID
            
        Returns:
            Dict with validation rules and metadata
        """
        start_time = datetime.utcnow()
        
        # Build query
        # Protocol v3 gate: only sync rules that have passed verification.
        # 'draft' and 'flagged_error' are never sent to clients.
        # See module-level SYNC_ALLOWED_STATUSES for the full list.
        query = self.db.query(ValidationRule).filter(
            ValidationRule.is_active == True,  # noqa: E712
            ValidationRule.archived_at.is_(None),
            ValidationRule.deleted_at.is_(None),
            ValidationRule.review_status.in_(SYNC_ALLOWED_STATUSES),
        )
        
        # Collect all matching rules
        rules = []
        
        # Level 1: Universal validators (always included if enabled)
        if include_universal:
            universal_rules = query.filter(
                ValidationRule.validator_level == 1
            ).all()
            rules.extend(universal_rules)
        
        # Level 2: Practice area validators
        if practice_area:
            practice_area_rules = query.filter(
                ValidationRule.validator_level == 2,
                ValidationRule.practice_area == practice_area
            ).all()
            rules.extend(practice_area_rules)
        
        # Level 3: Specialization validators
        if specialization and practice_area:
            specialization_rules = query.filter(
                ValidationRule.validator_level == 3,
                ValidationRule.practice_area == practice_area,
                ValidationRule.specialization == specialization
            ).all()
            rules.extend(specialization_rules)
        
        # Level 4: Document type validators
        if document_type:
            document_type_rules = query.filter(
                ValidationRule.validator_level == 4,
                ValidationRule.document_type == document_type
            ).all()
            rules.extend(document_type_rules)
        
        # Level 5: Jurisdiction validators
        if jurisdiction_state:
            jurisdiction_filters = [
                ValidationRule.validator_level == 5,
                ValidationRule.jurisdiction_state == jurisdiction_state
            ]
            
            if jurisdiction_county:
                jurisdiction_filters.append(
                    ValidationRule.jurisdiction_county == jurisdiction_county
                )
            
            jurisdiction_rules = query.filter(
                and_(*jurisdiction_filters)
            ).all()
            rules.extend(jurisdiction_rules)
        
        # Remove duplicates (same rule might match multiple levels)
        unique_rules = list({rule.id: rule for rule in rules}.values())
        
        # Convert to dict
        rules_data = [rule.to_dict() for rule in unique_rules]
        
        # Get current version (max version of all rules)
        current_version = max([rule.version for rule in unique_rules]) if unique_rules else 1
        
        # Prepare response
        response = {
            "validation_rules": rules_data,
            "rules_count": len(rules_data),
            "rules_version": current_version,
            "sync_timestamp": datetime.utcnow().isoformat(),
            "encrypted": True,
            "filters_applied": {
                "practice_area": practice_area,
                "specialization": specialization,
                "document_type": document_type,
                "jurisdiction_state": jurisdiction_state,
                "jurisdiction_county": jurisdiction_county,
                "include_universal": include_universal,
            }
        }
        
        # Calculate sync duration
        end_time = datetime.utcnow()
        sync_duration_ms = int((end_time - start_time).total_seconds() * 1000)
        
        # Encrypt rules data
        rules_json = json.dumps(rules_data)
        encrypted_data = encrypt_validation_rules(rules_json)
        data_size_bytes = len(encrypted_data.encode('utf-8'))
        
        # Update response with encrypted data
        response["encrypted_rules"] = encrypted_data
        
        # Log sync operation (non-blocking — don't crash if logging fails)
        try:
            sync_log = ValidationAnalytics(
                tenant_id=str(tenant_id),
                validation_passed=True,
                practice_area=practice_area or "unknown",
                document_type=document_type or "sync",
                source_type="api",
                jurisdiction_state=jurisdiction_state or "",
                validated_at=datetime.utcnow(),
                rules_checked=len(rules_data),
            )
            self.db.add(sync_log)
            self.db.commit()
            
            # Add sync metadata to response
            response["sync_metadata"] = {
                "sync_id": str(sync_log.id),
                "sync_duration_ms": sync_duration_ms,
                "data_size_bytes": data_size_bytes,
            }
        except Exception as log_err:
            logger.warning(f"Sync logging failed: {log_err}. Proceeding without log.")
            self.db.rollback()
            response["sync_metadata"] = {
                "sync_id": None,
                "sync_duration_ms": sync_duration_ms,
                "data_size_bytes": data_size_bytes,
            }
        
        return response
    
    def get_rule_by_id(self, rule_id: UUID) -> Optional[ValidationRule]:
        """
        Get validation rule by ID
        
        Args:
            rule_id: Rule ID
            
        Returns:
            ValidationRule or None if not found
        """
        return self.db.query(ValidationRule).filter(
            ValidationRule.id == rule_id,
            ValidationRule.is_active == True,  # noqa: E712
            ValidationRule.archived_at.is_(None),
            ValidationRule.deleted_at.is_(None),
            ValidationRule.review_status.in_(SYNC_ALLOWED_STATUSES),
        ).first()
    
    def get_rules_by_ids(self, rule_ids: List[UUID]) -> List[ValidationRule]:
        """
        Get validation rules by IDs
        
        Args:
            rule_ids: List of rule IDs
            
        Returns:
            List of ValidationRule objects
        """
        return self.db.query(ValidationRule).filter(
            ValidationRule.id.in_(rule_ids),
            ValidationRule.is_active == True,  # noqa: E712
            ValidationRule.archived_at.is_(None),
            ValidationRule.deleted_at.is_(None),
            ValidationRule.review_status.in_(SYNC_ALLOWED_STATUSES),
        ).all()
    
    def check_for_updates(
        self,
        tenant_id: UUID,
        current_version: int,
        practice_area: Optional[str] = None,
        specialization: Optional[str] = None,
        document_type: Optional[str] = None,
        jurisdiction_state: Optional[str] = None,
    ) -> Dict:
        """
        Check if there are rule updates since client's current version
        
        Args:
            tenant_id: Tenant ID
            current_version: Client's current rules version
            practice_area: Filter by practice area (optional)
            specialization: Filter by specialization (optional)
            document_type: Filter by document type (optional)
            jurisdiction_state: Filter by state (optional)
            
        Returns:
            Dict with update availability and new rules
        """
        # Query for rules with version > current_version
        query = self.db.query(ValidationRule).filter(
            ValidationRule.is_active == True,  # noqa: E712
            ValidationRule.archived_at.is_(None),
            ValidationRule.deleted_at.is_(None),
            ValidationRule.review_status.in_(SYNC_ALLOWED_STATUSES),
            ValidationRule.version > current_version
        )
        
        # Apply filters if provided
        if practice_area:
            query = query.filter(
                (ValidationRule.practice_area == practice_area) |
                (ValidationRule.validator_level == 1)  # Include universal
            )
        
        if specialization:
            query = query.filter(
                (ValidationRule.specialization == specialization) |
                (ValidationRule.validator_level <= 2)  # Include universal and practice area
            )
        
        updated_rules = query.all()
        
        # Get latest version
        latest_version = self.db.query(ValidationRule).order_by(
            ValidationRule.version.desc()
        ).first()
        
        latest_version_number = latest_version.version if latest_version else 1
        
        return {
            "updates_available": len(updated_rules) > 0,
            "current_version": current_version,
            "latest_version": latest_version_number,
            "updated_rules_count": len(updated_rules),
            "updated_rules": [rule.to_dict() for rule in updated_rules] if updated_rules else [],
        }

