
%%%-------------------------------------------------------------------
%%% gen_q.erl — generated generic behaviour module (gen_statem)
%%%-------------------------------------------------------------------
-module(gen_q).
-behaviour(gen_statem).

%% Public API
-export([start_link/2, callback_mode/0]).

%% gen_statem callbacks
-export([init/1, code_change/4, terminate/3,
  s4/3,
  s5/3,
  s7/3,
  s10/3,
  send_s4_Interrupt/2,
  send_s10_Ack/2]).

%% Types & records
-include("q.hrl").
-export_type([state_data/0]).
-type state_data() :: #state_data{}.

-callback init(Args :: list()) -> {ok, s4, state_data(), [{next_event, internal, {'Interrupt'}}]}.
-callback s4(internal | cast, {'Interrupt'} | {pid(), {'Start'}}, state_data()) -> {next_state, s5, state_data()} | {next_state, s5, state_data(), [{next_event, internal, {'Interrupt'}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s5(cast, {pid(), {'More'}} | {pid(), {'Stop'}}, state_data()) -> {next_state, s10, state_data()} | {next_state, s7, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s7(cast, {pid(), {'More'}}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s10(internal, {'Ack'}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.

%% ===== API =====
-spec start_link(CallbackModule :: module(), Args :: list()) ->
    {ok, pid()} | {error, term()}.
start_link(CallbackModule, Args) ->
    case code:ensure_loaded(CallbackModule) of
        {module, CallbackModule} ->
            gen_statem:start_link({local, CallbackModule}, gen_q, {CallbackModule, Args}, [{debug, [trace, {log_to_file, "q_debug.log"}]}]);
        {error, Reason} ->
            {error, Reason}
    end.

-spec callback_mode() -> state_functions.
callback_mode() -> state_functions.

%% ===== gen_statem =====
-spec init({module(), list()}) ->
    {ok, s4, state_data(), [{next_event, internal, {'Interrupt'}}]}.
init({CallbackModule, _Args}) ->
    io:format("q: Initializing with callback module ~p~n", [CallbackModule]),
    put(callback_module, CallbackModule),
    set_commit(#{}),
    CallbackModule:init([]).

%% ---------- State functions----------
%% Mixed-choice entry state
-spec s4(internal | cast, {'Interrupt'} | {pid(), {'Start'}, list()}, state_data()) -> {next_state, s5, state_data()} | {next_state, s5, state_data(), [{next_event, internal, {'Interrupt'}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s4(internal, {'Interrupt'}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s4(internal, {'Interrupt'}, Data),
        Next;
s4(cast, {PPid, {'Start'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_q[s4]: Purging stale event ~p~n", [{'Start'}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s4(cast, {PPid, {'Start'}}, Data)
               catch error:function_clause ->
                 io:format("gen_q[s4]: Callback had no clause for ~p, postponing~n", [{'Start'}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {next_state, s2, _} -> commit_entry(mc1, right), Next;
          {next_state, s2, _, _} -> commit_entry(mc1, right), Next;
          {next_state, s5, _} -> commit_entry(mc1, left), Next;
          {next_state, s5, _, _} -> commit_entry(mc1, left), Next;
          _ -> Next
        end
    end;
s4(cast, {_PPid, {'Stop'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_q[s4]: Purging stale event ~p~n", [{'Stop'}]),
        {keep_state, Data};
      false ->
        io:format("gen_q[s4]: Postponing event ~p~n", [{'Stop'}]),
        {keep_state, Data, [postpone]}
    end;
s4(cast, {_PPid, {'More'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_q[s4]: Purging stale event ~p~n", [{'More'}]),
        {keep_state, Data};
      false ->
        io:format("gen_q[s4]: Postponing event ~p~n", [{'More'}]),
        {keep_state, Data, [postpone]}
    end.

-spec s5(cast, {pid(), {'More'}, list()} | {pid(), {'Stop'}, list()}, state_data()) -> {next_state, s10, state_data()} | {next_state, s7, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
s5(cast, {PPid, {'Stop'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_q[s5]: Purging stale event ~p~n", [{'Stop'}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s5(cast, {PPid, {'Stop'}}, Data)
               catch error:function_clause ->
                 io:format("gen_q[s5]: Callback had no clause for ~p, postponing~n", [{'Stop'}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> Next
        end
    end;
s5(cast, {PPid, {'More'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_q[s5]: Purging stale event ~p~n", [{'More'}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s5(cast, {PPid, {'More'}}, Data)
               catch error:function_clause ->
                 io:format("gen_q[s5]: Callback had no clause for ~p, postponing~n", [{'More'}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> Next
        end
    end;
s5(cast, {_PPid, {'Start'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_q[s5]: Purging stale event ~p~n", [{'Start'}]),
        {keep_state, Data};
      false ->
        io:format("gen_q[s5]: Postponing event ~p~n", [{'Start'}]),
        {keep_state, Data, [postpone]}
    end.

-spec s7(cast, {pid(), {'More'}, list()}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
s7(cast, {PPid, {'More'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_q[s7]: Purging stale event ~p~n", [{'More'}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s7(cast, {PPid, {'More'}}, Data)
               catch error:function_clause ->
                 io:format("gen_q[s7]: Callback had no clause for ~p, postponing~n", [{'More'}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> Next
        end
    end;
s7(cast, {_PPid, {'Start'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_q[s7]: Purging stale event ~p~n", [{'Start'}]),
        {keep_state, Data};
      false ->
        io:format("gen_q[s7]: Postponing event ~p~n", [{'Start'}]),
        {keep_state, Data, [postpone]}
    end;
s7(cast, {_PPid, {'Stop'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_q[s7]: Purging stale event ~p~n", [{'Stop'}]),
        {keep_state, Data};
      false ->
        io:format("gen_q[s7]: Postponing event ~p~n", [{'Stop'}]),
        {keep_state, Data, [postpone]}
    end.

-spec s10(internal, {'Ack'}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
s10(internal, {'Ack'}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s10(internal, {'Ack'}, Data),
        Next;
s10(cast, {_PPid, {'Start'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_q[s10]: Purging stale event ~p~n", [{'Start'}]),
        {keep_state, Data};
      false ->
        io:format("gen_q[s10]: Postponing event ~p~n", [{'Start'}]),
        {keep_state, Data, [postpone]}
    end;
s10(cast, {_PPid, {'Stop'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_q[s10]: Purging stale event ~p~n", [{'Stop'}]),
        {keep_state, Data};
      false ->
        io:format("gen_q[s10]: Postponing event ~p~n", [{'Stop'}]),
        {keep_state, Data, [postpone]}
    end;
s10(cast, {_PPid, {'More'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_q[s10]: Purging stale event ~p~n", [{'More'}]),
        {keep_state, Data};
      false ->
        io:format("gen_q[s10]: Postponing event ~p~n", [{'More'}]),
        {keep_state, Data, [postpone]}
    end.


%% ---------- Send helpers----------

-spec send_s4_Interrupt(PPid :: pid(), _Data :: state_data()) -> ok.
send_s4_Interrupt(PPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(PPid, {self(), {'Interrupt'}, Path}).


-spec send_s10_Ack(PPid :: pid(), _Data :: state_data()) -> ok.
send_s10_Ack(PPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(PPid, {self(), {'Ack'}, Path}).


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

