"""
TrueVow LEVERAGE™ Service - Database Connection Management
Handles PostgreSQL connection pooling and session management
"""

from typing import Generator
from sqlalchemy import create_engine, event
from sqlalchemy.orm import DeclarativeBase
from sqlalchemy.orm import sessionmaker, Session
from sqlalchemy.pool import Pool

from app.core.config import get_settings

settings = get_settings()

# ============================================================================
# DATABASE ENGINE CONFIGURATION (LAZY INITIALIZATION)
# ============================================================================

_engine = None


def get_engine():
    """
    Get or create database engine (lazy initialization)
    
    This allows the application to import without database configuration,
    which is useful for testing and development.
    
    Returns:
        Engine: SQLAlchemy engine
        
    Raises:
        ValueError: If database configuration is missing when engine is actually used
    """
    global _engine
    
    if _engine is None:
        try:
            database_url = settings.database_url_computed
        except ValueError as e:
            # In development/testing, allow app to start without DB config
            # The error will be raised when DB is actually accessed
            import os
            if os.getenv("ALLOW_NO_DB", "false").lower() == "true":
                # Create a dummy engine that will fail on first use
                # This allows app import but will fail on actual DB operations
                database_url = "postgresql://dummy:dummy@localhost:5432/dummy"
            else:
                raise e
        
        # Supabase transaction pooler requires channel_binding=disable for psycopg3
        _connect_args = {
            "options": "-c timezone=utc -c search_path=leverage,public",
        }
        # Add channel_binding=disable for Supabase pooler connections
        if "pooler.supabase.com" in database_url:
            _connect_args["channel_binding"] = "disable"

        _engine = create_engine(
            database_url,
            pool_size=settings.DATABASE_POOL_SIZE,
            max_overflow=settings.DATABASE_MAX_OVERFLOW,
            pool_pre_ping=True,  # Verify connections before using
            echo=settings.DATABASE_ECHO,
            connect_args=_connect_args,
        )
    
    return _engine


# Create engine at module level for backward compatibility
# But catch errors to allow import without DB config
try:
    engine = get_engine()
except ValueError:
    # Engine will be created lazily when needed
    engine = None


# ============================================================================
# CONNECTION POOL MANAGEMENT
# ============================================================================

@event.listens_for(Pool, "connect")
def set_session_config(dbapi_connection, connection_record):
    """
    Set session-level configuration when connection is established
    """
    cursor = dbapi_connection.cursor()
    
    # Set timezone to UTC
    cursor.execute("SET TIME ZONE 'UTC'")
    
    # Set search path to leverage and public schemas
    cursor.execute("SET search_path TO leverage, public")
    
    cursor.close()


# ============================================================================
# SESSION FACTORY
# ============================================================================

# Create session factory (lazy initialization)
def get_session_local():
    """
    Get or create session factory (lazy initialization)
    
    Returns:
        sessionmaker: SQLAlchemy session factory
    """
    return sessionmaker(
        autocommit=False,
        autoflush=False,
        bind=get_engine()
    )


# For backward compatibility
SessionLocal = None


def _init_session_local():
    """Initialize SessionLocal on first use"""
    global SessionLocal
    if SessionLocal is None:
        SessionLocal = get_session_local()
    return SessionLocal

# Base class for declarative models
class Base(DeclarativeBase):
    pass


# ============================================================================
# DATABASE SESSION DEPENDENCY
# ============================================================================

def get_db() -> Generator[Session, None, None]:
    """
    Dependency for getting database session
    
    Yields:
        Session: SQLAlchemy database session
        
    Usage:
        @app.get("/endpoint")
        def endpoint(db: Session = Depends(get_db)):
            # Use db session here
            pass
    """
    # Initialize session factory if needed
    session_factory = _init_session_local()
    db = session_factory()
    try:
        yield db
    finally:
        db.close()


# ============================================================================
# DATABASE INITIALIZATION
# ============================================================================

def init_db() -> None:
    """
    Initialize database (create all tables)
    
    Note: In production, use Alembic migrations instead
    """
    # Import all models here to ensure they are registered with Base
    # This is required for Base.metadata.create_all() to work
    from app.models import validation_rule_v2, template, analytics_v2  # noqa: F401
    
    # Create all tables
    Base.metadata.create_all(bind=get_engine())


def check_db_connection() -> bool:
    """
    Check if database connection is working
    
    Returns:
        bool: True if connection successful, False otherwise
    """
    try:
        from sqlalchemy import text
        session_factory = _init_session_local()
        db = session_factory()
        db.execute(text("SELECT 1"))
        db.close()
        return True
    except Exception as e:
        print(f"Database connection failed: {e}")
        return False


# ============================================================================
# ZERO-KNOWLEDGE COMPLIANCE MONITORING
# ============================================================================

def validate_no_document_content_in_db() -> None:
    """
    Validate that database schema does not contain document content columns
    
    This is a compliance check to ensure zero-knowledge architecture
    is maintained at the database level.
    
    Raises:
        ValueError: If forbidden columns are found
    """
    from sqlalchemy import inspect
    
    inspector = inspect(get_engine())
    
    # Forbidden column names that might contain document content
    forbidden_column_names = [
        "document_content",
        "document_text",
        "document_body",
        "client_data",
        "client_name",
        "client_address",
        "plaintiff_name",
        "defendant_name",
        "case_details",
        "settlement_amount",
        "injury_description",
    ]
    
    # Check all tables in leverage schema
    for table_name in inspector.get_table_names(schema="leverage"):
        columns = inspector.get_columns(table_name, schema="leverage")
        
        for column in columns:
            column_name = column["name"].lower()
            
            for forbidden in forbidden_column_names:
                if forbidden in column_name:
                    raise ValueError(
                        f"ZERO-KNOWLEDGE VIOLATION: Table 'leverage.{table_name}' "
                        f"contains forbidden column '{column['name']}' that may "
                        f"store document content. Documents must NEVER be stored."
                    )


# ============================================================================
# DATABASE UTILITIES
# ============================================================================

def get_table_names(schema: str = "leverage") -> list[str]:
    """
    Get all table names in specified schema
    
    Args:
        schema: Database schema name
        
    Returns:
        List of table names
    """
    from sqlalchemy import inspect
    
    inspector = inspect(get_engine())
    return inspector.get_table_names(schema=schema)


def execute_raw_sql(sql: str) -> None:
    """
    Execute raw SQL (use with caution)
    
    Args:
        sql: SQL statement to execute
    """
    session_factory = _init_session_local()
    db = session_factory()
    try:
        db.execute(sql)
        db.commit()
    finally:
        db.close()




