# WORKING_CACHE.md
Repo Type: Python backend
Truth Commands: alembic upgrade head; python -m pytest tests/ -v; ruff check . (if configured); mypy . (if configured)
Status Word Policy: DONE/UNVERIFIED/BLOCKED only
No-Delete Policy: Must ask before deleting any file/folder
First-Failure Fix Loop: Fix only the first failure, then rerun the same command