module IOF
    import ..PMIx
    import PMIx: API, Info, Value, @check, PMIxException

    function redirect_stdin!(target)
        info = [
            Info(API.PMIX_IOF_PUSH_STDIN, Value(true, API.PMIX_BOOL)),
        ]
        status = API.PMIx_IOF_push(Ref(target), 1, C_NULL, info, length(info), C_NULL, C_NULL)
        if !(status == API.PMIX_OPERATION_SUCCEEDED || status == API.PMIX_SUCCESS)
            throw(PMIxException(status))
        end
        return nothing
    end

    function redirect!(target, stderr=true, stdout=true)
        channel = API.PMIX_FWD_NO_CHANNELS
        stderr && (channel |= API.PMIX_FWD_STDERR_CHANNEL)
        stdout && (channel |= API.PMIX_FWD_STDOUT_CHANNEL)

        status = API.PMIx_IOF_pull(Ref(target), 1, C_NULL, 0, channel, C_NULL, C_NULL, C_NULL)
        if !(status == API.PMIX_OPERATION_SUCCEEDED || status == API.PMIX_SUCCESS || status > 0)
            # FIXME, with regcbfunc == C_NULL, status sometimes is 1
            throw(PMIxException(status))
        end
        return nothing
    end

end