
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
-callback s8(cast, {pid(), {cancel_ack}} | {pid(), {prepare_shutdown}} | {pid(), {storage_request}} | {pid(), {timeout_notice}}, state_data()) -> {next_state, s12, state_data()} | {next_state, s15, state_data()} | {next_state, s9, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s9(internal, {storage_reponse}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s12(cast, {pid(), {storage_restart}}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
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
    set_commit(#{}),
    CallbackModule:init([]).

%% ---------- State functions----------
-spec s1(cast, {pid(), {start_storage}}, state_data()) -> {next_state, s3, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
s1(cast, {ControllerPid, {start_storage}}, Data) ->
    CallbackModule = get(callback_module),
    try CallbackModule:s1(cast, {ControllerPid, {start_storage}}, Data)
    catch error:function_clause ->
      io:format("gen_storage[s1]: Callback had no clause for ~p, ignoring~n", [{start_storage}]),
      {keep_state, Data}
    end;
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
        Next;
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
-spec s8(cast, {pid(), {cancel_ack}, list()} | {pid(), {storage_request}, list()} | {pid(), {timeout_notice}, list()} | {pid(), {prepare_shutdown}, list()}, state_data()) -> {next_state, s12, state_data()} | {next_state, s15, state_data()} | {next_state, s9, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
s8(cast, {APIPid, {prepare_shutdown}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_storage[s8]: Purging stale event ~p~n", [{prepare_shutdown}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s8(cast, {APIPid, {prepare_shutdown}}, Data)
               catch error:function_clause ->
                 io:format("gen_storage[s8]: Callback had no clause for ~p, postponing~n", [{prepare_shutdown}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {next_state, s9, _} -> commit_entry(mc1, left), Next;
          {next_state, s9, _, _} -> commit_entry(mc1, left), Next;
          _ -> Next
        end
    end;
s8(cast, {ControllerPid, {timeout_notice}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_storage[s8]: Purging stale event ~p~n", [{timeout_notice}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s8(cast, {ControllerPid, {timeout_notice}}, Data)
               catch error:function_clause ->
                 io:format("gen_storage[s8]: Callback had no clause for ~p, postponing~n", [{timeout_notice}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {next_state, s9, _} -> commit_entry(mc1, left), Next;
          {next_state, s9, _, _} -> commit_entry(mc1, left), Next;
          _ -> Next
        end
    end;
s8(cast, {APIPid, {cancel_ack}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_storage[s8]: Purging stale event ~p~n", [{cancel_ack}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s8(cast, {APIPid, {cancel_ack}}, Data)
               catch error:function_clause ->
                 io:format("gen_storage[s8]: Callback had no clause for ~p, postponing~n", [{cancel_ack}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {next_state, s9, _} -> commit_entry(mc1, left), Next;
          {next_state, s9, _, _} -> commit_entry(mc1, left), Next;
          _ -> Next
        end
    end;
s8(cast, {APIPid, {storage_request}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_storage[s8]: Purging stale event ~p~n", [{storage_request}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s8(cast, {APIPid, {storage_request}}, Data)
               catch error:function_clause ->
                 io:format("gen_storage[s8]: Callback had no clause for ~p, postponing~n", [{storage_request}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {next_state, s9, _} -> commit_entry(mc1, left), Next;
          {next_state, s9, _, _} -> commit_entry(mc1, left), Next;
          _ -> Next
        end
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

-spec s9(internal, {storage_reponse}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
s9(internal, {storage_reponse}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s9(internal, {storage_reponse}, Data),
        Next;
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
s9(cast, {_ControllerPid, {timeout_notice}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_storage[s9]: Purging stale event ~p~n", [{timeout_notice}]),
        {keep_state, Data};
      false ->
        io:format("gen_storage[s9]: Postponing event ~p~n", [{timeout_notice}]),
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

-spec s12(cast, {pid(), {storage_restart}, list()}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
s12(cast, {ControllerPid, {storage_restart}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_storage[s12]: Purging stale event ~p~n", [{storage_restart}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s12(cast, {ControllerPid, {storage_restart}}, Data)
               catch error:function_clause ->
                 io:format("gen_storage[s12]: Callback had no clause for ~p, postponing~n", [{storage_restart}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> Next
        end
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
s12(cast, {_ControllerPid, {timeout_notice}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_storage[s12]: Purging stale event ~p~n", [{timeout_notice}]),
        {keep_state, Data};
      false ->
        io:format("gen_storage[s12]: Postponing event ~p~n", [{timeout_notice}]),
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
    case stale(Path) of
      true ->
        io:format("gen_storage[s15]: Purging stale event ~p~n", [{shutdown_storage}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s15(cast, {ControllerPid, {shutdown_storage}}, Data)
               catch error:function_clause ->
                 io:format("gen_storage[s15]: Callback had no clause for ~p, postponing~n", [{shutdown_storage}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> Next
        end
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
s15(cast, {_ControllerPid, {timeout_notice}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_storage[s15]: Purging stale event ~p~n", [{timeout_notice}]),
        {keep_state, Data};
      false ->
        io:format("gen_storage[s15]: Postponing event ~p~n", [{timeout_notice}]),
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

