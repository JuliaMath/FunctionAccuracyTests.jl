using Printf, Test
using FunctionAccuracyTests

MAX_EXP(n::Val{2}, ::Type{Float32}) = 128.0f0
MAX_EXP(n::Val{2}, ::Type{Float64}) = 1024.0
MAX_EXP(n::Val{:ℯ}, ::Type{Float32}) = 88.72284f0
MAX_EXP(n::Val{:ℯ}, ::Type{Float64}) = 709.7827128933841
MAX_EXP(n::Val{10}, ::Type{Float32}) = 38.53184f0
MAX_EXP(n::Val{10}, ::Type{Float64}) = 308.25471555991675

# min_exp = T(-(exponent_bias(T)+significand_bits(T)) * log(base, big(2)))
MIN_EXP(n::Val{2}, ::Type{Float32}) = -150.0f0
MIN_EXP(n::Val{2}, ::Type{Float64}) = -1075.0
MIN_EXP(n::Val{:ℯ}, ::Type{Float32}) = -103.97208f0
MIN_EXP(n::Val{:ℯ}, ::Type{Float64}) = -745.1332191019412
MIN_EXP(n::Val{10}, ::Type{Float32}) = -45.1545f0
MIN_EXP(n::Val{10}, ::Type{Float64}) = -323.60724533877976

for (func, base) in (exp2=>Val(2), exp=>Val(:ℯ), exp10=>Val(10))
    for T in (Float32, Float64)
        xx = range(MIN_EXP(base,T),  MAX_EXP(base,T), length = 10^6);
        test_acc(func, xx)
    end
end


exp10(Float16(-3.764))
exp10(Float16(-1.76))
asinh(Float16(258.5))
asinh(Float16(-258.5))
@testset "Float16" begin
    @testset "$func" for func in (atan,sinh,cosh,tanh,asinh,
                                  exp,exp2,exp10,expm1,cbrt)
        test_acc(func, -Inf16, Inf16, tol=.501)
    end
    @testset "$func" for func in (sin, cos, tan)
        test_acc(func, -floatmax(Float16),floatmax(Float16), tol=.501)
    end
    @testset "$func" for func in (asin, acos, atanh)
        test_acc(func, -one(Float16),one(Float16), tol=.501)
    end
    test_acc(acosh, one(Float16), Inf16, tol=.501)
    @testset "$func" for func in (log, log2, log10, sqrt)
        test_acc(func, zero(Float16), Inf16, tol=.501)
    end
    test_acc(log1p, -one(Float16), Inf16, tol=.501)
end
