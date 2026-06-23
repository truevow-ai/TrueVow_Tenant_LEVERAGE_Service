# DRAFT Service v2.0 - Deployment Guide

**Date:** December 10, 2025  
**Version:** 2.0.0  
**Status:** Ready for Deployment

---

## 📋 **PRE-DEPLOYMENT CHECKLIST**

Before deploying, ensure you have:

- [ ] PostgreSQL 14+ database server
- [ ] Python 3.11+ installed
- [ ] Virtual environment set up
- [ ] Environment variables configured
- [ ] Database connection verified

---

## 🚀 **STEP 1: ENVIRONMENT SETUP**

### **1.1 Create Virtual Environment**

```bash
cd C:\Users\yasha\OneDrive\Documents\TrueVow\Cursor\2025-TrueVow-Draft-Service

# Create virtual environment
python -m venv venv

# Activate (Windows PowerShell)
.\venv\Scripts\Activate.ps1

# Activate (Windows CMD)
.\venv\Scripts\activate.bat

# Activate (Linux/Mac)
source venv/bin/activate
```

### **1.2 Install Dependencies**

```bash
# Install requirements
pip install -r requirements.txt

# Verify installation
pip list
```

### **1.3 Configure Environment Variables**

Create `.env` file in project root:

```bash
# Database
DATABASE_URL=postgresql://draft_user:SecurePassword123@localhost:5432/truevow_draft

# API Configuration
API_HOST=0.0.0.0
API_PORT=8000
API_RELOAD=false

# Security
SECRET_KEY=your-secret-key-here-change-in-production
ENCRYPTION_KEY=your-fernet-encryption-key-here

# CORS (adjust for production)
ALLOWED_ORIGINS=http://localhost:3000,https://admin.truevow.law,https://app.truevow.law

# Logging
LOG_LEVEL=INFO
```

---

## 🗄️ **STEP 2: DATABASE SETUP**

### **2.1 Create Database**

```sql
-- Connect to PostgreSQL as superuser
psql -U postgres

-- Create database
CREATE DATABASE truevow_draft;

-- Create user
CREATE USER draft_user WITH ENCRYPTED PASSWORD 'SecurePassword123';

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE truevow_draft TO draft_user;

-- Exit
\q
```

### **2.2 Run Migrations**

```bash
# Set database URL
export DATABASE_URL="postgresql://draft_user:SecurePassword123@localhost:5432/truevow_draft"

# Initialize Alembic (if not already done)
cd database/migrations
alembic init alembic

# Run migration
alembic upgrade head

# Verify tables created
psql -U draft_user -d truevow_draft -c "\dt draft.*"
```

**Expected Output:**
```
                  List of relations
 Schema |         Name          | Type  |   Owner
--------+-----------------------+-------+------------
 draft  | api_keys              | table | draft_user
 draft  | validation_analytics  | table | draft_user
 draft  | validation_rules      | table | draft_user
```

### **2.3 Verify Schema**

```bash
# Check validation_rules table structure
psql -U draft_user -d truevow_draft -c "\d draft.validation_rules"

# Should show columns:
# - id, tenant_id, is_template, template_name, rule_name
# - inherited_from_template_id, is_customized
# - validator_level, validator_name, validator_config
# - etc.
```

---

## 🔑 **STEP 3: GENERATE API KEYS**

### **3.1 Create Admin API Key (for SaaS Admin)**

Create script `scripts/create_admin_key.py`:

```python
import sys
import os
sys.path.insert(0, os.path.abspath('.'))

from app.core.database import SessionLocal
from app.core.auth_v2 import create_admin_api_key

db = SessionLocal()

raw_key, key_record = create_admin_api_key(
    db=db,
    description="SaaS Admin Master Key - Production",
    expires_in_days=None  # Never expires
)

print("=" * 80)
print("ADMIN API KEY CREATED")
print("=" * 80)
print(f"API Key: {raw_key}")
print(f"Key ID: {key_record.id}")
print(f"Access Level: {key_record.access_level}")
print(f"Created: {key_record.created_at}")
print("=" * 80)
print("IMPORTANT: Save this key securely! It will not be shown again.")
print("Add to SaaS Admin .env file:")
print(f"DRAFT_ADMIN_API_KEY={raw_key}")
print("=" * 80)

db.close()
```

Run:
```bash
python scripts/create_admin_key.py
```

### **3.2 Create Tenant API Keys (for each Law Firm)**

Create script `scripts/create_tenant_key.py`:

```python
import sys
import os
from uuid import UUID
sys.path.insert(0, os.path.abspath('.'))

from app.core.database import SessionLocal
from app.core.auth_v2 import create_tenant_api_key

# Get tenant ID from command line
tenant_id = UUID(sys.argv[1])
firm_name = sys.argv[2] if len(sys.argv) > 2 else "Law Firm"

db = SessionLocal()

raw_key, key_record = create_tenant_api_key(
    db=db,
    tenant_id=tenant_id,
    description=f"{firm_name} - Production Key",
    expires_in_days=None  # Never expires
)

print("=" * 80)
print(f"TENANT API KEY CREATED - {firm_name}")
print("=" * 80)
print(f"API Key: {raw_key}")
print(f"Key ID: {key_record.id}")
print(f"Tenant ID: {key_record.tenant_id}")
print(f"Access Level: {key_record.access_level}")
print(f"Created: {key_record.created_at}")
print("=" * 80)
print("IMPORTANT: Save this key securely! It will not be shown again.")
print(f"Add to {firm_name} Tenant App .env file:")
print(f"DRAFT_TENANT_API_KEY={raw_key}")
print("=" * 80)

db.close()
```

Run:
```bash
# Replace with actual tenant UUID
python scripts/create_tenant_key.py "a1b2c3d4-e5f6-7890-abcd-ef1234567890" "Smith & Associates"
```

---

## 🌱 **STEP 4: SEED SAMPLE DATA (Optional)**

Create script `scripts/seed_templates.py`:

```python
import sys
import os
sys.path.insert(0, os.path.abspath('.'))

from app.core.database import SessionLocal
from app.services.rules_service_v2 import GlobalRuleTemplatesService

db = SessionLocal()
service = GlobalRuleTemplatesService(db)

# Sample template 1: Arizona Demand Letter Format
template1 = service.create_template({
    "template_name": "Arizona Bar Demand Letter Format",
    "template_description": "Ensures demand letters comply with Arizona Bar formatting requirements",
    "validator_level": 4,
    "validator_name": "demand_letter_format_validator",
    "validator_type": "format",
    "practice_area": "personal_injury",
    "document_type": "demand_letter",
    "jurisdiction_state": "AZ",
    "validator_config": {
        "required_sections": ["header", "facts", "liability", "damages", "settlement_demand"],
        "font_size_min": 11,
        "font_size_max": 14,
        "margin_inches": 1.0
    },
    "error_message": "Demand letter does not meet Arizona Bar formatting requirements",
    "severity": "error"
})

print(f"✅ Created template: {template1.template_name} (ID: {template1.id})")

# Sample template 2: Universal Required Fields
template2 = service.create_template({
    "template_name": "Universal Required Fields",
    "template_description": "Universal validator for required fields in all documents",
    "validator_level": 1,
    "validator_name": "required_fields_validator",
    "validator_type": "content",
    "validator_config": {
        "required_fields": ["attorney_name", "attorney_bar_number", "date"]
    },
    "error_message": "Document is missing required fields",
    "severity": "error"
})

print(f"✅ Created template: {template2.template_name} (ID: {template2.id})")

print("\n✅ Sample templates created successfully!")

db.close()
```

Run:
```bash
python scripts/seed_templates.py
```

---

## 🖥️ **STEP 5: START THE SERVICE**

### **5.1 Development Mode**

```bash
# Start with auto-reload
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# Service available at http://localhost:8000
```

### **5.2 Production Mode**

```bash
# Start with Gunicorn (recommended for production)
gunicorn app.main:app \
    --workers 4 \
    --worker-class uvicorn.workers.UvicornWorker \
    --bind 0.0.0.0:8000 \
    --log-level info \
    --access-logfile - \
    --error-logfile -

# Or with Uvicorn
uvicorn app.main:app \
    --host 0.0.0.0 \
    --port 8000 \
    --workers 4 \
    --log-level info
```

### **5.3 Verify Service Running**

```bash
# Health check
curl http://localhost:8000/api/v1/health

# Expected response:
# {
#   "status": "healthy",
#   "service": "draft",
#   "version": "2.0",
#   "architecture": "correct",
#   "zero_knowledge": true
# }
```

---

## 🧪 **STEP 6: TEST API ENDPOINTS**

### **6.1 Test Admin Endpoints**

```bash
# Set admin API key
export ADMIN_KEY="draft_live_xxx"  # Use your generated key

# List templates
curl -H "Authorization: Bearer $ADMIN_KEY" \
     http://localhost:8000/api/v1/admin/rule-templates

# Create template
curl -X POST \
     -H "Authorization: Bearer $ADMIN_KEY" \
     -H "Content-Type: application/json" \
     -d '{
       "template_name": "Test Template",
       "validator_level": 1,
       "validator_name": "test_validator",
       "validator_type": "format",
       "validator_config": {},
       "error_message": "Test error",
       "severity": "error"
     }' \
     http://localhost:8000/api/v1/admin/rule-templates
```

### **6.2 Test Tenant Endpoints**

```bash
# Set tenant API key
export TENANT_KEY="draft_live_yyy"  # Use your generated key

# List tenant rules
curl -H "Authorization: Bearer $TENANT_KEY" \
     http://localhost:8000/api/v1/tenant/rules

# Browse templates
curl -H "Authorization: Bearer $TENANT_KEY" \
     http://localhost:8000/api/v1/tenant/rule-templates
```

---

## 🐳 **STEP 7: DOCKER DEPLOYMENT (Optional)**

### **7.1 Create Dockerfile**

```dockerfile
FROM python:3.11-slim

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application
COPY . .

# Expose port
EXPOSE 8000

# Run application
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### **7.2 Create docker-compose.yml**

```yaml
version: '3.8'

services:
  draft-service:
    build: .
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgresql://draft_user:password@db:5432/truevow_draft
      - SECRET_KEY=${SECRET_KEY}
    depends_on:
      - db
  
  db:
    image: postgres:14
    environment:
      - POSTGRES_DB=truevow_draft
      - POSTGRES_USER=draft_user
      - POSTGRES_PASSWORD=password
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

### **7.3 Deploy with Docker**

```bash
# Build and start
docker-compose up -d

# Check logs
docker-compose logs -f draft-service

# Stop
docker-compose down
```

---

## 📊 **STEP 8: MONITORING & LOGS**

### **8.1 Check Application Logs**

```bash
# View logs (if using systemd)
journalctl -u draft-service -f

# View logs (if using Docker)
docker-compose logs -f draft-service

# View logs (if using pm2)
pm2 logs draft-service
```

### **8.2 Monitor Database**

```bash
# Check active connections
psql -U draft_user -d truevow_draft -c "SELECT count(*) FROM pg_stat_activity;"

# Check table sizes
psql -U draft_user -d truevow_draft -c "
  SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
  FROM pg_tables
  WHERE schemaname = 'draft'
  ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
"
```

---

## ✅ **DEPLOYMENT VERIFICATION CHECKLIST**

After deployment, verify:

- [ ] Service is running (health check returns 200)
- [ ] Database connection works
- [ ] Admin API key works (can list templates)
- [ ] Tenant API key works (can list rules)
- [ ] CORS headers configured correctly
- [ ] Logs are being written
- [ ] No errors in logs
- [ ] Performance is acceptable

---

## 🔧 **TROUBLESHOOTING**

### **Issue: Database connection failed**

```bash
# Check PostgreSQL is running
sudo systemctl status postgresql

# Check connection
psql -U draft_user -d truevow_draft -c "SELECT 1;"

# Check DATABASE_URL format
echo $DATABASE_URL
```

### **Issue: Migration failed**

```bash
# Check current migration version
alembic current

# Downgrade and retry
alembic downgrade -1
alembic upgrade head

# Reset database (CAUTION: destroys data)
psql -U draft_user -d truevow_draft -c "DROP SCHEMA draft CASCADE;"
alembic upgrade head
```

### **Issue: API key authentication failed**

```bash
# Verify key format
echo $ADMIN_KEY  # Should start with "draft_live_"

# Check key in database
psql -U draft_user -d truevow_draft -c "SELECT key_prefix, access_level FROM draft.api_keys;"

# Regenerate key
python scripts/create_admin_key.py
```

---

## 🔒 **SECURITY CHECKLIST**

Before production:

- [ ] Change all default passwords
- [ ] Use strong SECRET_KEY
- [ ] Enable HTTPS only
- [ ] Configure CORS properly
- [ ] Set up firewall rules
- [ ] Enable rate limiting
- [ ] Set up monitoring/alerting
- [ ] Regular backups configured
- [ ] API keys rotated regularly

---

## 📚 **NEXT STEPS AFTER DEPLOYMENT**

1. ✅ Share API keys with SaaS Admin team
2. ✅ Share API keys with Tenant App teams
3. ✅ Share API documentation
4. ✅ Set up monitoring dashboards
5. ✅ Configure backup schedule
6. ✅ Set up CI/CD pipeline

---

**Deployment Complete!** 🎉

The DRAFT Service v2.0 is now running and ready for integration.

**API Base URL:** `http://localhost:8000` (or your production URL)  
**Health Check:** `http://localhost:8000/api/v1/health`  
**API Docs:** `http://localhost:8000/docs` (Swagger UI)

---

**Last Updated:** December 10, 2025  
**Version:** 2.0.0  
**Status:** Production Ready

