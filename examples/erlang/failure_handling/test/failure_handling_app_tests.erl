-module(failure_handling_app_tests).

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

failure_handling_start_stop_test_() ->
    {timeout, 60,
     fun() ->
         start_path_trace(),
         try
             {ok, _} = application:ensure_all_started(failure_handling),

             Sup = whereis(failure_handling_sup),
             ?assertMatch(P when is_pid(P), Sup),

             MPid = whereis(m),
             WPid = whereis(w),
             FdPid = whereis(fd),
             ?assert(is_pid(MPid) andalso is_process_alive(MPid)),
             ?assert(is_pid(WPid) andalso is_process_alive(WPid)),
             ?assert(is_pid(FdPid) andalso is_process_alive(FdPid)),

             ?assert(has_commit_map(MPid)),
             ?assert(has_commit_map(WPid)),
             ?assert(has_commit_map(FdPid)),
             ?assert(is_structural_path(receive_structural_path(5000))),

             timer:sleep(300),
             ?assert(log_nonempty("m_debug.log")),
             ?assert(log_nonempty("w_debug.log")),
             ?assert(log_nonempty("fd_debug.log"))
         after
             stop_path_trace(),
             _ = application:stop(failure_handling),
             flush_trace_messages()
         end
     end}.
