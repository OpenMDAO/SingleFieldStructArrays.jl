module SingleFieldStructArrays

export SingleFieldStructArray

struct SingleFieldStructArray{TData, TStruct, NField, TField, N} <: AbstractArray{TField, N}
    data::TData
end

function SingleFieldStructArray(data, fieldname)
    TData = typeof(data)
    TStruct = eltype(data)
    TField = fieldtype(TStruct, fieldname)
    N = ndims(data)
    return SingleFieldStructArray{TData, TStruct, fieldname, TField, N}(data)
end

Base.size(A::SingleFieldStructArray) = size(A.data)

Base.IndexStyle(::Type{<:SingleFieldStructArray{TData, TStruct, NField, TField, N}}) where {TData,TStruct,NField,TField,N} = Base.IndexStyle(TData)

Base.getindex(A::SingleFieldStructArray{TData, TStruct, NField, TField, N}, i::Int) where {TData,TStruct,NField,TField,N} = getproperty(A.data[i], NField)::TField
Base.getindex(A::SingleFieldStructArray{TData, TStruct, NField, TField, N}, I::Vararg{Int, N}) where {TData,TStruct,NField,TField,N} = getproperty(A.data[I...], NField)::TField

# function Base.setindex!(A::SingleFieldStructArray, v, i::Int)
#     # Get the struct element we want to modify.
#     data_i = A.data[i]
#     TStruct = typeof(data_i)

#     # Get the arguments needed to create the new struct.
#     args::Tuple{TStruct.types...} = tuple((ifelse(name!=A.fieldname, getproperty(data_i, name), v) for name in fieldnames(typeof(data_i)))...)

#     # Create and assign the new struct.
#     A.data[i] = TStruct(args...)

#     return v
# end

@generated function Base.setindex!(A::SingleFieldStructArray{TData, TStruct, NField, TField, N}, v, i::Int) where {TData,TStruct,NField,TField,N}
    args = []
    for field in fieldnames(TStruct)
        if field === NField
           ex = :(v)
        else
           ex = :(getproperty(A.data[i], $(QuoteNode(field))))
        end
       push!(args, ex)
    end
    :(A.data[i] = TStruct($(args...)))
end

# function mysetindex!(A::Type{SingleFieldStructArray{TData, TStruct, NField, TField, N}}, v, i::Type{Int}) where {TData,TStruct,NField,TField,N}
#     args = []
#     for field in fieldnames(TStruct)
#         if field === NField
#             push!(args, v)
#         else
#             push!(args, :(getproperty(getindex(A.data, i), field)))
#         end
#     end
#     :(setindex!($(A.data), TStruct($args...), $i))
# end


# function Base.setindex!(A::SingleFieldStructArray{TData,TField,N}, v, I::Vararg{Int, N}) where {TData,TField,N}
#     # Get the struct element we want to modify.
#     data_i = A.data[I...]
#     TStruct = eltype(A.data)

#     # Get a tuple of the arguments needed to create the new struct.
#     args::Tuple{TStruct.types...} = tuple((ifelse(name!=A.fieldname, getproperty(data_i, name), v) for name in fieldnames(typeof(data_i)))...)

#     # Create and assign the new struct.
#     A.data[I...] = TStruct(args...)

#     return v
# end

Base.length(A::SingleFieldStructArray) = length(A.data)

# Base.similar(A::SingleFieldStructArray, ::Type{S}) where{S} = similar(A.data, S)
# Base.similar(A::SingleFieldStructArray, dims::Dims) = similar(A.data, dims)
Base.similar(A::SingleFieldStructArray, ::Type{S}, dims::Dims) where{S} = similar(A.data, S, dims)

Base.axes(A::SingleFieldStructArray) = axes(A.data)

end # module
