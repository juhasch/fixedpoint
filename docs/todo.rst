TODO
====


* support dtype int
* print

* shape for complex numbers:

    >>> ra = np.random.rand(N,3) +1j*np.random.rand(N,3)
    >>> a = FixedPointArray(ra, 'Q8.8')
    >>> a
    FixedPointArray([[0.25      +0.28125j    0.37109375+0.3125j    ]
     [0.234375  +0.8984375j  0.4453125 +0.13671875j]
     [0.2890625 +0.421875j   0.5625    +0.1171875j ]
     [0.60546875+0.2421875j  0.265625  +0.00390625j]], 'Q8.8')
    >>> a.shape
    (4, 3, 2)

* implement numpy functions

  * generic int view for functions that can handle ints. Check if result fits in given number format after calling ufunc
  * generic float conversion for floating point functions

* correct size calculations for add/subtract/multiply/divide
