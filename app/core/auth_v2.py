"""
TrueVow LEVERAGE™ Service - Authentication & Authorization v2.0

Supports two access levels:
1. Admin API Keys (SaaS Admin): Manage global rule templates
2. Tenant API Keys (Law Firms): Manage tenant-specific rules

Zero-Knowledge Architecture:
- API keys are hashed (bcrypt), not encrypted
- Keys include only tenant_id and access_level
- NO document content ever transmitted
"""

import secrets
import hashlib
from datetime import datetime, timedelta
from typing import Optional, Dict, Any
from uuid import UUID

import bcrypt
from fastapi import HTTPException, Security, status, Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import Session

from app.models import APIKey
from app.core.database import get_db


security = HTTPBearer()


# ============================================================================
# API KEY GENERATION
# ============================================================================

def generate_api_key() -> str:
    """
    Generate a secure API key
    
    Format: draft_live_<40_random_chars>
    Example: draft_live_a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0
    
    Returns:
        Secure random API key
    """
    random_part = secrets.token_urlsafe(30)[:40]
    return f"draft_live_{random_part}"


def hash_api_key(api_key: str) -> str:
    """
    Hash API key with bcrypt
    
    Args:
        api_key: Raw API key
    
    Returns:
        Hashed API key
    """
    return bcrypt.hashpw(api_key.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')


def verify_api_key(api_key: str, key_hash: str) -> bool:
    """
    Verify API key against hash
    
    Args:
        api_key: Raw API key
        key_hash: Hashed API key from database
    
    Returns:
        True if key matches hash
    """
    return bcrypt.checkpw(api_key.encode('utf-8'), key_hash.encode('utf-8'))


def get_key_prefix(api_key: str) -> str:
    """
    Get first 12 characters of API key for identification
    
    Args:
        api_key: Raw API key
    
    Returns:
        Key prefix (first 12 chars)
    """
    return api_key[:12]


# ============================================================================
# API KEY AUTHENTICATION
# ============================================================================

async def get_api_key_from_header(
    credentials: HTTPAuthorizationCredentials = Security(security)
) -> str:
    """
    Extract API key from Authorization header or X-API-Key header
    
    Supports:
    1. Authorization: Bearer <api_key>
    2. X-API-Key: <api_key> (via middleware injection)
    
    Args:
        credentials: HTTP Authorization credentials
    
    Returns:
        Raw API key
    
    Raises:
        HTTPException: If authorization header is invalid
    """
    if not credentials:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Missing authorization header. Use 'Authorization: Bearer <api_key>' or 'X-API-Key: <api_key>'"
        )
    
    api_key = credentials.credentials
    
    if not api_key.startswith("draft_live_"):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid API key format. Expected format: draft_live_<key>"
        )
    
    return api_key


async def authenticate_api_key(
    api_key: str,
    db: Session
) -> Dict[str, Any]:
    """
    Authenticate API key and return key data
    
    Args:
        api_key: Raw API key
        db: Database session
    
    Returns:
        Dict with key data (id, access_level, tenant_id, etc.)
    
    Raises:
        HTTPException: If authentication fails
    """
    # Get key prefix for lookup
    key_prefix = get_key_prefix(api_key)
    
    # Find API key by prefix
    api_key_record = db.query(APIKey).filter(
        APIKey.key_prefix == key_prefix
    ).first()
    
    if not api_key_record:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid API key"
        )
    
    # Verify key hash
    if not verify_api_key(api_key, api_key_record.key_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid API key"
        )
    
    # Check if key is active
    if not api_key_record.is_active:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="API key is inactive"
        )
    
    # Check if key is revoked
    if api_key_record.revoked_at:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="API key has been revoked"
        )
    
    # Check if key is expired
    if api_key_record.expires_at and api_key_record.expires_at < datetime.now():
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="API key has expired"
        )
    
    # Update usage tracking
    api_key_record.last_used_at = datetime.now()
    api_key_record.usage_count += 1
    db.commit()
    
    # Return key data
    return {
        "key_id": api_key_record.id,
        "access_level": api_key_record.access_level,
        "tenant_id": api_key_record.tenant_id,
        "rate_limit_per_minute": api_key_record.rate_limit_per_minute,
        "rate_limit_per_hour": api_key_record.rate_limit_per_hour,
    }


# ============================================================================
# AUTHORIZATION DEPENDENCIES
# ============================================================================

async def require_admin_access(
    credentials: HTTPAuthorizationCredentials = Security(security),
    db: Session = Depends(get_db)
) -> Dict[str, Any]:
    """
    Require admin API key (for SaaS Admin)
    
    Usage in FastAPI endpoints:
        @router.post("/admin/rule-templates")
        async def create_template(
            api_key_data: dict = Depends(require_admin_access)
        ):
            # api_key_data["access_level"] == "admin"
            # api_key_data["tenant_id"] == None
    
    Args:
        credentials: HTTP Authorization credentials
        db: Database session (injected via Depends)
    
    Returns:
        API key data
    
    Raises:
        HTTPException: If not authenticated or not admin
    """
    api_key = await get_api_key_from_header(credentials)
    key_data = await authenticate_api_key(api_key, db)
    
    if key_data["access_level"] != "admin":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Admin access required"
        )
    
    return key_data


async def require_tenant_access(
    credentials: HTTPAuthorizationCredentials = Security(security),
    db: Session = Depends(get_db)
) -> Dict[str, Any]:
    """
    Require tenant API key (for Law Firms)
    
    Usage in FastAPI endpoints:
        @router.post("/tenant/rules")
        async def create_rule(
            api_key_data: dict = Depends(require_tenant_access),
            db: Session = Depends(get_db)
        ):
            # api_key_data["access_level"] == "tenant"
            # api_key_data["tenant_id"] == UUID
    
    Args:
        credentials: HTTP Authorization credentials
        db: Database session
    
    Returns:
        API key data (includes tenant_id)
    
    Raises:
        HTTPException: If not authenticated or not tenant
    """
    api_key = await get_api_key_from_header(credentials)
    key_data = await authenticate_api_key(api_key, db)
    
    if key_data["access_level"] != "tenant":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Tenant access required"
        )
    
    if not key_data["tenant_id"]:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Tenant API key missing tenant_id"
        )
    
    return key_data


async def require_any_access(
    credentials: HTTPAuthorizationCredentials = Security(security),
    db: Session = None
) -> Dict[str, Any]:
    """
    Require any valid API key (admin, tenant, or external)
    
    Usage in FastAPI endpoints:
        @router.get("/health")
        async def health_check(
            api_key_data: dict = Depends(require_any_access)
        ):
            # Any valid API key accepted
    
    Args:
        credentials: HTTP Authorization credentials
        db: Database session
    
    Returns:
        API key data
    
    Raises:
        HTTPException: If not authenticated
    """
    api_key = await get_api_key_from_header(credentials)
    key_data = await authenticate_api_key(api_key, db)
    
    return key_data


# ============================================================================
# TENANT ISOLATION HELPERS
# ============================================================================

def verify_tenant_access(api_key_data: Dict[str, Any], tenant_id: UUID) -> None:
    """
    Verify that API key has access to the specified tenant
    
    Rules:
    - Admin keys have access to all tenants
    - Tenant keys only have access to their own tenant
    
    Args:
        api_key_data: API key data from authentication
        tenant_id: Tenant ID to verify access to
    
    Raises:
        HTTPException: If access denied
    """
    if api_key_data["access_level"] == "admin":
        # Admin has access to all tenants
        return
    
    if api_key_data["access_level"] == "tenant":
        # Tenant can only access their own data
        if api_key_data["tenant_id"] != tenant_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Access denied to this tenant's data"
            )
        return
    
    # External keys have no tenant access
    raise HTTPException(
        status_code=status.HTTP_403_FORBIDDEN,
        detail="External API keys cannot access tenant data"
    )


def get_tenant_filter(api_key_data: Dict[str, Any]) -> Optional[UUID]:
    """
    Get tenant_id filter for database queries
    
    Rules:
    - Admin keys: Return None (no filter, access all tenants)
    - Tenant keys: Return tenant_id (filter to tenant's data)
    - External keys: Raise exception
    
    Args:
        api_key_data: API key data from authentication
    
    Returns:
        tenant_id to filter by, or None for admin (no filter)
    
    Raises:
        HTTPException: If external key tries to access tenant data
    """
    if api_key_data["access_level"] == "admin":
        return None  # No filter - admin sees all tenants
    
    if api_key_data["access_level"] == "tenant":
        return api_key_data["tenant_id"]  # Filter to tenant's data
    
    # External keys have no tenant access
    raise HTTPException(
        status_code=status.HTTP_403_FORBIDDEN,
        detail="External API keys cannot access tenant data"
    )


# ============================================================================
# API KEY MANAGEMENT (Admin Only)
# ============================================================================

def create_tenant_api_key(
    db: Session,
    tenant_id: UUID,
    description: Optional[str] = None,
    expires_in_days: Optional[int] = None,
    created_by: Optional[UUID] = None
) -> tuple[str, APIKey]:
    """
    Create a new tenant API key
    
    Args:
        db: Database session
        tenant_id: Tenant ID
        description: Key description
        expires_in_days: Expiration in days (None = never expires)
        created_by: User who created the key
    
    Returns:
        Tuple of (raw_api_key, api_key_record)
        NOTE: raw_api_key is only returned once, never stored
    """
    # Generate API key
    raw_api_key = generate_api_key()
    key_hash = hash_api_key(raw_api_key)
    key_prefix = get_key_prefix(raw_api_key)
    
    # Calculate expiration
    expires_at = None
    if expires_in_days:
        expires_at = datetime.now() + timedelta(days=expires_in_days)
    
    # Create API key record
    api_key = APIKey(
        key_hash=key_hash,
        key_prefix=key_prefix,
        access_level="tenant",
        tenant_id=tenant_id,
        description=description,
        expires_at=expires_at,
        created_by=created_by
    )
    
    db.add(api_key)
    db.commit()
    db.refresh(api_key)
    
    return raw_api_key, api_key


def create_admin_api_key(
    db: Session,
    description: Optional[str] = None,
    expires_in_days: Optional[int] = None,
    created_by: Optional[UUID] = None
) -> tuple[str, APIKey]:
    """
    Create a new admin API key
    
    Args:
        db: Database session
        description: Key description
        expires_in_days: Expiration in days (None = never expires)
        created_by: User who created the key
    
    Returns:
        Tuple of (raw_api_key, api_key_record)
        NOTE: raw_api_key is only returned once, never stored
    """
    # Generate API key
    raw_api_key = generate_api_key()
    key_hash = hash_api_key(raw_api_key)
    key_prefix = get_key_prefix(raw_api_key)
    
    # Calculate expiration
    expires_at = None
    if expires_in_days:
        expires_at = datetime.now() + timedelta(days=expires_in_days)
    
    # Create API key record
    api_key = APIKey(
        key_hash=key_hash,
        key_prefix=key_prefix,
        access_level="admin",
        tenant_id=None,  # Admin keys have no tenant
        description=description,
        expires_at=expires_at,
        created_by=created_by
    )
    
    db.add(api_key)
    db.commit()
    db.refresh(api_key)
    
    return raw_api_key, api_key


def revoke_api_key(db: Session, key_id: UUID) -> APIKey:
    """
    Revoke an API key
    
    Args:
        db: Database session
        key_id: API key ID to revoke
    
    Returns:
        Revoked API key record
    
    Raises:
        HTTPException: If key not found
    """
    api_key = db.query(APIKey).filter(APIKey.id == key_id).first()
    
    if not api_key:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="API key not found"
        )
    
    api_key.is_active = False
    api_key.revoked_at = datetime.now()
    
    db.commit()
    db.refresh(api_key)
    
    return api_key

