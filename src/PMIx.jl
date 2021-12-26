module PMIx
using  Setfield

include("api.jl")

struct PMIxException <: Exception
    status::API.pmix_status_t
end

macro check(ex)
    quote
        status = $(esc(ex))
        if status != API.PMIX_SUCCESS
            throw(PMIxException(status))
        end
    end
end

function pmix_strncopy(dst::Ptr{Cchar}, src::Ptr{Cchar}, len)
    i = 1
    while i <= len
        c = unsafe_load(src, i)
        unsafe_store!(dst, i, c)
        if Char(c) == '\0'
            break
        end
        i += 1
    end
    unsafe_store!(dst, i, '\0'%Cchar)
end

include("value.jl")

function ZeroInfo()
    # Equivalent to PMIX_INFO_CONSTRUCT
    r_info = Ref{API.pmix_info_t}()
    ccall(:memset, Ptr{Cvoid}, (Ptr{Cvoid}, Cint, Csize_t), r_info, 0, sizeof(API.pmix_info_t))
    return r_info[]
end

function Info()
    info = ZeroInfo()
    info = @set info.value = UndefValue()
    return info
end

function Info(key, value, flags = 0)
    r_key = Ref{API.pmix_key_t}()
    GC.@preserve r_key key begin
        cstr = Base.unsafe_convert(Cstring, key) # ensure null termination
        p_src = convert(Ptr{Cchar}, cstr)
        p_dst = Base.unsafe_convert(Ptr{Cchar}, r_key)
        pmix_strncopy(p_dst, p_src, API.PMIX_MAX_KEYLEN)
    end
    API.pmix_info(r_key[], flags, value)
end

function Proc()
    # Equivalent to PMIX_PROC_CONSTRUCT
    r_proc = Ref{API.pmix_proc_t}()
    ccall(:memset, Ptr{Cvoid}, (Ptr{Cvoid}, Cint, Csize_t), r_proc, 0, sizeof(API.pmix_proc_t))
    return r_proc[]
end

function Proc(nspace, rank)
    proc = Proc()
    proc = @set proc.nspace = nspace
    proc = @set proc.rank = rank
    return proc
end

function nspace(proc::API.pmix_proc_t)
    ns = Ref(proc.nspace)
    GC.@preserve ns begin
        return unsafe_string(Base.unsafe_convert(Ptr{Cchar}, ns))
    end
end

# 4. Client initialization and finalization

function initialized()
    API.PMIx_Initialized() != 0
end

function version()
    return Base.unsafe_string(API.PMIx_Get_version())
end

# TODO: Parameters
function init()
    r_proc = Ref{API.pmix_proc_t}()
    @check API.PMIx_Init(r_proc, C_NULL, 0)
    return r_proc[]
end

function finalize()
    @check API.PMIx_Finalize(C_NULL, 0)
end

function progress()
    API.PMIx_Progress()
end

# 5. Synchronization and Data Access Operations

function fence(procs)
    @check API.PMIx_Fence(procs, length(procs), C_NULL, 0)
end

## PMIx_Fence_nb

function get(proc, key, info=nothing)
    if info === nothing
        info = C_NULL
        len = 0
    else 
        len= length(info)
    end
    r_ptr = Ref{Ptr{API.pmix_value_t}}()
    @check API.PMIx_Get(Ref(proc), key, info, len, r_ptr)
    ptr = r_ptr[]
    value = Base.unsafe_load(ptr)
    # TODO: Complain about pmix_free being defined inline
    # TODO: Memory rules?
    Libc.free(ptr)
    return value
end

# 5.4 Query

# 7. Process-Related Non-Reserved Keys'

function put!(scope, key, value)
    @check API.PMIx_Put(scope, key, value)
end

# PMIx_Store_internal

function commit()
    @check API.PMIx_Commit()
end

# 8. Publish/Lookup Operations
# 9. Event Notification
# 10. Data Packing and Unpacking
# 11. Process Management

end # module
