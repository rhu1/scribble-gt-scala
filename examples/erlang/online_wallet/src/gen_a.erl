
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
-callback s8(cast, {pid(), {end_session}} | {pid(), {keep_alive}} | {pid(), {timeout}}, state_data()) -> {next_state, s8, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
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
    init_context(),
    CallbackModule:init([]).

%% ---------- State functions----------
-spec s1(cast, {pid(), {login, {term(), term()}}}, state_data()) -> {next_state, s3, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
s1(cast, {CPid, {login, {Id, Password}}}, Data) ->
    CallbackModule = get(callback_module),
    Next = try CallbackModule:s1(cast, {CPid, {login, {Id, Password}}}, Data)
           catch error:function_clause ->
             io:format("gen_a[s1]: Callback had no clause for ~p, ignoring~n", [{login, {Id, Password}}]),
             {keep_state, Data}
           end,
    after_transition(Next);
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
    after_transition(Next);
s3(internal, {login_failed}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s3(internal, {login_failed}, Data),
    after_transition(Next);
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
    after_transition(Next);
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
-spec s8(cast, {pid(), {timeout}, list()} | {pid(), {end_session}, list()} | {pid(), {keep_alive}, list()}, state_data()) -> {next_state, s8, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
s8(cast, {CPid, {end_session}, Path}, Data) ->
    case message_status(Path, branch_path(mc1, left)) of
      stale ->
        io:format("gen_a[s8]: Purging stale event ~p~n", [{end_session}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s8(cast, {CPid, {end_session}}, Data)
               catch error:function_clause ->
                 io:format("gen_a[s8]: Callback had no clause for ~p, postponing~n", [{end_session}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {stop, _, _} -> after_transition(commit_if_taken(Next, mc1, left));
          _ -> after_transition(Next)
        end;
      not_ready ->
        io:format("gen_a[s8]: Postponing not-ready event ~p~n", [{end_session}]),
        {keep_state, Data, [postpone]}
    end;
s8(cast, {CPid, {keep_alive}, Path}, Data) ->
    case message_status(Path, branch_path(mc1, left)) of
      stale ->
        io:format("gen_a[s8]: Purging stale event ~p~n", [{keep_alive}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s8(cast, {CPid, {keep_alive}}, Data)
               catch error:function_clause ->
                 io:format("gen_a[s8]: Callback had no clause for ~p, postponing~n", [{keep_alive}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {next_state, s8, _} -> after_transition(commit_if_taken(Next, mc1, left));
          {next_state, s8, _, _} -> after_transition(commit_if_taken(Next, mc1, left));
          _ -> after_transition(Next)
        end;
      not_ready ->
        io:format("gen_a[s8]: Postponing not-ready event ~p~n", [{keep_alive}]),
        {keep_state, Data, [postpone]}
    end;
s8(cast, {SPid, {timeout}, Path}, Data) ->
    case message_status(Path, branch_path(mc1, right)) of
      stale ->
        io:format("gen_a[s8]: Purging stale event ~p~n", [{timeout}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s8(cast, {SPid, {timeout}}, Data)
               catch error:function_clause ->
                 io:format("gen_a[s8]: Callback had no clause for ~p, postponing~n", [{timeout}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {stop, _, _} -> after_transition(commit_if_taken(Next, mc1, right));
          _ -> after_transition(Next)
        end;
      not_ready ->
        io:format("gen_a[s8]: Postponing not-ready event ~p~n", [{timeout}]),
        {keep_state, Data, [postpone]}
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
    after_transition(Next);
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

after_transition({next_state, s8, _} = Next) -> enter_mc(mc1), Next;
after_transition({next_state, s8, _, _} = Next) -> enter_mc(mc1), Next;
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

