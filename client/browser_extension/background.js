/**
 * TrueVow DRAFT™ - Background Service Worker
 * Handles background tasks, API calls, and analytics logging
 */

console.log('TrueVow DRAFT™ background service worker initialized');

// Constants
// UPDATED: DRAFT is now integrated into Tenant App (not separate service)
// URL format: https://{tenant}.truevow.law/api/v1/draft/...
// Example: https://smithlaw.truevow.law/api/v1/draft/sync/rules
const API_BASE_URL = 'http://localhost:8000/api/v1'; // Tenant App (dev)
const DRAFT_PREFIX = '/draft'; // DRAFT endpoints prefix
const SYNC_INTERVAL_HOURS = 24;

// Listen for extension installation
chrome.runtime.onInstalled.addListener((details) => {
    if (details.reason === 'install') {
        console.log('TrueVow DRAFT™ installed');
        
        // Open options page on first install
        chrome.tabs.create({
            url: 'options.html'
        });
        
        // Set default settings
        chrome.storage.local.set({
            'truevow_api_key': '',
            'truevow_sync_interval': SYNC_INTERVAL_HOURS,
            'truevow_auto_sync': true,
            'truevow_analytics_enabled': true
        });
    }
});

// Listen for messages from popup and content scripts
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
    if (request.action === 'logAnalytics') {
        logAnalyticsToServer(request.data)
            .then(() => sendResponse({ success: true }))
            .catch(error => sendResponse({ success: false, error: error.message }));
        
        return true; // Keep channel open for async response
    }
    
    if (request.action === 'checkSync') {
        checkSyncStatus()
            .then(status => sendResponse(status))
            .catch(error => sendResponse({ error: error.message }));
        
        return true;
    }
});

// Periodic sync check (every hour)
chrome.alarms.create('syncCheck', { periodInMinutes: 60 });

chrome.alarms.onAlarm.addListener((alarm) => {
    if (alarm.name === 'syncCheck') {
        checkAndAutoSync();
    }
});

/**
 * Check sync status and auto-sync if needed
 */
async function checkAndAutoSync() {
    try {
        const settings = await chrome.storage.local.get([
            'truevow_auto_sync',
            'truevow_last_sync',
            'truevow_sync_interval'
        ]);
        
        if (!settings.truevow_auto_sync) {
            return; // Auto-sync disabled
        }
        
        const lastSync = settings.truevow_last_sync;
        const syncInterval = settings.truevow_sync_interval || SYNC_INTERVAL_HOURS;
        
        if (!lastSync) {
            // Never synced
            showSyncNotification('Validation rules need to be synced');
            return;
        }
        
        const lastSyncDate = new Date(lastSync);
        const now = new Date();
        const hoursSinceSync = (now - lastSyncDate) / (1000 * 60 * 60);
        
        if (hoursSinceSync >= syncInterval) {
            showSyncNotification('Time to sync validation rules');
        }
        
    } catch (error) {
        console.error('Auto-sync check failed:', error);
    }
}

/**
 * Check sync status
 */
async function checkSyncStatus() {
    const data = await chrome.storage.local.get([
        'truevow_last_sync',
        'truevow_cached_rules'
    ]);
    
    return {
        last_sync: data.truevow_last_sync,
        has_cached_rules: !!data.truevow_cached_rules,
        needs_sync: !data.truevow_last_sync || !data.truevow_cached_rules
    };
}

/**
 * Log analytics to server (metadata only - NO document content)
 */
async function logAnalyticsToServer(analyticsData) {
    try {
        const settings = await chrome.storage.local.get([
            'truevow_api_key',
            'truevow_analytics_enabled'
        ]);
        
        if (!settings.truevow_analytics_enabled) {
            return; // Analytics disabled
        }
        
        const apiKey = settings.truevow_api_key;
        if (!apiKey) {
            console.warn('API key not configured, skipping analytics');
            return;
        }
        
        // Send analytics to server (NEW ENDPOINT: /draft/validation/log)
        const response = await fetch(`${API_BASE_URL}${DRAFT_PREFIX}/validation/log`, {
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${apiKey}`,
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(analyticsData)
        });
        
        if (!response.ok) {
            throw new Error(`Analytics logging failed: ${response.statusText}`);
        }
        
        console.log('Analytics logged successfully');
        
    } catch (error) {
        console.error('Failed to log analytics:', error);
        // Don't throw - analytics failure shouldn't break extension
    }
}

/**
 * Show sync notification
 */
function showSyncNotification(message) {
    chrome.notifications.create({
        type: 'basic',
        iconUrl: 'icons/icon48.png',
        title: 'TrueVow DRAFT™',
        message: message,
        buttons: [
            { title: 'Sync Now' }
        ]
    });
}

// Handle notification button clicks
chrome.notifications.onButtonClicked.addListener((notificationId, buttonIndex) => {
    if (buttonIndex === 0) {
        // "Sync Now" button clicked
        // Open popup to trigger sync
        chrome.action.openPopup();
    }
});

// Handle extension icon click
chrome.action.onClicked.addListener((tab) => {
    // Open popup (default behavior)
    // This is here for reference
});

/**
 * Fetch updates from server
 */
async function fetchUpdates() {
    try {
        const settings = await chrome.storage.local.get(['truevow_api_key']);
        const apiKey = settings.truevow_api_key;
        
        if (!apiKey) {
            return;
        }
        
        // NEW ENDPOINT: Use /draft/sync/rules instead of /validation-rules/check-updates
        const response = await fetch(`${API_BASE_URL}${DRAFT_PREFIX}/sync/rules?document_type=demand_letter`, {
            method: 'GET',
            headers: {
                'Authorization': `Bearer ${apiKey}`,
                'Content-Type': 'application/json',
                'X-Client-Version': chrome.runtime.getManifest().version
            }
        });
        
        if (response.ok) {
            const data = await response.json();
            
            // Response format: { rules: [...], total_rules: N, version: "1.0.0" }
            if (data.rules && data.rules.length > 0) {
                showSyncNotification(`${data.total_rules} validation rules synced`);
                
                // Store synced rules in cache
                await chrome.storage.local.set({
                    'truevow_cached_rules': data.rules,
                    'truevow_last_sync': new Date().toISOString()
                });
            }
        }
        
    } catch (error) {
        console.error('Failed to check for updates:', error);
    }
}

// Check for updates on startup
chrome.runtime.onStartup.addListener(() => {
    fetchUpdates();
});

