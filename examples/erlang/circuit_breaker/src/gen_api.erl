
%%%-------------------------------------------------------------------
%%% gen_api.erl — generated generic behaviour module (gen_statem)
%%%-------------------------------------------------------------------
-module(gen_api).
-behaviour(gen_statem).

%% Public API
-export([start_link/2, callback_mode/0]).

%% gen_statem callbacks
-export([init/1, code_change/4, terminate/3,
  s1/3,
  s3/3,
  s5/3,
  s6/3,
  s8/3,
  s11/3,
  s12/3,
  s13/3,
  s14/3,
  s15/3,
  s18/3,
  s19/3,
  s20/3,
  s23/3,
  s24/3,
  s25/3,
  send_s3_ready/2,
  send_s6_get_mode/2,
  send_s8_timeout_notice/2,
  send_s11_timeout/2,
  send_s12_ack/2,
  send_s13_storage_request/2,
  send_s15_api_response/2,
  send_s18_error_ack/2,
  send_s19_cancel_ack/2,
  send_s20_error_response/2,
  send_s23_shutdown_ack/2,
  send_s24_prepare_shutdown/2,
  send_s25_shutdown_user/2]).

%% Types & records
-include("api.hrl").
-export_type([state_data/0]).
-type state_data() :: #state_data{}.

-callback init(Args :: list()) -> {ok, s1, state_data()}.
-callback s1(cast, {pid(), {start_controller}}, state_data()) -> {next_state, s3, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s3(internal, {ready}, state_data()) -> {next_state, s5, state_data()} | {next_state, s5, state_data(), [{next_event, internal, {ready}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s5(cast, {pid(), {request}}, state_data()) -> {next_state, s6, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s6(internal, {get_mode}, state_data()) -> {next_state, s11, state_data()} | {next_state, s11, state_data(), [{next_event, internal, {get_mode}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s8(internal, {timeout_notice}, state_data()) -> {next_state, s5, state_data()} | {next_state, s5, state_data(), [{next_event, internal, {timeout_notice}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s11(internal | cast, {timeout} | {pid(), {error_notice}} | {pid(), {service_operational}} | {pid(), {shutdown_api}}, state_data()) -> {next_state, s12, state_data()} | {next_state, s18, state_data()} | {next_state, s23, state_data()} | {next_state, s8, state_data()} | {next_state, s12, state_data(), [{next_event, internal, {timeout}}] } | {next_state, s18, state_data(), [{next_event, internal, {timeout}}] } | {next_state, s23, state_data(), [{next_event, internal, {timeout}}] } | {next_state, s8, state_data(), [{next_event, internal, {timeout}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s12(internal, {ack}, state_data()) -> {next_state, s13, state_data()} | {next_state, s13, state_data(), [{next_event, internal, {ack}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s13(internal, {storage_request}, state_data()) -> {next_state, s14, state_data()} | {next_state, s14, state_data(), [{next_event, internal, {storage_request}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s14(cast, {pid(), {storage_reponse}}, state_data()) -> {next_state, s15, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s15(internal, {api_response}, state_data()) -> {next_state, s5, state_data()} | {next_state, s5, state_data(), [{next_event, internal, {api_response}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s18(internal, {error_ack}, state_data()) -> {next_state, s19, state_data()} | {next_state, s19, state_data(), [{next_event, internal, {error_ack}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s19(internal, {cancel_ack}, state_data()) -> {next_state, s20, state_data()} | {next_state, s20, state_data(), [{next_event, internal, {cancel_ack}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s20(internal, {error_response}, state_data()) -> {next_state, s5, state_data()} | {next_state, s5, state_data(), [{next_event, internal, {error_response}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s23(internal, {shutdown_ack}, state_data()) -> {next_state, s24, state_data()} | {next_state, s24, state_data(), [{next_event, internal, {shutdown_ack}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s24(internal, {prepare_shutdown}, state_data()) -> {next_state, s25, state_data()} | {next_state, s25, state_data(), [{next_event, internal, {prepare_shutdown}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s25(internal, {shutdown_user}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.

%% ===== API =====
-spec start_link(CallbackModule :: module(), Args :: list()) ->
    {ok, pid()} | {error, term()}.
start_link(CallbackModule, Args) ->
    case code:ensure_loaded(CallbackModule) of
        {module, CallbackModule} ->
            gen_statem:start_link({local, CallbackModule}, gen_api, {CallbackModule, Args}, [{debug, [trace, {log_to_file, "api_debug.log"}]}]);
        {error, Reason} ->
            {error, Reason}
    end.

-spec callback_mode() -> state_functions.
callback_mode() -> state_functions.

%% ===== gen_statem =====
-spec init({module(), list()}) ->
    {ok, s1, state_data()}.
init({CallbackModule, _Args}) ->
    io:format("api: Initializing with callback module ~p~n", [CallbackModule]),
    put(callback_module, CallbackModule),
    init_context(),
    CallbackModule:init([]).

%% ---------- State functions----------
-spec s1(cast, {pid(), {start_controller}}, state_data()) -> {next_state, s3, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
s1(cast, {ControllerPid, {start_controller}}, Data) ->
    CallbackModule = get(callback_module),
    Next = try CallbackModule:s1(cast, {ControllerPid, {start_controller}}, Data)
           catch error:function_clause ->
             io:format("gen_api[s1]: Callback had no clause for ~p, ignoring~n", [{start_controller}]),
             {keep_state, Data}
           end,
    after_transition(Next);
s1(cast, {_From, _Msg, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s1]: Purging stale early-path event ~p~n", [_Msg]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s1]: Postponing early-path event ~p~n", [_Msg]),
        {keep_state, Data, [postpone]}
    end.

-spec s3(internal, {ready}, state_data()) -> {next_state, s5, state_data()} | {next_state, s5, state_data(), [{next_event, internal, {ready}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s3(internal, {ready}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s3(internal, {ready}, Data),
    after_transition(Next);
s3(cast, {_From, _Msg, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s3]: Purging stale early-path event ~p~n", [_Msg]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s3]: Postponing early-path event ~p~n", [_Msg]),
        {keep_state, Data, [postpone]}
    end.

-spec s5(cast, {pid(), {request}}, state_data()) -> {next_state, s6, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
s5(cast, {UsrPid, {request}}, Data) ->
    CallbackModule = get(callback_module),
    Next = try CallbackModule:s5(cast, {UsrPid, {request}}, Data)
           catch error:function_clause ->
             io:format("gen_api[s5]: Callback had no clause for ~p, ignoring~n", [{request}]),
             {keep_state, Data}
           end,
    after_transition(Next);
s5(cast, {_From, _Msg, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s5]: Purging stale early-path event ~p~n", [_Msg]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s5]: Postponing early-path event ~p~n", [_Msg]),
        {keep_state, Data, [postpone]}
    end.

-spec s6(internal, {get_mode}, state_data()) -> {next_state, s11, state_data()} | {next_state, s11, state_data(), [{next_event, internal, {get_mode}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s6(internal, {get_mode}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s6(internal, {get_mode}, Data),
    after_transition(Next);
s6(cast, {_From, _Msg, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s6]: Purging stale early-path event ~p~n", [_Msg]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s6]: Postponing early-path event ~p~n", [_Msg]),
        {keep_state, Data, [postpone]}
    end.

-spec s8(internal, {timeout_notice}, state_data()) -> {next_state, s5, state_data()} | {next_state, s5, state_data(), [{next_event, internal, {timeout_notice}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s8(internal, {timeout_notice}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s8(internal, {timeout_notice}, Data),
    after_transition(Next);
s8(cast, {_ControllerPid, {start_controller}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s8]: Purging stale event ~p~n", [{start_controller}]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s8]: Postponing event ~p~n", [{start_controller}]),
        {keep_state, Data, [postpone]}
    end;
s8(cast, {_UsrPid, {request}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s8]: Purging stale event ~p~n", [{request}]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s8]: Postponing event ~p~n", [{request}]),
        {keep_state, Data, [postpone]}
    end;
s8(cast, {_ControllerPid, {error_notice}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s8]: Purging stale event ~p~n", [{error_notice}]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s8]: Postponing event ~p~n", [{error_notice}]),
        {keep_state, Data, [postpone]}
    end;
s8(cast, {_ControllerPid, {shutdown_api}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s8]: Purging stale event ~p~n", [{shutdown_api}]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s8]: Postponing event ~p~n", [{shutdown_api}]),
        {keep_state, Data, [postpone]}
    end;
s8(cast, {_ControllerPid, {service_operational}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s8]: Purging stale event ~p~n", [{service_operational}]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s8]: Postponing event ~p~n", [{service_operational}]),
        {keep_state, Data, [postpone]}
    end;
s8(cast, {_StoragePid, {storage_reponse}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s8]: Purging stale event ~p~n", [{storage_reponse}]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s8]: Postponing event ~p~n", [{storage_reponse}]),
        {keep_state, Data, [postpone]}
    end.

%% Mixed-choice entry state
-spec s11(internal | cast, {timeout} | {pid(), {error_notice}, list()} | {pid(), {shutdown_api}, list()} | {pid(), {service_operational}, list()}, state_data()) -> {next_state, s12, state_data()} | {next_state, s18, state_data()} | {next_state, s23, state_data()} | {next_state, s8, state_data()} | {next_state, s12, state_data(), [{next_event, internal, {timeout}}] } | {next_state, s18, state_data(), [{next_event, internal, {timeout}}] } | {next_state, s23, state_data(), [{next_event, internal, {timeout}}] } | {next_state, s8, state_data(), [{next_event, internal, {timeout}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s11(cast, {ControllerPid, {service_operational}, Path}, Data) ->
    case message_status(Path, branch_path(mc1, left)) of
      stale ->
        io:format("gen_api[s11]: Purging stale event ~p~n", [{service_operational}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s11(cast, {ControllerPid, {service_operational}}, Data)
               catch error:function_clause ->
                 io:format("gen_api[s11]: Callback had no clause for ~p, postponing~n", [{service_operational}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {next_state, s8, _} -> after_transition(commit_if_taken(Next, mc1, right));
          {next_state, s8, _, _} -> after_transition(commit_if_taken(Next, mc1, right));
          {next_state, s12, _} -> after_transition(commit_if_taken(Next, mc1, left));
          {next_state, s12, _, _} -> after_transition(commit_if_taken(Next, mc1, left));
          _ -> after_transition(Next)
        end;
      not_ready ->
        io:format("gen_api[s11]: Postponing not-ready event ~p~n", [{service_operational}]),
        {keep_state, Data, [postpone]}
    end;
s11(internal, {timeout}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s11(internal, {timeout}, Data),
    after_transition(Next);
s11(cast, {ControllerPid, {shutdown_api}, Path}, Data) ->
    case message_status(Path, branch_path(mc1, left)) of
      stale ->
        io:format("gen_api[s11]: Purging stale event ~p~n", [{shutdown_api}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s11(cast, {ControllerPid, {shutdown_api}}, Data)
               catch error:function_clause ->
                 io:format("gen_api[s11]: Callback had no clause for ~p, postponing~n", [{shutdown_api}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {next_state, s8, _} -> after_transition(commit_if_taken(Next, mc1, right));
          {next_state, s8, _, _} -> after_transition(commit_if_taken(Next, mc1, right));
          {next_state, s23, _} -> after_transition(commit_if_taken(Next, mc1, left));
          {next_state, s23, _, _} -> after_transition(commit_if_taken(Next, mc1, left));
          _ -> after_transition(Next)
        end;
      not_ready ->
        io:format("gen_api[s11]: Postponing not-ready event ~p~n", [{shutdown_api}]),
        {keep_state, Data, [postpone]}
    end;
s11(cast, {ControllerPid, {error_notice}, Path}, Data) ->
    case message_status(Path, branch_path(mc1, left)) of
      stale ->
        io:format("gen_api[s11]: Purging stale event ~p~n", [{error_notice}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s11(cast, {ControllerPid, {error_notice}}, Data)
               catch error:function_clause ->
                 io:format("gen_api[s11]: Callback had no clause for ~p, postponing~n", [{error_notice}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {next_state, s8, _} -> after_transition(commit_if_taken(Next, mc1, right));
          {next_state, s8, _, _} -> after_transition(commit_if_taken(Next, mc1, right));
          {next_state, s18, _} -> after_transition(commit_if_taken(Next, mc1, left));
          {next_state, s18, _, _} -> after_transition(commit_if_taken(Next, mc1, left));
          _ -> after_transition(Next)
        end;
      not_ready ->
        io:format("gen_api[s11]: Postponing not-ready event ~p~n", [{error_notice}]),
        {keep_state, Data, [postpone]}
    end;
s11(cast, {_ControllerPid, {start_controller}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s11]: Purging stale event ~p~n", [{start_controller}]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s11]: Postponing event ~p~n", [{start_controller}]),
        {keep_state, Data, [postpone]}
    end;
s11(cast, {_UsrPid, {request}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s11]: Purging stale event ~p~n", [{request}]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s11]: Postponing event ~p~n", [{request}]),
        {keep_state, Data, [postpone]}
    end;
s11(cast, {_StoragePid, {storage_reponse}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s11]: Purging stale event ~p~n", [{storage_reponse}]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s11]: Postponing event ~p~n", [{storage_reponse}]),
        {keep_state, Data, [postpone]}
    end.

-spec s12(internal, {ack}, state_data()) -> {next_state, s13, state_data()} | {next_state, s13, state_data(), [{next_event, internal, {ack}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s12(internal, {ack}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s12(internal, {ack}, Data),
    after_transition(Next);
s12(cast, {_ControllerPid, {start_controller}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s12]: Purging stale event ~p~n", [{start_controller}]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s12]: Postponing event ~p~n", [{start_controller}]),
        {keep_state, Data, [postpone]}
    end;
s12(cast, {_UsrPid, {request}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s12]: Purging stale event ~p~n", [{request}]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s12]: Postponing event ~p~n", [{request}]),
        {keep_state, Data, [postpone]}
    end;
s12(cast, {_ControllerPid, {error_notice}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s12]: Purging stale event ~p~n", [{error_notice}]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s12]: Postponing event ~p~n", [{error_notice}]),
        {keep_state, Data, [postpone]}
    end;
s12(cast, {_ControllerPid, {shutdown_api}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s12]: Purging stale event ~p~n", [{shutdown_api}]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s12]: Postponing event ~p~n", [{shutdown_api}]),
        {keep_state, Data, [postpone]}
    end;
s12(cast, {_ControllerPid, {service_operational}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s12]: Purging stale event ~p~n", [{service_operational}]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s12]: Postponing event ~p~n", [{service_operational}]),
        {keep_state, Data, [postpone]}
    end;
s12(cast, {_StoragePid, {storage_reponse}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s12]: Purging stale event ~p~n", [{storage_reponse}]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s12]: Postponing event ~p~n", [{storage_reponse}]),
        {keep_state, Data, [postpone]}
    end.

-spec s13(internal, {storage_request}, state_data()) -> {next_state, s14, state_data()} | {next_state, s14, state_data(), [{next_event, internal, {storage_request}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s13(internal, {storage_request}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s13(internal, {storage_request}, Data),
    after_transition(Next);
s13(cast, {_ControllerPid, {start_controller}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s13]: Purging stale event ~p~n", [{start_controller}]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s13]: Postponing event ~p~n", [{start_controller}]),
        {keep_state, Data, [postpone]}
    end;
s13(cast, {_UsrPid, {request}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s13]: Purging stale event ~p~n", [{request}]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s13]: Postponing event ~p~n", [{request}]),
        {keep_state, Data, [postpone]}
    end;
s13(cast, {_ControllerPid, {error_notice}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s13]: Purging stale event ~p~n", [{error_notice}]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s13]: Postponing event ~p~n", [{error_notice}]),
        {keep_state, Data, [postpone]}
    end;
s13(cast, {_ControllerPid, {shutdown_api}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s13]: Purging stale event ~p~n", [{shutdown_api}]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s13]: Postponing event ~p~n", [{shutdown_api}]),
        {keep_state, Data, [postpone]}
    end;
s13(cast, {_ControllerPid, {service_operational}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s13]: Purging stale event ~p~n", [{service_operational}]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s13]: Postponing event ~p~n", [{service_operational}]),
        {keep_state, Data, [postpone]}
    end;
s13(cast, {_StoragePid, {storage_reponse}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s13]: Purging stale event ~p~n", [{storage_reponse}]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s13]: Postponing event ~p~n", [{storage_reponse}]),
        {keep_state, Data, [postpone]}
    end.

-spec s14(cast, {pid(), {storage_reponse}, list()}, state_data()) -> {next_state, s15, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
s14(cast, {StoragePid, {storage_reponse}, Path}, Data) ->
    case message_status(Path, current_path()) of
      stale ->
        io:format("gen_api[s14]: Purging stale event ~p~n", [{storage_reponse}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s14(cast, {StoragePid, {storage_reponse}}, Data)
               catch error:function_clause ->
                 io:format("gen_api[s14]: Callback had no clause for ~p, postponing~n", [{storage_reponse}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> after_transition(Next)
        end;
      not_ready ->
        io:format("gen_api[s14]: Postponing not-ready event ~p~n", [{storage_reponse}]),
        {keep_state, Data, [postpone]}
    end;
s14(cast, {_ControllerPid, {start_controller}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s14]: Purging stale event ~p~n", [{start_controller}]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s14]: Postponing event ~p~n", [{start_controller}]),
        {keep_state, Data, [postpone]}
    end;
s14(cast, {_UsrPid, {request}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s14]: Purging stale event ~p~n", [{request}]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s14]: Postponing event ~p~n", [{request}]),
        {keep_state, Data, [postpone]}
    end;
s14(cast, {_ControllerPid, {error_notice}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s14]: Purging stale event ~p~n", [{error_notice}]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s14]: Postponing event ~p~n", [{error_notice}]),
        {keep_state, Data, [postpone]}
    end;
s14(cast, {_ControllerPid, {shutdown_api}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s14]: Purging stale event ~p~n", [{shutdown_api}]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s14]: Postponing event ~p~n", [{shutdown_api}]),
        {keep_state, Data, [postpone]}
    end;
s14(cast, {_ControllerPid, {service_operational}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s14]: Purging stale event ~p~n", [{service_operational}]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s14]: Postponing event ~p~n", [{service_operational}]),
        {keep_state, Data, [postpone]}
    end.

-spec s15(internal, {api_response}, state_data()) -> {next_state, s5, state_data()} | {next_state, s5, state_data(), [{next_event, internal, {api_response}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s15(internal, {api_response}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s15(internal, {api_response}, Data),
    after_transition(Next);
s15(cast, {_ControllerPid, {start_controller}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s15]: Purging stale event ~p~n", [{start_controller}]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s15]: Postponing event ~p~n", [{start_controller}]),
        {keep_state, Data, [postpone]}
    end;
s15(cast, {_UsrPid, {request}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s15]: Purging stale event ~p~n", [{request}]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s15]: Postponing event ~p~n", [{request}]),
        {keep_state, Data, [postpone]}
    end;
s15(cast, {_ControllerPid, {error_notice}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s15]: Purging stale event ~p~n", [{error_notice}]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s15]: Postponing event ~p~n", [{error_notice}]),
        {keep_state, Data, [postpone]}
    end;
s15(cast, {_ControllerPid, {shutdown_api}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s15]: Purging stale event ~p~n", [{shutdown_api}]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s15]: Postponing event ~p~n", [{shutdown_api}]),
        {keep_state, Data, [postpone]}
    end;
s15(cast, {_ControllerPid, {service_operational}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s15]: Purging stale event ~p~n", [{service_operational}]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s15]: Postponing event ~p~n", [{service_operational}]),
        {keep_state, Data, [postpone]}
    end;
s15(cast, {_StoragePid, {storage_reponse}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s15]: Purging stale event ~p~n", [{storage_reponse}]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s15]: Postponing event ~p~n", [{storage_reponse}]),
        {keep_state, Data, [postpone]}
    end.

-spec s18(internal, {error_ack}, state_data()) -> {next_state, s19, state_data()} | {next_state, s19, state_data(), [{next_event, internal, {error_ack}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s18(internal, {error_ack}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s18(internal, {error_ack}, Data),
    after_transition(Next);
s18(cast, {_ControllerPid, {start_controller}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s18]: Purging stale event ~p~n", [{start_controller}]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s18]: Postponing event ~p~n", [{start_controller}]),
        {keep_state, Data, [postpone]}
    end;
s18(cast, {_UsrPid, {request}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s18]: Purging stale event ~p~n", [{request}]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s18]: Postponing event ~p~n", [{request}]),
        {keep_state, Data, [postpone]}
    end;
s18(cast, {_ControllerPid, {error_notice}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s18]: Purging stale event ~p~n", [{error_notice}]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s18]: Postponing event ~p~n", [{error_notice}]),
        {keep_state, Data, [postpone]}
    end;
s18(cast, {_ControllerPid, {shutdown_api}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s18]: Purging stale event ~p~n", [{shutdown_api}]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s18]: Postponing event ~p~n", [{shutdown_api}]),
        {keep_state, Data, [postpone]}
    end;
s18(cast, {_ControllerPid, {service_operational}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s18]: Purging stale event ~p~n", [{service_operational}]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s18]: Postponing event ~p~n", [{service_operational}]),
        {keep_state, Data, [postpone]}
    end;
s18(cast, {_StoragePid, {storage_reponse}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s18]: Purging stale event ~p~n", [{storage_reponse}]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s18]: Postponing event ~p~n", [{storage_reponse}]),
        {keep_state, Data, [postpone]}
    end.

-spec s19(internal, {cancel_ack}, state_data()) -> {next_state, s20, state_data()} | {next_state, s20, state_data(), [{next_event, internal, {cancel_ack}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s19(internal, {cancel_ack}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s19(internal, {cancel_ack}, Data),
    after_transition(Next);
s19(cast, {_ControllerPid, {start_controller}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s19]: Purging stale event ~p~n", [{start_controller}]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s19]: Postponing event ~p~n", [{start_controller}]),
        {keep_state, Data, [postpone]}
    end;
s19(cast, {_UsrPid, {request}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s19]: Purging stale event ~p~n", [{request}]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s19]: Postponing event ~p~n", [{request}]),
        {keep_state, Data, [postpone]}
    end;
s19(cast, {_ControllerPid, {error_notice}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s19]: Purging stale event ~p~n", [{error_notice}]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s19]: Postponing event ~p~n", [{error_notice}]),
        {keep_state, Data, [postpone]}
    end;
s19(cast, {_ControllerPid, {shutdown_api}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s19]: Purging stale event ~p~n", [{shutdown_api}]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s19]: Postponing event ~p~n", [{shutdown_api}]),
        {keep_state, Data, [postpone]}
    end;
s19(cast, {_ControllerPid, {service_operational}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s19]: Purging stale event ~p~n", [{service_operational}]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s19]: Postponing event ~p~n", [{service_operational}]),
        {keep_state, Data, [postpone]}
    end;
s19(cast, {_StoragePid, {storage_reponse}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s19]: Purging stale event ~p~n", [{storage_reponse}]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s19]: Postponing event ~p~n", [{storage_reponse}]),
        {keep_state, Data, [postpone]}
    end.

-spec s20(internal, {error_response}, state_data()) -> {next_state, s5, state_data()} | {next_state, s5, state_data(), [{next_event, internal, {error_response}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s20(internal, {error_response}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s20(internal, {error_response}, Data),
    after_transition(Next);
s20(cast, {_ControllerPid, {start_controller}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s20]: Purging stale event ~p~n", [{start_controller}]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s20]: Postponing event ~p~n", [{start_controller}]),
        {keep_state, Data, [postpone]}
    end;
s20(cast, {_UsrPid, {request}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s20]: Purging stale event ~p~n", [{request}]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s20]: Postponing event ~p~n", [{request}]),
        {keep_state, Data, [postpone]}
    end;
s20(cast, {_ControllerPid, {error_notice}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s20]: Purging stale event ~p~n", [{error_notice}]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s20]: Postponing event ~p~n", [{error_notice}]),
        {keep_state, Data, [postpone]}
    end;
s20(cast, {_ControllerPid, {shutdown_api}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s20]: Purging stale event ~p~n", [{shutdown_api}]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s20]: Postponing event ~p~n", [{shutdown_api}]),
        {keep_state, Data, [postpone]}
    end;
s20(cast, {_ControllerPid, {service_operational}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s20]: Purging stale event ~p~n", [{service_operational}]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s20]: Postponing event ~p~n", [{service_operational}]),
        {keep_state, Data, [postpone]}
    end;
s20(cast, {_StoragePid, {storage_reponse}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s20]: Purging stale event ~p~n", [{storage_reponse}]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s20]: Postponing event ~p~n", [{storage_reponse}]),
        {keep_state, Data, [postpone]}
    end.

-spec s23(internal, {shutdown_ack}, state_data()) -> {next_state, s24, state_data()} | {next_state, s24, state_data(), [{next_event, internal, {shutdown_ack}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s23(internal, {shutdown_ack}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s23(internal, {shutdown_ack}, Data),
    after_transition(Next);
s23(cast, {_ControllerPid, {start_controller}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s23]: Purging stale event ~p~n", [{start_controller}]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s23]: Postponing event ~p~n", [{start_controller}]),
        {keep_state, Data, [postpone]}
    end;
s23(cast, {_UsrPid, {request}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s23]: Purging stale event ~p~n", [{request}]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s23]: Postponing event ~p~n", [{request}]),
        {keep_state, Data, [postpone]}
    end;
s23(cast, {_ControllerPid, {error_notice}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s23]: Purging stale event ~p~n", [{error_notice}]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s23]: Postponing event ~p~n", [{error_notice}]),
        {keep_state, Data, [postpone]}
    end;
s23(cast, {_ControllerPid, {shutdown_api}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s23]: Purging stale event ~p~n", [{shutdown_api}]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s23]: Postponing event ~p~n", [{shutdown_api}]),
        {keep_state, Data, [postpone]}
    end;
s23(cast, {_ControllerPid, {service_operational}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s23]: Purging stale event ~p~n", [{service_operational}]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s23]: Postponing event ~p~n", [{service_operational}]),
        {keep_state, Data, [postpone]}
    end;
s23(cast, {_StoragePid, {storage_reponse}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s23]: Purging stale event ~p~n", [{storage_reponse}]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s23]: Postponing event ~p~n", [{storage_reponse}]),
        {keep_state, Data, [postpone]}
    end.

-spec s24(internal, {prepare_shutdown}, state_data()) -> {next_state, s25, state_data()} | {next_state, s25, state_data(), [{next_event, internal, {prepare_shutdown}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s24(internal, {prepare_shutdown}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s24(internal, {prepare_shutdown}, Data),
    after_transition(Next);
s24(cast, {_ControllerPid, {start_controller}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s24]: Purging stale event ~p~n", [{start_controller}]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s24]: Postponing event ~p~n", [{start_controller}]),
        {keep_state, Data, [postpone]}
    end;
s24(cast, {_UsrPid, {request}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s24]: Purging stale event ~p~n", [{request}]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s24]: Postponing event ~p~n", [{request}]),
        {keep_state, Data, [postpone]}
    end;
s24(cast, {_ControllerPid, {error_notice}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s24]: Purging stale event ~p~n", [{error_notice}]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s24]: Postponing event ~p~n", [{error_notice}]),
        {keep_state, Data, [postpone]}
    end;
s24(cast, {_ControllerPid, {shutdown_api}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s24]: Purging stale event ~p~n", [{shutdown_api}]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s24]: Postponing event ~p~n", [{shutdown_api}]),
        {keep_state, Data, [postpone]}
    end;
s24(cast, {_ControllerPid, {service_operational}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s24]: Purging stale event ~p~n", [{service_operational}]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s24]: Postponing event ~p~n", [{service_operational}]),
        {keep_state, Data, [postpone]}
    end;
s24(cast, {_StoragePid, {storage_reponse}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s24]: Purging stale event ~p~n", [{storage_reponse}]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s24]: Postponing event ~p~n", [{storage_reponse}]),
        {keep_state, Data, [postpone]}
    end.

-spec s25(internal, {shutdown_user}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
s25(internal, {shutdown_user}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s25(internal, {shutdown_user}, Data),
    after_transition(Next);
s25(cast, {_ControllerPid, {start_controller}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s25]: Purging stale event ~p~n", [{start_controller}]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s25]: Postponing event ~p~n", [{start_controller}]),
        {keep_state, Data, [postpone]}
    end;
s25(cast, {_UsrPid, {request}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s25]: Purging stale event ~p~n", [{request}]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s25]: Postponing event ~p~n", [{request}]),
        {keep_state, Data, [postpone]}
    end;
s25(cast, {_ControllerPid, {error_notice}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s25]: Purging stale event ~p~n", [{error_notice}]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s25]: Postponing event ~p~n", [{error_notice}]),
        {keep_state, Data, [postpone]}
    end;
s25(cast, {_ControllerPid, {shutdown_api}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s25]: Purging stale event ~p~n", [{shutdown_api}]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s25]: Postponing event ~p~n", [{shutdown_api}]),
        {keep_state, Data, [postpone]}
    end;
s25(cast, {_ControllerPid, {service_operational}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s25]: Purging stale event ~p~n", [{service_operational}]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s25]: Postponing event ~p~n", [{service_operational}]),
        {keep_state, Data, [postpone]}
    end;
s25(cast, {_StoragePid, {storage_reponse}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_api[s25]: Purging stale event ~p~n", [{storage_reponse}]),
        {keep_state, Data};
      false ->
        io:format("gen_api[s25]: Postponing event ~p~n", [{storage_reponse}]),
        {keep_state, Data, [postpone]}
    end.


%% ---------- Send helpers----------

-spec send_s3_ready(UsrPid :: pid(), _Data :: state_data()) -> ok.
send_s3_ready(UsrPid, _Data) ->
    gen_statem:cast(UsrPid, {self(), {ready}}).


-spec send_s6_get_mode(ControllerPid :: pid(), _Data :: state_data()) -> ok.
send_s6_get_mode(ControllerPid, _Data) ->
    gen_statem:cast(ControllerPid, {self(), {get_mode}}).


-spec send_s8_timeout_notice(UsrPid :: pid(), _Data :: state_data()) -> ok.
send_s8_timeout_notice(UsrPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(UsrPid, {self(), {timeout_notice}, Path}).


-spec send_s11_timeout(ControllerPid :: pid(), _Data :: state_data()) -> ok.
send_s11_timeout(ControllerPid, _Data) ->
    Path = branch_path(mc1, right),
    commit_current(mc1, right),
    gen_statem:cast(ControllerPid, {self(), {timeout}, Path}).


-spec send_s12_ack(ControllerPid :: pid(), _Data :: state_data()) -> ok.
send_s12_ack(ControllerPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(ControllerPid, {self(), {ack}, Path}).


-spec send_s13_storage_request(StoragePid :: pid(), _Data :: state_data()) -> ok.
send_s13_storage_request(StoragePid, _Data) ->
    Path = current_path(),
    gen_statem:cast(StoragePid, {self(), {storage_request}, Path}).


-spec send_s15_api_response(UsrPid :: pid(), _Data :: state_data()) -> ok.
send_s15_api_response(UsrPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(UsrPid, {self(), {api_response}, Path}).


-spec send_s18_error_ack(ControllerPid :: pid(), _Data :: state_data()) -> ok.
send_s18_error_ack(ControllerPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(ControllerPid, {self(), {error_ack}, Path}).


-spec send_s19_cancel_ack(StoragePid :: pid(), _Data :: state_data()) -> ok.
send_s19_cancel_ack(StoragePid, _Data) ->
    Path = current_path(),
    gen_statem:cast(StoragePid, {self(), {cancel_ack}, Path}).


-spec send_s20_error_response(UsrPid :: pid(), _Data :: state_data()) -> ok.
send_s20_error_response(UsrPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(UsrPid, {self(), {error_response}, Path}).


-spec send_s23_shutdown_ack(ControllerPid :: pid(), _Data :: state_data()) -> ok.
send_s23_shutdown_ack(ControllerPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(ControllerPid, {self(), {shutdown_ack}, Path}).


-spec send_s24_prepare_shutdown(StoragePid :: pid(), _Data :: state_data()) -> ok.
send_s24_prepare_shutdown(StoragePid, _Data) ->
    Path = current_path(),
    gen_statem:cast(StoragePid, {self(), {prepare_shutdown}, Path}).


-spec send_s25_shutdown_user(UsrPid :: pid(), _Data :: state_data()) -> ok.
send_s25_shutdown_user(UsrPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(UsrPid, {self(), {shutdown_user}, Path}).


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

