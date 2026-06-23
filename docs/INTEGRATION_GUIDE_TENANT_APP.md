# DRAFT Service - Tenant App Integration Guide

**Date:** January 9, 2026  
**Purpose:** Guide for integrating DRAFT Customer Portal UI into Tenant Application  
**Status:** ✅ Ready for Integration

---

## 📋 Overview

The DRAFT Customer Portal UI has been created in `web/draft/` directory. This guide explains how to integrate it into the Tenant Application.

---

## 📁 Files Created

All files are located in: `2025-TrueVow-Draft-Service/web/draft/`

### Core Files
- ✅ `index.html` - Main customer portal page (all tabs)
- ✅ `styles.css` - Complete styling
- ✅ `app.js` - Application logic
- ✅ `draft-client.js` - API client
- ✅ `validation-engine.js` - Client-side validation (copied from browser extension)
- ✅ `README.md` - Documentation

---

## 🚀 Integration Steps

### Step 1: Copy Files to Tenant App

**Option A: Copy to Tenant App `web/` directory**
```bash
# From DRAFT service repo
cd 2025-TrueVow-Draft-Service
cp -r web/draft ../2025-TrueVow-Tenant-Application/web/draft
```

**Option B: Copy to Tenant App `app/tenant-portal/draft/` (if using Next.js)**
```bash
# If Tenant App uses Next.js/React
# Copy HTML/JS files and convert to React components
```

---

### Step 2: Configure API Endpoints

**Update `draft-client.js` or create config:**

```javascript
// In Tenant App, set these environment variables or config
window.DRAFT_API_URL = process.env.DRAFT_API_URL || 'https://draft.truevow.law';
window.DRAFT_API_KEY = process.env.DRAFT_API_KEY || ''; // Tenant-specific API key
```

**Or update `app.js`:**
```javascript
const draftClient = new DraftClient({
    apiUrl: 'https://draft.truevow.law', // Or from env
    apiKey: getTenantApiKey() // From Tenant App auth
});
```

---

### Step 3: Add Routing

**If Tenant App uses simple HTML/JS:**

Add route in Tenant App router:
```python
# In Tenant App FastAPI router
@app.get("/draft")
async def draft_portal():
    return FileResponse("web/draft/index.html")
```

**If Tenant App uses Next.js/React:**

Create route: `app/tenant-portal/draft/page.tsx`
```typescript
'use client'
import { useEffect } from 'react'

export default function DraftPage() {
  useEffect(() => {
    // Load DRAFT portal in iframe or embed
    // Or convert HTML to React components
  }, [])
  
  return (
    <iframe 
      src="/web/draft/index.html" 
      style={{ width: '100%', height: '100vh', border: 'none' }}
    />
  )
}
```

---

### Step 4: Authentication Integration

**Update `draft-client.js` to use Tenant App auth:**

```javascript
class DraftClient {
    constructor(config) {
        this.apiUrl = config.apiUrl;
        // Get API key from Tenant App auth system
        this.apiKey = getTenantDraftApiKey(); // From Tenant App
        this.tenantId = getTenantId(); // From Tenant App
    }
    
    async validateFile(file, options = {}) {
        // Include tenant_id from Tenant App
        formData.append('tenant_id', this.tenantId);
        // ... rest of method
    }
}
```

---

### Step 5: CORS Configuration

**Update DRAFT service CORS settings:**

```python
# In DRAFT service app/main.py
CORS_ORIGINS = [
    "https://tenant-app.truevow.law",
    "http://localhost:8000",  # For development
]
```

---

### Step 6: Test Integration

1. **Start DRAFT service:**
   ```bash
   cd 2025-TrueVow-Draft-Service
   python -m uvicorn app.main:app --port 8003
   ```

2. **Start Tenant App:**
   ```bash
   cd 2025-TrueVow-Tenant-Application
   # Start Tenant App server
   ```

3. **Test Customer Portal:**
   - Navigate to `/draft` in Tenant App
   - Test document upload
   - Test validation
   - Test history
   - Test rules viewer

---

## 🔧 Customization

### Styling

Update `styles.css` to match Tenant App theme:
```css
:root {
    --primary: #your-brand-color;
    --bg-primary: #your-bg-color;
    /* ... other variables */
}
```

### Branding

Update `index.html` header:
```html
<header>
    <h1>Your Law Firm Name - DRAFT™</h1>
    <p class="subtitle">Compliance Document Validator</p>
</header>
```

---

## 📝 API Endpoints Required

Ensure these DRAFT service endpoints are accessible:

- ✅ `POST /api/v1/validation/validate` - Validate document text
- ✅ `POST /api/v1/validation/validate-file` - Validate uploaded file
- ✅ `GET /api/v1/validation/rules` - Get validation rules
- ⏳ `GET /api/v1/validation/history` - Get validation history (if needed)

---

## ✅ Integration Checklist

- [ ] Copy files to Tenant App
- [ ] Configure API endpoints
- [ ] Add routing
- [ ] Integrate authentication
- [ ] Update CORS settings
- [ ] Test document validation
- [ ] Test validation history
- [ ] Test rules viewer
- [ ] Test download tools
- [ ] Customize styling
- [ ] Update branding

---

## 🐛 Troubleshooting

### CORS Errors
- Check DRAFT service CORS configuration
- Verify Tenant App domain is in allowed origins

### API Key Issues
- Verify API key is correctly passed
- Check Tenant App auth integration
- Verify tenant_id is included in requests

### File Upload Issues
- Check file size limits
- Verify content-type headers
- Check DRAFT service file upload endpoint

---

## 📚 Additional Resources

- DRAFT Service API Documentation: `docs/AGENT_ONBOARDING.md`
- Client-Side Validation: `docs/DRAFT_CLIENT_SIDE_VALIDATION_ARCHITECTURE.md`
- Zero-Knowledge Architecture: `docs/DRAFT_ZERO_KNOWLEDGE_ARCHITECTURE.md`

---

**Last Updated:** January 9, 2026
