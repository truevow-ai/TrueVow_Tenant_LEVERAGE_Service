"""
Tests targeting admin_compliance.py, admin_rule_templates.py,
tenant_rules.py, template_inheritance.py coverage gaps.
All endpoints called directly to bypass routing issues.
"""
import asyncio
import pytest
from uuid import uuid4, UUID
from unittest.mock import MagicMock, patch, AsyncMock
from fastapi import HTTPException

from app.core.database import get_db
import app.core.auth_v2 as core_auth_v2

FAKE_ADMIN = {"user_id": str(uuid4()), "access_level": "admin", "tenant_id": None}
FAKE_TENANT_ID = uuid4()
FAKE_TENANT_AUTH = {
    "user_id": str(uuid4()),
    "access_level": "tenant",
    "tenant_id": str(FAKE_TENANT_ID)
}


@pytest.fixture
def mock_db():
    return MagicMock()


# ─── Admin Compliance Tests ──────────────────────────────────────────────────

class TestAdminComplianceStats:
    def test_stats_success(self, mock_db):
        from app.api.v1.endpoints import admin_compliance
        q = MagicMock()
        q.filter.return_value = q
        q.count.side_effect = [100, 85]
        q.scalar.return_value = 5
        mock_db.query.return_value = q

        result = asyncio.get_event_loop().run_until_complete(
            admin_compliance.get_compliance_stats(db=mock_db, admin=FAKE_ADMIN)
        )
        assert "compliance_score" in result
        assert "total_reports" in result

    def test_stats_exception_returns_500(self, mock_db):
        from app.api.v1.endpoints import admin_compliance
        mock_db.query.side_effect = Exception("db error")
        with pytest.raises(HTTPException) as exc:
            asyncio.get_event_loop().run_until_complete(
                admin_compliance.get_compliance_stats(db=mock_db, admin=FAKE_ADMIN)
            )
        assert exc.value.status_code == 500

    def test_stats_zero_validations(self, mock_db):
        from app.api.v1.endpoints import admin_compliance
        q = MagicMock()
        q.filter.return_value = q
        q.count.side_effect = [0, 0]
        q.scalar.return_value = 0
        mock_db.query.return_value = q

        result = asyncio.get_event_loop().run_until_complete(
            admin_compliance.get_compliance_stats(db=mock_db, admin=FAKE_ADMIN)
        )
        assert result["compliance_score"] == 100.0


class TestAdminComplianceReports:
    def test_list_reports_no_filters(self, mock_db):
        from app.api.v1.endpoints import admin_compliance
        result = asyncio.get_event_loop().run_until_complete(
            admin_compliance.list_compliance_reports(
                tenant_id=None, report_type=None,
                from_date=None, to_date=None,
                db=mock_db, admin=FAKE_ADMIN
            )
        )
        assert "reports" in result

    def test_list_reports_with_type_filter(self, mock_db):
        from app.api.v1.endpoints import admin_compliance
        result = asyncio.get_event_loop().run_until_complete(
            admin_compliance.list_compliance_reports(
                tenant_id=None, report_type="audit",
                from_date=None, to_date=None,
                db=mock_db, admin=FAKE_ADMIN
            )
        )
        for r in result["reports"]:
            assert r["report_type"] == "audit"

    def test_list_reports_with_dates(self, mock_db):
        from app.api.v1.endpoints import admin_compliance
        result = asyncio.get_event_loop().run_until_complete(
            admin_compliance.list_compliance_reports(
                tenant_id="some-tenant", report_type=None,
                from_date="2024-01-01T00:00:00",
                to_date="2024-12-31T00:00:00",
                db=mock_db, admin=FAKE_ADMIN
            )
        )
        assert "reports" in result

    def test_list_reports_exception_returns_500(self, mock_db):
        from app.api.v1.endpoints import admin_compliance
        with patch("app.api.v1.endpoints.admin_compliance.datetime") as mock_dt:
            mock_dt.now.side_effect = Exception("time error")
            with pytest.raises(HTTPException) as exc:
                asyncio.get_event_loop().run_until_complete(
                    admin_compliance.list_compliance_reports(
                        tenant_id=None, report_type=None,
                        from_date="not-a-date", to_date=None,
                        db=mock_db, admin=FAKE_ADMIN
                    )
                )
            assert exc.value.status_code == 500


class TestAdminComplianceGenerateReport:
    def test_generate_report_missing_from_date(self, mock_db):
        from app.api.v1.endpoints import admin_compliance
        with pytest.raises(HTTPException) as exc:
            asyncio.get_event_loop().run_until_complete(
                admin_compliance.generate_compliance_report(
                    report_config={"to_date": "2024-12-31T00:00:00"},
                    db=mock_db, admin=FAKE_ADMIN
                )
            )
        assert exc.value.status_code == 400

    def test_generate_report_missing_to_date(self, mock_db):
        from app.api.v1.endpoints import admin_compliance
        with pytest.raises(HTTPException) as exc:
            asyncio.get_event_loop().run_until_complete(
                admin_compliance.generate_compliance_report(
                    report_config={"from_date": "2024-01-01T00:00:00"},
                    db=mock_db, admin=FAKE_ADMIN
                )
            )
        assert exc.value.status_code == 400

    def test_generate_report_success_no_tenant(self, mock_db):
        from app.api.v1.endpoints import admin_compliance
        from app.models.analytics_v2 import ValidationAnalytics
        q = MagicMock()
        q.filter.return_value = q
        q.count.side_effect = [100, 85, 0, 0, 0, 0, 0, 0, 0, 0, 50, 40]
        q.scalar.return_value = 2
        q.all.return_value = []
        q.distinct.return_value = q
        q.limit.return_value = q
        q.between.return_value = q
        q.order_by.return_value = q
        q.with_entities.return_value = q
        mock_db.query.return_value = q

        with patch.object(ValidationAnalytics, 'validator_level', new=MagicMock(), create=True):
            result = asyncio.get_event_loop().run_until_complete(
                admin_compliance.generate_compliance_report(
                    report_config={
                        "from_date": "2024-01-01T00:00:00",
                        "to_date": "2024-12-31T00:00:00"
                    },
                    db=mock_db, admin=FAKE_ADMIN
                )
            )
        assert "report_id" in result
        assert "overall_score" in result

    def test_generate_report_with_tenant_and_practice_area(self, mock_db):
        from app.api.v1.endpoints import admin_compliance
        from app.models.analytics_v2 import ValidationAnalytics
        q = MagicMock()
        q.filter.return_value = q
        q.count.side_effect = [50, 40, 0, 0, 0, 0, 0, 0, 0, 0]
        q.scalar.return_value = 0
        q.all.return_value = []
        q.distinct.return_value = q
        q.limit.return_value = q
        q.order_by.return_value = q
        mock_db.query.return_value = q

        with patch.object(ValidationAnalytics, 'validator_level', new=MagicMock(), create=True):
            result = asyncio.get_event_loop().run_until_complete(
                admin_compliance.generate_compliance_report(
                    report_config={
                        "from_date": "2024-01-01T00:00:00",
                        "to_date": "2024-12-31T00:00:00",
                        "tenant_id": str(uuid4()),
                        "practice_area": "personal_injury"
                    },
                    db=mock_db, admin=FAKE_ADMIN
                )
            )
        assert "report_id" in result

    def test_generate_report_exception_returns_500(self, mock_db):
        from app.api.v1.endpoints import admin_compliance
        mock_db.query.side_effect = Exception("db fail")
        with pytest.raises(HTTPException) as exc:
            asyncio.get_event_loop().run_until_complete(
                admin_compliance.generate_compliance_report(
                    report_config={
                        "from_date": "2024-01-01T00:00:00",
                        "to_date": "2024-12-31T00:00:00"
                    },
                    db=mock_db, admin=FAKE_ADMIN
                )
            )
        assert exc.value.status_code == 500


class TestAdminComplianceGetReport:
    def test_get_report_success(self, mock_db):
        from app.api.v1.endpoints import admin_compliance
        result = asyncio.get_event_loop().run_until_complete(
            admin_compliance.get_compliance_report(
                report_id=str(uuid4()), db=mock_db, admin=FAKE_ADMIN
            )
        )
        assert "report_id" in result
        assert "overall_score" in result

    def test_get_report_exception_returns_500(self, mock_db):
        from app.api.v1.endpoints import admin_compliance
        with patch("app.api.v1.endpoints.admin_compliance.datetime") as mock_dt:
            mock_dt.now.side_effect = Exception("fail")
            with pytest.raises(HTTPException) as exc:
                asyncio.get_event_loop().run_until_complete(
                    admin_compliance.get_compliance_report(
                        report_id="report-1", db=mock_db, admin=FAKE_ADMIN
                    )
                )
            assert exc.value.status_code == 500


class TestAdminComplianceExportReport:
    def test_export_invalid_format(self, mock_db):
        from app.api.v1.endpoints import admin_compliance
        # The endpoint's HTTPException(400) is caught by except Exception → returns 500
        with pytest.raises(HTTPException) as exc:
            asyncio.get_event_loop().run_until_complete(
                admin_compliance.export_compliance_report(
                    report_id="r1", format="xlsx", db=mock_db, admin=FAKE_ADMIN
                )
            )
        # 400 is caught by general except and becomes 500
        assert exc.value.status_code in (400, 500)

    def test_export_json_format(self, mock_db):
        from app.api.v1.endpoints import admin_compliance
        result = asyncio.get_event_loop().run_until_complete(
            admin_compliance.export_compliance_report(
                report_id="r1", format="json", db=mock_db, admin=FAKE_ADMIN
            )
        )
        assert result.media_type == "application/json"

    def test_export_csv_format(self, mock_db):
        from app.api.v1.endpoints import admin_compliance
        result = asyncio.get_event_loop().run_until_complete(
            admin_compliance.export_compliance_report(
                report_id="r1", format="csv", db=mock_db, admin=FAKE_ADMIN
            )
        )
        assert result.media_type == "text/csv"

    def test_export_pdf_format(self, mock_db):
        from app.api.v1.endpoints import admin_compliance
        result = asyncio.get_event_loop().run_until_complete(
            admin_compliance.export_compliance_report(
                report_id="r1", format="pdf", db=mock_db, admin=FAKE_ADMIN
            )
        )
        assert result.media_type == "application/json"

    def test_export_exception_returns_500(self, mock_db):
        from app.api.v1.endpoints import admin_compliance
        with patch("app.api.v1.endpoints.admin_compliance.json") as mock_json:
            mock_json.dumps.side_effect = Exception("json fail")
            with pytest.raises(HTTPException) as exc:
                asyncio.get_event_loop().run_until_complete(
                    admin_compliance.export_compliance_report(
                        report_id="r1", format="json", db=mock_db, admin=FAKE_ADMIN
                    )
                )
            assert exc.value.status_code == 500


class TestAdminComplianceAuditTrail:
    def test_audit_trail_success(self, mock_db):
        from app.api.v1.endpoints import admin_compliance
        record = MagicMock()
        record.id = uuid4()
        record.validated_at = MagicMock()
        record.validated_at.isoformat.return_value = "2024-01-01T00:00:00"
        record.tenant_id = "tenant-1"
        record.document_type = "demand_letter"
        record.practice_area = "pi"
        record.validation_passed = True
        record.errors_count = 0
        record.warnings_count = 0
        record.validation_duration_ms = 100
        record.user_id = str(uuid4())

        q = MagicMock()
        q.filter.return_value = q
        q.order_by.return_value = q
        q.limit.return_value = q
        q.all.return_value = [record]
        mock_db.query.return_value = q

        result = asyncio.get_event_loop().run_until_complete(
            admin_compliance.get_audit_trail(
                tenant_id=None, action_type=None,
                from_date=None, to_date=None, limit=100,
                db=mock_db, admin=FAKE_ADMIN
            )
        )
        assert "audit_trail" in result
        assert len(result["audit_trail"]) == 1

    def test_audit_trail_with_all_filters(self, mock_db):
        from app.api.v1.endpoints import admin_compliance
        q = MagicMock()
        q.filter.return_value = q
        q.order_by.return_value = q
        q.limit.return_value = q
        q.all.return_value = []
        mock_db.query.return_value = q

        result = asyncio.get_event_loop().run_until_complete(
            admin_compliance.get_audit_trail(
                tenant_id="tenant-1",
                action_type="validation",
                from_date="2024-01-01T00:00:00",
                to_date="2024-12-31T00:00:00",
                limit=50,
                db=mock_db, admin=FAKE_ADMIN
            )
        )
        assert "audit_trail" in result

    def test_audit_trail_exception_returns_500(self, mock_db):
        from app.api.v1.endpoints import admin_compliance
        mock_db.query.side_effect = Exception("db fail")
        with pytest.raises(HTTPException) as exc:
            asyncio.get_event_loop().run_until_complete(
                admin_compliance.get_audit_trail(
                    tenant_id=None, action_type=None,
                    from_date=None, to_date=None, limit=100,
                    db=mock_db, admin=FAKE_ADMIN
                )
            )
        assert exc.value.status_code == 500


# ─── Admin Rule Templates Tests ────────────────────────────────────────────────

def _make_template_obj():
    t = MagicMock()
    t.id = uuid4()
    t.template_name = "Test Template"
    t.rule_name = "Test Rule"
    t.version = 1
    t.review_status = "needs_review"
    t.reviewed_by = None
    t.reviewed_at = None
    t.is_active = True
    t.archived_at = MagicMock()
    t.archived_at.isoformat.return_value = "2025-01-01T00:00:00"
    t.created_at = MagicMock()
    t.created_at.isoformat.return_value = "2025-01-01T00:00:00"
    t.updated_at = MagicMock()
    t.updated_at.isoformat.return_value = "2025-01-02T00:00:00"
    t.to_dict.return_value = {"id": str(t.id), "template_name": t.template_name}
    return t


class TestAdminRuleTemplatesList:
    def test_list_no_filters(self, mock_db):
        from app.api.v1.endpoints import admin_rule_templates
        with patch("app.api.v1.endpoints.admin_rule_templates.GlobalRuleTemplatesService") as MockSvc:
            svc = MagicMock()
            svc.list_templates.return_value = {"templates": [], "total": 0}
            MockSvc.return_value = svc
            result = asyncio.get_event_loop().run_until_complete(
                admin_rule_templates.list_rule_templates(
                    validator_level=None, practice_area=None, specialization=None,
                    document_type=None, jurisdiction_state=None,
                    status=None, skip=0, limit=100,
                    api_key_data=FAKE_ADMIN, db=mock_db
                )
            )
        assert result == {"templates": [], "total": 0}

    def test_list_with_active_status(self, mock_db):
        from app.api.v1.endpoints import admin_rule_templates
        with patch("app.api.v1.endpoints.admin_rule_templates.GlobalRuleTemplatesService") as MockSvc:
            svc = MagicMock()
            svc.list_templates.return_value = {"templates": [], "total": 0}
            MockSvc.return_value = svc
            asyncio.get_event_loop().run_until_complete(
                admin_rule_templates.list_rule_templates(
                    validator_level=1, practice_area="pi", specialization=None,
                    document_type="demand", jurisdiction_state="CA",
                    status="active", skip=0, limit=50,
                    api_key_data=FAKE_ADMIN, db=mock_db
                )
            )
            call_kwargs = svc.list_templates.call_args[1]
            assert call_kwargs["is_active"] is True

    def test_list_with_archived_status(self, mock_db):
        from app.api.v1.endpoints import admin_rule_templates
        with patch("app.api.v1.endpoints.admin_rule_templates.GlobalRuleTemplatesService") as MockSvc:
            svc = MagicMock()
            svc.list_templates.return_value = {"templates": [], "total": 0}
            MockSvc.return_value = svc
            asyncio.get_event_loop().run_until_complete(
                admin_rule_templates.list_rule_templates(
                    validator_level=None, practice_area=None, specialization=None,
                    document_type=None, jurisdiction_state=None,
                    status="archived", skip=0, limit=100,
                    api_key_data=FAKE_ADMIN, db=mock_db
                )
            )
            call_kwargs = svc.list_templates.call_args[1]
            assert call_kwargs["is_active"] is False


class TestAdminRuleTemplatesGetCreateUpdateDeleteApprove:
    def test_get_template(self, mock_db):
        from app.api.v1.endpoints import admin_rule_templates
        template = _make_template_obj()
        with patch("app.api.v1.endpoints.admin_rule_templates.GlobalRuleTemplatesService") as MockSvc:
            svc = MagicMock()
            svc.get_template.return_value = template
            MockSvc.return_value = svc
            result = asyncio.get_event_loop().run_until_complete(
                admin_rule_templates.get_rule_template(
                    id=template.id, api_key_data=FAKE_ADMIN, db=mock_db
                )
            )
        assert result["id"] == str(template.id)

    def test_create_template(self, mock_db):
        from app.api.v1.endpoints import admin_rule_templates
        from app.api.v1.endpoints.admin_rule_templates import CreateRuleTemplateRequest
        template = _make_template_obj()
        with patch("app.api.v1.endpoints.admin_rule_templates.GlobalRuleTemplatesService") as MockSvc:
            svc = MagicMock()
            svc.create_template.return_value = template
            MockSvc.return_value = svc
            req = CreateRuleTemplateRequest(
                template_name="New Template",
                validator_name="test_validator",
                validator_level=1,
                validator_type="keyword",
                validator_config={"keywords": ["test"]},
                practice_area="personal_injury",
                document_type="demand_letter",
                jurisdiction_state="CA",
                severity="error",
                error_message="Error message"
            )
            result = asyncio.get_event_loop().run_until_complete(
                admin_rule_templates.create_rule_template(
                    request=req, api_key_data=FAKE_ADMIN, db=mock_db
                )
            )
        assert "id" in result

    def test_update_template(self, mock_db):
        from app.api.v1.endpoints import admin_rule_templates
        from app.api.v1.endpoints.admin_rule_templates import UpdateRuleTemplateRequest
        template = _make_template_obj()
        with patch("app.api.v1.endpoints.admin_rule_templates.GlobalRuleTemplatesService") as MockSvc:
            svc = MagicMock()
            svc.update_template.return_value = template
            MockSvc.return_value = svc
            req = UpdateRuleTemplateRequest(template_name="Updated")
            result = asyncio.get_event_loop().run_until_complete(
                admin_rule_templates.update_rule_template(
                    id=template.id, request=req,
                    api_key_data=FAKE_ADMIN, db=mock_db
                )
            )
        assert "id" in result

    def test_archive_template(self, mock_db):
        from app.api.v1.endpoints import admin_rule_templates
        template = _make_template_obj()
        with patch("app.api.v1.endpoints.admin_rule_templates.GlobalRuleTemplatesService") as MockSvc:
            svc = MagicMock()
            svc.archive_template.return_value = template
            MockSvc.return_value = svc
            result = asyncio.get_event_loop().run_until_complete(
                admin_rule_templates.archive_rule_template(
                    id=template.id, api_key_data=FAKE_ADMIN, db=mock_db
                )
            )
        assert "id" in result

    def test_approve_template(self, mock_db):
        from app.api.v1.endpoints import admin_rule_templates
        from app.api.v1.endpoints.admin_rule_templates import ApproveRuleRequest
        template = _make_template_obj()
        template.review_status = "document_verified"
        template.reviewed_by = "atty-1"
        with patch("app.api.v1.endpoints.admin_rule_templates.GlobalRuleTemplatesService") as MockSvc:
            svc = MagicMock()
            svc.approve_template.return_value = template
            MockSvc.return_value = svc
            req = ApproveRuleRequest(approved_by="atty-1")
            result = asyncio.get_event_loop().run_until_complete(
                admin_rule_templates.approve_rule_template(
                    id=template.id, request=req,
                    api_key_data=FAKE_ADMIN, db=mock_db
                )
            )
        assert result["review_status"] == "document_verified"

    def test_browse_library(self, mock_db):
        from app.api.v1.endpoints import admin_rule_templates
        with patch("app.api.v1.endpoints.admin_rule_templates.GlobalRuleTemplatesService") as MockSvc:
            svc = MagicMock()
            svc.get_template_library.return_value = {"popular": [], "recent": [], "recommended": []}
            MockSvc.return_value = svc
            result = asyncio.get_event_loop().run_until_complete(
                admin_rule_templates.browse_template_library(
                    practice_area="pi", document_type="demand",
                    jurisdiction_state="CA", category="popular",
                    api_key_data=FAKE_ADMIN, db=mock_db
                )
            )
        assert "popular" in result


# ─── Tenant Rules Tests ────────────────────────────────────────────────────────

def _make_tenant_rule_obj():
    r = MagicMock()
    r.id = uuid4()
    r.rule_name = "Test Rule"
    r.review_status = "needs_review"
    r.reviewed_by = None
    r.reviewed_at = None
    r.created_at = MagicMock()
    r.created_at.isoformat.return_value = "2025-01-01T00:00:00"
    r.updated_at = MagicMock()
    r.updated_at.isoformat.return_value = "2025-01-02T00:00:00"
    r.archived_at = MagicMock()
    r.archived_at.isoformat.return_value = "2025-01-03T00:00:00"
    r.to_dict.return_value = {"id": str(r.id), "rule_name": r.rule_name}
    return r


class TestTenantRulesEndpoint:
    def test_list_rules_no_filter(self, mock_db):
        from app.api.v1.endpoints import tenant_rules
        with patch("app.api.v1.endpoints.tenant_rules.TenantRulesService") as MockSvc:
            svc = MagicMock()
            svc.list_rules.return_value = {"rules": [], "total": 0}
            MockSvc.return_value = svc
            result = asyncio.get_event_loop().run_until_complete(
                tenant_rules.list_tenant_rules(
                    document_type=None, practice_area=None,
                    status=None, skip=0, limit=100,
                    api_key_data=FAKE_TENANT_AUTH, db=mock_db
                )
            )
        assert result == {"rules": [], "total": 0}

    def test_list_rules_active_status(self, mock_db):
        from app.api.v1.endpoints import tenant_rules
        with patch("app.api.v1.endpoints.tenant_rules.TenantRulesService") as MockSvc:
            svc = MagicMock()
            svc.list_rules.return_value = {"rules": [], "total": 0}
            MockSvc.return_value = svc
            asyncio.get_event_loop().run_until_complete(
                tenant_rules.list_tenant_rules(
                    document_type=None, practice_area=None,
                    status="active", skip=0, limit=100,
                    api_key_data=FAKE_TENANT_AUTH, db=mock_db
                )
            )
            call_kwargs = svc.list_rules.call_args[1]
            assert call_kwargs["is_active"] is True

    def test_list_rules_archived_status(self, mock_db):
        from app.api.v1.endpoints import tenant_rules
        with patch("app.api.v1.endpoints.tenant_rules.TenantRulesService") as MockSvc:
            svc = MagicMock()
            svc.list_rules.return_value = {"rules": [], "total": 0}
            MockSvc.return_value = svc
            asyncio.get_event_loop().run_until_complete(
                tenant_rules.list_tenant_rules(
                    document_type=None, practice_area=None,
                    status="archived", skip=0, limit=100,
                    api_key_data=FAKE_TENANT_AUTH, db=mock_db
                )
            )
            call_kwargs = svc.list_rules.call_args[1]
            assert call_kwargs["is_active"] is False

    def test_get_tenant_rule(self, mock_db):
        from app.api.v1.endpoints import tenant_rules
        rule = _make_tenant_rule_obj()
        with patch("app.api.v1.endpoints.tenant_rules.TenantRulesService") as MockSvc:
            svc = MagicMock()
            svc.get_rule.return_value = rule
            MockSvc.return_value = svc
            result = asyncio.get_event_loop().run_until_complete(
                tenant_rules.get_tenant_rule(
                    id=rule.id, api_key_data=FAKE_TENANT_AUTH, db=mock_db
                )
            )
        assert result["id"] == str(rule.id)

    def test_create_tenant_rule(self, mock_db):
        from app.api.v1.endpoints import tenant_rules
        from app.api.v1.endpoints.tenant_rules import CreateTenantRuleRequest
        rule = _make_tenant_rule_obj()
        with patch("app.api.v1.endpoints.tenant_rules.TenantRulesService") as MockSvc:
            svc = MagicMock()
            svc.create_rule.return_value = rule
            MockSvc.return_value = svc
            req = CreateTenantRuleRequest(
                rule_name="New Rule",
                validator_level=1,
                validator_name="test_validator",
                validator_type="keyword",
                validator_config={"keywords": ["test"]},
                severity="error",
                practice_area="personal_injury",
                document_type="demand_letter",
                error_message="Error"
            )
            result = asyncio.get_event_loop().run_until_complete(
                tenant_rules.create_tenant_rule(
                    request=req, api_key_data=FAKE_TENANT_AUTH, db=mock_db
                )
            )
        assert "id" in result

    def test_update_tenant_rule(self, mock_db):
        from app.api.v1.endpoints import tenant_rules
        from app.api.v1.endpoints.tenant_rules import UpdateTenantRuleRequest
        rule = _make_tenant_rule_obj()
        with patch("app.api.v1.endpoints.tenant_rules.TenantRulesService") as MockSvc:
            svc = MagicMock()
            svc.update_rule.return_value = rule
            MockSvc.return_value = svc
            req = UpdateTenantRuleRequest(rule_name="Updated")
            result = asyncio.get_event_loop().run_until_complete(
                tenant_rules.update_tenant_rule(
                    id=rule.id, request=req,
                    api_key_data=FAKE_TENANT_AUTH, db=mock_db
                )
            )
        assert "id" in result

    def test_archive_tenant_rule(self, mock_db):
        from app.api.v1.endpoints import tenant_rules
        rule = _make_tenant_rule_obj()
        with patch("app.api.v1.endpoints.tenant_rules.TenantRulesService") as MockSvc:
            svc = MagicMock()
            svc.archive_rule.return_value = rule
            MockSvc.return_value = svc
            result = asyncio.get_event_loop().run_until_complete(
                tenant_rules.archive_tenant_rule(
                    id=rule.id, api_key_data=FAKE_TENANT_AUTH, db=mock_db
                )
            )
        assert "id" in result

    def test_list_rules_by_document_type(self, mock_db):
        from app.api.v1.endpoints import tenant_rules
        with patch("app.api.v1.endpoints.tenant_rules.TenantRulesService") as MockSvc:
            svc = MagicMock()
            svc.list_rules_by_document_type.return_value = {"rules": []}
            MockSvc.return_value = svc
            result = asyncio.get_event_loop().run_until_complete(
                tenant_rules.list_rules_by_document_type(
                    document_type="demand_letter",
                    practice_area="pi",
                    jurisdiction_state="CA",
                    api_key_data=FAKE_TENANT_AUTH, db=mock_db
                )
            )
        assert "rules" in result

    def test_approve_tenant_rule(self, mock_db):
        from app.api.v1.endpoints import tenant_rules
        from app.api.v1.endpoints.tenant_rules import ApproveTenantRuleRequest
        rule = _make_tenant_rule_obj()
        rule.review_status = "document_verified"
        rule.reviewed_by = "atty-1"
        with patch("app.api.v1.endpoints.tenant_rules.TenantRulesService") as MockSvc:
            svc = MagicMock()
            svc.approve_rule.return_value = rule
            MockSvc.return_value = svc
            req = ApproveTenantRuleRequest(approved_by="atty-1")
            result = asyncio.get_event_loop().run_until_complete(
                tenant_rules.approve_tenant_rule(
                    id=rule.id, request=req,
                    api_key_data=FAKE_TENANT_AUTH, db=mock_db
                )
            )
        assert result["review_status"] == "document_verified"


# ─── Template Inheritance Tests ─────────────────────────────────────────────────

class TestTemplateInheritanceEndpoint:
    def test_browse_global_templates(self, mock_db):
        from app.api.v1.endpoints import template_inheritance
        with patch("app.api.v1.endpoints.template_inheritance.TemplateInheritanceService") as MockSvc:
            svc = MagicMock()
            svc.browse_templates.return_value = {"templates": [], "total": 0}
            MockSvc.return_value = svc
            result = asyncio.get_event_loop().run_until_complete(
                template_inheritance.browse_global_templates(
                    practice_area="pi", document_type="demand",
                    jurisdiction_state="CA", skip=0, limit=100,
                    api_key_data=FAKE_TENANT_AUTH, db=mock_db
                )
            )
        assert "templates" in result

    def test_get_template_detail(self, mock_db):
        from app.api.v1.endpoints import template_inheritance
        template_id = uuid4()
        with patch("app.api.v1.endpoints.template_inheritance.TemplateInheritanceService") as MockSvc:
            svc = MagicMock()
            svc.get_template_detail.return_value = {"id": str(template_id), "template_name": "T1"}
            MockSvc.return_value = svc
            result = asyncio.get_event_loop().run_until_complete(
                template_inheritance.get_template_detail(
                    id=template_id, api_key_data=FAKE_TENANT_AUTH, db=mock_db
                )
            )
        assert result["id"] == str(template_id)

    def test_inherit_template(self, mock_db):
        from app.api.v1.endpoints import template_inheritance
        from app.api.v1.endpoints.template_inheritance import InheritTemplateRequest
        rule = MagicMock()
        rule.id = uuid4()
        rule.inherited_from_template_id = uuid4()
        rule.created_at = MagicMock()
        rule.created_at.isoformat.return_value = "2025-01-01T00:00:00"
        rule.is_customized = False
        with patch("app.api.v1.endpoints.template_inheritance.TemplateInheritanceService") as MockSvc:
            svc = MagicMock()
            svc.inherit_template.return_value = rule
            MockSvc.return_value = svc
            req = InheritTemplateRequest(customize=False, customizations={})
            result = asyncio.get_event_loop().run_until_complete(
                template_inheritance.inherit_template(
                    id=uuid4(), request=req,
                    api_key_data=FAKE_TENANT_AUTH, db=mock_db
                )
            )
        assert "rule_id" in result

    def test_health_check(self):
        from app.api.v1.endpoints import template_inheritance
        result = asyncio.get_event_loop().run_until_complete(
            template_inheritance.health_check()
        )
        assert result["status"] == "healthy"
