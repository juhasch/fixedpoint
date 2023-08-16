from __future__ import annotations
from typing import Tuple
import re


def parse_fmt(fmt: str) -> Tuple[int, int]:
    """Parse Q<m>.<n> string

    Parameters
    ----------
    fmt
            Format string in the form 'Qm.n', where
                m is the number of integer bits
                n is the number of fractional bits

    Returns
    -------
    n, m
        Number of int and fract bits
    """
    match = re.match(r'^Q(\d+).(\d+)', fmt)
    if match is None:
        raise ValueError(f'Invalid format specification {fmt}')
    m = int(match.group(1))
    n = int(match.group(2))
    return m, n


