using PMIx

function main()
    # we need to attach to a "system" PMIx server so we
    # can ask it to spawn applications for us. There can
    # only be one such connection on a node, so we will
    # instruct the tool library to only look for it

    info = PMIx.Info(PMIx.API.PMIX_CONNECT_TO_SYSTEM, PMIx.Value(true, PMIx.API.PMIX_BOOL))
    _ = PMIx.tool_init(Ref(info))

    barrier = Threads.Event()

    function notification_fn(evhdlr_registration_id, status, source, info, ninfo, results, nresults, cbfunc, cbdata)
        if cbfunc != C_NULL
            ccall(cbfunc, Cvoid, (PMIx.API.pmix_status_t, Ptr{PMIx.API.pmix_info_t}, Csize_t, PMIx.API.pmix_op_cbfunc_t, Ptr{Cvoid}, Ptr{Cvoid}),
                PMIx.API.PMIX_EVENT_ACTION_COMPLETE, C_NULL, 0, C_NULL, C_NULL,cbdata)
        end
        ccall(:jl_breakpoint, Cvoid, ())
        return nothing
    end

    codes = [
        PMIx.API.PMIX_ERR_PROC_ABORTING,
        PMIx.API.PMIX_ERR_PROC_ABORTED,
        PMIx.API.PMIX_ERR_PROC_REQUESTED_ABORT,
        PMIx.API.PMIX_ERR_JOB_TERMINATED,
        PMIx.API.PMIX_ERR_UNREACH,
        PMIx.API.PMIX_ERR_LOST_CONNECTION_TO_SERVER
    ]

    callback = @cfunction($notification_fn, Cvoid, (Csize_t, PMIx.API.pmix_status_t, Ptr{PMIx.API.pmix_proc_t}, Ptr{PMIx.API.pmix_info_t}, Csize_t, Ptr{PMIx.API.pmix_info_t}, Csize_t, Ptr{PMIx.API.pmix_event_notification_cbfunc_fn_t}, Ptr{Cvoid}))
    PMIx.register(callback; codes)

    # provide directives so the apps do what the user requested - just
    # some random examples provided here

    infos = [
        PMIx.Info(PMIx.API.PMIX_MAPBY, PMIx.Value("slot", PMIx.API.PMIX_STRING)),
        PMIx.Info(PMIx.API.PMIX_NOTIFY_COMPLETION, PMIx.Value(true, PMIx.API.PMIX_BOOL)),
        # PMIx.Info(PMIx.API.PMIX_STDIN_TGT, PMIx.Value("0", PMIx.API.PMIX_PROC)), # all, none, or int -- maybe should be PMIX_PROC
        PMIx.Info(PMIx.API.PMIX_FWD_STDERR, PMIx.Value(true, PMIx.API.PMIX_BOOL)),
        PMIx.Info(PMIx.API.PMIX_FWD_STDOUT, PMIx.Value(true, PMIx.API.PMIX_BOOL)),
        # PMIx.Info(PMIx.API.PMIX_FWD_STDIN, PMIx.Value(0, PMIx.API.PMIX_PROC_RANK)),
    ]

    # parse the cmd line and create our array of app structs
    # describing the application we want launched
    # can also provide environmental params in the app.env field
    @show cmd = `$(Base.julia_cmd()) -e "println(:Hello)"`
    apps = [
        PMIx.App(
            first(cmd.exec),
            cmd.exec,
            String[],
            pwd(),
            2,
            [],
        )
    ]

    # spawn the application
    nspace = PMIx.spawn(apps, infos)
    @info "Spawned in" nspace

    root = PMIx.Proc(nspace, 0)
    # PMIx.IOF.redirect!(root)
    # PMIx.IOF.redirect_stdin!(root)

    # wait for the application to exit
    sleep(10)

    PMIx.tool_finalize()
end

if !isinteractive()
    import prrte_jll
    prte = prrte_jll.prte() do prte
            run(`$prte`, wait=false)
    end
    try
        main()
    finally
        kill(prte)
    end
end