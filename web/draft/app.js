// TrueVow DRAFT™ - Customer Portal Application Logic

// Toast Notification System
const Toast = {
    show(message, type = 'info', duration = 5000) {
        const container = document.getElementById('toastContainer');
        const toast = document.createElement('div');
        toast.className = `toast ${type}`;
        
        const icons = {
            success: '✓',
            error: '✗',
            warning: '⚠',
            info: 'ℹ'
        };
        
        toast.innerHTML = `
            <span class="toast-icon">${icons[type]}</span>
            <span class="toast-message">${message}</span>
            <button class="toast-close">×</button>
        `;
        
        container.appendChild(toast);
        
        // Auto dismiss
        const timer = setTimeout(() => {
            this.hide(toast);
        }, duration);
        
        // Manual dismiss
        toast.querySelector('.toast-close').addEventListener('click', () => {
            clearTimeout(timer);
            this.hide(toast);
        });
        
        return toast;
    },
    
    success(message, duration) {
        return this.show(message, 'success', duration);
    },
    
    error(message, duration) {
        return this.show(message, 'error', duration);
    },
    
    warning(message, duration) {
        return this.show(message, 'warning', duration);
    },
    
    info(message, duration) {
        return this.show(message, 'info', duration);
    },
    
    hide(toast) {
        toast.classList.add('hide');
        setTimeout(() => {
            if (toast.parentNode) {
                toast.parentNode.removeChild(toast);
            }
        }, 300);
    }
};

// Breadcrumb Navigation
const Breadcrumb = {
    update(path) {
        const trail = document.getElementById('breadcrumbTrail');
        const items = [
            { name: 'Home', path: '/' },
            ...path.map((item, index) => ({
                name: item,
                path: '#' + index
            }))
        ];
        
        trail.innerHTML = items.map((item, index) => 
            `<span class="breadcrumb-item ${index === items.length - 1 ? 'active' : ''}">
                ${item.name}
            </span>`
        ).join('');
    }
};

// Company Statistics
const CompanyStats = {
    stats: {
        docsValidated: 0,
        pendingReviews: 0,
        complianceRate: 0
    },
    
    updateStats() {
        document.getElementById('docsValidated').textContent = this.stats.docsValidated;
        document.getElementById('pendingReviews').textContent = this.stats.pendingReviews;
        document.getElementById('complianceRate').textContent = `${this.stats.complianceRate}%`;
    },
    
    incrementValidated() {
        this.stats.docsValidated++;
        this.updateComplianceRate();
        this.updateStats();
    },
    
    setPendingReviews(count) {
        this.stats.pendingReviews = count;
        this.updateStats();
    },
    
    updateComplianceRate() {
        if (this.stats.docsValidated > 0) {
            // In a real app, this would calculate from actual validation results
            this.stats.complianceRate = Math.min(100, 95 + Math.floor(Math.random() * 5));
        }
    }
};

// Initialize DRAFT client
const draftClient = new DraftClient({
    apiUrl: window.DRAFT_API_URL || 'http://localhost:8003',
    apiKey: window.DRAFT_API_KEY || ''
});

// Tab switching
document.querySelectorAll('.tab').forEach(tab => {
    tab.addEventListener('click', () => {
        const tabName = tab.dataset.tab;
        
        // Update active tab
        document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
        tab.classList.add('active');
        
        // Update active content
        document.querySelectorAll('.tab-content').forEach(content => {
            content.classList.remove('active');
        });
        document.getElementById(tabName).classList.add('active');
        
        // Update breadcrumb based on tab
        const tabTitles = {
            'validate': ['Validate Document'],
            'history': ['Validation History'],
            'rules': ['View Rules'],
            'tools': ['Download Tools']
        };
        Breadcrumb.update(tabTitles[tabName] || []);
        
        // Load content for tab
        loadTabContent(tabName);
        
        // Show tab change notification
        Toast.info(`Switched to ${tab.textContent} tab`);
    });
});

// Load content for specific tab
function loadTabContent(tabName) {
    switch(tabName) {
        case 'validate':
            // Already loaded
            break;
        case 'history':
            loadValidationHistory();
            break;
        case 'rules':
            loadValidationRules();
            break;
        case 'tools':
            loadInstallationInstructions();
            break;
    }
}

// File upload handling
const uploadArea = document.getElementById('uploadArea');
const fileInput = document.getElementById('fileInput');
const validateBtn = document.getElementById('validateBtn');

uploadArea.addEventListener('click', () => fileInput.click());
uploadArea.addEventListener('dragover', (e) => {
    e.preventDefault();
    uploadArea.style.borderColor = 'var(--primary)';
});
uploadArea.addEventListener('dragleave', () => {
    uploadArea.style.borderColor = 'var(--border)';
});
uploadArea.addEventListener('drop', (e) => {
    e.preventDefault();
    uploadArea.style.borderColor = 'var(--border)';
    const files = e.dataTransfer.files;
    if (files.length > 0) {
        handleFileSelect(files[0]);
    }
});

fileInput.addEventListener('change', (e) => {
    if (e.target.files.length > 0) {
        handleFileSelect(e.target.files[0]);
    }
});

function handleFileSelect(file) {
    // Update UI
    const placeholder = uploadArea.querySelector('.upload-placeholder');
    placeholder.innerHTML = `
        <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path>
            <polyline points="14 2 14 8 20 8"></polyline>
            <line x1="16" y1="13" x2="8" y2="13"></line>
            <line x1="16" y1="17" x2="8" y2="17"></line>
            <polyline points="10 9 9 9 8 9"></polyline>
        </svg>
        <p><strong>${file.name}</strong></p>
        <p class="file-types">${(file.size / 1024).toFixed(2)} KB</p>
    `;
    
    validateBtn.disabled = false;
    validateBtn.dataset.file = file.name;
    validateBtn.dataset.fileSize = file.size;
}

// Validation
validateBtn.addEventListener('click', async () => {
    const file = fileInput.files[0];
    if (!file) return;
    
    const documentType = document.getElementById('documentType').value;
    const jurisdiction = document.getElementById('jurisdiction').value;
    
    validateBtn.disabled = true;
    validateBtn.textContent = 'Validating...';
    
    // Show processing toast
    const processingToast = Toast.info('Processing document validation...', 0); // 0 = no auto-dismiss
    
    try {
        const result = await draftClient.validateFile(file, {
            document_type: documentType,
            jurisdiction: jurisdiction
        });
        
        // Hide processing toast
        Toast.hide(processingToast);
        
        // Show success toast
        Toast.success(`Document validated successfully! ${result.errors_count || 0} errors found.`);
        
        displayValidationResults(result);
        
        // Update company statistics
        CompanyStats.incrementValidated();
        CompanyStats.setPendingReviews(result.warnings_count || 0);
        
        // Save to history
        saveToHistory({
            filename: file.name,
            documentType: documentType,
            jurisdiction: jurisdiction,
            result: result,
            timestamp: new Date().toISOString()
        });
        
        // Update breadcrumb
        Breadcrumb.update(['Validate', 'Results']);
        
    } catch (error) {
        console.error('Validation error:', error);
        
        // Hide processing toast
        Toast.hide(processingToast);
        
        // Show error toast
        Toast.error(`Validation failed: ${error.message}`);
        
    } finally {
        validateBtn.disabled = false;
        validateBtn.textContent = 'Validate Document';
    }
});

function displayValidationResults(result) {
    const resultsDiv = document.getElementById('validationResults');
    const contentDiv = document.getElementById('resultsContent');
    
    resultsDiv.classList.remove('hidden');
    
    const passed = result.validation_passed;
    const errors = result.errors || [];
    const warnings = result.warnings || [];
    const info = result.info || [];
    
    contentDiv.innerHTML = `
        <div class="validation-result">
            <div class="result-header ${passed ? 'passed' : 'failed'}">
                <h3>${passed ? '✓ Validation Passed' : '✗ Validation Failed'}</h3>
            </div>
            
            <div class="result-stats">
                <div class="stat-card">
                    <div class="stat-value">${result.total_rules_checked || 0}</div>
                    <div class="stat-label">Rules Checked</div>
                </div>
                <div class="stat-card">
                    <div class="stat-value" style="color: var(--error)">${result.errors_count || 0}</div>
                    <div class="stat-label">Errors</div>
                </div>
                <div class="stat-card">
                    <div class="stat-value" style="color: var(--warning)">${result.warnings_count || 0}</div>
                    <div class="stat-label">Warnings</div>
                </div>
                <div class="stat-card">
                    <div class="stat-value" style="color: var(--info)">${result.info_count || 0}</div>
                    <div class="stat-label">Info</div>
                </div>
            </div>
            
            ${errors.length > 0 ? `
                <div class="errors-list">
                    <h4>Errors</h4>
                    ${errors.map(error => `
                        <div class="error-item">
                            <strong>${error.rule_name || 'Error'}</strong>
                            <p>${error.message || error.error_message || 'Validation error'}</p>
                        </div>
                    `).join('')}
                </div>
            ` : ''}
            
            ${warnings.length > 0 ? `
                <div class="warnings-list">
                    <h4>Warnings</h4>
                    ${warnings.map(warning => `
                        <div class="warning-item">
                            <strong>${warning.rule_name || 'Warning'}</strong>
                            <p>${warning.message || warning.warning_message || 'Validation warning'}</p>
                        </div>
                    `).join('')}
                </div>
            ` : ''}
            
            ${info.length > 0 ? `
                <div class="info-list">
                    <h4>Information</h4>
                    ${info.map(item => `
                        <div class="info-item">
                            <strong>${item.rule_name || 'Info'}</strong>
                            <p>${item.message || item.info_message || 'Information'}</p>
                        </div>
                    `).join('')}
                </div>
            ` : ''}
        </div>
    `;
    
    // Scroll to results
    resultsDiv.scrollIntoView({ behavior: 'smooth' });
}

// Validation History
async function loadValidationHistory() {
    const historyList = document.getElementById('historyList');
    historyList.innerHTML = '<div class="loading">Loading history...</div>';
    
    try {
        const history = getValidationHistory();
        
        if (history.length === 0) {
            historyList.innerHTML = '<p class="empty-state">No validation history yet</p>';
            return;
        }
        
        // Apply filters
        const searchTerm = document.getElementById('searchInput').value.toLowerCase();
        const filterType = document.getElementById('filterType').value;
        const dateFrom = document.getElementById('dateFrom').value;
        const dateTo = document.getElementById('dateTo').value;
        
        let filtered = history.filter(item => {
            if (searchTerm && !item.filename.toLowerCase().includes(searchTerm)) return false;
            if (filterType !== 'all' && item.documentType !== filterType) return false;
            if (dateFrom && item.timestamp < dateFrom) return false;
            if (dateTo && item.timestamp > dateTo) return false;
            return true;
        });
        
        historyList.innerHTML = filtered.map(item => `
            <div class="history-item">
                <div class="history-item-header">
                    <div class="history-item-title">${item.filename}</div>
                    <div class="history-item-date">${new Date(item.timestamp).toLocaleDateString()}</div>
                </div>
                <div class="history-item-meta">
                    <span>Type: ${item.documentType}</span>
                    <span>Jurisdiction: ${item.jurisdiction}</span>
                    <span>Status: ${item.result.validation_passed ? '✓ Passed' : '✗ Failed'}</span>
                </div>
            </div>
        `).join('');
        
    } catch (error) {
        console.error('Error loading history:', error);
        historyList.innerHTML = '<p class="empty-state">Error loading history</p>';
    }
}

// Validation Rules
async function loadValidationRules() {
    const rulesList = document.getElementById('rulesList');
    rulesList.innerHTML = '<div class="loading">Loading rules...</div>';
    
    try {
        const documentType = document.getElementById('ruleDocumentType').value;
        const practiceArea = document.getElementById('rulePracticeArea').value;
        const searchTerm = document.getElementById('ruleSearch').value.toLowerCase();
        
        const rules = await draftClient.getValidationRules({
            document_type: documentType || undefined,
            practice_area: practiceArea || undefined
        });
        
        let filtered = rules.rules || [];
        if (searchTerm) {
            filtered = filtered.filter(rule => 
                rule.rule_name.toLowerCase().includes(searchTerm) ||
                (rule.description && rule.description.toLowerCase().includes(searchTerm))
            );
        }
        
        if (filtered.length === 0) {
            rulesList.innerHTML = '<p class="empty-state">No rules found</p>';
            return;
        }
        
        rulesList.innerHTML = filtered.map(rule => `
            <div class="rule-card">
                <div class="rule-card-header">
                    <div class="rule-name">${rule.rule_name}</div>
                    <span class="rule-severity ${rule.severity}">${rule.severity}</span>
                </div>
                <div class="rule-description">
                    ${rule.description || 'No description available'}
                </div>
            </div>
        `).join('');
        
    } catch (error) {
        console.error('Error loading rules:', error);
        rulesList.innerHTML = '<p class="empty-state">Error loading rules</p>';
    }
}

// Download Tools
function downloadTool(toolType) {
    // In production, this would download the actual tool
    alert(`Downloading ${toolType} tool...`);
    
    // Update instructions
    loadInstallationInstructions(toolType);
}

function loadInstallationInstructions(toolType = 'browser') {
    const instructions = {
        browser: `
1. Download the browser extension ZIP file
2. Extract the ZIP file
3. Open Chrome/Edge and go to chrome://extensions/
4. Enable "Developer mode"
5. Click "Load unpacked" and select the extracted folder
6. The extension will appear in your browser toolbar
        `,
        desktop: `
1. Download the desktop application installer
2. Run the installer
3. Follow the installation wizard
4. Launch the application from your desktop
5. Sign in with your TrueVow credentials
        `,
        word: `
1. Download the Word add-in package
2. Open Microsoft Word
3. Go to Insert > Get Add-ins
4. Click "Upload My Add-in"
5. Select the downloaded manifest.xml file
6. The add-in will appear in the ribbon
        `
    };
    
    document.getElementById('instructions').textContent = instructions[toolType] || instructions.browser;
}

// Local storage helpers
function saveToHistory(item) {
    const history = getValidationHistory();
    history.unshift(item);
    // Keep only last 100 items
    if (history.length > 100) {
        history.pop();
    }
    localStorage.setItem('draft_validation_history', JSON.stringify(history));
}

function getValidationHistory() {
    const stored = localStorage.getItem('draft_validation_history');
    return stored ? JSON.parse(stored) : [];
}

// Filter event listeners
document.getElementById('searchInput')?.addEventListener('input', loadValidationHistory);
document.getElementById('filterType')?.addEventListener('change', loadValidationHistory);
document.getElementById('dateFrom')?.addEventListener('change', loadValidationHistory);
document.getElementById('dateTo')?.addEventListener('change', loadValidationHistory);

document.getElementById('ruleSearch')?.addEventListener('input', loadValidationRules);
document.getElementById('rulePracticeArea')?.addEventListener('change', loadValidationRules);
document.getElementById('ruleDocumentType')?.addEventListener('change', loadValidationRules);

// Initialize
window.addEventListener('DOMContentLoaded', () => {
    // Initialize enterprise features
    CompanyStats.updateStats();
    Breadcrumb.update(['Home']);
    
    // Show welcome toast
    Toast.success('Welcome to TrueVow DRAFT™ Enterprise Portal');
    
    // Load initial tab content
    loadTabContent('validate');
});
