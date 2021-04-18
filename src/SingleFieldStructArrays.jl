module SingleFieldStructArrays

export SingleFieldStructArray

struct SingleFieldStructArray{TData, TStruct, FN, TField, N} <: AbstractArray{TField, N}
    data::TData
end

"""
    SingleFieldStructArray(data, fieldname::Symbol)

Create a SingleFieldStructArray from an array of structs (`data`) that acts like an array of the values of `fieldname`. 

# Examples
```jldoctest
julia> struct Foo3{T} a::T; b::T; c::T; end
julia> foo3s = Foo3.(1:5, 6:10, 11:15)
5-element Array{Foo3{Int64},1}:
 Foo3{Int64}(1, 6, 11)
 Foo3{Int64}(2, 7, 12)
 Foo3{Int64}(3, 8, 13)
 Foo3{Int64}(4, 9, 14)
 Foo3{Int64}(5, 10, 15)

julia> as = SingleFieldStructArray(foo3s, :a)
5-element SingleFieldStructArray{Array{Foo3{Int64},1},Foo3{Int64},:a,Int64,1}:
 1
 2
 3
 4
 5

julia> as[3] == 3
true

julia> as[3] = -1
-1

julia> foo3s
5-element Array{Foo3{Int64},1}:
 Foo3{Int64}(1, 6, 11)
 Foo3{Int64}(2, 7, 12)
 Foo3{Int64}(-1, 8, 13)
 Foo3{Int64}(4, 9, 14)
 Foo3{Int64}(5, 10, 15)

julia>
```
"""
function SingleFieldStructArray(data, fieldname::Symbol)
    TData = typeof(data)
    TStruct = eltype(data)
    TField = fieldtype(TStruct, fieldname)
    N = ndims(data)
    return SingleFieldStructArray{TData, TStruct, fieldname, TField, N}(data)
end


@inline Base.size(A::SingleFieldStructArray) = size(A.data)

@inline Base.IndexStyle(::Type{<:SingleFieldStructArray{TData, TStruct, FN, TField, N}}) where {TData,TStruct,FN,TField,N} = Base.IndexStyle(TData)

Base.@propagate_inbounds function Base.getindex(A::SingleFieldStructArray{TData, TStruct, FN, TField, N}, i::Int) where {TData,TStruct,FN,TField,N} 
    @boundscheck checkbounds(A.data, i)
    # Do I need the @inbounds here? Doesn't Base.@propagate_inbounds tell Julia
    # that I want to skip all bounds checking in this block? Should be
    # equivalent to adding @inbounds to every line.
    return @inbounds getproperty(A.data[i], FN)::TField
end

Base.@propagate_inbounds function Base.getindex(A::SingleFieldStructArray{TData, TStruct, FN, TField, N}, I::Vararg{Int, N}) where {TData,TStruct,FN,TField,N} 
    @boundscheck checkbounds(A.data, I...)
    # Do I need the @inbounds here? Doesn't Base.@propagate_inbounds tell Julia
    # that I want to skip all bounds checking in this block? Should be
    # equivalent to adding @inbounds to every line.
    return @inbounds getproperty(A.data[I...], FN)::TField
end

Base.@propagate_inbounds @generated function Base.setindex!(A::SingleFieldStructArray{TData, TStruct, FN, TField, N}, v, i::Int) where {TData,TStruct,FN,TField,N}
    args = []
    for field in fieldnames(TStruct)
        if field === FN
           ex = :(v)
        else
           ex = :(getproperty(A.data[i], $(QuoteNode(field))))
        end
       push!(args, ex)
    end
    quote
        @boundscheck checkbounds(A.data, i)
        # Do I need the @inbounds here? Doesn't Base.@propagate_inbounds tell Julia
        # that I want to skip all bounds checking in this block? Should be
        # equivalent to adding @inbounds to every line.
        @inbounds A.data[i] = TStruct($(args...))
    end
end

Base.@propagate_inbounds @generated function Base.setindex!(A::SingleFieldStructArray{TData, TStruct, FN, TField, N}, v, I::Vararg{Int, N}) where {TData,TStruct,FN,TField,N}
    args = []
    for field in fieldnames(TStruct)
        if field === FN
           ex = :(v)
        else
           ex = :(getproperty(A.data[I...], $(QuoteNode(field))))
        end
       push!(args, ex)
    end
    quote 
        @boundscheck checkbounds(A.data, I...)
        # Do I need the @inbounds here? Doesn't Base.@propagate_inbounds tell Julia
        # that I want to skip all bounds checking in this block? Should be
        # equivalent to adding @inbounds to every line.
        @inbounds A.data[I...] = TStruct($(args...))
    end
end

@inline Base.length(A::SingleFieldStructArray) = length(A.data)
@inline Base.similar(A::SingleFieldStructArray, ::Type{S}, dims::Dims) where{S} = similar(A.data, S, dims)
@inline Base.axes(A::SingleFieldStructArray) = axes(A.data)

end # module
