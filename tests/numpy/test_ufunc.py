from fixedpoint.numpy.fixedpoint import FixedPoint, FixedPointDType, Q
import numpy as np
from hypothesis import given, strategies as st
import random


@given(m=st.integers(1, 10), n=st.integers(1, 10))
def test_add_1(m, n):
    q = Q(m, n)
    v1 = random.uniform(q.minval, q.maxval)
    v2 = random.uniform(q.minval, q.maxval)
    a = np.array([FixedPoint(v1, q)])
    b = np.array([FixedPoint(v2, q)])
    c = a + b
    assert c[0].value == a[0].value + b[0].value
    assert c[0].m == a[0].m + 1
    assert c[0].n == a[0].n


@given(m=st.integers(1, 10), n=st.integers(1, 10))
def test_add_2(m, n):
    q = Q(m, n)
    v = random.uniform(q.minval, q.maxval)
    a = np.array([FixedPoint(v, q)])
    b = np.zeros(8, dtype=FixedPointDType(q))
    c = b + a
    assert c[0].value == a[0].value
    assert c[0].m == a[0].m + 1
    assert c[0].n == a[0].n


@given(m=st.integers(2, 10), n=st.integers(2, 10))
def test_subtract_1(m, n):
    q = Q(m, n)
    v1 = random.uniform(q.minval, q.maxval)
    v2 = random.uniform(q.minval, q.maxval)
    a = np.array([FixedPoint(v1, q)])
    b = np.array([FixedPoint(v2, q)])
    c = a - b
    assert float(c[0]) == float(a[0] - b[0])
    assert c[0].m == a[0].m + 1
    assert c[0].n == a[0].n


@given(m=st.integers(1, 10), n=st.integers(1, 10))
def test_sub_2(m, n):
    q = Q(m, n)
    v = random.uniform(q.minval, q.maxval)
    a = np.array([FixedPoint(v, q)])
    b = np.zeros(8, dtype=FixedPointDType(q))
    c = a - b
    assert c[0].value == a[0].value
    assert c[0].m == a[0].m + 1
    assert c[0].n == a[0].n


def test_multiply():
    a = np.array([FixedPoint(2, Q(5, 4))])
    b = np.array([FixedPoint(3, Q(5, 4))])
    c = a * b


#def test_divide():
#    a = np.array([FixedPoint(2, Q(5, 4))])
#    b = np.array([FixedPoint(3, Q(5, 4))])
#    c = a / b
