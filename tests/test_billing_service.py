"""
Tests for BillingService (app/services/billing_service.py)
Uses httpx mock — no real HTTP calls.

Covers the LEVERAGE pricing tier model:
  SOLO:   $99/mo  — 5 active cases,  $19/extra
  GROWTH: $349/mo — 20 active cases, $14/extra
  TEAM:   $899/mo — 50 active cases,  $9/extra
"""

import pytest
from unittest.mock import MagicMock, AsyncMock, patch
from uuid import uuid4

from app.services.billing_service import (
    BillingService,
    LeverageFeatureAccess,
    LeverageTier,
    TierConfig,
    TIER_CONFIGS,
    FeatureAccessResponse,
    FeatureSource,
    BillingServiceError,
    BillingServiceUnavailable,
    TenantNotFound,
    LeverageAccessDenied,
    get_billing_service,
    _billing_service,
    INTAKE_BUNDLE_DISCOUNT_PCT,
)


# ---------------------------------------------------------------------------
# LeverageTier enum
# ---------------------------------------------------------------------------

class TestLeverageTier:
    def test_values(self):
        assert LeverageTier.SOLO == "solo"
        assert LeverageTier.GROWTH == "growth"
        assert LeverageTier.TEAM == "team"


# ---------------------------------------------------------------------------
# TIER_CONFIGS
# ---------------------------------------------------------------------------

class TestTierConfigs:
    def test_solo_config(self):
        cfg = TIER_CONFIGS[LeverageTier.SOLO]
        assert cfg.monthly_price_usd == 99
        assert cfg.included_cases == 5
        assert cfg.overage_price_per_case_usd == 49
        assert cfg.team_collaboration is False

    def test_growth_config(self):
        cfg = TIER_CONFIGS[LeverageTier.GROWTH]
        assert cfg.monthly_price_usd == 349
        assert cfg.included_cases == 20
        assert cfg.overage_price_per_case_usd == 39
        assert cfg.team_collaboration is True

    def test_team_config(self):
        cfg = TIER_CONFIGS[LeverageTier.TEAM]
        assert cfg.monthly_price_usd == 899
        assert cfg.included_cases == 50
        assert cfg.overage_price_per_case_usd == 29
        assert cfg.priority_support is True

    def test_all_tiers_present(self):
        assert len(TIER_CONFIGS) == 3
        assert set(TIER_CONFIGS.keys()) == {LeverageTier.SOLO, LeverageTier.GROWTH, LeverageTier.TEAM}


# ---------------------------------------------------------------------------
# LeverageFeatureAccess dataclass
# ---------------------------------------------------------------------------

class TestLeverageFeatureAccess:

    def test_case_limit_returns_included_cases(self):
        access = LeverageFeatureAccess(
            enabled=True, tier=LeverageTier.SOLO, source=FeatureSource.TIER,
            included_cases=5, overage_price_per_case_usd=49, monthly_price_usd=99,
        )
        assert access.case_limit == 5

    def test_overage_cases_when_under_limit(self):
        access = LeverageFeatureAccess(
            enabled=True, tier=LeverageTier.SOLO, source=FeatureSource.TIER,
            included_cases=5, overage_price_per_case_usd=49, monthly_price_usd=99,
            active_cases=3,
        )
        assert access.overage_cases == 0

    def test_overage_cases_when_at_limit(self):
        access = LeverageFeatureAccess(
            enabled=True, tier=LeverageTier.SOLO, source=FeatureSource.TIER,
            included_cases=5, overage_price_per_case_usd=49, monthly_price_usd=99,
            active_cases=5,
        )
        assert access.overage_cases == 0

    def test_overage_cases_when_over_limit(self):
        access = LeverageFeatureAccess(
            enabled=True, tier=LeverageTier.GROWTH, source=FeatureSource.TIER,
            included_cases=20, overage_price_per_case_usd=39, monthly_price_usd=349,
            active_cases=25,
        )
        assert access.overage_cases == 5

    def test_overage_charge_usd(self):
        access = LeverageFeatureAccess(
            enabled=True, tier=LeverageTier.GROWTH, source=FeatureSource.TIER,
            included_cases=20, overage_price_per_case_usd=39, monthly_price_usd=349,
            active_cases=25,
        )
        assert access.overage_charge_usd == 5 * 39

    def test_can_open_case_when_under_limit(self):
        access = LeverageFeatureAccess(
            enabled=True, tier=LeverageTier.SOLO, source=FeatureSource.TIER,
            included_cases=5, overage_price_per_case_usd=49, monthly_price_usd=99,
            active_cases=3,
        )
        assert access.can_open_case is True

    def test_can_open_case_when_at_limit(self):
        access = LeverageFeatureAccess(
            enabled=True, tier=LeverageTier.SOLO, source=FeatureSource.TIER,
            included_cases=5, overage_price_per_case_usd=49, monthly_price_usd=99,
            active_cases=5,
        )
        assert access.can_open_case is False

    def test_can_open_case_when_disabled(self):
        access = LeverageFeatureAccess(
            enabled=False, tier=None, source=None,
            included_cases=5, overage_price_per_case_usd=49, monthly_price_usd=99,
            active_cases=0,
        )
        assert access.can_open_case is False

    def test_effective_monthly_price_without_bundle(self):
        access = LeverageFeatureAccess(
            enabled=True, tier=LeverageTier.SOLO, source=FeatureSource.TIER,
            included_cases=5, overage_price_per_case_usd=49, monthly_price_usd=99,
            has_intake_bundle=False,
        )
        assert access.effective_monthly_price_usd == 99

    def test_effective_monthly_price_with_intake_bundle(self):
        access = LeverageFeatureAccess(
            enabled=True, tier=LeverageTier.SOLO, source=FeatureSource.TIER,
            included_cases=5, overage_price_per_case_usd=49, monthly_price_usd=99,
            has_intake_bundle=True,
        )
        expected = 99 - int(99 * INTAKE_BUNDLE_DISCOUNT_PCT / 100)
        assert access.effective_monthly_price_usd == expected


# ---------------------------------------------------------------------------
# BillingService._parse_feature_access
# ---------------------------------------------------------------------------

class TestParseFeatureAccess:

    def setup_method(self):
        self.service = BillingService(base_url="http://test", api_key="test-key")

    def test_parses_leverage_enabled_solo(self):
        data = {
            "tenant_id": "org_123",
            "tier": "solo",
            "features": {
                "leverage": {
                    "enabled": True,
                    "source": "tier",
                    "included_cases": 5,
                    "overage_price_per_case_usd": 19,
                    "monthly_price_usd": 99,
                }
            },
            "addons": [],
            "intake_bundle": {"enabled": False},
        }
        result = self.service._parse_feature_access(data)
        assert isinstance(result, FeatureAccessResponse)
        assert result.leverage.enabled is True
        assert result.leverage.tier == LeverageTier.SOLO
        assert result.leverage.included_cases == 5
        assert result.tenant_id == "org_123"
        assert result.has_intake_bundle is False

    def test_parses_growth_tier(self):
        data = {
            "tenant_id": "org_456",
            "tier": "growth",
            "features": {
                "leverage": {
                    "enabled": True,
                    "source": "tier",
                    "included_cases": 20,
                    "overage_price_per_case_usd": 14,
                    "monthly_price_usd": 349,
                }
            },
            "addons": [],
            "intake_bundle": {"enabled": True},
        }
        result = self.service._parse_feature_access(data)
        assert result.leverage.tier == LeverageTier.GROWTH
        assert result.leverage.included_cases == 20
        assert result.has_intake_bundle is True

    def test_parses_leverage_disabled(self):
        data = {
            "tenant_id": "org_789",
            "tier": "starter",
            "features": {
                "leverage": {
                    "enabled": False,
                    "source": None,
                }
            },
            "addons": [],
        }
        result = self.service._parse_feature_access(data)
        assert result.leverage.enabled is False
        assert result.leverage.tier is None

    def test_handles_missing_features_key(self):
        data = {
            "tenant_id": "org_000",
            "tier": "starter",
            "addons": [],
        }
        result = self.service._parse_feature_access(data)
        assert result.leverage.enabled is False

    def test_defaults_to_solo_tier_for_unknown(self):
        data = {
            "tenant_id": "org_unk",
            "tier": "unknown_tier",
            "features": {
                "leverage": {"enabled": True, "source": "tier"}
            },
            "addons": [],
        }
        result = self.service._parse_feature_access(data)
        # Should fall back to SOLO defaults
        assert result.leverage.included_cases == TIER_CONFIGS[LeverageTier.SOLO].included_cases


# ---------------------------------------------------------------------------
# BillingService async methods (mocked httpx)
# ---------------------------------------------------------------------------

class TestGetFeatureAccess:

    @pytest.mark.asyncio
    async def test_returns_parsed_response_on_200(self):
        service = BillingService(base_url="http://test", api_key="test-key")

        mock_response = MagicMock()
        mock_response.status_code = 200
        mock_response.json.return_value = {
            "tenant_id": "org_1",
            "tier": "solo",
            "features": {"leverage": {"enabled": True, "source": "tier", "included_cases": 5, "overage_price_per_case_usd": 19, "monthly_price_usd": 99}},
            "addons": [],
            "intake_bundle": {"enabled": False},
        }
        mock_response.raise_for_status = MagicMock()

        mock_client = AsyncMock()
        mock_client.get.return_value = mock_response
        mock_client.is_closed = False

        with patch.object(service, "_get_client", return_value=mock_client):
            result = await service.get_feature_access("org_1")

        assert result.leverage.enabled is True
        assert result.tenant_id == "org_1"

    @pytest.mark.asyncio
    async def test_raises_tenant_not_found_on_404(self):
        service = BillingService(base_url="http://test", api_key="test-key")

        mock_response = MagicMock()
        mock_response.status_code = 404

        mock_client = AsyncMock()
        mock_client.get.return_value = mock_response
        mock_client.is_closed = False

        with patch.object(service, "_get_client", return_value=mock_client):
            with pytest.raises(TenantNotFound):
                await service.get_feature_access("nonexistent")

    @pytest.mark.asyncio
    async def test_raises_billing_unavailable_on_500(self):
        import httpx
        service = BillingService(base_url="http://test", api_key="test-key")

        mock_response = MagicMock()
        mock_response.status_code = 500
        mock_response.text = "Internal Server Error"

        mock_client = AsyncMock()
        mock_client.get.return_value = mock_response
        mock_client.is_closed = False

        with patch.object(service, "_get_client", return_value=mock_client):
            with pytest.raises(BillingServiceUnavailable):
                await service.get_feature_access("org_1")

    @pytest.mark.asyncio
    async def test_raises_billing_unavailable_on_timeout(self):
        import httpx
        service = BillingService(base_url="http://test", api_key="test-key")

        mock_client = AsyncMock()
        mock_client.get.side_effect = httpx.TimeoutException("timeout")
        mock_client.is_closed = False

        with patch.object(service, "_get_client", return_value=mock_client):
            with pytest.raises(BillingServiceUnavailable):
                await service.get_feature_access("org_1")

    @pytest.mark.asyncio
    async def test_raises_billing_unavailable_on_connect_error(self):
        import httpx
        service = BillingService(base_url="http://test", api_key="test-key")

        mock_client = AsyncMock()
        mock_client.get.side_effect = httpx.ConnectError("connection refused")
        mock_client.is_closed = False

        with patch.object(service, "_get_client", return_value=mock_client):
            with pytest.raises(BillingServiceUnavailable):
                await service.get_feature_access("org_1")


# ---------------------------------------------------------------------------
# BillingService.validate_leverage_access
# ---------------------------------------------------------------------------

class TestValidateLeverageAccess:

    @pytest.mark.asyncio
    async def test_returns_allowed_when_enabled(self):
        service = BillingService(base_url="http://test", api_key="test-key")
        mock_access = LeverageFeatureAccess(
            enabled=True, tier=LeverageTier.GROWTH, source=FeatureSource.TIER,
            included_cases=20, overage_price_per_case_usd=39, monthly_price_usd=349,
        )
        with patch.object(service, "get_leverage_access", return_value=mock_access):
            result = await service.validate_leverage_access("org_1")

        assert result["allowed"] is True
        assert result["tier"] == "growth"
        assert result["included_cases"] == 20

    @pytest.mark.asyncio
    async def test_raises_access_denied_when_disabled(self):
        service = BillingService(base_url="http://test", api_key="test-key")
        mock_access = LeverageFeatureAccess(
            enabled=False, tier=None, source=None,
            included_cases=0, overage_price_per_case_usd=0, monthly_price_usd=0,
        )
        with patch.object(service, "get_leverage_access", return_value=mock_access):
            with pytest.raises(LeverageAccessDenied):
                await service.validate_leverage_access("org_1")


# ---------------------------------------------------------------------------
# BillingService.check_case_limit
# ---------------------------------------------------------------------------

class TestCheckCaseLimit:

    @pytest.mark.asyncio
    async def test_under_limit_not_overage(self):
        service = BillingService(base_url="http://test", api_key="test-key")
        mock_access = LeverageFeatureAccess(
            enabled=True, tier=LeverageTier.SOLO, source=FeatureSource.TIER,
            included_cases=5, overage_price_per_case_usd=49, monthly_price_usd=99,
            active_cases=3,
        )
        with patch.object(service, "get_leverage_access", return_value=mock_access):
            result = await service.check_case_limit("org_1")

        assert result["can_open"] is True
        assert result["is_overage"] is False
        assert result["overage_charge_usd"] == 0

    @pytest.mark.asyncio
    async def test_at_limit_is_overage(self):
        service = BillingService(base_url="http://test", api_key="test-key")
        mock_access = LeverageFeatureAccess(
            enabled=True, tier=LeverageTier.SOLO, source=FeatureSource.TIER,
            included_cases=5, overage_price_per_case_usd=49, monthly_price_usd=99,
            active_cases=5,
        )
        with patch.object(service, "get_leverage_access", return_value=mock_access):
            result = await service.check_case_limit("org_1")

        assert result["can_open"] is True  # Always allow — just charges more
        assert result["is_overage"] is True
        assert result["overage_charge_usd"] == 49
        assert result["authorized"] is True
        assert result["source"] == "overage"
        assert result["price_cents"] == 4900
        assert result["validations_unlimited"] is True

    @pytest.mark.asyncio
    async def test_fail_open_when_billing_unavailable(self):
        service = BillingService(base_url="http://test", api_key="test-key")
        with patch.object(service, "get_leverage_access", side_effect=BillingServiceUnavailable("down")):
            result = await service.check_case_limit("org_1")

        assert result["can_open"] is True  # Fail-open
        assert result["billing_unavailable"] is True

    @pytest.mark.asyncio
    async def test_denied_when_not_enabled(self):
        service = BillingService(base_url="http://test", api_key="test-key")
        mock_access = LeverageFeatureAccess(
            enabled=False, tier=None, source=None,
            included_cases=0, overage_price_per_case_usd=0, monthly_price_usd=0,
        )
        with patch.object(service, "get_leverage_access", return_value=mock_access):
            result = await service.check_case_limit("org_1")

        assert result["authorized"] is False
        assert result["can_open"] is not True  # Not authorized = can't open


# ---------------------------------------------------------------------------
# get_billing_service singleton
# ---------------------------------------------------------------------------

class TestGetBillingService:

    def test_returns_billing_service_instance(self):
        import app.services.billing_service as bm
        bm._billing_service = None  # reset singleton
        result = get_billing_service()
        assert isinstance(result, BillingService)

    def test_returns_same_instance_on_second_call(self):
        import app.services.billing_service as bm
        bm._billing_service = None
        first = get_billing_service()
        second = get_billing_service()
        assert first is second


# ---------------------------------------------------------------------------
# BillingService close method
# ---------------------------------------------------------------------------

class TestBillingServiceClose:

    @pytest.mark.asyncio
    async def test_close_sets_client_to_none(self):
        service = BillingService(base_url="http://test", api_key="test-key")
        mock_client = AsyncMock()
        mock_client.is_closed = False
        service._client = mock_client

        await service.close()

        mock_client.aclose.assert_called_once()
        assert service._client is None

    @pytest.mark.asyncio
    async def test_close_is_safe_when_no_client(self):
        service = BillingService(base_url="http://test", api_key="test-key")
        service._client = None
        # Should not raise
        await service.close()
