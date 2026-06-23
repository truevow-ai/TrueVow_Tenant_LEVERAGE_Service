"""
TrueVow LEVERAGE™ Service - Main Application
FastAPI application entry point
"""

import os
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import logging

from app.core.config import get_settings, validate_zero_knowledge_compliance
from app.core.database import check_db_connection, engine
from app.core.security_middleware import SecurityMiddleware
from app.api.v1.router import api_router
from app.services.service_registry_client import ServiceRegistryClient, HeartbeatTask
from app.services.service_config import (
    LEVERAGE_SERVICE_CONFIG,
    LEVERAGE_MODULES,
    LEVERAGE_INTEGRATIONS,
    SERVICE_NAME,
)

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

settings = get_settings()


# ============================================================================
# LIFESPAN EVENTS
# ============================================================================

@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    Application lifespan events
    Handles startup and shutdown logic
    """
    # Startup
    logger.info("Starting TrueVow LEVERAGE Service...")
    logger.info(f"Environment: {settings.APP_ENVIRONMENT}")
    logger.info(f"Debug Mode: {settings.DEBUG}")
    
    # Validate zero-knowledge compliance
    try:
        validate_zero_knowledge_compliance()
        logger.info("✓ Zero-knowledge compliance validated")
    except ValueError as e:
        logger.error(f"✗ Zero-knowledge compliance check failed: {e}")
        raise
    
    # Check database connection (non-blocking)
    try:
        if check_db_connection():
            logger.info("✓ Database connection successful")
        else:
            logger.warning("⚠ Database connection failed - service will start but database operations may fail")
    except Exception as e:
        logger.warning(f"⚠ Database connection check failed: {e} - service will start but database operations may fail")
        # Don't raise error - allow service to start for testing/development
    
    # TODO: Initialize validation rules cache (optional)
    # TODO: Start background tasks (analytics flush, compliance monitoring)

    # ── Service Registry registration ────────────────────────────────────────
    _registry_enabled = os.getenv("SERVICE_REGISTRY_ENABLED", "false").lower() == "true"
    _heartbeat_task: HeartbeatTask = None

    if _registry_enabled:
        _registry_client = ServiceRegistryClient()
        try:
            # 1. Register service
            reg_result = await _registry_client.register(LEVERAGE_SERVICE_CONFIG)
            if reg_result.get("success") is not False:
                logger.info("✓ Service registered with registry")
            else:
                logger.warning(f"⚠ Service registration returned: {reg_result}")

            # 2. Register modules
            for mod in LEVERAGE_MODULES:
                await _registry_client.register_module(
                    service_name=SERVICE_NAME,
                    **mod,
                )
            logger.info(f"✓ {len(LEVERAGE_MODULES)} modules registered")

            # 3. Register integration contracts
            for contract in LEVERAGE_INTEGRATIONS:
                await _registry_client.register_integration(**contract)
            logger.info(f"✓ {len(LEVERAGE_INTEGRATIONS)} integration contracts registered")

        except Exception as e:
            logger.warning(f"⚠ Service registry startup failed (non-fatal): {e}")
        finally:
            await _registry_client.close()

        # 4. Start heartbeat background task
        _heartbeat_task = HeartbeatTask(SERVICE_NAME)
        await _heartbeat_task.start()
        logger.info("✓ Heartbeat task started")
    else:
        logger.info("Service registry disabled (SERVICE_REGISTRY_ENABLED != true)")

    logger.info("TrueVow LEVERAGE Service started successfully")
    logger.info(f"API Documentation: http://{settings.HOST}:{settings.PORT}/docs")
    
    yield  # Application runs here
    
    # Shutdown
    logger.info("Shutting down TrueVow LEVERAGE Service...")

    # Stop heartbeat task
    if _registry_enabled and _heartbeat_task:
        await _heartbeat_task.stop()
        logger.info("✓ Heartbeat task stopped")

    # Close database connections
    try:
        from app.core.database import get_engine
        db_engine = get_engine()
        db_engine.dispose()
        logger.info("✓ Database connections closed")
    except Exception as e:
        logger.warning(f"⚠ Could not close database connections: {e}")
    
    # TODO: Cleanup background tasks
    # TODO: Flush remaining analytics
    
    logger.info("TrueVow LEVERAGE Service shut down successfully")


# ============================================================================
# FASTAPI APPLICATION
# ============================================================================

app = FastAPI(
    title="TrueVow LEVERAGE™ Service",
    description="""
    # TrueVow LEVERAGE™ Case Intelligence Service
    
    **Zero-Knowledge Architecture:** Documents never uploaded to TrueVow servers
    
    ## Features
    
    - ✅ Case lifecycle management (open, compliance, settle)
    - ✅ Statute of limitations validation (SOL deadline tracking)
    - ✅ Compliance intelligence signals (demand readiness, flags)
    - ✅ PI damages worksheet calculator
    - ✅ Case disbursement / net-to-client projection
    - ✅ Reward credit system (welcome bonus, settlement rewards)
    
    ## Compliance
    
    - **ABA Model Rule 1.1:** Competence (validation ensures attorney competence)
    - **ABA Model Rule 5.5:** Unauthorized Practice of Law (client-side validation only)
    - **Zero-Knowledge:** Documents and client data NEVER stored
    
    ## API Authentication
    
    All endpoints require API key authentication via Bearer token:
    
    ```
    Authorization: Bearer {api_key}
    ```
    
    ## Integration
    
    - **MDM:** Receives case lifecycle events (case_id, tenant_id)
    - **Billing Service:** $79/case open, reward credits
    - **SETTLE Service:** Settlement data for intelligence network
    """,
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
    openapi_url="/openapi.json",
    lifespan=lifespan,
)


# ============================================================================
# MIDDLEWARE
# ============================================================================

# Security Middleware (must be added before CORS)
app.add_middleware(SecurityMiddleware)

# CORS Middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.allowed_origins_list,
    allow_credentials=settings.ALLOW_CREDENTIALS,
    allow_methods=settings.allowed_methods_list,
    allow_headers=["*", "X-API-Key", "X-Tenant-ID", "X-Request-ID"],
)


# Request Logging Middleware (optional)
if settings.ENABLE_REQUEST_LOGGING:
    @app.middleware("http")
    async def log_requests(request, call_next):
        """Log all HTTP requests"""
        logger.info(f"Request: {request.method} {request.url.path}")
        response = await call_next(request)
        logger.info(f"Response: {response.status_code}")
        return response


# ============================================================================
# EXCEPTION HANDLERS
# ============================================================================

@app.exception_handler(ValueError)
async def value_error_handler(request, exc):
    """Handle ValueError exceptions"""
    logger.error(f"ValueError: {exc}")
    request_id = getattr(request.state, 'request_id', None)
    return JSONResponse(
        status_code=400,
        content={
            "detail": str(exc),
            "error_code": "VALIDATION_ERROR",
            "request_id": request_id
        }
    )


@app.exception_handler(Exception)
async def general_exception_handler(request, exc):
    """Handle general exceptions with sanitized errors"""
    from app.core.security_middleware import sanitize_error
    
    logger.error(f"Unhandled exception: {exc}", exc_info=True)
    request_id = getattr(request.state, 'request_id', None)
    
    # Sanitize error for response
    sanitized = sanitize_error(exc)
    sanitized["request_id"] = request_id
    
    return JSONResponse(
        status_code=500,
        content=sanitized
    )


# ============================================================================
# ROUTES
# ============================================================================

# Include API v1 router
app.include_router(api_router, prefix="/api/v1")


# Root endpoint
@app.get("/", tags=["Root"])
async def root():
    """Root endpoint"""
    return {
        "service": "TrueVow LEVERAGE™ Service",
        "version": "1.0.0",
        "description": "Case Intelligence Service for Personal Injury Law Firms",
        "api_version": "v1",
        "documentation": f"http://{settings.HOST}:{settings.PORT}/docs",
        "zero_knowledge_compliant": True,
        "aba_compliant": True,
    }


# Health check endpoint
@app.get("/health", tags=["Health"])
async def health():
    """Health check endpoint"""
    db_healthy = check_db_connection()
    
    return {
        "status": "healthy" if db_healthy else "unhealthy",
        "service": "TrueVow LEVERAGE Service",
        "version": "1.0.0",
        "database": "connected" if db_healthy else "disconnected",
        "environment": settings.APP_ENVIRONMENT,
        "zero_knowledge_compliant": True,
    }


# ============================================================================
# RUN APPLICATION (for development only)
# ============================================================================

if __name__ == "__main__":
    import uvicorn
    
    uvicorn.run(
        "app.main:app",
        host=settings.HOST,
        port=settings.PORT,
        reload=settings.RELOAD,
        log_level=settings.LOG_LEVEL.lower()
    )

