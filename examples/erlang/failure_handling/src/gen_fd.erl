
%%%-------------------------------------------------------------------
%%% gen_fd.erl — generated generic behaviour module (gen_statem)
%%%-------------------------------------------------------------------
-module(gen_fd).
-behaviour(gen_statem).

%% Public API
-export([start_link/2, callback_mode/0]).

%% gen_statem callbacks
-export([init/1, code_change/4, terminate/3,
  s4/3,
  s6/3,
  s7/3,
  send_s4_Crash/2,
  send_s6_Timeout/2,
  send_s7_OK/2]).

%% Types & records
-include("fd.hrl").
-export_type([state_data/0]).
-type state_data() :: #state_data{}.

-callback init(Args :: list()) -> {ok, s6, state_data(), [{next_event, internal, {'Timeout'}}]}.
-callback s4(internal, {'Crash'}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s6(internal | cast, {'Timeout'} | {pid(), {'HB'}}, state_data()) -> {next_state, s4, state_data()} | {next_state, s7, state_data()} | {next_state, s4, state_data(), [{next_event, internal, {'Timeout'}}] } | {next_state, s7, state_data(), [{next_event, internal, {'Timeout'}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s7(internal, {'OK'}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.

%% ===== API =====
-spec start_link(CallbackModule :: module(), Args :: list()) ->
    {ok, pid()} | {error, term()}.
start_link(CallbackModule, Args) ->
    case code:ensure_loaded(CallbackModule) of
        {module, CallbackModule} ->
            gen_statem:start_link({local, CallbackModule}, gen_fd, {CallbackModule, Args}, [{debug, [trace, {log_to_file, "fd_debug.log"}]}]);
        {error, Reason} ->
            {error, Reason}
    end.

-spec callback_mode() -> state_functions.
callback_mode() -> state_functions.

%% ===== gen_statem =====
-spec init({module(), list()}) ->
    {ok, s6, state_data(), [{next_event, internal, {'Timeout'}}]}.
init({CallbackModule, _Args}) ->
    io:format("fd: Initializing with callback module ~p~n", [CallbackModule]),
    put(callback_module, CallbackModule),
    set_commit(#{}),
    CallbackModule:init([]).

%% ---------- State functions----------
-spec s4(internal, {'Crash'}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
s4(internal, {'Crash'}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s4(internal, {'Crash'}, Data),
        Next;
s4(cast, {_WPid, {'HB'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_fd[s4]: Purging stale event ~p~n", [{'HB'}]),
        {keep_state, Data};
      false ->
        io:format("gen_fd[s4]: Postponing event ~p~n", [{'HB'}]),
        {keep_state, Data, [postpone]}
    end.

%% Mixed-choice entry state
-spec s6(internal | cast, {'Timeout'} | {pid(), {'HB'}, list()}, state_data()) -> {next_state, s4, state_data()} | {next_state, s7, state_data()} | {next_state, s4, state_data(), [{next_event, internal, {'Timeout'}}] } | {next_state, s7, state_data(), [{next_event, internal, {'Timeout'}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s6(cast, {WPid, {'HB'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_fd[s6]: Purging stale event ~p~n", [{'HB'}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s6(cast, {WPid, {'HB'}}, Data)
               catch error:function_clause ->
                 io:format("gen_fd[s6]: Callback had no clause for ~p, postponing~n", [{'HB'}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {next_state, s4, _} -> commit_entry(mc1, right), Next;
          {next_state, s4, _, _} -> commit_entry(mc1, right), Next;
          {next_state, s7, _} -> commit_entry(mc1, left), Next;
          {next_state, s7, _, _} -> commit_entry(mc1, left), Next;
          _ -> Next
        end
    end;
s6(internal, {'Timeout'}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s6(internal, {'Timeout'}, Data),
        Next.

-spec s7(internal, {'OK'}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
s7(internal, {'OK'}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s7(internal, {'OK'}, Data),
        Next;
s7(cast, {_WPid, {'HB'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_fd[s7]: Purging stale event ~p~n", [{'HB'}]),
        {keep_state, Data};
      false ->
        io:format("gen_fd[s7]: Postponing event ~p~n", [{'HB'}]),
        {keep_state, Data, [postpone]}
    end.


%% ---------- Send helpers----------

-spec send_s4_Crash(MPid :: pid(), _Data :: state_data()) -> ok.
send_s4_Crash(MPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(MPid, {self(), {'Crash'}, Path}).


-spec send_s6_Timeout(WPid :: pid(), _Data :: state_data()) -> ok.
send_s6_Timeout(WPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(WPid, {self(), {'Timeout'}, Path}).


-spec send_s7_OK(MPid :: pid(), _Data :: state_data()) -> ok.
send_s7_OK(MPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(MPid, {self(), {'OK'}, Path}).


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

