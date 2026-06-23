# 🔍 Database Connection Diagnostic Report

**Date:** December 23, 2025  
**Issue:** Cannot connect to Supabase PostgreSQL database  
**Status:** ⚠️ **DNS Resolution Issue (Windows/psycopg2)**

---

## 🎯 PROBLEM SUMMARY

The DRAFT service cannot connect to the Supabase database due to a DNS resolution failure in psycopg2 on Windows.

**Error:**
```
psycopg2.OperationalError: could not translate host name 
"db.flhnyyreaxkmwmexchla.supabase.co" to address: Name or service not known
```

---

## 🔍 DIAGNOSTIC RESULTS

### **✅ What Works:**

1. **Internet Connectivity:** ✅ Working
   ```powershell
   Test-NetConnection google.com -Port 443
   # Result: True
   ```

2. **DNS Resolution (nslookup):** ✅ Working
   ```powershell
   nslookup db.flhnyyreaxkmwmexchla.supabase.co
   # Result: 2600:1f18:2e13:9d38:ac9:a017:cb42:e255 (IPv6)
   ```

3. **Server Startup:** ✅ Working
   - Server runs on port 8003
   - All endpoints accessible
   - API documentation available

4. **Database URL Format:** ✅ Correct
   - Protocol: `postgresql://`
   - Has credentials: Yes
   - Has port: Yes
   - Format: Valid

### **❌ What Doesn't Work:**

1. **Windows Ping:** ❌ Failed
   ```powershell
   ping db.flhnyyreaxkmwmexchla.supabase.co
   # Result: "could not find host"
   ```

2. **psycopg2 Connection:** ❌ Failed
   ```python
   from app.core.database import check_db_connection
   check_db_connection()
   # Result: False (DNS resolution error)
   ```

3. **Test-NetConnection:** ❌ Failed
   ```powershell
   Test-NetConnection db.flhnyyreaxkmwmexchla.supabase.co -Port 5432
   # Result: "Name resolution failed"
   ```

---

## 🔬 ROOT CAUSE ANALYSIS

### **Issue:** psycopg2 DNS Resolution on Windows

**Explanation:**
- `psycopg2` uses its own DNS resolution mechanism (via libpq)
- On Windows, this doesn't always respect Windows DNS settings
- `nslookup` works (uses Windows DNS)
- `ping` fails (uses Windows networking stack)
- `psycopg2` fails (uses libpq DNS resolution)

**This is a known issue:** psycopg2 on Windows sometimes has trouble with DNS resolution, especially for:
- Long hostnames
- Hostnames with multiple subdomains
- IPv6-first DNS responses

---

## 🔧 ATTEMPTED FIXES

### **1. DNS Cache Flush** ✅ Completed
```powershell
ipconfig /flushdns
# Result: Successfully flushed, but didn't resolve issue
```

### **2. Made Database Non-Fatal** ✅ Completed
- Server now starts even without database connection
- Allows testing of non-database endpoints
- Prevents complete service failure

---

## 💡 POSSIBLE SOLUTIONS

### **Solution 1: Use Direct IP Connection** ⚠️ **Not Recommended**

**Pros:**
- Bypasses DNS resolution
- Might work immediately

**Cons:**
- IP addresses can change
- Supabase uses load balancing
- SSL certificate won't match IP
- Not a production solution

**How to test:**
```python
# Get IPv6 address
# 2600:1f18:2e13:9d38:ac9:a017:cb42:e255

# Modify connection string (NOT RECOMMENDED)
postgresql://user:pass@[2600:1f18:2e13:9d38:ac9:a017:cb42:e255]:5432/db
```

---

### **Solution 2: Use Supabase Connection Pooler** ✅ **RECOMMENDED**

**Pros:**
- Designed for external connections
- Better for serverless/edge environments
- May have better DNS resolution
- Port 6543 (transaction mode) or 5432 (session mode)

**How to implement:**
1. Check if `TENANT_APPLICATION_DATABASE_POOLER_URL` exists in `.env.local`
2. If yes, use it instead of direct URL
3. If no, ask user to provision it from Supabase dashboard

**Format:**
```
postgresql://user:pass@db.flhnyyreaxkmwmexchla.supabase.co:6543/postgres
```

---

### **Solution 3: Add to Windows Hosts File** ⚠️ **Temporary Workaround**

**Pros:**
- Forces DNS resolution
- Works for testing

**Cons:**
- Requires admin privileges
- Manual maintenance
- Not portable

**How to implement:**
```powershell
# 1. Get IP address
nslookup db.flhnyyreaxkmwmexchla.supabase.co

# 2. Add to C:\Windows\System32\drivers\etc\hosts (as admin)
# IPv6 format:
2600:1f18:2e13:9d38:ac9:a017:cb42:e255 db.flhnyyreaxkmwmexchla.supabase.co
```

---

### **Solution 4: Use psycopg3 (psycopg)** ✅ **BEST LONG-TERM**

**Pros:**
- Modern PostgreSQL adapter
- Better Windows support
- Better DNS handling
- Async support
- Better performance

**Cons:**
- Requires code changes
- Different API (mostly compatible)
- Need to update SQLAlchemy connection

**How to implement:**
```bash
# 1. Install psycopg (version 3)
pip uninstall psycopg2-binary
pip install psycopg[binary]

# 2. Update database URL in config
# Change: postgresql://... 
# To: postgresql+psycopg://...

# 3. Test connection
```

---

### **Solution 5: Check Firewall/Network Settings** ⚠️ **Worth Checking**

**Possible issues:**
- Corporate firewall blocking Supabase
- VPN interfering with DNS
- Antivirus blocking PostgreSQL connections
- Windows Firewall blocking outbound port 5432

**How to check:**
```powershell
# Check if port 5432 is allowed
Test-NetConnection -ComputerName google.com -Port 5432

# Check firewall rules
Get-NetFirewallRule | Where-Object {$_.DisplayName -like "*postgres*"}

# Temporarily disable firewall (for testing only)
# Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
```

---

## 🎯 RECOMMENDED ACTION PLAN

### **Immediate (Next 10 minutes):**

1. ✅ **Check for Pooler URL**
   - Look in `.env.local` for `TENANT_APPLICATION_DATABASE_POOLER_URL`
   - If exists, update config to use it
   - Test connection

2. ✅ **Test Network/Firewall**
   - Check if corporate firewall is blocking
   - Test from different network (mobile hotspot)
   - Check VPN settings

### **Short-term (Next 1 hour):**

3. ✅ **Try psycopg3**
   - Install `psycopg[binary]`
   - Update connection string
   - Test connection

4. ✅ **Hosts File Workaround**
   - Add entry to hosts file (temporary)
   - Test if DNS is the only issue

### **Long-term (Production):**

5. ✅ **Use Connection Pooler**
   - Always use Supabase pooler for external connections
   - More reliable for Windows environments
   - Better for production

6. ✅ **Migrate to psycopg3**
   - Modern adapter with better Windows support
   - Better async support
   - Future-proof

---

## 📊 CURRENT STATUS

| Component | Status | Notes |
|-----------|--------|-------|
| **Server** | ✅ Running | Port 8003 |
| **API Endpoints** | ✅ Working | Non-DB endpoints |
| **Database Connection** | ❌ Failed | DNS resolution issue |
| **DNS Resolution (nslookup)** | ✅ Working | Can resolve hostname |
| **DNS Resolution (psycopg2)** | ❌ Failed | Can't resolve hostname |
| **Internet** | ✅ Working | General connectivity OK |

---

## 🚀 NEXT STEPS

**Choose ONE of these paths:**

### **Path A: Quick Fix (Hosts File)**
1. Get IP from nslookup
2. Add to hosts file (requires admin)
3. Test connection
4. **Time:** 5 minutes
5. **Risk:** Low (temporary)

### **Path B: Proper Fix (Pooler URL)**
1. Check for pooler URL in `.env.local`
2. Update config to use pooler
3. Test connection
4. **Time:** 10 minutes
5. **Risk:** Low (recommended)

### **Path C: Modern Fix (psycopg3)**
1. Install psycopg3
2. Update connection string
3. Test connection
4. **Time:** 15-20 minutes
5. **Risk:** Medium (code changes)

### **Path D: Network Troubleshooting**
1. Check firewall settings
2. Test from different network
3. Check VPN/proxy settings
4. **Time:** 20-30 minutes
5. **Risk:** Low (diagnostic)

---

## 💬 QUESTIONS FOR USER

1. **Do you have `TENANT_APPLICATION_DATABASE_POOLER_URL` in `.env.local`?**
   - If yes → Use Path B (pooler)
   - If no → Can you get it from Supabase dashboard?

2. **Are you on a corporate network?**
   - If yes → Might be firewall issue (Path D)
   - If no → Likely psycopg2 DNS issue (Path A or C)

3. **Is this for production or development?**
   - Production → Use Path B (pooler)
   - Development → Use Path A (hosts file) for quick fix

4. **Do you have admin privileges?**
   - If yes → Can try Path A (hosts file)
   - If no → Must use Path B or C

---

## 📝 WORKAROUND (Current State)

**Server is running without database:**
- ✅ API endpoints accessible
- ✅ Swagger docs available
- ✅ Health endpoint works
- ❌ Database operations will fail

**This allows:**
- Testing API structure
- Validating security middleware
- Testing non-database endpoints
- Developing/testing frontend integration

**This blocks:**
- CRUD operations on rules
- Validation logging
- Analytics queries
- Template management

---

**Status:** ⚠️ **Server Running, Database Disconnected**  
**Blocker:** DNS resolution in psycopg2 on Windows  
**Recommended:** Try pooler URL or psycopg3

---

*DRAFT Service Agent - Database Diagnostic Complete*

