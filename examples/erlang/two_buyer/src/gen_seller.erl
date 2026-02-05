
%%%-------------------------------------------------------------------
%%% gen_seller.erl — generated generic behaviour module (gen_statem)
%%%-------------------------------------------------------------------
-module(gen_seller).
-behaviour(gen_statem).

%% Public API
-export([start_link/2, callback_mode/0]).

%% gen_statem callbacks
-export([init/1, code_change/4, terminate/3,
  s3/3,
  s5/3,
  s6/3,
  s7/3,
  s9/3,
  s11/3,
  s12/3,
  s14/3,
  send_s3_not_available/2,
  send_s5_not_available/2,
  send_s6_price_quote/3,
  send_s6_price_quote/2,
  send_s7_price_quote/2,
  send_s7_price_quote/3,
  send_s9_response_timeout/2,
  send_s11_response_timeout/2,
  send_s12_purchase_confirmed/2,
  send_s14_cancel_confirmation/2]).

%% Types & records
-include("seller.hrl").
-export_type([state_data/0]).
-type state_data() :: #state_data{}.

-callback init(Args :: list()) -> {ok, s5, state_data(), [{next_event, internal, {not_available}}]}.
-callback s3(internal, {not_available}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s5(internal | cast, {not_available} | {pid(), {request_title, {term()}}}, state_data()) -> {next_state, s3, state_data()} | {next_state, s6, state_data()} | {next_state, s3, state_data(), [{next_event, internal, {not_available}}] } | {next_state, s6, state_data(), [{next_event, internal, {not_available}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s6(internal, {price_quote}, state_data()) -> {next_state, s7, state_data()} | {next_state, s7, state_data(), [{next_event, internal, {price_quote}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s7(internal, {price_quote}, state_data()) -> {next_state, s11, state_data()} | {next_state, s11, state_data(), [{next_event, internal, {price_quote}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s9(internal, {response_timeout}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s11(internal | cast, {response_timeout} | {pid(), {accept_quote}} | {pid(), {reject_quote}}, state_data()) -> {next_state, s12, state_data()} | {next_state, s14, state_data()} | {next_state, s9, state_data()} | {next_state, s12, state_data(), [{next_event, internal, {response_timeout}}] } | {next_state, s14, state_data(), [{next_event, internal, {response_timeout}}] } | {next_state, s9, state_data(), [{next_event, internal, {response_timeout}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s12(internal, {purchase_confirmed}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s14(internal, {cancel_confirmation}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.

%% ===== API =====
-spec start_link(CallbackModule :: module(), Args :: list()) ->
    {ok, pid()} | {error, term()}.
start_link(CallbackModule, Args) ->
    case code:ensure_loaded(CallbackModule) of
        {module, CallbackModule} ->
            gen_statem:start_link({local, CallbackModule}, gen_seller, {CallbackModule, Args}, [{debug, [trace, {log_to_file, "seller_debug.log"}]}]);
        {error, Reason} ->
            {error, Reason}
    end.

-spec callback_mode() -> state_functions.
callback_mode() -> state_functions.

%% ===== gen_statem =====
-spec init({module(), list()}) ->
    {ok, s5, state_data(), [{next_event, internal, {not_available}}]}.
init({CallbackModule, _Args}) ->
    io:format("seller: Initializing with callback module ~p~n", [CallbackModule]),
    put(callback_module, CallbackModule),
    set_commit(#{}),
    CallbackModule:init([]).

%% ---------- State functions----------
-spec s3(internal, {not_available}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
s3(internal, {not_available}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s3(internal, {not_available}, Data),
        Next;
s3(cast, {_AlicePid, {request_title, {Title}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_seller[s3]: Purging stale event ~p~n", [{request_title, {Title}}]),
        {keep_state, Data};
      false ->
        io:format("gen_seller[s3]: Postponing event ~p~n", [{request_title, {Title}}]),
        {keep_state, Data, [postpone]}
    end;
s3(cast, {_BobPid, {reject_quote}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_seller[s3]: Purging stale event ~p~n", [{reject_quote}]),
        {keep_state, Data};
      false ->
        io:format("gen_seller[s3]: Postponing event ~p~n", [{reject_quote}]),
        {keep_state, Data, [postpone]}
    end;
s3(cast, {_BobPid, {accept_quote}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_seller[s3]: Purging stale event ~p~n", [{accept_quote}]),
        {keep_state, Data};
      false ->
        io:format("gen_seller[s3]: Postponing event ~p~n", [{accept_quote}]),
        {keep_state, Data, [postpone]}
    end.

%% Mixed-choice entry state
-spec s5(internal | cast, {not_available} | {pid(), {request_title, {term()}}, list()}, state_data()) -> {next_state, s3, state_data()} | {next_state, s6, state_data()} | {next_state, s3, state_data(), [{next_event, internal, {not_available}}] } | {next_state, s6, state_data(), [{next_event, internal, {not_available}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s5(cast, {AlicePid, {request_title, {Title}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_seller[s5]: Purging stale event ~p~n", [{request_title, {Title}}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s5(cast, {AlicePid, {request_title, {Title}}}, Data)
               catch error:function_clause ->
                 io:format("gen_seller[s5]: Callback had no clause for ~p, postponing~n", [{request_title, {Title}}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {next_state, s3, _} -> commit_entry(mc1, right), Next;
          {next_state, s3, _, _} -> commit_entry(mc1, right), Next;
          {next_state, s6, _} -> commit_entry(mc1, left), Next;
          {next_state, s6, _, _} -> commit_entry(mc1, left), Next;
          _ -> Next
        end
    end;
s5(internal, {not_available}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s5(internal, {not_available}, Data),
        Next;
s5(cast, {_BobPid, {reject_quote}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_seller[s5]: Purging stale event ~p~n", [{reject_quote}]),
        {keep_state, Data};
      false ->
        io:format("gen_seller[s5]: Postponing event ~p~n", [{reject_quote}]),
        {keep_state, Data, [postpone]}
    end;
s5(cast, {_BobPid, {accept_quote}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_seller[s5]: Purging stale event ~p~n", [{accept_quote}]),
        {keep_state, Data};
      false ->
        io:format("gen_seller[s5]: Postponing event ~p~n", [{accept_quote}]),
        {keep_state, Data, [postpone]}
    end.

-spec s6(internal, {price_quote}, state_data()) -> {next_state, s7, state_data()} | {next_state, s7, state_data(), [{next_event, internal, {price_quote}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s6(internal, {price_quote}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s6(internal, {price_quote}, Data),
        Next;
s6(cast, {_AlicePid, {request_title, {Title}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_seller[s6]: Purging stale event ~p~n", [{request_title, {Title}}]),
        {keep_state, Data};
      false ->
        io:format("gen_seller[s6]: Postponing event ~p~n", [{request_title, {Title}}]),
        {keep_state, Data, [postpone]}
    end;
s6(cast, {_BobPid, {reject_quote}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_seller[s6]: Purging stale event ~p~n", [{reject_quote}]),
        {keep_state, Data};
      false ->
        io:format("gen_seller[s6]: Postponing event ~p~n", [{reject_quote}]),
        {keep_state, Data, [postpone]}
    end;
s6(cast, {_BobPid, {accept_quote}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_seller[s6]: Purging stale event ~p~n", [{accept_quote}]),
        {keep_state, Data};
      false ->
        io:format("gen_seller[s6]: Postponing event ~p~n", [{accept_quote}]),
        {keep_state, Data, [postpone]}
    end.

-spec s7(internal, {price_quote}, state_data()) -> {next_state, s11, state_data()} | {next_state, s11, state_data(), [{next_event, internal, {price_quote}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s7(internal, {price_quote}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s7(internal, {price_quote}, Data),
        Next;
s7(cast, {_AlicePid, {request_title, {Title}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_seller[s7]: Purging stale event ~p~n", [{request_title, {Title}}]),
        {keep_state, Data};
      false ->
        io:format("gen_seller[s7]: Postponing event ~p~n", [{request_title, {Title}}]),
        {keep_state, Data, [postpone]}
    end;
s7(cast, {_BobPid, {reject_quote}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_seller[s7]: Purging stale event ~p~n", [{reject_quote}]),
        {keep_state, Data};
      false ->
        io:format("gen_seller[s7]: Postponing event ~p~n", [{reject_quote}]),
        {keep_state, Data, [postpone]}
    end;
s7(cast, {_BobPid, {accept_quote}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_seller[s7]: Purging stale event ~p~n", [{accept_quote}]),
        {keep_state, Data};
      false ->
        io:format("gen_seller[s7]: Postponing event ~p~n", [{accept_quote}]),
        {keep_state, Data, [postpone]}
    end.

-spec s9(internal, {response_timeout}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
s9(internal, {response_timeout}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s9(internal, {response_timeout}, Data),
        Next;
s9(cast, {_AlicePid, {request_title, {Title}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_seller[s9]: Purging stale event ~p~n", [{request_title, {Title}}]),
        {keep_state, Data};
      false ->
        io:format("gen_seller[s9]: Postponing event ~p~n", [{request_title, {Title}}]),
        {keep_state, Data, [postpone]}
    end;
s9(cast, {_BobPid, {reject_quote}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_seller[s9]: Purging stale event ~p~n", [{reject_quote}]),
        {keep_state, Data};
      false ->
        io:format("gen_seller[s9]: Postponing event ~p~n", [{reject_quote}]),
        {keep_state, Data, [postpone]}
    end;
s9(cast, {_BobPid, {accept_quote}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_seller[s9]: Purging stale event ~p~n", [{accept_quote}]),
        {keep_state, Data};
      false ->
        io:format("gen_seller[s9]: Postponing event ~p~n", [{accept_quote}]),
        {keep_state, Data, [postpone]}
    end.

%% Mixed-choice entry state
-spec s11(internal | cast, {response_timeout} | {pid(), {reject_quote}, list()} | {pid(), {accept_quote}, list()}, state_data()) -> {next_state, s12, state_data()} | {next_state, s14, state_data()} | {next_state, s9, state_data()} | {next_state, s12, state_data(), [{next_event, internal, {response_timeout}}] } | {next_state, s14, state_data(), [{next_event, internal, {response_timeout}}] } | {next_state, s9, state_data(), [{next_event, internal, {response_timeout}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s11(cast, {BobPid, {reject_quote}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_seller[s11]: Purging stale event ~p~n", [{reject_quote}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s11(cast, {BobPid, {reject_quote}}, Data)
               catch error:function_clause ->
                 io:format("gen_seller[s11]: Callback had no clause for ~p, postponing~n", [{reject_quote}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {next_state, s9, _} -> commit_entry(mc2, right), Next;
          {next_state, s9, _, _} -> commit_entry(mc2, right), Next;
          {next_state, s12, _} -> commit_entry(mc2, left), Next;
          {next_state, s12, _, _} -> commit_entry(mc2, left), Next;
          _ -> Next
        end
    end;
s11(internal, {response_timeout}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s11(internal, {response_timeout}, Data),
        Next;
s11(cast, {BobPid, {accept_quote}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_seller[s11]: Purging stale event ~p~n", [{accept_quote}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s11(cast, {BobPid, {accept_quote}}, Data)
               catch error:function_clause ->
                 io:format("gen_seller[s11]: Callback had no clause for ~p, postponing~n", [{accept_quote}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {next_state, s9, _} -> commit_entry(mc2, right), Next;
          {next_state, s9, _, _} -> commit_entry(mc2, right), Next;
          {next_state, s12, _} -> commit_entry(mc2, left), Next;
          {next_state, s12, _, _} -> commit_entry(mc2, left), Next;
          _ -> Next
        end
    end;
s11(cast, {_AlicePid, {request_title, {Title}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_seller[s11]: Purging stale event ~p~n", [{request_title, {Title}}]),
        {keep_state, Data};
      false ->
        io:format("gen_seller[s11]: Postponing event ~p~n", [{request_title, {Title}}]),
        {keep_state, Data, [postpone]}
    end.

-spec s12(internal, {purchase_confirmed}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
s12(internal, {purchase_confirmed}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s12(internal, {purchase_confirmed}, Data),
        Next;
s12(cast, {_AlicePid, {request_title, {Title}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_seller[s12]: Purging stale event ~p~n", [{request_title, {Title}}]),
        {keep_state, Data};
      false ->
        io:format("gen_seller[s12]: Postponing event ~p~n", [{request_title, {Title}}]),
        {keep_state, Data, [postpone]}
    end;
s12(cast, {_BobPid, {reject_quote}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_seller[s12]: Purging stale event ~p~n", [{reject_quote}]),
        {keep_state, Data};
      false ->
        io:format("gen_seller[s12]: Postponing event ~p~n", [{reject_quote}]),
        {keep_state, Data, [postpone]}
    end;
s12(cast, {_BobPid, {accept_quote}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_seller[s12]: Purging stale event ~p~n", [{accept_quote}]),
        {keep_state, Data};
      false ->
        io:format("gen_seller[s12]: Postponing event ~p~n", [{accept_quote}]),
        {keep_state, Data, [postpone]}
    end.

-spec s14(internal, {cancel_confirmation}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
s14(internal, {cancel_confirmation}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s14(internal, {cancel_confirmation}, Data),
        Next;
s14(cast, {_AlicePid, {request_title, {Title}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_seller[s14]: Purging stale event ~p~n", [{request_title, {Title}}]),
        {keep_state, Data};
      false ->
        io:format("gen_seller[s14]: Postponing event ~p~n", [{request_title, {Title}}]),
        {keep_state, Data, [postpone]}
    end;
s14(cast, {_BobPid, {reject_quote}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_seller[s14]: Purging stale event ~p~n", [{reject_quote}]),
        {keep_state, Data};
      false ->
        io:format("gen_seller[s14]: Postponing event ~p~n", [{reject_quote}]),
        {keep_state, Data, [postpone]}
    end;
s14(cast, {_BobPid, {accept_quote}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_seller[s14]: Purging stale event ~p~n", [{accept_quote}]),
        {keep_state, Data};
      false ->
        io:format("gen_seller[s14]: Postponing event ~p~n", [{accept_quote}]),
        {keep_state, Data, [postpone]}
    end.


%% ---------- Send helpers----------

-spec send_s3_not_available(BobPid :: pid(), _Data :: state_data()) -> ok.
send_s3_not_available(BobPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(BobPid, {self(), {not_available}, Path}).


-spec send_s5_not_available(AlicePid :: pid(), _Data :: state_data()) -> ok.
send_s5_not_available(AlicePid, _Data) ->
    Path = current_path(),
    gen_statem:cast(AlicePid, {self(), {not_available}, Path}).


-spec send_s6_price_quote(AlicePid :: pid(), term(), _Data :: state_data()) -> ok.
send_s6_price_quote(AlicePid, Price, _Data) ->
    Path = current_path(),
    gen_statem:cast(AlicePid, {self(), {price_quote, {Price}}, Path}).


-spec send_s6_price_quote(AlicePid :: pid(), _Data :: state_data()) -> ok.
send_s6_price_quote(AlicePid, _Data) ->
    Path = current_path(),
    gen_statem:cast(AlicePid, {self(), {price_quote}, Path}).


-spec send_s7_price_quote(BobPid :: pid(), _Data :: state_data()) -> ok.
send_s7_price_quote(BobPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(BobPid, {self(), {price_quote}, Path}).


-spec send_s7_price_quote(BobPid :: pid(), term(), _Data :: state_data()) -> ok.
send_s7_price_quote(BobPid, Price, _Data) ->
    Path = current_path(),
    gen_statem:cast(BobPid, {self(), {price_quote, {Price}}, Path}).


-spec send_s9_response_timeout(AlicePid :: pid(), _Data :: state_data()) -> ok.
send_s9_response_timeout(AlicePid, _Data) ->
    Path = current_path(),
    gen_statem:cast(AlicePid, {self(), {response_timeout}, Path}).


-spec send_s11_response_timeout(BobPid :: pid(), _Data :: state_data()) -> ok.
send_s11_response_timeout(BobPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(BobPid, {self(), {response_timeout}, Path}).


-spec send_s12_purchase_confirmed(BobPid :: pid(), _Data :: state_data()) -> ok.
send_s12_purchase_confirmed(BobPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(BobPid, {self(), {purchase_confirmed}, Path}).


-spec send_s14_cancel_confirmation(BobPid :: pid(), _Data :: state_data()) -> ok.
send_s14_cancel_confirmation(BobPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(BobPid, {self(), {cancel_confirmation}, Path}).


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

