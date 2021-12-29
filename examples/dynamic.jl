# Based off https://github.com/openpmix/openpmix/blob/4d07260d9f79bb7f328b1fc9107b45e683cf2c4e/examples/dynamic.c
using PMIx

import PMIx: nspace

function main()
    myproc = PMIx.init()
    @info "Client running" ns=nspace(myproc) rank=myproc.rank


    # get our job size
    nprocs = let proc = PMIx.Proc(myproc.nspace, PMIx.API.PMIX_RANK_WILDCARD)
        value = PMIx.get(proc, PMIx.API.PMIX_JOB_SIZE)
        PMIx.get_number(value)
    end

    @info "Client" ns=nspace(myproc) rank=myproc.rank nprocs

    # call fence to sync
    let proc = PMIx.Proc(myproc.nspace, PMIx.API.PMIX_RANK_WILDCARD)
        PMIx.fence(proc)
    end

    # rank 0 calls spawn
    if myproc.rank == 0
        client = joinpath(@__DIR__, "client.jl")
        cmd = `$(Base.julia_cmd()) $client`
        apps = [
            PMIx.App(
                first(cmd.exec),
                cmd.exec,
                String[],
                pwd(),
                2,
                PMIx.API.pmix_info_t[],
            )
        ]

        # spawn the application
        nspace_foreign = PMIx.spawn(apps)
        @info "Spawned in" nspace_foreign rank = myproc.rank

        # get their universe size
        nprocs_foreign = let proc = PMIx.Proc(nspace_foreign, PMIx.API.PMIX_RANK_WILDCARD)
            value = PMIx.get(proc, PMIx.API.PMIX_JOB_SIZE)
            PMIx.get_number(value)
        end
        @info "Client: Foreign job size" ns=nspace(myproc) rank = myproc.rank nprocs_foreign

        # get a proc-specific value
        tmp = let proc = PMIx.Proc(nspace_foreign, 1)
            value = PMIx.get(proc, PMIx.API.PMIX_LOCAL_RANK)
            PMIx.get_number(value)
        end
        @info "Client: Local rank" ns=nspace(myproc) rank = myproc.rank lrank=tmp

    end

    # call fence to sync
    let proc = PMIx.Proc(myproc.nspace, PMIx.API.PMIX_RANK_WILDCARD)
        PMIx.fence(proc)
    end
    PMIx.finalize()
    exit()
end

if !isinteractive()
    main()
end