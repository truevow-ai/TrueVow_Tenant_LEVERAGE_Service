# DRAFT Service - Complete Architecture Summary

**Date:** December 8, 2025  
**Status:** Architecture Documentation  
**Purpose:** Understand how DRAFT service integrates across SaaS Admin and Tenant App

---

## 🎯 **ARCHITECTURE OVERVIEW**

### **The Big Picture:**

```
┌─────────────────────────────────────────────────────────────┐
│                    TRUEVOW ECOSYSTEM                          │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│              SaaS Admin Platform                              │
│  (Internal TrueVow Staff Tool)                                │
│  • Tenant management                                         │
│  • Billing & subscriptions                                   │
│  • Integration management                                    │
│  • DRAFT Admin UI ⭐ (Manage DRAFT service globally)         │
└─────────────────────────────────────────────────────────────┘
                              │
                              │ Manages
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    DRAFT Service                              │
│  (Separate Service - API-Based)                               │
│  • Validation Rules API                                       │
│  • Templates API                                              │
│  • Analytics API                                              │
│  • Email Attachment Validation API ⭐ NEW                     │
│  • Client-Side Validation Engine                             │
└─────────────────────────────────────────────────────────────┘
                              ▲
                              │ Used by
                              │
┌─────────────────────────────────────────────────────────────┐
│              Tenant App (Customer Portal)                     │
│  (Law Firm Customer-Facing UI)                                │
│  • Per-tenant container                                      │
│  • Unified customer portal                                   │
│  • DRAFT Customer UI ⭐ (Law firms use DRAFT service)        │
│  • Email Attachment Validation ⭐ NEW                         │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔑 **KEY ARCHITECTURAL PRINCIPLES**

### **1. Separation of Concerns**

**SaaS Admin:**
- ✅ **Role:** Internal TrueVow staff tool
- ✅ **Purpose:** Manage DRAFT service globally
- ✅ **Users:** Admins, customer success, support
- ✅ **Access:** Admin API key (from environment)
- ✅ **Features:**
  - Create/edit/archive validation rules (all tenants)
  - Compliance monitoring (all tenants)
  - Analytics dashboard (all tenants)
  - API key management (issue keys to tenants)
  - Template management (global templates)
  - **NEW:** Email validation analytics (all tenants)

**Tenant App:**
- ✅ **Role:** Customer-facing portal
- ✅ **Purpose:** Law firms use DRAFT service
- ✅ **Users:** Attorneys, paralegals (law firm staff)
- ✅ **Access:** Tenant API key (from `tenant_integrations`)
- ✅ **Features:**
  - View validation rules (read-only, synced from DRAFT service)
  - Download client-side validation tools
  - View validation history (metadata only)
  - Manage custom templates (optional, tenant-specific)
  - View/rotate tenant's own API key
  - **NEW:** Validate email attachments (zero-knowledge)

### **2. Multi-Tenant Container Architecture**

**Each Law Firm = Separate Tenant Container:**
- ✅ **Isolation:** Complete data isolation per tenant
- ✅ **Deployment:** Each tenant can be spun off as separate container/cluster
- ✅ **Database:** Per-tenant database (or shared with RLS)
- ✅ **API Keys:** Tenant-scoped API keys for DRAFT service

**Benefits:**
- ✅ **Scalability:** Scale tenants independently
- ✅ **Security:** Complete tenant isolation
- ✅ **Performance:** Optimize per tenant
- ✅ **Compliance:** Easier to meet regulatory requirements

### **3. API-Based Integration**

**Tenant App → DRAFT Service:**
- ✅ **Direct API calls** (not through SaaS Admin)
- ✅ **Tenant-scoped API keys** (stored in `tenant_integrations`)
- ✅ **Tenant isolation** (each tenant only sees their own data)
- ✅ **Same pattern as SETTLE, CONNECT, INTAKE**

**SaaS Admin → DRAFT Service:**
- ✅ **Admin API calls** (for global management)
- ✅ **Admin API key** (stored in environment variables)
- ✅ **Global access** (can see all tenants' data)

### **4. Zero-Knowledge Architecture**

**Critical Requirements:**
- ✅ **Never request document content** from DRAFT service
- ✅ **Only request metadata** (document type, validation status, missing fields)
- ✅ **Client-side validation** (documents validated locally, never uploaded)
- ✅ **No document storage** in Tenant App or SaaS Admin

**Why:**
- ✅ **Privacy:** Documents never leave attorney's device
- ✅ **Compliance:** Meets HIPAA and State Bar requirements
- ✅ **Security:** Reduces attack surface
- ✅ **Trust:** Attorneys maintain full control of documents

**NEW: Email Attachment Validation (Zero-Knowledge):**
- ✅ Attachment downloaded directly to browser memory (encrypted transfer)
- ✅ Validation rules synced from DRAFT service (encrypted)
- ✅ Validation runs entirely client-side in browser JavaScript
- ✅ Results displayed locally (never sent to server)
- ✅ Only metadata logged (NO CONTENT) - practice area, validation result, error counts
- ✅ Email subject hashed (SHA-256) for privacy

---

## 📊 **DATA FLOW DIAGRAMS**

### **Validation Rules Flow:**

```
┌─────────────────────────────────────────────────────────────┐
│              SaaS Admin (TrueVow Staff)                       │
│                                                               │
│  1. Admin creates validation rule                             │
│  2. Calls DRAFT Service API:                                 │
│     POST /api/v1/admin/validation-rules                      │
│  3. Uses admin API key (from env)                            │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│                    DRAFT Service                              │
│                                                               │
│  1. Stores validation rule in database                        │
│  2. Rule becomes active immediately                           │
│  3. Rule synced to attorney devices on next sync             │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│              Tenant App (Law Firm)                            │
│                                                               │
│  1. Attorney views validation rules                          │
│  2. Calls DRAFT Service API:                                 │
│     GET /api/v1/tenant/validation-rules                      │
│  3. Uses tenant API key (from tenant_integrations)           │
│  4. Displays rules (read-only)                               │
└─────────────────────────────────────────────────────────────┘
```

### **Document Validation Flow:**

```
┌─────────────────────────────────────────────────────────────┐
│              Attorney's Device (Client-Side)                  │
│                                                               │
│  1. Attorney opens document in Word/browser                  │
│  2. Client-side validation tool validates document locally   │
│  3. Validation rules synced from DRAFT service (encrypted)   │
│  4. Results shown locally (never uploaded)                   │
│  5. Metadata sent to DRAFT service (no document content)     │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        │ Metadata Only
                        │ (document type, status, missing fields)
                        ▼
┌─────────────────────────────────────────────────────────────┐
│                    DRAFT Service                              │
│                                                               │
│  1. Receives validation metadata                            │
│  2. Stores metadata in database                              │
│  3. NO document content stored                               │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        │ Metadata Query
                        ▼
┌─────────────────────────────────────────────────────────────┐
│              Tenant App (Law Firm)                            │
│                                                               │
│  1. Attorney views validation history                        │
│  2. Calls DRAFT Service API:                                 │
│     GET /api/v1/tenant/validation-history                    │
│  3. Displays metadata (document type, status, missing fields)│
│  4. NO document content displayed                            │
└─────────────────────────────────────────────────────────────┘
```

### **NEW: Email Attachment Validation Flow:**

```
┌─────────────────────────────────────────────────────────────┐
│              Attorney's Browser (Client-Side)                 │
│                                                               │
│  1. Attorney receives email with .docx/.pdf attachment       │
│  2. Opens email in Customer Portal inbox                     │
│  3. Clicks "Validate with DRAFT™" button                     │
│  4. Attachment downloaded to browser memory (encrypted)      │
│  5. Validation rules synced from DRAFT service (encrypted)   │
│  6. Validation runs CLIENT-SIDE in JavaScript                │
│  7. Results displayed locally (never uploaded)               │
│  8. Metadata sent to DRAFT service (NO CONTENT)              │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        │ Metadata Only
                        │ (practice area, result, error counts)
                        │ Email subject HASHED (SHA-256)
                        ▼
┌─────────────────────────────────────────────────────────────┐
│                    DRAFT Service                              │
│                                                               │
│  1. Receives validation metadata                            │
│  2. Stores metadata in database (source=email_attachment)    │
│  3. NO document content stored                               │
│  4. NO email body stored                                     │
│  5. Email subject hashed for privacy                         │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        │ Metadata Query
                        ▼
┌─────────────────────────────────────────────────────────────┐
│              Customer Portal (Law Firm)                       │
│                                                               │
│  1. Attorney views email validation history                  │
│  2. Navigate to /draft/email-validations                     │
│  3. Calls DRAFT Service API:                                 │
│     GET /api/v1/email/validation-history                     │
│  4. Displays metadata (sender, date, result, error counts)   │
│  5. NO document content displayed                            │
│  6. NO email body displayed                                  │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔧 **IMPLEMENTATION STATUS**

### **✅ COMPLETED:**

**SaaS Admin:**
- ✅ `app/(dashboard)/admin/draft/` - Admin UI (existing)
- ✅ `lib/integrations/draft/client.ts` - Admin client
- ✅ `lib/integrations/email/gmail.ts` - Enhanced with attachments
- ✅ `lib/integrations/email/outlook.ts` - Enhanced with attachments
- ✅ `lib/validation/engine.ts` - Client-side validation engine
- ✅ `components/draft/EmailAttachmentValidator.tsx` - Email validator component
- ✅ `app/(dashboard)/draft/email-validations/page.tsx` - Email validation history page

**DRAFT Service:**
- ✅ `app/models/analytics.py` - Enhanced with email validation fields
- ✅ `app/services/email_validation.py` - Email validation service
- ✅ `app/api/v1/endpoints/email_validation.py` - Email validation endpoints
- ✅ `database/migrations/004_add_email_validation_fields.py` - Database migration

### **🔄 IN PROGRESS:**

**Tenant App:**
- ⏳ Create `app/(portal)/draft/` - Customer UI module
- ⏳ Create `app/services/integrations/draft/client.ts` - Tenant client
- ⏳ Follow same pattern as SETTLE, CONNECT modules

---

## 📋 **BEST PRACTICES**

### **1. Zero-Knowledge Compliance**

**✅ DO:**
- ✅ Only request metadata (document type, validation status, missing fields)
- ✅ Client-side validation (documents validated locally)
- ✅ Store only validation results (metadata)
- ✅ Never request document content
- ✅ Hash sensitive data (email subjects) for privacy

**❌ DON'T:**
- ❌ Request document content from DRAFT service
- ❌ Store document content in Tenant App
- ❌ Upload documents to DRAFT service
- ❌ Expose document content in UI
- ❌ Store raw email subjects (always hash)

### **2. Tenant Isolation**

**✅ DO:**
- ✅ Always use tenant-scoped API keys
- ✅ Always filter data by tenant_id
- ✅ Enforce RLS policies
- ✅ Validate tenant_id in all API calls

**❌ DON'T:**
- ❌ Share data between tenants
- ❌ Use admin API keys in Tenant App
- ❌ Bypass tenant isolation
- ❌ Expose other tenants' data

### **3. API Key Security**

**✅ DO:**
- ✅ Encrypt API keys in database
- ✅ Decrypt API keys server-side only
- ✅ Rotate API keys regularly
- ✅ Revoke compromised keys immediately

**❌ DON'T:**
- ❌ Expose API keys in frontend
- ❌ Store API keys in plain text
- ❌ Share API keys between tenants
- ❌ Log API keys in error messages

### **4. Error Handling**

**✅ DO:**
- ✅ Handle API errors gracefully
- ✅ Show user-friendly error messages
- ✅ Log errors for debugging
- ✅ Retry failed requests (with backoff)

**❌ DON'T:**
- ❌ Expose internal error details
- ❌ Crash on API failures
- ❌ Ignore error responses
- ❌ Show stack traces to users

### **5. Caching Strategy**

**✅ DO:**
- ✅ Cache validation rules (optional, for performance)
- ✅ Cache client tools download links
- ✅ Use cache invalidation on updates
- ✅ Set appropriate TTL

**❌ DON'T:**
- ❌ Cache sensitive data
- ❌ Cache without expiration
- ❌ Cache validation history (always fresh)
- ❌ Cache API keys

---

## 🎯 **IMPLEMENTATION CHECKLIST**

### **Phase 1: Core Integration (Weeks 1-2)**

**Tenant App:**
- [ ] Create DRAFT service client (tenant-scoped)
- [ ] Create DRAFT module dashboard page
- [ ] Create validation rules viewer (read-only)
- [ ] Create client tools download page

**DRAFT Service:**
- [x] Verify tenant-scoped API endpoints exist
- [ ] Document tenant API endpoints
- [ ] Test tenant API key authentication

### **Phase 2: Validation History (Weeks 3-4)**

**Tenant App:**
- [ ] Create validation history page
- [ ] Add filters and search
- [ ] Add export functionality (CSV)

**DRAFT Service:**
- [x] Verify validation history API exists
- [x] Test tenant isolation

### **Phase 3: Email Attachment Validation (Weeks 5-6)** ✅ COMPLETE

**Tenant App (via SaaS Admin):**
- [x] Create EmailAttachmentValidator component
- [x] Create email validation history page
- [x] Integrate with Gmail/Outlook clients
- [x] Implement zero-knowledge validation

**DRAFT Service:**
- [x] Create email validation service
- [x] Create email validation API endpoints
- [x] Add email validation analytics
- [x] Database migration

### **Phase 4: Template Management (Weeks 7-8)**

**Tenant App:**
- [ ] Create template library page
- [ ] Create template detail page
- [ ] Create template creation page (optional)

**DRAFT Service:**
- [ ] Verify template API endpoints exist
- [ ] Test tenant-scoped templates

### **Phase 5: Integration & Testing (Weeks 9-10)**

**Tenant App:**
- [ ] Integrate with main dashboard
- [ ] Add DRAFT service card
- [ ] Add subscription gating
- [ ] End-to-end testing

**SaaS Admin:**
- [x] Test API key issuance
- [x] Test tenant isolation
- [x] Verify zero-knowledge compliance

---

## 📝 **KEY TAKEAWAYS**

1. **SaaS Admin DRAFT UI:** ✅ Already built - includes email validation ⭐
2. **Tenant App DRAFT UI:** ⏳ Needs to be built - new work
3. **API Pattern:** Tenant App calls DRAFT service directly (not through SaaS Admin)
4. **Zero-Knowledge:** Critical requirement - never request document content
5. **Tenant Isolation:** Always use tenant-scoped API keys
6. **Best Practices:** Follow same patterns as SETTLE, CONNECT, INTAKE
7. **Email Validation:** ✅ Complete implementation with zero-knowledge architecture

---

## 🚀 **DEPLOYMENT STEPS**

### **1. DRAFT Service Backend**
```bash
# Navigate to DRAFT service
cd 2025-TrueVow-Draft-Service

# Run database migration
alembic upgrade head

# Verify migration
alembic current

# Start service
uvicorn app.main:app --reload --port 8000
```

### **2. SaaS Admin Frontend**
```bash
# Navigate to SaaS Admin
cd 2025-TrueVow-SaaS-Administration

# Install dependencies (if needed)
npm install

# Update environment variables
# Add to .env.local:
NEXT_PUBLIC_DRAFT_API_URL=http://localhost:8000
NEXT_PUBLIC_DRAFT_API_KEY=your_api_key_here

# Start development server
npm run dev
```

### **3. Test Email Attachment Validation**
1. Send test email with .docx attachment
2. Open Customer Portal (http://localhost:3000)
3. Navigate to email inbox
4. Click "Validate with DRAFT™"
5. Verify results display
6. Check validation history at `/draft/email-validations`

---

**Last Updated:** December 8, 2025  
**Status:** Architecture Documentation + Email Validation Complete ✅  
**Next Steps:** 
1. Deploy DRAFT service with email validation
2. Test end-to-end email attachment validation
3. Begin Tenant App DRAFT module implementation

