-module(interrupt_app_tests).

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

interrupt_start_stop_test_() ->
    {timeout, 60,
     fun() ->
         {ok, _} = application:ensure_all_started(interrupt),

         Sup = whereis(interrupt_sup),
         ?assertMatch(P when is_pid(P), Sup),

         PPid = whereis(p),
         QPid = whereis(q),
         ?assert(is_pid(PPid) andalso is_process_alive(PPid)),
         ?assert(is_pid(QPid) andalso is_process_alive(QPid)),

         ?assert(has_commit_map(PPid)),
         ?assert(has_commit_map(QPid)),

         timer:sleep(300),
         ?assert(log_nonempty("p_debug.log")),
         ?assert(log_nonempty("q_debug.log")),

         ok = application:stop(interrupt)
     end}.
