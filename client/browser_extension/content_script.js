/**
 * TrueVow DRAFT™ - Content Script
 * Injected into web pages (Google Docs, Office 365, etc.) to extract document content
 * 
 * ZERO-KNOWLEDGE: Document content stays in browser, never uploaded
 */

console.log('TrueVow DRAFT™ content script loaded');

// Listen for messages from popup
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
    if (request.action === 'extractDocument') {
        extractDocumentContent()
            .then(content => {
                sendResponse({ success: true, content });
            })
            .catch(error => {
                sendResponse({ success: false, error: error.message });
            });
        
        return true; // Keep channel open for async response
    }
});

/**
 * Extract document content from current page
 */
async function extractDocumentContent() {
    const url = window.location.href;
    
    // Google Docs
    if (url.includes('docs.google.com/document')) {
        return extractFromGoogleDocs();
    }
    
    // Microsoft Office 365
    if (url.includes('office.com') || url.includes('sharepoint.com')) {
        return extractFromOffice365();
    }
    
    // Generic fallback
    return extractFromGenericPage();
}

/**
 * Extract from Google Docs
 */
function extractFromGoogleDocs() {
    // Google Docs uses canvas rendering, need to extract from DOM
    const contentElement = document.querySelector('.kix-paginateddocumentplugin');
    
    if (!contentElement) {
        throw new Error('Could not find Google Docs content');
    }
    
    // Extract all text nodes
    const walker = document.createTreeWalker(
        contentElement,
        NodeFilter.SHOW_TEXT,
        null,
        false
    );
    
    let text = '';
    let node;
    
    while (node = walker.nextNode()) {
        text += node.textContent + ' ';
    }
    
    return text.trim();
}

/**
 * Extract from Office 365
 */
function extractFromOffice365() {
    // Office 365 web editor
    const contentElement = document.querySelector('[role="textbox"]') ||
                          document.querySelector('.office-editor-content') ||
                          document.querySelector('#WACViewPanel');
    
    if (!contentElement) {
        throw new Error('Could not find Office 365 content');
    }
    
    return contentElement.textContent.trim();
}

/**
 * Extract from generic web page
 */
function extractFromGenericPage() {
    // Try common content selectors
    const selectors = [
        'article',
        'main',
        '[role="main"]',
        '.content',
        '#content',
        'body'
    ];
    
    for (const selector of selectors) {
        const element = document.querySelector(selector);
        if (element) {
            return element.textContent.trim();
        }
    }
    
    return document.body.textContent.trim();
}

// Inject validation panel (optional - for inline validation UI)
function injectValidationPanel() {
    if (document.getElementById('truevow-validation-panel')) {
        return; // Already injected
    }
    
    const panel = document.createElement('div');
    panel.id = 'truevow-validation-panel';
    panel.innerHTML = `
        <div class="truevow-panel-header">
            <h3>TrueVow DRAFT™</h3>
            <button class="truevow-close-btn">&times;</button>
        </div>
        <div class="truevow-panel-content">
            <p>Click extension icon to validate document</p>
        </div>
    `;
    
    document.body.appendChild(panel);
    
    // Close button
    panel.querySelector('.truevow-close-btn').addEventListener('click', () => {
        panel.style.display = 'none';
    });
}

// Auto-inject panel on supported sites (optional)
if (window.location.href.includes('docs.google.com') ||
    window.location.href.includes('office.com')) {
    // Uncomment to enable auto-inject:
    // setTimeout(injectValidationPanel, 2000);
}

