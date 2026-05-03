# LEVERAGE Database Connection Guide

**Date:** 2026-04-27
**Status:** Verified Working
**Applies to:** LEVERAGE Service (Python/FastAPI, psycopg3, Supabase)

---

## Quick Reference for Coding Agents

### 5 Critical Rules

1. **Always load `.env.local` with FULL path** — relative paths fail from subdirectories
2. **Use transaction pooler URL (port 6543)** — session pooler fails with psycopg3
3. **Add `channel_binding=disable`** for Supabase pooler connections
4. **Set `search_path=leverage,public`** — leverage schema first, then public
5. **Always close connections** when done (use context managers)

### Copy-Paste Template

```python
# See: scripts/database_connection_template.py
from pathlib import Path
from dotenv import load_dotenv
import psycopg

# CRITICAL: Full path to .env.local
env_file = Path(__file__).parent.parent / ".env.local"
load_dotenv(dotenv_path=env_file)

url = os.getenv("TENANT_LEVERAGE_APP_DATABASE_TRANSACTION_POOLER_URL")
# Strip psycopg driver prefix for raw psycopg3
url = url.replace("postgresql+psycopg://", "postgresql://")

params = {
    "channel_binding": "disable",  # Required for Supabase pooler
    "sslmode": "require",
    "options": "-c search_path=leverage,public",
}

with psycopg.connect(url, **params, prepare_threshold=None) as conn:
    with conn.cursor() as cur:
        cur.execute("SELECT 1")
        print(cur.fetchone())
```

---

## Connection URL Priority

The LEVERAGE service uses this priority order (defined in `app/core/config.py`):

| Priority | Environment Variable | Port | Notes |
|----------|---------------------|------|-------|
| 1 | `TENANT_LEVERAGE_APP_DATABASE_TRANSACTION_POOLER_URL` | 6543 | **PRIMARY** — psycopg3 compatible |
| 2 | `LEVERAGE_DATABASE_TRANSACTION_POOLER_URL` | 6543 | Alternative name |
| 3 | `TENANT_LEVERAGE_APP_DATABASE_SESSION_POOLER_URL` | 5432 | May fail with psycopg3 |
| 4 | `LEVERAGE_DATABASE_SESSION_POOLER_URL` | 5432 | May fail with psycopg3 |
| 5 | `TENANT_LEVERAGE_APP_DATABASE_DIRECT_CONNECTION_URL` | 5432 | DNS may not resolve |
| 6 | `LEVERAGE_DATABASE_DIRECT_CONNECTION_URL` | 5432 | DNS may not resolve |
| 7 | `DATABASE_URL` | varies | Fallback |

### Why Transaction Pooler (port 6543)?

psycopg3 has compatibility issues with Supabase's session-mode pgbouncer. The transaction pooler on port 6543 works reliably. Session pooler on port 5432 will intermittently fail with "server closed the connection unexpectedly".

### Why `aws-1` Pooler Host?

The `db.*` Supabase hostname (e.g., `db.cnbzuiuyppzrygxllgxj.supabase.co`) does NOT resolve from some networks. Only the `aws-*` pooler hostnames work:
- Works: `aws-1-us-east-1.pooler.supabase.com:6543`
- Fails: `db.cnbzuiuyppzrygxllgxj.supabase.co:5432`

---

## .env.local Configuration

The LEVERAGE service loads both `.env` and `.env.local` (Pydantic Settings). The `.env.local` file contains all Supabase connection details:

```bash
# PRIMARY — Transaction pooler (port 6543) — USE THIS
TENANT_LEVERAGE_APP_DATABASE_TRANSACTION_POOLER_URL=postgresql://postgres.PROJECT_ID:PASSWORD@aws-1-us-east-1.pooler.supabase.com:6543/postgres

# Session pooler (port 5432) — May fail with psycopg3
TENANT_LEVERAGE_APP_DATABASE_SESSION_POOLER_URL=postgresql://postgres.PROJECT_ID:PASSWORD@aws-1-us-east-1.pooler.supabase.com:5432/postgres

# Direct connection — DNS may not resolve
TENANT_LEVERAGE_APP_DATABASE_DIRECT_CONNECTION_URL=postgresql://postgres.PROJECT_ID:PASSWORD@db.PROJECT_ID.supabase.co:5432/postgres

# Supabase API
TENANT_LEVERAGE_APP_DATABASE_URL=https://PROJECT_ID.supabase.co
TENANT_LEVERAGE_APP_DATABASE_SERVICE_ROLE_KEY=eyJ...
TENANT_LEVERAGE_APP_DATABASE_ANON_KEY=eyJ...
```

---

## Application vs Script Connection

### Application (FastAPI) — Use SQLAlchemy

The app uses SQLAlchemy with psycopg3 driver. Connection is handled by `app/core/database.py`:

```python
from app.core.database import get_engine, get_db_session

# Engine automatically configured from .env.local via config.py
engine = get_engine()

# Session via dependency injection
with get_db_session() as session:
    result = session.execute(text("SELECT 1"))
```

Key config in `app/core/config.py`:
- `database_url_computed` property handles priority and normalization
- Automatically converts `postgresql://` → `postgresql+psycopg://` for psycopg3
- Automatically adds `channel_binding=disable` for pooler URLs

### Scripts — Use psycopg3 directly

For standalone scripts (migrations, seeding, verification):

```python
from pathlib import Path
from dotenv import load_dotenv
import psycopg

env_file = Path(__file__).parent.parent / ".env.local"
load_dotenv(dotenv_path=env_file)

url = os.getenv("TENANT_LEVERAGE_APP_DATABASE_TRANSACTION_POOLER_URL")
url = url.replace("postgresql+psycopg://", "postgresql://")

with psycopg.connect(
    url,
    channel_binding="disable",
    sslmode="require",
    options="-c search_path=leverage,public",
    prepare_threshold=None,
) as conn:
    # Your code here
    pass
```

---

## Database Schema

The LEVERAGE database uses two schemas:

### `leverage` schema (19 tables) — Business data

| Table | Purpose |
|-------|---------|
| `leverage_case_profiles` | Case management and billing status |
| `leverage_case_events` | Case event timeline |
| `leverage_validation_results` | Compliance validation outcomes |
| `leverage_settlement_details` | Settlement records |
| `leverage_settlement_windows` | Settlement timing analysis |
| `leverage_damages_worksheets` | Damages calculations |
| `leverage_disbursement_worksheets` | Disbursement tracking |
| `leverage_case_deadlines` | SOL and other deadline tracking |
| `leverage_notification_subscriptions` | Notification preferences |
| `leverage_notification_log` | Notification delivery log |
| `leverage_reward_ledger` | Billing and usage tracking |
| `leverage_valuation_multipliers` | Valuation adjustment factors |
| `validation_rules` | Legal compliance rules |
| `legal_sources` | Statute and case law references |
| `rule_citations` | Rule-to-source citations |
| `templates` | Document templates |
| `validation_analytics` | Validation usage statistics |
| `api_keys` | API key management |
| `alembic_version` | Migration tracking |

### `draft` schema — Validation rules and templates (shared with INTAKE)

### `public` schema — Supabase system tables

---

## Common Errors and Solutions

### Error: "DATABASE_URL not configured"

**Cause:** `.env.local` not loaded (wrong path or missing file)
**Fix:** Use full path: `Path(__file__).parent.parent / ".env.local"`

### Error: "server closed the connection unexpectedly"

**Cause:** Using session pooler (port 5432) with psycopg3
**Fix:** Use transaction pooler URL (port 6543) instead

### Error: "could not translate host name"

**Cause:** Using `db.*` hostname that doesn't resolve
**Fix:** Use `aws-1-us-east-1.pooler.supabase.com` hostname

### Error: "channel_binding required but not supported"

**Cause:** Missing `channel_binding=disable` for pooler connection
**Fix:** Add `channel_binding="disable"` to connection params

### Error: "relation does not exist"

**Cause:** Schema not in search_path
**Fix:** Set `options="-c search_path=leverage,public"`

---

## Verification

Run the template script to verify connection:

```bash
python scripts/database_connection_template.py
```

Expected output:
```
Connected! PostgreSQL version: PostgreSQL 17.6...
Schemas: auth, extensions, leverage, public, ...
Leverage schema tables (19):
  - alembic_version
  - api_keys
  - legal_sources
  ...
Total tables: 19
```

---

## Related Files

| File | Purpose |
|------|---------|
| `app/core/config.py` | Pydantic Settings with URL priority logic |
| `app/core/database.py` | SQLAlchemy engine + session management |
| `scripts/database_connection_template.py` | Copy-paste template for scripts |
| `alembic.ini` | Alembic migration configuration |
| `.env.local` | Database credentials (not in git) |
