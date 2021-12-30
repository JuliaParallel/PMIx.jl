# Based off https://github.com/openpmix/openpmix/blob/4d07260d9f79bb7f328b1fc9107b45e683cf2c4e/examples/client.c
using PMIx

import PMIx: nspace

function notification_fn(evhdlr_registration_id::Csize_t, status::PMIx.API.pmix_status_t, source::Ptr{PMIx.API.pmix_proc_t},
                         info::Ptr{PMIx.API.pmix_info_t}, ninfo::Csize_t,
                         results::Ptr{PMIx.API.pmix_info_t}, nresults::Csize_t,
                         cbfunc::PMIx.API.pmix_event_notification_cbfunc_fn_t, cbdata::Ptr{Cvoid})::Nothing

    if cbfunc != C_NULL
        ccall(cbfunc, Cvoid, (PMIx.API.pmix_status_t, Ptr{PMIx.API.pmix_info_t}, Csize_t, PMIx.API.pmix_op_cbfunc_t, Ptr{Cvoid}, Ptr{Cvoid}),
            PMIx.API.PMIX_EVENT_ACTION_COMPLETE, C_NULL, 0, C_NULL, C_NULL,cbdata)
    end

    @info "Callback called"
    return nothing
end

function main()
    pid = Libc.getpid()
    @info "Client running" pid

    # init us - note that the call to "init" includes the return of
    # any job-related info provided by the RM. This includes any
    # debugger flag instructing us to stop-in-init. If such a directive
    # is included, then the process will be stopped in this call until
    # the "debugger release" notification arrives

    myproc = PMIx.init()
    @info "Client initialized" ns=nspace(myproc) rank=myproc.rank pid

    callback = @cfunction(notification_fn, Cvoid, (Csize_t, PMIx.API.pmix_status_t, Ptr{PMIx.API.pmix_proc_t}, Ptr{PMIx.API.pmix_info_t}, Csize_t, Ptr{PMIx.API.pmix_info_t}, Csize_t, Ptr{PMIx.API.pmix_event_notification_cbfunc_fn_t}, Ptr{Cvoid}))
    PMIx.register(callback)

    # job-related info is found in our nspace, assigned to the
    # wildcard rank as it doesn't relate to a specific rank. Setup
    # a name to retrieve such values
    proc = PMIx.Proc(myproc.nspace, PMIx.API.PMIX_RANK_WILDCARD)

    # TODO: Check debugger
    # TODO: Check local topo

    # get our universe size
    value = PMIx.get(proc, PMIx.API.PMIX_UNIV_SIZE)
    @info "Universe size" ns=nspace(myproc) size=PMIx.get_number(value)

    PMIx.finalize()
    exit()
end

if !isinteractive()
    main()
end
