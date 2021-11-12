using LinearAlgebra
using SingleFieldStructArrays
using Test

import Base.zero

struct Foo{T1, T2}
    a::T1
    b::T2
end

function Base.zero(::Type{Foo{T1, T2}}) where {T1, T2}
    return Foo(zero(T1), zero(T2))
end

@testset "SingleFieldStructArrays" begin

    @testset "Array container" begin

        @testset "all scalars" begin

            foos = [Foo(i, float(i+1)) for i in 1:10]
            foos_a = SingleFieldStructArray(foos, Val{:a})

            @testset "length and size" begin
                @test size(foos_a) == size(foos)
                @test length(foos_a) == length(foos)
            end

            @testset "getindex and setindex!" begin
                @test foos_a ≈ getproperty.(foos, :a)

                foos_b = SingleFieldStructArray(foos, Val{:b})
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
                foos = Foo.(as, bs)
                foos_b = SingleFieldStructArray(foos, Val{:b})
                @test foos_b ≈ getproperty.(foos, :b)
                @test foos_b[:, 1] ≈ bs[:, 1]
                @test foos_b[2, :] ≈ bs[2, :]
                @test foos_b[2:end, 3:4] ≈ bs[2:end, 3:4]
                foos_b[2:end, 3:4] .= -1
                @test all(foos_b[2:end, 3:4] .== -1)
            end

        end

        @testset "scalar with array" begin

            foos = [Foo(i, zeros(8)) for i in 1:10]
            foos_a = SingleFieldStructArray(foos, Val{:a})

            @testset "length and size" begin
                @test size(foos_a) == size(foos)
                @test length(foos_a) == length(foos)
            end

            @testset "getindex and setindex!" begin
                @test foos_a ≈ getproperty.(foos, :a)

                foos_a[2] = -1
                @test foos[2].a ≈ -1

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
                foos = Foo.(as, Ref(zeros(8)))
                foos_a = SingleFieldStructArray(foos, Val{:a})
                @test foos_a ≈ getproperty.(foos, :a)
                @test foos_a[:, 1] ≈ as[:, 1]
                @test foos_a[2, :] ≈ as[2, :]
                @test foos_a[2:end, 3:4] ≈ as[2:end, 3:4]
                foos_a[2:end, 3:4] .= -1
                @test all(foos_a[2:end, 3:4] .== -1)
            end

        end

    end

    @testset "Diagonal container" begin
            as = reshape(1:3*4, 3, 4)
            bs = as .+ 1
            foos = Foo.(as, bs)
            foos_diag = Diagonal(foos)
            foos_diag_a = SingleFieldStructArray(foos_diag, Val{:a})
            as_diag = Diagonal(as)

            @test all(foos_diag_a .≈ as_diag)

            @testset "length and size" begin
                @test size(foos_diag_a) == size(as_diag)
                @test length(foos_diag_a) == length(as_diag)
            end

            @testset "getindex and setindex!" begin
                @test foos_diag_a ≈ getproperty.(foos_diag, :a)
                foos_diag_a[1, 1] = -1
                @test foos_diag[1, 1].a == -1
            end
    end
end
