# SaaS Admin Platform - DRAFT Compliance Validator Service Integration Guide

**Date:** December 5, 2025  
**Status:** Integration Guide - Ready for Implementation  
**Target:** SaaS Admin Platform Team  
**Service:** DRAFT Compliance Validator (Phase 3)

---

## 🎯 **PRIMARY MISSION FOR SaaS ADMIN**

Build comprehensive **DRAFT compliance validator service management capabilities** within the SaaS Admin Platform that:
- Manage validation rules library (create, update, archive rules across all 5 levels)
- Monitor compliance violations (from usage analytics - no document content)
- Manage API keys for tenant access to DRAFT
- Provide analytics and reporting on validation usage
- Manage optional template library (supporting service)

**⚠️ CRITICAL:** SaaS Admin is the **PRIMARY MANAGEMENT INTERFACE** for DRAFT service. All validation rules management, compliance monitoring, and template management happens through SaaS Admin. **ZERO-KNOWLEDGE IS MANDATORY** - SaaS Admin never sees document content.

---

## 📚 **ESSENTIAL DOCUMENTATION (READ FIRST)**

### **1. DRAFT Agent Onboarding**
**Location:** `../2025-TrueVow-Draft-Service/AGENT_ONBOARDING.md`

**Read Sections:**
- Section 2: SaaS Admin → DRAFT Service (CRITICAL INTEGRATION)
- All API endpoint specifications
- Request/response examples
- Zero-knowledge architecture requirements

**Key File Path:**
```
../2025-TrueVow-Draft-Service/AGENT_ONBOARDING.md
```

### **2. Client-Side Validation Architecture**
**Location:** `../2025-TrueVow-Draft-Service/docs/DRAFT_CLIENT_SIDE_VALIDATION_ARCHITECTURE.md`

**Read Sections:**
- Architecture Overview (client-side validation)
- Implementation Options (Browser Extension, Desktop App, Word Add-In)
- Validation Rules Sync
- Usage Analytics (optional, no document content)

**Key File Path:**
```
../2025-TrueVow-Draft-Service/docs/DRAFT_CLIENT_SIDE_VALIDATION_ARCHITECTURE.md
```

### **3. Zero-Knowledge Architecture**
**Location:** `../2025-TrueVow-Draft-Service/docs/DRAFT_ZERO_KNOWLEDGE_ARCHITECTURE.md`

**Read Sections:**
- What CAN Be Stored (Templates, Rules, Metadata - not client data)
- What CANNOT Be Stored (Document Content, Client Data)
- Ephemeral Processing (document content processed in memory only)

**Key File Path:**
```
../2025-TrueVow-Draft-Service/docs/DRAFT_ZERO_KNOWLEDGE_ARCHITECTURE.md
```

### **4. Main Technical Documentation**
**Location:** `../2025-TrueVow-Tenant-Application/TrueVow-Complete System-Technical-Documentation.md`

**Read Sections:**
- Part 9: DRAFT Module
- Section 9.6: Integration Points (SaaS Admin → DRAFT Service)

---

## 🏗️ **ARCHITECTURE OVERVIEW**

### **SaaS Admin's Role in DRAFT**

```
┌─────────────────────────────────────────────────────────────┐
│                    DRAFT SERVICE ARCHITECTURE                  │
└─────────────────────────────────────────────────────────────┘

┌──────────────────────┐
│  SaaS Admin Platform │
│  (Management Layer)  │
│                      │
│  - Validation Rules  │
│  - Templates (opt)   │
│  - Compliance        │
│  - Analytics        │
│  - API Key Mgmt     │
└──────────┬──────────┘
           │
           │ API Calls (Bearer Token)
           │
           ↓
┌──────────────────────┐
│  DRAFT Service       │
│  (API Layer)         │
│                      │
│  - /api/v1/admin/*  │
│  - Validation Rules │
│  - Templates (opt)   │
│  - Analytics        │
└──────────────────────┘
           │
           │ Validation Rules Sync (Encrypted)
           │
           ↓
┌──────────────────────┐
│  Attorney's Device   │
│  (Client-Side)       │
│                      │
│  - Validation Engine │
│  - Document (local)  │
│  - Results (local)  │
│  - Never uploaded    │
└──────────────────────┘
```

### **Key Architectural Principles**

1. **SaaS Admin is the Management Interface:**
   - All validation rules management happens through SaaS Admin
   - All template management (optional) happens through SaaS Admin
   - SaaS Admin calls DRAFT service APIs (not direct database access)
   - SaaS Admin provides UI for all DRAFT management tasks

2. **API-Based Integration:**
   - All communication via RESTful API
   - Bearer token authentication
   - No direct database access to DRAFT service

3. **Zero-Knowledge Architecture:**
   - SaaS Admin never sees document content
   - Only validation rules, templates (work product), and analytics (metadata) are managed
   - Document content never flows through SaaS Admin

4. **Client-Side Validation:**
   - Validation rules synced to attorney's device (encrypted)
   - Documents validated locally (never uploaded)
   - Results shown locally (never sent to TrueVow)

---

## 🔗 **INTEGRATION PATTERNS**

### **1. API Client Setup**

**Create DRAFT Service Client in SaaS Admin:**

```python
# app/services/integrations/draft/client.py
import httpx
import logging
from app.core.config import settings

logger = logging.getLogger(__name__)

class DraftServiceClient:
    def __init__(self):
        self.api_base_url = settings.draft_api_url  # e.g., "https://draft.truevow.law/api/v1"
        self.api_key = settings.draft_admin_api_key  # SaaS Admin's API key for DRAFT
        self.client = httpx.AsyncClient(
            timeout=30.0,
            headers={
                "Content-Type": "application/json",
                "Authorization": f"Bearer {self.api_key}",
            }
        )
        logger.info(f"✅ DraftServiceClient initialized with URL: {self.api_base_url}")

    async def list_validation_rules(self, validator_level: str = None, practice_area: str = None, skip: int = 0, limit: int = 100):
        """List validation rules"""
        params = {"skip": skip, "limit": limit}
        if validator_level:
            params["validator_level"] = validator_level
        if practice_area:
            params["practice_area"] = practice_area
        
        response = await self.client.get(
            f"{self.api_base_url}/admin/validation-rules",
            params=params
        )
        response.raise_for_status()
        return response.json()

    async def create_validation_rule(self, data: dict):
        """Create validation rule"""
        response = await self.client.post(
            f"{self.api_base_url}/admin/validation-rules",
            json=data
        )
        response.raise_for_status()
        return response.json()

    # ... (implement all other methods)
```

### **2. Configuration Setup**

**Add to SaaS Admin `app/core/config.py`:**

```python
class Config:
    # ... existing config ...
    
    # DRAFT Service Integration
    draft_api_url: str
    draft_admin_api_key: str
    
    @classmethod
    def from_env(cls):
        return cls(
            # ... existing config ...
            
            # DRAFT Service Integration
            draft_api_url=os.getenv('DRAFT_API_URL', 'https://draft.truevow.law/api/v1'),
            draft_admin_api_key=os.getenv('DRAFT_ADMIN_API_KEY', ''),
        )
```

**Add to `env.example`:**
```bash
# DRAFT Service Integration
DRAFT_API_URL=https://draft.truevow.law/api/v1
DRAFT_ADMIN_API_KEY=your_saas_admin_api_key_here
```

---

## 📋 **SCOPE OF WORK FOR SaaS ADMIN**

### **Phase 1: Core Integration & Validation Rules Management (Weeks 1-3)**

#### **1.1 API Client Implementation**
- [ ] Create `DraftServiceClient` class
- [ ] Implement all API endpoint methods
- [ ] Add error handling and retry logic
- [ ] Add request/response logging
- [ ] Add rate limiting awareness

#### **1.2 Validation Rules Library Management UI**
- [ ] **Validation Rules List Page** (`/admin/draft/validation-rules`)
  - Table showing all validation rules
  - Filters: validator level, practice area, specialization, document type, jurisdiction, status
  - Search functionality
  - Pagination
  - Actions: Create, Edit, Archive, View Details, Duplicate

- [ ] **Validation Rule Detail Page** (`/admin/draft/validation-rules/{id}`)
  - Validation rule information
  - Validator configuration (JSON editor)
  - Error/warning messages
  - Status and priority
  - Hierarchical identifiers display
  - Actions: Edit, Archive, Duplicate, Test

- [ ] **Create Validation Rule Page** (`/admin/draft/validation-rules/create`)
  - Validator level selector (universal, practice_area, specialization, document_type, jurisdiction)
  - Practice area selector (if applicable)
  - Specialization selector (if applicable)
  - Document type selector (if applicable)
  - Jurisdiction selector (if applicable)
  - Validator name
  - Validator type selector (check, warning, blocking, requirement)
  - Validator configuration (JSON editor with schema validation)
  - Error message
  - Warning message
  - Priority
  - Create button

#### **1.3 Validation Rule Templates**
- [ ] **Pre-built Validation Rule Templates**
  - Universal validators (required fields, document completeness)
  - Practice area validators (statute of limitations, HIPAA, etc.)
  - Specialization validators (PIP coverage, expert witnesses, etc.)
  - Document type validators (pre-suit notice, formatting, etc.)
  - Jurisdiction validators (local rules, filing fees, etc.)

- [ ] **Template Library UI**
  - Browse validation rule templates
  - Apply template to create new rule
  - Customize template configuration

---

### **Phase 2: Optional Template Management (Weeks 4-5)**

#### **2.1 Template Library Management UI (Optional Supporting Service)**
- [ ] **Template List Page** (`/admin/draft/templates`)
  - Table showing all templates
  - Filters: practice area, document type, status
  - Search functionality
  - Pagination
  - Actions: Create, Edit, Archive, View Details

- [ ] **Template Detail Page** (`/admin/draft/templates/{id}`)
  - Template information
  - Template content editor (rich text editor)
  - Safe fields configuration
  - Version history
  - Actions: Edit, Archive, Duplicate, Share

- [ ] **Create Template Page** (`/admin/draft/templates/create`)
  - Template name and description
  - Practice area selector
  - Specialization selector (optional)
  - Document type selector
  - Jurisdiction selector (optional)
  - Template content editor (rich text editor with placeholders)
  - Safe fields configuration
  - Create button

---

### **Phase 3: Compliance & Analytics (Weeks 6-7)**

#### **3.1 Compliance Dashboard**
- [ ] **Compliance Overview Page** (`/admin/draft/compliance`)
  - Total validations performed (from analytics - no document content)
  - Validation failure count
  - Validation failure rate
  - Compliance violations by level
  - Recent validation failures
  - Compliance trends chart

- [ ] **Validation Failures List Page** (`/admin/draft/compliance/failures`)
  - Table of validation failures (from analytics - no document content)
  - Filters: validator level, practice area, document type, date range
  - Search functionality
  - Actions: View Details, Resolve

- [ ] **Compliance Report Generator** (`/admin/draft/compliance/reports`)
  - Date range selector
  - Report type selector (summary, detailed, audit)
  - Generate report button
  - Download PDF/CSV export
  - Email report functionality

#### **3.2 Analytics Dashboard**
- [ ] **Validation Usage Analytics** (`/admin/draft/analytics/usage`)
  - Total validations performed
  - Validations by practice area
  - Validations by document type
  - Validations by jurisdiction
  - Validation trends over time
  - Top validation rules used

- [ ] **Validation Failure Analytics** (`/admin/draft/analytics/failures`)
  - Validation failure rate
  - Failures by validator level
  - Failures by practice area
  - Failures by document type
  - Most common validation failures
  - Validation performance metrics

**⚠️ CRITICAL:** All analytics data is metadata only (document type, validation status, missing fields) - NO document content, NO client data.

---

### **Phase 4: API Key Management (Weeks 8-9)**

#### **4.1 API Key Management UI**
- [ ] **API Keys List Page** (`/admin/draft/api-keys`)
  - Table showing all DRAFT API keys
  - Filters: tenant, active status, access level
  - Search functionality
  - Actions: Create, Revoke, View Details

- [ ] **Create API Key Page** (`/admin/draft/api-keys/create`)
  - Tenant selector (dropdown)
  - Access level selector (tenant, external)
  - Expiration date picker
  - Notes field
  - Create button

- [ ] **API Key Detail Page** (`/admin/draft/api-keys/{id}`)
  - API key information (masked)
  - Tenant information
  - Access level
  - Usage statistics (if available)
  - Actions: Revoke, Rotate, View Usage

#### **4.2 API Key Integration with Tenant Management**
- [ ] **Auto-create API key** when tenant subscribes to DRAFT
- [ ] **Auto-revoke API key** when tenant cancels DRAFT subscription
- [ ] **API key rotation** workflow
- [ ] **API key usage tracking** (if DRAFT service provides)

---

## 🔌 **API ENDPOINTS SaaS ADMIN MUST IMPLEMENT**

### **Validation Rules Management (4 endpoints)**

#### **1. List Validation Rules**
```http
GET /api/v1/admin/validation-rules
Authorization: Bearer {draft_admin_api_key}
Query Parameters:
  - validator_level: string (optional: 'universal', 'practice_area', 'specialization', 'document_type', 'jurisdiction')
  - practice_area: string (optional)
  - specialization: string (optional)
  - document_type: string (optional)
  - jurisdiction_state: string (optional)
  - status: string (optional: 'active', 'archived')
  - skip: int (default: 0)
  - limit: int (default: 100)
```

**SaaS Admin Implementation:**
- Call this endpoint to populate validation rules list table
- Implement pagination using `skip` and `limit`
- Implement filters for validator level, practice area, status
- Cache results for performance (optional)

**Response Example:**
```json
{
    "rules": [
        {
            "id": "uuid",
            "validator_level": "universal",
            "validator_name": "required_fields",
            "validator_type": "blocking",
            "validator_config": {
                "required_fields": ["statute_of_limitations", "venue", "jurisdiction"]
            },
            "error_message": "Required fields missing",
            "warning_message": null,
            "priority": 10,
            "status": "active"
        },
        // ... more rules
    ],
    "total": 150,
    "skip": 0,
    "limit": 100
}
```

#### **2. Create Validation Rule**
```http
POST /api/v1/admin/validation-rules
Authorization: Bearer {draft_admin_api_key}
Body:
{
    "validator_level": "practice_area",
    "practice_area": "personal_injury",
    "validator_name": "statute_of_limitations",
    "validator_type": "check",
    "validator_config": {
        "state": "AZ",
        "limitation_years": 2
    },
    "error_message": "Statute of limitations expired",
    "warning_message": "Check statute of limitations for this jurisdiction",
    "priority": 10
}
```

**SaaS Admin Implementation:**
- Call this after admin creates validation rule in UI
- Update UI to show created rule
- Rule becomes active immediately
- Rule synced to attorney devices on next sync

#### **3. Update Validation Rule**
```http
PUT /api/v1/admin/validation-rules/{rule_id}
Authorization: Bearer {draft_admin_api_key}
Body:
{
    "validator_config": {...},
    "error_message": "...",
    "priority": 15
}
```

**SaaS Admin Implementation:**
- Call this after admin updates validation rule in UI
- Update UI to show updated rule
- Rule changes apply to future validation rule syncs

#### **4. Archive Validation Rule**
```http
DELETE /api/v1/admin/validation-rules/{rule_id}
Authorization: Bearer {draft_admin_api_key}
```

**SaaS Admin Implementation:**
- Call this when admin archives validation rule
- Update UI to show archived status
- Rule no longer synced to attorney devices

---

### **Optional Template Management (4 endpoints)**

#### **5. List Templates**
```http
GET /api/v1/admin/templates
Authorization: Bearer {draft_admin_api_key}
Query Parameters:
  - practice_area: string (optional)
  - document_type: string (optional)
  - status: string (optional: 'active', 'archived')
  - skip: int (default: 0)
  - limit: int (default: 100)
```

**SaaS Admin Implementation:**
- Call this to populate template list table
- Implement pagination and filters
- Templates are attorney's work product (not client data)

#### **6. Create Template**
```http
POST /api/v1/admin/templates
Authorization: Bearer {draft_admin_api_key}
Body:
{
    "template_name": "Personal Injury - Car Accident - Demand Letter",
    "practice_area": "personal_injury",
    "specialization": "car_accident",
    "document_type": "demand_letter",
    "jurisdiction_state": "AZ",
    "template_content": "...",
    "safe_fields": ["client_name", "date", "venue"],
    "is_shared": true
}
```

**SaaS Admin Implementation:**
- Call this after admin creates template in UI
- Template stored (attorney's work product, not client data)
- Template available for optional document assembly

#### **7. Update Template**
```http
PUT /api/v1/admin/templates/{template_id}
Authorization: Bearer {draft_admin_api_key}
Body:
{
    "template_content": "...",
    "version": 2
}
```

#### **8. Archive Template**
```http
DELETE /api/v1/admin/templates/{template_id}
Authorization: Bearer {draft_admin_api_key}
```

---

### **Compliance & Analytics (3 endpoints)**

#### **9. Generate Compliance Report**
```http
GET /api/v1/admin/compliance/report
Authorization: Bearer {draft_admin_api_key}
Query Parameters:
  - start_date: date (optional)
  - end_date: date (optional)
  - report_type: string (optional: 'summary', 'detailed', 'audit')
```

**SaaS Admin Implementation:**
- Call this to generate compliance reports
- Display report in UI
- Provide PDF/CSV export functionality
- Schedule recurring reports (daily, weekly, monthly)

**Response Example:**
```json
{
    "report_type": "summary",
    "period": {
        "start_date": "2025-12-01",
        "end_date": "2025-12-31"
    },
    "summary": {
        "total_validations": 1250,
        "validation_failures": 87,
        "failure_rate": 6.96,
        "failures_by_level": {
            "universal": 12,
            "practice_area": 25,
            "specialization": 18,
            "document_type": 20,
            "jurisdiction": 12
        }
    },
    "top_failures": [
        {
            "validator_name": "statute_of_limitations",
            "failure_count": 15,
            "validator_level": "practice_area"
        },
        // ... more failures
    ]
}
```

**⚠️ CRITICAL:** Report contains NO document content, NO client data - only validation metadata.

#### **10. Validation Usage Analytics**
```http
GET /api/v1/admin/analytics/validation-usage
Authorization: Bearer {draft_admin_api_key}
Query Parameters:
  - start_date: date (optional)
  - end_date: date (optional)
  - practice_area: string (optional)
```

**SaaS Admin Implementation:**
- Call this to populate validation usage analytics dashboard
- Display metrics in charts and graphs
- Show trends over time
- Export analytics data

**Response Example:**
```json
{
    "period": {
        "start_date": "2025-12-01",
        "end_date": "2025-12-31"
    },
    "total_validations": 1250,
    "validations_by_practice_area": {
        "personal_injury": 850,
        "family_law": 250,
        "criminal_law": 150
    },
    "validations_by_document_type": {
        "demand_letter": 600,
        "pleading": 400,
        "contract": 250
    },
    "validations_by_jurisdiction": {
        "AZ": 450,
        "CA": 350,
        "FL": 300,
        "TX": 150
    },
    "trends": [
        {
            "date": "2025-12-01",
            "validations": 45
        },
        // ... more trends
    ]
}
```

**⚠️ CRITICAL:** Analytics contains NO document content, NO client data - only metadata (document type, validation status, missing fields).

#### **11. Validation Failure Analytics**
```http
GET /api/v1/admin/analytics/validation-failures
Authorization: Bearer {draft_admin_api_key}
Query Parameters:
  - start_date: date (optional)
  - end_date: date (optional)
  - validator_level: string (optional)
```

**SaaS Admin Implementation:**
- Call this to populate validation failure analytics dashboard
- Display failure rates by validator level
- Identify most common validation failures
- Show trends over time

**Response Example:**
```json
{
    "period": {
        "start_date": "2025-12-01",
        "end_date": "2025-12-31"
    },
    "total_failures": 87,
    "failure_rate": 6.96,
    "failures_by_level": {
        "universal": 12,
        "practice_area": 25,
        "specialization": 18,
        "document_type": 20,
        "jurisdiction": 12
    },
    "most_common_failures": [
        {
            "validator_name": "statute_of_limitations",
            "failure_count": 15,
            "validator_level": "practice_area",
            "missing_fields": ["statute_of_limitations_date"]
        },
        // ... more failures
    ]
}
```

**⚠️ CRITICAL:** Analytics contains NO document content, NO client data - only failure metadata (missing fields list, not field values).

---

### **API Key Management (3 endpoints)**

#### **12. Create API Key for Tenant**
```http
POST /api/v1/admin/api-keys
Authorization: Bearer {draft_admin_api_key}
Body:
{
    "tenant_id": "uuid",
    "access_level": "tenant",
    "expires_at": "2026-12-31T23:59:59Z",
    "notes": "API key for Oakwood Law Firm"
}
```

**SaaS Admin Implementation:**
- Call this when tenant subscribes to DRAFT
- Store API key securely (encrypted)
- Display masked API key in UI
- Provide "Show Full Key" functionality (with security confirmation)

#### **13. List API Keys**
```http
GET /api/v1/admin/api-keys
Authorization: Bearer {draft_admin_api_key}
Query Parameters:
  - tenant_id: uuid (optional)
  - active: boolean (optional)
```

**SaaS Admin Implementation:**
- Call this to populate API keys list table
- Filter by tenant or active status
- Show API key usage statistics (if available)

#### **14. Revoke API Key**
```http
POST /api/v1/admin/api-keys/{api_key_id}/revoke
Authorization: Bearer {draft_admin_api_key}
Body:
{
    "reason": "Tenant subscription cancelled",
    "revoked_by": "admin_user_id"
}
```

**SaaS Admin Implementation:**
- Call this when tenant cancels DRAFT subscription
- Update UI to show revoked status
- Log revocation in audit trail

---

## 🎨 **UI COMPONENTS TO BUILD**

### **1. Validation Rules Management**

#### **Validation Rules List Component**
```typescript
// components/draft/ValidationRulesList.tsx
interface ValidationRulesListProps {
  rules: ValidationRule[];
  onCreate: () => void;
  onEdit: (ruleId: string) => void;
  onArchive: (ruleId: string) => void;
  onViewDetails: (ruleId: string) => void;
  onDuplicate: (ruleId: string) => void;
}

// Features:
// - Table with columns: Name, Level, Practice Area, Type, Status, Priority, Actions
// - Filters: Validator Level, Practice Area, Specialization, Document Type, Jurisdiction, Status
// - Search functionality
// - Pagination
// - Bulk actions (if needed)
// - Export to CSV
```

#### **Validation Rule Detail Component**
```typescript
// components/draft/ValidationRuleDetail.tsx
interface ValidationRuleDetailProps {
  ruleId: string;
}

// Features:
// - Validation rule information display
// - Hierarchical identifiers display (level, practice area, specialization, etc.)
// - Validator configuration editor (JSON editor with schema validation)
// - Error/warning messages editor
// - Status and priority display
// - Test validator button (test against sample document)
// - Actions: Edit, Archive, Duplicate
```

#### **Create Validation Rule Component**
```typescript
// components/draft/CreateValidationRule.tsx
interface CreateValidationRuleProps {
  onSuccess: (rule: ValidationRule) => void;
  onCancel: () => void;
}

// Features:
// - Validator level selector (universal, practice_area, specialization, document_type, jurisdiction)
// - Practice area selector (if applicable) - shows only when level >= practice_area
// - Specialization selector (if applicable) - shows only when level >= specialization
// - Document type selector (if applicable) - shows only when level >= document_type
// - Jurisdiction selector (if applicable) - shows only when level = jurisdiction
// - Validator name input
// - Validator type selector (check, warning, blocking, requirement)
// - Validator configuration editor (JSON editor with schema validation)
// - Error message editor
// - Warning message editor
// - Priority input
// - Create button
// - Form validation
```

#### **Validation Rule Template Library Component**
```typescript
// components/draft/ValidationRuleTemplates.tsx
interface ValidationRuleTemplatesProps {
  onApplyTemplate: (template: ValidationRuleTemplate) => void;
}

// Features:
// - Browse validation rule templates by level
// - Template preview
// - Apply template button (opens Create Validation Rule with template pre-filled)
// - Customize template configuration
```

---

### **2. Optional Template Management**

#### **Template List Component**
```typescript
// components/draft/TemplateList.tsx
interface TemplateListProps {
  templates: Template[];
  onCreate: () => void;
  onEdit: (templateId: string) => void;
  onArchive: (templateId: string) => void;
  onViewDetails: (templateId: string) => void;
}

// Features:
// - Table with columns: Name, Practice Area, Document Type, Status, Actions
// - Filters: Practice Area, Document Type, Status
// - Search functionality
// - Pagination
```

#### **Template Detail Component**
```typescript
// components/draft/TemplateDetail.tsx
interface TemplateDetailProps {
  templateId: string;
}

// Features:
// - Template information display
// - Template content editor (rich text editor)
// - Safe fields configuration
// - Version history
// - Actions: Edit, Archive, Duplicate, Share
```

#### **Create Template Component**
```typescript
// components/draft/CreateTemplate.tsx
interface CreateTemplateProps {
  onSuccess: (template: Template) => void;
  onCancel: () => void;
}

// Features:
// - Template name and description
// - Practice area selector
// - Specialization selector (optional)
// - Document type selector
// - Jurisdiction selector (optional)
// - Template content editor (rich text editor with placeholders)
// - Safe fields configuration
// - Create button
```

---

### **3. Compliance & Analytics**

#### **Compliance Dashboard Component**
```typescript
// components/draft/ComplianceDashboard.tsx
interface ComplianceDashboardProps {}

// Features:
// - Summary cards (total validations, validation failures, failure rate)
// - Validation failures by level chart (bar chart)
// - Validation failures by practice area chart (pie chart)
// - Recent validation failures timeline
// - Compliance trends chart (line chart)
// - All data from analytics (NO document content)
```

#### **Validation Failures List Component**
```typescript
// components/draft/ValidationFailuresList.tsx
interface ValidationFailuresListProps {
  failures: ValidationFailure[];
  onViewDetails: (failureId: string) => void;
  onResolve: (failureId: string) => void;
}

// Features:
// - Table with columns: Document Type, Validator Level, Validator Name, Missing Fields, Date, Actions
// - Filters: Validator Level, Practice Area, Document Type, Date Range
// - Search functionality
// - Pagination
// - All data from analytics (NO document content, only metadata)
```

#### **Compliance Report Generator Component**
```typescript
// components/draft/ComplianceReportGenerator.tsx
interface ComplianceReportGeneratorProps {
  onGenerate: (reportConfig: ReportConfig) => void;
}

// Features:
// - Date range selector
// - Report type selector (summary, detailed, audit)
// - Generate report button
// - Download PDF/CSV export
// - Email report functionality
// - Report preview
```

---

### **4. Analytics Dashboards**

#### **Validation Usage Analytics Component**
```typescript
// components/draft/ValidationUsageAnalytics.tsx
interface ValidationUsageAnalyticsProps {}

// Features:
// - Total validations performed (chart)
// - Validations by practice area (pie chart)
// - Validations by document type (bar chart)
// - Validations by jurisdiction (bar chart)
// - Validation trends over time (line chart)
// - Top validation rules used (table)
// - All data from analytics (NO document content, only metadata)
```

#### **Validation Failure Analytics Component**
```typescript
// components/draft/ValidationFailureAnalytics.tsx
interface ValidationFailureAnalyticsProps {}

// Features:
// - Validation failure rate (gauge chart)
// - Failures by validator level (bar chart)
// - Failures by practice area (pie chart)
// - Failures by document type (bar chart)
// - Most common validation failures (table)
// - Validation performance metrics (table)
// - All data from analytics (NO document content, only metadata)
```

---

## 🔄 **WORKFLOWS TO IMPLEMENT**

### **1. Validation Rule Creation Workflow**

```
1. Admin navigates to Validation Rules Library
   ↓
2. Admin clicks "Create Validation Rule"
   ↓
3. Admin selects validator level (universal, practice_area, etc.)
   ↓
4. Admin fills in validation rule form:
   - Validator name
   - Validator type (check, warning, blocking, requirement)
   - Validator configuration (JSON)
   - Error message
   - Warning message
   - Priority
   ↓
5. Admin clicks "Create"
   ↓
6. SaaS Admin calls DRAFT API: POST /api/v1/admin/validation-rules
   ↓
7. DRAFT service stores validation rule in database
   ↓
8. Validation rule becomes active immediately
   ↓
9. Validation rule synced to attorney devices on next sync
   ↓
10. Validation rule appears in Validation Rules Library
```

### **2. Validation Rule Template Application Workflow**

```
1. Admin navigates to Validation Rule Templates
   ↓
2. Admin browses templates by level
   ↓
3. Admin selects template (e.g., "Statute of Limitations - Personal Injury")
   ↓
4. Admin clicks "Apply Template"
   ↓
5. Create Validation Rule form opens with template pre-filled
   ↓
6. Admin customizes configuration (e.g., state, limitation years)
   ↓
7. Admin clicks "Create"
   ↓
8. Validation rule created (same as workflow 1)
```

### **3. Compliance Report Generation Workflow**

```
1. Admin navigates to Compliance Dashboard
   ↓
2. Admin clicks "Generate Report"
   ↓
3. Admin selects:
   - Date range
   - Report type (summary, detailed, audit)
   ↓
4. Admin clicks "Generate"
   ↓
5. SaaS Admin calls DRAFT API: GET /api/v1/admin/compliance/report
   ↓
6. DRAFT service generates report (from analytics - NO document content)
   ↓
7. Report displayed in UI
   ↓
8. Admin can download PDF/CSV or email report
```

### **4. API Key Creation Workflow**

```
1. Admin navigates to API Keys
   ↓
2. Admin clicks "Create API Key"
   ↓
3. Admin selects tenant from dropdown
   ↓
4. Admin selects access level (tenant, external)
   ↓
5. Admin sets expiration date (optional)
   ↓
6. Admin adds notes (optional)
   ↓
7. Admin clicks "Create"
   ↓
8. SaaS Admin calls DRAFT API: POST /api/v1/admin/api-keys
   ↓
9. DRAFT service creates API key
   ↓
10. API key displayed (masked) in UI
   ↓
11. Admin can copy full key (with security confirmation)
```

---

## 🗄️ **DATABASE TABLES (SaaS Admin Side)**

### **Optional: Cache Tables (For Performance)**

**Note:** These are optional. SaaS Admin can call DRAFT API directly for all data. Cache is only for performance optimization.

#### **1. DRAFT Validation Rules Cache**
```sql
CREATE TABLE saas_admin.draft_validation_rule_cache (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    draft_validation_rule_id UUID NOT NULL UNIQUE,
    validator_level TEXT NOT NULL,
    validator_name TEXT NOT NULL,
    practice_area TEXT,
    specialization TEXT,
    document_type TEXT,
    jurisdiction_state TEXT,
    status TEXT,
    last_synced_at TIMESTAMPTZ DEFAULT now(),
    cached_data JSONB,  -- Full validation rule data from DRAFT API
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_draft_validation_rule_cache_level ON saas_admin.draft_validation_rule_cache(validator_level);
CREATE INDEX idx_draft_validation_rule_cache_practice_area ON saas_admin.draft_validation_rule_cache(practice_area);
CREATE INDEX idx_draft_validation_rule_cache_status ON saas_admin.draft_validation_rule_cache(status);
```

#### **2. DRAFT Template Cache (Optional)**
```sql
CREATE TABLE saas_admin.draft_template_cache (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    draft_template_id UUID NOT NULL UNIQUE,
    template_name TEXT,
    practice_area TEXT,
    document_type TEXT,
    status TEXT,
    last_synced_at TIMESTAMPTZ DEFAULT now(),
    cached_data JSONB,  -- Full template data from DRAFT API
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_draft_template_cache_practice_area ON saas_admin.draft_template_cache(practice_area);
CREATE INDEX idx_draft_template_cache_document_type ON saas_admin.draft_template_cache(document_type);
```

#### **3. DRAFT API Keys (SaaS Admin Storage)**
```sql
CREATE TABLE saas_admin.draft_api_keys (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES saas_admin.tenants(id),
    draft_api_key_id UUID NOT NULL,  -- ID from DRAFT service
    api_key_encrypted TEXT NOT NULL,   -- Encrypted API key
    access_level TEXT NOT NULL,
    expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT now(),
    revoked_at TIMESTAMPTZ,
    revoked_by UUID REFERENCES saas_admin.users(id),
    notes TEXT
);

CREATE INDEX idx_draft_api_keys_tenant ON saas_admin.draft_api_keys(tenant_id);
CREATE INDEX idx_draft_api_keys_active ON saas_admin.draft_api_keys(revoked_at) WHERE revoked_at IS NULL;
```

---

## 🔐 **AUTHENTICATION & SECURITY**

### **API Key Management**

**SaaS Admin's DRAFT API Key:**
- Stored in environment variable: `DRAFT_ADMIN_API_KEY`
- Used for all DRAFT service API calls
- Never exposed in frontend code
- Rotated periodically (recommended: every 90 days)

**Tenant API Keys (Created by SaaS Admin):**
- Created when tenant subscribes to DRAFT
- Stored encrypted in SaaS Admin database
- Displayed (masked) in tenant's DRAFT settings
- Revoked when tenant cancels subscription

### **Security Best Practices**

1. **Never expose API keys in frontend:**
   - All API calls from SaaS Admin backend only
   - Frontend calls SaaS Admin backend, which calls DRAFT service

2. **Encrypt API keys in database:**
   - Use AES-256 encryption
   - Store encryption key in secure key management system

3. **Rate limiting:**
   - Implement rate limiting for DRAFT API calls
   - Handle rate limit errors gracefully

4. **Error handling:**
   - Handle DRAFT service downtime gracefully
   - Show user-friendly error messages
   - Log all API errors for debugging

5. **Zero-knowledge compliance:**
   - Never request document content from DRAFT service
   - Only request validation rules, templates (work product), analytics (metadata)
   - Never display document content in UI

---

## 🧪 **TESTING REQUIREMENTS**

### **Integration Tests**

#### **1. DRAFT API Client Tests**
- [ ] Test all 14+ API endpoint methods
- [ ] Test error handling (network errors, API errors)
- [ ] Test retry logic
- [ ] Test rate limiting handling
- [ ] Test zero-knowledge compliance (no document content requests)

#### **2. Validation Rules Management Tests**
- [ ] Test validation rule list retrieval
- [ ] Test validation rule creation
- [ ] Test validation rule update
- [ ] Test validation rule archiving
- [ ] Test validation rule template application

#### **3. Optional Template Management Tests**
- [ ] Test template list retrieval
- [ ] Test template creation
- [ ] Test template update
- [ ] Test template archiving

#### **4. Compliance & Analytics Tests**
- [ ] Test compliance report generation
- [ ] Test validation usage analytics
- [ ] Test validation failure analytics
- [ ] Test zero-knowledge compliance (analytics contain no document content)

#### **5. API Key Management Tests**
- [ ] Test API key creation
- [ ] Test API key listing
- [ ] Test API key revocation
- [ ] Test API key encryption/decryption

### **UI Tests**

- [ ] Test all UI components render correctly
- [ ] Test filters and search functionality
- [ ] Test pagination
- [ ] Test form submissions
- [ ] Test error states
- [ ] Test loading states
- [ ] Test zero-knowledge compliance (no document content displayed)

---

## 📊 **SUCCESS METRICS**

### **Phase 1 (Weeks 1-3)**
- [ ] DRAFT API client implemented and tested
- [ ] Validation rules list page functional
- [ ] Validation rule creation workflow functional
- [ ] Validation rule detail page functional
- [ ] Validation rule templates library functional

### **Phase 2 (Weeks 4-5)**
- [ ] Template list page functional (optional)
- [ ] Template creation workflow functional (optional)
- [ ] Template detail page functional (optional)

### **Phase 3 (Weeks 6-7)**
- [ ] Compliance dashboard functional
- [ ] Compliance report generator functional
- [ ] Analytics dashboards functional
- [ ] Zero-knowledge compliance verified (no document content in analytics)

### **Phase 4 (Weeks 8-9)**
- [ ] API key management UI functional
- [ ] Auto-create API key on tenant subscription
- [ ] Auto-revoke API key on tenant cancellation

---

## ⚠️ **CRITICAL WARNINGS**

### **1. Zero-Knowledge Architecture**
- **NEVER** request document content from DRAFT service
- **NEVER** display document content in UI
- **ONLY** request validation rules, templates (work product), analytics (metadata)
- **ALWAYS** verify analytics contain no document content

### **2. No Direct Database Access**
- **NEVER** access DRAFT service database directly
- **ALWAYS** use DRAFT service APIs
- Direct database access violates service boundaries

### **3. API Key Security**
- **NEVER** expose DRAFT API keys in frontend code
- **ALWAYS** encrypt API keys in database
- **ALWAYS** use HTTPS for all API calls

### **4. Error Handling**
- **ALWAYS** handle DRAFT service downtime gracefully
- **ALWAYS** show user-friendly error messages
- **ALWAYS** log API errors for debugging

### **5. Rate Limiting**
- **ALWAYS** respect DRAFT service rate limits
- **ALWAYS** implement retry logic with exponential backoff
- **ALWAYS** handle rate limit errors gracefully

### **6. Compliance Monitoring**
- **ALWAYS** monitor validation failures in real-time
- **ALWAYS** respond to critical validation failures immediately
- **ALWAYS** log all compliance actions
- **ALWAYS** verify analytics contain no document content

---

## 🚀 **QUICK START CHECKLIST**

1. [ ] Read all essential documentation
2. [ ] Set up DRAFT API client in SaaS Admin
3. [ ] Add DRAFT configuration to SaaS Admin config
4. [ ] Implement validation rules list page
5. [ ] Implement validation rule creation workflow
6. [ ] Implement validation rule templates library
7. [ ] Implement compliance dashboard
8. [ ] Implement analytics dashboards
9. [ ] Implement API key management
10. [ ] Write integration tests
11. [ ] Verify zero-knowledge compliance
12. [ ] Deploy to staging
13. [ ] Test with DRAFT service
14. [ ] Deploy to production

---

## 📞 **INTEGRATION SUPPORT**

### **DRAFT Service Team**
- **Repository:** `2025-TrueVow-Draft-Service/`
- **Documentation:** `AGENT_ONBOARDING.md`
- **Client-Side Architecture:** `docs/DRAFT_CLIENT_SIDE_VALIDATION_ARCHITECTURE.md`

### **API Endpoint Base URL**
- **Staging:** `https://draft-staging.truevow.law/api/v1`
- **Production:** `https://draft.truevow.law/api/v1`

### **Authentication**
- **Method:** Bearer token
- **Header:** `Authorization: Bearer {draft_admin_api_key}`
- **API Key:** Provided by DRAFT service team

---

## 📝 **IMPLEMENTATION PRIORITIES**

### **Priority 1 (Must Have - Weeks 1-3)**
1. DRAFT API client implementation
2. Validation rules list page
3. Validation rule creation workflow
4. Validation rule detail page
5. Validation rule templates library

### **Priority 2 (Should Have - Weeks 4-5)**
1. Optional template list page
2. Optional template creation workflow
3. Optional template detail page

### **Priority 3 (Nice to Have - Weeks 6-9)**
1. Compliance dashboard
2. Analytics dashboards
3. API key management UI
4. Custom report builder

---

## 🎯 **KEY INTEGRATION PRINCIPLES**

1. **Zero-Knowledge First:** Never request or display document content
2. **API-Based Integration:** All communication via RESTful API
3. **Validation Rules Focus:** Primary service is validation rules management
4. **Optional Templates:** Template management is supporting service only
5. **Privacy-Preserving Analytics:** Only metadata, no document content

---

**Last Updated:** December 5, 2025  
**Status:** Integration Guide Complete  
**Next Step:** Begin Phase 1 Implementation (API Client & Validation Rules Management)
