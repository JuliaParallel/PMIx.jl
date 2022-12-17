using PMIx_jll

function __init__()
    # Required for PMIx relocateable binaries
    # TODO: this should be done in PMIx_jll package
    # https://github.com/JuliaPackaging/Yggdrasil/issues/390
    ENV["PMIX_INSTALL_PREFIX"] = PMIx_jll.artifact_dir
    nothing
end

const pid_t = Cint
const gid_t = Cuint
const uid_t = Cuint

const __time_t = Clong
const __suseconds_t = Clong
const time_t = __time_t

const UINT32_MAX = typemax(UInt32)
const UINT8_MAX = typemax(UInt8)

# FIXME:
# correct for 4.1.0

const PMIX_INTERNAL_ERR_BASE = -1330
