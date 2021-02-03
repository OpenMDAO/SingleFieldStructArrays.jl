using SingleFieldStructArrays
using Test

struct Foo{T1, T2}
    a::T1
    b::T2
end

@testset "SingleFieldStructArrays" begin
    foos = [Foo(i, float(i+1)) for i in 1:10]
    foos_a = SingleFieldStructArray(foos, :a)

    @testset "length and size" begin
        @test size(foos_a) == size(foos)
        @test length(foos_a) == length(foos)
    end

    @testset "getindex and setindex!" begin
        @test foos_a ≈ getproperty.(foos, :a)

        foos_b = SingleFieldStructArray(foos, :b)
        @test foos_b ≈ getproperty.(foos, :b)

        foos_a[2] = -1
        @test foos[2].a ≈ -1

        foos_b[2] = -3.0
        @test foos[2].b ≈ -3.0
    end

    @testset "similar" begin
        foos_a_sim = similar(foos_a)
        foos_a_copy = getproperty.(foos, :a)
        @test typeof(foos_a_sim) == typeof(foos_a_copy)
        @test size(foos_a_sim) == size(foos_a_copy)
    end

    @testset "axes" begin
        @test axes(foos_a) == axes(foos)
    end

    @testset "multidimensional array" begin
        as = reshape(1:3*4, 3, 4)
        bs = as .+ 1
        foos = Foo.(as, as.+1)
        foos_b = SingleFieldStructArray(foos, :b)
        @test foos_b ≈ getproperty.(foos, :b)
        @test foos_b[:, 1] ≈ bs[:, 1]
        @test foos_b[2, :] ≈ bs[2, :]
        @test foos_b[2:end, 3:4] ≈ bs[2:end, 3:4]
        foos_b[2:end, 3:4] .= -1
        @test all(foos_b[2:end, 3:4] .== -1)
    end

end
