
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
-callback s8(cast, {pid(), {'Timeout'}} | {pid(), {more, {term()}}}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.

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
    set_commit(#{}),
    CallbackModule:init([]).

%% ---------- State functions----------
-spec s1(cast, {pid(), {init, {term()}}}, state_data()) -> {next_state, s6, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
s1(cast, {MPid, {init, {Payload}}}, Data) ->
    CallbackModule = get(callback_module),
    try CallbackModule:s1(cast, {MPid, {init, {Payload}}}, Data)
    catch error:function_clause ->
      io:format("gen_w[s1]: Callback had no clause for ~p, ignoring~n", [{init, {Payload}}]),
      {keep_state, Data}
    end;
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
        Next;
s6(cast, {FDPid, {'Timeout'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_w[s6]: Purging stale event ~p~n", [{'Timeout'}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s6(cast, {FDPid, {'Timeout'}}, Data)
               catch error:function_clause ->
                 io:format("gen_w[s6]: Callback had no clause for ~p, postponing~n", [{'Timeout'}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {next_state, s7, _} -> commit_entry(mc1, right), Next;
          {next_state, s7, _, _} -> commit_entry(mc1, right), Next;
          {next_state, s2, _} -> commit_entry(mc1, left), Next;
          {next_state, s2, _, _} -> commit_entry(mc1, left), Next;
          _ -> Next
        end
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
s7(internal, {result}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s7(internal, {result}, Data),
        Next;
s7(cast, {FDPid, {'Timeout'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_w[s7]: Purging stale event ~p~n", [{'Timeout'}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s7(cast, {FDPid, {'Timeout'}}, Data)
               catch error:function_clause ->
                 io:format("gen_w[s7]: Callback had no clause for ~p, postponing~n", [{'Timeout'}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> Next
        end
    end;
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

-spec s8(cast, {pid(), {'Timeout'}, list()} | {pid(), {more, {term()}}, list()}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
s8(cast, {FDPid, {'Timeout'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_w[s8]: Purging stale event ~p~n", [{'Timeout'}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s8(cast, {FDPid, {'Timeout'}}, Data)
               catch error:function_clause ->
                 io:format("gen_w[s8]: Callback had no clause for ~p, postponing~n", [{'Timeout'}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> Next
        end
    end;
s8(cast, {MPid, {more, {Payload}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_w[s8]: Purging stale event ~p~n", [{more, {Payload}}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s8(cast, {MPid, {more, {Payload}}}, Data)
               catch error:function_clause ->
                 io:format("gen_w[s8]: Callback had no clause for ~p, postponing~n", [{more, {Payload}}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> Next
        end
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
    Path = current_path(),
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


%% ---------- GC / commitment helpers (per-mixed-choice side) ----------
%% We track, per MC id, which side this role is committed to: left | right.
%% Uncommitted MCs have no entry.
get_commit() -> case get(commit_map) of undefined -> #{}; M -> M end.
set_commit(M) -> put(commit_map, M), M.

-spec commit_entry(atom(), left | right) -> map().
commit_entry(McId, Side) when Side =:= left; Side =:= right ->
    set_commit(maps:put(McId, Side, get_commit())).

%% Staleness follows Section 4.1: a message is stale if, for some MC on its Path,
%% following the Path hits a stale side (i.e., we are committed to the opposite side).
%% We approximate local type commitment using the commit_map.

-spec stale([{atom(), left | right}]) -> boolean().
stale(Path) when is_list(Path) ->
    Commit = get_commit(),
    lists:any(
      fun({Mc, MsgSide}) ->
        case maps:find(Mc, Commit) of
          error -> false; %% not committed => nothing is stale for this MC
          {ok, LocalSide} -> LocalSide =/= MsgSide
        end
      end, Path).


%% current_path/0 is used only to annotate outgoing messages with the sender's
%% current MC context, when this role is inside an active mixed-choice region.
-spec current_path() -> [{atom(), left | right}].
current_path() ->
    Commit = get_commit(),
    lists:sort(maps:to_list(Commit)).

