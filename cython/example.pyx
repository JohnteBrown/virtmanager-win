# cython: language_level=3
"""
Example Cython module for testing the build script.
This file demonstrates basic Cython functionality and can be used to verify
that the build.py script works correctly.
"""

import cython
import numpy as np
cimport numpy as cnp
from libc.math cimport sqrt, sin, cos

# Define numpy array types
ctypedef cnp.float64_t DTYPE_t

@cython.boundscheck(False)
@cython.wraparound(False)
def fast_sum(cnp.ndarray[DTYPE_t, ndim=1] arr):
    """
    Fast summation of a 1D numpy array using Cython.

    Args:
        arr: 1D numpy array of double precision floats

    Returns:
        double: Sum of all elements in the array
    """
    cdef int i
    cdef int n = arr.shape[0]
    cdef double total = 0.0

    for i in range(n):
        total += arr[i]

    return total

@cython.boundscheck(False)
@cython.wraparound(False)
def euclidean_distance(cnp.ndarray[DTYPE_t, ndim=1] a, cnp.ndarray[DTYPE_t, ndim=1] b):
    """
    Calculate Euclidean distance between two points using Cython.

    Args:
        a: First point as 1D numpy array
        b: Second point as 1D numpy array

    Returns:
        double: Euclidean distance between the points
    """
    cdef int i
    cdef int n = a.shape[0]
    cdef double diff, sum_sq = 0.0

    for i in range(n):
        diff = a[i] - b[i]
        sum_sq += diff * diff

    return sqrt(sum_sq)

def fibonacci(int n):
    """
    Calculate nth Fibonacci number using Cython.

    Args:
        n: Position in Fibonacci sequence

    Returns:
        int: nth Fibonacci number
    """
    cdef int a = 0
    cdef int b = 1
    cdef int i, temp

    if n <= 0:
        return 0
    elif n == 1:
        return 1

    for i in range(2, n + 1):
        temp = a + b
        a = b
        b = temp

    return b

cdef class FastCalculator:
    """
    A Cython class demonstrating fast mathematical operations.
    """
    cdef double x, y

    def __init__(self, double x, double y):
        self.x = x
        self.y = y

    cdef double _fast_multiply(self):
        """Internal fast multiplication method."""
        return self.x * self.y

    def multiply(self):
        """Public method to access fast multiplication."""
        return self._fast_multiply()

    def trigonometric_sum(self):
        """Calculate sin(x) + cos(y)."""
        return sin(self.x) + cos(self.y)

def test_functions():
    """
    Test function to verify all examples work correctly.
    """
    print("Testing Cython example functions...")

    # Test fast_sum
    arr = np.array([1.0, 2.0, 3.0, 4.0, 5.0])
    result = fast_sum(arr)
    print(f"fast_sum([1,2,3,4,5]) = {result}")

    # Test euclidean_distance
    point1 = np.array([0.0, 0.0])
    point2 = np.array([3.0, 4.0])
    distance = euclidean_distance(point1, point2)
    print(f"euclidean_distance([0,0], [3,4]) = {distance}")

    # Test fibonacci
    fib_10 = fibonacci(10)
    print(f"fibonacci(10) = {fib_10}")

    # Test FastCalculator
    calc = FastCalculator(3.14, 2.71)
    product = calc.multiply()
    trig_sum = calc.trigonometric_sum()
    print(f"FastCalculator(3.14, 2.71).multiply() = {product}")
    print(f"FastCalculator(3.14, 2.71).trigonometric_sum() = {trig_sum}")

    print("All tests completed successfully!")
