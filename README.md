[![Build Status](https://travis-ci.com/dingraha/SingleFieldStructArrays.svg?token=vVssarhszBZxvnbDtMCo&branch=main)](https://travis-ci.com/dingraha/SingleFieldStructArrays)

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
n_out = 101
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
