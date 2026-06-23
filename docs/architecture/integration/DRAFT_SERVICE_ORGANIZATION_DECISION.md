# DRAFT Service Organization - Final Decision Document

**Date:** December 8, 2025  
**Status:** Architecture Decision Required  
**Based On:** TrueVow Complete System Technical Documentation Analysis

---

## 🎯 **WHAT I LEARNED FROM THE DOCUMENTATION**

### **Key System Architecture Principles:**

1. **Multi-Tenant Isolation** - Each law firm gets complete data isolation
2. **Tenant App** - Python/FastAPI backend serving individual law firms
3. **SaaS Admin Platform** - Separate system for TrueVow internal staff
4. **Zero-Knowledge Architecture** - Documents never leave attorney's device
5. **Service Separation** - SETTLE and CONNECT are separate repositories with centralized databases
6. **Per-Tenant Databases** - Compliance requirement (ABA Rule 1.6)

### **Service Classification from Documentation:**

```
✅ INTAKE - Part of Tenant App (per-tenant, core service)
✅ SETTLE - Separate repository, centralized database, API-based
✅ CONNECT - Separate repository, centralized database, API-based
✅ DRAFT - Separate repository, centralized database, API-based (just created)
```

---

## 📊 **CURRENT STATE ANALYSIS**

### **What We Just Built (Email Attachment Validation):**

**Location: `2025-TrueVow-SaaS-Administration/`**

**Components:**
- ✅ `lib/integrations/email/gmail.ts` - Gmail attachment methods
- ✅ `lib/integrations/email/outlook.ts` - Outlook attachment methods
- ✅ `lib/integrations/draft/client.ts` - DRAFT API client
- ✅ `lib/validation/engine.ts` - Client-side validation engine
- ✅ `components/draft/EmailAttachmentValidator.tsx` - Validator component
- ✅ `app/(dashboard)/draft/email-validations/page.tsx` - History page

**Backend: `2025-TrueVow-Draft-Service/`**
- ✅ `app/services/email_validation.py` - Email validation service
- ✅ `app/api/v1/endpoints/email_validation.py` - API endpoints
- ✅ `app/models/analytics.py` - Enhanced with email fields

---

## ❓ **THE CORE QUESTION**

**Where should DRAFT UI components live?**

### **Option A: Keep in SaaS Admin** ❌ WRONG
**Problem:**
- SaaS Admin is for **internal TrueVow staff**
- Email validation is for **attorney customers**
- Mixing customer features with admin features = bad UX

### **Option B: Move to Tenant App** ✅ CORRECT
**Benefits:**
- Tenant App is the **Customer Portal** for law firms
- Attorneys use email validation for their work
- Consistent with SETTLE/CONNECT pattern
- Clean separation of concerns

---

## 🏗️ **RECOMMENDED ARCHITECTURE**

### **Phase 1: SaaS Admin (Internal Staff Only)**

**Location:** `2025-TrueVow-SaaS-Administration/`

**Keep These (Admin Functions):**
```
app/(dashboard)/admin/draft/
├── validation-rules/          # Manage global rules
├── compliance-reports/        # Monitor all tenants
├── api-keys/                  # Issue tenant API keys
└── analytics/                 # Global analytics dashboard
```

**Remove These (Customer Functions):**
```
❌ components/draft/EmailAttachmentValidator.tsx
❌ app/(dashboard)/draft/email-validations/page.tsx
❌ lib/validation/engine.ts
```

### **Phase 2: Tenant App (Law Firm Customers)**

**Location:** `2025-TrueVow-Tenant-Application/`

**Create New Customer Portal DRAFT Module:**
```
app/services/draft/
├── client.py                  # DRAFT API client (Python)
├── __init__.py

web/draft/                     # Customer-facing UI
├── email-validator.html       # Email attachment validation
├── email-validator.js         # Client-side validation engine
├── validation-history.html    # Validation history
├── validation-history.js
├── download-tools.html        # Download browser ext/desktop app
└── rules-viewer.html          # View validation rules (read-only)
```

**Why `web/` not a React app?**
Based on the documentation, the Tenant App uses:
- **Backend:** Python/FastAPI (`app/`)
- **Frontend:** Simple HTML/JS in `web/` folder
- **No React/Next.js** in Tenant App (only in SaaS Admin)

---

## 🔄 **MIGRATION PLAN**

### **Step 1: Keep Shared Components in DRAFT Service**

**Location:** `2025-TrueVow-Draft-Service/`

**Create Shared Client Library:**
```
client/
├── javascript/
│   └── validation_engine.js   # Core engine (shared)
├── python/
│   └── draft_client.py        # Python client (for Tenant App)
└── typescript/
    └── draft_client.ts        # TypeScript client (for SaaS Admin)
```

### **Step 2: Move Customer Components to Tenant App**

**From:** `2025-TrueVow-SaaS-Administration/`  
**To:** `2025-TrueVow-Tenant-Application/web/draft/`

**Files to Move:**
1. `components/draft/EmailAttachmentValidator.tsx` → Convert to vanilla JS
2. `app/(dashboard)/draft/email-validations/page.tsx` → Convert to HTML/JS
3. `lib/validation/engine.ts` → Already exists in DRAFT service

### **Step 3: Update SaaS Admin (Keep Admin Only)**

**Keep in SaaS Admin:**
```
app/(dashboard)/admin/draft/
├── validation-rules/          # Global rule management
│   ├── page.tsx
│   └── [id]/page.tsx
├── compliance/                # Compliance monitoring
│   ├── page.tsx
│   └── reports/page.tsx
├── api-keys/                  # Tenant API key management
│   └── page.tsx
└── analytics/                 # Global analytics
    └── page.tsx
```

**Admin Features:**
- Create/edit/delete validation rules (affects all tenants)
- Monitor compliance violations (all tenants)
- Issue/revoke tenant API keys
- View global analytics (all tenants)

### **Step 4: Update Tenant App (Add Customer Portal)**

**Add to Tenant App:**
```
web/draft/
├── index.html                 # DRAFT module dashboard
├── email-validator.html       # Email attachment validation
├── validation-history.html    # Validation history (tenant-specific)
├── download-tools.html        # Download client tools
├── rules-viewer.html          # View rules (read-only)
└── js/
    ├── draft-client.js        # API client
    ├── validation-engine.js   # Client-side validation
    └── email-validator.js     # Email validation logic
```

**Customer Features:**
- Validate email attachments (their documents only)
- View validation history (their tenant only)
- Download browser extension/desktop app
- View validation rules (read-only, synced from DRAFT service)

---

## 📋 **DECISION MATRIX**

| Component | SaaS Admin | Tenant App | DRAFT Service |
|-----------|-----------|-----------|---------------|
| **Global Rule Management** | ✅ Admin UI | ❌ | ✅ API |
| **Tenant API Keys** | ✅ Admin UI | ❌ | ✅ API |
| **Global Analytics** | ✅ Admin UI | ❌ | ✅ API |
| **Email Validation UI** | ❌ | ✅ Customer UI | ❌ |
| **Validation History (Tenant)** | ❌ | ✅ Customer UI | ✅ API |
| **Client Tools Download** | ❌ | ✅ Customer UI | ❌ |
| **Rules Viewer (Read-Only)** | ❌ | ✅ Customer UI | ✅ API |
| **Validation Engine (JS)** | ❌ | ✅ Uses | ✅ Hosts |
| **Backend API** | ❌ | ❌ | ✅ Hosts |
| **Database** | ❌ | ❌ | ✅ Hosts |

---

## ✅ **FINAL RECOMMENDATION**

### **1. DRAFT Service Repository** (`2025-TrueVow-Draft-Service/`)

**Role:** Centralized API service + shared client libraries

**Structure:**
```
2025-TrueVow-Draft-Service/
├── app/                       # FastAPI backend
│   ├── api/v1/endpoints/
│   │   ├── validation_rules.py
│   │   ├── email_validation.py
│   │   └── admin.py
│   ├── services/
│   └── models/
├── client/                    # Shared client libraries
│   ├── javascript/
│   │   └── validation_engine.js
│   ├── python/
│   │   └── draft_client.py
│   └── typescript/
│       └── draft_client.ts
└── database/
```

### **2. SaaS Admin** (`2025-TrueVow-SaaS-Administration/`)

**Role:** Internal admin UI only

**Structure:**
```
2025-TrueVow-SaaS-Administration/
├── app/(dashboard)/admin/draft/
│   ├── validation-rules/      # Manage global rules
│   ├── compliance/            # Monitor compliance
│   ├── api-keys/              # Manage tenant keys
│   └── analytics/             # Global analytics
└── lib/integrations/draft/
    └── client.ts              # Admin API client
```

### **3. Tenant App** (`2025-TrueVow-Tenant-Application/`)

**Role:** Customer-facing portal

**Structure:**
```
2025-TrueVow-Tenant-Application/
├── app/services/draft/
│   ├── client.py              # Python API client
│   └── __init__.py
└── web/draft/
    ├── index.html             # DRAFT dashboard
    ├── email-validator.html   # Email validation
    ├── validation-history.html
    ├── download-tools.html
    ├── rules-viewer.html
    └── js/
        ├── draft-client.js
        ├── validation-engine.js  # From DRAFT service
        └── email-validator.js
```

---

## 🚀 **IMPLEMENTATION STEPS**

### **Step 1: Reorganize DRAFT Service** (1 day)
1. Create `client/` directory structure
2. Move `validation_engine.js` to `client/javascript/`
3. Create Python client for Tenant App
4. Update documentation

### **Step 2: Clean Up SaaS Admin** (1 day)
1. Keep only admin features in `app/(dashboard)/admin/draft/`
2. Remove customer-facing components
3. Update navigation to admin-only routes

### **Step 3: Build Tenant App DRAFT Module** (3 days)
1. Create `app/services/draft/client.py`
2. Create `web/draft/` structure
3. Convert React components to vanilla HTML/JS
4. Integrate with Tenant App navigation
5. Test end-to-end flow

### **Step 4: Testing & Documentation** (1 day)
1. Test admin workflow (SaaS Admin)
2. Test customer workflow (Tenant App)
3. Update architecture documentation
4. Update deployment guides

**Total Time:** 6 days

---

## 🎯 **KEY TAKEAWAYS**

1. **SaaS Admin = Internal Staff ONLY** (manage DRAFT service globally)
2. **Tenant App = Customer Portal** (attorneys use DRAFT for their work)
3. **DRAFT Service = API Backend** (serves both SaaS Admin and Tenant App)
4. **Shared Client Libraries** (reuse validation engine across all platforms)
5. **Clear Separation of Concerns** (admin functions vs customer functions)

---

## ❓ **NEXT STEPS - YOUR DECISION**

**Option 1: Proceed with Reorganization** ✅ Recommended
- Move customer components to Tenant App
- Clean up SaaS Admin (admin-only)
- Create shared client libraries

**Option 2: Keep Current Structure** ❌ Not Recommended
- Mixing admin and customer features
- Confusing for users and developers
- Doesn't follow SETTLE/CONNECT pattern

**Option 3: Defer Reorganization**
- Keep building features in SaaS Admin for now
- Plan reorganization for later
- Risk: Technical debt accumulates

---

**What would you like to do?**

A) **Start reorganization now** (I'll move components to Tenant App)  
B) **Keep current structure** (explain why)  
C) **Discuss further** (clarify something first)

---

**Last Updated:** December 8, 2025  
**Status:** Awaiting Decision  
**Prepared By:** AI Development Agent

