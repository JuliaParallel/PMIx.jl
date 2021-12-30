using PMIx

function main()
    # we need to attach to a "system" PMIx server so we
    # can ask it to spawn applications for us. There can
    # only be one such connection on a node, so we will
    # instruct the tool library to only look for it

    info = PMIx.Info(PMIx.API.PMIX_CONNECT_TO_SYSTEM, PMIx.Value(true, PMIx.API.PMIX_BOOL))
    _ = PMIx.tool_init(Ref(info))

    # TODO event handler

    # provide directives so the apps do what the user requested - just
    # some random examples provided here

    infos = [
        PMIx.Info(PMIx.API.PMIX_MAPBY, PMIx.Value("slot", PMIx.API.PMIX_STRING)),
        PMIx.Info(PMIx.API.PMIX_NOTIFY_COMPLETION, PMIx.Value(true, PMIx.API.PMIX_BOOL)),
        # PMIx.Info(PMIx.API.PMIX_STDIN_TGT, PMIx.Value("0", PMIx.API.PMIX_PROC)), # all, none, or int -- maybe should be PMIX_PROC
        PMIx.Info(PMIx.API.PMIX_FWD_STDERR, PMIx.Value(true, PMIx.API.PMIX_BOOL)),
        PMIx.Info(PMIx.API.PMIX_FWD_STDOUT, PMIx.Value(true, PMIx.API.PMIX_BOOL)),
        PMIx.Info(PMIx.API.PMIX_FWD_STDIN, PMIx.Value(0, PMIx.API.PMIX_RANK)),
    ]

    # parse the cmd line and create our array of app structs
    # describing the application we want launched
    # can also provide environmental params in the app.env field
    cmd = `$(Base.julia_cmd())`
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

    root = PMIx.proc(nspace, 0)
    PMIx.IOF.redirect!(root)
    PMIx.IOF.redirect_stdin!(root)

    # wait for the application to exit

    PMIx.tool_finalize()
end

if !isinteractive()
    main()
end