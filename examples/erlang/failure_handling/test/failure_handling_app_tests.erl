-module(failure_handling_app_tests).

-include_lib("eunit/include/eunit.hrl").

has_commit_map(Pid) when is_pid(Pid) ->
    case erlang:process_info(Pid, dictionary) of
        {dictionary, Dict} -> lists:keymember(commit_map, 1, Dict);
        _ -> false
    end;
has_commit_map(_) -> false.

log_nonempty(Path) ->
    case filelib:is_file(Path) of
        true -> filelib:file_size(Path) > 0;
        false -> false
    end.

failure_handling_start_stop_test_() ->
    {timeout, 60,
     fun() ->
         {ok, _} = application:ensure_all_started(failure_handling),

         Sup = whereis(failure_handling_sup),
         ?assertMatch(P when is_pid(P), Sup),

         MPid = whereis(m),
         WPid = whereis(w),
         FdPid = whereis(fd),
         ?assert(is_pid(MPid) andalso is_process_alive(MPid)),
         ?assert(is_pid(WPid) andalso is_process_alive(WPid)),
         ?assert(is_pid(FdPid) andalso is_process_alive(FdPid)),

         ?assert(has_commit_map(MPid)),
         ?assert(has_commit_map(WPid)),
         ?assert(has_commit_map(FdPid)),

         timer:sleep(300),
         ?assert(log_nonempty("m_debug.log")),
         ?assert(log_nonempty("w_debug.log")),
         ?assert(log_nonempty("fd_debug.log")),

         ok = application:stop(failure_handling)
     end}.
