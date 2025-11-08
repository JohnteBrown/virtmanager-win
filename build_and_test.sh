#!/bin/bash
# Build and Test Script for Cython Extensions
# This script compiles all .pyx files and runs tests to verify they work

set -e  # Exit on any error

echo "============================================================"
echo "Cython Build and Test Script for virtmanager-win"
echo "============================================================"

# Check if Python is available
if ! command -v python3 &> /dev/null; then
    if ! command -v python &> /dev/null; then
        echo "❌ ERROR: Python is not available or not in PATH"
        echo "   Please install Python and add it to your PATH"
        exit 1
    else
        PYTHON_CMD="python"
    fi
else
    PYTHON_CMD="python3"
fi

echo "Python version:"
$PYTHON_CMD --version

# Check if we're in a virtual environment or if dependencies are available
echo ""
echo "Checking dependencies..."
if ! $PYTHON_CMD -c "import cython; print('✓ Cython available')" 2>/dev/null; then
    echo "❌ ERROR: Cython not found"
    echo "   Please install dependencies with: pip install cython numpy setuptools"
    echo "   Or if using uv: uv sync"
    exit 1
fi

# Clean previous builds
echo ""
echo "Cleaning previous builds..."
rm -rf build/
find cython/ -name "*.so" -delete 2>/dev/null || true
find cython/ -name "*.c" -delete 2>/dev/null || true
find cython/ -name "*.cpp" -delete 2>/dev/null || true

# Build Cython extensions
echo ""
echo "============================================================"
echo "Building Cython Extensions"
echo "============================================================"
$PYTHON_CMD build.py build_ext --inplace

if [ $? -ne 0 ]; then
    echo ""
    echo "❌ ERROR: Build failed!"
    echo "   Check the error messages above for details."
    exit 1
fi

echo ""
echo "✅ Build completed successfully!"

# List compiled extensions
echo ""
echo "Compiled extensions:"
find cython/ -name "*.so" -exec echo "   - {}" \;

# Run tests
echo ""
echo "============================================================"
echo "Running Tests"
echo "============================================================"
if $PYTHON_CMD test_cython.py; then
    echo ""
    echo "✅ All tests passed successfully!"
    TEST_SUCCESS=true
else
    echo ""
    echo "⚠️  WARNING: Some tests failed!"
    echo "   Check the test output above for details."
    TEST_SUCCESS=false
fi

# Show HTML annotation files
echo ""
echo "============================================================"
echo "Build Artifacts"
echo "============================================================"
if [ -d "build/cython" ]; then
    echo "HTML annotation files for performance analysis:"
    find build/cython -name "*.html" -exec echo "   - {}" \;
    echo ""
    echo "Open these files in a web browser to analyze performance."
fi

echo ""
echo "Build and test process completed!"
echo ""
echo "Next steps:"
echo "   1. Check compiled .so files in the cython/ directory"
echo "   2. Review HTML annotation files in build/cython/ for optimization"
echo "   3. Import and use your compiled modules in your Python code"
echo ""

if [ "$TEST_SUCCESS" = true ]; then
    echo "🎉 Success! Your Cython extensions are ready to use."
    exit 0
else
    echo "⚠️  Build succeeded but some tests failed. Extensions may still be usable."
    exit 1
fi
