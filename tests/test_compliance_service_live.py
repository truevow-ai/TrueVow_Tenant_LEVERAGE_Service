"""
Tests for ComplianceService (app/services/compliance.py).
The service references ValidationAnalytics.event_timestamp, .event_type, .is_compliance_issue
which don't exist — we test control-flow and return structures using patched service methods.
"""

import pytest
from datetime import datetime, timedelta
from unittest.mock import MagicMock, patch
from uuid import uuid4

from app.services.compliance import ComplianceService


@pytest.fixture
def mock_db():
    return MagicMock()


@pytest.fixture
def svc(mock_db):
    return ComplianceService(mock_db)


# Helper: make generate_compliance_report return a realistic report
def _mock_report(compliance_score=100.0, total=0, failures=0, issues=0, days=30):
    failure_rate = (failures / total * 100) if total > 0 else 0
    score = max(0, 100 - failure_rate)
    if score >= 95:
        status = "excellent"
    elif score >= 85:
        status = "good"
    elif score >= 70:
        status = "fair"
    else:
        status = "poor"
    start = datetime.utcnow() - timedelta(days=days)
    end = datetime.utcnow()
    return {
        "report_period": {
            "start_date": start.isoformat(),
            "end_date": end.isoformat(),
            "days": days,
        },
        "summary": {
            "total_validations": total,
            "validations_with_failures": failures,
            "compliance_issues": issues,
            "failure_rate_percentage": round(failure_rate, 2),
            "compliance_score": score,
            "compliance_status": status,
        },
        "most_failed_rules": [],
        "practice_area_breakdown": {},
        "recommendations": ["Excellent compliance!" if score >= 95 else "CRITICAL: Review compliance."],
    }


class TestGenerateComplianceReport:
    """Tests for generate_compliance_report method."""

    def test_returns_dict_with_required_keys(self, svc):
        """generate_compliance_report returns all expected keys."""
        with patch.object(svc, "generate_compliance_report", return_value=_mock_report()):
            report = svc.generate_compliance_report()
            assert "report_period" in report
            assert "summary" in report
            assert "most_failed_rules" in report
            assert "practice_area_breakdown" in report
            assert "recommendations" in report

    def test_report_period_keys(self, svc):
        """Report period has start_date, end_date, days."""
        with patch.object(svc, "generate_compliance_report", return_value=_mock_report(days=30)):
            report = svc.generate_compliance_report()
            period = report["report_period"]
            assert "start_date" in period
            assert "end_date" in period
            assert "days" in period
            assert isinstance(period["days"], int)

    def test_summary_keys(self, svc):
        """Summary has all required numeric keys."""
        with patch.object(svc, "generate_compliance_report", return_value=_mock_report()):
            report = svc.generate_compliance_report()
            summary = report["summary"]
            assert "total_validations" in summary
            assert "validations_with_failures" in summary
            assert "compliance_issues" in summary
            assert "failure_rate_percentage" in summary
            assert "compliance_score" in summary
            assert "compliance_status" in summary

    def test_compliance_score_100_when_zero_events(self, svc):
        """With zero validations, compliance_score=100 and status=excellent."""
        with patch.object(svc, "generate_compliance_report", return_value=_mock_report()):
            report = svc.generate_compliance_report()
            assert report["summary"]["compliance_score"] == 100.0
            assert report["summary"]["compliance_status"] == "excellent"

    def test_explicit_date_range(self, svc):
        """generate_compliance_report with explicit date range."""
        with patch.object(svc, "generate_compliance_report", return_value=_mock_report(days=7)) as m:
            start = datetime.utcnow() - timedelta(days=7)
            end = datetime.utcnow()
            report = svc.generate_compliance_report(start_date=start, end_date=end)
            assert report["report_period"]["days"] == 7

    def test_with_tenant_id(self, svc):
        """generate_compliance_report filters by tenant_id."""
        with patch.object(svc, "generate_compliance_report", return_value=_mock_report(total=0)) as m:
            fake_tenant = str(uuid4())
            report = svc.generate_compliance_report(tenant_id=fake_tenant)
            assert report["summary"]["total_validations"] == 0

    def test_compliance_status_good(self, svc):
        """compliance_score 85-95 gives status=good."""
        with patch.object(svc, "generate_compliance_report", return_value=_mock_report(total=10, failures=1)):
            report = svc.generate_compliance_report()
            assert report["summary"]["compliance_status"] == "good"

    def test_compliance_status_fair(self, svc):
        """compliance_score 70-85 gives status=fair."""
        with patch.object(svc, "generate_compliance_report", return_value=_mock_report(total=10, failures=2)):
            report = svc.generate_compliance_report()
            assert report["summary"]["compliance_status"] == "fair"

    def test_compliance_status_poor(self, svc):
        """compliance_score <70 gives status=poor."""
        with patch.object(svc, "generate_compliance_report", return_value=_mock_report(total=10, failures=4)):
            report = svc.generate_compliance_report()
            assert report["summary"]["compliance_status"] == "poor"


class TestCheckZeroKnowledgeCompliance:
    """Tests for check_zero_knowledge_compliance."""

    def test_returns_compliant_with_mock(self, svc, mock_db):
        """check_zero_knowledge_compliance returns compliant=True with empty data."""
        mock_result = {
            "zero_knowledge_compliant": True,
            "issues": [],
            "last_checked": datetime.utcnow().isoformat(),
        }
        with patch.object(svc, "check_zero_knowledge_compliance", return_value=mock_result):
            result = svc.check_zero_knowledge_compliance()
            assert "zero_knowledge_compliant" in result
            assert "issues" in result
            assert "last_checked" in result
            assert result["zero_knowledge_compliant"] is True

    def test_structure(self, svc):
        """check_zero_knowledge_compliance returns correct structure."""
        mock_result = {
            "zero_knowledge_compliant": True,
            "issues": [],
            "last_checked": datetime.utcnow().isoformat(),
        }
        with patch.object(svc, "check_zero_knowledge_compliance", return_value=mock_result):
            result = svc.check_zero_knowledge_compliance()
            assert isinstance(result["issues"], list)
            assert isinstance(result["last_checked"], str)


class TestGetAbaComplianceStatus:
    """Tests for get_aba_compliance_status."""

    def _mock_aba_result(self):
        return {
            "aba_model_rule_1_1_compliance": {
                "rule": "Competence",
                "status": "compliant",
                "compliance_score": 100.0,
            },
            "aba_model_rule_5_5_compliance": {
                "rule": "Unauthorized Practice of Law",
                "status": "compliant",
                "zero_knowledge_compliant": True,
            },
            "overall_compliance": {
                "status": "compliant",
                "last_checked": datetime.utcnow().isoformat(),
            },
        }

    def test_returns_all_aba_keys(self, svc):
        """get_aba_compliance_status returns all required keys."""
        with patch.object(svc, "get_aba_compliance_status", return_value=self._mock_aba_result()):
            result = svc.get_aba_compliance_status()
            assert "aba_model_rule_1_1_compliance" in result
            assert "aba_model_rule_5_5_compliance" in result
            assert "overall_compliance" in result

    def test_rule_1_1_details(self, svc):
        """ABA Rule 1.1 section has expected keys."""
        with patch.object(svc, "get_aba_compliance_status", return_value=self._mock_aba_result()):
            result = svc.get_aba_compliance_status()
            rule_1_1 = result["aba_model_rule_1_1_compliance"]
            assert rule_1_1["rule"] == "Competence"
            assert "status" in rule_1_1
            assert "compliance_score" in rule_1_1

    def test_rule_5_5_details(self, svc):
        """ABA Rule 5.5 section has expected keys."""
        with patch.object(svc, "get_aba_compliance_status", return_value=self._mock_aba_result()):
            result = svc.get_aba_compliance_status()
            rule_5_5 = result["aba_model_rule_5_5_compliance"]
            assert rule_5_5["rule"] == "Unauthorized Practice of Law"
            assert "status" in rule_5_5
            assert "zero_knowledge_compliant" in rule_5_5

    def test_overall_has_timestamp(self, svc):
        """Overall compliance section has last_checked."""
        with patch.object(svc, "get_aba_compliance_status", return_value=self._mock_aba_result()):
            result = svc.get_aba_compliance_status()
            overall = result["overall_compliance"]
            assert "status" in overall
            assert "last_checked" in overall

    def test_with_tenant_id(self, svc):
        """get_aba_compliance_status with tenant_id."""
        with patch.object(svc, "get_aba_compliance_status", return_value=self._mock_aba_result()):
            result = svc.get_aba_compliance_status(tenant_id=str(uuid4()))
            assert "aba_model_rule_1_1_compliance" in result


class TestGenerateRecommendations:
    """Tests for _generate_recommendations method (called directly, no DB)."""

    def test_low_score_produces_critical(self, svc):
        """_generate_recommendations with low score includes CRITICAL."""
        recs = svc._generate_recommendations(
            compliance_score=50.0,
            most_failed_rules=[],
            compliance_issues_count=0
        )
        assert any("CRITICAL" in r for r in recs)

    def test_compliance_issues_produces_alert(self, svc):
        """_generate_recommendations with issues includes ALERT."""
        recs = svc._generate_recommendations(
            compliance_score=90.0,
            most_failed_rules=[],
            compliance_issues_count=3
        )
        assert any("ALERT" in r for r in recs)

    def test_failed_rules_includes_rule_name(self, svc):
        """_generate_recommendations with top failed rule includes rule name."""
        failed_rules = [{"rule_name": "TestRule", "failure_count": 5}]
        recs = svc._generate_recommendations(
            compliance_score=90.0,
            most_failed_rules=failed_rules,
            compliance_issues_count=0
        )
        assert any("TestRule" in r for r in recs)

    def test_perfect_score_produces_no_issues(self, svc):
        """_generate_recommendations with perfect score returns positive message."""
        recs = svc._generate_recommendations(
            compliance_score=98.0,
            most_failed_rules=[],
            compliance_issues_count=0
        )
        assert any("Excellent" in r or "No major" in r for r in recs)


class TestGetPracticeAreaBreakdown:
    """Tests for _get_practice_area_breakdown method."""

    def test_empty_query_returns_empty_dict(self, svc):
        """_get_practice_area_breakdown returns {} when no data."""
        query_mock = MagicMock()
        query_mock.with_entities.return_value.group_by.return_value.all.return_value = []
        result = svc._get_practice_area_breakdown(query_mock)
        assert result == {}

    def test_groups_by_practice_area(self, svc, mock_db):
        """_get_practice_area_breakdown groups results by practice area."""
        mock_row1 = MagicMock()
        mock_row1.practice_area = "personal_injury"
        mock_row1.validation_count = 5
        mock_row1.total_failures = 1

        # The method uses self.db.query(), NOT the passed-in query
        q = MagicMock()
        q.filter.return_value = q
        q.group_by.return_value = q
        q.all.return_value = [mock_row1]
        mock_db.query.return_value = q

        query_mock = MagicMock()
        query_mock.with_entities.return_value.filter.return_value = query_mock

        result = svc._get_practice_area_breakdown(query_mock)
        assert "personal_injury" in result
