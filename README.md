[![Build Status](https://travis-ci.com/dingraha/SingleFieldStructArrays.svg?token=vVssarhszBZxvnbDtMCo&branch=main)](https://travis-ci.com/dingraha/SingleFieldStructArrays)
[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://dingraha.github.io/SingleFieldStructArrays/dev)

# SingleFieldStructArrays

## Quick Start
Make an `Array` of `struct`s act like an Array of one of the fields of the
`struct`.

```julia
struct Foo3{T1,T2,T3}
    t::T1
    x::T2
    y::T3
end

foos = Foo3.([0.0, 1.0], [2.0, 3.0], [4.0, 5.0])

using SingleFieldStructArrays
t_sfsa = SingleFieldStructArray(foos, :t)
x_sfsa = SingleFieldStructArray(foos, :x)

@show t_sfsa[1]
t_sfsa[1] = 0.0

@show x_sfsa[1]
x_sfsa[1] = 2.0
```

## Usage

SingleFieldStructArrays is a small Julia package that makes working with arrays
of `structs` easier. Say you have a `struct`

```julia
struct Foo3{T1,T2,T3}
    t::T1
    x::T2
    y::T3
end
```

and you end up with an array of them:

```julia
n_in = 51
t = range(0.0, 1.0, length=n_in)
x = @. sin(2*pi*(t-0.2)) + 0.3*sin(4*pi*(t-0.3))
y = @. 1.5*sin(2*pi*(t-0.5)) + 0.5*sin(4*pi*(t-0.2))
foos = Foo3.(t, x, y)  # Vector{Foo3{Float64, Float64, Float64}}
```

But now you'd like to work with an array of the components of `foos`. For
example, you might want to take all the `t` and `x` components of each entry in
the `foos` `Vector` and interpolate the `x` components onto a new grid of `t`
values, maybe using Akima splines from
[FLOWMath](https://github.com/byuflowlab/FLOWMath.jl). But most likely the
interpolation routine expects a plain old `Array`. So, you could create a new
array with `getproperty` and broadcasting:

```julia
t_in = getproperty.(foos, :t)
x_in = getproperty.(foos, :x)
```

and then pass that to the interpolation routine:

```julia
n_out = 1001
t_out = range(0.0, 1.0, length=n_out)
x_out = akima(t_in, x_in, t_out)
```

but that involves allocating a new `Array`, which could be expensive. What you really
want to do is pass the `foos` `Array` to routines like `akima`,
but, say, treat `foo[i]` as `foo[i].t` or `foo[i].x`.

And now you can, with SingleFieldStructArrays:

```julia
using SingleFieldStructArrays
t_sfsa = SingleFieldStructArray(foos, :t)
x_sfsa = SingleFieldStructArray(foos, :x)
x_out2 = akima(t_sfsa, x_sfsa, t_out)
```

The `SingleFieldStructArray` constructor takes two arguments: the
`AbstractArray` `data` of `struct`s to be wrapped, and a `Symbol` `fieldname`
indicating the single field of the `struct` the `SingleFieldStructArray` will
work with. The `SingleFieldStructArray` is `<:AbstractArray{T, N}`, where the
type `T` matches the type of `fieldtype(eltype(typeof(data)), fieldname)`.

## Performance
But is this any faster? Let's try it out:
```julia
using BenchmarkTools

function akima_getproperty(foos, t_out)
    t = getproperty.(foos, :t)
    x = getproperty.(foos, :x)
    y = getproperty.(foos, :y)

    x_out = akima(t, x, t_out)
    y_out = akima(t, y, t_out)

    return x_out, y_out
end

function akima_sfsa(foos, t_out)
    t = SingleFieldStructArray(foos, :t)
    x = SingleFieldStructArray(foos, :x)
    y = SingleFieldStructArray(foos, :y)

    x_out = akima(t, x, t_out)
    y_out = akima(t, y, t_out)

    return x_out, y_out
end

@benchmark akima_getproperty($foos, $t_out)
BenchmarkTools.Trial:
  memory estimate:  30.53 KiB
  allocs estimate:  323
  --------------
  minimum time:     63.470 μs (0.00% GC)
  median time:      67.492 μs (0.00% GC)
  mean time:        72.031 μs (2.08% GC)
  maximum time:     2.790 ms (93.61% GC)
  --------------
  samples:          10000
  evals/sample:     1

@benchmark akima_sfsa($foos, $t_out)
BenchmarkTools.Trial:
  memory estimate:  22.11 KiB
  allocs estimate:  20
  --------------
  minimum time:     58.077 μs (0.00% GC)
  median time:      61.565 μs (0.00% GC)
  mean time:        65.105 μs (0.90% GC)
  maximum time:     1.695 ms (89.63% GC)
  --------------
  samples:          10000
  evals/sample:     1
```

So, a bit faster. But what if we pass in working arrays to avoid allocating
inside the function?

```julia
function akima_cache_loop(foos, t_out, cache)
    for i in eachindex(foos)
        @inbounds cache.t[i] = foos[i].t
        @inbounds cache.x[i] = foos[i].x
        @inbounds cache.y[i] = foos[i].y
    end

    x_out = akima(cache.t, cache.x, t_out)
    y_out = akima(cache.t, cache.y, t_out)

    return x_out, y_out
end

cache = Foo3(similar(t), similar(x), similar(y))

@benchmark akima_cache_loop($foos, $t_out, $cache)
BenchmarkTools.Trial:
  memory estimate:  21.91 KiB
  allocs estimate:  14
  --------------
  minimum time:     59.594 μs (0.00% GC)
  median time:      63.170 μs (0.00% GC)
  mean time:        68.953 μs (0.87% GC)
  maximum time:     1.834 ms (85.47% GC)
  --------------
  samples:          10000
  evals/sample:     1
```

The `SingleFieldStructArray` approach is still a bit faster! And not requiring
the caller to pass in an extra `cache` array is handy.

You can try these benchmarks yourself in `perf/benchmarks.jl`.


