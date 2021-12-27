# Based off https://github.com/openpmix/openpmix/blob/4d07260d9f79bb7f328b1fc9107b45e683cf2c4e/examples/client.c
using PMIx

import PMIx: nspace

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

    # TODO: Register event handler

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
