
%%%-------------------------------------------------------------------
%%% gen_logs.erl — generated generic behaviour module (gen_statem)
%%%-------------------------------------------------------------------
-module(gen_logs).
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
  send_s5_ack/2,
  send_s9_log_success/3,
  send_s9_log_success/2,
  send_s9_log_failure/3,
  send_s9_log_failure/2]).

%% Types & records
-include("logs.hrl").
-export_type([state_data/0]).
-type state_data() :: #state_data{}.

-callback init(Args :: list()) -> {ok, s1, state_data()}.
-callback s1(cast, {pid(), {start_logging, {term()}}}, state_data()) -> {next_state, s9, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s5(internal, {ack}, state_data()) -> {next_state, s6, state_data()} | {next_state, s6, state_data(), [{next_event, internal, {ack}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s6(cast, {pid(), {restart, {term()}}}, state_data()) -> {next_state, s9, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s9(internal | cast, {log_failure} | {log_success} | {pid(), {timeout}}, state_data()) -> {next_state, s10, state_data()} | {next_state, s13, state_data()} | {next_state, s5, state_data()} | {next_state, s10, state_data(), [{next_event, internal, {log_failure}}] } | {next_state, s10, state_data(), [{next_event, internal, {log_success}}] } | {next_state, s13, state_data(), [{next_event, internal, {log_failure}}] } | {next_state, s13, state_data(), [{next_event, internal, {log_success}}] } | {next_state, s5, state_data(), [{next_event, internal, {log_failure}}] } | {next_state, s5, state_data(), [{next_event, internal, {log_success}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s10(cast, {pid(), {success_ack}} | {pid(), {timeout}}, state_data()) -> {next_state, s5, state_data()} | {next_state, s9, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s13(cast, {pid(), {restart_logging, {term()}}} | {pid(), {stop_logging, {term()}}} | {pid(), {timeout}}, state_data()) -> {next_state, s5, state_data()} | {next_state, s9, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.

%% ===== API =====
-spec start_link(CallbackModule :: module(), Args :: list()) ->
    {ok, pid()} | {error, term()}.
start_link(CallbackModule, Args) ->
    case code:ensure_loaded(CallbackModule) of
        {module, CallbackModule} ->
            gen_statem:start_link({local, CallbackModule}, gen_logs, {CallbackModule, Args}, [{debug, [trace, {log_to_file, "logs_debug.log"}]}]);
        {error, Reason} ->
            {error, Reason}
    end.

-spec callback_mode() -> state_functions.
callback_mode() -> state_functions.

%% ===== gen_statem =====
-spec init({module(), list()}) ->
    {ok, s1, state_data()}.
init({CallbackModule, _Args}) ->
    io:format("logs: Initializing with callback module ~p~n", [CallbackModule]),
    put(callback_module, CallbackModule),
    init_context(),
    CallbackModule:init([]).

%% ---------- State functions----------
-spec s1(cast, {pid(), {start_logging, {term()}}}, state_data()) -> {next_state, s9, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
s1(cast, {ControllerPid, {start_logging, {Int}}}, Data) ->
    CallbackModule = get(callback_module),
    Next = try CallbackModule:s1(cast, {ControllerPid, {start_logging, {Int}}}, Data)
           catch error:function_clause ->
             io:format("gen_logs[s1]: Callback had no clause for ~p, ignoring~n", [{start_logging, {Int}}]),
             {keep_state, Data}
           end,
    after_transition(Next);
s1(cast, {_From, _Msg, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_logs[s1]: Purging stale early-path event ~p~n", [_Msg]),
        {keep_state, Data};
      false ->
        io:format("gen_logs[s1]: Postponing early-path event ~p~n", [_Msg]),
        {keep_state, Data, [postpone]}
    end.

-spec s5(internal, {ack}, state_data()) -> {next_state, s6, state_data()} | {next_state, s6, state_data(), [{next_event, internal, {ack}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s5(internal, {ack}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s5(internal, {ack}, Data),
    after_transition(Next);
s5(cast, {_ControllerPid, {start_logging, {Int}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_logs[s5]: Purging stale event ~p~n", [{start_logging, {Int}}]),
        {keep_state, Data};
      false ->
        io:format("gen_logs[s5]: Postponing event ~p~n", [{start_logging, {Int}}]),
        {keep_state, Data, [postpone]}
    end;
s5(cast, {_ControllerPid, {restart, {Int}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_logs[s5]: Purging stale event ~p~n", [{restart, {Int}}]),
        {keep_state, Data};
      false ->
        io:format("gen_logs[s5]: Postponing event ~p~n", [{restart, {Int}}]),
        {keep_state, Data, [postpone]}
    end;
s5(cast, {ControllerPid, {timeout}, Path}, Data) ->
    case message_status(Path, branch_path(mc1, right)) of
      stale ->
        io:format("gen_logs[s5]: Purging stale interrupt ~p~n", [{timeout}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s9(cast, {ControllerPid, {timeout}}, Data)
               catch error:function_clause ->
                 io:format("gen_logs[s5]: Callback had no interrupt clause for ~p, postponing~n", [{timeout}]),
                 {keep_state, Data, [postpone]}
               end,
        after_transition(commit_if_taken(Next, mc1, right));
      not_ready ->
        io:format("gen_logs[s5]: Postponing not-ready interrupt ~p~n", [{timeout}]),
        {keep_state, Data, [postpone]}
    end;
s5(cast, {_ControllerPid, {success_ack}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_logs[s5]: Purging stale event ~p~n", [{success_ack}]),
        {keep_state, Data};
      false ->
        io:format("gen_logs[s5]: Postponing event ~p~n", [{success_ack}]),
        {keep_state, Data, [postpone]}
    end;
s5(cast, {_ControllerPid, {restart_logging, {Int}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_logs[s5]: Purging stale event ~p~n", [{restart_logging, {Int}}]),
        {keep_state, Data};
      false ->
        io:format("gen_logs[s5]: Postponing event ~p~n", [{restart_logging, {Int}}]),
        {keep_state, Data, [postpone]}
    end;
s5(cast, {_ControllerPid, {stop_logging, {Int}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_logs[s5]: Purging stale event ~p~n", [{stop_logging, {Int}}]),
        {keep_state, Data};
      false ->
        io:format("gen_logs[s5]: Postponing event ~p~n", [{stop_logging, {Int}}]),
        {keep_state, Data, [postpone]}
    end.

-spec s6(cast, {pid(), {restart, {term()}}, list()}, state_data()) -> {next_state, s9, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
s6(cast, {ControllerPid, {restart, {Int}}, Path}, Data) ->
    case message_status(Path, current_path()) of
      stale ->
        io:format("gen_logs[s6]: Purging stale event ~p~n", [{restart, {Int}}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s6(cast, {ControllerPid, {restart, {Int}}}, Data)
               catch error:function_clause ->
                 io:format("gen_logs[s6]: Callback had no clause for ~p, postponing~n", [{restart, {Int}}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> after_transition(Next)
        end;
      not_ready ->
        io:format("gen_logs[s6]: Postponing not-ready event ~p~n", [{restart, {Int}}]),
        {keep_state, Data, [postpone]}
    end;
s6(cast, {_ControllerPid, {start_logging, {Int}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_logs[s6]: Purging stale event ~p~n", [{start_logging, {Int}}]),
        {keep_state, Data};
      false ->
        io:format("gen_logs[s6]: Postponing event ~p~n", [{start_logging, {Int}}]),
        {keep_state, Data, [postpone]}
    end;
s6(cast, {ControllerPid, {timeout}, Path}, Data) ->
    case message_status(Path, branch_path(mc1, right)) of
      stale ->
        io:format("gen_logs[s6]: Purging stale interrupt ~p~n", [{timeout}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s9(cast, {ControllerPid, {timeout}}, Data)
               catch error:function_clause ->
                 io:format("gen_logs[s6]: Callback had no interrupt clause for ~p, postponing~n", [{timeout}]),
                 {keep_state, Data, [postpone]}
               end,
        after_transition(commit_if_taken(Next, mc1, right));
      not_ready ->
        io:format("gen_logs[s6]: Postponing not-ready interrupt ~p~n", [{timeout}]),
        {keep_state, Data, [postpone]}
    end;
s6(cast, {_ControllerPid, {success_ack}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_logs[s6]: Purging stale event ~p~n", [{success_ack}]),
        {keep_state, Data};
      false ->
        io:format("gen_logs[s6]: Postponing event ~p~n", [{success_ack}]),
        {keep_state, Data, [postpone]}
    end;
s6(cast, {_ControllerPid, {restart_logging, {Int}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_logs[s6]: Purging stale event ~p~n", [{restart_logging, {Int}}]),
        {keep_state, Data};
      false ->
        io:format("gen_logs[s6]: Postponing event ~p~n", [{restart_logging, {Int}}]),
        {keep_state, Data, [postpone]}
    end;
s6(cast, {_ControllerPid, {stop_logging, {Int}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_logs[s6]: Purging stale event ~p~n", [{stop_logging, {Int}}]),
        {keep_state, Data};
      false ->
        io:format("gen_logs[s6]: Postponing event ~p~n", [{stop_logging, {Int}}]),
        {keep_state, Data, [postpone]}
    end.

%% Mixed-choice entry state
-spec s9(internal | cast, {log_failure} | {log_success} | {pid(), {timeout}, list()}, state_data()) -> {next_state, s10, state_data()} | {next_state, s13, state_data()} | {next_state, s5, state_data()} | {next_state, s10, state_data(), [{next_event, internal, {log_failure}}] } | {next_state, s10, state_data(), [{next_event, internal, {log_success}}] } | {next_state, s13, state_data(), [{next_event, internal, {log_failure}}] } | {next_state, s13, state_data(), [{next_event, internal, {log_success}}] } | {next_state, s5, state_data(), [{next_event, internal, {log_failure}}] } | {next_state, s5, state_data(), [{next_event, internal, {log_success}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s9(internal, {log_success}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s9(internal, {log_success}, Data),
    after_transition(Next);
s9(cast, {ControllerPid, {timeout}, Path}, Data) ->
    case message_status(Path, branch_path(mc1, right)) of
      stale ->
        io:format("gen_logs[s9]: Purging stale event ~p~n", [{timeout}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s9(cast, {ControllerPid, {timeout}}, Data)
               catch error:function_clause ->
                 io:format("gen_logs[s9]: Callback had no clause for ~p, postponing~n", [{timeout}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {next_state, s5, _} -> after_transition(commit_if_taken(Next, mc1, right));
          {next_state, s5, _, _} -> after_transition(commit_if_taken(Next, mc1, right));
          _ -> after_transition(Next)
        end;
      not_ready ->
        io:format("gen_logs[s9]: Postponing not-ready event ~p~n", [{timeout}]),
        {keep_state, Data, [postpone]}
    end;
s9(internal, {log_failure}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s9(internal, {log_failure}, Data),
    after_transition(Next);
s9(cast, {_ControllerPid, {start_logging, {Int}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_logs[s9]: Purging stale event ~p~n", [{start_logging, {Int}}]),
        {keep_state, Data};
      false ->
        io:format("gen_logs[s9]: Postponing event ~p~n", [{start_logging, {Int}}]),
        {keep_state, Data, [postpone]}
    end;
s9(cast, {_ControllerPid, {restart, {Int}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_logs[s9]: Purging stale event ~p~n", [{restart, {Int}}]),
        {keep_state, Data};
      false ->
        io:format("gen_logs[s9]: Postponing event ~p~n", [{restart, {Int}}]),
        {keep_state, Data, [postpone]}
    end;
s9(cast, {_ControllerPid, {success_ack}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_logs[s9]: Purging stale event ~p~n", [{success_ack}]),
        {keep_state, Data};
      false ->
        io:format("gen_logs[s9]: Postponing event ~p~n", [{success_ack}]),
        {keep_state, Data, [postpone]}
    end;
s9(cast, {_ControllerPid, {restart_logging, {Int}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_logs[s9]: Purging stale event ~p~n", [{restart_logging, {Int}}]),
        {keep_state, Data};
      false ->
        io:format("gen_logs[s9]: Postponing event ~p~n", [{restart_logging, {Int}}]),
        {keep_state, Data, [postpone]}
    end;
s9(cast, {_ControllerPid, {stop_logging, {Int}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_logs[s9]: Purging stale event ~p~n", [{stop_logging, {Int}}]),
        {keep_state, Data};
      false ->
        io:format("gen_logs[s9]: Postponing event ~p~n", [{stop_logging, {Int}}]),
        {keep_state, Data, [postpone]}
    end.

-spec s10(cast, {pid(), {timeout}, list()} | {pid(), {success_ack}, list()}, state_data()) -> {next_state, s5, state_data()} | {next_state, s9, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
s10(cast, {ControllerPid, {success_ack}, Path}, Data) ->
    case message_status(Path, current_path()) of
      stale ->
        io:format("gen_logs[s10]: Purging stale event ~p~n", [{success_ack}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s10(cast, {ControllerPid, {success_ack}}, Data)
               catch error:function_clause ->
                 io:format("gen_logs[s10]: Callback had no clause for ~p, postponing~n", [{success_ack}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> after_transition(Next)
        end;
      not_ready ->
        io:format("gen_logs[s10]: Postponing not-ready event ~p~n", [{success_ack}]),
        {keep_state, Data, [postpone]}
    end;
s10(cast, {ControllerPid, {timeout}, Path}, Data) ->
    case message_status(Path, branch_path(mc1, right)) of
      stale ->
        io:format("gen_logs[s10]: Purging stale event ~p~n", [{timeout}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s10(cast, {ControllerPid, {timeout}}, Data)
               catch error:function_clause ->
                 io:format("gen_logs[s10]: Callback had no clause for ~p, postponing~n", [{timeout}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {next_state, s5, _} -> after_transition(commit_if_taken(Next, mc1, right));
          {next_state, s5, _, _} -> after_transition(commit_if_taken(Next, mc1, right));
          _ -> after_transition(Next)
        end;
      not_ready ->
        io:format("gen_logs[s10]: Postponing not-ready event ~p~n", [{timeout}]),
        {keep_state, Data, [postpone]}
    end;
s10(cast, {_ControllerPid, {start_logging, {Int}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_logs[s10]: Purging stale event ~p~n", [{start_logging, {Int}}]),
        {keep_state, Data};
      false ->
        io:format("gen_logs[s10]: Postponing event ~p~n", [{start_logging, {Int}}]),
        {keep_state, Data, [postpone]}
    end;
s10(cast, {_ControllerPid, {restart, {Int}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_logs[s10]: Purging stale event ~p~n", [{restart, {Int}}]),
        {keep_state, Data};
      false ->
        io:format("gen_logs[s10]: Postponing event ~p~n", [{restart, {Int}}]),
        {keep_state, Data, [postpone]}
    end;
s10(cast, {_ControllerPid, {restart_logging, {Int}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_logs[s10]: Purging stale event ~p~n", [{restart_logging, {Int}}]),
        {keep_state, Data};
      false ->
        io:format("gen_logs[s10]: Postponing event ~p~n", [{restart_logging, {Int}}]),
        {keep_state, Data, [postpone]}
    end;
s10(cast, {_ControllerPid, {stop_logging, {Int}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_logs[s10]: Purging stale event ~p~n", [{stop_logging, {Int}}]),
        {keep_state, Data};
      false ->
        io:format("gen_logs[s10]: Postponing event ~p~n", [{stop_logging, {Int}}]),
        {keep_state, Data, [postpone]}
    end.

-spec s13(cast, {pid(), {restart_logging, {term()}}, list()} | {pid(), {stop_logging, {term()}}, list()} | {pid(), {timeout}, list()}, state_data()) -> {next_state, s5, state_data()} | {next_state, s9, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
s13(cast, {ControllerPid, {restart_logging, {Int}}, Path}, Data) ->
    case message_status(Path, current_path()) of
      stale ->
        io:format("gen_logs[s13]: Purging stale event ~p~n", [{restart_logging, {Int}}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s13(cast, {ControllerPid, {restart_logging, {Int}}}, Data)
               catch error:function_clause ->
                 io:format("gen_logs[s13]: Callback had no clause for ~p, postponing~n", [{restart_logging, {Int}}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> after_transition(Next)
        end;
      not_ready ->
        io:format("gen_logs[s13]: Postponing not-ready event ~p~n", [{restart_logging, {Int}}]),
        {keep_state, Data, [postpone]}
    end;
s13(cast, {ControllerPid, {stop_logging, {Int}}, Path}, Data) ->
    case message_status(Path, current_path()) of
      stale ->
        io:format("gen_logs[s13]: Purging stale event ~p~n", [{stop_logging, {Int}}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s13(cast, {ControllerPid, {stop_logging, {Int}}}, Data)
               catch error:function_clause ->
                 io:format("gen_logs[s13]: Callback had no clause for ~p, postponing~n", [{stop_logging, {Int}}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> after_transition(Next)
        end;
      not_ready ->
        io:format("gen_logs[s13]: Postponing not-ready event ~p~n", [{stop_logging, {Int}}]),
        {keep_state, Data, [postpone]}
    end;
s13(cast, {ControllerPid, {timeout}, Path}, Data) ->
    case message_status(Path, branch_path(mc1, right)) of
      stale ->
        io:format("gen_logs[s13]: Purging stale event ~p~n", [{timeout}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s13(cast, {ControllerPid, {timeout}}, Data)
               catch error:function_clause ->
                 io:format("gen_logs[s13]: Callback had no clause for ~p, postponing~n", [{timeout}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {next_state, s5, _} -> after_transition(commit_if_taken(Next, mc1, right));
          {next_state, s5, _, _} -> after_transition(commit_if_taken(Next, mc1, right));
          _ -> after_transition(Next)
        end;
      not_ready ->
        io:format("gen_logs[s13]: Postponing not-ready event ~p~n", [{timeout}]),
        {keep_state, Data, [postpone]}
    end;
s13(cast, {_ControllerPid, {start_logging, {Int}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_logs[s13]: Purging stale event ~p~n", [{start_logging, {Int}}]),
        {keep_state, Data};
      false ->
        io:format("gen_logs[s13]: Postponing event ~p~n", [{start_logging, {Int}}]),
        {keep_state, Data, [postpone]}
    end;
s13(cast, {_ControllerPid, {restart, {Int}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_logs[s13]: Purging stale event ~p~n", [{restart, {Int}}]),
        {keep_state, Data};
      false ->
        io:format("gen_logs[s13]: Postponing event ~p~n", [{restart, {Int}}]),
        {keep_state, Data, [postpone]}
    end;
s13(cast, {_ControllerPid, {success_ack}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_logs[s13]: Purging stale event ~p~n", [{success_ack}]),
        {keep_state, Data};
      false ->
        io:format("gen_logs[s13]: Postponing event ~p~n", [{success_ack}]),
        {keep_state, Data, [postpone]}
    end.


%% ---------- Send helpers----------

-spec send_s5_ack(ControllerPid :: pid(), _Data :: state_data()) -> ok.
send_s5_ack(ControllerPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(ControllerPid, {self(), {ack}, Path}).


-spec send_s9_log_success(ControllerPid :: pid(), term(), _Data :: state_data()) -> ok.
send_s9_log_success(ControllerPid, Int, _Data) ->
    Path = branch_path(mc1, left),
    set_current_path(Path),
    gen_statem:cast(ControllerPid, {self(), {log_success, {Int}}, Path}).


-spec send_s9_log_success(ControllerPid :: pid(), _Data :: state_data()) -> ok.
send_s9_log_success(ControllerPid, _Data) ->
    Path = branch_path(mc1, left),
    set_current_path(Path),
    gen_statem:cast(ControllerPid, {self(), {log_success}, Path}).


-spec send_s9_log_failure(ControllerPid :: pid(), term(), _Data :: state_data()) -> ok.
send_s9_log_failure(ControllerPid, Int, _Data) ->
    Path = branch_path(mc1, left),
    set_current_path(Path),
    gen_statem:cast(ControllerPid, {self(), {log_failure, {Int}}, Path}).


-spec send_s9_log_failure(ControllerPid :: pid(), _Data :: state_data()) -> ok.
send_s9_log_failure(ControllerPid, _Data) ->
    Path = branch_path(mc1, left),
    set_current_path(Path),
    gen_statem:cast(ControllerPid, {self(), {log_failure}, Path}).


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

