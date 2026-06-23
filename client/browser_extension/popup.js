/**
 * TrueVow DRAFT™ Browser Extension - Popup Script
 * Manages UI and user interactions in the extension popup
 */

// Configuration
// UPDATED: DRAFT is now integrated into Tenant App
const API_BASE_URL = 'http://localhost:8000/api/v1'; // Tenant App (dev)
const DRAFT_PREFIX = '/draft'; // DRAFT endpoints prefix
const STORAGE_KEYS = {
    API_KEY: 'truevow_api_key',
    CACHED_RULES: 'truevow_cached_rules',
    LAST_SYNC: 'truevow_last_sync',
    PRACTICE_AREA: 'truevow_practice_area',
    SPECIALIZATION: 'truevow_specialization',
    DOCUMENT_TYPE: 'truevow_document_type',
    JURISDICTION: 'truevow_jurisdiction'
};

// DOM Elements
let syncButton, validateButton, statusIndicator, statusText, lastSyncText;
let practiceAreaSelect, specializationSelect, documentTypeSelect, jurisdictionSelect;
let validationResults, resultsContent;

// Initialize popup when DOM loads
document.addEventListener('DOMContentLoaded', async () => {
    initializeElements();
    await loadSettings();
    await checkSyncStatus();
    setupEventListeners();
});

/**
 * Initialize DOM element references
 */
function initializeElements() {
    syncButton = document.getElementById('syncButton');
    validateButton = document.getElementById('validateButton');
    statusIndicator = document.getElementById('statusIndicator');
    statusText = document.getElementById('statusText');
    lastSyncText = document.getElementById('lastSync');
    
    practiceAreaSelect = document.getElementById('practiceArea');
    specializationSelect = document.getElementById('specialization');
    documentTypeSelect = document.getElementById('documentType');
    jurisdictionSelect = document.getElementById('jurisdiction');
    
    validationResults = document.getElementById('validationResults');
    resultsContent = document.getElementById('resultsContent');
}

/**
 * Load saved settings from chrome.storage
 */
async function loadSettings() {
    try {
        const settings = await chrome.storage.local.get([
            STORAGE_KEYS.PRACTICE_AREA,
            STORAGE_KEYS.SPECIALIZATION,
            STORAGE_KEYS.DOCUMENT_TYPE,
            STORAGE_KEYS.JURISDICTION
        ]);
        
        if (settings[STORAGE_KEYS.PRACTICE_AREA]) {
            practiceAreaSelect.value = settings[STORAGE_KEYS.PRACTICE_AREA];
            await updateSpecializationOptions();
        }
        
        if (settings[STORAGE_KEYS.SPECIALIZATION]) {
            specializationSelect.value = settings[STORAGE_KEYS.SPECIALIZATION];
        }
        
        if (settings[STORAGE_KEYS.DOCUMENT_TYPE]) {
            documentTypeSelect.value = settings[STORAGE_KEYS.DOCUMENT_TYPE];
        }
        
        if (settings[STORAGE_KEYS.JURISDICTION]) {
            jurisdictionSelect.value = settings[STORAGE_KEYS.JURISDICTION];
        }
        
        checkValidationReady();
    } catch (error) {
        console.error('Failed to load settings:', error);
    }
}

/**
 * Setup event listeners
 */
function setupEventListeners() {
    // Sync button
    syncButton.addEventListener('click', handleSync);
    
    // Validate button
    validateButton.addEventListener('click', handleValidate);
    
    // Form changes
    practiceAreaSelect.addEventListener('change', async () => {
        await saveSettings();
        await updateSpecializationOptions();
        checkValidationReady();
    });
    
    specializationSelect.addEventListener('change', async () => {
        await saveSettings();
        checkValidationReady();
    });
    
    documentTypeSelect.addEventListener('change', async () => {
        await saveSettings();
        checkValidationReady();
    });
    
    jurisdictionSelect.addEventListener('change', async () => {
        await saveSettings();
        checkValidationReady();
    });
}

/**
 * Save current settings to chrome.storage
 */
async function saveSettings() {
    try {
        await chrome.storage.local.set({
            [STORAGE_KEYS.PRACTICE_AREA]: practiceAreaSelect.value,
            [STORAGE_KEYS.SPECIALIZATION]: specializationSelect.value,
            [STORAGE_KEYS.DOCUMENT_TYPE]: documentTypeSelect.value,
            [STORAGE_KEYS.JURISDICTION]: jurisdictionSelect.value
        });
    } catch (error) {
        console.error('Failed to save settings:', error);
    }
}

/**
 * Update specialization dropdown based on practice area
 */
async function updateSpecializationOptions() {
    const practiceArea = practiceAreaSelect.value;
    
    // Clear current options
    specializationSelect.innerHTML = '<option value="">Select...</option>';
    
    // Specialization mappings
    const specializations = {
        personal_injury: [
            { value: 'car_accident', label: 'Car Accident' },
            { value: 'medical_malpractice', label: 'Medical Malpractice' },
            { value: 'slip_and_fall', label: 'Slip and Fall' },
            { value: 'product_liability', label: 'Product Liability' }
        ],
        family_law: [
            { value: 'divorce', label: 'Divorce' },
            { value: 'child_custody', label: 'Child Custody' },
            { value: 'adoption', label: 'Adoption' },
            { value: 'domestic_violence', label: 'Domestic Violence' }
        ],
        criminal_law: [
            { value: 'dui', label: 'DUI' },
            { value: 'drug_crimes', label: 'Drug Crimes' },
            { value: 'theft', label: 'Theft' },
            { value: 'assault', label: 'Assault' }
        ]
        // Add more as needed
    };
    
    if (practiceArea && specializations[practiceArea]) {
        specializations[practiceArea].forEach(spec => {
            const option = document.createElement('option');
            option.value = spec.value;
            option.textContent = spec.label;
            specializationSelect.appendChild(option);
        });
    }
}

/**
 * Check if validation can be performed
 */
function checkValidationReady() {
    const hasRequired = practiceAreaSelect.value && documentTypeSelect.value;
    validateButton.disabled = !hasRequired;
}

/**
 * Check sync status
 */
async function checkSyncStatus() {
    try {
        const data = await chrome.storage.local.get([
            STORAGE_KEYS.LAST_SYNC,
            STORAGE_KEYS.CACHED_RULES
        ]);
        
        const lastSync = data[STORAGE_KEYS.LAST_SYNC];
        const cachedRules = data[STORAGE_KEYS.CACHED_RULES];
        
        if (lastSync && cachedRules) {
            const syncDate = new Date(lastSync);
            const now = new Date();
            const hoursSinceSync = (now - syncDate) / (1000 * 60 * 60);
            
            if (hoursSinceSync < 24) {
                updateStatus('synced', `Last synced: ${formatRelativeTime(syncDate)}`);
            } else {
                updateStatus('needs-sync', 'Rules need updating');
            }
        } else {
            updateStatus('not-synced', 'Rules not synced');
        }
    } catch (error) {
        console.error('Failed to check sync status:', error);
        updateStatus('error', 'Error checking status');
    }
}

/**
 * Update sync status UI
 */
function updateStatus(status, message) {
    statusIndicator.className = 'status-indicator';
    statusIndicator.classList.add(`status-${status}`);
    statusText.textContent = message;
}

/**
 * Format relative time
 */
function formatRelativeTime(date) {
    const now = new Date();
    const diff = now - date;
    const hours = Math.floor(diff / (1000 * 60 * 60));
    const minutes = Math.floor(diff / (1000 * 60));
    
    if (hours > 0) return `${hours}h ago`;
    if (minutes > 0) return `${minutes}m ago`;
    return 'Just now';
}

/**
 * Handle sync button click
 */
async function handleSync() {
    syncButton.disabled = true;
    syncButton.textContent = 'Syncing...';
    updateStatus('syncing', 'Syncing validation rules...');
    
    try {
        // Get API key from storage
        const data = await chrome.storage.local.get(STORAGE_KEYS.API_KEY);
        const apiKey = data[STORAGE_KEYS.API_KEY];
        
        if (!apiKey) {
            throw new Error('API key not configured. Please set it in Settings.');
        }
        
        // Prepare sync request
        const syncRequest = {
            practice_area: practiceAreaSelect.value || null,
            specialization: specializationSelect.value || null,
            document_type: documentTypeSelect.value || null,
            jurisdiction_state: jurisdictionSelect.value || null,
            include_universal: true,
            client_type: 'browser_extension',
            client_version: '1.0.0'
        };
        
        // Call sync endpoint (NEW: /draft/sync/rules)
        const documentType = syncRequest.document_type || 'demand_letter';
        const response = await fetch(`${API_BASE_URL}${DRAFT_PREFIX}/sync/rules?document_type=${documentType}`, {
            method: 'GET',
            headers: {
                'Authorization': `Bearer ${apiKey}`,
                'Content-Type': 'application/json',
                'X-Client-Version': syncRequest.client_version
            }
        });
        
        if (!response.ok) {
            throw new Error(`Sync failed: ${response.statusText}`);
        }
        
        const result = await response.json();
        
        // Response format: { rules: [...], total_rules: N, version: "1.0.0" }
        // Store synced rules
        await chrome.storage.local.set({
            [STORAGE_KEYS.CACHED_RULES]: result.rules || [],
            [STORAGE_KEYS.LAST_SYNC]: new Date().toISOString()
        });
        
        const rulesCount = result.total_rules || result.rules?.length || 0;
        updateStatus('synced', `Synced ${rulesCount} rules`);
        
        // Show notification
        chrome.notifications.create({
            type: 'basic',
            iconUrl: 'icons/icon48.png',
            title: 'TrueVow DRAFT™',
            message: `Successfully synced ${rulesCount} validation rules`
        });
        
    } catch (error) {
        console.error('Sync failed:', error);
        updateStatus('error', error.message);
        
        chrome.notifications.create({
            type: 'basic',
            iconUrl: 'icons/icon48.png',
            title: 'TrueVow DRAFT™',
            message: `Sync failed: ${error.message}`
        });
    } finally {
        syncButton.disabled = false;
        syncButton.textContent = 'Sync Rules';
    }
}

/**
 * Handle validate button click
 */
async function handleValidate() {
    validateButton.disabled = true;
    validateButton.textContent = 'Validating...';
    
    try {
        // Get current tab
        const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
        
        // Send message to content script to extract document
        const response = await chrome.tabs.sendMessage(tab.id, {
            action: 'extractDocument'
        });
        
        if (!response || !response.content) {
            throw new Error('Failed to extract document content');
        }
        
        // Get cached rules
        const data = await chrome.storage.local.get(STORAGE_KEYS.CACHED_RULES);
        const encryptedRules = data[STORAGE_KEYS.CACHED_RULES];
        
        if (!encryptedRules) {
            throw new Error('No validation rules cached. Please sync first.');
        }
        
        // Validate document (import validation engine)
        const validationEngine = await import('./validation_engine.js');
        const results = await validationEngine.validateDocument(
            response.content,
            encryptedRules,
            {
                practice_area: practiceAreaSelect.value,
                specialization: specializationSelect.value,
                document_type: documentTypeSelect.value,
                jurisdiction_state: jurisdictionSelect.value
            }
        );
        
        // Display results
        displayResults(results);
        
    } catch (error) {
        console.error('Validation failed:', error);
        alert(`Validation failed: ${error.message}`);
    } finally {
        validateButton.disabled = false;
        validateButton.textContent = 'Validate Document';
    }
}

/**
 * Display validation results
 */
function displayResults(results) {
    validationResults.style.display = 'block';
    
    const { passed, failed, warnings } = results;
    
    let html = `
        <div class="results-summary">
            <div class="result-item result-passed">
                ✓ ${passed.length} Passed
            </div>
            <div class="result-item result-failed">
                ✗ ${failed.length} Failed
            </div>
            <div class="result-item result-warning">
                ⚠ ${warnings.length} Warnings
            </div>
        </div>
    `;
    
    // Show failed rules
    if (failed.length > 0) {
        html += '<div class="failed-rules"><h4>Failed Rules:</h4>';
        failed.forEach(rule => {
            html += `
                <div class="rule-item rule-failed">
                    <strong>${rule.validator_name}</strong>
                    <p>${rule.error_message}</p>
                </div>
            `;
        });
        html += '</div>';
    }
    
    // Show warnings
    if (warnings.length > 0) {
        html += '<div class="warning-rules"><h4>Warnings:</h4>';
        warnings.forEach(rule => {
            html += `
                <div class="rule-item rule-warning">
                    <strong>${rule.validator_name}</strong>
                    <p>${rule.warning_message}</p>
                </div>
            `;
        });
        html += '</div>';
    }
    
    resultsContent.innerHTML = html;
    
    // Scroll to results
    validationResults.scrollIntoView({ behavior: 'smooth' });
}

