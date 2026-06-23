"""
DRAFT Service - Tenant App Routing Configuration
Add this routing to Tenant App's main.py or router
"""

from fastapi import APIRouter
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles
from pathlib import Path

# Create router for DRAFT portal
draft_router = APIRouter()

# Get web directory path
WEB_DIR = Path(__file__).parent.parent / "web" / "draft"

@draft_router.get("/draft")
async def draft_portal():
    """
    Serve DRAFT Customer Portal
    """
    return FileResponse(WEB_DIR / "index.html")

@draft_router.get("/draft/{file_path:path}")
async def draft_static_files(file_path: str):
    """
    Serve static files for DRAFT portal (CSS, JS, etc.)
    """
    file = WEB_DIR / file_path
    if file.exists() and file.is_file():
        return FileResponse(file)
    else:
        from fastapi import HTTPException
        raise HTTPException(status_code=404, detail="File not found")

# Alternative: Mount static files directory
# app.mount("/draft/static", StaticFiles(directory=str(WEB_DIR)), name="draft_static")

# To use in main.py:
# from app.routes.draft import draft_router
# app.include_router(draft_router, tags=["DRAFT"])
