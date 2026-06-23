"""
TrueVow LEVERAGE™ Service - Security Middleware
Handles security requirements for SaaS Admin integration:
1. X-API-Key header support (alternative to Bearer token)
2. UUID validation for tenant_id and resource IDs
3. Request size limits (5MB max)
4. Timeout configuration
5. Error sanitization (don't expose internals)
6. Audit logging infrastructure
"""

import re
import time
import logging
from typing import Optional, Callable
from uuid import UUID
from datetime import datetime

from fastapi import Request, Response, HTTPException, status
from fastapi.responses import JSONResponse
from starlette.middleware.base import BaseHTTPMiddleware
from pydantic import BaseModel

from app.core.config import get_settings

logger = logging.getLogger(__name__)
settings = get_settings()


# ============================================================================
# UUID VALIDATION
# ============================================================================

# RFC 4122 UUID regex pattern
UUID_PATTERN = re.compile(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    re.IGNORECASE
)


def is_valid_uuid(value: str) -> bool:
    """
    Validate UUID format (RFC 4122 compliant)
    
    Args:
        value: String to validate
        
    Returns:
        True if valid UUID, False otherwise
    """
    if not value:
        return False
    
    return bool(UUID_PATTERN.match(value))


def validate_uuid_strict(value: str, field_name: str = "id") -> UUID:
    """
    Validate and parse UUID strictly
    
    Args:
        value: String to validate
        field_name: Name of field for error message
        
    Returns:
        Parsed UUID
        
    Raises:
        HTTPException: If invalid UUID format
    """
    if not is_valid_uuid(value):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Invalid {field_name} format. Must be a valid UUID (RFC 4122)"
        )
    
    return UUID(value)


# ============================================================================
# X-API-KEY HEADER SUPPORT
# ============================================================================

async def get_api_key_from_request(request: Request) -> Optional[str]:
    """
    Extract API key from request headers
    Supports both Authorization: Bearer and X-API-Key headers
    
    Priority:
    1. Authorization: Bearer <api_key>
    2. X-API-Key: <api_key>
    
    Args:
        request: FastAPI request object
        
    Returns:
        API key string or None if not found
    """
    # Try Authorization header first
    auth_header = request.headers.get("Authorization")
    if auth_header and auth_header.startswith("Bearer "):
        return auth_header[7:]  # Strip "Bearer " prefix
    
    # Try X-API-Key header
    api_key = request.headers.get("X-API-Key")
    if api_key:
        return api_key
    
    return None


# ============================================================================
# ERROR SANITIZATION
# ============================================================================

class SanitizedError(BaseModel):
    """Sanitized error response model"""
    detail: str
    error_code: Optional[str] = None
    request_id: Optional[str] = None


def sanitize_error(error: Exception, include_trace: bool = False) -> dict:
    """
    Sanitize error messages to prevent information leakage
    
    Args:
        error: Exception to sanitize
        include_trace: Include stack trace (dev only)
        
    Returns:
        Sanitized error dict
    """
    # Map internal errors to safe messages
    error_str = str(error).lower()
    
    # Database errors
    if "database" in error_str or "postgresql" in error_str or "sqlalchemy" in error_str:
        return {
            "detail": "A database error occurred. Please try again later.",
            "error_code": "DATABASE_ERROR"
        }
    
    # Connection errors
    if "connection" in error_str or "timeout" in error_str:
        return {
            "detail": "Service temporarily unavailable. Please try again.",
            "error_code": "SERVICE_UNAVAILABLE"
        }
    
    # Authentication errors (already handled by auth module)
    if "unauthorized" in error_str or "authentication" in error_str:
        return {
            "detail": "Authentication failed.",
            "error_code": "AUTH_ERROR"
        }
    
    # Permission errors
    if "forbidden" in error_str or "permission" in error_str:
        return {
            "detail": "You don't have permission to perform this action.",
            "error_code": "PERMISSION_DENIED"
        }
    
    # Validation errors (safe to pass through)
    if "validation" in error_str:
        return {
            "detail": str(error),
            "error_code": "VALIDATION_ERROR"
        }
    
    # Default: generic error
    if settings.is_production:
        return {
            "detail": "An unexpected error occurred. Please try again later.",
            "error_code": "INTERNAL_ERROR"
        }
    else:
        # In development, include more details
        return {
            "detail": str(error),
            "error_code": "INTERNAL_ERROR"
        }


# ============================================================================
# REQUEST SIZE LIMITS
# ============================================================================

# Maximum request body size (5MB)
MAX_REQUEST_SIZE = 5 * 1024 * 1024  # 5MB in bytes

# Maximum request size per endpoint (can be customized)
ENDPOINT_SIZE_LIMITS = {
    "/api/v1/validation-rules/sync": 1 * 1024 * 1024,  # 1MB for rule sync
    "/api/v1/email/validation-log": 100 * 1024,  # 100KB for validation log
    "/api/v1/admin/templates": 5 * 1024 * 1024,  # 5MB for templates
}


def get_size_limit_for_path(path: str) -> int:
    """
    Get request size limit for a specific path
    
    Args:
        path: Request path
        
    Returns:
        Size limit in bytes
    """
    for endpoint, limit in ENDPOINT_SIZE_LIMITS.items():
        if path.startswith(endpoint):
            return limit
    
    return MAX_REQUEST_SIZE


# ============================================================================
# TIMEOUT CONFIGURATION
# ============================================================================

# Default timeout in seconds
DEFAULT_TIMEOUT = 10

# Endpoint-specific timeouts
ENDPOINT_TIMEOUTS = {
    "/api/v1/validation-rules/sync": 15,  # Rule sync may take longer
    "/api/v1/admin/templates": 20,  # Template operations
    "/api/v1/admin/analytics": 30,  # Analytics queries
    "/api/v1/admin/compliance/report": 60,  # Compliance reports
}


def get_timeout_for_path(path: str) -> int:
    """
    Get timeout for a specific path
    
    Args:
        path: Request path
        
    Returns:
        Timeout in seconds
    """
    for endpoint, timeout in ENDPOINT_TIMEOUTS.items():
        if path.startswith(endpoint):
            return timeout
    
    return DEFAULT_TIMEOUT


# ============================================================================
# AUDIT LOGGING
# ============================================================================

class AuditLogEntry(BaseModel):
    """Audit log entry model"""
    timestamp: str
    request_id: str
    method: str
    path: str
    tenant_id: Optional[str] = None
    user_id: Optional[str] = None
    api_key_prefix: Optional[str] = None
    status_code: int
    duration_ms: int
    client_ip: Optional[str] = None
    user_agent: Optional[str] = None
    error: Optional[str] = None


async def log_audit_entry(entry: AuditLogEntry) -> None:
    """
    Log audit entry for compliance
    
    Args:
        entry: Audit log entry
    """
    # Log to standard logger
    log_message = (
        f"AUDIT | {entry.method} {entry.path} | "
        f"status={entry.status_code} | "
        f"duration={entry.duration_ms}ms | "
        f"tenant={entry.tenant_id or 'N/A'} | "
        f"key_prefix={entry.api_key_prefix or 'N/A'}"
    )
    
    if entry.error:
        logger.warning(f"{log_message} | error={entry.error}")
    else:
        logger.info(log_message)
    
    # TODO: In production, also write to dedicated audit log table
    # await write_to_audit_table(entry)


# ============================================================================
# SECURITY MIDDLEWARE
# ============================================================================

class SecurityMiddleware(BaseHTTPMiddleware):
    """
    Security middleware that handles:
    1. X-API-Key header conversion to Authorization header
    2. Request size validation
    3. Timeout tracking
    4. Audit logging
    5. Error sanitization
    """
    
    async def dispatch(
        self,
        request: Request,
        call_next: Callable
    ) -> Response:
        """Process request with security checks"""
        
        start_time = time.time()
        request_id = request.headers.get("X-Request-ID", str(time.time_ns()))
        
        # 0. Convert X-API-Key header to Authorization header
        # This allows SaaS Admin to use X-API-Key while our auth uses Bearer
        if "X-API-Key" in request.headers and "Authorization" not in request.headers:
            # Create a new scope with the Authorization header added
            api_key = request.headers.get("X-API-Key")
            new_headers = list(request.scope["headers"])
            new_headers.append((b"authorization", f"Bearer {api_key}".encode()))
            request.scope["headers"] = new_headers
        
        # Store request_id for use in response
        request.state.request_id = request_id
        
        # 1. Check request size (only for requests with body)
        if request.method in ["POST", "PUT", "PATCH"]:
            content_length = request.headers.get("content-length")
            if content_length:
                try:
                    size = int(content_length)
                    max_size = get_size_limit_for_path(request.url.path)
                    
                    if size > max_size:
                        logger.warning(
                            f"Request too large: {size} bytes > {max_size} bytes for {request.url.path}"
                        )
                        return JSONResponse(
                            status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
                            content={
                                "detail": f"Request body too large. Maximum size: {max_size // 1024}KB",
                                "error_code": "REQUEST_TOO_LARGE",
                                "request_id": request_id
                            }
                        )
                except ValueError:
                    pass  # Invalid content-length, let FastAPI handle it
        
        # 2. Extract API key info for audit
        api_key = await get_api_key_from_request(request)
        api_key_prefix = api_key[:12] if api_key else None
        
        # 3. Get tenant_id from header (if present)
        tenant_id = request.headers.get("X-Tenant-ID")
        
        # 4. Process request and handle errors
        try:
            response = await call_next(request)
            
            # 5. Calculate duration
            duration_ms = int((time.time() - start_time) * 1000)
            
            # 6. Log audit entry
            await log_audit_entry(AuditLogEntry(
                timestamp=datetime.utcnow().isoformat(),
                request_id=request_id,
                method=request.method,
                path=request.url.path,
                tenant_id=tenant_id,
                api_key_prefix=api_key_prefix,
                status_code=response.status_code,
                duration_ms=duration_ms,
                client_ip=request.client.host if request.client else None,
                user_agent=request.headers.get("user-agent"),
            ))
            
            # 7. Add security headers to response
            response.headers["X-Request-ID"] = request_id
            response.headers["X-Content-Type-Options"] = "nosniff"
            response.headers["X-Frame-Options"] = "DENY"
            response.headers["X-XSS-Protection"] = "1; mode=block"
            
            return response
            
        except HTTPException:
            # Re-raise HTTP exceptions (already handled)
            raise
            
        except Exception as e:
            # 8. Sanitize unexpected errors
            duration_ms = int((time.time() - start_time) * 1000)
            
            # Log the actual error internally
            logger.exception(f"Unhandled error in {request.method} {request.url.path}")
            
            # Log audit entry with error
            await log_audit_entry(AuditLogEntry(
                timestamp=datetime.utcnow().isoformat(),
                request_id=request_id,
                method=request.method,
                path=request.url.path,
                tenant_id=tenant_id,
                api_key_prefix=api_key_prefix,
                status_code=500,
                duration_ms=duration_ms,
                client_ip=request.client.host if request.client else None,
                user_agent=request.headers.get("user-agent"),
                error=str(e),
            ))
            
            # Return sanitized error
            sanitized = sanitize_error(e)
            sanitized["request_id"] = request_id
            
            return JSONResponse(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                content=sanitized
            )


# ============================================================================
# URL WHITELIST (SSRF Prevention)
# ============================================================================

# Allowed external URLs for outbound requests
ALLOWED_EXTERNAL_URLS = [
    "http://localhost:8000",  # Tenant App
    "http://localhost:8001",  # SaaS Admin
    "http://localhost:8002",  # Other services
    # Add production URLs here
]


def is_url_allowed(url: str) -> bool:
    """
    Check if URL is in the whitelist (SSRF prevention)
    
    Args:
        url: URL to check
        
    Returns:
        True if allowed, False otherwise
    """
    for allowed in ALLOWED_EXTERNAL_URLS:
        if url.startswith(allowed):
            return True
    
    return False


def validate_url(url: str) -> None:
    """
    Validate URL against whitelist
    
    Args:
        url: URL to validate
        
    Raises:
        HTTPException: If URL is not allowed
    """
    if not is_url_allowed(url):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid URL. External URL not in whitelist."
        )


# ============================================================================
# RATE LIMIT HEADERS
# ============================================================================

def add_rate_limit_headers(
    response: Response,
    limit: int,
    remaining: int,
    reset_time: int
) -> None:
    """
    Add rate limit headers to response
    
    Args:
        response: Response object
        limit: Rate limit
        remaining: Remaining requests
        reset_time: Unix timestamp when limit resets
    """
    response.headers["X-RateLimit-Limit"] = str(limit)
    response.headers["X-RateLimit-Remaining"] = str(remaining)
    response.headers["X-RateLimit-Reset"] = str(reset_time)


# ============================================================================
# HELPER FUNCTIONS FOR ENDPOINTS
# ============================================================================

def validate_path_uuid(value: str, param_name: str = "id") -> UUID:
    """
    Validate UUID from path parameter
    
    Use in endpoints:
        @router.get("/{id}")
        async def get_item(id: str):
            validated_id = validate_path_uuid(id)
            ...
    
    Args:
        value: UUID string from path
        param_name: Parameter name for error message
        
    Returns:
        Validated UUID
        
    Raises:
        HTTPException: If invalid UUID
    """
    return validate_uuid_strict(value, param_name)


def validate_query_uuid(value: Optional[str], param_name: str = "id") -> Optional[UUID]:
    """
    Validate optional UUID from query parameter
    
    Args:
        value: UUID string from query (may be None)
        param_name: Parameter name for error message
        
    Returns:
        Validated UUID or None
        
    Raises:
        HTTPException: If invalid UUID format (when value is provided)
    """
    if value is None:
        return None
    
    return validate_uuid_strict(value, param_name)

