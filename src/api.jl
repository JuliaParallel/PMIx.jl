module API

using CEnum

using PMIx_jll

function __init__()
    # Required for PMIx relocateable binaries
    # TODO: this should be done in PMIx_jll package
    # https://github.com/JuliaPackaging/Yggdrasil/issues/390
    ENV["PMIX_PREFIX"] = PMIx_jll.artifact_dir
    # ENV["PMIX_MCA_mca_base_component_path"] = joinpath(PMIx_jll.artifact_dir, "lib", "pmix")
    nothing
end

const pid_t = Cint

const __time_t = Clong
const __suseconds_t = Clong
const time_t = __time_t

const UINT32_MAX = typemax(UInt32)
const UINT8_MAX = typemax(UInt8)

# FIXME:
# correct for 4.1.0

const PMIX_INTERNAL_ERR_BASE = -1330


struct timeval
    tv_sec::__time_t
    tv_usec::__suseconds_t
end

function pmix_strncpy(dest, src, len)
    ccall((:pmix_strncpy, libpmix), Cvoid, (Ptr{Cchar}, Ptr{Cchar}, Csize_t), dest, src, len)
end

function pmix_nslen(src)
    ccall((:pmix_nslen, libpmix), Csize_t, (Ptr{Cchar},), src)
end

const pmix_nspace_t = NTuple{256, Cchar}

const pmix_rank_t = UInt32

struct pmix_proc
    nspace::pmix_nspace_t
    rank::pmix_rank_t
end

const pmix_proc_t = pmix_proc

const pmix_coord_view_t = UInt8

struct pmix_coord
    view::pmix_coord_view_t
    coord::Ptr{UInt32}
    dims::Csize_t
end

const pmix_coord_t = pmix_coord

function pmix_calloc(n, m)
    ccall((:pmix_calloc, libpmix), Ptr{Cvoid}, (Csize_t, Csize_t), n, m)
end

function pmix_free(m)
    ccall((:pmix_free, libpmix), Cvoid, (Ptr{Cvoid},), m)
end

struct pmix_cpuset_t
    source::Ptr{Cchar}
    bitmap::Ptr{Cvoid}
end

function pmix_ploc_base_destruct_cpuset(cpuset)
    ccall((:pmix_ploc_base_destruct_cpuset, libpmix), Cvoid, (Ptr{pmix_cpuset_t},), cpuset)
end

function pmix_ploc_base_release_cpuset(cpuset, n)
    ccall((:pmix_ploc_base_release_cpuset, libpmix), Cvoid, (Ptr{pmix_cpuset_t}, Csize_t), cpuset, n)
end

struct pmix_topology_t
    source::Ptr{Cchar}
    topology::Ptr{Cvoid}
end

function pmix_ploc_base_destruct_topology(topo)
    ccall((:pmix_ploc_base_destruct_topology, libpmix), Cvoid, (Ptr{pmix_topology_t},), topo)
end

function pmix_ploc_base_release_topology(topo, n)
    ccall((:pmix_ploc_base_release_topology, libpmix), Cvoid, (Ptr{pmix_topology_t}, Csize_t), topo, n)
end

struct pmix_geometry
    fabric::Csize_t
    uuid::Ptr{Cchar}
    osname::Ptr{Cchar}
    coordinates::Ptr{pmix_coord_t}
    ncoords::Csize_t
end

const pmix_geometry_t = pmix_geometry

const pmix_device_type_t = UInt64

struct pmix_device_distance
    uuid::Ptr{Cchar}
    osname::Ptr{Cchar}
    type::pmix_device_type_t
    mindist::UInt16
    maxdist::UInt16
end

const pmix_device_distance_t = pmix_device_distance

struct pmix_byte_object
    bytes::Ptr{Cchar}
    size::Csize_t
end

const pmix_byte_object_t = pmix_byte_object

function pmix_malloc(n)
    ccall((:pmix_malloc, libpmix), Ptr{Cvoid}, (Csize_t,), n)
end

struct pmix_endpoint
    uuid::Ptr{Cchar}
    osname::Ptr{Cchar}
    endpt::pmix_byte_object_t
end

const pmix_endpoint_t = pmix_endpoint

struct pmix_envar_t
    envar::Ptr{Cchar}
    value::Ptr{Cchar}
    separator::Cchar
end

struct pmix_data_buffer
    base_ptr::Ptr{Cchar}
    pack_ptr::Ptr{Cchar}
    unpack_ptr::Ptr{Cchar}
    bytes_allocated::Csize_t
    bytes_used::Csize_t
end

const pmix_data_buffer_t = pmix_data_buffer

const pmix_status_t = Cint

function PMIx_Data_load(buffer, payload)
    ccall((:PMIx_Data_load, libpmix), pmix_status_t, (Ptr{pmix_data_buffer_t}, Ptr{pmix_byte_object_t}), buffer, payload)
end

function PMIx_Data_unload(buffer, payload)
    ccall((:PMIx_Data_unload, libpmix), pmix_status_t, (Ptr{pmix_data_buffer_t}, Ptr{pmix_byte_object_t}), buffer, payload)
end

const pmix_proc_state_t = UInt8

struct pmix_proc_info
    proc::pmix_proc_t
    hostname::Ptr{Cchar}
    executable_name::Ptr{Cchar}
    pid::pid_t
    exit_code::Cint
    state::pmix_proc_state_t
end

const pmix_proc_info_t = pmix_proc_info

struct pmix_proc_stats
    node::Ptr{Cchar}
    proc::pmix_proc_t
    pid::pid_t
    cmd::Ptr{Cchar}
    state::Cchar
    time::timeval
    percent_cpu::Cfloat
    priority::Int32
    num_threads::UInt16
    pss::Cfloat
    vsize::Cfloat
    rss::Cfloat
    peak_vsize::Cfloat
    processor::UInt16
    sample_time::timeval
end

const pmix_proc_stats_t = pmix_proc_stats

struct pmix_disk_stats_t
    disk::Ptr{Cchar}
    num_reads_completed::UInt64
    num_reads_merged::UInt64
    num_sectors_read::UInt64
    milliseconds_reading::UInt64
    num_writes_completed::UInt64
    num_writes_merged::UInt64
    num_sectors_written::UInt64
    milliseconds_writing::UInt64
    num_ios_in_progress::UInt64
    milliseconds_io::UInt64
    weighted_milliseconds_io::UInt64
end

struct pmix_net_stats_t
    net_interface::Ptr{Cchar}
    num_bytes_recvd::UInt64
    num_packets_recvd::UInt64
    num_recv_errs::UInt64
    num_bytes_sent::UInt64
    num_packets_sent::UInt64
    num_send_errs::UInt64
end

struct pmix_node_stats_t
    node::Ptr{Cchar}
    la::Cfloat
    la5::Cfloat
    la15::Cfloat
    total_mem::Cfloat
    free_mem::Cfloat
    buffers::Cfloat
    cached::Cfloat
    swap_cached::Cfloat
    swap_total::Cfloat
    swap_free::Cfloat
    mapped::Cfloat
    sample_time::timeval
    diskstats::Ptr{pmix_disk_stats_t}
    ndiskstats::Csize_t
    netstats::Ptr{pmix_net_stats_t}
    nnetstats::Csize_t
end

const pmix_data_type_t = UInt16

struct __JL_Ctag_29
    data::NTuple{24, UInt8}
end

function Base.getproperty(x::Ptr{__JL_Ctag_29}, f::Symbol)
    f === :flag && return Ptr{Bool}(x + 0)
    f === :byte && return Ptr{UInt8}(x + 0)
    f === :string && return Ptr{Ptr{Cchar}}(x + 0)
    f === :size && return Ptr{Csize_t}(x + 0)
    f === :pid && return Ptr{pid_t}(x + 0)
    f === :integer && return Ptr{Cint}(x + 0)
    f === :int8 && return Ptr{Int8}(x + 0)
    f === :int16 && return Ptr{Int16}(x + 0)
    f === :int32 && return Ptr{Int32}(x + 0)
    f === :int64 && return Ptr{Int64}(x + 0)
    f === :uint && return Ptr{Cuint}(x + 0)
    f === :uint8 && return Ptr{UInt8}(x + 0)
    f === :uint16 && return Ptr{UInt16}(x + 0)
    f === :uint32 && return Ptr{UInt32}(x + 0)
    f === :uint64 && return Ptr{UInt64}(x + 0)
    f === :fval && return Ptr{Cfloat}(x + 0)
    f === :dval && return Ptr{Cdouble}(x + 0)
    f === :tv && return Ptr{timeval}(x + 0)
    f === :time && return Ptr{time_t}(x + 0)
    f === :status && return Ptr{pmix_status_t}(x + 0)
    f === :rank && return Ptr{pmix_rank_t}(x + 0)
    f === :nspace && return Ptr{Ptr{pmix_nspace_t}}(x + 0)
    f === :proc && return Ptr{Ptr{pmix_proc_t}}(x + 0)
    f === :bo && return Ptr{pmix_byte_object_t}(x + 0)
    f === :persist && return Ptr{pmix_persistence_t}(x + 0)
    f === :scope && return Ptr{pmix_scope_t}(x + 0)
    f === :range && return Ptr{pmix_data_range_t}(x + 0)
    f === :state && return Ptr{pmix_proc_state_t}(x + 0)
    f === :pinfo && return Ptr{Ptr{pmix_proc_info_t}}(x + 0)
    f === :darray && return Ptr{Ptr{pmix_data_array_t}}(x + 0)
    f === :ptr && return Ptr{Ptr{Cvoid}}(x + 0)
    f === :adir && return Ptr{pmix_alloc_directive_t}(x + 0)
    f === :envar && return Ptr{pmix_envar_t}(x + 0)
    f === :coord && return Ptr{Ptr{pmix_coord_t}}(x + 0)
    f === :linkstate && return Ptr{pmix_link_state_t}(x + 0)
    f === :jstate && return Ptr{pmix_job_state_t}(x + 0)
    f === :topo && return Ptr{Ptr{pmix_topology_t}}(x + 0)
    f === :cpuset && return Ptr{Ptr{pmix_cpuset_t}}(x + 0)
    f === :locality && return Ptr{pmix_locality_t}(x + 0)
    f === :geometry && return Ptr{Ptr{pmix_geometry_t}}(x + 0)
    f === :devtype && return Ptr{pmix_device_type_t}(x + 0)
    f === :devdist && return Ptr{Ptr{pmix_device_distance_t}}(x + 0)
    f === :endpoint && return Ptr{Ptr{pmix_endpoint_t}}(x + 0)
    f === :dbuf && return Ptr{Ptr{pmix_data_buffer_t}}(x + 0)
    f === :pstats && return Ptr{Ptr{pmix_proc_stats_t}}(x + 0)
    f === :dkstats && return Ptr{Ptr{pmix_disk_stats_t}}(x + 0)
    f === :netstats && return Ptr{Ptr{pmix_net_stats_t}}(x + 0)
    f === :ndstats && return Ptr{Ptr{pmix_node_stats_t}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::__JL_Ctag_29, f::Symbol)
    r = Ref{__JL_Ctag_29}(x)
    ptr = Base.unsafe_convert(Ptr{__JL_Ctag_29}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{__JL_Ctag_29}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

struct pmix_value
    data::NTuple{32, UInt8}
end

function Base.getproperty(x::Ptr{pmix_value}, f::Symbol)
    f === :type && return Ptr{pmix_data_type_t}(x + 0)
    f === :data && return Ptr{__JL_Ctag_29}(x + 8)
    return getfield(x, f)
end

function Base.getproperty(x::pmix_value, f::Symbol)
    r = Ref{pmix_value}(x)
    ptr = Base.unsafe_convert(Ptr{pmix_value}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{pmix_value}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

const pmix_value_t = pmix_value

function pmix_value_destruct(m)
    ccall((:pmix_value_destruct, libpmix), Cvoid, (Ptr{pmix_value_t},), m)
end

function pmix_value_load(v, data, type)
    ccall((:pmix_value_load, libpmix), Cvoid, (Ptr{pmix_value_t}, Ptr{Cvoid}, pmix_data_type_t), v, data, type)
end

function pmix_value_unload(kv, data, sz)
    ccall((:pmix_value_unload, libpmix), pmix_status_t, (Ptr{pmix_value_t}, Ptr{Ptr{Cvoid}}, Ptr{Csize_t}), kv, data, sz)
end

function pmix_value_xfer(kv, src)
    ccall((:pmix_value_xfer, libpmix), pmix_status_t, (Ptr{pmix_value_t}, Ptr{pmix_value_t}), kv, src)
end

const pmix_key_t = NTuple{512, Cchar}

const pmix_info_directives_t = UInt32

struct pmix_info
    key::pmix_key_t
    flags::pmix_info_directives_t
    value::pmix_value_t
end

const pmix_info_t = pmix_info

function pmix_info_list_start()
    ccall((:pmix_info_list_start, libpmix), Ptr{Cvoid}, ())
end

function pmix_info_list_add(ptr, key, value, type)
    ccall((:pmix_info_list_add, libpmix), pmix_status_t, (Ptr{Cvoid}, Ptr{Cchar}, Ptr{Cvoid}, pmix_data_type_t), ptr, key, value, type)
end

function pmix_info_list_xfer(ptr, info)
    ccall((:pmix_info_list_xfer, libpmix), pmix_status_t, (Ptr{Cvoid}, Ptr{pmix_info_t}), ptr, info)
end

struct pmix_data_array
    type::pmix_data_type_t
    size::Csize_t
    array::Ptr{Cvoid}
end

const pmix_data_array_t = pmix_data_array

function pmix_info_list_convert(ptr, array)
    ccall((:pmix_info_list_convert, libpmix), pmix_status_t, (Ptr{Cvoid}, Ptr{pmix_data_array_t}), ptr, array)
end

function pmix_info_list_release(ptr)
    ccall((:pmix_info_list_release, libpmix), Cvoid, (Ptr{Cvoid},), ptr)
end

struct pmix_pdata
    proc::pmix_proc_t
    key::pmix_key_t
    value::pmix_value_t
end

const pmix_pdata_t = pmix_pdata

struct pmix_app
    cmd::Ptr{Cchar}
    argv::Ptr{Ptr{Cchar}}
    env::Ptr{Ptr{Cchar}}
    cwd::Ptr{Cchar}
    maxprocs::Cint
    info::Ptr{pmix_info_t}
    ninfo::Csize_t
end

const pmix_app_t = pmix_app

struct pmix_query
    keys::Ptr{Ptr{Cchar}}
    qualifiers::Ptr{pmix_info_t}
    nqual::Csize_t
end

const pmix_query_t = pmix_query

function pmix_argv_append_nosize(argv, arg)
    ccall((:pmix_argv_append_nosize, libpmix), pmix_status_t, (Ptr{Ptr{Ptr{Cchar}}}, Ptr{Cchar}), argv, arg)
end

function pmix_argv_free(argv)
    ccall((:pmix_argv_free, libpmix), Cvoid, (Ptr{Ptr{Cchar}},), argv)
end

struct pmix_regattr_t
    name::Ptr{Cchar}
    string::pmix_key_t
    type::pmix_data_type_t
    description::Ptr{Ptr{Cchar}}
end

function pmix_argv_copy(argv)
    ccall((:pmix_argv_copy, libpmix), Ptr{Ptr{Cchar}}, (Ptr{Ptr{Cchar}},), argv)
end

struct pmix_fabric_s
    name::Ptr{Cchar}
    index::Csize_t
    info::Ptr{pmix_info_t}
    ninfo::Csize_t
    _module::Ptr{Cvoid}
end

const pmix_fabric_t = pmix_fabric_s

function pmix_argv_prepend_nosize(argv, arg)
    ccall((:pmix_argv_prepend_nosize, libpmix), pmix_status_t, (Ptr{Ptr{Ptr{Cchar}}}, Ptr{Cchar}), argv, arg)
end

function pmix_argv_append_unique_nosize(argv, arg)
    ccall((:pmix_argv_append_unique_nosize, libpmix), pmix_status_t, (Ptr{Ptr{Ptr{Cchar}}}, Ptr{Cchar}), argv, arg)
end

function pmix_argv_split(src_string, delimiter)
    ccall((:pmix_argv_split, libpmix), Ptr{Ptr{Cchar}}, (Ptr{Cchar}, Cint), src_string, delimiter)
end

function pmix_argv_count(argv)
    ccall((:pmix_argv_count, libpmix), Cint, (Ptr{Ptr{Cchar}},), argv)
end

function pmix_argv_join(argv, delimiter)
    ccall((:pmix_argv_join, libpmix), Ptr{Cchar}, (Ptr{Ptr{Cchar}}, Cint), argv, delimiter)
end

function pmix_setenv(name, value, overwrite, env)
    ccall((:pmix_setenv, libpmix), pmix_status_t, (Ptr{Cchar}, Ptr{Cchar}, Bool, Ptr{Ptr{Ptr{Cchar}}}), name, value, overwrite, env)
end

const pmix_link_state_t = UInt8

function pmix_darray_destruct(m)
    ccall((:pmix_darray_destruct, libpmix), Cvoid, (Ptr{pmix_data_array_t},), m)
end

# typedef void ( * pmix_info_cbfunc_t ) ( pmix_status_t status , pmix_info_t * info , size_t ninfo , void * cbdata , pmix_release_cbfunc_t release_fn , void * release_cbdata )
const pmix_info_cbfunc_t = Ptr{Cvoid}

function PMIx_Process_monitor_nb(monitor, error, directives, ndirs, cbfunc, cbdata)
    ccall((:PMIx_Process_monitor_nb, libpmix), pmix_status_t, (Ptr{pmix_info_t}, pmix_status_t, Ptr{pmix_info_t}, Csize_t, pmix_info_cbfunc_t, Ptr{Cvoid}), monitor, error, directives, ndirs, cbfunc, cbdata)
end

const pmix_job_state_t = UInt8

const pmix_scope_t = UInt8

const pmix_data_range_t = UInt8

const pmix_persistence_t = UInt8

const pmix_alloc_directive_t = UInt8

const pmix_iof_channel_t = UInt16

@cenum pmix_group_opt_t::UInt32 begin
    PMIX_GROUP_DECLINE = 0
    PMIX_GROUP_ACCEPT = 1
end

@cenum pmix_group_operation_t::UInt32 begin
    PMIX_GROUP_CONSTRUCT = 0
    PMIX_GROUP_DESTRUCT = 1
end

const pmix_bind_envelope_t = UInt8

const pmix_locality_t = UInt16

@cenum pmix_fabric_operation_t::UInt32 begin
    PMIX_FABRIC_REQUEST_INFO = 0
    PMIX_FABRIC_UPDATE_INFO = 1
end

# typedef void ( * pmix_release_cbfunc_t ) ( void * cbdata )
const pmix_release_cbfunc_t = Ptr{Cvoid}

# typedef void ( * pmix_modex_cbfunc_t ) ( pmix_status_t status , const char * data , size_t ndata , void * cbdata , pmix_release_cbfunc_t release_fn , void * release_cbdata )
const pmix_modex_cbfunc_t = Ptr{Cvoid}

# typedef void ( * pmix_spawn_cbfunc_t ) ( pmix_status_t status , pmix_nspace_t nspace , void * cbdata )
const pmix_spawn_cbfunc_t = Ptr{Cvoid}

# typedef void ( * pmix_op_cbfunc_t ) ( pmix_status_t status , void * cbdata )
const pmix_op_cbfunc_t = Ptr{Cvoid}

# typedef void ( * pmix_lookup_cbfunc_t ) ( pmix_status_t status , pmix_pdata_t data [ ] , size_t ndata , void * cbdata )
const pmix_lookup_cbfunc_t = Ptr{Cvoid}

# typedef void ( * pmix_event_notification_cbfunc_fn_t ) ( pmix_status_t status , pmix_info_t * results , size_t nresults , pmix_op_cbfunc_t cbfunc , void * thiscbdata , void * notification_cbdata )
const pmix_event_notification_cbfunc_fn_t = Ptr{Cvoid}

# typedef void ( * pmix_notification_fn_t ) ( size_t evhdlr_registration_id , pmix_status_t status , const pmix_proc_t * source , pmix_info_t info [ ] , size_t ninfo , pmix_info_t * results , size_t nresults , pmix_event_notification_cbfunc_fn_t cbfunc , void * cbdata )
const pmix_notification_fn_t = Ptr{Cvoid}

# typedef void ( * pmix_hdlr_reg_cbfunc_t ) ( pmix_status_t status , size_t refid , void * cbdata )
const pmix_hdlr_reg_cbfunc_t = Ptr{Cvoid}

# typedef void ( * pmix_evhdlr_reg_cbfunc_t ) ( pmix_status_t status , size_t refid , void * cbdata )
const pmix_evhdlr_reg_cbfunc_t = Ptr{Cvoid}

# typedef void ( * pmix_value_cbfunc_t ) ( pmix_status_t status , pmix_value_t * kv , void * cbdata )
const pmix_value_cbfunc_t = Ptr{Cvoid}

# typedef void ( * pmix_credential_cbfunc_t ) ( pmix_status_t status , pmix_byte_object_t * credential , pmix_info_t info [ ] , size_t ninfo , void * cbdata )
const pmix_credential_cbfunc_t = Ptr{Cvoid}

# typedef void ( * pmix_validation_cbfunc_t ) ( pmix_status_t status , pmix_info_t info [ ] , size_t ninfo , void * cbdata )
const pmix_validation_cbfunc_t = Ptr{Cvoid}

# typedef void ( * pmix_device_dist_cbfunc_t ) ( pmix_status_t status , pmix_device_distance_t * dist , size_t ndist , void * cbdata , pmix_release_cbfunc_t release_fn , void * release_cbdata )
const pmix_device_dist_cbfunc_t = Ptr{Cvoid}

function pmix_keylen(src)
    ccall((:pmix_keylen, libpmix), Csize_t, (Ptr{Cchar},), src)
end

function PMIx_tool_connect_to_server(proc, info, ninfo)
    ccall((:PMIx_tool_connect_to_server, libpmix), pmix_status_t, (Ptr{pmix_proc_t}, Ptr{pmix_info_t}, Csize_t), proc, info, ninfo)
end

function PMIx_Init(proc, info, ninfo)
    ccall((:PMIx_Init, libpmix), pmix_status_t, (Ptr{pmix_proc_t}, Ptr{pmix_info_t}, Csize_t), proc, info, ninfo)
end

function PMIx_Finalize(info, ninfo)
    ccall((:PMIx_Finalize, libpmix), pmix_status_t, (Ptr{pmix_info_t}, Csize_t), info, ninfo)
end

function PMIx_Initialized()
    ccall((:PMIx_Initialized, libpmix), Cint, ())
end

function PMIx_Abort(status, msg, procs, nprocs)
    ccall((:PMIx_Abort, libpmix), pmix_status_t, (Cint, Ptr{Cchar}, Ptr{pmix_proc_t}, Csize_t), status, msg, procs, nprocs)
end

function PMIx_Put(scope, key, val)
    ccall((:PMIx_Put, libpmix), pmix_status_t, (pmix_scope_t, Ptr{Cchar}, Ptr{pmix_value_t}), scope, key, val)
end

function PMIx_Commit()
    ccall((:PMIx_Commit, libpmix), pmix_status_t, ())
end

function PMIx_Fence(procs, nprocs, info, ninfo)
    ccall((:PMIx_Fence, libpmix), pmix_status_t, (Ptr{pmix_proc_t}, Csize_t, Ptr{pmix_info_t}, Csize_t), procs, nprocs, info, ninfo)
end

function PMIx_Fence_nb(procs, nprocs, info, ninfo, cbfunc, cbdata)
    ccall((:PMIx_Fence_nb, libpmix), pmix_status_t, (Ptr{pmix_proc_t}, Csize_t, Ptr{pmix_info_t}, Csize_t, pmix_op_cbfunc_t, Ptr{Cvoid}), procs, nprocs, info, ninfo, cbfunc, cbdata)
end

function PMIx_Get(proc, key, info, ninfo, val)
    ccall((:PMIx_Get, libpmix), pmix_status_t, (Ptr{pmix_proc_t}, Ptr{Cchar}, Ptr{pmix_info_t}, Csize_t, Ptr{Ptr{pmix_value_t}}), proc, key, info, ninfo, val)
end

function PMIx_Get_nb(proc, key, info, ninfo, cbfunc, cbdata)
    ccall((:PMIx_Get_nb, libpmix), pmix_status_t, (Ptr{pmix_proc_t}, Ptr{Cchar}, Ptr{pmix_info_t}, Csize_t, pmix_value_cbfunc_t, Ptr{Cvoid}), proc, key, info, ninfo, cbfunc, cbdata)
end

function PMIx_Publish(info, ninfo)
    ccall((:PMIx_Publish, libpmix), pmix_status_t, (Ptr{pmix_info_t}, Csize_t), info, ninfo)
end

function PMIx_Publish_nb(info, ninfo, cbfunc, cbdata)
    ccall((:PMIx_Publish_nb, libpmix), pmix_status_t, (Ptr{pmix_info_t}, Csize_t, pmix_op_cbfunc_t, Ptr{Cvoid}), info, ninfo, cbfunc, cbdata)
end

function PMIx_Lookup(data, ndata, info, ninfo)
    ccall((:PMIx_Lookup, libpmix), pmix_status_t, (Ptr{pmix_pdata_t}, Csize_t, Ptr{pmix_info_t}, Csize_t), data, ndata, info, ninfo)
end

function PMIx_Lookup_nb(keys, info, ninfo, cbfunc, cbdata)
    ccall((:PMIx_Lookup_nb, libpmix), pmix_status_t, (Ptr{Ptr{Cchar}}, Ptr{pmix_info_t}, Csize_t, pmix_lookup_cbfunc_t, Ptr{Cvoid}), keys, info, ninfo, cbfunc, cbdata)
end

function PMIx_Unpublish(keys, info, ninfo)
    ccall((:PMIx_Unpublish, libpmix), pmix_status_t, (Ptr{Ptr{Cchar}}, Ptr{pmix_info_t}, Csize_t), keys, info, ninfo)
end

function PMIx_Unpublish_nb(keys, info, ninfo, cbfunc, cbdata)
    ccall((:PMIx_Unpublish_nb, libpmix), pmix_status_t, (Ptr{Ptr{Cchar}}, Ptr{pmix_info_t}, Csize_t, pmix_op_cbfunc_t, Ptr{Cvoid}), keys, info, ninfo, cbfunc, cbdata)
end

function PMIx_Spawn(job_info, ninfo, apps, napps, nspace)
    ccall((:PMIx_Spawn, libpmix), pmix_status_t, (Ptr{pmix_info_t}, Csize_t, Ptr{pmix_app_t}, Csize_t, Ptr{Cchar}), job_info, ninfo, apps, napps, nspace)
end

function PMIx_Spawn_nb(job_info, ninfo, apps, napps, cbfunc, cbdata)
    ccall((:PMIx_Spawn_nb, libpmix), pmix_status_t, (Ptr{pmix_info_t}, Csize_t, Ptr{pmix_app_t}, Csize_t, pmix_spawn_cbfunc_t, Ptr{Cvoid}), job_info, ninfo, apps, napps, cbfunc, cbdata)
end

function PMIx_Connect(procs, nprocs, info, ninfo)
    ccall((:PMIx_Connect, libpmix), pmix_status_t, (Ptr{pmix_proc_t}, Csize_t, Ptr{pmix_info_t}, Csize_t), procs, nprocs, info, ninfo)
end

function PMIx_Connect_nb(procs, nprocs, info, ninfo, cbfunc, cbdata)
    ccall((:PMIx_Connect_nb, libpmix), pmix_status_t, (Ptr{pmix_proc_t}, Csize_t, Ptr{pmix_info_t}, Csize_t, pmix_op_cbfunc_t, Ptr{Cvoid}), procs, nprocs, info, ninfo, cbfunc, cbdata)
end

function PMIx_Disconnect(procs, nprocs, info, ninfo)
    ccall((:PMIx_Disconnect, libpmix), pmix_status_t, (Ptr{pmix_proc_t}, Csize_t, Ptr{pmix_info_t}, Csize_t), procs, nprocs, info, ninfo)
end

function PMIx_Disconnect_nb(ranges, nprocs, info, ninfo, cbfunc, cbdata)
    ccall((:PMIx_Disconnect_nb, libpmix), pmix_status_t, (Ptr{pmix_proc_t}, Csize_t, Ptr{pmix_info_t}, Csize_t, pmix_op_cbfunc_t, Ptr{Cvoid}), ranges, nprocs, info, ninfo, cbfunc, cbdata)
end

function PMIx_Resolve_peers(nodename, nspace, procs, nprocs)
    ccall((:PMIx_Resolve_peers, libpmix), pmix_status_t, (Ptr{Cchar}, Ptr{Cchar}, Ptr{Ptr{pmix_proc_t}}, Ptr{Csize_t}), nodename, nspace, procs, nprocs)
end

function PMIx_Resolve_nodes(nspace, nodelist)
    ccall((:PMIx_Resolve_nodes, libpmix), pmix_status_t, (Ptr{Cchar}, Ptr{Ptr{Cchar}}), nspace, nodelist)
end

function PMIx_Query_info(queries, nqueries, results, nresults)
    ccall((:PMIx_Query_info, libpmix), pmix_status_t, (Ptr{pmix_query_t}, Csize_t, Ptr{Ptr{pmix_info_t}}, Ptr{Csize_t}), queries, nqueries, results, nresults)
end

function PMIx_Query_info_nb(queries, nqueries, cbfunc, cbdata)
    ccall((:PMIx_Query_info_nb, libpmix), pmix_status_t, (Ptr{pmix_query_t}, Csize_t, pmix_info_cbfunc_t, Ptr{Cvoid}), queries, nqueries, cbfunc, cbdata)
end

function PMIx_Log(data, ndata, directives, ndirs)
    ccall((:PMIx_Log, libpmix), pmix_status_t, (Ptr{pmix_info_t}, Csize_t, Ptr{pmix_info_t}, Csize_t), data, ndata, directives, ndirs)
end

function PMIx_Log_nb(data, ndata, directives, ndirs, cbfunc, cbdata)
    ccall((:PMIx_Log_nb, libpmix), pmix_status_t, (Ptr{pmix_info_t}, Csize_t, Ptr{pmix_info_t}, Csize_t, pmix_op_cbfunc_t, Ptr{Cvoid}), data, ndata, directives, ndirs, cbfunc, cbdata)
end

function PMIx_Allocation_request(directive, info, ninfo, results, nresults)
    ccall((:PMIx_Allocation_request, libpmix), pmix_status_t, (pmix_alloc_directive_t, Ptr{pmix_info_t}, Csize_t, Ptr{Ptr{pmix_info_t}}, Ptr{Csize_t}), directive, info, ninfo, results, nresults)
end

function PMIx_Allocation_request_nb(directive, info, ninfo, cbfunc, cbdata)
    ccall((:PMIx_Allocation_request_nb, libpmix), pmix_status_t, (pmix_alloc_directive_t, Ptr{pmix_info_t}, Csize_t, pmix_info_cbfunc_t, Ptr{Cvoid}), directive, info, ninfo, cbfunc, cbdata)
end

function PMIx_Job_control(targets, ntargets, directives, ndirs, results, nresults)
    ccall((:PMIx_Job_control, libpmix), pmix_status_t, (Ptr{pmix_proc_t}, Csize_t, Ptr{pmix_info_t}, Csize_t, Ptr{Ptr{pmix_info_t}}, Ptr{Csize_t}), targets, ntargets, directives, ndirs, results, nresults)
end

function PMIx_Job_control_nb(targets, ntargets, directives, ndirs, cbfunc, cbdata)
    ccall((:PMIx_Job_control_nb, libpmix), pmix_status_t, (Ptr{pmix_proc_t}, Csize_t, Ptr{pmix_info_t}, Csize_t, pmix_info_cbfunc_t, Ptr{Cvoid}), targets, ntargets, directives, ndirs, cbfunc, cbdata)
end

function PMIx_Process_monitor(monitor, error, directives, ndirs, results, nresults)
    ccall((:PMIx_Process_monitor, libpmix), pmix_status_t, (Ptr{pmix_info_t}, pmix_status_t, Ptr{pmix_info_t}, Csize_t, Ptr{Ptr{pmix_info_t}}, Ptr{Csize_t}), monitor, error, directives, ndirs, results, nresults)
end

function PMIx_Get_credential(info, ninfo, credential)
    ccall((:PMIx_Get_credential, libpmix), pmix_status_t, (Ptr{pmix_info_t}, Csize_t, Ptr{pmix_byte_object_t}), info, ninfo, credential)
end

function PMIx_Get_credential_nb(info, ninfo, cbfunc, cbdata)
    ccall((:PMIx_Get_credential_nb, libpmix), pmix_status_t, (Ptr{pmix_info_t}, Csize_t, pmix_credential_cbfunc_t, Ptr{Cvoid}), info, ninfo, cbfunc, cbdata)
end

function PMIx_Validate_credential(cred, info, ninfo, results, nresults)
    ccall((:PMIx_Validate_credential, libpmix), pmix_status_t, (Ptr{pmix_byte_object_t}, Ptr{pmix_info_t}, Csize_t, Ptr{Ptr{pmix_info_t}}, Ptr{Csize_t}), cred, info, ninfo, results, nresults)
end

function PMIx_Validate_credential_nb(cred, info, ninfo, cbfunc, cbdata)
    ccall((:PMIx_Validate_credential_nb, libpmix), pmix_status_t, (Ptr{pmix_byte_object_t}, Ptr{pmix_info_t}, Csize_t, pmix_validation_cbfunc_t, Ptr{Cvoid}), cred, info, ninfo, cbfunc, cbdata)
end

function PMIx_Group_construct(grp, procs, nprocs, directives, ndirs, results, nresults)
    ccall((:PMIx_Group_construct, libpmix), pmix_status_t, (Ptr{Cchar}, Ptr{pmix_proc_t}, Csize_t, Ptr{pmix_info_t}, Csize_t, Ptr{Ptr{pmix_info_t}}, Ptr{Csize_t}), grp, procs, nprocs, directives, ndirs, results, nresults)
end

function PMIx_Group_construct_nb(grp, procs, nprocs, info, ninfo, cbfunc, cbdata)
    ccall((:PMIx_Group_construct_nb, libpmix), pmix_status_t, (Ptr{Cchar}, Ptr{pmix_proc_t}, Csize_t, Ptr{pmix_info_t}, Csize_t, pmix_info_cbfunc_t, Ptr{Cvoid}), grp, procs, nprocs, info, ninfo, cbfunc, cbdata)
end

function PMIx_Group_invite(grp, procs, nprocs, info, ninfo, results, nresult)
    ccall((:PMIx_Group_invite, libpmix), pmix_status_t, (Ptr{Cchar}, Ptr{pmix_proc_t}, Csize_t, Ptr{pmix_info_t}, Csize_t, Ptr{Ptr{pmix_info_t}}, Ptr{Csize_t}), grp, procs, nprocs, info, ninfo, results, nresult)
end

function PMIx_Group_invite_nb(grp, procs, nprocs, info, ninfo, cbfunc, cbdata)
    ccall((:PMIx_Group_invite_nb, libpmix), pmix_status_t, (Ptr{Cchar}, Ptr{pmix_proc_t}, Csize_t, Ptr{pmix_info_t}, Csize_t, pmix_info_cbfunc_t, Ptr{Cvoid}), grp, procs, nprocs, info, ninfo, cbfunc, cbdata)
end

function PMIx_Group_join(grp, leader, opt, info, ninfo, results, nresult)
    ccall((:PMIx_Group_join, libpmix), pmix_status_t, (Ptr{Cchar}, Ptr{pmix_proc_t}, pmix_group_opt_t, Ptr{pmix_info_t}, Csize_t, Ptr{Ptr{pmix_info_t}}, Ptr{Csize_t}), grp, leader, opt, info, ninfo, results, nresult)
end

function PMIx_Group_join_nb(grp, leader, opt, info, ninfo, cbfunc, cbdata)
    ccall((:PMIx_Group_join_nb, libpmix), pmix_status_t, (Ptr{Cchar}, Ptr{pmix_proc_t}, pmix_group_opt_t, Ptr{pmix_info_t}, Csize_t, pmix_info_cbfunc_t, Ptr{Cvoid}), grp, leader, opt, info, ninfo, cbfunc, cbdata)
end

function PMIx_Group_leave(grp, info, ninfo)
    ccall((:PMIx_Group_leave, libpmix), pmix_status_t, (Ptr{Cchar}, Ptr{pmix_info_t}, Csize_t), grp, info, ninfo)
end

function PMIx_Group_leave_nb(grp, info, ninfo, cbfunc, cbdata)
    ccall((:PMIx_Group_leave_nb, libpmix), pmix_status_t, (Ptr{Cchar}, Ptr{pmix_info_t}, Csize_t, pmix_op_cbfunc_t, Ptr{Cvoid}), grp, info, ninfo, cbfunc, cbdata)
end

function PMIx_Group_destruct(grp, info, ninfo)
    ccall((:PMIx_Group_destruct, libpmix), pmix_status_t, (Ptr{Cchar}, Ptr{pmix_info_t}, Csize_t), grp, info, ninfo)
end

function PMIx_Group_destruct_nb(grp, info, ninfo, cbfunc, cbdata)
    ccall((:PMIx_Group_destruct_nb, libpmix), pmix_status_t, (Ptr{Cchar}, Ptr{pmix_info_t}, Csize_t, pmix_op_cbfunc_t, Ptr{Cvoid}), grp, info, ninfo, cbfunc, cbdata)
end

function PMIx_Register_event_handler(codes, ncodes, info, ninfo, evhdlr, cbfunc, cbdata)
    ccall((:PMIx_Register_event_handler, libpmix), pmix_status_t, (Ptr{pmix_status_t}, Csize_t, Ptr{pmix_info_t}, Csize_t, pmix_notification_fn_t, pmix_hdlr_reg_cbfunc_t, Ptr{Cvoid}), codes, ncodes, info, ninfo, evhdlr, cbfunc, cbdata)
end

function PMIx_Deregister_event_handler(evhdlr_ref, cbfunc, cbdata)
    ccall((:PMIx_Deregister_event_handler, libpmix), pmix_status_t, (Csize_t, pmix_op_cbfunc_t, Ptr{Cvoid}), evhdlr_ref, cbfunc, cbdata)
end

function PMIx_Notify_event(status, source, range, info, ninfo, cbfunc, cbdata)
    ccall((:PMIx_Notify_event, libpmix), pmix_status_t, (pmix_status_t, Ptr{pmix_proc_t}, pmix_data_range_t, Ptr{pmix_info_t}, Csize_t, pmix_op_cbfunc_t, Ptr{Cvoid}), status, source, range, info, ninfo, cbfunc, cbdata)
end

function PMIx_Fabric_register(fabric, directives, ndirs)
    ccall((:PMIx_Fabric_register, libpmix), pmix_status_t, (Ptr{pmix_fabric_t}, Ptr{pmix_info_t}, Csize_t), fabric, directives, ndirs)
end

function PMIx_Fabric_register_nb(fabric, directives, ndirs, cbfunc, cbdata)
    ccall((:PMIx_Fabric_register_nb, libpmix), pmix_status_t, (Ptr{pmix_fabric_t}, Ptr{pmix_info_t}, Csize_t, pmix_op_cbfunc_t, Ptr{Cvoid}), fabric, directives, ndirs, cbfunc, cbdata)
end

function PMIx_Fabric_update(fabric)
    ccall((:PMIx_Fabric_update, libpmix), pmix_status_t, (Ptr{pmix_fabric_t},), fabric)
end

function PMIx_Fabric_update_nb(fabric, cbfunc, cbdata)
    ccall((:PMIx_Fabric_update_nb, libpmix), pmix_status_t, (Ptr{pmix_fabric_t}, pmix_op_cbfunc_t, Ptr{Cvoid}), fabric, cbfunc, cbdata)
end

function PMIx_Fabric_deregister(fabric)
    ccall((:PMIx_Fabric_deregister, libpmix), pmix_status_t, (Ptr{pmix_fabric_t},), fabric)
end

function PMIx_Fabric_deregister_nb(fabric, cbfunc, cbdata)
    ccall((:PMIx_Fabric_deregister_nb, libpmix), pmix_status_t, (Ptr{pmix_fabric_t}, pmix_op_cbfunc_t, Ptr{Cvoid}), fabric, cbfunc, cbdata)
end

function PMIx_Compute_distances(topo, cpuset, info, ninfo, distances, ndist)
    ccall((:PMIx_Compute_distances, libpmix), pmix_status_t, (Ptr{pmix_topology_t}, Ptr{pmix_cpuset_t}, Ptr{pmix_info_t}, Csize_t, Ptr{Ptr{pmix_device_distance_t}}, Ptr{Csize_t}), topo, cpuset, info, ninfo, distances, ndist)
end

function PMIx_Compute_distances_nb(topo, cpuset, info, ninfo, cbfunc, cbdata)
    ccall((:PMIx_Compute_distances_nb, libpmix), pmix_status_t, (Ptr{pmix_topology_t}, Ptr{pmix_cpuset_t}, Ptr{pmix_info_t}, Csize_t, pmix_device_dist_cbfunc_t, Ptr{Cvoid}), topo, cpuset, info, ninfo, cbfunc, cbdata)
end

function PMIx_Load_topology(topo)
    ccall((:PMIx_Load_topology, libpmix), pmix_status_t, (Ptr{pmix_topology_t},), topo)
end

function PMIx_Parse_cpuset_string(cpuset_string, cpuset)
    ccall((:PMIx_Parse_cpuset_string, libpmix), pmix_status_t, (Ptr{Cchar}, Ptr{pmix_cpuset_t}), cpuset_string, cpuset)
end

function PMIx_Get_cpuset(cpuset, ref)
    ccall((:PMIx_Get_cpuset, libpmix), pmix_status_t, (Ptr{pmix_cpuset_t}, pmix_bind_envelope_t), cpuset, ref)
end

function PMIx_Get_relative_locality(locality1, locality2, locality)
    ccall((:PMIx_Get_relative_locality, libpmix), pmix_status_t, (Ptr{Cchar}, Ptr{Cchar}, Ptr{pmix_locality_t}), locality1, locality2, locality)
end

function PMIx_Progress()
    ccall((:PMIx_Progress, libpmix), Cvoid, ())
end

function PMIx_Error_string(status)
    ccall((:PMIx_Error_string, libpmix), Ptr{Cchar}, (pmix_status_t,), status)
end

function PMIx_Proc_state_string(state)
    ccall((:PMIx_Proc_state_string, libpmix), Ptr{Cchar}, (pmix_proc_state_t,), state)
end

function PMIx_Scope_string(scope)
    ccall((:PMIx_Scope_string, libpmix), Ptr{Cchar}, (pmix_scope_t,), scope)
end

function PMIx_Persistence_string(persist)
    ccall((:PMIx_Persistence_string, libpmix), Ptr{Cchar}, (pmix_persistence_t,), persist)
end

function PMIx_Data_range_string(range)
    ccall((:PMIx_Data_range_string, libpmix), Ptr{Cchar}, (pmix_data_range_t,), range)
end

function PMIx_Info_directives_string(directives)
    ccall((:PMIx_Info_directives_string, libpmix), Ptr{Cchar}, (pmix_info_directives_t,), directives)
end

function PMIx_Data_type_string(type)
    ccall((:PMIx_Data_type_string, libpmix), Ptr{Cchar}, (pmix_data_type_t,), type)
end

function PMIx_Alloc_directive_string(directive)
    ccall((:PMIx_Alloc_directive_string, libpmix), Ptr{Cchar}, (pmix_alloc_directive_t,), directive)
end

function PMIx_IOF_channel_string(channel)
    ccall((:PMIx_IOF_channel_string, libpmix), Ptr{Cchar}, (pmix_iof_channel_t,), channel)
end

function PMIx_Job_state_string(state)
    ccall((:PMIx_Job_state_string, libpmix), Ptr{Cchar}, (pmix_job_state_t,), state)
end

function PMIx_Get_attribute_string(attribute)
    ccall((:PMIx_Get_attribute_string, libpmix), Ptr{Cchar}, (Ptr{Cchar},), attribute)
end

function PMIx_Get_attribute_name(attrstring)
    ccall((:PMIx_Get_attribute_name, libpmix), Ptr{Cchar}, (Ptr{Cchar},), attrstring)
end

function PMIx_Link_state_string(state)
    ccall((:PMIx_Link_state_string, libpmix), Ptr{Cchar}, (pmix_link_state_t,), state)
end

function PMIx_Device_type_string(type)
    ccall((:PMIx_Device_type_string, libpmix), Ptr{Cchar}, (pmix_device_type_t,), type)
end

function PMIx_Get_version()
    ccall((:PMIx_Get_version, libpmix), Ptr{Cchar}, ())
end

function PMIx_Store_internal(proc, key, val)
    ccall((:PMIx_Store_internal, libpmix), pmix_status_t, (Ptr{pmix_proc_t}, Ptr{Cchar}, Ptr{pmix_value_t}), proc, key, val)
end

function PMIx_Data_pack(target, buffer, src, num_vals, type)
    ccall((:PMIx_Data_pack, libpmix), pmix_status_t, (Ptr{pmix_proc_t}, Ptr{pmix_data_buffer_t}, Ptr{Cvoid}, Int32, pmix_data_type_t), target, buffer, src, num_vals, type)
end

function PMIx_Data_unpack(source, buffer, dest, max_num_values, type)
    ccall((:PMIx_Data_unpack, libpmix), pmix_status_t, (Ptr{pmix_proc_t}, Ptr{pmix_data_buffer_t}, Ptr{Cvoid}, Ptr{Int32}, pmix_data_type_t), source, buffer, dest, max_num_values, type)
end

function PMIx_Data_copy(dest, src, type)
    ccall((:PMIx_Data_copy, libpmix), pmix_status_t, (Ptr{Ptr{Cvoid}}, Ptr{Cvoid}, pmix_data_type_t), dest, src, type)
end

function PMIx_Data_print(output, prefix, src, type)
    ccall((:PMIx_Data_print, libpmix), pmix_status_t, (Ptr{Ptr{Cchar}}, Ptr{Cchar}, Ptr{Cvoid}, pmix_data_type_t), output, prefix, src, type)
end

function PMIx_Data_copy_payload(dest, src)
    ccall((:PMIx_Data_copy_payload, libpmix), pmix_status_t, (Ptr{pmix_data_buffer_t}, Ptr{pmix_data_buffer_t}), dest, src)
end

function PMIx_Data_embed(buffer, payload)
    ccall((:PMIx_Data_embed, libpmix), pmix_status_t, (Ptr{pmix_data_buffer_t}, Ptr{pmix_byte_object_t}), buffer, payload)
end

function PMIx_Data_compress(inbytes, size, outbytes, nbytes)
    ccall((:PMIx_Data_compress, libpmix), Bool, (Ptr{UInt8}, Csize_t, Ptr{Ptr{UInt8}}, Ptr{Csize_t}), inbytes, size, outbytes, nbytes)
end

function PMIx_Data_decompress(inbytes, size, outbytes, nbytes)
    ccall((:PMIx_Data_decompress, libpmix), Bool, (Ptr{UInt8}, Csize_t, Ptr{Ptr{UInt8}}, Ptr{Csize_t}), inbytes, size, outbytes, nbytes)
end

const PMIX_HAVE_VISIBILITY = 1

const PMIX_VERSION_MAJOR = Clong(4)

const PMIX_VERSION_MINOR = Clong(1)

const PMIX_VERSION_RELEASE = Clong(0)

const PMIX_NUMERIC_VERSION = 0x00040100

const PMIX_MAX_NSLEN = 255

const PMIX_MAX_KEYLEN = 511

const PMIX_RANK_UNDEF = UINT32_MAX

const PMIX_RANK_WILDCARD = UINT32_MAX - 1

const PMIX_RANK_LOCAL_NODE = UINT32_MAX - 2

const PMIX_RANK_LOCAL_PEERS = UINT32_MAX - 4

const PMIX_RANK_INVALID = UINT32_MAX - 3

const PMIX_RANK_VALID = UINT32_MAX - 50

const PMIX_APP_WILDCARD = UINT32_MAX

const PMIX_LAUNCHER_RNDZ_URI = "PMIX_LAUNCHER_RNDZ_URI"

const PMIX_LAUNCHER_RNDZ_FILE = "PMIX_LAUNCHER_RNDZ_FILE"

const PMIX_KEEPALIVE_PIPE = "PMIX_KEEPALIVE_PIPE"

const PMIX_ATTR_UNDEF = "pmix.undef"

const PMIX_EXTERNAL_PROGRESS = "pmix.evext"

const PMIX_SERVER_TOOL_SUPPORT = "pmix.srvr.tool"

const PMIX_SERVER_REMOTE_CONNECTIONS = "pmix.srvr.remote"

const PMIX_SERVER_SYSTEM_SUPPORT = "pmix.srvr.sys"

const PMIX_SERVER_SESSION_SUPPORT = "pmix.srvr.sess"

const PMIX_SERVER_TMPDIR = "pmix.srvr.tmpdir"

const PMIX_SYSTEM_TMPDIR = "pmix.sys.tmpdir"

const PMIX_SERVER_SHARE_TOPOLOGY = "pmix.srvr.share"

const PMIX_SERVER_ENABLE_MONITORING = "pmix.srv.monitor"

const PMIX_SERVER_NSPACE = "pmix.srv.nspace"

const PMIX_SERVER_RANK = "pmix.srv.rank"

const PMIX_SERVER_GATEWAY = "pmix.srv.gway"

const PMIX_SERVER_SCHEDULER = "pmix.srv.sched"

const PMIX_SERVER_START_TIME = "pmix.srv.strtime"

const PMIX_HOMOGENEOUS_SYSTEM = "pmix.homo"

const PMIX_TOOL_NSPACE = "pmix.tool.nspace"

const PMIX_TOOL_RANK = "pmix.tool.rank"

const PMIX_SERVER_PIDINFO = "pmix.srvr.pidinfo"

const PMIX_CONNECT_TO_SYSTEM = "pmix.cnct.sys"

const PMIX_CONNECT_SYSTEM_FIRST = "pmix.cnct.sys.first"

const PMIX_SERVER_URI = "pmix.srvr.uri"

const PMIX_SERVER_HOSTNAME = "pmix.srvr.host"

const PMIX_CONNECT_MAX_RETRIES = "pmix.tool.mretries"

const PMIX_CONNECT_RETRY_DELAY = "pmix.tool.retry"

const PMIX_TOOL_DO_NOT_CONNECT = "pmix.tool.nocon"

const PMIX_TOOL_CONNECT_OPTIONAL = "pmix.tool.conopt"

const PMIX_LAUNCHER = "pmix.tool.launcher"

const PMIX_LAUNCHER_RENDEZVOUS_FILE = "pmix.tool.lncrnd"

const PMIX_TOOL_ATTACHMENT_FILE = "pmix.tool.attach"

const PMIX_PRIMARY_SERVER = "pmix.pri.srvr"

const PMIX_NOHUP = "pmix.nohup"

const PMIX_LAUNCHER_DAEMON = "pmix.lnch.dmn"

const PMIX_EXEC_AGENT = "pmix.exec.agnt"

const PMIX_LAUNCH_DIRECTIVES = "pmix.lnch.dirs"

const PMIX_USERID = "pmix.euid"

const PMIX_GRPID = "pmix.egid"

const PMIX_VERSION_INFO = "pmix.version"

const PMIX_REQUESTOR_IS_TOOL = "pmix.req.tool"

const PMIX_REQUESTOR_IS_CLIENT = "pmix.req.client"

const PMIX_PSET_NAME = "pmix.pset.nm"

const PMIX_PSET_NAMES = "pmix.pset.nms"

const PMIX_PSET_MEMBERS = "pmix.pset.mems"

const PMIX_REINCARNATION = "pmix.reinc"

const PMIX_PROGRAMMING_MODEL = "pmix.pgm.model"

const PMIX_MODEL_LIBRARY_NAME = "pmix.mdl.name"

const PMIX_MODEL_LIBRARY_VERSION = "pmix.mld.vrs"

const PMIX_THREADING_MODEL = "pmix.threads"

const PMIX_MODEL_NUM_THREADS = "pmix.mdl.nthrds"

const PMIX_MODEL_NUM_CPUS = "pmix.mdl.ncpu"

const PMIX_MODEL_CPU_TYPE = "pmix.mdl.cputype"

const PMIX_MODEL_PHASE_NAME = "pmix.mdl.phase"

const PMIX_MODEL_PHASE_TYPE = "pmix.mdl.ptype"

const PMIX_MODEL_AFFINITY_POLICY = "pmix.mdl.tap"

const PMIX_USOCK_DISABLE = "pmix.usock.disable"

const PMIX_SOCKET_MODE = "pmix.sockmode"

const PMIX_SINGLE_LISTENER = "pmix.sing.listnr"

const PMIX_TCP_REPORT_URI = "pmix.tcp.repuri"

const PMIX_TCP_URI = "pmix.tcp.uri"

const PMIX_TCP_IF_INCLUDE = "pmix.tcp.ifinclude"

const PMIX_TCP_IF_EXCLUDE = "pmix.tcp.ifexclude"

const PMIX_TCP_IPV4_PORT = "pmix.tcp.ipv4"

const PMIX_TCP_IPV6_PORT = "pmix.tcp.ipv6"

const PMIX_TCP_DISABLE_IPV4 = "pmix.tcp.disipv4"

const PMIX_TCP_DISABLE_IPV6 = "pmix.tcp.disipv6"

const PMIX_CPUSET = "pmix.cpuset"

const PMIX_CPUSET_BITMAP = "pmix.bitmap"

const PMIX_CREDENTIAL = "pmix.cred"

const PMIX_SPAWNED = "pmix.spawned"

const PMIX_NODE_OVERSUBSCRIBED = "pmix.ndosub"

const PMIX_TMPDIR = "pmix.tmpdir"

const PMIX_NSDIR = "pmix.nsdir"

const PMIX_PROCDIR = "pmix.pdir"

const PMIX_TDIR_RMCLEAN = "pmix.tdir.rmclean"

const PMIX_CLUSTER_ID = "pmix.clid"

const PMIX_PROCID = "pmix.procid"

const PMIX_NSPACE = "pmix.nspace"

const PMIX_JOBID = "pmix.jobid"

const PMIX_APPNUM = "pmix.appnum"

const PMIX_RANK = "pmix.rank"

const PMIX_GLOBAL_RANK = "pmix.grank"

const PMIX_APP_RANK = "pmix.apprank"

const PMIX_NPROC_OFFSET = "pmix.offset"

const PMIX_LOCAL_RANK = "pmix.lrank"

const PMIX_NODE_RANK = "pmix.nrank"

const PMIX_PACKAGE_RANK = "pmix.pkgrank"

const PMIX_LOCALLDR = "pmix.lldr"

const PMIX_APPLDR = "pmix.aldr"

const PMIX_PROC_PID = "pmix.ppid"

const PMIX_SESSION_ID = "pmix.session.id"

const PMIX_NODE_LIST = "pmix.nlist"

const PMIX_ALLOCATED_NODELIST = "pmix.alist"

const PMIX_HOSTNAME = "pmix.hname"

const PMIX_HOSTNAME_ALIASES = "pmix.alias"

const PMIX_HOSTNAME_KEEP_FQDN = "pmix.fqdn"

const PMIX_NODEID = "pmix.nodeid"

const PMIX_LOCAL_PEERS = "pmix.lpeers"

const PMIX_LOCAL_PROCS = "pmix.lprocs"

const PMIX_LOCAL_CPUSETS = "pmix.lcpus"

const PMIX_PARENT_ID = "pmix.parent"

const PMIX_EXIT_CODE = "pmix.exit.code"

const PMIX_UNIV_SIZE = "pmix.univ.size"

const PMIX_JOB_SIZE = "pmix.job.size"

const PMIX_JOB_NUM_APPS = "pmix.job.napps"

const PMIX_APP_SIZE = "pmix.app.size"

const PMIX_LOCAL_SIZE = "pmix.local.size"

const PMIX_NODE_SIZE = "pmix.node.size"

const PMIX_MAX_PROCS = "pmix.max.size"

const PMIX_NUM_SLOTS = "pmix.num.slots"

const PMIX_NUM_NODES = "pmix.num.nodes"

const PMIX_NUM_ALLOCATED_NODES = "pmix.num.anodes"

const PMIX_AVAIL_PHYS_MEMORY = "pmix.pmem"

const PMIX_DAEMON_MEMORY = "pmix.dmn.mem"

const PMIX_CLIENT_AVG_MEMORY = "pmix.cl.mem.avg"

const PMIX_TOPOLOGY2 = "pmix.topo2"

const PMIX_LOCALITY_STRING = "pmix.locstr"

const PMIX_COLLECT_DATA = "pmix.collect"

const PMIX_ALL_CLONES_PARTICIPATE = "pmix.clone.part"

const PMIX_COLLECT_GENERATED_JOB_INFO = "pmix.collect.gen"

const PMIX_TIMEOUT = "pmix.timeout"

const PMIX_IMMEDIATE = "pmix.immediate"

const PMIX_WAIT = "pmix.wait"

const PMIX_NOTIFY_COMPLETION = "pmix.notecomp"

const PMIX_RANGE = "pmix.range"

const PMIX_PERSISTENCE = "pmix.persist"

const PMIX_DATA_SCOPE = "pmix.scope"

const PMIX_OPTIONAL = "pmix.optional"

const PMIX_GET_STATIC_VALUES = "pmix.get.static"

const PMIX_GET_POINTER_VALUES = "pmix.get.pntrs"

const PMIX_EMBED_BARRIER = "pmix.embed.barrier"

const PMIX_JOB_TERM_STATUS = "pmix.job.term.status"

const PMIX_PROC_TERM_STATUS = "pmix.proc.term.status"

const PMIX_PROC_STATE_STATUS = "pmix.proc.state"

const PMIX_GET_REFRESH_CACHE = "pmix.get.refresh"

const PMIX_ACCESS_PERMISSIONS = "pmix.aperms"

const PMIX_ACCESS_USERIDS = "pmix.auids"

const PMIX_ACCESS_GRPIDS = "pmix.agids"

const PMIX_WAIT_FOR_CONNECTION = "pmix.wait.conn"

const PMIX_REGISTER_NODATA = "pmix.reg.nodata"

const PMIX_NODE_MAP = "pmix.nmap"

const PMIX_NODE_MAP_RAW = "pmix.nmap.raw"

const PMIX_PROC_MAP = "pmix.pmap"

const PMIX_PROC_MAP_RAW = "pmix.pmap.raw"

const PMIX_ANL_MAP = "pmix.anlmap"

const PMIX_APP_MAP_TYPE = "pmix.apmap.type"

const PMIX_APP_MAP_REGEX = "pmix.apmap.regex"

const PMIX_REQUIRED_KEY = "pmix.req.key"

const PMIX_EVENT_HDLR_NAME = "pmix.evname"

const PMIX_EVENT_HDLR_FIRST = "pmix.evfirst"

const PMIX_EVENT_HDLR_LAST = "pmix.evlast"

const PMIX_EVENT_HDLR_FIRST_IN_CATEGORY = "pmix.evfirstcat"

const PMIX_EVENT_HDLR_LAST_IN_CATEGORY = "pmix.evlastcat"

const PMIX_EVENT_HDLR_BEFORE = "pmix.evbefore"

const PMIX_EVENT_HDLR_AFTER = "pmix.evafter"

const PMIX_EVENT_HDLR_PREPEND = "pmix.evprepend"

const PMIX_EVENT_HDLR_APPEND = "pmix.evappend"

const PMIX_EVENT_CUSTOM_RANGE = "pmix.evrange"

const PMIX_EVENT_AFFECTED_PROC = "pmix.evproc"

const PMIX_EVENT_AFFECTED_PROCS = "pmix.evaffected"

const PMIX_EVENT_NON_DEFAULT = "pmix.evnondef"

const PMIX_EVENT_RETURN_OBJECT = "pmix.evobject"

const PMIX_EVENT_DO_NOT_CACHE = "pmix.evnocache"

const PMIX_EVENT_SILENT_TERMINATION = "pmix.evsilentterm"

const PMIX_EVENT_PROXY = "pmix.evproxy"

const PMIX_EVENT_TEXT_MESSAGE = "pmix.evtext"

const PMIX_EVENT_TIMESTAMP = "pmix.evtstamp"

const PMIX_EVENT_TERMINATE_SESSION = "pmix.evterm.sess"

const PMIX_EVENT_TERMINATE_JOB = "pmix.evterm.job"

const PMIX_EVENT_TERMINATE_NODE = "pmix.evterm.node"

const PMIX_EVENT_TERMINATE_PROC = "pmix.evterm.proc"

const PMIX_EVENT_ACTION_TIMEOUT = "pmix.evtimeout"

const PMIX_PERSONALITY = "pmix.pers"

const PMIX_HOST = "pmix.host"

const PMIX_HOSTFILE = "pmix.hostfile"

const PMIX_ADD_HOST = "pmix.addhost"

const PMIX_ADD_HOSTFILE = "pmix.addhostfile"

const PMIX_PREFIX = "pmix.prefix"

const PMIX_WDIR = "pmix.wdir"

const PMIX_DISPLAY_MAP = "pmix.dispmap"

const PMIX_PPR = "pmix.ppr"

const PMIX_MAPBY = "pmix.mapby"

const PMIX_RANKBY = "pmix.rankby"

const PMIX_BINDTO = "pmix.bindto"

const PMIX_PRELOAD_BIN = "pmix.preloadbin"

const PMIX_PRELOAD_FILES = "pmix.preloadfiles"

const PMIX_STDIN_TGT = "pmix.stdin"

const PMIX_DEBUGGER_DAEMONS = "pmix.debugger"

const PMIX_COSPAWN_APP = "pmix.cospawn"

const PMIX_SET_SESSION_CWD = "pmix.ssncwd"

const PMIX_INDEX_ARGV = "pmix.indxargv"

const PMIX_CPUS_PER_PROC = "pmix.cpuperproc"

const PMIX_NO_PROCS_ON_HEAD = "pmix.nolocal"

const PMIX_NO_OVERSUBSCRIBE = "pmix.noover"

const PMIX_REPORT_BINDINGS = "pmix.repbind"

const PMIX_CPU_LIST = "pmix.cpulist"

const PMIX_JOB_RECOVERABLE = "pmix.recover"

const PMIX_JOB_CONTINUOUS = "pmix.continuous"

const PMIX_MAX_RESTARTS = "pmix.maxrestarts"

const PMIX_FWD_STDIN = "pmix.fwd.stdin"

const PMIX_FWD_STDOUT = "pmix.fwd.stdout"

const PMIX_FWD_STDERR = "pmix.fwd.stderr"

const PMIX_FWD_STDDIAG = "pmix.fwd.stddiag"

const PMIX_SPAWN_TOOL = "pmix.spwn.tool"

const PMIX_CMD_LINE = "pmix.cmd.line"

const PMIX_FORKEXEC_AGENT = "pmix.fe.agnt"

const PMIX_TIMEOUT_STACKTRACES = "pmix.tim.stack"

const PMIX_TIMEOUT_REPORT_STATE = "pmix.tim.state"

const PMIX_APP_ARGV = "pmix.app.argv"

const PMIX_NOTIFY_JOB_EVENTS = "pmix.note.jev"

const PMIX_NOTIFY_PROC_TERMINATION = "pmix.noteproc"

const PMIX_NOTIFY_PROC_ABNORMAL_TERMINATION = "pmix.noteabproc"

const PMIX_ENVARS_HARVESTED = "pmix.evar.hvstd"

const PMIX_QUERY_SUPPORTED_KEYS = "pmix.qry.keys"

const PMIX_QUERY_NAMESPACES = "pmix.qry.ns"

const PMIX_QUERY_NAMESPACE_INFO = "pmix.qry.nsinfo"

const PMIX_QUERY_JOB_STATUS = "pmix.qry.jst"

const PMIX_QUERY_QUEUE_LIST = "pmix.qry.qlst"

const PMIX_QUERY_QUEUE_STATUS = "pmix.qry.qst"

const PMIX_QUERY_PROC_TABLE = "pmix.qry.ptable"

const PMIX_QUERY_LOCAL_PROC_TABLE = "pmix.qry.lptable"

const PMIX_QUERY_AUTHORIZATIONS = "pmix.qry.auths"

const PMIX_QUERY_SPAWN_SUPPORT = "pmix.qry.spawn"

const PMIX_QUERY_DEBUG_SUPPORT = "pmix.qry.debug"

const PMIX_QUERY_MEMORY_USAGE = "pmix.qry.mem"

const PMIX_QUERY_ALLOC_STATUS = "pmix.query.alloc"

const PMIX_TIME_REMAINING = "pmix.time.remaining"

const PMIX_QUERY_NUM_PSETS = "pmix.qry.psetnum"

const PMIX_QUERY_PSET_NAMES = "pmix.qry.psets"

const PMIX_QUERY_PSET_MEMBERSHIP = "pmix.qry.pmems"

const PMIX_QUERY_NUM_GROUPS = "pmix.qry.pgrpnum"

const PMIX_QUERY_GROUP_NAMES = "pmix.qry.pgrp"

const PMIX_QUERY_GROUP_MEMBERSHIP = "pmix.qry.pgrpmems"

const PMIX_QUERY_ATTRIBUTE_SUPPORT = "pmix.qry.attrs"

const PMIX_CLIENT_FUNCTIONS = "pmix.client.fns"

const PMIX_SERVER_FUNCTIONS = "pmix.srvr.fns"

const PMIX_TOOL_FUNCTIONS = "pmix.tool.fns"

const PMIX_HOST_FUNCTIONS = "pmix.host.fns"

const PMIX_QUERY_AVAIL_SERVERS = "pmix.qry.asrvrs"

const PMIX_QUERY_QUALIFIERS = "pmix.qry.quals"

const PMIX_QUERY_RESULTS = "pmix.qry.res"

const PMIX_QUERY_REFRESH_CACHE = "pmix.qry.rfsh"

const PMIX_QUERY_LOCAL_ONLY = "pmix.qry.local"

const PMIX_QUERY_REPORT_AVG = "pmix.qry.avg"

const PMIX_QUERY_REPORT_MINMAX = "pmix.qry.minmax"

const PMIX_CLIENT_ATTRIBUTES = "pmix.client.attrs"

const PMIX_SERVER_ATTRIBUTES = "pmix.srvr.attrs"

const PMIX_HOST_ATTRIBUTES = "pmix.host.attrs"

const PMIX_TOOL_ATTRIBUTES = "pmix.tool.attrs"

const PMIX_QUERY_SUPPORTED_QUALIFIERS = "pmix.qry.quals"

const PMIX_SESSION_INFO = "pmix.ssn.info"

const PMIX_JOB_INFO = "pmix.job.info"

const PMIX_APP_INFO = "pmix.app.info"

const PMIX_NODE_INFO = "pmix.node.info"

const PMIX_SESSION_INFO_ARRAY = "pmix.ssn.arr"

const PMIX_JOB_INFO_ARRAY = "pmix.job.arr"

const PMIX_APP_INFO_ARRAY = "pmix.app.arr"

const PMIX_PROC_INFO_ARRAY = "pmix.pdata"

const PMIX_NODE_INFO_ARRAY = "pmix.node.arr"

const PMIX_SERVER_INFO_ARRAY = "pmix.srv.arr"

const PMIX_LOG_SOURCE = "pmix.log.source"

const PMIX_LOG_STDERR = "pmix.log.stderr"

const PMIX_LOG_STDOUT = "pmix.log.stdout"

const PMIX_LOG_SYSLOG = "pmix.log.syslog"

const PMIX_LOG_LOCAL_SYSLOG = "pmix.log.lsys"

const PMIX_LOG_GLOBAL_SYSLOG = "pmix.log.gsys"

const PMIX_LOG_SYSLOG_PRI = "pmix.log.syspri"

const PMIX_LOG_TIMESTAMP = "pmix.log.tstmp"

const PMIX_LOG_GENERATE_TIMESTAMP = "pmix.log.gtstmp"

const PMIX_LOG_TAG_OUTPUT = "pmix.log.tag"

const PMIX_LOG_TIMESTAMP_OUTPUT = "pmix.log.tsout"

const PMIX_LOG_XML_OUTPUT = "pmix.log.xml"

const PMIX_LOG_ONCE = "pmix.log.once"

const PMIX_LOG_MSG = "pmix.log.msg"

const PMIX_LOG_EMAIL = "pmix.log.email"

const PMIX_LOG_EMAIL_ADDR = "pmix.log.emaddr"

const PMIX_LOG_EMAIL_SENDER_ADDR = "pmix.log.emfaddr"

const PMIX_LOG_EMAIL_SUBJECT = "pmix.log.emsub"

const PMIX_LOG_EMAIL_MSG = "pmix.log.emmsg"

const PMIX_LOG_EMAIL_SERVER = "pmix.log.esrvr"

const PMIX_LOG_EMAIL_SRVR_PORT = "pmix.log.esrvrprt"

const PMIX_LOG_GLOBAL_DATASTORE = "pmix.log.gstore"

const PMIX_LOG_JOB_RECORD = "pmix.log.jrec"

const PMIX_LOG_PROC_TERMINATION = "pmix.logproc"

const PMIX_LOG_PROC_ABNORMAL_TERMINATION = "pmix.logabproc"

const PMIX_LOG_JOB_EVENTS = "pmix.log.jev"

const PMIX_LOG_COMPLETION = "pmix.logcomp"

const PMIX_DEBUG_STOP_ON_EXEC = "pmix.dbg.exec"

const PMIX_DEBUG_STOP_IN_INIT = "pmix.dbg.init"

const PMIX_DEBUG_STOP_IN_APP = "pmix.dbg.notify"

const PMIX_BREAKPOINT = "pmix.brkpnt"

const PMIX_DEBUG_TARGET = "pmix.dbg.tgt"

const PMIX_DEBUG_DAEMONS_PER_PROC = "pmix.dbg.dpproc"

const PMIX_DEBUG_DAEMONS_PER_NODE = "pmix.dbg.dpnd"

const PMIX_RM_NAME = "pmix.rm.name"

const PMIX_RM_VERSION = "pmix.rm.version"

const PMIX_SET_ENVAR = "pmix.envar.set"

const PMIX_ADD_ENVAR = "pmix.envar.add"

const PMIX_UNSET_ENVAR = "pmix.envar.unset"

const PMIX_PREPEND_ENVAR = "pmix.envar.prepnd"

const PMIX_APPEND_ENVAR = "pmix.envar.appnd"

const PMIX_FIRST_ENVAR = "pmix.envar.first"

const PMIX_ALLOC_REQ_ID = "pmix.alloc.reqid"

const PMIX_ALLOC_ID = "pmix.alloc.id"

const PMIX_ALLOC_NUM_NODES = "pmix.alloc.nnodes"

const PMIX_ALLOC_NODE_LIST = "pmix.alloc.nlist"

const PMIX_ALLOC_NUM_CPUS = "pmix.alloc.ncpus"

const PMIX_ALLOC_NUM_CPU_LIST = "pmix.alloc.ncpulist"

const PMIX_ALLOC_CPU_LIST = "pmix.alloc.cpulist"

const PMIX_ALLOC_MEM_SIZE = "pmix.alloc.msize"

const PMIX_ALLOC_FABRIC = "pmix.alloc.net"

const PMIX_ALLOC_FABRIC_ID = "pmix.alloc.netid"

const PMIX_ALLOC_BANDWIDTH = "pmix.alloc.bw"

const PMIX_ALLOC_FABRIC_QOS = "pmix.alloc.netqos"

const PMIX_ALLOC_TIME = "pmix.alloc.time"

const PMIX_ALLOC_FABRIC_TYPE = "pmix.alloc.nettype"

const PMIX_ALLOC_FABRIC_PLANE = "pmix.alloc.netplane"

const PMIX_ALLOC_FABRIC_ENDPTS = "pmix.alloc.endpts"

const PMIX_ALLOC_FABRIC_ENDPTS_NODE = "pmix.alloc.endpts.nd"

const PMIX_ALLOC_FABRIC_SEC_KEY = "pmix.alloc.nsec"

const PMIX_ALLOC_QUEUE = "pmix.alloc.queue"

const PMIX_JOB_CTRL_ID = "pmix.jctrl.id"

const PMIX_JOB_CTRL_PAUSE = "pmix.jctrl.pause"

const PMIX_JOB_CTRL_RESUME = "pmix.jctrl.resume"

const PMIX_JOB_CTRL_CANCEL = "pmix.jctrl.cancel"

const PMIX_JOB_CTRL_KILL = "pmix.jctrl.kill"

const PMIX_JOB_CTRL_RESTART = "pmix.jctrl.restart"

const PMIX_JOB_CTRL_CHECKPOINT = "pmix.jctrl.ckpt"

const PMIX_JOB_CTRL_CHECKPOINT_EVENT = "pmix.jctrl.ckptev"

const PMIX_JOB_CTRL_CHECKPOINT_SIGNAL = "pmix.jctrl.ckptsig"

const PMIX_JOB_CTRL_CHECKPOINT_TIMEOUT = "pmix.jctrl.ckptsig"

const PMIX_JOB_CTRL_CHECKPOINT_METHOD = "pmix.jctrl.ckmethod"

const PMIX_JOB_CTRL_SIGNAL = "pmix.jctrl.sig"

const PMIX_JOB_CTRL_PROVISION = "pmix.jctrl.pvn"

const PMIX_JOB_CTRL_PROVISION_IMAGE = "pmix.jctrl.pvnimg"

const PMIX_JOB_CTRL_PREEMPTIBLE = "pmix.jctrl.preempt"

const PMIX_JOB_CTRL_TERMINATE = "pmix.jctrl.term"

const PMIX_REGISTER_CLEANUP = "pmix.reg.cleanup"

const PMIX_REGISTER_CLEANUP_DIR = "pmix.reg.cleanupdir"

const PMIX_CLEANUP_RECURSIVE = "pmix.clnup.recurse"

const PMIX_CLEANUP_EMPTY = "pmix.clnup.empty"

const PMIX_CLEANUP_IGNORE = "pmix.clnup.ignore"

const PMIX_CLEANUP_LEAVE_TOPDIR = "pmix.clnup.lvtop"

const PMIX_MONITOR_ID = "pmix.monitor.id"

const PMIX_MONITOR_CANCEL = "pmix.monitor.cancel"

const PMIX_MONITOR_APP_CONTROL = "pmix.monitor.appctrl"

const PMIX_MONITOR_HEARTBEAT = "pmix.monitor.mbeat"

const PMIX_SEND_HEARTBEAT = "pmix.monitor.beat"

const PMIX_MONITOR_HEARTBEAT_TIME = "pmix.monitor.btime"

const PMIX_MONITOR_HEARTBEAT_DROPS = "pmix.monitor.bdrop"

const PMIX_MONITOR_FILE = "pmix.monitor.fmon"

const PMIX_MONITOR_FILE_SIZE = "pmix.monitor.fsize"

const PMIX_MONITOR_FILE_ACCESS = "pmix.monitor.faccess"

const PMIX_MONITOR_FILE_MODIFY = "pmix.monitor.fmod"

const PMIX_MONITOR_FILE_CHECK_TIME = "pmix.monitor.ftime"

const PMIX_MONITOR_FILE_DROPS = "pmix.monitor.fdrop"

const PMIX_CRED_TYPE = "pmix.sec.ctype"

const PMIX_CRYPTO_KEY = "pmix.sec.key"

const PMIX_IOF_CACHE_SIZE = "pmix.iof.csize"

const PMIX_IOF_DROP_OLDEST = "pmix.iof.old"

const PMIX_IOF_DROP_NEWEST = "pmix.iof.new"

const PMIX_IOF_BUFFERING_SIZE = "pmix.iof.bsize"

const PMIX_IOF_BUFFERING_TIME = "pmix.iof.btime"

const PMIX_IOF_COMPLETE = "pmix.iof.cmp"

const PMIX_IOF_PUSH_STDIN = "pmix.iof.stdin"

const PMIX_IOF_TAG_OUTPUT = "pmix.iof.tag"

const PMIX_IOF_RANK_OUTPUT = "pmix.iof.rank"

const PMIX_IOF_TIMESTAMP_OUTPUT = "pmix.iof.ts"

const PMIX_IOF_MERGE_STDERR_STDOUT = "pmix.iof.mrg"

const PMIX_IOF_XML_OUTPUT = "pmix.iof.xml"

const PMIX_IOF_OUTPUT_TO_FILE = "pmix.iof.file"

const PMIX_IOF_FILE_PATTERN = "pmix.iof.fpt"

const PMIX_IOF_OUTPUT_TO_DIRECTORY = "pmix.iof.dir"

const PMIX_IOF_FILE_ONLY = "pmix.iof.fonly"

const PMIX_IOF_COPY = "pmix.iof.cpy"

const PMIX_IOF_REDIRECT = "pmix.iof.redir"

const PMIX_IOF_LOCAL_OUTPUT = "pmix.iof.local"

const PMIX_SETUP_APP_ENVARS = "pmix.setup.env"

const PMIX_SETUP_APP_NONENVARS = "pmix.setup.nenv"

const PMIX_SETUP_APP_ALL = "pmix.setup.all"

const PMIX_GROUP_ID = "pmix.grp.id"

const PMIX_GROUP_LEADER = "pmix.grp.ldr"

const PMIX_GROUP_OPTIONAL = "pmix.grp.opt"

const PMIX_GROUP_NOTIFY_TERMINATION = "pmix.grp.notterm"

const PMIX_GROUP_FT_COLLECTIVE = "pmix.grp.ftcoll"

const PMIX_GROUP_MEMBERSHIP = "pmix.grp.mbrs"

const PMIX_GROUP_ASSIGN_CONTEXT_ID = "pmix.grp.actxid"

const PMIX_GROUP_CONTEXT_ID = "pmix.grp.ctxid"

const PMIX_GROUP_LOCAL_ONLY = "pmix.grp.lcl"

const PMIX_GROUP_ENDPT_DATA = "pmix.grp.endpt"

const PMIX_GROUP_NAMES = "pmix.pgrp.nm"

const PMIX_QUERY_STORAGE_LIST = "pmix.strg.list"

const PMIX_STORAGE_CAPACITY_LIMIT = "pmix.strg.cap"

const PMIX_STORAGE_CAPACITY_FREE = "pmix.strg.free"

const PMIX_STORAGE_CAPACITY_AVAIL = "pmix.strg.avail"

const PMIX_STORAGE_OBJECT_LIMIT = "pmix.strg.obj"

const PMIX_STORAGE_OBJECTS_FREE = "pmix.strg.objf"

const PMIX_STORAGE_OBJECTS_AVAIL = "pmix.strg.obja"

const PMIX_STORAGE_BW = "pmix.strg.bw"

const PMIX_STORAGE_AVAIL_BW = "pmix.strg.availbw"

const PMIX_STORAGE_ID = "pmix.strg.id"

const PMIX_STORAGE_PATH = "pmix.strg.path"

const PMIX_STORAGE_TYPE = "pmix.strg.type"

const PMIX_FABRIC_COST_MATRIX = "pmix.fab.cm"

const PMIX_FABRIC_GROUPS = "pmix.fab.grps"

const PMIX_FABRIC_VENDOR = "pmix.fab.vndr"

const PMIX_FABRIC_IDENTIFIER = "pmix.fab.id"

const PMIX_FABRIC_INDEX = "pmix.fab.idx"

const PMIX_FABRIC_COORDINATES = "pmix.fab.coord"

const PMIX_FABRIC_DEVICE_VENDORID = "pmix.fabdev.vendid"

const PMIX_FABRIC_NUM_DEVICES = "pmix.fab.nverts"

const PMIX_FABRIC_DIMS = "pmix.fab.dims"

const PMIX_FABRIC_PLANE = "pmix.fab.plane"

const PMIX_FABRIC_SWITCH = "pmix.fab.switch"

const PMIX_FABRIC_ENDPT = "pmix.fab.endpt"

const PMIX_FABRIC_SHAPE = "pmix.fab.shape"

const PMIX_FABRIC_SHAPE_STRING = "pmix.fab.shapestr"

const PMIX_SWITCH_PEERS = "pmix.speers"

const PMIX_FABRIC_DEVICE = "pmix.fabdev"

const PMIX_FABRIC_DEVICES = "pmix.fab.devs"

const PMIX_FABRIC_DEVICE_NAME = "pmix.fabdev.nm"

const PMIX_FABRIC_DEVICE_INDEX = "pmix.fabdev.idx"

const PMIX_FABRIC_DEVICE_VENDOR = "pmix.fabdev.vndr"

const PMIX_FABRIC_DEVICE_BUS_TYPE = "pmix.fabdev.btyp"

const PMIX_FABRIC_DEVICE_DRIVER = "pmix.fabdev.driver"

const PMIX_FABRIC_DEVICE_FIRMWARE = "pmix.fabdev.fmwr"

const PMIX_FABRIC_DEVICE_ADDRESS = "pmix.fabdev.addr"

const PMIX_FABRIC_DEVICE_COORDINATES = "pmix.fab.coord"

const PMIX_FABRIC_DEVICE_MTU = "pmix.fabdev.mtu"

const PMIX_FABRIC_DEVICE_SPEED = "pmix.fabdev.speed"

const PMIX_FABRIC_DEVICE_STATE = "pmix.fabdev.state"

const PMIX_FABRIC_DEVICE_TYPE = "pmix.fabdev.type"

const PMIX_FABRIC_DEVICE_PCI_DEVID = "pmix.fabdev.pcidevid"

const PMIX_DEVICE_DISTANCES = "pmix.dev.dist"

const PMIX_DEVICE_TYPE = "pmix.dev.type"

const PMIX_DEVICE_ID = "pmix.dev.id"

const PMIX_MAX_VALUE = "pmix.descr.maxval"

const PMIX_MIN_VALUE = "pmix.descr.minval"

const PMIX_ENUM_VALUE = "pmix.descr.enum"

const PMIX_PROC_STATE_UNDEF = 0

const PMIX_PROC_STATE_PREPPED = 1

const PMIX_PROC_STATE_LAUNCH_UNDERWAY = 2

const PMIX_PROC_STATE_RESTART = 3

const PMIX_PROC_STATE_TERMINATE = 4

const PMIX_PROC_STATE_RUNNING = 5

const PMIX_PROC_STATE_CONNECTED = 6

const PMIX_PROC_STATE_UNTERMINATED = 15

const PMIX_PROC_STATE_TERMINATED = 20

const PMIX_PROC_STATE_ERROR = 50

const PMIX_PROC_STATE_KILLED_BY_CMD = PMIX_PROC_STATE_ERROR + 1

const PMIX_PROC_STATE_ABORTED = PMIX_PROC_STATE_ERROR + 2

const PMIX_PROC_STATE_FAILED_TO_START = PMIX_PROC_STATE_ERROR + 3

const PMIX_PROC_STATE_ABORTED_BY_SIG = PMIX_PROC_STATE_ERROR + 4

const PMIX_PROC_STATE_TERM_WO_SYNC = PMIX_PROC_STATE_ERROR + 5

const PMIX_PROC_STATE_COMM_FAILED = PMIX_PROC_STATE_ERROR + 6

const PMIX_PROC_STATE_SENSOR_BOUND_EXCEEDED = PMIX_PROC_STATE_ERROR + 7

const PMIX_PROC_STATE_CALLED_ABORT = PMIX_PROC_STATE_ERROR + 8

const PMIX_PROC_STATE_HEARTBEAT_FAILED = PMIX_PROC_STATE_ERROR + 9

const PMIX_PROC_STATE_MIGRATING = PMIX_PROC_STATE_ERROR + 10

const PMIX_PROC_STATE_CANNOT_RESTART = PMIX_PROC_STATE_ERROR + 11

const PMIX_PROC_STATE_TERM_NON_ZERO = PMIX_PROC_STATE_ERROR + 12

const PMIX_PROC_STATE_FAILED_TO_LAUNCH = PMIX_PROC_STATE_ERROR + 13

const PMIX_JOB_STATE_UNDEF = 0

const PMIX_JOB_STATE_AWAITING_ALLOC = 1

const PMIX_JOB_STATE_LAUNCH_UNDERWAY = 2

const PMIX_JOB_STATE_RUNNING = 3

const PMIX_JOB_STATE_SUSPENDED = 4

const PMIX_JOB_STATE_CONNECTED = 5

const PMIX_JOB_STATE_UNTERMINATED = 15

const PMIX_JOB_STATE_TERMINATED = 20

const PMIX_JOB_STATE_TERMINATED_WITH_ERROR = 50

const PMIX_SUCCESS = 0

const PMIX_ERROR = -1

const PMIX_ERR_PROC_RESTART = -4

const PMIX_ERR_PROC_CHECKPOINT = -5

const PMIX_ERR_PROC_MIGRATE = -6

const PMIX_ERR_EXISTS = -11

const PMIX_ERR_INVALID_CRED = -12

const PMIX_ERR_WOULD_BLOCK = -15

const PMIX_ERR_UNKNOWN_DATA_TYPE = -16

const PMIX_ERR_TYPE_MISMATCH = -18

const PMIX_ERR_UNPACK_INADEQUATE_SPACE = -19

const PMIX_ERR_UNPACK_FAILURE = -20

const PMIX_ERR_PACK_FAILURE = -21

const PMIX_ERR_NO_PERMISSIONS = -23

const PMIX_ERR_TIMEOUT = -24

const PMIX_ERR_UNREACH = -25

const PMIX_ERR_BAD_PARAM = -27

const PMIX_ERR_RESOURCE_BUSY = -28

const PMIX_ERR_OUT_OF_RESOURCE = -29

const PMIX_ERR_INIT = -31

const PMIX_ERR_NOMEM = -32

const PMIX_ERR_NOT_FOUND = -46

const PMIX_ERR_NOT_SUPPORTED = -47

const PMIX_ERR_PARAM_VALUE_NOT_SUPPORTED = -59

const PMIX_ERR_COMM_FAILURE = -49

const PMIX_ERR_UNPACK_READ_PAST_END_OF_BUFFER = -50

const PMIX_ERR_CONFLICTING_CLEANUP_DIRECTIVES = -51

const PMIX_ERR_PARTIAL_SUCCESS = -52

const PMIX_ERR_DUPLICATE_KEY = -53

const PMIX_ERR_EMPTY = -60

const PMIX_ERR_LOST_CONNECTION = -61

const PMIX_ERR_EXISTS_OUTSIDE_SCOPE = -62

const PMIX_PROCESS_SET_DEFINE = -55

const PMIX_PROCESS_SET_DELETE = -56

const PMIX_DEBUGGER_RELEASE = -3

const PMIX_READY_FOR_DEBUG = -58

const PMIX_QUERY_PARTIAL_SUCCESS = -104

const PMIX_JCTRL_CHECKPOINT = -106

const PMIX_JCTRL_CHECKPOINT_COMPLETE = -107

const PMIX_JCTRL_PREEMPT_ALERT = -108

const PMIX_MONITOR_HEARTBEAT_ALERT = -109

const PMIX_MONITOR_FILE_ALERT = -110

const PMIX_PROC_TERMINATED = -111

const PMIX_ERR_EVENT_REGISTRATION = -144

const PMIX_MODEL_DECLARED = -147

const PMIX_MODEL_RESOURCES = -151

const PMIX_OPENMP_PARALLEL_ENTERED = -152

const PMIX_OPENMP_PARALLEL_EXITED = -153

const PMIX_LAUNCHER_READY = -155

const PMIX_OPERATION_IN_PROGRESS = -156

const PMIX_OPERATION_SUCCEEDED = -157

const PMIX_ERR_INVALID_OPERATION = -158

const PMIX_GROUP_INVITED = -159

const PMIX_GROUP_LEFT = -160

const PMIX_GROUP_INVITE_ACCEPTED = -161

const PMIX_GROUP_INVITE_DECLINED = -162

const PMIX_GROUP_INVITE_FAILED = -163

const PMIX_GROUP_MEMBERSHIP_UPDATE = -164

const PMIX_GROUP_CONSTRUCT_ABORT = -165

const PMIX_GROUP_CONSTRUCT_COMPLETE = -166

const PMIX_GROUP_LEADER_SELECTED = -167

const PMIX_GROUP_LEADER_FAILED = -168

const PMIX_GROUP_CONTEXT_ID_ASSIGNED = -169

const PMIX_GROUP_MEMBER_FAILED = -170

const PMIX_ERR_REPEAT_ATTR_REGISTRATION = -171

const PMIX_ERR_IOF_FAILURE = -172

const PMIX_ERR_IOF_COMPLETE = -173

const PMIX_LAUNCH_COMPLETE = -174

const PMIX_FABRIC_UPDATED = -175

const PMIX_FABRIC_UPDATE_PENDING = -176

const PMIX_FABRIC_UPDATE_ENDPOINTS = -113

const PMIX_ERR_JOB_APP_NOT_EXECUTABLE = -177

const PMIX_ERR_JOB_NO_EXE_SPECIFIED = -178

const PMIX_ERR_JOB_FAILED_TO_MAP = -179

const PMIX_ERR_JOB_CANCELED = -180

const PMIX_ERR_JOB_FAILED_TO_LAUNCH = -181

const PMIX_ERR_JOB_ABORTED = -182

const PMIX_ERR_JOB_KILLED_BY_CMD = -183

const PMIX_ERR_JOB_ABORTED_BY_SIG = -184

const PMIX_ERR_JOB_TERM_WO_SYNC = -185

const PMIX_ERR_JOB_SENSOR_BOUND_EXCEEDED = -186

const PMIX_ERR_JOB_NON_ZERO_TERM = -187

const PMIX_ERR_JOB_ALLOC_FAILED = -188

const PMIX_ERR_JOB_ABORTED_BY_SYS_EVENT = -189

const PMIX_ERR_JOB_EXE_NOT_FOUND = -190

const PMIX_ERR_JOB_WDIR_NOT_FOUND = -233

const PMIX_ERR_JOB_INSUFFICIENT_RESOURCES = -234

const PMIX_ERR_JOB_SYS_OP_FAILED = -235

const PMIX_EVENT_JOB_START = -191

const PMIX_EVENT_JOB_END = -145

const PMIX_EVENT_SESSION_START = -192

const PMIX_EVENT_SESSION_END = -193

const PMIX_ERR_PROC_TERM_WO_SYNC = -200

const PMIX_EVENT_PROC_TERMINATED = -201

const PMIX_EVENT_SYS_BASE = -230

const PMIX_EVENT_NODE_DOWN = -231

const PMIX_EVENT_NODE_OFFLINE = -232

const PMIX_EVENT_SYS_OTHER = -330

const PMIX_EVENT_NO_ACTION_TAKEN = -331

const PMIX_EVENT_PARTIAL_ACTION_TAKEN = -332

const PMIX_EVENT_ACTION_DEFERRED = -333

const PMIX_EVENT_ACTION_COMPLETE = -334

const PMIX_EXTERNAL_ERR_BASE = PMIX_INTERNAL_ERR_BASE - 2000

const PMIX_UNDEF = 0

const PMIX_BOOL = 1

const PMIX_BYTE = 2

const PMIX_STRING = 3

const PMIX_SIZE = 4

const PMIX_PID = 5

const PMIX_INT = 6

const PMIX_INT8 = 7

const PMIX_INT16 = 8

const PMIX_INT32 = 9

const PMIX_INT64 = 10

const PMIX_UINT = 11

const PMIX_UINT8 = 12

const PMIX_UINT16 = 13

const PMIX_UINT32 = 14

const PMIX_UINT64 = 15

const PMIX_FLOAT = 16

const PMIX_DOUBLE = 17

const PMIX_TIMEVAL = 18

const PMIX_TIME = 19

const PMIX_STATUS = 20

const PMIX_VALUE = 21

const PMIX_PROC = 22

const PMIX_APP = 23

const PMIX_INFO = 24

const PMIX_PDATA = 25

const PMIX_BYTE_OBJECT = 27

const PMIX_KVAL = 28

const PMIX_PERSIST = 30

const PMIX_POINTER = 31

const PMIX_SCOPE = 32

const PMIX_DATA_RANGE = 33

const PMIX_COMMAND = 34

const PMIX_INFO_DIRECTIVES = 35

const PMIX_DATA_TYPE = 36

const PMIX_PROC_STATE = 37

const PMIX_PROC_INFO = 38

const PMIX_DATA_ARRAY = 39

const PMIX_PROC_RANK = 40

const PMIX_QUERY = 41

const PMIX_COMPRESSED_STRING = 42

const PMIX_ALLOC_DIRECTIVE = 43

const PMIX_IOF_CHANNEL = 45

const PMIX_ENVAR = 46

const PMIX_COORD = 47

const PMIX_REGATTR = 48

const PMIX_REGEX = 49

const PMIX_JOB_STATE = 50

const PMIX_LINK_STATE = 51

const PMIX_PROC_CPUSET = 52

const PMIX_GEOMETRY = 53

const PMIX_DEVICE_DIST = 54

const PMIX_ENDPOINT = 55

const PMIX_TOPO = 56

const PMIX_DEVTYPE = 57

const PMIX_LOCTYPE = 58

const PMIX_COMPRESSED_BYTE_OBJECT = 59

const PMIX_PROC_NSPACE = 60

const PMIX_PROC_STATS = 61

const PMIX_DISK_STATS = 62

const PMIX_NET_STATS = 63

const PMIX_NODE_STATS = 64

const PMIX_DATA_BUFFER = 65

const PMIX_DATA_TYPE_MAX = 500

const PMIX_SCOPE_UNDEF = 0

const PMIX_LOCAL = 1

const PMIX_REMOTE = 2

const PMIX_GLOBAL = 3

const PMIX_INTERNAL = 4

const PMIX_RANGE_UNDEF = 0

const PMIX_RANGE_RM = 1

const PMIX_RANGE_LOCAL = 2

const PMIX_RANGE_NAMESPACE = 3

const PMIX_RANGE_SESSION = 4

const PMIX_RANGE_GLOBAL = 5

const PMIX_RANGE_CUSTOM = 6

const PMIX_RANGE_PROC_LOCAL = 7

const PMIX_RANGE_INVALID = UINT8_MAX

const PMIX_PERSIST_INDEF = 0

const PMIX_PERSIST_FIRST_READ = 1

const PMIX_PERSIST_PROC = 2

const PMIX_PERSIST_APP = 3

const PMIX_PERSIST_SESSION = 4

const PMIX_PERSIST_INVALID = UINT8_MAX

const PMIX_INFO_REQD = 0x00000001

const PMIX_INFO_ARRAY_END = 0x00000002

const PMIX_INFO_REQD_PROCESSED = 0x00000004

const PMIX_INFO_DIR_RESERVED = 0xffff0000

const PMIX_ALLOC_NEW = 1

const PMIX_ALLOC_EXTEND = 2

const PMIX_ALLOC_RELEASE = 3

const PMIX_ALLOC_REAQUIRE = 4

const PMIX_ALLOC_EXTERNAL = 128

const PMIX_FWD_NO_CHANNELS = 0x0000

const PMIX_FWD_STDIN_CHANNEL = 0x0001

const PMIX_FWD_STDOUT_CHANNEL = 0x0002

const PMIX_FWD_STDERR_CHANNEL = 0x0004

const PMIX_FWD_STDDIAG_CHANNEL = 0x0008

const PMIX_FWD_ALL_CHANNELS = 0x00ff

const PMIX_COORD_VIEW_UNDEF = 0x00

const PMIX_COORD_LOGICAL_VIEW = 0x01

const PMIX_COORD_PHYSICAL_VIEW = 0x02

const PMIX_LINK_STATE_UNKNOWN = 0

const PMIX_LINK_DOWN = 1

const PMIX_LINK_UP = 2

const PMIX_CPUBIND_PROCESS = 0

const PMIX_CPUBIND_THREAD = 1

const PMIX_LOCALITY_UNKNOWN = 0x0000

const PMIX_LOCALITY_NONLOCAL = 0x8000

const PMIX_LOCALITY_SHARE_HWTHREAD = 0x0001

const PMIX_LOCALITY_SHARE_CORE = 0x0002

const PMIX_LOCALITY_SHARE_L1CACHE = 0x0004

const PMIX_LOCALITY_SHARE_L2CACHE = 0x0008

const PMIX_LOCALITY_SHARE_L3CACHE = 0x0010

const PMIX_LOCALITY_SHARE_PACKAGE = 0x0020

const PMIX_LOCALITY_SHARE_NUMA = 0x0040

const PMIX_LOCALITY_SHARE_NODE = 0x4000

const PMIX_DEVTYPE_UNKNOWN = 0x00

const PMIX_DEVTYPE_BLOCK = 0x01

const PMIX_DEVTYPE_GPU = 0x02

const PMIX_DEVTYPE_NETWORK = 0x04

const PMIX_DEVTYPE_OPENFABRICS = 0x08

const PMIX_DEVTYPE_DMA = 0x10

const PMIX_DEVTYPE_COPROC = 0x20

const PMIX_BUFFER = 26

const PMIX_ERR_SILENT = -2

const PMIX_ERR_DEBUGGER_RELEASE = -3

const PMIX_ERR_PROC_ABORTED = -7

const PMIX_ERR_PROC_REQUESTED_ABORT = -8

const PMIX_ERR_PROC_ABORTING = -9

const PMIX_ERR_SERVER_FAILED_REQUEST = -10

const PMIX_EXISTS = -11

const PMIX_ERR_HANDSHAKE_FAILED = -13

const PMIX_ERR_READY_FOR_HANDSHAKE = -14

const PMIX_ERR_PROC_ENTRY_NOT_FOUND = -17

const PMIX_ERR_PACK_MISMATCH = -22

const PMIX_ERR_IN_ERRNO = -26

const PMIX_ERR_DATA_VALUE_NOT_FOUND = -30

const PMIX_ERR_INVALID_ARG = -33

const PMIX_ERR_INVALID_KEY = -34

const PMIX_ERR_INVALID_KEY_LENGTH = -35

const PMIX_ERR_INVALID_VAL = -36

const PMIX_ERR_INVALID_VAL_LENGTH = -37

const PMIX_ERR_INVALID_LENGTH = -38

const PMIX_ERR_INVALID_NUM_ARGS = -39

const PMIX_ERR_INVALID_ARGS = -40

const PMIX_ERR_INVALID_NUM_PARSED = -41

const PMIX_ERR_INVALID_KEYVALP = -42

const PMIX_ERR_INVALID_SIZE = -43

const PMIX_ERR_INVALID_NAMESPACE = -44

const PMIX_ERR_SERVER_NOT_AVAIL = -45

const PMIX_ERR_NOT_IMPLEMENTED = -48

const PMIX_DEBUG_WAITING_FOR_NOTIFY = -58

const PMIX_ERR_LOST_CONNECTION_TO_SERVER = -101

const PMIX_ERR_LOST_PEER_CONNECTION = -102

const PMIX_ERR_LOST_CONNECTION_TO_CLIENT = -103

const PMIX_NOTIFY_ALLOC_COMPLETE = -105

const PMIX_ERR_INVALID_TERMINATION = -112

const PMIX_ERR_JOB_TERMINATED = -145

const PMIX_ERR_UPDATE_ENDPOINTS = -146

const PMIX_GDS_ACTION_COMPLETE = -148

const PMIX_PROC_HAS_CONNECTED = -149

const PMIX_CONNECT_REQUESTED = -150

const PMIX_ERR_NODE_DOWN = -231

const PMIX_ERR_NODE_OFFLINE = -232

const PMIX_ERR_SYS_BASE = PMIX_EVENT_SYS_BASE

const PMIX_ERR_SYS_OTHER = PMIX_EVENT_SYS_OTHER

const PMIX_JOB_STATE_PREPPED = 1

const PMIX_EVENT_BASE = "pmix.evbase"

const PMIX_TOPOLOGY = "pmix.topo"

const PMIX_DEBUG_JOB = "pmix.dbg.job"

const PMIX_RECONNECT_SERVER = "pmix.cnct.recon"

const PMIX_ALLOC_NETWORK = "pmix.alloc.net"

const PMIX_ALLOC_NETWORK_ID = "pmix.alloc.netid"

const PMIX_ALLOC_NETWORK_QOS = "pmix.alloc.netqos"

const PMIX_ALLOC_NETWORK_TYPE = "pmix.alloc.nettype"

const PMIX_ALLOC_NETWORK_PLANE = "pmix.alloc.netplane"

const PMIX_ALLOC_NETWORK_ENDPTS = "pmix.alloc.endpts"

const PMIX_ALLOC_NETWORK_ENDPTS_NODE = "pmix.alloc.endpts.nd"

const PMIX_ALLOC_NETWORK_SEC_KEY = "pmix.alloc.nsec"

const PMIX_PROC_DATA = "pmix.pdata"

const PMIX_LOCALITY = "pmix.loc"

const PMIX_LOCAL_TOPO = "pmix.ltopo"

const PMIX_TOPOLOGY_XML = "pmix.topo.xml"

const PMIX_TOPOLOGY_FILE = "pmix.topo.file"

const PMIX_TOPOLOGY_SIGNATURE = "pmix.toposig"

const PMIX_HWLOC_SHMEM_ADDR = "pmix.hwlocaddr"

const PMIX_HWLOC_SHMEM_SIZE = "pmix.hwlocsize"

const PMIX_HWLOC_SHMEM_FILE = "pmix.hwlocfile"

const PMIX_HWLOC_XML_V1 = "pmix.hwlocxml1"

const PMIX_HWLOC_XML_V2 = "pmix.hwlocxml2"

const PMIX_HWLOC_SHARE_TOPO = "pmix.hwlocsh"

const PMIX_HWLOC_HOLE_KIND = "pmix.hwlocholek"

const PMIX_DSTPATH = "pmix.dstpath"

const PMIX_COLLECTIVE_ALGO = "pmix.calgo"

const PMIX_COLLECTIVE_ALGO_REQD = "pmix.calreqd"

const PMIX_PROC_BLOB = "pmix.pblob"

const PMIX_MAP_BLOB = "pmix.mblob"

const PMIX_MAPPER = "pmix.mapper"

const PMIX_NON_PMI = "pmix.nonpmi"

const PMIX_PROC_URI = "pmix.puri"

const PMIX_ARCH = "pmix.arch"

const PMIX_DEBUG_JOB_DIRECTIVES = "pmix.dbg.jdirs"

const PMIX_DEBUG_APP_DIRECTIVES = "pmix.dbg.adirs"

const PMIX_EVENT_NO_TERMINATION = "pmix.evnoterm"

const PMIX_EVENT_WANT_TERMINATION = "pmix.evterm"

const PMIX_TAG_OUTPUT = "pmix.tagout"

const PMIX_TIMESTAMP_OUTPUT = "pmix.tsout"

const PMIX_MERGE_STDERR_STDOUT = "pmix.mergeerrout"

const PMIX_OUTPUT_TO_FILE = "pmix.outfile"

const PMIX_OUTPUT_TO_DIRECTORY = "pmix.outdir"

const PMIX_OUTPUT_NOCOPY = "pmix.nocopy"

const PMIX_GDS_MODULE = "pmix.gds.mod"

const PMIX_IOF_STOP = "pmix.iof.stop"

const PMIX_NOTIFY_LAUNCH = "pmix.note.lnch"

end # module
