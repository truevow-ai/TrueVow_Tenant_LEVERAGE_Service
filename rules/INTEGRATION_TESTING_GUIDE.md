# 🧪 DRAFT SERVICE - COMPLETE INTEGRATION TESTING GUIDE

**Date:** December 24, 2025  
**Status:** Ready for Testing  
**Components:** Backend API + SaaS Admin UI + Proxy Layer

---

## 🎯 TESTING OVERVIEW

This guide covers end-to-end testing of the complete DRAFT system:
1. **DRAFT Service** (Backend API - Port 8003)
2. **SaaS Admin Proxy** (Middleware - Port 3000)
3. **SaaS Admin UI** (Frontend Components)

---

## 🏗️ ARCHITECTURE RECAP

```
┌─────────────────┐
│  SaaS Admin UI  │ (React/Next.js - Port 3000)
│  - Templates    │
│  - Analytics    │
│  - Compliance   │
└────────┬────────┘
         │
         ↓ HTTP Requests
┌─────────────────┐
│  Proxy Layer    │ (Next.js API Routes)
│  - Auth Check   │
│  - UUID Valid   │
│  - Module Gate  │
└────────┬────────┘
         │
         ↓ HTTP + X-API-Key
┌─────────────────┐
│  DRAFT Service  │ (FastAPI - Port 8003)
│  - Validation   │
│  - Rules        │
│  - Templates    │
└────────┬────────┘
         │
         ↓
┌─────────────────┐
│  Supabase DB    │ (PostgreSQL Cloud)
│  - draft schema │
└─────────────────┘
```

---

## ⚙️ PRE-TESTING SETUP

### **1. Environment Variables**

**DRAFT Service (`.env.local`):**
```bash
# Database (Supabase Cloud)
TENANT_APPLICATION_DATABASE_POOLER_URL=postgresql://postgres.flhnyyreaxkmwmexchla:Intakely%40786@aws-1-us-east-1.pooler.supabase.com:6543/postgres

# API Keys
SAAS_ADMIN_API_KEY=00bc0cebdb9f61d40cb10e123ac0c51df9801ece89ce0ab4dff3404c0602ddc6
API_KEY_ENCRYPTION_KEY=I07q6ghsE9rIO_Ex5KzYAjaA18TcA2dUe-rDngkHCqk=
RULES_ENCRYPTION_KEY=<your-rules-encryption-key>
```

**SaaS Admin (`.env.local`):**
```bash
# DRAFT Service Connection
DRAFT_SERVICE_URL=http://localhost:8003
DRAFT_SERVICE_API_KEY=00bc0cebdb9f61d40cb10e123ac0c51df9801ece89ce0ab4dff3404c0602ddc6

# Database
SAAS_ADMIN_DATABASE_URL=<your-saas-admin-db-url>

# Clerk Auth
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=<your-clerk-key>
CLERK_SECRET_KEY=<your-clerk-secret>
```

### **2. Start Services**

**Terminal 1 - DRAFT Service:**
```bash
cd C:\Users\yasha\OneDrive\Documents\TrueVow\Cursor\2025-TrueVow-Draft-Service
python -m uvicorn app.main:app --host 0.0.0.0 --port 8003 --reload
```

**Terminal 2 - SaaS Admin:**
```bash
cd C:\Users\yasha\OneDrive\Documents\TrueVow\Cursor\2025-TrueVow-SaaS-Administration
npm run dev
```

### **3. Verify Services Running**

```bash
# Check DRAFT Service
curl http://localhost:8003/health

# Check SaaS Admin
curl http://localhost:3000/api/health
```

---

## 🧪 TESTING LAYERS

### **LAYER 1: DRAFT Service API (Direct)**

**Test Backend Endpoints Directly:**

```bash
# Health Check
curl http://localhost:8003/health

# API Documentation
curl http://localhost:8003/docs

# List Templates (with API key)
curl -X GET http://localhost:8003/api/v1/admin/templates \
  -H "X-API-Key: 00bc0cebdb9f61d40cb10e123ac0c51df9801ece89ce0ab4dff3404c0602ddc6"
```

**Expected Results:**
- ✅ Health endpoint returns `{"status": "healthy", "database": "connected"}`
- ✅ Docs endpoint shows Swagger UI
- ✅ Templates endpoint returns list of templates

---

### **LAYER 2: SaaS Admin Proxy (Middleware)**

**Test Proxy Layer with Auth:**

```bash
# Set variables
TOKEN="your-clerk-auth-token"
TENANT_ID="your-tenant-uuid"

# Test proxy endpoint
curl -X GET "http://localhost:3000/api/v1/tenants/${TENANT_ID}/draft/rules" \
  -H "Authorization: Bearer ${TOKEN}"
```

**Security Tests:**

```bash
# Test 1: Missing Auth (should fail)
curl -X GET "http://localhost:3000/api/v1/tenants/${TENANT_ID}/draft/rules"
# Expected: 401 Unauthorized

# Test 2: Invalid UUID (should fail)
curl -X GET "http://localhost:3000/api/v1/tenants/invalid-uuid/draft/rules" \
  -H "Authorization: Bearer ${TOKEN}"
# Expected: 400 Bad Request

# Test 3: Tenant Not Found (should fail)
curl -X GET "http://localhost:3000/api/v1/tenants/00000000-0000-0000-0000-000000000000/draft/rules" \
  -H "Authorization: Bearer ${TOKEN}"
# Expected: 404 Not Found

# Test 4: Module Disabled (should fail)
# Use tenant without DRAFT module enabled
# Expected: 403 Forbidden
```

---

### **LAYER 3: SaaS Admin UI (Frontend)**

**Manual UI Testing:**

#### **A. Rule Template Manager**
**URL:** `http://localhost:3000/draft/templates`

**Test Cases:**
1. ✅ Page loads without errors
2. ✅ Stats cards display correctly
3. ✅ Template list loads
4. ✅ Search functionality works
5. ✅ Filters work (practice area, document type)
6. ✅ Template cards display metadata
7. ✅ Click template opens detail modal
8. ✅ Duplicate button works
9. ✅ Delete button shows confirmation
10. ✅ Create new template button visible

#### **B. Validation Analytics Dashboard**
**URL:** `http://localhost:3000/draft/analytics`

**Test Cases:**
1. ✅ Page loads without errors
2. ✅ KPI cards display with trend indicators
3. ✅ Practice area chart renders
4. ✅ Document type chart renders
5. ✅ Top failing rules list displays
6. ✅ Severity distribution shows
7. ✅ Tenant usage table loads
8. ✅ Date range picker works
9. ✅ Export button visible
10. ✅ Data updates when date range changes

#### **C. Compliance Reports**
**URL:** `http://localhost:3000/draft/compliance`

**Test Cases:**
1. ✅ Page loads without errors
2. ✅ Compliance score displays
3. ✅ ABA status indicator shows
4. ✅ Stats cards render
5. ✅ Generate report button works
6. ✅ Reports list displays
7. ✅ Download PDF button works
8. ✅ Date range filter works
9. ✅ Recommendations display
10. ✅ Color coding works correctly

#### **D. Template Browser Component**
**URL:** Can be used in any page

**Test Cases:**
1. ✅ Component renders correctly
2. ✅ Search works
3. ✅ Filters work
4. ✅ Template cards display
5. ✅ Click opens detail modal
6. ✅ Inherit button works (if enabled)
7. ✅ Empty state displays when no results
8. ✅ Loading state shows while fetching
9. ✅ Responsive on mobile
10. ✅ Keyboard navigation works

#### **E. Tenant Portal Dashboard**
**URL:** `http://localhost:3000/tenant-portal/draft`

**Test Cases:**
1. ✅ Page loads without errors
2. ✅ Stats cards display
3. ✅ Document list loads
4. ✅ Filter tabs work
5. ✅ Status indicators show correctly
6. ✅ Edit/Download/Delete buttons visible
7. ✅ New document button works
8. ✅ Document details display
9. ✅ Responsive design works
10. ✅ Empty state shows when no documents

---

## 🔄 END-TO-END TESTING SCENARIOS

### **Scenario 1: Create and Use a Template**

**Steps:**
1. Navigate to Template Manager
2. Click "New Template"
3. Fill in template details
4. Save template
5. Verify template appears in list
6. Navigate to Tenant Portal
7. Browse templates
8. Inherit template
9. Verify rule created for tenant
10. Validate document against rule

**Expected Result:** ✅ Template created, inherited, and used successfully

---

### **Scenario 2: Generate Compliance Report**

**Steps:**
1. Navigate to Compliance page
2. Select date range
3. Click "Generate Report"
4. Wait for generation
5. Verify report appears in list
6. Click "Download PDF"
7. Verify PDF downloads
8. Open PDF and check content
9. Verify recommendations displayed
10. Check compliance score

**Expected Result:** ✅ Report generated and downloaded successfully

---

### **Scenario 3: View Analytics**

**Steps:**
1. Navigate to Analytics Dashboard
2. Verify all KPI cards load
3. Change date range
4. Verify data updates
5. Check practice area chart
6. Check document type chart
7. Review top failing rules
8. Check tenant usage table
9. Click export button
10. Verify export works

**Expected Result:** ✅ Analytics display correctly and update with filters

---

## 🐛 TROUBLESHOOTING

### **Issue: "DRAFT service not configured"**

**Solutions:**
1. Check `DRAFT_SERVICE_URL` in SaaS Admin `.env.local`
2. Check `DRAFT_SERVICE_API_KEY` in SaaS Admin `.env.local`
3. Restart SaaS Admin dev server
4. Verify DRAFT service is running on port 8003

---

### **Issue: "Database connection failed"**

**Solutions:**
1. Check `TENANT_APPLICATION_DATABASE_POOLER_URL` in DRAFT `.env.local`
2. Verify Supabase credentials are correct
3. Test connection: `curl http://localhost:8003/health`
4. Check database is accessible
5. Verify `draft` schema exists

---

### **Issue: "Authentication required"**

**Solutions:**
1. Check Clerk is configured in SaaS Admin
2. Verify user is logged in
3. Check Authorization header is present
4. Verify Bearer token is valid
5. Check token hasn't expired

---

### **Issue: "Module not enabled"**

**Solutions:**
1. Check `tenant_settings` table in database
2. Verify `module_draft_enabled = true` for tenant
3. Add setting if missing:
```sql
INSERT INTO tenant_settings (tenant_id, setting_key, setting_value)
VALUES ('your-tenant-id', 'module_draft_enabled', true);
```

---

### **Issue: UI Components Not Loading**

**Solutions:**
1. Check browser console for errors
2. Verify API endpoints are responding
3. Check network tab for failed requests
4. Clear browser cache
5. Restart dev server
6. Check TypeScript compilation errors

---

## ✅ TESTING CHECKLIST

### **Backend (DRAFT Service)**
- [ ] Server starts without errors
- [ ] Health endpoint responds
- [ ] Database connected to Supabase
- [ ] API documentation accessible
- [ ] All 45 endpoints working
- [ ] Authentication working
- [ ] Error handling working
- [ ] Logging working

### **Middleware (Proxy Layer)**
- [ ] All 12 proxy endpoints working
- [ ] Authentication verification working
- [ ] UUID validation working
- [ ] Tenant verification working
- [ ] Module gating working
- [ ] Error handling working
- [ ] Timeout handling working
- [ ] Request size limits working

### **Frontend (UI Components)**
- [ ] All 5 components render without errors
- [ ] Search functionality works
- [ ] Filters work correctly
- [ ] Data loads from API
- [ ] Loading states display
- [ ] Empty states display
- [ ] Error states display
- [ ] Responsive design works
- [ ] Accessibility features work
- [ ] Keyboard navigation works

### **Integration**
- [ ] End-to-end flows work
- [ ] Data flows correctly between layers
- [ ] Error messages propagate correctly
- [ ] Performance is acceptable
- [ ] No memory leaks
- [ ] No console errors
- [ ] Security measures working
- [ ] Audit logging working

---

## 📊 PERFORMANCE BENCHMARKS

**Expected Response Times:**
- Health check: < 100ms
- List templates: < 500ms
- Create rule: < 1s
- Validate content: < 2s
- Generate report: < 10s
- UI page load: < 2s

**Load Testing:**
- Concurrent users: 100+
- Requests per second: 1000+
- Database connections: 20 pool size
- Memory usage: < 512MB
- CPU usage: < 50%

---

## 📝 TEST REPORT TEMPLATE

```
DRAFT SERVICE INTEGRATION TEST REPORT
=====================================

Date: _______________
Tester: _______________
Environment: [ ] Development  [ ] Staging  [ ] Production

BACKEND TESTS:
[ ] DRAFT Service Running          Status: ___  Notes: _______________
[ ] Database Connected             Status: ___  Notes: _______________
[ ] Health Endpoint                Status: ___  Notes: _______________
[ ] API Documentation              Status: ___  Notes: _______________
[ ] Authentication                 Status: ___  Notes: _______________

PROXY TESTS:
[ ] All 12 Endpoints               Status: ___  Notes: _______________
[ ] Authentication Check           Status: ___  Notes: _______________
[ ] UUID Validation                Status: ___  Notes: _______________
[ ] Tenant Verification            Status: ___  Notes: _______________
[ ] Module Gating                  Status: ___  Notes: _______________

UI TESTS:
[ ] Rule Template Manager          Status: ___  Notes: _______________
[ ] Validation Analytics           Status: ___  Notes: _______________
[ ] Compliance Reports             Status: ___  Notes: _______________
[ ] Template Browser               Status: ___  Notes: _______________
[ ] Tenant Portal Dashboard        Status: ___  Notes: _______________

E2E TESTS:
[ ] Create Template Flow           Status: ___  Notes: _______________
[ ] Generate Report Flow           Status: ___  Notes: _______________
[ ] View Analytics Flow            Status: ___  Notes: _______________

PERFORMANCE:
Average Response Time: _____ ms
Peak Memory Usage: _____ MB
CPU Usage: _____ %
Concurrent Users Tested: _____

ISSUES FOUND:
1. ________________________________________________________________
2. ________________________________________________________________
3. ________________________________________________________________

OVERALL STATUS: [ ] PASS  [ ] FAIL  [ ] PARTIAL

SIGN-OFF:
Tester: _______________  Date: _______________
Reviewer: _______________  Date: _______________
```

---

## 🎯 NEXT STEPS AFTER TESTING

### **If Tests Pass:**
1. ✅ Mark components as production-ready
2. ✅ Deploy to staging environment
3. ✅ Conduct user acceptance testing
4. ✅ Performance optimization
5. ✅ Security audit
6. ✅ Deploy to production

### **If Tests Fail:**
1. ❌ Document all failures
2. ❌ Prioritize critical issues
3. ❌ Fix issues
4. ❌ Re-test
5. ❌ Repeat until all tests pass

---

## 📚 RELATED DOCUMENTATION

- **Backend API:** `rules/SUPABASE_CONNECTION_SUCCESS_REPORT.md`
- **Architecture:** `rules/ARCHITECTURE_BREACH_RESOLVED.md`
- **UI Components:** `rules/SAAS_ADMIN_UI_COMPLETE.md`
- **Proxy API:** SaaS Admin `DRAFT_PROXY_QUICK_START.md`
- **Session Summary:** `rules/COMPLETE_SESSION_SUMMARY.md`

---

**Integration Testing Guide Complete**  
**Status:** Ready for Testing  
**Last Updated:** December 24, 2025

