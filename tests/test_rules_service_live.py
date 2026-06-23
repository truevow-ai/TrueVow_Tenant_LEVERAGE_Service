"""
Live-DB integration tests for rules_service_v2.
Uses real draft.validation_rules table (2971 rows).
All write tests create then delete their own rows.
"""

import pytest
from uuid import uuid4
from fastapi import HTTPException

from app.core.database import get_session_local
from app.services.rules_service_v2 import (
    GlobalRuleTemplatesService,
    TenantRulesService,
    TemplateInheritanceService,
    RuleSelectionService,
)


FAKE_TENANT = str(uuid4())


@pytest.fixture(scope="module")
def db():
    SessionLocal = get_session_local()
    session = SessionLocal()
    yield session
    session.close()


@pytest.fixture(scope="function")
def fresh_db():
    """Function-scoped session for tests that do writes (avoids poisoned session)."""
    SessionLocal = get_session_local()
    session = SessionLocal()
    yield session
    try:
        session.rollback()
    except Exception:
        pass
    session.close()


@pytest.fixture(scope="module")
def global_svc(db):
    return GlobalRuleTemplatesService(db)


@pytest.fixture(scope="module")
def tenant_svc(db):
    return TenantRulesService(db, FAKE_TENANT)


@pytest.fixture(scope="module")
def inheritance_svc(db):
    return TemplateInheritanceService(db, FAKE_TENANT)


@pytest.fixture(scope="module")
def selection_svc(db):
    return RuleSelectionService(db, FAKE_TENANT)


# ─── Global Templates ────────────────────────────────────────────────────────

class TestGlobalRuleTemplatesServiceLive:

    def test_list_templates_returns_dict(self, global_svc):
        result = global_svc.list_templates()
        assert isinstance(result, dict)
        assert "templates" in result
        assert "total" in result
        assert "skip" in result
        assert "limit" in result

    def test_list_templates_is_active_filter(self, global_svc):
        result = global_svc.list_templates(is_active=True)
        assert result["total"] >= 0

    def test_list_templates_practice_area_filter(self, global_svc):
        result = global_svc.list_templates(practice_area="personal_injury")
        assert isinstance(result["templates"], list)

    def test_list_templates_jurisdiction_filter(self, global_svc):
        result = global_svc.list_templates(jurisdiction_state="CA")
        assert isinstance(result["templates"], list)

    def test_list_templates_pagination(self, global_svc):
        result = global_svc.list_templates(skip=0, limit=5)
        assert len(result["templates"]) <= 5

    def test_list_templates_validator_level_filter(self, global_svc):
        result = global_svc.list_templates(validator_level=1)
        assert isinstance(result["templates"], list)

    def test_get_template_not_found(self, global_svc):
        with pytest.raises(HTTPException) as exc_info:
            global_svc.get_template(uuid4())
        assert exc_info.value.status_code == 404

    def test_create_update_archive_template(self, global_svc, db):
        """Full lifecycle: create → update → approve → archive → cleanup."""
        # Create
        data = {
            "template_name": f"test-tpl-{uuid4().hex[:8]}",
            "template_description": "Integration test template",
            "validator_level": 1,
            "validator_name": "test_validator",
            "validator_type": "keyword",
            "practice_area": "personal_injury",
            "document_type": "demand_letter",
            "jurisdiction_state": "CA",
            "validator_config": {"keywords": ["negligence"]},
            "error_message": "Missing keyword",
            "severity": "error",
        }
        tpl = global_svc.create_template(data)
        assert tpl is not None
        assert tpl.review_status == "needs_review"

        # Update name only
        updated = global_svc.update_template(tpl.id, {"template_name": tpl.template_name + "-upd"})
        assert "-upd" in updated.template_name

        # Update validator_config resets review_status
        updated2 = global_svc.update_template(tpl.id, {"validator_config": {"keywords": ["damage"]}})
        assert updated2.review_status == "needs_review"

        # Approve
        approved = global_svc.approve_template(tpl.id, approved_by="test-user")
        assert approved.review_status == "document_verified"

        # Archive
        archived = global_svc.archive_template(tpl.id)
        assert archived.is_active is False

        # Cleanup
        db.delete(tpl)
        db.commit()

    def test_approve_flagged_error_template_raises(self, global_svc, db):
        """approve_template raises 422 if review_status=flagged_error."""
        data = {
            "template_name": f"flagged-{uuid4().hex[:8]}",
            "validator_level": 1,
            "validator_name": "flag_test",
            "validator_type": "keyword",
            "validator_config": {},
        }
        tpl = global_svc.create_template(data)
        # Manually set flagged_error
        tpl.review_status = "flagged_error"
        db.commit()

        with pytest.raises(HTTPException) as exc_info:
            global_svc.approve_template(tpl.id)
        assert exc_info.value.status_code == 422

        db.delete(tpl)
        db.commit()

    def test_get_template_library_no_filter(self, global_svc):
        result = global_svc.get_template_library()
        assert "categories" in result
        assert "total_templates" in result

    def test_get_template_library_popular_only(self, global_svc):
        result = global_svc.get_template_library(category="popular")
        assert "popular" in result["categories"]

    def test_get_template_library_recent_only(self, global_svc):
        result = global_svc.get_template_library(category="recent")
        assert "recent" in result["categories"]

    def test_get_template_library_recommended_only(self, global_svc):
        result = global_svc.get_template_library(category="recommended")
        assert "recommended" in result["categories"]

    def test_get_template_library_practice_area_filter(self, global_svc):
        result = global_svc.get_template_library(practice_area="personal_injury")
        assert isinstance(result["total_templates"], int)


# ─── Tenant Rules ─────────────────────────────────────────────────────────────

class TestTenantRulesServiceLive:

    def test_list_rules_empty_tenant(self, tenant_svc):
        result = tenant_svc.list_rules()
        assert isinstance(result, dict)
        assert result["total"] == 0

    def test_list_rules_with_document_type_filter(self, tenant_svc):
        result = tenant_svc.list_rules(document_type="demand_letter")
        assert isinstance(result["rules"], list)

    def test_list_rules_with_practice_area_filter(self, tenant_svc):
        result = tenant_svc.list_rules(practice_area="personal_injury")
        assert isinstance(result["rules"], list)

    def test_get_rule_not_found(self, tenant_svc):
        with pytest.raises(HTTPException) as exc_info:
            tenant_svc.get_rule(uuid4())
        assert exc_info.value.status_code == 404

    def test_create_update_archive_rule(self, tenant_svc, db):
        """Full lifecycle: create → update → approve → archive → cleanup."""
        rule_data = {
            "rule_name": f"test-rule-{uuid4().hex[:8]}",
            "validator_level": 1,
            "validator_name": "test_rule_validator",
            "validator_type": "keyword",
            "practice_area": "personal_injury",
            "document_type": "demand_letter",
            "validator_config": {"keywords": ["injury"]},
            "error_message": "Missing injury keyword",
            "severity": "error",
        }
        rule = tenant_svc.create_rule(rule_data)
        assert rule is not None
        assert rule.tenant_id == FAKE_TENANT
        assert rule.review_status == "needs_review"

        # Update rule_name
        updated = tenant_svc.update_rule(rule.id, {"rule_name": "updated-rule"})
        assert updated.rule_name == "updated-rule"

        # Update validator_config resets review_status
        updated2 = tenant_svc.update_rule(rule.id, {"validator_config": {"keywords": ["harm"]}})
        assert updated2.review_status == "needs_review"

        # Approve
        approved = tenant_svc.approve_rule(rule.id, approved_by="atty-user")
        assert approved.review_status == "document_verified"

        # Archive
        archived = tenant_svc.archive_rule(rule.id)
        assert archived.is_active is False

        # Cleanup
        db.delete(rule)
        db.commit()

    def test_approve_flagged_rule_raises(self, tenant_svc, db):
        """approve_rule raises 422 for flagged_error rules."""
        rule_data = {
            "rule_name": f"flag-rule-{uuid4().hex[:8]}",
            "validator_level": 1,
            "validator_name": "flagged_test",
            "validator_type": "keyword",
            "validator_config": {},
        }
        rule = tenant_svc.create_rule(rule_data)
        rule.review_status = "flagged_error"
        db.commit()

        with pytest.raises(HTTPException) as exc_info:
            tenant_svc.approve_rule(rule.id)
        assert exc_info.value.status_code == 422

        db.delete(rule)
        db.commit()

    def test_update_rule_sets_customized_flag(self, tenant_svc, db, global_svc):
        """update_rule sets is_customized=True when inherited_from_template_id is set."""
        # First create a template to inherit from
        tpl_data = {
            "template_name": f"inh-tpl-{uuid4().hex[:8]}",
            "validator_level": 1,
            "validator_name": "inh_validator",
            "validator_type": "keyword",
            "validator_config": {"keywords": ["test"]},
        }
        tpl = global_svc.create_template(tpl_data)

        # Create tenant rule with inherited_from_template_id set
        rule_data = {
            "rule_name": f"inherited-{uuid4().hex[:8]}",
            "validator_level": 1,
            "validator_name": "inh_validator",
            "validator_type": "keyword",
            "validator_config": {"keywords": ["test"]},
        }
        rule = tenant_svc.create_rule(rule_data)
        rule.inherited_from_template_id = tpl.id
        db.commit()

        # Now update validator_config — should set is_customized=True
        updated = tenant_svc.update_rule(rule.id, {"validator_config": {"keywords": ["modified"]}})
        assert updated.is_customized is True

        db.delete(rule)
        db.delete(tpl)
        db.commit()

    def test_list_rules_by_document_type(self, tenant_svc, db):
        """list_rules_by_document_type returns dict with document_type key."""
        rule_data = {
            "rule_name": f"doctype-rule-{uuid4().hex[:8]}",
            "validator_level": 1,
            "validator_name": "doctype_validator",
            "validator_type": "keyword",
            "document_type": "demand_letter",
            "practice_area": "personal_injury",
            "jurisdiction_state": "CA",
            "validator_config": {},
        }
        rule = tenant_svc.create_rule(rule_data)
        rule.is_active = True
        db.commit()

        result = tenant_svc.list_rules_by_document_type(
            "demand_letter",
            practice_area="personal_injury",
            jurisdiction_state="CA",
        )
        assert result["document_type"] == "demand_letter"
        assert isinstance(result["rules"], list)
        assert result["total"] >= 1

        db.delete(rule)
        db.commit()


# ─── Template Inheritance ─────────────────────────────────────────────────────

class TestTemplateInheritanceServiceLive:

    def test_browse_templates_returns_dict(self, inheritance_svc):
        result = inheritance_svc.browse_templates()
        assert "templates" in result
        assert "total" in result

    def test_browse_templates_with_filters(self, inheritance_svc):
        result = inheritance_svc.browse_templates(
            practice_area="personal_injury",
            document_type="demand_letter",
        )
        assert isinstance(result["templates"], list)

    def test_get_template_detail_not_found(self, inheritance_svc):
        with pytest.raises(HTTPException) as exc_info:
            inheritance_svc.get_template_detail(uuid4())
        assert exc_info.value.status_code == 404

    def test_inherit_template_not_found(self, inheritance_svc):
        with pytest.raises(HTTPException) as exc_info:
            inheritance_svc.inherit_template(uuid4())
        assert exc_info.value.status_code == 404

    def test_inherit_template_and_conflict(self, fresh_db):
        """inherit_template creates rule; second inherit raises 409."""
        from app.models import ValidationRule as VR
        g_svc = GlobalRuleTemplatesService(fresh_db)
        inh_svc = TemplateInheritanceService(fresh_db, FAKE_TENANT)

        unique_suffix = uuid4().hex[:8]
        tpl_name = f"inh2-tpl-{unique_suffix}"
        # inherited rule_name will be tpl_name (same as template_name)
        # Since unique_rule_name is global, the inherited copy will conflict with template.
        # To avoid this, we use a unique customized rule_name for the inherited copy.
        tpl_data = {
            "template_name": tpl_name,
            "validator_level": 1,
            "validator_name": "inh2",
            "validator_type": "keyword",
            "validator_config": {"keywords": ["test"]},
        }

        # Pre-cleanup: remove any leftover rows from previous failed runs
        try:
            stale = fresh_db.query(VR).filter(
                VR.rule_name.like("inh2-tpl-%")
            ).all()
            for s in stale:
                fresh_db.delete(s)
            fresh_db.commit()
        except Exception:
            fresh_db.rollback()

        tpl = g_svc.create_template(tpl_data)
        # Make template active (needed for inheritance browse)
        tpl.is_active = True
        fresh_db.commit()

        # First inherit — customize to give a unique rule_name to avoid
        # conflict with the template's own rule_name on the global unique constraint
        rule = inh_svc.inherit_template(
            tpl.id,
            customize=True,
            customizations={"rule_name": f"{tpl_name}-tenant"},
        )
        assert rule is not None
        assert rule.tenant_id == FAKE_TENANT
        assert rule.inherited_from_template_id == tpl.id

        # Second inherit should conflict
        with pytest.raises(HTTPException) as exc_info:
            inh_svc.inherit_template(tpl.id)
        assert exc_info.value.status_code == 409

        # Cleanup
        try:
            fresh_db.rollback()  # clear any dirty state from the 409 path
            fresh_db.delete(fresh_db.merge(rule))
            fresh_db.delete(fresh_db.merge(tpl))
            fresh_db.commit()
        except Exception:
            fresh_db.rollback()

    def test_get_template_detail_shows_inheritance_status(self, fresh_db):
        """get_template_detail includes is_inherited key."""
        g_svc = GlobalRuleTemplatesService(fresh_db)
        inh_svc = TemplateInheritanceService(fresh_db, FAKE_TENANT)

        tpl_data = {
            "template_name": f"detail-tpl-{uuid4().hex[:8]}",
            "validator_level": 1,
            "validator_name": "detail_v",
            "validator_type": "keyword",
            "validator_config": {},
        }
        tpl = g_svc.create_template(tpl_data)
        fresh_db.commit()

        detail = inh_svc.get_template_detail(tpl.id)
        assert "is_inherited" in detail
        assert detail["is_inherited"] is False  # Not inherited yet

        try:
            fresh_db.delete(tpl)
            fresh_db.commit()
        except Exception:
            fresh_db.rollback()


# ─── Rule Selection ────────────────────────────────────────────────────────────

class TestRuleSelectionServiceLive:

    def test_select_rules_for_validation_empty_tenant(self, fresh_db):
        sel_svc = RuleSelectionService(fresh_db, FAKE_TENANT)
        result = sel_svc.select_rules_for_validation(
            document_type="demand_letter",
            practice_area="personal_injury",
            jurisdiction_state="CA",
        )
        assert "available_rules" in result
        assert "recommended_rules" in result
        assert isinstance(result["available_rules"], list)

    def test_select_rules_no_filters(self, fresh_db):
        sel_svc = RuleSelectionService(fresh_db, FAKE_TENANT)
        result = sel_svc.select_rules_for_validation(
            document_type="demand_letter",
        )
        assert isinstance(result["available_rules"], list)

    def test_get_enabled_rules_for_validation_empty(self, fresh_db):
        sel_svc = RuleSelectionService(fresh_db, FAKE_TENANT)
        rules = sel_svc.get_enabled_rules_for_validation(
            document_type="demand_letter",
            practice_area="personal_injury",
            jurisdiction_state="CA",
        )
        assert isinstance(rules, list)

    def test_get_enabled_rules_no_filters(self, fresh_db):
        sel_svc = RuleSelectionService(fresh_db, FAKE_TENANT)
        rules = sel_svc.get_enabled_rules_for_validation(
            document_type="demand_letter",
        )
        assert isinstance(rules, list)

    def test_select_rules_recommended_level_1(self, fresh_db):
        """Level-1 rules appear in recommended_rules."""
        t_svc = TenantRulesService(fresh_db, FAKE_TENANT)
        sel_svc = RuleSelectionService(fresh_db, FAKE_TENANT)

        rule_data = {
            "rule_name": f"lvl1-{uuid4().hex[:8]}",
            "validator_level": 1,
            "validator_name": "lvl1_v",
            "validator_type": "keyword",
            "document_type": "demand_letter",
            "validator_config": {},
        }
        rule = t_svc.create_rule(rule_data)
        rule.is_active = True
        fresh_db.commit()

        result = sel_svc.select_rules_for_validation(
            document_type="demand_letter",
        )
        rule_ids = [r["id"] for r in result["recommended_rules"]]
        assert str(rule.id) in rule_ids

        try:
            fresh_db.delete(rule)
            fresh_db.commit()
        except Exception:
            fresh_db.rollback()
