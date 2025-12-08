# TrueVow DRAFT™ Service

**Status:** Phase 3 (Future Module)  
**Version:** 1.0.0  
**Last Updated:** December 5, 2025

---

## 🎯 **OVERVIEW**

TrueVow DRAFT™ is a **document assembly service** that assembles initial drafts of legal documents (demand letters, pleadings, contracts) from attorney-configured templates and data inputs. The service includes **hierarchical compliance validators** to ensure Bar compliance and prevent malpractice.

**Key Features:**
- ✅ Document assembly from attorney-provided templates
- ✅ 5-level hierarchical compliance validators
- ✅ Practice area, specialization, document type, and jurisdiction-specific validation
- ✅ Mandatory watermark and signature block lock-out
- ✅ Attorney review and certification workflow

---

## 📋 **SERVICE ARCHITECTURE**

### **Separate Service Model**

DRAFT is a **separate service** (not part of Tenant App):
- **Repository:** `2025-TrueVow-Draft-Service/` (this repository)
- **Database:** Centralized database (shared across all tenants)
- **Access:** API-based (tenants call DRAFT service via API)
- **Deployment:** Shared service (one container), not per-tenant

**Why Separate:**
- Centralized template library (shared across all tenants)
- Centralized validator rules (easier to maintain and update)
- Different access patterns than tenant-specific Intake
- SaaS Admin manages centrally, not per-tenant

---

## 🏗️ **REPOSITORY STRUCTURE**

```
2025-TrueVow-Draft-Service/
├── app/
│   ├── api/v1/
│   │   ├── endpoints/
│   │   │   ├── documents.py      # Document generation endpoints
│   │   │   ├── templates.py      # Template management endpoints
│   │   │   └── validation.py    # Validation endpoints
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

1. **Level 1: Universal Validators** (ALL documents)
   - Mandatory "DRAFT ONLY" watermark
   - Signature block lock-out
   - Attorney review requirement
   - Template safety validator

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

**See:** `docs/DRAFT_COMPLIANCE_VALIDATOR_SUMMARY.md` for complete details

---

## 🔗 **INTEGRATION POINTS**

### **Tenant App → DRAFT Service**

**Use Case:** Attorney wants to generate a document during case management

**API Endpoint:** `POST /api/v1/documents/generate`

**Request:**
```json
{
    "template_id": "uuid",
    "practice_area": "personal_injury",
    "specialization": "car_accident",
    "document_type": "demand_letter",
    "jurisdiction_state": "AZ",
    "jurisdiction_county": "Maricopa",
    "data": {
        "client_name": "John Doe",
        "date": "2025-12-05",
        "venue": "Maricopa County Superior Court"
    }
}
```

**Response:**
```json
{
    "document_id": "uuid",
    "content": "...",
    "validation_status": "passed",
    "validation_report": {
        "level_1": {"watermark": true, "signature": true},
        "level_2": {"practice_area": true},
        "level_3": {"specialization": true},
        "level_4": {"document_type": true},
        "level_5": {"jurisdiction": true}
    },
    "warnings": ["Citation audit required", "Local rule placeholder detected"]
}
```

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

