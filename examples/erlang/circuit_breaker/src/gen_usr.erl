
%%%-------------------------------------------------------------------
%%% gen_usr.erl — generated generic behaviour module (gen_statem)
%%%-------------------------------------------------------------------
-module(gen_usr).
-behaviour(gen_statem).

%% Public API
-export([start_link/2, callback_mode/0]).

%% gen_statem callbacks
-export([init/1, code_change/4, terminate/3,
  s1/3,
  s4/3,
  s8/3,
  send_s4_request/2]).

%% Types & records
-include("usr.hrl").
-export_type([state_data/0]).
-type state_data() :: #state_data{}.

-callback init(Args :: list()) -> {ok, s1, state_data()}.
-callback s1(cast, {pid(), {ready}}, state_data()) -> {next_state, s4, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s4(internal, {request}, state_data()) -> {next_state, s8, state_data()} | {next_state, s8, state_data(), [{next_event, internal, {request}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s8(cast, {pid(), {api_response}} | {pid(), {error_response}} | {pid(), {shutdown_user}} | {pid(), {timeout_notice}}, state_data()) -> {next_state, s4, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.

%% ===== API =====
-spec start_link(CallbackModule :: module(), Args :: list()) ->
    {ok, pid()} | {error, term()}.
start_link(CallbackModule, Args) ->
    case code:ensure_loaded(CallbackModule) of
        {module, CallbackModule} ->
            gen_statem:start_link({local, CallbackModule}, gen_usr, {CallbackModule, Args}, [{debug, [trace, {log_to_file, "usr_debug.log"}]}]);
        {error, Reason} ->
            {error, Reason}
    end.

-spec callback_mode() -> state_functions.
callback_mode() -> state_functions.

%% ===== gen_statem =====
-spec init({module(), list()}) ->
    {ok, s1, state_data()}.
init({CallbackModule, _Args}) ->
    io:format("usr: Initializing with callback module ~p~n", [CallbackModule]),
    put(callback_module, CallbackModule),
    init_context(),
    CallbackModule:init([]).

%% ---------- State functions----------
-spec s1(cast, {pid(), {ready}}, state_data()) -> {next_state, s4, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
s1(cast, {APIPid, {ready}}, Data) ->
    CallbackModule = get(callback_module),
    Next = try CallbackModule:s1(cast, {APIPid, {ready}}, Data)
           catch error:function_clause ->
             io:format("gen_usr[s1]: Callback had no clause for ~p, ignoring~n", [{ready}]),
             {keep_state, Data}
           end,
    after_transition(Next);
s1(cast, {_From, _Msg, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_usr[s1]: Purging stale early-path event ~p~n", [_Msg]),
        {keep_state, Data};
      false ->
        io:format("gen_usr[s1]: Postponing early-path event ~p~n", [_Msg]),
        {keep_state, Data, [postpone]}
    end.

-spec s4(internal, {request}, state_data()) -> {next_state, s8, state_data()} | {next_state, s8, state_data(), [{next_event, internal, {request}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s4(internal, {request}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s4(internal, {request}, Data),
    after_transition(Next);
s4(cast, {_From, _Msg, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_usr[s4]: Purging stale early-path event ~p~n", [_Msg]),
        {keep_state, Data};
      false ->
        io:format("gen_usr[s4]: Postponing early-path event ~p~n", [_Msg]),
        {keep_state, Data, [postpone]}
    end.

%% Mixed-choice entry state
-spec s8(cast, {pid(), {error_response}, list()} | {pid(), {api_response}, list()} | {pid(), {timeout_notice}, list()} | {pid(), {shutdown_user}, list()}, state_data()) -> {next_state, s4, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
s8(cast, {APIPid, {timeout_notice}, Path}, Data) ->
    case message_status(Path, branch_path(mc1, right)) of
      stale ->
        io:format("gen_usr[s8]: Purging stale event ~p~n", [{timeout_notice}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s8(cast, {APIPid, {timeout_notice}}, Data)
               catch error:function_clause ->
                 io:format("gen_usr[s8]: Callback had no clause for ~p, postponing~n", [{timeout_notice}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {next_state, s4, _} -> after_transition(commit_if_taken(Next, mc1, right));
          {next_state, s4, _, _} -> after_transition(commit_if_taken(Next, mc1, right));
          _ -> after_transition(Next)
        end;
      not_ready ->
        io:format("gen_usr[s8]: Postponing not-ready event ~p~n", [{timeout_notice}]),
        {keep_state, Data, [postpone]}
    end;
s8(cast, {APIPid, {api_response}, Path}, Data) ->
    case message_status(Path, branch_path(mc1, left)) of
      stale ->
        io:format("gen_usr[s8]: Purging stale event ~p~n", [{api_response}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s8(cast, {APIPid, {api_response}}, Data)
               catch error:function_clause ->
                 io:format("gen_usr[s8]: Callback had no clause for ~p, postponing~n", [{api_response}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {next_state, s4, _} -> after_transition(commit_if_taken(Next, mc1, left));
          {next_state, s4, _, _} -> after_transition(commit_if_taken(Next, mc1, left));
          _ -> after_transition(Next)
        end;
      not_ready ->
        io:format("gen_usr[s8]: Postponing not-ready event ~p~n", [{api_response}]),
        {keep_state, Data, [postpone]}
    end;
s8(cast, {APIPid, {error_response}, Path}, Data) ->
    case message_status(Path, branch_path(mc1, left)) of
      stale ->
        io:format("gen_usr[s8]: Purging stale event ~p~n", [{error_response}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s8(cast, {APIPid, {error_response}}, Data)
               catch error:function_clause ->
                 io:format("gen_usr[s8]: Callback had no clause for ~p, postponing~n", [{error_response}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {next_state, s4, _} -> after_transition(commit_if_taken(Next, mc1, left));
          {next_state, s4, _, _} -> after_transition(commit_if_taken(Next, mc1, left));
          _ -> after_transition(Next)
        end;
      not_ready ->
        io:format("gen_usr[s8]: Postponing not-ready event ~p~n", [{error_response}]),
        {keep_state, Data, [postpone]}
    end;
s8(cast, {APIPid, {shutdown_user}, Path}, Data) ->
    case message_status(Path, branch_path(mc1, left)) of
      stale ->
        io:format("gen_usr[s8]: Purging stale event ~p~n", [{shutdown_user}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s8(cast, {APIPid, {shutdown_user}}, Data)
               catch error:function_clause ->
                 io:format("gen_usr[s8]: Callback had no clause for ~p, postponing~n", [{shutdown_user}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {stop, _, _} -> after_transition(commit_if_taken(Next, mc1, left));
          _ -> after_transition(Next)
        end;
      not_ready ->
        io:format("gen_usr[s8]: Postponing not-ready event ~p~n", [{shutdown_user}]),
        {keep_state, Data, [postpone]}
    end;
s8(cast, {_APIPid, {ready}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_usr[s8]: Purging stale event ~p~n", [{ready}]),
        {keep_state, Data};
      false ->
        io:format("gen_usr[s8]: Postponing event ~p~n", [{ready}]),
        {keep_state, Data, [postpone]}
    end.


%% ---------- Send helpers----------

-spec send_s4_request(APIPid :: pid(), _Data :: state_data()) -> ok.
send_s4_request(APIPid, _Data) ->
    gen_statem:cast(APIPid, {self(), {request}}).


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

