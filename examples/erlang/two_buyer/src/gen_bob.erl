
%%%-------------------------------------------------------------------
%%% gen_bob.erl — generated generic behaviour module (gen_statem)
%%%-------------------------------------------------------------------
-module(gen_bob).
-behaviour(gen_statem).

%% Public API
-export([start_link/2, callback_mode/0]).

%% gen_statem callbacks
-export([init/1, code_change/4, terminate/3,
  s4/3,
  s5/3,
  s8/3,
  s9/3,
  s10/3,
  s12/3,
  s13/3,
  send_s8_reject_quote/2,
  send_s8_accept_quote/2,
  send_s10_purchase_notification/2,
  send_s13_cancel_notification/2]).

%% Types & records
-include("bob.hrl").
-export_type([state_data/0]).
-type state_data() :: #state_data{}.

-callback init(Args :: list()) -> {ok, s4, state_data()}.
-callback s4(cast, {pid(), {not_available}} | {pid(), {price_quote, {term()}}}, state_data()) -> {next_state, s5, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s5(cast, {pid(), {contribution, {term()}}}, state_data()) -> {next_state, s8, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s8(internal | cast, {accept_quote} | {reject_quote} | {pid(), {response_timeout}}, state_data()) -> {next_state, s12, state_data()} | {next_state, s9, state_data()} | {next_state, s12, state_data(), [{next_event, internal, {accept_quote}}] } | {next_state, s12, state_data(), [{next_event, internal, {reject_quote}}] } | {next_state, s9, state_data(), [{next_event, internal, {accept_quote}}] } | {next_state, s9, state_data(), [{next_event, internal, {reject_quote}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s9(cast, {pid(), {purchase_confirmed}} | {pid(), {response_timeout}}, state_data()) -> {next_state, s10, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s10(internal, {purchase_notification}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s12(cast, {pid(), {cancel_confirmation}} | {pid(), {response_timeout}}, state_data()) -> {next_state, s13, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s13(internal, {cancel_notification}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.

%% ===== API =====
-spec start_link(CallbackModule :: module(), Args :: list()) ->
    {ok, pid()} | {error, term()}.
start_link(CallbackModule, Args) ->
    case code:ensure_loaded(CallbackModule) of
        {module, CallbackModule} ->
            gen_statem:start_link({local, CallbackModule}, gen_bob, {CallbackModule, Args}, [{debug, [trace, {log_to_file, "bob_debug.log"}]}]);
        {error, Reason} ->
            {error, Reason}
    end.

-spec callback_mode() -> state_functions.
callback_mode() -> state_functions.

%% ===== gen_statem =====
-spec init({module(), list()}) ->
    {ok, s4, state_data()}.
init({CallbackModule, _Args}) ->
    io:format("bob: Initializing with callback module ~p~n", [CallbackModule]),
    put(callback_module, CallbackModule),
    init_context(),
    enter_mc(mc2),
    CallbackModule:init([]).

%% ---------- State functions----------
%% Mixed-choice entry state
-spec s4(cast, {pid(), {price_quote, {term()}}, list()} | {pid(), {not_available}, list()}, state_data()) -> {next_state, s5, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
s4(cast, {SellerPid, {price_quote, {Price}}, Path}, Data) ->
    case message_status(Path, branch_path(mc2, left)) of
      stale ->
        io:format("gen_bob[s4]: Purging stale event ~p~n", [{price_quote, {Price}}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s4(cast, {SellerPid, {price_quote, {Price}}}, Data)
               catch error:function_clause ->
                 io:format("gen_bob[s4]: Callback had no clause for ~p, postponing~n", [{price_quote, {Price}}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {next_state, s5, _} -> after_transition(commit_if_taken(Next, mc2, left));
          {next_state, s5, _, _} -> after_transition(commit_if_taken(Next, mc2, left));
          _ -> after_transition(Next)
        end;
      not_ready ->
        io:format("gen_bob[s4]: Postponing not-ready event ~p~n", [{price_quote, {Price}}]),
        {keep_state, Data, [postpone]}
    end;
s4(cast, {SellerPid, {not_available}, Path}, Data) ->
    case message_status(Path, branch_path(mc2, right)) of
      stale ->
        io:format("gen_bob[s4]: Purging stale event ~p~n", [{not_available}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s4(cast, {SellerPid, {not_available}}, Data)
               catch error:function_clause ->
                 io:format("gen_bob[s4]: Callback had no clause for ~p, postponing~n", [{not_available}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {stop, _, _} -> after_transition(commit_if_taken(Next, mc2, right));
          _ -> after_transition(Next)
        end;
      not_ready ->
        io:format("gen_bob[s4]: Postponing not-ready event ~p~n", [{not_available}]),
        {keep_state, Data, [postpone]}
    end;
s4(cast, {_AlicePid, {contribution, {Amount}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_bob[s4]: Purging stale event ~p~n", [{contribution, {Amount}}]),
        {keep_state, Data};
      false ->
        io:format("gen_bob[s4]: Postponing event ~p~n", [{contribution, {Amount}}]),
        {keep_state, Data, [postpone]}
    end;
s4(cast, {_SellerPid, {response_timeout}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_bob[s4]: Purging stale event ~p~n", [{response_timeout}]),
        {keep_state, Data};
      false ->
        io:format("gen_bob[s4]: Postponing event ~p~n", [{response_timeout}]),
        {keep_state, Data, [postpone]}
    end;
s4(cast, {_SellerPid, {purchase_confirmed}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_bob[s4]: Purging stale event ~p~n", [{purchase_confirmed}]),
        {keep_state, Data};
      false ->
        io:format("gen_bob[s4]: Postponing event ~p~n", [{purchase_confirmed}]),
        {keep_state, Data, [postpone]}
    end;
s4(cast, {_SellerPid, {cancel_confirmation}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_bob[s4]: Purging stale event ~p~n", [{cancel_confirmation}]),
        {keep_state, Data};
      false ->
        io:format("gen_bob[s4]: Postponing event ~p~n", [{cancel_confirmation}]),
        {keep_state, Data, [postpone]}
    end.

-spec s5(cast, {pid(), {contribution, {term()}}, list()}, state_data()) -> {next_state, s8, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
s5(cast, {AlicePid, {contribution, {Amount}}, Path}, Data) ->
    case message_status(Path, current_path()) of
      stale ->
        io:format("gen_bob[s5]: Purging stale event ~p~n", [{contribution, {Amount}}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s5(cast, {AlicePid, {contribution, {Amount}}}, Data)
               catch error:function_clause ->
                 io:format("gen_bob[s5]: Callback had no clause for ~p, postponing~n", [{contribution, {Amount}}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> after_transition(Next)
        end;
      not_ready ->
        io:format("gen_bob[s5]: Postponing not-ready event ~p~n", [{contribution, {Amount}}]),
        {keep_state, Data, [postpone]}
    end;
s5(cast, {_SellerPid, {price_quote, {Price}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_bob[s5]: Purging stale event ~p~n", [{price_quote, {Price}}]),
        {keep_state, Data};
      false ->
        io:format("gen_bob[s5]: Postponing event ~p~n", [{price_quote, {Price}}]),
        {keep_state, Data, [postpone]}
    end;
s5(cast, {SellerPid, {not_available}, Path}, Data) ->
    case message_status(Path, branch_path(mc2, right)) of
      stale ->
        io:format("gen_bob[s5]: Purging stale interrupt ~p~n", [{not_available}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s4(cast, {SellerPid, {not_available}}, Data)
               catch error:function_clause ->
                 io:format("gen_bob[s5]: Callback had no interrupt clause for ~p, postponing~n", [{not_available}]),
                 {keep_state, Data, [postpone]}
               end,
        after_transition(commit_if_taken(Next, mc2, right));
      not_ready ->
        io:format("gen_bob[s5]: Postponing not-ready interrupt ~p~n", [{not_available}]),
        {keep_state, Data, [postpone]}
    end;
s5(cast, {_SellerPid, {response_timeout}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_bob[s5]: Purging stale event ~p~n", [{response_timeout}]),
        {keep_state, Data};
      false ->
        io:format("gen_bob[s5]: Postponing event ~p~n", [{response_timeout}]),
        {keep_state, Data, [postpone]}
    end;
s5(cast, {_SellerPid, {purchase_confirmed}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_bob[s5]: Purging stale event ~p~n", [{purchase_confirmed}]),
        {keep_state, Data};
      false ->
        io:format("gen_bob[s5]: Postponing event ~p~n", [{purchase_confirmed}]),
        {keep_state, Data, [postpone]}
    end;
s5(cast, {_SellerPid, {cancel_confirmation}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_bob[s5]: Purging stale event ~p~n", [{cancel_confirmation}]),
        {keep_state, Data};
      false ->
        io:format("gen_bob[s5]: Postponing event ~p~n", [{cancel_confirmation}]),
        {keep_state, Data, [postpone]}
    end.

%% Mixed-choice entry state
-spec s8(internal | cast, {accept_quote} | {reject_quote} | {pid(), {response_timeout}, list()}, state_data()) -> {next_state, s12, state_data()} | {next_state, s9, state_data()} | {next_state, s12, state_data(), [{next_event, internal, {accept_quote}}] } | {next_state, s12, state_data(), [{next_event, internal, {reject_quote}}] } | {next_state, s9, state_data(), [{next_event, internal, {accept_quote}}] } | {next_state, s9, state_data(), [{next_event, internal, {reject_quote}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s8(internal, {reject_quote}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s8(internal, {reject_quote}, Data),
    after_transition(Next);
s8(internal, {accept_quote}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s8(internal, {accept_quote}, Data),
    after_transition(Next);
s8(cast, {SellerPid, {response_timeout}, Path}, Data) ->
    case message_status(Path, branch_path(mc1, right)) of
      stale ->
        io:format("gen_bob[s8]: Purging stale event ~p~n", [{response_timeout}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s8(cast, {SellerPid, {response_timeout}}, Data)
               catch error:function_clause ->
                 io:format("gen_bob[s8]: Callback had no clause for ~p, postponing~n", [{response_timeout}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {stop, _, _} -> after_transition(commit_if_taken(Next, mc1, right));
          _ -> after_transition(Next)
        end;
      not_ready ->
        io:format("gen_bob[s8]: Postponing not-ready event ~p~n", [{response_timeout}]),
        {keep_state, Data, [postpone]}
    end;
s8(cast, {_SellerPid, {price_quote, {Price}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_bob[s8]: Purging stale event ~p~n", [{price_quote, {Price}}]),
        {keep_state, Data};
      false ->
        io:format("gen_bob[s8]: Postponing event ~p~n", [{price_quote, {Price}}]),
        {keep_state, Data, [postpone]}
    end;
s8(cast, {SellerPid, {not_available}, Path}, Data) ->
    case message_status(Path, branch_path(mc2, right)) of
      stale ->
        io:format("gen_bob[s8]: Purging stale interrupt ~p~n", [{not_available}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s4(cast, {SellerPid, {not_available}}, Data)
               catch error:function_clause ->
                 io:format("gen_bob[s8]: Callback had no interrupt clause for ~p, postponing~n", [{not_available}]),
                 {keep_state, Data, [postpone]}
               end,
        after_transition(commit_if_taken(Next, mc2, right));
      not_ready ->
        io:format("gen_bob[s8]: Postponing not-ready interrupt ~p~n", [{not_available}]),
        {keep_state, Data, [postpone]}
    end;
s8(cast, {_AlicePid, {contribution, {Amount}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_bob[s8]: Purging stale event ~p~n", [{contribution, {Amount}}]),
        {keep_state, Data};
      false ->
        io:format("gen_bob[s8]: Postponing event ~p~n", [{contribution, {Amount}}]),
        {keep_state, Data, [postpone]}
    end;
s8(cast, {_SellerPid, {purchase_confirmed}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_bob[s8]: Purging stale event ~p~n", [{purchase_confirmed}]),
        {keep_state, Data};
      false ->
        io:format("gen_bob[s8]: Postponing event ~p~n", [{purchase_confirmed}]),
        {keep_state, Data, [postpone]}
    end;
s8(cast, {_SellerPid, {cancel_confirmation}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_bob[s8]: Purging stale event ~p~n", [{cancel_confirmation}]),
        {keep_state, Data};
      false ->
        io:format("gen_bob[s8]: Postponing event ~p~n", [{cancel_confirmation}]),
        {keep_state, Data, [postpone]}
    end.

-spec s9(cast, {pid(), {response_timeout}, list()} | {pid(), {purchase_confirmed}, list()}, state_data()) -> {next_state, s10, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
s9(cast, {SellerPid, {purchase_confirmed}, Path}, Data) ->
    case message_status(Path, current_path()) of
      stale ->
        io:format("gen_bob[s9]: Purging stale event ~p~n", [{purchase_confirmed}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s9(cast, {SellerPid, {purchase_confirmed}}, Data)
               catch error:function_clause ->
                 io:format("gen_bob[s9]: Callback had no clause for ~p, postponing~n", [{purchase_confirmed}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> after_transition(Next)
        end;
      not_ready ->
        io:format("gen_bob[s9]: Postponing not-ready event ~p~n", [{purchase_confirmed}]),
        {keep_state, Data, [postpone]}
    end;
s9(cast, {SellerPid, {response_timeout}, Path}, Data) ->
    case message_status(Path, branch_path(mc1, right)) of
      stale ->
        io:format("gen_bob[s9]: Purging stale event ~p~n", [{response_timeout}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s9(cast, {SellerPid, {response_timeout}}, Data)
               catch error:function_clause ->
                 io:format("gen_bob[s9]: Callback had no clause for ~p, postponing~n", [{response_timeout}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {stop, _, _} -> after_transition(commit_if_taken(Next, mc1, right));
          _ -> after_transition(Next)
        end;
      not_ready ->
        io:format("gen_bob[s9]: Postponing not-ready event ~p~n", [{response_timeout}]),
        {keep_state, Data, [postpone]}
    end;
s9(cast, {_SellerPid, {price_quote, {Price}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_bob[s9]: Purging stale event ~p~n", [{price_quote, {Price}}]),
        {keep_state, Data};
      false ->
        io:format("gen_bob[s9]: Postponing event ~p~n", [{price_quote, {Price}}]),
        {keep_state, Data, [postpone]}
    end;
s9(cast, {SellerPid, {not_available}, Path}, Data) ->
    case message_status(Path, branch_path(mc2, right)) of
      stale ->
        io:format("gen_bob[s9]: Purging stale interrupt ~p~n", [{not_available}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s4(cast, {SellerPid, {not_available}}, Data)
               catch error:function_clause ->
                 io:format("gen_bob[s9]: Callback had no interrupt clause for ~p, postponing~n", [{not_available}]),
                 {keep_state, Data, [postpone]}
               end,
        after_transition(commit_if_taken(Next, mc2, right));
      not_ready ->
        io:format("gen_bob[s9]: Postponing not-ready interrupt ~p~n", [{not_available}]),
        {keep_state, Data, [postpone]}
    end;
s9(cast, {_AlicePid, {contribution, {Amount}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_bob[s9]: Purging stale event ~p~n", [{contribution, {Amount}}]),
        {keep_state, Data};
      false ->
        io:format("gen_bob[s9]: Postponing event ~p~n", [{contribution, {Amount}}]),
        {keep_state, Data, [postpone]}
    end;
s9(cast, {_SellerPid, {cancel_confirmation}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_bob[s9]: Purging stale event ~p~n", [{cancel_confirmation}]),
        {keep_state, Data};
      false ->
        io:format("gen_bob[s9]: Postponing event ~p~n", [{cancel_confirmation}]),
        {keep_state, Data, [postpone]}
    end.

-spec s10(internal, {purchase_notification}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
s10(internal, {purchase_notification}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s10(internal, {purchase_notification}, Data),
    after_transition(Next);
s10(cast, {_SellerPid, {price_quote, {Price}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_bob[s10]: Purging stale event ~p~n", [{price_quote, {Price}}]),
        {keep_state, Data};
      false ->
        io:format("gen_bob[s10]: Postponing event ~p~n", [{price_quote, {Price}}]),
        {keep_state, Data, [postpone]}
    end;
s10(cast, {SellerPid, {not_available}, Path}, Data) ->
    case message_status(Path, branch_path(mc2, right)) of
      stale ->
        io:format("gen_bob[s10]: Purging stale interrupt ~p~n", [{not_available}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s4(cast, {SellerPid, {not_available}}, Data)
               catch error:function_clause ->
                 io:format("gen_bob[s10]: Callback had no interrupt clause for ~p, postponing~n", [{not_available}]),
                 {keep_state, Data, [postpone]}
               end,
        after_transition(commit_if_taken(Next, mc2, right));
      not_ready ->
        io:format("gen_bob[s10]: Postponing not-ready interrupt ~p~n", [{not_available}]),
        {keep_state, Data, [postpone]}
    end;
s10(cast, {_AlicePid, {contribution, {Amount}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_bob[s10]: Purging stale event ~p~n", [{contribution, {Amount}}]),
        {keep_state, Data};
      false ->
        io:format("gen_bob[s10]: Postponing event ~p~n", [{contribution, {Amount}}]),
        {keep_state, Data, [postpone]}
    end;
s10(cast, {SellerPid, {response_timeout}, Path}, Data) ->
    case message_status(Path, branch_path(mc1, right)) of
      stale ->
        io:format("gen_bob[s10]: Purging stale interrupt ~p~n", [{response_timeout}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s8(cast, {SellerPid, {response_timeout}}, Data)
               catch error:function_clause ->
                 io:format("gen_bob[s10]: Callback had no interrupt clause for ~p, postponing~n", [{response_timeout}]),
                 {keep_state, Data, [postpone]}
               end,
        after_transition(commit_if_taken(Next, mc1, right));
      not_ready ->
        io:format("gen_bob[s10]: Postponing not-ready interrupt ~p~n", [{response_timeout}]),
        {keep_state, Data, [postpone]}
    end;
s10(cast, {_SellerPid, {purchase_confirmed}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_bob[s10]: Purging stale event ~p~n", [{purchase_confirmed}]),
        {keep_state, Data};
      false ->
        io:format("gen_bob[s10]: Postponing event ~p~n", [{purchase_confirmed}]),
        {keep_state, Data, [postpone]}
    end;
s10(cast, {_SellerPid, {cancel_confirmation}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_bob[s10]: Purging stale event ~p~n", [{cancel_confirmation}]),
        {keep_state, Data};
      false ->
        io:format("gen_bob[s10]: Postponing event ~p~n", [{cancel_confirmation}]),
        {keep_state, Data, [postpone]}
    end.

-spec s12(cast, {pid(), {response_timeout}, list()} | {pid(), {cancel_confirmation}, list()}, state_data()) -> {next_state, s13, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
s12(cast, {SellerPid, {response_timeout}, Path}, Data) ->
    case message_status(Path, branch_path(mc1, right)) of
      stale ->
        io:format("gen_bob[s12]: Purging stale event ~p~n", [{response_timeout}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s12(cast, {SellerPid, {response_timeout}}, Data)
               catch error:function_clause ->
                 io:format("gen_bob[s12]: Callback had no clause for ~p, postponing~n", [{response_timeout}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {stop, _, _} -> after_transition(commit_if_taken(Next, mc1, right));
          _ -> after_transition(Next)
        end;
      not_ready ->
        io:format("gen_bob[s12]: Postponing not-ready event ~p~n", [{response_timeout}]),
        {keep_state, Data, [postpone]}
    end;
s12(cast, {SellerPid, {cancel_confirmation}, Path}, Data) ->
    case message_status(Path, current_path()) of
      stale ->
        io:format("gen_bob[s12]: Purging stale event ~p~n", [{cancel_confirmation}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s12(cast, {SellerPid, {cancel_confirmation}}, Data)
               catch error:function_clause ->
                 io:format("gen_bob[s12]: Callback had no clause for ~p, postponing~n", [{cancel_confirmation}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> after_transition(Next)
        end;
      not_ready ->
        io:format("gen_bob[s12]: Postponing not-ready event ~p~n", [{cancel_confirmation}]),
        {keep_state, Data, [postpone]}
    end;
s12(cast, {_SellerPid, {price_quote, {Price}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_bob[s12]: Purging stale event ~p~n", [{price_quote, {Price}}]),
        {keep_state, Data};
      false ->
        io:format("gen_bob[s12]: Postponing event ~p~n", [{price_quote, {Price}}]),
        {keep_state, Data, [postpone]}
    end;
s12(cast, {SellerPid, {not_available}, Path}, Data) ->
    case message_status(Path, branch_path(mc2, right)) of
      stale ->
        io:format("gen_bob[s12]: Purging stale interrupt ~p~n", [{not_available}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s4(cast, {SellerPid, {not_available}}, Data)
               catch error:function_clause ->
                 io:format("gen_bob[s12]: Callback had no interrupt clause for ~p, postponing~n", [{not_available}]),
                 {keep_state, Data, [postpone]}
               end,
        after_transition(commit_if_taken(Next, mc2, right));
      not_ready ->
        io:format("gen_bob[s12]: Postponing not-ready interrupt ~p~n", [{not_available}]),
        {keep_state, Data, [postpone]}
    end;
s12(cast, {_AlicePid, {contribution, {Amount}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_bob[s12]: Purging stale event ~p~n", [{contribution, {Amount}}]),
        {keep_state, Data};
      false ->
        io:format("gen_bob[s12]: Postponing event ~p~n", [{contribution, {Amount}}]),
        {keep_state, Data, [postpone]}
    end;
s12(cast, {_SellerPid, {purchase_confirmed}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_bob[s12]: Purging stale event ~p~n", [{purchase_confirmed}]),
        {keep_state, Data};
      false ->
        io:format("gen_bob[s12]: Postponing event ~p~n", [{purchase_confirmed}]),
        {keep_state, Data, [postpone]}
    end.

-spec s13(internal, {cancel_notification}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
s13(internal, {cancel_notification}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s13(internal, {cancel_notification}, Data),
    after_transition(Next);
s13(cast, {_SellerPid, {price_quote, {Price}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_bob[s13]: Purging stale event ~p~n", [{price_quote, {Price}}]),
        {keep_state, Data};
      false ->
        io:format("gen_bob[s13]: Postponing event ~p~n", [{price_quote, {Price}}]),
        {keep_state, Data, [postpone]}
    end;
s13(cast, {SellerPid, {not_available}, Path}, Data) ->
    case message_status(Path, branch_path(mc2, right)) of
      stale ->
        io:format("gen_bob[s13]: Purging stale interrupt ~p~n", [{not_available}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s4(cast, {SellerPid, {not_available}}, Data)
               catch error:function_clause ->
                 io:format("gen_bob[s13]: Callback had no interrupt clause for ~p, postponing~n", [{not_available}]),
                 {keep_state, Data, [postpone]}
               end,
        after_transition(commit_if_taken(Next, mc2, right));
      not_ready ->
        io:format("gen_bob[s13]: Postponing not-ready interrupt ~p~n", [{not_available}]),
        {keep_state, Data, [postpone]}
    end;
s13(cast, {_AlicePid, {contribution, {Amount}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_bob[s13]: Purging stale event ~p~n", [{contribution, {Amount}}]),
        {keep_state, Data};
      false ->
        io:format("gen_bob[s13]: Postponing event ~p~n", [{contribution, {Amount}}]),
        {keep_state, Data, [postpone]}
    end;
s13(cast, {SellerPid, {response_timeout}, Path}, Data) ->
    case message_status(Path, branch_path(mc1, right)) of
      stale ->
        io:format("gen_bob[s13]: Purging stale interrupt ~p~n", [{response_timeout}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s8(cast, {SellerPid, {response_timeout}}, Data)
               catch error:function_clause ->
                 io:format("gen_bob[s13]: Callback had no interrupt clause for ~p, postponing~n", [{response_timeout}]),
                 {keep_state, Data, [postpone]}
               end,
        after_transition(commit_if_taken(Next, mc1, right));
      not_ready ->
        io:format("gen_bob[s13]: Postponing not-ready interrupt ~p~n", [{response_timeout}]),
        {keep_state, Data, [postpone]}
    end;
s13(cast, {_SellerPid, {purchase_confirmed}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_bob[s13]: Purging stale event ~p~n", [{purchase_confirmed}]),
        {keep_state, Data};
      false ->
        io:format("gen_bob[s13]: Postponing event ~p~n", [{purchase_confirmed}]),
        {keep_state, Data, [postpone]}
    end;
s13(cast, {_SellerPid, {cancel_confirmation}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_bob[s13]: Purging stale event ~p~n", [{cancel_confirmation}]),
        {keep_state, Data};
      false ->
        io:format("gen_bob[s13]: Postponing event ~p~n", [{cancel_confirmation}]),
        {keep_state, Data, [postpone]}
    end.


%% ---------- Send helpers----------

-spec send_s8_reject_quote(SellerPid :: pid(), _Data :: state_data()) -> ok.
send_s8_reject_quote(SellerPid, _Data) ->
    Path = branch_path(mc1, left),
    set_current_path(Path),
    gen_statem:cast(SellerPid, {self(), {reject_quote}, Path}).


-spec send_s8_accept_quote(SellerPid :: pid(), _Data :: state_data()) -> ok.
send_s8_accept_quote(SellerPid, _Data) ->
    Path = branch_path(mc1, left),
    set_current_path(Path),
    gen_statem:cast(SellerPid, {self(), {accept_quote}, Path}).


-spec send_s10_purchase_notification(AlicePid :: pid(), _Data :: state_data()) -> ok.
send_s10_purchase_notification(AlicePid, _Data) ->
    Path = current_path(),
    gen_statem:cast(AlicePid, {self(), {purchase_notification}, Path}).


-spec send_s13_cancel_notification(AlicePid :: pid(), _Data :: state_data()) -> ok.
send_s13_cancel_notification(AlicePid, _Data) ->
    Path = current_path(),
    gen_statem:cast(AlicePid, {self(), {cancel_notification}, Path}).


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

after_transition({next_state, s4, _} = Next) -> enter_mc(mc2), Next;
after_transition({next_state, s4, _, _} = Next) -> enter_mc(mc2), Next;
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

