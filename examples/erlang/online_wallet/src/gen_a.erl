
%%%-------------------------------------------------------------------
%%% gen_a.erl — generated generic behaviour module (gen_statem)
%%%-------------------------------------------------------------------
-module(gen_a).
-behaviour(gen_statem).

%% Public API
-export([start_link/2, callback_mode/0]).

%% gen_statem callbacks
-export([init/1, code_change/4, terminate/3,
  s1/3,
  s3/3,
  s4/3,
  s8/3,
  s12/3,
  send_s3_login_failed/2,
  send_s3_login_success/2,
  send_s4_login_accepted/2,
  send_s12_auth_fail/2]).

%% Types & records
-include("a.hrl").
-export_type([state_data/0]).
-type state_data() :: #state_data{}.

-callback init(Args :: list()) -> {ok, s1, state_data()}.
-callback s1(cast, {pid(), {login, {term(), term()}}}, state_data()) -> {next_state, s3, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s3(internal, {login_failed} | {login_success}, state_data()) -> {next_state, s12, state_data()} | {next_state, s4, state_data()} | {next_state, s12, state_data(), [{next_event, internal, {login_failed}}] } | {next_state, s12, state_data(), [{next_event, internal, {login_success}}] } | {next_state, s4, state_data(), [{next_event, internal, {login_failed}}] } | {next_state, s4, state_data(), [{next_event, internal, {login_success}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s4(internal, {login_accepted}, state_data()) -> {next_state, s8, state_data()} | {next_state, s8, state_data(), [{next_event, internal, {login_accepted}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s8(cast, {pid(), {end_session}} | {pid(), {keep_alive}} | {pid(), {timeout}}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s12(internal, {auth_fail}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.

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
    {ok, s1, state_data()}.
init({CallbackModule, _Args}) ->
    io:format("a: Initializing with callback module ~p~n", [CallbackModule]),
    put(callback_module, CallbackModule),
    set_commit(#{}),
    CallbackModule:init([]).

%% ---------- State functions----------
-spec s1(cast, {pid(), {login, {term(), term()}}}, state_data()) -> {next_state, s3, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
s1(cast, {CPid, {login, {Id, Password}}}, Data) ->
    CallbackModule = get(callback_module),
    try CallbackModule:s1(cast, {CPid, {login, {Id, Password}}}, Data)
    catch error:function_clause ->
      io:format("gen_a[s1]: Callback had no clause for ~p, ignoring~n", [{login, {Id, Password}}]),
      {keep_state, Data}
    end;
s1(cast, {_From, _Msg, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_a[s1]: Purging stale early-path event ~p~n", [_Msg]),
        {keep_state, Data};
      false ->
        io:format("gen_a[s1]: Postponing early-path event ~p~n", [_Msg]),
        {keep_state, Data, [postpone]}
    end.

-spec s3(internal, {login_failed} | {login_success}, state_data()) -> {next_state, s12, state_data()} | {next_state, s4, state_data()} | {next_state, s12, state_data(), [{next_event, internal, {login_failed}}] } | {next_state, s12, state_data(), [{next_event, internal, {login_success}}] } | {next_state, s4, state_data(), [{next_event, internal, {login_failed}}] } | {next_state, s4, state_data(), [{next_event, internal, {login_success}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s3(internal, {login_success}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s3(internal, {login_success}, Data),
        Next;
s3(internal, {login_failed}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s3(internal, {login_failed}, Data),
        Next;
s3(cast, {_From, _Msg, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_a[s3]: Purging stale early-path event ~p~n", [_Msg]),
        {keep_state, Data};
      false ->
        io:format("gen_a[s3]: Postponing early-path event ~p~n", [_Msg]),
        {keep_state, Data, [postpone]}
    end.

-spec s4(internal, {login_accepted}, state_data()) -> {next_state, s8, state_data()} | {next_state, s8, state_data(), [{next_event, internal, {login_accepted}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s4(internal, {login_accepted}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s4(internal, {login_accepted}, Data),
        Next;
s4(cast, {_From, _Msg, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_a[s4]: Purging stale early-path event ~p~n", [_Msg]),
        {keep_state, Data};
      false ->
        io:format("gen_a[s4]: Postponing early-path event ~p~n", [_Msg]),
        {keep_state, Data, [postpone]}
    end.

%% Mixed-choice entry state
-spec s8(cast, {pid(), {timeout}, list()} | {pid(), {end_session}, list()} | {pid(), {keep_alive}, list()}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
s8(cast, {CPid, {keep_alive}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_a[s8]: Purging stale event ~p~n", [{keep_alive}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s8(cast, {CPid, {keep_alive}}, Data)
               catch error:function_clause ->
                 io:format("gen_a[s8]: Callback had no clause for ~p, postponing~n", [{keep_alive}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {next_state, s10, _} -> commit_entry(mc1, left), Next;
          {next_state, s10, _, _} -> commit_entry(mc1, left), Next;
          _ -> Next
        end
    end;
s8(cast, {CPid, {end_session}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_a[s8]: Purging stale event ~p~n", [{end_session}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s8(cast, {CPid, {end_session}}, Data)
               catch error:function_clause ->
                 io:format("gen_a[s8]: Callback had no clause for ~p, postponing~n", [{end_session}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {next_state, s10, _} -> commit_entry(mc1, left), Next;
          {next_state, s10, _, _} -> commit_entry(mc1, left), Next;
          _ -> Next
        end
    end;
s8(cast, {SPid, {timeout}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_a[s8]: Purging stale event ~p~n", [{timeout}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s8(cast, {SPid, {timeout}}, Data)
               catch error:function_clause ->
                 io:format("gen_a[s8]: Callback had no clause for ~p, postponing~n", [{timeout}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {next_state, s10, _} -> commit_entry(mc1, left), Next;
          {next_state, s10, _, _} -> commit_entry(mc1, left), Next;
          _ -> Next
        end
    end;
s8(cast, {_CPid, {login, {Id, Password}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_a[s8]: Purging stale event ~p~n", [{login, {Id, Password}}]),
        {keep_state, Data};
      false ->
        io:format("gen_a[s8]: Postponing event ~p~n", [{login, {Id, Password}}]),
        {keep_state, Data, [postpone]}
    end.

-spec s12(internal, {auth_fail}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
s12(internal, {auth_fail}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s12(internal, {auth_fail}, Data),
        Next;
s12(cast, {_From, _Msg, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_a[s12]: Purging stale early-path event ~p~n", [_Msg]),
        {keep_state, Data};
      false ->
        io:format("gen_a[s12]: Postponing early-path event ~p~n", [_Msg]),
        {keep_state, Data, [postpone]}
    end.


%% ---------- Send helpers----------

-spec send_s3_login_failed(CPid :: pid(), _Data :: state_data()) -> ok.
send_s3_login_failed(CPid, _Data) ->
    gen_statem:cast(CPid, {self(), {login_failed}}).


-spec send_s3_login_success(CPid :: pid(), _Data :: state_data()) -> ok.
send_s3_login_success(CPid, _Data) ->
    gen_statem:cast(CPid, {self(), {login_success}}).


-spec send_s4_login_accepted(SPid :: pid(), _Data :: state_data()) -> ok.
send_s4_login_accepted(SPid, _Data) ->
    gen_statem:cast(SPid, {self(), {login_accepted}}).


-spec send_s12_auth_fail(SPid :: pid(), _Data :: state_data()) -> ok.
send_s12_auth_fail(SPid, _Data) ->
    gen_statem:cast(SPid, {self(), {auth_fail}}).


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



