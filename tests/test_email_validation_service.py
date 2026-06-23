"""
Tests for EmailAttachmentValidationService (app/services/email_validation.py).
Covers get_validation_context, log_email_attachment_validation,
get_email_validation_history, get_email_validation_stats, _hash_email_subject.
"""

import pytest
import asyncio
from datetime import datetime, timedelta
from unittest.mock import MagicMock, patch, AsyncMock
from uuid import uuid4

from app.services.email_validation import EmailAttachmentValidationService


@pytest.fixture
def mock_db():
    return MagicMock()


@pytest.fixture
def svc(mock_db):
    service = EmailAttachmentValidationService(mock_db)
    # Replace the real sync_service with a mock so get_rules_for_sync works
    service.sync_service = MagicMock()
    service.sync_service.get_rules_for_sync = AsyncMock(return_value=[])
    return service


# ─── get_validation_context ───────────────────────────────────────────────────

class TestGetValidationContext:

    def test_returns_expected_keys(self, svc):
        result = asyncio.get_event_loop().run_until_complete(
            svc.get_validation_context(
                practice_area="personal_injury",
                specialization="car_accident",
                document_type="demand_letter",
                jurisdiction_state="CA",
            )
        )
        assert "rules" in result
        assert "context" in result
        assert "encryption" in result
        assert "source" in result

    def test_context_mirrors_inputs(self, svc):
        result = asyncio.get_event_loop().run_until_complete(
            svc.get_validation_context(
                practice_area="family_law",
                specialization="divorce",
                document_type="petition",
                jurisdiction_state="TX",
                jurisdiction_county="Travis",
            )
        )
        ctx = result["context"]
        assert ctx["practice_area"] == "family_law"
        assert ctx["specialization"] == "divorce"
        assert ctx["document_type"] == "petition"
        assert ctx["jurisdiction_state"] == "TX"
        assert ctx["jurisdiction_county"] == "Travis"

    def test_encryption_info_present(self, svc):
        result = asyncio.get_event_loop().run_until_complete(
            svc.get_validation_context(
                practice_area="pi",
                specialization=None,
                document_type="demand",
                jurisdiction_state="AZ",
            )
        )
        enc = result["encryption"]
        assert enc["algorithm"] == "AES-256-GCM"
        assert enc["key_version"] == 1

    def test_source_is_email_attachment(self, svc):
        result = asyncio.get_event_loop().run_until_complete(
            svc.get_validation_context(
                practice_area="pi",
                specialization=None,
                document_type="demand",
                jurisdiction_state="AZ",
            )
        )
        assert result["source"] == "email_attachment"

    def test_rules_forwarded_from_sync_service(self, svc):
        svc.sync_service.get_rules_for_sync = AsyncMock(return_value=[{"id": "r1"}])
        result = asyncio.get_event_loop().run_until_complete(
            svc.get_validation_context(
                practice_area="pi",
                specialization=None,
                document_type="demand",
                jurisdiction_state="AZ",
            )
        )
        assert result["rules"] == [{"id": "r1"}]

    def test_with_tenant_id(self, svc):
        tid = uuid4()
        result = asyncio.get_event_loop().run_until_complete(
            svc.get_validation_context(
                practice_area="pi",
                specialization=None,
                document_type="demand",
                jurisdiction_state="AZ",
                tenant_id=tid,
            )
        )
        assert result is not None
        # Verify sync_service was called with tenant_id
        call_kwargs = svc.sync_service.get_rules_for_sync.call_args[1]
        assert call_kwargs["tenant_id"] == tid


# ─── log_email_attachment_validation ─────────────────────────────────────────

class TestLogEmailAttachmentValidation:

    def _base_call(self, svc, **overrides):
        kwargs = dict(
            tenant_id=uuid4(),
            user_id=uuid4(),
            practice_area="personal_injury",
            document_type="demand_letter",
            jurisdiction_state="CA",
            validation_passed=True,
            validation_result={
                "rules_checked": 10,
                "rules_passed": 10,
                "rules_failed": 0,
                "warnings": [],
                "duration_ms": 100,
            },
            email_metadata={
                "sender": "client@law.com",
                "date": "2025-01-01T10:00:00Z",
                "subject": "Test Subject",
            },
        )
        kwargs.update(overrides)
        return asyncio.get_event_loop().run_until_complete(
            svc.log_email_attachment_validation(**kwargs)
        )

    def test_commits_to_db(self, svc, mock_db):
        with patch("app.services.email_validation.ValidationAnalytics") as MockModel:
            MockModel.return_value = MagicMock()
            self._base_call(svc)
        mock_db.add.assert_called_once()
        mock_db.commit.assert_called_once()

    def test_hashes_subject(self, svc, mock_db):
        captured = {}
        with patch("app.services.email_validation.ValidationAnalytics") as MockModel:
            def capture(**kw):
                captured.update(kw)
                return MagicMock()
            MockModel.side_effect = capture
            self._base_call(svc)
        # subject_hash should be a 32-char hex string
        subj = captured.get("email_subject_hash", "")
        assert len(subj) == 32
        assert subj.isalnum()

    def test_no_subject_leaves_hash_none(self, svc, mock_db):
        captured = {}
        with patch("app.services.email_validation.ValidationAnalytics") as MockModel:
            def capture(**kw):
                captured.update(kw)
                return MagicMock()
            MockModel.side_effect = capture
            self._base_call(svc, email_metadata={"sender": "x@y.com"})
        assert captured.get("email_subject_hash") is None

    def test_date_string_parsed(self, svc, mock_db):
        captured = {}
        with patch("app.services.email_validation.ValidationAnalytics") as MockModel:
            def capture(**kw):
                captured.update(kw)
                return MagicMock()
            MockModel.side_effect = capture
            self._base_call(svc)
        assert isinstance(captured.get("email_date"), datetime)

    def test_date_datetime_object(self, svc, mock_db):
        captured = {}
        with patch("app.services.email_validation.ValidationAnalytics") as MockModel:
            def capture(**kw):
                captured.update(kw)
                return MagicMock()
            MockModel.side_effect = capture
            self._base_call(svc, email_metadata={"date": datetime(2025, 1, 1, 12, 0), "subject": "hi"})
        assert isinstance(captured.get("email_date"), datetime)

    def test_invalid_date_skipped(self, svc, mock_db):
        captured = {}
        with patch("app.services.email_validation.ValidationAnalytics") as MockModel:
            def capture(**kw):
                captured.update(kw)
                return MagicMock()
            MockModel.side_effect = capture
            self._base_call(svc, email_metadata={"date": "not-a-date", "subject": "hi"})
        assert captured.get("email_date") is None

    def test_failed_rule_ids_converted(self, svc, mock_db):
        captured = {}
        rule_id = str(uuid4())
        with patch("app.services.email_validation.ValidationAnalytics") as MockModel:
            def capture(**kw):
                captured.update(kw)
                return MagicMock()
            MockModel.side_effect = capture
            self._base_call(svc, validation_result={
                "rules_checked": 5,
                "rules_passed": 4,
                "rules_failed": 1,
                "warnings": [],
                "failed_rule_ids": [rule_id],
            })
        ids = captured.get("failed_rule_ids")
        assert ids is not None
        from uuid import UUID
        assert isinstance(ids[0], UUID)

    def test_no_failed_rule_ids_none(self, svc, mock_db):
        captured = {}
        with patch("app.services.email_validation.ValidationAnalytics") as MockModel:
            def capture(**kw):
                captured.update(kw)
                return MagicMock()
            MockModel.side_effect = capture
            self._base_call(svc, validation_result={
                "rules_checked": 5,
                "rules_passed": 5,
                "rules_failed": 0,
                "warnings": [],
            })
        assert captured.get("failed_rule_ids") is None

    def test_is_compliance_issue_set_on_failure(self, svc, mock_db):
        captured = {}
        with patch("app.services.email_validation.ValidationAnalytics") as MockModel:
            def capture(**kw):
                captured.update(kw)
                return MagicMock()
            MockModel.side_effect = capture
            self._base_call(svc, validation_passed=False, validation_result={
                "rules_checked": 10,
                "rules_passed": 7,
                "rules_failed": 3,
                "warnings": [],
            })
        assert captured.get("is_compliance_issue") is True

    def test_not_compliance_issue_on_pass(self, svc, mock_db):
        captured = {}
        with patch("app.services.email_validation.ValidationAnalytics") as MockModel:
            def capture(**kw):
                captured.update(kw)
                return MagicMock()
            MockModel.side_effect = capture
            self._base_call(svc, validation_passed=True, validation_result={
                "rules_checked": 10,
                "rules_passed": 10,
                "rules_failed": 0,
                "warnings": [],
            })
        assert captured.get("is_compliance_issue") is False

    def test_client_info_used_when_provided(self, svc, mock_db):
        captured = {}
        with patch("app.services.email_validation.ValidationAnalytics") as MockModel:
            def capture(**kw):
                captured.update(kw)
                return MagicMock()
            MockModel.side_effect = capture
            self._base_call(svc, client_info={"client_type": "word_addin", "client_version": "2.0"})
        assert captured.get("client_type") == "word_addin"
        assert captured.get("client_version") == "2.0"

    def test_no_client_info_defaults_portal(self, svc, mock_db):
        captured = {}
        with patch("app.services.email_validation.ValidationAnalytics") as MockModel:
            def capture(**kw):
                captured.update(kw)
                return MagicMock()
            MockModel.side_effect = capture
            self._base_call(svc)
        assert captured.get("client_type") == "customer_portal"


# ─── get_email_validation_history ────────────────────────────────────────────

class TestGetEmailValidationHistory:

    def test_returns_list(self, svc, mock_db):
        mock_entry = MagicMock()
        mock_entry.to_dict.return_value = {"id": str(uuid4())}
        q = MagicMock()
        q.filter.return_value = q
        q.order_by.return_value = q
        q.limit.return_value = q
        q.offset.return_value = q
        q.all.return_value = [mock_entry]
        mock_db.query.return_value = q

        with patch("app.services.email_validation.ValidationAnalytics") as MockModel:
            MockModel.tenant_id = MagicMock()
            MockModel.source = MagicMock()
            result = asyncio.get_event_loop().run_until_complete(
                svc.get_email_validation_history(tenant_id=uuid4())
            )
        assert isinstance(result, list)
        assert len(result) == 1

    def test_with_practice_area_filter(self, svc, mock_db):
        q = MagicMock()
        q.filter.return_value = q
        q.order_by.return_value = q
        q.limit.return_value = q
        q.offset.return_value = q
        q.all.return_value = []
        mock_db.query.return_value = q

        with patch("app.services.email_validation.ValidationAnalytics") as MockModel:
            MockModel.tenant_id = MagicMock()
            MockModel.source = MagicMock()
            MockModel.practice_area = MagicMock()
            result = asyncio.get_event_loop().run_until_complete(
                svc.get_email_validation_history(
                    tenant_id=uuid4(),
                    filters={"practice_area": "personal_injury"},
                )
            )
        assert isinstance(result, list)

    def test_with_all_filters(self, svc, mock_db):
        q = MagicMock()
        q.filter.return_value = q
        q.order_by.return_value = q
        q.limit.return_value = q
        q.offset.return_value = q
        q.all.return_value = []
        mock_db.query.return_value = q

        with patch("app.services.email_validation.ValidationAnalytics") as MockModel:
            MockModel.tenant_id = MagicMock()
            MockModel.source = MagicMock()
            MockModel.practice_area = MagicMock()
            MockModel.document_type = MagicMock()
            MockModel.jurisdiction_state = MagicMock()
            ts = MagicMock()
            ts.__ge__ = MagicMock(return_value=MagicMock())
            ts.__le__ = MagicMock(return_value=MagicMock())
            MockModel.event_timestamp = ts
            rf = MagicMock()
            rf.__gt__ = MagicMock(return_value=MagicMock())
            MockModel.rules_failed = rf
            result = asyncio.get_event_loop().run_until_complete(
                svc.get_email_validation_history(
                    tenant_id=uuid4(),
                    filters={
                        "practice_area": "pi",
                        "document_type": "demand_letter",
                        "jurisdiction_state": "CA",
                        "start_date": datetime.utcnow() - timedelta(days=7),
                        "end_date": datetime.utcnow(),
                        "validation_passed": True,
                    },
                )
            )
        assert isinstance(result, list)

    def test_with_validation_failed_filter(self, svc, mock_db):
        q = MagicMock()
        q.filter.return_value = q
        q.order_by.return_value = q
        q.limit.return_value = q
        q.offset.return_value = q
        q.all.return_value = []
        mock_db.query.return_value = q

        with patch("app.services.email_validation.ValidationAnalytics") as MockModel:
            MockModel.tenant_id = MagicMock()
            MockModel.source = MagicMock()
            rf = MagicMock()
            rf.__gt__ = MagicMock(return_value=MagicMock())
            MockModel.rules_failed = rf
            result = asyncio.get_event_loop().run_until_complete(
                svc.get_email_validation_history(
                    tenant_id=uuid4(),
                    filters={"validation_passed": False},
                )
            )
        assert isinstance(result, list)


# ─── get_email_validation_stats ───────────────────────────────────────────────

class TestGetEmailValidationStats:

    def test_empty_returns_zeros(self, svc, mock_db):
        q = MagicMock()
        q.filter.return_value = q
        q.order_by.return_value = q
        q.all.return_value = []
        mock_db.query.return_value = q

        with patch("app.services.email_validation.ValidationAnalytics") as MockModel:
            MockModel.tenant_id = MagicMock()
            MockModel.source = MagicMock()
            result = asyncio.get_event_loop().run_until_complete(
                svc.get_email_validation_stats(tenant_id=uuid4())
            )
        assert result["total_validations"] == 0
        assert result["passed"] == 0
        assert result["pass_rate"] == 0.0

    def test_with_validations(self, svc, mock_db):
        v1 = MagicMock()
        v1.rules_failed = 0
        v1.validation_duration_ms = 100
        v1.document_type = "demand_letter"
        v1.practice_area = "personal_injury"

        v2 = MagicMock()
        v2.rules_failed = 2
        v2.validation_duration_ms = 200
        v2.document_type = "demand_letter"
        v2.practice_area = "personal_injury"

        q = MagicMock()
        q.filter.return_value = q
        q.all.return_value = [v1, v2]
        mock_db.query.return_value = q

        with patch("app.services.email_validation.ValidationAnalytics") as MockModel:
            MockModel.tenant_id = MagicMock()
            MockModel.source = MagicMock()
            result = asyncio.get_event_loop().run_until_complete(
                svc.get_email_validation_stats(tenant_id=uuid4())
            )
        assert result["total_validations"] == 2
        assert result["passed"] == 1
        assert result["failed"] == 1
        assert result["pass_rate"] == 0.5
        assert result["avg_duration_ms"] == 150
        assert result["most_common_document_type"] == "demand_letter"
        assert result["most_common_practice_area"] == "personal_injury"

    def test_with_date_filters(self, svc, mock_db):
        q = MagicMock()
        q.filter.return_value = q
        q.all.return_value = []
        mock_db.query.return_value = q

        with patch("app.services.email_validation.ValidationAnalytics") as MockModel:
            MockModel.tenant_id = MagicMock()
            MockModel.source = MagicMock()
            ts = MagicMock()
            ts.__ge__ = MagicMock(return_value=MagicMock())
            ts.__le__ = MagicMock(return_value=MagicMock())
            MockModel.event_timestamp = ts
            result = asyncio.get_event_loop().run_until_complete(
                svc.get_email_validation_stats(
                    tenant_id=uuid4(),
                    start_date=datetime.utcnow() - timedelta(days=7),
                    end_date=datetime.utcnow(),
                )
            )
        assert result["total_validations"] == 0

    def test_no_durations_avg_zero(self, svc, mock_db):
        v1 = MagicMock()
        v1.rules_failed = 0
        v1.validation_duration_ms = None  # no duration
        v1.document_type = None
        v1.practice_area = None

        q = MagicMock()
        q.filter.return_value = q
        q.all.return_value = [v1]
        mock_db.query.return_value = q

        with patch("app.services.email_validation.ValidationAnalytics") as MockModel:
            MockModel.tenant_id = MagicMock()
            MockModel.source = MagicMock()
            result = asyncio.get_event_loop().run_until_complete(
                svc.get_email_validation_stats(tenant_id=uuid4())
            )
        assert result["avg_duration_ms"] == 0


# ─── _hash_email_subject ──────────────────────────────────────────────────────

class TestHashEmailSubject:

    def test_returns_32_chars(self):
        result = EmailAttachmentValidationService._hash_email_subject("Hello Subject")
        assert len(result) == 32

    def test_deterministic(self):
        h1 = EmailAttachmentValidationService._hash_email_subject("same")
        h2 = EmailAttachmentValidationService._hash_email_subject("same")
        assert h1 == h2

    def test_different_inputs_different_output(self):
        h1 = EmailAttachmentValidationService._hash_email_subject("a")
        h2 = EmailAttachmentValidationService._hash_email_subject("b")
        assert h1 != h2

    def test_hex_only(self):
        result = EmailAttachmentValidationService._hash_email_subject("test")
        assert all(c in "0123456789abcdef" for c in result)

    def test_unicode_input(self):
        result = EmailAttachmentValidationService._hash_email_subject("Héllo Wörld")
        assert len(result) == 32
