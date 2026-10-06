
%%%-------------------------------------------------------------------
%%% gen_storage.erl — generated generic behaviour module (gen_statem)
%%%-------------------------------------------------------------------
-module(gen_storage).
-behaviour(gen_statem).

%% Public API
-export([start_link/2, callback_mode/0]).

%% gen_statem callbacks
-export([init/1, code_change/4, terminate/3,
  s1/3,
  s3/3,
  s8/3,
  s9/3,
  s12/3,
  s15/3,
  send_s3_hard_ping/2,
  send_s9_storage_reponse/2]).

%% Types & records
-include("storage.hrl").
-export_type([state_data/0]).
-type state_data() :: #state_data{}.

-callback init(Args :: list()) -> {ok, s1, state_data()}.
-callback s1(cast, {pid(), {start_storage}}, state_data()) -> {next_state, s3, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s3(internal, {hard_ping}, state_data()) -> {next_state, s8, state_data()} | {next_state, s8, state_data(), [{next_event, internal, {hard_ping}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s8(cast, {pid(), {cancel_ack}} | {pid(), {prepare_shutdown}} | {pid(), {storage_request}} | {pid(), {timeout_notice}}, state_data()) -> {next_state, s12, state_data()} | {next_state, s15, state_data()} | {next_state, s8, state_data()} | {next_state, s9, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s9(internal, {storage_reponse}, state_data()) -> {next_state, s8, state_data()} | {next_state, s8, state_data(), [{next_event, internal, {storage_reponse}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s12(cast, {pid(), {storage_restart}}, state_data()) -> {next_state, s8, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s15(cast, {pid(), {shutdown_storage}}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.

%% ===== API =====
-spec start_link(CallbackModule :: module(), Args :: list()) ->
    {ok, pid()} | {error, term()}.
start_link(CallbackModule, Args) ->
    case code:ensure_loaded(CallbackModule) of
        {module, CallbackModule} ->
            gen_statem:start_link({local, CallbackModule}, gen_storage, {CallbackModule, Args}, [{debug, [trace, {log_to_file, "storage_debug.log"}]}]);
        {error, Reason} ->
            {error, Reason}
    end.

-spec callback_mode() -> state_functions.
callback_mode() -> state_functions.

%% ===== gen_statem =====
-spec init({module(), list()}) ->
    {ok, s1, state_data()}.
init({CallbackModule, _Args}) ->
    io:format("storage: Initializing with callback module ~p~n", [CallbackModule]),
    put(callback_module, CallbackModule),
    init_context(),
    CallbackModule:init([]).

%% ---------- State functions----------
-spec s1(cast, {pid(), {start_storage}}, state_data()) -> {next_state, s3, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
s1(cast, {ControllerPid, {start_storage}}, Data) ->
    CallbackModule = get(callback_module),
    Next = try CallbackModule:s1(cast, {ControllerPid, {start_storage}}, Data)
           catch error:function_clause ->
             io:format("gen_storage[s1]: Callback had no clause for ~p, ignoring~n", [{start_storage}]),
             {keep_state, Data}
           end,
    after_transition(Next);
s1(cast, {_From, _Msg, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_storage[s1]: Purging stale early-path event ~p~n", [_Msg]),
        {keep_state, Data};
      false ->
        io:format("gen_storage[s1]: Postponing early-path event ~p~n", [_Msg]),
        {keep_state, Data, [postpone]}
    end.

-spec s3(internal, {hard_ping}, state_data()) -> {next_state, s8, state_data()} | {next_state, s8, state_data(), [{next_event, internal, {hard_ping}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s3(internal, {hard_ping}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s3(internal, {hard_ping}, Data),
    after_transition(Next);
s3(cast, {_From, _Msg, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_storage[s3]: Purging stale early-path event ~p~n", [_Msg]),
        {keep_state, Data};
      false ->
        io:format("gen_storage[s3]: Postponing early-path event ~p~n", [_Msg]),
        {keep_state, Data, [postpone]}
    end.

%% Mixed-choice entry state
-spec s8(cast, {pid(), {cancel_ack}, list()} | {pid(), {storage_request}, list()} | {pid(), {timeout_notice}, list()} | {pid(), {prepare_shutdown}, list()}, state_data()) -> {next_state, s12, state_data()} | {next_state, s15, state_data()} | {next_state, s8, state_data()} | {next_state, s9, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
s8(cast, {APIPid, {prepare_shutdown}, Path}, Data) ->
    case message_status(Path, branch_path(mc1, left)) of
      stale ->
        io:format("gen_storage[s8]: Purging stale event ~p~n", [{prepare_shutdown}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s8(cast, {APIPid, {prepare_shutdown}}, Data)
               catch error:function_clause ->
                 io:format("gen_storage[s8]: Callback had no clause for ~p, postponing~n", [{prepare_shutdown}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {next_state, s15, _} -> after_transition(commit_if_taken(Next, mc1, left));
          {next_state, s15, _, _} -> after_transition(commit_if_taken(Next, mc1, left));
          _ -> after_transition(Next)
        end;
      not_ready ->
        io:format("gen_storage[s8]: Postponing not-ready event ~p~n", [{prepare_shutdown}]),
        {keep_state, Data, [postpone]}
    end;
s8(cast, {APIPid, {storage_request}, Path}, Data) ->
    case message_status(Path, branch_path(mc1, left)) of
      stale ->
        io:format("gen_storage[s8]: Purging stale event ~p~n", [{storage_request}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s8(cast, {APIPid, {storage_request}}, Data)
               catch error:function_clause ->
                 io:format("gen_storage[s8]: Callback had no clause for ~p, postponing~n", [{storage_request}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {next_state, s9, _} -> after_transition(commit_if_taken(Next, mc1, left));
          {next_state, s9, _, _} -> after_transition(commit_if_taken(Next, mc1, left));
          _ -> after_transition(Next)
        end;
      not_ready ->
        io:format("gen_storage[s8]: Postponing not-ready event ~p~n", [{storage_request}]),
        {keep_state, Data, [postpone]}
    end;
s8(cast, {ControllerPid, {timeout_notice}, Path}, Data) ->
    case message_status(Path, branch_path(mc1, right)) of
      stale ->
        io:format("gen_storage[s8]: Purging stale event ~p~n", [{timeout_notice}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s8(cast, {ControllerPid, {timeout_notice}}, Data)
               catch error:function_clause ->
                 io:format("gen_storage[s8]: Callback had no clause for ~p, postponing~n", [{timeout_notice}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {next_state, s8, _} -> after_transition(commit_if_taken(Next, mc1, right));
          {next_state, s8, _, _} -> after_transition(commit_if_taken(Next, mc1, right));
          _ -> after_transition(Next)
        end;
      not_ready ->
        io:format("gen_storage[s8]: Postponing not-ready event ~p~n", [{timeout_notice}]),
        {keep_state, Data, [postpone]}
    end;
s8(cast, {APIPid, {cancel_ack}, Path}, Data) ->
    case message_status(Path, branch_path(mc1, left)) of
      stale ->
        io:format("gen_storage[s8]: Purging stale event ~p~n", [{cancel_ack}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s8(cast, {APIPid, {cancel_ack}}, Data)
               catch error:function_clause ->
                 io:format("gen_storage[s8]: Callback had no clause for ~p, postponing~n", [{cancel_ack}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {next_state, s12, _} -> after_transition(commit_if_taken(Next, mc1, left));
          {next_state, s12, _, _} -> after_transition(commit_if_taken(Next, mc1, left));
          _ -> after_transition(Next)
        end;
      not_ready ->
        io:format("gen_storage[s8]: Postponing not-ready event ~p~n", [{cancel_ack}]),
        {keep_state, Data, [postpone]}
    end;
s8(cast, {_ControllerPid, {start_storage}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_storage[s8]: Purging stale event ~p~n", [{start_storage}]),
        {keep_state, Data};
      false ->
        io:format("gen_storage[s8]: Postponing event ~p~n", [{start_storage}]),
        {keep_state, Data, [postpone]}
    end;
s8(cast, {_ControllerPid, {storage_restart}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_storage[s8]: Purging stale event ~p~n", [{storage_restart}]),
        {keep_state, Data};
      false ->
        io:format("gen_storage[s8]: Postponing event ~p~n", [{storage_restart}]),
        {keep_state, Data, [postpone]}
    end;
s8(cast, {_ControllerPid, {shutdown_storage}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_storage[s8]: Purging stale event ~p~n", [{shutdown_storage}]),
        {keep_state, Data};
      false ->
        io:format("gen_storage[s8]: Postponing event ~p~n", [{shutdown_storage}]),
        {keep_state, Data, [postpone]}
    end.

-spec s9(internal, {storage_reponse}, state_data()) -> {next_state, s8, state_data()} | {next_state, s8, state_data(), [{next_event, internal, {storage_reponse}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s9(internal, {storage_reponse}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s9(internal, {storage_reponse}, Data),
    after_transition(Next);
s9(cast, {_ControllerPid, {start_storage}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_storage[s9]: Purging stale event ~p~n", [{start_storage}]),
        {keep_state, Data};
      false ->
        io:format("gen_storage[s9]: Postponing event ~p~n", [{start_storage}]),
        {keep_state, Data, [postpone]}
    end;
s9(cast, {_APIPid, {prepare_shutdown}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_storage[s9]: Purging stale event ~p~n", [{prepare_shutdown}]),
        {keep_state, Data};
      false ->
        io:format("gen_storage[s9]: Postponing event ~p~n", [{prepare_shutdown}]),
        {keep_state, Data, [postpone]}
    end;
s9(cast, {_APIPid, {storage_request}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_storage[s9]: Purging stale event ~p~n", [{storage_request}]),
        {keep_state, Data};
      false ->
        io:format("gen_storage[s9]: Postponing event ~p~n", [{storage_request}]),
        {keep_state, Data, [postpone]}
    end;
s9(cast, {ControllerPid, {timeout_notice}, Path}, Data) ->
    case message_status(Path, branch_path(mc1, right)) of
      stale ->
        io:format("gen_storage[s9]: Purging stale interrupt ~p~n", [{timeout_notice}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s8(cast, {ControllerPid, {timeout_notice}}, Data)
               catch error:function_clause ->
                 io:format("gen_storage[s9]: Callback had no interrupt clause for ~p, postponing~n", [{timeout_notice}]),
                 {keep_state, Data, [postpone]}
               end,
        after_transition(commit_if_taken(Next, mc1, right));
      not_ready ->
        io:format("gen_storage[s9]: Postponing not-ready interrupt ~p~n", [{timeout_notice}]),
        {keep_state, Data, [postpone]}
    end;
s9(cast, {_APIPid, {cancel_ack}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_storage[s9]: Purging stale event ~p~n", [{cancel_ack}]),
        {keep_state, Data};
      false ->
        io:format("gen_storage[s9]: Postponing event ~p~n", [{cancel_ack}]),
        {keep_state, Data, [postpone]}
    end;
s9(cast, {_ControllerPid, {storage_restart}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_storage[s9]: Purging stale event ~p~n", [{storage_restart}]),
        {keep_state, Data};
      false ->
        io:format("gen_storage[s9]: Postponing event ~p~n", [{storage_restart}]),
        {keep_state, Data, [postpone]}
    end;
s9(cast, {_ControllerPid, {shutdown_storage}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_storage[s9]: Purging stale event ~p~n", [{shutdown_storage}]),
        {keep_state, Data};
      false ->
        io:format("gen_storage[s9]: Postponing event ~p~n", [{shutdown_storage}]),
        {keep_state, Data, [postpone]}
    end.

-spec s12(cast, {pid(), {storage_restart}, list()}, state_data()) -> {next_state, s8, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
s12(cast, {ControllerPid, {storage_restart}, Path}, Data) ->
    case message_status(Path, current_path()) of
      stale ->
        io:format("gen_storage[s12]: Purging stale event ~p~n", [{storage_restart}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s12(cast, {ControllerPid, {storage_restart}}, Data)
               catch error:function_clause ->
                 io:format("gen_storage[s12]: Callback had no clause for ~p, postponing~n", [{storage_restart}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> after_transition(Next)
        end;
      not_ready ->
        io:format("gen_storage[s12]: Postponing not-ready event ~p~n", [{storage_restart}]),
        {keep_state, Data, [postpone]}
    end;
s12(cast, {_ControllerPid, {start_storage}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_storage[s12]: Purging stale event ~p~n", [{start_storage}]),
        {keep_state, Data};
      false ->
        io:format("gen_storage[s12]: Postponing event ~p~n", [{start_storage}]),
        {keep_state, Data, [postpone]}
    end;
s12(cast, {_APIPid, {prepare_shutdown}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_storage[s12]: Purging stale event ~p~n", [{prepare_shutdown}]),
        {keep_state, Data};
      false ->
        io:format("gen_storage[s12]: Postponing event ~p~n", [{prepare_shutdown}]),
        {keep_state, Data, [postpone]}
    end;
s12(cast, {_APIPid, {storage_request}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_storage[s12]: Purging stale event ~p~n", [{storage_request}]),
        {keep_state, Data};
      false ->
        io:format("gen_storage[s12]: Postponing event ~p~n", [{storage_request}]),
        {keep_state, Data, [postpone]}
    end;
s12(cast, {ControllerPid, {timeout_notice}, Path}, Data) ->
    case message_status(Path, branch_path(mc1, right)) of
      stale ->
        io:format("gen_storage[s12]: Purging stale interrupt ~p~n", [{timeout_notice}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s8(cast, {ControllerPid, {timeout_notice}}, Data)
               catch error:function_clause ->
                 io:format("gen_storage[s12]: Callback had no interrupt clause for ~p, postponing~n", [{timeout_notice}]),
                 {keep_state, Data, [postpone]}
               end,
        after_transition(commit_if_taken(Next, mc1, right));
      not_ready ->
        io:format("gen_storage[s12]: Postponing not-ready interrupt ~p~n", [{timeout_notice}]),
        {keep_state, Data, [postpone]}
    end;
s12(cast, {_APIPid, {cancel_ack}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_storage[s12]: Purging stale event ~p~n", [{cancel_ack}]),
        {keep_state, Data};
      false ->
        io:format("gen_storage[s12]: Postponing event ~p~n", [{cancel_ack}]),
        {keep_state, Data, [postpone]}
    end;
s12(cast, {_ControllerPid, {shutdown_storage}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_storage[s12]: Purging stale event ~p~n", [{shutdown_storage}]),
        {keep_state, Data};
      false ->
        io:format("gen_storage[s12]: Postponing event ~p~n", [{shutdown_storage}]),
        {keep_state, Data, [postpone]}
    end.

-spec s15(cast, {pid(), {shutdown_storage}, list()}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
s15(cast, {ControllerPid, {shutdown_storage}, Path}, Data) ->
    case message_status(Path, current_path()) of
      stale ->
        io:format("gen_storage[s15]: Purging stale event ~p~n", [{shutdown_storage}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s15(cast, {ControllerPid, {shutdown_storage}}, Data)
               catch error:function_clause ->
                 io:format("gen_storage[s15]: Callback had no clause for ~p, postponing~n", [{shutdown_storage}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> after_transition(Next)
        end;
      not_ready ->
        io:format("gen_storage[s15]: Postponing not-ready event ~p~n", [{shutdown_storage}]),
        {keep_state, Data, [postpone]}
    end;
s15(cast, {_ControllerPid, {start_storage}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_storage[s15]: Purging stale event ~p~n", [{start_storage}]),
        {keep_state, Data};
      false ->
        io:format("gen_storage[s15]: Postponing event ~p~n", [{start_storage}]),
        {keep_state, Data, [postpone]}
    end;
s15(cast, {_APIPid, {prepare_shutdown}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_storage[s15]: Purging stale event ~p~n", [{prepare_shutdown}]),
        {keep_state, Data};
      false ->
        io:format("gen_storage[s15]: Postponing event ~p~n", [{prepare_shutdown}]),
        {keep_state, Data, [postpone]}
    end;
s15(cast, {_APIPid, {storage_request}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_storage[s15]: Purging stale event ~p~n", [{storage_request}]),
        {keep_state, Data};
      false ->
        io:format("gen_storage[s15]: Postponing event ~p~n", [{storage_request}]),
        {keep_state, Data, [postpone]}
    end;
s15(cast, {ControllerPid, {timeout_notice}, Path}, Data) ->
    case message_status(Path, branch_path(mc1, right)) of
      stale ->
        io:format("gen_storage[s15]: Purging stale interrupt ~p~n", [{timeout_notice}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s8(cast, {ControllerPid, {timeout_notice}}, Data)
               catch error:function_clause ->
                 io:format("gen_storage[s15]: Callback had no interrupt clause for ~p, postponing~n", [{timeout_notice}]),
                 {keep_state, Data, [postpone]}
               end,
        after_transition(commit_if_taken(Next, mc1, right));
      not_ready ->
        io:format("gen_storage[s15]: Postponing not-ready interrupt ~p~n", [{timeout_notice}]),
        {keep_state, Data, [postpone]}
    end;
s15(cast, {_APIPid, {cancel_ack}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_storage[s15]: Purging stale event ~p~n", [{cancel_ack}]),
        {keep_state, Data};
      false ->
        io:format("gen_storage[s15]: Postponing event ~p~n", [{cancel_ack}]),
        {keep_state, Data, [postpone]}
    end;
s15(cast, {_ControllerPid, {storage_restart}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_storage[s15]: Purging stale event ~p~n", [{storage_restart}]),
        {keep_state, Data};
      false ->
        io:format("gen_storage[s15]: Postponing event ~p~n", [{storage_restart}]),
        {keep_state, Data, [postpone]}
    end.


%% ---------- Send helpers----------

-spec send_s3_hard_ping(ControllerPid :: pid(), _Data :: state_data()) -> ok.
send_s3_hard_ping(ControllerPid, _Data) ->
    gen_statem:cast(ControllerPid, {self(), {hard_ping}}).


-spec send_s9_storage_reponse(APIPid :: pid(), _Data :: state_data()) -> ok.
send_s9_storage_reponse(APIPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(APIPid, {self(), {storage_reponse}, Path}).


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

