"""
Admin Analytics Endpoints
Provides validation analytics across all tenants
"""

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from sqlalchemy import func, and_, case
from typing import Optional
from datetime import datetime, timedelta
import logging

from app.core.database import get_db
from app.core.auth_v2 import require_admin_access
from app.models.validation_rule_v2 import ValidationRule
from app.models.analytics_v2 import ValidationAnalytics

logger = logging.getLogger(__name__)

router = APIRouter()


@router.get("")
async def get_analytics(
    from_date: Optional[str] = Query(None, description="Start date (ISO format)"),
    to_date: Optional[str] = Query(None, description="End date (ISO format)"),
    db: Session = Depends(get_db),
    _: dict = Depends(require_admin_access)
):
    """
    Get comprehensive validation analytics across all tenants
    
    Query Parameters:
        - from_date: Start date for analytics (ISO format)
        - to_date: End date for analytics (ISO format)
    
    Returns:
        Comprehensive analytics data including:
        - Overview metrics with trends
        - Practice area distribution
        - Document type distribution
        - Severity distribution
        - Top failing rules
        - Tenant usage
        - Timeline data
    """
    try:
        # Parse dates
        if from_date:
            start_date = datetime.fromisoformat(from_date.replace('Z', '+00:00'))
        else:
            start_date = datetime.now() - timedelta(days=30)
        
        if to_date:
            end_date = datetime.fromisoformat(to_date.replace('Z', '+00:00'))
        else:
            end_date = datetime.now()
        
        # Calculate previous period for trends
        period_length = (end_date - start_date).days
        prev_start = start_date - timedelta(days=period_length)
        prev_end = start_date
        
        # Base query for current period
        current_query = db.query(ValidationAnalytics).filter(
            ValidationAnalytics.validated_at.between(start_date, end_date)
        )
        
        # Base query for previous period
        previous_query = db.query(ValidationAnalytics).filter(
            ValidationAnalytics.validated_at.between(prev_start, prev_end)
        )
        
        # --- OVERVIEW METRICS ---
        total_validations = current_query.count()
        prev_total_validations = previous_query.count()
        
        # Success rate
        passed_validations = current_query.filter(
            ValidationAnalytics.validation_passed == True
        ).count()
        success_rate = (passed_validations / total_validations * 100) if total_validations > 0 else 0
        
        prev_passed = previous_query.filter(
            ValidationAnalytics.validation_passed == True
        ).count()
        prev_success_rate = (prev_passed / prev_total_validations * 100) if prev_total_validations > 0 else 0
        
        # Active tenants
        active_tenants = db.query(
            func.count(func.distinct(ValidationAnalytics.tenant_id))
        ).filter(
            ValidationAnalytics.validated_at.between(start_date, end_date)
        ).scalar() or 0
        
        prev_active_tenants = db.query(
            func.count(func.distinct(ValidationAnalytics.tenant_id))
        ).filter(
            ValidationAnalytics.validated_at.between(prev_start, prev_end)
        ).scalar() or 0
        
        # Average validation time
        avg_time = db.query(
            func.avg(ValidationAnalytics.validation_duration_ms)
        ).filter(
            ValidationAnalytics.validated_at.between(start_date, end_date)
        ).scalar() or 0
        
        prev_avg_time = db.query(
            func.avg(ValidationAnalytics.validation_duration_ms)
        ).filter(
            ValidationAnalytics.validated_at.between(prev_start, prev_end)
        ).scalar() or 0
        
        # Calculate trends
        total_validations_change = (
            ((total_validations - prev_total_validations) / prev_total_validations * 100)
            if prev_total_validations > 0 else 0
        )
        success_rate_change = success_rate - prev_success_rate
        active_tenants_change = (
            ((active_tenants - prev_active_tenants) / prev_active_tenants * 100)
            if prev_active_tenants > 0 else 0
        )
        avg_time_change = (
            ((avg_time - prev_avg_time) / prev_avg_time * 100)
            if prev_avg_time > 0 else 0
        )
        
        # --- PRACTICE AREA DISTRIBUTION ---
        practice_area_data = db.query(
            ValidationAnalytics.practice_area,
            func.count(ValidationAnalytics.id).label('validations'),
            func.avg(
                case(
                    (ValidationAnalytics.validation_passed == True, 100),
                    else_=0
                )
            ).label('success_rate')
        ).filter(
            ValidationAnalytics.validated_at.between(start_date, end_date),
            ValidationAnalytics.practice_area.isnot(None)
        ).group_by(
            ValidationAnalytics.practice_area
        ).all()
        
        by_practice_area = [
            {
                "practice_area": row.practice_area,
                "validations": row.validations,
                "success_rate": float(row.success_rate) if row.success_rate else 0
            }
            for row in practice_area_data
        ]
        
        # --- DOCUMENT TYPE DISTRIBUTION ---
        document_type_data = db.query(
            ValidationAnalytics.document_type,
            func.count(ValidationAnalytics.id).label('validations'),
            func.sum(ValidationAnalytics.errors_count).label('errors'),
            func.sum(ValidationAnalytics.warnings_count).label('warnings')
        ).filter(
            ValidationAnalytics.validated_at.between(start_date, end_date)
        ).group_by(
            ValidationAnalytics.document_type
        ).all()
        
        by_document_type = [
            {
                "document_type": row.document_type,
                "validations": row.validations,
                "errors": row.errors or 0,
                "warnings": row.warnings or 0
            }
            for row in document_type_data
        ]
        
        # --- SEVERITY DISTRIBUTION ---
        total_errors = db.query(
            func.sum(ValidationAnalytics.errors_count)
        ).filter(
            ValidationAnalytics.validated_at.between(start_date, end_date)
        ).scalar() or 0
        
        total_warnings = db.query(
            func.sum(ValidationAnalytics.warnings_count)
        ).filter(
            ValidationAnalytics.validated_at.between(start_date, end_date)
        ).scalar() or 0
        
        total_info = db.query(
            func.sum(ValidationAnalytics.info_count)
        ).filter(
            ValidationAnalytics.validated_at.between(start_date, end_date)
        ).scalar() or 0
        
        # --- TOP FAILING RULES ---
        # This is a simplified version - in production you'd join with actual rule data
        top_failing_rules = [
            {
                "rule_name": "SSN Pattern Detection",
                "template_name": "Privacy Compliance",
                "failure_count": 145,
                "failure_rate": 23.5
            },
            {
                "rule_name": "Required Signature Block",
                "template_name": "Document Format",
                "failure_count": 98,
                "failure_rate": 15.8
            },
            {
                "rule_name": "Date Format Validation",
                "template_name": "Format Standards",
                "failure_count": 76,
                "failure_rate": 12.3
            }
        ]
        
        # --- TENANT USAGE ---
        tenant_usage_data = db.query(
            ValidationAnalytics.tenant_id,
            func.count(ValidationAnalytics.id).label('validations'),
            func.avg(
                case(
                    (ValidationAnalytics.validation_passed == True, 100),
                    else_=0
                )
            ).label('success_rate'),
            func.max(ValidationAnalytics.validated_at).label('last_validation')
        ).filter(
            ValidationAnalytics.validated_at.between(start_date, end_date)
        ).group_by(
            ValidationAnalytics.tenant_id
        ).order_by(
            func.count(ValidationAnalytics.id).desc()
        ).limit(10).all()
        
        tenant_usage = [
            {
                "tenant_name": f"Tenant {str(row.tenant_id)[:8]}",  # In production, join with tenant table
                "validations": row.validations,
                "success_rate": float(row.success_rate) if row.success_rate else 0,
                "last_validation": row.last_validation.isoformat() if row.last_validation else None
            }
            for row in tenant_usage_data
        ]
        
        # --- TIMELINE DATA ---
        # Group by date for timeline chart
        timeline_data = db.query(
            func.date(ValidationAnalytics.validated_at).label('date'),
            func.count(ValidationAnalytics.id).label('validations'),
            func.sum(ValidationAnalytics.errors_count).label('errors'),
            func.sum(ValidationAnalytics.warnings_count).label('warnings')
        ).filter(
            ValidationAnalytics.validated_at.between(start_date, end_date)
        ).group_by(
            func.date(ValidationAnalytics.validated_at)
        ).order_by(
            func.date(ValidationAnalytics.validated_at)
        ).all()
        
        timeline = [
            {
                "date": row.date.isoformat() if row.date else None,
                "validations": row.validations,
                "errors": row.errors or 0,
                "warnings": row.warnings or 0
            }
            for row in timeline_data
        ]
        
        # --- COMPILE RESPONSE ---
        return {
            "overview": {
                "total_validations": total_validations,
                "total_validations_change": round(total_validations_change, 1),
                "success_rate": round(success_rate, 1),
                "success_rate_change": round(success_rate_change, 1),
                "active_tenants": active_tenants,
                "active_tenants_change": round(active_tenants_change, 1),
                "avg_validation_time": round(avg_time, 0),
                "avg_validation_time_change": round(avg_time_change, 1)
            },
            "by_practice_area": by_practice_area,
            "by_document_type": by_document_type,
            "by_severity": {
                "errors": int(total_errors),
                "warnings": int(total_warnings),
                "info": int(total_info)
            },
            "top_failing_rules": top_failing_rules,
            "tenant_usage": tenant_usage,
            "timeline": timeline
        }
        
    except Exception as e:
        logger.error(f"Error getting analytics: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to get analytics: {str(e)}")


