"""Fixed Point calculation with Python


"""
from __future__ import annotations
from math import floor
from .format import parse_fmt


class FixedPoint:
    """Class to perform fixed point operations on single values

    """
    fmt: str
    value: int

    def __init__(self, value: float, fmt: str):
        """FixedPoint number
        The value is stored as integer scaled by the n fractional bits

        Parameters
        ----------
        value
            Numerical value
        fmt
            Format string in the form 'Qm.n', where
                m is the number of integer bits
                n is the number of fractional bits

        Notes
        -----
            Q number format: https://en.wikipedia.org/wiki/Q_(number_format)

        """
        self.fmt = fmt
        self.m, self.n = parse_fmt(fmt)
        self.value = self.to_fixedpoint(value)

    def to_fixedpoint(self, value: float, fmt: str | None = None) -> int:
        """Convert floating point value to and integer with given format

        Parameters
        ----------
        value
            numeric value
        fmt
            Qm.n format string

        Returns
        -------
            Integer value scaled up by the number of fractional bits
        """
        if fmt is None:
            fmt = self.fmt
        if not self.minval <= value <= self.maxval:
            raise ValueError(f'A value of {value} does not fit in the given format {fmt}')
        numbits = self.m + self.n
        if numbits > 32:
            raise ValueError(f'Implementation only allows 32 Bits for now, '
                             f'{numbits} Bits were requested.')
        return int(value * 2 ** self.n)

    def to(self, fmt: str, policy: str = 'exact') -> FixedPoint:
        """Coerce to new format according to policy

        Parameters
        ----------
        fmt
            New Format
        policy
            Rounding policy
                exact: value must fit into new format without loss
                round: fractional part is rounded to fit
                fit: value is rounded to nearest value and saturates if larger than value range

        Returns
        -------
            FixedPoint class

        """
        fp = self.__class__(0, fmt)
        val = float(self)
        if policy == 'fit':
            if val > 0:
                val = min(fp.maxval, val)
            else:
                val = max(fp.minval, val)
            fp.value = fp.to_fixedpoint(val)
        elif policy == 'round':
            fp.value = fp.to_fixedpoint(val)
        elif policy == 'exact':
            fp.value = fp.to_fixedpoint(val)
            if float(fp) != val and policy == 'exact':
                raise ValueError(f'Rounding error not allowed with policy {policy} set.')
        else:
            raise ValueError(f'Invalid policy {policy} given.')
        return fp

    @property
    def minval(self) -> float:
        """Minimum value for FixedPoint number"""
        return -(2 ** (self.m - 1))

    @property
    def maxval(self) -> float:
        """Maximum value for FixedPoint number"""
        return 2 ** (self.m - 1) - 2 ** (-self.n)

    @property
    def resolution(self) -> float:
        """Resolution of FixedPoint number"""
        return 2 ** (-self.n)

    @property
    def integer(self) -> int:
        """Return integer part of value"""
        return self.value >> self.n

    def __round__(self, n=None):
        return self.__class__(round(float(self), n), self.fmt)

    @property
    def fract(self) -> float:
        """Return fractional part"""
        return floor(self.value & (2 ** self.n - 1)) / 2 ** self.n

    def __add__(self, other) -> FixedPoint:
        """Add two values
        Adding two FixedPoint values means Q4.2 + Q4.2 -> Q5.2

        Parameters
        ----------
        other
            other value to add
            if type is FixedPoint, the number of int bits (m) -> (m+1)
        """
        if isinstance(other, FixedPoint):
            m = max(self.m, other.m) + 1
            n = max(self.n, other.n)
            newval = (self.value << (n - self.n)) + (other.value << (n - other.n))
            newfmt = f'Q{m}.{n}'
            return self.__class__(newval * 2 ** -n, newfmt)
        newval = self.value * 2 ** -self.n + other
        return self.__class__(newval, self.fmt)

    def __sub__(self, other):
        """Subtract two values

        Substracting two FixedPoint values means Q4.2 + Q4.2 -> Q5.2

        Parameters
        ----------
        other
            other value to add
            if type is FixedPoint, the number of int bits (m) -> (m+1)
        """
        if isinstance(other, FixedPoint):
            m = max(self.m, other.m) + 1
            n = max(self.n, other.n)
            newval = (self.value << (n - self.n)) - (other.value << (n - other.n))
            newfmt = f'Q{m}.{n}'
            return self.__class__(newval * 2 ** -n, newfmt)
        newval = self.value * 2 ** -self.n - other
        return self.__class__(newval, self.fmt)

    def __repr__(self):
        return f"FixedPoint({self.__float__()}, '{self.fmt}')"

    def __float__(self):
        return self.value * 2 ** -self.n

    def __int__(self):
        return self.integer

    def __divmod__(self, other):
        return 0

    def __mul__(self, other):
        """Multiply two values
         Multiplying two FixedPoint values means Q4.2 + Q4.2 -> Q8.2

         Parameters
         ----------
         other
             other value to multiply
             if type is FixedPoint, the number of int bits (m) -> (m+m_other)
         """
        newval = float(self) * float(other)
        if isinstance(other, FixedPoint):
            m = self.m + other.m
            n = max(self.n, self.n)
            newfmt = f'Q{m}.{n}'
            return self.__class__(newval, newfmt)
        return self.__class__(newval, self.fmt)

    def __rmul__(self, other):
        return self.__mul__(other)

    def __floor__(self):
        return self.value >> self.n

    def __floordiv__(self, other):
        return 0

    def __div__(self, other):
        """Divide two values
         **TODO** Multiplying two FixedPoint values means Q4.2 + Q4.2 -> Q8.2

         Parameters
         ----------
         other
             other value to multiply
             **TODO**if type is FixedPoint, the number of int bits (m) -> (m+m_other)
         """
        newval = float(self) / float(other)
        if isinstance(other, FixedPoint):
            m = self.m + other.n
            n = max(self.n, self.m)
            newfmt = f'Q{m}.{n}'
            return self.__class__(newval, newfmt)
        return self.__class__(newval, self.fmt)

    def __rdiv__(self, other):
        return self.__div__(other)

    def __truediv__(self, other):
        return self.__div__(other)

    def __rmod__(self, other):
        return 0

    def __eq__(self, other):
        if isinstance(other, FixedPoint) and self.fmt == other.fmt:
            return self.value == other.value
        return float(self) == float(other)

    def __ne__(self, other):
        if isinstance(other, FixedPoint) and self.fmt == other.fmt:
            return self.value != other.value
        return float(self) != float(other)

    def __gt__(self, other):
        if isinstance(other, FixedPoint) and self.fmt == other.fmt:
            return self.value > other.value
        return float(self) > float(other)

    def __ge__(self, other):
        if isinstance(other, FixedPoint) and self.fmt == other.fmt:
            return self.value >= other.value
        return float(self) >= float(other)

    def __le__(self, other):
        if isinstance(other, FixedPoint) and self.fmt == other.fmt:
            return self.value <= other.value
        return float(self) <= float(other)

    def __lt__(self, other):
        if isinstance(other, FixedPoint) and self.fmt == other.fmt:
            return self.value < other.value
        return float(self) < float(other)

    def __neg__(self):
        return self.__class__(self.to_fixedpoint(-float(self.value)), self.fmt)

    def __pos__(self):
        return self.__class__(self.to_fixedpoint(abs(float(self.value))), self.fmt)

    def __pow__(self, power: int) -> FixedPoint:
        """Calculate power of FixedPoint value

         Parameters
         ----------
         power
            power to take
            number of int bits increase (m) -> (m*power)
         """
        newval = float(self) ** power
        m = self.m * power
        n = self.n
        newfmt = f'Q{m}.{n}'
        return self.__class__(newval, newfmt)

    def __abs__(self):
        return self.__class__(self.to_fixedpoint(abs(float(self.value))), self.fmt)

    def __mod__(self, other):
        return 0

    def __radd__(self, other):
        return self.__add__(other)

    def __rsub__(self, other):
        return self.__sub__(other)

    def __rtruediv__(self, other):
        return self.__div__(other)

    def __rfloordiv__(self, other):
        return self.__floordiv__(other)

    def __rpow__(self, other):
        return self.__pow__(other)

    def __rdivmod__(self, other):
        return self.__divmod__(other)

    def __lshift__(self, other):
        return self.__class__(self.value << other, self.fmt)

    def __rshift__(self, other):
        return self.__class__(self.value >> other, self.fmt)
