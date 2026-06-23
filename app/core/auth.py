"""
TrueVow LEVERAGE™ Service - Authentication & Authorization
Handles API key validation and access control
"""

from datetime import datetime, timedelta
from typing import Optional
from fastapi import Depends, HTTPException, Security, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from jose import JWTError, jwt
from sqlalchemy.orm import Session
from cryptography.fernet import Fernet

from app.core.config import get_settings
from app.core.database import get_db

settings = get_settings()
security = HTTPBearer()

# ============================================================================
# JWT TOKEN MANAGEMENT
# ============================================================================

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    """
    Create JWT access token
    
    Args:
        data: Data to encode in token
        expires_delta: Token expiration time
        
    Returns:
        Encoded JWT token
    """
    to_encode = data.copy()
    
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    
    to_encode.update({"exp": expire})
    
    encoded_jwt = jwt.encode(
        to_encode,
        settings.secret_key_computed,
        algorithm=settings.ALGORITHM
    )
    
    return encoded_jwt


def verify_token(token: str) -> dict:
    """
    Verify JWT token
    
    Args:
        token: JWT token to verify
        
    Returns:
        Decoded token data
        
    Raises:
        HTTPException: If token is invalid
    """
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    
    try:
        payload = jwt.decode(
            token,
            settings.secret_key_computed,
            algorithms=[settings.ALGORITHM]
        )
        return payload
    except JWTError:
        raise credentials_exception


# ============================================================================
# API KEY ENCRYPTION/DECRYPTION
# ============================================================================

def get_encryption_cipher() -> Fernet:
    """
    Get Fernet cipher for API key encryption
    
    Returns:
        Fernet cipher instance
    """
    return Fernet(settings.api_key_encryption_key_computed.encode())


def encrypt_api_key(api_key: str) -> str:
    """
    Encrypt API key before storing in database
    
    Args:
        api_key: Plain text API key
        
    Returns:
        Encrypted API key (base64 encoded)
    """
    cipher = get_encryption_cipher()
    encrypted = cipher.encrypt(api_key.encode())
    return encrypted.decode()


def decrypt_api_key(encrypted_key: str) -> str:
    """
    Decrypt API key from database
    
    Args:
        encrypted_key: Encrypted API key (base64 encoded)
        
    Returns:
        Plain text API key
    """
    cipher = get_encryption_cipher()
    decrypted = cipher.decrypt(encrypted_key.encode())
    return decrypted.decode()


# ============================================================================
# API KEY VALIDATION
# ============================================================================

class APIKeyAccess:
    """
    API key access levels
    """
    TENANT = "tenant"          # Tenant access (sync validation rules)
    ADMIN = "admin"            # SaaS Admin management
    EXTERNAL = "external"      # Non-customers (pay-per-use)


async def validate_api_key(
    credentials: HTTPAuthorizationCredentials = Security(security),
    db: Session = Depends(get_db)
) -> dict:
    """
    Validate API key from Authorization header
    
    Args:
        credentials: HTTP Bearer credentials
        db: Database session
        
    Returns:
        API key data (tenant_id, access_level, etc.)
        
    Raises:
        HTTPException: If API key is invalid or expired
    """
    api_key = credentials.credentials
    
    # Import here to avoid circular imports
    from app.models.validation_rule_v2 import APIKey
    
    # Query database for API key
    db_api_key = db.query(APIKey).filter(
        APIKey.is_active == True  # noqa: E712
    ).all()
    
    # Check each API key (encrypted in database)
    for key_record in db_api_key:
        try:
            decrypted_key = decrypt_api_key(key_record.encrypted_key)
            
            if decrypted_key == api_key:
                # Check if key is expired
                if key_record.expires_at and key_record.expires_at < datetime.utcnow():
                    raise HTTPException(
                        status_code=status.HTTP_401_UNAUTHORIZED,
                        detail="API key has expired",
                    )
                
                # Update last used timestamp
                key_record.last_used_at = datetime.utcnow()
                db.commit()
                
                return {
                    "api_key_id": key_record.id,
                    "tenant_id": key_record.tenant_id,
                    "access_level": key_record.access_level,
                    "description": key_record.description,
                }
        except Exception:
            continue
    
    # API key not found
    raise HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Invalid API key",
    )


async def require_admin_access(
    api_key_data: dict = Depends(validate_api_key)
) -> dict:
    """
    Require admin access level
    
    Args:
        api_key_data: API key data from validate_api_key
        
    Returns:
        API key data
        
    Raises:
        HTTPException: If access level is not admin
    """
    if api_key_data["access_level"] != APIKeyAccess.ADMIN:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Admin access required",
        )
    
    return api_key_data


async def require_tenant_access(
    api_key_data: dict = Depends(validate_api_key)
) -> dict:
    """
    Require tenant access level (or higher)
    
    Args:
        api_key_data: API key data from validate_api_key
        
    Returns:
        API key data
        
    Raises:
        HTTPException: If access level is not tenant or admin
    """
    allowed_levels = [APIKeyAccess.TENANT, APIKeyAccess.ADMIN]
    
    if api_key_data["access_level"] not in allowed_levels:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Tenant access required",
        )
    
    return api_key_data


# ============================================================================
# VALIDATION RULES ENCRYPTION (for client sync)
# ============================================================================

def get_rules_encryption_cipher() -> Fernet:
    """
    Get Fernet cipher for validation rules encryption
    
    Returns:
        Fernet cipher instance
    """
    return Fernet(settings.rules_encryption_key_computed.encode())


def encrypt_validation_rules(rules_data: str) -> str:
    """
    Encrypt validation rules before sending to client
    
    Args:
        rules_data: JSON string of validation rules
        
    Returns:
        Encrypted rules data (base64 encoded)
    """
    cipher = get_rules_encryption_cipher()
    encrypted = cipher.encrypt(rules_data.encode())
    return encrypted.decode()


def decrypt_validation_rules(encrypted_data: str) -> str:
    """
    Decrypt validation rules (client-side operation)
    
    Args:
        encrypted_data: Encrypted rules data (base64 encoded)
        
    Returns:
        Decrypted JSON string of validation rules
    """
    cipher = get_rules_encryption_cipher()
    decrypted = cipher.decrypt(encrypted_data.encode())
    return decrypted.decode()


# ============================================================================
# RATE LIMITING (TODO: Implement with Redis)
# ============================================================================

async def check_rate_limit(
    api_key_data: dict = Depends(validate_api_key)
) -> None:
    """
    Check rate limit for API key
    
    Args:
        api_key_data: API key data
        
    Raises:
        HTTPException: If rate limit exceeded
        
    Note:
        This is a placeholder. Implement with Redis for production.
    """
    # TODO: Implement rate limiting with Redis
    # For now, just pass through
    pass

