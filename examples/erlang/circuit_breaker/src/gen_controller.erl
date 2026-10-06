
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
  s3/3,
  s4/3,
  s6/3,
  s8/3,
  s11/3,
  s12/3,
  s15/3,
  s16/3,
  s19/3,
  s20/3,
  send_s1_start_storage/2,
  send_s3_start_controller/2,
  send_s8_timeout_notice/2,
  send_s11_error_notice/2,
  send_s11_service_operational/2,
  send_s11_shutdown_api/2,
  send_s16_storage_restart/2,
  send_s20_shutdown_storage/2]).

%% Types & records
-include("controller.hrl").
-export_type([state_data/0]).
-type state_data() :: #state_data{}.

-callback init(Args :: list()) -> {ok, s1, state_data(), [{next_event, internal, {start_storage}}]}.
-callback s1(internal, {start_storage}, state_data()) -> {next_state, s3, state_data()} | {next_state, s3, state_data(), [{next_event, internal, {start_storage}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s3(internal, {start_controller}, state_data()) -> {next_state, s4, state_data()} | {next_state, s4, state_data(), [{next_event, internal, {start_controller}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s4(cast, {pid(), {hard_ping}}, state_data()) -> {next_state, s6, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s6(cast, {pid(), {get_mode}}, state_data()) -> {next_state, s11, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s8(internal, {timeout_notice}, state_data()) -> {next_state, s6, state_data()} | {next_state, s6, state_data(), [{next_event, internal, {timeout_notice}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s11(internal | cast, {error_notice} | {service_operational} | {shutdown_api} | {pid(), {timeout}}, state_data()) -> {next_state, s12, state_data()} | {next_state, s15, state_data()} | {next_state, s19, state_data()} | {next_state, s8, state_data()} | {next_state, s12, state_data(), [{next_event, internal, {error_notice}}] } | {next_state, s12, state_data(), [{next_event, internal, {service_operational}}] } | {next_state, s12, state_data(), [{next_event, internal, {shutdown_api}}] } | {next_state, s15, state_data(), [{next_event, internal, {error_notice}}] } | {next_state, s15, state_data(), [{next_event, internal, {service_operational}}] } | {next_state, s15, state_data(), [{next_event, internal, {shutdown_api}}] } | {next_state, s19, state_data(), [{next_event, internal, {error_notice}}] } | {next_state, s19, state_data(), [{next_event, internal, {service_operational}}] } | {next_state, s19, state_data(), [{next_event, internal, {shutdown_api}}] } | {next_state, s8, state_data(), [{next_event, internal, {error_notice}}] } | {next_state, s8, state_data(), [{next_event, internal, {service_operational}}] } | {next_state, s8, state_data(), [{next_event, internal, {shutdown_api}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s12(cast, {pid(), {ack}} | {pid(), {timeout}}, state_data()) -> {next_state, s6, state_data()} | {next_state, s8, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s15(cast, {pid(), {error_ack}} | {pid(), {timeout}}, state_data()) -> {next_state, s16, state_data()} | {next_state, s8, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s16(internal, {storage_restart}, state_data()) -> {next_state, s6, state_data()} | {next_state, s6, state_data(), [{next_event, internal, {storage_restart}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s19(cast, {pid(), {shutdown_ack}} | {pid(), {timeout}}, state_data()) -> {next_state, s20, state_data()} | {next_state, s8, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s20(internal, {shutdown_storage}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.

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
    {ok, s1, state_data(), [{next_event, internal, {start_storage}}]}.
init({CallbackModule, _Args}) ->
    io:format("controller: Initializing with callback module ~p~n", [CallbackModule]),
    put(callback_module, CallbackModule),
    init_context(),
    CallbackModule:init([]).

%% ---------- State functions----------
-spec s1(internal, {start_storage}, state_data()) -> {next_state, s3, state_data()} | {next_state, s3, state_data(), [{next_event, internal, {start_storage}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s1(internal, {start_storage}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s1(internal, {start_storage}, Data),
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

-spec s3(internal, {start_controller}, state_data()) -> {next_state, s4, state_data()} | {next_state, s4, state_data(), [{next_event, internal, {start_controller}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s3(internal, {start_controller}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s3(internal, {start_controller}, Data),
    after_transition(Next);
s3(cast, {_From, _Msg, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_controller[s3]: Purging stale early-path event ~p~n", [_Msg]),
        {keep_state, Data};
      false ->
        io:format("gen_controller[s3]: Postponing early-path event ~p~n", [_Msg]),
        {keep_state, Data, [postpone]}
    end.

-spec s4(cast, {pid(), {hard_ping}}, state_data()) -> {next_state, s6, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
s4(cast, {StoragePid, {hard_ping}}, Data) ->
    CallbackModule = get(callback_module),
    Next = try CallbackModule:s4(cast, {StoragePid, {hard_ping}}, Data)
           catch error:function_clause ->
             io:format("gen_controller[s4]: Callback had no clause for ~p, ignoring~n", [{hard_ping}]),
             {keep_state, Data}
           end,
    after_transition(Next);
s4(cast, {_From, _Msg, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_controller[s4]: Purging stale early-path event ~p~n", [_Msg]),
        {keep_state, Data};
      false ->
        io:format("gen_controller[s4]: Postponing early-path event ~p~n", [_Msg]),
        {keep_state, Data, [postpone]}
    end.

-spec s6(cast, {pid(), {get_mode}}, state_data()) -> {next_state, s11, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
s6(cast, {APIPid, {get_mode}}, Data) ->
    CallbackModule = get(callback_module),
    Next = try CallbackModule:s6(cast, {APIPid, {get_mode}}, Data)
           catch error:function_clause ->
             io:format("gen_controller[s6]: Callback had no clause for ~p, ignoring~n", [{get_mode}]),
             {keep_state, Data}
           end,
    after_transition(Next);
s6(cast, {_From, _Msg, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_controller[s6]: Purging stale early-path event ~p~n", [_Msg]),
        {keep_state, Data};
      false ->
        io:format("gen_controller[s6]: Postponing early-path event ~p~n", [_Msg]),
        {keep_state, Data, [postpone]}
    end.

-spec s8(internal, {timeout_notice}, state_data()) -> {next_state, s6, state_data()} | {next_state, s6, state_data(), [{next_event, internal, {timeout_notice}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s8(internal, {timeout_notice}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s8(internal, {timeout_notice}, Data),
    after_transition(Next);
s8(cast, {_StoragePid, {hard_ping}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_controller[s8]: Purging stale event ~p~n", [{hard_ping}]),
        {keep_state, Data};
      false ->
        io:format("gen_controller[s8]: Postponing event ~p~n", [{hard_ping}]),
        {keep_state, Data, [postpone]}
    end;
s8(cast, {_APIPid, {get_mode}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_controller[s8]: Purging stale event ~p~n", [{get_mode}]),
        {keep_state, Data};
      false ->
        io:format("gen_controller[s8]: Postponing event ~p~n", [{get_mode}]),
        {keep_state, Data, [postpone]}
    end;
s8(cast, {APIPid, {timeout}, Path}, Data) ->
    case message_status(Path, branch_path(mc1, right)) of
      stale ->
        io:format("gen_controller[s8]: Purging stale interrupt ~p~n", [{timeout}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s11(cast, {APIPid, {timeout}}, Data)
               catch error:function_clause ->
                 io:format("gen_controller[s8]: Callback had no interrupt clause for ~p, postponing~n", [{timeout}]),
                 {keep_state, Data, [postpone]}
               end,
        after_transition(commit_if_taken(Next, mc1, right));
      not_ready ->
        io:format("gen_controller[s8]: Postponing not-ready interrupt ~p~n", [{timeout}]),
        {keep_state, Data, [postpone]}
    end;
s8(cast, {_APIPid, {ack}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_controller[s8]: Purging stale event ~p~n", [{ack}]),
        {keep_state, Data};
      false ->
        io:format("gen_controller[s8]: Postponing event ~p~n", [{ack}]),
        {keep_state, Data, [postpone]}
    end;
s8(cast, {_APIPid, {error_ack}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_controller[s8]: Purging stale event ~p~n", [{error_ack}]),
        {keep_state, Data};
      false ->
        io:format("gen_controller[s8]: Postponing event ~p~n", [{error_ack}]),
        {keep_state, Data, [postpone]}
    end;
s8(cast, {_APIPid, {shutdown_ack}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_controller[s8]: Purging stale event ~p~n", [{shutdown_ack}]),
        {keep_state, Data};
      false ->
        io:format("gen_controller[s8]: Postponing event ~p~n", [{shutdown_ack}]),
        {keep_state, Data, [postpone]}
    end.

%% Mixed-choice entry state
-spec s11(internal | cast, {error_notice} | {service_operational} | {shutdown_api} | {pid(), {timeout}, list()}, state_data()) -> {next_state, s12, state_data()} | {next_state, s15, state_data()} | {next_state, s19, state_data()} | {next_state, s8, state_data()} | {next_state, s12, state_data(), [{next_event, internal, {error_notice}}] } | {next_state, s12, state_data(), [{next_event, internal, {service_operational}}] } | {next_state, s12, state_data(), [{next_event, internal, {shutdown_api}}] } | {next_state, s15, state_data(), [{next_event, internal, {error_notice}}] } | {next_state, s15, state_data(), [{next_event, internal, {service_operational}}] } | {next_state, s15, state_data(), [{next_event, internal, {shutdown_api}}] } | {next_state, s19, state_data(), [{next_event, internal, {error_notice}}] } | {next_state, s19, state_data(), [{next_event, internal, {service_operational}}] } | {next_state, s19, state_data(), [{next_event, internal, {shutdown_api}}] } | {next_state, s8, state_data(), [{next_event, internal, {error_notice}}] } | {next_state, s8, state_data(), [{next_event, internal, {service_operational}}] } | {next_state, s8, state_data(), [{next_event, internal, {shutdown_api}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s11(internal, {error_notice}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s11(internal, {error_notice}, Data),
    after_transition(Next);
s11(cast, {APIPid, {timeout}, Path}, Data) ->
    case message_status(Path, branch_path(mc1, right)) of
      stale ->
        io:format("gen_controller[s11]: Purging stale event ~p~n", [{timeout}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s11(cast, {APIPid, {timeout}}, Data)
               catch error:function_clause ->
                 io:format("gen_controller[s11]: Callback had no clause for ~p, postponing~n", [{timeout}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {next_state, s8, _} -> after_transition(commit_if_taken(Next, mc1, right));
          {next_state, s8, _, _} -> after_transition(commit_if_taken(Next, mc1, right));
          _ -> after_transition(Next)
        end;
      not_ready ->
        io:format("gen_controller[s11]: Postponing not-ready event ~p~n", [{timeout}]),
        {keep_state, Data, [postpone]}
    end;
s11(internal, {shutdown_api}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s11(internal, {shutdown_api}, Data),
    after_transition(Next);
s11(internal, {service_operational}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s11(internal, {service_operational}, Data),
    after_transition(Next);
s11(cast, {_StoragePid, {hard_ping}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_controller[s11]: Purging stale event ~p~n", [{hard_ping}]),
        {keep_state, Data};
      false ->
        io:format("gen_controller[s11]: Postponing event ~p~n", [{hard_ping}]),
        {keep_state, Data, [postpone]}
    end;
s11(cast, {_APIPid, {get_mode}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_controller[s11]: Purging stale event ~p~n", [{get_mode}]),
        {keep_state, Data};
      false ->
        io:format("gen_controller[s11]: Postponing event ~p~n", [{get_mode}]),
        {keep_state, Data, [postpone]}
    end;
s11(cast, {_APIPid, {ack}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_controller[s11]: Purging stale event ~p~n", [{ack}]),
        {keep_state, Data};
      false ->
        io:format("gen_controller[s11]: Postponing event ~p~n", [{ack}]),
        {keep_state, Data, [postpone]}
    end;
s11(cast, {_APIPid, {error_ack}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_controller[s11]: Purging stale event ~p~n", [{error_ack}]),
        {keep_state, Data};
      false ->
        io:format("gen_controller[s11]: Postponing event ~p~n", [{error_ack}]),
        {keep_state, Data, [postpone]}
    end;
s11(cast, {_APIPid, {shutdown_ack}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_controller[s11]: Purging stale event ~p~n", [{shutdown_ack}]),
        {keep_state, Data};
      false ->
        io:format("gen_controller[s11]: Postponing event ~p~n", [{shutdown_ack}]),
        {keep_state, Data, [postpone]}
    end.

-spec s12(cast, {pid(), {ack}, list()} | {pid(), {timeout}, list()}, state_data()) -> {next_state, s6, state_data()} | {next_state, s8, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
s12(cast, {APIPid, {ack}, Path}, Data) ->
    case message_status(Path, current_path()) of
      stale ->
        io:format("gen_controller[s12]: Purging stale event ~p~n", [{ack}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s12(cast, {APIPid, {ack}}, Data)
               catch error:function_clause ->
                 io:format("gen_controller[s12]: Callback had no clause for ~p, postponing~n", [{ack}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> after_transition(Next)
        end;
      not_ready ->
        io:format("gen_controller[s12]: Postponing not-ready event ~p~n", [{ack}]),
        {keep_state, Data, [postpone]}
    end;
s12(cast, {APIPid, {timeout}, Path}, Data) ->
    case message_status(Path, branch_path(mc1, right)) of
      stale ->
        io:format("gen_controller[s12]: Purging stale event ~p~n", [{timeout}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s12(cast, {APIPid, {timeout}}, Data)
               catch error:function_clause ->
                 io:format("gen_controller[s12]: Callback had no clause for ~p, postponing~n", [{timeout}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {next_state, s8, _} -> after_transition(commit_if_taken(Next, mc1, right));
          {next_state, s8, _, _} -> after_transition(commit_if_taken(Next, mc1, right));
          _ -> after_transition(Next)
        end;
      not_ready ->
        io:format("gen_controller[s12]: Postponing not-ready event ~p~n", [{timeout}]),
        {keep_state, Data, [postpone]}
    end;
s12(cast, {_StoragePid, {hard_ping}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_controller[s12]: Purging stale event ~p~n", [{hard_ping}]),
        {keep_state, Data};
      false ->
        io:format("gen_controller[s12]: Postponing event ~p~n", [{hard_ping}]),
        {keep_state, Data, [postpone]}
    end;
s12(cast, {_APIPid, {get_mode}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_controller[s12]: Purging stale event ~p~n", [{get_mode}]),
        {keep_state, Data};
      false ->
        io:format("gen_controller[s12]: Postponing event ~p~n", [{get_mode}]),
        {keep_state, Data, [postpone]}
    end;
s12(cast, {_APIPid, {error_ack}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_controller[s12]: Purging stale event ~p~n", [{error_ack}]),
        {keep_state, Data};
      false ->
        io:format("gen_controller[s12]: Postponing event ~p~n", [{error_ack}]),
        {keep_state, Data, [postpone]}
    end;
s12(cast, {_APIPid, {shutdown_ack}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_controller[s12]: Purging stale event ~p~n", [{shutdown_ack}]),
        {keep_state, Data};
      false ->
        io:format("gen_controller[s12]: Postponing event ~p~n", [{shutdown_ack}]),
        {keep_state, Data, [postpone]}
    end.

-spec s15(cast, {pid(), {error_ack}, list()} | {pid(), {timeout}, list()}, state_data()) -> {next_state, s16, state_data()} | {next_state, s8, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
s15(cast, {APIPid, {error_ack}, Path}, Data) ->
    case message_status(Path, current_path()) of
      stale ->
        io:format("gen_controller[s15]: Purging stale event ~p~n", [{error_ack}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s15(cast, {APIPid, {error_ack}}, Data)
               catch error:function_clause ->
                 io:format("gen_controller[s15]: Callback had no clause for ~p, postponing~n", [{error_ack}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> after_transition(Next)
        end;
      not_ready ->
        io:format("gen_controller[s15]: Postponing not-ready event ~p~n", [{error_ack}]),
        {keep_state, Data, [postpone]}
    end;
s15(cast, {APIPid, {timeout}, Path}, Data) ->
    case message_status(Path, branch_path(mc1, right)) of
      stale ->
        io:format("gen_controller[s15]: Purging stale event ~p~n", [{timeout}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s15(cast, {APIPid, {timeout}}, Data)
               catch error:function_clause ->
                 io:format("gen_controller[s15]: Callback had no clause for ~p, postponing~n", [{timeout}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {next_state, s8, _} -> after_transition(commit_if_taken(Next, mc1, right));
          {next_state, s8, _, _} -> after_transition(commit_if_taken(Next, mc1, right));
          _ -> after_transition(Next)
        end;
      not_ready ->
        io:format("gen_controller[s15]: Postponing not-ready event ~p~n", [{timeout}]),
        {keep_state, Data, [postpone]}
    end;
s15(cast, {_StoragePid, {hard_ping}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_controller[s15]: Purging stale event ~p~n", [{hard_ping}]),
        {keep_state, Data};
      false ->
        io:format("gen_controller[s15]: Postponing event ~p~n", [{hard_ping}]),
        {keep_state, Data, [postpone]}
    end;
s15(cast, {_APIPid, {get_mode}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_controller[s15]: Purging stale event ~p~n", [{get_mode}]),
        {keep_state, Data};
      false ->
        io:format("gen_controller[s15]: Postponing event ~p~n", [{get_mode}]),
        {keep_state, Data, [postpone]}
    end;
s15(cast, {_APIPid, {ack}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_controller[s15]: Purging stale event ~p~n", [{ack}]),
        {keep_state, Data};
      false ->
        io:format("gen_controller[s15]: Postponing event ~p~n", [{ack}]),
        {keep_state, Data, [postpone]}
    end;
s15(cast, {_APIPid, {shutdown_ack}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_controller[s15]: Purging stale event ~p~n", [{shutdown_ack}]),
        {keep_state, Data};
      false ->
        io:format("gen_controller[s15]: Postponing event ~p~n", [{shutdown_ack}]),
        {keep_state, Data, [postpone]}
    end.

-spec s16(internal, {storage_restart}, state_data()) -> {next_state, s6, state_data()} | {next_state, s6, state_data(), [{next_event, internal, {storage_restart}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s16(internal, {storage_restart}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s16(internal, {storage_restart}, Data),
    after_transition(Next);
s16(cast, {_StoragePid, {hard_ping}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_controller[s16]: Purging stale event ~p~n", [{hard_ping}]),
        {keep_state, Data};
      false ->
        io:format("gen_controller[s16]: Postponing event ~p~n", [{hard_ping}]),
        {keep_state, Data, [postpone]}
    end;
s16(cast, {_APIPid, {get_mode}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_controller[s16]: Purging stale event ~p~n", [{get_mode}]),
        {keep_state, Data};
      false ->
        io:format("gen_controller[s16]: Postponing event ~p~n", [{get_mode}]),
        {keep_state, Data, [postpone]}
    end;
s16(cast, {APIPid, {timeout}, Path}, Data) ->
    case message_status(Path, branch_path(mc1, right)) of
      stale ->
        io:format("gen_controller[s16]: Purging stale interrupt ~p~n", [{timeout}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s11(cast, {APIPid, {timeout}}, Data)
               catch error:function_clause ->
                 io:format("gen_controller[s16]: Callback had no interrupt clause for ~p, postponing~n", [{timeout}]),
                 {keep_state, Data, [postpone]}
               end,
        after_transition(commit_if_taken(Next, mc1, right));
      not_ready ->
        io:format("gen_controller[s16]: Postponing not-ready interrupt ~p~n", [{timeout}]),
        {keep_state, Data, [postpone]}
    end;
s16(cast, {_APIPid, {ack}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_controller[s16]: Purging stale event ~p~n", [{ack}]),
        {keep_state, Data};
      false ->
        io:format("gen_controller[s16]: Postponing event ~p~n", [{ack}]),
        {keep_state, Data, [postpone]}
    end;
s16(cast, {_APIPid, {error_ack}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_controller[s16]: Purging stale event ~p~n", [{error_ack}]),
        {keep_state, Data};
      false ->
        io:format("gen_controller[s16]: Postponing event ~p~n", [{error_ack}]),
        {keep_state, Data, [postpone]}
    end;
s16(cast, {_APIPid, {shutdown_ack}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_controller[s16]: Purging stale event ~p~n", [{shutdown_ack}]),
        {keep_state, Data};
      false ->
        io:format("gen_controller[s16]: Postponing event ~p~n", [{shutdown_ack}]),
        {keep_state, Data, [postpone]}
    end.

-spec s19(cast, {pid(), {timeout}, list()} | {pid(), {shutdown_ack}, list()}, state_data()) -> {next_state, s20, state_data()} | {next_state, s8, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
s19(cast, {APIPid, {shutdown_ack}, Path}, Data) ->
    case message_status(Path, current_path()) of
      stale ->
        io:format("gen_controller[s19]: Purging stale event ~p~n", [{shutdown_ack}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s19(cast, {APIPid, {shutdown_ack}}, Data)
               catch error:function_clause ->
                 io:format("gen_controller[s19]: Callback had no clause for ~p, postponing~n", [{shutdown_ack}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> after_transition(Next)
        end;
      not_ready ->
        io:format("gen_controller[s19]: Postponing not-ready event ~p~n", [{shutdown_ack}]),
        {keep_state, Data, [postpone]}
    end;
s19(cast, {APIPid, {timeout}, Path}, Data) ->
    case message_status(Path, branch_path(mc1, right)) of
      stale ->
        io:format("gen_controller[s19]: Purging stale event ~p~n", [{timeout}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s19(cast, {APIPid, {timeout}}, Data)
               catch error:function_clause ->
                 io:format("gen_controller[s19]: Callback had no clause for ~p, postponing~n", [{timeout}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {next_state, s8, _} -> after_transition(commit_if_taken(Next, mc1, right));
          {next_state, s8, _, _} -> after_transition(commit_if_taken(Next, mc1, right));
          _ -> after_transition(Next)
        end;
      not_ready ->
        io:format("gen_controller[s19]: Postponing not-ready event ~p~n", [{timeout}]),
        {keep_state, Data, [postpone]}
    end;
s19(cast, {_StoragePid, {hard_ping}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_controller[s19]: Purging stale event ~p~n", [{hard_ping}]),
        {keep_state, Data};
      false ->
        io:format("gen_controller[s19]: Postponing event ~p~n", [{hard_ping}]),
        {keep_state, Data, [postpone]}
    end;
s19(cast, {_APIPid, {get_mode}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_controller[s19]: Purging stale event ~p~n", [{get_mode}]),
        {keep_state, Data};
      false ->
        io:format("gen_controller[s19]: Postponing event ~p~n", [{get_mode}]),
        {keep_state, Data, [postpone]}
    end;
s19(cast, {_APIPid, {ack}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_controller[s19]: Purging stale event ~p~n", [{ack}]),
        {keep_state, Data};
      false ->
        io:format("gen_controller[s19]: Postponing event ~p~n", [{ack}]),
        {keep_state, Data, [postpone]}
    end;
s19(cast, {_APIPid, {error_ack}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_controller[s19]: Purging stale event ~p~n", [{error_ack}]),
        {keep_state, Data};
      false ->
        io:format("gen_controller[s19]: Postponing event ~p~n", [{error_ack}]),
        {keep_state, Data, [postpone]}
    end.

-spec s20(internal, {shutdown_storage}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
s20(internal, {shutdown_storage}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s20(internal, {shutdown_storage}, Data),
    after_transition(Next);
s20(cast, {_StoragePid, {hard_ping}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_controller[s20]: Purging stale event ~p~n", [{hard_ping}]),
        {keep_state, Data};
      false ->
        io:format("gen_controller[s20]: Postponing event ~p~n", [{hard_ping}]),
        {keep_state, Data, [postpone]}
    end;
s20(cast, {_APIPid, {get_mode}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_controller[s20]: Purging stale event ~p~n", [{get_mode}]),
        {keep_state, Data};
      false ->
        io:format("gen_controller[s20]: Postponing event ~p~n", [{get_mode}]),
        {keep_state, Data, [postpone]}
    end;
s20(cast, {APIPid, {timeout}, Path}, Data) ->
    case message_status(Path, branch_path(mc1, right)) of
      stale ->
        io:format("gen_controller[s20]: Purging stale interrupt ~p~n", [{timeout}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s11(cast, {APIPid, {timeout}}, Data)
               catch error:function_clause ->
                 io:format("gen_controller[s20]: Callback had no interrupt clause for ~p, postponing~n", [{timeout}]),
                 {keep_state, Data, [postpone]}
               end,
        after_transition(commit_if_taken(Next, mc1, right));
      not_ready ->
        io:format("gen_controller[s20]: Postponing not-ready interrupt ~p~n", [{timeout}]),
        {keep_state, Data, [postpone]}
    end;
s20(cast, {_APIPid, {ack}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_controller[s20]: Purging stale event ~p~n", [{ack}]),
        {keep_state, Data};
      false ->
        io:format("gen_controller[s20]: Postponing event ~p~n", [{ack}]),
        {keep_state, Data, [postpone]}
    end;
s20(cast, {_APIPid, {error_ack}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_controller[s20]: Purging stale event ~p~n", [{error_ack}]),
        {keep_state, Data};
      false ->
        io:format("gen_controller[s20]: Postponing event ~p~n", [{error_ack}]),
        {keep_state, Data, [postpone]}
    end;
s20(cast, {_APIPid, {shutdown_ack}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_controller[s20]: Purging stale event ~p~n", [{shutdown_ack}]),
        {keep_state, Data};
      false ->
        io:format("gen_controller[s20]: Postponing event ~p~n", [{shutdown_ack}]),
        {keep_state, Data, [postpone]}
    end.


%% ---------- Send helpers----------

-spec send_s1_start_storage(StoragePid :: pid(), _Data :: state_data()) -> ok.
send_s1_start_storage(StoragePid, _Data) ->
    gen_statem:cast(StoragePid, {self(), {start_storage}}).


-spec send_s3_start_controller(APIPid :: pid(), _Data :: state_data()) -> ok.
send_s3_start_controller(APIPid, _Data) ->
    gen_statem:cast(APIPid, {self(), {start_controller}}).


-spec send_s8_timeout_notice(StoragePid :: pid(), _Data :: state_data()) -> ok.
send_s8_timeout_notice(StoragePid, _Data) ->
    Path = current_path(),
    gen_statem:cast(StoragePid, {self(), {timeout_notice}, Path}).


-spec send_s11_error_notice(APIPid :: pid(), _Data :: state_data()) -> ok.
send_s11_error_notice(APIPid, _Data) ->
    Path = branch_path(mc1, left),
    set_current_path(Path),
    gen_statem:cast(APIPid, {self(), {error_notice}, Path}).


-spec send_s11_service_operational(APIPid :: pid(), _Data :: state_data()) -> ok.
send_s11_service_operational(APIPid, _Data) ->
    Path = branch_path(mc1, left),
    set_current_path(Path),
    gen_statem:cast(APIPid, {self(), {service_operational}, Path}).


-spec send_s11_shutdown_api(APIPid :: pid(), _Data :: state_data()) -> ok.
send_s11_shutdown_api(APIPid, _Data) ->
    Path = branch_path(mc1, left),
    set_current_path(Path),
    gen_statem:cast(APIPid, {self(), {shutdown_api}, Path}).


-spec send_s16_storage_restart(StoragePid :: pid(), _Data :: state_data()) -> ok.
send_s16_storage_restart(StoragePid, _Data) ->
    Path = current_path(),
    gen_statem:cast(StoragePid, {self(), {storage_restart}, Path}).


-spec send_s20_shutdown_storage(StoragePid :: pid(), _Data :: state_data()) -> ok.
send_s20_shutdown_storage(StoragePid, _Data) ->
    Path = current_path(),
    gen_statem:cast(StoragePid, {self(), {shutdown_storage}, Path}).


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

after_transition({next_state, s11, _} = Next) -> enter_mc(mc1), Next;
after_transition({next_state, s11, _, _} = Next) -> enter_mc(mc1), Next;
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

