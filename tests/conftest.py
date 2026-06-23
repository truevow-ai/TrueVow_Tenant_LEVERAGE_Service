"""
Pytest configuration and fixtures for TrueVow DRAFT Service.

Sets up test database environment so that:
- DATABASE_URL or TEST_DATABASE_URL is set before any app imports
- Full test suite and runtime verification can run against test DB
"""

import os
import sys
from pathlib import Path

import pytest
from dotenv import load_dotenv

# Load .env.local from project root
project_root = Path(__file__).parent.parent
env_file = project_root / ".env.local"
if env_file.exists():
    load_dotenv(env_file)

# Set test environment BEFORE any app or config imports
# This ensures get_settings() and get_engine() use test database when tests run
if "DATABASE_URL" not in os.environ:
    # First try TENANT_APP_DATABASE_URL from .env.local
    db_url = os.getenv(
        "TENANT_APP_DATABASE_URL",
        os.getenv(
            "TEST_DATABASE_URL",
            "postgresql://postgres:postgres@localhost:5432/truevow_draft_test",
        )
    )
    os.environ["DATABASE_URL"] = db_url

os.environ["TESTING"] = "1"
# Optional: use test app environment so config uses TEST_DATABASE_URL if DATABASE_URL were unset
if "APP_ENVIRONMENT" not in os.environ:
    os.environ["APP_ENVIRONMENT"] = "development"


def pytest_configure(config):
    """Pytest hook: mark that we're in test mode."""
    os.environ["TESTING"] = "1"


def _get_app():
    """Lazy import app so env vars are set first."""
    from app.main import app
    return app


@pytest.fixture
def app():
    """FastAPI app instance (env already set by conftest load)."""
    return _get_app()


@pytest.fixture
def client(app):
    """TestClient for FastAPI app."""
    from fastapi.testclient import TestClient
    return TestClient(app)
