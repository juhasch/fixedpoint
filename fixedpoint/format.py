from __future__ import annotations
from typing import Tuple


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
    if not fmt.startswith('Q'):
        raise ValueError(f'Invalid format specification {fmt}')
    
    parts = fmt[1:].split('.')
    if len(parts) != 2:
        raise ValueError(f'Invalid format specification {fmt}')
    
    try:
        m = int(parts[0])
        n = int(parts[1])
    except ValueError:
        raise ValueError(f'Invalid format specification {fmt}')
    
    return m, n

