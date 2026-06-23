# DRAFT Customer Portal UI

**Location:** `web/draft/`  
**Purpose:** Customer-facing UI for law firms to use DRAFT service  
**Status:** ✅ Complete

---

## 📁 Files

### Core Files
- `index.html` - Main customer portal page with tabs
- `styles.css` - Complete styling
- `app.js` - Application logic and UI interactions
- `draft-client.js` - API client for DRAFT service
- `validation-engine.js` - Client-side validation engine (shared)

---

## 🎯 Features

### 1. Document Validation Tab
- File upload (drag & drop or click)
- Document type selection
- Jurisdiction selection
- Real-time validation
- Results display with errors/warnings/info
- Validation statistics

### 2. Validation History Tab
- View past validations
- Search functionality
- Filter by document type
- Date range filtering
- Local storage persistence

### 3. View Rules Tab
- Browse validation rules
- Search rules
- Filter by practice area
- Filter by document type
- Rule details display

### 4. Download Tools Tab
- Download browser extension
- Download desktop app
- Download Word add-in
- Installation instructions

---

## 🚀 Integration

### For Tenant App Integration

1. **Copy files to Tenant App:**
   ```
   Copy web/draft/* to 2025-TrueVow-Tenant-Application/web/draft/
   ```

2. **Update API configuration:**
   ```javascript
   // In app.js or config file
   window.DRAFT_API_URL = 'https://draft.truevow.law';
   window.DRAFT_API_KEY = 'tenant-api-key-here';
   ```

3. **Add to Tenant App routing:**
   - Add route: `/draft` → `web/draft/index.html`
   - Or integrate into existing React/Next.js app

### For Standalone Deployment

1. **Serve static files:**
   ```bash
   # Using Python
   cd web/draft
   python -m http.server 8080
   
   # Using Node.js
   npx serve web/draft
   ```

2. **Configure CORS:**
   - Ensure DRAFT service allows requests from your domain
   - Update `CORS_ORIGINS` in DRAFT service config

---

## 📝 API Endpoints Used

- `POST /api/v1/validation/validate` - Validate document text
- `POST /api/v1/validation/validate-file` - Validate uploaded file
- `GET /api/v1/validation/rules` - Get validation rules
- `GET /api/v1/validation/history` - Get validation history (if implemented)

---

## 🎨 Styling

Uses CSS custom properties for theming:
- Primary color: `--primary`
- Success/Warning/Error colors
- Responsive design (mobile-first)
- Modern, clean UI

---

## ✅ Status

- ✅ Document validation interface
- ✅ Validation history viewer
- ✅ Rules viewer
- ✅ Download tools page
- ✅ API client
- ✅ Responsive design
- ✅ Error handling
- ✅ Local storage for history

---

**Last Updated:** January 9, 2026
