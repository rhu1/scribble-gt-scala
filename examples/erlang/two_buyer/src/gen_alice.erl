
%%%-------------------------------------------------------------------
%%% gen_alice.erl — generated generic behaviour module (gen_statem)
%%%-------------------------------------------------------------------
-module(gen_alice).
-behaviour(gen_statem).

%% Public API
-export([start_link/2, callback_mode/0]).

%% gen_statem callbacks
-export([init/1, code_change/4, terminate/3,
  s4/3,
  s5/3,
  s6/3,
  s9/3,
  send_s4_request_title/2,
  send_s4_request_title/3,
  send_s6_contribution/3,
  send_s6_contribution/2]).

%% Types & records
-include("alice.hrl").
-export_type([state_data/0]).
-type state_data() :: #state_data{}.

-callback init(Args :: list()) -> {ok, s4, state_data(), [{next_event, internal, {request_title}}]}.
-callback s4(internal | cast, {request_title} | {pid(), {not_available}}, state_data()) -> {next_state, s5, state_data()} | {next_state, s5, state_data(), [{next_event, internal, {request_title}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s5(cast, {pid(), {not_available}} | {pid(), {price_quote, {term()}}}, state_data()) -> {next_state, s6, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s6(internal, {contribution}, state_data()) -> {next_state, s9, state_data()} | {next_state, s9, state_data(), [{next_event, internal, {contribution}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s9(cast, {pid(), {cancel_notification}} | {pid(), {purchase_notification}} | {pid(), {response_timeout}}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.

%% ===== API =====
-spec start_link(CallbackModule :: module(), Args :: list()) ->
    {ok, pid()} | {error, term()}.
start_link(CallbackModule, Args) ->
    case code:ensure_loaded(CallbackModule) of
        {module, CallbackModule} ->
            gen_statem:start_link({local, CallbackModule}, gen_alice, {CallbackModule, Args}, [{debug, [trace, {log_to_file, "alice_debug.log"}]}]);
        {error, Reason} ->
            {error, Reason}
    end.

-spec callback_mode() -> state_functions.
callback_mode() -> state_functions.

%% ===== gen_statem =====
-spec init({module(), list()}) ->
    {ok, s4, state_data(), [{next_event, internal, {request_title}}]}.
init({CallbackModule, _Args}) ->
    io:format("alice: Initializing with callback module ~p~n", [CallbackModule]),
    put(callback_module, CallbackModule),
    set_commit(#{}),
    CallbackModule:init([]).

%% ---------- State functions----------
%% Mixed-choice entry state
-spec s4(internal | cast, {request_title} | {pid(), {not_available}, list()}, state_data()) -> {next_state, s5, state_data()} | {next_state, s5, state_data(), [{next_event, internal, {request_title}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s4(cast, {SellerPid, {not_available}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_alice[s4]: Purging stale event ~p~n", [{not_available}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s4(cast, {SellerPid, {not_available}}, Data)
               catch error:function_clause ->
                 io:format("gen_alice[s4]: Callback had no clause for ~p, postponing~n", [{not_available}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {next_state, s5, _} -> commit_entry(mc1, right), Next;
          {next_state, s5, _, _} -> commit_entry(mc1, right), Next;
          {next_state, s2, _} -> commit_entry(mc1, left), Next;
          {next_state, s2, _, _} -> commit_entry(mc1, left), Next;
          _ -> Next
        end
    end;
s4(internal, {request_title}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s4(internal, {request_title}, Data),
        Next;
s4(cast, {_SellerPid, {price_quote, {Price}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_alice[s4]: Purging stale event ~p~n", [{price_quote, {Price}}]),
        {keep_state, Data};
      false ->
        io:format("gen_alice[s4]: Postponing event ~p~n", [{price_quote, {Price}}]),
        {keep_state, Data, [postpone]}
    end;
s4(cast, {_BobPid, {purchase_notification}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_alice[s4]: Purging stale event ~p~n", [{purchase_notification}]),
        {keep_state, Data};
      false ->
        io:format("gen_alice[s4]: Postponing event ~p~n", [{purchase_notification}]),
        {keep_state, Data, [postpone]}
    end;
s4(cast, {_SellerPid, {response_timeout}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_alice[s4]: Purging stale event ~p~n", [{response_timeout}]),
        {keep_state, Data};
      false ->
        io:format("gen_alice[s4]: Postponing event ~p~n", [{response_timeout}]),
        {keep_state, Data, [postpone]}
    end;
s4(cast, {_BobPid, {cancel_notification}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_alice[s4]: Purging stale event ~p~n", [{cancel_notification}]),
        {keep_state, Data};
      false ->
        io:format("gen_alice[s4]: Postponing event ~p~n", [{cancel_notification}]),
        {keep_state, Data, [postpone]}
    end.

-spec s5(cast, {pid(), {price_quote, {term()}}, list()} | {pid(), {not_available}, list()}, state_data()) -> {next_state, s6, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
s5(cast, {SellerPid, {price_quote, {Price}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_alice[s5]: Purging stale event ~p~n", [{price_quote, {Price}}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s5(cast, {SellerPid, {price_quote, {Price}}}, Data)
               catch error:function_clause ->
                 io:format("gen_alice[s5]: Callback had no clause for ~p, postponing~n", [{price_quote, {Price}}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> Next
        end
    end;
s5(cast, {SellerPid, {not_available}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_alice[s5]: Purging stale event ~p~n", [{not_available}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s5(cast, {SellerPid, {not_available}}, Data)
               catch error:function_clause ->
                 io:format("gen_alice[s5]: Callback had no clause for ~p, postponing~n", [{not_available}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> Next
        end
    end;
s5(cast, {_BobPid, {purchase_notification}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_alice[s5]: Purging stale event ~p~n", [{purchase_notification}]),
        {keep_state, Data};
      false ->
        io:format("gen_alice[s5]: Postponing event ~p~n", [{purchase_notification}]),
        {keep_state, Data, [postpone]}
    end;
s5(cast, {_SellerPid, {response_timeout}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_alice[s5]: Purging stale event ~p~n", [{response_timeout}]),
        {keep_state, Data};
      false ->
        io:format("gen_alice[s5]: Postponing event ~p~n", [{response_timeout}]),
        {keep_state, Data, [postpone]}
    end;
s5(cast, {_BobPid, {cancel_notification}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_alice[s5]: Purging stale event ~p~n", [{cancel_notification}]),
        {keep_state, Data};
      false ->
        io:format("gen_alice[s5]: Postponing event ~p~n", [{cancel_notification}]),
        {keep_state, Data, [postpone]}
    end.

-spec s6(internal, {contribution}, state_data()) -> {next_state, s9, state_data()} | {next_state, s9, state_data(), [{next_event, internal, {contribution}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s6(internal, {contribution}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s6(internal, {contribution}, Data),
        Next;
s6(cast, {_SellerPid, {not_available}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_alice[s6]: Purging stale event ~p~n", [{not_available}]),
        {keep_state, Data};
      false ->
        io:format("gen_alice[s6]: Postponing event ~p~n", [{not_available}]),
        {keep_state, Data, [postpone]}
    end;
s6(cast, {_SellerPid, {price_quote, {Price}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_alice[s6]: Purging stale event ~p~n", [{price_quote, {Price}}]),
        {keep_state, Data};
      false ->
        io:format("gen_alice[s6]: Postponing event ~p~n", [{price_quote, {Price}}]),
        {keep_state, Data, [postpone]}
    end;
s6(cast, {_BobPid, {purchase_notification}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_alice[s6]: Purging stale event ~p~n", [{purchase_notification}]),
        {keep_state, Data};
      false ->
        io:format("gen_alice[s6]: Postponing event ~p~n", [{purchase_notification}]),
        {keep_state, Data, [postpone]}
    end;
s6(cast, {_SellerPid, {response_timeout}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_alice[s6]: Purging stale event ~p~n", [{response_timeout}]),
        {keep_state, Data};
      false ->
        io:format("gen_alice[s6]: Postponing event ~p~n", [{response_timeout}]),
        {keep_state, Data, [postpone]}
    end;
s6(cast, {_BobPid, {cancel_notification}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_alice[s6]: Purging stale event ~p~n", [{cancel_notification}]),
        {keep_state, Data};
      false ->
        io:format("gen_alice[s6]: Postponing event ~p~n", [{cancel_notification}]),
        {keep_state, Data, [postpone]}
    end.

%% Mixed-choice entry state
-spec s9(cast, {pid(), {response_timeout}, list()} | {pid(), {cancel_notification}, list()} | {pid(), {purchase_notification}, list()}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
s9(cast, {SellerPid, {response_timeout}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_alice[s9]: Purging stale event ~p~n", [{response_timeout}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s9(cast, {SellerPid, {response_timeout}}, Data)
               catch error:function_clause ->
                 io:format("gen_alice[s9]: Callback had no clause for ~p, postponing~n", [{response_timeout}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {next_state, s2, _} -> commit_entry(mc2, left), Next;
          {next_state, s2, _, _} -> commit_entry(mc2, left), Next;
          _ -> Next
        end
    end;
s9(cast, {BobPid, {cancel_notification}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_alice[s9]: Purging stale event ~p~n", [{cancel_notification}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s9(cast, {BobPid, {cancel_notification}}, Data)
               catch error:function_clause ->
                 io:format("gen_alice[s9]: Callback had no clause for ~p, postponing~n", [{cancel_notification}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {next_state, s2, _} -> commit_entry(mc2, left), Next;
          {next_state, s2, _, _} -> commit_entry(mc2, left), Next;
          _ -> Next
        end
    end;
s9(cast, {BobPid, {purchase_notification}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_alice[s9]: Purging stale event ~p~n", [{purchase_notification}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s9(cast, {BobPid, {purchase_notification}}, Data)
               catch error:function_clause ->
                 io:format("gen_alice[s9]: Callback had no clause for ~p, postponing~n", [{purchase_notification}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {next_state, s2, _} -> commit_entry(mc2, left), Next;
          {next_state, s2, _, _} -> commit_entry(mc2, left), Next;
          _ -> Next
        end
    end;
s9(cast, {_SellerPid, {not_available}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_alice[s9]: Purging stale event ~p~n", [{not_available}]),
        {keep_state, Data};
      false ->
        io:format("gen_alice[s9]: Postponing event ~p~n", [{not_available}]),
        {keep_state, Data, [postpone]}
    end;
s9(cast, {_SellerPid, {price_quote, {Price}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_alice[s9]: Purging stale event ~p~n", [{price_quote, {Price}}]),
        {keep_state, Data};
      false ->
        io:format("gen_alice[s9]: Postponing event ~p~n", [{price_quote, {Price}}]),
        {keep_state, Data, [postpone]}
    end.


%% ---------- Send helpers----------

-spec send_s4_request_title(SellerPid :: pid(), _Data :: state_data()) -> ok.
send_s4_request_title(SellerPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(SellerPid, {self(), {request_title}, Path}).


-spec send_s4_request_title(SellerPid :: pid(), term(), _Data :: state_data()) -> ok.
send_s4_request_title(SellerPid, Title, _Data) ->
    Path = current_path(),
    gen_statem:cast(SellerPid, {self(), {request_title, {Title}}, Path}).


-spec send_s6_contribution(BobPid :: pid(), term(), _Data :: state_data()) -> ok.
send_s6_contribution(BobPid, Amount, _Data) ->
    Path = current_path(),
    gen_statem:cast(BobPid, {self(), {contribution, {Amount}}, Path}).


-spec send_s6_contribution(BobPid :: pid(), _Data :: state_data()) -> ok.
send_s6_contribution(BobPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(BobPid, {self(), {contribution}, Path}).


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

