
%%%-------------------------------------------------------------------
%%% gen_controller.erl — generated generic behaviour module (gen_statem)
%%%-------------------------------------------------------------------
-module(gen_controller).
-behaviour(gen_statem).

%% Public API
-export([start_link/2, callback_mode/0]).

%% gen_statem callbacks
-export([init/1, code_change/4, terminate/3,
  s1/3,
  s5/3,
  s6/3,
  s9/3,
  s10/3,
  s13/3,
  send_s1_start_logging/3,
  send_s1_start_logging/2,
  send_s6_restart/2,
  send_s6_restart/3,
  send_s9_timeout/2,
  send_s10_success_ack/2,
  send_s13_restart_logging/2,
  send_s13_stop_logging/2,
  send_s13_stop_logging/3,
  send_s13_restart_logging/3]).

%% Types & records
-include("controller.hrl").
-export_type([state_data/0]).
-type state_data() :: #state_data{}.

-callback init(Args :: list()) -> {ok, s1, state_data(), [{next_event, internal, {start_logging}}]}.
-callback s1(internal, {start_logging}, state_data()) -> {next_state, s9, state_data()} | {next_state, s9, state_data(), [{next_event, internal, {start_logging}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s5(cast, {pid(), {ack}}, state_data()) -> {next_state, s6, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s6(internal, {restart}, state_data()) -> {next_state, s9, state_data()} | {next_state, s9, state_data(), [{next_event, internal, {restart}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s9(internal | cast, {timeout} | {pid(), {log_failure, {term()}}} | {pid(), {log_success, {term()}}}, state_data()) -> {next_state, s10, state_data()} | {next_state, s13, state_data()} | {next_state, s5, state_data()} | {next_state, s10, state_data(), [{next_event, internal, {timeout}}] } | {next_state, s13, state_data(), [{next_event, internal, {timeout}}] } | {next_state, s5, state_data(), [{next_event, internal, {timeout}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s10(internal, {success_ack}, state_data()) -> {next_state, s9, state_data()} | {next_state, s9, state_data(), [{next_event, internal, {success_ack}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s13(internal, {restart_logging} | {stop_logging}, state_data()) -> {next_state, s9, state_data()} | {next_state, s9, state_data(), [{next_event, internal, {restart_logging}}] } | {next_state, s9, state_data(), [{next_event, internal, {stop_logging}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.

%% ===== API =====
-spec start_link(CallbackModule :: module(), Args :: list()) ->
    {ok, pid()} | {error, term()}.
start_link(CallbackModule, Args) ->
    case code:ensure_loaded(CallbackModule) of
        {module, CallbackModule} ->
            gen_statem:start_link({local, CallbackModule}, gen_controller, {CallbackModule, Args}, [{debug, [trace, {log_to_file, "controller_debug.log"}]}]);
        {error, Reason} ->
            {error, Reason}
    end.

-spec callback_mode() -> state_functions.
callback_mode() -> state_functions.

%% ===== gen_statem =====
-spec init({module(), list()}) ->
    {ok, s1, state_data(), [{next_event, internal, {start_logging}}]}.
init({CallbackModule, _Args}) ->
    io:format("controller: Initializing with callback module ~p~n", [CallbackModule]),
    put(callback_module, CallbackModule),
    init_context(),
    CallbackModule:init([]).

%% ---------- State functions----------
-spec s1(internal, {start_logging}, state_data()) -> {next_state, s9, state_data()} | {next_state, s9, state_data(), [{next_event, internal, {start_logging}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s1(internal, {start_logging}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s1(internal, {start_logging}, Data),
    after_transition(Next);
s1(cast, {_From, _Msg, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_controller[s1]: Purging stale early-path event ~p~n", [_Msg]),
        {keep_state, Data};
      false ->
        io:format("gen_controller[s1]: Postponing early-path event ~p~n", [_Msg]),
        {keep_state, Data, [postpone]}
    end.

-spec s5(cast, {pid(), {ack}, list()}, state_data()) -> {next_state, s6, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
s5(cast, {LogsPid, {ack}, Path}, Data) ->
    case message_status(Path, current_path()) of
      stale ->
        io:format("gen_controller[s5]: Purging stale event ~p~n", [{ack}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s5(cast, {LogsPid, {ack}}, Data)
               catch error:function_clause ->
                 io:format("gen_controller[s5]: Callback had no clause for ~p, postponing~n", [{ack}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> after_transition(Next)
        end;
      not_ready ->
        io:format("gen_controller[s5]: Postponing not-ready event ~p~n", [{ack}]),
        {keep_state, Data, [postpone]}
    end;
s5(cast, {_LogsPid, {log_success, {Int}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_controller[s5]: Purging stale event ~p~n", [{log_success, {Int}}]),
        {keep_state, Data};
      false ->
        io:format("gen_controller[s5]: Postponing event ~p~n", [{log_success, {Int}}]),
        {keep_state, Data, [postpone]}
    end;
s5(cast, {_LogsPid, {log_failure, {Int}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_controller[s5]: Purging stale event ~p~n", [{log_failure, {Int}}]),
        {keep_state, Data};
      false ->
        io:format("gen_controller[s5]: Postponing event ~p~n", [{log_failure, {Int}}]),
        {keep_state, Data, [postpone]}
    end.

-spec s6(internal, {restart}, state_data()) -> {next_state, s9, state_data()} | {next_state, s9, state_data(), [{next_event, internal, {restart}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s6(internal, {restart}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s6(internal, {restart}, Data),
    after_transition(Next);
s6(cast, {_LogsPid, {ack}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_controller[s6]: Purging stale event ~p~n", [{ack}]),
        {keep_state, Data};
      false ->
        io:format("gen_controller[s6]: Postponing event ~p~n", [{ack}]),
        {keep_state, Data, [postpone]}
    end;
s6(cast, {_LogsPid, {log_success, {Int}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_controller[s6]: Purging stale event ~p~n", [{log_success, {Int}}]),
        {keep_state, Data};
      false ->
        io:format("gen_controller[s6]: Postponing event ~p~n", [{log_success, {Int}}]),
        {keep_state, Data, [postpone]}
    end;
s6(cast, {_LogsPid, {log_failure, {Int}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_controller[s6]: Purging stale event ~p~n", [{log_failure, {Int}}]),
        {keep_state, Data};
      false ->
        io:format("gen_controller[s6]: Postponing event ~p~n", [{log_failure, {Int}}]),
        {keep_state, Data, [postpone]}
    end.

%% Mixed-choice entry state
-spec s9(internal | cast, {timeout} | {pid(), {log_failure, {term()}}, list()} | {pid(), {log_success, {term()}}, list()}, state_data()) -> {next_state, s10, state_data()} | {next_state, s13, state_data()} | {next_state, s5, state_data()} | {next_state, s10, state_data(), [{next_event, internal, {timeout}}] } | {next_state, s13, state_data(), [{next_event, internal, {timeout}}] } | {next_state, s5, state_data(), [{next_event, internal, {timeout}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s9(cast, {LogsPid, {log_failure, {Int}}, Path}, Data) ->
    case message_status(Path, branch_path(mc1, left)) of
      stale ->
        io:format("gen_controller[s9]: Purging stale event ~p~n", [{log_failure, {Int}}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s9(cast, {LogsPid, {log_failure, {Int}}}, Data)
               catch error:function_clause ->
                 io:format("gen_controller[s9]: Callback had no clause for ~p, postponing~n", [{log_failure, {Int}}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {next_state, s5, _} -> after_transition(commit_if_taken(Next, mc1, right));
          {next_state, s5, _, _} -> after_transition(commit_if_taken(Next, mc1, right));
          {next_state, s13, _} -> after_transition(commit_if_taken(Next, mc1, left));
          {next_state, s13, _, _} -> after_transition(commit_if_taken(Next, mc1, left));
          _ -> after_transition(Next)
        end;
      not_ready ->
        io:format("gen_controller[s9]: Postponing not-ready event ~p~n", [{log_failure, {Int}}]),
        {keep_state, Data, [postpone]}
    end;
s9(internal, {timeout}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s9(internal, {timeout}, Data),
    after_transition(Next);
s9(cast, {LogsPid, {log_success, {Int}}, Path}, Data) ->
    case message_status(Path, branch_path(mc1, left)) of
      stale ->
        io:format("gen_controller[s9]: Purging stale event ~p~n", [{log_success, {Int}}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s9(cast, {LogsPid, {log_success, {Int}}}, Data)
               catch error:function_clause ->
                 io:format("gen_controller[s9]: Callback had no clause for ~p, postponing~n", [{log_success, {Int}}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {next_state, s5, _} -> after_transition(commit_if_taken(Next, mc1, right));
          {next_state, s5, _, _} -> after_transition(commit_if_taken(Next, mc1, right));
          {next_state, s10, _} -> after_transition(commit_if_taken(Next, mc1, left));
          {next_state, s10, _, _} -> after_transition(commit_if_taken(Next, mc1, left));
          _ -> after_transition(Next)
        end;
      not_ready ->
        io:format("gen_controller[s9]: Postponing not-ready event ~p~n", [{log_success, {Int}}]),
        {keep_state, Data, [postpone]}
    end;
s9(cast, {_LogsPid, {ack}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_controller[s9]: Purging stale event ~p~n", [{ack}]),
        {keep_state, Data};
      false ->
        io:format("gen_controller[s9]: Postponing event ~p~n", [{ack}]),
        {keep_state, Data, [postpone]}
    end.

-spec s10(internal, {success_ack}, state_data()) -> {next_state, s9, state_data()} | {next_state, s9, state_data(), [{next_event, internal, {success_ack}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s10(internal, {success_ack}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s10(internal, {success_ack}, Data),
    after_transition(Next);
s10(cast, {_LogsPid, {ack}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_controller[s10]: Purging stale event ~p~n", [{ack}]),
        {keep_state, Data};
      false ->
        io:format("gen_controller[s10]: Postponing event ~p~n", [{ack}]),
        {keep_state, Data, [postpone]}
    end;
s10(cast, {_LogsPid, {log_success, {Int}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_controller[s10]: Purging stale event ~p~n", [{log_success, {Int}}]),
        {keep_state, Data};
      false ->
        io:format("gen_controller[s10]: Postponing event ~p~n", [{log_success, {Int}}]),
        {keep_state, Data, [postpone]}
    end;
s10(cast, {_LogsPid, {log_failure, {Int}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_controller[s10]: Purging stale event ~p~n", [{log_failure, {Int}}]),
        {keep_state, Data};
      false ->
        io:format("gen_controller[s10]: Postponing event ~p~n", [{log_failure, {Int}}]),
        {keep_state, Data, [postpone]}
    end.

-spec s13(internal, {restart_logging} | {stop_logging}, state_data()) -> {next_state, s9, state_data()} | {next_state, s9, state_data(), [{next_event, internal, {restart_logging}}] } | {next_state, s9, state_data(), [{next_event, internal, {stop_logging}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s13(internal, {restart_logging}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s13(internal, {restart_logging}, Data),
    after_transition(Next);
s13(internal, {stop_logging}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s13(internal, {stop_logging}, Data),
    after_transition(Next);
s13(cast, {_LogsPid, {ack}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_controller[s13]: Purging stale event ~p~n", [{ack}]),
        {keep_state, Data};
      false ->
        io:format("gen_controller[s13]: Postponing event ~p~n", [{ack}]),
        {keep_state, Data, [postpone]}
    end;
s13(cast, {_LogsPid, {log_success, {Int}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_controller[s13]: Purging stale event ~p~n", [{log_success, {Int}}]),
        {keep_state, Data};
      false ->
        io:format("gen_controller[s13]: Postponing event ~p~n", [{log_success, {Int}}]),
        {keep_state, Data, [postpone]}
    end;
s13(cast, {_LogsPid, {log_failure, {Int}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_controller[s13]: Purging stale event ~p~n", [{log_failure, {Int}}]),
        {keep_state, Data};
      false ->
        io:format("gen_controller[s13]: Postponing event ~p~n", [{log_failure, {Int}}]),
        {keep_state, Data, [postpone]}
    end.


%% ---------- Send helpers----------

-spec send_s1_start_logging(LogsPid :: pid(), term(), _Data :: state_data()) -> ok.
send_s1_start_logging(LogsPid, Int, _Data) ->
    gen_statem:cast(LogsPid, {self(), {start_logging, {Int}}}).


-spec send_s1_start_logging(LogsPid :: pid(), _Data :: state_data()) -> ok.
send_s1_start_logging(LogsPid, _Data) ->
    gen_statem:cast(LogsPid, {self(), {start_logging}}).


-spec send_s6_restart(LogsPid :: pid(), _Data :: state_data()) -> ok.
send_s6_restart(LogsPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(LogsPid, {self(), {restart}, Path}).


-spec send_s6_restart(LogsPid :: pid(), term(), _Data :: state_data()) -> ok.
send_s6_restart(LogsPid, Int, _Data) ->
    Path = current_path(),
    gen_statem:cast(LogsPid, {self(), {restart, {Int}}, Path}).


-spec send_s9_timeout(LogsPid :: pid(), _Data :: state_data()) -> ok.
send_s9_timeout(LogsPid, _Data) ->
    Path = branch_path(mc1, right),
    commit_current(mc1, right),
    gen_statem:cast(LogsPid, {self(), {timeout}, Path}).


-spec send_s10_success_ack(LogsPid :: pid(), _Data :: state_data()) -> ok.
send_s10_success_ack(LogsPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(LogsPid, {self(), {success_ack}, Path}).


-spec send_s13_restart_logging(LogsPid :: pid(), _Data :: state_data()) -> ok.
send_s13_restart_logging(LogsPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(LogsPid, {self(), {restart_logging}, Path}).


-spec send_s13_stop_logging(LogsPid :: pid(), _Data :: state_data()) -> ok.
send_s13_stop_logging(LogsPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(LogsPid, {self(), {stop_logging}, Path}).


-spec send_s13_stop_logging(LogsPid :: pid(), term(), _Data :: state_data()) -> ok.
send_s13_stop_logging(LogsPid, Int, _Data) ->
    Path = current_path(),
    gen_statem:cast(LogsPid, {self(), {stop_logging, {Int}}, Path}).


-spec send_s13_restart_logging(LogsPid :: pid(), term(), _Data :: state_data()) -> ok.
send_s13_restart_logging(LogsPid, Int, _Data) ->
    Path = current_path(),
    gen_statem:cast(LogsPid, {self(), {restart_logging, {Int}}, Path}).


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

after_transition({next_state, s9, _} = Next) -> enter_mc(mc1), Next;
after_transition({next_state, s9, _, _} = Next) -> enter_mc(mc1), Next;
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

