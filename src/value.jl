function ZeroValue()
    value = Ref{API.pmix_value_t}()
    ccall(:memset, Ptr{Cvoid}, (Ptr{Cvoid}, Cint, Csize_t), value, 0, sizeof(API.pmix_value_t))
    return value[]
end

function UndefValue()
    value = ZeroValue()
    value = @set value.type = API.PMIX_UNDEF
    return value
end

function destruct(value)
    r_value = Ref{API.pmix_value_t}(value)
    @check API.pmix_value_destruct(r_value)
    return nothing
end

# function unload(value)
#     r_value = Ref{API.pmix_value_t}(value)
#     data = Ref{Ptr{Cvoid}}()
#     sz = Ref{Csize_t}()
#     @check API.pmix_value_unload(r_value, data, sz)
#     return (data[], sz[])
# end

function load(value, data, type)
    r_value = Ref{API.pmix_value_t}(value)
    API.pmix_value_load(r_value, data, type)
    return r_value[]
end

function Value(data, type)
    value = ZeroValue()
    value = load(value, Ref(data), type)
    return value
end

# function xfer()
# end

macro get_number(T, PMIX_T, value)
    quote
        let value = $(esc(value))
            if value.type != $API.$(PMIX_T)
                throw($PMIxException($API.PMIX_ERR_TYPE_MISMATCH))
            end
            data = Ref(value.data)
            GC.@preserve data begin
                ptr = Base.unsafe_convert(Ptr{Cvoid}, data)
                result = unsafe_load(reinterpret(Ptr{$T}, ptr))
            end
            result
        end
    end
end


import Base: convert
function convert(::Type{Int32}, value::API.pmix_value_t)
    @assert Cint == Int32
    @assert Cint == API.pid_t
    if !(value.type == API.PMIX_INT || value.type ==  API.PMIX_INT32 || value.type == API.PMIX_PID)
        throw(PMIxException(API.PMIX_ERR_TYPE_MISMATCH))
    end
    data = Ref(value.data)
    GC.@preserve data begin
        ptr = Base.unsafe_convert(Ptr{Cvoid}, data)
        return unsafe_load(reinterpret(Ptr{Int32}, ptr))
    end
end

function convert(::Type{UInt32}, value::API.pmix_value_t)
    @assert Cuint == UInt32
    if !(value.type == API.PMIX_UINT || value.type ==  API.PMIX_UINT32)
        throw(PMIxException(API.PMIX_ERR_TYPE_MISMATCH))
    end
    data = Ref(value.data)
    GC.@preserve data begin
        ptr = Base.unsafe_convert(Ptr{Cvoid}, data)
        return unsafe_load(reinterpret(Ptr{UInt32}, ptr))
    end
end

function convert(::Type{UInt64}, value::API.pmix_value_t)
    @assert Csize_t == UInt64
    if !(value.type == API.PMIX_SIZE || value.type ==  API.PMIX_UINT64)
        throw(PMIxException(API.PMIX_ERR_TYPE_MISMATCH))
    end
    data = Ref(value.data)
    GC.@preserve data begin
        ptr = Base.unsafe_convert(Ptr{Cvoid}, data)
        return unsafe_load(reinterpret(Ptr{UInt64}, ptr))
    end
end

convert(::Type{Bool}, value::API.pmix_value_t) = @get_number(Bool, PMIX_BOOL, value)
convert(::Type{Int8}, value::API.pmix_value_t) = @get_number(Int8, PMIX_INT8, value)
convert(::Type{Int16}, value::API.pmix_value_t) = @get_number(Int16, PMIX_INT16, value)
convert(::Type{Int64}, value::API.pmix_value_t) = @get_number(Int64, PMIX_INT64, value)
convert(::Type{UInt8}, value::API.pmix_value_t) = @get_number(UInt8, PMIX_UINT8, value)
convert(::Type{UInt16}, value::API.pmix_value_t) = @get_number(UInt16, PMIX_UINT16, value)
convert(::Type{Float32}, value::API.pmix_value_t) = @get_number(Float32, PMIX_FLOAT, value)
convert(::Type{Float64}, value::API.pmix_value_t) = @get_number(Float64, PMIX_DOUBLE, value)


function get_number(value::API.pmix_value_t)
    if value.type == API.PMIX_SIZE
        return @get_number(Csize_t, PMIX_SIZE, value)
    elseif value.type == API.PMIX_PID
        return @get_number(API.pid_t, PMIX_PID, value)
    elseif value.type == API.PMIX_INT
        return @get_number(Cint, PMIX_INT, value)
    elseif value.type == API.PMIX_INT8
        return @get_number(Int8, PMIX_INT8, value)
    elseif value.type == API.PMIX_INT16
        return @get_number(Int16, PMIX_INT16, value)
    elseif value.type == API.PMIX_INT32
        return @get_number(Int32, PMIX_INT32, value)
    elseif value.type == API.PMIX_INT64
        return @get_number(Int64, PMIX_INT64, value)
    elseif value.type == API.PMIX_UINT
        return @get_number(Cuint, PMIX_UINT, value)
    elseif value.type == API.PMIX_UINT8
        return @get_number(UInt8, PMIX_UINT8, value)
    elseif value.type == API.PMIX_UINT16
        return @get_number(UInt16, PMIX_UINT16, value)
    elseif value.type == API.PMIX_UINT32
        return @get_number(UInt32, PMIX_UINT32, value)
    elseif value.type == API.PMIX_UINT64
        return @get_number(UInt64, PMIX_UINT64, value)
    elseif value.type == API.PMIX_FLOAT
        return @get_number(Float32, PMIX_FLOAT, value)
    elseif value.type == API.PMIX_DOUBLE
        return @get_number(Float64, PMIX_DOUBLE, value)
    end
    error("Unkown numeric typed $(value.type)")
end