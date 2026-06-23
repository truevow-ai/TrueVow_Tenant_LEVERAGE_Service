"""
TrueVow DRAFT™ Service - API Router v2.0 (CORRECT ARCHITECTURE)

Includes all API endpoints for:
1. Global Rule Templates (Admin)
2. Tenant Rules (Law Firms)
3. Template Inheritance
4. Rule Selection
"""

from fastapi import APIRouter

from app.api.v1.endpoints import (
    admin_rule_templates,
    tenant_rules,
    template_inheritance,
    rule_selection
)

# Create main API router
api_router = APIRouter()

# ============================================================================
# ADMIN ENDPOINTS (Global Rule Templates)
# ============================================================================
api_router.include_router(
    admin_rule_templates.router,
    prefix="/v1"
)

# ============================================================================
# TENANT ENDPOINTS (Tenant Rules, Templates, Selection)
# ============================================================================
api_router.include_router(
    tenant_rules.router,
    prefix="/v1"
)

api_router.include_router(
    template_inheritance.router,
    prefix="/v1"
)

api_router.include_router(
    rule_selection.router,
    prefix="/v1"
)

# ============================================================================
# HEALTH CHECK
# ============================================================================

@api_router.get("/v1/health")
async def health_check():
    """Global health check"""
    return {
        "status": "healthy",
        "service": "draft",
        "version": "2.0",
        "architecture": "correct",
        "zero_knowledge": True
    }

