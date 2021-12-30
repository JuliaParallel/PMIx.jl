# Based off https://github.com/openpmix/openpmix/blob/4d07260d9f79bb7f328b1fc9107b45e683cf2c4e/examples/launcher.c
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
        error("BURN")
        if cbfunc != C_NULL
            ccall(cbfunc, Cvoid, (PMIx.API.pmix_status_t, Ptr{PMIx.API.pmix_info_t}, Csize_t, PMIx.API.pmix_op_cbfunc_t, Ptr{Cvoid}, Ptr{Cvoid}),
                PMIx.API.PMIX_EVENT_ACTION_COMPLETE, C_NULL, 0, C_NULL, C_NULL,cbdata)
        end
        @info "Callback called"
        notify(barrier)
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
        PMIx.Info(PMIx.API.PMIX_MAPBY, PMIx.Value("slot", PMIx.API.PMIX_STRING))
        PMIx.Info(PMIx.API.PMIX_NOTIFY_COMPLETION, PMIx.Value(true, PMIx.API.PMIX_BOOL))
    ]

    # parse the cmd line and create our array of app structs
    # describing the application we want launched
    # can also provide environmental params in the app.env field
    client = joinpath(@__DIR__, "client.jl")
    cmd = `$(Base.julia_cmd()) $client`
    apps = [
        PMIx.App(
            first(cmd.exec),
            cmd.exec,
            String[],
            pwd(),
            2,
            infos,
        )
    ]

    # spawn the application
    nspace = PMIx.spawn(apps)
    @info "Spawned in" nspace
    wait(barrier)
    PMIx.tool_finalize()
end

if !isinteractive()
    main()
end