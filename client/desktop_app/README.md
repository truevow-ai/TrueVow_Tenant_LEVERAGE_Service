# TrueVow DRAFT™ Desktop Application

**Zero-Knowledge Document Validation for Legal Professionals**

Cross-platform desktop application for validating local document files.

---

## 🎯 **Features**

- ✅ **Zero-Knowledge Validation** - Documents processed locally, never uploaded
- ✅ **Multi-Format Support** - Word (.docx), PDF (.pdf), Text (.txt)
- ✅ **Drag & Drop** - Simple file selection
- ✅ **Offline Capable** - Cached rules work offline
- ✅ **Cross-Platform** - Windows, macOS, Linux
- ✅ **System Tray Integration** - Quick access from system tray
- ✅ **Beautiful UI** - Modern, professional interface
- ✅ **5-Level Hierarchical Validators** - Comprehensive compliance checking

---

## 📦 **Installation**

### **From Releases (Recommended)**

1. Download the installer for your platform:
   - **Windows:** `TrueVow-DRAFT-Setup-1.0.0.exe`
   - **macOS:** `TrueVow-DRAFT-1.0.0.dmg`
   - **Linux:** `TrueVow-DRAFT-1.0.0.AppImage` or `.deb`

2. Run the installer

3. Launch TrueVow DRAFT

### **From Source (Development)**

```bash
# Clone repository
cd client/desktop_app

# Install dependencies
npm install

# Run in development mode
npm start

# Build for production
npm run build

# Build for specific platform
npm run build:win   # Windows
npm run build:mac   # macOS
npm run build:linux # Linux
```

---

## ⚙️ **Configuration**

### **1. First Launch**

- Click Settings (⚙️) in sidebar
- Configure API settings:
  - **API URL:** `http://localhost:8003/api/v1` (or production URL)
  - **API Key:** (get from TrueVow Admin)
- Save settings

### **2. Sync Validation Rules**

- Click "Sync Rules" button
- Wait for sync to complete
- Rules are now cached locally

---

## 📖 **Usage**

### **Validate a Document**

#### **Method 1: Drag & Drop**
1. Open TrueVow DRAFT
2. Drag document file into drop zone
3. Select practice area, document type, jurisdiction
4. Click "Validate Document"
5. Review results

#### **Method 2: File Selection**
1. Click "Select File" button
2. Browse and select document
3. Configure validation settings
4. Click "Validate Document"
5. Review results

#### **Method 3: Menu Bar**
1. File → Open Document (Ctrl/Cmd+O)
2. Select document
3. Validation → Validate Current Document (Ctrl/Cmd+V)

---

## 🗂️ **Supported File Formats**

| Format | Extension | Status |
|--------|-----------|--------|
| Word Document | `.docx` | ✅ Supported |
| Word Legacy | `.doc` | ⏳ Coming Soon |
| PDF | `.pdf` | ✅ Supported |
| Text | `.txt` | ✅ Supported |
| Rich Text | `.rtf` | ⏳ Coming Soon |

---

## 🔐 **Zero-Knowledge Architecture**

### **How It Works:**

```
┌──────────────────────────────────────┐
│         Your Computer                 │
├──────────────────────────────────────┤
│  1. Open Document File               │ ← File stays on your device
│     (Read from disk)                 │
├──────────────────────────────────────┤
│  2. Load Cached Rules                │ ← Rules cached locally
│     (From local storage)             │
├──────────────────────────────────────┤
│  3. Validate Document                │ ← Validation runs locally
│     (In memory only)                 │
├──────────────────────────────────────┤
│  4. Display Results                  │ ← Results shown immediately
│     (On screen)                      │
└──────────────────────────────────────┘

✅ Document NEVER uploaded
✅ Validation happens locally
✅ Privacy preserved
```

---

## ⌨️ **Keyboard Shortcuts**

| Action | Windows/Linux | macOS |
|--------|---------------|-------|
| Open File | `Ctrl+O` | `Cmd+O` |
| Validate | `Ctrl+V` | `Cmd+V` |
| Sync Rules | `Ctrl+S` | `Cmd+S` |
| Settings | `Ctrl+,` | `Cmd+,` |
| Quit | `Ctrl+Q` | `Cmd+Q` |
| Reload | `Ctrl+R` | `Cmd+R` |
| Toggle DevTools | `Ctrl+Shift+I` | `Cmd+Option+I` |

---

## 🖥️ **System Requirements**

### **Minimum:**
- **OS:** Windows 10+, macOS 10.13+, Ubuntu 18.04+
- **RAM:** 4 GB
- **Disk Space:** 200 MB

### **Recommended:**
- **OS:** Windows 11, macOS 13+, Ubuntu 22.04+
- **RAM:** 8 GB
- **Disk Space:** 500 MB

---

## 🔧 **Development**

### **Project Structure:**

```
desktop_app/
├── main.js                 # Main process (Electron)
├── renderer.js             # Renderer process (UI logic)
├── validation_engine.js    # Validation engine
├── index.html              # Main window UI
├── styles.css              # Application styles
├── package.json            # Dependencies & build config
└── assets/                 # Icons and images
```

### **Technologies:**
- **Framework:** Electron 28+
- **UI:** HTML5, CSS3, Vanilla JavaScript
- **File Reading:**
  - Word: `mammoth` library
  - PDF: `pdf-parse` library
  - Text: Node.js `fs` module
- **Storage:** `electron-store` for persistent settings
- **HTTP Client:** `axios` for API calls

### **Build Configuration:**

```json
{
  "build": {
    "appId": "com.truevow.draft",
    "productName": "TrueVow DRAFT",
    "win": {
      "target": ["nsis", "portable"],
      "icon": "assets/icon.ico"
    },
    "mac": {
      "target": ["dmg", "zip"],
      "icon": "assets/icon.icns",
      "category": "public.app-category.productivity"
    },
    "linux": {
      "target": ["AppImage", "deb"],
      "icon": "assets/icon.png",
      "category": "Office"
    }
  }
}
```

---

## 🐛 **Troubleshooting**

### **Issue: App Won't Start**

**Solution:**
- Check minimum system requirements
- Try running from command line: `npm start`
- Check for error messages in console

### **Issue: Can't Open Files**

**Solution:**
- Verify file format is supported (.docx, .pdf, .txt)
- Check file permissions
- Try copying file to different location

### **Issue: Validation Rules Not Syncing**

**Solution:**
- Check API URL in settings
- Verify API key is correct
- Ensure server is running
- Check internet connection

### **Issue: PDF Not Reading Correctly**

**Solution:**
- Some PDFs (scanned images) require OCR
- Try converting to text first
- Use `.docx` format for best results

---

## 📝 **Changelog**

### **v1.0.0 (2025-12-08)**
- ✅ Initial release
- ✅ Multi-format support (.docx, .pdf, .txt)
- ✅ Drag & drop interface
- ✅ System tray integration
- ✅ Cross-platform support
- ✅ Zero-knowledge validation

---

## 🔒 **Privacy & Security**

### **Data Collection:**
- **✅ Collected:** Document type, validation status (metadata only)
- **❌ NOT Collected:** Document content, file names, file paths
- **🔒 Local Processing:** All validation happens on your device
- **💾 Local Storage:** Settings and cached rules only

### **Compliance:**
- ✅ ABA Model Rule 1.1 (Competence)
- ✅ ABA Model Rule 5.5 (Unauthorized Practice of Law)
- ✅ HIPAA Compliant (no PHI transmitted)
- ✅ Attorney-Client Privilege Preserved

---

## 🆘 **Support**

### **Documentation:**
- **Architecture:** `../../docs/DRAFT_CLIENT_SIDE_VALIDATION_ARCHITECTURE.md`
- **Zero-Knowledge:** `../../docs/DRAFT_ZERO_KNOWLEDGE_ARCHITECTURE.md`
- **API Docs:** http://localhost:8003/docs

### **Issues:**
- Report bugs: https://github.com/truevow/draft/issues
- Email support: support@truevow.com

---

## 📚 **Resources**

- **User Guide:** https://docs.truevow.com/draft/desktop
- **API Documentation:** https://docs.truevow.com/api
- **Video Tutorials:** https://truevow.com/tutorials
- **Community Forum:** https://community.truevow.com

---

## 📄 **License**

MIT License - See LICENSE file for details

---

**Last Updated:** December 8, 2025  
**Version:** 1.0.0  
**Status:** Production Ready ✅

