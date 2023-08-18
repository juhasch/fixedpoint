# FixedPoint

FixedPoint is a Python module designed to perform fixed-point calculations. It provides a simple and efficient way to handle fixed-point numbers in your Python applications.

## Features

- Implements fixed-point calculations for single numbers.
- Easy to use and integrate into your Python projects.
- Provides accurate results, ideal for financial and scientific computations.

## Installation

You can install FixedPoint using pip:
    bash
    pip install FixedPoint

## Usage

Here's a basic example of how to use the FixedPoint module:

    >>> from FixedPoint import FixedPoint
    >>> # Create a fixed point number
    >>> fp = FixedPoint(10.5, 'Q6.4')
    >>> # Perform some calculations
    >>> fp  + 2
    FixedPoint(12.5, 'Q6.4')
    >>> fp.maxval
    31.9375

## Contributing

We welcome contributions! Please see our contributing guidelines for details.

## License

This project is licensed under the terms of the MIT license.

## Author

FixedPoint was created by Juergen Hasch in 2021.
