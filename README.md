# FunctionAccuracyTests.jl
ULP testing for Floating Point special functions.

This package provides 2 useful things for testing the accuracy of functions. A `FloatIterator` type, and a function `test_acc`.

* `FloatIterator{T}(min, max)` 

Construct an indexable iterator over all floating point values between min and max. This is useful for testing `Float16` and `Float32` implimentations of functions. For relatively cheap functions, testing all `Float16` values takes about .1 second, and testing all `Float32` values takes around 90 seconds. Do not use this for testing `Float64` inputs.


`test_acc` - Function
* `test_acc(Dict(test_fun=>reference_fun), xs; tol=1.5)`

This tests whether `test_fun` and `reference_fun` produce the same result on an iterator of `x` values. `tol` is the tolerance specified in ULPs (Units in Last Place). The `reference_fun` should be the accurate "reference" function you're comparing your new "test" function with.
* `test_acc(f::Function, xx; tol = 1.5)`

This is the same, except it tests the `BigFloat` method of a function against the method for `eltype(xx)`.
* `test_acc(f::Function, min, max; tol = 1.5)`

This tests whether all floating point values between `min` and `max` match.
* `test_acc(f::Function, T::Type; tol = 1.5)`

This tests whether all values of a Floating Point type match.
