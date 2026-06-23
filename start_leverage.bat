@echo off
echo Starting TrueVow LEVERAGE Service...
cd /d "%~dp0"
set SKIP_REGISTRY=true
set APP_ENVIRONMENT=development
set SERVICE_PORT=3036
call .venv\Scripts\python.exe -m uvicorn app.main:app --host 0.0.0.0 --port %SERVICE_PORT% --log-level info
pause
