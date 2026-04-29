# LEVERAGE Billing Integration Guide

**Date:** 2026-04-27  
**Status:** Implementation Guide  
**Related:** SETTLE_BILLING_ARCHITECTURE.md, INTEGRATION_SUMMARY.md

---

## IMPORTANT: Billing Model Clarification

**LEVERAGE is case-based, NOT validation-based.**

| Billing Model | Description |
|--------------|-------------|
| **Case opens** | Billed per case (included in tier or overage) |
| **Validations** | **FREE and unlimited** within opened case |

This is different from SETTLE where each report costs money.

### Tier Model (from Product Positioning)

| Tier | Cases Included | Overage | Validations per Case |
|------|---------------|---------|---------------------|
| SOLO | 5 | $49/case | Unlimited |
| GROWTH | 20 | $39/case | Unlimited |
| TEAM | 50 | $29/case | Unlimited |

Once a case is opened, **validations are FREE** — no per-validation billing.

---

## Correct Integration Pattern

### DO NOT DO THIS

```typescript
// DON'T: Per-validation billing (not how LEVERAGE works)
await fetch('/api/v1/billing/leverage/consume-validation', {...});

// DON'T: Billing per validation run
const price = calculatePerValidation();  // Wrong model
```

### DO THIS

```typescript
// DO: Case-based billing — LEVERAGE only bills on CASE OPEN

// Step 1: Open/activate case (this is the billing trigger)
const response = await fetch(
  `/api/v1/billing/leverage/open-case?tenant_id=${tenantId}`,
  {
    method: 'POST',
    headers: {
      'X-API-Key': INTERNAL_SERVICE_API_KEY,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      case_id: caseId,
      external_case_id: externalCaseId,  // Optional
      idempotency_key: `leverage-open-${tenantId}-${caseId}`
    })
  }
);

const result = await response.json();

if (result.authorized) {
  // CASE IS NOW OPEN — validations are FREE and unlimited
  // LEVERAGE can run as many validations as needed
  
  const calculation = await calculateDamages(caseId);  // No billing call needed
  const anotherValidation = await runDamagesCheck(caseId);  // Still free
  
  return { calculation, billing_context: result };
} else {
  throw new Error(result.message);
}
```

---

## API Reference

### POST /api/v1/billing/leverage/open-case

**Purpose:** Open/activate a case for LEVERAGE analysis. **This is the only billing trigger.**

**Authentication:** Internal API key (X-API-Key header)

**Request:**
```json
{
  "case_id": "uuid",           // Required - Case UUID
  "external_case_id": "string", // Optional - External reference
  "idempotency_key": "string"    // Optional - Prevent duplicate opens
}
```

**Response:**
```json
{
  "authorized": true,
  "case_id": "uuid",
  "source": "included",        // "included" | "overage" | "credit" | "invoice"
  "price_cents": 0,             // 0 if included, amount if overage
  "cases_used": 6,
  "cases_included": 5,         // From tier
  "cases_remaining": 0,
  "validations_unlimited": true,
  "message": "Case opened. Validations are unlimited and free."
}
```

---

## Billing Sources for LEVERAGE

| Source | Meaning | Price |
|--------|---------|-------|
| `included` | Within tier's case allowance | $0 |
| `overage` | Beyond tier's case allowance | Tier overage rate |
| `credit` | Using prepaid bundle credit | $0 |
| `invoice` | Pay-per-case (standalone) | Tier price |

---

## LEVERAGE Flow (Correct)

```
+---------------------------------------------------------------------+
|                         LEVERAGE SERVICE                            |
|                                                                     |
|  Step 1: CASE OPEN (billing trigger)                               |
|  +------------------------------------------------------------------+|
|  | POST /api/v1/billing/leverage/open-case                         ||
|  | Billing Service checks:                                        ||
|  |   - Tier allowance (5/20/50 cases)                              ||
|  |   - Overage rate                                               ||
|  |   - Available credits                                          ||
|  | Returns: { authorized, price, cases_remaining }                ||
|  +------------------------------------------------------------------+|
|                                                                     |
|  Step 2: RUN VALIDATIONS (FREE — no billing call)                   |
|  +------------------------------------------------------------------+|
|  | NO billing API call                                            ||
|  | LEVERAGE runs calculations directly                            ||
|  | No tracking, no charges, no limits                            ||
|  +------------------------------------------------------------------+|
+---------------------------------------------------------------------+
```

---

## Error Handling

### Case Not Authorized

```typescript
const result = await openCase(tenantId, caseId);

if (!result.authorized) {
  switch (result.message) {
    case "Case limit reached. Please upgrade or purchase additional cases.":
      // Show upgrade prompt
      showUpgradeOptions(result.cases_used, result.cases_included);
      break;
      
    case "LEVERAGE not unlocked. Complete required unlocks first.":
      // Show unlock requirements
      showUnlockRequirements();
      break;
      
    default:
      showError(result.message);
  }
}
```

### Idempotency

Same `idempotency_key` returns same result:

```json
{
  "authorized": true,
  "source": "already_opened",
  "message": "Case already opened (idempotent retry)"
}
```

---

## Environment Configuration

```bash
# .env for LEVERAGE service
INTERNAL_SERVICE_API_KEY=your-internal-api-key
BILLING_SERVICE_URL=http://localhost:8002
```

---

## Testing

### Test Case Open

```bash
curl -X POST "http://localhost:8002/api/v1/billing/leverage/open-case?tenant_id=TENANT_UUID" \
  -H "X-API-Key: your-internal-api-key" \
  -H "Content-Type: application/json" \
  -d '{"case_id": "CASE_UUID", "idempotency_key": "test-1"}'
```

Expected response:
```json
{
  "authorized": true,
  "case_id": "CASE_UUID",
  "source": "included",
  "price_cents": 0,
  "cases_used": 1,
  "cases_included": 5,
  "cases_remaining": 4,
  "validations_unlimited": true,
  "message": "Case opened. Validations are unlimited and free."
}
```

---

## Common Issues

### 401 Unauthorized
- Check `INTERNAL_SERVICE_API_KEY` matches Billing Service
- Ensure header name is `X-API-Key` (not `Authorization`)

### Case Limit Reached
- Show upgrade prompt with current usage
- Offer to purchase additional cases

### LEVERAGE Not Unlocked
- Show unlock requirements

---

## Service Boundaries

| What LEVERAGE Does | What LEVERAGE Does NOT Do |
|-------------------|---------------------------|
| Run damages calculations | Write to billing tables |
| Call `/open-case` for billing trigger | Bill per validation |
| Run unlimited validations after case open | Track validation counts |
| Store calculation results | Know pricing (delegates to Billing) |

---

## LEVERAGE vs SETTLE — Key Difference

| Aspect | LEVERAGE | SETTLE |
|--------|----------|--------|
| **Billing trigger** | Case open (one-time) | Report generation (per use) |
| **Usage model** | Unlimited validations per case | Pay per report |
| **Tier inclusion** | X cases included | X reports included (Pro) |
| **Overage** | Per case beyond allowance | Per report beyond allocation |

---

## Standalone vs Ecosystem LEVERAGE

### Standalone LEVERAGE
- Separate activation flow
- Own credit packs
- Pay-per-case after included

### Ecosystem LEVERAGE (with INTAKE)
- Discounted overage pricing
- Included cases in INTAKE subscription
- Monthly billing for overage

LEVERAGE handles both via `/open-case` — Billing Service determines correct pricing.

---

## Existing Implementation Mapping

| Integration Guide Concept | Python Implementation | Notes |
|---|---|---|
| `/leverage/activate` | `check_case_limit()` + `record_case_open()` | "Open case" = "activate" |
| `/leverage/consume-validation` | Not needed | Validations are free |
| Per-validation billing | Case-based billing | Correct model |
| Idempotency keys | `leverage_open_{tenant_id}_{case_id}` | Already implemented |
| `authorized` field | `check_case_limit()["authorized"]` | Added in billing service |
| `source` field | `check_case_limit()["source"]` | "included" or "overage" |
| `price_cents` field | `check_case_limit()["price_cents"]` | 0 for included, overage*100 for overage |
| `validations_unlimited` | `check_case_limit()["validations_unlimited"]` | Always True |

---

## Related Documents

- SETTLE_BILLING_ARCHITECTURE.md - Full billing architecture
- INTEGRATION_SETTLE.md - SETTLE integration guide
- INTEGRATION_SAAS_ADMIN_PORTAL.md - Other service integration
- INTEGRATION_SUMMARY.md - Implementation summary
