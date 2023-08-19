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
    """Test negative value"""
    a = FixedPoint(-2, 'Q2.0')
    assert a.value == -2
    assert a.m == 2
    assert a.n == 0


def test_instantiate_4():
    """Test invalid format"""
    with raises(ValueError):
        FixedPoint(1.5, 'Q2.0')


def test_instantiate_6():
    """Test invalid format"""
    with raises(ValueError):
        FixedPoint(1.5, 'Q0.4')


def test_instantiate_7():
    """Test for too large numbers"""
    with raises(ValueError):
        FixedPoint(1.5, 'Q20.204')


def test_instantiate_8():
    """Test value stored as int"""
    a = FixedPoint(0.1, 'Q0.4')
    assert a.value == 1


def test_minval():
    """Test minval property"""
    a = FixedPoint(1, 'Q2.1')
    assert a.minval == -2


def test_maxval():
    """Test maxval property"""
    a = FixedPoint(1, 'Q2.1')
    assert a.maxval == 1.5


def test_repr():
    """Test __repr__ method"""
    a = FixedPoint(1, 'Q2.1')
    assert repr(a) == "FixedPoint(1.0, 'Q2.1')"


def test_float():
    """Test __float__ method"""
    a = FixedPoint(1, 'Q2.1')
    assert float(a) == 1.0


def test_int():
    """Test __int__ property"""
    a = FixedPoint(1, 'Q2.1')
    assert int(a) == 1


# def test_remainder():
#    a = FixedPoint(1.5, 'Q2.2')
#    assert a%1 == 0.5

def test_le_1():
    """Test __le__ method between class and int"""
    a = FixedPoint(1, 'Q2.8')
    assert a < 1.1


def test_le_2():
    """Test __le__ method betwee two classes"""
    a = FixedPoint(1, 'Q2.8')
    b = FixedPoint(1.1, 'Q2.8')
    assert a < b


def test_lt_1():
    """Test __lt__ method between class and int"""
    a = FixedPoint(1, 'Q2.8')
    assert a < 1.1


def test_lt_2():
    """Test __lt__ method betwee two classes"""
    a = FixedPoint(1, 'Q2.8')
    b = FixedPoint(1.1, 'Q2.8')
    assert a < b


def test_ge_1():
    """Test __ge__ method between class and int"""
    a = FixedPoint(1, 'Q2.8')
    assert a > 0.9


def test_ge_2():
    """Test __ge__ method betwee two classes"""
    a = FixedPoint(1, 'Q2.8')
    b = FixedPoint(1.1, 'Q2.8')
    assert b > a


def test_gt_1():
    """Test __gt__ method between class and int"""
    a = FixedPoint(1, 'Q2.8')
    assert a > 0.9


def test_gt_2():
    """Test __gt__ method betwee two classes"""
    a = FixedPoint(1, 'Q2.8')
    b = FixedPoint(1.1, 'Q2.8')
    assert b > a


def test_eq_1():
    """Test __eq__ method between class and int"""
    a = FixedPoint(1, 'Q2.8')
    assert a == 1


def test_eq_2():
    """Test __eq__ method betwee two classes"""
    a = FixedPoint(1, 'Q2.8')
    b = FixedPoint(1, 'Q2.8')
    assert a == b


def test_div():
    """Test __div__ method"""
    a = FixedPoint(2, 'Q4.8')
    assert float(a / 2) == 1


def test_power():
    """Test __pow__ method"""
    a = FixedPoint(2, 'Q4.8')
    b = a ** 2
    assert float(b) == 4
    assert a.n == b.n
    assert 2 * a.m == b.m


def test_power_3():
    """Test __pow__ method"""
    a = FixedPoint(2, 'Q4.8')
    b = a ** 3
    assert float(b) == 8
    assert a.n == b.n
    assert 3 * a.m == b.m
