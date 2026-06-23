"""
Admin Compliance Endpoints
Handles compliance reporting and audit trails
"""

from fastapi import APIRouter, Depends, HTTPException, Query, Response
from sqlalchemy.orm import Session
from sqlalchemy import func, and_, desc
from typing import Optional
from datetime import datetime, timedelta
from uuid import UUID, uuid4
import logging
import json

from app.core.database import get_db
from app.core.auth_v2 import require_admin_access
from app.models.analytics_v2 import ValidationAnalytics

logger = logging.getLogger(__name__)

router = APIRouter()


@router.get("/stats")
async def get_compliance_stats(
    db: Session = Depends(get_db),
    admin: dict = Depends(require_admin_access)
):
    """
    Get compliance statistics for dashboard
    
    Returns:
        - total_reports: Total number of reports generated
        - active_audits: Number of ongoing audits
        - compliance_score: Overall compliance score (0-100)
        - critical_issues: Number of critical compliance issues
    """
    try:
        # Get date ranges
        now = datetime.now()
        last_30_days = now - timedelta(days=30)
        
        # Total validations in last 30 days
        total_validations = db.query(ValidationAnalytics).filter(
            ValidationAnalytics.validated_at >= last_30_days
        ).count()
        
        # Passed validations
        passed_validations = db.query(ValidationAnalytics).filter(
            ValidationAnalytics.validated_at >= last_30_days,
            ValidationAnalytics.validation_passed == True
        ).count()
        
        # Compliance score (based on pass rate)
        compliance_score = (
            (passed_validations / total_validations * 100)
            if total_validations > 0 else 100
        )
        
        # Critical issues (errors)
        critical_issues = db.query(
            func.sum(ValidationAnalytics.errors_count)
        ).filter(
            ValidationAnalytics.validated_at >= last_30_days
        ).scalar() or 0
        
        # For demo purposes, we'll use mock data for reports and audits
        # In production, these would come from dedicated tables
        total_reports = 24
        active_audits = 3
        
        return {
            "total_reports": total_reports,
            "active_audits": active_audits,
            "compliance_score": round(compliance_score, 1),
            "critical_issues": int(critical_issues)
        }
        
    except Exception as e:
        logger.error(f"Error getting compliance stats: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to get compliance stats: {str(e)}")


@router.get("/reports")
async def list_compliance_reports(
    tenant_id: Optional[str] = Query(None, description="Filter by tenant"),
    report_type: Optional[str] = Query(None, description="Filter by report type"),
    from_date: Optional[str] = Query(None, description="Start date (ISO format)"),
    to_date: Optional[str] = Query(None, description="End date (ISO format)"),
    db: Session = Depends(get_db),
    admin: dict = Depends(require_admin_access)
):
    """
    List all compliance reports with optional filters
    
    Query Parameters:
        - tenant_id: Filter by tenant UUID
        - report_type: Filter by report type (validation, audit, summary)
        - from_date: Start date for reports
        - to_date: End date for reports
    
    Returns:
        List of compliance reports
    """
    try:
        # In production, this would query a dedicated compliance_reports table
        # For now, we'll generate mock data based on analytics
        
        # Parse dates
        if from_date:
            start_date = datetime.fromisoformat(from_date.replace('Z', '+00:00'))
        else:
            start_date = datetime.now() - timedelta(days=90)
        
        if to_date:
            end_date = datetime.fromisoformat(to_date.replace('Z', '+00:00'))
        else:
            end_date = datetime.now()
        
        # Mock reports data
        reports = [
            {
                "id": str(uuid4()),
                "report_name": "Q4 2024 Validation Summary",
                "report_type": "summary",
                "tenant_name": "All Tenants",
                "generated_at": (datetime.now() - timedelta(days=5)).isoformat(),
                "period_start": (datetime.now() - timedelta(days=95)).isoformat(),
                "period_end": (datetime.now() - timedelta(days=5)).isoformat(),
                "status": "completed",
                "file_size": "2.4 MB"
            },
            {
                "id": str(uuid4()),
                "report_name": "December Validation Audit",
                "report_type": "audit",
                "tenant_name": "Smith & Associates",
                "generated_at": (datetime.now() - timedelta(days=12)).isoformat(),
                "period_start": (datetime.now() - timedelta(days=42)).isoformat(),
                "period_end": (datetime.now() - timedelta(days=12)).isoformat(),
                "status": "completed",
                "file_size": "1.8 MB"
            },
            {
                "id": str(uuid4()),
                "report_name": "Weekly Validation Report",
                "report_type": "validation",
                "tenant_name": "Johnson Legal Group",
                "generated_at": (datetime.now() - timedelta(days=2)).isoformat(),
                "period_start": (datetime.now() - timedelta(days=9)).isoformat(),
                "period_end": (datetime.now() - timedelta(days=2)).isoformat(),
                "status": "completed",
                "file_size": "856 KB"
            }
        ]
        
        # Apply filters
        if tenant_id:
            # In production, filter by actual tenant_id
            pass
        
        if report_type:
            reports = [r for r in reports if r["report_type"] == report_type]
        
        return {"reports": reports}
        
    except Exception as e:
        logger.error(f"Error listing compliance reports: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to list compliance reports: {str(e)}")


@router.post("/reports")
async def generate_compliance_report(
    report_config: dict,
    db: Session = Depends(get_db),
    admin: dict = Depends(require_admin_access)
) -> dict:
    """
    Generate a new compliance report (matches UI endpoint)
    
    Request Body:
        - from_date: Start date for report period (ISO format) (required)
        - to_date: End date for report period (ISO format) (required)
        - tenant_id: Specific tenant or null for all tenants (optional)
        - practice_area: Filter by practice area (optional)
    
    Returns:
        Complete ComplianceReport object
    """
    try:
        # Validate required fields
        if "from_date" not in report_config:
            raise HTTPException(status_code=400, detail="Missing required field: from_date")
        
        if "to_date" not in report_config:
            raise HTTPException(status_code=400, detail="Missing required field: to_date")
        
        # Parse dates
        from_date = report_config.get("from_date")
        to_date = report_config.get("to_date")
        tenant_id = report_config.get("tenant_id")
        practice_area = report_config.get("practice_area")
        
        start_date = datetime.fromisoformat(from_date.replace('Z', '+00:00'))
        end_date = datetime.fromisoformat(to_date.replace('Z', '+00:00'))
        
        # Get analytics data for the report
        query = db.query(ValidationAnalytics).filter(
            ValidationAnalytics.validated_at.between(start_date, end_date)
        )
        
        if tenant_id:
            query = query.filter(ValidationAnalytics.tenant_id == tenant_id)
        
        if practice_area:
            query = query.filter(ValidationAnalytics.practice_area == practice_area)
        
        total_validations = query.count()
        passed_validations = query.filter(ValidationAnalytics.validation_passed == True).count()
        
        # Calculate compliance breakdown by validator level
        format_validations = query.filter(
            ValidationAnalytics.validator_level == 'format'
        ).count()
        format_passed = query.filter(
            ValidationAnalytics.validator_level == 'format',
            ValidationAnalytics.validation_passed == True
        ).count()
        
        content_validations = query.filter(
            ValidationAnalytics.validator_level == 'content'
        ).count()
        content_passed = query.filter(
            ValidationAnalytics.validator_level == 'content',
            ValidationAnalytics.validation_passed == True
        ).count()
        
        compliance_validations = query.filter(
            ValidationAnalytics.validator_level == 'compliance'
        ).count()
        compliance_passed = query.filter(
            ValidationAnalytics.validator_level == 'compliance',
            ValidationAnalytics.validation_passed == True
        ).count()
        
        quality_validations = query.filter(
            ValidationAnalytics.validator_level == 'quality'
        ).count()
        quality_passed = query.filter(
            ValidationAnalytics.validator_level == 'quality',
            ValidationAnalytics.validation_passed == True
        ).count()
        
        # Get top violations (rules with most errors)
        # Simplified implementation - in production would join with validation_rules table
        # For now, aggregate by errors_count from analytics
        violations_data = db.query(
            func.sum(ValidationAnalytics.errors_count).label('total_errors'),
            func.count(ValidationAnalytics.id).label('occurrences')
        ).filter(
            ValidationAnalytics.validated_at.between(start_date, end_date),
            ValidationAnalytics.errors_count > 0
        )
        
        if tenant_id:
            violations_data = violations_data.filter(ValidationAnalytics.tenant_id == tenant_id)
        
        violations_result = violations_data.scalar()
        total_errors = int(violations_result or 0)
        
        # Simplified top violations - in production would get actual rule names
        top_violations = []
        if total_errors > 0:
            # Get sample violations from analytics
            sample_violations = query.filter(
                ValidationAnalytics.errors_count > 0
            ).order_by(desc(ValidationAnalytics.errors_count)).limit(10).all()
            
            for i, violation in enumerate(sample_violations):
                top_violations.append({
                    "rule_id": f"rule-{i+1}",
                    "rule_name": f"Validation Rule {i+1}",  # Would get from rules table
                    "violation_count": violation.errors_count or 0,
                    "affected_tenants": 1,  # Simplified
                    "severity": "error"
                })
        
        # Get tenant compliance (simplified - would need proper tenant aggregation)
        tenant_compliance = []
        if not tenant_id:
            # Get unique tenants
            tenant_ids = db.query(ValidationAnalytics.tenant_id).filter(
                ValidationAnalytics.validated_at.between(start_date, end_date)
            ).distinct().all()
            
            for tid in tenant_ids[:20]:  # Limit to 20 tenants for demo
                if tid[0]:
                    tenant_query = query.filter(ValidationAnalytics.tenant_id == tid[0])
                    tenant_total = tenant_query.count()
                    tenant_passed = tenant_query.filter(ValidationAnalytics.validation_passed == True).count()
                    tenant_score = (tenant_passed / tenant_total * 100) if tenant_total > 0 else 100
                    tenant_errors = db.query(func.sum(ValidationAnalytics.errors_count)).filter(
                        ValidationAnalytics.tenant_id == tid[0],
                        ValidationAnalytics.validated_at.between(start_date, end_date)
                    ).scalar() or 0
                    
                    last_validation = db.query(func.max(ValidationAnalytics.validated_at)).filter(
                        ValidationAnalytics.tenant_id == tid[0]
                    ).scalar()
                    
                    status = 'compliant' if tenant_score >= 90 else ('at-risk' if tenant_score >= 70 else 'non-compliant')
                    
                    tenant_compliance.append({
                        "tenant_id": str(tid[0]),
                        "tenant_name": f"Tenant {str(tid[0])[:8]}",  # Simplified
                        "compliance_score": round(tenant_score, 1),
                        "violations_count": int(tenant_errors),
                        "last_validation": last_validation.isoformat() if last_validation else None,
                        "status": status
                    })
        
        # Calculate overall score
        overall_score = (passed_validations / total_validations * 100) if total_validations > 0 else 100
        
        report_id = str(uuid4())
        
        # Build compliance report response
        report = {
            "report_id": report_id,
            "generated_at": datetime.now().isoformat(),
            "generated_by": admin.get("user_id", "admin"),
            "date_range": {
                "from": from_date,
                "to": to_date
            },
            "overall_score": round(overall_score, 1),
            "tenant_count": len(tenant_compliance) if tenant_compliance else 1,
            "total_validations": total_validations,
            "compliance_breakdown": {
                "format": round((format_passed / format_validations * 100) if format_validations > 0 else 100, 1),
                "content": round((content_passed / content_validations * 100) if content_validations > 0 else 100, 1),
                "compliance": round((compliance_passed / compliance_validations * 100) if compliance_validations > 0 else 100, 1),
                "quality": round((quality_passed / quality_validations * 100) if quality_validations > 0 else 100, 1)
            },
            "top_violations": top_violations,
            "tenant_compliance": tenant_compliance if tenant_compliance else [
                {
                    "tenant_id": tenant_id or "all",
                    "tenant_name": "All Tenants" if not tenant_id else f"Tenant {tenant_id[:8]}",
                    "compliance_score": round(overall_score, 1),
                    "violations_count": int(db.query(func.sum(ValidationAnalytics.errors_count)).filter(
                        ValidationAnalytics.validated_at.between(start_date, end_date)
                    ).scalar() or 0),
                    "last_validation": end_date.isoformat(),
                    "status": "compliant" if overall_score >= 90 else ("at-risk" if overall_score >= 70 else "non-compliant")
                }
            ]
        }
        
        logger.info(f"Generated compliance report: {report_id} covering {total_validations} validations")
        
        return report
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error generating compliance report: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to generate compliance report: {str(e)}")


@router.get("/reports/{report_id}")
async def get_compliance_report(
    report_id: str,
    db: Session = Depends(get_db),
    admin: dict = Depends(require_admin_access)
):
    """
    Get a specific compliance report by ID
    
    Path Parameters:
        - report_id: UUID of the report
    
    Returns:
        Complete ComplianceReport object
    """
    try:
        # In production, this would retrieve from database
        # For now, return a mock response
        return {
            "report_id": report_id,
            "generated_at": datetime.now().isoformat(),
            "generated_by": "admin",
            "date_range": {
                "from": (datetime.now() - timedelta(days=30)).isoformat(),
                "to": datetime.now().isoformat()
            },
            "overall_score": 87.5,
            "tenant_count": 10,
            "total_validations": 1247,
            "compliance_breakdown": {
                "format": 95.2,
                "content": 88.7,
                "compliance": 85.3,
                "quality": 90.1
            },
            "top_violations": [],
            "tenant_compliance": []
        }
    except Exception as e:
        logger.error(f"Error getting compliance report: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to get compliance report: {str(e)}")


@router.get("/reports/{report_id}/export")
async def export_compliance_report(
    report_id: str,
    format: str = Query("pdf", description="Export format: pdf, csv, or json"),
    db: Session = Depends(get_db),
    admin: dict = Depends(require_admin_access)
):
    """
    Export a compliance report in specified format
    
    Path Parameters:
        - report_id: UUID of the report
    
    Query Parameters:
        - format: Export format (pdf, csv, json)
    
    Returns:
        Report file download
    """
    try:
        # Validate format
        if format not in ['pdf', 'csv', 'json']:
            raise HTTPException(status_code=400, detail="Invalid format. Must be pdf, csv, or json")
        
        # In production, this would:
        # 1. Verify report exists and is completed
        # 2. Generate file in requested format
        # 3. Return file with appropriate headers
        
        # For now, return JSON format
        mock_report = {
            "report_id": report_id,
            "generated_at": datetime.now().isoformat(),
            "summary": {
                "total_validations": 1247,
                "passed_validations": 1089,
                "success_rate": 87.3,
                "critical_issues": 23,
                "warnings": 135
            }
        }
        
        logger.info(f"Exported compliance report: {report_id} as {format}")
        
        if format == 'json':
            return Response(
                content=json.dumps(mock_report, indent=2),
                media_type="application/json",
                headers={
                    "Content-Disposition": f"attachment; filename=compliance_report_{report_id}.json"
                }
            )
        elif format == 'csv':
            # Generate CSV (simplified)
            csv_content = "Report ID,Generated At,Total Validations,Passed,Success Rate\n"
            csv_content += f"{report_id},{mock_report['generated_at']},{mock_report['summary']['total_validations']},{mock_report['summary']['passed_validations']},{mock_report['summary']['success_rate']}\n"
            
            return Response(
                content=csv_content,
                media_type="text/csv",
                headers={
                    "Content-Disposition": f"attachment; filename=compliance_report_{report_id}.csv"
                }
            )
        else:  # PDF
            # In production, generate actual PDF
            # For now, return JSON with note
            return Response(
                content=json.dumps({**mock_report, "note": "PDF generation not yet implemented"}),
                media_type="application/json",
                headers={
                    "Content-Disposition": f"attachment; filename=compliance_report_{report_id}.json"
                }
            )
        
    except Exception as e:
        logger.error(f"Error downloading compliance report: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to download compliance report: {str(e)}")


@router.get("/audit-trail")
async def get_audit_trail(
    tenant_id: Optional[str] = Query(None, description="Filter by tenant"),
    action_type: Optional[str] = Query(None, description="Filter by action type"),
    from_date: Optional[str] = Query(None, description="Start date (ISO format)"),
    to_date: Optional[str] = Query(None, description="End date (ISO format)"),
    limit: int = Query(100, description="Number of records to return"),
    db: Session = Depends(get_db),
    admin: dict = Depends(require_admin_access)
):
    """
    Get audit trail of all validation activities
    
    Query Parameters:
        - tenant_id: Filter by tenant UUID
        - action_type: Filter by action type
        - from_date: Start date for audit trail
        - to_date: End date for audit trail
        - limit: Number of records to return (default: 100)
    
    Returns:
        List of audit trail entries
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
        
        # Query analytics as audit trail
        query = db.query(ValidationAnalytics).filter(
            ValidationAnalytics.validated_at.between(start_date, end_date)
        )
        
        if tenant_id:
            query = query.filter(ValidationAnalytics.tenant_id == tenant_id)
        
        # Get records
        records = query.order_by(
            desc(ValidationAnalytics.validated_at)
        ).limit(limit).all()
        
        # Format as audit trail
        audit_trail = []
        for record in records:
            audit_trail.append({
                "id": str(record.id),
                "timestamp": record.validated_at.isoformat() if record.validated_at else None,
                "tenant_id": str(record.tenant_id) if record.tenant_id else None,
                "action": "validation_performed",
                "document_type": record.document_type,
                "practice_area": record.practice_area,
                "result": "passed" if record.validation_passed else "failed",
                "errors_count": record.errors_count,
                "warnings_count": record.warnings_count,
                "duration_ms": record.validation_duration_ms,
                "user_id": record.user_id
            })
        
        return {
            "audit_trail": audit_trail,
            "total_records": len(audit_trail),
            "from_date": start_date.isoformat(),
            "to_date": end_date.isoformat()
        }
        
    except Exception as e:
        logger.error(f"Error getting audit trail: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to get audit trail: {str(e)}")


