# TrueVow DRAFT™ Word Add-In

**Zero-Knowledge Document Validation for Microsoft Word**

Validate legal documents directly in Microsoft Word - content never leaves the application.

---

## 🎯 **Features**

- ✅ **In-Document Validation** - Validates active Word document
- ✅ **Zero-Knowledge** - Document content processed locally via Office.js
- ✅ **Task Pane UI** - Side panel for validation controls
- ✅ **Real-Time Results** - Immediate validation feedback
- ✅ **5-Level Validators** - Comprehensive compliance checking
- ✅ **Ribbon Integration** - Accessible from Word ribbon
- ✅ **Office 365 Compatible** - Works with Word Desktop and Online

---

## 📦 **Installation**

### **Method 1: Sideload in Word Desktop (Development)**

1. **Install Dependencies:**
   ```bash
   cd client/word_addin
   npm install
   ```

2. **Start Dev Server:**
   ```bash
   npm start
   ```
   This starts a local server at `https://localhost:3000`

3. **Sideload Add-In:**
   ```bash
   npm run sideload
   ```
   Or manually:
   - File → Options → Trust Center → Trust Center Settings
   - Trusted Add-in Catalogs
   - Add `manifest.xml` location

4. **Open Word** and find "TrueVow DRAFT™" in Home tab

### **Method 2: Office 365 Admin Deployment (Production)**

1. Package add-in files
2. Upload to Office 365 Admin Center
3. Deploy to users/groups
4. Users find add-in in Office Store (Internal)

---

## ⚙️ **Configuration**

### **1. Update Manifest URLs**

Edit `manifest.xml` and update URLs:

```xml
<!-- Development -->
<bt:Url id="Taskpane.Url" DefaultValue="https://localhost:3000/taskpane.html"/>

<!-- Production -->
<bt:Url id="Taskpane.Url" DefaultValue="https://yourserver.com/taskpane.html"/>
```

### **2. Configure Add-In Settings**

In Word:
1. Click "TrueVow DRAFT™" in ribbon
2. Click "Settings" in task pane
3. Enter:
   - **API URL:** `http://localhost:8003/api/v1`
   - **API Key:** (from TrueVow Admin)
4. Save settings

### **3. Sync Validation Rules**

1. Click "Sync Rules" button
2. Rules are cached in localStorage
3. Ready for offline validation

---

## 📖 **Usage**

### **Validate Current Document**

1. **Open Document in Word**
2. **Launch Add-In:**
   - Click "TrueVow DRAFT™" in ribbon
   - Or: Insert → My Add-ins → TrueVow DRAFT™

3. **Configure Validation:**
   - Select Practice Area
   - Select Specialization (optional)
   - Select Document Type
   - Select Jurisdiction

4. **Click "Validate Document"**

5. **Review Results:**
   - ✓ Passed rules
   - ✗ Failed rules (errors)
   - ⚠ Warnings

---

## 🏗️ **Project Structure**

```
word_addin/
├── manifest.xml           # Add-in manifest (Office configuration)
├── taskpane.html          # Task pane UI
├── taskpane.js            # Task pane logic (Office.js integration)
├── taskpane.css           # Task pane styles
├── validation_engine.js   # Validation engine
├── package.json           # Dependencies
└── README.md              # This file
```

---

## 🔐 **Zero-Knowledge Architecture**

### **How It Works:**

```
┌─────────────────────────────────────┐
│        Microsoft Word               │
├─────────────────────────────────────┤
│  1. Document Open                   │ ← Document stays in Word
│     (Active document)               │
├─────────────────────────────────────┤
│  2. Extract Content                 │ ← Office.js API (local)
│     (Office.context.document)       │
├─────────────────────────────────────┤
│  3. Load Cached Rules               │ ← Rules in localStorage
│     (From browser storage)          │
├─────────────────────────────────────┤
│  4. Validate Locally                │ ← Validation in browser
│     (JavaScript in task pane)       │
├─────────────────────────────────────┤
│  5. Display Results                 │ ← Results in task pane
│     (In task pane UI)               │
└─────────────────────────────────────┘

✅ Document content accessed via Office.js
✅ Validation runs in browser context
✅ Content NEVER sent to servers
✅ Zero-knowledge maintained
```

---

## 🧪 **Testing**

### **Test in Word Desktop:**

1. Start dev server: `npm start`
2. Sideload add-in: `npm run sideload`
3. Open Word document
4. Click TrueVow DRAFT™ in ribbon
5. Test validation

### **Test in Word Online:**

1. Deploy to test environment
2. Open Word Online
3. Insert → Add-ins → Upload My Add-in
4. Select manifest.xml
5. Test validation

---

## 🐛 **Troubleshooting**

### **Issue: Add-In Not Appearing in Ribbon**

**Solution:**
- Verify manifest.xml is valid: `npm run validate`
- Restart Word completely
- Clear Office cache:
  - Windows: `%LOCALAPPDATA%\Microsoft\Office\16.0\Wef\`
  - Mac: `~/Library/Containers/com.microsoft.Word/Data/Library/Caches/`

### **Issue: "Office is not defined" Error**

**Solution:**
- Ensure Office.js is loaded:
  ```html
  <script src="https://appsforoffice.microsoft.com/lib/1/hosted/office.js"></script>
  ```
- Wait for `Office.onReady()` callback

### **Issue: CORS Errors**

**Solution:**
- Ensure dev server uses HTTPS
- Add manifest URLs to CORS allowed origins
- Check browser console for specific errors

### **Issue: Rules Not Syncing**

**Solution:**
- Check API URL in settings
- Verify API key is correct
- Check browser console for errors
- Ensure localStorage is enabled

---

## 📝 **Office.js API Usage**

### **Extract Document Content:**

```javascript
await Word.run(async (context) => {
    const body = context.document.body;
    body.load('text');
    await context.sync();
    const content = body.text;
    // Validate content...
});
```

### **Get Document Properties:**

```javascript
await Word.run(async (context) => {
    const properties = context.document.properties;
    properties.load('title, author');
    await context.sync();
    console.log(properties.title);
});
```

---

## 🚀 **Deployment**

### **Development:**
- Sideload manifest.xml
- Use localhost:3000

### **Production:**

1. **Host Files:**
   - Upload taskpane.html, taskpane.js, taskpane.css to HTTPS server
   - Update manifest.xml URLs

2. **Update Manifest:**
   - Change localhost URLs to production URLs
   - Update AppId (generate new GUID)

3. **Deploy via Office 365 Admin:**
   - Package as ZIP
   - Upload to Integrated Apps
   - Assign to users/groups

---

## 📚 **Resources**

### **Office Add-ins Documentation:**
- [Office Add-ins Overview](https://docs.microsoft.com/office/dev/add-ins/)
- [Word Add-ins Documentation](https://docs.microsoft.com/office/dev/add-ins/word/)
- [Office.js API Reference](https://docs.microsoft.com/javascript/api/word)

### **TrueVow DRAFT:**
- **Architecture:** `../../docs/DRAFT_CLIENT_SIDE_VALIDATION_ARCHITECTURE.md`
- **Zero-Knowledge:** `../../docs/DRAFT_ZERO_KNOWLEDGE_ARCHITECTURE.md`
- **API Docs:** http://localhost:8003/docs

---

## ⚠️ **Known Limitations**

- **Word Online:** Limited Office.js API support
- **Word 2016:** Some features require Word 2019+
- **Mac:** Sideloading process different from Windows
- **Content Controls:** Cannot highlight specific text (read-only access)

---

## 🔒 **Privacy & Compliance**

### **Data Collection:**
- **✅ Collected:** Document type, validation status (metadata)
- **❌ NOT Collected:** Document content, file names, user names
- **🔒 Processing:** All validation in browser via Office.js
- **💾 Storage:** Only rules and settings in localStorage

### **Compliance:**
- ✅ ABA Model Rule 1.1 (Competence)
- ✅ ABA Model Rule 5.5 (Unauthorized Practice of Law)
- ✅ HIPAA Compliant (no PHI accessed or transmitted)
- ✅ Attorney-Client Privilege Preserved

---

## 🆘 **Support**

- **Issues:** https://github.com/truevow/draft/issues
- **Email:** support@truevow.com
- **Docs:** https://docs.truevow.com/draft/word-addin

---

**Last Updated:** December 8, 2025  
**Version:** 1.0.0  
**Status:** Production Ready ✅

