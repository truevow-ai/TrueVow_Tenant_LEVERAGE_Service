/**
 * TrueVow DRAFT™ Word Add-In - Task Pane
 * Office.js integration for Microsoft Word
 * 
 * ZERO-KNOWLEDGE ARCHITECTURE:
 * - Document content extracted via Office.js
 * - Validation happens locally in Word
 * - Content never leaves the application
 */

Office.onReady((info) => {
    if (info.host === Office.HostType.Word) {
        console.log('TrueVow DRAFT™ Word Add-In loaded');
        initializeAddIn();
    }
});

// Global state
let cachedRules = null;
let settings = {
    // UPDATED: DRAFT is now integrated into Tenant App
    apiUrl: 'http://localhost:8000/api/v1',
    apiKey: ''
};

/**
 * Initialize add-in
 */
async function initializeAddIn() {
    // Load settings from local storage
    loadSettings();
    
    // Setup event listeners
    setupEventListeners();
    
    // Update document info
    await updateDocumentInfo();
    
    // Check sync status
    await updateSyncStatus();
    
    console.log('Add-in initialized');
}

/**
 * Setup event listeners
 */
function setupEventListeners() {
    // Sync button
    document.getElementById('syncButton').addEventListener('click', syncRules);
    
    // Validate button
    document.getElementById('validateButton').addEventListener('click', validateDocument);
    
    // Form changes
    document.getElementById('practiceArea').addEventListener('change', updateSpecializationOptions);
    document.getElementById('practiceArea').addEventListener('change', checkValidationReady);
    document.getElementById('documentType').addEventListener('change', checkValidationReady);
    
    // Settings
    document.getElementById('settingsLink').addEventListener('click', showSettings);
    document.getElementById('saveSettingsButton').addEventListener('click', saveSettings);
    document.getElementById('backButton').addEventListener('click', hideSettings);
}

/**
 * Load settings from local storage
 */
function loadSettings() {
    const stored = localStorage.getItem('truevow_settings');
    if (stored) {
        settings = JSON.parse(stored);
        document.getElementById('apiUrl').value = settings.apiUrl || '';
        document.getElementById('apiKey').value = settings.apiKey || '';
    }
    
    // Load cached rules
    const rules = localStorage.getItem('truevow_cached_rules');
    if (rules) {
        cachedRules = rules;
    }
}

/**
 * Save settings to local storage
 */
function saveSettings() {
    settings.apiUrl = document.getElementById('apiUrl').value;
    settings.apiKey = document.getElementById('apiKey').value;
    
    localStorage.setItem('truevow_settings', JSON.stringify(settings));
    
    showMessage('Settings saved successfully', 'success');
    hideSettings();
}

/**
 * Show settings panel
 */
function showSettings() {
    document.querySelector('.validation-section').style.display = 'none';
    document.getElementById('resultsSection').style.display = 'none';
    document.getElementById('settingsSection').style.display = 'block';
}

/**
 * Hide settings panel
 */
function hideSettings() {
    document.getElementById('settingsSection').style.display = 'none';
    document.querySelector('.validation-section').style.display = 'block';
}

/**
 * Update document info
 */
async function updateDocumentInfo() {
    try {
        await Word.run(async (context) => {
            const body = context.document.body;
            body.load('text');
            
            await context.sync();
            
            const text = body.text;
            const wordCount = text.trim().split(/\s+/).length;
            const charCount = text.length;
            
            document.getElementById('wordCount').textContent = 
                `${wordCount} words, ${charCount} characters`;
        });
    } catch (error) {
        console.error('Error updating document info:', error);
        document.getElementById('wordCount').textContent = 'Unable to load document info';
    }
}

/**
 * Update sync status
 */
async function updateSyncStatus() {
    const lastSync = localStorage.getItem('truevow_last_sync');
    
    if (lastSync && cachedRules) {
        const syncDate = new Date(lastSync);
        const now = new Date();
        const hoursSinceSync = (now - syncDate) / (1000 * 60 * 60);
        
        if (hoursSinceSync < 24) {
            updateStatus('synced', formatRelativeTime(syncDate));
        } else {
            updateStatus('needs-sync', 'Rules need updating');
        }
    } else {
        updateStatus('not-synced', 'Not synced');
    }
}

/**
 * Update status UI
 */
function updateStatus(status, message) {
    const indicator = document.getElementById('statusIndicator');
    const text = document.getElementById('statusText');
    
    indicator.className = 'status-indicator';
    indicator.classList.add(`status-${status}`);
    text.textContent = message;
}

/**
 * Update specialization options
 */
function updateSpecializationOptions() {
    const practiceArea = document.getElementById('practiceArea').value;
    const specializationSelect = document.getElementById('specialization');
    
    specializationSelect.innerHTML = '<option value="">Select...</option>';
    
    const specializations = {
        personal_injury: [
            { value: 'car_accident', label: 'Car Accident' },
            { value: 'medical_malpractice', label: 'Medical Malpractice' },
            { value: 'slip_and_fall', label: 'Slip and Fall' }
        ],
        family_law: [
            { value: 'divorce', label: 'Divorce' },
            { value: 'child_custody', label: 'Child Custody' },
            { value: 'adoption', label: 'Adoption' }
        ],
        criminal_law: [
            { value: 'dui', label: 'DUI' },
            { value: 'drug_crimes', label: 'Drug Crimes' },
            { value: 'theft', label: 'Theft' }
        ]
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
    const hasPracticeArea = document.getElementById('practiceArea').value;
    const hasDocumentType = document.getElementById('documentType').value;
    
    document.getElementById('validateButton').disabled = !(hasPracticeArea && hasDocumentType);
}

/**
 * Sync rules from server
 */
async function syncRules() {
    if (!settings.apiUrl || !settings.apiKey) {
        showMessage('Please configure API settings first', 'error');
        showSettings();
        return;
    }
    
    try {
        showLoading('Syncing validation rules...');
        
        updateStatus('syncing', 'Syncing...');
        
        // UPDATED: New endpoint /draft/sync/rules (GET instead of POST)
        const documentType = 'demand_letter'; // Default for Word documents
        const response = await fetch(`${settings.apiUrl}/draft/sync/rules?document_type=${documentType}`, {
            method: 'GET',
            headers: {
                'Authorization': `Bearer ${settings.apiKey}`,
                'Content-Type': 'application/json',
                'X-Client-Version': '1.0.0'
            }
        });
        
        if (!response.ok) {
            throw new Error(`Sync failed: ${response.statusText}`);
        }
        
        const data = await response.json();
        
        // Response format: { rules: [...], total_rules: N, version: "1.0.0" }
        cachedRules = data.rules || [];
        localStorage.setItem('truevow_cached_rules', JSON.stringify(cachedRules));
        localStorage.setItem('truevow_last_sync', new Date().toISOString());
        
        const rulesCount = data.total_rules || data.rules?.length || 0;
        updateStatus('synced', `Synced ${rulesCount} rules`);
        showMessage(`Successfully synced ${rulesCount} rules`, 'success');
        
    } catch (error) {
        updateStatus('error', 'Sync failed');
        showMessage(`Sync failed: ${error.message}`, 'error');
    } finally {
        hideLoading();
    }
}

/**
 * Validate document
 */
async function validateDocument() {
    if (!cachedRules) {
        showMessage('No validation rules cached. Please sync first.', 'error');
        return;
    }
    
    try {
        showLoading('Extracting document content...');
        
        // Extract document content using Office.js
        const documentContent = await extractDocumentContent();
        
        showLoading('Validating document...');
        
        // Prepare context
        const context = {
            practice_area: document.getElementById('practiceArea').value,
            specialization: document.getElementById('specialization').value,
            document_type: document.getElementById('documentType').value,
            jurisdiction_state: document.getElementById('jurisdiction').value
        };
        
        // Validate (using validation_engine.js)
        const results = await window.validateDocument(documentContent, cachedRules, context);
        
        // Display results
        displayResults(results);
        
        showMessage('Validation complete', 'success');
        
    } catch (error) {
        showMessage(`Validation failed: ${error.message}`, 'error');
    } finally {
        hideLoading();
    }
}

/**
 * Extract document content from Word
 */
async function extractDocumentContent() {
    return new Promise((resolve, reject) => {
        Word.run(async (context) => {
            try {
                const body = context.document.body;
                body.load('text');
                
                await context.sync();
                
                resolve(body.text);
            } catch (error) {
                reject(error);
            }
        }).catch(reject);
    });
}

/**
 * Display validation results
 */
function displayResults(results) {
    const resultsSection = document.getElementById('resultsSection');
    const summaryDiv = document.getElementById('resultsSummary');
    const detailsDiv = document.getElementById('resultsDetails');
    
    const { passed, failed, warnings } = results;
    
    // Summary
    summaryDiv.innerHTML = `
        <div class="result-cards">
            <div class="result-card result-passed">
                <div class="result-count">${passed.length}</div>
                <div class="result-label">Passed</div>
            </div>
            <div class="result-card result-failed">
                <div class="result-count">${failed.length}</div>
                <div class="result-label">Failed</div>
            </div>
            <div class="result-card result-warning">
                <div class="result-count">${warnings.length}</div>
                <div class="result-label">Warnings</div>
            </div>
        </div>
    `;
    
    // Details
    let detailsHTML = '';
    
    if (failed.length > 0) {
        detailsHTML += '<div class="failed-rules"><h3 class="ms-font-m">Failed Rules:</h3>';
        failed.forEach(rule => {
            detailsHTML += `
                <div class="rule-item rule-failed">
                    <strong class="ms-font-s">${rule.validator_name}</strong>
                    <p class="ms-font-xs">${rule.error_message}</p>
                </div>
            `;
        });
        detailsHTML += '</div>';
    }
    
    if (warnings.length > 0) {
        detailsHTML += '<div class="warning-rules"><h3 class="ms-font-m">Warnings:</h3>';
        warnings.forEach(rule => {
            detailsHTML += `
                <div class="rule-item rule-warning">
                    <strong class="ms-font-s">${rule.validator_name}</strong>
                    <p class="ms-font-xs">${rule.warning_message}</p>
                </div>
            `;
        });
        detailsHTML += '</div>';
    }
    
    if (failed.length === 0 && warnings.length === 0) {
        detailsHTML = '<div class="success-message"><p class="ms-font-m">✓ All validation checks passed!</p></div>';
    }
    
    detailsDiv.innerHTML = detailsHTML;
    resultsSection.style.display = 'block';
    
    // Scroll to results
    resultsSection.scrollIntoView({ behavior: 'smooth' });
}

/**
 * Show loading overlay
 */
function showLoading(text) {
    const overlay = document.getElementById('loadingOverlay');
    const loadingText = document.getElementById('loadingText');
    
    loadingText.textContent = text;
    overlay.style.display = 'flex';
}

/**
 * Hide loading overlay
 */
function hideLoading() {
    document.getElementById('loadingOverlay').style.display = 'none';
}

/**
 * Show message (simple alert for now)
 */
function showMessage(message, type) {
    // In production, use Office UI Fabric MessageBar
    console.log(`${type.toUpperCase()}: ${message}`);
    
    // Simple alert for now
    if (type === 'error') {
        alert(`Error: ${message}`);
    }
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

