
%%%-------------------------------------------------------------------
%%% gen_a.erl — generated generic behaviour module (gen_statem)
%%%-------------------------------------------------------------------
-module(gen_a).
-behaviour(gen_statem).

%% Public API
-export([start_link/2, callback_mode/0]).

%% gen_statem callbacks
-export([init/1, code_change/4, terminate/3,
  s5/3,
  s6/3,
  s9/3,
  send_s5_fibonacci_1/3,
  send_s5_fibonacci_1/2,
  send_s5_stop/2]).

%% Types & records
-include("a.hrl").
-export_type([state_data/0]).
-type state_data() :: #state_data{}.

-callback init(Args :: list()) -> {ok, s5, state_data()} | {ok, s5, state_data(), [gen_statem:action()]}.
-callback s5(internal | cast, {fibonacci_1} | {stop} | {pid(), {error}}, state_data()) -> {next_state, s6, state_data()} | {next_state, s9, state_data()} | {next_state, s6, state_data(), [{next_event, internal, {fibonacci_1}}] } | {next_state, s6, state_data(), [{next_event, internal, {stop}}] } | {next_state, s9, state_data(), [{next_event, internal, {fibonacci_1}}] } | {next_state, s9, state_data(), [{next_event, internal, {stop}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s6(cast, {pid(), {error}} | {pid(), {fibonacci_2, {term()}}}, state_data()) -> {next_state, s5, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s9(cast, {pid(), {ack}} | {pid(), {error}}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.

%% ===== API =====
-spec start_link(CallbackModule :: module(), Args :: list()) ->
    {ok, pid()} | {error, term()}.
start_link(CallbackModule, Args) ->
    case code:ensure_loaded(CallbackModule) of
        {module, CallbackModule} ->
            gen_statem:start_link({local, CallbackModule}, gen_a, {CallbackModule, Args}, [{debug, [trace, {log_to_file, "a_debug.log"}]}]);
        {error, Reason} ->
            {error, Reason}
    end.

-spec callback_mode() -> state_functions.
callback_mode() -> state_functions.

%% ===== gen_statem =====
-spec init({module(), list()}) ->
    {ok, s5, state_data()} | {ok, s5, state_data(), [gen_statem:action()]}.
init({CallbackModule, _Args}) ->
    io:format("a: Initializing with callback module ~p~n", [CallbackModule]),
    put(callback_module, CallbackModule),
    init_context(),
    enter_mc(mc1),
    CallbackModule:init([]).

%% ---------- State functions----------
%% Mixed-choice entry state
-spec s5(internal | cast, {fibonacci_1} | {stop} | {pid(), {error}, list()}, state_data()) -> {next_state, s6, state_data()} | {next_state, s9, state_data()} | {next_state, s6, state_data(), [{next_event, internal, {fibonacci_1}}] } | {next_state, s6, state_data(), [{next_event, internal, {stop}}] } | {next_state, s9, state_data(), [{next_event, internal, {fibonacci_1}}] } | {next_state, s9, state_data(), [{next_event, internal, {stop}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s5(internal, {stop}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s5(internal, {stop}, Data),
    after_transition(Next);
s5(internal, {fibonacci_1}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s5(internal, {fibonacci_1}, Data),
    after_transition(Next);
s5(cast, {BPid, {error}, Path}, Data) ->
    case message_status(Path, branch_path(mc1, right)) of
      stale ->
        io:format("gen_a[s5]: Purging stale event ~p~n", [{error}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s5(cast, {BPid, {error}}, Data)
               catch error:function_clause ->
                 io:format("gen_a[s5]: Callback had no clause for ~p, postponing~n", [{error}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {stop, _, _} -> after_transition(commit_if_taken(Next, mc1, right));
          _ -> after_transition(Next)
        end;
      not_ready ->
        io:format("gen_a[s5]: Postponing not-ready event ~p~n", [{error}]),
        {keep_state, Data, [postpone]}
    end;
s5(cast, {_BPid, {fibonacci_2, {Num}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_a[s5]: Purging stale event ~p~n", [{fibonacci_2, {Num}}]),
        {keep_state, Data};
      false ->
        io:format("gen_a[s5]: Postponing event ~p~n", [{fibonacci_2, {Num}}]),
        {keep_state, Data, [postpone]}
    end;
s5(cast, {_BPid, {ack}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_a[s5]: Purging stale event ~p~n", [{ack}]),
        {keep_state, Data};
      false ->
        io:format("gen_a[s5]: Postponing event ~p~n", [{ack}]),
        {keep_state, Data, [postpone]}
    end.

-spec s6(cast, {pid(), {error}, list()} | {pid(), {fibonacci_2, {term()}}, list()}, state_data()) -> {next_state, s5, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
s6(cast, {BPid, {error}, Path}, Data) ->
    case message_status(Path, branch_path(mc1, right)) of
      stale ->
        io:format("gen_a[s6]: Purging stale event ~p~n", [{error}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s6(cast, {BPid, {error}}, Data)
               catch error:function_clause ->
                 io:format("gen_a[s6]: Callback had no clause for ~p, postponing~n", [{error}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {stop, _, _} -> after_transition(commit_if_taken(Next, mc1, right));
          _ -> after_transition(Next)
        end;
      not_ready ->
        io:format("gen_a[s6]: Postponing not-ready event ~p~n", [{error}]),
        {keep_state, Data, [postpone]}
    end;
s6(cast, {BPid, {fibonacci_2, {Num}}, Path}, Data) ->
    case message_status(Path, current_path()) of
      stale ->
        io:format("gen_a[s6]: Purging stale event ~p~n", [{fibonacci_2, {Num}}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s6(cast, {BPid, {fibonacci_2, {Num}}}, Data)
               catch error:function_clause ->
                 io:format("gen_a[s6]: Callback had no clause for ~p, postponing~n", [{fibonacci_2, {Num}}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> after_transition(Next)
        end;
      not_ready ->
        io:format("gen_a[s6]: Postponing not-ready event ~p~n", [{fibonacci_2, {Num}}]),
        {keep_state, Data, [postpone]}
    end;
s6(cast, {_BPid, {ack}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_a[s6]: Purging stale event ~p~n", [{ack}]),
        {keep_state, Data};
      false ->
        io:format("gen_a[s6]: Postponing event ~p~n", [{ack}]),
        {keep_state, Data, [postpone]}
    end.

-spec s9(cast, {pid(), {ack}, list()} | {pid(), {error}, list()}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
s9(cast, {BPid, {error}, Path}, Data) ->
    case message_status(Path, branch_path(mc1, right)) of
      stale ->
        io:format("gen_a[s9]: Purging stale event ~p~n", [{error}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s9(cast, {BPid, {error}}, Data)
               catch error:function_clause ->
                 io:format("gen_a[s9]: Callback had no clause for ~p, postponing~n", [{error}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {stop, _, _} -> after_transition(commit_if_taken(Next, mc1, right));
          _ -> after_transition(Next)
        end;
      not_ready ->
        io:format("gen_a[s9]: Postponing not-ready event ~p~n", [{error}]),
        {keep_state, Data, [postpone]}
    end;
s9(cast, {BPid, {ack}, Path}, Data) ->
    case message_status(Path, current_path()) of
      stale ->
        io:format("gen_a[s9]: Purging stale event ~p~n", [{ack}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s9(cast, {BPid, {ack}}, Data)
               catch error:function_clause ->
                 io:format("gen_a[s9]: Callback had no clause for ~p, postponing~n", [{ack}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> after_transition(Next)
        end;
      not_ready ->
        io:format("gen_a[s9]: Postponing not-ready event ~p~n", [{ack}]),
        {keep_state, Data, [postpone]}
    end;
s9(cast, {_BPid, {fibonacci_2, {Num}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_a[s9]: Purging stale event ~p~n", [{fibonacci_2, {Num}}]),
        {keep_state, Data};
      false ->
        io:format("gen_a[s9]: Postponing event ~p~n", [{fibonacci_2, {Num}}]),
        {keep_state, Data, [postpone]}
    end.


%% ---------- Send helpers----------

-spec send_s5_fibonacci_1(BPid :: pid(), term(), _Data :: state_data()) -> ok.
send_s5_fibonacci_1(BPid, Num, _Data) ->
    Path = branch_path(mc1, left),
    set_current_path(Path),
    gen_statem:cast(BPid, {self(), {fibonacci_1, {Num}}, Path}).


-spec send_s5_fibonacci_1(BPid :: pid(), _Data :: state_data()) -> ok.
send_s5_fibonacci_1(BPid, _Data) ->
    Path = branch_path(mc1, left),
    set_current_path(Path),
    gen_statem:cast(BPid, {self(), {fibonacci_1}, Path}).


-spec send_s5_stop(BPid :: pid(), _Data :: state_data()) -> ok.
send_s5_stop(BPid, _Data) ->
    Path = branch_path(mc1, left),
    set_current_path(Path),
    gen_statem:cast(BPid, {self(), {stop}, Path}).


%% ===== misc OTP =====
-spec code_change(OldVsn :: term(), StateName :: atom(), StateData :: state_data(), Extra :: term()) ->
    {ok, state_data()}.
code_change(_Vsn, _StateName, StateData, _Extra) ->
    {ok, StateData}.

-spec terminate(Reason :: term(), State :: atom(), Data :: state_data()) -> ok.
terminate(_Reason, _State, _StateData) ->
    ok.


get_commit() -> case get(commit_map) of undefined -> #{}; M -> M end.
set_commit(M) -> put(commit_map, M), M.

init_context() ->
    set_current_path([]),
    set_commit(#{}),
    ok.

-spec current_path() -> [left | right].
current_path() -> case get(mc_path) of undefined -> []; Path -> Path end.

set_current_path(Path) -> put(mc_path, Path), Path.

enter_mc(McId) ->
    Prefix = current_path(),
    set_commit(maps:put(Prefix, {McId, none}, get_commit())),
    ok.

active_prefix(McId) ->
    Current = current_path(),
    Candidates = lists:filtermap(
      fun({Prefix, {FrameMc, _Side}}) ->
        case FrameMc =:= McId andalso lists:prefix(Prefix, Current) of
          true -> {true, {length(Prefix), Prefix}};
          false -> false
        end
      end, maps:to_list(get_commit())),
    case Candidates of
      [] -> error({missing_mixed_choice, McId, Current});
      _ -> element(2, lists:max(Candidates))
    end.

branch_path(McId, Side) when Side =:= left; Side =:= right ->
    active_prefix(McId) ++ [Side].

commit_current(McId, Side) when Side =:= left; Side =:= right ->
    Prefix = active_prefix(McId),
    set_commit(maps:put(Prefix, {McId, Side}, get_commit())),
    set_current_path(Prefix ++ [Side]),
    ok.


commit_if_taken(Next, McId, Side) ->
    case Next of
      {keep_state, _} -> Next;
      {keep_state, _, _} -> Next;
      _ -> commit_current(McId, Side), Next
    end.

after_transition({next_state, s5, _} = Next) -> enter_mc(mc1), Next;
after_transition({next_state, s5, _, _} = Next) -> enter_mc(mc1), Next;
after_transition(Next) -> Next.

message_status(Path, Expected) ->
    case stale(Path) of
      true -> stale;
      false when Path =:= Expected -> ready;
      false -> not_ready
    end.

-spec stale([left | right]) -> boolean().
stale(Path) when is_list(Path) -> stale(Path, [], get_commit()).

stale([], _Prefix, _Frames) -> false;
stale([Side | Rest], Prefix, Frames) ->
    case maps:find(Prefix, Frames) of
      {ok, {_McId, Commit}} when Commit =/= none, Commit =/= Side -> true;
      _ -> stale(Rest, Prefix ++ [Side], Frames)
    end.

