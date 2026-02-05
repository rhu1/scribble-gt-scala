-module(travel_agency_app_tests).

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

travel_agency_start_stop_test_() ->
    {timeout, 60,
     fun() ->
         {ok, _} = application:ensure_all_started(travel_agency),

         Sup = whereis(travel_agency_sup),
         ?assertMatch(P when is_pid(P), Sup),

         ClientPid = whereis(client),
         AgencyPid = whereis(agency),
         SupplierPid = whereis(supplier),
         ?assert(is_pid(ClientPid) andalso is_process_alive(ClientPid)),
         ?assert(is_pid(AgencyPid) andalso is_process_alive(AgencyPid)),
         ?assert(is_pid(SupplierPid) andalso is_process_alive(SupplierPid)),

         ?assert(has_commit_map(ClientPid)),
         ?assert(has_commit_map(AgencyPid)),
         ?assert(has_commit_map(SupplierPid)),

         timer:sleep(300),
         ?assert(log_nonempty("client_debug.log")),
         ?assert(log_nonempty("agency_debug.log")),
         ?assert(log_nonempty("supplier_debug.log")),

         ok = application:stop(travel_agency)
     end}.
