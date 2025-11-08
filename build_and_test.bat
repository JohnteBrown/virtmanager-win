@echo off
REM Build and Test Script for Cython Extensions
REM This script compiles all .pyx files and runs tests to verify they work

echo ============================================================
echo Cython Build and Test Script for virtmanager-win
echo ============================================================

REM Check if Python is available
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python is not available or not in PATH
    echo Please install Python and add it to your PATH
    pause
    exit /b 1
)

echo Python version:
python --version

REM Check if we're in a virtual environment or if dependencies are available
echo.
echo Checking dependencies...
python -c "import cython; print('✓ Cython available')" 2>nul || (
    echo ERROR: Cython not found
    echo Please install dependencies with: pip install cython numpy setuptools
    echo Or if using uv: uv sync
    pause
    exit /b 1
)

REM Clean previous builds
echo.
echo Cleaning previous builds...
if exist "build" rmdir /s /q "build"
if exist "cython\*.pyd" del /q "cython\*.pyd"
if exist "cython\*.c" del /q "cython\*.c"
if exist "cython\*.cpp" del /q "cython\*.cpp"

REM Build Cython extensions
echo.
echo ============================================================
echo Building Cython Extensions
echo ============================================================
python build.py build_ext --inplace
if errorlevel 1 (
    echo.
    echo ERROR: Build failed!
    echo Check the error messages above for details.
    pause
    exit /b 1
)

echo.
echo ✓ Build completed successfully!

REM List compiled extensions
echo.
echo Compiled extensions:
for /r "cython" %%f in (*.pyd) do echo   - %%f

REM Run tests
echo.
echo ============================================================
echo Running Tests
echo ============================================================
python test_cython.py
if errorlevel 1 (
    echo.
    echo WARNING: Some tests failed!
    echo Check the test output above for details.
) else (
    echo.
    echo ✓ All tests passed successfully!
)

REM Show HTML annotation files
echo.
echo ============================================================
echo Build Artifacts
echo ============================================================
if exist "build\cython" (
    echo HTML annotation files for performance analysis:
    for /r "build\cython" %%f in (*.html) do echo   - %%f
    echo.
    echo Open these files in a web browser to analyze performance.
)

echo.
echo Build and test process completed!
echo.
echo Next steps:
echo   1. Check compiled .pyd files in the cython/ directory
echo   2. Review HTML annotation files in build/cython/ for optimization
echo   3. Import and use your compiled modules in your Python code
echo.

pause
