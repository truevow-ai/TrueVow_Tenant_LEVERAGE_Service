# TrueVow DRAFT™ Service - Quick Start Guide

**Last Updated:** December 8, 2025

This guide will help you get the TrueVow DRAFT service running locally in under 10 minutes.

---

## 📋 **Prerequisites**

### **Required:**
- Python 3.11+ ([Download](https://www.python.org/downloads/))
- PostgreSQL 14+ ([Download](https://www.postgresql.org/download/))
- Git

### **Optional:**
- VS Code or PyCharm
- Postman or similar API testing tool

---

## 🚀 **Step 1: Clone Repository**

```bash
cd C:\Users\yasha\OneDrive\Documents\TrueVow\Cursor
cd 2025-TrueVow-Draft-Service
```

---

## 🐍 **Step 2: Setup Python Environment**

### **Windows:**
```powershell
# Create virtual environment
python -m venv venv

# Activate virtual environment
venv\Scripts\activate

# Upgrade pip
python -m pip install --upgrade pip

# Install dependencies
pip install -r requirements.txt
```

### **macOS/Linux:**
```bash
# Create virtual environment
python3 -m venv venv

# Activate virtual environment
source venv/bin/activate

# Upgrade pip
python -m pip install --upgrade pip

# Install dependencies
pip install -r requirements.txt
```

**Expected Output:**
```
Successfully installed fastapi-0.109.2 uvicorn-0.27.1 sqlalchemy-2.0.25 ...
```

---

## 🗄️ **Step 3: Setup Database**

### **Create Database:**

```powershell
# Windows (PowerShell)
# Start PostgreSQL (if not running)
# Then create database

psql -U postgres

# In psql:
CREATE DATABASE truevow_draft;
CREATE SCHEMA draft;
\c truevow_draft
\q
```

### **Run Schema:**

```powershell
# Option 1: Run SQL directly
psql -U postgres -d truevow_draft -f database\schemas\draft.sql

# Option 2: Use Alembic (recommended)
alembic upgrade head
```

**Expected Output:**
```
CREATE SCHEMA
CREATE TABLE
CREATE TABLE
...
Schema version: 1.0.0
```

---

## ⚙️ **Step 4: Configure Environment**

### **Copy Environment Template:**

```powershell
# Windows
copy env.example .env

# macOS/Linux
cp env.example .env
```

### **Edit .env File:**

Open `.env` and update these critical settings:

```env
# Database Settings
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_NAME=truevow_draft
DATABASE_USER=postgres
DATABASE_PASSWORD=your_actual_password_here

# Security (IMPORTANT: Generate secure keys!)
SECRET_KEY=your-secret-key-here
API_KEY_ENCRYPTION_KEY=your-api-key-encryption-key-here
RULES_ENCRYPTION_KEY=your-rules-encryption-key-here
```

### **Generate Encryption Keys:**

```python
# Run this Python script to generate keys
python -c "import secrets; print('SECRET_KEY=' + secrets.token_urlsafe(32))"
python -c "from cryptography.fernet import Fernet; print('API_KEY_ENCRYPTION_KEY=' + Fernet.generate_key().decode())"
python -c "from cryptography.fernet import Fernet; print('RULES_ENCRYPTION_KEY=' + Fernet.generate_key().decode())"
```

**Copy the output to your `.env` file.**

---

## 🏃 **Step 5: Run Application**

### **Start Development Server:**

```bash
# Option 1: Using uvicorn directly
uvicorn app.main:app --reload --host 0.0.0.0 --port 8003

# Option 2: Using Python
python app/main.py
```

**Expected Output:**
```
INFO:     Started server process [12345]
INFO:     Waiting for application startup.
INFO:     Starting TrueVow DRAFT Service...
INFO:     Environment: development
INFO:     ✓ Zero-knowledge compliance validated
INFO:     ✓ Database connection successful
INFO:     TrueVow DRAFT Service started successfully
INFO:     API Documentation: http://0.0.0.0:8003/docs
INFO:     Application startup complete.
INFO:     Uvicorn running on http://0.0.0.0:8003 (Press CTRL+C to quit)
```

---

## 🧪 **Step 6: Test Installation**

### **1. Test Health Endpoint:**

Open browser or use curl:

```bash
# Browser
http://localhost:8003/health

# Or curl
curl http://localhost:8003/health
```

**Expected Response:**
```json
{
  "status": "healthy",
  "service": "TrueVow DRAFT Service",
  "version": "1.0.0",
  "database": "connected",
  "environment": "development",
  "zero_knowledge_compliant": true
}
```

### **2. Access API Documentation:**

Open browser:
```
http://localhost:8003/docs
```

You should see the **Swagger UI** with all API endpoints.

### **3. Run Tests:**

```bash
# Run all tests
pytest -v

# Run with coverage
pytest --cov=app --cov-report=html
```

**Expected Output:**
```
tests/test_config.py::test_get_settings PASSED
tests/test_config.py::test_database_url_computed PASSED
...
========== 8 passed in 2.45s ==========
```

---

## 🔑 **Step 7: Create API Keys (Optional)**

To test the API endpoints, you'll need to create API keys.

### **Option 1: Direct SQL Insert:**

```sql
-- Connect to database
psql -U postgres -d truevow_draft

-- Insert test API key (tenant access)
INSERT INTO draft.api_keys (
    encrypted_key,
    access_level,
    tenant_id,
    description,
    is_active
) VALUES (
    'gAAAAABl...',  -- Encrypt this with your API_KEY_ENCRYPTION_KEY
    'tenant',
    'f47ac10b-58cc-4372-a567-0e02b2c3d479'::uuid,
    'Test API Key',
    true
);
```

### **Option 2: Python Script:**

Create `create_api_key.py`:

```python
from app.core.auth import encrypt_api_key
from app.core.config import get_settings
import secrets

# Generate API key
api_key = secrets.token_urlsafe(32)
print(f"Plain API Key: {api_key}")

# Encrypt it
encrypted = encrypt_api_key(api_key)
print(f"Encrypted API Key: {encrypted}")

# Use this SQL to insert:
print(f"\nINSERT INTO draft.api_keys (encrypted_key, access_level, tenant_id, description, is_active)")
print(f"VALUES ('{encrypted}', 'tenant', 'f47ac10b-58cc-4372-a567-0e02b2c3d479', 'Test Key', true);")
```

Run it:
```bash
python create_api_key.py
```

---

## 📡 **Step 8: Test API Endpoints**

### **Using Swagger UI:**

1. Go to http://localhost:8003/docs
2. Click "Authorize" button
3. Enter: `Bearer your-api-key-here`
4. Try the `/api/v1/validation-rules/sync` endpoint

### **Using Curl:**

```bash
# Test validation rules sync (requires API key)
curl -X POST http://localhost:8003/api/v1/validation-rules/sync \
  -H "Authorization: Bearer your-api-key-here" \
  -H "Content-Type: application/json" \
  -d '{
    "practice_area": "personal_injury",
    "document_type": "demand_letter",
    "jurisdiction_state": "AZ",
    "include_universal": true
  }'
```

**Expected Response:**
```json
{
  "validation_rules": [...],
  "rules_count": 2,
  "rules_version": 1,
  "encrypted": true,
  "encrypted_rules": "gAAAAABl...",
  "sync_metadata": {...}
}
```

---

## 🐛 **Troubleshooting**

### **Issue: Database Connection Failed**

```
✗ Database connection failed
```

**Solution:**
1. Verify PostgreSQL is running
2. Check database credentials in `.env`
3. Verify database exists: `psql -U postgres -l`

### **Issue: Import Errors**

```
ModuleNotFoundError: No module named 'fastapi'
```

**Solution:**
1. Activate virtual environment: `venv\Scripts\activate`
2. Reinstall dependencies: `pip install -r requirements.txt`

### **Issue: Zero-Knowledge Compliance Error**

```
ValueError: Configuration contains forbidden key
```

**Solution:**
- Remove any `DOCUMENT_STORAGE_PATH` or similar keys from `.env`
- Zero-knowledge architecture forbids document storage

### **Issue: Encryption Key Error**

```
cryptography.fernet.InvalidToken
```

**Solution:**
- Regenerate encryption keys using the Python commands above
- Ensure keys are properly formatted in `.env` (no extra spaces)

---

## 📚 **Next Steps**

### **1. Read Documentation:**
- `AGENT_ONBOARDING.md` - Comprehensive onboarding guide
- `IMPLEMENTATION_SUMMARY.md` - What was built
- API Docs: http://localhost:8003/docs

### **2. Create Validation Rules:**
- Use admin endpoints to create validation rules
- See `docs/DRAFT_COMPLIANCE_VALIDATOR_SUMMARY.md` for rule types

### **3. Build Client-Side Validator:**
- Phase 2: Browser extension (Chrome, Firefox, Edge)
- Phase 2: Desktop app (Electron or Python)
- Phase 2: Word Add-In (Office.js)

### **4. Integration:**
- Integrate with Tenant App
- Integrate with SaaS Admin
- Test end-to-end validation flow

---

## 🆘 **Get Help**

### **Documentation:**
- **Onboarding:** `AGENT_ONBOARDING.md`
- **Architecture:** `docs/DRAFT_CLIENT_SIDE_VALIDATION_ARCHITECTURE.md`
- **Zero-Knowledge:** `docs/DRAFT_ZERO_KNOWLEDGE_ARCHITECTURE.md`
- **Compliance:** `docs/DRAFT_LEGAL_COMPLIANCE_FRAMEWORK.md`

### **API Reference:**
- **Swagger UI:** http://localhost:8003/docs
- **ReDoc:** http://localhost:8003/redoc

---

## ✅ **Success Checklist**

- [ ] Python 3.11+ installed
- [ ] PostgreSQL 14+ installed and running
- [ ] Virtual environment activated
- [ ] Dependencies installed (`pip install -r requirements.txt`)
- [ ] Database created (`truevow_draft`)
- [ ] Schema created (`database/schemas/draft.sql`)
- [ ] `.env` file configured
- [ ] Encryption keys generated
- [ ] Server running (`uvicorn app.main:app --reload`)
- [ ] Health endpoint returns "healthy"
- [ ] API documentation accessible
- [ ] Tests passing (`pytest`)

---

## 🎉 **You're Ready!**

Your TrueVow DRAFT service is now running locally. You can:

1. ✅ Create validation rules via admin API
2. ✅ Sync rules to client (encrypted)
3. ✅ Monitor compliance
4. ✅ Track analytics (metadata only)
5. ✅ Build client-side validators

**Happy coding!** 🚀

---

**Last Updated:** December 8, 2025  
**For Support:** See `AGENT_ONBOARDING.md` or `IMPLEMENTATION_SUMMARY.md`

