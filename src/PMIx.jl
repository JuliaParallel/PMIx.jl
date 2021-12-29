module PMIx
using  Setfield

include("api.jl")

struct PMIxException <: Exception
    status::API.pmix_status_t
end

function Base.showerror(io::IO, pmi::PMIxException)
    print(io, "PMIxException: ")
    print(io, unsafe_string(API.PMIx_Error_string(pmi.status)))
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
        p_src = Base.unsafe_convert(Ptr{Cchar}, key)
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

nspace(proc::API.pmix_proc_t) = NSpace(proc.nspace)

struct NSpace
    x::API.pmix_nspace_t
end

function Base.string(nspace::NSpace)
    r_nspace = Ref(nspace.x)
    GC.@preserve r_nspace begin
        return unsafe_string(Base.unsafe_convert(Ptr{Cchar}, r_nspace))
    end
end

Base.convert(::Type{API.pmix_nspace_t}, ns::NSpace) = ns.x
Base.show(io::IO, ::MIME"text/plain", ns::NSpace) = print(io, Base.string(ns))

# 4. Client initialization and finalization

function initialized()
    API.PMIx_Initialized() != 0
end

function version()
    return Base.unsafe_string(API.PMIx_Get_version())
end

function init(info=nothing)
    if info === nothing
        info = C_NULL
        len = 0
    else
        len = length(info)
    end
    r_proc = Ref{API.pmix_proc_t}()
    @check API.PMIx_Init(r_proc, info, len)
    return r_proc[]
end

function finalize()
    @check API.PMIx_Finalize(C_NULL, 0)
end

function progress()
    API.PMIx_Progress()
end

# 5. Synchronization and Data Access Operations
fence(proc::API.pmix_proc_t, info=nothing) = fence(Ref(proc), info)
function fence(procs, info=nothing)
    if info === nothing
        info = C_NULL
        len = 0
    else
        len = length(info)
    end
    @check API.PMIx_Fence(procs, length(procs), C_NULL, 0)
end

## PMIx_Fence_nb

function get(proc, key, info=nothing)
    if info === nothing
        info = C_NULL
        len = 0
    else 
        len = length(info)
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

struct App
    cmd::String
    argv::Vector{String}
    env::Vector{String}
    cwd::String
    maxprocs::Cint
    info::Vector{API.pmix_info_t}
end

# Holds the temporary data we need to allocate
struct CApp
    argv::Vector{Ptr{Cchar}} # null-terminated
    env::Vector{Ptr{Cchar}} # null-terminated
    app::App
end

function Base.cconvert(::Type{API.pmix_app_t}, app::App)
    argv = map(s->Base.unsafe_convert(Ptr{Cchar}, s), app.argv)
    env = map(s->Base.unsafe_convert(Ptr{Cchar}, s), app.env)
    push!(argv, C_NULL)
    push!(env, C_NULL)
    return CApp(argv, env, app)
end

function Base.unsafe_convert(::Type{API.pmix_app_t}, app::CApp)
    argv = isempty(app.argv) ? C_NULL : Base.unsafe_convert(Ptr{Ptr{Cchar}}, app.argv)
    env = isempty(app.env) ? C_NULL : Base.unsafe_convert(Ptr{Ptr{Cchar}}, app.env)
    info = isempty(app.app.info) ? C_NULL : Base.unsafe_convert(Ptr{API.pmix_info_t}, app.app.info)

    API.pmix_app_t(
        Base.unsafe_convert(Ptr{Cchar}, app.app.cmd),
        argv,
        env,
        Base.unsafe_convert(Ptr{Cchar}, app.app.cwd),
        app.app.maxprocs,
        info,
        length(app.app.info)
    )
end

function spawn(app::App, job_info=nothing)
    if job_info === nothing
        job_info = C_NULL
        len = 0
    else
        len = length(job_info)
    end
    capp = Base.cconvert(API.pmix_app_t, app)
    nspace = Ref{API.pmix_nspace_t}()
    GC.@preserve capp app begin
        r_app = Ref(Base.unsafe_convert(API.pmix_app_t, capp))
        @check API.PMIx_Spawn(job_info, len, r_app, 1, nspace)
    end
    return NSpace(nspace[])
end

function spawn(apps::Vector{App}, job_info=nothing)
    if job_info === nothing
        job_info = C_NULL
        len = 0
    else
        len = length(job_info)
    end
    capps = map(app->Base.cconvert(API.pmix_app_t, app), apps)
    nspace = Ref{API.pmix_nspace_t}()
    GC.@preserve capps apps begin
        _apps = map(capp->Base.unsafe_convert(API.pmix_app_t, capp), capps)
        @check API.PMIx_Spawn(job_info, len, _apps, length(_apps), nspace)
    end
    return NSpace(nspace[])
end

# 17. Tools and Debuggers

function tool_init(info=nothing)
    if info === nothing
        info = C_NULL
        len = 0
    else
        len = length(info)
    end
    r_proc = Ref{API.pmix_proc_t}()
    @check API.PMIx_tool_init(r_proc, info, len)
    return r_proc[]
end

function tool_finalize()
    @check API.PMIx_tool_finalize()
end

end # module
