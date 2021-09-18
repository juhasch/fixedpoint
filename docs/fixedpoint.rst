FixedPoint
==========

Allows fixed point calculation for single numbers. The number is stored as integer and
converted to a float number having `m` integer and `n` fractional bits.

A simple example:

    >>> from fixedpoint import FixedPoint
    >>> a = FixedPoint(3.45, 'Q4.4')
    >>> a
    FixedPoint(3.4375, 'Q4.4')
    >>> a+1
    FixedPoint(4.4375, 'Q4.4')

Functionality
-------------

Value range and resolution:

    >>> from fixedpoint import FixedPoint
    >>> a = FixedPoint(3.45, 'Q4.4')
    >>> a.minval, a.maxval, a.resolution
    (-8, 7.9375, 0.0625)


Integer and fractional part:

    >>> from fixedpoint import FixedPoint
    >>> a = FixedPoint(3.45, 'Q4.4')
    >>> a.int, a.fract
    (3, 0.4375)

Internal storage:

    >>> from fixedpoint import FixedPoint
    >>> a = FixedPoint(3.45, 'Q5.4')
    >>> a.m, a.n, a.value
    (5, 4, 55)


Changing resolution using `.to('Qm.n')` format specifier:
    >>> from fixedpoint import FixedPoint
    >>> a = FixedPoint(3.45, 'Q5.4')
    >>> a, a.value
    (FixedPoint(3.4375, 'Q5.4'), 55)
    >>> b = a.to('Q6.5')
    >>> b, b.value
    (FixedPoint(3.4375, 'Q6.5'), 110)

Resolution conversion options:
    >>> from fixedpoint import FixedPoint
    >>> a = FixedPoint(3.45, 'Q5.4')
    (FixedPoint(3.4375, 'Q5.4'), 55)
    >>> b = a.to('Q6.3')
    ValueError: Rounding error not allowed with policy exact set.
    >>> b = a.to('Q6.3', policy='round')
    (FixedPoint(3.375, 'Q3.4'), 27)
    >>> b = a.to('Q1.3', policy='fit')
    (FixedPoint(0.875, 'Q1.3'), 7)

Supported operations:

* Add, subtract, multiply, divide, comparison, power

    >>> a = FixedPoint(3.45, 'Q5.4')
    >>> b = FixedPoint(1.23, 'Q5.4')
    >>> a, b
    (FixedPoint(3.4375, 'Q5.4'), FixedPoint(1.1875, 'Q5.4'))
    >>> a+b
    FixedPoint(4.625, 'Q6.4')
    >>> a-b
    FixedPoint(2.25, 'Q6.4')
    >>> a*b
    FixedPoint(4.0625, 'Q10.4')
    >>> a/b
    FixedPoint(2.875, 'Q9.5')
    >>> a**2
    FixedPoint(11.8125, 'Q10.4')
    >>> a > b
    True
    >>> a > 1, a < 1
    (True, False)

