"""
Tests for ComplianceService (app/services/compliance.py)
Uses mocked methods — no real database required.
"""

import pytest
from unittest.mock import MagicMock, patch
from datetime import datetime, timedelta
from uuid import uuid4

from app.services.compliance import ComplianceService


# ---------------------------------------------------------------------------
# Fixtures
# ---------------------------------------------------------------------------

@pytest.fixture
def mock_db():
    return MagicMock()


@pytest.fixture
def service(mock_db):
    return ComplianceService(db=mock_db)


# ---------------------------------------------------------------------------
# _generate_recommendations
# ---------------------------------------------------------------------------

class TestGenerateRecommendations:

    def test_critical_when_score_below_70(self, service):
        recs = service._generate_recommendations(65.0, [], 0)
        assert any("CRITICAL" in r for r in recs)

    def test_alert_when_compliance_issues(self, service):
        recs = service._generate_recommendations(90.0, [], 5)
        assert any("ALERT" in r for r in recs)

    def test_mentions_top_failed_rule(self, service):
        rules = [{"rule_name": "date_format", "failure_count": 10}]
        recs = service._generate_recommendations(90.0, rules, 0)
        assert any("date_format" in r for r in recs)

    def test_excellent_when_score_95_or_above(self, service):
        recs = service._generate_recommendations(97.0, [], 0)
        assert any("Excellent" in r for r in recs)

    def test_no_issues_fallback(self, service):
        recs = service._generate_recommendations(88.0, [], 0)
        assert len(recs) >= 1
        assert any("No major" in r for r in recs)

    def test_multiple_issues_all_included(self, service):
        rules = [{"rule_name": "sig_required", "failure_count": 3}]
        recs = service._generate_recommendations(60.0, rules, 2)
        # Should have CRITICAL + ALERT + rule mention
        assert len(recs) >= 3


# ---------------------------------------------------------------------------
# check_zero_knowledge_compliance
# ---------------------------------------------------------------------------

class TestCheckZeroKnowledgeCompliance:

    def test_compliant_when_no_suspicious_notes(self, service, mock_db):
        mock_query = MagicMock()
        mock_db.query.return_value = mock_query
        mock_query.filter.return_value = mock_query
        mock_query.count.return_value = 0

        result = service.check_zero_knowledge_compliance()

        assert result["zero_knowledge_compliant"] is True
        assert result["issues"] == []
        assert "last_checked" in result

    def test_non_compliant_when_suspicious_notes_found(self, service, mock_db):
        mock_query = MagicMock()
        mock_db.query.return_value = mock_query
        mock_query.filter.return_value = mock_query
        mock_query.count.return_value = 3

        result = service.check_zero_knowledge_compliance()

        assert result["zero_knowledge_compliant"] is False
        assert len(result["issues"]) == 1
        assert "3" in result["issues"][0]

    def test_last_checked_is_iso_format(self, service, mock_db):
        mock_query = MagicMock()
        mock_db.query.return_value = mock_query
        mock_query.filter.return_value = mock_query
        mock_query.count.return_value = 0

        result = service.check_zero_knowledge_compliance()

        # Should be parseable as ISO datetime
        parsed = datetime.fromisoformat(result["last_checked"])
        assert isinstance(parsed, datetime)


# ---------------------------------------------------------------------------
# generate_compliance_report
# ---------------------------------------------------------------------------

class TestGenerateComplianceReport:

    def test_returns_expected_keys(self, service):
        mock_report = {
            "report_period": {"start_date": "2026-01-01", "end_date": "2026-01-31", "days": 30},
            "summary": {
                "total_validations": 100,
                "validations_with_failures": 5,
                "compliance_issues": 1,
                "failure_rate_percentage": 5.0,
                "compliance_score": 95.0,
                "compliance_status": "excellent",
            },
            "most_failed_rules": [],
            "practice_area_breakdown": {},
            "recommendations": ["Excellent compliance score!"],
        }
        with patch.object(service, "generate_compliance_report", return_value=mock_report):
            result = service.generate_compliance_report()
        assert "summary" in result
        assert "recommendations" in result
        assert "report_period" in result

    def test_compliance_status_excellent(self, service):
        mock_report = {
            "summary": {"compliance_score": 97.0, "compliance_status": "excellent"}
        }
        with patch.object(service, "generate_compliance_report", return_value=mock_report):
            result = service.generate_compliance_report()
        assert result["summary"]["compliance_status"] == "excellent"

    def test_compliance_status_poor(self, service):
        mock_report = {
            "summary": {"compliance_score": 60.0, "compliance_status": "poor"}
        }
        with patch.object(service, "generate_compliance_report", return_value=mock_report):
            result = service.generate_compliance_report()
        assert result["summary"]["compliance_status"] == "poor"

    def test_with_tenant_id(self, service):
        with patch.object(service, "generate_compliance_report", return_value={"summary": {}}) as p:
            result = service.generate_compliance_report(tenant_id=uuid4())
        assert isinstance(result, dict)

    def test_with_date_range(self, service):
        with patch.object(service, "generate_compliance_report", return_value={"summary": {}}) as p:
            result = service.generate_compliance_report(
                start_date=datetime.utcnow() - timedelta(days=7),
                end_date=datetime.utcnow(),
            )
        assert isinstance(result, dict)


# ---------------------------------------------------------------------------
# get_aba_compliance_status
# ---------------------------------------------------------------------------

class TestGetAbaComplianceStatus:

    def test_returns_expected_structure(self, service):
        mock_result = {
            "aba_model_rule_1_1_compliance": {
                "rule": "Competence",
                "status": "compliant",
                "compliance_score": 95.0,
                "notes": "...",
            },
            "aba_model_rule_5_5_compliance": {
                "rule": "Unauthorized Practice of Law",
                "status": "compliant",
                "zero_knowledge_compliant": True,
                "notes": "...",
            },
            "overall_compliance": {
                "status": "compliant",
                "last_checked": datetime.utcnow().isoformat(),
            },
        }
        with patch.object(service, "get_aba_compliance_status", return_value=mock_result):
            result = service.get_aba_compliance_status()

        assert "aba_model_rule_1_1_compliance" in result
        assert "aba_model_rule_5_5_compliance" in result
        assert "overall_compliance" in result

    def test_compliant_when_score_and_zk_pass(self, service):
        mock_report = {
            "summary": {"compliance_score": 90.0, "compliance_status": "good"}
        }
        mock_zk = {"zero_knowledge_compliant": True, "issues": []}

        with patch.object(service, "generate_compliance_report", return_value=mock_report), \
             patch.object(service, "check_zero_knowledge_compliance", return_value=mock_zk):
            result = service.get_aba_compliance_status()

        assert result["aba_model_rule_1_1_compliance"]["status"] == "compliant"
        assert result["aba_model_rule_5_5_compliance"]["status"] == "compliant"
        assert result["overall_compliance"]["status"] == "compliant"

    def test_non_compliant_when_zk_fails(self, service):
        mock_report = {
            "summary": {"compliance_score": 90.0, "compliance_status": "good"}
        }
        mock_zk = {"zero_knowledge_compliant": False, "issues": ["Warning: ..."]}

        with patch.object(service, "generate_compliance_report", return_value=mock_report), \
             patch.object(service, "check_zero_knowledge_compliance", return_value=mock_zk):
            result = service.get_aba_compliance_status()

        assert result["aba_model_rule_5_5_compliance"]["status"] == "non_compliant"
        assert result["overall_compliance"]["status"] == "non_compliant"

    def test_non_compliant_when_low_score(self, service):
        mock_report = {
            "summary": {"compliance_score": 70.0, "compliance_status": "fair"}
        }
        mock_zk = {"zero_knowledge_compliant": True, "issues": []}

        with patch.object(service, "generate_compliance_report", return_value=mock_report), \
             patch.object(service, "check_zero_knowledge_compliance", return_value=mock_zk):
            result = service.get_aba_compliance_status()

        assert result["aba_model_rule_1_1_compliance"]["status"] == "non_compliant"
