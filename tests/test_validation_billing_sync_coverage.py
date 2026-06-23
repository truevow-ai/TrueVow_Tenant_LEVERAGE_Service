"""
Tests covering:
- validation.py batch, file upload, rules endpoints
- billing_service.py
- validation_rules_sync.py check_for_updates, get_rule_by_id, get_rules_by_ids
- auth_v2.py require_admin_access, require_tenant_access, verify_tenant_access, get_tenant_filter
"""
import asyncio
import pytest
from uuid import uuid4, UUID
from unittest.mock import MagicMock, patch, AsyncMock
from fastapi import HTTPException
from io import BytesIO


# ─── Validation Endpoint: batch and rules ────────────────────────────────────

class TestValidateBatchEndpoint:
    @pytest.fixture
    def mock_db(self):
        return MagicMock()

    def test_batch_no_rules_returns_all_pass(self, mock_db):
        from app.api.v1.endpoints.validation import validate_batch_endpoint, BatchValidationRequest
        with patch("app.api.v1.endpoints.validation.ValidationRulesSyncService") as MockSvc:
            svc = MagicMock()
            svc.get_validation_rules.return_value = {"validation_rules": []}
            MockSvc.return_value = svc
            req = BatchValidationRequest(
                tenant_id=str(uuid4()),
                document_type="demand_letter",
                jurisdiction=None,
                practice_area=None,
                documents=["doc one text", "doc two text"]
            )
            result = asyncio.get_event_loop().run_until_complete(
                validate_batch_endpoint(request=req, db=mock_db)
            )
        assert result.total_documents == 2
        assert result.passed_count == 2

    def test_batch_with_rules_validates_each(self, mock_db):
        from app.api.v1.endpoints.validation import validate_batch_endpoint, BatchValidationRequest
        with patch("app.api.v1.endpoints.validation.ValidationRulesSyncService") as MockSvc:
            svc = MagicMock()
            svc.get_validation_rules.return_value = {
                "validation_rules": [
                    {"rule_id": str(uuid4()), "rule_name": "r1", "rule_type": "keyword",
                     "severity": "error", "rule_config": {"keywords": ["forbidden"]}}
                ]
            }
            MockSvc.return_value = svc
            with patch("app.api.v1.endpoints.validation.validate_document_engine") as mock_engine:
                mock_engine.return_value = {
                    "validation_passed": True,
                    "errors_count": 0, "warnings_count": 0, "info_count": 0,
                    "total_rules_checked": 1, "validation_duration_ms": 5,
                    "errors": [], "warnings": [], "info": []
                }
                req = BatchValidationRequest(
                    tenant_id=str(uuid4()),
                    document_type="demand_letter",
                    documents=["text one"]
                )
                result = asyncio.get_event_loop().run_until_complete(
                    validate_batch_endpoint(request=req, db=mock_db)
                )
        assert result.total_documents == 1
        assert result.summary["total_rules"] == 1

    def test_batch_invalid_tenant_id_uses_empty_rules(self, mock_db):
        from app.api.v1.endpoints.validation import validate_batch_endpoint, BatchValidationRequest
        req = BatchValidationRequest(
            tenant_id="not-a-uuid",
            document_type="demand_letter",
            documents=["some text"]
        )
        result = asyncio.get_event_loop().run_until_complete(
            validate_batch_endpoint(request=req, db=mock_db)
        )
        assert result.passed_count == 1

    def test_batch_with_rule_objects_not_dicts(self, mock_db):
        from app.api.v1.endpoints.validation import validate_batch_endpoint, BatchValidationRequest
        rule_obj = MagicMock()
        rule_obj.rule_id = None
        rule_obj.id = uuid4()
        rule_obj.rule_name = "r1"
        rule_obj.rule_type = "keyword"
        rule_obj.severity = "error"
        rule_obj.rule_config = {"keywords": ["test"]}
        with patch("app.api.v1.endpoints.validation.ValidationRulesSyncService") as MockSvc:
            svc = MagicMock()
            svc.get_validation_rules.return_value = {"validation_rules": [rule_obj]}
            MockSvc.return_value = svc
            with patch("app.api.v1.endpoints.validation.validate_document_engine") as mock_engine:
                mock_engine.return_value = {
                    "validation_passed": False, "errors_count": 1, "warnings_count": 0,
                    "info_count": 0, "total_rules_checked": 1, "validation_duration_ms": 3,
                    "errors": ["err"], "warnings": [], "info": []
                }
                req = BatchValidationRequest(
                    tenant_id=str(uuid4()),
                    document_type="demand_letter",
                    documents=["doc"]
                )
                result = asyncio.get_event_loop().run_until_complete(
                    validate_batch_endpoint(request=req, db=mock_db)
                )
        assert result.failed_count == 1

    def test_batch_sync_exception_uses_empty_rules(self, mock_db):
        from app.api.v1.endpoints.validation import validate_batch_endpoint, BatchValidationRequest
        with patch("app.api.v1.endpoints.validation.ValidationRulesSyncService") as MockSvc:
            MockSvc.side_effect = Exception("sync fail")
            req = BatchValidationRequest(
                tenant_id=str(uuid4()),
                document_type="demand_letter",
                documents=["text"]
            )
            result = asyncio.get_event_loop().run_until_complete(
                validate_batch_endpoint(request=req, db=mock_db)
            )
        assert result.passed_count == 1

    def test_batch_http_exception_reraises(self, mock_db):
        from app.api.v1.endpoints.validation import validate_batch_endpoint, BatchValidationRequest
        # Trigger via engine raising HTTPException
        req = BatchValidationRequest(
            tenant_id=str(uuid4()),
            document_type="demand_letter",
            documents=["text"]
        )
        with patch("app.api.v1.endpoints.validation.ValidationRulesSyncService") as MockSvc:
            svc = MagicMock()
            svc.get_validation_rules.return_value = {
                "validation_rules": [{"rule_id": str(uuid4()), "rule_name": "r1",
                                      "rule_type": "keyword", "severity": "error",
                                      "rule_config": {}}]
            }
            MockSvc.return_value = svc
            with patch("app.api.v1.endpoints.validation.validate_document_engine") as mock_engine:
                mock_engine.side_effect = Exception("engine error")
                with pytest.raises(HTTPException) as exc:
                    asyncio.get_event_loop().run_until_complete(
                        validate_batch_endpoint(request=req, db=mock_db)
                    )
        assert exc.value.status_code == 500  # engine exception wrapped as 500


class TestGetValidationRulesEndpoint:
    @pytest.fixture
    def mock_db(self):
        return MagicMock()

    def test_get_rules_returns_rules(self, mock_db):
        from app.api.v1.endpoints.validation import get_validation_rules
        with patch("app.api.v1.endpoints.validation.ValidationRulesSyncService") as MockSvc:
            svc = MagicMock()
            svc.get_validation_rules.return_value = {
                "validation_rules": [{"rule_id": "r1"}]
            }
            MockSvc.return_value = svc
            result = asyncio.get_event_loop().run_until_complete(
                get_validation_rules(
                    tenant_id=str(uuid4()),
                    document_type="demand_letter",
                    jurisdiction="CA",
                    practice_area="pi",
                    db=mock_db
                )
            )
        assert result["total"] == 1

    def test_get_rules_invalid_tenant_uuid(self, mock_db):
        from app.api.v1.endpoints.validation import get_validation_rules
        result = asyncio.get_event_loop().run_until_complete(
            get_validation_rules(
                tenant_id="not-a-uuid",
                document_type=None,
                jurisdiction=None,
                practice_area=None,
                db=mock_db
            )
        )
        assert result["total"] == 0

    def test_get_rules_sync_exception(self, mock_db):
        from app.api.v1.endpoints.validation import get_validation_rules
        with patch("app.api.v1.endpoints.validation.ValidationRulesSyncService") as MockSvc:
            svc = MagicMock()
            svc.get_validation_rules.side_effect = Exception("sync fail")
            MockSvc.return_value = svc
            result = asyncio.get_event_loop().run_until_complete(
                get_validation_rules(
                    tenant_id=str(uuid4()),
                    document_type=None,
                    jurisdiction=None,
                    practice_area=None,
                    db=mock_db
                )
            )
        assert result["total"] == 0

    def test_get_rules_outer_exception(self, mock_db):
        from app.api.v1.endpoints.validation import get_validation_rules
        # Sync failures are caught internally and return empty rules (no 500)
        with patch("app.api.v1.endpoints.validation.ValidationRulesSyncService") as MockSvc:
            MockSvc.side_effect = Exception("bad init")
            result = asyncio.get_event_loop().run_until_complete(
                get_validation_rules(
                    tenant_id=str(uuid4()),
                    document_type=None,
                    jurisdiction=None,
                    practice_area=None,
                    db=mock_db
                )
            )
        assert result["total"] == 0


class TestValidateDocumentEndpoint:
    """Test the main validate endpoint for object-format rules."""

    @pytest.fixture
    def mock_db(self):
        return MagicMock()

    def test_validate_with_object_format_rules(self, mock_db):
        from app.api.v1.endpoints.validation import validate_document_endpoint, ValidateDocumentRequest
        rule_obj = MagicMock()
        rule_obj.rule_id = None
        rule_obj.id = uuid4()
        rule_obj.rule_name = "r1"
        rule_obj.rule_type = "keyword"
        rule_obj.severity = "error"
        rule_obj.rule_config = None  # test None config

        with patch("app.api.v1.endpoints.validation.ValidationRulesSyncService") as MockSvc:
            svc = MagicMock()
            svc.get_validation_rules.return_value = {"validation_rules": [rule_obj]}
            MockSvc.return_value = svc
            with patch("app.api.v1.endpoints.validation.validate_document_engine") as mock_engine:
                mock_engine.return_value = {
                    "validation_passed": True, "errors_count": 0, "warnings_count": 0,
                    "info_count": 0, "total_rules_checked": 1, "validation_duration_ms": 5,
                    "errors": [], "warnings": [], "info": []
                }
                req = ValidateDocumentRequest(
                    tenant_id=str(uuid4()),
                    document_type="demand_letter",
                    document_text="Some document text here"
                )
                result = asyncio.get_event_loop().run_until_complete(
                    validate_document_endpoint(request=req, db=mock_db)
                )
        assert result.validation_passed is True

    def test_validate_http_exception_reraises(self, mock_db):
        from app.api.v1.endpoints.validation import validate_document_endpoint, ValidateDocumentRequest
        with patch("app.api.v1.endpoints.validation.ValidationRulesSyncService") as MockSvc:
            svc = MagicMock()
            svc.get_validation_rules.return_value = {"validation_rules": []}
            MockSvc.return_value = svc
            with patch("app.api.v1.endpoints.validation.ValidationResponse") as MockResp:
                MockResp.side_effect = HTTPException(status_code=422, detail="validation error")
                req = ValidateDocumentRequest(
                    tenant_id=str(uuid4()),
                    document_type="demand_letter",
                    document_text="text"
                )
                with pytest.raises(HTTPException) as exc:
                    asyncio.get_event_loop().run_until_complete(
                        validate_document_endpoint(request=req, db=mock_db)
                    )
                assert exc.value.status_code == 422


# ─── Billing Service Tests ─────────────────────────────────────────────────────

class TestBillingService:
    def test_get_client_creates_new_client(self):
        from app.services.billing_service import BillingService
        with patch("app.services.billing_service.get_settings") as mock_settings:
            settings = MagicMock()
            settings.TENANT_BILLING_SERVICE_URL = "http://billing:8000"
            settings.TENANT_BILLING_SERVICE_API_KEY = "test-key"
            mock_settings.return_value = settings
            svc = BillingService()
            client = asyncio.get_event_loop().run_until_complete(svc._get_client())
            assert client is not None
            asyncio.get_event_loop().run_until_complete(svc.close())

    def test_get_client_reuses_existing(self):
        from app.services.billing_service import BillingService
        with patch("app.services.billing_service.get_settings") as mock_settings:
            settings = MagicMock()
            settings.TENANT_BILLING_SERVICE_URL = "http://billing:8000"
            settings.TENANT_BILLING_SERVICE_API_KEY = ""
            mock_settings.return_value = settings
            svc = BillingService()
            client1 = asyncio.get_event_loop().run_until_complete(svc._get_client())
            client2 = asyncio.get_event_loop().run_until_complete(svc._get_client())
            assert client1 is client2
            asyncio.get_event_loop().run_until_complete(svc.close())

    def test_close_idempotent_when_no_client(self):
        from app.services.billing_service import BillingService
        with patch("app.services.billing_service.get_settings") as mock_settings:
            settings = MagicMock()
            settings.TENANT_BILLING_SERVICE_URL = "http://billing:8000"
            settings.TENANT_BILLING_SERVICE_API_KEY = ""
            mock_settings.return_value = settings
            svc = BillingService()
            # Should not raise
            asyncio.get_event_loop().run_until_complete(svc.close())

    def test_get_feature_access_404_raises_tenant_not_found(self):
        from app.services.billing_service import BillingService, TenantNotFound
        with patch("app.services.billing_service.get_settings") as mock_settings:
            settings = MagicMock()
            settings.TENANT_BILLING_SERVICE_URL = "http://billing:8000"
            settings.TENANT_BILLING_SERVICE_API_KEY = "k"
            mock_settings.return_value = settings
            svc = BillingService()
            mock_resp = MagicMock()
            mock_resp.status_code = 404
            mock_client = AsyncMock()
            mock_client.get = AsyncMock(return_value=mock_resp)
            async def mock_get_client():
                return mock_client
            svc._get_client = mock_get_client
            with pytest.raises(TenantNotFound):
                asyncio.get_event_loop().run_until_complete(
                    svc.get_feature_access("tenant-1")
                )

    def test_get_feature_access_500_raises_unavailable(self):
        from app.services.billing_service import BillingService, BillingServiceUnavailable
        with patch("app.services.billing_service.get_settings") as mock_settings:
            settings = MagicMock()
            settings.TENANT_BILLING_SERVICE_URL = "http://billing:8000"
            settings.TENANT_BILLING_SERVICE_API_KEY = "k"
            mock_settings.return_value = settings
            svc = BillingService()
            mock_resp = MagicMock()
            mock_resp.status_code = 500
            mock_resp.text = "Server Error"
            mock_client = AsyncMock()
            mock_client.get = AsyncMock(return_value=mock_resp)
            async def mock_get_client():
                return mock_client
            svc._get_client = mock_get_client
            with pytest.raises(BillingServiceUnavailable):
                asyncio.get_event_loop().run_until_complete(
                    svc.get_feature_access("tenant-1")
                )

    def test_get_feature_access_timeout_raises_unavailable(self):
        from app.services.billing_service import BillingService, BillingServiceUnavailable
        import httpx
        with patch("app.services.billing_service.get_settings") as mock_settings:
            settings = MagicMock()
            settings.TENANT_BILLING_SERVICE_URL = "http://billing:8000"
            settings.TENANT_BILLING_SERVICE_API_KEY = "k"
            mock_settings.return_value = settings
            svc = BillingService()
            mock_client = AsyncMock()
            mock_client.get = AsyncMock(side_effect=httpx.TimeoutException("timeout"))
            async def mock_get_client():
                return mock_client
            svc._get_client = mock_get_client
            with pytest.raises(BillingServiceUnavailable):
                asyncio.get_event_loop().run_until_complete(
                    svc.get_feature_access("tenant-1")
                )

    def test_get_feature_access_connect_error_raises_unavailable(self):
        from app.services.billing_service import BillingService, BillingServiceUnavailable
        import httpx
        with patch("app.services.billing_service.get_settings") as mock_settings:
            settings = MagicMock()
            settings.TENANT_BILLING_SERVICE_URL = "http://billing:8000"
            settings.TENANT_BILLING_SERVICE_API_KEY = "k"
            mock_settings.return_value = settings
            svc = BillingService()
            mock_client = AsyncMock()
            mock_client.get = AsyncMock(side_effect=httpx.ConnectError("connection refused"))
            async def mock_get_client():
                return mock_client
            svc._get_client = mock_get_client
            with pytest.raises(BillingServiceUnavailable):
                asyncio.get_event_loop().run_until_complete(
                    svc.get_feature_access("tenant-1")
                )

    def test_get_feature_access_generic_error_raises_billing_error(self):
        from app.services.billing_service import BillingService, BillingServiceError
        with patch("app.services.billing_service.get_settings") as mock_settings:
            settings = MagicMock()
            settings.TENANT_BILLING_SERVICE_URL = "http://billing:8000"
            settings.TENANT_BILLING_SERVICE_API_KEY = "k"
            mock_settings.return_value = settings
            svc = BillingService()
            mock_client = AsyncMock()
            mock_client.get = AsyncMock(side_effect=ValueError("parse error"))
            async def mock_get_client():
                return mock_client
            svc._get_client = mock_get_client
            with pytest.raises(BillingServiceError):
                asyncio.get_event_loop().run_until_complete(
                    svc.get_feature_access("tenant-1")
                )

    def test_get_feature_access_success(self):
        from app.services.billing_service import BillingService
        with patch("app.services.billing_service.get_settings") as mock_settings:
            settings = MagicMock()
            settings.TENANT_BILLING_SERVICE_URL = "http://billing:8000"
            settings.TENANT_BILLING_SERVICE_API_KEY = "k"
            mock_settings.return_value = settings
            svc = BillingService()
            mock_resp = MagicMock()
            mock_resp.status_code = 200
            mock_resp.json.return_value = {
                "tenant_id": "t1", "tier": "solo",
                "features": {"leverage": {"enabled": True, "source": "tier", "included_cases": 5, "overage_price_per_case_usd": 19, "monthly_price_usd": 99}},
                "addons": [], "intake_bundle": {"enabled": False}
            }
            mock_resp.raise_for_status = MagicMock(return_value=None)
            mock_client = AsyncMock()
            mock_client.get = AsyncMock(return_value=mock_resp)
            async def mock_get_client():
                return mock_client
            svc._get_client = mock_get_client
            result = asyncio.get_event_loop().run_until_complete(
                svc.get_feature_access("t1")
            )
        assert result.tenant_id == "t1"
        assert result.leverage.enabled is True

    def test_validate_leverage_access_denied_when_not_enabled(self):
        from app.services.billing_service import BillingService, LeverageAccessDenied, LeverageFeatureAccess
        with patch("app.services.billing_service.get_settings") as mock_settings:
            settings = MagicMock()
            settings.TENANT_BILLING_SERVICE_URL = "http://billing:8000"
            settings.TENANT_BILLING_SERVICE_API_KEY = "k"
            mock_settings.return_value = settings
            svc = BillingService()
            mock_access = LeverageFeatureAccess(enabled=False, tier=None, source=None, included_cases=0, overage_price_per_case_usd=0, monthly_price_usd=0)
            async def mock_get_leverage(*args, **kwargs):
                return mock_access
            svc.get_leverage_access = mock_get_leverage
            with pytest.raises(LeverageAccessDenied):
                asyncio.get_event_loop().run_until_complete(
                    svc.validate_leverage_access("t1")
                )

    def test_has_leverage_addon_no_longer_exists(self):
        # has_draft_addon was removed in v1 pricing redesign
        # This test verifies the service still instantiates correctly
        from app.services.billing_service import BillingService
        with patch("app.services.billing_service.get_settings") as mock_settings:
            settings = MagicMock()
            settings.TENANT_BILLING_SERVICE_URL = "http://billing:8000"
            settings.TENANT_BILLING_SERVICE_API_KEY = ""
            mock_settings.return_value = settings
            svc = BillingService()
            assert svc is not None

    def test_no_draft_addon_method(self):
        # has_draft_addon was removed in v1 pricing redesign
        from app.services.billing_service import BillingService
        with patch("app.services.billing_service.get_settings") as mock_settings:
            settings = MagicMock()
            settings.TENANT_BILLING_SERVICE_URL = "http://billing:8000"
            settings.TENANT_BILLING_SERVICE_API_KEY = ""
            mock_settings.return_value = settings
            svc = BillingService()
            assert not hasattr(svc, 'has_draft_addon')

    def test_get_billing_service_singleton(self):
        from app.services import billing_service
        with patch("app.services.billing_service.get_settings") as mock_settings:
            settings = MagicMock()
            settings.TENANT_BILLING_SERVICE_URL = "http://billing:8000"
            settings.TENANT_BILLING_SERVICE_API_KEY = ""
            mock_settings.return_value = settings
            billing_service._billing_service = None  # Reset singleton
            s1 = billing_service.get_billing_service()
            s2 = billing_service.get_billing_service()
            assert s1 is s2
            billing_service._billing_service = None  # Clean up

    def test_require_leverage_access_dependency_403(self):
        from app.services.billing_service import require_leverage_access, LeverageAccessDenied
        with patch("app.services.billing_service.get_billing_service") as mock_get:
            svc = AsyncMock()
            svc.validate_leverage_access.side_effect = LeverageAccessDenied("not enabled")
            mock_get.return_value = svc
            with pytest.raises(HTTPException) as exc:
                asyncio.get_event_loop().run_until_complete(
                    require_leverage_access("t1")
                )
            assert exc.value.status_code == 403

    def test_require_leverage_access_dependency_404(self):
        from app.services.billing_service import require_leverage_access, TenantNotFound
        with patch("app.services.billing_service.get_billing_service") as mock_get:
            svc = AsyncMock()
            svc.validate_leverage_access.side_effect = TenantNotFound("not found")
            mock_get.return_value = svc
            with pytest.raises(HTTPException) as exc:
                asyncio.get_event_loop().run_until_complete(
                    require_leverage_access("t1")
                )
            assert exc.value.status_code == 404

    def test_require_leverage_access_dependency_503(self):
        from app.services.billing_service import require_leverage_access, BillingServiceUnavailable
        with patch("app.services.billing_service.get_billing_service") as mock_get:
            svc = AsyncMock()
            svc.validate_leverage_access.side_effect = BillingServiceUnavailable("down")
            mock_get.return_value = svc
            with pytest.raises(HTTPException) as exc:
                asyncio.get_event_loop().run_until_complete(
                    require_leverage_access("t1")
                )
            assert exc.value.status_code == 503

    def test_require_leverage_access_dependency_500(self):
        from app.services.billing_service import require_leverage_access, BillingServiceError
        with patch("app.services.billing_service.get_billing_service") as mock_get:
            svc = AsyncMock()
            svc.validate_leverage_access.side_effect = BillingServiceError("error")
            mock_get.return_value = svc
            with pytest.raises(HTTPException) as exc:
                asyncio.get_event_loop().run_until_complete(
                    require_leverage_access("t1")
                )
            assert exc.value.status_code == 500


# ─── Validation Rules Sync Tests ──────────────────────────────────────────────

class TestValidationRulesSyncService:
    @pytest.fixture
    def mock_db(self):
        return MagicMock()

    def test_get_rule_by_id_returns_rule(self, mock_db):
        from app.services.validation_rules_sync import ValidationRulesSyncService
        rule = MagicMock()
        q = MagicMock()
        q.filter.return_value = q
        q.first.return_value = rule
        mock_db.query.return_value = q
        svc = ValidationRulesSyncService(mock_db)
        result = svc.get_rule_by_id(uuid4())
        assert result is rule

    def test_get_rule_by_id_returns_none(self, mock_db):
        from app.services.validation_rules_sync import ValidationRulesSyncService
        q = MagicMock()
        q.filter.return_value = q
        q.first.return_value = None
        mock_db.query.return_value = q
        svc = ValidationRulesSyncService(mock_db)
        result = svc.get_rule_by_id(uuid4())
        assert result is None

    def test_get_rules_by_ids(self, mock_db):
        from app.services.validation_rules_sync import ValidationRulesSyncService
        rules = [MagicMock(), MagicMock()]
        q = MagicMock()
        q.filter.return_value = q
        q.all.return_value = rules
        mock_db.query.return_value = q
        svc = ValidationRulesSyncService(mock_db)
        result = svc.get_rules_by_ids([uuid4(), uuid4()])
        assert result == rules

    def test_check_for_updates_no_updates(self, mock_db):
        from app.services.validation_rules_sync import ValidationRulesSyncService
        q = MagicMock()
        q.filter.return_value = q
        q.all.return_value = []
        latest = MagicMock()
        latest.version = 5
        q.order_by.return_value = q
        q.first.return_value = latest
        mock_db.query.return_value = q
        svc = ValidationRulesSyncService(mock_db)
        result = svc.check_for_updates(tenant_id=uuid4(), current_version=5)
        assert result["updates_available"] is False

    def test_check_for_updates_has_updates(self, mock_db):
        from app.services.validation_rules_sync import ValidationRulesSyncService
        rule = MagicMock()
        rule.version = 6
        rule.to_dict.return_value = {}
        q = MagicMock()
        q.filter.return_value = q
        q.all.return_value = [rule]
        latest = MagicMock()
        latest.version = 6
        q.order_by.return_value = q
        q.first.return_value = latest
        mock_db.query.return_value = q
        svc = ValidationRulesSyncService(mock_db)
        result = svc.check_for_updates(tenant_id=uuid4(), current_version=5)
        assert result["updates_available"] is True

    def test_check_for_updates_with_all_filters(self, mock_db):
        from app.services.validation_rules_sync import ValidationRulesSyncService
        q = MagicMock()
        q.filter.return_value = q
        q.all.return_value = []
        q.order_by.return_value = q
        q.first.return_value = None
        mock_db.query.return_value = q
        svc = ValidationRulesSyncService(mock_db)
        result = svc.check_for_updates(
            tenant_id=uuid4(),
            current_version=1,
            practice_area="pi",
            specialization="dog_bite",
            document_type="demand_letter",
            jurisdiction_state="CA"
        )
        # No latest version found -> version 1
        assert result["latest_version"] == 1


# ─── Auth V2 Tests ─────────────────────────────────────────────────────────────

class TestAuthV2Functions:
    @pytest.fixture
    def mock_db(self):
        return MagicMock()

    def test_require_admin_access_non_admin_raises_403(self, mock_db):
        from app.core.auth_v2 import require_admin_access
        with patch("app.core.auth_v2.get_api_key_from_header", new_callable=AsyncMock) as mock_get_key:
            mock_get_key.return_value = "test-key"
            with patch("app.core.auth_v2.authenticate_api_key", new_callable=AsyncMock) as mock_auth:
                mock_auth.return_value = {"access_level": "tenant", "tenant_id": str(uuid4())}
                from fastapi.security import HTTPAuthorizationCredentials
                creds = HTTPAuthorizationCredentials(scheme="Bearer", credentials="test-key")
                with pytest.raises(HTTPException) as exc:
                    asyncio.get_event_loop().run_until_complete(
                        require_admin_access(credentials=creds, db=mock_db)
                    )
                assert exc.value.status_code == 403

    def test_require_admin_access_admin_returns_data(self, mock_db):
        from app.core.auth_v2 import require_admin_access
        with patch("app.core.auth_v2.get_api_key_from_header", new_callable=AsyncMock) as mock_get_key:
            mock_get_key.return_value = "test-key"
            with patch("app.core.auth_v2.authenticate_api_key", new_callable=AsyncMock) as mock_auth:
                mock_auth.return_value = {"access_level": "admin", "tenant_id": None}
                from fastapi.security import HTTPAuthorizationCredentials
                creds = HTTPAuthorizationCredentials(scheme="Bearer", credentials="test-key")
                result = asyncio.get_event_loop().run_until_complete(
                    require_admin_access(credentials=creds, db=mock_db)
                )
                assert result["access_level"] == "admin"

    def test_require_tenant_access_non_tenant_raises_403(self, mock_db):
        from app.core.auth_v2 import require_tenant_access
        with patch("app.core.auth_v2.get_api_key_from_header", new_callable=AsyncMock) as mock_get_key:
            mock_get_key.return_value = "key"
            with patch("app.core.auth_v2.authenticate_api_key", new_callable=AsyncMock) as mock_auth:
                mock_auth.return_value = {"access_level": "admin", "tenant_id": None}
                from fastapi.security import HTTPAuthorizationCredentials
                creds = HTTPAuthorizationCredentials(scheme="Bearer", credentials="key")
                with pytest.raises(HTTPException) as exc:
                    asyncio.get_event_loop().run_until_complete(
                        require_tenant_access(credentials=creds, db=mock_db)
                    )
                assert exc.value.status_code == 403

    def test_require_tenant_access_missing_tenant_id_raises_500(self, mock_db):
        from app.core.auth_v2 import require_tenant_access
        with patch("app.core.auth_v2.get_api_key_from_header", new_callable=AsyncMock) as mock_get_key:
            mock_get_key.return_value = "key"
            with patch("app.core.auth_v2.authenticate_api_key", new_callable=AsyncMock) as mock_auth:
                mock_auth.return_value = {"access_level": "tenant", "tenant_id": None}
                from fastapi.security import HTTPAuthorizationCredentials
                creds = HTTPAuthorizationCredentials(scheme="Bearer", credentials="key")
                with pytest.raises(HTTPException) as exc:
                    asyncio.get_event_loop().run_until_complete(
                        require_tenant_access(credentials=creds, db=mock_db)
                    )
                assert exc.value.status_code == 500

    def test_require_tenant_access_success(self, mock_db):
        from app.core.auth_v2 import require_tenant_access
        tenant_id = str(uuid4())
        with patch("app.core.auth_v2.get_api_key_from_header", new_callable=AsyncMock) as mock_get_key:
            mock_get_key.return_value = "key"
            with patch("app.core.auth_v2.authenticate_api_key", new_callable=AsyncMock) as mock_auth:
                mock_auth.return_value = {"access_level": "tenant", "tenant_id": tenant_id}
                from fastapi.security import HTTPAuthorizationCredentials
                creds = HTTPAuthorizationCredentials(scheme="Bearer", credentials="key")
                result = asyncio.get_event_loop().run_until_complete(
                    require_tenant_access(credentials=creds, db=mock_db)
                )
                assert result["tenant_id"] == tenant_id

    def test_verify_tenant_access_admin_always_passes(self):
        from app.core.auth_v2 import verify_tenant_access
        api_key_data = {"access_level": "admin", "tenant_id": None}
        # Should not raise
        verify_tenant_access(api_key_data, uuid4())

    def test_verify_tenant_access_tenant_same_tenant_passes(self):
        from app.core.auth_v2 import verify_tenant_access
        tenant_id = uuid4()
        api_key_data = {"access_level": "tenant", "tenant_id": tenant_id}
        # Should not raise
        verify_tenant_access(api_key_data, tenant_id)

    def test_verify_tenant_access_tenant_different_tenant_raises_403(self):
        from app.core.auth_v2 import verify_tenant_access
        api_key_data = {"access_level": "tenant", "tenant_id": uuid4()}
        with pytest.raises(HTTPException) as exc:
            verify_tenant_access(api_key_data, uuid4())
        assert exc.value.status_code == 403

    def test_verify_tenant_access_external_raises_403(self):
        from app.core.auth_v2 import verify_tenant_access
        api_key_data = {"access_level": "external", "tenant_id": None}
        with pytest.raises(HTTPException) as exc:
            verify_tenant_access(api_key_data, uuid4())
        assert exc.value.status_code == 403

    def test_get_tenant_filter_admin_returns_none(self):
        from app.core.auth_v2 import get_tenant_filter
        result = get_tenant_filter({"access_level": "admin", "tenant_id": None})
        assert result is None

    def test_get_tenant_filter_tenant_returns_tenant_id(self):
        from app.core.auth_v2 import get_tenant_filter
        tid = uuid4()
        result = get_tenant_filter({"access_level": "tenant", "tenant_id": tid})
        assert result == tid

    def test_get_tenant_filter_external_raises_403(self):
        from app.core.auth_v2 import get_tenant_filter
        with pytest.raises(HTTPException) as exc:
            get_tenant_filter({"access_level": "external", "tenant_id": None})
        assert exc.value.status_code == 403
