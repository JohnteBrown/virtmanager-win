@echo off
echo Starting Virtmanager-Win...
echo.

REM Change to the script directory
cd /d "%~dp0"

REM Check if uv is available
uv --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: UV package manager not found. Please install UV first.
    echo Visit: https://docs.astral.sh/uv/getting-started/installation/
    pause
    exit /b 1
)

REM Check if virtual environment exists
if not exist ".venv" (
    echo Virtual environment not found. Creating one...
    uv sync
    if %errorlevel% neq 0 (
        echo Error: Failed to create virtual environment
        pause
        exit /b 1
    )
)

REM Run the application
echo Running application...
uv run python main.py

REM Keep window open if there was an error
if %errorlevel% neq 0 (
    echo.
    echo Application exited with error code %errorlevel%
    pause
)
