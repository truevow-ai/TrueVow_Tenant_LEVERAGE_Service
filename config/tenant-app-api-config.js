// DRAFT Service - Tenant App API Configuration
// Copy this configuration to Tenant App and update values

// Get DRAFT API configuration from environment or Tenant App config
const DRAFT_API_CONFIG = {
    // DRAFT service URL (from environment or config)
    apiUrl: process.env.DRAFT_API_URL || window.DRAFT_API_URL || 'https://draft.truevow.law',
    
    // Get API key from Tenant App auth system
    getApiKey: function() {
        // Option 1: From environment variable
        if (process.env.DRAFT_API_KEY) {
            return process.env.DRAFT_API_KEY;
        }
        
        // Option 2: From window (if set globally)
        if (window.DRAFT_API_KEY) {
            return window.DRAFT_API_KEY;
        }
        
        // Option 3: From Tenant App auth system
        // Replace with your Tenant App's auth system
        if (typeof getTenantDraftApiKey === 'function') {
            return getTenantDraftApiKey();
        }
        
        // Option 4: From localStorage (if stored)
        if (typeof localStorage !== 'undefined') {
            return localStorage.getItem('draft_api_key');
        }
        
        return '';
    },
    
    // Get tenant ID from Tenant App
    getTenantId: function() {
        // Replace with your Tenant App's tenant ID retrieval
        if (typeof getTenantId === 'function') {
            return getTenantId();
        }
        
        if (window.TENANT_ID) {
            return window.TENANT_ID;
        }
        
        if (typeof localStorage !== 'undefined') {
            return localStorage.getItem('tenant_id');
        }
        
        return 'default';
    }
};

// Update draft-client.js to use this configuration
// In web/draft/draft-client.js, replace:
/*
const draftClient = new DraftClient({
    apiUrl: window.DRAFT_API_URL || 'http://localhost:8003',
    apiKey: window.DRAFT_API_KEY || ''
});
*/

// With:
/*
const draftClient = new DraftClient({
    apiUrl: DRAFT_API_CONFIG.apiUrl,
    apiKey: DRAFT_API_CONFIG.getApiKey()
});
*/

// Export for use in other files
if (typeof module !== 'undefined' && module.exports) {
    module.exports = DRAFT_API_CONFIG;
}
