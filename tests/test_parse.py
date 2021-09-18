"""Tests for FixedPoint class"""
from pytest import raises
from fixedpoint.format import parse_fmt


def test_format():
    """Test parsing"""
    assert parse_fmt('Q1.2') == (1, 2)
    assert parse_fmt('Q1,2') == (1, 2)


def test_format_1():
    """Test invalid format"""
    with raises(ValueError):
        assert parse_fmt('Q1,') == (1, 2)


def test_format_2():
    """Test invalid format"""
    with raises(ValueError):
        assert parse_fmt('Q.2') == (1, 2)
