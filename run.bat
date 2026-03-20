@echo off
echo Starting Virtmanager-Win...
echo.

REM Change to the script directory
cd /d "%~dp0"

set POETRY_VIRTUALENVS_IN_PROJECT=true
set POETRY_NO_INTERACTION=1

REM Check if poetry is available
poetry --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: Poetry not found. Please install Poetry first.
    echo Visit: https://python-poetry.org/docs/#installation
    pause
    exit /b 1
)

REM Check if virtual environment exists
if not exist ".venv" (
    echo Virtual environment not found. Creating one...
    poetry install --no-root
    if %errorlevel% neq 0 (
        echo Error: Failed to create virtual environment
        pause
        exit /b 1
    )
)

REM Run the application
echo Running application...
poetry run python main.py

REM Keep window open if there was an error
if %errorlevel% neq 0 (
    echo.
    echo Application exited with error code %errorlevel%
    if not defined APPVEYOR pause
)
