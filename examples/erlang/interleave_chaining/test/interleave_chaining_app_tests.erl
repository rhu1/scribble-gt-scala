-module(interleave_chaining_app_tests).

-include_lib("eunit/include/eunit.hrl").

wait_for_registered(Name, 0) ->
    whereis(Name);
wait_for_registered(Name, N) ->
    case whereis(Name) of
        P when is_pid(P) -> P;
        undefined ->
            timer:sleep(20),
            wait_for_registered(Name, N - 1)
    end.

has_callback_module(Pid) when is_pid(Pid) ->
    case erlang:process_info(Pid, dictionary) of
        {dictionary, Dict} -> lists:keymember(callback_module, 1, Dict);
        _ -> false
    end;
has_callback_module(_) -> false.

log_nonempty(Path) ->
    case filelib:is_file(Path) of
        true -> filelib:file_size(Path) > 0;
        false -> false
    end.

interleave_chaining_start_stop_test_() ->
    {timeout, 60,
     fun() ->
         {ok, _} = application:ensure_all_started(interleaving),

         Sup = whereis(interleaving_sup),
         ?assertMatch(P when is_pid(P), Sup),

         AlicePid = whereis(alice),
         BobPid = whereis(bob),
         CarolPid = whereis(carol),
         ?assert(is_pid(AlicePid) andalso is_process_alive(AlicePid)),
         ?assert(is_pid(BobPid) andalso is_process_alive(BobPid)),
         ?assert(is_pid(CarolPid) andalso is_process_alive(CarolPid)),
         ?assert(has_callback_module(AlicePid)),
         ?assert(has_callback_module(BobPid)),
         ?assert(has_callback_module(CarolPid)),

         %% alice2 is spawned after alice completes its first session.
         Alice2Pid = wait_for_registered(alice2, 50),
         ?assert(is_pid(Alice2Pid) andalso is_process_alive(Alice2Pid)),
         ?assert(has_callback_module(Alice2Pid)),

         timer:sleep(300),
         ?assert(log_nonempty("alice_debug.log")),
         ?assert(log_nonempty("bob_debug.log")),
         ?assert(log_nonempty("carol_debug.log")),

         ok = application:stop(interleaving)
     end}.
