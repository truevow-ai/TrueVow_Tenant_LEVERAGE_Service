"""
TrueVow DRAFT™ Service - API Router
Aggregates all API endpoints into a single router
"""

from fastapi import APIRouter

from app.api.v1.endpoints import (
    validation_rules,
    admin,
    email_validation,
    validation,
    admin_compliance,
    admin_rule_templates,
    tenant_rules,
    template_inheritance,
    rule_selection,
    saas_admin_adapter,
    admin_templates,
    admin_analytics,
    tenant_draft,
    deadlines,
    # leverage_rewards,  # DISABLED v1: reward/credit system removed from pricing strategy
    leverage_economics,
    leverage_case,
    notifications,
)

# Create main API router
api_router = APIRouter()

# ============================================================================
# VALIDATION & RULES ENDPOINTS
# ============================================================================
api_router.include_router(validation_rules.router)
api_router.include_router(validation.router)  # Server-side validation endpoints
api_router.include_router(deadlines.router)   # Standalone deadline calculators
# api_router.include_router(leverage_rewards.router)    # DISABLED v1: reward/credit system removed
api_router.include_router(leverage_economics.router)  # LEVERAGE Group B: damages + disbursement
api_router.include_router(leverage_case.router)       # LEVERAGE case lifecycle (open/status/compliance/settle)
api_router.include_router(notifications.router)     # LEVERAGE notifications (SOL urgency, settlement nudge)

# ============================================================================
# ADMIN ENDPOINTS
# ============================================================================
api_router.include_router(admin.router)
api_router.include_router(admin_rule_templates.router)
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
    prefix="/admin/draft/compliance",
    tags=["Admin - DRAFT Compliance"]
)

# ============================================================================
# TENANT ENDPOINTS
# ============================================================================
api_router.include_router(tenant_rules.router)
api_router.include_router(template_inheritance.router)
api_router.include_router(rule_selection.router)
api_router.include_router(
    tenant_draft.router,
    prefix="/tenant/draft",
    tags=["Tenant - DRAFT"]
)
api_router.include_router(saas_admin_adapter.router)

# ============================================================================
# EMAIL VALIDATION ENDPOINTS
# ============================================================================
api_router.include_router(email_validation.router)

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

