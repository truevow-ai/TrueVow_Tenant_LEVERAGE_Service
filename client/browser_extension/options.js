/**
 * TrueVow DRAFT™ - Options/Settings Page Script
 */

// DOM Elements
let saveButton, apiUrl, apiKey, autoSync, syncInterval;
let analyticsEnabled, defaultPracticeArea, defaultJurisdiction;
let alertSuccess, alertError, errorMessage;

// Initialize
document.addEventListener('DOMContentLoaded', async () => {
    initializeElements();
    await loadSettings();
    setupEventListeners();
});

/**
 * Initialize DOM element references
 */
function initializeElements() {
    saveButton = document.getElementById('saveButton');
    apiUrl = document.getElementById('apiUrl');
    apiKey = document.getElementById('apiKey');
    autoSync = document.getElementById('autoSync');
    syncInterval = document.getElementById('syncInterval');
    analyticsEnabled = document.getElementById('analyticsEnabled');
    defaultPracticeArea = document.getElementById('defaultPracticeArea');
    defaultJurisdiction = document.getElementById('defaultJurisdiction');
    
    alertSuccess = document.getElementById('alertSuccess');
    alertError = document.getElementById('alertError');
    errorMessage = document.getElementById('errorMessage');
}

/**
 * Load settings from chrome.storage
 */
async function loadSettings() {
    try {
        const settings = await chrome.storage.local.get([
            'truevow_api_url',
            'truevow_api_key',
            'truevow_auto_sync',
            'truevow_sync_interval',
            'truevow_analytics_enabled',
            'truevow_default_practice_area',
            'truevow_default_jurisdiction'
        ]);
        
        if (settings.truevow_api_url) {
            apiUrl.value = settings.truevow_api_url;
        }
        
        if (settings.truevow_api_key) {
            apiKey.value = settings.truevow_api_key;
            apiKey.type = 'password'; // Show masked
        }
        
        autoSync.checked = settings.truevow_auto_sync !== false;
        syncInterval.value = settings.truevow_sync_interval || 24;
        analyticsEnabled.checked = settings.truevow_analytics_enabled !== false;
        
        if (settings.truevow_default_practice_area) {
            defaultPracticeArea.value = settings.truevow_default_practice_area;
        }
        
        if (settings.truevow_default_jurisdiction) {
            defaultJurisdiction.value = settings.truevow_default_jurisdiction;
        }
        
    } catch (error) {
        showError(`Failed to load settings: ${error.message}`);
    }
}

/**
 * Setup event listeners
 */
function setupEventListeners() {
    saveButton.addEventListener('click', saveSettings);
    
    // Allow showing/hiding API key
    apiKey.addEventListener('focus', () => {
        apiKey.type = 'text';
    });
    
    apiKey.addEventListener('blur', () => {
        if (apiKey.value) {
            apiKey.type = 'password';
        }
    });
}

/**
 * Save settings to chrome.storage
 */
async function saveSettings() {
    try {
        saveButton.disabled = true;
        saveButton.textContent = 'Saving...';
        
        // Validate settings
        if (!apiUrl.value) {
            throw new Error('API URL is required');
        }
        
        if (!apiKey.value) {
            throw new Error('API Key is required');
        }
        
        const settings = {
            truevow_api_url: apiUrl.value,
            truevow_api_key: apiKey.value,
            truevow_auto_sync: autoSync.checked,
            truevow_sync_interval: parseInt(syncInterval.value),
            truevow_analytics_enabled: analyticsEnabled.checked,
            truevow_default_practice_area: defaultPracticeArea.value,
            truevow_default_jurisdiction: defaultJurisdiction.value
        };
        
        await chrome.storage.local.set(settings);
        
        showSuccess();
        
        // Test API connection
        await testApiConnection(settings.truevow_api_url, settings.truevow_api_key);
        
    } catch (error) {
        showError(error.message);
    } finally {
        saveButton.disabled = false;
        saveButton.textContent = 'Save Settings';
    }
}

/**
 * Test API connection
 * UPDATED: Use new /api/v1/health endpoint
 */
async function testApiConnection(baseUrl, key) {
    try {
        // Use general health endpoint instead of DRAFT-specific
        const response = await fetch(`${baseUrl}/health`, {
            headers: {
                'Authorization': `Bearer ${key}`
            }
        });
        
        if (!response.ok) {
            console.warn('API connection test failed');
        }
    } catch (error) {
        console.warn('Could not test API connection:', error);
    }
}

/**
 * Show success message
 */
function showSuccess() {
    alertSuccess.style.display = 'block';
    alertError.style.display = 'none';
    
    setTimeout(() => {
        alertSuccess.style.display = 'none';
    }, 5000);
}

/**
 * Show error message
 */
function showError(message) {
    errorMessage.textContent = message;
    alertError.style.display = 'block';
    alertSuccess.style.display = 'none';
    
    setTimeout(() => {
        alertError.style.display = 'none';
    }, 5000);
}

