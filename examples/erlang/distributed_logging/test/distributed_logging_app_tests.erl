-module(distributed_logging_app_tests).

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

distributed_logging_start_stop_test_() ->
    {timeout, 60,
     fun() ->
         {ok, _} = application:ensure_all_started(distributed_logging),

         Sup = whereis(distributed_logging_sup),
         ?assertMatch(P when is_pid(P), Sup),

         ControllerPid = whereis(controller),
         LogsPid = whereis(logs),
         ?assert(is_pid(ControllerPid) andalso is_process_alive(ControllerPid)),
         ?assert(is_pid(LogsPid) andalso is_process_alive(LogsPid)),

         ?assert(has_commit_map(ControllerPid)),
         ?assert(has_commit_map(LogsPid)),

         timer:sleep(300),
         ?assert(log_nonempty("controller_debug.log")),
         ?assert(log_nonempty("logs_debug.log")),

         ok = application:stop(distributed_logging)
     end}.
