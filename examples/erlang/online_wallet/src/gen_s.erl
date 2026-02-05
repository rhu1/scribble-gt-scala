
%%%-------------------------------------------------------------------
%%% gen_s.erl — generated generic behaviour module (gen_statem)
%%%-------------------------------------------------------------------
-module(gen_s).
-behaviour(gen_statem).

%% Public API
-export([start_link/2, callback_mode/0]).

%% gen_statem callbacks
-export([init/1, code_change/4, terminate/3,
  s1/3,
  s4/3,
  s6/3,
  s8/3,
  s9/3,
  s12/3,
  send_s4_account/4,
  send_s4_account/2,
  send_s6_timeout/2,
  send_s8_timeout/2,
  send_s9_confirmation/2,
  send_s12_quit_ack/2]).

%% Types & records
-include("s.hrl").
-export_type([state_data/0]).
-type state_data() :: #state_data{}.

-callback init(Args :: list()) -> {ok, s1, state_data()}.
-callback s1(cast, {pid(), {auth_fail}} | {pid(), {login_accepted}}, state_data()) -> {next_state, s4, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s4(internal, {account}, state_data()) -> {next_state, s8, state_data()} | {next_state, s8, state_data(), [{next_event, internal, {account}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s6(internal, {timeout}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s8(internal | cast, {timeout} | {pid(), {pay, {term(), term()}}} | {pid(), {quit}}, state_data()) -> {next_state, s12, state_data()} | {next_state, s6, state_data()} | {next_state, s9, state_data()} | {next_state, s12, state_data(), [{next_event, internal, {timeout}}] } | {next_state, s6, state_data(), [{next_event, internal, {timeout}}] } | {next_state, s9, state_data(), [{next_event, internal, {timeout}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s9(internal, {confirmation}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s12(internal, {quit_ack}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.

%% ===== API =====
-spec start_link(CallbackModule :: module(), Args :: list()) ->
    {ok, pid()} | {error, term()}.
start_link(CallbackModule, Args) ->
    case code:ensure_loaded(CallbackModule) of
        {module, CallbackModule} ->
            gen_statem:start_link({local, CallbackModule}, gen_s, {CallbackModule, Args}, [{debug, [trace, {log_to_file, "s_debug.log"}]}]);
        {error, Reason} ->
            {error, Reason}
    end.

-spec callback_mode() -> state_functions.
callback_mode() -> state_functions.

%% ===== gen_statem =====
-spec init({module(), list()}) ->
    {ok, s1, state_data()}.
init({CallbackModule, _Args}) ->
    io:format("s: Initializing with callback module ~p~n", [CallbackModule]),
    put(callback_module, CallbackModule),
    set_commit(#{}),
    CallbackModule:init([]).

%% ---------- State functions----------
-spec s1(cast, {pid(), {login_accepted}} | {pid(), {auth_fail}}, state_data()) -> {next_state, s4, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
s1(cast, {APid, {login_accepted}}, Data) ->
    CallbackModule = get(callback_module),
    try CallbackModule:s1(cast, {APid, {login_accepted}}, Data)
    catch error:function_clause ->
      io:format("gen_s[s1]: Callback had no clause for ~p, ignoring~n", [{login_accepted}]),
      {keep_state, Data}
    end;
s1(cast, {APid, {auth_fail}}, Data) ->
    CallbackModule = get(callback_module),
    try CallbackModule:s1(cast, {APid, {auth_fail}}, Data)
    catch error:function_clause ->
      io:format("gen_s[s1]: Callback had no clause for ~p, ignoring~n", [{auth_fail}]),
      {keep_state, Data}
    end;
s1(cast, {_From, _Msg, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s1]: Purging stale early-path event ~p~n", [_Msg]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s1]: Postponing early-path event ~p~n", [_Msg]),
        {keep_state, Data, [postpone]}
    end.

-spec s4(internal, {account}, state_data()) -> {next_state, s8, state_data()} | {next_state, s8, state_data(), [{next_event, internal, {account}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s4(internal, {account}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s4(internal, {account}, Data),
        Next;
s4(cast, {_APid, {auth_fail}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s4]: Purging stale event ~p~n", [{auth_fail}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s4]: Postponing event ~p~n", [{auth_fail}]),
        {keep_state, Data, [postpone]}
    end;
s4(cast, {_APid, {login_accepted}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s4]: Purging stale event ~p~n", [{login_accepted}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s4]: Postponing event ~p~n", [{login_accepted}]),
        {keep_state, Data, [postpone]}
    end;
s4(cast, {_CPid, {quit}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s4]: Purging stale event ~p~n", [{quit}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s4]: Postponing event ~p~n", [{quit}]),
        {keep_state, Data, [postpone]}
    end;
s4(cast, {_CPid, {pay, {Payee, Amount}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s4]: Purging stale event ~p~n", [{pay, {Payee, Amount}}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s4]: Postponing event ~p~n", [{pay, {Payee, Amount}}]),
        {keep_state, Data, [postpone]}
    end.

-spec s6(internal, {timeout}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
s6(internal, {timeout}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s6(internal, {timeout}, Data),
        Next;
s6(cast, {_APid, {auth_fail}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s6]: Purging stale event ~p~n", [{auth_fail}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s6]: Postponing event ~p~n", [{auth_fail}]),
        {keep_state, Data, [postpone]}
    end;
s6(cast, {_APid, {login_accepted}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s6]: Purging stale event ~p~n", [{login_accepted}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s6]: Postponing event ~p~n", [{login_accepted}]),
        {keep_state, Data, [postpone]}
    end;
s6(cast, {_CPid, {quit}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s6]: Purging stale event ~p~n", [{quit}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s6]: Postponing event ~p~n", [{quit}]),
        {keep_state, Data, [postpone]}
    end;
s6(cast, {_CPid, {pay, {Payee, Amount}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s6]: Purging stale event ~p~n", [{pay, {Payee, Amount}}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s6]: Postponing event ~p~n", [{pay, {Payee, Amount}}]),
        {keep_state, Data, [postpone]}
    end.

%% Mixed-choice entry state
-spec s8(internal | cast, {timeout} | {pid(), {pay, {term(), term()}}, list()} | {pid(), {quit}, list()}, state_data()) -> {next_state, s12, state_data()} | {next_state, s6, state_data()} | {next_state, s9, state_data()} | {next_state, s12, state_data(), [{next_event, internal, {timeout}}] } | {next_state, s6, state_data(), [{next_event, internal, {timeout}}] } | {next_state, s9, state_data(), [{next_event, internal, {timeout}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s8(cast, {CPid, {quit}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s8]: Purging stale event ~p~n", [{quit}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s8(cast, {CPid, {quit}}, Data)
               catch error:function_clause ->
                 io:format("gen_s[s8]: Callback had no clause for ~p, postponing~n", [{quit}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {next_state, s6, _} -> commit_entry(mc1, right), Next;
          {next_state, s6, _, _} -> commit_entry(mc1, right), Next;
          {next_state, s9, _} -> commit_entry(mc1, left), Next;
          {next_state, s9, _, _} -> commit_entry(mc1, left), Next;
          _ -> Next
        end
    end;
s8(internal, {timeout}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s8(internal, {timeout}, Data),
        Next;
s8(cast, {CPid, {pay, {Payee, Amount}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s8]: Purging stale event ~p~n", [{pay, {Payee, Amount}}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s8(cast, {CPid, {pay, {Payee, Amount}}}, Data)
               catch error:function_clause ->
                 io:format("gen_s[s8]: Callback had no clause for ~p, postponing~n", [{pay, {Payee, Amount}}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {next_state, s6, _} -> commit_entry(mc1, right), Next;
          {next_state, s6, _, _} -> commit_entry(mc1, right), Next;
          {next_state, s9, _} -> commit_entry(mc1, left), Next;
          {next_state, s9, _, _} -> commit_entry(mc1, left), Next;
          _ -> Next
        end
    end;
s8(cast, {_APid, {auth_fail}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s8]: Purging stale event ~p~n", [{auth_fail}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s8]: Postponing event ~p~n", [{auth_fail}]),
        {keep_state, Data, [postpone]}
    end;
s8(cast, {_APid, {login_accepted}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s8]: Purging stale event ~p~n", [{login_accepted}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s8]: Postponing event ~p~n", [{login_accepted}]),
        {keep_state, Data, [postpone]}
    end.

-spec s9(internal, {confirmation}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
s9(internal, {confirmation}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s9(internal, {confirmation}, Data),
        Next;
s9(cast, {_APid, {auth_fail}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s9]: Purging stale event ~p~n", [{auth_fail}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s9]: Postponing event ~p~n", [{auth_fail}]),
        {keep_state, Data, [postpone]}
    end;
s9(cast, {_APid, {login_accepted}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s9]: Purging stale event ~p~n", [{login_accepted}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s9]: Postponing event ~p~n", [{login_accepted}]),
        {keep_state, Data, [postpone]}
    end;
s9(cast, {_CPid, {quit}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s9]: Purging stale event ~p~n", [{quit}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s9]: Postponing event ~p~n", [{quit}]),
        {keep_state, Data, [postpone]}
    end;
s9(cast, {_CPid, {pay, {Payee, Amount}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s9]: Purging stale event ~p~n", [{pay, {Payee, Amount}}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s9]: Postponing event ~p~n", [{pay, {Payee, Amount}}]),
        {keep_state, Data, [postpone]}
    end.

-spec s12(internal, {quit_ack}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
s12(internal, {quit_ack}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s12(internal, {quit_ack}, Data),
        Next;
s12(cast, {_APid, {auth_fail}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s12]: Purging stale event ~p~n", [{auth_fail}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s12]: Postponing event ~p~n", [{auth_fail}]),
        {keep_state, Data, [postpone]}
    end;
s12(cast, {_APid, {login_accepted}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s12]: Purging stale event ~p~n", [{login_accepted}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s12]: Postponing event ~p~n", [{login_accepted}]),
        {keep_state, Data, [postpone]}
    end;
s12(cast, {_CPid, {quit}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s12]: Purging stale event ~p~n", [{quit}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s12]: Postponing event ~p~n", [{quit}]),
        {keep_state, Data, [postpone]}
    end;
s12(cast, {_CPid, {pay, {Payee, Amount}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s12]: Purging stale event ~p~n", [{pay, {Payee, Amount}}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s12]: Postponing event ~p~n", [{pay, {Payee, Amount}}]),
        {keep_state, Data, [postpone]}
    end.


%% ---------- Send helpers----------

-spec send_s4_account(CPid :: pid(), term(), term(), _Data :: state_data()) -> ok.
send_s4_account(CPid, Balance, Overdraft, _Data) ->
    Path = current_path(),
    gen_statem:cast(CPid, {self(), {account, {Balance, Overdraft}}, Path}).


-spec send_s4_account(CPid :: pid(), _Data :: state_data()) -> ok.
send_s4_account(CPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(CPid, {self(), {account}, Path}).


-spec send_s6_timeout(APid :: pid(), _Data :: state_data()) -> ok.
send_s6_timeout(APid, _Data) ->
    Path = current_path(),
    gen_statem:cast(APid, {self(), {timeout}, Path}).


-spec send_s8_timeout(CPid :: pid(), _Data :: state_data()) -> ok.
send_s8_timeout(CPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(CPid, {self(), {timeout}, Path}).


-spec send_s9_confirmation(CPid :: pid(), _Data :: state_data()) -> ok.
send_s9_confirmation(CPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(CPid, {self(), {confirmation}, Path}).


-spec send_s12_quit_ack(CPid :: pid(), _Data :: state_data()) -> ok.
send_s12_quit_ack(CPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(CPid, {self(), {quit_ack}, Path}).


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

