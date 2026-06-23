"""
TrueVow DRAFT™ Service - Compliance Service
Business logic for compliance monitoring and reporting
"""

from datetime import datetime, timedelta
from typing import Dict, List, Optional
from uuid import UUID

from sqlalchemy.orm import Session
from sqlalchemy import and_, func

from app.models.analytics_v2 import ValidationAnalytics
from app.models.validation_rule_v2 import ValidationRule
from app.core.config import get_settings

settings = get_settings()


class ComplianceService:
    """
    Service for compliance monitoring and reporting
    
    Features:
    - Generate compliance reports
    - Monitor validation failures
    - Track ABA Model Rules compliance
    - Alert on compliance violations
    
    Compliance Framework:
    - ABA Model Rule 1.1 (Competence)
    - ABA Model Rule 5.5 (Unauthorized Practice of Law)
    - Zero-knowledge architecture enforcement
    """
    
    def __init__(self, db: Session):
        self.db = db
    
    def generate_compliance_report(
        self,
        tenant_id: Optional[UUID] = None,
        start_date: Optional[datetime] = None,
        end_date: Optional[datetime] = None,
    ) -> Dict:
        """
        Generate compliance report
        
        Args:
            tenant_id: Filter by tenant ID (optional)
            start_date: Start date (optional, default: last 30 days)
            end_date: End date (optional, default: now)
            
        Returns:
            Dict with compliance report data
        """
        if not start_date:
            start_date = datetime.utcnow() - timedelta(days=30)
        
        if not end_date:
            end_date = datetime.utcnow()
        
        # Build query
        query = self.db.query(ValidationAnalytics).filter(
            ValidationAnalytics.event_timestamp >= start_date,
            ValidationAnalytics.event_timestamp <= end_date
        )
        
        if tenant_id:
            query = query.filter(ValidationAnalytics.tenant_id == tenant_id)
        
        # Get total validations
        total_validations = query.filter(
            ValidationAnalytics.event_type == "validation_run"
        ).count()
        
        # Get validations with failures
        validations_with_failures = query.filter(
            ValidationAnalytics.rules_failed > 0
        ).count()
        
        # Get compliance issues
        compliance_issues = query.filter(
            ValidationAnalytics.is_compliance_issue == True  # noqa: E712
        ).count()
        
        # Calculate failure rate
        failure_rate = (validations_with_failures / total_validations * 100) if total_validations > 0 else 0
        
        # Get most failed rules
        most_failed_rules = self._get_most_failed_rules(
            query, limit=10
        )
        
        # Get practice area breakdown
        practice_area_breakdown = self._get_practice_area_breakdown(query)
        
        # Compliance score (100 - failure rate)
        compliance_score = max(0, 100 - failure_rate)
        
        # Determine compliance status
        if compliance_score >= 95:
            compliance_status = "excellent"
        elif compliance_score >= 85:
            compliance_status = "good"
        elif compliance_score >= 70:
            compliance_status = "fair"
        else:
            compliance_status = "poor"
        
        return {
            "report_period": {
                "start_date": start_date.isoformat(),
                "end_date": end_date.isoformat(),
                "days": (end_date - start_date).days,
            },
            "summary": {
                "total_validations": total_validations,
                "validations_with_failures": validations_with_failures,
                "compliance_issues": compliance_issues,
                "failure_rate_percentage": round(failure_rate, 2),
                "compliance_score": round(compliance_score, 2),
                "compliance_status": compliance_status,
            },
            "most_failed_rules": most_failed_rules,
            "practice_area_breakdown": practice_area_breakdown,
            "recommendations": self._generate_recommendations(
                compliance_score,
                most_failed_rules,
                compliance_issues
            ),
        }
    
    def _get_most_failed_rules(
        self,
        query,
        limit: int = 10
    ) -> List[Dict]:
        """Get most failed rules from query"""
        # Query to unnest failed_rule_ids and count
        results = self.db.query(
            func.unnest(ValidationAnalytics.failed_rule_ids).label("rule_id"),
            func.count().label("failure_count")
        ).filter(
            ValidationAnalytics.id.in_(
                query.with_entities(ValidationAnalytics.id).filter(
                    ValidationAnalytics.failed_rule_ids.isnot(None)
                )
            )
        ).group_by("rule_id").order_by(
            func.count().desc()
        ).limit(limit).all()
        
        # Get rule details
        failed_rules = []
        for result in results:
            rule = self.db.query(ValidationRule).filter(
                ValidationRule.id == result.rule_id
            ).first()
            
            if rule:
                failed_rules.append({
                    "rule_id": str(rule.id),
                    "rule_name": rule.validator_name,
                    "rule_level": rule.validator_level,
                    "failure_count": result.failure_count,
                    "error_message": rule.error_message,
                })
        
        return failed_rules
    
    def _get_practice_area_breakdown(self, query) -> Dict:
        """Get practice area breakdown from query"""
        practice_areas = self.db.query(
            ValidationAnalytics.practice_area,
            func.count().label("validation_count"),
            func.sum(ValidationAnalytics.rules_failed).label("total_failures")
        ).filter(
            ValidationAnalytics.id.in_(
                query.with_entities(ValidationAnalytics.id).filter(
                    ValidationAnalytics.practice_area.isnot(None)
                )
            )
        ).group_by(ValidationAnalytics.practice_area).all()
        
        breakdown = {}
        for area in practice_areas:
            breakdown[area.practice_area] = {
                "validation_count": area.validation_count,
                "total_failures": area.total_failures or 0,
                "failure_rate": (area.total_failures / area.validation_count * 100) if area.validation_count > 0 else 0
            }
        
        return breakdown
    
    def _generate_recommendations(
        self,
        compliance_score: float,
        most_failed_rules: List[Dict],
        compliance_issues_count: int
    ) -> List[str]:
        """Generate recommendations based on compliance data"""
        recommendations = []
        
        if compliance_score < 70:
            recommendations.append(
                "CRITICAL: Compliance score is below 70%. Immediate review of validation "
                "processes required to ensure ABA Model Rules compliance."
            )
        
        if compliance_issues_count > 0:
            recommendations.append(
                f"ALERT: {compliance_issues_count} compliance issues detected. "
                "Review flagged validations and implement corrective actions."
            )
        
        if most_failed_rules:
            top_rule = most_failed_rules[0]
            recommendations.append(
                f"Most failed rule: '{top_rule['rule_name']}' (failed {top_rule['failure_count']} times). "
                "Consider reviewing rule configuration or providing additional training."
            )
        
        if compliance_score >= 95:
            recommendations.append(
                "Excellent compliance score! Continue current validation practices."
            )
        
        if not recommendations:
            recommendations.append(
                "No major compliance issues detected. Continue monitoring validation results."
            )
        
        return recommendations
    
    def check_zero_knowledge_compliance(self) -> Dict:
        """
        Check if system maintains zero-knowledge compliance
        
        Returns:
            Dict with zero-knowledge compliance status
        """
        issues = []
        
        # Check if any validation events have document content in notes
        # (this would be a violation)
        suspicious_notes_count = self.db.query(ValidationAnalytics).filter(
            ValidationAnalytics.notes.ilike("%document content%")
        ).count()
        
        if suspicious_notes_count > 0:
            issues.append(
                f"WARNING: {suspicious_notes_count} analytics events have suspicious notes "
                "that may contain document content."
            )
        
        # Check database schema compliance (from database.py)
        # This is handled in app.core.database.validate_no_document_content_in_db()
        
        return {
            "zero_knowledge_compliant": len(issues) == 0,
            "issues": issues,
            "last_checked": datetime.utcnow().isoformat(),
        }
    
    def get_aba_compliance_status(
        self,
        tenant_id: Optional[UUID] = None
    ) -> Dict:
        """
        Get ABA Model Rules compliance status
        
        Args:
            tenant_id: Tenant ID (optional)
            
        Returns:
            Dict with ABA compliance status
        """
        # ABA Model Rule 1.1: Competence
        # - Attorneys must use competent document validation
        
        # ABA Model Rule 5.5: Unauthorized Practice of Law
        # - System must not provide legal advice
        # - Validation must be client-side only
        
        report = self.generate_compliance_report(
            tenant_id=tenant_id,
            start_date=datetime.utcnow() - timedelta(days=90)
        )
        
        zero_knowledge_status = self.check_zero_knowledge_compliance()
        
        return {
            "aba_model_rule_1_1_compliance": {
                "rule": "Competence",
                "status": "compliant" if report["summary"]["compliance_score"] >= 85 else "non_compliant",
                "compliance_score": report["summary"]["compliance_score"],
                "notes": "Document validation system helps ensure attorney competence"
            },
            "aba_model_rule_5_5_compliance": {
                "rule": "Unauthorized Practice of Law",
                "status": "compliant" if zero_knowledge_status["zero_knowledge_compliant"] else "non_compliant",
                "zero_knowledge_compliant": zero_knowledge_status["zero_knowledge_compliant"],
                "notes": "Client-side validation ensures no unauthorized practice of law"
            },
            "overall_compliance": {
                "status": "compliant" if (
                    report["summary"]["compliance_score"] >= 85 and
                    zero_knowledge_status["zero_knowledge_compliant"]
                ) else "non_compliant",
                "last_checked": datetime.utcnow().isoformat()
            }
        }

