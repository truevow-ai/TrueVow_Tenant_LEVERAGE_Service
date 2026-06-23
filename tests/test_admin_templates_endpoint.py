"""
Tests for admin_templates.py endpoint - comprehensive coverage.
Uses app.dependency_overrides to mock auth and DB.
Overrides BOTH auth and auth_v2 require_admin_access since admin.router
(prefix /admin) shadows some routes.
"""

import pytest
from uuid import uuid4
from unittest.mock import MagicMock, patch, AsyncMock
from fastapi.testclient import TestClient
import asyncio

from app.core.database import get_db
import app.core.auth as core_auth
import app.core.auth_v2 as core_auth_v2
from app.api.v1.endpoints import admin_templates


FAKE_ADMIN = {"user_id": str(uuid4()), "access_level": "admin", "api_key_id": str(uuid4())}
BASE = "/api/v1/admin/templates"


@pytest.fixture
def mock_db():
    return MagicMock()


@pytest.fixture
def client(app, mock_db):
    app.dependency_overrides[get_db] = lambda: mock_db
    app.dependency_overrides[core_auth.require_admin_access] = lambda: FAKE_ADMIN
    app.dependency_overrides[core_auth_v2.require_admin_access] = lambda: FAKE_ADMIN
    yield TestClient(app)
    app.dependency_overrides.clear()


def _make_rule(name="tpl1", **kwargs):
    r = MagicMock()
    r.id = uuid4()
    r.template_name = name
    r.template_description = "desc"
    r.rule_name = name
    r.practice_area = "personal_injury"
    r.document_type = "demand_letter"
    r.jurisdiction_state = "CA"
    r.jurisdiction_county = None
    r.jurisdiction_court = None
    r.validator_level = 1
    r.validator_name = "validator"
    r.validator_type = "keyword"
    r.validator_config = {"keywords": ["test"]}
    r.severity = "error"
    r.error_message = None
    r.warning_message = None
    r.info_message = None
    r.is_active = True
    r.is_template = True
    r.inherited_from_template_id = None
    r.created_at = MagicMock()
    r.created_at.isoformat.return_value = "2025-01-01T00:00:00"
    r.updated_at = MagicMock()
    r.updated_at.isoformat.return_value = "2025-01-01T00:00:00"
    for k, v in kwargs.items():
        setattr(r, k, v)
    return r


# ─── Direct function tests (bypass routing conflicts) ─────────────────────────

class TestGetTemplateStatsFunction:
    """Test get_template_stats directly."""

    def test_returns_stats(self, mock_db):
        q = MagicMock()
        q.filter.return_value = q
        q.count.side_effect = [5, 3]  # total, active
        q.scalar.return_value = 2
        q.group_by.return_value = q
        q.order_by.return_value = q
        q.first.return_value = ("personal_injury", 3)
        mock_db.query.return_value = q

        result = asyncio.get_event_loop().run_until_complete(
            admin_templates.get_template_stats(db=mock_db, _=FAKE_ADMIN)
        )
        assert result["total_templates"] == 5
        assert result["active_templates"] == 3
        assert result["most_inherited"] == "personal_injury"

    def test_stats_no_most_inherited(self, mock_db):
        q = MagicMock()
        q.filter.return_value = q
        q.count.side_effect = [0, 0]
        q.scalar.return_value = 0
        q.group_by.return_value = q
        q.order_by.return_value = q
        q.first.return_value = None
        mock_db.query.return_value = q

        result = asyncio.get_event_loop().run_until_complete(
            admin_templates.get_template_stats(db=mock_db, _=FAKE_ADMIN)
        )
        assert result["most_inherited"] == "N/A"

    def test_stats_exception_returns_500(self, mock_db):
        mock_db.query.side_effect = Exception("db error")
        from fastapi import HTTPException
        with pytest.raises(HTTPException) as exc_info:
            asyncio.get_event_loop().run_until_complete(
                admin_templates.get_template_stats(db=mock_db, _=FAKE_ADMIN)
            )
        assert exc_info.value.status_code == 500


class TestListTemplatesFunction:
    """Test list_templates directly."""

    def test_empty_list(self, mock_db):
        q = MagicMock()
        q.filter.return_value = q
        q.order_by.return_value = q
        q.all.return_value = []
        mock_db.query.return_value = q

        result = asyncio.get_event_loop().run_until_complete(
            admin_templates.list_templates(
                practice_area=None, document_type=None, severity=None,
                is_active=None, db=mock_db, _=FAKE_ADMIN
            )
        )
        assert result["templates"] == []

    def test_returns_templates(self, mock_db):
        rule = _make_rule("tpl1")
        q = MagicMock()
        q.filter.return_value = q
        q.order_by.return_value = q
        q.all.return_value = [rule]
        q.count.return_value = 0
        mock_db.query.return_value = q

        result = asyncio.get_event_loop().run_until_complete(
            admin_templates.list_templates(
                practice_area=None, document_type=None, severity=None,
                is_active=None, db=mock_db, _=FAKE_ADMIN
            )
        )
        assert len(result["templates"]) == 1
        assert result["templates"][0]["template_name"] == "tpl1"
        assert "inheritance_count" in result["templates"][0]

    def test_filter_by_practice_area(self, mock_db):
        q = MagicMock()
        q.filter.return_value = q
        q.order_by.return_value = q
        q.all.return_value = []
        mock_db.query.return_value = q

        result = asyncio.get_event_loop().run_until_complete(
            admin_templates.list_templates(
                practice_area="personal_injury", document_type=None,
                severity=None, is_active=None, db=mock_db, _=FAKE_ADMIN
            )
        )
        assert result["templates"] == []

    def test_filter_by_document_type(self, mock_db):
        q = MagicMock()
        q.filter.return_value = q
        q.order_by.return_value = q
        q.all.return_value = []
        mock_db.query.return_value = q

        result = asyncio.get_event_loop().run_until_complete(
            admin_templates.list_templates(
                practice_area=None, document_type="demand_letter",
                severity=None, is_active=None, db=mock_db, _=FAKE_ADMIN
            )
        )
        assert result["templates"] == []

    def test_filter_by_severity(self, mock_db):
        q = MagicMock()
        q.filter.return_value = q
        q.order_by.return_value = q
        q.all.return_value = []
        mock_db.query.return_value = q

        result = asyncio.get_event_loop().run_until_complete(
            admin_templates.list_templates(
                practice_area=None, document_type=None,
                severity="error", is_active=None, db=mock_db, _=FAKE_ADMIN
            )
        )
        assert result["templates"] == []

    def test_filter_by_is_active(self, mock_db):
        q = MagicMock()
        q.filter.return_value = q
        q.order_by.return_value = q
        q.all.return_value = []
        mock_db.query.return_value = q

        result = asyncio.get_event_loop().run_until_complete(
            admin_templates.list_templates(
                practice_area=None, document_type=None,
                severity=None, is_active=True, db=mock_db, _=FAKE_ADMIN
            )
        )
        assert result["templates"] == []

    def test_exception_returns_500(self, mock_db):
        mock_db.query.side_effect = Exception("db error")
        from fastapi import HTTPException
        with pytest.raises(HTTPException) as exc_info:
            asyncio.get_event_loop().run_until_complete(
                admin_templates.list_templates(
                    practice_area=None, document_type=None,
                    severity=None, is_active=None, db=mock_db, _=FAKE_ADMIN
                )
            )
        assert exc_info.value.status_code == 500


class TestCreateTemplateFunction:
    """Test create_template directly."""

    def _payload(self):
        return {
            "template_name": "Test Template",
            "template_description": "Test desc",
            "rule_name": "test_rule",
            "practice_area": "personal_injury",
            "document_type": "demand_letter",
            "jurisdiction_state": "CA",
            "validator_level": 1,
            "validator_name": "test_validator",
            "validator_type": "keyword",
            "validator_config": {"keywords": ["test"]},
            "severity": "error",
        }

    def test_creates_template(self, mock_db):
        mock_db.add.return_value = None
        mock_db.commit.return_value = None
        mock_db.refresh.return_value = None

        result = asyncio.get_event_loop().run_until_complete(
            admin_templates.create_template(
                template_data=self._payload(),
                db=mock_db,
                admin=FAKE_ADMIN
            )
        )
        assert result is not None
        assert result["template_name"] == "Test Template"

    def test_missing_field_returns_400(self, mock_db):
        payload = self._payload()
        del payload["template_name"]
        from fastapi import HTTPException
        with pytest.raises(HTTPException) as exc_info:
            asyncio.get_event_loop().run_until_complete(
                admin_templates.create_template(
                    template_data=payload,
                    db=mock_db,
                    admin=FAKE_ADMIN
                )
            )
        assert exc_info.value.status_code == 400

    def test_missing_validator_config_returns_400(self, mock_db):
        payload = self._payload()
        del payload["validator_config"]
        from fastapi import HTTPException
        with pytest.raises(HTTPException) as exc_info:
            asyncio.get_event_loop().run_until_complete(
                admin_templates.create_template(
                    template_data=payload,
                    db=mock_db,
                    admin=FAKE_ADMIN
                )
            )
        assert exc_info.value.status_code == 400

    def test_db_exception_returns_500(self, mock_db):
        mock_db.add.side_effect = Exception("db error")
        from fastapi import HTTPException
        with pytest.raises(HTTPException) as exc_info:
            asyncio.get_event_loop().run_until_complete(
                admin_templates.create_template(
                    template_data=self._payload(),
                    db=mock_db,
                    admin=FAKE_ADMIN
                )
            )
        assert exc_info.value.status_code == 500


class TestUpdateTemplateFunction:
    """Test update_template directly."""

    def test_not_found_returns_404(self, mock_db):
        q = MagicMock()
        q.filter.return_value = q
        q.first.return_value = None
        mock_db.query.return_value = q
        from fastapi import HTTPException
        with pytest.raises(HTTPException) as exc_info:
            asyncio.get_event_loop().run_until_complete(
                admin_templates.update_template(
                    template_id=str(uuid4()),
                    template_data={"is_active": False},
                    db=mock_db,
                    admin=FAKE_ADMIN
                )
            )
        assert exc_info.value.status_code == 404

    def test_updates_template(self, mock_db):
        rule = _make_rule("tpl1")
        q = MagicMock()
        q.filter.return_value = q
        q.first.return_value = rule
        mock_db.query.return_value = q

        result = asyncio.get_event_loop().run_until_complete(
            admin_templates.update_template(
                template_id=str(rule.id),
                template_data={"severity": "warning", "is_active": False},
                db=mock_db,
                admin=FAKE_ADMIN
            )
        )
        assert result is not None

    def test_db_exception_returns_500(self, mock_db):
        mock_db.query.side_effect = Exception("db error")
        from fastapi import HTTPException
        with pytest.raises(HTTPException) as exc_info:
            asyncio.get_event_loop().run_until_complete(
                admin_templates.update_template(
                    template_id=str(uuid4()),
                    template_data={"is_active": False},
                    db=mock_db,
                    admin=FAKE_ADMIN
                )
            )
        assert exc_info.value.status_code == 500


class TestDeleteTemplateFunction:
    """Test delete_template directly."""

    def test_not_found_returns_404(self, mock_db):
        q = MagicMock()
        q.filter.return_value = q
        q.first.return_value = None
        mock_db.query.return_value = q
        from fastapi import HTTPException
        with pytest.raises(HTTPException) as exc_info:
            asyncio.get_event_loop().run_until_complete(
                admin_templates.delete_template(
                    template_id=str(uuid4()),
                    db=mock_db,
                    admin=FAKE_ADMIN
                )
            )
        assert exc_info.value.status_code == 404

    def test_deletes_template(self, mock_db):
        rule = _make_rule("tpl1")
        # First query: get template; second query: check inherited
        q1 = MagicMock()
        q1.filter.return_value = q1
        q1.first.return_value = rule
        q2 = MagicMock()
        q2.filter.return_value = q2
        q2.count.return_value = 0
        mock_db.query.side_effect = [q1, q2]

        result = asyncio.get_event_loop().run_until_complete(
            admin_templates.delete_template(
                template_id=str(rule.id),
                db=mock_db,
                admin=FAKE_ADMIN
            )
        )
        assert result["message"] == "Template deleted successfully"

    def test_db_exception_returns_500(self, mock_db):
        mock_db.query.side_effect = Exception("db error")
        from fastapi import HTTPException
        with pytest.raises(HTTPException) as exc_info:
            asyncio.get_event_loop().run_until_complete(
                admin_templates.delete_template(
                    template_id=str(uuid4()),
                    db=mock_db,
                    admin=FAKE_ADMIN
                )
            )
        assert exc_info.value.status_code == 500


class TestGetTemplateFunction:
    """Test get_template directly."""

    def test_not_found_returns_404(self, mock_db):
        q = MagicMock()
        q.filter.return_value = q
        q.first.return_value = None
        mock_db.query.return_value = q
        from fastapi import HTTPException
        with pytest.raises(HTTPException) as exc_info:
            asyncio.get_event_loop().run_until_complete(
                admin_templates.get_template(
                    template_id=str(uuid4()),
                    db=mock_db,
                    _=FAKE_ADMIN
                )
            )
        assert exc_info.value.status_code == 404

    def test_returns_template(self, mock_db):
        rule = _make_rule("tpl1")
        q1 = MagicMock()
        q1.filter.return_value = q1
        q1.first.return_value = rule
        q2 = MagicMock()
        q2.filter.return_value = q2
        q2.count.return_value = 2
        mock_db.query.side_effect = [q1, q2]

        result = asyncio.get_event_loop().run_until_complete(
            admin_templates.get_template(
                template_id=str(rule.id),
                db=mock_db,
                _=FAKE_ADMIN
            )
        )
        assert result["template_name"] == "tpl1"
        assert result["inheritance_count"] == 2

    def test_exception_returns_500(self, mock_db):
        mock_db.query.side_effect = Exception("db error")
        from fastapi import HTTPException
        with pytest.raises(HTTPException) as exc_info:
            asyncio.get_event_loop().run_until_complete(
                admin_templates.get_template(
                    template_id=str(uuid4()),
                    db=mock_db,
                    _=FAKE_ADMIN
                )
            )
        assert exc_info.value.status_code == 500
