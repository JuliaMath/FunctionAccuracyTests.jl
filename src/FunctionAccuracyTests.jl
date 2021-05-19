module FunctionAccuracyTests

using Base.Math: significand_bits, exponent_bias
using Test, Printf

export FloatIterator, test_acc

struct FloatIterator{T}<:AbstractVector{T}
    min::T
    max::T
    FloatIterator{T}(min, max) where T = min > max ? error("max less than min") : new{T}(min,max)
end

FloatIterator(min::T,max::T) where T = FloatIterator{T}(min,max)
FloatIterator{T}() where T = FloatIterator{T}(T(-Inf),T(Inf))
Base.iterate(it::FloatIterator) = (it.min, nextfloat(it.min))
function Base.iterate(it::FloatIterator{T}, el) where T
    return el == it.max ? nothing : (el, nextfloat(el))
end

function Base.size(it::FloatIterator{T}) where T
    if isless(it.max, 0.0)
        size = reinterpret(Base.uinttype(T), it.max) - reinterpret(Base.uinttype(T), it.min)
    elseif isless(-0.0, it.min)
        size = reinterpret(Base.uinttype(T), it.max) - reinterpret(Base.uinttype(T), it.min)
    else
        size  = reinterpret(Base.uinttype(T), it.max)
        size += reinterpret(Base.uinttype(T), it.min) - reinterpret(Base.uinttype(T), T(-0.0))
    end
    return (size+1,)
end

Base.getindex(it::FloatIterator{T}, i::Int) where T = nextfloat(it.min, i-1)
Base.show(io::IO, mime::MIME"text/plain", it::FloatIterator) =  show(io, it)
Base.show(io::IO, it::FloatIterator) = print(io, "FloatIterator(", it.min, ", ", it.max, ")")

# the following compares the ulp between x and y.
# First it promotes them to the larger of the two types x,y
const infh(T) = prevfloat(T(Inf),4)
function countulp(T, x::AbstractFloat, y::AbstractFloat)
    X, Y = promote(x, y)
    x, y = T(X), T(Y) # Cast to smaller type
    (isnan(x) && isnan(y)) && return 0
    (isnan(x) || isnan(y)) && return 10000
    if isinf(x)
        (sign(x) == sign(y) && abs(y) > infh(T)) && return 0 # relaxed infinity handling
        return 10001
    end
    (x ==  Inf && y ==  Inf) && return 0
    (x == -Inf && y == -Inf) && return 0
    if y == 0
        x == 0 && return 0
        return 10002
    end
    if isfinite(x) && isfinite(y)
        return T(abs(X - Y) / ulp(y))
    end
    return 10003
end

const DENORMAL_MIN(::Type{Float64}) = 2.0^-1074 
const DENORMAL_MIN(::Type{Float32}) = 2f0^-149
const DENORMAL_MIN(::Type{Float16}) = Float16(6.0e-8)

function ulp(x::T) where {T<:AbstractFloat}
    x = abs(x)
    x == T(0.0) && return DENORMAL_MIN(T)
    val, e = frexp(x)
    return max(ldexp(T(1.0), e - significand_bits(T) - 1), DENORMAL_MIN(T))
end

countulp(x::T, y::T) where {T <: AbstractFloat} = countulp(T, x, y)
strip_module_name(f::Function) = last(split(string(f), '.')) # strip module name from function f

function test_acc(fun_table::Dict, xx; tol=1.5, debug = true, tol_debug = 5)
    T = eltype(xx)
    @testset "accuracy $(strip_module_name(xfun))" for (xfun, fun) in fun_table
        rmax = 0.0
        rmean = 0.0
        xmax = map(zero, first(xx))
        tol_debug_failed = 0
        for x in xx
            q = xfun(x...)
            c = fun(map(big, x)...)
            u = countulp(T, q, c)
            rmax = max(rmax, u)
            xmax = rmax == u ? x : xmax
            rmean += u
            if debug && u > tol_debug
                tol_debug_failed += 1
                #@printf("%s = %.20g\n%s  = %.20g\nx = %.20g\nulp = %g\n", strip_module_name(xfun), q, strip_module_name(fun), T(c), x, u)
            end
        end
        if debug
            println("Tol debug failed $(100tol_debug_failed / length(xx))% of the time.")
        end
        rmean = rmean / length(xx)
        println(strip_module_name(xfun))
        println("max $rmax at x = $xmax")
        println("mean $rmean")
        t = @test rmax <= tol
    end
end

test_acc(f::Function, xx; tol = 1.5, debug = true, tol_debug = 5) = test_acc(Dict(f=>f), xx; tol = 1.5, debug = true, tol_debug = 5)
test_acc(f::Function, min, max; tol = 1.5, debug = true, tol_debug = 5) = test_acc(Dict(f=>f), FloatIterator(min,max); tol = 1.5, debug = true, tol_debug = 5)

end # module
