# Build Instructions for Cython Extensions

This document explains how to use the `build.py` script to compile Cython (`.pyx`) files into Python extension modules (`.pyd` files on Windows, `.so` files on Linux/macOS).

## Prerequisites

Make sure you have the required dependencies installed:

```bash
# Install dependencies using uv (recommended)
uv sync

# Or using pip
pip install cython numpy setuptools
```

## Directory Structure

The build script automatically searches for `.pyx` files in the `cython/` directory and all its subdirectories:

```
virtmanager-win/
├── build.py                 # Build script
├── cython/                  # Cython source files directory
│   ├── example.pyx         # Example Cython file
│   ├── utils/              # Subdirectory example
│   │   └── helpers.pyx     # Another .pyx file
│   └── modules/
│       └── core.pyx
└── BUILD_INSTRUCTIONS.md   # This file
```

## Building Extensions

### Basic Usage

To compile all `.pyx` files in the `cython/` directory:

```bash
python build.py build_ext --inplace
```

### Common Build Commands

```bash
# Build extensions in-place (recommended for development)
python build.py build_ext --inplace

# Build and install extensions
python build.py build_ext --inplace install

# Clean previous builds and rebuild
python build.py clean build_ext --inplace

# Build with verbose output for debugging
python build.py build_ext --inplace --verbose
```

### Build Options

The build script supports several setuptools options:

- `--inplace`: Build extensions in the source directory
- `--verbose`: Enable verbose output
- `--debug`: Build with debug symbols
- `--force`: Force rebuild even if files haven't changed

## Output Files

After successful compilation, you'll find:

1. **Compiled Extensions**: `.pyd` files (Windows) or `.so` files (Linux/macOS) in the same directory as the source `.pyx` files
2. **Generated C/C++ Code**: In the `build/` directory
3. **HTML Annotation Files**: In `build/cython/` for performance analysis

## Using Compiled Extensions

Once compiled, you can import and use the extensions like regular Python modules:

```python
# If you have cython/example.pyx
from cython.example import fast_sum, fibonacci, FastCalculator
import numpy as np

# Use the compiled functions
arr = np.array([1.0, 2.0, 3.0, 4.0, 5.0])
result = fast_sum(arr)
print(f"Sum: {result}")

fib = fibonacci(10)
print(f"Fibonacci(10): {fib}")
```

## Build Script Features

The `build.py` script includes:

- **Automatic Discovery**: Finds all `.pyx` files recursively
- **Optimized Compilation**: Uses `-O3` optimization and performance-oriented compiler directives
- **NumPy Integration**: Includes NumPy headers automatically
- **C++ Support**: Configured for C++ compilation (can be changed to C)
- **HTML Annotations**: Generates performance analysis files
- **Error Handling**: Clear error messages for missing dependencies

## Compiler Directives

The build script uses these Cython compiler directives for optimal performance:

- `language_level: 3` - Use Python 3 syntax
- `boundscheck: False` - Disable bounds checking for speed
- `wraparound: False` - Disable negative index wrapping
- `cdivision: True` - Use C division semantics
- `nonecheck: False` - Disable None checking
- `embedsignature: True` - Include function signatures in docstrings

## Troubleshooting

### Common Issues

1. **"No .pyx files found"**
   - Make sure your `.pyx` files are in the `cython/` directory
   - Check file extensions are `.pyx` not `.py`

2. **"NumPy is required for compilation"**
   ```bash
   pip install numpy
   # or
   uv add numpy
   ```

3. **"Cython is required for compilation"**
   ```bash
   pip install cython
   # or
   uv add cython
   ```

4. **Import errors after compilation**
   - Make sure you built with `--inplace` flag
   - Check that the `.pyd`/`.so` files were created in the correct location
   - Verify your Python path includes the project directory

### Performance Analysis

The build script generates HTML annotation files in `build/cython/` that show:
- Which lines are pure Python (yellow) vs C (white)
- Performance bottlenecks and optimization opportunities
- Type inference information

Open these `.html` files in a web browser to analyze your code's performance.

## Example Workflow

1. **Write Cython Code**: Create `.pyx` files in the `cython/` directory
2. **Build**: Run `python build.py build_ext --inplace`
3. **Test**: Import and test your compiled modules
4. **Optimize**: Check HTML annotations and optimize bottlenecks
5. **Rebuild**: Run the build command again after changes

## Advanced Configuration

To modify build settings, edit the `build.py` file:

- Change compiler from C++ to C: Set `language="c"`
- Modify optimization flags: Edit `extra_compile_args`
- Add include directories: Extend `include_dirs`
- Add libraries: Use `libraries` and `library_dirs` parameters

For more advanced setuptools configuration, refer to the [setuptools documentation](https://setuptools.pypa.io/en/latest/).