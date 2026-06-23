"""
Tenant DRAFT Endpoints
Provides tenant-specific validation statistics and document management
"""

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from sqlalchemy import func, and_, desc
from typing import Optional
from datetime import datetime, timedelta
from uuid import UUID
import logging

from app.core.database import get_db
from app.core.auth_v2 import require_tenant_access
from app.models.validation_rule_v2 import ValidationRule
from app.models.analytics_v2 import ValidationAnalytics

logger = logging.getLogger(__name__)

router = APIRouter()


@router.get("/stats")
async def get_tenant_draft_stats(
    tenant_id: str,
    db: Session = Depends(get_db),
    auth: dict = Depends(require_tenant_access)
):
    """
    Get DRAFT statistics for a specific tenant
    
    Path Parameters:
        - tenant_id: UUID of the tenant
    
    Returns:
        - total_validations: Total validations performed
        - success_rate: Percentage of successful validations
        - active_rules: Number of active validation rules
        - documents_processed: Number of documents processed
    """
    try:
        # Verify tenant access
        if str(auth.get("tenant_id")) != tenant_id:
            raise HTTPException(status_code=403, detail="Access denied to this tenant")
        
        # Get date range (last 30 days)
        now = datetime.now()
        last_30_days = now - timedelta(days=30)
        
        # Total validations
        total_validations = db.query(ValidationAnalytics).filter(
            ValidationAnalytics.tenant_id == tenant_id,
            ValidationAnalytics.validated_at >= last_30_days
        ).count()
        
        # Successful validations
        passed_validations = db.query(ValidationAnalytics).filter(
            ValidationAnalytics.tenant_id == tenant_id,
            ValidationAnalytics.validated_at >= last_30_days,
            ValidationAnalytics.validation_passed == True
        ).count()
        
        # Success rate
        success_rate = (
            (passed_validations / total_validations * 100)
            if total_validations > 0 else 0
        )
        
        # Active rules for this tenant
        active_rules = db.query(ValidationRule).filter(
            ValidationRule.tenant_id == tenant_id,
            ValidationRule.is_active == True
        ).count()
        
        # Documents processed (unique document IDs)
        documents_processed = db.query(
            func.count(func.distinct(ValidationAnalytics.document_id))
        ).filter(
            ValidationAnalytics.tenant_id == tenant_id,
            ValidationAnalytics.validated_at >= last_30_days
        ).scalar() or 0
        
        return {
            "total_validations": total_validations,
            "success_rate": round(success_rate, 1),
            "active_rules": active_rules,
            "documents_processed": documents_processed
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting tenant DRAFT stats: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to get tenant DRAFT stats: {str(e)}")


@router.get("/documents")
async def list_tenant_documents(
    tenant_id: str,
    document_type: Optional[str] = Query(None, description="Filter by document type"),
    practice_area: Optional[str] = Query(None, description="Filter by practice area"),
    validation_status: Optional[str] = Query(None, description="Filter by validation status (passed/failed)"),
    from_date: Optional[str] = Query(None, description="Start date (ISO format)"),
    to_date: Optional[str] = Query(None, description="End date (ISO format)"),
    limit: int = Query(50, description="Number of records to return"),
    offset: int = Query(0, description="Offset for pagination"),
    db: Session = Depends(get_db),
    auth: dict = Depends(require_tenant_access)
):
    """
    List documents processed by DRAFT for a specific tenant
    
    Path Parameters:
        - tenant_id: UUID of the tenant
    
    Query Parameters:
        - document_type: Filter by document type
        - practice_area: Filter by practice area
        - validation_status: Filter by validation status (passed/failed)
        - from_date: Start date for documents
        - to_date: End date for documents
        - limit: Number of records to return (default: 50)
        - offset: Offset for pagination (default: 0)
    
    Returns:
        List of documents with validation results
    """
    try:
        # Verify tenant access
        if str(auth.get("tenant_id")) != tenant_id:
            raise HTTPException(status_code=403, detail="Access denied to this tenant")
        
        # Parse dates
        if from_date:
            start_date = datetime.fromisoformat(from_date.replace('Z', '+00:00'))
        else:
            start_date = datetime.now() - timedelta(days=30)
        
        if to_date:
            end_date = datetime.fromisoformat(to_date.replace('Z', '+00:00'))
        else:
            end_date = datetime.now()
        
        # Build query
        query = db.query(ValidationAnalytics).filter(
            ValidationAnalytics.tenant_id == tenant_id,
            ValidationAnalytics.validated_at.between(start_date, end_date)
        )
        
        # Apply filters
        if document_type:
            query = query.filter(ValidationAnalytics.document_type == document_type)
        
        if practice_area:
            query = query.filter(ValidationAnalytics.practice_area == practice_area)
        
        if validation_status:
            if validation_status.lower() == "passed":
                query = query.filter(ValidationAnalytics.validation_passed == True)
            elif validation_status.lower() == "failed":
                query = query.filter(ValidationAnalytics.validation_passed == False)
        
        # Get total count
        total_count = query.count()
        
        # Get paginated results
        documents = query.order_by(
            desc(ValidationAnalytics.validated_at)
        ).limit(limit).offset(offset).all()
        
        # Format results
        result = []
        for doc in documents:
            result.append({
                "id": str(doc.id),
                "document_id": doc.document_id,
                "document_type": doc.document_type,
                "practice_area": doc.practice_area,
                "validated_at": doc.validated_at.isoformat() if doc.validated_at else None,
                "validation_passed": doc.validation_passed,
                "errors_count": doc.errors_count,
                "warnings_count": doc.warnings_count,
                "info_count": doc.info_count,
                "validation_duration_ms": doc.validation_duration_ms,
                "user_id": doc.user_id
            })
        
        return {
            "documents": result,
            "total_count": total_count,
            "limit": limit,
            "offset": offset,
            "has_more": (offset + limit) < total_count
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error listing tenant documents: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to list tenant documents: {str(e)}")


@router.get("/documents/{document_id}")
async def get_document_validation_details(
    tenant_id: str,
    document_id: str,
    db: Session = Depends(get_db),
    auth: dict = Depends(require_tenant_access)
):
    """
    Get detailed validation results for a specific document
    
    Path Parameters:
        - tenant_id: UUID of the tenant
        - document_id: ID of the document
    
    Returns:
        Detailed validation results including all rules applied
    """
    try:
        # Verify tenant access
        if str(auth.get("tenant_id")) != tenant_id:
            raise HTTPException(status_code=403, detail="Access denied to this tenant")
        
        # Get validation record
        validation = db.query(ValidationAnalytics).filter(
            ValidationAnalytics.tenant_id == tenant_id,
            ValidationAnalytics.document_id == document_id
        ).order_by(
            desc(ValidationAnalytics.validated_at)
        ).first()
        
        if not validation:
            raise HTTPException(status_code=404, detail="Document validation not found")
        
        # In production, this would also include:
        # - Detailed rule-by-rule results
        # - Specific error messages and locations
        # - Suggested fixes
        # - Document metadata
        
        return {
            "id": str(validation.id),
            "document_id": validation.document_id,
            "document_type": validation.document_type,
            "practice_area": validation.practice_area,
            "validated_at": validation.validated_at.isoformat() if validation.validated_at else None,
            "validation_passed": validation.validation_passed,
            "errors_count": validation.errors_count,
            "warnings_count": validation.warnings_count,
            "info_count": validation.info_count,
            "validation_duration_ms": validation.validation_duration_ms,
            "user_id": validation.user_id,
            "validation_results": {
                "summary": {
                    "total_rules_applied": validation.errors_count + validation.warnings_count + validation.info_count,
                    "errors": validation.errors_count,
                    "warnings": validation.warnings_count,
                    "info": validation.info_count
                },
                "details": [
                    # In production, this would be actual rule results
                    {
                        "rule_name": "Example Rule",
                        "severity": "error",
                        "message": "This is an example validation result",
                        "location": "Page 1, Line 5"
                    }
                ]
            }
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting document validation details: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to get document validation details: {str(e)}")


@router.get("/analytics")
async def get_tenant_analytics(
    tenant_id: str,
    from_date: Optional[str] = Query(None, description="Start date (ISO format)"),
    to_date: Optional[str] = Query(None, description="End date (ISO format)"),
    db: Session = Depends(get_db),
    auth: dict = Depends(require_tenant_access)
):
    """
    Get analytics for a specific tenant
    
    Path Parameters:
        - tenant_id: UUID of the tenant
    
    Query Parameters:
        - from_date: Start date for analytics (ISO format)
        - to_date: End date for analytics (ISO format)
    
    Returns:
        Tenant-specific analytics including trends and breakdowns
    """
    try:
        # Verify tenant access
        if str(auth.get("tenant_id")) != tenant_id:
            raise HTTPException(status_code=403, detail="Access denied to this tenant")
        
        # Parse dates
        if from_date:
            start_date = datetime.fromisoformat(from_date.replace('Z', '+00:00'))
        else:
            start_date = datetime.now() - timedelta(days=30)
        
        if to_date:
            end_date = datetime.fromisoformat(to_date.replace('Z', '+00:00'))
        else:
            end_date = datetime.now()
        
        # Get validation data
        query = db.query(ValidationAnalytics).filter(
            ValidationAnalytics.tenant_id == tenant_id,
            ValidationAnalytics.validated_at.between(start_date, end_date)
        )
        
        total_validations = query.count()
        passed_validations = query.filter(ValidationAnalytics.validation_passed == True).count()
        
        # By document type
        by_document_type = db.query(
            ValidationAnalytics.document_type,
            func.count(ValidationAnalytics.id).label('count'),
            func.sum(ValidationAnalytics.errors_count).label('errors')
        ).filter(
            ValidationAnalytics.tenant_id == tenant_id,
            ValidationAnalytics.validated_at.between(start_date, end_date)
        ).group_by(
            ValidationAnalytics.document_type
        ).all()
        
        # By practice area
        by_practice_area = db.query(
            ValidationAnalytics.practice_area,
            func.count(ValidationAnalytics.id).label('count')
        ).filter(
            ValidationAnalytics.tenant_id == tenant_id,
            ValidationAnalytics.validated_at.between(start_date, end_date),
            ValidationAnalytics.practice_area.isnot(None)
        ).group_by(
            ValidationAnalytics.practice_area
        ).all()
        
        # Timeline
        timeline = db.query(
            func.date(ValidationAnalytics.validated_at).label('date'),
            func.count(ValidationAnalytics.id).label('validations')
        ).filter(
            ValidationAnalytics.tenant_id == tenant_id,
            ValidationAnalytics.validated_at.between(start_date, end_date)
        ).group_by(
            func.date(ValidationAnalytics.validated_at)
        ).order_by(
            func.date(ValidationAnalytics.validated_at)
        ).all()
        
        return {
            "overview": {
                "total_validations": total_validations,
                "success_rate": (passed_validations / total_validations * 100) if total_validations > 0 else 0
            },
            "by_document_type": [
                {
                    "document_type": row.document_type,
                    "count": row.count,
                    "errors": row.errors or 0
                }
                for row in by_document_type
            ],
            "by_practice_area": [
                {
                    "practice_area": row.practice_area,
                    "count": row.count
                }
                for row in by_practice_area
            ],
            "timeline": [
                {
                    "date": row.date.isoformat() if row.date else None,
                    "validations": row.validations
                }
                for row in timeline
            ]
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting tenant analytics: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to get tenant analytics: {str(e)}")


