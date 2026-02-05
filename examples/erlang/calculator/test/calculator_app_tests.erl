-module(calculator_app_tests).

-include_lib("eunit/include/eunit.hrl").

has_commit_map(Pid) when is_pid(Pid) ->
    case erlang:process_info(Pid, dictionary) of
        {dictionary, Dict} -> lists:keymember(commit_map, 1, Dict);
        _ -> false
    end;
has_commit_map(_) -> false.

calculator_start_stop_test_() ->
    {timeout, 60,
     fun() ->
         {ok, _} = application:ensure_all_started(calculator),

         Sup = whereis(calculator_sup),
         ?assertMatch(P when is_pid(P), Sup),

         AlicePid = whereis(alice),
         CarolPid = whereis(carol),
         SrvPid = whereis(srv),
         ?assert(is_pid(AlicePid) andalso is_process_alive(AlicePid)),
         ?assert(is_pid(CarolPid) andalso is_process_alive(CarolPid)),
         ?assert(is_pid(SrvPid) andalso is_process_alive(SrvPid)),

         ?assert(has_commit_map(AlicePid)),
         ?assert(has_commit_map(CarolPid)),
         ?assert(has_commit_map(SrvPid)),

         timer:sleep(300),
         ?assert(not (is_process_alive(AlicePid) andalso is_process_alive(CarolPid) andalso is_process_alive(SrvPid))),

         ok = application:stop(calculator)
     end}.
