using PMIx 
using Test

using prrte_jll

if !haskey(ENV, "PRTE_LAUNCHED")
    @testset "Outside PRTE session" begin
        @test PMIx.initialized() == false
        @test_throws PMIx.PMIxException PMIx.init()
    end

    @info "relaunching under PRTE"
    current_file = @__FILE__ # bug in 1.5 can't be directly interpolated
    jlcmd = `$(Base.julia_cmd()) $(current_file)`

    prrte_jll.prterun() do prterun
        cmd = `$prterun -np 2 $jlcmd`
        @test success(pipeline(cmd, stdout=stdout, stderr=stderr))
    end
    exit()
end

# These tests now execute on multiple ranks
@testset "Inside PRTE session" begin
    PMIx.init()
    @test PMIx.initialized() == true
    PMIx.finalize()
end
