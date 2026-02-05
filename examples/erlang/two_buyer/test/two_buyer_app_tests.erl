-module(two_buyer_app_tests).

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

%% Minimal OTP-app test:
%% - start/stop the OTP application
%% - assert the expected registered role processes exist

two_buyer_start_stop_test_() ->
    {timeout, 60,
     fun() ->
         {ok, _} = application:ensure_all_started(two_buyer),

         Sup = whereis(two_buyer_sup),
         ?assertMatch(P when is_pid(P), Sup),

         AlicePid = whereis(alice),
         BobPid = whereis(bob),
         SellerPid = whereis(seller),
         ?assert(is_pid(AlicePid) andalso is_process_alive(AlicePid)),
         ?assert(is_pid(BobPid) andalso is_process_alive(BobPid)),
         ?assert(is_pid(SellerPid) andalso is_process_alive(SellerPid)),

         ?assert(has_commit_map(AlicePid)),
         ?assert(has_commit_map(BobPid)),
         ?assert(has_commit_map(SellerPid)),

         timer:sleep(300),
         ?assert(log_nonempty("alice_debug.log")),
         ?assert(log_nonempty("bob_debug.log")),
         ?assert(log_nonempty("seller_debug.log")),

         ok = application:stop(two_buyer)
     end}.
