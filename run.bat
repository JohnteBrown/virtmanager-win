@echo off
echo Starting Virtmanager-Win...
echo.

REM Change to the script directory
cd /d "%~dp0"

set UV_NO_PROGRESS=1

REM Check if uv is available
uv --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: uv not found. Please install uv first.
    echo Visit: https://docs.astral.sh/uv/getting-started/installation/
    pause
    exit /b 1
)

REM Check if virtual environment exists
if not exist ".venv" (
    echo Virtual environment not found. Creating one...
    uv sync --no-install-project
    if %errorlevel% neq 0 (
        echo Error: Failed to create virtual environment or install dependencies.
        pause
        exit /b 1
    )
)

REM Ensure dependencies are synchronized
uv sync --no-install-project
if %errorlevel% neq 0 (
    echo Error: Failed to synchronize dependencies.
    pause
    exit /b 1
)

REM Run the application
echo Running application...
uv run --no-sync python main.py

REM Keep window open if there was an error
if %errorlevel% neq 0 (
    echo.
    echo Application exited with error code %errorlevel%
    if not defined APPVEYOR pause
)