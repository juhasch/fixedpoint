from pytest import raises
from fixedpoint.numpy.fixedpoint import FixedPoint, Q



def test_fp_instantiate_1():
    """Test value, int and fract bits correctly stored"""
    v = 12
    m = 5
    n = 4
    a = FixedPoint(v, Q(m, n))
    assert a.value == v*2**n
    assert a.m == m
    assert a.n == n


def test_fp_instantiate_2():
    """Test value, int and fract bits correctly stored"""
    v = 7
    m = 4
    n = 5
    a = FixedPoint(v, Q(m, n), scale=False)
    assert a.value == v
    assert a.m == m
    assert a.n == n


def test_fp_instantiate_3():
    with raises(ValueError):
        a = FixedPoint(100, Q(5, 3))


def test_fp_float():
    a = FixedPoint(0.75, Q(5, 4))
    assert float(a) == 0.75


def test_fp_float():
    a = FixedPoint(7, Q(5, 4))
    assert int(a) == 7
    assert a.int == 7


def test_fp_to_fixedpoint():
    v = 3.5
    a = FixedPoint(v, Q(5, 4))
    assert a.to_fixedpoint(v) == a.value


def test_ft_fmt():
    v = 7
    m = 4
    n = 5
    a = FixedPoint(v, Q(m, n))
    assert a.fmt == f'Q{a.m}.{a.n}'


def test_ft_fract():
    v = 0.375
    a = FixedPoint(v, Q(5, 4))
    assert a.fract == v


def test_ft_minmaxal():
    a = FixedPoint(7, Q(5, 4))
    assert a.minval == a.Q.minval
    assert a.maxval == a.Q.maxval


def test_ft_resolution():
    a = FixedPoint(7, Q(5, 4))
    assert a.resolution == a.Q.resolution
