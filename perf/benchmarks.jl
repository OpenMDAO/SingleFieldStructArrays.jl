using BenchmarkTools
using FLOWMath
using SingleFieldStructArrays

const paramsfile = joinpath(@__DIR__, "params.json")
const resultsfile = joinpath(@__DIR__, "results.json")

struct Foo3{T1,T2,T3}
    t::T1
    x::T2
    y::T3
end

function run_benchmarks(; load_params=true, save_params=false)
    n_cp = 11
    t = range(0.0, 1.0, length=n_cp)
    x = @. sin(2*pi*(t-0.2)) + 0.3*sin(4*pi*(t-0.3))
    y = @. 1.5*sin(2*pi*(t-0.5)) + 0.5*sin(4*pi*(t-0.2))
    foos = Foo3.(t, x, y)

    cache = Foo3(similar(t), similar(x), similar(y))

    n_out = 51
    t_out = range(t[1], t[end], length=n_out)

    suite = BenchmarkGroup()

    s_akima = suite["akima"] = BenchmarkGroup()
    s_akima_gp = s_akima["getproperty"] = @benchmarkable akima_getproperty($foos, $t_out)
    s_akima_sfsa = s_akima["SingleFieldStructArray"] = @benchmarkable akima_sfsa($foos, $t_out)
    s_akima_cache = s_akima["cache"] = @benchmarkable akima_cache($foos, $t_out, $cache)

    if load_params && isfile(paramsfile)
        # Load the benchmark parameters.
        # https://github.com/JuliaCI/BenchmarkTools.jl/blob/master/doc/manual.md#caching-parameters
        loadparams!(suite, BenchmarkTools.load(paramsfile)[1])

        # Also need to warmup the benchmarks to get rid of the JIT overhead
        # (when not using tune!):
        # https://discourse.julialang.org/t/benchmarktools-theory-and-practice/5728
        warmup(suite, verbose=false)
    else
        tune!(suite, verbose=false)
    end

    results = run(suite, verbose=false)

    if save_params
        BenchmarkTools.save(paramsfile, params(suite))
    end

    return suite, results
end

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

function akima_cache(foos, t_out, cache)
    cache.t .= getproperty.(foos, :t)
    cache.x .= getproperty.(foos, :x)
    cache.y .= getproperty.(foos, :y)

    x_out = akima(cache.t, cache.x, t_out)
    y_out = akima(cache.t, cache.y, t_out)

    return x_out, y_out
end

function compare_benchmarks(; load_params=true, save_params=false)
    suite, results = run_benchmarks(load_params=load_params, save_params=save_params)

    println("getproperty vs SingleFieldStructArrays, Akima interpolation:")
    rold = results["akima"]["getproperty"]
    rnew = results["akima"]["SingleFieldStructArray"]
    display(judge(median(rnew), median(rold)))

    println("getproperty vs cache, Akima interpolation:")
    rold = results["akima"]["getproperty"]
    rnew = results["akima"]["cache"]
    display(judge(median(rnew), median(rold)))
end
