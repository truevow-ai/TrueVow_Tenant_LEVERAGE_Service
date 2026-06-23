"""
Tests for app/services/template_manager.py
Mocks the SQLAlchemy Session so no real DB is needed.
"""

import pytest
from unittest.mock import MagicMock, patch, call
from uuid import uuid4
from datetime import datetime

from app.services.template_manager import TemplateManagerService


# ─── helpers ────────────────────────────────────────────────────────────────

def make_mock_template(**kwargs):
    t = MagicMock()
    t.id = kwargs.get("id", uuid4())
    t.template_name = kwargs.get("template_name", "Test Template")
    t.practice_area = kwargs.get("practice_area", "personal_injury")
    t.document_type = kwargs.get("document_type", "complaint")
    t.is_active = kwargs.get("is_active", True)
    t.archived_at = kwargs.get("archived_at", None)
    t.deleted_at = kwargs.get("deleted_at", None)
    t.is_public = kwargs.get("is_public", True)
    t.tenant_id = kwargs.get("tenant_id", None)
    t.version = kwargs.get("version", 1)
    t.usage_count = kwargs.get("usage_count", 0)
    t.to_dict = MagicMock(return_value={"id": str(t.id), "template_name": t.template_name})
    return t


@pytest.fixture
def mock_db():
    return MagicMock()


@pytest.fixture
def svc(mock_db):
    return TemplateManagerService(mock_db)


# ─── create_template ────────────────────────────────────────────────────────

class TestCreateTemplate:
    def test_creates_template_and_commits(self, svc, mock_db):
        mock_tmpl = make_mock_template()
        with patch("app.services.template_manager.Template", return_value=mock_tmpl):
            result = svc.create_template(
                template_name="Demand Letter",
                template_content="{{client_name}} v. {{defendant_name}}",
                practice_area="personal_injury",
                document_type="demand_letter",
                merge_fields=[{"name": "client_name"}, {"name": "defendant_name"}],
            )
        mock_db.add.assert_called_once_with(mock_tmpl)
        mock_db.commit.assert_called_once()
        mock_db.refresh.assert_called_once_with(mock_tmpl)
        assert result is mock_tmpl

    def test_passes_all_optional_fields(self, svc, mock_db):
        captured = {}

        def capture(**kwargs):
            captured.update(kwargs)
            return make_mock_template()

        with patch("app.services.template_manager.Template", side_effect=capture):
            tid = uuid4()
            creator = uuid4()
            svc.create_template(
                template_name="T",
                template_content="content",
                practice_area="family_law",
                document_type="petition",
                merge_fields=[],
                template_description="desc",
                specialization="divorce",
                jurisdiction_state="CA",
                jurisdiction_county="Los Angeles",
                template_format="docx",
                is_public=True,
                tenant_id=tid,
                created_by=creator,
                notes="some notes",
            )
        assert captured["template_description"] == "desc"
        assert captured["specialization"] == "divorce"
        assert captured["jurisdiction_state"] == "CA"
        assert captured["tenant_id"] == tid
        assert captured["created_by"] == creator

    def test_default_format_is_docx(self, svc, mock_db):
        captured = {}

        def capture(**kwargs):
            captured.update(kwargs)
            return make_mock_template()

        with patch("app.services.template_manager.Template", side_effect=capture):
            svc.create_template("T", "content", "pa", "dt", [])
        assert captured["template_format"] == "docx"

    def test_default_is_public_false(self, svc, mock_db):
        captured = {}

        def capture(**kwargs):
            captured.update(kwargs)
            return make_mock_template()

        with patch("app.services.template_manager.Template", side_effect=capture):
            svc.create_template("T", "content", "pa", "dt", [])
        assert captured["is_public"] is False


# ─── get_template_by_id ─────────────────────────────────────────────────────

class TestGetTemplateById:
    def _build_query_chain(self, mock_db, return_value):
        mock_query = MagicMock()
        mock_db.query.return_value = mock_query
        mock_query.filter.return_value = mock_query
        mock_query.first.return_value = return_value
        return mock_query

    def test_returns_template_when_found(self, svc, mock_db):
        tmpl = make_mock_template()
        self._build_query_chain(mock_db, tmpl)
        result = svc.get_template_by_id(tmpl.id)
        assert result is tmpl

    def test_returns_none_when_not_found(self, svc, mock_db):
        self._build_query_chain(mock_db, None)
        result = svc.get_template_by_id(uuid4())
        assert result is None

    def test_applies_tenant_filter_when_provided(self, svc, mock_db):
        tmpl = make_mock_template()
        self._build_query_chain(mock_db, tmpl)
        tid = uuid4()
        result = svc.get_template_by_id(tmpl.id, tenant_id=tid)
        # filter was called (at least once for base + once for tenant)
        assert mock_db.query.return_value.filter.call_count >= 2


# ─── list_templates ─────────────────────────────────────────────────────────

class TestListTemplates:
    def _build_list_chain(self, mock_db, templates, total=None):
        mock_query = MagicMock()
        mock_db.query.return_value = mock_query
        mock_query.filter.return_value = mock_query
        mock_query.order_by.return_value = mock_query
        mock_query.offset.return_value = mock_query
        mock_query.limit.return_value = mock_query
        mock_query.count.return_value = total if total is not None else len(templates)
        mock_query.all.return_value = templates
        return mock_query

    def test_returns_dict_with_templates(self, svc, mock_db):
        tmpls = [make_mock_template(), make_mock_template()]
        self._build_list_chain(mock_db, tmpls, total=2)
        result = svc.list_templates()
        assert "templates" in result
        assert result["total_count"] == 2
        assert result["skip"] == 0
        assert result["limit"] == 100

    def test_has_more_true_when_more_exist(self, svc, mock_db):
        tmpls = [make_mock_template()]
        self._build_list_chain(mock_db, tmpls, total=200)
        result = svc.list_templates(skip=0, limit=10)
        assert result["has_more"] is True

    def test_has_more_false_when_at_end(self, svc, mock_db):
        tmpls = [make_mock_template()]
        self._build_list_chain(mock_db, tmpls, total=1)
        result = svc.list_templates(skip=0, limit=100)
        assert result["has_more"] is False

    def test_filters_applied(self, svc, mock_db):
        tmpls = [make_mock_template()]
        self._build_list_chain(mock_db, tmpls, total=1)
        svc.list_templates(
            practice_area="personal_injury",
            document_type="complaint",
            jurisdiction_state="CA",
            is_public=True,
            tenant_id=uuid4(),
        )
        # filter was called multiple times for each filter
        assert mock_db.query.return_value.filter.call_count >= 3


# ─── update_template ─────────────────────────────────────────────────────────

class TestUpdateTemplate:
    def test_returns_none_when_template_not_found(self, svc, mock_db):
        with patch.object(svc, "get_template_by_id", return_value=None):
            result = svc.update_template(uuid4())
        assert result is None

    def test_updates_fields_and_increments_version(self, svc, mock_db):
        tmpl = make_mock_template()
        tmpl.version = 3
        with patch.object(svc, "get_template_by_id", return_value=tmpl):
            result = svc.update_template(
                tmpl.id,
                template_name="New Name",
            )
        assert tmpl.version == 4
        mock_db.commit.assert_called_once()
        mock_db.refresh.assert_called_once_with(tmpl)
        assert result is tmpl

    def test_none_values_not_applied(self, svc, mock_db):
        tmpl = make_mock_template()
        tmpl.template_name = "Original"
        with patch.object(svc, "get_template_by_id", return_value=tmpl):
            svc.update_template(tmpl.id, template_name=None)
        # None value not applied — setattr is only called if value is not None
        assert tmpl.template_name == "Original"


# ─── archive_template ───────────────────────────────────────────────────────

class TestArchiveTemplate:
    def test_returns_false_when_not_found(self, svc, mock_db):
        with patch.object(svc, "get_template_by_id", return_value=None):
            result = svc.archive_template(uuid4())
        assert result is False

    def test_archives_template_sets_inactive(self, svc, mock_db):
        tmpl = make_mock_template()
        tmpl.is_active = True
        tmpl.archived_at = None
        with patch.object(svc, "get_template_by_id", return_value=tmpl):
            result = svc.archive_template(tmpl.id)
        assert result is True
        assert tmpl.is_active is False
        assert tmpl.archived_at is not None
        mock_db.commit.assert_called_once()


# ─── increment_usage ────────────────────────────────────────────────────────

class TestIncrementUsage:
    def test_calls_increment_usage_on_template(self, svc, mock_db):
        tmpl = make_mock_template()
        mock_db.query.return_value.filter.return_value.first.return_value = tmpl
        svc.increment_usage(tmpl.id)
        tmpl.increment_usage.assert_called_once()
        mock_db.commit.assert_called_once()

    def test_no_op_when_template_not_found(self, svc, mock_db):
        mock_db.query.return_value.filter.return_value.first.return_value = None
        # Should not raise
        svc.increment_usage(uuid4())
        mock_db.commit.assert_not_called()


# ─── get_popular_templates ──────────────────────────────────────────────────

class TestGetPopularTemplates:
    def _build_popular_chain(self, mock_db, return_value):
        mock_query = MagicMock()
        mock_db.query.return_value = mock_query
        mock_query.filter.return_value = mock_query
        mock_query.order_by.return_value = mock_query
        mock_query.limit.return_value = mock_query
        mock_query.all.return_value = return_value
        return mock_query

    def test_returns_list_of_templates(self, svc, mock_db):
        tmpls = [make_mock_template(), make_mock_template()]
        self._build_popular_chain(mock_db, tmpls)
        result = svc.get_popular_templates()
        assert result == tmpls

    def test_applies_practice_area_filter(self, svc, mock_db):
        tmpls = [make_mock_template()]
        self._build_popular_chain(mock_db, tmpls)
        result = svc.get_popular_templates(practice_area="family_law")
        assert mock_db.query.return_value.filter.call_count >= 2

    def test_applies_tenant_id_filter(self, svc, mock_db):
        tmpls = [make_mock_template()]
        self._build_popular_chain(mock_db, tmpls)
        tid = uuid4()
        result = svc.get_popular_templates(tenant_id=tid)
        assert mock_db.query.return_value.filter.call_count >= 2

    def test_default_limit_is_10(self, svc, mock_db):
        self._build_popular_chain(mock_db, [])
        svc.get_popular_templates()
        mock_db.query.return_value.filter.return_value.order_by.return_value.limit.assert_called_once_with(10)
