# ⚠️ DRAFT SERVICE - ENDPOINTS TO BE IMPLEMENTED

**Date:** December 25, 2025  
**Status:** 🔴 **ENDPOINTS NOT IMPLEMENTED YET**  
**Responsibility:** DRAFT Service Agent

---

## 🚨 IMPORTANT NOTE

**The 500 errors from SaaS Admin are EXPECTED!**

The DRAFT microservice returns 404 for endpoints that don't exist yet. This causes the SaaS Admin proxy to return 500 errors.

**This is NORMAL and EXPECTED behavior until endpoints are implemented.**

---

## 📋 ENDPOINTS THAT NEED IMPLEMENTATION

### **Admin Endpoints (SaaS Admin UI)**

#### **1. Template Statistics**
```
GET /api/v1/admin/templates/stats
```
**Purpose:** Get template statistics for dashboard  
**Status:** ❌ NOT IMPLEMENTED  
**Used By:** Rule Template Manager page  
**Returns:**
```json
{
  "total_templates": 0,
  "active_templates": 0,
  "practice_areas": 0,
  "total_rules": 0,
  "most_inherited": "string"
}
```

---

#### **2. List Templates**
```
GET /api/v1/admin/templates
Query Params: ?practice_area=string&document_type=string&severity=string
```
**Purpose:** List all global templates with filters  
**Status:** ❌ NOT IMPLEMENTED  
**Used By:** Rule Template Manager, Template Browser  
**Returns:**
```json
{
  "templates": [
    {
      "id": "uuid",
      "template_name": "string",
      "template_description": "string",
      "rule_name": "string",
      "practice_area": "string",
      "document_type": "string",
      "jurisdiction_state": "string",
      "validator_level": 1,
      "validator_type": "string",
      "validator_config": {},
      "severity": "error",
      "is_active": true,
      "created_at": "datetime",
      "inheritance_count": 0
    }
  ]
}
```

---

#### **3. Create Template**
```
POST /api/v1/admin/templates
```
**Purpose:** Create new global template  
**Status:** ❌ NOT IMPLEMENTED  
**Used By:** Rule Template Manager  
**Request Body:**
```json
{
  "template_name": "string",
  "template_description": "string",
  "rule_name": "string",
  "practice_area": "string",
  "document_type": "string",
  "jurisdiction_state": "string",
  "validator_level": 1,
  "validator_type": "string",
  "validator_config": {},
  "severity": "error",
  "is_active": true
}
```

---

#### **4. Update Template**
```
PUT /api/v1/admin/templates/{template_id}
```
**Purpose:** Update existing template  
**Status:** ❌ NOT IMPLEMENTED  
**Used By:** Rule Template Manager

---

#### **5. Delete Template**
```
DELETE /api/v1/admin/templates/{template_id}
```
**Purpose:** Delete template  
**Status:** ❌ NOT IMPLEMENTED  
**Used By:** Rule Template Manager

---

#### **6. Analytics Data**
```
GET /api/v1/admin/analytics
Query Params: ?from=datetime&to=datetime
```
**Purpose:** Get validation analytics across all tenants  
**Status:** ❌ NOT IMPLEMENTED  
**Used By:** Validation Analytics Dashboard  
**Returns:**
```json
{
  "overview": {
    "total_validations": 0,
    "total_validations_change": 0,
    "success_rate": 0,
    "success_rate_change": 0,
    "active_tenants": 0,
    "active_tenants_change": 0,
    "avg_validation_time": 0,
    "avg_validation_time_change": 0
  },
  "by_practice_area": [],
  "by_document_type": [],
  "by_severity": {
    "errors": 0,
    "warnings": 0,
    "info": 0
  },
  "top_failing_rules": [],
  "tenant_usage": [],
  "timeline": []
}
```

---

#### **7. Compliance Statistics**
```
GET /api/v1/admin/compliance/stats
```
**Purpose:** Get compliance statistics  
**Status:** ❌ NOT IMPLEMENTED  
**Used By:** Compliance Reports page  
**Returns:**
```json
{
  "current_score": 0,
  "score_trend": 0,
  "aba_status": "compliant",
  "last_audit_date": "datetime",
  "next_audit_due": "datetime",
  "total_tenants": 0,
  "compliant_tenants": 0,
  "issues_resolved_30d": 0,
  "avg_resolution_time": 0
}
```

---

#### **8. List Compliance Reports**
```
GET /api/v1/admin/compliance/reports
Query Params: ?from=datetime&to=datetime
```
**Purpose:** List generated compliance reports  
**Status:** ❌ NOT IMPLEMENTED  
**Used By:** Compliance Reports page

---

#### **9. Generate Compliance Report**
```
POST /api/v1/admin/compliance/generate
```
**Purpose:** Generate new compliance report  
**Status:** ❌ NOT IMPLEMENTED  
**Used By:** Compliance Reports page  
**Request Body:**
```json
{
  "start_date": "datetime",
  "end_date": "datetime"
}
```

---

#### **10. Download Compliance Report**
```
GET /api/v1/admin/compliance/reports/{report_id}/download
```
**Purpose:** Download report as PDF  
**Status:** ❌ NOT IMPLEMENTED  
**Used By:** Compliance Reports page  
**Returns:** PDF file

---

### **Tenant Endpoints (Tenant Portal UI)**

#### **11. Tenant Draft Statistics**
```
GET /api/v1/tenant/draft/stats
```
**Purpose:** Get tenant-specific draft statistics  
**Status:** ❌ NOT IMPLEMENTED  
**Used By:** Tenant Portal Dashboard  
**Returns:**
```json
{
  "total_documents": 0,
  "draft": 0,
  "review": 0,
  "finalized": 0,
  "templates_available": 0
}
```

---

#### **12. List Tenant Documents**
```
GET /api/v1/tenant/draft/documents
Query Params: ?status=string
```
**Purpose:** List tenant's draft documents  
**Status:** ❌ NOT IMPLEMENTED  
**Used By:** Tenant Portal Dashboard  
**Returns:**
```json
{
  "documents": [
    {
      "document_id": "uuid",
      "title": "string",
      "template_name": "string",
      "status": "draft",
      "created_at": "datetime",
      "updated_at": "datetime",
      "client_name": "string",
      "case_type": "string"
    }
  ]
}
```

---

## 📊 IMPLEMENTATION PRIORITY

### **High Priority (Required for UI to work):**
1. 🔴 `GET /api/v1/admin/templates/stats`
2. 🔴 `GET /api/v1/admin/templates`
3. 🔴 `POST /api/v1/admin/templates`
4. 🔴 `DELETE /api/v1/admin/templates/{id}`
5. 🔴 `GET /api/v1/admin/analytics`

### **Medium Priority (Nice to have):**
6. 🟡 `PUT /api/v1/admin/templates/{id}`
7. 🟡 `GET /api/v1/admin/compliance/stats`
8. 🟡 `GET /api/v1/admin/compliance/reports`
9. 🟡 `POST /api/v1/admin/compliance/generate`

### **Low Priority (Future features):**
10. 🟢 `GET /api/v1/admin/compliance/reports/{id}/download`
11. 🟢 `GET /api/v1/tenant/draft/stats`
12. 🟢 `GET /api/v1/tenant/draft/documents`

---

## 🔧 IMPLEMENTATION GUIDE

### **Step 1: Create Endpoint Files**

**Location:** `app/api/v1/endpoints/`

Create these files:
- `admin_templates.py` - Template CRUD operations
- `admin_analytics.py` - Analytics endpoints
- `admin_compliance.py` - Compliance endpoints
- `tenant_draft.py` - Tenant draft endpoints

---

### **Step 2: Implement Each Endpoint**

**Example Template:**

```python
# app/api/v1/endpoints/admin_templates.py

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Optional

from app.core.database import get_db
from app.core.auth_v2 import require_admin_access
from app.models.validation_rule_v2 import ValidationRule
from app.schemas.template_schemas import TemplateResponse, TemplateCreate

router = APIRouter()

@router.get("/stats")
async def get_template_stats(
    db: Session = Depends(get_db),
    _: dict = Depends(require_admin_access)
):
    """Get template statistics"""
    total = db.query(ValidationRule).filter(
        ValidationRule.is_template == True
    ).count()
    
    active = db.query(ValidationRule).filter(
        ValidationRule.is_template == True,
        ValidationRule.is_active == True
    ).count()
    
    # ... more stats logic
    
    return {
        "total_templates": total,
        "active_templates": active,
        # ... more stats
    }

@router.get("")
async def list_templates(
    practice_area: Optional[str] = None,
    document_type: Optional[str] = None,
    severity: Optional[str] = None,
    db: Session = Depends(get_db),
    _: dict = Depends(require_admin_access)
):
    """List all templates with optional filters"""
    query = db.query(ValidationRule).filter(
        ValidationRule.is_template == True
    )
    
    if practice_area:
        query = query.filter(ValidationRule.practice_area == practice_area)
    if document_type:
        query = query.filter(ValidationRule.document_type == document_type)
    if severity:
        query = query.filter(ValidationRule.severity == severity)
    
    templates = query.all()
    
    return {"templates": templates}

@router.post("")
async def create_template(
    template: TemplateCreate,
    db: Session = Depends(get_db),
    _: dict = Depends(require_admin_access)
):
    """Create new template"""
    new_template = ValidationRule(
        **template.dict(),
        is_template=True,
        tenant_id=None
    )
    
    db.add(new_template)
    db.commit()
    db.refresh(new_template)
    
    return new_template

@router.delete("/{template_id}")
async def delete_template(
    template_id: str,
    db: Session = Depends(get_db),
    _: dict = Depends(require_admin_access)
):
    """Delete template"""
    template = db.query(ValidationRule).filter(
        ValidationRule.id == template_id,
        ValidationRule.is_template == True
    ).first()
    
    if not template:
        raise HTTPException(status_code=404, detail="Template not found")
    
    db.delete(template)
    db.commit()
    
    return {"message": "Template deleted successfully"}
```

---

### **Step 3: Register Routes**

**File:** `app/api/v1/router.py`

```python
from app.api.v1.endpoints import admin_templates, admin_analytics, admin_compliance

# Add to router
api_router.include_router(
    admin_templates.router,
    prefix="/admin/templates",
    tags=["admin-templates"]
)

api_router.include_router(
    admin_analytics.router,
    prefix="/admin/analytics",
    tags=["admin-analytics"]
)

api_router.include_router(
    admin_compliance.router,
    prefix="/admin/compliance",
    tags=["admin-compliance"]
)
```

---

### **Step 4: Test Endpoints**

```bash
# Test template stats
curl -X GET http://localhost:8003/api/v1/admin/templates/stats \
  -H "X-API-Key: your-api-key"

# Test list templates
curl -X GET http://localhost:8003/api/v1/admin/templates \
  -H "X-API-Key: your-api-key"

# Test create template
curl -X POST http://localhost:8003/api/v1/admin/templates \
  -H "X-API-Key: your-api-key" \
  -H "Content-Type: application/json" \
  -d '{"template_name": "Test", "rule_name": "Test Rule", ...}'
```

---

## ✅ WHEN ENDPOINTS ARE IMPLEMENTED

Once these endpoints are implemented:

1. ✅ SaaS Admin UI will work correctly
2. ✅ No more 500 errors from proxy
3. ✅ Template Manager will load data
4. ✅ Analytics Dashboard will show charts
5. ✅ Compliance Reports will generate
6. ✅ Full end-to-end testing possible

---

## 📝 CURRENT STATUS

```
┌─────────────────────────────────────────┐
│  DRAFT SERVICE - ENDPOINT STATUS        │
├─────────────────────────────────────────┤
│  ✅ Health Endpoint: WORKING            │
│  ✅ API Docs: WORKING                   │
│  ✅ Database: CONNECTED                 │
│  ❌ Admin Endpoints: NOT IMPLEMENTED    │
│  ❌ Tenant Endpoints: NOT IMPLEMENTED   │
│  ❌ Analytics: NOT IMPLEMENTED          │
│  ❌ Compliance: NOT IMPLEMENTED         │
├─────────────────────────────────────────┤
│  Status: BACKEND IMPLEMENTATION NEEDED  │
│  Priority: HIGH                         │
│  Estimated Time: 4-6 hours              │
└─────────────────────────────────────────┘
```

---

## 🎯 NEXT STEPS

1. **Implement High Priority Endpoints** (Templates, Analytics)
2. **Test Each Endpoint** (curl, Postman, Swagger)
3. **Verify SaaS Admin UI Works** (no more 500 errors)
4. **Implement Medium Priority** (Compliance)
5. **Implement Low Priority** (Tenant endpoints)
6. **Full Integration Testing**

---

**Document Created By:** DRAFT Service Agent  
**Date:** December 25, 2025  
**Status:** ⚠️ **ENDPOINTS PENDING IMPLEMENTATION**

🚨 **IMPORTANT: These endpoints MUST be implemented for the UI to work!** 🚨

