
%%%-------------------------------------------------------------------
%%% gen_c.erl — generated generic behaviour module (gen_statem)
%%%-------------------------------------------------------------------
-module(gen_c).
-behaviour(gen_statem).

%% Public API
-export([start_link/2, callback_mode/0]).

%% gen_statem callbacks
-export([init/1, code_change/4, terminate/3,
  s1/3,
  s3/3,
  s5/3,
  s8/3,
  s9/3,
  s10/3,
  s13/3,
  s14/3,
  send_s1_login/2,
  send_s1_login/4,
  send_s8_quit/2,
  send_s8_pay/4,
  send_s8_pay/2,
  send_s10_keep_alive/2,
  send_s14_end_session/2]).

%% Types & records
-include("c.hrl").
-export_type([state_data/0]).
-type state_data() :: #state_data{}.

-callback init(Args :: list()) -> {ok, s1, state_data(), [{next_event, internal, {login}}]}.
-callback s1(internal, {login}, state_data()) -> {next_state, s3, state_data()} | {next_state, s3, state_data(), [{next_event, internal, {login}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s3(cast, {pid(), {login_failed}} | {pid(), {login_success}}, state_data()) -> {next_state, s5, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s5(cast, {pid(), {account, {term(), term()}}}, state_data()) -> {next_state, s8, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s8(internal | cast, {pay} | {quit} | {pid(), {timeout}}, state_data()) -> {next_state, s13, state_data()} | {next_state, s9, state_data()} | {next_state, s13, state_data(), [{next_event, internal, {pay}}] } | {next_state, s13, state_data(), [{next_event, internal, {quit}}] } | {next_state, s9, state_data(), [{next_event, internal, {pay}}] } | {next_state, s9, state_data(), [{next_event, internal, {quit}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s9(cast, {pid(), {confirmation}} | {pid(), {timeout}}, state_data()) -> {next_state, s10, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s10(internal, {keep_alive}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s13(cast, {pid(), {quit_ack}} | {pid(), {timeout}}, state_data()) -> {next_state, s14, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s14(internal, {end_session}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.

%% ===== API =====
-spec start_link(CallbackModule :: module(), Args :: list()) ->
    {ok, pid()} | {error, term()}.
start_link(CallbackModule, Args) ->
    case code:ensure_loaded(CallbackModule) of
        {module, CallbackModule} ->
            gen_statem:start_link({local, CallbackModule}, gen_c, {CallbackModule, Args}, [{debug, [trace, {log_to_file, "c_debug.log"}]}]);
        {error, Reason} ->
            {error, Reason}
    end.

-spec callback_mode() -> state_functions.
callback_mode() -> state_functions.

%% ===== gen_statem =====
-spec init({module(), list()}) ->
    {ok, s1, state_data(), [{next_event, internal, {login}}]}.
init({CallbackModule, _Args}) ->
    io:format("c: Initializing with callback module ~p~n", [CallbackModule]),
    put(callback_module, CallbackModule),
    set_commit(#{}),
    CallbackModule:init([]).

%% ---------- State functions----------
-spec s1(internal, {login}, state_data()) -> {next_state, s3, state_data()} | {next_state, s3, state_data(), [{next_event, internal, {login}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s1(internal, {login}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s1(internal, {login}, Data),
        Next;
s1(cast, {_From, _Msg, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s1]: Purging stale early-path event ~p~n", [_Msg]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s1]: Postponing early-path event ~p~n", [_Msg]),
        {keep_state, Data, [postpone]}
    end.

-spec s3(cast, {pid(), {login_success}} | {pid(), {login_failed}}, state_data()) -> {next_state, s5, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
s3(cast, {APid, {login_failed}}, Data) ->
    CallbackModule = get(callback_module),
    try CallbackModule:s3(cast, {APid, {login_failed}}, Data)
    catch error:function_clause ->
      io:format("gen_c[s3]: Callback had no clause for ~p, ignoring~n", [{login_failed}]),
      {keep_state, Data}
    end;
s3(cast, {APid, {login_success}}, Data) ->
    CallbackModule = get(callback_module),
    try CallbackModule:s3(cast, {APid, {login_success}}, Data)
    catch error:function_clause ->
      io:format("gen_c[s3]: Callback had no clause for ~p, ignoring~n", [{login_success}]),
      {keep_state, Data}
    end;
s3(cast, {_From, _Msg, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s3]: Purging stale early-path event ~p~n", [_Msg]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s3]: Postponing early-path event ~p~n", [_Msg]),
        {keep_state, Data, [postpone]}
    end.

-spec s5(cast, {pid(), {account, {term(), term()}}, list()}, state_data()) -> {next_state, s8, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
s5(cast, {SPid, {account, {Balance, Overdraft}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s5]: Purging stale event ~p~n", [{account, {Balance, Overdraft}}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s5(cast, {SPid, {account, {Balance, Overdraft}}}, Data)
               catch error:function_clause ->
                 io:format("gen_c[s5]: Callback had no clause for ~p, postponing~n", [{account, {Balance, Overdraft}}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> Next
        end
    end;
s5(cast, {_APid, {login_failed}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s5]: Purging stale event ~p~n", [{login_failed}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s5]: Postponing event ~p~n", [{login_failed}]),
        {keep_state, Data, [postpone]}
    end;
s5(cast, {_APid, {login_success}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s5]: Purging stale event ~p~n", [{login_success}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s5]: Postponing event ~p~n", [{login_success}]),
        {keep_state, Data, [postpone]}
    end;
s5(cast, {_SPid, {timeout}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s5]: Purging stale event ~p~n", [{timeout}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s5]: Postponing event ~p~n", [{timeout}]),
        {keep_state, Data, [postpone]}
    end;
s5(cast, {_SPid, {confirmation}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s5]: Purging stale event ~p~n", [{confirmation}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s5]: Postponing event ~p~n", [{confirmation}]),
        {keep_state, Data, [postpone]}
    end;
s5(cast, {_SPid, {quit_ack}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s5]: Purging stale event ~p~n", [{quit_ack}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s5]: Postponing event ~p~n", [{quit_ack}]),
        {keep_state, Data, [postpone]}
    end.

%% Mixed-choice entry state
-spec s8(internal | cast, {pay} | {quit} | {pid(), {timeout}, list()}, state_data()) -> {next_state, s13, state_data()} | {next_state, s9, state_data()} | {next_state, s13, state_data(), [{next_event, internal, {pay}}] } | {next_state, s13, state_data(), [{next_event, internal, {quit}}] } | {next_state, s9, state_data(), [{next_event, internal, {pay}}] } | {next_state, s9, state_data(), [{next_event, internal, {quit}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s8(internal, {quit}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s8(internal, {quit}, Data),
        Next;
s8(cast, {SPid, {timeout}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s8]: Purging stale event ~p~n", [{timeout}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s8(cast, {SPid, {timeout}}, Data)
               catch error:function_clause ->
                 io:format("gen_c[s8]: Callback had no clause for ~p, postponing~n", [{timeout}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {next_state, s9, _} -> commit_entry(mc1, right), Next;
          {next_state, s9, _, _} -> commit_entry(mc1, right), Next;
          {next_state, s2, _} -> commit_entry(mc1, left), Next;
          {next_state, s2, _, _} -> commit_entry(mc1, left), Next;
          _ -> Next
        end
    end;
s8(internal, {pay}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s8(internal, {pay}, Data),
        Next;
s8(cast, {_APid, {login_failed}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s8]: Purging stale event ~p~n", [{login_failed}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s8]: Postponing event ~p~n", [{login_failed}]),
        {keep_state, Data, [postpone]}
    end;
s8(cast, {_APid, {login_success}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s8]: Purging stale event ~p~n", [{login_success}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s8]: Postponing event ~p~n", [{login_success}]),
        {keep_state, Data, [postpone]}
    end;
s8(cast, {_SPid, {account, {Balance, Overdraft}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s8]: Purging stale event ~p~n", [{account, {Balance, Overdraft}}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s8]: Postponing event ~p~n", [{account, {Balance, Overdraft}}]),
        {keep_state, Data, [postpone]}
    end;
s8(cast, {_SPid, {confirmation}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s8]: Purging stale event ~p~n", [{confirmation}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s8]: Postponing event ~p~n", [{confirmation}]),
        {keep_state, Data, [postpone]}
    end;
s8(cast, {_SPid, {quit_ack}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s8]: Purging stale event ~p~n", [{quit_ack}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s8]: Postponing event ~p~n", [{quit_ack}]),
        {keep_state, Data, [postpone]}
    end.

-spec s9(cast, {pid(), {confirmation}, list()} | {pid(), {timeout}, list()}, state_data()) -> {next_state, s10, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
s9(cast, {SPid, {timeout}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s9]: Purging stale event ~p~n", [{timeout}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s9(cast, {SPid, {timeout}}, Data)
               catch error:function_clause ->
                 io:format("gen_c[s9]: Callback had no clause for ~p, postponing~n", [{timeout}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> Next
        end
    end;
s9(cast, {SPid, {confirmation}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s9]: Purging stale event ~p~n", [{confirmation}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s9(cast, {SPid, {confirmation}}, Data)
               catch error:function_clause ->
                 io:format("gen_c[s9]: Callback had no clause for ~p, postponing~n", [{confirmation}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> Next
        end
    end;
s9(cast, {_APid, {login_failed}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s9]: Purging stale event ~p~n", [{login_failed}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s9]: Postponing event ~p~n", [{login_failed}]),
        {keep_state, Data, [postpone]}
    end;
s9(cast, {_APid, {login_success}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s9]: Purging stale event ~p~n", [{login_success}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s9]: Postponing event ~p~n", [{login_success}]),
        {keep_state, Data, [postpone]}
    end;
s9(cast, {_SPid, {account, {Balance, Overdraft}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s9]: Purging stale event ~p~n", [{account, {Balance, Overdraft}}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s9]: Postponing event ~p~n", [{account, {Balance, Overdraft}}]),
        {keep_state, Data, [postpone]}
    end;
s9(cast, {_SPid, {quit_ack}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s9]: Purging stale event ~p~n", [{quit_ack}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s9]: Postponing event ~p~n", [{quit_ack}]),
        {keep_state, Data, [postpone]}
    end.

-spec s10(internal, {keep_alive}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
s10(internal, {keep_alive}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s10(internal, {keep_alive}, Data),
        Next;
s10(cast, {_APid, {login_failed}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s10]: Purging stale event ~p~n", [{login_failed}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s10]: Postponing event ~p~n", [{login_failed}]),
        {keep_state, Data, [postpone]}
    end;
s10(cast, {_APid, {login_success}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s10]: Purging stale event ~p~n", [{login_success}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s10]: Postponing event ~p~n", [{login_success}]),
        {keep_state, Data, [postpone]}
    end;
s10(cast, {_SPid, {account, {Balance, Overdraft}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s10]: Purging stale event ~p~n", [{account, {Balance, Overdraft}}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s10]: Postponing event ~p~n", [{account, {Balance, Overdraft}}]),
        {keep_state, Data, [postpone]}
    end;
s10(cast, {_SPid, {timeout}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s10]: Purging stale event ~p~n", [{timeout}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s10]: Postponing event ~p~n", [{timeout}]),
        {keep_state, Data, [postpone]}
    end;
s10(cast, {_SPid, {confirmation}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s10]: Purging stale event ~p~n", [{confirmation}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s10]: Postponing event ~p~n", [{confirmation}]),
        {keep_state, Data, [postpone]}
    end;
s10(cast, {_SPid, {quit_ack}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s10]: Purging stale event ~p~n", [{quit_ack}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s10]: Postponing event ~p~n", [{quit_ack}]),
        {keep_state, Data, [postpone]}
    end.

-spec s13(cast, {pid(), {quit_ack}, list()} | {pid(), {timeout}, list()}, state_data()) -> {next_state, s14, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
s13(cast, {SPid, {quit_ack}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s13]: Purging stale event ~p~n", [{quit_ack}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s13(cast, {SPid, {quit_ack}}, Data)
               catch error:function_clause ->
                 io:format("gen_c[s13]: Callback had no clause for ~p, postponing~n", [{quit_ack}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> Next
        end
    end;
s13(cast, {SPid, {timeout}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s13]: Purging stale event ~p~n", [{timeout}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s13(cast, {SPid, {timeout}}, Data)
               catch error:function_clause ->
                 io:format("gen_c[s13]: Callback had no clause for ~p, postponing~n", [{timeout}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> Next
        end
    end;
s13(cast, {_APid, {login_failed}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s13]: Purging stale event ~p~n", [{login_failed}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s13]: Postponing event ~p~n", [{login_failed}]),
        {keep_state, Data, [postpone]}
    end;
s13(cast, {_APid, {login_success}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s13]: Purging stale event ~p~n", [{login_success}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s13]: Postponing event ~p~n", [{login_success}]),
        {keep_state, Data, [postpone]}
    end;
s13(cast, {_SPid, {account, {Balance, Overdraft}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s13]: Purging stale event ~p~n", [{account, {Balance, Overdraft}}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s13]: Postponing event ~p~n", [{account, {Balance, Overdraft}}]),
        {keep_state, Data, [postpone]}
    end;
s13(cast, {_SPid, {confirmation}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s13]: Purging stale event ~p~n", [{confirmation}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s13]: Postponing event ~p~n", [{confirmation}]),
        {keep_state, Data, [postpone]}
    end.

-spec s14(internal, {end_session}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
s14(internal, {end_session}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s14(internal, {end_session}, Data),
        Next;
s14(cast, {_APid, {login_failed}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s14]: Purging stale event ~p~n", [{login_failed}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s14]: Postponing event ~p~n", [{login_failed}]),
        {keep_state, Data, [postpone]}
    end;
s14(cast, {_APid, {login_success}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s14]: Purging stale event ~p~n", [{login_success}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s14]: Postponing event ~p~n", [{login_success}]),
        {keep_state, Data, [postpone]}
    end;
s14(cast, {_SPid, {account, {Balance, Overdraft}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s14]: Purging stale event ~p~n", [{account, {Balance, Overdraft}}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s14]: Postponing event ~p~n", [{account, {Balance, Overdraft}}]),
        {keep_state, Data, [postpone]}
    end;
s14(cast, {_SPid, {timeout}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s14]: Purging stale event ~p~n", [{timeout}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s14]: Postponing event ~p~n", [{timeout}]),
        {keep_state, Data, [postpone]}
    end;
s14(cast, {_SPid, {confirmation}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s14]: Purging stale event ~p~n", [{confirmation}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s14]: Postponing event ~p~n", [{confirmation}]),
        {keep_state, Data, [postpone]}
    end;
s14(cast, {_SPid, {quit_ack}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s14]: Purging stale event ~p~n", [{quit_ack}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s14]: Postponing event ~p~n", [{quit_ack}]),
        {keep_state, Data, [postpone]}
    end.


%% ---------- Send helpers----------

-spec send_s1_login(APid :: pid(), _Data :: state_data()) -> ok.
send_s1_login(APid, _Data) ->
    gen_statem:cast(APid, {self(), {login}}).


-spec send_s1_login(APid :: pid(), term(), term(), _Data :: state_data()) -> ok.
send_s1_login(APid, Id, Password, _Data) ->
    gen_statem:cast(APid, {self(), {login, {Id, Password}}}).


-spec send_s8_quit(SPid :: pid(), _Data :: state_data()) -> ok.
send_s8_quit(SPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(SPid, {self(), {quit}, Path}).


-spec send_s8_pay(SPid :: pid(), term(), term(), _Data :: state_data()) -> ok.
send_s8_pay(SPid, Payee, Amount, _Data) ->
    Path = current_path(),
    gen_statem:cast(SPid, {self(), {pay, {Payee, Amount}}, Path}).


-spec send_s8_pay(SPid :: pid(), _Data :: state_data()) -> ok.
send_s8_pay(SPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(SPid, {self(), {pay}, Path}).


-spec send_s10_keep_alive(APid :: pid(), _Data :: state_data()) -> ok.
send_s10_keep_alive(APid, _Data) ->
    Path = current_path(),
    gen_statem:cast(APid, {self(), {keep_alive}, Path}).


-spec send_s14_end_session(APid :: pid(), _Data :: state_data()) -> ok.
send_s14_end_session(APid, _Data) ->
    Path = current_path(),
    gen_statem:cast(APid, {self(), {end_session}, Path}).


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

