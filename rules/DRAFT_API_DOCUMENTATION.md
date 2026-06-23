# TrueVow DRAFT™ Service - API Documentation

**Service:** DRAFT (Document Review and Automated Filing Tool)  
**Version:** 1.0.0  
**Port:** 8003  
**Base URL:** `http://localhost:8003/api/v1`  
**Last Updated:** December 21, 2025

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Authentication](#authentication)
3. [Endpoint Summary](#endpoint-summary)
4. [Admin Endpoints (SaaS Admin)](#admin-endpoints-saas-admin)
5. [Tenant Endpoints (Law Firms)](#tenant-endpoints-law-firms)
6. [Validation Rules Endpoints](#validation-rules-endpoints)
7. [Email Validation Endpoints](#email-validation-endpoints)
8. [Error Codes](#error-codes)
9. [Rate Limits](#rate-limits)
10. [Integration Guide for SaaS Admin](#integration-guide-for-saas-admin)

---

## Overview

The TrueVow DRAFT™ Service provides document validation rules management for legal compliance. It follows a **zero-knowledge architecture** where:

- ✅ Documents are validated **client-side only**
- ✅ Document content **never** leaves the attorney's device
- ✅ Only validation rules and metadata are transmitted
- ✅ ABA Model Rules compliant

### Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         SaaS Admin                              │
│                    (Global Templates)                           │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │ Proxy APIs → /api/v1/tenant/draft/* → DRAFT Service         ││
│  └─────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      DRAFT Service (:8003)                      │
│  ┌──────────────────────┐  ┌──────────────────────┐             │
│  │  Global Templates    │  │   Tenant Rules       │             │
│  │  (Admin Only)        │  │   (Law Firms)        │             │
│  └──────────────────────┘  └──────────────────────┘             │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Client Devices                             │
│  ┌───────────────┐  ┌───────────────┐  ┌───────────────┐       │
│  │ Browser Ext.  │  │  Desktop App  │  │   Word Add-in │       │
│  │ (Validation)  │  │  (Validation) │  │  (Validation) │       │
│  └───────────────┘  └───────────────┘  └───────────────┘       │
│                    Documents stay HERE                          │
└─────────────────────────────────────────────────────────────────┘
```

---

## Authentication

### API Key Header

All endpoints require API key authentication:

```http
Authorization: Bearer draft_live_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

**OR** (alternative for SaaS Admin integration):

```http
X-API-Key: draft_live_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

### Access Levels

| Level | Description | Endpoints |
|-------|-------------|-----------|
| `admin` | SaaS Admin (global templates) | `/api/v1/admin/*` |
| `tenant` | Law Firm (tenant-specific rules) | `/api/v1/tenant/*`, `/api/v1/validation-rules/*` |
| `external` | Pay-per-use (limited access) | Future use |

### API Key Format

```
draft_live_<40_random_chars>
```

Example: `draft_live_a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0`

---

## Endpoint Summary

### All Endpoints (34 total)

| # | Method | Path | Description | Access |
|---|--------|------|-------------|--------|
| **ADMIN - Global Rule Templates** |
| 1 | GET | `/admin/rule-templates` | List global templates | admin |
| 2 | GET | `/admin/rule-templates/{id}` | Get template details | admin |
| 3 | POST | `/admin/rule-templates` | Create template | admin |
| 4 | PUT | `/admin/rule-templates/{id}` | Update template | admin |
| 5 | DELETE | `/admin/rule-templates/{id}` | Archive template | admin |
| 6 | GET | `/admin/rule-templates/library/browse` | Browse template library | admin |
| 7 | GET | `/admin/rule-templates/health` | Health check | admin |
| **ADMIN - Legacy** |
| 8 | POST | `/admin/validation-rules` | Create validation rule | admin |
| 9 | GET | `/admin/validation-rules` | List validation rules | admin |
| 10 | PUT | `/admin/validation-rules/{id}` | Update validation rule | admin |
| 11 | DELETE | `/admin/validation-rules/{id}` | Archive validation rule | admin |
| 12 | POST | `/admin/templates` | Create document template | admin |
| 13 | GET | `/admin/templates` | List document templates | admin |
| 14 | GET | `/admin/compliance/report` | Generate compliance report | admin |
| 15 | GET | `/admin/compliance/aba-status` | Get ABA compliance status | admin |
| 16 | GET | `/admin/analytics/validation-usage` | Get validation analytics | admin |
| **TENANT - Rules Management** |
| 17 | GET | `/tenant/rules` | List tenant rules | tenant |
| 18 | GET | `/tenant/rules/{id}` | Get rule details | tenant |
| 19 | POST | `/tenant/rules` | Create tenant rule | tenant |
| 20 | PUT | `/tenant/rules/{id}` | Update rule | tenant |
| 21 | DELETE | `/tenant/rules/{id}` | Archive rule | tenant |
| 22 | GET | `/tenant/rules/by-document-type` | List rules by document type | tenant |
| 23 | GET | `/tenant/rules/health` | Health check | tenant |
| **TENANT - Template Inheritance** |
| 24 | GET | `/tenant/rule-templates` | Browse available templates | tenant |
| 25 | GET | `/tenant/rule-templates/{id}` | Get template details | tenant |
| 26 | POST | `/tenant/rule-templates/{id}/inherit` | Inherit template | tenant |
| 27 | GET | `/tenant/rule-templates/health` | Health check | tenant |
| **TENANT - Rule Selection** |
| 28 | POST | `/tenant/validate/select-rules` | Select rules for validation | tenant |
| 29 | GET | `/tenant/validate/enabled-rules` | Get enabled rules | tenant |
| 30 | GET | `/tenant/validate/health` | Health check | tenant |
| **VALIDATION RULES - Sync** |
| 31 | POST | `/validation-rules/sync` | Sync validation rules | tenant |
| 32 | GET | `/validation-rules/{id}` | Get validation rule | tenant |
| 33 | POST | `/validation-rules/check-updates` | Check for updates | tenant |
| 34 | GET | `/validation-rules/health` | Health check | tenant |
| **EMAIL VALIDATION** |
| 35 | POST | `/email/validation-context` | Get validation context | tenant |
| 36 | POST | `/email/validation-log` | Log validation | tenant |
| 37 | GET | `/email/validation-history` | Get validation history | tenant |
| 38 | GET | `/email/validation-stats` | Get validation stats | tenant |
| 39 | GET | `/email/health` | Health check | tenant |
| **HEALTH** |
| 40 | GET | `/health` | API health check | any |

---

## Admin Endpoints (SaaS Admin)

### 1. List Global Rule Templates

```http
GET /api/v1/admin/rule-templates
Authorization: Bearer {admin_api_key}
```

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `validator_level` | int | No | Filter by level (1-5) |
| `practice_area` | string | No | Filter by practice area |
| `specialization` | string | No | Filter by specialization |
| `document_type` | string | No | Filter by document type |
| `jurisdiction_state` | string | No | Filter by state (2 letters) |
| `status` | string | No | Filter by status (active/archived) |
| `skip` | int | No | Pagination offset (default: 0) |
| `limit` | int | No | Results per page (default: 100, max: 500) |

**Response:**

```json
{
  "templates": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440001",
      "template_name": "Universal Document Structure Validator",
      "template_description": "Validates basic document structure",
      "validator_level": 1,
      "validator_name": "document_structure",
      "validator_type": "structure",
      "practice_area": null,
      "specialization": null,
      "document_type": null,
      "jurisdiction_state": null,
      "validator_config": {
        "required_sections": ["header", "body", "signature"],
        "max_pages": 100
      },
      "error_message": "Document structure is invalid",
      "warning_message": null,
      "severity": "error",
      "version": 1,
      "is_active": true,
      "created_at": "2025-12-21T10:00:00Z",
      "updated_at": "2025-12-21T10:00:00Z"
    }
  ],
  "total_count": 150,
  "skip": 0,
  "limit": 100,
  "has_more": true
}
```

---

### 2. Get Global Rule Template

```http
GET /api/v1/admin/rule-templates/{id}
Authorization: Bearer {admin_api_key}
```

**Path Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Template ID |

**Response:**

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440001",
  "template_name": "Arizona Demand Letter Format",
  "template_description": "Format requirements for AZ demand letters",
  "validator_level": 5,
  "validator_name": "az_demand_letter_format",
  "validator_type": "format",
  "practice_area": "personal_injury",
  "specialization": "car_accident",
  "document_type": "demand_letter",
  "jurisdiction_state": "AZ",
  "jurisdiction_county": null,
  "jurisdiction_court": null,
  "validator_config": {
    "required_sections": ["header", "facts", "liability", "damages", "settlement_demand"],
    "font_size_min": 10,
    "font_size_max": 14,
    "margin_inches": 1.0
  },
  "error_message": "Document does not comply with Arizona demand letter format",
  "warning_message": "Consider adding medical records summary",
  "info_message": null,
  "severity": "error",
  "version": 3,
  "is_active": true,
  "inheritance_count": 45,
  "created_at": "2025-12-21T10:00:00Z",
  "updated_at": "2025-12-21T12:30:00Z"
}
```

---

### 3. Create Global Rule Template

```http
POST /api/v1/admin/rule-templates
Authorization: Bearer {admin_api_key}
Content-Type: application/json
```

**Request Body:**

```json
{
  "template_name": "Arizona Demand Letter Format",
  "template_description": "Format requirements for AZ demand letters",
  "validator_level": 5,
  "validator_name": "az_demand_letter_format",
  "validator_type": "format",
  "practice_area": "personal_injury",
  "specialization": "car_accident",
  "document_type": "demand_letter",
  "jurisdiction_state": "AZ",
  "jurisdiction_county": "Maricopa",
  "jurisdiction_court": null,
  "validator_config": {
    "required_sections": ["header", "facts", "liability", "damages", "settlement_demand"],
    "font_size_min": 10,
    "font_size_max": 14,
    "margin_inches": 1.0
  },
  "error_message": "Document does not comply with Arizona demand letter format",
  "warning_message": "Consider adding medical records summary",
  "info_message": null,
  "severity": "error"
}
```

**Response (201 Created):**

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440002",
  "template_name": "Arizona Demand Letter Format",
  "version": 1,
  "created_at": "2025-12-21T14:00:00Z"
}
```

---

### 4. Update Global Rule Template

```http
PUT /api/v1/admin/rule-templates/{id}
Authorization: Bearer {admin_api_key}
Content-Type: application/json
```

**Request Body (partial update):**

```json
{
  "template_description": "Updated description",
  "validator_config": {
    "required_sections": ["header", "facts", "liability", "damages", "settlement_demand", "attorney_fees"],
    "font_size_min": 11,
    "font_size_max": 14,
    "margin_inches": 1.0
  },
  "error_message": "Updated error message"
}
```

**Response:**

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440002",
  "version": 2,
  "updated_at": "2025-12-21T15:00:00Z"
}
```

---

### 5. Archive Global Rule Template

```http
DELETE /api/v1/admin/rule-templates/{id}
Authorization: Bearer {admin_api_key}
```

**Response:**

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440002",
  "archived_at": "2025-12-21T16:00:00Z"
}
```

---

### 6. Browse Template Library

```http
GET /api/v1/admin/rule-templates/library/browse
Authorization: Bearer {admin_api_key}
```

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `practice_area` | string | No | Filter by practice area |
| `document_type` | string | No | Filter by document type |
| `jurisdiction_state` | string | No | Filter by state |
| `category` | string | No | Filter by category (popular/recent/recommended) |

**Response:**

```json
{
  "categories": {
    "popular": [
      {
        "id": "...",
        "template_name": "Universal Document Structure",
        "inheritance_count": 250
      }
    ],
    "recent": [
      {
        "id": "...",
        "template_name": "California Probate Filing",
        "created_at": "2025-12-20T10:00:00Z"
      }
    ],
    "recommended": [
      {
        "id": "...",
        "template_name": "Level 1 - Universal Validators",
        "validator_level": 1
      }
    ]
  }
}
```

---

## Tenant Endpoints (Law Firms)

### 17. List Tenant Rules

```http
GET /api/v1/tenant/rules
Authorization: Bearer {tenant_api_key}
```

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `document_type` | string | No | Filter by document type |
| `practice_area` | string | No | Filter by practice area |
| `status` | string | No | Filter by status (active/archived) |
| `skip` | int | No | Pagination offset (default: 0) |
| `limit` | int | No | Results per page (default: 100) |

**Response:**

```json
{
  "rules": [
    {
      "id": "660e8400-e29b-41d4-a716-446655440001",
      "tenant_id": "770e8400-e29b-41d4-a716-446655440001",
      "rule_name": "Custom AZ Demand Letter Format",
      "validator_level": 5,
      "validator_name": "az_demand_letter_format",
      "validator_config": {
        "required_sections": ["header", "facts", "liability", "damages", "settlement_demand", "firm_custom_section"]
      },
      "is_active": true,
      "is_customized": true,
      "inherited_from_template_id": "550e8400-e29b-41d4-a716-446655440001"
    }
  ],
  "total_count": 25,
  "skip": 0,
  "limit": 100,
  "has_more": false
}
```

---

### 26. Inherit Template

```http
POST /api/v1/tenant/rule-templates/{id}/inherit
Authorization: Bearer {tenant_api_key}
Content-Type: application/json
```

**Request Body:**

```json
{
  "customize": true,
  "customizations": {
    "rule_name": "Custom Arizona Demand Letter Format",
    "validator_config": {
      "required_sections": ["header", "facts", "liability", "damages", "settlement_demand", "firm_custom_section"],
      "font_size_min": 11,
      "font_size_max": 14
    },
    "error_message": "Custom error message for our firm"
  }
}
```

**Response (201 Created):**

```json
{
  "rule_id": "660e8400-e29b-41d4-a716-446655440002",
  "template_id": "550e8400-e29b-41d4-a716-446655440001",
  "inherited_at": "2025-12-21T17:00:00Z",
  "is_customized": true
}
```

---

## Validation Rules Endpoints

### 31. Sync Validation Rules (Client)

```http
POST /api/v1/validation-rules/sync
Authorization: Bearer {tenant_api_key}
Content-Type: application/json
```

**Request Body:**

```json
{
  "practice_area": "personal_injury",
  "specialization": "car_accident",
  "document_type": "demand_letter",
  "jurisdiction_state": "AZ",
  "jurisdiction_county": "Maricopa",
  "include_universal": true,
  "client_type": "browser_extension",
  "client_version": "1.0.0",
  "device_id": "device_123",
  "session_id": "880e8400-e29b-41d4-a716-446655440001"
}
```

**Response:**

```json
{
  "validation_rules": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440001",
      "validator_level": 1,
      "validator_name": "document_structure",
      "validator_config": {...}
    }
  ],
  "rules_count": 15,
  "rules_version": 42,
  "sync_timestamp": "2025-12-21T18:00:00Z",
  "encrypted": true,
  "encrypted_rules": "gAAAAABh...",
  "filters_applied": {
    "practice_area": "personal_injury",
    "jurisdiction_state": "AZ"
  },
  "sync_metadata": {
    "client_type": "browser_extension",
    "sync_duration_ms": 45
  }
}
```

---

## Email Validation Endpoints

### 35. Get Email Validation Context

```http
POST /api/v1/email/validation-context
Authorization: Bearer {tenant_api_key}
Content-Type: application/json
```

**Request Body:**

```json
{
  "practice_area": "personal_injury",
  "specialization": "car_accident",
  "document_type": "demand_letter",
  "jurisdiction_state": "AZ",
  "jurisdiction_county": "Maricopa",
  "tenant_id": "770e8400-e29b-41d4-a716-446655440001"
}
```

**Response:**

```json
{
  "rules": [...],
  "context": {
    "practice_area": "personal_injury",
    "document_type": "demand_letter",
    "jurisdiction_state": "AZ"
  },
  "encryption": {
    "algorithm": "Fernet",
    "key_id": "key_001"
  },
  "source": "draft_service"
}
```

---

### 36. Log Email Validation

```http
POST /api/v1/email/validation-log
Authorization: Bearer {tenant_api_key}
Content-Type: application/json
```

**Request Body:**

```json
{
  "tenant_id": "770e8400-e29b-41d4-a716-446655440001",
  "user_id": "880e8400-e29b-41d4-a716-446655440001",
  "practice_area": "personal_injury",
  "document_type": "demand_letter",
  "jurisdiction_state": "AZ",
  "validation_passed": true,
  "validation_result": {
    "errors": [],
    "warnings": ["Consider adding medical records summary"],
    "rules_checked": 15,
    "rules_passed": 14,
    "rules_failed": 0,
    "duration_ms": 125
  },
  "email_metadata": {
    "sender": "attorney@lawfirm.com",
    "date": "2025-12-21T10:00:00Z",
    "subject": "RE: Case 12345"
  },
  "client_info": {
    "client_type": "customer_portal",
    "client_version": "2.0.0"
  }
}
```

**Response:**

```json
{
  "success": true,
  "message": "Validation metadata logged successfully"
}
```

---

## Error Codes

### HTTP Status Codes

| Code | Description |
|------|-------------|
| 200 | Success |
| 201 | Created |
| 400 | Bad Request (invalid input) |
| 401 | Unauthorized (invalid/missing API key) |
| 403 | Forbidden (insufficient permissions) |
| 404 | Not Found |
| 422 | Unprocessable Entity (validation error) |
| 429 | Too Many Requests (rate limit exceeded) |
| 500 | Internal Server Error |

### Error Response Format

```json
{
  "detail": "Human-readable error message",
  "error_code": "VALIDATION_ERROR",
  "field": "validator_level"
}
```

### Common Error Codes

| Code | Description |
|------|-------------|
| `INVALID_API_KEY` | API key is invalid or expired |
| `ADMIN_ACCESS_REQUIRED` | Endpoint requires admin API key |
| `TENANT_ACCESS_REQUIRED` | Endpoint requires tenant API key |
| `VALIDATION_ERROR` | Request validation failed |
| `RESOURCE_NOT_FOUND` | Requested resource not found |
| `DUPLICATE_RESOURCE` | Resource already exists |
| `RATE_LIMIT_EXCEEDED` | Too many requests |

---

## Rate Limits

### Default Limits

| Access Level | Per Minute | Per Hour |
|--------------|------------|----------|
| Admin | 100 | 1000 |
| Tenant | 60 | 600 |
| External | 10 | 100 |

### Rate Limit Headers

```http
X-RateLimit-Limit: 60
X-RateLimit-Remaining: 45
X-RateLimit-Reset: 1703178600
```

---

## Integration Guide for SaaS Admin

### 1. Create Proxy Routes

For each DRAFT endpoint, create a proxy in SaaS Admin:

```typescript
// Example: Next.js API route
// app/api/v1/tenant/draft/rules/route.ts

import { NextRequest, NextResponse } from 'next/server';

const DRAFT_SERVICE_URL = process.env.DRAFT_SERVICE_URL || 'http://localhost:8003';

export async function GET(request: NextRequest) {
  // 1. Validate tenant_id from session
  const tenantId = request.headers.get('X-Tenant-ID');
  if (!tenantId || !isValidUUID(tenantId)) {
    return NextResponse.json({ error: 'Invalid tenant_id' }, { status: 400 });
  }
  
  // 2. Get DRAFT API key from secure storage
  const apiKey = await getSecureApiKey('DRAFT_SERVICE_API_KEY');
  
  // 3. Forward request to DRAFT service
  const response = await fetch(`${DRAFT_SERVICE_URL}/api/v1/tenant/rules`, {
    method: 'GET',
    headers: {
      'Authorization': `Bearer ${apiKey}`,
      'X-Tenant-ID': tenantId,
      'Content-Type': 'application/json',
    },
    signal: AbortSignal.timeout(10000), // 10s timeout
  });
  
  // 4. Return response
  const data = await response.json();
  return NextResponse.json(data, { status: response.status });
}
```

### 2. Proxy Endpoint Mapping

| SaaS Admin Route | DRAFT Service Route |
|------------------|---------------------|
| `GET /api/v1/tenant/draft/rules` | `GET /api/v1/tenant/rules` |
| `GET /api/v1/tenant/draft/rules/{id}` | `GET /api/v1/tenant/rules/{id}` |
| `POST /api/v1/tenant/draft/rules` | `POST /api/v1/tenant/rules` |
| `PUT /api/v1/tenant/draft/rules/{id}` | `PUT /api/v1/tenant/rules/{id}` |
| `DELETE /api/v1/tenant/draft/rules/{id}` | `DELETE /api/v1/tenant/rules/{id}` |
| `GET /api/v1/tenant/draft/templates` | `GET /api/v1/tenant/rule-templates` |
| `POST /api/v1/tenant/draft/templates/{id}/apply` | `POST /api/v1/tenant/rule-templates/{id}/inherit` |
| `POST /api/v1/tenant/draft/validation/log` | `POST /api/v1/email/validation-log` |
| `GET /api/v1/tenant/draft/validation/history` | `GET /api/v1/email/validation-history` |
| `GET /api/v1/tenant/draft/sync/rules` | `POST /api/v1/validation-rules/sync` |
| `GET /api/v1/tenant/draft/analytics` | `GET /api/v1/admin/analytics/validation-usage` |

### 3. Security Requirements

Before building proxies, ensure:

1. **UUID Validation** - Validate all `tenant_id` and resource IDs as RFC 4122 UUIDs
2. **API Key Header** - Use `X-API-Key` header for service-to-service auth
3. **Request Size Limits** - 5MB max for document validation requests
4. **Timeout Configuration** - 10 second max timeout
5. **Error Sanitization** - Don't expose internal DRAFT errors to clients
6. **Audit Logging** - Log all requests for compliance

### 4. Example: Full Integration Pattern

```typescript
// middleware/draft-proxy.ts

import { validateUUID, sanitizeError, logAudit } from './security';

interface ProxyConfig {
  maxBodySize: number;
  timeout: number;
  retries: number;
}

const DEFAULT_CONFIG: ProxyConfig = {
  maxBodySize: 5 * 1024 * 1024, // 5MB
  timeout: 10000, // 10s
  retries: 2,
};

export async function proxyToDraft(
  method: string,
  path: string,
  tenantId: string,
  body?: any,
  config: ProxyConfig = DEFAULT_CONFIG
) {
  // 1. Validate tenant_id
  if (!validateUUID(tenantId)) {
    throw new Error('Invalid tenant_id format');
  }
  
  // 2. Build request
  const url = `${process.env.DRAFT_SERVICE_URL}/api/v1${path}`;
  const headers = {
    'Authorization': `Bearer ${process.env.DRAFT_API_KEY}`,
    'X-Tenant-ID': tenantId,
    'Content-Type': 'application/json',
  };
  
  // 3. Execute with timeout
  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), config.timeout);
  
  try {
    const response = await fetch(url, {
      method,
      headers,
      body: body ? JSON.stringify(body) : undefined,
      signal: controller.signal,
    });
    
    clearTimeout(timeoutId);
    
    // 4. Log for audit
    await logAudit({
      service: 'DRAFT',
      method,
      path,
      tenantId,
      statusCode: response.status,
    });
    
    // 5. Parse and return
    const data = await response.json();
    
    if (!response.ok) {
      // Sanitize error before returning
      return {
        error: sanitizeError(data),
        status: response.status,
      };
    }
    
    return { data, status: response.status };
    
  } catch (error) {
    clearTimeout(timeoutId);
    
    if (error.name === 'AbortError') {
      return {
        error: { detail: 'Request timeout' },
        status: 504,
      };
    }
    
    return {
      error: { detail: 'Service unavailable' },
      status: 503,
    };
  }
}
```

---

## Health Check

### Endpoint

```http
GET /api/v1/health
```

**Response:**

```json
{
  "status": "healthy",
  "service": "TrueVow DRAFT Service",
  "version": "1.0.0",
  "database": "connected",
  "environment": "production",
  "zero_knowledge_compliant": true
}
```

---

## Contact

For integration questions:
- **Email:** integration@truevow.com
- **Documentation:** https://docs.truevow.com/draft
- **Status Page:** https://status.truevow.com

---

*Last Updated: December 21, 2025*  
*Document Version: 1.0.0*

