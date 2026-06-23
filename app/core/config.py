"""
TrueVow LEVERAGE™ Service - Configuration Management
Handles all application configuration from environment variables
"""

from typing import List, Optional
from pydantic import Field, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """
    Application settings loaded from environment variables
    """
    
    # ========================================================================
    # APPLICATION SETTINGS
    # ========================================================================
    APP_NAME: str = "TrueVow LEVERAGE Service"
    APP_VERSION: str = "1.0.0"
    APP_ENVIRONMENT: str = "development"
    DEBUG: bool = True
    LOG_LEVEL: str = "INFO"
    
    # ========================================================================
    # SERVER SETTINGS
    # ========================================================================
    HOST: str = "0.0.0.0"
    PORT: int = 8003
    RELOAD: bool = True
    
    # ========================================================================
    # DATABASE SETTINGS
    # ========================================================================
    # DRAFT uses the Tenant Application database (same as INTAKE)
    DATABASE_HOST: str = "localhost"
    DATABASE_PORT: int = 5432
    DATABASE_NAME: str = "truevow_draft"
    DATABASE_USER: str = "postgres"
    DATABASE_PASSWORD: Optional[str] = None  # Optional if using DATABASE_URL
    DATABASE_POOL_SIZE: int = 20
    DATABASE_MAX_OVERFLOW: int = 10
    DATABASE_ECHO: bool = False
    
    # Use DATABASE_URL (preferred) - maps to TENANT_APPLICATION_DATABASE_URL
    DATABASE_URL: Optional[str] = None
    TENANT_APPLICATION_DATABASE_URL: Optional[str] = None  # Alternative name
    TENANT_APPLICATION_DATABASE_POOLER_URL: Optional[str] = None  # Pooler URL (preferred for external connections)

    # LEVERAGE-specific database URLs (highest priority)
    LEVERAGE_DATABASE_SESSION_POOLER_URL: Optional[str] = None  # Preferred for external connections
    LEVERAGE_DATABASE_DIRECT_CONNECTION_URL: Optional[str] = None  # Direct connection for migrations/scripts
    LEVERAGE_DATABASE_TRANSACTION_POOLER_URL: Optional[str] = None  # Transaction pooler (port 6543)

    # TrueVow TENANT LEVERAGE APP naming (same DB, different env var prefix)
    TENANT_LEVERAGE_APP_DATABASE_URL: Optional[str] = None  # Supabase project URL (https://...)
    TENANT_LEVERAGE_APP_DATABASE_PUBLISHABLE_KEY: Optional[str] = None
    TENANT_LEVERAGE_APP_DATABASE_PUBLISHABLE_API_KEY: Optional[str] = None
    TENANT_LEVERAGE_APP_DATABASE_API_SECRET_KEY: Optional[str] = None
    TENANT_LEVERAGE_APP_DATABASE_LEVERAGE_API_SECRET_KEY: Optional[str] = None
    TENANT_LEVERAGE_APP_DATABASE_SESSION_POOLER_URL: Optional[str] = None  # Preferred for external connections
    TENANT_LEVERAGE_APP_DATABASE_TRANSACTION_POOLER_URL: Optional[str] = None  # Transaction pooler (port 6543)
    TENANT_LEVERAGE_APP_DATABASE_DIRECT_CONNECTION_URL: Optional[str] = None  # Direct connection for migrations/scripts
    TENANT_LEVERAGE_APP_DATABASE_JWT_SIGNING_KEY: Optional[str] = None
    TENANT_LEVERAGE_APP_DATABASE_SERVICE_ROLE_KEY: Optional[str] = None
    TENANT_LEVERAGE_APP_DATABASE_ANON_KEY: Optional[str] = None
    TENANT_LEVERAGE_APP_DATABASE_NAME: Optional[str] = None
    TENANT_LEVERAGE_APP_DATABASE_PROJECT_ID: Optional[str] = None
    
    # ========================================================================
    # AUTHENTICATION & SECURITY
    # ========================================================================
    # JWT Secret - use DRAFT_SERVICE_API_KEY as fallback
    SECRET_KEY: Optional[str] = None
    DRAFT_SERVICE_API_KEY: Optional[str] = None  # Alternative - used as SECRET_KEY
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    
    # API key encryption (Fernet key) - required for production
    API_KEY_ENCRYPTION_KEY: Optional[str] = None
    
    # ========================================================================
    # VALIDATION RULES ENCRYPTION
    # ========================================================================
    # Encryption key for validation rules sync (Fernet key)
    RULES_ENCRYPTION_KEY: Optional[str] = None
    
    # ========================================================================
    # CORS SETTINGS
    # ========================================================================
    ALLOWED_ORIGINS: str = "http://localhost:3000,http://localhost:5173,http://localhost:8000"
    ALLOW_CREDENTIALS: bool = True
    ALLOWED_METHODS: str = "GET,POST,PUT,DELETE,OPTIONS"
    ALLOWED_HEADERS: str = "*"
    
    # ========================================================================
    # INTEGRATION SETTINGS
    # ========================================================================
    TENANT_APP_API_URL: str = "http://localhost:8000/api/v1"
    SAAS_ADMIN_API_URL: str = "http://localhost:8001/api/v1"
    
    # Billing Service (unified feature-access endpoint)
    # Endpoint: GET /api/v1/billing/tenants/{tenant_id}/feature-access
    TENANT_BILLING_SERVICE_URL: str = "http://localhost:3004"
    TENANT_BILLING_SERVICE_API_KEY: Optional[str] = None
    
    # Alias for billing service URL (for backward compatibility)
    @property
    def BILLING_SERVICE_URL(self) -> str:
        """Alias for TENANT_BILLING_SERVICE_URL"""
        return self.TENANT_BILLING_SERVICE_URL
    
    # ========================================================================
    # RATE LIMITING
    # ========================================================================
    RATE_LIMIT_PER_MINUTE: int = 60
    RATE_LIMIT_PER_HOUR: int = 1000
    
    # ========================================================================
    # FILE STORAGE (for templates - NOT for documents)
    # ========================================================================
    TEMPLATE_STORAGE_PATH: str = "./storage/templates"
    MAX_TEMPLATE_SIZE_MB: int = 5
    
    # ========================================================================
    # ANALYTICS SETTINGS (NO DOCUMENT CONTENT)
    # ========================================================================
    ENABLE_ANALYTICS: bool = True
    ANALYTICS_BATCH_SIZE: int = 100
    ANALYTICS_FLUSH_INTERVAL_SECONDS: int = 300
    
    # ========================================================================
    # COMPLIANCE MONITORING
    # ========================================================================
    ENABLE_COMPLIANCE_MONITORING: bool = True
    COMPLIANCE_ALERT_EMAIL: str = "compliance@truevow.com"
    
    # ========================================================================
    # CLIENT-SIDE VALIDATION ENGINE
    # ========================================================================
    DEFAULT_SYNC_INTERVAL_HOURS: int = 24
    MAX_RULES_PER_SYNC: int = 1000
    ENABLE_OFFLINE_MODE: bool = True
    
    # ========================================================================
    # TESTING
    # ========================================================================
    TEST_DATABASE_URL: Optional[str] = None
    TEST_API_KEY: Optional[str] = None
    
    # ========================================================================
    # MONITORING & LOGGING
    # ========================================================================
    ENABLE_REQUEST_LOGGING: bool = True
    LOG_FILE_PATH: str = "./logs/draft-service.log"
    LOG_ROTATION: str = "1 day"
    LOG_RETENTION: str = "30 days"
    SENTRY_DSN: Optional[str] = None
    
    # ========================================================================
    # FEATURE FLAGS
    # ========================================================================
    FEATURE_TEMPLATE_ASSEMBLY: bool = True
    FEATURE_USAGE_ANALYTICS: bool = True
    FEATURE_ADMIN_DASHBOARD: bool = True
    
    # ========================================================================
    # PYDANTIC SETTINGS CONFIGURATION
    # ========================================================================
    model_config = SettingsConfigDict(
        env_file=(".env", ".env.local"),  # Load both .env and .env.local
        env_file_encoding="utf-8",
        case_sensitive=True,
        extra="ignore"
    )
    
    # ========================================================================
    # COMPUTED PROPERTIES
    # ========================================================================
    
    @property
    def database_url_computed(self) -> str:
        """
        Compute database URL from individual settings or use provided URL
        
        Priority (optimized for psycopg3 + Supabase pooler):
        1. TENANT_LEVERAGE_APP_DATABASE_TRANSACTION_POOLER_URL (TrueVow - psycopg3 compatible, port 6543)
        2. LEVERAGE_DATABASE_TRANSACTION_POOLER_URL (LEVERAGE transaction pooler)
        3. TENANT_LEVERAGE_APP_DATABASE_SESSION_POOLER_URL (TrueVow session - may fail with psycopg3)
        4. LEVERAGE_DATABASE_SESSION_POOLER_URL (LEVERAGE session pooler)
        5. TENANT_LEVERAGE_APP_DATABASE_DIRECT_CONNECTION_URL (TrueVow direct)
        6. LEVERAGE_DATABASE_DIRECT_CONNECTION_URL (LEVERAGE DB direct)
        7. TENANT_APPLICATION_DATABASE_POOLER_URL (pooler for external connections)
        8. DATABASE_URL (standard)
        9. TENANT_APPLICATION_DATABASE_URL (TrueVow naming)
        10. Computed from individual settings
        
        Note: Automatically converts postgresql:// to postgresql+psycopg:// for psycopg3
        Note: Transaction pooler (port 6543) is preferred over session pooler (port 5432)
              because psycopg3 has compatibility issues with Supabase's session-mode pgbouncer.
        """
        import os as _os
        url = None
        
        # Highest priority: Transaction pooler (port 6543) - psycopg3 compatible
        if self.TENANT_LEVERAGE_APP_DATABASE_TRANSACTION_POOLER_URL:
            url = self.TENANT_LEVERAGE_APP_DATABASE_TRANSACTION_POOLER_URL
        elif self.LEVERAGE_DATABASE_TRANSACTION_POOLER_URL:
            url = self.LEVERAGE_DATABASE_TRANSACTION_POOLER_URL
        # Session pooler (port 5432) - may fail with psycopg3
        elif self.TENANT_LEVERAGE_APP_DATABASE_SESSION_POOLER_URL:
            url = self.TENANT_LEVERAGE_APP_DATABASE_SESSION_POOLER_URL
        elif self.LEVERAGE_DATABASE_SESSION_POOLER_URL:
            url = self.LEVERAGE_DATABASE_SESSION_POOLER_URL
        # Direct connections
        elif self.TENANT_LEVERAGE_APP_DATABASE_DIRECT_CONNECTION_URL:
            url = self.TENANT_LEVERAGE_APP_DATABASE_DIRECT_CONNECTION_URL
        elif self.LEVERAGE_DATABASE_DIRECT_CONNECTION_URL:
            url = self.LEVERAGE_DATABASE_DIRECT_CONNECTION_URL
        # Next: standard pooler URL (better for external connections)
        elif self.TENANT_APPLICATION_DATABASE_POOLER_URL:
            url = self.TENANT_APPLICATION_DATABASE_POOLER_URL
        elif self.DATABASE_URL:
            url = self.DATABASE_URL
        elif self.TENANT_APPLICATION_DATABASE_URL:
            url = self.TENANT_APPLICATION_DATABASE_URL
        # Use test database when testing (pytest or TESTING=1 or APP_ENVIRONMENT=test)
        elif (
            (self.APP_ENVIRONMENT == "test" or _os.getenv("TESTING", "").lower() in ("1", "true"))
            and self.TEST_DATABASE_URL
        ):
            url = self.TEST_DATABASE_URL
        
        # Normalize postgres:// to postgresql:// (standard format)
        if url and url.startswith("postgres://"):
            url = url.replace("postgres://", "postgresql://", 1)
        
        # Convert to psycopg3 driver for better DNS resolution on Windows
        if url and url.startswith("postgresql://"):
            url = url.replace("postgresql://", "postgresql+psycopg://", 1)
        
        if url:
            return url
        
        if self.DATABASE_PASSWORD:
            return (
                f"postgresql://{self.DATABASE_USER}:{self.DATABASE_PASSWORD}"
                f"@{self.DATABASE_HOST}:{self.DATABASE_PORT}/{self.DATABASE_NAME}"
            )
        
        raise ValueError(
            "Database configuration missing. Set DATABASE_URL, "
            "TENANT_APPLICATION_DATABASE_URL, or DATABASE_PASSWORD"
        )
    
    @property
    def secret_key_computed(self) -> str:
        """
        Get secret key for JWT tokens
        
        Priority:
        1. SECRET_KEY (standard)
        2. DRAFT_SERVICE_API_KEY (fallback)
        """
        if self.SECRET_KEY:
            return self.SECRET_KEY
        
        if self.DRAFT_SERVICE_API_KEY:
            return self.DRAFT_SERVICE_API_KEY
        
        raise ValueError("SECRET_KEY or DRAFT_SERVICE_API_KEY required")
    
    @property
    def api_key_encryption_key_computed(self) -> str:
        """
        Get API key encryption key (Fernet key)
        
        For development: generates a temporary key if not set
        For production: raises error if not set
        """
        if self.API_KEY_ENCRYPTION_KEY and not self.API_KEY_ENCRYPTION_KEY.startswith("your-"):
            return self.API_KEY_ENCRYPTION_KEY
        
        if self.is_production:
            raise ValueError("API_KEY_ENCRYPTION_KEY required in production")
        
        # Development fallback: generate from secret key
        import base64
        import hashlib
        secret = self.secret_key_computed.encode()
        key = base64.urlsafe_b64encode(hashlib.sha256(secret).digest())
        return key.decode()
    
    @property
    def rules_encryption_key_computed(self) -> str:
        """
        Get rules encryption key (Fernet key)
        
        For development: generates a temporary key if not set
        For production: raises error if not set
        """
        if self.RULES_ENCRYPTION_KEY and not self.RULES_ENCRYPTION_KEY.startswith("your-"):
            return self.RULES_ENCRYPTION_KEY
        
        if self.is_production:
            raise ValueError("RULES_ENCRYPTION_KEY required in production")
        
        # Development fallback: generate from secret key + salt
        import base64
        import hashlib
        secret = (self.secret_key_computed + "_rules").encode()
        key = base64.urlsafe_b64encode(hashlib.sha256(secret).digest())
        return key.decode()
    
    @property
    def is_production(self) -> bool:
        """Check if running in production environment"""
        return self.APP_ENVIRONMENT.lower() == "production"
    
    @property
    def is_development(self) -> bool:
        """Check if running in development environment"""
        return self.APP_ENVIRONMENT.lower() == "development"
    
    @property
    def allowed_origins_list(self) -> List[str]:
        """Convert comma-separated origins to list"""
        return [origin.strip() for origin in self.ALLOWED_ORIGINS.split(",")]
    
    @property
    def allowed_methods_list(self) -> List[str]:
        """Convert comma-separated methods to list"""
        return [method.strip() for method in self.ALLOWED_METHODS.split(",")]
    
    # ========================================================================
    # VALIDATORS
    # ========================================================================
    
    @field_validator("LOG_LEVEL")
    @classmethod
    def validate_log_level(cls, v: str) -> str:
        """Validate log level"""
        allowed_levels = ["DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"]
        if v.upper() not in allowed_levels:
            raise ValueError(f"LOG_LEVEL must be one of: {', '.join(allowed_levels)}")
        return v.upper()
    
    @field_validator("APP_ENVIRONMENT")
    @classmethod
    def validate_environment(cls, v: str) -> str:
        """Validate environment"""
        allowed_envs = ["development", "staging", "production"]
        if v.lower() not in allowed_envs:
            raise ValueError(f"APP_ENVIRONMENT must be one of: {', '.join(allowed_envs)}")
        return v.lower()


# ============================================================================
# SINGLETON SETTINGS INSTANCE
# ============================================================================

# Global settings instance (singleton)
settings: Optional[Settings] = None


def get_settings() -> Settings:
    """
    Get or create global settings instance
    
    Returns:
        Settings: Application settings
    """
    global settings
    
    if settings is None:
        settings = Settings()
    
    return settings


# ============================================================================
# ZERO-KNOWLEDGE COMPLIANCE CHECKS
# ============================================================================

def validate_zero_knowledge_compliance() -> None:
    """
    Validate that configuration maintains zero-knowledge architecture
    
    Raises:
        ValueError: If configuration violates zero-knowledge principles
    """
    config = get_settings()
    
    # Ensure no document storage paths are configured (except templates)
    forbidden_keys = [
        "DOCUMENT_STORAGE_PATH",
        "DOCUMENT_UPLOAD_PATH",
        "CLIENT_DATA_PATH",
    ]
    
    for key in forbidden_keys:
        if hasattr(config, key):
            raise ValueError(
                f"Configuration contains forbidden key '{key}' that violates "
                "zero-knowledge architecture. Documents must NEVER be stored."
            )
    
    # Validate feature flags are safe
    if config.FEATURE_TEMPLATE_ASSEMBLY:
        # Template assembly is OK (ephemeral processing only)
        pass
    
    if config.FEATURE_USAGE_ANALYTICS:
        # Analytics OK if no document content (metadata only)
        pass


# Initialize settings on module load
_ = get_settings()

