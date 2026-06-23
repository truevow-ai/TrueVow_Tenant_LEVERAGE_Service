"""
TrueVow DRAFT™ Service - Rules Service v2.0 (CORRECT ARCHITECTURE)

Comprehensive service layer for:
1. Global Rule Templates (SaaS Admin)
2. Tenant-Specific Rules (Law Firms)
3. Template Inheritance
4. Rule Selection for Validation

Zero-Knowledge Architecture:
- Rules contain validation logic only
- NO document content stored
- NO client data stored
"""

from datetime import datetime
from typing import List, Optional, Dict, Any
from uuid import UUID

from fastapi import HTTPException, status
from sqlalchemy import and_, or_, func
from sqlalchemy.orm import Session

from app.models import ValidationRule
from app.core.auth_v2 import get_tenant_filter


# ============================================================================
# GLOBAL RULE TEMPLATES SERVICE (SaaS Admin)
# ============================================================================

class GlobalRuleTemplatesService:
    """
    Service for managing global rule templates (SaaS Admin only)
    
    Templates are managed by SaaS Admin and available for inheritance by all law firms.
    """
    
    def __init__(self, db: Session):
        self.db = db
    
    def list_templates(
        self,
        validator_level: Optional[str] = None,
        practice_area: Optional[str] = None,
        specialization: Optional[str] = None,
        document_type: Optional[str] = None,
        jurisdiction_state: Optional[str] = None,
        is_active: Optional[bool] = True,
        skip: int = 0,
        limit: int = 100
    ) -> Dict[str, Any]:
        """
        List global rule templates
        
        Args:
            validator_level: Filter by level (1-5)
            practice_area: Filter by practice area
            specialization: Filter by specialization
            document_type: Filter by document type
            jurisdiction_state: Filter by jurisdiction
            is_active: Filter by active status
            skip: Pagination offset
            limit: Number of results
        
        Returns:
            Dict with templates, total, skip, limit
        """
        query = self.db.query(ValidationRule).filter(
            ValidationRule.is_template == True,
            ValidationRule.tenant_id == None,
            ValidationRule.deleted_at == None,
        )

        # Apply filters
        if validator_level is not None:
            query = query.filter(ValidationRule.validator_level == validator_level)
        if practice_area:
            query = query.filter(ValidationRule.practice_area == practice_area)
        if specialization:
            query = query.filter(ValidationRule.specialization == specialization)
        if document_type:
            query = query.filter(ValidationRule.document_type == document_type)
        if jurisdiction_state:
            query = query.filter(ValidationRule.jurisdiction_state == jurisdiction_state)
        if is_active is not None:
            query = query.filter(ValidationRule.is_active == is_active)
        
        # Get total count
        total = query.count()
        
        # Apply pagination
        templates = query.order_by(ValidationRule.created_at.desc()).offset(skip).limit(limit).all()
        
        return {
            "templates": [t.to_dict() for t in templates],
            "total": total,
            "skip": skip,
            "limit": limit
        }
    
    def get_template(self, template_id: UUID) -> ValidationRule:
        """
        Get global rule template by ID
        
        Args:
            template_id: Template ID
        
        Returns:
            Template record
        
        Raises:
            HTTPException: If template not found
        """
        template = self.db.query(ValidationRule).filter(
            ValidationRule.id == template_id,
            ValidationRule.is_template == True,
            ValidationRule.tenant_id == None,
            ValidationRule.deleted_at == None,
        ).first()

        if not template:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Template {template_id} not found"
            )

        return template

    def create_template(
        self,
        template_data: Dict[str, Any],
        created_by: Optional[UUID] = None
    ) -> ValidationRule:
        """
        Create global rule template

        Args:
            template_data: Template data
            created_by: User ID who created the template

        Returns:
            Created template
        """
        template = ValidationRule(
            is_template=True,
            tenant_id=None,
            template_name=template_data.get("template_name"),
            template_description=template_data.get("template_description"),
            rule_name=template_data.get("template_name"),  # Same as template_name
            validator_level=template_data.get("validator_level"),
            validator_name=template_data.get("validator_name"),
            validator_type=template_data.get("validator_type"),
            practice_area=template_data.get("practice_area"),
            specialization=template_data.get("specialization"),
            document_type=template_data.get("document_type"),
            jurisdiction_state=template_data.get("jurisdiction_state"),
            jurisdiction_county=template_data.get("jurisdiction_county"),
            jurisdiction_court=template_data.get("jurisdiction_court"),
            validator_config=template_data.get("validator_config", {}),
            error_message=template_data.get("error_message"),
            warning_message=template_data.get("warning_message"),
            info_message=template_data.get("info_message"),
            severity=template_data.get("severity", "error"),
            created_by=created_by,
            # Protocol v3: all new templates enter as needs_review.
            # Caller cannot bypass this — document_verified requires approve().
            review_status="needs_review",
        )
        
        self.db.add(template)
        self.db.commit()
        self.db.refresh(template)
        
        return template
    
    def update_template(
        self,
        template_id: UUID,
        template_data: Dict[str, Any]
    ) -> ValidationRule:
        """
        Update global rule template
        
        Args:
            template_id: Template ID
            template_data: Updated template data
        
        Returns:
            Updated template
        
        Raises:
            HTTPException: If template not found
        """
        template = self.get_template(template_id)
        
        # Update fields
        if "template_name" in template_data:
            template.template_name = template_data["template_name"]
            template.rule_name = template_data["template_name"]  # Keep in sync
        if "template_description" in template_data:
            template.template_description = template_data["template_description"]
        if "validator_config" in template_data:
            template.validator_config = template_data["validator_config"]
            # Protocol v3: any validator_config change invalidates prior approval.
            # Reset to needs_review so the rule must pass verification again.
            template.review_status = "needs_review"
        if "error_message" in template_data:
            template.error_message = template_data["error_message"]
        if "warning_message" in template_data:
            template.warning_message = template_data["warning_message"]
        if "info_message" in template_data:
            template.info_message = template_data["info_message"]
        if "severity" in template_data:
            template.severity = template_data["severity"]
        if "is_active" in template_data:
            template.is_active = template_data["is_active"]
        
        # Increment version
        template.version += 1
        
        self.db.commit()
        self.db.refresh(template)
        
        return template
    
    def archive_template(self, template_id: UUID) -> ValidationRule:
        """
        Archive global rule template
        
        Args:
            template_id: Template ID
        
        Returns:
            Archived template
        
        Raises:
            HTTPException: If template not found
        """
        template = self.get_template(template_id)
        
        template.is_active = False
        template.archived_at = datetime.now()
        
        self.db.commit()
        self.db.refresh(template)
        
        return template

    def approve_template(
        self,
        template_id: UUID,
        approved_by: Optional[str] = None,
    ) -> ValidationRule:
        """
        Attorney approval — the ONLY path to review_status='document_verified'.

        This method is intentionally separate from update_template.
        Callers must explicitly call this after attorney review is complete.
        Setting review_status='document_verified' through any other code path
        is forbidden (Protocol v3).

        Args:
            template_id: Template to approve
            approved_by: Clerk user/org ID of the approving attorney

        Returns:
            Approved template
        """
        from datetime import timezone
        template = self.get_template(template_id)

        if template.review_status == "flagged_error":
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail=(
                    f"Template {template_id} is flagged_error and cannot be approved "
                    "directly. Resolve the flagged issues first, then re-run the "
                    "Protocol v3 verifier before approving."
                ),
            )

        template.review_status = "document_verified"
        template.reviewed_by = approved_by
        template.reviewed_at = datetime.now(timezone.utc)
        template.updated_by = approved_by

        self.db.commit()
        self.db.refresh(template)

        return template
    
    def get_template_library(
        self,
        practice_area: Optional[str] = None,
        document_type: Optional[str] = None,
        jurisdiction_state: Optional[str] = None,
        category: Optional[str] = None
    ) -> Dict[str, Any]:
        """
        Browse template library (organized by categories)
        
        Args:
            practice_area: Filter by practice area
            document_type: Filter by document type
            jurisdiction_state: Filter by jurisdiction
            category: Filter by category (popular, recent, recommended)
        
        Returns:
            Dict with categorized templates
        """
        base_query = self.db.query(ValidationRule).filter(
            ValidationRule.is_template == True,
            ValidationRule.tenant_id == None,
            ValidationRule.is_active == True,
            ValidationRule.deleted_at == None,
        )
        
        # Apply filters
        if practice_area:
            base_query = base_query.filter(ValidationRule.practice_area == practice_area)
        if document_type:
            base_query = base_query.filter(ValidationRule.document_type == document_type)
        if jurisdiction_state:
            base_query = base_query.filter(ValidationRule.jurisdiction_state == jurisdiction_state)
        
        # Get templates by category
        categories = {}
        
        if not category or category == "popular":
            # Popular: Most inherited templates
            # TODO: Join with inheritance stats
            popular = base_query.order_by(ValidationRule.created_at.desc()).limit(10).all()
            categories["popular"] = [t.to_dict() for t in popular]
        
        if not category or category == "recent":
            # Recent: Recently created templates
            recent = base_query.order_by(ValidationRule.created_at.desc()).limit(10).all()
            categories["recent"] = [t.to_dict() for t in recent]
        
        if not category or category == "recommended":
            # Recommended: Level 1 (Universal) templates
            recommended = base_query.filter(
                ValidationRule.validator_level == 1
            ).order_by(ValidationRule.created_at.desc()).limit(10).all()
            categories["recommended"] = [t.to_dict() for t in recommended]
        
        return {
            "categories": categories,
            "total_templates": base_query.count()
        }


# ============================================================================
# TENANT RULES SERVICE (Law Firms)
# ============================================================================

class TenantRulesService:
    """
    Service for managing tenant-specific rules (Law Firms)
    
    Law firms create and manage their own validation rules.
    """
    
    def __init__(self, db: Session, tenant_id: UUID):
        self.db = db
        self.tenant_id = tenant_id
    
    def list_rules(
        self,
        document_type: Optional[str] = None,
        practice_area: Optional[str] = None,
        is_active: Optional[bool] = True,
        skip: int = 0,
        limit: int = 100
    ) -> Dict[str, Any]:
        """
        List tenant-specific rules
        
        Args:
            document_type: Filter by document type
            practice_area: Filter by practice area
            is_active: Filter by active status
            skip: Pagination offset
            limit: Number of results
        
        Returns:
            Dict with rules, total, skip, limit
        """
        query = self.db.query(ValidationRule).filter(
            ValidationRule.tenant_id == self.tenant_id,
            ValidationRule.is_template == False,
            ValidationRule.deleted_at == None,
        )

        # Apply filters
        if document_type:
            query = query.filter(ValidationRule.document_type == document_type)
        if practice_area:
            query = query.filter(ValidationRule.practice_area == practice_area)
        if is_active is not None:
            query = query.filter(ValidationRule.is_active == is_active)
        
        # Get total count
        total = query.count()
        
        # Apply pagination
        rules = query.order_by(ValidationRule.created_at.desc()).offset(skip).limit(limit).all()
        
        return {
            "rules": [r.to_dict() for r in rules],
            "total": total,
            "skip": skip,
            "limit": limit
        }
    
    def get_rule(self, rule_id: UUID) -> ValidationRule:
        """
        Get tenant-specific rule by ID
        
        Args:
            rule_id: Rule ID
        
        Returns:
            Rule record
        
        Raises:
            HTTPException: If rule not found or access denied
        """
        rule = self.db.query(ValidationRule).filter(
            ValidationRule.id == rule_id,
            ValidationRule.tenant_id == self.tenant_id,
            ValidationRule.is_template == False,
            ValidationRule.deleted_at == None,
        ).first()
        
        if not rule:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Rule {rule_id} not found"
            )
        
        return rule
    
    def create_rule(
        self,
        rule_data: Dict[str, Any],
        created_by: Optional[UUID] = None
    ) -> ValidationRule:
        """
        Create tenant-specific rule
        
        Args:
            rule_data: Rule data
            created_by: User ID who created the rule
        
        Returns:
            Created rule
        """
        rule = ValidationRule(
            tenant_id=self.tenant_id,
            is_template=False,
            rule_name=rule_data.get("rule_name"),
            validator_level=rule_data.get("validator_level"),
            validator_name=rule_data.get("validator_name"),
            validator_type=rule_data.get("validator_type"),
            practice_area=rule_data.get("practice_area"),
            specialization=rule_data.get("specialization"),
            document_type=rule_data.get("document_type"),
            jurisdiction_state=rule_data.get("jurisdiction_state"),
            jurisdiction_county=rule_data.get("jurisdiction_county"),
            jurisdiction_court=rule_data.get("jurisdiction_court"),
            validator_config=rule_data.get("validator_config", {}),
            error_message=rule_data.get("error_message"),
            warning_message=rule_data.get("warning_message"),
            info_message=rule_data.get("info_message"),
            severity=rule_data.get("severity", "error"),
            created_by=created_by,
            # Protocol v3: all new tenant rules enter as needs_review.
            review_status="needs_review",
        )
        
        self.db.add(rule)
        self.db.commit()
        self.db.refresh(rule)
        
        return rule
    
    def update_rule(
        self,
        rule_id: UUID,
        rule_data: Dict[str, Any]
    ) -> ValidationRule:
        """
        Update tenant-specific rule
        
        Args:
            rule_id: Rule ID
            rule_data: Updated rule data
        
        Returns:
            Updated rule
        
        Raises:
            HTTPException: If rule not found
        """
        rule = self.get_rule(rule_id)
        
        # Update fields
        if "rule_name" in rule_data:
            rule.rule_name = rule_data["rule_name"]
        if "validator_config" in rule_data:
            rule.validator_config = rule_data["validator_config"]
            # Protocol v3: any validator_config change invalidates prior approval.
            rule.review_status = "needs_review"
            # Mark as customized if inherited
            if rule.inherited_from_template_id:
                rule.is_customized = True
        if "error_message" in rule_data:
            rule.error_message = rule_data["error_message"]
        if "warning_message" in rule_data:
            rule.warning_message = rule_data["warning_message"]
        if "info_message" in rule_data:
            rule.info_message = rule_data["info_message"]
        if "severity" in rule_data:
            rule.severity = rule_data["severity"]
        if "is_active" in rule_data:
            rule.is_active = rule_data["is_active"]
        if "is_enabled_for_validation" in rule_data:
            rule.is_enabled_for_validation = rule_data["is_enabled_for_validation"]
        
        self.db.commit()
        self.db.refresh(rule)
        
        return rule
    
    def archive_rule(self, rule_id: UUID) -> ValidationRule:
        """
        Archive tenant-specific rule
        
        Args:
            rule_id: Rule ID
        
        Returns:
            Archived rule
        
        Raises:
            HTTPException: If rule not found
        """
        rule = self.get_rule(rule_id)
        
        rule.is_active = False
        rule.archived_at = datetime.now()
        
        self.db.commit()
        self.db.refresh(rule)
        
        return rule

    def approve_rule(
        self,
        rule_id: UUID,
        approved_by: Optional[str] = None,
    ) -> ValidationRule:
        """
        Attorney approval — the ONLY path to review_status='document_verified'.

        Mirrors GlobalRuleTemplatesService.approve_template but scoped to
        this tenant's rules. Cannot approve a flagged_error rule — the
        flagged issue must be resolved and re-verified first.

        Args:
            rule_id: Rule to approve
            approved_by: Clerk user/org ID of the approving attorney

        Returns:
            Approved rule
        """
        from datetime import timezone
        rule = self.get_rule(rule_id)

        if rule.review_status == "flagged_error":
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail=(
                    f"Rule {rule_id} is flagged_error and cannot be approved directly. "
                    "Resolve the flagged issues first, then re-run the Protocol v3 "
                    "verifier before approving."
                ),
            )

        rule.review_status = "document_verified"
        rule.reviewed_by = approved_by
        rule.reviewed_at = datetime.now(timezone.utc)
        rule.updated_by = approved_by

        self.db.commit()
        self.db.refresh(rule)

        return rule

    def list_rules_by_document_type(
        self,
        document_type: str,
        practice_area: Optional[str] = None,
        jurisdiction_state: Optional[str] = None
    ) -> Dict[str, Any]:
        """
        List rules organized by document type
        
        Args:
            document_type: Document type
            practice_area: Filter by practice area
            jurisdiction_state: Filter by jurisdiction
        
        Returns:
            Dict with document_type and rules
        """
        query = self.db.query(ValidationRule).filter(
            ValidationRule.tenant_id == self.tenant_id,
            ValidationRule.is_template == False,
            ValidationRule.document_type == document_type,
            ValidationRule.is_active == True,
            ValidationRule.deleted_at == None,
        )
        
        # Apply filters
        if practice_area:
            query = query.filter(ValidationRule.practice_area == practice_area)
        if jurisdiction_state:
            query = query.filter(ValidationRule.jurisdiction_state == jurisdiction_state)
        
        rules = query.order_by(ValidationRule.validator_level).all()
        
        return {
            "document_type": document_type,
            "rules": [
                {
                    "id": str(r.id),
                    "rule_name": r.rule_name,
                    "validator_name": r.validator_name,
                    "severity": r.severity,
                    "is_active": r.is_active,
                    "is_enabled_for_validation": r.is_enabled_for_validation
                }
                for r in rules
            ],
            "total": len(rules)
        }


# ============================================================================
# TEMPLATE INHERITANCE SERVICE
# ============================================================================

class TemplateInheritanceService:
    """
    Service for template inheritance
    
    Law firms browse global templates and inherit them as tenant-specific rules.
    """
    
    def __init__(self, db: Session, tenant_id: UUID):
        self.db = db
        self.tenant_id = tenant_id
    
    def browse_templates(
        self,
        practice_area: Optional[str] = None,
        document_type: Optional[str] = None,
        jurisdiction_state: Optional[str] = None,
        skip: int = 0,
        limit: int = 100
    ) -> Dict[str, Any]:
        """
        Browse available global templates
        
        Shows which templates are available and which have been inherited.
        
        Args:
            practice_area: Filter by practice area
            document_type: Filter by document type
            jurisdiction_state: Filter by jurisdiction
            skip: Pagination offset
            limit: Number of results
        
        Returns:
            Dict with templates and inheritance status
        """
        # Get all global templates
        query = self.db.query(ValidationRule).filter(
            ValidationRule.is_template == True,
            ValidationRule.tenant_id == None,
            ValidationRule.is_active == True,
            ValidationRule.deleted_at == None,
        )

        # Apply filters
        if practice_area:
            query = query.filter(ValidationRule.practice_area == practice_area)
        if document_type:
            query = query.filter(ValidationRule.document_type == document_type)
        if jurisdiction_state:
            query = query.filter(ValidationRule.jurisdiction_state == jurisdiction_state)
        
        # Get total count
        total = query.count()
        
        # Get templates
        templates = query.order_by(ValidationRule.created_at.desc()).offset(skip).limit(limit).all()
        
        # Check inheritance status for each template
        result = []
        for template in templates:
            # Check if tenant has inherited this template
            inherited_rule = self.db.query(ValidationRule).filter(
                ValidationRule.tenant_id == self.tenant_id,
                ValidationRule.inherited_from_template_id == template.id,
                ValidationRule.deleted_at == None,
            ).first()

            template_dict = template.to_dict()
            template_dict["is_inherited"] = inherited_rule is not None
            template_dict["inherited_rule_id"] = str(inherited_rule.id) if inherited_rule else None
            
            result.append(template_dict)
        
        return {
            "templates": result,
            "total": total,
            "skip": skip,
            "limit": limit
        }
    
    def get_template_detail(self, template_id: UUID) -> Dict[str, Any]:
        """
        Get template detail with inheritance status
        
        Args:
            template_id: Template ID
        
        Returns:
            Template detail with inheritance status
        
        Raises:
            HTTPException: If template not found
        """
        template = self.db.query(ValidationRule).filter(
            ValidationRule.id == template_id,
            ValidationRule.is_template == True,
            ValidationRule.tenant_id == None,
            ValidationRule.deleted_at == None,
        ).first()

        if not template:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Template {template_id} not found"
            )

        # Check if tenant has inherited this template (only active/non-deleted copies)
        inherited_rule = self.db.query(ValidationRule).filter(
            ValidationRule.tenant_id == self.tenant_id,
            ValidationRule.inherited_from_template_id == template.id,
            ValidationRule.deleted_at == None,
        ).first()
        
        template_dict = template.to_dict()
        template_dict["is_inherited"] = inherited_rule is not None
        template_dict["inherited_rule_id"] = str(inherited_rule.id) if inherited_rule else None
        
        return template_dict
    
    def inherit_template(
        self,
        template_id: UUID,
        customize: bool = False,
        customizations: Optional[Dict[str, Any]] = None,
        created_by: Optional[UUID] = None
    ) -> ValidationRule:
        """
        Inherit global template as tenant-specific rule
        
        Args:
            template_id: Template ID to inherit
            customize: Whether to customize the inherited rule
            customizations: Customization data
            created_by: User ID who inherited the template
        
        Returns:
            Created tenant-specific rule
        
        Raises:
            HTTPException: If template not found or already inherited
        """
        # Get template
        template = self.db.query(ValidationRule).filter(
            ValidationRule.id == template_id,
            ValidationRule.is_template == True,
            ValidationRule.tenant_id == None,
            ValidationRule.deleted_at == None,
        ).first()

        if not template:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Template {template_id} not found"
            )

        # Check if already inherited (soft-deleted copies do not count — tenant may re-inherit)
        existing = self.db.query(ValidationRule).filter(
            ValidationRule.tenant_id == self.tenant_id,
            ValidationRule.inherited_from_template_id == template.id,
            ValidationRule.deleted_at == None,
        ).first()
        
        if existing:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Template already inherited by this tenant"
            )
        
        # Create tenant-specific rule from template
        rule = ValidationRule(
            tenant_id=self.tenant_id,
            is_template=False,
            inherited_from_template_id=template.id,
            template_version=template.version,
            is_customized=customize,
            rule_name=customizations.get("rule_name") if customize and customizations else template.template_name,
            validator_level=template.validator_level,
            validator_name=template.validator_name,
            validator_type=template.validator_type,
            practice_area=template.practice_area,
            specialization=template.specialization,
            document_type=template.document_type,
            jurisdiction_state=template.jurisdiction_state,
            jurisdiction_county=template.jurisdiction_county,
            jurisdiction_court=template.jurisdiction_court,
            validator_config=customizations.get("validator_config") if customize and customizations else template.validator_config,
            error_message=customizations.get("error_message") if customize and customizations else template.error_message,
            warning_message=customizations.get("warning_message") if customize and customizations else template.warning_message,
            info_message=template.info_message,
            severity=template.severity,
            created_by=created_by
        )
        
        self.db.add(rule)
        self.db.commit()
        self.db.refresh(rule)
        
        return rule


# ============================================================================
# RULE SELECTION SERVICE (for validation)
# ============================================================================

class RuleSelectionService:
    """
    Service for rule selection during validation
    
    Law firms select which rules to validate against when validating documents.
    """
    
    def __init__(self, db: Session, tenant_id: UUID):
        self.db = db
        self.tenant_id = tenant_id
    
    def select_rules_for_validation(
        self,
        document_type: str,
        practice_area: Optional[str] = None,
        jurisdiction_state: Optional[str] = None
    ) -> Dict[str, Any]:
        """
        Get available rules for validation selection
        
        Args:
            document_type: Document type
            practice_area: Practice area
            jurisdiction_state: Jurisdiction
        
        Returns:
            Dict with available_rules and recommended_rules
        """
        # Get all active tenant rules for this document type
        query = self.db.query(ValidationRule).filter(
            ValidationRule.tenant_id == self.tenant_id,
            ValidationRule.is_template == False,
            ValidationRule.is_active == True,
            ValidationRule.document_type == document_type,
            ValidationRule.deleted_at == None,
        )

        # Apply filters
        if practice_area:
            query = query.filter(
                or_(
                    ValidationRule.practice_area == practice_area,
                    ValidationRule.practice_area == None  # Universal rules
                )
            )
        if jurisdiction_state:
            query = query.filter(
                or_(
                    ValidationRule.jurisdiction_state == jurisdiction_state,
                    ValidationRule.jurisdiction_state == None  # Non-jurisdiction-specific
                )
            )

        rules = query.order_by(ValidationRule.validator_level).all()

        # Format rules for selection
        available_rules = [
            {
                "id": str(r.id),
                "rule_name": r.rule_name,
                "validator_name": r.validator_name,
                "severity": r.severity,
                "description": r.error_message,
                "is_enabled_for_validation": r.is_enabled_for_validation
            }
            for r in rules
        ]
        
        # Recommended rules (Level 1 universal + required rules)
        recommended_rules = [
            {
                "id": str(r.id),
                "rule_name": r.rule_name,
                "reason": "Universal rule" if r.validator_level == 1 else "Required rule"
            }
            for r in rules
            if r.validator_level == 1 or r.is_required
        ]
        
        return {
            "available_rules": available_rules,
            "recommended_rules": recommended_rules
        }
    
    def get_enabled_rules_for_validation(
        self,
        document_type: str,
        practice_area: Optional[str] = None,
        jurisdiction_state: Optional[str] = None
    ) -> List[ValidationRule]:
        """
        Get enabled rules for validation (for actual validation)
        
        Args:
            document_type: Document type
            practice_area: Practice area
            jurisdiction_state: Jurisdiction
        
        Returns:
            List of enabled validation rules
        """
        query = self.db.query(ValidationRule).filter(
            ValidationRule.tenant_id == self.tenant_id,
            ValidationRule.is_template == False,
            ValidationRule.is_active == True,
            ValidationRule.is_enabled_for_validation == True,
            ValidationRule.document_type == document_type,
            ValidationRule.deleted_at == None,
        )
        
        # Apply filters
        if practice_area:
            query = query.filter(
                or_(
                    ValidationRule.practice_area == practice_area,
                    ValidationRule.practice_area == None
                )
            )
        if jurisdiction_state:
            query = query.filter(
                or_(
                    ValidationRule.jurisdiction_state == jurisdiction_state,
                    ValidationRule.jurisdiction_state == None
                )
            )
        
        return query.order_by(ValidationRule.validator_level).all()

