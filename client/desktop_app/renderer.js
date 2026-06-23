/**
 * TrueVow DRAFT™ Desktop - Renderer Process
 * UI logic and user interactions
 */

const { ipcRenderer } = require('electron');
const axios = require('axios');
const validationEngine = require('./validation_engine');

// Global state
let currentFile = null;
let currentFileContent = null;
let cachedRules = null;
let settings = {};

// Initialize app when DOM is loaded
document.addEventListener('DOMContentLoaded', async () => {
    await initializeApp();
    setupEventListeners();
    setupMenuListeners();
});

/**
 * Initialize application
 */
async function initializeApp() {
    // Load settings
    settings = await ipcRenderer.invoke('get-settings');
    
    // Load cached rules
    cachedRules = await ipcRenderer.invoke('get-cached-rules');
    
    // Update sync status
    await updateSyncStatus();
    
    // Load settings into form
    loadSettingsToForm();
    
    console.log('TrueVow DRAFT Desktop initialized');
}

/**
 * Setup event listeners
 */
function setupEventListeners() {
    // Navigation
    document.querySelectorAll('.nav-item').forEach(item => {
        item.addEventListener('click', () => switchView(item.dataset.view));
    });
    
    // File selection
    document.getElementById('selectFileBtn').addEventListener('click', selectFile);
    document.getElementById('clearFileBtn').addEventListener('click', clearFile);
    
    // Drag & drop
    const dropZone = document.getElementById('dropZone');
    dropZone.addEventListener('dragover', handleDragOver);
    dropZone.addEventListener('drop', handleDrop);
    dropZone.addEventListener('dragleave', handleDragLeave);
    
    // Validation
    document.getElementById('validateBtn').addEventListener('click', validateDocument);
    
    // Sync
    document.getElementById('syncButton').addEventListener('click', syncRules);
    
    // Settings
    document.getElementById('saveSettingsBtn').addEventListener('click', saveSettings);
    
    // Form changes
    document.getElementById('practiceArea').addEventListener('change', updateSpecializationOptions);
    document.getElementById('practiceArea').addEventListener('change', checkValidationReady);
    document.getElementById('documentType').addEventListener('change', checkValidationReady);
}

/**
 * Setup menu listeners (from main process)
 */
function setupMenuListeners() {
    ipcRenderer.on('menu-open-file', selectFile);
    ipcRenderer.on('menu-validate', validateDocument);
    ipcRenderer.on('menu-sync-rules', syncRules);
    ipcRenderer.on('menu-open-settings', () => switchView('settings'));
    
    ipcRenderer.on('show-notification', (event, options) => {
        showToast(options.message, options.type || 'info');
    });
}

/**
 * Switch view
 */
function switchView(viewName) {
    // Update navigation
    document.querySelectorAll('.nav-item').forEach(item => {
        item.classList.toggle('active', item.dataset.view === viewName);
    });
    
    // Update views
    document.querySelectorAll('.view').forEach(view => {
        view.classList.toggle('active', view.id === `${viewName}View`);
    });
}

/**
 * Select file
 */
async function selectFile() {
    const result = await ipcRenderer.invoke('open-file-dialog');
    
    if (!result.canceled && result.filePaths.length > 0) {
        await loadFile(result.filePaths[0]);
    }
}

/**
 * Load file
 */
async function loadFile(filePath) {
    try {
        showToast('Loading file...', 'info');
        
        const result = await ipcRenderer.invoke('read-file', filePath);
        
        if (!result.success) {
            throw new Error(result.error);
        }
        
        currentFile = {
            path: filePath,
            name: filePath.split('\\').pop().split('/').pop(),
            size: require('fs').statSync(filePath).size,
            type: result.type
        };
        
        currentFileContent = result.content;
        
        // Update UI
        document.getElementById('dropZone').style.display = 'none';
        document.getElementById('selectedFile').style.display = 'block';
        document.getElementById('fileName').textContent = currentFile.name;
        document.getElementById('fileSize').textContent = formatFileSize(currentFile.size);
        
        checkValidationReady();
        
        showToast(`Loaded: ${currentFile.name}`, 'success');
        
    } catch (error) {
        showToast(`Failed to load file: ${error.message}`, 'error');
    }
}

/**
 * Clear file
 */
function clearFile() {
    currentFile = null;
    currentFileContent = null;
    
    document.getElementById('dropZone').style.display = 'flex';
    document.getElementById('selectedFile').style.display = 'none';
    document.getElementById('validationResults').style.display = 'none';
    
    checkValidationReady();
}

/**
 * Handle drag over
 */
function handleDragOver(e) {
    e.preventDefault();
    e.stopPropagation();
    e.currentTarget.classList.add('drag-over');
}

/**
 * Handle drag leave
 */
function handleDragLeave(e) {
    e.preventDefault();
    e.stopPropagation();
    e.currentTarget.classList.remove('drag-over');
}

/**
 * Handle drop
 */
async function handleDrop(e) {
    e.preventDefault();
    e.stopPropagation();
    e.currentTarget.classList.remove('drag-over');
    
    const files = Array.from(e.dataTransfer.files);
    
    if (files.length > 0) {
        await loadFile(files[0].path);
    }
}

/**
 * Check if validation can be performed
 */
function checkValidationReady() {
    const hasFile = currentFile !== null;
    const hasPracticeArea = document.getElementById('practiceArea').value;
    const hasDocumentType = document.getElementById('documentType').value;
    
    document.getElementById('validateBtn').disabled = !(hasFile && hasPracticeArea && hasDocumentType);
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
 * Validate document
 */
async function validateDocument() {
    if (!currentFileContent) {
        showToast('No document loaded', 'error');
        return;
    }
    
    if (!cachedRules) {
        showToast('No validation rules cached. Please sync first.', 'error');
        return;
    }
    
    try {
        const validateBtn = document.getElementById('validateBtn');
        validateBtn.disabled = true;
        validateBtn.textContent = 'Validating...';
        
        const context = {
            practice_area: document.getElementById('practiceArea').value,
            specialization: document.getElementById('specialization').value,
            document_type: document.getElementById('documentType').value,
            jurisdiction_state: document.getElementById('jurisdiction').value
        };
        
        const results = await validationEngine.validateDocument(
            currentFileContent,
            cachedRules,
            context
        );
        
        displayResults(results);
        
        // Log analytics (metadata only)
        if (settings.analyticsEnabled) {
            await validationEngine.logValidationEvent(results, context);
        }
        
        showToast('Validation complete', 'success');
        
    } catch (error) {
        showToast(`Validation failed: ${error.message}`, 'error');
    } finally {
        const validateBtn = document.getElementById('validateBtn');
        validateBtn.disabled = false;
        validateBtn.textContent = 'Validate Document';
    }
}

/**
 * Display validation results
 */
function displayResults(results) {
    const resultsDiv = document.getElementById('validationResults');
    const content = document.getElementById('resultsContent');
    
    const { passed, failed, warnings } = results;
    
    let html = `
        <div class="results-summary">
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
    
    content.innerHTML = html;
    resultsDiv.style.display = 'block';
    resultsDiv.scrollIntoView({ behavior: 'smooth' });
}

/**
 * Sync rules from server
 */
async function syncRules() {
    if (!settings.apiUrl || !settings.apiKey) {
        showToast('Please configure API settings first', 'error');
        switchView('settings');
        return;
    }
    
    try {
        const syncButton = document.getElementById('syncButton');
        syncButton.disabled = true;
        syncButton.textContent = 'Syncing...';
        
        updateStatus('syncing', 'Syncing validation rules...');
        
        // UPDATED: New endpoint /draft/sync/rules (GET instead of POST)
        const documentType = settings.defaultDocumentType || 'demand_letter';
        const response = await axios.get(
            `${settings.apiUrl}/draft/sync/rules?document_type=${documentType}`,
            {
                headers: {
                    'Authorization': `Bearer ${settings.apiKey}`,
                    'X-Client-Version': '1.0.0'
                }
            }
        );
        
        // Response format: { rules: [...], total_rules: N, version: "1.0.0" }
        cachedRules = response.data.rules || [];
        await ipcRenderer.invoke('save-cached-rules', cachedRules);
        
        const rulesCount = response.data.total_rules || response.data.rules?.length || 0;
        updateStatus('synced', `Synced ${rulesCount} rules`);
        showToast(`Successfully synced ${rulesCount} rules`, 'success');
        
    } catch (error) {
        updateStatus('error', 'Sync failed');
        showToast(`Sync failed: ${error.message}`, 'error');
    } finally {
        const syncButton = document.getElementById('syncButton');
        syncButton.disabled = false;
        syncButton.textContent = 'Sync Rules';
    }
}

/**
 * Update sync status
 */
async function updateSyncStatus() {
    const lastSync = await ipcRenderer.invoke('get-last-sync');
    
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
 * Load settings to form
 */
function loadSettingsToForm() {
    document.getElementById('apiUrl').value = settings.apiUrl || '';
    document.getElementById('apiKey').value = settings.apiKey || '';
    document.getElementById('autoSync').checked = settings.autoSync !== false;
    document.getElementById('syncInterval').value = settings.syncInterval || 24;
    document.getElementById('analyticsEnabled').checked = settings.analyticsEnabled !== false;
}

/**
 * Save settings
 */
async function saveSettings() {
    try {
        const newSettings = {
            apiUrl: document.getElementById('apiUrl').value,
            apiKey: document.getElementById('apiKey').value,
            autoSync: document.getElementById('autoSync').checked,
            syncInterval: parseInt(document.getElementById('syncInterval').value),
            analyticsEnabled: document.getElementById('analyticsEnabled').checked
        };
        
        const result = await ipcRenderer.invoke('save-settings', newSettings);
        
        if (result.success) {
            settings = newSettings;
            showToast('Settings saved successfully', 'success');
        } else {
            throw new Error(result.error);
        }
    } catch (error) {
        showToast(`Failed to save settings: ${error.message}`, 'error');
    }
}

/**
 * Show toast notification
 */
function showToast(message, type = 'info') {
    const toast = document.getElementById('toast');
    toast.textContent = message;
    toast.className = `toast toast-${type} show`;
    
    setTimeout(() => {
        toast.classList.remove('show');
    }, 3000);
}

/**
 * Format file size
 */
function formatFileSize(bytes) {
    if (bytes < 1024) return bytes + ' B';
    if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB';
    return (bytes / (1024 * 1024)).toFixed(1) + ' MB';
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

