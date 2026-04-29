"""
TrueVow LEVERAGE™ — Billing Service

Implements LEVERAGE pricing tiers with active-case metering.

Tiers:
  SOLO:   $99/mo  — 5 active cases,  $49/extra case
  GROWTH: $349/mo — 20 active cases, $39/extra case
  TEAM:   $899/mo — 50 active cases,  $29/extra case

INTAKE bundle discount: 20% off any tier when tenant also uses INTAKE.

Fail-open policy: billing unavailability NEVER blocks attorney workflow.
All billing calls degrade gracefully if the external billing service is down.
"""

import httpx
import logging
import hashlib
from typing import Optional, Dict, Any, List
from dataclasses import dataclass, field
from enum import Enum

from app.core.config import get_settings

logger = logging.getLogger(__name__)


# ============================================================================
# LEVERAGE PRICING TIERS
# ============================================================================

class LeverageTier(str, Enum):
    """LEVERAGE subscription tiers."""
    SOLO = "solo"
    GROWTH = "growth"
    TEAM = "team"


@dataclass(frozen=True)
class TierConfig:
    """Pricing configuration for a single LEVERAGE tier."""
    tier: LeverageTier
    monthly_price_usd: int
    included_cases: int
    overage_price_per_case_usd: int
    team_collaboration: bool
    advanced_analytics: bool
    priority_support: bool


# Tier definitions — single source of truth for pricing
TIER_CONFIGS: Dict[LeverageTier, TierConfig] = {
    LeverageTier.SOLO: TierConfig(
        tier=LeverageTier.SOLO,
        monthly_price_usd=99,
        included_cases=5,
        overage_price_per_case_usd=49,
        team_collaboration=False,
        advanced_analytics=False,
        priority_support=False,
    ),
    LeverageTier.GROWTH: TierConfig(
        tier=LeverageTier.GROWTH,
        monthly_price_usd=349,
        included_cases=20,
        overage_price_per_case_usd=39,
        team_collaboration=True,
        advanced_analytics=False,
        priority_support=False,
    ),
    LeverageTier.TEAM: TierConfig(
        tier=LeverageTier.TEAM,
        monthly_price_usd=899,
        included_cases=50,
        overage_price_per_case_usd=29,
        team_collaboration=True,
        advanced_analytics=True,
        priority_support=True,
    ),
}

# INTAKE bundle discount
INTAKE_BUNDLE_DISCOUNT_PCT = 20  # 20% off monthly price


# ============================================================================
# DATA STRUCTURES
# ============================================================================

class FeatureSource(str, Enum):
    """Source of feature access."""
    TIER = "tier"
    ADDON = "addon"


@dataclass
class LeverageFeatureAccess:
    """LEVERAGE feature access details for a tenant."""
    enabled: bool
    tier: Optional[LeverageTier]
    source: Optional[FeatureSource]
    included_cases: int
    overage_price_per_case_usd: int
    monthly_price_usd: int
    active_cases: int = 0
    has_intake_bundle: bool = False

    @property
    def case_limit(self) -> int:
        """Maximum cases included in the current billing period."""
        return self.included_cases

    @property
    def overage_cases(self) -> int:
        """Number of cases beyond the included limit."""
        return max(0, self.active_cases - self.included_cases)

    @property
    def overage_charge_usd(self) -> int:
        """Total overage charge for the current billing period."""
        return self.overage_cases * self.overage_price_per_case_usd

    @property
    def effective_monthly_price_usd(self) -> int:
        """Monthly price after INTAKE bundle discount (if applicable)."""
        if self.has_intake_bundle:
            discount = int(self.monthly_price_usd * INTAKE_BUNDLE_DISCOUNT_PCT / 100)
            return self.monthly_price_usd - discount
        return self.monthly_price_usd

    @property
    def can_open_case(self) -> bool:
        """Whether the tenant can open another case this period."""
        return self.enabled and self.active_cases < self.included_cases


@dataclass
class FeatureAccessResponse:
    """Parsed response from billing feature-access endpoint."""
    tenant_id: str
    tier: str
    leverage: LeverageFeatureAccess
    addons: list
    has_intake_bundle: bool
    raw_response: Dict[str, Any]


# ============================================================================
# BILLING SERVICE CLIENT
# ============================================================================

class BillingServiceError(Exception):
    """Base exception for billing service errors."""
    pass


class BillingServiceUnavailable(BillingServiceError):
    """Billing service is unavailable."""
    pass


class TenantNotFound(BillingServiceError):
    """Tenant not found in billing system."""
    pass


class LeverageAccessDenied(BillingServiceError):
    """Tenant does not have LEVERAGE access."""
    pass


class BillingService:
    """
    Client for the LEVERAGE billing system.

    Supports both:
      A) External billing microservice (if configured) for payment processing
      B) Local tier-aware access checks for case metering

    Usage:
        billing = BillingService()
        access = await billing.get_leverage_access(tenant_id, user_id)

        if not access.enabled:
            raise LeverageAccessDenied("LEVERAGE not enabled")

        if not access.can_open_case:
            # Overage: charge overage_price_per_case_usd
            ...
    """

    def __init__(
        self,
        base_url: Optional[str] = None,
        api_key: Optional[str] = None,
        timeout: float = 10.0,
    ):
        settings = get_settings()
        self.base_url = base_url or getattr(
            settings, "TENANT_BILLING_SERVICE_URL", "http://localhost:3016"
        )
        self.api_key = api_key or getattr(
            settings, "TENANT_BILLING_SERVICE_API_KEY", ""
        )
        self.timeout = timeout
        self._client: Optional[httpx.AsyncClient] = None

    async def _get_client(self) -> httpx.AsyncClient:
        """Get or create HTTP client."""
        if self._client is None or self._client.is_closed:
            headers = {"Content-Type": "application/json"}
            if self.api_key:
                headers["Authorization"] = f"Bearer {self.api_key}"
            self._client = httpx.AsyncClient(
                base_url=self.base_url,
                timeout=self.timeout,
                headers=headers,
            )
        return self._client

    async def close(self) -> None:
        """Close HTTP client."""
        if self._client and not self._client.is_closed:
            await self._client.aclose()
            self._client = None

    # ── External billing service queries ──────────────────────────────────

    async def get_feature_access(
        self,
        tenant_id: str,
        user_id: Optional[str] = None,
    ) -> FeatureAccessResponse:
        """
        Get feature access for a tenant from the external billing endpoint.

        Args:
            tenant_id: Tenant UUID
            user_id: Optional attorney user ID

        Returns:
            FeatureAccessResponse with all feature access details

        Raises:
            TenantNotFound: If tenant doesn't exist in billing system
            BillingServiceUnavailable: If billing service is down
            BillingServiceError: For other billing errors
        """
        client = await self._get_client()

        url = f"/api/v1/billing/tenants/{tenant_id}/feature-access"
        params = {"user_id": user_id} if user_id else {}

        try:
            response = await client.get(url, params=params)

            if response.status_code == 404:
                raise TenantNotFound(f"Tenant {tenant_id} not found in billing system")

            if response.status_code >= 500:
                logger.error(
                    "Billing service error: %d - %s", response.status_code, response.text
                )
                raise BillingServiceUnavailable("Billing service unavailable")

            response.raise_for_status()
            data = response.json()

            return self._parse_feature_access(data)

        except httpx.TimeoutException:
            logger.error("Billing service timeout for tenant %s", tenant_id)
            raise BillingServiceUnavailable("Billing service timeout")

        except httpx.ConnectError:
            logger.error("Cannot connect to billing service at %s", self.base_url)
            raise BillingServiceUnavailable("Cannot connect to billing service")

        except (TenantNotFound, BillingServiceUnavailable):
            raise

        except Exception as e:
            logger.error("Billing service error: %s", e)
            raise BillingServiceError(f"Billing service error: {e}")

    def _parse_feature_access(self, data: Dict[str, Any]) -> FeatureAccessResponse:
        """Parse raw API response into typed structure."""
        leverage_data = data.get("features", {}).get("leverage", {})

        # Resolve tier
        tier_str = leverage_data.get("tier", data.get("tier", "")).lower()
        tier = None
        for t in LeverageTier:
            if t.value == tier_str:
                tier = t
                break

        # Get tier config or fall back to SOLO defaults
        tier_config = TIER_CONFIGS.get(tier, TIER_CONFIGS[LeverageTier.SOLO])

        # Parse source enum
        source_str = leverage_data.get("source")
        source = FeatureSource(source_str) if source_str else FeatureSource.TIER

        # Check INTAKE bundle
        has_intake = data.get("intake_bundle", {}).get("enabled", False)

        leverage = LeverageFeatureAccess(
            enabled=leverage_data.get("enabled", False),
            tier=tier,
            source=source,
            included_cases=leverage_data.get("included_cases", tier_config.included_cases),
            overage_price_per_case_usd=leverage_data.get(
                "overage_price_per_case_usd", tier_config.overage_price_per_case_usd
            ),
            monthly_price_usd=leverage_data.get(
                "monthly_price_usd", tier_config.monthly_price_usd
            ),
            active_cases=leverage_data.get("active_cases", 0),
            has_intake_bundle=has_intake,
        )

        return FeatureAccessResponse(
            tenant_id=data.get("tenant_id", ""),
            tier=data.get("tier", ""),
            leverage=leverage,
            addons=data.get("addons", []),
            has_intake_bundle=has_intake,
            raw_response=data,
        )

    # ── LEVERAGE-specific access methods ──────────────────────────────────

    async def get_leverage_access(
        self,
        tenant_id: str,
        user_id: Optional[str] = None,
    ) -> LeverageFeatureAccess:
        """
        Get LEVERAGE-specific feature access.

        Convenience method that returns only LEVERAGE access details.

        Args:
            tenant_id: Tenant UUID
            user_id: Optional attorney user ID

        Returns:
            LeverageFeatureAccess with tier details, case limits, and pricing
        """
        response = await self.get_feature_access(tenant_id, user_id)
        return response.leverage

    async def validate_leverage_access(
        self,
        tenant_id: str,
        user_id: Optional[str] = None,
    ) -> Dict[str, Any]:
        """
        Validate LEVERAGE access and return pricing info.

        Use this before allowing case operations.

        Args:
            tenant_id: Tenant UUID
            user_id: Optional attorney user ID

        Returns:
            Dict with access details including case limits and overage pricing

        Raises:
            LeverageAccessDenied: If LEVERAGE not enabled for tenant
            TenantNotFound: If tenant doesn't exist
            BillingServiceUnavailable: If billing service is down
        """
        access = await self.get_leverage_access(tenant_id, user_id)

        if not access.enabled:
            raise LeverageAccessDenied(
                f"LEVERAGE not enabled for tenant {tenant_id}"
            )

        return {
            "allowed": True,
            "tier": access.tier.value if access.tier else None,
            "source": access.source.value if access.source else None,
            "included_cases": access.included_cases,
            "active_cases": access.active_cases,
            "can_open_case": access.can_open_case,
            "overage_price_per_case_usd": access.overage_price_per_case_usd,
            "effective_monthly_price_usd": access.effective_monthly_price_usd,
            "has_intake_bundle": access.has_intake_bundle,
        }

    async def check_case_limit(
        self,
        tenant_id: str,
        user_id: Optional[str] = None,
    ) -> Dict[str, Any]:
        """
        Check if tenant can open another case and return billing context.

        This is the primary billing gate for case-open operations.
        Corresponds to POST /api/v1/billing/leverage/open-case in the Billing Service.

        Fail-open: If billing is unavailable, allows the case but marks
        it for later reconciliation.

        Returns:
            Dict matching the Billing Service open-case response:
              - authorized: bool
              - source: 'included' | 'overage' | 'credit' | 'invoice'
              - price_cents: int (0 if included, overage amount if overage)
              - cases_used: int
              - cases_included: int
              - cases_remaining: int
              - validations_unlimited: bool (always True for LEVERAGE)
              - tier: str
              - message: str
        """
        try:
            access = await self.get_leverage_access(tenant_id, user_id)

            if not access.enabled:
                return {
                    "authorized": False,
                    "source": None,
                    "price_cents": 0,
                    "cases_used": 0,
                    "cases_included": 0,
                    "cases_remaining": 0,
                    "validations_unlimited": True,
                    "tier": None,
                    "message": "LEVERAGE not unlocked. Complete required unlocks first.",
                    # Legacy fields
                    "can_open": False,
                    "is_overage": False,
                    "overage_charge_usd": 0,
                }

            cases_used = access.active_cases
            cases_included = access.included_cases
            is_overage = cases_used >= cases_included
            cases_remaining = max(0, cases_included - cases_used)

            if is_overage:
                source = "overage"
                price_cents = access.overage_price_per_case_usd * 100
            else:
                source = "included"
                price_cents = 0

            return {
                "authorized": True,
                "source": source,
                "price_cents": price_cents,
                "cases_used": cases_used + 1,  # This case will be the next one
                "cases_included": cases_included,
                "cases_remaining": max(0, cases_remaining - 1),
                "validations_unlimited": True,
                "tier": access.tier.value if access.tier else None,
                "message": (
                    "Case opened. Validations are unlimited and free."
                    if not is_overage
                    else f"Case opened as overage (${access.overage_price_per_case_usd}/case). Validations are unlimited and free."
                ),
                # Legacy fields kept for backward compatibility
                "can_open": True,
                "is_overage": is_overage,
                "overage_charge_usd": access.overage_price_per_case_usd if is_overage else 0,
            }

        except BillingServiceUnavailable:
            # Fail-open: allow case, reconcile later
            logger.warning(
                "check_case_limit: billing unavailable for %s — fail-open",
                tenant_id,
            )
            return {
                "authorized": True,
                "source": "included",  # Assume included until reconciled
                "price_cents": 0,
                "cases_used": 0,
                "cases_included": 0,
                "cases_remaining": 0,
                "validations_unlimited": True,
                "tier": None,
                "message": "Billing unavailable — case opened (fail-open). Will reconcile later.",
                "billing_unavailable": True,
                # Legacy fields
                "can_open": True,
                "is_overage": False,
                "overage_charge_usd": 0,
            }

        except Exception as exc:
            logger.warning(
                "check_case_limit: unexpected error for %s — %s — fail-open",
                tenant_id,
                exc,
            )
            return {
                "authorized": True,
                "source": "included",
                "price_cents": 0,
                "cases_used": 0,
                "cases_included": 0,
                "cases_remaining": 0,
                "validations_unlimited": True,
                "tier": None,
                "message": f"Billing error — case opened (fail-open). Will reconcile later.",
                "billing_unavailable": True,
                # Legacy fields
                "can_open": True,
                "is_overage": False,
                "overage_charge_usd": 0,
            }

    async def record_case_open(
        self,
        tenant_id: str,
        case_id: str,
        is_overage: bool = False,
        overage_charge_usd: int = 0,
    ) -> bool:
        """
        Record a case-open event with the external billing service.

        For included cases: no charge.
        For overage cases: charge the overage_price_per_case_usd.

        Fail-open: returns True even if billing is unavailable.

        Args:
            tenant_id: Tenant UUID
            case_id: Case UUID
            is_overage: Whether this case exceeds the included limit
            overage_charge_usd: Charge amount if overage

        Returns:
            True if billing recorded successfully, False otherwise
        """
        client = await self._get_client()
        try:
            payload = {
                "case_id": case_id,
                "idempotency_key": f"leverage_open_{tenant_id}_{case_id}",
                "is_overage": is_overage,
            }
            if is_overage:
                payload["amount_usd"] = overage_charge_usd

            resp = await client.post(
                f"/api/v1/billing/tenants/{tenant_id}/leverage/cases/open",
                json=payload,
            )
            return resp.status_code in (200, 201, 409)  # 409 = idempotent

        except Exception as exc:
            logger.warning(
                "record_case_open: billing unavailable for %s case %s — %s (fail-open)",
                tenant_id,
                case_id,
                exc,
            )
            return False


    async def get_case_status(
        self,
        tenant_id: str,
        case_id: str,
    ) -> Dict[str, Any]:
        """
        Get the billing status of a LEVERAGE case.

        Returns a dict with keys: leverage_unlocked, settle_unlocked, is_overage, overage_charge_usd.
        Fail-open: returns safe defaults (unlocked=False) if billing is unavailable.

        Args:
            tenant_id: Tenant UUID
            case_id: Case UUID string

        Returns:
            Dict with case billing status fields
        """
        client = await self._get_client()
        try:
            resp = await client.get(
                f"/api/v1/billing/tenants/{tenant_id}/leverage/cases/{case_id}/status"
            )
            if resp.status_code == 200:
                data = resp.json()
                return {
                    "leverage_unlocked": data.get("leverage_unlocked", False),
                    "settle_unlocked": data.get("settle_unlocked", False),
                    "is_overage": data.get("is_overage", False),
                    "overage_charge_usd": data.get("overage_charge_usd", 0),
                }
            elif resp.status_code == 404:
                return {
                    "leverage_unlocked": False,
                    "settle_unlocked": False,
                    "is_overage": False,
                    "overage_charge_usd": 0,
                }
            else:
                logger.warning(
                    "get_case_status: billing %d for tenant %s case %s",
                    resp.status_code, tenant_id, case_id,
                )
                return {
                    "leverage_unlocked": False,
                    "settle_unlocked": False,
                    "is_overage": False,
                    "overage_charge_usd": 0,
                }
        except BillingServiceUnavailable:
            raise
        except Exception as exc:
            logger.warning(
                "get_case_status: error for %s/%s — %s (fail-open)",
                tenant_id, case_id, exc,
            )
            return {
                "leverage_unlocked": False,
                "settle_unlocked": False,
                "is_overage": False,
                "overage_charge_usd": 0,
            }


# ============================================================================
# CASE FINGERPRINT  (deterministic duplicate-detection for council submissions)
# ============================================================================

def build_case_fingerprint(
    county: Optional[str],
    incident_type: Optional[str],
    injury_category: Optional[str],
    insurer: Optional[str],
    settlement_band: Optional[str],
    settlement_month: Optional[str],   # format: "YYYY-MM"
) -> str:
    """
    Compute a deterministic SHA-256 fingerprint for a council settlement submission.

    Used by the SETTLE service to reject duplicate council entries.
    Hash fields (per spec):
        county | incident_type | injury_category | insurer | settlement_band | settlement_month

    All values are lower-cased and stripped before hashing.
    Returns a 16-character hex prefix (sufficient for dedup; full hash stored in DB).
    """
    components = [
        (county         or "").lower().strip(),
        (incident_type  or "").lower().strip(),
        (injury_category or "").lower().strip(),
        (insurer        or "").lower().strip(),
        (settlement_band or "").lower().strip(),
        (settlement_month or "").lower().strip(),
    ]
    raw = "|".join(components)
    full_hash = hashlib.sha256(raw.encode("utf-8")).hexdigest()
    return full_hash  # caller may store full or prefix as needed


# ============================================================================
# MODULE-LEVEL SINGLETON
# ============================================================================

_billing_service: Optional[BillingService] = None


def get_billing_service() -> BillingService:
    """
    Get or create billing service singleton.

    Returns:
        BillingService instance
    """
    global _billing_service
    if _billing_service is None:
        _billing_service = BillingService()
    return _billing_service


# ============================================================================
# FASTAPI DEPENDENCY
# ============================================================================

async def require_leverage_access(
    tenant_id: str,
    user_id: Optional[str] = None
) -> Dict[str, Any]:
    """
    FastAPI dependency to validate LEVERAGE access.

    Usage:
        @router.post("/leverage/case/open")
        async def open_case(
            tenant_id: str,
            access: dict = Depends(lambda: require_leverage_access(tenant_id))
        ):
            # access["allowed"] == True
            # access["tier"] == "solo" | "growth" | "team"

    Args:
        tenant_id: Tenant UUID
        user_id: Optional attorney user ID

    Returns:
        Dict with access details

    Raises:
        HTTPException: If access denied or service unavailable
    """
    from fastapi import HTTPException, status

    billing = get_billing_service()

    try:
        return await billing.validate_leverage_access(tenant_id, user_id)

    except LeverageAccessDenied as e:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=str(e)
        )

    except TenantNotFound as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e)
        )

    except BillingServiceUnavailable as e:
        logger.error("Billing service unavailable: %s", e)
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Billing service unavailable - cannot validate access"
        )

    except BillingServiceError as e:
        logger.error("Billing service error: %s", e)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to validate LEVERAGE access"
        )


# ============================================================================
# BACKWARD COMPATIBILITY ALIASES
# ============================================================================

# These allow existing code that imports the old names to continue working
# during the transition. New code should use the LEVERAGE-named versions.
DraftFeatureAccess = LeverageFeatureAccess
DraftAccessDenied = LeverageAccessDenied
require_draft_access = require_leverage_access
