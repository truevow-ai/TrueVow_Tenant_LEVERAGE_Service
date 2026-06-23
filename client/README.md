# TrueVow DRAFT™ Client-Side Validators

**Zero-Knowledge Architecture:** All validation happens locally on attorney's device

---

## 📁 **Client Implementations**

### **1. Browser Extension** (Primary - Chrome, Firefox, Edge)
- **Path:** `client/browser_extension/`
- **Purpose:** Validate documents in web-based editors (Google Docs, Office 365, etc.)
- **Technology:** Vanilla JavaScript (or React)
- **Status:** ✅ Implemented

### **2. Desktop Application** (Secondary - Windows, macOS)
- **Path:** `client/desktop_app/`
- **Purpose:** Validate local document files (Word, PDF, etc.)
- **Technology:** Electron (JavaScript) or Python (PyQt)
- **Status:** ✅ Implemented

### **3. Word Add-In** (Tertiary - Microsoft Word)
- **Path:** `client/word_addin/`
- **Purpose:** Validate documents directly in Microsoft Word
- **Technology:** Office.js (JavaScript)
- **Status:** ✅ Implemented

---

## 🔐 **Zero-Knowledge Compliance**

### **All Client Implementations:**
- ✅ **NO document upload** - Documents stay on device
- ✅ **Local validation only** - Rules synced, validation runs locally
- ✅ **Encrypted sync** - Rules encrypted during sync
- ✅ **Offline capable** - Cached rules work offline
- ✅ **No telemetry** - Analytics are optional and metadata-only

---

## 🚀 **Quick Start**

### **Browser Extension:**
```bash
cd client/browser_extension
# Load unpacked extension in Chrome/Edge/Firefox
# See browser_extension/README.md
```

### **Desktop App:**
```bash
cd client/desktop_app
npm install  # Electron
# or
pip install -r requirements.txt  # Python
npm start  # or python main.py
```

### **Word Add-In:**
```bash
cd client/word_addin
npm install
npm start
# Sideload in Word (see word_addin/README.md)
```

---

## 📚 **Documentation**

- **Architecture:** `../docs/DRAFT_CLIENT_SIDE_VALIDATION_ARCHITECTURE.md`
- **Zero-Knowledge:** `../docs/DRAFT_ZERO_KNOWLEDGE_ARCHITECTURE.md`
- **Compliance:** `../docs/DRAFT_LEGAL_COMPLIANCE_FRAMEWORK.md`

---

**Last Updated:** December 8, 2025

