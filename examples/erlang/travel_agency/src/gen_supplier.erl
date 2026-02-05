
%%%-------------------------------------------------------------------
%%% gen_supplier.erl — generated generic behaviour module (gen_statem)
%%%-------------------------------------------------------------------
-module(gen_supplier).
-behaviour(gen_statem).

%% Public API
-export([start_link/2, callback_mode/0]).

%% gen_statem callbacks
-export([init/1, code_change/4, terminate/3,
  s5/3,
  s6/3,
  send_s6_confirm_date/2,
  send_s6_confirm_date/3]).

%% Types & records
-include("supplier.hrl").
-export_type([state_data/0]).
-type state_data() :: #state_data{}.

-callback init(Args :: list()) -> {ok, s5, state_data()}.
-callback s5(cast, {pid(), {cancel_booking}} | {pid(), {cancel_supplier}} | {pid(), {provide_address, {term()}}} | {pid(), {resubmitting}}, state_data()) -> {next_state, s6, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s6(internal, {confirm_date}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.

%% ===== API =====
-spec start_link(CallbackModule :: module(), Args :: list()) ->
    {ok, pid()} | {error, term()}.
start_link(CallbackModule, Args) ->
    case code:ensure_loaded(CallbackModule) of
        {module, CallbackModule} ->
            gen_statem:start_link({local, CallbackModule}, gen_supplier, {CallbackModule, Args}, [{debug, [trace, {log_to_file, "supplier_debug.log"}]}]);
        {error, Reason} ->
            {error, Reason}
    end.

-spec callback_mode() -> state_functions.
callback_mode() -> state_functions.

%% ===== gen_statem =====
-spec init({module(), list()}) ->
    {ok, s5, state_data()}.
init({CallbackModule, _Args}) ->
    io:format("supplier: Initializing with callback module ~p~n", [CallbackModule]),
    put(callback_module, CallbackModule),
    set_commit(#{}),
    CallbackModule:init([]).

%% ---------- State functions----------
%% Mixed-choice entry state
-spec s5(cast, {pid(), {resubmitting}, list()} | {pid(), {cancel_supplier}, list()} | {pid(), {cancel_booking}, list()} | {pid(), {provide_address, {term()}}, list()}, state_data()) -> {next_state, s6, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
s5(cast, {ClientPid, {cancel_booking}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_supplier[s5]: Purging stale event ~p~n", [{cancel_booking}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s5(cast, {ClientPid, {cancel_booking}}, Data)
               catch error:function_clause ->
                 io:format("gen_supplier[s5]: Callback had no clause for ~p, postponing~n", [{cancel_booking}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {next_state, s6, _} -> commit_entry(mc1, left), Next;
          {next_state, s6, _, _} -> commit_entry(mc1, left), Next;
          _ -> Next
        end
    end;
s5(cast, {ClientPid, {provide_address, {Address}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_supplier[s5]: Purging stale event ~p~n", [{provide_address, {Address}}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s5(cast, {ClientPid, {provide_address, {Address}}}, Data)
               catch error:function_clause ->
                 io:format("gen_supplier[s5]: Callback had no clause for ~p, postponing~n", [{provide_address, {Address}}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {next_state, s6, _} -> commit_entry(mc1, left), Next;
          {next_state, s6, _, _} -> commit_entry(mc1, left), Next;
          _ -> Next
        end
    end;
s5(cast, {ClientPid, {cancel_supplier}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_supplier[s5]: Purging stale event ~p~n", [{cancel_supplier}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s5(cast, {ClientPid, {cancel_supplier}}, Data)
               catch error:function_clause ->
                 io:format("gen_supplier[s5]: Callback had no clause for ~p, postponing~n", [{cancel_supplier}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {next_state, s6, _} -> commit_entry(mc1, left), Next;
          {next_state, s6, _, _} -> commit_entry(mc1, left), Next;
          _ -> Next
        end
    end;
s5(cast, {ClientPid, {resubmitting}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_supplier[s5]: Purging stale event ~p~n", [{resubmitting}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s5(cast, {ClientPid, {resubmitting}}, Data)
               catch error:function_clause ->
                 io:format("gen_supplier[s5]: Callback had no clause for ~p, postponing~n", [{resubmitting}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {next_state, s6, _} -> commit_entry(mc1, left), Next;
          {next_state, s6, _, _} -> commit_entry(mc1, left), Next;
          _ -> Next
        end
    end.

-spec s6(internal, {confirm_date}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
s6(internal, {confirm_date}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s6(internal, {confirm_date}, Data),
        Next;
s6(cast, {_ClientPid, {resubmitting}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_supplier[s6]: Purging stale event ~p~n", [{resubmitting}]),
        {keep_state, Data};
      false ->
        io:format("gen_supplier[s6]: Postponing event ~p~n", [{resubmitting}]),
        {keep_state, Data, [postpone]}
    end;
s6(cast, {_ClientPid, {cancel_booking}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_supplier[s6]: Purging stale event ~p~n", [{cancel_booking}]),
        {keep_state, Data};
      false ->
        io:format("gen_supplier[s6]: Postponing event ~p~n", [{cancel_booking}]),
        {keep_state, Data, [postpone]}
    end;
s6(cast, {_ClientPid, {cancel_supplier}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_supplier[s6]: Purging stale event ~p~n", [{cancel_supplier}]),
        {keep_state, Data};
      false ->
        io:format("gen_supplier[s6]: Postponing event ~p~n", [{cancel_supplier}]),
        {keep_state, Data, [postpone]}
    end;
s6(cast, {_ClientPid, {provide_address, {Address}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_supplier[s6]: Purging stale event ~p~n", [{provide_address, {Address}}]),
        {keep_state, Data};
      false ->
        io:format("gen_supplier[s6]: Postponing event ~p~n", [{provide_address, {Address}}]),
        {keep_state, Data, [postpone]}
    end.


%% ---------- Send helpers----------

-spec send_s6_confirm_date(ClientPid :: pid(), _Data :: state_data()) -> ok.
send_s6_confirm_date(ClientPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(ClientPid, {self(), {confirm_date}, Path}).


-spec send_s6_confirm_date(ClientPid :: pid(), term(), _Data :: state_data()) -> ok.
send_s6_confirm_date(ClientPid, Date, _Data) ->
    Path = current_path(),
    gen_statem:cast(ClientPid, {self(), {confirm_date, {Date}}, Path}).


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

