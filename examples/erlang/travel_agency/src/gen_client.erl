
%%%-------------------------------------------------------------------
%%% gen_client.erl — generated generic behaviour module (gen_statem)
%%%-------------------------------------------------------------------
-module(gen_client).
-behaviour(gen_statem).

%% Public API
-export([start_link/2, callback_mode/0]).

%% gen_statem callbacks
-export([init/1, code_change/4, terminate/3,
  s3/3,
  s4/3,
  s6/3,
  s7/3,
  s9/3,
  s10/3,
  s11/3,
  s12/3,
  s14/3,
  s15/3,
  s17/3,
  s18/3,
  send_s3_booking_request/3,
  send_s3_booking_request/2,
  send_s6_cancel_agency/2,
  send_s7_cancel_supplier/2,
  send_s9_reject_offer/2,
  send_s9_resubmit_request/2,
  send_s9_accept_offer/2,
  send_s11_provide_address/3,
  send_s11_provide_address/2,
  send_s15_cancel_booking/2,
  send_s18_resubmitting/2]).

%% Types & records
-include("client.hrl").
-export_type([state_data/0]).
-type state_data() :: #state_data{}.

-callback init(Args :: list()) -> {ok, s3, state_data(), [{next_event, internal, {booking_request}}]}.
-callback s3(internal, {booking_request}, state_data()) -> {next_state, s4, state_data()} | {next_state, s4, state_data(), [{next_event, internal, {booking_request}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s4(cast, {pid(), {price_quote, {term()}}}, state_data()) -> {next_state, s9, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s6(internal, {cancel_agency}, state_data()) -> {next_state, s7, state_data()} | {next_state, s7, state_data(), [{next_event, internal, {cancel_agency}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s7(internal, {cancel_supplier}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s9(internal | cast, {accept_offer} | {reject_offer} | {resubmit_request} | {pid(), {price_adjustment, {term()}}}, state_data()) -> {next_state, s10, state_data()} | {next_state, s14, state_data()} | {next_state, s17, state_data()} | {next_state, s6, state_data()} | {next_state, s10, state_data(), [{next_event, internal, {accept_offer}}] } | {next_state, s10, state_data(), [{next_event, internal, {reject_offer}}] } | {next_state, s10, state_data(), [{next_event, internal, {resubmit_request}}] } | {next_state, s14, state_data(), [{next_event, internal, {accept_offer}}] } | {next_state, s14, state_data(), [{next_event, internal, {reject_offer}}] } | {next_state, s14, state_data(), [{next_event, internal, {resubmit_request}}] } | {next_state, s17, state_data(), [{next_event, internal, {accept_offer}}] } | {next_state, s17, state_data(), [{next_event, internal, {reject_offer}}] } | {next_state, s17, state_data(), [{next_event, internal, {resubmit_request}}] } | {next_state, s6, state_data(), [{next_event, internal, {accept_offer}}] } | {next_state, s6, state_data(), [{next_event, internal, {reject_offer}}] } | {next_state, s6, state_data(), [{next_event, internal, {resubmit_request}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s10(cast, {pid(), {accept_confirmation}} | {pid(), {price_adjustment, {term()}}}, state_data()) -> {next_state, s11, state_data()} | {next_state, s6, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s11(internal, {provide_address}, state_data()) -> {next_state, s12, state_data()} | {next_state, s12, state_data(), [{next_event, internal, {provide_address}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s12(cast, {pid(), {confirm_date, {term()}}}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s14(cast, {pid(), {price_adjustment, {term()}}} | {pid(), {reject_confirmation}}, state_data()) -> {next_state, s15, state_data()} | {next_state, s6, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s15(internal, {cancel_booking}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s17(cast, {pid(), {price_adjustment, {term()}}} | {pid(), {repeat_confirmation}}, state_data()) -> {next_state, s18, state_data()} | {next_state, s6, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s18(internal, {resubmitting}, state_data()) -> {next_state, s3, state_data()} | {next_state, s3, state_data(), [{next_event, internal, {resubmitting}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.

%% ===== API =====
-spec start_link(CallbackModule :: module(), Args :: list()) ->
    {ok, pid()} | {error, term()}.
start_link(CallbackModule, Args) ->
    case code:ensure_loaded(CallbackModule) of
        {module, CallbackModule} ->
            gen_statem:start_link({local, CallbackModule}, gen_client, {CallbackModule, Args}, [{debug, [trace, {log_to_file, "client_debug.log"}]}]);
        {error, Reason} ->
            {error, Reason}
    end.

-spec callback_mode() -> state_functions.
callback_mode() -> state_functions.

%% ===== gen_statem =====
-spec init({module(), list()}) ->
    {ok, s3, state_data(), [{next_event, internal, {booking_request}}]}.
init({CallbackModule, _Args}) ->
    io:format("client: Initializing with callback module ~p~n", [CallbackModule]),
    put(callback_module, CallbackModule),
    init_context(),
    CallbackModule:init([]).

%% ---------- State functions----------
-spec s3(internal, {booking_request}, state_data()) -> {next_state, s4, state_data()} | {next_state, s4, state_data(), [{next_event, internal, {booking_request}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s3(internal, {booking_request}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s3(internal, {booking_request}, Data),
    after_transition(Next);
s3(cast, {_From, _Msg, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_client[s3]: Purging stale early-path event ~p~n", [_Msg]),
        {keep_state, Data};
      false ->
        io:format("gen_client[s3]: Postponing early-path event ~p~n", [_Msg]),
        {keep_state, Data, [postpone]}
    end.

-spec s4(cast, {pid(), {price_quote, {term()}}}, state_data()) -> {next_state, s9, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
s4(cast, {AgencyPid, {price_quote, {Price}}}, Data) ->
    CallbackModule = get(callback_module),
    Next = try CallbackModule:s4(cast, {AgencyPid, {price_quote, {Price}}}, Data)
           catch error:function_clause ->
             io:format("gen_client[s4]: Callback had no clause for ~p, ignoring~n", [{price_quote, {Price}}]),
             {keep_state, Data}
           end,
    after_transition(Next);
s4(cast, {_From, _Msg, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_client[s4]: Purging stale early-path event ~p~n", [_Msg]),
        {keep_state, Data};
      false ->
        io:format("gen_client[s4]: Postponing early-path event ~p~n", [_Msg]),
        {keep_state, Data, [postpone]}
    end.

-spec s6(internal, {cancel_agency}, state_data()) -> {next_state, s7, state_data()} | {next_state, s7, state_data(), [{next_event, internal, {cancel_agency}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s6(internal, {cancel_agency}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s6(internal, {cancel_agency}, Data),
    after_transition(Next);
s6(cast, {_AgencyPid, {price_quote, {Price}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_client[s6]: Purging stale event ~p~n", [{price_quote, {Price}}]),
        {keep_state, Data};
      false ->
        io:format("gen_client[s6]: Postponing event ~p~n", [{price_quote, {Price}}]),
        {keep_state, Data, [postpone]}
    end;
s6(cast, {AgencyPid, {price_adjustment, {Price}}, Path}, Data) ->
    case message_status(Path, branch_path(mc1, right)) of
      stale ->
        io:format("gen_client[s6]: Purging stale interrupt ~p~n", [{price_adjustment, {Price}}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s9(cast, {AgencyPid, {price_adjustment, {Price}}}, Data)
               catch error:function_clause ->
                 io:format("gen_client[s6]: Callback had no interrupt clause for ~p, postponing~n", [{price_adjustment, {Price}}]),
                 {keep_state, Data, [postpone]}
               end,
        after_transition(commit_if_taken(Next, mc1, right));
      not_ready ->
        io:format("gen_client[s6]: Postponing not-ready interrupt ~p~n", [{price_adjustment, {Price}}]),
        {keep_state, Data, [postpone]}
    end;
s6(cast, {_AgencyPid, {accept_confirmation}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_client[s6]: Purging stale event ~p~n", [{accept_confirmation}]),
        {keep_state, Data};
      false ->
        io:format("gen_client[s6]: Postponing event ~p~n", [{accept_confirmation}]),
        {keep_state, Data, [postpone]}
    end;
s6(cast, {_SupplierPid, {confirm_date, {Date}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_client[s6]: Purging stale event ~p~n", [{confirm_date, {Date}}]),
        {keep_state, Data};
      false ->
        io:format("gen_client[s6]: Postponing event ~p~n", [{confirm_date, {Date}}]),
        {keep_state, Data, [postpone]}
    end;
s6(cast, {_AgencyPid, {reject_confirmation}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_client[s6]: Purging stale event ~p~n", [{reject_confirmation}]),
        {keep_state, Data};
      false ->
        io:format("gen_client[s6]: Postponing event ~p~n", [{reject_confirmation}]),
        {keep_state, Data, [postpone]}
    end;
s6(cast, {_AgencyPid, {repeat_confirmation}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_client[s6]: Purging stale event ~p~n", [{repeat_confirmation}]),
        {keep_state, Data};
      false ->
        io:format("gen_client[s6]: Postponing event ~p~n", [{repeat_confirmation}]),
        {keep_state, Data, [postpone]}
    end.

-spec s7(internal, {cancel_supplier}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
s7(internal, {cancel_supplier}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s7(internal, {cancel_supplier}, Data),
    after_transition(Next);
s7(cast, {_AgencyPid, {price_quote, {Price}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_client[s7]: Purging stale event ~p~n", [{price_quote, {Price}}]),
        {keep_state, Data};
      false ->
        io:format("gen_client[s7]: Postponing event ~p~n", [{price_quote, {Price}}]),
        {keep_state, Data, [postpone]}
    end;
s7(cast, {AgencyPid, {price_adjustment, {Price}}, Path}, Data) ->
    case message_status(Path, branch_path(mc1, right)) of
      stale ->
        io:format("gen_client[s7]: Purging stale interrupt ~p~n", [{price_adjustment, {Price}}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s9(cast, {AgencyPid, {price_adjustment, {Price}}}, Data)
               catch error:function_clause ->
                 io:format("gen_client[s7]: Callback had no interrupt clause for ~p, postponing~n", [{price_adjustment, {Price}}]),
                 {keep_state, Data, [postpone]}
               end,
        after_transition(commit_if_taken(Next, mc1, right));
      not_ready ->
        io:format("gen_client[s7]: Postponing not-ready interrupt ~p~n", [{price_adjustment, {Price}}]),
        {keep_state, Data, [postpone]}
    end;
s7(cast, {_AgencyPid, {accept_confirmation}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_client[s7]: Purging stale event ~p~n", [{accept_confirmation}]),
        {keep_state, Data};
      false ->
        io:format("gen_client[s7]: Postponing event ~p~n", [{accept_confirmation}]),
        {keep_state, Data, [postpone]}
    end;
s7(cast, {_SupplierPid, {confirm_date, {Date}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_client[s7]: Purging stale event ~p~n", [{confirm_date, {Date}}]),
        {keep_state, Data};
      false ->
        io:format("gen_client[s7]: Postponing event ~p~n", [{confirm_date, {Date}}]),
        {keep_state, Data, [postpone]}
    end;
s7(cast, {_AgencyPid, {reject_confirmation}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_client[s7]: Purging stale event ~p~n", [{reject_confirmation}]),
        {keep_state, Data};
      false ->
        io:format("gen_client[s7]: Postponing event ~p~n", [{reject_confirmation}]),
        {keep_state, Data, [postpone]}
    end;
s7(cast, {_AgencyPid, {repeat_confirmation}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_client[s7]: Purging stale event ~p~n", [{repeat_confirmation}]),
        {keep_state, Data};
      false ->
        io:format("gen_client[s7]: Postponing event ~p~n", [{repeat_confirmation}]),
        {keep_state, Data, [postpone]}
    end.

%% Mixed-choice entry state
-spec s9(internal | cast, {accept_offer} | {reject_offer} | {resubmit_request} | {pid(), {price_adjustment, {term()}}, list()}, state_data()) -> {next_state, s10, state_data()} | {next_state, s14, state_data()} | {next_state, s17, state_data()} | {next_state, s6, state_data()} | {next_state, s10, state_data(), [{next_event, internal, {accept_offer}}] } | {next_state, s10, state_data(), [{next_event, internal, {reject_offer}}] } | {next_state, s10, state_data(), [{next_event, internal, {resubmit_request}}] } | {next_state, s14, state_data(), [{next_event, internal, {accept_offer}}] } | {next_state, s14, state_data(), [{next_event, internal, {reject_offer}}] } | {next_state, s14, state_data(), [{next_event, internal, {resubmit_request}}] } | {next_state, s17, state_data(), [{next_event, internal, {accept_offer}}] } | {next_state, s17, state_data(), [{next_event, internal, {reject_offer}}] } | {next_state, s17, state_data(), [{next_event, internal, {resubmit_request}}] } | {next_state, s6, state_data(), [{next_event, internal, {accept_offer}}] } | {next_state, s6, state_data(), [{next_event, internal, {reject_offer}}] } | {next_state, s6, state_data(), [{next_event, internal, {resubmit_request}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s9(internal, {resubmit_request}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s9(internal, {resubmit_request}, Data),
    after_transition(Next);
s9(internal, {accept_offer}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s9(internal, {accept_offer}, Data),
    after_transition(Next);
s9(cast, {AgencyPid, {price_adjustment, {Price}}, Path}, Data) ->
    case message_status(Path, branch_path(mc1, right)) of
      stale ->
        io:format("gen_client[s9]: Purging stale event ~p~n", [{price_adjustment, {Price}}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s9(cast, {AgencyPid, {price_adjustment, {Price}}}, Data)
               catch error:function_clause ->
                 io:format("gen_client[s9]: Callback had no clause for ~p, postponing~n", [{price_adjustment, {Price}}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {next_state, s6, _} -> after_transition(commit_if_taken(Next, mc1, right));
          {next_state, s6, _, _} -> after_transition(commit_if_taken(Next, mc1, right));
          _ -> after_transition(Next)
        end;
      not_ready ->
        io:format("gen_client[s9]: Postponing not-ready event ~p~n", [{price_adjustment, {Price}}]),
        {keep_state, Data, [postpone]}
    end;
s9(internal, {reject_offer}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s9(internal, {reject_offer}, Data),
    after_transition(Next);
s9(cast, {_AgencyPid, {price_quote, {Price}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_client[s9]: Purging stale event ~p~n", [{price_quote, {Price}}]),
        {keep_state, Data};
      false ->
        io:format("gen_client[s9]: Postponing event ~p~n", [{price_quote, {Price}}]),
        {keep_state, Data, [postpone]}
    end;
s9(cast, {_AgencyPid, {accept_confirmation}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_client[s9]: Purging stale event ~p~n", [{accept_confirmation}]),
        {keep_state, Data};
      false ->
        io:format("gen_client[s9]: Postponing event ~p~n", [{accept_confirmation}]),
        {keep_state, Data, [postpone]}
    end;
s9(cast, {_SupplierPid, {confirm_date, {Date}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_client[s9]: Purging stale event ~p~n", [{confirm_date, {Date}}]),
        {keep_state, Data};
      false ->
        io:format("gen_client[s9]: Postponing event ~p~n", [{confirm_date, {Date}}]),
        {keep_state, Data, [postpone]}
    end;
s9(cast, {_AgencyPid, {reject_confirmation}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_client[s9]: Purging stale event ~p~n", [{reject_confirmation}]),
        {keep_state, Data};
      false ->
        io:format("gen_client[s9]: Postponing event ~p~n", [{reject_confirmation}]),
        {keep_state, Data, [postpone]}
    end;
s9(cast, {_AgencyPid, {repeat_confirmation}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_client[s9]: Purging stale event ~p~n", [{repeat_confirmation}]),
        {keep_state, Data};
      false ->
        io:format("gen_client[s9]: Postponing event ~p~n", [{repeat_confirmation}]),
        {keep_state, Data, [postpone]}
    end.

-spec s10(cast, {pid(), {price_adjustment, {term()}}, list()} | {pid(), {accept_confirmation}, list()}, state_data()) -> {next_state, s11, state_data()} | {next_state, s6, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
s10(cast, {AgencyPid, {price_adjustment, {Price}}, Path}, Data) ->
    case message_status(Path, branch_path(mc1, right)) of
      stale ->
        io:format("gen_client[s10]: Purging stale event ~p~n", [{price_adjustment, {Price}}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s10(cast, {AgencyPid, {price_adjustment, {Price}}}, Data)
               catch error:function_clause ->
                 io:format("gen_client[s10]: Callback had no clause for ~p, postponing~n", [{price_adjustment, {Price}}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {next_state, s6, _} -> after_transition(commit_if_taken(Next, mc1, right));
          {next_state, s6, _, _} -> after_transition(commit_if_taken(Next, mc1, right));
          _ -> after_transition(Next)
        end;
      not_ready ->
        io:format("gen_client[s10]: Postponing not-ready event ~p~n", [{price_adjustment, {Price}}]),
        {keep_state, Data, [postpone]}
    end;
s10(cast, {AgencyPid, {accept_confirmation}, Path}, Data) ->
    case message_status(Path, current_path()) of
      stale ->
        io:format("gen_client[s10]: Purging stale event ~p~n", [{accept_confirmation}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s10(cast, {AgencyPid, {accept_confirmation}}, Data)
               catch error:function_clause ->
                 io:format("gen_client[s10]: Callback had no clause for ~p, postponing~n", [{accept_confirmation}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> after_transition(Next)
        end;
      not_ready ->
        io:format("gen_client[s10]: Postponing not-ready event ~p~n", [{accept_confirmation}]),
        {keep_state, Data, [postpone]}
    end;
s10(cast, {_AgencyPid, {price_quote, {Price}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_client[s10]: Purging stale event ~p~n", [{price_quote, {Price}}]),
        {keep_state, Data};
      false ->
        io:format("gen_client[s10]: Postponing event ~p~n", [{price_quote, {Price}}]),
        {keep_state, Data, [postpone]}
    end;
s10(cast, {_SupplierPid, {confirm_date, {Date}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_client[s10]: Purging stale event ~p~n", [{confirm_date, {Date}}]),
        {keep_state, Data};
      false ->
        io:format("gen_client[s10]: Postponing event ~p~n", [{confirm_date, {Date}}]),
        {keep_state, Data, [postpone]}
    end;
s10(cast, {_AgencyPid, {reject_confirmation}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_client[s10]: Purging stale event ~p~n", [{reject_confirmation}]),
        {keep_state, Data};
      false ->
        io:format("gen_client[s10]: Postponing event ~p~n", [{reject_confirmation}]),
        {keep_state, Data, [postpone]}
    end;
s10(cast, {_AgencyPid, {repeat_confirmation}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_client[s10]: Purging stale event ~p~n", [{repeat_confirmation}]),
        {keep_state, Data};
      false ->
        io:format("gen_client[s10]: Postponing event ~p~n", [{repeat_confirmation}]),
        {keep_state, Data, [postpone]}
    end.

-spec s11(internal, {provide_address}, state_data()) -> {next_state, s12, state_data()} | {next_state, s12, state_data(), [{next_event, internal, {provide_address}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s11(internal, {provide_address}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s11(internal, {provide_address}, Data),
    after_transition(Next);
s11(cast, {_AgencyPid, {price_quote, {Price}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_client[s11]: Purging stale event ~p~n", [{price_quote, {Price}}]),
        {keep_state, Data};
      false ->
        io:format("gen_client[s11]: Postponing event ~p~n", [{price_quote, {Price}}]),
        {keep_state, Data, [postpone]}
    end;
s11(cast, {AgencyPid, {price_adjustment, {Price}}, Path}, Data) ->
    case message_status(Path, branch_path(mc1, right)) of
      stale ->
        io:format("gen_client[s11]: Purging stale interrupt ~p~n", [{price_adjustment, {Price}}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s9(cast, {AgencyPid, {price_adjustment, {Price}}}, Data)
               catch error:function_clause ->
                 io:format("gen_client[s11]: Callback had no interrupt clause for ~p, postponing~n", [{price_adjustment, {Price}}]),
                 {keep_state, Data, [postpone]}
               end,
        after_transition(commit_if_taken(Next, mc1, right));
      not_ready ->
        io:format("gen_client[s11]: Postponing not-ready interrupt ~p~n", [{price_adjustment, {Price}}]),
        {keep_state, Data, [postpone]}
    end;
s11(cast, {_AgencyPid, {accept_confirmation}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_client[s11]: Purging stale event ~p~n", [{accept_confirmation}]),
        {keep_state, Data};
      false ->
        io:format("gen_client[s11]: Postponing event ~p~n", [{accept_confirmation}]),
        {keep_state, Data, [postpone]}
    end;
s11(cast, {_SupplierPid, {confirm_date, {Date}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_client[s11]: Purging stale event ~p~n", [{confirm_date, {Date}}]),
        {keep_state, Data};
      false ->
        io:format("gen_client[s11]: Postponing event ~p~n", [{confirm_date, {Date}}]),
        {keep_state, Data, [postpone]}
    end;
s11(cast, {_AgencyPid, {reject_confirmation}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_client[s11]: Purging stale event ~p~n", [{reject_confirmation}]),
        {keep_state, Data};
      false ->
        io:format("gen_client[s11]: Postponing event ~p~n", [{reject_confirmation}]),
        {keep_state, Data, [postpone]}
    end;
s11(cast, {_AgencyPid, {repeat_confirmation}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_client[s11]: Purging stale event ~p~n", [{repeat_confirmation}]),
        {keep_state, Data};
      false ->
        io:format("gen_client[s11]: Postponing event ~p~n", [{repeat_confirmation}]),
        {keep_state, Data, [postpone]}
    end.

-spec s12(cast, {pid(), {confirm_date, {term()}}, list()}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
s12(cast, {SupplierPid, {confirm_date, {Date}}, Path}, Data) ->
    case message_status(Path, current_path()) of
      stale ->
        io:format("gen_client[s12]: Purging stale event ~p~n", [{confirm_date, {Date}}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s12(cast, {SupplierPid, {confirm_date, {Date}}}, Data)
               catch error:function_clause ->
                 io:format("gen_client[s12]: Callback had no clause for ~p, postponing~n", [{confirm_date, {Date}}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> after_transition(Next)
        end;
      not_ready ->
        io:format("gen_client[s12]: Postponing not-ready event ~p~n", [{confirm_date, {Date}}]),
        {keep_state, Data, [postpone]}
    end;
s12(cast, {_AgencyPid, {price_quote, {Price}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_client[s12]: Purging stale event ~p~n", [{price_quote, {Price}}]),
        {keep_state, Data};
      false ->
        io:format("gen_client[s12]: Postponing event ~p~n", [{price_quote, {Price}}]),
        {keep_state, Data, [postpone]}
    end;
s12(cast, {AgencyPid, {price_adjustment, {Price}}, Path}, Data) ->
    case message_status(Path, branch_path(mc1, right)) of
      stale ->
        io:format("gen_client[s12]: Purging stale interrupt ~p~n", [{price_adjustment, {Price}}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s9(cast, {AgencyPid, {price_adjustment, {Price}}}, Data)
               catch error:function_clause ->
                 io:format("gen_client[s12]: Callback had no interrupt clause for ~p, postponing~n", [{price_adjustment, {Price}}]),
                 {keep_state, Data, [postpone]}
               end,
        after_transition(commit_if_taken(Next, mc1, right));
      not_ready ->
        io:format("gen_client[s12]: Postponing not-ready interrupt ~p~n", [{price_adjustment, {Price}}]),
        {keep_state, Data, [postpone]}
    end;
s12(cast, {_AgencyPid, {accept_confirmation}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_client[s12]: Purging stale event ~p~n", [{accept_confirmation}]),
        {keep_state, Data};
      false ->
        io:format("gen_client[s12]: Postponing event ~p~n", [{accept_confirmation}]),
        {keep_state, Data, [postpone]}
    end;
s12(cast, {_AgencyPid, {reject_confirmation}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_client[s12]: Purging stale event ~p~n", [{reject_confirmation}]),
        {keep_state, Data};
      false ->
        io:format("gen_client[s12]: Postponing event ~p~n", [{reject_confirmation}]),
        {keep_state, Data, [postpone]}
    end;
s12(cast, {_AgencyPid, {repeat_confirmation}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_client[s12]: Purging stale event ~p~n", [{repeat_confirmation}]),
        {keep_state, Data};
      false ->
        io:format("gen_client[s12]: Postponing event ~p~n", [{repeat_confirmation}]),
        {keep_state, Data, [postpone]}
    end.

-spec s14(cast, {pid(), {price_adjustment, {term()}}, list()} | {pid(), {reject_confirmation}, list()}, state_data()) -> {next_state, s15, state_data()} | {next_state, s6, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
s14(cast, {AgencyPid, {price_adjustment, {Price}}, Path}, Data) ->
    case message_status(Path, branch_path(mc1, right)) of
      stale ->
        io:format("gen_client[s14]: Purging stale event ~p~n", [{price_adjustment, {Price}}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s14(cast, {AgencyPid, {price_adjustment, {Price}}}, Data)
               catch error:function_clause ->
                 io:format("gen_client[s14]: Callback had no clause for ~p, postponing~n", [{price_adjustment, {Price}}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {next_state, s6, _} -> after_transition(commit_if_taken(Next, mc1, right));
          {next_state, s6, _, _} -> after_transition(commit_if_taken(Next, mc1, right));
          _ -> after_transition(Next)
        end;
      not_ready ->
        io:format("gen_client[s14]: Postponing not-ready event ~p~n", [{price_adjustment, {Price}}]),
        {keep_state, Data, [postpone]}
    end;
s14(cast, {AgencyPid, {reject_confirmation}, Path}, Data) ->
    case message_status(Path, current_path()) of
      stale ->
        io:format("gen_client[s14]: Purging stale event ~p~n", [{reject_confirmation}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s14(cast, {AgencyPid, {reject_confirmation}}, Data)
               catch error:function_clause ->
                 io:format("gen_client[s14]: Callback had no clause for ~p, postponing~n", [{reject_confirmation}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> after_transition(Next)
        end;
      not_ready ->
        io:format("gen_client[s14]: Postponing not-ready event ~p~n", [{reject_confirmation}]),
        {keep_state, Data, [postpone]}
    end;
s14(cast, {_AgencyPid, {price_quote, {Price}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_client[s14]: Purging stale event ~p~n", [{price_quote, {Price}}]),
        {keep_state, Data};
      false ->
        io:format("gen_client[s14]: Postponing event ~p~n", [{price_quote, {Price}}]),
        {keep_state, Data, [postpone]}
    end;
s14(cast, {_AgencyPid, {accept_confirmation}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_client[s14]: Purging stale event ~p~n", [{accept_confirmation}]),
        {keep_state, Data};
      false ->
        io:format("gen_client[s14]: Postponing event ~p~n", [{accept_confirmation}]),
        {keep_state, Data, [postpone]}
    end;
s14(cast, {_SupplierPid, {confirm_date, {Date}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_client[s14]: Purging stale event ~p~n", [{confirm_date, {Date}}]),
        {keep_state, Data};
      false ->
        io:format("gen_client[s14]: Postponing event ~p~n", [{confirm_date, {Date}}]),
        {keep_state, Data, [postpone]}
    end;
s14(cast, {_AgencyPid, {repeat_confirmation}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_client[s14]: Purging stale event ~p~n", [{repeat_confirmation}]),
        {keep_state, Data};
      false ->
        io:format("gen_client[s14]: Postponing event ~p~n", [{repeat_confirmation}]),
        {keep_state, Data, [postpone]}
    end.

-spec s15(internal, {cancel_booking}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
s15(internal, {cancel_booking}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s15(internal, {cancel_booking}, Data),
    after_transition(Next);
s15(cast, {_AgencyPid, {price_quote, {Price}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_client[s15]: Purging stale event ~p~n", [{price_quote, {Price}}]),
        {keep_state, Data};
      false ->
        io:format("gen_client[s15]: Postponing event ~p~n", [{price_quote, {Price}}]),
        {keep_state, Data, [postpone]}
    end;
s15(cast, {AgencyPid, {price_adjustment, {Price}}, Path}, Data) ->
    case message_status(Path, branch_path(mc1, right)) of
      stale ->
        io:format("gen_client[s15]: Purging stale interrupt ~p~n", [{price_adjustment, {Price}}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s9(cast, {AgencyPid, {price_adjustment, {Price}}}, Data)
               catch error:function_clause ->
                 io:format("gen_client[s15]: Callback had no interrupt clause for ~p, postponing~n", [{price_adjustment, {Price}}]),
                 {keep_state, Data, [postpone]}
               end,
        after_transition(commit_if_taken(Next, mc1, right));
      not_ready ->
        io:format("gen_client[s15]: Postponing not-ready interrupt ~p~n", [{price_adjustment, {Price}}]),
        {keep_state, Data, [postpone]}
    end;
s15(cast, {_AgencyPid, {accept_confirmation}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_client[s15]: Purging stale event ~p~n", [{accept_confirmation}]),
        {keep_state, Data};
      false ->
        io:format("gen_client[s15]: Postponing event ~p~n", [{accept_confirmation}]),
        {keep_state, Data, [postpone]}
    end;
s15(cast, {_SupplierPid, {confirm_date, {Date}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_client[s15]: Purging stale event ~p~n", [{confirm_date, {Date}}]),
        {keep_state, Data};
      false ->
        io:format("gen_client[s15]: Postponing event ~p~n", [{confirm_date, {Date}}]),
        {keep_state, Data, [postpone]}
    end;
s15(cast, {_AgencyPid, {reject_confirmation}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_client[s15]: Purging stale event ~p~n", [{reject_confirmation}]),
        {keep_state, Data};
      false ->
        io:format("gen_client[s15]: Postponing event ~p~n", [{reject_confirmation}]),
        {keep_state, Data, [postpone]}
    end;
s15(cast, {_AgencyPid, {repeat_confirmation}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_client[s15]: Purging stale event ~p~n", [{repeat_confirmation}]),
        {keep_state, Data};
      false ->
        io:format("gen_client[s15]: Postponing event ~p~n", [{repeat_confirmation}]),
        {keep_state, Data, [postpone]}
    end.

-spec s17(cast, {pid(), {price_adjustment, {term()}}, list()} | {pid(), {repeat_confirmation}, list()}, state_data()) -> {next_state, s18, state_data()} | {next_state, s6, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
s17(cast, {AgencyPid, {price_adjustment, {Price}}, Path}, Data) ->
    case message_status(Path, branch_path(mc1, right)) of
      stale ->
        io:format("gen_client[s17]: Purging stale event ~p~n", [{price_adjustment, {Price}}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s17(cast, {AgencyPid, {price_adjustment, {Price}}}, Data)
               catch error:function_clause ->
                 io:format("gen_client[s17]: Callback had no clause for ~p, postponing~n", [{price_adjustment, {Price}}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {next_state, s6, _} -> after_transition(commit_if_taken(Next, mc1, right));
          {next_state, s6, _, _} -> after_transition(commit_if_taken(Next, mc1, right));
          _ -> after_transition(Next)
        end;
      not_ready ->
        io:format("gen_client[s17]: Postponing not-ready event ~p~n", [{price_adjustment, {Price}}]),
        {keep_state, Data, [postpone]}
    end;
s17(cast, {AgencyPid, {repeat_confirmation}, Path}, Data) ->
    case message_status(Path, current_path()) of
      stale ->
        io:format("gen_client[s17]: Purging stale event ~p~n", [{repeat_confirmation}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s17(cast, {AgencyPid, {repeat_confirmation}}, Data)
               catch error:function_clause ->
                 io:format("gen_client[s17]: Callback had no clause for ~p, postponing~n", [{repeat_confirmation}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> after_transition(Next)
        end;
      not_ready ->
        io:format("gen_client[s17]: Postponing not-ready event ~p~n", [{repeat_confirmation}]),
        {keep_state, Data, [postpone]}
    end;
s17(cast, {_AgencyPid, {price_quote, {Price}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_client[s17]: Purging stale event ~p~n", [{price_quote, {Price}}]),
        {keep_state, Data};
      false ->
        io:format("gen_client[s17]: Postponing event ~p~n", [{price_quote, {Price}}]),
        {keep_state, Data, [postpone]}
    end;
s17(cast, {_AgencyPid, {accept_confirmation}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_client[s17]: Purging stale event ~p~n", [{accept_confirmation}]),
        {keep_state, Data};
      false ->
        io:format("gen_client[s17]: Postponing event ~p~n", [{accept_confirmation}]),
        {keep_state, Data, [postpone]}
    end;
s17(cast, {_SupplierPid, {confirm_date, {Date}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_client[s17]: Purging stale event ~p~n", [{confirm_date, {Date}}]),
        {keep_state, Data};
      false ->
        io:format("gen_client[s17]: Postponing event ~p~n", [{confirm_date, {Date}}]),
        {keep_state, Data, [postpone]}
    end;
s17(cast, {_AgencyPid, {reject_confirmation}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_client[s17]: Purging stale event ~p~n", [{reject_confirmation}]),
        {keep_state, Data};
      false ->
        io:format("gen_client[s17]: Postponing event ~p~n", [{reject_confirmation}]),
        {keep_state, Data, [postpone]}
    end.

-spec s18(internal, {resubmitting}, state_data()) -> {next_state, s3, state_data()} | {next_state, s3, state_data(), [{next_event, internal, {resubmitting}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s18(internal, {resubmitting}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s18(internal, {resubmitting}, Data),
    after_transition(Next);
s18(cast, {_AgencyPid, {price_quote, {Price}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_client[s18]: Purging stale event ~p~n", [{price_quote, {Price}}]),
        {keep_state, Data};
      false ->
        io:format("gen_client[s18]: Postponing event ~p~n", [{price_quote, {Price}}]),
        {keep_state, Data, [postpone]}
    end;
s18(cast, {AgencyPid, {price_adjustment, {Price}}, Path}, Data) ->
    case message_status(Path, branch_path(mc1, right)) of
      stale ->
        io:format("gen_client[s18]: Purging stale interrupt ~p~n", [{price_adjustment, {Price}}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s9(cast, {AgencyPid, {price_adjustment, {Price}}}, Data)
               catch error:function_clause ->
                 io:format("gen_client[s18]: Callback had no interrupt clause for ~p, postponing~n", [{price_adjustment, {Price}}]),
                 {keep_state, Data, [postpone]}
               end,
        after_transition(commit_if_taken(Next, mc1, right));
      not_ready ->
        io:format("gen_client[s18]: Postponing not-ready interrupt ~p~n", [{price_adjustment, {Price}}]),
        {keep_state, Data, [postpone]}
    end;
s18(cast, {_AgencyPid, {accept_confirmation}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_client[s18]: Purging stale event ~p~n", [{accept_confirmation}]),
        {keep_state, Data};
      false ->
        io:format("gen_client[s18]: Postponing event ~p~n", [{accept_confirmation}]),
        {keep_state, Data, [postpone]}
    end;
s18(cast, {_SupplierPid, {confirm_date, {Date}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_client[s18]: Purging stale event ~p~n", [{confirm_date, {Date}}]),
        {keep_state, Data};
      false ->
        io:format("gen_client[s18]: Postponing event ~p~n", [{confirm_date, {Date}}]),
        {keep_state, Data, [postpone]}
    end;
s18(cast, {_AgencyPid, {reject_confirmation}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_client[s18]: Purging stale event ~p~n", [{reject_confirmation}]),
        {keep_state, Data};
      false ->
        io:format("gen_client[s18]: Postponing event ~p~n", [{reject_confirmation}]),
        {keep_state, Data, [postpone]}
    end;
s18(cast, {_AgencyPid, {repeat_confirmation}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_client[s18]: Purging stale event ~p~n", [{repeat_confirmation}]),
        {keep_state, Data};
      false ->
        io:format("gen_client[s18]: Postponing event ~p~n", [{repeat_confirmation}]),
        {keep_state, Data, [postpone]}
    end.


%% ---------- Send helpers----------

-spec send_s3_booking_request(AgencyPid :: pid(), term(), _Data :: state_data()) -> ok.
send_s3_booking_request(AgencyPid, Destination, _Data) ->
    gen_statem:cast(AgencyPid, {self(), {booking_request, {Destination}}}).


-spec send_s3_booking_request(AgencyPid :: pid(), _Data :: state_data()) -> ok.
send_s3_booking_request(AgencyPid, _Data) ->
    gen_statem:cast(AgencyPid, {self(), {booking_request}}).


-spec send_s6_cancel_agency(AgencyPid :: pid(), _Data :: state_data()) -> ok.
send_s6_cancel_agency(AgencyPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(AgencyPid, {self(), {cancel_agency}, Path}).


-spec send_s7_cancel_supplier(SupplierPid :: pid(), _Data :: state_data()) -> ok.
send_s7_cancel_supplier(SupplierPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(SupplierPid, {self(), {cancel_supplier}, Path}).


-spec send_s9_reject_offer(AgencyPid :: pid(), _Data :: state_data()) -> ok.
send_s9_reject_offer(AgencyPid, _Data) ->
    Path = branch_path(mc1, left),
    set_current_path(Path),
    gen_statem:cast(AgencyPid, {self(), {reject_offer}, Path}).


-spec send_s9_resubmit_request(AgencyPid :: pid(), _Data :: state_data()) -> ok.
send_s9_resubmit_request(AgencyPid, _Data) ->
    Path = branch_path(mc1, left),
    set_current_path(Path),
    gen_statem:cast(AgencyPid, {self(), {resubmit_request}, Path}).


-spec send_s9_accept_offer(AgencyPid :: pid(), _Data :: state_data()) -> ok.
send_s9_accept_offer(AgencyPid, _Data) ->
    Path = branch_path(mc1, left),
    set_current_path(Path),
    gen_statem:cast(AgencyPid, {self(), {accept_offer}, Path}).


-spec send_s11_provide_address(SupplierPid :: pid(), term(), _Data :: state_data()) -> ok.
send_s11_provide_address(SupplierPid, Address, _Data) ->
    Path = current_path(),
    gen_statem:cast(SupplierPid, {self(), {provide_address, {Address}}, Path}).


-spec send_s11_provide_address(SupplierPid :: pid(), _Data :: state_data()) -> ok.
send_s11_provide_address(SupplierPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(SupplierPid, {self(), {provide_address}, Path}).


-spec send_s15_cancel_booking(SupplierPid :: pid(), _Data :: state_data()) -> ok.
send_s15_cancel_booking(SupplierPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(SupplierPid, {self(), {cancel_booking}, Path}).


-spec send_s18_resubmitting(SupplierPid :: pid(), _Data :: state_data()) -> ok.
send_s18_resubmitting(SupplierPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(SupplierPid, {self(), {resubmitting}, Path}).


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

