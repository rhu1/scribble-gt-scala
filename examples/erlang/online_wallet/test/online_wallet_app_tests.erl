-module(online_wallet_app_tests).

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

online_wallet_start_stop_test_() ->
    {timeout, 60,
     fun() ->
         {ok, _} = application:ensure_all_started(online_wallet),

         Sup = whereis(online_wallet_sup),
         ?assertMatch(P when is_pid(P), Sup),

         APid = whereis(a),
         ClientPid = whereis(client),
         SPid = whereis(s),
         ?assert(is_pid(APid) andalso is_process_alive(APid)),
         ?assert(is_pid(ClientPid) andalso is_process_alive(ClientPid)),
         ?assert(is_pid(SPid) andalso is_process_alive(SPid)),

         ?assert(has_commit_map(APid)),
         ?assert(has_commit_map(ClientPid)),
         ?assert(has_commit_map(SPid)),

         timer:sleep(300),
         ?assert(log_nonempty("a_debug.log")),
         ?assert(log_nonempty("c_debug.log")),
         ?assert(log_nonempty("s_debug.log")),

         ok = application:stop(online_wallet)
     end}.
