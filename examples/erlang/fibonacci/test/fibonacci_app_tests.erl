-module(fibonacci_app_tests).

-include_lib("eunit/include/eunit.hrl").
-include("a.hrl").

normal_recursive_paths_test_() ->
    {timeout, 10, fun normal_recursive_paths/0}.

error_overtakes_speculative_left_test_() ->
    {timeout, 10, fun error_overtakes_speculative_left/0}.

recursive_stale_path_test() ->
    Data = #state_data{},
    try
        put(commit_map, #{[] => {mc1, right}}),
        ?assertEqual(
            {keep_state, Data},
            gen_a:s5(cast, {self(), {fibonacci_2, {1}}, [left]}, Data)
        ),
        ?assertEqual(
            {keep_state, Data, [postpone]},
            gen_a:s5(cast, {self(), {fibonacci_2, {1}}, [right]}, Data)
        ),

        put(commit_map, #{[] => {mc1, left}, [left] => {mc1, right}}),
        ?assertEqual(
            {keep_state, Data},
            gen_a:s5(cast, {self(), {fibonacci_2, {1}}, [left, left]}, Data)
        ),
        ?assertEqual(
            {keep_state, Data, [postpone]},
            gen_a:s5(cast, {self(), {fibonacci_2, {1}}, [left, right]}, Data)
        )
    after
        erase(commit_map)
    end.

normal_recursive_paths() ->
    with_application(
      normal,
      fun(APid) ->
          ?assertEqual([left], receive_fibonacci_1_from(APid)),
          ?assertEqual([left, left], receive_fibonacci_1_from(APid)),
          ?assertEqual([left, left, left, left, left], receive_ack()),
          receive_normal_exit(APid)
      end).

error_overtakes_speculative_left() ->
    with_application(
      error,
      fun(APid) ->
          ?assertEqual([left], receive_fibonacci_1_from(APid)),
          ?assertEqual([right], receive_error()),
          ?assertEqual([right], receive_error_at(APid)),
          receive_normal_exit(APid)
      end).

with_application(Mode, Test) ->
    stop_application(),
    flush_trace_messages(),
    start_runtime_trace(),
    ok = load_application(),
    ok = application:set_env(fibonacci, mode, Mode),
    ok = application:set_env(fibonacci, limit, 4),
    {ok, _Started} = application:ensure_all_started(fibonacci),
    APid = wait_for_registered(a, 50),
    try
        Test(APid)
    after
        stop_runtime_trace(),
        stop_application(),
        flush_trace_messages()
    end.

load_application() ->
    case application:load(fibonacci) of
        ok -> ok;
        {error, {already_loaded, fibonacci}} -> ok
    end.

stop_application() ->
    _ = application:stop(fibonacci),
    _ = application:unload(fibonacci),
    ok.

start_runtime_trace() ->
    _ = erlang:trace(new, true, [send, 'receive', procs, {tracer, self()}]),
    ok.

stop_runtime_trace() ->
    _ = erlang:trace(new, false, [send, 'receive', procs]),
    _ = erlang:trace(all, false, [send, 'receive', procs]),
    ok.

receive_fibonacci_1_from(Sender) ->
    receive
        {trace, Sender, send,
         {'$gen_cast', {Sender, {fibonacci_1, {_Number}}, Path}}, _Recipient} ->
            Path
    after 2000 ->
        error({missing_fibonacci_1_from, Sender})
    end.

receive_ack() ->
    receive
        {trace, Sender, send,
         {'$gen_cast', {Sender, {ack}, Path}}, _Recipient} ->
            Path
    after 2000 ->
        error(missing_ack)
    end.

receive_error() ->
    receive
        {trace, Sender, send,
         {'$gen_cast', {Sender, {error}, Path}}, _Recipient} ->
            Path
    after 2000 ->
        error(missing_error)
    end.

receive_error_at(APid) ->
    receive
        {trace, APid, 'receive',
         {'$gen_cast', {_Sender, {error}, Path}}} ->
            Path
    after 2000 ->
        error(missing_error_receive)
    end.

receive_normal_exit(Pid) ->
    receive
        {trace, Pid, exit, normal} ->
            ok
    after 2000 ->
        error({missing_normal_exit, Pid})
    end.

wait_for_registered(_Name, 0) ->
    error(process_not_registered);
wait_for_registered(Name, Attempts) ->
    case whereis(Name) of
        undefined ->
            timer:sleep(10),
            wait_for_registered(Name, Attempts - 1);
        Pid ->
            Pid
    end.

flush_trace_messages() ->
    receive
        {trace, _Pid, _Event, _Detail} ->
            flush_trace_messages();
        {trace, _Pid, _Event, _Detail, _Extra} ->
            flush_trace_messages()
    after 0 ->
        ok
    end.
