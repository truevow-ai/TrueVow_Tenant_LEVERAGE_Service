# DRAFT Service - Authentication & Authorization Architecture

**Date:** January 9, 2026  
**Status:** ✅ **IMPLEMENTED**

---

## 🎯 Overview

The DRAFT service uses **Clerk for authentication** and **application code for authorization**, with **RLS policies as defense-in-depth**.

---

## 🔐 Architecture

### Authentication Flow

```
User → Clerk Login → Application Code Checks Permissions → Database
```

1. **User logs in via Clerk** - Clerk handles all authentication
2. **Application code checks permissions** - Your code determines who can do what
3. **Database operation happens** - If allowed, the operation proceeds
4. **RLS policies** - Serve as a safety net (defense-in-depth)

---

## 🏗️ Implementation

### Database Access

**DRAFT service uses SQLAlchemy** (not Supabase client), so:

- **Direct PostgreSQL connections** via SQLAlchemy
- **Connection pooling** for performance
- **Service role connection** (bypasses RLS by default)
- **Application code handles all authorization**

### RLS Policies

**RLS is enabled on all tables** but serves as **defense-in-depth**:

- Policies exist and are documented
- Application code is the primary access control
- RLS can be activated if needed later

---

## 📋 Tables with RLS

### 1. `draft.validation_rules`

**Access Patterns:**
- **Global templates** (tenant_id = NULL, is_template = TRUE):
  - ✅ All authenticated users can **read**
  - ✅ SaaS Admin can **manage** (create/update/delete)

- **Tenant-specific rules** (tenant_id = UUID, is_template = FALSE):
  - ✅ Team members can **read** their tenant's rules
  - ✅ Team members can **create** rules for their tenant
  - ✅ Team admins/managers can **update** their tenant's rules
  - ✅ Team admins/managers can **delete** their tenant's rules

### 2. `draft.validation_analytics`

**Access Patterns:**
- ✅ Team members can **read** their tenant's analytics
- ✅ Team members can **create** analytics records for their tenant
- ✅ SaaS Admin can **read** all analytics (for compliance reports)
- ❌ Analytics records are **immutable** (no updates/deletes for audit trail)

### 3. `draft.templates`

**Access Patterns:**
- ✅ Team members can **read** their tenant's templates
- ✅ All users can **read** public templates (is_public = TRUE)
- ✅ Team members can **create** templates for their tenant
- ✅ Team admins/managers can **update** their tenant's templates
- ✅ Team admins/managers can **delete** their tenant's templates

---

## 🔧 Helper Functions

### Clerk Integration

```sql
-- Get current Clerk user ID from session
get_current_clerk_user_id() → TEXT

-- Check if user is team member
is_team_member(tenant_id UUID) → BOOLEAN

-- Get user's role
get_current_user_role(tenant_id UUID) → TEXT

-- Check specific role
has_role(tenant_id UUID, role TEXT) → BOOLEAN

-- Check multiple roles
has_any_role(tenant_id UUID, roles TEXT[]) → BOOLEAN

-- Check if admin
is_admin(tenant_id UUID) → BOOLEAN

-- Check if SaaS Admin
is_saas_admin() → BOOLEAN

-- Set Clerk user ID for RLS (called from app code)
set_current_clerk_user_id(clerk_user_id TEXT) → VOID
```

---

## 🛡️ Security Layers

### 1. Clerk Authentication ✅
- User must be logged in via Clerk
- Clerk provides JWT tokens
- Application validates tokens

### 2. Application Authorization ✅
- **Primary access control** in application code
- Checks team membership
- Checks user roles
- Enforces business rules

### 3. RLS Policies ✅
- **Defense-in-depth** safety net
- Policies exist and are documented
- Can be activated if needed
- Currently bypassed by service role

---

## 📝 How It Works

### Current Implementation

1. **User authenticates via Clerk**
2. **Application code checks permissions:**
   ```python
   # Example: Check if user can access tenant data
   if not is_team_member(user_id, tenant_id):
       raise HTTPException(403, "Access denied")
   ```
3. **Database operation proceeds** (using service role connection)
4. **RLS policies exist** but are bypassed (service role)

### Alternative (If Needed)

If you want to activate RLS enforcement:

1. **Set Clerk user ID before queries:**
   ```python
   # Set session variable for RLS
   db.execute(text("SELECT set_current_clerk_user_id(:user_id)"), 
              {"user_id": clerk_user_id})
   ```
2. **RLS policies will enforce access**
3. **More complex but provides database-level enforcement**

---

## ✅ Benefits

### Current Approach (Service Role)

- ✅ **Simpler** - All access control in one place (application code)
- ✅ **More flexible** - Can implement complex business rules
- ✅ **Better performance** - No database-level security overhead
- ✅ **Easier to maintain** - All rules in application code
- ✅ **Single system** - Clerk handles all authentication

### RLS Approach (If Activated)

- ✅ **Database-level enforcement** - Extra security layer
- ✅ **Defense-in-depth** - Multiple security layers
- ⚠️ **More complex** - Need to set session variables
- ⚠️ **Less flexible** - Database-level rules are harder to change

---

## 🎯 Recommended Approach

**Use service role (current implementation):**

1. ✅ Clerk handles authentication
2. ✅ Application code handles authorization
3. ✅ RLS policies exist as safety net
4. ✅ Simple and maintainable

---

## 📊 Summary

| Component | Implementation | Status |
|-----------|---------------|--------|
| Authentication | Clerk | ✅ Complete |
| Authorization | Application Code | ✅ Complete |
| RLS Policies | Created (defense-in-depth) | ✅ Complete |
| Database Access | SQLAlchemy (service role) | ✅ Complete |
| Helper Functions | Created | ✅ Complete |

---

## 🔄 Migration Status

- ✅ RLS migration created: `999_rls_policies_draft_service.sql`
- ✅ Helper functions created
- ✅ Policies created for all tables
- ✅ Documentation created

**Status:** ✅ **READY FOR DEPLOYMENT**

---

**Last Updated:** January 9, 2026
