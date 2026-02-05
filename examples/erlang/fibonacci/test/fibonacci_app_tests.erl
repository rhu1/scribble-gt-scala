-module(fibonacci_app_tests).

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

fibonacci_start_stop_test_() ->
    {timeout, 60,
     fun() ->
         {ok, _} = application:ensure_all_started(fibonacci),

         Sup = whereis(fibonacci_sup),
         ?assertMatch(P when is_pid(P), Sup),

         APid = whereis(a),
         BPid = whereis(b),
         ?assert(is_pid(APid) andalso is_process_alive(APid)),
         ?assert(is_pid(BPid) andalso is_process_alive(BPid)),

         ?assert(has_commit_map(APid)),
         ?assert(has_commit_map(BPid)),

         timer:sleep(300),
         ?assert(log_nonempty("a_debug.log")),
         ?assert(log_nonempty("b_debug.log")),

         ok = application:stop(fibonacci)
     end}.
