# TrueVow DRAFT™ Service

**Status:** Phase 3 (Future Module)  
**Version:** 1.0.0  
**Last Updated:** December 5, 2025

---

## 🎯 **OVERVIEW**

TrueVow DRAFT™ is a **compliance validation service** that validates completed legal documents against attorney-configured rules. The service provides **client-side validation** to ensure Bar compliance and prevent malpractice, maintaining **zero-knowledge architecture** where documents never leave the attorney's device.

**Key Features:**
- ✅ Client-side validation (document never uploaded to TrueVow)
- ✅ 5-level hierarchical compliance validators
- ✅ Practice area, specialization, document type, and jurisdiction-specific validation
- ✅ Zero-knowledge architecture (TrueVow never sees document content)
- ✅ Optional template-based document assembly (supporting service)

---

## 📋 **SERVICE ARCHITECTURE**

### **Separate Service Model**

DRAFT is a **separate service** (not part of Tenant App):
- **Repository:** `2025-TrueVow-Draft-Service/` (this repository)
- **Database:** Centralized database (shared across all tenants)
- **Access:** API-based (tenants call DRAFT service via API)
- **Deployment:** Shared service (one container), not per-tenant

**Why Separate:**
- Centralized validator rules library (shared across all tenants)
- Centralized template library (optional supporting service)
- Different access patterns than tenant-specific Intake
- SaaS Admin manages centrally, not per-tenant
- Client-side validation engine (runs on attorney's device)

---

## 🏗️ **REPOSITORY STRUCTURE**

```
2025-TrueVow-Draft-Service/
├── app/
│   ├── api/v1/
│   │   ├── endpoints/
│   │   │   ├── validation.py    # Validation rules sync endpoints
│   │   │   ├── templates.py      # Template management endpoints (optional)
│   │   │   └── analytics.py     # Usage analytics endpoints (optional)
│   │   └── router.py
│   ├── services/
│   │   ├── document_assembler.py # Document assembly logic
│   │   ├── validator.py          # Hierarchical validator engine
│   │   ├── template_manager.py   # Template management
│   │   └── compliance.py         # Compliance monitoring
│   ├── models/
│   │   ├── document.py
│   │   ├── template.py
│   │   └── validation.py
│   └── core/
│       ├── config.py
│       ├── auth.py
│       └── database.py
├── database/
│   ├── schemas/
│   │   └── draft.sql             # Centralized database schema
│   └── migrations/
├── tests/
│   ├── unit/
│   ├── integration/
│   └── compliance/
├── docs/
│   ├── architecture/
│   │   └── DRAFT_ARCHITECTURE.md
│   ├── DRAFT_COMPLIANCE_VALIDATOR_SUMMARY.md
│   └── ...
└── README.md
```

---

## 🛡️ **COMPLIANCE VALIDATORS**

### **5-Level Hierarchical Validator System**

**Client-Side Validation Architecture:**
- ✅ Validation rules synced to attorney's device (encrypted)
- ✅ Document validated locally (never uploaded to TrueVow)
- ✅ Results shown locally (never sent to TrueVow)
- ✅ Zero-knowledge maintained (TrueVow never sees document content)

**Validator Levels:**

1. **Level 1: Universal Validators** (ALL documents)
   - Required fields check (statute of limitations, venue, jurisdiction)
   - Signature block validation
   - Attorney review requirement
   - Document completeness check

2. **Level 2: Practice Area Validators**
   - Personal Injury, Family Law, Criminal Law, Corporate Law, Immigration Law
   - Practice area-specific requirements (statute of limitations, HIPAA, etc.)

3. **Level 3: Specialization Validators**
   - Car Accident, Medical Malpractice, Divorce, Child Custody, etc.
   - Specialization-specific requirements (PIP coverage, expert witnesses, etc.)

4. **Level 4: Document Type Validators**
   - Demand Letters, Pleadings, Contracts, Discovery, Motions
   - Document type-specific requirements (formatting, deadlines, citations)

5. **Level 5: Jurisdiction/Court Validators**
   - State, County, Court-specific rules
   - Local court rules, filing fees, formatting requirements

**See:** `docs/DRAFT_COMPLIANCE_VALIDATOR_SUMMARY.md` and `docs/DRAFT_CLIENT_SIDE_VALIDATION_ARCHITECTURE.md` for complete details

---

## 🔗 **INTEGRATION POINTS**

### **Tenant App → DRAFT Service**

**Use Case:** Attorney wants to validate a completed document

**Primary Flow (Client-Side Validation):**
1. Attorney completes document locally
2. Attorney opens DRAFT validation tool (browser extension or desktop app)
3. Validation rules synced from DRAFT service (encrypted)
4. Document validated locally (never uploaded)
5. Results shown locally (red/yellow/green flags)

**API Endpoint (Validation Rules Sync):** `GET /api/v1/validation-rules`

**Request:**
```json
{
    "practice_area": "personal_injury",
    "specialization": "car_accident",
    "document_type": "demand_letter",
    "jurisdiction_state": "AZ",
    "jurisdiction_county": "Maricopa"
}
```

**Response:**
```json
{
    "validation_rules": [
        {
            "level": 1,
            "validator_name": "statute_of_limitations",
            "validator_config": {"state": "AZ", "limitation_years": 2},
            "error_message": "Statute of limitations check required"
        },
        // ... more rules
    ],
    "encrypted": true
}
```

**Optional Flow (Template Assembly):**
- Attorney selects template
- Attorney manually enters all data (from consultation)
- DRAFT assembles document
- Attorney reviews and edits
- Attorney validates using client-side validation

### **SaaS Admin → DRAFT Service**

**Use Cases:**
- Manage template library
- Manage validator rules
- Monitor compliance violations
- Generate compliance reports

**API Endpoints:**
- `GET /api/v1/admin/templates` - List templates
- `POST /api/v1/admin/templates` - Create template
- `GET /api/v1/admin/validator-rules` - List validator rules
- `POST /api/v1/admin/validator-rules` - Create validator rule
- `GET /api/v1/admin/compliance/report` - Generate compliance report

---

## 📚 **DOCUMENTATION**

### **Essential Documentation**

1. **Compliance Validator Summary**
   - Location: `docs/DRAFT_COMPLIANCE_VALIDATOR_SUMMARY.md`
   - Complete validator architecture and specifications

2. **Architecture Documentation** (To Be Created)
   - Location: `docs/architecture/DRAFT_ARCHITECTURE.md`
   - System architecture, database design, API design

3. **Main Technical Documentation**
   - Location: `../2025-TrueVow-Tenant-Application/TrueVow-Complete System-Technical-Documentation.md`
   - Section: D.5 Phase 3: AI Legal Document Assembly (TrueVow Draft™)

---

## 🚀 **QUICK START**

### **Prerequisites**

- Python 3.11+
- PostgreSQL 14+
- FastAPI
- See `requirements.txt` (to be created)

### **Setup**

```bash
# Clone repository
git clone <repository-url>
cd 2025-TrueVow-Draft-Service

# Install dependencies
pip install -r requirements.txt

# Set up database
# Run migrations from database/migrations/

# Configure environment
cp env.example .env
# Edit .env with your configuration

# Run server
uvicorn app.main:app --reload
```

---

## 📊 **STATUS**

**Current Status:** Phase 3 (Future Module)

**Completed:**
- ✅ Compliance framework defined
- ✅ Hierarchical validator architecture designed
- ✅ Database schema proposed
- ✅ Documentation structure created

**Pending:**
- ⏳ Implementation (Phase 3)
- ⏳ API endpoints
- ⏳ Validator engine implementation
- ⏳ Template management system
- ⏳ Integration with Tenant App

---

## 📝 **LICENSE**

[To be determined]

---

**Last Updated:** December 5, 2025  
**Status:** Repository Structure Created - Ready for Implementation

