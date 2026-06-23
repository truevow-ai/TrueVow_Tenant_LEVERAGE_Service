"""
TrueVow DRAFT™ Service - API Router
Aggregates all API endpoints into a single router
"""

from fastapi import APIRouter

from app.api.v1.endpoints import (
    validation_rules,
    admin,
    email_validation,
    admin_templates,
    admin_analytics,
    admin_compliance,
    tenant_draft
)

# Create main API router
api_router = APIRouter()

# Include endpoint routers
api_router.include_router(validation_rules.router)
api_router.include_router(admin.router)
api_router.include_router(email_validation.router)

# Admin endpoints
api_router.include_router(
    admin_templates.router,
    prefix="/admin/templates",
    tags=["Admin - Templates"]
)
api_router.include_router(
    admin_analytics.router,
    prefix="/admin/analytics",
    tags=["Admin - Analytics"]
)
api_router.include_router(
    admin_compliance.router,
    prefix="/admin/compliance",
    tags=["Admin - Compliance"]
)

# Tenant endpoints
api_router.include_router(
    tenant_draft.router,
    prefix="/tenants/{tenant_id}/draft",
    tags=["Tenant - DRAFT"]
)

# Health check for API
@api_router.get("/health", tags=["Health"])
async def health_check():
    """API health check"""
    return {
        "status": "healthy",
        "service": "TrueVow DRAFT Service",
        "version": "1.0.0",
        "api_version": "v1",
        "zero_knowledge_compliant": True,
    }

