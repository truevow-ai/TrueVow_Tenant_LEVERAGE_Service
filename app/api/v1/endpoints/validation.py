"""
TrueVow DRAFT™ Service - Server-Side Validation API Endpoints
Endpoints for server-side document validation
"""

from typing import Optional, List
from datetime import date
from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File, Form
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session
from sqlalchemy import text
import asyncio

from app.core.database import get_db
# from app.core.auth import require_tenant_access  # TODO: Add auth when ready
from app.services.document_parser import parse_document
from app.services.validation_engine import validate_document as validate_document_engine
from app.services.validation_rules_sync import ValidationRulesSyncService
import logging

logger = logging.getLogger(__name__)

from app.core.event_emitter import DraftEventEmitter  # noqa: E402
from app.services.billing_service import (
    get_billing_service,
    BillingServiceUnavailable,
    DraftAccessDenied,  # Backward compat alias for LeverageAccessDenied
    TenantNotFound,
)  # noqa: E402



router = APIRouter(prefix="/validation", tags=["Validation"])


# ============================================================================
# PYDANTIC SCHEMAS
# ============================================================================

class ValidateDocumentRequest(BaseModel):
    """Request schema for document validation"""
    tenant_id: str = Field(..., description="Tenant ID")
    document_type: str = Field(..., description="Document type (e.g., demand_letter)")
    jurisdiction: Optional[str] = Field(None, description="Jurisdiction (e.g., arizona)")
    practice_area: Optional[str] = Field(None, description="Practice area")
    document_text: str = Field(..., description="Document text to validate")
    incident_date: Optional[date] = Field(
        None,
        description="Date of incident/injury (YYYY-MM-DD) — enables SOL deadline in response"
    )
    
    class Config:
        json_schema_extra = {
            "example": {
                "tenant_id": "test-tenant-123",
                "document_type": "demand_letter",
                "jurisdiction": "arizona",
                "practice_area": "personal_injury",
                "document_text": "Smith & Associates Law Firm\n123 Main Street\n...",
                "incident_date": "2024-03-15"
            }
        }


class ValidationResponse(BaseModel):
    """Response schema for validation results"""
    validation_passed: bool
    errors_count: int
    warnings_count: int
    info_count: int
    total_rules_checked: int
    validation_duration_ms: int
    errors: list
    warnings: list
    info: list
    deadline_summary: Optional[dict] = None
    billing: Optional[dict] = None  # charged, reward_used, price_cents


# ============================================================================
# API ENDPOINTS
# ============================================================================

@router.post("/validate", response_model=ValidationResponse, status_code=status.HTTP_200_OK)
async def validate_document_endpoint(
    request: ValidateDocumentRequest,
    db: Session = Depends(get_db),
    # tenant_access = Depends(require_tenant_access)  # TODO: Add auth
):
    """
    Validate document text against compliance rules (LEVERAGE pillar).

    Billing gate (fail-open):
    - Checks if LEVERAGE is enabled for the tenant's plan.
    - If enabled AND tenant has reward credits → consumes one credit (free).
    - Validation runs are included in subscription (no per-use charge in v1).
    - If billing is unavailable → proceeds (fail-open).
    - If explicitly disabled → returns 403.
    """
    try:
        # -- Billing gate --
        billing = get_billing_service()
        billing_allowed = True   # fail-open default
        billing_metadata: dict = {"charged": False, "included_in_subscription": True}
        
        try:
            access = await billing.get_leverage_access(request.tenant_id)
            if not access.enabled:
                raise DraftAccessDenied("LEVERAGE not enabled for your plan")
        
            # v1: Validation runs are included in subscription tier, no per-use charge
            billing_metadata = {
                "charged": False,
                "included_in_subscription": True,
                "tier": access.tier.value if access.tier else None,
            }
        
        except DraftAccessDenied as exc:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail=str(exc))
        except TenantNotFound:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Tenant not found in billing system",
            )
        except BillingServiceUnavailable:
            # Fail-open: proceed and reconcile later
            logger.warning(
                "leverage/validate: billing unavailable for tenant %s — proceeding (fail-open)",
                request.tenant_id,
            )
            billing_metadata = {"charged": False, "billing_unavailable": True}
        except Exception as exc:
            # Any other billing error -> fail-open
            logger.warning(
                "leverage/validate: unexpected billing error for %s — %s — proceeding (fail-open)",
                request.tenant_id, exc,
            )
            billing_metadata = {"charged": False, "billing_error": str(exc)}

        # ── Validation logic ──────────────────────────────────────────────────
        from uuid import UUID
        
        # Try to convert tenant_id to UUID, but handle string IDs gracefully
        tenant_uuid = None
        if request.tenant_id:
            try:
                tenant_uuid = UUID(request.tenant_id)
            except (ValueError, AttributeError):
                # If tenant_id is not a valid UUID, try to use it as-is
                # Some systems use string tenant IDs
                pass
        
        # Get rules from sync service
        try:
            sync_service = ValidationRulesSyncService(db)
            if tenant_uuid:
                sync_result = sync_service.get_validation_rules(
                    tenant_id=tenant_uuid,
                    document_type=request.document_type,
                    jurisdiction_state=request.jurisdiction,
                    practice_area=request.practice_area
                )
            else:
                # If no valid UUID, return empty rules (will result in passing validation)
                sync_result = {"validation_rules": []}
        except Exception as e:
            logger.warning(f"Error getting rules from sync service: {e}. Using empty rules.")
            sync_result = {"validation_rules": []}
        
        rules_data = sync_result.get("validation_rules", [])
        
        # Convert to validation engine format
        rules = []
        for rule_data in rules_data:
            # Handle both dict and object formats
            if isinstance(rule_data, dict):
                rule_id = rule_data.get("rule_id") or rule_data.get("id")
                rule_name = rule_data.get("rule_name", "")
                rule_type = rule_data.get("rule_type", "")
                severity = rule_data.get("severity", "error")
                rule_config = rule_data.get("rule_config", {})
            else:
                # Object format
                rule_id = getattr(rule_data, "rule_id", None) or getattr(rule_data, "id", None)
                rule_name = getattr(rule_data, "rule_name", "")
                rule_type = getattr(rule_data, "rule_type", "")
                severity = getattr(rule_data, "severity", "error")
                rule_config = getattr(rule_data, "rule_config", {}) or {}
            
            if rule_id:  # Only add if rule has an ID
                rules.append({
                    "id": str(rule_id),
                    "rule_name": rule_name,
                    "rule_type": rule_type,
                    "severity": severity,
                    "rule_config": rule_config if isinstance(rule_config, dict) else {}
                })
        
        # If no rules found, return passing validation (document passes if no rules to check)
        if not rules:
            return ValidationResponse(
                validation_passed=True,
                errors_count=0,
                warnings_count=0,
                info_count=0,
                total_rules_checked=0,
                validation_duration_ms=0,
                errors=[],
                warnings=[],
                info=[]
            )
        
        # Validate document
        result = validate_document_engine(request.document_text, rules)

        # ── Behavioral event ─────────────────────────────────────────────────
        _event_type = "document_validated" if result.get("validation_passed") else "document_validation_failed"
        import asyncio as _asyncio
        _asyncio.ensure_future(
            DraftEventEmitter(tenant_id=request.tenant_id).emit(
                _event_type,
                metadata={
                    "document_type":  request.document_type,
                    "practice_area":  request.practice_area,
                    "document_id":    request.document_id if hasattr(request, "document_id") else None,
                    "errors_count":   result.get("errors_count", 0),
                    "warnings_count": result.get("warnings_count", 0),
                    "rules_checked":  result.get("total_rules_checked", 0),
                    "source":         "draft-service",
                },
            )
        )

        # ── Deadline summary (optional — only when incident_date is provided) ─
        deadline_summary = None
        if request.incident_date and request.jurisdiction:
            try:
                from app.api.v1.endpoints.deadlines import (
                    _query_sol,
                    _build_sol_deadline,
                    _build_eeoc_deadline,
                    _days_remaining,
                    _urgency,
                )
                state = request.jurisdiction.upper()
                deadlines_out = []

                # PI SOL deadline
                if request.practice_area == "personal_injury":
                    sol_cfg = _query_sol(db, state, "personal_injury")
                    if sol_cfg:
                        item = _build_sol_deadline(request.incident_date, sol_cfg)
                        deadlines_out.append(item.model_dump())

                # EEOC deadline (employment law)
                if request.practice_area == "employment_law":
                    item = _build_eeoc_deadline(request.incident_date, state)
                    deadlines_out.append(item.model_dump())

                if deadlines_out:
                    deadline_summary = {
                        "jurisdiction_state": state,
                        "practice_area": request.practice_area,
                        "calculated_on": str(date.today()),
                        "deadlines": deadlines_out,
                    }
            except Exception as dl_exc:
                logger.warning("Deadline summary failed (non-fatal): %s", dl_exc)

        result["deadline_summary"] = deadline_summary
        result["billing"] = billing_metadata if billing_metadata else None
        return ValidationResponse(**result)
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Validation failed: {str(e)}"
        )


@router.post("/validate-file", response_model=ValidationResponse, status_code=status.HTTP_200_OK)
async def validate_file_endpoint(
    file: UploadFile = File(...),
    tenant_id: str = Form(...),
    document_type: str = Form(...),
    jurisdiction: Optional[str] = Form(None),
    practice_area: Optional[str] = Form(None),
    db: Session = Depends(get_db),
    # tenant_access = Depends(require_tenant_access)  # TODO: Add auth
):
    """
    Validate uploaded document file (PDF, DOCX) against compliance rules.
    
    **Supported File Types:**
    - PDF (application/pdf)
    - DOCX (application/vnd.openxmlformats-officedocument.wordprocessingml.document)
    - DOC (application/msword)
    - TXT (text/plain)
    
    **Note:** This endpoint performs server-side validation.
    For zero-knowledge architecture, use client-side validation with rules sync.
    
    **Example:**
    ```bash
    curl -X POST "http://localhost:8003/api/v1/validation/validate-file" \
      -F "file=@demand_letter.pdf" \
      -F "tenant_id=test-tenant-123" \
      -F "document_type=demand_letter" \
      -F "jurisdiction=arizona"
    ```
    """
    try:
        # Read file content
        content = await file.read()
        
        # Parse document
        parse_result = parse_document(content, file.content_type or "", file.filename)
        
        if not parse_result.get("parse_success"):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Failed to parse document: {parse_result.get('error', 'Unknown error')}"
            )
        
        document_text = parse_result.get("text", "")
        
        if not document_text:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Document appears to be empty or could not extract text"
            )
        
        # Get validation rules
        from uuid import UUID
        
        tenant_uuid = None
        if tenant_id:
            try:
                tenant_uuid = UUID(tenant_id)
            except (ValueError, AttributeError):
                pass
        
        try:
            sync_service = ValidationRulesSyncService(db)
            if tenant_uuid:
                sync_result = sync_service.get_validation_rules(
                    tenant_id=tenant_uuid,
                    document_type=document_type,
                    jurisdiction_state=jurisdiction,
                    practice_area=practice_area
                )
            else:
                sync_result = {"validation_rules": []}
        except Exception as e:
            logger.warning(f"Error getting rules: {e}")
            sync_result = {"validation_rules": []}
        
        rules_data = sync_result.get("validation_rules", [])
        
        # Convert to validation engine format
        rules = []
        for rule_data in rules_data:
            if isinstance(rule_data, dict):
                rule_id = rule_data.get("rule_id") or rule_data.get("id")
                rule_name = rule_data.get("rule_name", "")
                rule_type = rule_data.get("rule_type", "")
                severity = rule_data.get("severity", "error")
                rule_config = rule_data.get("rule_config", {})
            else:
                rule_id = getattr(rule_data, "rule_id", None) or getattr(rule_data, "id", None)
                rule_name = getattr(rule_data, "rule_name", "")
                rule_type = getattr(rule_data, "rule_type", "")
                severity = getattr(rule_data, "severity", "error")
                rule_config = getattr(rule_data, "rule_config", {}) or {}
            
            if rule_id:
                rules.append({
                    "id": str(rule_id),
                    "rule_name": rule_name,
                    "rule_type": rule_type,
                    "severity": severity,
                    "rule_config": rule_config if isinstance(rule_config, dict) else {}
                })
        
        # If no rules, return passing validation
        if not rules:
            result = {
                "validation_passed": True,
                "errors_count": 0,
                "warnings_count": 0,
                "info_count": 0,
                "total_rules_checked": 0,
                "validation_duration_ms": 0,
                "errors": [],
                "warnings": [],
                "info": []
            }
        else:
            # Validate document
            result = validate_document_engine(document_text, rules)
        
        if not rules:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"No validation rules found for document_type={document_type}, jurisdiction={jurisdiction}"
            )
        
        # Validate document
        result = validate_document_engine(document_text, rules)
        
        # Add parsing metadata to response
        result["parse_success"] = True
        result["document_metadata"] = parse_result.get("metadata", {})
        
        return ValidationResponse(**result)
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Validation failed: {str(e)}"
        )


@router.get("/rules", status_code=status.HTTP_200_OK)
async def get_validation_rules(
    tenant_id: str,
    document_type: Optional[str] = None,
    jurisdiction: Optional[str] = None,
    practice_area: Optional[str] = None,
    db: Session = Depends(get_db),
    # tenant_access = Depends(require_tenant_access)  # TODO: Add auth
):
    """
    Get validation rules for a tenant.
    
    **Example:**
    ```bash
    curl "http://localhost:8003/api/v1/validation/rules?tenant_id=test-tenant-123&document_type=demand_letter&jurisdiction=arizona"
    ```
    """
    try:
        from uuid import UUID
        # Try to convert tenant_id to UUID
        tenant_uuid = None
        if tenant_id:
            try:
                tenant_uuid = UUID(tenant_id)
            except (ValueError, AttributeError):
                # Invalid UUID format, will return empty rules
                pass
        
        try:
            sync_service = ValidationRulesSyncService(db)
            if tenant_uuid:
                sync_result = sync_service.get_validation_rules(
                    tenant_id=tenant_uuid,
                    document_type=document_type,
                    jurisdiction_state=jurisdiction,
                    practice_area=practice_area
                )
            else:
                sync_result = {"validation_rules": []}
        except Exception as e:
            logger.warning(f"Error getting rules: {e}")
            sync_result = {"validation_rules": []}
        
        rules_data = sync_result.get("validation_rules", [])
        
        return {
            "rules": rules_data,
            "total": len(rules_data)
        }
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to retrieve rules: {str(e)}"
        )


class BatchValidationRequest(BaseModel):
    """Request schema for batch document validation"""
    tenant_id: str = Field(..., description="Tenant ID")
    document_type: str = Field(..., description="Document type (e.g., demand_letter)")
    jurisdiction: Optional[str] = Field(None, description="Jurisdiction (e.g., arizona)")
    practice_area: Optional[str] = Field(None, description="Practice area")
    documents: List[str] = Field(..., description="List of document texts to validate", min_items=1, max_items=100)
    
    class Config:
        json_schema_extra = {
            "example": {
                "tenant_id": "test-tenant-123",
                "document_type": "demand_letter",
                "jurisdiction": "arizona",
                "practice_area": "personal_injury",
                "documents": [
                    "Smith & Associates Law Firm\n123 Main Street\n...",
                    "Johnson Legal Group\n456 Oak Avenue\n..."
                ]
            }
        }


class BatchValidationItem(BaseModel):
    """Individual validation result in batch"""
    document_index: int
    validation_passed: bool
    errors_count: int
    warnings_count: int
    info_count: int
    total_rules_checked: int
    validation_duration_ms: int
    errors: list
    warnings: list
    info: list


class BatchValidationResponse(BaseModel):
    """Response schema for batch validation results"""
    total_documents: int
    passed_count: int
    failed_count: int
    total_validation_duration_ms: int
    results: List[BatchValidationItem]
    summary: dict


@router.post("/validate-batch", response_model=BatchValidationResponse, status_code=status.HTTP_200_OK)
async def validate_batch_endpoint(
    request: BatchValidationRequest,
    db: Session = Depends(get_db),
    # tenant_access = Depends(require_tenant_access)  # TODO: Add auth
):
    """
    Validate multiple documents in batch against compliance rules.
    
    **Note:** This endpoint performs server-side batch validation.
    Maximum 100 documents per batch.
    
    **Example:**
    ```json
    {
        "tenant_id": "test-tenant-123",
        "document_type": "demand_letter",
        "jurisdiction": "arizona",
        "practice_area": "personal_injury",
        "documents": [
            "Document 1 text...",
            "Document 2 text...",
            "Document 3 text..."
        ]
    }
    ```
    """
    import time
    start_time = time.time()
    
    try:
        # Validate batch size
        if len(request.documents) > 100:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Maximum 100 documents per batch"
            )
        
        # Get validation rules for tenant (same as single validation)
        from uuid import UUID
        
        tenant_uuid = None
        if request.tenant_id:
            try:
                tenant_uuid = UUID(request.tenant_id)
            except (ValueError, AttributeError):
                pass
        
        try:
            sync_service = ValidationRulesSyncService(db)
            if tenant_uuid:
                sync_result = sync_service.get_validation_rules(
                    tenant_id=tenant_uuid,
                    document_type=request.document_type,
                    jurisdiction_state=request.jurisdiction,
                    practice_area=request.practice_area
                )
            else:
                sync_result = {"validation_rules": []}
        except Exception as e:
            logger.warning(f"Error getting rules from sync service: {e}. Using empty rules.")
            sync_result = {"validation_rules": []}
        
        rules_data = sync_result.get("validation_rules", [])
        
        # Convert to validation engine format
        rules = []
        for rule_data in rules_data:
            if isinstance(rule_data, dict):
                rule_id = rule_data.get("rule_id") or rule_data.get("id")
                rule_name = rule_data.get("rule_name", "")
                rule_type = rule_data.get("rule_type", "")
                severity = rule_data.get("severity", "error")
                rule_config = rule_data.get("rule_config", {})
            else:
                rule_id = getattr(rule_data, "rule_id", None) or getattr(rule_data, "id", None)
                rule_name = getattr(rule_data, "rule_name", "")
                rule_type = getattr(rule_data, "rule_type", "")
                severity = getattr(rule_data, "severity", "error")
                rule_config = getattr(rule_data, "rule_config", {}) or {}
            
            if rule_id:
                rules.append({
                    "id": str(rule_id),
                    "rule_name": rule_name,
                    "rule_type": rule_type,
                    "severity": severity,
                    "rule_config": rule_config if isinstance(rule_config, dict) else {}
                })
        
        # If no rules found, all documents pass
        if not rules:
            results = []
            for idx, _ in enumerate(request.documents):
                results.append(BatchValidationItem(
                    document_index=idx,
                    validation_passed=True,
                    errors_count=0,
                    warnings_count=0,
                    info_count=0,
                    total_rules_checked=0,
                    validation_duration_ms=0,
                    errors=[],
                    warnings=[],
                    info=[]
                ))
            
            total_duration = int((time.time() - start_time) * 1000)
            return BatchValidationResponse(
                total_documents=len(request.documents),
                passed_count=len(request.documents),
                failed_count=0,
                total_validation_duration_ms=total_duration,
                results=results,
                summary={
                    "total_rules": 0,
                    "average_validation_time_ms": 0,
                    "overall_success_rate": 100.0
                }
            )
        
        # Validate each document
        results = []
        for idx, document_text in enumerate(request.documents):
            doc_start_time = time.time()
            result = validate_document_engine(document_text, rules)
            doc_duration = int((time.time() - doc_start_time) * 1000)
            
            results.append(BatchValidationItem(
                document_index=idx,
                validation_passed=result.get("validation_passed", False),
                errors_count=result.get("errors_count", 0),
                warnings_count=result.get("warnings_count", 0),
                info_count=result.get("info_count", 0),
                total_rules_checked=result.get("total_rules_checked", 0),
                validation_duration_ms=doc_duration,
                errors=result.get("errors", []),
                warnings=result.get("warnings", []),
                info=result.get("info", [])
            ))
        
        # Calculate summary
        total_duration = int((time.time() - start_time) * 1000)
        passed_count = sum(1 for r in results if r.validation_passed)
        failed_count = len(results) - passed_count
        avg_validation_time = sum(r.validation_duration_ms for r in results) / len(results) if results else 0
        success_rate = (passed_count / len(results) * 100) if results else 0
        
        return BatchValidationResponse(
            total_documents=len(request.documents),
            passed_count=passed_count,
            failed_count=failed_count,
            total_validation_duration_ms=total_duration,
            results=results,
            summary={
                "total_rules": len(rules),
                "average_validation_time_ms": int(avg_validation_time),
                "overall_success_rate": round(success_rate, 2)
            }
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Batch validation failed: {str(e)}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Batch validation failed: {str(e)}"
        )

