"""Tests for FixedPoint class"""
from pytest import raises
from fixedpoint import FixedPoint


def test_instantiate_1():
    """Test value, int and fract bits correctly stored"""
    a = FixedPoint(1, 'Q2.0')
    assert a.value == 1
    assert a.m == 2
    assert a.n == 0


def test_instantiate_2():
    """Test negative value"""
    a = FixedPoint(-1, 'Q2.0')
    assert a.value == -1
    assert a.m == 2
    assert a.n == 0


def test_instantiate_3():
    a = FixedPoint(-2, 'Q2.0')
    assert a.value == -2
    assert a.m == 2
    assert a.n == 0


def test_instantiate_4():
    """Test invalid format"""
    with raises(ValueError):
        a = FixedPoint(1.5, 'Q2.0')


def test_instantiate_6():
    """Test invalid format"""
    with raises(ValueError):
        a = FixedPoint(1.5, 'Q0.4')


def test_instantiate_7():
    """Test for too large numbers"""
    with raises(ValueError):
        a = FixedPoint(1.5, 'Q20.204')


def test_instantiate_8():
    """Test value stored as int"""
    a = FixedPoint(0.1, 'Q0.4')
    assert a.value == 1


def test_minval():
    a = FixedPoint(1, 'Q2.1')
    assert a.minval == -2


def test_maxval():
    a = FixedPoint(1, 'Q2.1')
    assert a.maxval == 1.5


def test_repr():
    a = FixedPoint(1, 'Q2.1')
    assert a.__repr__() == "FixedPoint(1.0, 'Q2.1')"


def test_float():
    a = FixedPoint(1, 'Q2.1')
    assert float(a) == 1.0


def test_int():
    a = FixedPoint(1, 'Q2.1')
    assert int(a) == 1


# def test_remainder():
#    a = FixedPoint(1.5, 'Q2.2')
#    assert a%1 == 0.5

def test_le_1():
    a = FixedPoint(1, 'Q2.8')
    assert a < 1.1


def test_le_2():
    a = FixedPoint(1, 'Q2.8')
    b = FixedPoint(1.1, 'Q2.8')
    assert a < b


def test_lt_1():
    a = FixedPoint(1, 'Q2.8')
    assert a < 1.1


def test_lt_2():
    a = FixedPoint(1, 'Q2.8')
    b = FixedPoint(1.1, 'Q2.8')
    assert a < b


def test_ge_1():
    a = FixedPoint(1, 'Q2.8')
    assert a > 0.9


def test_ge_2():
    a = FixedPoint(1, 'Q2.8')
    b = FixedPoint(1.1, 'Q2.8')
    assert b > a


def test_gt_1():
    a = FixedPoint(1, 'Q2.8')
    assert a > 0.9


def test_gt_2():
    a = FixedPoint(1, 'Q2.8')
    b = FixedPoint(1.1, 'Q2.8')
    assert b > a


def test_eq_1():
    a = FixedPoint(1, 'Q2.8')
    assert a == 1


def test_eq_2():
    a = FixedPoint(1, 'Q2.8')
    b = FixedPoint(1, 'Q2.8')
    assert a == b


def test_div():
    a = FixedPoint(2, 'Q4.8')
    assert float(a / 2) == 1


def test_power():
    a = FixedPoint(2, 'Q4.8')
    b = a ** 2
    assert float(b) == 4
    assert a.n == b.n
    assert 2 * a.m == b.m


def test_power_3():
    a = FixedPoint(2, 'Q4.8')
    b = a ** 3
    assert float(b) == 8
    assert a.n == b.n
    assert 3 * a.m == b.m
