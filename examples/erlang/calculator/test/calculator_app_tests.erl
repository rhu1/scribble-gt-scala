-module(calculator_app_tests).

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
          when is_list(Path), Path =/= [] ->
            Path;
        _Other ->
            receive_structural_path_until(Deadline)
    after Remaining ->
        error(missing_structural_path)
    end.

is_structural_path([Side | Rest]) when Side =:= left; Side =:= right ->
    lists:all(fun(Item) -> Item =:= left orelse Item =:= right end, Rest);
is_structural_path(_) ->
    false.

flush_trace_messages() ->
    receive
        {trace, _Pid, _Event, _Detail} -> flush_trace_messages();
        {trace, _Pid, _Event, _Detail, _Extra} -> flush_trace_messages()
    after 0 ->
        ok
    end.

calculator_start_stop_test_() ->
    {timeout, 60,
     fun() ->
         start_path_trace(),
         try
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
             ?assert(is_structural_path(receive_structural_path(5000))),

             timer:sleep(300),
             ?assert(not (is_process_alive(AlicePid) andalso is_process_alive(CarolPid) andalso is_process_alive(SrvPid)))
         after
             stop_path_trace(),
             _ = application:stop(calculator),
             flush_trace_messages()
         end
     end}.
