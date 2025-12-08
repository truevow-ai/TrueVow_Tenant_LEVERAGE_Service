# TrueVow DRAFT™ Compliance Validator Module - Complete Documentation Summary

**Date:** December 5, 2025  
**Status:** Phase 3 (Future Module)  
**Source:** System Documentation Review

---

## 📋 **EXECUTIVE SUMMARY**

TrueVow DRAFT™ is a **compliance validation service** (Phase 3) that validates completed legal documents against attorney-configured rules. The service provides **client-side validation** to ensure Bar compliance and prevent malpractice, maintaining **zero-knowledge architecture** where documents never leave the attorney's device.

**Key Compliance Features:**
- ✅ Client-side validation (document never uploaded to TrueVow)
- ✅ Zero-knowledge architecture (TrueVow never sees document content)
- ✅ 5-level hierarchical validator system
- ✅ Required fields validator (statute of limitations, venue, jurisdiction)
- ✅ Citation audit requirement validator
- ✅ Local rule compliance validator
- ✅ Practice area, specialization, document type, jurisdiction validators

---

## 🎯 **MODULE FUNCTION**

**Primary Function:**
Validates completed legal documents (e.g., demand letters, pleadings) against attorney-configured validation rules using **client-side validation** (document never uploaded to TrueVow).

**Key Characteristics:**
- **Client-Side Validation:** Document validated locally on attorney's device
- **Zero-Knowledge Architecture:** Document never uploaded to TrueVow servers
- **Validation Rules Sync:** Rules synced to attorney's device (encrypted)
- **5-Level Hierarchical Validators:** Universal → Practice Area → Specialization → Document Type → Jurisdiction
- **Optional Template Assembly:** Supporting service (attorney manually enters all data)
- Does NOT conduct legal research
- Does NOT generate novel arguments
- Does NOT create legal conclusions, clauses, or strategy

---

## 🛡️ **COMPLIANCE VALIDATORS**

### **1. Mandatory "DRAFT ONLY" Watermark Validator**

**Requirement:**
Every document generated MUST include the following watermark on the first page:

```
"DRAFT – FOR ATTORNEY REVIEW ONLY. NOT FILED. NO WARRANTY OF ACCURACY. TRUEVOW IS NOT RESPONSIBLE FOR SUBSEQUENT EDITS."
```

**Validation Logic:**
- ✅ **Pre-Generation Check:** System validates watermark is present in template
- ✅ **Post-Generation Check:** System validates watermark appears on first page
- ✅ **Blocking:** Document cannot be exported/downloaded without watermark
- ✅ **Visual Indicator:** Watermark must be clearly visible (not hidden)

**Compliance Rule:**
- ABA Model Rule 1.1 (Competence)
- MSA Section 3.4 (All documents labeled as "DRAFTS")

**Error Handling:**
- If watermark missing: Document generation blocked
- Warning message: "Watermark required for Bar compliance"

---

### **2. Signature Block Lock-Out Validator**

**Requirement:**
The system pre-populates `[ATTORNEY NAME], [STATE] Bar No. _______` but **leaves the signature line blank**. Attorney must manually insert digital signature or wet sign.

**Validation Logic:**
- ✅ **Pre-Population:** System auto-fills attorney name and bar number
- ✅ **Signature Line:** MUST remain blank (no auto-signature)
- ✅ **Blocking:** Document cannot be finalized with blank signature
- ✅ **Review Enforcement:** Forces attorney review before signing

**Compliance Rule:**
- ABA Model Rule 1.1 (Competence - non-delegable duty to review)
- Malpractice prevention (prevents filing unreviewed documents)

**Error Handling:**
- If signature line pre-filled: Document generation blocked
- Warning message: "Signature line must remain blank to force attorney review"

---

### **3. Citation Audit Requirement Validator**

**Requirement:**
Attorney MUST run citation-check software (e.g., Lexis BriefCheck) on every pleading. DRAFT pulls only public Westlaw headnotes and may miss negative history.

**Validation Logic:**
- ✅ **Citation Source Warning:** System displays warning about Westlaw-only citations
- ✅ **Negative History Warning:** System warns about potential missing negative history
- ✅ **Audit Checklist:** System provides checklist for attorney to complete
- ✅ **Documentation:** System logs that citation audit was recommended

**Compliance Rule:**
- ABA Model Rule 1.1 (Competence - proper legal research)
- Shepardizing requirement (checking case history)

**Warning Messages:**
- "⚠️ Citation Audit Required: DRAFT pulls only public Westlaw headnotes and may miss negative history. You must run citation-check software (e.g., Lexis BriefCheck) before filing."
- "⚠️ This document contains citations that have not been Shepardized. Attorney review required."

---

### **4. Local Rule Overlay Validator**

**Requirement:**
Some districts (e.g., S.D.N.Y. Local Civ. R. 11.2) require counsel's e-mail address in the caption. DRAFT inserts a placeholder — **attorney must replace it**.

**Validation Logic:**
- ✅ **Placeholder Detection:** System identifies placeholder fields in template
- ✅ **Jurisdiction Check:** System checks if jurisdiction has local rule requirements
- ✅ **Warning Display:** System displays warning about placeholder fields
- ✅ **Replacement Tracking:** System tracks which placeholders were replaced

**Compliance Rule:**
- Local court rules (varies by jurisdiction)
- ABA Model Rule 1.1 (Competence - following court rules)

**Warning Messages:**
- "⚠️ Local Rule Overlay: This jurisdiction requires counsel's e-mail address in the caption. Please replace placeholder with your actual e-mail address."
- "⚠️ Placeholder Detected: [PLACEHOLDER_FIELD] must be replaced before filing."

---

### **5. Template Safety Validator**

**Requirement:**
DRAFT populates **attorney-provided templates** with **safe fields only** (client name, date, venue). No legal conclusions, clauses, or strategy are generated.

**Validation Logic:**
- ✅ **Template Source Check:** System validates template is attorney-provided (not AI-generated)
- ✅ **Field Safety Check:** System validates only safe fields are populated (name, date, venue)
- ✅ **Content Generation Block:** System blocks generation of legal conclusions, clauses, or strategy
- ✅ **Logic Validation:** System validates only attorney-defined logic is applied

**Safe Fields (Allowed):**
- Client name
- Date
- Venue
- Case number (if provided)
- Attorney name
- Bar number

**Prohibited Fields (Blocked):**
- Legal conclusions
- Legal clauses
- Legal strategy
- Novel arguments
- Legal research results

**Compliance Rule:**
- ABA Model Rule 5.5 (Unauthorized Practice of Law)
- System does NOT practice law - only assembles documents

**Error Handling:**
- If unsafe field detected: Document generation blocked
- Warning message: "Unsafe field detected. Only safe fields (name, date, venue) are allowed."

---

### **6. Attorney Review Requirement Validator**

**Requirement:**
Attorney bears **non-delegable duty** to review, edit, and certify the accuracy, completeness, and appropriateness of every document before filing or sending.

**Validation Logic:**
- ✅ **Review Status Tracking:** System tracks document review status (draft, reviewed, certified)
- ✅ **Certification Requirement:** System requires attorney certification before document can be finalized
- ✅ **Edit History:** System logs all edits made by attorney
- ✅ **Review Time Tracking:** System tracks time between generation and review

**Compliance Rule:**
- ABA Model Rule 1.1 (Competence - non-delegable duty)
- MSA Section 3.4 (Attorney review required)

**Critical Warning:**
> **"Reliance on DRAFT™ without independent attorney review is a breach of your ethical duty of competence."**

**Workflow:**
1. Document generated with "DRAFT" watermark
2. Attorney reviews document
3. Attorney makes edits (if needed)
4. Attorney certifies document (checkboxes required)
5. Document status changes to "reviewed" or "certified"
6. Document can be finalized/exported

---

## ⚖️ **ETHICAL COMPLIANCE FRAMEWORK**

### **ABA Model Rule 1.1 (Competence)**

**Risk:**
Attorney might file unreviewed documents, resulting in malpractice.

**Safeguards:**
- ✅ All documents explicitly labeled as "DRAFTS" (MSA 3.4)
- ✅ Attorney bears non-delegable duty to review, edit, certify before filing
- ✅ TrueVow DRAFT is a modern, efficient typewriter, not a legal strategist
- ✅ Signature block lock-out forces review
- ✅ Citation audit required
- ✅ Watermark on every page

**Compliance Status:** ✅ Compliant

---

### **ABA Model Rule 5.5 (Unauthorized Practice of Law)**

**Risk:**
Document assembly might constitute practicing law.

**Safeguards:**
- ✅ System applies logic set by attorney
- ✅ Does NOT conduct legal research
- ✅ Does NOT generate novel arguments
- ✅ Automates assembly based on pre-approved patterns
- ✅ Populates attorney-provided templates with safe fields only
- ✅ No legal conclusions, clauses, or strategy generated

**Compliance Status:** ✅ Compliant

---

### **Malpractice Prevention**

**Risk:**
Filing unreviewed documents could result in malpractice claims.

**Safeguards:**
- ✅ Signature block lock-out (forces review)
- ✅ Citation audit required
- ✅ Watermark on every page
- ✅ Attorney review requirement
- ✅ Certification workflow

**Compliance Status:** ✅ Compliant

---

## 📝 **REQUIRED DISCLOSURES & WARNINGS**

### **Mandatory Watermark Text**

Every document MUST include:

```
"DRAFT – FOR ATTORNEY REVIEW ONLY. NOT FILED. NO WARRANTY OF ACCURACY. TRUEVOW IS NOT RESPONSIBLE FOR SUBSEQUENT EDITS."
```

### **Critical Warning Statement**

Every document MUST include:

```
"⚠️ CRITICAL WARNING: Reliance on DRAFT™ without independent attorney review is a breach of your ethical duty of competence."
```

### **Client Disclosure (If Applicable)**

When using DRAFT-generated documents with clients:

```
"2. Document Drafting (TrueVow DRAFT™): If retained, we may use the TrueVow DRAFT module to generate initial drafts of legal documents (e.g., initial complaints, letters). These documents are raw, preliminary drafts only. Our licensed attorney is required to review, edit, verify the accuracy, and certify the final document before it is used in your representation or filed with any court. The attorney is solely responsible for the content and legal sufficiency of any final document."
```

---

## 🏗️ **VALIDATOR ARCHITECTURE - HIERARCHICAL STRUCTURE**

### **Validator Hierarchy (5 Levels)**

The DRAFT compliance validators are organized in a **hierarchical structure** to ensure maximum compliance coverage:

```
Level 1: Universal Validators (ALL documents)
    ↓
Level 2: Practice Area Validators (e.g., Personal Injury, Family Law)
    ↓
Level 3: Specialization Validators (e.g., Car Accident, Divorce)
    ↓
Level 4: Document Type Validators (e.g., Demand Letter, Pleading, Contract)
    ↓
Level 5: Jurisdiction/Court Validators (e.g., State, County, Court-specific rules)
```

### **Level 1: Universal Validators (Apply to ALL Documents)**

**These validators run for EVERY document, regardless of practice area, specialization, or document type:**

1. ✅ **Required Fields Validator** (statute of limitations, venue, jurisdiction)
2. ✅ **Document Completeness Validator** (all required sections present)
3. ✅ **Attorney Review Requirement Validator** (attorney must review before filing)
4. ✅ **Citation Presence Validator** (citations present if required)

**Why Universal:**
- These are Bar compliance requirements that apply to ALL legal documents
- No exceptions - every document must have required fields, completeness check, attorney review

---

### **Level 2: Practice Area Validators**

**Different practice areas have different compliance requirements:**

#### **Personal Injury Validators:**
- ✅ **Statute of Limitations Check** (varies by state, typically 2-4 years)
- ✅ **Medical Records Requirement** (HIPAA compliance)
- ✅ **Insurance Disclosure Requirements** (varies by state)
- ✅ **Comparative Fault Rules** (varies by state - pure, modified, contributory)
- ✅ **PIP Coverage Requirements** (no-fault states)
- ✅ **Expert Witness Requirements** (medical malpractice cases)

#### **Family Law Validators:**
- ✅ **Child Custody Disclosure Requirements** (varies by state)
- ✅ **Financial Disclosure Requirements** (asset disclosure, income verification)
- ✅ **Domestic Violence Reporting** (mandatory reporting in some states)
- ✅ **Mediation Requirements** (mandatory in some jurisdictions)
- ✅ **Parenting Plan Requirements** (specific format requirements)

#### **Criminal Law Validators:**
- ✅ **Miranda Rights Disclosure** (constitutional requirement)
- ✅ **Statute of Limitations Check** (varies by crime type)
- ✅ **Bail/Bond Requirements** (varies by jurisdiction)
- ✅ **Discovery Deadlines** (Brady disclosure requirements)
- ✅ **Plea Agreement Requirements** (specific format requirements)

#### **Corporate Law Validators:**
- ✅ **SEC Filing Requirements** (if applicable)
- ✅ **State Corporate Law Compliance** (varies by state)
- ✅ **Contract Statute of Frauds** (varies by state)
- ✅ **Intellectual Property Registration** (federal requirements)
- ✅ **Merger/Acquisition Disclosure** (SEC requirements)

#### **Immigration Law Validators:**
- ✅ **USCIS Form Requirements** (specific forms required)
- ✅ **Deadline Compliance** (strict deadlines, no extensions)
- ✅ **Document Translation Requirements** (certified translations)
- ✅ **Fee Payment Requirements** (USCIS fee schedule)
- ✅ **Biometric Requirements** (fingerprinting, photos)

---

### **Level 3: Specialization Validators (Within Practice Area)**

**Within each practice area, specializations have unique requirements:**

#### **Personal Injury - Car Accident:**
- ✅ **Auto Insurance Policy Limits** (state minimum requirements)
- ✅ **PIP Coverage Validation** (no-fault states)
- ✅ **Uninsured Motorist Coverage** (varies by state)
- ✅ **Police Report Requirements** (when required)
- ✅ **Vehicle Damage Documentation** (photos, estimates)

#### **Personal Injury - Medical Malpractice:**
- ✅ **Certificate of Merit Requirements** (required in many states)
- ✅ **Expert Witness Qualifications** (same specialty requirement)
- ✅ **Medical Board Notification** (some states require)
- ✅ **Statute of Limitations** (often shorter, 1-2 years)
- ✅ **Pre-Suit Notice Requirements** (some states require)

#### **Family Law - Divorce:**
- ✅ **Residency Requirements** (varies by state, 6 months to 1 year)
- ✅ **Grounds for Divorce** (fault vs. no-fault states)
- ✅ **Property Division Rules** (community property vs. equitable distribution)
- ✅ **Spousal Support Calculations** (state-specific formulas)
- ✅ **Child Support Guidelines** (state-specific calculations)

#### **Family Law - Child Custody:**
- ✅ **Best Interest Factors** (state-specific factors)
- ✅ **Parenting Plan Requirements** (specific format, content)
- ✅ **Visitation Schedule Requirements** (standard vs. custom)
- ✅ **Relocation Notice Requirements** (varies by state)
- ✅ **Grandparent Rights** (varies by state)

---

### **Level 4: Document Type Validators**

**Different document types have different compliance requirements:**

#### **Demand Letters:**
- ✅ **Pre-Suit Notice Requirements** (some states require before filing)
- ✅ **Settlement Offer Format** (specific language requirements)
- ✅ **Time Limits** (response deadlines)
- ✅ **Mediation Requirements** (some states require before suit)
- ✅ **Good Faith Requirements** (some states require)

#### **Pleadings (Complaints, Answers, Motions):**
- ✅ **Court-Specific Formatting** (margins, font, line spacing)
- ✅ **Caption Requirements** (party names, case numbers, court name)
- ✅ **Signature Requirements** (attorney signature, bar number)
- ✅ **Service Requirements** (proof of service, service deadlines)
- ✅ **Filing Fee Requirements** (court filing fees)
- ✅ **Local Rule Compliance** (court-specific rules)
- ✅ **Citation Format** (Bluebook, state-specific citation rules)

#### **Discovery Documents:**
- ✅ **Response Deadlines** (typically 30 days, varies by jurisdiction)
- ✅ **Objection Requirements** (specific objection language)
- ✅ **Privilege Log Requirements** (when withholding documents)
- ✅ **Expert Disclosure Deadlines** (varies by court)
- ✅ **Deposition Notice Requirements** (time, place, witness)

#### **Contracts:**
- ✅ **Statute of Frauds Compliance** (written requirement for certain contracts)
- ✅ **Consideration Requirements** (valid consideration)
- ✅ **Governing Law Clauses** (state law selection)
- ✅ **Venue/Forum Selection** (jurisdiction clauses)
- ✅ **Severability Clauses** (if required)

#### **Motions:**
- ✅ **Motion Type Requirements** (summary judgment, dismissal, etc.)
- ✅ **Supporting Affidavit Requirements** (when required)
- ✅ **Brief Page Limits** (court-specific limits)
- ✅ **Hearing Notice Requirements** (time, place, judge)
- ✅ **Opposition Deadlines** (typically 14-21 days)

---

### **Level 5: Jurisdiction/Court Validators**

**The most specific level - jurisdiction and court-specific rules:**

#### **State-Level Validators:**
- ✅ **State Statute of Limitations** (varies by state and claim type)
- ✅ **State Court Rules** (state-specific procedural rules)
- ✅ **State Bar Requirements** (state bar number format)
- ✅ **State Filing Fees** (varies by state and document type)
- ✅ **State Service Requirements** (state-specific service rules)

#### **County-Level Validators:**
- ✅ **County-Specific Rules** (some counties have additional rules)
- ✅ **County Filing Requirements** (county-specific procedures)
- ✅ **County Fee Schedules** (varies by county)

#### **Court-Level Validators:**
- ✅ **Federal Court Rules** (FRCP - Federal Rules of Civil Procedure)
- ✅ **State Court Rules** (state-specific rules)
- ✅ **Local Court Rules** (court-specific rules, e.g., S.D.N.Y. Local Civ. R. 11.2)
- ✅ **Judge-Specific Requirements** (standing orders, preferences)
- ✅ **Court Formatting Requirements** (margins, font, line spacing, page limits)

#### **Example: S.D.N.Y. Local Rule 11.2**
- ✅ **Email Address in Caption** (required in caption)
- ✅ **Placeholder Detection** (system identifies placeholder)
- ✅ **Replacement Warning** (system warns attorney to replace)

---

## 🔧 **TECHNICAL IMPLEMENTATION REQUIREMENTS**

### **Validator Resolution Algorithm**

**When generating a document, the system applies validators in this order:**

1. **Universal Validators** (Level 1) - Always run
2. **Practice Area Validators** (Level 2) - Based on selected practice area
3. **Specialization Validators** (Level 3) - Based on selected specialization
4. **Document Type Validators** (Level 4) - Based on document type
5. **Jurisdiction/Court Validators** (Level 5) - Based on jurisdiction and court

**Example: Personal Injury - Car Accident - Demand Letter - Maricopa County, AZ**

```
Universal Validators:
  ✅ Watermark present
  ✅ Signature line blank
  ✅ Attorney review required
  ✅ Safe fields only

Practice Area Validators (Personal Injury):
  ✅ Statute of limitations check (AZ: 2 years)
  ✅ Medical records requirement (HIPAA)
  ✅ Insurance disclosure (AZ requirements)

Specialization Validators (Car Accident):
  ✅ Auto insurance policy limits (AZ minimum: $15k/$30k)
  ✅ PIP coverage (AZ is no-fault state)
  ✅ Police report requirements

Document Type Validators (Demand Letter):
  ✅ Pre-suit notice (AZ requires 60 days)
  ✅ Settlement offer format
  ✅ Time limits (response deadline)

Jurisdiction Validators (Maricopa County, AZ):
  ✅ AZ state court rules
  ✅ Maricopa County local rules
  ✅ AZ filing fee requirements
```

### **Client-Side Validation Workflow**

**Primary Workflow (Compliance Validation):**

1. **Attorney Completes Document**
   - Attorney completes document locally (Word, PDF, etc.)
   - Document stays on attorney's device (never uploaded to TrueVow)
   - Attorney opens DRAFT validation tool (browser extension/desktop app/Word add-in)

2. **Validation Rules Sync**
   - Validation rules synced from DRAFT service (encrypted, one-time or periodic)
   - Rules stored locally on attorney's device
   - System identifies: Practice Area, Specialization, Document Type, Jurisdiction
   - System loads applicable validators (Levels 1-5)

3. **Client-Side Validation**
   - Document content extracted locally (in browser/app memory)
   - Validation engine runs locally (on attorney's device)
   - All 5 levels of validators applied:
     - ✅ **Level 1:** Required fields present, document complete
     - ✅ **Level 2:** Practice area requirements met
     - ✅ **Level 3:** Specialization requirements met
     - ✅ **Level 4:** Document type requirements met
     - ✅ **Level 5:** Jurisdiction/court requirements met
   - Document content processed in memory only (ephemeral)
   - Document content never sent to TrueVow servers

4. **Validation Results Display**
   - Results shown locally (red/yellow/green flags)
   - Missing fields list displayed
   - Compliance issues flagged
   - Results never sent to TrueVow (zero-knowledge maintained)

5. **Attorney Review & Fix**
   - Attorney reviews validation results locally
   - Attorney fixes issues in document
   - Attorney re-validates if needed
   - Attorney files document when validation passes

**Optional Workflow (Template Assembly - Supporting Service):**

1. **Template Selection**
   - Attorney selects template from library
   - Attorney manually enters all data (from consultation notes)
   - DRAFT assembles document (ephemeral processing, not stored)

2. **Document Assembly (Ephemeral)**
   - System populates template with attorney-provided data
   - Document assembled in memory only
   - Document returned to attorney
   - Memory cleared immediately (no storage)

3. **Attorney Completes & Validates**
   - Attorney reviews and edits assembled document
   - Attorney completes document
   - Attorney validates using client-side validation (primary workflow above)

---

### **Database Schema (Proposed - Hierarchical Validators)**

**⚠️ CRITICAL: NO DOCUMENT CONTENT STORED**

```sql
-- Validation rules table (stores validation rules, NOT document content)
CREATE TABLE draft_validation_rules (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Hierarchical identifiers
    validator_level TEXT NOT NULL,  -- 'universal', 'practice_area', 'specialization', 'document_type', 'jurisdiction'
    practice_area TEXT,  -- nullable (only for practice_area level and below)
    specialization TEXT,  -- nullable (only for specialization level and below)
    document_type TEXT,  -- nullable (only for document_type level and below)
    jurisdiction_state TEXT,  -- nullable (only for jurisdiction level)
    jurisdiction_county TEXT,  -- nullable (only for jurisdiction level)
    court_name TEXT,  -- nullable (only for jurisdiction level)
    
    -- Validator configuration
    validator_name TEXT NOT NULL,  -- 'statute_of_limitations', 'local_rule_11.2', etc.
    validator_type TEXT NOT NULL,  -- 'check', 'warning', 'blocking', 'requirement'
    validator_config JSONB NOT NULL,  -- validator-specific configuration
    error_message TEXT,  -- error message if validation fails
    warning_message TEXT,  -- warning message if validation passes but warning needed
    
    -- Status
    status TEXT DEFAULT 'active',  -- 'active', 'archived'
    priority INTEGER DEFAULT 0,  -- Higher priority validators run first
    
    -- Metadata
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- Usage analytics table (NO document content, only metadata)
CREATE TABLE draft_validation_analytics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL,
    
    -- Document metadata (NOT content)
    document_type TEXT NOT NULL,  -- 'demand_letter', 'pleading', etc.
    practice_area TEXT NOT NULL,
    specialization TEXT,
    jurisdiction_state TEXT NOT NULL,
    jurisdiction_county TEXT,
    
    -- Validation results (NOT document content)
    validation_status TEXT NOT NULL,  -- 'passed', 'failed', 'warnings'
    missing_fields TEXT[],  -- List of missing fields (not field values)
    validation_errors TEXT[],  -- List of errors (not document content)
    validation_warnings TEXT[],  -- List of warnings (not document content)
    
    -- Metadata
    validated_at TIMESTAMPTZ DEFAULT now(),
    validation_duration_ms INTEGER  -- Performance tracking
);

-- Templates table (attorney's work product, NOT client data)
CREATE TABLE draft_templates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL,
    
    -- Template metadata
    template_name TEXT NOT NULL,
    practice_area TEXT NOT NULL,
    document_type TEXT NOT NULL,
    
    -- Template content (attorney's work product, not client data)
    template_content TEXT NOT NULL,  -- Template with placeholders
    safe_fields TEXT[] NOT NULL,  -- List of safe fields allowed
    
    -- Status
    status TEXT DEFAULT 'active',
    created_at TIMESTAMPTZ DEFAULT now()
);

-- NOTE: NO table for document content - documents never stored!
    
    -- Validation status (all levels)
    validation_status TEXT DEFAULT 'pending',  -- 'pending', 'passed', 'failed'
    
    -- Level 1: Universal validators
    watermark_validated BOOLEAN DEFAULT FALSE,
    signature_validated BOOLEAN DEFAULT FALSE,
    field_safety_validated BOOLEAN DEFAULT FALSE,
    
    -- Level 2: Practice area validators
    practice_area_validated BOOLEAN DEFAULT FALSE,
    practice_area_errors TEXT[],
    practice_area_warnings TEXT[],
    
    -- Level 3: Specialization validators
    specialization_validated BOOLEAN DEFAULT FALSE,
    specialization_errors TEXT[],
    specialization_warnings TEXT[],
    
    -- Level 4: Document type validators
    document_type_validated BOOLEAN DEFAULT FALSE,
    document_type_errors TEXT[],
    document_type_warnings TEXT[],
    
    -- Level 5: Jurisdiction/court validators
    jurisdiction_validated BOOLEAN DEFAULT FALSE,
    local_rule_warning_displayed BOOLEAN DEFAULT FALSE,
    jurisdiction_errors TEXT[],
    jurisdiction_warnings TEXT[],
    
    -- Review workflow
    review_status TEXT DEFAULT 'draft',  -- 'draft', 'reviewed', 'certified', 'finalized'
    reviewed_by UUID,
    reviewed_at TIMESTAMPTZ,
    certified_by UUID,
    certified_at TIMESTAMPTZ,
    
    -- Metadata
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now(),
    finalized_at TIMESTAMPTZ
);

-- Document templates table
CREATE TABLE draft_templates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL,
    template_name TEXT NOT NULL,
    
    -- Hierarchical identifiers
    practice_area TEXT NOT NULL,
    specialization TEXT,  -- nullable
    document_type TEXT NOT NULL,
    jurisdiction_state TEXT,  -- nullable (if multi-state template)
    jurisdiction_county TEXT,  -- nullable
    court_name TEXT,  -- nullable
    
    -- Template content
    template_content TEXT NOT NULL,
    
    -- Validation requirements
    watermark_required BOOLEAN DEFAULT TRUE,
    signature_block_required BOOLEAN DEFAULT TRUE,
    safe_fields_only BOOLEAN DEFAULT TRUE,
    
    -- Status
    status TEXT DEFAULT 'active',  -- 'active', 'archived'
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- Validator rules table (stores validation rules for each level)
CREATE TABLE draft_validator_rules (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Hierarchical identifiers
    validator_level TEXT NOT NULL,  -- 'universal', 'practice_area', 'specialization', 'document_type', 'jurisdiction'
    practice_area TEXT,  -- nullable (only for practice_area level and below)
    specialization TEXT,  -- nullable (only for specialization level and below)
    document_type TEXT,  -- nullable (only for document_type level and below)
    jurisdiction_state TEXT,  -- nullable (only for jurisdiction level)
    jurisdiction_county TEXT,  -- nullable (only for jurisdiction level)
    court_name TEXT,  -- nullable (only for jurisdiction level)
    
    -- Validator configuration
    validator_name TEXT NOT NULL,  -- 'statute_of_limitations', 'local_rule_11.2', etc.
    validator_type TEXT NOT NULL,  -- 'check', 'warning', 'blocking', 'requirement'
    validator_config JSONB NOT NULL,  -- validator-specific configuration
    error_message TEXT,  -- error message if validation fails
    warning_message TEXT,  -- warning message if validation passes but warning needed
    
    -- Status
    status TEXT DEFAULT 'active',  -- 'active', 'archived'
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- Document validation log (tracks all validation checks)
CREATE TABLE draft_validation_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    document_id UUID NOT NULL REFERENCES draft_documents(id),
    validator_rule_id UUID NOT NULL REFERENCES draft_validator_rules(id),
    
    -- Validation check
    validator_level TEXT NOT NULL,
    validator_name TEXT NOT NULL,
    validation_passed BOOLEAN,
    validation_result TEXT,  -- 'passed', 'failed', 'warning'
    error_message TEXT,
    warning_message TEXT,
    
    -- Metadata
    validated_at TIMESTAMPTZ DEFAULT now(),
    validated_by UUID
);

-- Indexes for performance
CREATE INDEX idx_draft_documents_practice_area ON draft_documents(practice_area);
CREATE INDEX idx_draft_documents_specialization ON draft_documents(specialization);
CREATE INDEX idx_draft_documents_document_type ON draft_documents(document_type);
CREATE INDEX idx_draft_documents_jurisdiction ON draft_documents(jurisdiction_state, jurisdiction_county);
CREATE INDEX idx_draft_templates_hierarchy ON draft_templates(practice_area, specialization, document_type, jurisdiction_state);
CREATE INDEX idx_draft_validator_rules_hierarchy ON draft_validator_rules(validator_level, practice_area, specialization, document_type, jurisdiction_state);
```

---

## 🚨 **CRITICAL WARNINGS & INDEMNIFICATION**

### **Attorney Indemnity - DRAFT Module**

**YOU INDEMNIFY TRUEVOW AGAINST ALL CLAIMS ARISING FROM:**

- ❌ Filing unreviewed documents generated by DRAFT
- ❌ Errors, omissions, or inaccuracies in generated documents
- ❌ Citation errors or citing overruled/distinguished cases
- ❌ Local rule violations or formatting errors
- ❌ Reliance on document templates without professional judgment
- ❌ Malpractice claims related to document quality or content

---

### **Malpractice Carrier Notice**

**Required Action:**
Add DRAFT usage to your next malpractice insurance application or renewal. Carriers now ask specifically about "AI or automated drafting tools."

---

## 📊 **COMPLIANCE CHECKLIST**

### **Pre-Generation Checklist**

- [ ] Template is attorney-provided (not AI-generated)
- [ ] Template includes mandatory watermark
- [ ] Template includes signature block (with blank signature line)
- [ ] Only safe fields will be populated
- [ ] No legal conclusions, clauses, or strategy in template

### **Post-Generation Checklist**

- [ ] Watermark appears on first page
- [ ] Signature line is blank
- [ ] Only safe fields populated
- [ ] Placeholders identified for local rule requirements
- [ ] Citation warnings displayed
- [ ] Document marked as "DRAFT"

### **Pre-Filing Checklist**

- [ ] Attorney reviewed document
- [ ] Attorney made edits (if needed)
- [ ] Attorney certified document
- [ ] Citation audit completed (if applicable)
- [ ] Local rule placeholders replaced
- [ ] Watermark removed (if finalizing)
- [ ] Signature added manually

---

## 📚 **DOCUMENTATION SOURCES**

### **Primary Sources**

1. **Bar Compliance Documentation**
   - Location: `web/bar-compliance.html`
   - Section: 6. TrueVow DRAFT™ — Document Assembly
   - Lines: 658-723

2. **Bar Submission Memorandum**
   - Location: `web/BAR_SUBMISSION_MEMORANDUM.md`
   - Section: 3.2 TrueVow DRAFT™ (Document Assembly)
   - Lines: 68-85

3. **Main Technical Documentation**
   - Location: `TrueVow-Complete System-Technical-Documentation.md`
   - Section: D.5 Phase 3: AI Legal Document Assembly (TrueVow Draft™)
   - Line: 1566

### **Secondary Sources**

1. **Bar Compliance Comprehensive Analysis**
   - Location: `archive_before_website_separation/web_backup_2025-11-06/BAR_COMPLIANCE_COMPREHENSIVE_ANALYSIS.md`
   - Section: DRAFT Module (9 improvements)
   - Lines: 194-222

2. **Client Disclosure Template**
   - Location: `web/CLIENT_DISCLOSURE_TEMPLATE.md`
   - Contains DRAFT module disclosure language

---

## 🎯 **IMPLEMENTATION STATUS**

**Current Status:** Phase 3 (Future Module)

**Roadmap:**
- Phase 1: ✅ INTAKE (Complete)
- Phase 2: SaaS Admin Panel (In Progress)
- Phase 3: DRAFT Module (Planned)
- Phase 3: SETTLE Module (Planned)
- Phase 4: CONNECT Module (Architecture Complete)

**DRAFT Module Status:**
- ✅ Compliance framework defined
- ✅ Validator requirements specified
- ✅ Database schema proposed
- ⏳ Implementation pending (Phase 3)

---

## 📝 **SUMMARY**

The TrueVow DRAFT™ Compliance Validator Service provides **client-side validation** with a **5-level hierarchical validator system**:

**Primary Service: Compliance Validation (Client-Side)**
- ✅ Document validated locally on attorney's device (never uploaded)
- ✅ Zero-knowledge architecture (TrueVow never sees document content)
- ✅ Validation rules synced to device (encrypted)
- ✅ Results shown locally (never sent to TrueVow)

**5-Level Hierarchical Validator System:**
1. **Level 1: Universal Validators** - Required fields, document completeness, attorney review
2. **Level 2: Practice Area Validators** - Practice area-specific requirements (statute of limitations, HIPAA, etc.)
3. **Level 3: Specialization Validators** - Specialization-specific requirements (PIP coverage, expert witnesses, etc.)
4. **Level 4: Document Type Validators** - Document type-specific requirements (formatting, deadlines, citations)
5. **Level 5: Jurisdiction/Court Validators** - State, county, court-specific rules

**Optional Supporting Service: Template Assembly**
- ✅ Template-based document assembly (ephemeral processing, not stored)
- ✅ Attorney manually enters all data (from consultation)
- ✅ Document assembled in memory only (never stored)

**Compliance Status:** ✅ All validators designed to meet ABA Model Rules 1.1 and 5.5

**Critical Requirement:** Zero-knowledge architecture - documents must never be uploaded to TrueVow servers. All validation runs client-side.

---

**Last Updated:** December 5, 2025  
**Status:** Documentation Complete - Ready for Phase 3 Implementation

