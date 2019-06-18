module ImmutableArrays

export ImmutableArray, freeze, thaw

struct ImmutableArray{T,N} <: DenseArray{T,N}
    data::Array{T,N}
end
freeze(A::Array) = ImmutableArray(copy(A))
thaw(A::ImmutableArray) = copy(A.data)

Base.size(A::ImmutableArray) = size(A.data)
Base.@propagate_inbounds Base.getindex(A::ImmutableArray, I::Integer...) = getindex(A.data, I...)
Base.@propagate_inbounds Base.getindex(A::ImmutableArray, I...) = freeze(getindex(A.data, I...))
Base.strides(A::ImmutableArray) = strides(A.data)
Base.pointer(A::ImmutableArray) = pointer(A.data)
Base.pointer(A::ImmutableArray, i::Integer) = pointer(A.data, i)
Base.unsafe_convert(::Type{Ptr{T}}, A::ImmutableArray) where {T} = Base.unsafe_convert(Ptr{T}, A.data)
Base.reshape(A::ImmutableArray, args...) = freeze(reshape(A.data, args...)) # This could share data if possible
Base.reshape(A::ImmutableArray, arg::Tuple{Vararg{Int64,N}} where N) = freeze(reshape(A.data, arg))

