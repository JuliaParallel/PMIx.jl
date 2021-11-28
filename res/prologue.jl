using PMIx_jll

const pid_t = Cint

const __time_t = Clong
const __suseconds_t = Clong
const time_t = __time_t

const UINT32_MAX = typemax(UInt32)
const UINT8_MAX = typemax(UInt8)

# FIXME:
# correct for 4.1.0

const PMIX_INTERNAL_ERR_BASE = -1330
