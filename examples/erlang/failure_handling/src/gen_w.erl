
%%%-------------------------------------------------------------------
%%% gen_w.erl — generated generic behaviour module (gen_statem)
%%%-------------------------------------------------------------------
-module(gen_w).
-behaviour(gen_statem).

%% Public API
-export([start_link/2, callback_mode/0]).

%% gen_statem callbacks
-export([init/1, code_change/4, terminate/3,
  s1/3,
  s6/3,
  s7/3,
  s8/3,
  send_s6_HB/2,
  send_s7_result/2,
  send_s7_result/3]).

%% Types & records
-include("w.hrl").
-export_type([state_data/0]).
-type state_data() :: #state_data{}.

-callback init(Args :: list()) -> {ok, s1, state_data()}.
-callback s1(cast, {pid(), {init, {term()}}}, state_data()) -> {next_state, s6, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s6(internal | cast, {'HB'} | {pid(), {'Timeout'}}, state_data()) -> {next_state, s7, state_data()} | {next_state, s7, state_data(), [{next_event, internal, {'HB'}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s7(internal | cast, {result} | {pid(), {'Timeout'}}, state_data()) -> {next_state, s8, state_data()} | {next_state, s8, state_data(), [{next_event, internal, {result}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s8(cast, {pid(), {'Timeout'}} | {pid(), {more, {term()}}}, state_data()) -> {next_state, s6, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.

%% ===== API =====
-spec start_link(CallbackModule :: module(), Args :: list()) ->
    {ok, pid()} | {error, term()}.
start_link(CallbackModule, Args) ->
    case code:ensure_loaded(CallbackModule) of
        {module, CallbackModule} ->
            gen_statem:start_link({local, CallbackModule}, gen_w, {CallbackModule, Args}, [{debug, [trace, {log_to_file, "w_debug.log"}]}]);
        {error, Reason} ->
            {error, Reason}
    end.

-spec callback_mode() -> state_functions.
callback_mode() -> state_functions.

%% ===== gen_statem =====
-spec init({module(), list()}) ->
    {ok, s1, state_data()}.
init({CallbackModule, _Args}) ->
    io:format("w: Initializing with callback module ~p~n", [CallbackModule]),
    put(callback_module, CallbackModule),
    init_context(),
    CallbackModule:init([]).

%% ---------- State functions----------
-spec s1(cast, {pid(), {init, {term()}}}, state_data()) -> {next_state, s6, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
s1(cast, {MPid, {init, {Payload}}}, Data) ->
    CallbackModule = get(callback_module),
    Next = try CallbackModule:s1(cast, {MPid, {init, {Payload}}}, Data)
           catch error:function_clause ->
             io:format("gen_w[s1]: Callback had no clause for ~p, ignoring~n", [{init, {Payload}}]),
             {keep_state, Data}
           end,
    after_transition(Next);
s1(cast, {_From, _Msg, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_w[s1]: Purging stale early-path event ~p~n", [_Msg]),
        {keep_state, Data};
      false ->
        io:format("gen_w[s1]: Postponing early-path event ~p~n", [_Msg]),
        {keep_state, Data, [postpone]}
    end.

%% Mixed-choice entry state
-spec s6(internal | cast, {'HB'} | {pid(), {'Timeout'}, list()}, state_data()) -> {next_state, s7, state_data()} | {next_state, s7, state_data(), [{next_event, internal, {'HB'}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s6(internal, {'HB'}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s6(internal, {'HB'}, Data),
    after_transition(Next);
s6(cast, {FDPid, {'Timeout'}, Path}, Data) ->
    case message_status(Path, branch_path(mc1, right)) of
      stale ->
        io:format("gen_w[s6]: Purging stale event ~p~n", [{'Timeout'}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s6(cast, {FDPid, {'Timeout'}}, Data)
               catch error:function_clause ->
                 io:format("gen_w[s6]: Callback had no clause for ~p, postponing~n", [{'Timeout'}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {stop, _, _} -> after_transition(commit_if_taken(Next, mc1, right));
          _ -> after_transition(Next)
        end;
      not_ready ->
        io:format("gen_w[s6]: Postponing not-ready event ~p~n", [{'Timeout'}]),
        {keep_state, Data, [postpone]}
    end;
s6(cast, {_MPid, {init, {Payload}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_w[s6]: Purging stale event ~p~n", [{init, {Payload}}]),
        {keep_state, Data};
      false ->
        io:format("gen_w[s6]: Postponing event ~p~n", [{init, {Payload}}]),
        {keep_state, Data, [postpone]}
    end;
s6(cast, {_MPid, {more, {Payload}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_w[s6]: Purging stale event ~p~n", [{more, {Payload}}]),
        {keep_state, Data};
      false ->
        io:format("gen_w[s6]: Postponing event ~p~n", [{more, {Payload}}]),
        {keep_state, Data, [postpone]}
    end.

-spec s7(internal | cast, {result} | {pid(), {'Timeout'}, list()}, state_data()) -> {next_state, s8, state_data()} | {next_state, s8, state_data(), [{next_event, internal, {result}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s7(cast, {FDPid, {'Timeout'}, Path}, Data) ->
    case message_status(Path, branch_path(mc1, right)) of
      stale ->
        io:format("gen_w[s7]: Purging stale event ~p~n", [{'Timeout'}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s7(cast, {FDPid, {'Timeout'}}, Data)
               catch error:function_clause ->
                 io:format("gen_w[s7]: Callback had no clause for ~p, postponing~n", [{'Timeout'}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {stop, _, _} -> after_transition(commit_if_taken(Next, mc1, right));
          _ -> after_transition(Next)
        end;
      not_ready ->
        io:format("gen_w[s7]: Postponing not-ready event ~p~n", [{'Timeout'}]),
        {keep_state, Data, [postpone]}
    end;
s7(internal, {result}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s7(internal, {result}, Data),
    after_transition(Next);
s7(cast, {_MPid, {init, {Payload}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_w[s7]: Purging stale event ~p~n", [{init, {Payload}}]),
        {keep_state, Data};
      false ->
        io:format("gen_w[s7]: Postponing event ~p~n", [{init, {Payload}}]),
        {keep_state, Data, [postpone]}
    end;
s7(cast, {_MPid, {more, {Payload}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_w[s7]: Purging stale event ~p~n", [{more, {Payload}}]),
        {keep_state, Data};
      false ->
        io:format("gen_w[s7]: Postponing event ~p~n", [{more, {Payload}}]),
        {keep_state, Data, [postpone]}
    end.

-spec s8(cast, {pid(), {'Timeout'}, list()} | {pid(), {more, {term()}}, list()}, state_data()) -> {next_state, s6, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
s8(cast, {FDPid, {'Timeout'}, Path}, Data) ->
    case message_status(Path, branch_path(mc1, right)) of
      stale ->
        io:format("gen_w[s8]: Purging stale event ~p~n", [{'Timeout'}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s8(cast, {FDPid, {'Timeout'}}, Data)
               catch error:function_clause ->
                 io:format("gen_w[s8]: Callback had no clause for ~p, postponing~n", [{'Timeout'}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {stop, _, _} -> after_transition(commit_if_taken(Next, mc1, right));
          _ -> after_transition(Next)
        end;
      not_ready ->
        io:format("gen_w[s8]: Postponing not-ready event ~p~n", [{'Timeout'}]),
        {keep_state, Data, [postpone]}
    end;
s8(cast, {MPid, {more, {Payload}}, Path}, Data) ->
    case message_status(Path, current_path()) of
      stale ->
        io:format("gen_w[s8]: Purging stale event ~p~n", [{more, {Payload}}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s8(cast, {MPid, {more, {Payload}}}, Data)
               catch error:function_clause ->
                 io:format("gen_w[s8]: Callback had no clause for ~p, postponing~n", [{more, {Payload}}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> after_transition(Next)
        end;
      not_ready ->
        io:format("gen_w[s8]: Postponing not-ready event ~p~n", [{more, {Payload}}]),
        {keep_state, Data, [postpone]}
    end;
s8(cast, {_MPid, {init, {Payload}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_w[s8]: Purging stale event ~p~n", [{init, {Payload}}]),
        {keep_state, Data};
      false ->
        io:format("gen_w[s8]: Postponing event ~p~n", [{init, {Payload}}]),
        {keep_state, Data, [postpone]}
    end.


%% ---------- Send helpers----------

-spec send_s6_HB(FDPid :: pid(), _Data :: state_data()) -> ok.
send_s6_HB(FDPid, _Data) ->
    Path = branch_path(mc1, left),
    set_current_path(Path),
    gen_statem:cast(FDPid, {self(), {'HB'}, Path}).


-spec send_s7_result(MPid :: pid(), _Data :: state_data()) -> ok.
send_s7_result(MPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(MPid, {self(), {result}, Path}).


-spec send_s7_result(MPid :: pid(), term(), _Data :: state_data()) -> ok.
send_s7_result(MPid, Payload, _Data) ->
    Path = current_path(),
    gen_statem:cast(MPid, {self(), {result, {Payload}}, Path}).


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

after_transition({next_state, s6, _} = Next) -> enter_mc(mc1), Next;
after_transition({next_state, s6, _, _} = Next) -> enter_mc(mc1), Next;
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

