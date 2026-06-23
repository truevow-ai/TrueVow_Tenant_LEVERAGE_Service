"""
Tests covering:
- email_validation.py endpoint (log, history, stats, health)
- compliance.py service (generate_compliance_report)
"""
import asyncio
import pytest
from uuid import uuid4, UUID
from unittest.mock import MagicMock, patch, AsyncMock
from fastapi import HTTPException


FAKE_TENANT_ID = uuid4()
FAKE_TENANT_AUTH = {
    "user_id": str(uuid4()),
    "access_level": "tenant",
    "tenant_id": str(FAKE_TENANT_ID)
}


@pytest.fixture
def mock_db():
    return MagicMock()


# ─── Email Validation Endpoint Tests ──────────────────────────────────────────

class TestEmailValidationContextEndpoint:
    def test_get_context_success(self, mock_db):
        from app.api.v1.endpoints.email_validation import (
            get_email_validation_context,
            EmailValidationContextRequest
        )
        with patch("app.api.v1.endpoints.email_validation.EmailAttachmentValidationService") as MockSvc:
            svc = AsyncMock()
            svc.get_validation_context.return_value = {
                "rules": [],
                "context": {"practice_area": "pi"},
                "encryption": {"algorithm": "AES-256"},
                "source": "email_validation_service"
            }
            MockSvc.return_value = svc
            req = EmailValidationContextRequest(
                practice_area="personal_injury",
                document_type="demand_letter",
                jurisdiction_state="CA",
                tenant_id=FAKE_TENANT_ID
            )
            result = asyncio.get_event_loop().run_until_complete(
                get_email_validation_context(
                    request=req, db=mock_db, api_key_data=FAKE_TENANT_AUTH
                )
            )
        assert result.source == "email_validation_service"

    def test_get_context_exception_returns_500(self, mock_db):
        from app.api.v1.endpoints.email_validation import (
            get_email_validation_context,
            EmailValidationContextRequest
        )
        with patch("app.api.v1.endpoints.email_validation.EmailAttachmentValidationService") as MockSvc:
            svc = AsyncMock()
            svc.get_validation_context.side_effect = Exception("service fail")
            MockSvc.return_value = svc
            req = EmailValidationContextRequest(
                practice_area="pi",
                document_type="demand",
                jurisdiction_state="CA"
            )
            with pytest.raises(HTTPException) as exc:
                asyncio.get_event_loop().run_until_complete(
                    get_email_validation_context(
                        request=req, db=mock_db, api_key_data=FAKE_TENANT_AUTH
                    )
                )
            assert exc.value.status_code == 500


class TestEmailValidationLogEndpoint:
    def test_log_validation_success(self, mock_db):
        from app.api.v1.endpoints.email_validation import (
            log_email_validation,
            EmailValidationLogRequest,
            ValidationResult,
            EmailMetadata,
            ClientInfo
        )
        with patch("app.api.v1.endpoints.email_validation.EmailAttachmentValidationService") as MockSvc:
            svc = AsyncMock()
            svc.log_email_attachment_validation.return_value = None
            MockSvc.return_value = svc
            req = EmailValidationLogRequest(
                tenant_id=FAKE_TENANT_ID,
                user_id=uuid4(),
                practice_area="personal_injury",
                document_type="demand_letter",
                jurisdiction_state="CA",
                validation_passed=True,
                validation_result=ValidationResult(
                    rules_checked=5, rules_passed=5, rules_failed=0
                ),
                email_metadata=EmailMetadata(
                    sender="test@example.com",
                    date="2025-01-01T00:00:00"
                ),
                client_info=ClientInfo(client_type="email_addin", client_version="1.0")
            )
            result = asyncio.get_event_loop().run_until_complete(
                log_email_validation(
                    request=req, db=mock_db, api_key_data=FAKE_TENANT_AUTH
                )
            )
        assert result["success"] is True

    def test_log_validation_no_client_info(self, mock_db):
        from app.api.v1.endpoints.email_validation import (
            log_email_validation,
            EmailValidationLogRequest,
            ValidationResult,
            EmailMetadata
        )
        with patch("app.api.v1.endpoints.email_validation.EmailAttachmentValidationService") as MockSvc:
            svc = AsyncMock()
            svc.log_email_attachment_validation.return_value = None
            MockSvc.return_value = svc
            req = EmailValidationLogRequest(
                tenant_id=FAKE_TENANT_ID,
                practice_area="pi",
                document_type="demand",
                jurisdiction_state="CA",
                validation_passed=False,
                validation_result=ValidationResult(
                    rules_checked=3, rules_passed=1, rules_failed=2
                ),
                email_metadata=EmailMetadata()
            )
            result = asyncio.get_event_loop().run_until_complete(
                log_email_validation(
                    request=req, db=mock_db, api_key_data=FAKE_TENANT_AUTH
                )
            )
        assert result["success"] is True

    def test_log_validation_exception_returns_500(self, mock_db):
        from app.api.v1.endpoints.email_validation import (
            log_email_validation,
            EmailValidationLogRequest,
            ValidationResult,
            EmailMetadata
        )
        with patch("app.api.v1.endpoints.email_validation.EmailAttachmentValidationService") as MockSvc:
            svc = AsyncMock()
            svc.log_email_attachment_validation.side_effect = Exception("db fail")
            MockSvc.return_value = svc
            req = EmailValidationLogRequest(
                tenant_id=FAKE_TENANT_ID,
                practice_area="pi",
                document_type="demand",
                jurisdiction_state="CA",
                validation_passed=True,
                validation_result=ValidationResult(
                    rules_checked=1, rules_passed=1, rules_failed=0
                ),
                email_metadata=EmailMetadata()
            )
            with pytest.raises(HTTPException) as exc:
                asyncio.get_event_loop().run_until_complete(
                    log_email_validation(
                        request=req, db=mock_db, api_key_data=FAKE_TENANT_AUTH
                    )
                )
            assert exc.value.status_code == 500


class TestEmailValidationHistoryEndpoint:
    def test_get_history_success(self, mock_db):
        from app.api.v1.endpoints.email_validation import get_email_validation_history
        with patch("app.api.v1.endpoints.email_validation.EmailAttachmentValidationService") as MockSvc:
            svc = AsyncMock()
            svc.get_email_validation_history.return_value = [
                {
                    "id": str(uuid4()), "event_type": "validation_run",
                    "event_timestamp": "2025-01-01T00:00:00",
                    "tenant_id": str(FAKE_TENANT_ID),
                    "user_id": None, "practice_area": "pi", "document_type": "demand",
                    "jurisdiction_state": "CA", "total_rules_checked": 5,
                    "rules_passed": 5, "rules_failed": 0, "rules_warned": 0,
                    "validation_duration_ms": 100, "email_sender": None,
                    "email_date": None, "source": "email_addin"
                }
            ]
            MockSvc.return_value = svc
            result = asyncio.get_event_loop().run_until_complete(
                get_email_validation_history(
                    tenant_id=FAKE_TENANT_ID,
                    limit=50, offset=0,
                    practice_area="pi", document_type="demand",
                    jurisdiction_state="CA",
                    start_date="2025-01-01T00:00:00",
                    end_date="2025-12-31T00:00:00",
                    validation_passed=True,
                    db=mock_db, api_key_data=FAKE_TENANT_AUTH
                )
            )
        assert len(result) == 1

    def test_get_history_no_filters(self, mock_db):
        from app.api.v1.endpoints.email_validation import get_email_validation_history
        with patch("app.api.v1.endpoints.email_validation.EmailAttachmentValidationService") as MockSvc:
            svc = AsyncMock()
            svc.get_email_validation_history.return_value = []
            MockSvc.return_value = svc
            result = asyncio.get_event_loop().run_until_complete(
                get_email_validation_history(
                    tenant_id=FAKE_TENANT_ID,
                    limit=50, offset=0,
                    practice_area=None, document_type=None,
                    jurisdiction_state=None,
                    start_date=None, end_date=None,
                    validation_passed=None,
                    db=mock_db, api_key_data=FAKE_TENANT_AUTH
                )
            )
        assert result == []

    def test_get_history_exception_returns_500(self, mock_db):
        from app.api.v1.endpoints.email_validation import get_email_validation_history
        with patch("app.api.v1.endpoints.email_validation.EmailAttachmentValidationService") as MockSvc:
            svc = AsyncMock()
            svc.get_email_validation_history.side_effect = Exception("fail")
            MockSvc.return_value = svc
            with pytest.raises(HTTPException) as exc:
                asyncio.get_event_loop().run_until_complete(
                    get_email_validation_history(
                        tenant_id=FAKE_TENANT_ID,
                        limit=50, offset=0,
                        practice_area=None, document_type=None,
                        jurisdiction_state=None,
                        start_date=None, end_date=None,
                        validation_passed=None,
                        db=mock_db, api_key_data=FAKE_TENANT_AUTH
                    )
                )
            assert exc.value.status_code == 500


class TestEmailValidationStatsEndpoint:
    def test_get_stats_success(self, mock_db):
        from app.api.v1.endpoints.email_validation import get_email_validation_stats
        with patch("app.api.v1.endpoints.email_validation.EmailAttachmentValidationService") as MockSvc:
            svc = AsyncMock()
            svc.get_email_validation_stats.return_value = {
                "total_validations": 10,
                "passed": 8, "failed": 2, "pass_rate": 80.0,
                "avg_duration_ms": 120,
                "most_common_document_type": "demand_letter",
                "most_common_practice_area": "pi"
            }
            MockSvc.return_value = svc
            result = asyncio.get_event_loop().run_until_complete(
                get_email_validation_stats(
                    tenant_id=FAKE_TENANT_ID,
                    start_date="2025-01-01T00:00:00",
                    end_date="2025-12-31T00:00:00",
                    db=mock_db, api_key_data=FAKE_TENANT_AUTH
                )
            )
        assert result.total_validations == 10

    def test_get_stats_no_dates(self, mock_db):
        from app.api.v1.endpoints.email_validation import get_email_validation_stats
        with patch("app.api.v1.endpoints.email_validation.EmailAttachmentValidationService") as MockSvc:
            svc = AsyncMock()
            svc.get_email_validation_stats.return_value = {
                "total_validations": 0,
                "passed": 0, "failed": 0, "pass_rate": 0.0,
                "avg_duration_ms": 0,
                "most_common_document_type": None,
                "most_common_practice_area": None
            }
            MockSvc.return_value = svc
            result = asyncio.get_event_loop().run_until_complete(
                get_email_validation_stats(
                    tenant_id=FAKE_TENANT_ID,
                    start_date=None, end_date=None,
                    db=mock_db, api_key_data=FAKE_TENANT_AUTH
                )
            )
        assert result.pass_rate == 0.0

    def test_get_stats_exception_returns_500(self, mock_db):
        from app.api.v1.endpoints.email_validation import get_email_validation_stats
        with patch("app.api.v1.endpoints.email_validation.EmailAttachmentValidationService") as MockSvc:
            svc = AsyncMock()
            svc.get_email_validation_stats.side_effect = Exception("fail")
            MockSvc.return_value = svc
            with pytest.raises(HTTPException) as exc:
                asyncio.get_event_loop().run_until_complete(
                    get_email_validation_stats(
                        tenant_id=FAKE_TENANT_ID,
                        start_date=None, end_date=None,
                        db=mock_db, api_key_data=FAKE_TENANT_AUTH
                    )
                )
            assert exc.value.status_code == 500


class TestEmailValidationHealthEndpoint:
    def test_health_check(self, mock_db):
        from app.api.v1.endpoints.email_validation import email_validation_health_check
        result = asyncio.get_event_loop().run_until_complete(
            email_validation_health_check()
        )
        assert result["status"] == "healthy"


# ─── Compliance Service Tests ──────────────────────────────────────────────────

class TestComplianceServiceGenerateReport:
    def test_generate_report_defaults(self, mock_db):
        from app.services.compliance import ComplianceService
        from app.models.analytics_v2 import ValidationAnalytics

        # Create mock attributes for comparison operators
        ts = MagicMock()
        ts.__ge__ = MagicMock(return_value=MagicMock())
        ts.__le__ = MagicMock(return_value=MagicMock())
        rf = MagicMock()
        rf.__gt__ = MagicMock(return_value=MagicMock())

        q = MagicMock()
        q.filter.return_value = q
        q.count.side_effect = [10, 3, 1]
        q.with_entities.return_value = q
        q.group_by.return_value = q
        q.order_by.return_value = q
        q.limit.return_value = q
        q.all.return_value = []
        mock_db.query.return_value = q

        with patch.object(ValidationAnalytics, 'event_timestamp', new=ts, create=True):
            with patch.object(ValidationAnalytics, 'rules_failed', new=rf, create=True):
                with patch.object(ValidationAnalytics, 'is_compliance_issue', new=MagicMock(), create=True):
                    with patch.object(ValidationAnalytics, 'event_type', new=MagicMock(), create=True):
                        with patch.object(ValidationAnalytics, 'failed_rule_ids', new=MagicMock(), create=True):
                            svc = ComplianceService(mock_db)
                            result = svc.generate_compliance_report()

        assert "summary" in result
        assert "compliance_score" in result["summary"]

    def test_generate_report_with_all_params(self, mock_db):
        from app.services.compliance import ComplianceService
        from app.models.analytics_v2 import ValidationAnalytics
        from datetime import datetime, timedelta

        ts = MagicMock()
        ts.__ge__ = MagicMock(return_value=MagicMock())
        ts.__le__ = MagicMock(return_value=MagicMock())
        rf = MagicMock()
        rf.__gt__ = MagicMock(return_value=MagicMock())

        q = MagicMock()
        q.filter.return_value = q
        q.count.side_effect = [0, 0, 0]
        q.with_entities.return_value = q
        q.group_by.return_value = q
        q.order_by.return_value = q
        q.limit.return_value = q
        q.all.return_value = []
        mock_db.query.return_value = q

        start = datetime.utcnow() - timedelta(days=30)
        end = datetime.utcnow()

        with patch.object(ValidationAnalytics, 'event_timestamp', new=ts, create=True):
            with patch.object(ValidationAnalytics, 'rules_failed', new=rf, create=True):
                with patch.object(ValidationAnalytics, 'is_compliance_issue', new=MagicMock(), create=True):
                    with patch.object(ValidationAnalytics, 'event_type', new=MagicMock(), create=True):
                        with patch.object(ValidationAnalytics, 'failed_rule_ids', new=MagicMock(), create=True):
                            svc = ComplianceService(mock_db)
                            result = svc.generate_compliance_report(
                                tenant_id=uuid4(),
                                start_date=start,
                                end_date=end
                            )

        assert result["summary"]["compliance_score"] == 100.0

    def test_compliance_status_levels(self, mock_db):
        """Test different compliance status values based on score."""
        from app.services.compliance import ComplianceService
        from app.models.analytics_v2 import ValidationAnalytics

        ts = MagicMock()
        ts.__ge__ = MagicMock(return_value=MagicMock())
        ts.__le__ = MagicMock(return_value=MagicMock())
        rf = MagicMock()
        rf.__gt__ = MagicMock(return_value=MagicMock())

        # 50% failure rate -> score 50 -> "poor"
        q = MagicMock()
        q.filter.return_value = q
        q.count.side_effect = [10, 5, 1]  # 10 total, 5 failed -> 50% failure
        q.with_entities.return_value = q
        q.group_by.return_value = q
        q.order_by.return_value = q
        q.limit.return_value = q
        q.all.return_value = []
        mock_db.query.return_value = q

        with patch.object(ValidationAnalytics, 'event_timestamp', new=ts, create=True):
            with patch.object(ValidationAnalytics, 'rules_failed', new=rf, create=True):
                with patch.object(ValidationAnalytics, 'is_compliance_issue', new=MagicMock(), create=True):
                    with patch.object(ValidationAnalytics, 'event_type', new=MagicMock(), create=True):
                        with patch.object(ValidationAnalytics, 'failed_rule_ids', new=MagicMock(), create=True):
                            svc = ComplianceService(mock_db)
                            result = svc.generate_compliance_report()

        # compliance_score = 100 - 50 = 50, which is "poor"
        assert result["summary"]["compliance_status"] == "poor"
