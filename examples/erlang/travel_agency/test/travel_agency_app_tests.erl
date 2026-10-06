-module(travel_agency_app_tests).

-export([s6/3]).

-include_lib("eunit/include/eunit.hrl").

has_commit_map(Pid) when is_pid(Pid) ->
    case erlang:process_info(Pid, dictionary) of
        {dictionary, Dict} -> lists:keymember(commit_map, 1, Dict);
        _ -> false
    end;
has_commit_map(_) -> false.

start_path_trace() ->
    flush_trace_messages(),
    _ = erlang:trace(new, true, [send, {tracer, self()}]),
    ok.

stop_path_trace() ->
    _ = erlang:trace(new, false, [send]),
    _ = erlang:trace(all, false, [send]),
    ok.

receive_structural_path(Timeout) ->
    Deadline = erlang:monotonic_time(millisecond) + Timeout,
    receive_structural_path_until(Deadline).

receive_structural_path_until(Deadline) ->
    Remaining = erlang:max(0, Deadline - erlang:monotonic_time(millisecond)),
    receive
        {trace, _Sender, send,
         {'$gen_cast', {_From, _Payload, Path}}, _Recipient}
          when is_list(Path), Path =/= [] -> Path;
        _Other -> receive_structural_path_until(Deadline)
    after Remaining -> error(missing_structural_path)
    end.

is_structural_path([Side | Rest]) when Side =:= left; Side =:= right ->
    lists:all(fun(Item) -> Item =:= left orelse Item =:= right end, Rest);
is_structural_path(_) -> false.

flush_trace_messages() ->
    receive
        {trace, _Pid, _Event, _Detail} -> flush_trace_messages();
        {trace, _Pid, _Event, _Detail, _Extra} -> flush_trace_messages()
    after 0 -> ok
    end.

log_nonempty(Path) ->
    case filelib:is_file(Path) of
        true -> filelib:file_size(Path) > 0;
        false -> false
    end.

s6(cast, {ClientPid, {cancel_agency}}, Data) when ClientPid =:= self() ->
    self() ! continuation_callback_called,
    {stop, normal, Data}.

continuation_receive_uses_current_path_test() ->
    PreviousCallback = put(callback_module, ?MODULE),
    PreviousPath = put(mc_path, [right]),
    PreviousCommit = put(commit_map, #{[] => {mc1, right}}),
    try
        ?assertEqual(
            {stop, normal, continuation_data},
            gen_agency:s6(cast, {self(), {cancel_agency}, [right]}, continuation_data)
        ),
        receive
            continuation_callback_called -> ok
        after 1000 ->
            error(continuation_callback_not_called)
        end,
        ?assertEqual([right], get(mc_path)),
        ?assertEqual(#{[] => {mc1, right}}, get(commit_map))
    after
        restore_process_value(callback_module, PreviousCallback),
        restore_process_value(mc_path, PreviousPath),
        restore_process_value(commit_map, PreviousCommit)
    end.

restore_process_value(Key, undefined) ->
    erase(Key);
restore_process_value(Key, Value) ->
    put(Key, Value).

travel_agency_start_stop_test_() ->
    {timeout, 60,
     fun() ->
         start_path_trace(),
         try
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
             ?assert(is_structural_path(receive_structural_path(5000))),

             timer:sleep(300),
             ?assert(log_nonempty("client_debug.log")),
             ?assert(log_nonempty("agency_debug.log")),
             ?assert(log_nonempty("supplier_debug.log"))
         after
             stop_path_trace(),
             _ = application:stop(travel_agency),
             flush_trace_messages()
         end
     end}.
