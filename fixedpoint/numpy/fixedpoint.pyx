#cython: language_level=3

from cpython.object cimport (
        PyObject, PyTypeObject, Py_TPFLAGS_DEFAULT, Py_TPFLAGS_BASETYPE)
from cpython.ref cimport Py_INCREF
from cpython.type cimport PyType_Ready
from libc.string cimport memcpy
cimport numpy as npc

from . cimport dtype_api
from . import dtypes as _npdtypes


import numpy as np
import cython

cdef extern from "math.h":
    double floor(double x)


__all__ = ["FixedPoint", "FixedPointDType", "Q"]

dtype_api.import_experimental_dtype_api(1)

cdef class Q:
    cdef readonly m
    cdef readonly n
    def __init__(self, m:int, n: int):
        """Fixpoint number format specification

        Parameters
        ----------
        m
            is the number of integer bits
        n
            is the number of fractional bits

        Notes
        -----
            Q number format: https://en.wikipedia.org/wiki/Q_(number_format)
        """
        if m+n > 32:
            raise ValueError('Maximum number of bits for number format is 32 (n+m={n+m}')
        self.m = m
        self.n = n

    def __repr__(self) -> str:
        return f"Q{self.m}.{self.n}"

    def __eq__(self, other):
        return self.m == other.m and self.n == other.n

    def __add__(self, other):
        m = max(self.m, other.m) + 1
        n = max(self.n, other.n)
        return self.__class__(m, n)

    def __sub__(self, other):
        m = max(self.m, other.m) + 1
        n = max(self.n, other.n)
        return self.__class__(m, n)

    def __mul__(self, other):
        m = self.m + other.m
        n = max(self.n, other.n)
        return self.__class__(m, n)

    def __div__(self, other):
        m = self.m + other.n
        n = max(self.n, self.m)
        return self.__class__(m, n)

    @property
    def minval(self) -> float:
        """Minimum value for FixedPoint number"""
        return -(2 ** (self.m - 1))

    @property
    def maxval(self) -> float:
        """Maximum value for FixedPoint number"""
        ret: cython.float
        ret = 2 ** (self.m - 1)  - 1.0/ 2**self.n
        #ret = self.m
        return ret

    @property
    def resolution(self) -> float:
        """Resolution of FixedPoint number"""
        return 1.0 / 2 ** self.n


cdef class FixedPoint:
    cdef readonly long value
    cdef readonly object Q  # temporary hack

    def __cinit__(self, value: [int, float], q: Q, scale=True):
        """FixedPoint number
        The value is stored as integer scaled by the n fractional bits

        Parameters
        ----------
        value
            Numerical value as unsigned in representing a fixed point float
        q
            format specification
        scale
            If true, scale input value according to format specification
        """
        self.Q = q
        if scale:
            self.value = self.to_fixedpoint(value)
        else:
            self.value = value

    @property
    def fmt(self):
        return f'Q{self.Q.m}.{self.Q.n}'

    def to_fixedpoint(self, value):
        """Convert float to fixedpoint integer value according to Q format"""
        if not self.Q.minval <= value <= self.Q.maxval:
            raise ValueError(f'A value of {value} does not fit in the given format Q{self.Q.m}.{self.Q.n}')
        numbits = self.Q.m + self.Q.n
        if numbits > 32:
            raise ValueError(f'Implementation only allows 32 Bits for now, {numbits} Bits were requested.')
        return int(value * 2 ** self.Q.n)

    @property
    def minval(self) -> float:
        return self.Q.minval

    @property
    def maxval(self) -> float:
        return self.Q.maxval

    @property
    def resolution(self) -> float:
        return self.Q.resolution

    @property
    def int(self):
        """Return integer part of value"""
        return self.value >> self.Q.n

    @property
    def m(self):
        return self.Q.m

    @property
    def n(self):
        return self.Q.n

    @property
    def fract(self) -> float:
        """Return fractional part"""
        return floor(<float>(self.value & (2 ** self.Q.n - 1))) / 2 ** self.Q.n

    def __repr__(self) -> str:
        return f"{self.__float__()} (Q{self.m}.{self.n})"

    def __int__(self) -> int:
        return self.int

    def __float__(self)-> float:
        return <float>self.value / 2 ** self.Q.n

    def __add__(self, other) -> 'FixedPoint':
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
            return self.__class__(newval * 2 ** -n, Q(m, n), scale=True)
        else:
            newval = self.value * 2 ** -self.n + other
            return self.__class__(newval, self.Q, scale=True)
    def __sub__(self, other) -> 'FixedPoint':
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
            return self.__class__(newval * 2 ** -n, Q(m, n), scale=True)
        else:
            newval = self.value * 2 ** -self.Q.n - other
            return self.__class__(newval, self.Q, scale=True)

    def __mul__(self, other) -> 'FixedPoint':
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
            n = max(self.n, other.n)
            return self.__class__(newval, Q(m, n), scale=True)
        else:
            return self.__class__(newval, self.Q, scale=True)

    def __rmul__(self, other):
        return self.__mul__(other)

    def __pow__(self, power: int, modulo) -> 'FixedPoint':
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
        return self.__class__(newval, Q(m, n), scale=True)

    def __abs__(self) -> 'FixedPoint':
        return self.__class__(self.to_fixedpoint(abs(float(self.value))), self.Q, scale=True)

    def __floor__(self):
        return self.value >> self.Q.n


cdef object common_dtype(self, other):
    # Must return a DType (or NotImplemented)
    if other in (_npdtypes.Float16, _npdtypes.Float32, _npdtypes.Float64):
        return other
    return NotImplemented

cdef object common_instance(descr1, descr2):
    raise ValueError("Not implemented, maybe will even force exact match?")


cdef object discover_descr_from_pyobject(cls, obj):
    cdef FixedPoint fixedpoint
    # Must return a descriptor (or an error).
    if isinstance(obj, FixedPoint):
        fixedpoint = <FixedPoint>obj
        return cls(fixedpoint.Q)

    # Must be a builtin, use "dimensionless":
    return cls("")


cdef int setitem(_FixedPointDTypeBase self, object obj, char *ptr) except -1:
    cdef long value

    if isinstance(obj, FixedPoint):
        print(obj)
        print(self)
        value = obj.value
        if obj.Q != self.Q:
            raise NotImplementedError("not implemented yet")
    else:
        value = obj

    # This allows force-casting dimensionless to dimension.
    memcpy(ptr, <void *>&value, sizeof(double))
    return 0


cdef object getitem(_FixedPointDTypeBase self, char *ptr):
    cdef long value
    memcpy(<void *>&value, ptr, sizeof(long))
    return FixedPoint(value, self.Q, scale=False)


#cdef extern from *:
#    """
#    typedef struct{
#        unsigned int n : 4;
#        unsigned int m : 4;
#        unsigned long long value: 56;
#    } FixedPoint;
#    """

cdef class _FixedPointDTypeBase(npc.dtype):
    # This is an aweful hack, this type must NOT be used!
    # Further, this will lock us in on the ABI size of `PyArray_Descr`
    # (which is probably fine, lets just add a `void *reserved` maybe?)
    cdef readonly object Q
    def __cinit__(self, Q):
        if (type(type(self)) is not type(np.dtype)
                or type(self) is _FixedPointDTypeBase):
            # The "base" class must not be instantiated (the first check should
            # cover the second one as well really).
            raise RuntimeError("Invalid use of implementation detail!")
        self.Q = Q
        self.itemsize = 2*sizeof(int) + sizeof(long)
        self.alignment = 2*sizeof(int) + sizeof(long)

    @property
    def name(self):
        return f"FixedPointDType(Q{self.Q.m}.{self.Q.n})"

    def __repr__(self):
        return self.name

    def __str__(self):
        return self.name


cdef npc.NPY_CASTING unit_to_unit_cast_resolve_descriptors(method,
        PyObject *dtypes[2],
        PyObject *descrs[2], PyObject *descrs_out[2]) except <npc.NPY_CASTING>-1:
    """
    The resolver function, could possibly provide a default for this type
    of unary/casting resolver.
    """
    cdef npc.NPY_CASTING casting
    if descrs[1] == <PyObject *>0:
        # Shouldn't really happen a cast function?
        Py_INCREF(<object>descrs[0])
        descrs_out[0] = <PyObject *>descrs[0]
        Py_INCREF(<object>descrs[0])
        descrs_out[1] = <PyObject *>descrs[0]

    # For units, we have to check it "twice" unfortunately (currently more
    # potentially):
    conv = (<_FixedPointDTypeBase>descrs[0]).unit.get_conversion_factor(
                (<_FixedPointDTypeBase>descrs[1]).unit)
    if conv == (1.0, None):
        casting = <npc.NPY_CASTING>(
                        npc.NPY_SAFE_CASTING | dtype_api.NPY_CAST_IS_VIEW)
    else:
        # Casting can be lossy, so don't lie about that:
        casting = npc.NPY_SAME_KIND_CASTING

    Py_INCREF(<object>descrs[0])
    descrs_out[0] = <PyObject *>descrs[0]
    Py_INCREF(<object>descrs[1])
    descrs_out[1] = <PyObject *>descrs[1]
    return casting


cdef int string_equal_strided_loop(
        dtype_api.PyArrayMethod_Context *context,
        char **data, npc.intp_t *dimensions, npc.intp_t *strides,
        void *userdata) nogil except -1:
    cdef npc.intp_t N = dimensions[0]
    cdef char *vals_in = <char *>data[0]
    cdef char *vals_out = <char *>data[1]
    cdef npc.intp_t strides_in = strides[0]
    cdef npc.intp_t strides_out = strides[1]

    cdef double factor
    cdef double offset = 0
    with gil:
        # NOTE: This GIL block should be part of of the _get_loop, but I
        #       did not make that publically available yet due to bad API.
        #       We could at least "cache" these in `userdata`, but that would
        #       require working with the NpyAuxdata, so lets not do that...
        Q1 = (<_FixedPointDTypeBase>context.descriptors[0]).Q
        Q2 = (<_FixedPointDTypeBase>context.descriptors[1]).Q

#        factor, offset_obj = unit1.get_conversion_factor(Q2)
#        if offset_obj is not None:
#            offset = offset_obj

    for i in range(N):
        (<long *>vals_out)[0] = (<long *>vals_in)[0]

        vals_in += strides_in
        vals_out += strides_out

    return 0


cdef int string_equal_strided_loop_unaligned(
        dtype_api.PyArrayMethod_Context *context,
        char **data, npc.intp_t *dimensions, npc.intp_t *strides,
        void *userdata) nogil except -1:
    cdef npc.intp_t N = dimensions[0]
    cdef char *vals_in = data[0]
    cdef char *vals_out = data[1]
    cdef npc.intp_t strides_in = strides[0]
    cdef npc.intp_t strides_out = strides[1]

    cdef int value

    with gil:
        Q1 = (<_FixedPointDTypeBase>context.descriptors[0]).Q
        Q2 = (<_FixedPointDTypeBase>context.descriptors[1]).Q

        # FIXME: Q1 = Q2

    for i in range(N):
        memcpy(&value, vals_in, sizeof(long))
        memcpy(vals_out, &value, sizeof(long))
        vals_in += strides_in
        vals_out += strides_out

    return 0



cdef dtype_api.PyArrayDTypeMeta_Spec spec
spec.name = "FixedPointDType"
spec.typeobj = <PyTypeObject *>FixedPoint
spec.flags = dtype_api.NPY_DT_PARAMETRIC

# Generic DType slots:
cdef dtype_api.PyType_Slot slots[6]
spec.slots = slots
slots[0].slot = dtype_api.NPY_DT_common_dtype
slots[0].pfunc = <void *>common_dtype
slots[1].slot = dtype_api.NPY_DT_common_instance
slots[1].pfunc = <void *>common_instance
slots[2].slot = dtype_api.NPY_DT_setitem
slots[2].pfunc = <void *>setitem
slots[3].slot = dtype_api.NPY_DT_getitem
slots[3].pfunc = <void *>getitem
slots[4].slot = dtype_api.NPY_DT_discover_descr_from_pyobject
slots[4].pfunc = <void *>discover_descr_from_pyobject
# Sentinel:
slots[5].slot = 0
slots[5].pfunc = <void *>0


# Define all casts::
cdef dtype_api.PyArrayMethod_Spec *castingimpls[2]
spec.casts = &castingimpls[0]

# First cast (from one unit to another "within the same DType")
cdef dtype_api.PyArrayMethod_Spec unit_to_unit_cast_spec
castingimpls[0] = &unit_to_unit_cast_spec

unit_to_unit_cast_spec.name = "unit_to_unit_cast"
unit_to_unit_cast_spec.nin = 1
unit_to_unit_cast_spec.nout = 1
# We have to get the GIL briefly currently. Note that floating point checks
# currently do not happen for casts, this is a NumPy bug:
unit_to_unit_cast_spec.flags = dtype_api.NPY_METH_SUPPORTS_UNALIGNED

cdef PyObject *dtypes[2]
unit_to_unit_cast_spec.dtypes = dtypes
# We don't know the new DType yet, so use NULL:
dtypes[0] = <PyObject *>0
dtypes[1] = <PyObject *>0

cdef dtype_api.PyType_Slot meth_slots[4]
unit_to_unit_cast_spec.slots = meth_slots
meth_slots[0].slot = dtype_api.NPY_METH_resolve_descriptors
meth_slots[0].pfunc = <void *>unit_to_unit_cast_resolve_descriptors
meth_slots[1].slot = dtype_api.NPY_METH_strided_loop
meth_slots[1].pfunc = <void *>string_equal_strided_loop
meth_slots[2].slot = dtype_api.NPY_METH_unaligned_strided_loop
meth_slots[2].pfunc = <void *>string_equal_strided_loop_unaligned
# End of casts sentinel:
castingimpls[1] = <dtype_api.PyArrayMethod_Spec *>0


spec.baseclass = <PyTypeObject *>_FixedPointDTypeBase


# Use the C API to create the actual static type, so that we can give
# it the size of PyArray_DTypeMeta.  This is very ugly, and it would likely
# be better to just not do it in cython.  But I started in Cython, and it seems
# easier to do it "manually" here, rather than moving everything to C, or
# making a dance to define functions in Cython and then export to C.
cdef dtype_api.PyArray_DTypeMeta fixedpoint_struct

# TODO: Should use proper initialization marcos!
# TODO: is there a better way to write this even if we embrace the approach?
cdef PyObject *float64_as_obj = <PyObject *>&fixedpoint_struct
cdef type _dtypemeta = <type>type(np.dtype)
float64_as_obj[0].ob_type = <PyTypeObject *>_dtypemeta
float64_as_obj[0].ob_refcnt = 1

cdef PyTypeObject *float64_as_type = <PyTypeObject *>&fixedpoint_struct
float64_as_type[0].tp_name = "fixedpoint.fixedpoint.FixedPointDType"
float64_as_type[0].tp_base = <PyTypeObject *>_FixedPointDTypeBase
float64_as_type[0].tp_flags = Py_TPFLAGS_DEFAULT | Py_TPFLAGS_BASETYPE

PyType_Ready(<object>&fixedpoint_struct)

dtype_api.PyArrayInitDTypeMeta_FromSpec(
        <dtype_api.PyArray_DTypeMeta *>&fixedpoint_struct, &spec)

FixedPointDType = <object>&fixedpoint_struct

#-------------------------------------------------------
# Multiply

cdef npc.NPY_CASTING multiply_resolve_descriptors(method,
        PyObject *dtypes[3],
        PyObject *descrs[3], PyObject *descrs_out[3]) except <npc.NPY_CASTING>-1:
    """
    The resolver function, could possibly provide a default for this type
    of unary/casting resolver.
    """
    cdef npc.NPY_CASTING casting
    if descrs[1] == <PyObject *>0:
        # Shouldn't really happen a cast function?
        Py_INCREF(<object>descrs[0])
        descrs_out[0] = <PyObject *>descrs[0]
        Py_INCREF(<object>descrs[0])
        descrs_out[1] = <PyObject *>descrs[0]

    out_q = (<_FixedPointDTypeBase>descrs[0]).Q + (<_FixedPointDTypeBase>descrs[1]).Q

    if (descrs[2] != <PyObject *>0
            and (<_FixedPointDTypeBase>descrs[2]).Q == out_q):  # TODO: also for n
        # retain exact instance when passed in, currently necessary for things
        # to work smoothly, but should only be a mild performance improvement.
        out_dtype = <object>descrs[2]
    else:
        out_dtype = FixedPointDType(out_q)

    Py_INCREF(<object>descrs[0])
    descrs_out[0] = <PyObject *>descrs[0]
    Py_INCREF(<object>descrs[1])
    descrs_out[1] = <PyObject *>descrs[1]
    Py_INCREF(out_dtype)
    descrs_out[2] = <PyObject *>out_dtype
    return npc.NPY_SAFE_CASTING


cdef int multiply_strided_loop(
        dtype_api.PyArrayMethod_Context *context,
        char **data, npc.intp_t *dimensions, npc.intp_t *strides,
        void *userdata) nogil:
    cdef npc.intp_t N = dimensions[0]
    cdef char *vals_in0 = <char *>data[0]
    cdef char *vals_in1 = <char *>data[1]
    cdef char *vals_out = <char *>data[2]
    cdef npc.intp_t strides_in0 = strides[0]
    cdef npc.intp_t strides_in1 = strides[1]
    cdef npc.intp_t strides_out = strides[2]

    for i in range(N):
        (<long *>vals_out)[0] = (<long *>vals_in0)[0] * (<long *>vals_in1)[0]
        vals_in0 += strides_in0
        vals_in1 += strides_in1
        vals_out += strides_out


# We now declare the `spec` and fill it (it can be discarted later).
cdef dtype_api.PyArrayMethod_Spec multiply_spec

# Basic information:
multiply_spec.name = "fixedpoint_multiply"
multiply_spec.nin = 2
multiply_spec.nout = 1

# Define the dtypes we operate on:
cdef PyObject *multiply_dtypes[3]
multiply_spec.dtypes = multiply_dtypes
multiply_dtypes[0] = <PyObject *>FixedPointDType
multiply_dtypes[1] = <PyObject *>FixedPointDType
multiply_dtypes[2] = <PyObject *>FixedPointDType


# Define the function:
cdef dtype_api.PyType_Slot multiply_slots[3]
multiply_spec.slots = multiply_slots

# Pass the function using the 0 terminated slots.
multiply_slots[0].slot = dtype_api.NPY_METH_resolve_descriptors
multiply_slots[0].pfunc = <void *>multiply_resolve_descriptors
multiply_slots[1].slot = dtype_api.NPY_METH_strided_loop
multiply_slots[1].pfunc = <void *>multiply_strided_loop
multiply_slots[2].slot = 0
multiply_slots[2].pfunc = <void *>0

# Not used right now, but we can indicate not to check float errors,
# we do not require the GIL to be held, which is the default (currently):
multiply_spec.flags = 0

dtype_api.PyUFunc_AddLoopFromSpec(np.multiply, &multiply_spec)

#-------------------------------------------------------------------
# Addition

cdef int add_strided_loop(
        dtype_api.PyArrayMethod_Context *context,
        char **data, npc.intp_t *dimensions, npc.intp_t *strides,
        void *userdata) nogil:
    cdef npc.intp_t N = dimensions[0]
    cdef char *vals_in0 = <char *>data[0]
    cdef char *vals_in1 = <char *>data[1]
    cdef char *vals_out = <char *>data[2]
    cdef npc.intp_t strides_in0 = strides[0]
    cdef npc.intp_t strides_in1 = strides[1]
    cdef npc.intp_t strides_out = strides[2]

    for i in range(N):
        (<long *>vals_out)[0] = (<long *>vals_in0)[0] + (<long *>vals_in1)[0]
        vals_in0 += strides_in0
        vals_in1 += strides_in1
        vals_out += strides_out

cdef npc.NPY_CASTING add_resolve_descriptors(method,
        PyObject *dtypes[3],
        PyObject *descrs[3], PyObject *descrs_out[3]) except <npc.NPY_CASTING>-1:
    """
    The resolver function, could possibly provide a default for this type
    of unary/casting resolver.
    """
    cdef npc.NPY_CASTING casting

    out_q = (<_FixedPointDTypeBase>descrs[0]).Q + (<_FixedPointDTypeBase>descrs[1]).Q

    if (descrs[2] != <PyObject *>0
            and (<_FixedPointDTypeBase>descrs[2]).Q == out_q):  # TODO: also for n
        # retain exact instance when passed in, currently necessary for things
        # to work smoothly, but should only be a mild performance improvement.
        out_dtype = <object>descrs[2]
    else:
        out_dtype = FixedPointDType(out_q)

    Py_INCREF(<object>descrs[0])
    descrs_out[0] = <PyObject *>descrs[0]
    Py_INCREF(<object>descrs[1])
    descrs_out[1] = <PyObject *>descrs[1]
    Py_INCREF(out_dtype)
    descrs_out[2] = <PyObject *>out_dtype
    return npc.NPY_SAFE_CASTING


cdef dtype_api.PyArrayMethod_Spec add_spec
add_spec.name = "fixedpoint_add"
add_spec.nin = 2
add_spec.nout = 1

cdef PyObject *add_dtypes[3]
add_spec.dtypes = add_dtypes
add_dtypes[0] = <PyObject *>FixedPointDType
add_dtypes[1] = <PyObject *>FixedPointDType
add_dtypes[2] = <PyObject *>FixedPointDType

cdef dtype_api.PyType_Slot add_slots[3]
add_spec.slots = add_slots
add_slots[0].slot = dtype_api.NPY_METH_resolve_descriptors
add_slots[0].pfunc = <void *>add_resolve_descriptors
add_slots[1].slot = dtype_api.NPY_METH_strided_loop
add_slots[1].pfunc = <void *>add_strided_loop
add_slots[2].slot = 0
add_slots[2].pfunc = <void *>0

add_spec.flags = 0

dtype_api.PyUFunc_AddLoopFromSpec(np.add, &add_spec)

#-------------------------------------------------------------------
# Subtraction

cdef int sub_strided_loop(
        dtype_api.PyArrayMethod_Context *context,
        char **data, npc.intp_t *dimensions, npc.intp_t *strides,
        void *userdata) nogil:
    cdef npc.intp_t N = dimensions[0]
    cdef char *vals_in0 = <char *>data[0]
    cdef char *vals_in1 = <char *>data[1]
    cdef char *vals_out = <char *>data[2]
    cdef npc.intp_t strides_in0 = strides[0]
    cdef npc.intp_t strides_in1 = strides[1]
    cdef npc.intp_t strides_out = strides[2]

    for i in range(N):
        (<long *>vals_out)[0] = (<long *>vals_in0)[0] - (<long *>vals_in1)[0]
        vals_in0 += strides_in0
        vals_in1 += strides_in1
        vals_out += strides_out


cdef npc.NPY_CASTING sub_resolve_descriptors(method,
        PyObject *dtypes[3],
        PyObject *descrs[3], PyObject *descrs_out[3]) except <npc.NPY_CASTING>-1:
    """
    The resolver function, could possibly provide a default for this type
    of unary/casting resolver.
    """
    cdef npc.NPY_CASTING casting

    out_q = (<_FixedPointDTypeBase>descrs[0]).Q + (<_FixedPointDTypeBase>descrs[1]).Q

    if (descrs[2] != <PyObject *>0
            and (<_FixedPointDTypeBase>descrs[2]).Q == out_q):  # TODO: also for n
        # retain exact instance when passed in, currently necessary for things
        # to work smoothly, but should only be a mild performance improvement.
        out_dtype = <object>descrs[2]
    else:
        out_dtype = FixedPointDType(out_q)

    Py_INCREF(<object>descrs[0])
    descrs_out[0] = <PyObject *>descrs[0]
    Py_INCREF(<object>descrs[1])
    descrs_out[1] = <PyObject *>descrs[1]
    Py_INCREF(out_dtype)
    descrs_out[2] = <PyObject *>out_dtype
    return npc.NPY_SAFE_CASTING


cdef dtype_api.PyArrayMethod_Spec sub_spec
sub_spec.name = "fixedpoint_sub"
sub_spec.nin = 2
sub_spec.nout = 1

cdef PyObject *sub_dtypess[3]
sub_spec.dtypes = sub_dtypess
sub_dtypess[0] = <PyObject *>FixedPointDType
sub_dtypess[1] = <PyObject *>FixedPointDType
sub_dtypess[2] = <PyObject *>FixedPointDType

cdef dtype_api.PyType_Slot sub_slots[3]
sub_spec.slots = sub_slots
sub_slots[0].slot = dtype_api.NPY_METH_resolve_descriptors
sub_slots[0].pfunc = <void *>sub_resolve_descriptors
sub_slots[1].slot = dtype_api.NPY_METH_strided_loop
sub_slots[1].pfunc = <void *>sub_strided_loop
sub_slots[2].slot = 0
sub_slots[2].pfunc = <void *>0

sub_spec.flags = 0

dtype_api.PyUFunc_AddLoopFromSpec(np.subtract, &sub_spec)
