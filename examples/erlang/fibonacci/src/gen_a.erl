
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
  send_s5_fibonacci/2,
  send_s5_fibonacci/3,
  send_s5_stop/2]).

%% Types & records
-include("a.hrl").
-export_type([state_data/0]).
-type state_data() :: #state_data{}.

-callback init(Args :: list()) -> {ok, s5, state_data()} | {ok, s5, state_data(), [gen_statem:action()]}.
-callback s5(internal | cast, {fibonacci} | {stop} | {pid(), {error}}, state_data()) -> {next_state, s6, state_data()} | {next_state, s9, state_data()} | {next_state, s6, state_data(), [{next_event, internal, {fibonacci}}] } | {next_state, s6, state_data(), [{next_event, internal, {stop}}] } | {next_state, s9, state_data(), [{next_event, internal, {fibonacci}}] } | {next_state, s9, state_data(), [{next_event, internal, {stop}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s6(cast, {pid(), {fibonacci, {term()}}}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
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
    set_commit(#{}),
    CallbackModule:init([]).

%% ---------- State functions----------
%% Mixed-choice entry state
-spec s5(internal | cast, {fibonacci} | {stop} | {pid(), {error}, list()}, state_data()) -> {next_state, s6, state_data()} | {next_state, s9, state_data()} | {next_state, s6, state_data(), [{next_event, internal, {fibonacci}}] } | {next_state, s6, state_data(), [{next_event, internal, {stop}}] } | {next_state, s9, state_data(), [{next_event, internal, {fibonacci}}] } | {next_state, s9, state_data(), [{next_event, internal, {stop}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s5(internal, {stop}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s5(internal, {stop}, Data),
        Next;
s5(cast, {BPid, {error}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_a[s5]: Purging stale event ~p~n", [{error}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s5(cast, {BPid, {error}}, Data)
               catch error:function_clause ->
                 io:format("gen_a[s5]: Callback had no clause for ~p, postponing~n", [{error}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {next_state, s6, _} -> commit_entry(mc1, right), Next;
          {next_state, s6, _, _} -> commit_entry(mc1, right), Next;
          {next_state, s2, _} -> commit_entry(mc1, left), Next;
          {next_state, s2, _, _} -> commit_entry(mc1, left), Next;
          _ -> Next
        end
    end;
s5(internal, {fibonacci}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s5(internal, {fibonacci}, Data),
        Next;
s5(cast, {_BPid, {fibonacci, {Num}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_a[s5]: Purging stale event ~p~n", [{fibonacci, {Num}}]),
        {keep_state, Data};
      false ->
        io:format("gen_a[s5]: Postponing event ~p~n", [{fibonacci, {Num}}]),
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

-spec s6(cast, {pid(), {fibonacci, {term()}}, list()}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
s6(cast, {BPid, {fibonacci, {Num}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_a[s6]: Purging stale event ~p~n", [{fibonacci, {Num}}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s6(cast, {BPid, {fibonacci, {Num}}}, Data)
               catch error:function_clause ->
                 io:format("gen_a[s6]: Callback had no clause for ~p, postponing~n", [{fibonacci, {Num}}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> Next
        end
    end;
s6(cast, {_BPid, {error}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_a[s6]: Purging stale event ~p~n", [{error}]),
        {keep_state, Data};
      false ->
        io:format("gen_a[s6]: Postponing event ~p~n", [{error}]),
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
    case stale(Path) of
      true ->
        io:format("gen_a[s9]: Purging stale event ~p~n", [{error}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s9(cast, {BPid, {error}}, Data)
               catch error:function_clause ->
                 io:format("gen_a[s9]: Callback had no clause for ~p, postponing~n", [{error}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> Next
        end
    end;
s9(cast, {BPid, {ack}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_a[s9]: Purging stale event ~p~n", [{ack}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s9(cast, {BPid, {ack}}, Data)
               catch error:function_clause ->
                 io:format("gen_a[s9]: Callback had no clause for ~p, postponing~n", [{ack}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> Next
        end
    end;
s9(cast, {_BPid, {fibonacci, {Num}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_a[s9]: Purging stale event ~p~n", [{fibonacci, {Num}}]),
        {keep_state, Data};
      false ->
        io:format("gen_a[s9]: Postponing event ~p~n", [{fibonacci, {Num}}]),
        {keep_state, Data, [postpone]}
    end.


%% ---------- Send helpers----------

-spec send_s5_fibonacci(BPid :: pid(), _Data :: state_data()) -> ok.
send_s5_fibonacci(BPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(BPid, {self(), {fibonacci}, Path}).


-spec send_s5_fibonacci(BPid :: pid(), term(), _Data :: state_data()) -> ok.
send_s5_fibonacci(BPid, Num, _Data) ->
    Path = current_path(),
    gen_statem:cast(BPid, {self(), {fibonacci, {Num}}, Path}).


-spec send_s5_stop(BPid :: pid(), _Data :: state_data()) -> ok.
send_s5_stop(BPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(BPid, {self(), {stop}, Path}).


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

