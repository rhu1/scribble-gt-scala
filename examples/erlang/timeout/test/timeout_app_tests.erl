-module(timeout_app_tests).

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

wait_for_registered(Name, 0) ->
    whereis(Name);
wait_for_registered(Name, N) ->
    case whereis(Name) of
        P when is_pid(P) -> P;
        undefined ->
            timer:sleep(20),
            wait_for_registered(Name, N - 1)
    end.

timeout_start_stop_test_() ->
    {timeout, 60,
     fun() ->
         {ok, _} = application:ensure_all_started(timeout),

         Sup = whereis(timeout_sup),
         ?assertMatch(P when is_pid(P), Sup),

         APid = wait_for_registered(a, 50),
         BPid = wait_for_registered(b, 50),
         CPid = wait_for_registered(client, 50),
         ?assert(is_pid(APid)),
         ?assert(is_pid(BPid)),
         ?assert(is_pid(CPid)),

         %% Wrapper marker (commit_map) should be present while the process lives.
         %% If a role exits before we inspect it, we'll still validate activity via logs.
         case is_process_alive(APid) of true -> ?assert(has_commit_map(APid)); false -> ok end,
         case is_process_alive(BPid) of true -> ?assert(has_commit_map(BPid)); false -> ok end,
         case is_process_alive(CPid) of true -> ?assert(has_commit_map(CPid)); false -> ok end,

         %% Functionality evidence: role wrappers should have executed some transitions.
         timer:sleep(300),
         ?assert(log_nonempty("a_debug.log")),
         ?assert(log_nonempty("b_debug.log")),
         ?assert(log_nonempty("c_debug.log")),

         ok = application:stop(timeout)
     end}.
