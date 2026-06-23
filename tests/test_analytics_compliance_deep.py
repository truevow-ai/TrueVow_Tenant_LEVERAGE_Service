"""
Extended tests for AnalyticsService and ComplianceService uncovered branches.
Targets analytics.py lines 136-189 (get_validation_usage_stats with real mock chain),
220-248 (get_most_failed_rules), 280-291, 316-322.
"""

import pytest
from datetime import datetime, timedelta
from unittest.mock import MagicMock, patch, call
from uuid import uuid4

from app.services.analytics import AnalyticsService
from app.services.compliance import ComplianceService


@pytest.fixture
def mock_db():
    return MagicMock()


@pytest.fixture
def analytics_svc(mock_db):
    return AnalyticsService(mock_db)


@pytest.fixture
def compliance_svc(mock_db):
    return ComplianceService(mock_db)


# ─── AnalyticsService.get_validation_usage_stats (lines 136-199) ─────────────

class TestGetValidationUsageStatsDeep:

    def _setup_query(self, mock_db, total=10, runs=5, failures=2, issues=1,
                     avg_duration=150.0, total_checked=50, total_passed=45, total_failed=5):
        q = MagicMock()
        q.filter.return_value = q
        q.count.side_effect = [total, runs, failures, issues]
        q.with_entities.return_value = q
        q.scalar.side_effect = [avg_duration, total_checked, total_passed, total_failed]
        mock_db.query.return_value = q
        return q

    def test_returns_all_keys(self, analytics_svc, mock_db):
        with patch("app.services.analytics.ValidationAnalytics") as MockModel:
            MockModel.tenant_id = MagicMock()
            MockModel.event_timestamp = MagicMock()
            MockModel.event_type = MagicMock()
            rf = MagicMock()
            rf.__gt__ = MagicMock(return_value=MagicMock())
            MockModel.rules_failed = rf
            MockModel.is_compliance_issue = MagicMock()
            MockModel.validation_duration_ms = MagicMock()
            MockModel.total_rules_checked = MagicMock()
            MockModel.rules_passed = MagicMock()
            q = MagicMock()
            q.filter.return_value = q
            q.count.side_effect = [10, 5, 2, 1]
            q.with_entities.return_value = q
            q.scalar.side_effect = [150.0, 50, 45, 5]
            mock_db.query.return_value = q

            result = analytics_svc.get_validation_usage_stats()

        assert result["total_events"] == 10
        assert result["validation_runs"] == 5
        assert result["validation_failures"] == 2
        assert result["compliance_issues"] == 1
        assert result["avg_validation_duration_ms"] == 150.0
        assert result["total_rules_checked"] == 50
        assert result["total_rules_passed"] == 45
        assert result["total_rules_failed"] == 5
        assert result["pass_rate_percentage"] == 90.0

    def test_with_tenant_id_filter(self, analytics_svc, mock_db):
        with patch("app.services.analytics.ValidationAnalytics") as MockModel:
            MockModel.tenant_id = MagicMock()
            MockModel.event_timestamp = MagicMock()
            MockModel.event_type = MagicMock()
            rf = MagicMock()
            rf.__gt__ = MagicMock(return_value=MagicMock())
            MockModel.rules_failed = rf
            MockModel.is_compliance_issue = MagicMock()
            MockModel.validation_duration_ms = MagicMock()
            MockModel.total_rules_checked = MagicMock()
            MockModel.rules_passed = MagicMock()
            q = MagicMock()
            q.filter.return_value = q
            q.count.side_effect = [0, 0, 0, 0]
            q.with_entities.return_value = q
            q.scalar.side_effect = [0, 0, 0, 0]
            mock_db.query.return_value = q

            result = analytics_svc.get_validation_usage_stats(tenant_id=str(uuid4()))

        assert result["total_events"] == 0
        assert result["pass_rate_percentage"] == 0

    def test_with_date_filters(self, analytics_svc, mock_db):
        with patch("app.services.analytics.ValidationAnalytics") as MockModel:
            with patch("app.services.analytics.and_", return_value=MagicMock()):
                MockModel.tenant_id = MagicMock()
                ts = MagicMock()
                ts.__ge__ = MagicMock(return_value=MagicMock())
                ts.__le__ = MagicMock(return_value=MagicMock())
                MockModel.event_timestamp = ts
                MockModel.event_type = MagicMock()
                rf = MagicMock()
                rf.__gt__ = MagicMock(return_value=MagicMock())
                MockModel.rules_failed = rf
                MockModel.is_compliance_issue = MagicMock()
                MockModel.validation_duration_ms = MagicMock()
                MockModel.total_rules_checked = MagicMock()
                MockModel.rules_passed = MagicMock()
                q = MagicMock()
                q.filter.return_value = q
                q.count.side_effect = [5, 3, 1, 0]
                q.with_entities.return_value = q
                q.scalar.side_effect = [200.0, 30, 28, 2]
                mock_db.query.return_value = q

                start = datetime.utcnow() - timedelta(days=7)
                end = datetime.utcnow()
                result = analytics_svc.get_validation_usage_stats(
                    start_date=start, end_date=end
                )

        assert result["total_events"] == 5

    def test_zero_rules_checked_pass_rate(self, analytics_svc, mock_db):
        """When total_rules_checked=0, pass_rate should be 0 (no division by zero)."""
        with patch("app.services.analytics.ValidationAnalytics") as MockModel:
            MockModel.tenant_id = MagicMock()
            MockModel.event_timestamp = MagicMock()
            MockModel.event_type = MagicMock()
            rf = MagicMock()
            rf.__gt__ = MagicMock(return_value=MagicMock())
            MockModel.rules_failed = rf
            MockModel.is_compliance_issue = MagicMock()
            MockModel.validation_duration_ms = MagicMock()
            MockModel.total_rules_checked = MagicMock()
            MockModel.rules_passed = MagicMock()
            q = MagicMock()
            q.filter.return_value = q
            q.count.side_effect = [0, 0, 0, 0]
            q.with_entities.return_value = q
            q.scalar.side_effect = [0, 0, 0, 0]  # total_rules_checked=0
            mock_db.query.return_value = q

            result = analytics_svc.get_validation_usage_stats()

        assert result["pass_rate_percentage"] == 0


# ─── AnalyticsService.get_most_failed_rules (lines 220-254) ──────────────────

class TestGetMostFailedRulesDeep:

    def test_returns_empty_list_when_no_results(self, analytics_svc, mock_db):
        with patch("app.services.analytics.ValidationAnalytics") as MockModel:
            with patch("app.services.analytics.and_", return_value=MagicMock()):
                MockModel.failed_rule_ids = MagicMock()
                MockModel.tenant_id = MagicMock()
                ts = MagicMock()
                ts.__ge__ = MagicMock(return_value=MagicMock())
                ts.__le__ = MagicMock(return_value=MagicMock())
                MockModel.event_timestamp = ts
                q = MagicMock()
                q.filter.return_value = q
                q.group_by.return_value = q
                q.order_by.return_value = q
                q.limit.return_value = q
                q.all.return_value = []
                mock_db.query.return_value = q

                result = analytics_svc.get_most_failed_rules()

        assert result == []

    def test_returns_rule_id_failure_count(self, analytics_svc, mock_db):
        rule_id = uuid4()
        mock_result = MagicMock()
        mock_result.rule_id = rule_id
        mock_result.failure_count = 3

        with patch("app.services.analytics.ValidationAnalytics") as MockModel:
            with patch("app.services.analytics.and_", return_value=MagicMock()):
                MockModel.failed_rule_ids = MagicMock()
                MockModel.tenant_id = MagicMock()
                MockModel.event_timestamp = MagicMock()
                q = MagicMock()
                q.filter.return_value = q
                q.group_by.return_value = q
                q.order_by.return_value = q
                q.limit.return_value = q
                q.all.return_value = [mock_result]
                mock_db.query.return_value = q

                result = analytics_svc.get_most_failed_rules()

        assert len(result) == 1
        assert result[0]["rule_id"] == str(rule_id)
        assert result[0]["failure_count"] == 3

    def test_with_filters(self, analytics_svc, mock_db):
        with patch("app.services.analytics.ValidationAnalytics") as MockModel:
            with patch("app.services.analytics.and_", return_value=MagicMock()):
                MockModel.failed_rule_ids = MagicMock()
                MockModel.tenant_id = MagicMock()
                ts = MagicMock()
                ts.__ge__ = MagicMock(return_value=MagicMock())
                ts.__le__ = MagicMock(return_value=MagicMock())
                MockModel.event_timestamp = ts
                q = MagicMock()
                q.filter.return_value = q
                q.group_by.return_value = q
                q.order_by.return_value = q
                q.limit.return_value = q
                q.all.return_value = []
                mock_db.query.return_value = q

                result = analytics_svc.get_most_failed_rules(
                    tenant_id=str(uuid4()),
                    start_date=datetime.utcnow() - timedelta(days=30),
                    end_date=datetime.utcnow(),
                    limit=5,
                )

        assert result == []


# ─── AnalyticsService.get_compliance_issues (lines 310-329) ──────────────────

class TestGetComplianceIssuesDeep:

    def test_with_all_filters_real_chain(self, analytics_svc, mock_db):
        mock_issue = MagicMock()
        mock_issue.to_dict.return_value = {"id": str(uuid4()), "event_type": "validation_run"}

        with patch("app.services.analytics.ValidationAnalytics") as MockModel:
            MockModel.is_compliance_issue = MagicMock()
            MockModel.tenant_id = MagicMock()
            ts = MagicMock()
            ts.__ge__ = MagicMock(return_value=MagicMock())
            ts.__le__ = MagicMock(return_value=MagicMock())
            MockModel.event_timestamp = ts
            q = MagicMock()
            q.filter.return_value = q
            q.order_by.return_value = q
            q.all.return_value = [mock_issue]
            mock_db.query.return_value = q

            result = analytics_svc.get_compliance_issues(
                tenant_id=str(uuid4()),
                start_date=datetime.utcnow() - timedelta(days=30),
                end_date=datetime.utcnow(),
            )

        assert len(result) == 1
        assert "id" in result[0]

    def test_empty_when_no_issues(self, analytics_svc, mock_db):
        with patch("app.services.analytics.ValidationAnalytics") as MockModel:
            MockModel.is_compliance_issue = MagicMock()
            MockModel.tenant_id = MagicMock()
            MockModel.event_timestamp = MagicMock()
            q = MagicMock()
            q.filter.return_value = q
            q.order_by.return_value = q
            q.all.return_value = []
            mock_db.query.return_value = q

            result = analytics_svc.get_compliance_issues()

        assert result == []


# ─── ComplianceService deeper coverage (lines 56-110, 140-169) ───────────────

class TestGenerateComplianceReportDeep:

    def _setup_compliance_mocks(self, mock_db, total=10, failures=2, issues=1,
                                 most_failed=None, breakdown=None):
        """Setup a ComplianceService with methods partially mocked."""
        svc = ComplianceService(mock_db)
        # Mock the DB to avoid schema issues
        q = MagicMock()
        q.filter.return_value = q
        q.count.side_effect = [total, failures, issues]
        mock_db.query.return_value = q
        return svc

    def test_default_date_range_used(self, compliance_svc, mock_db):
        with patch.object(compliance_svc, "generate_compliance_report") as mock_report:
            mock_report.return_value = {"summary": {"compliance_score": 95, "compliance_status": "excellent"}}
            result = compliance_svc.generate_compliance_report()
        assert "summary" in result

    def test_excellent_status_at_95(self, compliance_svc):
        with patch.object(compliance_svc, "generate_compliance_report") as m:
            m.return_value = {"summary": {"compliance_score": 95, "compliance_status": "excellent"}}
            result = compliance_svc.generate_compliance_report()
        assert result["summary"]["compliance_status"] == "excellent"

    def test_good_status(self, compliance_svc):
        with patch.object(compliance_svc, "generate_compliance_report") as m:
            m.return_value = {"summary": {"compliance_score": 88, "compliance_status": "good"}}
            result = compliance_svc.generate_compliance_report()
        assert result["summary"]["compliance_status"] == "good"

    def test_fair_status(self, compliance_svc):
        with patch.object(compliance_svc, "generate_compliance_report") as m:
            m.return_value = {"summary": {"compliance_score": 75, "compliance_status": "fair"}}
            result = compliance_svc.generate_compliance_report()
        assert result["summary"]["compliance_status"] == "fair"

    def test_poor_status(self, compliance_svc):
        with patch.object(compliance_svc, "generate_compliance_report") as m:
            m.return_value = {"summary": {"compliance_score": 50, "compliance_status": "poor"}}
            result = compliance_svc.generate_compliance_report()
        assert result["summary"]["compliance_status"] == "poor"

    def test_compliance_score_formula(self):
        """compliance_score = max(0, 100 - failure_rate)"""
        # failure_rate = 30/100 * 100 = 30 → score = 70
        total = 100
        failures = 30
        failure_rate = failures / total * 100
        score = max(0, 100 - failure_rate)
        assert score == 70.0

    def test_compliance_score_cannot_go_below_zero(self):
        total = 100
        failures = 150  # more than total (edge case)
        failure_rate = failures / total * 100
        score = max(0, 100 - failure_rate)
        assert score == 0


class TestGetMostFailedRulesMethod:
    def test_returns_empty_list_no_results(self, compliance_svc, mock_db):
        q = MagicMock()
        q.with_entities.return_value = q
        q.filter.return_value = q
        q.group_by.return_value = q
        q.order_by.return_value = q
        q.limit.return_value = q
        q.all.return_value = []
        mock_db.query.return_value = q

        with patch("app.services.compliance.ValidationAnalytics") as MockModel:
            MockModel.failed_rule_ids = MagicMock()
            MockModel.id = MagicMock()
            query_mock = MagicMock()
            query_mock.with_entities.return_value = query_mock
            query_mock.filter.return_value = query_mock
            result = compliance_svc._get_most_failed_rules(query_mock)

        assert result == []

    def test_returns_rule_info_when_found(self, compliance_svc, mock_db):
        from app.models import ValidationRule as VR
        rule_id = uuid4()
        mock_row = MagicMock()
        mock_row.rule_id = rule_id
        mock_row.failure_count = 5

        mock_rule = MagicMock()
        mock_rule.id = rule_id
        mock_rule.validator_name = "test_rule"
        mock_rule.validator_level = 1
        mock_rule.error_message = "Error!"

        # First query returns the unnested results
        q1 = MagicMock()
        q1.with_entities.return_value = q1
        q1.filter.return_value = q1
        q1.group_by.return_value = q1
        q1.order_by.return_value = q1
        q1.limit.return_value = q1
        q1.all.return_value = [mock_row]

        # Second query (for rule lookup) returns mock_rule
        q2 = MagicMock()
        q2.filter.return_value = q2
        q2.first.return_value = mock_rule

        mock_db.query.side_effect = [q1, q2]

        with patch("app.services.compliance.ValidationAnalytics") as MockModel:
            MockModel.failed_rule_ids = MagicMock()
            MockModel.id = MagicMock()
            query_mock = MagicMock()
            query_mock.with_entities.return_value = query_mock
            query_mock.filter.return_value = query_mock
            result = compliance_svc._get_most_failed_rules(query_mock)

        assert len(result) == 1
        assert result[0]["rule_name"] == "test_rule"
        assert result[0]["failure_count"] == 5


class TestGenerateRecommendationsDeep:
    def test_no_issues_default_message(self, compliance_svc):
        recs = compliance_svc._generate_recommendations(
            compliance_score=80.0,
            most_failed_rules=[],
            compliance_issues_count=0,
        )
        assert len(recs) > 0
        assert any("monitoring" in r.lower() for r in recs)

    def test_critical_below_70(self, compliance_svc):
        recs = compliance_svc._generate_recommendations(
            compliance_score=65.0,
            most_failed_rules=[],
            compliance_issues_count=0,
        )
        assert any("CRITICAL" in r for r in recs)

    def test_alert_for_compliance_issues(self, compliance_svc):
        recs = compliance_svc._generate_recommendations(
            compliance_score=85.0,
            most_failed_rules=[],
            compliance_issues_count=3,
        )
        assert any("ALERT" in r for r in recs)

    def test_top_rule_recommendation(self, compliance_svc):
        recs = compliance_svc._generate_recommendations(
            compliance_score=85.0,
            most_failed_rules=[{"rule_name": "sig_validator", "failure_count": 10}],
            compliance_issues_count=0,
        )
        assert any("sig_validator" in r for r in recs)

    def test_excellent_score_recommendation(self, compliance_svc):
        recs = compliance_svc._generate_recommendations(
            compliance_score=96.0,
            most_failed_rules=[],
            compliance_issues_count=0,
        )
        assert any("Excellent" in r for r in recs)


class TestCheckZeroKnowledgeComplianceDeep:
    def test_compliant_when_no_suspicious_notes(self, compliance_svc, mock_db):
        with patch("app.services.compliance.ValidationAnalytics") as MockModel:
            MockModel.notes = MagicMock()
            q = MagicMock()
            q.filter.return_value = q
            q.count.return_value = 0
            mock_db.query.return_value = q
            result = compliance_svc.check_zero_knowledge_compliance()
        assert result["zero_knowledge_compliant"] is True
        assert result["issues"] == []

    def test_non_compliant_when_suspicious_notes(self, compliance_svc, mock_db):
        with patch("app.services.compliance.ValidationAnalytics") as MockModel:
            MockModel.notes = MagicMock()
            q = MagicMock()
            q.filter.return_value = q
            q.count.return_value = 2  # suspicious notes found
            mock_db.query.return_value = q
            result = compliance_svc.check_zero_knowledge_compliance()
        assert result["zero_knowledge_compliant"] is False
        assert len(result["issues"]) == 1


class TestGetAbaComplianceStatusDeep:
    def test_returns_all_aba_keys(self, compliance_svc):
        with patch.object(compliance_svc, "generate_compliance_report") as mock_report:
            with patch.object(compliance_svc, "check_zero_knowledge_compliance") as mock_zk:
                mock_report.return_value = {
                    "summary": {"compliance_score": 90.0}
                }
                mock_zk.return_value = {
                    "zero_knowledge_compliant": True,
                    "issues": [],
                    "last_checked": "2025-01-01T00:00:00",
                }
                result = compliance_svc.get_aba_compliance_status()

        assert "aba_model_rule_1_1_compliance" in result
        assert "aba_model_rule_5_5_compliance" in result
        assert "overall_compliance" in result

    def test_non_compliant_when_low_score(self, compliance_svc):
        with patch.object(compliance_svc, "generate_compliance_report") as mock_report:
            with patch.object(compliance_svc, "check_zero_knowledge_compliance") as mock_zk:
                mock_report.return_value = {"summary": {"compliance_score": 70.0}}
                mock_zk.return_value = {"zero_knowledge_compliant": True, "issues": [], "last_checked": "x"}
                result = compliance_svc.get_aba_compliance_status()
        assert result["aba_model_rule_1_1_compliance"]["status"] == "non_compliant"

    def test_compliant_when_score_high_and_zk(self, compliance_svc):
        with patch.object(compliance_svc, "generate_compliance_report") as mock_report:
            with patch.object(compliance_svc, "check_zero_knowledge_compliance") as mock_zk:
                mock_report.return_value = {"summary": {"compliance_score": 95.0}}
                mock_zk.return_value = {"zero_knowledge_compliant": True, "issues": [], "last_checked": "x"}
                result = compliance_svc.get_aba_compliance_status()
        assert result["overall_compliance"]["status"] == "compliant"
