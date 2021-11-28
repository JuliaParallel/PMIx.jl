using Clang.Generators
using PMIx_jll

include_dir = joinpath(PMIx_jll.artifact_dir ,"include")

options = load_options(joinpath(@__DIR__, "wrap.toml"))

args = get_default_args()
push!(args, "-I$include_dir")

headers = [joinpath(include_dir, header) for header in ["pmix.h"]]

@add_def pid_t
@add_def __time_t
@add_def __suseconds_t
@add_def time_t
@add_def UINT32_MAX

ctx = create_context(headers, args, options)
build!(ctx)