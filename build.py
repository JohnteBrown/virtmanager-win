#!/usr/bin/env python3
"""
Build script for compiling Cython (.pyx) files to Python extension modules (.pyd/.so)
Uses setuptools to automatically find and compile all .pyx files in the cython/ directory.
"""

import os
import sys
import glob
from pathlib import Path
from setuptools import setup, Extension
from Cython.Build import cythonize
from Cython.Distutils import build_ext

# Try to import numpy, but make it optional
try:
    import numpy as np

    NUMPY_AVAILABLE = True
except ImportError:
    NUMPY_AVAILABLE = False
    np = None


def find_pyx_files(directory="cython"):
    """
    Find all .pyx files in the specified directory and its subdirectories.

    Args:
        directory (str): Directory to search for .pyx files

    Returns:
        list: List of .pyx file paths
    """
    pyx_files = []
    search_pattern = os.path.join(directory, "**", "*.pyx")
    pyx_files.extend(glob.glob(search_pattern, recursive=True))

    # Also check the root of the directory
    root_pattern = os.path.join(directory, "*.pyx")
    pyx_files.extend(glob.glob(root_pattern))

    return list(set(pyx_files))  # Remove duplicates


def create_extensions(pyx_files):
    """
    Create Extension objects for each .pyx file.

    Args:
        pyx_files (list): List of .pyx file paths

    Returns:
        list: List of Extension objects
    """
    extensions = []

    for pyx_file in pyx_files:
        # Convert file path to module name
        # e.g., "cython/utils/helper.pyx" -> "virtmanager_cython.utils.helper"
        # Avoid using "cython" as module name as it conflicts with the Cython package
        module_name = pyx_file.replace(os.sep, ".").replace(".pyx", "")
        if module_name.startswith("cython."):
            module_name = module_name.replace("cython.", "virtmanager_cython.", 1)
        elif module_name == "cython":
            module_name = "virtmanager_cython"

        # Create extension with common settings
        ext = Extension(
            name=module_name,
            sources=[pyx_file],
            include_dirs=[
                ".",
                "cython",
            ]
            + ([np.get_include()] if NUMPY_AVAILABLE else []),
            language="c++",  # Use C++ compiler (change to "c" if you prefer C)
            extra_compile_args=[
                "-O3",  # Optimization level
                "-Wall",  # Enable warnings
            ],
            extra_link_args=[],
            define_macros=[
                ("NPY_NO_DEPRECATED_API", "NPY_1_7_API_MIN"),
            ]
            if NUMPY_AVAILABLE
            else [],
        )
        extensions.append(ext)

    return extensions


def main():
    """Main build function."""
    print("=" * 60)
    print("Cython Build Script for virtmanager-win")
    print("=" * 60)

    # Check if cython directory exists
    if not os.path.exists("cython"):
        print("❌ Error: 'cython' directory not found!")
        print("   Please create the directory and add .pyx files to compile.")
        sys.exit(1)

    # Show NumPy availability
    if NUMPY_AVAILABLE:
        print("✅ NumPy detected - NumPy integration enabled")
    else:
        print("⚠️  NumPy not available - compiling without NumPy support")

    # Find all .pyx files
    pyx_files = find_pyx_files("cython")

    if not pyx_files:
        print("⚠️  No .pyx files found in the 'cython' directory.")
        print("   Please add .pyx files to compile.")
        return

    print(f"📁 Found {len(pyx_files)} .pyx file(s):")
    for pyx_file in pyx_files:
        print(f"   - {pyx_file}")
    print()

    # Create extensions
    extensions = create_extensions(pyx_files)

    # Configure Cython compilation
    compiler_directives = {
        "language_level": 3,  # Use Python 3 syntax
        "embedsignature": True,  # Include function signatures in docstrings
        "boundscheck": False,  # Disable bounds checking for performance
        "wraparound": False,  # Disable negative index wrapping
        "cdivision": True,  # Use C division semantics
        "nonecheck": False,  # Disable None checking for performance
    }

    # Cythonize extensions
    print("🔨 Cythonizing extensions...")
    cythonized_extensions = cythonize(
        extensions,
        compiler_directives=compiler_directives,
        annotate=True,  # Generate HTML annotation files for optimization analysis
        build_dir="build/cython",
        language_level=3,
    )

    # Setup configuration
    setup(
        name="virtmanager-win-cython",
        ext_modules=cythonized_extensions,
        cmdclass={"build_ext": build_ext},
        packages=[],  # Explicitly set to empty list to avoid auto-discovery
        zip_safe=False,
    )

    print("✅ Build completed successfully!")
    print(
        "📊 HTML annotation files generated in 'build/cython' for performance analysis."
    )
    print("🎯 Compiled extensions (.pyd/.so files) are ready for use.")


if __name__ == "__main__":
    # Check if Cython is available
    try:
        from Cython.Build import cythonize
        from Cython.Distutils import build_ext
    except ImportError:
        print("❌ Error: Cython is required for compilation.")
        print("   Install it with: pip install cython")
        print("   Or run: uv add cython")
        sys.exit(1)

    main()
