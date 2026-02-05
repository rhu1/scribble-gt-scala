
%%%-------------------------------------------------------------------
%%% gen_a.erl — generated generic behaviour module (gen_statem)
%%%-------------------------------------------------------------------
-module(gen_a).
-behaviour(gen_statem).

%% Public API
-export([start_link/2, callback_mode/0]).

%% gen_statem callbacks
-export([init/1, code_change/4, terminate/3,
  s4/3,
  s5/3,
  s6/3,
  s7/3,
  send_s4_a1/2,
  send_s5_a2/2]).

%% Types & records
-include("a.hrl").
-export_type([state_data/0]).
-type state_data() :: #state_data{}.

-callback init(Args :: list()) -> {ok, s4, state_data(), [{next_event, internal, {a1}}]}.
-callback s4(internal | cast, {a1} | {pid(), {'TOa'}}, state_data()) -> {next_state, s5, state_data()} | {next_state, s5, state_data(), [{next_event, internal, {a1}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s5(internal | cast, {a2} | {pid(), {'TOa'}}, state_data()) -> {next_state, s6, state_data()} | {next_state, s6, state_data(), [{next_event, internal, {a2}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s6(cast, {pid(), {'TOa'}} | {pid(), {a4}}, state_data()) -> {next_state, s7, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s7(cast, {pid(), {a5}}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.

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
    {ok, s4, state_data(), [{next_event, internal, {a1}}]}.
init({CallbackModule, _Args}) ->
    io:format("a: Initializing with callback module ~p~n", [CallbackModule]),
    put(callback_module, CallbackModule),
    set_commit(#{}),
    CallbackModule:init([]).

%% ---------- State functions----------
%% Mixed-choice entry state
-spec s4(internal | cast, {a1} | {pid(), {'TOa'}, list()}, state_data()) -> {next_state, s5, state_data()} | {next_state, s5, state_data(), [{next_event, internal, {a1}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s4(cast, {BPid, {'TOa'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_a[s4]: Purging stale event ~p~n", [{'TOa'}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s4(cast, {BPid, {'TOa'}}, Data)
               catch error:function_clause ->
                 io:format("gen_a[s4]: Callback had no clause for ~p, postponing~n", [{'TOa'}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {next_state, s5, _} -> commit_entry(mc1, right), Next;
          {next_state, s5, _, _} -> commit_entry(mc1, right), Next;
          {next_state, s2, _} -> commit_entry(mc1, left), Next;
          {next_state, s2, _, _} -> commit_entry(mc1, left), Next;
          _ -> Next
        end
    end;
s4(internal, {a1}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s4(internal, {a1}, Data),
        Next;
s4(cast, {_BPid, {a4}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_a[s4]: Purging stale event ~p~n", [{a4}]),
        {keep_state, Data};
      false ->
        io:format("gen_a[s4]: Postponing event ~p~n", [{a4}]),
        {keep_state, Data, [postpone]}
    end;
s4(cast, {_CPid, {a5}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_a[s4]: Purging stale event ~p~n", [{a5}]),
        {keep_state, Data};
      false ->
        io:format("gen_a[s4]: Postponing event ~p~n", [{a5}]),
        {keep_state, Data, [postpone]}
    end.

-spec s5(internal | cast, {a2} | {pid(), {'TOa'}, list()}, state_data()) -> {next_state, s6, state_data()} | {next_state, s6, state_data(), [{next_event, internal, {a2}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s5(cast, {BPid, {'TOa'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_a[s5]: Purging stale event ~p~n", [{'TOa'}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s5(cast, {BPid, {'TOa'}}, Data)
               catch error:function_clause ->
                 io:format("gen_a[s5]: Callback had no clause for ~p, postponing~n", [{'TOa'}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> Next
        end
    end;
s5(internal, {a2}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s5(internal, {a2}, Data),
        Next;
s5(cast, {_BPid, {a4}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_a[s5]: Purging stale event ~p~n", [{a4}]),
        {keep_state, Data};
      false ->
        io:format("gen_a[s5]: Postponing event ~p~n", [{a4}]),
        {keep_state, Data, [postpone]}
    end;
s5(cast, {_CPid, {a5}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_a[s5]: Purging stale event ~p~n", [{a5}]),
        {keep_state, Data};
      false ->
        io:format("gen_a[s5]: Postponing event ~p~n", [{a5}]),
        {keep_state, Data, [postpone]}
    end.

-spec s6(cast, {pid(), {a4}, list()} | {pid(), {'TOa'}, list()}, state_data()) -> {next_state, s7, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
s6(cast, {BPid, {a4}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_a[s6]: Purging stale event ~p~n", [{a4}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s6(cast, {BPid, {a4}}, Data)
               catch error:function_clause ->
                 io:format("gen_a[s6]: Callback had no clause for ~p, postponing~n", [{a4}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> Next
        end
    end;
s6(cast, {BPid, {'TOa'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_a[s6]: Purging stale event ~p~n", [{'TOa'}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s6(cast, {BPid, {'TOa'}}, Data)
               catch error:function_clause ->
                 io:format("gen_a[s6]: Callback had no clause for ~p, postponing~n", [{'TOa'}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> Next
        end
    end;
s6(cast, {_CPid, {a5}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_a[s6]: Purging stale event ~p~n", [{a5}]),
        {keep_state, Data};
      false ->
        io:format("gen_a[s6]: Postponing event ~p~n", [{a5}]),
        {keep_state, Data, [postpone]}
    end.

-spec s7(cast, {pid(), {a5}, list()}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
s7(cast, {CPid, {a5}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_a[s7]: Purging stale event ~p~n", [{a5}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s7(cast, {CPid, {a5}}, Data)
               catch error:function_clause ->
                 io:format("gen_a[s7]: Callback had no clause for ~p, postponing~n", [{a5}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> Next
        end
    end;
s7(cast, {_BPid, {'TOa'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_a[s7]: Purging stale event ~p~n", [{'TOa'}]),
        {keep_state, Data};
      false ->
        io:format("gen_a[s7]: Postponing event ~p~n", [{'TOa'}]),
        {keep_state, Data, [postpone]}
    end;
s7(cast, {_BPid, {a4}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_a[s7]: Purging stale event ~p~n", [{a4}]),
        {keep_state, Data};
      false ->
        io:format("gen_a[s7]: Postponing event ~p~n", [{a4}]),
        {keep_state, Data, [postpone]}
    end.


%% ---------- Send helpers----------

-spec send_s4_a1(BPid :: pid(), _Data :: state_data()) -> ok.
send_s4_a1(BPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(BPid, {self(), {a1}, Path}).


-spec send_s5_a2(CPid :: pid(), _Data :: state_data()) -> ok.
send_s5_a2(CPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(CPid, {self(), {a2}, Path}).


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

