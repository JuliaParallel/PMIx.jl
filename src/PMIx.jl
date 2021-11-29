module PMIx

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

function version()
    return Base.unsafe_string(API.PMIx_Get_version())
end

function init()
    r_proc = Ref{API.pmix_proc_t}()
    @check API.PMIx_Init(r_proc, C_NULL, 0)
    return r_proc[]
end

function initialized()
    API.PMIx_Initialized() != 0
end

function finalize()
    @check API.PMIx_Finalize(C_NULL, 0)
end

end # module
