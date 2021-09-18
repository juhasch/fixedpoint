Fixed Point Data Format
=======================


A fixed point number is specified as `"Q<m>.<n>"`, where `<m>` is the number of integer bits
and `<n>` is the number of fractional bits. It is a signed number stored in two's complement.

The number range is from -2^(m-1) to 2^(m-1) - 2^(-n) with a resolution of 2^-n
For example, `Q3.4` gives a number range from -4 to 3.975 with a resolution of 0.0625.

For a more detailed documentation see Q (number format) <https://en.wikipedia.org/wiki/Q_%28number_format%29>.

