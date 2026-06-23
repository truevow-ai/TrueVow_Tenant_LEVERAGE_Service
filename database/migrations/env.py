"""
Alembic Environment Configuration
"""

from logging.config import fileConfig
from sqlalchemy import engine_from_config, pool
from alembic import context
import sys
import os
from pathlib import Path
from dotenv import load_dotenv

# Load .env.local from project root BEFORE any app imports
project_root = Path(__file__).parent.parent.parent
env_file = project_root / ".env.local"
if env_file.exists():
    load_dotenv(env_file)

# Add parent directory to path for imports
sys.path.insert(0, os.path.realpath(os.path.join(os.path.dirname(__file__), '../..')))

from app.core.database import Base

# Import all models to ensure they're registered with Base
from app.models import validation_rule_v2, template, analytics_v2  # noqa: F401

# Alembic Config object
config = context.config

# Interpret the config file for Python logging
if config.config_file_name is not None:
    fileConfig(config.config_file_name)

# Get DATABASE_URL directly from environment (no app settings dependency)
# Prioritize TENANT_LEVERAGE_APP transaction pooler for psycopg3 + Supabase compatibility
# Transaction pooler (port 6543) is the ONLY working connection from client networks.
_db_url_candidates = [
    "TENANT_LEVERAGE_APP_DATABASE_TRANSACTION_POOLER_URL",
    "TENANT_LEVERAGE_APP_DATABASE_SESSION_POOLER_URL",
    "TENANT_LEVERAGE_APP_DATABASE_DIRECT_CONNECTION_URL",
    "LEVERAGE_DATABASE_TRANSACTION_POOLER_URL",
    "LEVERAGE_DATABASE_SESSION_POOLER_URL",
    "LEVERAGE_DATABASE_DIRECT_CONNECTION_URL",
    "TENANT_APP_DATABASE_TRANSACTION_POOLER_URL",
    "DATABASE_URL",
    "TENANT_APP_DATABASE_URL",
]
db_url = None
for key in _db_url_candidates:
    val = os.getenv(key)
    if val and (val.startswith("postgresql") or val.startswith("postgres")):
        db_url = val
        break

if not db_url:
    raise ValueError(
        "No database URL found in environment. Set TENANT_LEVERAGE_APP_DATABASE_TRANSACTION_POOLER_URL "
        "or check .env.local file."
    )

# Convert postgres:// to postgresql:// for SQLAlchemy 2.0 compatibility
if db_url.startswith("postgres://"):
    db_url = db_url.replace("postgres://", "postgresql://", 1)

# Convert postgresql:// to postgresql+psycopg:// for SQLAlchemy + psycopg3 driver
if db_url.startswith("postgresql://") and "+psycopg" not in db_url:
    db_url = db_url.replace("postgresql://", "postgresql+psycopg://", 1)

# Escape % characters for ConfigParser
db_url = db_url.replace('%', '%%')
config.set_main_option("sqlalchemy.url", db_url)

# Add your model's MetaData object here for 'autogenerate' support
target_metadata = Base.metadata


def run_migrations_offline() -> None:
    """
    Run migrations in 'offline' mode.
    
    This configures the context with just a URL and not an Engine,
    though an Engine is acceptable here as well. By skipping the Engine
    creation we don't even need a DBAPI to be available.
    
    Calls to context.execute() here emit the given string to the script output.
    """
    url = config.get_main_option("sqlalchemy.url")
    context.configure(
        url=url,
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
        version_table_schema="leverage",
    )
    
    with context.begin_transaction():
        context.run_migrations()


def run_migrations_online() -> None:
    """
    Run migrations in 'online' mode.
    
    In this scenario we need to create an Engine and associate a connection
    with the context.
    """
    connectable = engine_from_config(
        config.get_section(config.config_ini_section, {}),
        prefix="sqlalchemy.",
        poolclass=pool.NullPool,
    )
    
    with connectable.connect() as connection:
        context.configure(
            connection=connection,
            target_metadata=target_metadata,
            version_table_schema="leverage",
        )
        
        with context.begin_transaction():
            context.run_migrations()


if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()

