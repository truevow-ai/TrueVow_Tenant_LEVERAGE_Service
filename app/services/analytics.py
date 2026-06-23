"""
TrueVow DRAFT™ Service - Analytics Service
Business logic for validation analytics and usage tracking
"""

from datetime import datetime, timedelta
from typing import Dict, List, Optional
from uuid import UUID

from sqlalchemy.orm import Session
from sqlalchemy import func, and_

from app.models.analytics_v2 import ValidationAnalytics
from app.core.config import get_settings

settings = get_settings()


class AnalyticsService:
    """
    Service for tracking validation analytics
    
    Features:
    - Log validation events (metadata only - NO document content)
    - Track validation failures for compliance monitoring
    - Generate usage reports
    - Monitor performance metrics
    
    Zero-Knowledge Architecture:
    - NEVER log document content
    - NEVER log client data (PII/PHI)
    - ONLY log metadata (document type, validation status, rule IDs)
    """
    
    def __init__(self, db: Session):
        self.db = db
    
    def log_validation_event(
        self,
        event_type: str,
        tenant_id: Optional[UUID] = None,
        user_id: Optional[UUID] = None,
        practice_area: Optional[str] = None,
        specialization: Optional[str] = None,
        document_type: Optional[str] = None,
        jurisdiction_state: Optional[str] = None,
        jurisdiction_county: Optional[str] = None,
        total_rules_checked: Optional[int] = None,
        rules_passed: Optional[int] = None,
        rules_failed: Optional[int] = None,
        rules_warned: Optional[int] = None,
        failed_rule_ids: Optional[List[UUID]] = None,
        validation_duration_ms: Optional[int] = None,
        client_type: Optional[str] = None,
        client_version: Optional[str] = None,
        session_id: Optional[UUID] = None,
        is_compliance_issue: bool = False,
        notes: Optional[str] = None,
    ) -> ValidationAnalytics:
        """
        Log validation event
        
        Args:
            event_type: Event type (validation_sync, validation_run, validation_failure, etc.)
            tenant_id: Tenant ID (optional)
            user_id: User ID (optional)
            practice_area: Practice area (optional)
            specialization: Specialization (optional)
            document_type: Document type (optional)
            jurisdiction_state: State code (optional)
            jurisdiction_county: County name (optional)
            total_rules_checked: Total rules checked (optional)
            rules_passed: Rules passed (optional)
            rules_failed: Rules failed (optional)
            rules_warned: Rules warned (optional)
            failed_rule_ids: Failed rule IDs (optional)
            validation_duration_ms: Validation duration in ms (optional)
            client_type: Client type (optional)
            client_version: Client version (optional)
            session_id: Session ID (optional)
            is_compliance_issue: Flag for compliance issue (default: False)
            notes: Notes (optional, NO document content)
            
        Returns:
            Created ValidationAnalytics object
        """
        if not settings.ENABLE_ANALYTICS:
            # Analytics disabled
            return None
        
        analytics_event = ValidationAnalytics(
            event_type=event_type,
            tenant_id=tenant_id,
            user_id=user_id,
            practice_area=practice_area,
            specialization=specialization,
            document_type=document_type,
            jurisdiction_state=jurisdiction_state,
            jurisdiction_county=jurisdiction_county,
            total_rules_checked=total_rules_checked,
            rules_passed=rules_passed,
            rules_failed=rules_failed,
            rules_warned=rules_warned,
            failed_rule_ids=failed_rule_ids,
            validation_duration_ms=validation_duration_ms,
            client_type=client_type,
            client_version=client_version,
            session_id=session_id,
            is_compliance_issue=is_compliance_issue,
            notes=notes,
        )
        
        self.db.add(analytics_event)
        self.db.commit()
        self.db.refresh(analytics_event)
        
        return analytics_event
    
    def get_validation_usage_stats(
        self,
        tenant_id: Optional[UUID] = None,
        start_date: Optional[datetime] = None,
        end_date: Optional[datetime] = None,
    ) -> Dict:
        """
        Get validation usage statistics
        
        Args:
            tenant_id: Filter by tenant ID (optional)
            start_date: Start date (optional)
            end_date: End date (optional)
            
        Returns:
            Dict with usage statistics
        """
        query = self.db.query(ValidationAnalytics)
        
        # Apply filters
        filters = []
        
        if tenant_id:
            filters.append(ValidationAnalytics.tenant_id == tenant_id)
        
        if start_date:
            filters.append(ValidationAnalytics.event_timestamp >= start_date)
        
        if end_date:
            filters.append(ValidationAnalytics.event_timestamp <= end_date)
        
        if filters:
            query = query.filter(and_(*filters))
        
        # Get counts
        total_events = query.count()
        
        validation_runs = query.filter(
            ValidationAnalytics.event_type == "validation_run"
        ).count()
        
        validation_failures = query.filter(
            ValidationAnalytics.rules_failed > 0
        ).count()
        
        compliance_issues = query.filter(
            ValidationAnalytics.is_compliance_issue == True  # noqa: E712
        ).count()
        
        # Get average validation duration
        avg_duration = query.with_entities(
            func.avg(ValidationAnalytics.validation_duration_ms)
        ).scalar() or 0
        
        # Get total rules checked
        total_rules_checked = query.with_entities(
            func.sum(ValidationAnalytics.total_rules_checked)
        ).scalar() or 0
        
        # Get pass/fail rates
        total_passed = query.with_entities(
            func.sum(ValidationAnalytics.rules_passed)
        ).scalar() or 0
        
        total_failed = query.with_entities(
            func.sum(ValidationAnalytics.rules_failed)
        ).scalar() or 0
        
        pass_rate = (total_passed / total_rules_checked * 100) if total_rules_checked > 0 else 0
        
        return {
            "total_events": total_events,
            "validation_runs": validation_runs,
            "validation_failures": validation_failures,
            "compliance_issues": compliance_issues,
            "avg_validation_duration_ms": round(avg_duration, 2),
            "total_rules_checked": total_rules_checked,
            "total_rules_passed": total_passed,
            "total_rules_failed": total_failed,
            "pass_rate_percentage": round(pass_rate, 2),
        }
    
    def get_most_failed_rules(
        self,
        tenant_id: Optional[UUID] = None,
        start_date: Optional[datetime] = None,
        end_date: Optional[datetime] = None,
        limit: int = 10,
    ) -> List[Dict]:
        """
        Get most frequently failed validation rules
        
        Args:
            tenant_id: Filter by tenant ID (optional)
            start_date: Start date (optional)
            end_date: End date (optional)
            limit: Number of rules to return (default: 10)
            
        Returns:
            List of rules with failure counts
        """
        from sqlalchemy import func
        from sqlalchemy.dialects.postgresql import ARRAY
        
        query = self.db.query(
            func.unnest(ValidationAnalytics.failed_rule_ids).label("rule_id"),
            func.count().label("failure_count")
        )
        
        # Apply filters
        filters = [ValidationAnalytics.failed_rule_ids.isnot(None)]
        
        if tenant_id:
            filters.append(ValidationAnalytics.tenant_id == tenant_id)
        
        if start_date:
            filters.append(ValidationAnalytics.event_timestamp >= start_date)
        
        if end_date:
            filters.append(ValidationAnalytics.event_timestamp <= end_date)
        
        if filters:
            query = query.filter(and_(*filters))
        
        # Group and order
        results = query.group_by("rule_id").order_by(
            func.count().desc()
        ).limit(limit).all()
        
        return [
            {
                "rule_id": str(result.rule_id),
                "failure_count": result.failure_count
            }
            for result in results
        ]
    
    def get_sync_history(
        self,
        tenant_id: UUID,
        start_date: Optional[datetime] = None,
        end_date: Optional[datetime] = None,
        limit: int = 50,
    ) -> List[Dict]:
        """
        Get sync history for tenant
        
        Args:
            tenant_id: Tenant ID
            start_date: Start date (optional)
            end_date: End date (optional)
            limit: Number of records to return (default: 50)
            
        Returns:
            List of sync log entries
        """
        query = self.db.query(SyncLog).filter(
            SyncLog.tenant_id == tenant_id
        )
        
        # Apply date filters
        if start_date:
            query = query.filter(SyncLog.sync_timestamp >= start_date)
        
        if end_date:
            query = query.filter(SyncLog.sync_timestamp <= end_date)
        
        # Order and limit
        sync_logs = query.order_by(
            SyncLog.sync_timestamp.desc()
        ).limit(limit).all()
        
        return [log.to_dict() for log in sync_logs]
    
    def get_compliance_issues(
        self,
        tenant_id: Optional[UUID] = None,
        start_date: Optional[datetime] = None,
        end_date: Optional[datetime] = None,
    ) -> List[Dict]:
        """
        Get compliance issues
        
        Args:
            tenant_id: Filter by tenant ID (optional)
            start_date: Start date (optional)
            end_date: End date (optional)
            
        Returns:
            List of compliance issue events
        """
        query = self.db.query(ValidationAnalytics).filter(
            ValidationAnalytics.is_compliance_issue == True  # noqa: E712
        )
        
        # Apply filters
        if tenant_id:
            query = query.filter(ValidationAnalytics.tenant_id == tenant_id)
        
        if start_date:
            query = query.filter(ValidationAnalytics.event_timestamp >= start_date)
        
        if end_date:
            query = query.filter(ValidationAnalytics.event_timestamp <= end_date)
        
        # Order by timestamp
        issues = query.order_by(
            ValidationAnalytics.event_timestamp.desc()
        ).all()
        
        return [issue.to_dict() for issue in issues]

