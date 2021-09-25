# FixedPoint

A simple Python module for fixedpoint calculations. This is work-in-progress, also
the Python and Numpy Cython side exhibit a slightly different interface.

Example:

    >>> from fixedpoint import FixedPoint
    >>> a = FixedPoint(3.45, 'Q4.4')
    >>> a
    FixedPoint(3.4375, 'Q4.4')
    >>> a+1
    FixedPoint(4.4375, 'Q4.4')

A protoype implementation of a custom dtype for Numpy is work-in-progress.
For the Numpy-side see: https://github.com/numpy/numpy/pull/19919 

Example:

    >>> from fixedpoint.numpy.fixedpoint import FixedPoint, FixedPointDType, Q
    >>> import numpy as np
    >>> a = FixedPoint(3.1, Q(4,5))
    >>> a
    3.09375 (Q4.5)
    >>> z = np.zeros(8, dtype=FixedPointDType(Q(4, 5)))
    >>> z
    array([0.0 (Q4.5), 0.0 (Q4.5), 0.0 (Q4.5), 0.0 (Q4.5), 0.0 (Q4.5),
           0.0 (Q4.5), 0.0 (Q4.5), 0.0 (Q4.5)], dtype=FixedPointDType(Q4.5))
    >>> z + a
    array([3.09375 (Q5.5), 3.09375 (Q5.5), 3.09375 (Q5.5), 3.09375 (Q5.5),
           3.09375 (Q5.5), 3.09375 (Q5.5), 3.09375 (Q5.5), 3.09375 (Q5.5)],
          dtype=FixedPointDType(Q5.5))

(C) 2021 Juergen Hasch



