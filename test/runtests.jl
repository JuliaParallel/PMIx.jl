using PMIx 
using Test

using prrte_jll

if !haskey(ENV, "PRTE_LAUNCHED")
    @testset "Outside PRTE session" begin
        @test PMIx.initialized() == false
        @test_throws PMIx.PMIxException PMIx.init()
    end

    @testset "Examples" begin
        examples = [
            ("client.jl", 2),
            ("dynamic.jl", 1),
        ]
        for (file, np) in examples
            example = realpath(joinpath(@__DIR__, "..", "examples", file))
            prrte_jll.prterun() do prterun
                cmd = `$prterun -np $np $(Base.julia_cmd()) $example`
                @testset "Example $file" begin
                    @test success(pipeline(cmd, stdout=stdout, stderr=stderr))
                end
            end
        end

        examples = [
            "launcher.jl",
        ]
        # Start a PRTE session
        prte = prrte_jll.prte() do prte
            run(`$prte`, wait=false)
        end
        try
            for file in examples
                example = realpath(joinpath(@__DIR__, "..", "examples", file))
                cmd = `$(Base.julia_cmd()) $example`
                @testset "Example $file" begin
                    @test success(pipeline(cmd, stdout=stdout, stderr=stderr))
                end
            end
        finally
            kill(prte)
        end
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
const myproc = PMIx.init()

@testset "Inside PRTE session" begin
    @test PMIx.initialized() == true
    @test myproc.rank ∈ (0, 1)
end

@testset "Values" begin
    optional = PMIx.Value(true, PMIx.API.PMIX_BOOL)
    @test convert(Bool, optional)

    optional = PMIx.Value(false, PMIx.API.PMIX_BOOL)
    @test !convert(Bool, optional)

    str = PMIx.Value("hello", PMIx.API.PMIX_STRING)
    @test convert(String, str) == "hello"
end

@testset "Job size" begin
    proc = PMIx.Proc(myproc.nspace, PMIx.API.PMIX_RANK_WILDCARD)
    optional = PMIx.Value(true, PMIx.API.PMIX_BOOL)
    value = PMIx.get(proc, PMIx.API.PMIX_JOB_SIZE, [PMIx.Info(PMIx.API.PMIX_OPTIONAL, optional)])
    @test PMIx.get_number(value) == 2
end

PMIx.finalize()
