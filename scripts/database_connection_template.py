"""
TrueVow LEVERAGE™ — Database Connection Template

Copy-paste template for scripts and agents that need direct database access.

CRITICAL RULES:
1. Always load .env.local with FULL path (relative paths fail from subdirectories)
2. Use transaction pooler URL (port 6543) — session pooler fails with psycopg3
3. Add channel_binding=disable for Supabase pooler connections
4. Set search_path=leverage,public for correct schema resolution
5. Always close connections when done

USAGE:
    python scripts/database_connection_template.py
"""

import os
import sys
from pathlib import Path
from dotenv import load_dotenv
import psycopg


def get_leverage_database_url() -> str:
    """
    Get the working database URL for LEVERAGE service.

    Priority order (matches app/core/config.py database_url_computed):
    1. TENANT_LEVERAGE_APP_DATABASE_TRANSACTION_POOLER_URL (port 6543) — PRIMARY
    2. LEVERAGE_DATABASE_TRANSACTION_POOLER_URL
    3. TENANT_LEVERAGE_APP_DATABASE_SESSION_POOLER_URL (port 5432) — may fail
    4. LEVERAGE_DATABASE_SESSION_POOLER_URL
    5. TENANT_LEVERAGE_APP_DATABASE_DIRECT_CONNECTION_URL
    6. LEVERAGE_DATABASE_DIRECT_CONNECTION_URL
    7. DATABASE_URL (fallback)

    Returns:
        str: Working database URL with psycopg3 driver prefix
    """
    # CRITICAL: Load .env.local with FULL path
    env_file = Path(__file__).parent.parent / ".env.local"
    load_dotenv(dotenv_path=env_file)

    # Check URLs in priority order
    url_candidates = [
        os.getenv("TENANT_LEVERAGE_APP_DATABASE_TRANSACTION_POOLER_URL"),
        os.getenv("LEVERAGE_DATABASE_TRANSACTION_POOLER_URL"),
        os.getenv("TENANT_LEVERAGE_APP_DATABASE_SESSION_POOLER_URL"),
        os.getenv("LEVERAGE_DATABASE_SESSION_POOLER_URL"),
        os.getenv("TENANT_LEVERAGE_APP_DATABASE_DIRECT_CONNECTION_URL"),
        os.getenv("LEVERAGE_DATABASE_DIRECT_CONNECTION_URL"),
        os.getenv("DATABASE_URL"),
    ]

    for url in url_candidates:
        if url:
            # Normalize postgres:// to postgresql://
            if url.startswith("postgres://"):
                url = url.replace("postgres://", "postgresql://", 1)
            # Convert to psycopg3 driver
            if url.startswith("postgresql://"):
                url = url.replace("postgresql://", "postgresql+psycopg://", 1)
            return url

    raise ValueError(
        "No database URL found in .env.local. "
        "Set TENANT_LEVERAGE_APP_DATABASE_TRANSACTION_POOLER_URL or DATABASE_URL."
    )


def get_connection_params(url: str) -> dict:
    """
    Build psycopg3 connection parameters from a URL.

    Handles Supabase-specific requirements:
    - channel_binding=disable for pooler connections
    - sslmode=require for all Supabase connections
    - search_path for leverage schema

    Args:
        url: Database URL (with or without psycopg driver prefix)

    Returns:
        dict: Connection parameters for psycopg.connect()
    """
    # Strip psycopg driver prefix for raw psycopg3 connection
    clean_url = url.replace("postgresql+psycopg://", "postgresql://")

    params = {}

    # Supabase pooler requires channel_binding=disable
    if "pooler.supabase.com" in clean_url:
        params["channel_binding"] = "disable"

    # SSL required for all Supabase connections
    if "supabase" in clean_url or "sslmode" not in clean_url:
        params["sslmode"] = "require"

    # Schema search path — leverage schema first, then public
    params["options"] = "-c search_path=leverage,public"

    return clean_url, params


def test_connection():
    """
    Test database connection and list tables.
    Verifies that the connection method works and shows available tables.
    """
    url = get_leverage_database_url()
    clean_url, params = get_connection_params(url)

    print(f"Connecting to: {clean_url[:30]}...{clean_url[-30:]}")
    print(f"Connection params: {params}")

    try:
        with psycopg.connect(clean_url, **params, prepare_threshold=None) as conn:
            with conn.cursor() as cur:
                # Verify connection
                cur.execute("SELECT version();")
                version = cur.fetchone()[0]
                print(f"\nConnected! PostgreSQL version: {version[:60]}...")

                # List schemas
                cur.execute("""
                    SELECT schema_name
                    FROM information_schema.schemata
                    WHERE schema_name NOT IN ('pg_catalog', 'information_schema')
                    ORDER BY schema_name;
                """)
                schemas = [row[0] for row in cur.fetchall()]
                print(f"\nSchemas: {', '.join(schemas)}")

                # List tables in leverage schema
                cur.execute("""
                    SELECT table_name
                    FROM information_schema.tables
                    WHERE table_schema = 'leverage'
                    ORDER BY table_name;
                """)
                leverage_tables = [row[0] for row in cur.fetchall()]
                print(f"\nLeverage schema tables ({len(leverage_tables)}):")
                for table in leverage_tables:
                    print(f"  - {table}")

                # List tables in public schema
                cur.execute("""
                    SELECT table_name
                    FROM information_schema.tables
                    WHERE table_schema = 'public'
                    ORDER BY table_name;
                """)
                public_tables = [row[0] for row in cur.fetchall()]
                print(f"\nPublic schema tables ({len(public_tables)}):")
                for table in public_tables[:20]:
                    print(f"  - {table}")
                if len(public_tables) > 20:
                    print(f"  ... and {len(public_tables) - 20} more")

                print(f"\nTotal tables: {len(leverage_tables) + len(public_tables)}")

    except Exception as e:
        print(f"Connection failed: {e}")
        raise


if __name__ == "__main__":
    test_connection()
