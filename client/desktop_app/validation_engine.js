/**
 * TrueVow DRAFT™ - Client-Side Validation Engine
 * 
 * ZERO-KNOWLEDGE ARCHITECTURE:
 * - All validation happens locally in browser
 * - Document content NEVER sent to servers
 * - Rules are decrypted locally
 * 
 * 5-LEVEL HIERARCHICAL VALIDATOR SYSTEM:
 * Level 1: Universal Validators (ALL documents)
 * Level 2: Practice Area Validators
 * Level 3: Specialization Validators
 * Level 4: Document Type Validators
 * Level 5: Jurisdiction Validators
 */

/**
 * Decrypt validation rules (Fernet encryption)
 * 
 * Note: In production, use proper crypto library (crypto-js or similar)
 * This is a simplified implementation for demonstration
 */
async function decryptRules(encryptedRules, encryptionKey) {
    try {
        // In production: Use Fernet or AES-GCM decryption
        // For now, we'll assume rules are base64 encoded JSON
        const decoded = atob(encryptedRules);
        return JSON.parse(decoded);
    } catch (error) {
        console.error('Failed to decrypt rules:', error);
        throw new Error('Failed to decrypt validation rules');
    }
}

/**
 * Validate document against validation rules
 * 
 * @param {string} documentContent - Document content (plain text or HTML)
 * @param {string} encryptedRules - Encrypted validation rules
 * @param {object} context - Validation context (practice area, document type, etc.)
 * @returns {object} Validation results
 */
async function validateDocument(documentContent, encryptedRules, context) {
    // Decrypt rules (happens locally)
    const rules = await decryptRules(encryptedRules);
    
    // Filter rules by context
    const applicableRules = filterRulesByContext(rules, context);
    
    // Run validation
    const results = {
        passed: [],
        failed: [],
        warnings: [],
        total_checked: 0,
        execution_time_ms: 0
    };
    
    const startTime = performance.now();
    
    for (const rule of applicableRules) {
        results.total_checked++;
        
        const validationResult = await validateRule(documentContent, rule);
        
        if (validationResult.passed) {
            results.passed.push(rule);
        } else if (rule.severity === 'error') {
            results.failed.push({
                ...rule,
                ...validationResult
            });
        } else if (rule.severity === 'warning') {
            results.warnings.push({
                ...rule,
                ...validationResult
            });
        }
    }
    
    results.execution_time_ms = Math.round(performance.now() - startTime);
    
    return results;
}

/**
 * Filter rules by validation context
 */
function filterRulesByContext(rules, context) {
    const applicable = [];
    
    for (const rule of rules) {
        // Level 1: Universal validators (always apply)
        if (rule.validator_level === 1) {
            applicable.push(rule);
            continue;
        }
        
        // Level 2: Practice area validators
        if (rule.validator_level === 2 && rule.practice_area === context.practice_area) {
            applicable.push(rule);
            continue;
        }
        
        // Level 3: Specialization validators
        if (rule.validator_level === 3 && 
            rule.practice_area === context.practice_area &&
            rule.specialization === context.specialization) {
            applicable.push(rule);
            continue;
        }
        
        // Level 4: Document type validators
        if (rule.validator_level === 4 && 
            rule.document_type === context.document_type) {
            applicable.push(rule);
            continue;
        }
        
        // Level 5: Jurisdiction validators
        if (rule.validator_level === 5 && 
            rule.jurisdiction_state === context.jurisdiction_state) {
            applicable.push(rule);
            continue;
        }
    }
    
    return applicable;
}

/**
 * Validate a single rule against document
 */
async function validateRule(documentContent, rule) {
    const { validator_name, validator_config } = rule;
    
    // Route to appropriate validator
    switch (validator_name) {
        case 'statute_of_limitations':
            return validateStatuteOfLimitations(documentContent, validator_config);
        
        case 'required_fields':
            return validateRequiredFields(documentContent, validator_config);
        
        case 'signature_block':
            return validateSignatureBlock(documentContent, validator_config);
        
        case 'attorney_review':
            return validateAttorneyReview(documentContent, validator_config);
        
        case 'jurisdiction_check':
            return validateJurisdiction(documentContent, validator_config);
        
        case 'date_format':
            return validateDateFormat(documentContent, validator_config);
        
        case 'party_names':
            return validatePartyNames(documentContent, validator_config);
        
        case 'court_information':
            return validateCourtInformation(documentContent, validator_config);
        
        default:
            return validateGeneric(documentContent, rule);
    }
}

// ============================================================================
// VALIDATOR IMPLEMENTATIONS
// ============================================================================

/**
 * Validate statute of limitations
 */
function validateStatuteOfLimitations(documentContent, config) {
    // Check if document mentions incident date
    const hasIncidentDate = /incident\s+date|date\s+of\s+incident|occurred\s+on/i.test(documentContent);
    
    if (!hasIncidentDate) {
        return {
            passed: false,
            reason: 'Document does not reference incident date for statute of limitations verification'
        };
    }
    
    return { passed: true };
}

/**
 * Validate required fields
 */
function validateRequiredFields(documentContent, config) {
    const required = config.required_fields || [];
    const missing = [];
    
    for (const field of required) {
        const regex = new RegExp(field.replace(/_/g, '\\s+'), 'i');
        if (!regex.test(documentContent)) {
            missing.push(field);
        }
    }
    
    if (missing.length > 0) {
        return {
            passed: false,
            reason: `Missing required fields: ${missing.join(', ')}`
        };
    }
    
    return { passed: true };
}

/**
 * Validate signature block
 */
function validateSignatureBlock(documentContent, config) {
    // Check for signature indicators
    const hasSignature = /signature|signed|attorney\s+for|respectfully\s+submitted/i.test(documentContent);
    
    if (!hasSignature) {
        return {
            passed: false,
            reason: 'Document appears to be missing signature block'
        };
    }
    
    return { passed: true };
}

/**
 * Validate attorney review
 */
function validateAttorneyReview(documentContent, config) {
    // This is a compliance check - always requires manual review
    return {
        passed: false,
        reason: 'Attorney review required before filing (ABA Model Rule 1.1 - Competence)',
        severity: 'warning'
    };
}

/**
 * Validate jurisdiction
 */
function validateJurisdiction(documentContent, config) {
    const state = config.state;
    
    if (!state) {
        return { passed: true };
    }
    
    // Check if document mentions the jurisdiction
    const stateRegex = new RegExp(state, 'i');
    const hasJurisdiction = stateRegex.test(documentContent);
    
    if (!hasJurisdiction) {
        return {
            passed: false,
            reason: `Document does not reference jurisdiction (${state})`,
            severity: 'warning'
        };
    }
    
    return { passed: true };
}

/**
 * Validate date format
 */
function validateDateFormat(documentContent, config) {
    // Check for dates in various formats
    const dateRegex = /\b\d{1,2}\/\d{1,2}\/\d{2,4}\b|\b\d{1,2}-\d{1,2}-\d{2,4}\b|\b(?:January|February|March|April|May|June|July|August|September|October|November|December)\s+\d{1,2},?\s+\d{4}\b/g;
    
    const dates = documentContent.match(dateRegex);
    
    if (!dates || dates.length === 0) {
        return {
            passed: false,
            reason: 'No dates found in document',
            severity: 'warning'
        };
    }
    
    return { passed: true };
}

/**
 * Validate party names
 */
function validatePartyNames(documentContent, config) {
    // Check for party indicators
    const hasParties = /plaintiff|defendant|petitioner|respondent|appellant|appellee/i.test(documentContent);
    
    if (!hasParties) {
        return {
            passed: false,
            reason: 'Document does not identify parties',
            severity: 'warning'
        };
    }
    
    return { passed: true };
}

/**
 * Validate court information
 */
function validateCourtInformation(documentContent, config) {
    // Check for court identifiers
    const hasCourt = /court|tribunal|judge|honorable/i.test(documentContent);
    
    if (!hasCourt) {
        return {
            passed: false,
            reason: 'Document does not reference court or tribunal',
            severity: 'warning'
        };
    }
    
    return { passed: true };
}

/**
 * Generic validator (for custom rules)
 */
function validateGeneric(documentContent, rule) {
    // Basic pattern matching
    if (rule.validator_config.required_pattern) {
        const regex = new RegExp(rule.validator_config.required_pattern, 'i');
        const passed = regex.test(documentContent);
        
        return {
            passed,
            reason: passed ? null : `Pattern not found: ${rule.validator_config.required_pattern}`
        };
    }
    
    // If no specific validation logic, pass
    return { passed: true };
}

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

/**
 * Extract clean text from HTML document
 */
function extractTextFromHTML(html) {
    const parser = new DOMParser();
    const doc = parser.parseFromString(html, 'text/html');
    return doc.body.textContent || '';
}

/**
 * Calculate document statistics
 */
function calculateDocumentStats(content) {
    const words = content.split(/\s+/).length;
    const characters = content.length;
    const paragraphs = content.split(/\n\n+/).length;
    
    return {
        words,
        characters,
        paragraphs
    };
}

/**
 * Log validation event (metadata only - NO document content)
 */
async function logValidationEvent(results, context) {
    try {
        // Prepare analytics data (metadata only)
        const analyticsData = {
            event_type: 'validation_run',
            practice_area: context.practice_area,
            specialization: context.specialization,
            document_type: context.document_type,
            jurisdiction_state: context.jurisdiction_state,
            total_rules_checked: results.total_checked,
            rules_passed: results.passed.length,
            rules_failed: results.failed.length,
            rules_warned: results.warnings.length,
            failed_rule_ids: results.failed.map(r => r.id),
            validation_duration_ms: results.execution_time_ms,
            client_type: 'desktop_app',
            client_version: '1.0.0'
        };
        
        // Desktop app: would send to server if analytics enabled
        console.log('Analytics event:', analyticsData);
    } catch (error) {
        console.error('Failed to log validation event:', error);
        // Don't throw - analytics failure shouldn't block validation
    }
}

// Node.js exports
module.exports = {
    validateDocument,
    extractTextFromHTML,
    calculateDocumentStats,
    logValidationEvent
};

