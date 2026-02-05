
%%%-------------------------------------------------------------------
%%% gen_alice.erl — generated generic behaviour module (gen_statem)
%%%-------------------------------------------------------------------
-module(gen_alice).
-behaviour(gen_statem).

%% Public API
-export([start_link/2, callback_mode/0]).

%% gen_statem callbacks
-export([init/1, code_change/4, terminate/3,
  s4/3]).

%% Types & records
-include("alice.hrl").
-export_type([state_data/0]).
-type state_data() :: #state_data{}.

-callback init(Args :: list()) -> {ok, s4, state_data()}.
-callback s4(cast, {pid(), {cancel}} | {pid(), {diff_result, {term()}}} | {pid(), {sum_result, {term()}}}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.

%% ===== API =====
-spec start_link(CallbackModule :: module(), Args :: list()) ->
    {ok, pid()} | {error, term()}.
start_link(CallbackModule, Args) ->
    case code:ensure_loaded(CallbackModule) of
        {module, CallbackModule} ->
            gen_statem:start_link({local, CallbackModule}, gen_alice, {CallbackModule, Args}, [{debug, [trace, {log_to_file, "alice_debug.log"}]}]);
        {error, Reason} ->
            {error, Reason}
    end.

-spec callback_mode() -> state_functions.
callback_mode() -> state_functions.

%% ===== gen_statem =====
-spec init({module(), list()}) ->
    {ok, s4, state_data()}.
init({CallbackModule, _Args}) ->
    io:format("alice: Initializing with callback module ~p~n", [CallbackModule]),
    put(callback_module, CallbackModule),
    set_commit(#{}),
    CallbackModule:init([]).

%% ---------- State functions----------
%% Mixed-choice entry state
-spec s4(cast, {pid(), {cancel}, list()} | {pid(), {sum_result, {term()}}, list()} | {pid(), {diff_result, {term()}}, list()}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
s4(cast, {CarolPid, {diff_result, {Result}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_alice[s4]: Purging stale event ~p~n", [{diff_result, {Result}}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s4(cast, {CarolPid, {diff_result, {Result}}}, Data)
               catch error:function_clause ->
                 io:format("gen_alice[s4]: Callback had no clause for ~p, postponing~n", [{diff_result, {Result}}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {next_state, s2, _} -> commit_entry(mc1, left), Next;
          {next_state, s2, _, _} -> commit_entry(mc1, left), Next;
          _ -> Next
        end
    end;
s4(cast, {CarolPid, {cancel}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_alice[s4]: Purging stale event ~p~n", [{cancel}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s4(cast, {CarolPid, {cancel}}, Data)
               catch error:function_clause ->
                 io:format("gen_alice[s4]: Callback had no clause for ~p, postponing~n", [{cancel}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {next_state, s2, _} -> commit_entry(mc1, left), Next;
          {next_state, s2, _, _} -> commit_entry(mc1, left), Next;
          _ -> Next
        end
    end;
s4(cast, {CarolPid, {sum_result, {Result}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_alice[s4]: Purging stale event ~p~n", [{sum_result, {Result}}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s4(cast, {CarolPid, {sum_result, {Result}}}, Data)
               catch error:function_clause ->
                 io:format("gen_alice[s4]: Callback had no clause for ~p, postponing~n", [{sum_result, {Result}}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {next_state, s2, _} -> commit_entry(mc1, left), Next;
          {next_state, s2, _, _} -> commit_entry(mc1, left), Next;
          _ -> Next
        end
    end.


%% ---------- Send helpers----------


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



