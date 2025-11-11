#!/usr/bin/env python3
"""
Test script for compiled Cython extensions.
This script verifies that the compiled .pyx files work correctly.
"""

import sys
import os
import importlib
import traceback
from pathlib import Path


def test_cython_import():
    """Test importing compiled Cython modules."""
    print("=" * 60)
    print("Testing Cython Extension Imports")
    print("=" * 60)

    # Try to import the example module
    try:
        from virtmanager_cython.example import (
            fast_sum,
            euclidean_distance,
            fibonacci,
            FastCalculator,
            test_functions,
        )

        print("✅ Successfully imported virtmanager_cython.example module")
        return True
    except ImportError as e:
        print(f"❌ Failed to import virtmanager_cython.example: {e}")
        print("   Make sure to run: python build.py build_ext --inplace")
        return False
    except Exception as e:
        print(f"❌ Unexpected error importing virtmanager_cython.example: {e}")
        traceback.print_exc()
        return False


def test_basic_functions():
    """Test basic Cython functions."""
    print("\n" + "=" * 60)
    print("Testing Basic Cython Functions")
    print("=" * 60)

    try:
        import numpy as np
        from virtmanager_cython.example import fast_sum, euclidean_distance, fibonacci

        # Test fast_sum
        print("\n🧮 Testing fast_sum function:")
        test_array = np.array([1.0, 2.0, 3.0, 4.0, 5.0], dtype=np.float64)
        result = fast_sum(test_array)
        expected = 15.0
        print(f"   Input: {test_array}")
        print(f"   Result: {result}")
        print(f"   Expected: {expected}")
        assert abs(result - expected) < 1e-10, f"Expected {expected}, got {result}"
        print("   ✅ fast_sum test passed")

        # Test euclidean_distance
        print("\n📏 Testing euclidean_distance function:")
        point1 = np.array([0.0, 0.0], dtype=np.float64)
        point2 = np.array([3.0, 4.0], dtype=np.float64)
        distance = euclidean_distance(point1, point2)
        expected_distance = 5.0
        print(f"   Point 1: {point1}")
        print(f"   Point 2: {point2}")
        print(f"   Distance: {distance}")
        print(f"   Expected: {expected_distance}")
        assert abs(distance - expected_distance) < 1e-10, (
            f"Expected {expected_distance}, got {distance}"
        )
        print("   ✅ euclidean_distance test passed")

        # Test fibonacci
        print("\n🔢 Testing fibonacci function:")
        fib_input = 10
        fib_result = fibonacci(fib_input)
        expected_fib = 55  # 10th Fibonacci number
        print(f"   Input: {fib_input}")
        print(f"   Result: {fib_result}")
        print(f"   Expected: {expected_fib}")
        assert fib_result == expected_fib, f"Expected {expected_fib}, got {fib_result}"
        print("   ✅ fibonacci test passed")

        return True

    except ImportError as e:
        print(f"❌ Failed to import required modules: {e}")
        return False
    except Exception as e:
        print(f"❌ Error in basic function tests: {e}")
        traceback.print_exc()
        return False


def test_cython_class():
    """Test Cython class functionality."""
    print("\n" + "=" * 60)
    print("Testing Cython Class")
    print("=" * 60)

    try:
        from virtmanager_cython.example import FastCalculator

        print("\n⚡ Testing FastCalculator class:")
        x_val, y_val = 3.14, 2.71
        calc = FastCalculator(x_val, y_val)
        print(f"   Created FastCalculator({x_val}, {y_val})")

        # Test multiply method
        multiply_result = calc.multiply()
        expected_multiply = x_val * y_val
        print(f"   multiply() result: {multiply_result}")
        print(f"   Expected: {expected_multiply}")
        assert abs(multiply_result - expected_multiply) < 1e-10, (
            f"Expected {expected_multiply}, got {multiply_result}"
        )
        print("   ✅ multiply method test passed")

        # Test trigonometric_sum method
        trig_result = calc.trigonometric_sum()
        print(f"   trigonometric_sum() result: {trig_result}")
        print("   ✅ trigonometric_sum method test passed")

        return True

    except Exception as e:
        print(f"❌ Error in class tests: {e}")
        traceback.print_exc()
        return False


def test_performance_comparison():
    """Compare Cython performance with pure Python."""
    print("\n" + "=" * 60)
    print("Performance Comparison (Cython vs Pure Python)")
    print("=" * 60)

    try:
        import numpy as np
        import time
        from virtmanager_cython.example import fast_sum

        # Create a large test array
        size = 1000000
        test_array = np.random.random(size).astype(np.float64)

        print(f"\n⏱️  Testing with array of {size:,} elements:")

        # Test Cython version
        start_time = time.time()
        cython_result = fast_sum(test_array)
        cython_time = time.time() - start_time

        # Test NumPy version
        start_time = time.time()
        numpy_result = np.sum(test_array)
        numpy_time = time.time() - start_time

        # Test pure Python version
        start_time = time.time()
        python_result = sum(test_array)
        python_time = time.time() - start_time

        print(f"   Cython result: {cython_result:.10f} (Time: {cython_time:.6f}s)")
        print(f"   NumPy result:  {numpy_result:.10f} (Time: {numpy_time:.6f}s)")
        print(f"   Python result: {python_result:.10f} (Time: {python_time:.6f}s)")

        # Verify results are approximately equal
        assert abs(cython_result - numpy_result) < 1e-6, (
            "Cython and NumPy results don't match"
        )
        assert abs(cython_result - python_result) < 1e-6, (
            "Cython and Python results don't match"
        )

        # Calculate speedups
        if python_time > 0:
            speedup_vs_python = python_time / cython_time
            print(f"\n🚀 Cython speedup vs Pure Python: {speedup_vs_python:.2f}x")

        if numpy_time > 0:
            speedup_vs_numpy = numpy_time / cython_time
            print(f"🚀 Cython speedup vs NumPy: {speedup_vs_numpy:.2f}x")

        print("   ✅ Performance comparison completed")
        return True

    except Exception as e:
        print(f"❌ Error in performance comparison: {e}")
        traceback.print_exc()
        return False


def run_example_test_functions():
    """Run the test functions included in the example module."""
    print("\n" + "=" * 60)
    print("Running Example Module Test Functions")
    print("=" * 60)

    try:
        from virtmanager_cython.example import test_functions

        print("\n🧪 Running built-in test functions:")
        test_functions()
        print("   ✅ Built-in test functions completed")
        return True
    except Exception as e:
        print(f"❌ Error running built-in test functions: {e}")
        traceback.print_exc()
        return False


def main():
    """Main test function."""
    print("🔬 Cython Extension Test Suite")
    print("Testing compiled Cython extensions for virtmanager-win")

    # Check if compiled extensions exist
    virtmanager_cython_dir = Path("virtmanager_cython")
    pyd_files = list(virtmanager_cython_dir.glob("**/*.pyd"))  # Windows
    so_files = list(virtmanager_cython_dir.glob("**/*.so"))  # Linux/macOS

    if not pyd_files and not so_files:
        print("\n❌ No compiled extensions found!")
        print("   Please run: python build.py build_ext --inplace")
        print("   This will compile .pyx files to .pyd/.so files")
        return False

    compiled_files = pyd_files + so_files
    print(f"\n📦 Found {len(compiled_files)} compiled extension(s):")
    for file in compiled_files:
        print(f"   - {file}")

    # Run all tests
    tests = [
        test_cython_import,
        test_basic_functions,
        test_cython_class,
        run_example_test_functions,
        test_performance_comparison,
    ]

    passed = 0
    failed = 0

    for test in tests:
        try:
            if test():
                passed += 1
            else:
                failed += 1
        except Exception as e:
            print(f"❌ Test {test.__name__} failed with exception: {e}")
            failed += 1

    # Final results
    print("\n" + "=" * 60)
    print("Test Results Summary")
    print("=" * 60)
    print(f"✅ Tests Passed: {passed}")
    print(f"❌ Tests Failed: {failed}")
    print(f"📊 Success Rate: {passed / (passed + failed) * 100:.1f}%")

    if failed == 0:
        print("\n🎉 All tests passed! Cython extensions are working correctly.")
        return True
    else:
        print(f"\n⚠️  {failed} test(s) failed. Please check the output above.")
        return False


if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
