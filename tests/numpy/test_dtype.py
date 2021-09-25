from fixedpoint.numpy.fixedpoint import FixedPoint, FixedPointDType, Q
import numpy as np


def test_dtype_1():
    q = Q(5, 4)
    dt = FixedPointDType(q)
    assert q == dt.Q
    assert str(dt) == f'FixedPointDType({q})'


def test_dtype_2():
    q = Q(5, 4)
    a = FixedPoint(0.375, q)
    b = np.array([a])
    assert str(b.dtype) == f'FixedPointDType({q})'
    assert b[0].Q == a.Q


def test_dtype_3():
    q = Q(5, 4)
    a = np.zeros(9, dtype=FixedPointDType(q))
    assert str(a.dtype) == f'FixedPointDType({q})'
