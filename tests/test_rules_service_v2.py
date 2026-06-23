"""
Tests for GlobalRuleTemplatesService and TenantRulesService
(app/services/rules_service_v2.py)
All DB interactions are mocked — no real database needed.
"""

import pytest
from unittest.mock import MagicMock, patch, call
from uuid import uuid4
from fastapi import HTTPException

from app.services.rules_service_v2 import GlobalRuleTemplatesService, TenantRulesService


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def make_mock_rule(**kwargs):
    """Return a MagicMock that looks like a ValidationRule."""
    rule = MagicMock()
    rule.id = kwargs.get("id", uuid4())
    rule.is_template = kwargs.get("is_template", True)
    rule.tenant_id = kwargs.get("tenant_id", None)
    rule.review_status = kwargs.get("review_status", "needs_review")
    rule.version = kwargs.get("version", 1)
    rule.to_dict.return_value = {
        "id": str(rule.id),
        "is_template": rule.is_template,
        "review_status": rule.review_status,
    }
    return rule


@pytest.fixture
def mock_db():
    return MagicMock()


@pytest.fixture
def global_svc(mock_db):
    return GlobalRuleTemplatesService(db=mock_db)


@pytest.fixture
def tenant_svc(mock_db):
    return TenantRulesService(db=mock_db, tenant_id=uuid4())


# ===========================================================================
# GlobalRuleTemplatesService
# ===========================================================================

class TestGlobalListTemplates:

    def test_returns_dict_with_expected_keys(self, global_svc, mock_db):
        mock_query = MagicMock()
        mock_db.query.return_value = mock_query
        mock_query.filter.return_value = mock_query
        mock_query.count.return_value = 0
        mock_query.order_by.return_value = mock_query
        mock_query.offset.return_value = mock_query
        mock_query.limit.return_value = mock_query
        mock_query.all.return_value = []

        result = global_svc.list_templates()
        assert "templates" in result
        assert "total" in result
        assert "skip" in result
        assert "limit" in result

    def test_calls_to_dict_for_each_template(self, global_svc, mock_db):
        rule = make_mock_rule()
        mock_query = MagicMock()
        mock_db.query.return_value = mock_query
        mock_query.filter.return_value = mock_query
        mock_query.count.return_value = 1
        mock_query.order_by.return_value = mock_query
        mock_query.offset.return_value = mock_query
        mock_query.limit.return_value = mock_query
        mock_query.all.return_value = [rule]

        result = global_svc.list_templates()
        assert len(result["templates"]) == 1
        rule.to_dict.assert_called_once()

    def test_pagination_values_passed_through(self, global_svc, mock_db):
        mock_query = MagicMock()
        mock_db.query.return_value = mock_query
        mock_query.filter.return_value = mock_query
        mock_query.count.return_value = 50
        mock_query.order_by.return_value = mock_query
        mock_query.offset.return_value = mock_query
        mock_query.limit.return_value = mock_query
        mock_query.all.return_value = []

        result = global_svc.list_templates(skip=10, limit=20)
        assert result["skip"] == 10
        assert result["limit"] == 20
        assert result["total"] == 50

    def test_filters_applied_without_error(self, global_svc, mock_db):
        mock_query = MagicMock()
        mock_db.query.return_value = mock_query
        mock_query.filter.return_value = mock_query
        mock_query.count.return_value = 0
        mock_query.order_by.return_value = mock_query
        mock_query.offset.return_value = mock_query
        mock_query.limit.return_value = mock_query
        mock_query.all.return_value = []

        result = global_svc.list_templates(
            validator_level=1,
            practice_area="personal_injury",
            specialization="slip_fall",
            document_type="demand_letter",
            jurisdiction_state="AZ",
            is_active=True,
        )
        assert isinstance(result, dict)


class TestGlobalGetTemplate:

    def test_raises_404_when_not_found(self, global_svc, mock_db):
        mock_query = MagicMock()
        mock_db.query.return_value = mock_query
        mock_query.filter.return_value = mock_query
        mock_query.first.return_value = None

        with pytest.raises(HTTPException) as exc_info:
            global_svc.get_template(uuid4())
        assert exc_info.value.status_code == 404

    def test_returns_template_when_found(self, global_svc, mock_db):
        rule = make_mock_rule()
        mock_query = MagicMock()
        mock_db.query.return_value = mock_query
        mock_query.filter.return_value = mock_query
        mock_query.first.return_value = rule

        result = global_svc.get_template(rule.id)
        assert result is rule


class TestGlobalCreateTemplate:

    def test_creates_and_commits(self, global_svc, mock_db):
        mock_rule = make_mock_rule()
        with patch("app.services.rules_service_v2.ValidationRule", return_value=mock_rule):
            result = global_svc.create_template(
                template_data={
                    "template_name": "Test Template",
                    "validator_level": 1,
                    "validator_name": "date_check",
                    "validator_type": "format",
                    "practice_area": "personal_injury",
                    "document_type": "demand_letter",
                    "severity": "error",
                }
            )

        mock_db.add.assert_called_once_with(mock_rule)
        mock_db.commit.assert_called_once()
        mock_db.refresh.assert_called_once_with(mock_rule)
        assert result is mock_rule

    def test_review_status_is_needs_review(self, global_svc, mock_db):
        """Protocol v3: all new templates must be needs_review."""
        captured = {}

        def capture_rule(**kwargs):
            captured.update(kwargs)
            return make_mock_rule()

        with patch("app.services.rules_service_v2.ValidationRule", side_effect=capture_rule):
            global_svc.create_template(template_data={"template_name": "T"})

        assert captured.get("review_status") == "needs_review"


class TestGlobalUpdateTemplate:

    def test_updates_template_name(self, global_svc, mock_db):
        rule = make_mock_rule()
        rule.version = 1
        with patch.object(global_svc, "get_template", return_value=rule):
            result = global_svc.update_template(
                rule.id,
                {"template_name": "New Name"}
            )
        assert rule.template_name == "New Name"
        assert rule.rule_name == "New Name"
        assert rule.version == 2
        mock_db.commit.assert_called_once()

    def test_validator_config_change_resets_review_status(self, global_svc, mock_db):
        rule = make_mock_rule()
        rule.review_status = "document_verified"
        rule.version = 3
        with patch.object(global_svc, "get_template", return_value=rule):
            global_svc.update_template(
                rule.id,
                {"validator_config": {"new": "config"}}
            )
        assert rule.review_status == "needs_review"

    def test_update_severity(self, global_svc, mock_db):
        rule = make_mock_rule()
        rule.version = 1
        with patch.object(global_svc, "get_template", return_value=rule):
            global_svc.update_template(rule.id, {"severity": "warning"})
        assert rule.severity == "warning"

    def test_version_increments(self, global_svc, mock_db):
        rule = make_mock_rule()
        rule.version = 5
        with patch.object(global_svc, "get_template", return_value=rule):
            global_svc.update_template(rule.id, {"is_active": False})
        assert rule.version == 6


class TestGlobalArchiveTemplate:

    def test_sets_is_active_false(self, global_svc, mock_db):
        rule = make_mock_rule()
        rule.is_active = True
        with patch.object(global_svc, "get_template", return_value=rule):
            global_svc.archive_template(rule.id)
        assert rule.is_active is False

    def test_sets_archived_at(self, global_svc, mock_db):
        rule = make_mock_rule()
        rule.archived_at = None
        with patch.object(global_svc, "get_template", return_value=rule):
            global_svc.archive_template(rule.id)
        assert rule.archived_at is not None


class TestGlobalApproveTemplate:

    def test_sets_review_status_to_document_verified(self, global_svc, mock_db):
        rule = make_mock_rule()
        rule.review_status = "needs_review"
        with patch.object(global_svc, "get_template", return_value=rule):
            global_svc.approve_template(rule.id, approved_by="atty_123")
        assert rule.review_status == "document_verified"
        assert rule.reviewed_by == "atty_123"

    def test_raises_422_when_flagged_error(self, global_svc, mock_db):
        rule = make_mock_rule()
        rule.review_status = "flagged_error"
        with patch.object(global_svc, "get_template", return_value=rule):
            with pytest.raises(HTTPException) as exc_info:
                global_svc.approve_template(rule.id)
        assert exc_info.value.status_code == 422

    def test_approve_sets_updated_by(self, global_svc, mock_db):
        rule = make_mock_rule()
        rule.review_status = "needs_review"
        with patch.object(global_svc, "get_template", return_value=rule):
            global_svc.approve_template(rule.id, approved_by="org_abc")
        assert rule.updated_by == "org_abc"


class TestGlobalGetTemplateLibrary:

    def _setup_library_query(self, mock_db, templates=None):
        mock_query = MagicMock()
        mock_db.query.return_value = mock_query
        mock_query.filter.return_value = mock_query
        mock_query.order_by.return_value = mock_query
        mock_query.limit.return_value = mock_query
        mock_query.all.return_value = templates or []
        mock_query.count.return_value = len(templates or [])
        return mock_query

    def test_returns_expected_keys(self, global_svc, mock_db):
        self._setup_library_query(mock_db)
        result = global_svc.get_template_library()
        assert "categories" in result
        assert "total_templates" in result

    def test_all_categories_present_by_default(self, global_svc, mock_db):
        self._setup_library_query(mock_db)
        result = global_svc.get_template_library()
        assert "popular" in result["categories"]
        assert "recent" in result["categories"]
        assert "recommended" in result["categories"]

    def test_only_requested_category_returned(self, global_svc, mock_db):
        self._setup_library_query(mock_db)
        result = global_svc.get_template_library(category="popular")
        assert "popular" in result["categories"]
        assert "recent" not in result["categories"]

    def test_with_filters(self, global_svc, mock_db):
        self._setup_library_query(mock_db)
        result = global_svc.get_template_library(
            practice_area="personal_injury",
            document_type="demand_letter",
            jurisdiction_state="CA",
        )
        assert isinstance(result, dict)


# ===========================================================================
# TenantRulesService
# ===========================================================================

class TestTenantListRules:

    def test_returns_dict_with_expected_keys(self, tenant_svc, mock_db):
        mock_query = MagicMock()
        mock_db.query.return_value = mock_query
        mock_query.filter.return_value = mock_query
        mock_query.count.return_value = 0
        mock_query.order_by.return_value = mock_query
        mock_query.offset.return_value = mock_query
        mock_query.limit.return_value = mock_query
        mock_query.all.return_value = []

        result = tenant_svc.list_rules()
        assert "rules" in result
        assert "total" in result
        assert "skip" in result
        assert "limit" in result

    def test_with_filters(self, tenant_svc, mock_db):
        mock_query = MagicMock()
        mock_db.query.return_value = mock_query
        mock_query.filter.return_value = mock_query
        mock_query.count.return_value = 0
        mock_query.order_by.return_value = mock_query
        mock_query.offset.return_value = mock_query
        mock_query.limit.return_value = mock_query
        mock_query.all.return_value = []

        result = tenant_svc.list_rules(
            document_type="demand_letter",
            practice_area="personal_injury",
            is_active=True,
        )
        assert isinstance(result, dict)

    def test_calls_to_dict_on_each_rule(self, tenant_svc, mock_db):
        rule = make_mock_rule(is_template=False)
        mock_query = MagicMock()
        mock_db.query.return_value = mock_query
        mock_query.filter.return_value = mock_query
        mock_query.count.return_value = 1
        mock_query.order_by.return_value = mock_query
        mock_query.offset.return_value = mock_query
        mock_query.limit.return_value = mock_query
        mock_query.all.return_value = [rule]

        result = tenant_svc.list_rules()
        assert len(result["rules"]) == 1
        rule.to_dict.assert_called_once()


class TestTenantGetRule:

    def test_raises_404_when_not_found(self, tenant_svc, mock_db):
        mock_query = MagicMock()
        mock_db.query.return_value = mock_query
        mock_query.filter.return_value = mock_query
        mock_query.first.return_value = None

        with pytest.raises(HTTPException) as exc_info:
            tenant_svc.get_rule(uuid4())
        assert exc_info.value.status_code == 404

    def test_returns_rule_when_found(self, tenant_svc, mock_db):
        rule = make_mock_rule(is_template=False)
        mock_query = MagicMock()
        mock_db.query.return_value = mock_query
        mock_query.filter.return_value = mock_query
        mock_query.first.return_value = rule

        result = tenant_svc.get_rule(rule.id)
        assert result is rule
