# FixedPoint

FixedPoint is a Python module designed to perform fixed-point calculations
for single numbers. 

Main use is to try out approaches for a NumPy dtype extension.

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
