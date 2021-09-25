from pytest import raises
from fixedpoint.numpy.fixedpoint import Q
from hypothesis import given, strategies as st


@given(m=st.integers(), n=st.integers())
def test_instantiate_q(m, n):
    if m+n > 32:
        with raises(ValueError):
            q = Q(m, n)
    else:
        q = Q(m, n)
        assert m == q.m
        assert n == q.n


@given(m=st.integers(0, 32))
def test_q_minval(m):
    n = 0
    q = Q(m, n)
    assert q.minval == -2**(m-1)


@given(m=st.integers(1, 8), n=st.integers(1, 14))
def test_q_maxval(m, n):
    q = Q(m, n)
    assert q.maxval == 2**(m-1)-1/2**n


@given(n=st.integers(0, 20))
def test_q_resolution(n):
    q = Q(8, n)
    assert q.resolution == 1/2**n
