module IOF
    import ..PMIx
    import PMIx: API, Info, Value, @check

    function redirect_stdin!(target)
        info = [
            Info(API.PMIX_IOF_PUSH_STDIN, Value(true, API.PMIX_BOOL)),
        ]
        @check API.PMIx_IOF_push(Ref(target), 1, C_NULL, info, length(info), C_NULL, C_NULL)
    end

    function redirect!(target, stderr=true, stdout=true)
        channel = API.PMIX_FWD_NO_CHANNELS
        stderr && (channel |= API.PMIX_FWD_STDERR)
        stdout && (channel |= API.PMIX_FWD_STDOUT)

        @check API.PMIx_IOF_pull(Ref(target), 1, C_NULL, 0, channel, C_NULL, C_NULL, C_NULL)
    end

end