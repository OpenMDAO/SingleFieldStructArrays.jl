module SingleFieldStructArrays

export SingleFieldStructArray

struct SingleFieldStructArray{TData, TStruct, FN, TField, N} <: AbstractArray{TField, N}
    data::TData
end

"""
    SingleFieldStructArray(data, fieldname::Symbol)

Create a SingleFieldStructArray from an array of structs (`data`) that acts like an array of the values of `fieldname`. 
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
    return @inbounds getproperty(A.data[i], FN)::TField
end

Base.@propagate_inbounds function Base.getindex(A::SingleFieldStructArray{TData, TStruct, FN, TField, N}, I::Vararg{Int, N}) where {TData,TStruct,FN,TField,N} 
    @boundscheck checkbounds(A.data, I...)
    return @inbounds getproperty(A.data[I...], FN)::TField
end

@inline @generated function Base.setindex!(A::SingleFieldStructArray{TData, TStruct, FN, TField, N}, v, i::Int) where {TData,TStruct,FN,TField,N}
    args = []
    for field in fieldnames(TStruct)
        if field === FN
           ex = :(v)
        else
           ex = :(getproperty(A.data[i], $(QuoteNode(field))))
        end
       push!(args, ex)
    end
    :(A.data[i] = TStruct($(args...)))
end

@inline @generated function Base.setindex!(A::SingleFieldStructArray{TData, TStruct, FN, TField, N}, v, I::Vararg{Int, N}) where {TData,TStruct,FN,TField,N}
    args = []
    for field in fieldnames(TStruct)
        if field === FN
           ex = :(v)
        else
           ex = :(getproperty(A.data[I...], $(QuoteNode(field))))
        end
       push!(args, ex)
    end
    :(A.data[I...] = TStruct($(args...)))
end

@inline Base.length(A::SingleFieldStructArray) = length(A.data)
@inline Base.similar(A::SingleFieldStructArray, ::Type{S}, dims::Dims) where{S} = similar(A.data, S, dims)
@inline Base.axes(A::SingleFieldStructArray) = axes(A.data)

end # module
