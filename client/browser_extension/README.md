# TrueVow DRAFT™ Browser Extension

**Zero-Knowledge Document Validation for Legal Professionals**

Validate legal documents locally - documents never leave your device.

---

## 🎯 **Features**

- ✅ **Client-Side Validation** - Documents validated locally, never uploaded
- ✅ **Encrypted Rules Sync** - Validation rules synced encrypted from server
- ✅ **5-Level Hierarchical Validators** - Universal, Practice Area, Specialization, Document Type, Jurisdiction
- ✅ **Multi-Platform Support** - Chrome, Firefox, Edge
- ✅ **Offline Capable** - Cached rules work offline
- ✅ **Google Docs Integration** - Extract and validate from Google Docs
- ✅ **Office 365 Integration** - Extract and validate from Office Online
- ✅ **Privacy-Preserving** - Optional analytics (metadata only, no content)

---

## 🚀 **Installation**

### **Chrome / Edge (Development)**

1. Clone this repository
2. Open Chrome/Edge and navigate to `chrome://extensions/`
3. Enable "Developer mode"
4. Click "Load unpacked"
5. Select the `client/browser_extension/` folder

### **Firefox (Development)**

1. Clone this repository
2. Open Firefox and navigate to `about:debugging#/runtime/this-firefox`
3. Click "Load Temporary Add-on"
4. Select the `manifest.json` file from `client/browser_extension/`

---

## ⚙️ **Configuration**

### **1. Get API Key**

- Log in to TrueVow Admin Dashboard
- Navigate to Settings → API Keys
- Create a new API key for browser extension
- Copy the API key

### **2. Configure Extension**

- Click extension icon in browser toolbar
- Click "Settings" link
- Enter:
  - **API Base URL:** `http://localhost:8003/api/v1` (or production URL)
  - **API Key:** (paste your API key)
- Configure sync and privacy settings
- Click "Save Settings"

### **3. Sync Validation Rules**

- Click extension icon
- Click "Sync Rules" button
- Wait for sync to complete
- Rules are now cached locally for offline use

---

## 📖 **Usage**

### **Validate a Document**

1. Open a document in Google Docs or Office 365
2. Click TrueVow DRAFT™ extension icon
3. Select:
   - Practice Area
   - Specialization
   - Document Type
   - Jurisdiction
4. Click "Validate Document"
5. Review validation results

### **Validation Results**

- **✓ Passed:** Rules that passed validation
- **✗ Failed:** Critical issues that must be fixed
- **⚠ Warnings:** Non-critical issues to review

---

## 🔐 **Zero-Knowledge Architecture**

### **How It Works:**

1. **Rules Sync:**
   - Validation rules downloaded from server (encrypted)
   - Rules decrypted locally in browser
   - Rules cached in browser storage

2. **Document Extraction:**
   - Document content extracted from current page
   - Content stays in browser memory only
   - **NEVER uploaded to servers**

3. **Local Validation:**
   - Rules applied to document locally
   - Validation runs entirely in browser
   - Results displayed immediately

4. **Optional Analytics:**
   - Only metadata logged (document type, validation status)
   - **NO document content** ever sent
   - Analytics can be disabled in settings

---

## 🗂️ **File Structure**

```
browser_extension/
├── manifest.json              # Extension manifest (Chrome/Edge/Firefox)
├── popup.html                 # Extension popup UI
├── popup.js                   # Popup logic
├── validation_engine.js       # Core validation engine
├── content_script.js          # Document extraction (Google Docs, Office 365)
├── background.js              # Background service worker
├── options.html               # Settings page
├── options.js                 # Settings logic
├── styles.css                 # UI styles
├── content_styles.css         # Content script styles
└── icons/                     # Extension icons
    ├── icon16.png
    ├── icon32.png
    ├── icon48.png
    └── icon128.png
```

---

## 🧪 **Testing**

### **Test on Google Docs:**

1. Create a test document in Google Docs
2. Load extension
3. Click extension icon
4. Configure validation settings
5. Click "Validate Document"
6. Verify results appear

### **Test Offline:**

1. Sync rules while online
2. Disconnect from internet
3. Attempt validation
4. Should work with cached rules

---

## 🔧 **Development**

### **Build Extension:**

```bash
# No build process required - pure JavaScript
# Load unpacked extension directly
```

### **Debug:**

```bash
# Chrome DevTools
1. Right-click extension icon → "Inspect popup"
2. View console logs

# Content Script
1. Open page (Google Docs, etc.)
2. Open DevTools (F12)
3. View console logs

# Background Script
1. Go to chrome://extensions/
2. Click "background page" under extension
3. View console logs
```

---

## 🐛 **Troubleshooting**

### **Issue: Rules Not Syncing**

**Solution:**
- Check API URL in settings
- Verify API key is correct
- Check browser console for errors
- Ensure server is running

### **Issue: Cannot Extract Document**

**Solution:**
- Verify supported site (Google Docs or Office 365)
- Check browser permissions
- Refresh page and try again
- Check content script console logs

### **Issue: Validation Not Working Offline**

**Solution:**
- Sync rules while online first
- Check chrome.storage for cached rules
- Clear cache and re-sync if needed

---

## 📝 **Supported Sites**

- ✅ Google Docs
- ✅ Microsoft Office 365 Online
- ✅ Microsoft SharePoint Online
- ⏳ More coming soon

---

## 🔒 **Privacy & Compliance**

### **Data Collection:**

- **✅ Collected:** Document type, practice area, validation status (metadata)
- **❌ NOT Collected:** Document content, client names, case details
- **🔒 Encrypted:** All API communication (HTTPS)
- **💾 Local Storage:** Validation rules cached in browser only

### **Compliance:**

- ✅ ABA Model Rule 1.1 (Competence)
- ✅ ABA Model Rule 5.5 (Unauthorized Practice of Law)
- ✅ HIPAA Compliant (no PHI transmitted)
- ✅ Attorney-Client Privilege Preserved

---

## 📚 **Resources**

- **Architecture:** `../../docs/DRAFT_CLIENT_SIDE_VALIDATION_ARCHITECTURE.md`
- **Zero-Knowledge:** `../../docs/DRAFT_ZERO_KNOWLEDGE_ARCHITECTURE.md`
- **API Docs:** http://localhost:8003/docs

---

## 🆘 **Support**

For issues or questions:
1. Check `TROUBLESHOOTING.md`
2. Review browser console logs
3. Check server logs
4. Contact TrueVow support

---

**Last Updated:** December 8, 2025  
**Version:** 1.0.0  
**Status:** Phase 2 Complete ✅

