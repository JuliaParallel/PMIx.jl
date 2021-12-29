# Based off https://github.com/openpmix/openpmix/blob/4d07260d9f79bb7f328b1fc9107b45e683cf2c4e/examples/launcher.c
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
        PMIx.Info(PMIx.API.PMIX_MAPBY, PMIx.Value("slot", PMIx.API.PMIX_STRING))
        PMIx.Info(PMIx.API.PMIX_NOTIFY_COMPLETION, PMIx.Value(true, PMIx.API.PMIX_BOOL))
    ]

    # parse the cmd line and create our array of app structs
    # describing the application we want launched
    # can also provide environmental params in the app.env field
    cmd = `$(Base.julia_cmd()) --eval "exit()"`
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

    PMIx.tool_finalize()
end

if !isinteractive()
    main()
end