
%%%-------------------------------------------------------------------
%%% gen_agency.erl — generated generic behaviour module (gen_statem)
%%%-------------------------------------------------------------------
-module(gen_agency).
-behaviour(gen_statem).

%% Public API
-export([start_link/2, callback_mode/0]).

%% gen_statem callbacks
-export([init/1, code_change/4, terminate/3,
  s3/3,
  s4/3,
  s6/3,
  s8/3,
  s9/3,
  s11/3,
  s13/3,
  send_s4_price_quote/2,
  send_s4_price_quote/3,
  send_s8_price_adjustment/2,
  send_s8_price_adjustment/3,
  send_s9_accept_confirmation/2,
  send_s11_reject_confirmation/2,
  send_s13_repeat_confirmation/2]).

%% Types & records
-include("agency.hrl").
-export_type([state_data/0]).
-type state_data() :: #state_data{}.

-callback init(Args :: list()) -> {ok, s3, state_data()}.
-callback s3(cast, {pid(), {booking_request, {term()}}}, state_data()) -> {next_state, s4, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s4(internal, {price_quote}, state_data()) -> {next_state, s8, state_data()} | {next_state, s8, state_data(), [{next_event, internal, {price_quote}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s6(cast, {pid(), {cancel_agency}}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s8(internal | cast, {price_adjustment} | {pid(), {accept_offer}} | {pid(), {reject_offer}} | {pid(), {resubmit_request}}, state_data()) -> {next_state, s11, state_data()} | {next_state, s13, state_data()} | {next_state, s6, state_data()} | {next_state, s9, state_data()} | {next_state, s11, state_data(), [{next_event, internal, {price_adjustment}}] } | {next_state, s13, state_data(), [{next_event, internal, {price_adjustment}}] } | {next_state, s6, state_data(), [{next_event, internal, {price_adjustment}}] } | {next_state, s9, state_data(), [{next_event, internal, {price_adjustment}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s9(internal, {accept_confirmation}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s11(internal, {reject_confirmation}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s13(internal, {repeat_confirmation}, state_data()) -> {next_state, s3, state_data()} | {next_state, s3, state_data(), [{next_event, internal, {repeat_confirmation}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.

%% ===== API =====
-spec start_link(CallbackModule :: module(), Args :: list()) ->
    {ok, pid()} | {error, term()}.
start_link(CallbackModule, Args) ->
    case code:ensure_loaded(CallbackModule) of
        {module, CallbackModule} ->
            gen_statem:start_link({local, CallbackModule}, gen_agency, {CallbackModule, Args}, [{debug, [trace, {log_to_file, "agency_debug.log"}]}]);
        {error, Reason} ->
            {error, Reason}
    end.

-spec callback_mode() -> state_functions.
callback_mode() -> state_functions.

%% ===== gen_statem =====
-spec init({module(), list()}) ->
    {ok, s3, state_data()}.
init({CallbackModule, _Args}) ->
    io:format("agency: Initializing with callback module ~p~n", [CallbackModule]),
    put(callback_module, CallbackModule),
    init_context(),
    CallbackModule:init([]).

%% ---------- State functions----------
-spec s3(cast, {pid(), {booking_request, {term()}}}, state_data()) -> {next_state, s4, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
s3(cast, {ClientPid, {booking_request, {Destination}}}, Data) ->
    CallbackModule = get(callback_module),
    Next = try CallbackModule:s3(cast, {ClientPid, {booking_request, {Destination}}}, Data)
           catch error:function_clause ->
             io:format("gen_agency[s3]: Callback had no clause for ~p, ignoring~n", [{booking_request, {Destination}}]),
             {keep_state, Data}
           end,
    after_transition(Next);
s3(cast, {_From, _Msg, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_agency[s3]: Purging stale early-path event ~p~n", [_Msg]),
        {keep_state, Data};
      false ->
        io:format("gen_agency[s3]: Postponing early-path event ~p~n", [_Msg]),
        {keep_state, Data, [postpone]}
    end.

-spec s4(internal, {price_quote}, state_data()) -> {next_state, s8, state_data()} | {next_state, s8, state_data(), [{next_event, internal, {price_quote}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s4(internal, {price_quote}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s4(internal, {price_quote}, Data),
    after_transition(Next);
s4(cast, {_From, _Msg, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_agency[s4]: Purging stale early-path event ~p~n", [_Msg]),
        {keep_state, Data};
      false ->
        io:format("gen_agency[s4]: Postponing early-path event ~p~n", [_Msg]),
        {keep_state, Data, [postpone]}
    end.

-spec s6(cast, {pid(), {cancel_agency}, list()}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
s6(cast, {ClientPid, {cancel_agency}, Path}, Data) ->
    case message_status(Path, current_path()) of
      stale ->
        io:format("gen_agency[s6]: Purging stale event ~p~n", [{cancel_agency}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s6(cast, {ClientPid, {cancel_agency}}, Data)
               catch error:function_clause ->
                 io:format("gen_agency[s6]: Callback had no clause for ~p, postponing~n", [{cancel_agency}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> after_transition(Next)
        end;
      not_ready ->
        io:format("gen_agency[s6]: Postponing not-ready event ~p~n", [{cancel_agency}]),
        {keep_state, Data, [postpone]}
    end;
s6(cast, {_ClientPid, {booking_request, {Destination}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_agency[s6]: Purging stale event ~p~n", [{booking_request, {Destination}}]),
        {keep_state, Data};
      false ->
        io:format("gen_agency[s6]: Postponing event ~p~n", [{booking_request, {Destination}}]),
        {keep_state, Data, [postpone]}
    end;
s6(cast, {_ClientPid, {reject_offer}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_agency[s6]: Purging stale event ~p~n", [{reject_offer}]),
        {keep_state, Data};
      false ->
        io:format("gen_agency[s6]: Postponing event ~p~n", [{reject_offer}]),
        {keep_state, Data, [postpone]}
    end;
s6(cast, {_ClientPid, {accept_offer}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_agency[s6]: Purging stale event ~p~n", [{accept_offer}]),
        {keep_state, Data};
      false ->
        io:format("gen_agency[s6]: Postponing event ~p~n", [{accept_offer}]),
        {keep_state, Data, [postpone]}
    end;
s6(cast, {_ClientPid, {resubmit_request}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_agency[s6]: Purging stale event ~p~n", [{resubmit_request}]),
        {keep_state, Data};
      false ->
        io:format("gen_agency[s6]: Postponing event ~p~n", [{resubmit_request}]),
        {keep_state, Data, [postpone]}
    end.

%% Mixed-choice entry state
-spec s8(internal | cast, {price_adjustment} | {pid(), {accept_offer}, list()} | {pid(), {reject_offer}, list()} | {pid(), {resubmit_request}, list()}, state_data()) -> {next_state, s11, state_data()} | {next_state, s13, state_data()} | {next_state, s6, state_data()} | {next_state, s9, state_data()} | {next_state, s11, state_data(), [{next_event, internal, {price_adjustment}}] } | {next_state, s13, state_data(), [{next_event, internal, {price_adjustment}}] } | {next_state, s6, state_data(), [{next_event, internal, {price_adjustment}}] } | {next_state, s9, state_data(), [{next_event, internal, {price_adjustment}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s8(cast, {ClientPid, {reject_offer}, Path}, Data) ->
    case message_status(Path, branch_path(mc1, left)) of
      stale ->
        io:format("gen_agency[s8]: Purging stale event ~p~n", [{reject_offer}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s8(cast, {ClientPid, {reject_offer}}, Data)
               catch error:function_clause ->
                 io:format("gen_agency[s8]: Callback had no clause for ~p, postponing~n", [{reject_offer}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {next_state, s6, _} -> after_transition(commit_if_taken(Next, mc1, right));
          {next_state, s6, _, _} -> after_transition(commit_if_taken(Next, mc1, right));
          {next_state, s11, _} -> after_transition(commit_if_taken(Next, mc1, left));
          {next_state, s11, _, _} -> after_transition(commit_if_taken(Next, mc1, left));
          _ -> after_transition(Next)
        end;
      not_ready ->
        io:format("gen_agency[s8]: Postponing not-ready event ~p~n", [{reject_offer}]),
        {keep_state, Data, [postpone]}
    end;
s8(cast, {ClientPid, {accept_offer}, Path}, Data) ->
    case message_status(Path, branch_path(mc1, left)) of
      stale ->
        io:format("gen_agency[s8]: Purging stale event ~p~n", [{accept_offer}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s8(cast, {ClientPid, {accept_offer}}, Data)
               catch error:function_clause ->
                 io:format("gen_agency[s8]: Callback had no clause for ~p, postponing~n", [{accept_offer}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {next_state, s6, _} -> after_transition(commit_if_taken(Next, mc1, right));
          {next_state, s6, _, _} -> after_transition(commit_if_taken(Next, mc1, right));
          {next_state, s9, _} -> after_transition(commit_if_taken(Next, mc1, left));
          {next_state, s9, _, _} -> after_transition(commit_if_taken(Next, mc1, left));
          _ -> after_transition(Next)
        end;
      not_ready ->
        io:format("gen_agency[s8]: Postponing not-ready event ~p~n", [{accept_offer}]),
        {keep_state, Data, [postpone]}
    end;
s8(internal, {price_adjustment}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s8(internal, {price_adjustment}, Data),
    after_transition(Next);
s8(cast, {ClientPid, {resubmit_request}, Path}, Data) ->
    case message_status(Path, branch_path(mc1, left)) of
      stale ->
        io:format("gen_agency[s8]: Purging stale event ~p~n", [{resubmit_request}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s8(cast, {ClientPid, {resubmit_request}}, Data)
               catch error:function_clause ->
                 io:format("gen_agency[s8]: Callback had no clause for ~p, postponing~n", [{resubmit_request}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {next_state, s6, _} -> after_transition(commit_if_taken(Next, mc1, right));
          {next_state, s6, _, _} -> after_transition(commit_if_taken(Next, mc1, right));
          {next_state, s13, _} -> after_transition(commit_if_taken(Next, mc1, left));
          {next_state, s13, _, _} -> after_transition(commit_if_taken(Next, mc1, left));
          _ -> after_transition(Next)
        end;
      not_ready ->
        io:format("gen_agency[s8]: Postponing not-ready event ~p~n", [{resubmit_request}]),
        {keep_state, Data, [postpone]}
    end;
s8(cast, {_ClientPid, {booking_request, {Destination}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_agency[s8]: Purging stale event ~p~n", [{booking_request, {Destination}}]),
        {keep_state, Data};
      false ->
        io:format("gen_agency[s8]: Postponing event ~p~n", [{booking_request, {Destination}}]),
        {keep_state, Data, [postpone]}
    end;
s8(cast, {_ClientPid, {cancel_agency}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_agency[s8]: Purging stale event ~p~n", [{cancel_agency}]),
        {keep_state, Data};
      false ->
        io:format("gen_agency[s8]: Postponing event ~p~n", [{cancel_agency}]),
        {keep_state, Data, [postpone]}
    end.

-spec s9(internal, {accept_confirmation}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
s9(internal, {accept_confirmation}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s9(internal, {accept_confirmation}, Data),
    after_transition(Next);
s9(cast, {_ClientPid, {booking_request, {Destination}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_agency[s9]: Purging stale event ~p~n", [{booking_request, {Destination}}]),
        {keep_state, Data};
      false ->
        io:format("gen_agency[s9]: Postponing event ~p~n", [{booking_request, {Destination}}]),
        {keep_state, Data, [postpone]}
    end;
s9(cast, {_ClientPid, {cancel_agency}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_agency[s9]: Purging stale event ~p~n", [{cancel_agency}]),
        {keep_state, Data};
      false ->
        io:format("gen_agency[s9]: Postponing event ~p~n", [{cancel_agency}]),
        {keep_state, Data, [postpone]}
    end;
s9(cast, {_ClientPid, {reject_offer}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_agency[s9]: Purging stale event ~p~n", [{reject_offer}]),
        {keep_state, Data};
      false ->
        io:format("gen_agency[s9]: Postponing event ~p~n", [{reject_offer}]),
        {keep_state, Data, [postpone]}
    end;
s9(cast, {_ClientPid, {accept_offer}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_agency[s9]: Purging stale event ~p~n", [{accept_offer}]),
        {keep_state, Data};
      false ->
        io:format("gen_agency[s9]: Postponing event ~p~n", [{accept_offer}]),
        {keep_state, Data, [postpone]}
    end;
s9(cast, {_ClientPid, {resubmit_request}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_agency[s9]: Purging stale event ~p~n", [{resubmit_request}]),
        {keep_state, Data};
      false ->
        io:format("gen_agency[s9]: Postponing event ~p~n", [{resubmit_request}]),
        {keep_state, Data, [postpone]}
    end.

-spec s11(internal, {reject_confirmation}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
s11(internal, {reject_confirmation}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s11(internal, {reject_confirmation}, Data),
    after_transition(Next);
s11(cast, {_ClientPid, {booking_request, {Destination}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_agency[s11]: Purging stale event ~p~n", [{booking_request, {Destination}}]),
        {keep_state, Data};
      false ->
        io:format("gen_agency[s11]: Postponing event ~p~n", [{booking_request, {Destination}}]),
        {keep_state, Data, [postpone]}
    end;
s11(cast, {_ClientPid, {cancel_agency}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_agency[s11]: Purging stale event ~p~n", [{cancel_agency}]),
        {keep_state, Data};
      false ->
        io:format("gen_agency[s11]: Postponing event ~p~n", [{cancel_agency}]),
        {keep_state, Data, [postpone]}
    end;
s11(cast, {_ClientPid, {reject_offer}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_agency[s11]: Purging stale event ~p~n", [{reject_offer}]),
        {keep_state, Data};
      false ->
        io:format("gen_agency[s11]: Postponing event ~p~n", [{reject_offer}]),
        {keep_state, Data, [postpone]}
    end;
s11(cast, {_ClientPid, {accept_offer}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_agency[s11]: Purging stale event ~p~n", [{accept_offer}]),
        {keep_state, Data};
      false ->
        io:format("gen_agency[s11]: Postponing event ~p~n", [{accept_offer}]),
        {keep_state, Data, [postpone]}
    end;
s11(cast, {_ClientPid, {resubmit_request}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_agency[s11]: Purging stale event ~p~n", [{resubmit_request}]),
        {keep_state, Data};
      false ->
        io:format("gen_agency[s11]: Postponing event ~p~n", [{resubmit_request}]),
        {keep_state, Data, [postpone]}
    end.

-spec s13(internal, {repeat_confirmation}, state_data()) -> {next_state, s3, state_data()} | {next_state, s3, state_data(), [{next_event, internal, {repeat_confirmation}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s13(internal, {repeat_confirmation}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s13(internal, {repeat_confirmation}, Data),
    after_transition(Next);
s13(cast, {_ClientPid, {booking_request, {Destination}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_agency[s13]: Purging stale event ~p~n", [{booking_request, {Destination}}]),
        {keep_state, Data};
      false ->
        io:format("gen_agency[s13]: Postponing event ~p~n", [{booking_request, {Destination}}]),
        {keep_state, Data, [postpone]}
    end;
s13(cast, {_ClientPid, {cancel_agency}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_agency[s13]: Purging stale event ~p~n", [{cancel_agency}]),
        {keep_state, Data};
      false ->
        io:format("gen_agency[s13]: Postponing event ~p~n", [{cancel_agency}]),
        {keep_state, Data, [postpone]}
    end;
s13(cast, {_ClientPid, {reject_offer}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_agency[s13]: Purging stale event ~p~n", [{reject_offer}]),
        {keep_state, Data};
      false ->
        io:format("gen_agency[s13]: Postponing event ~p~n", [{reject_offer}]),
        {keep_state, Data, [postpone]}
    end;
s13(cast, {_ClientPid, {accept_offer}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_agency[s13]: Purging stale event ~p~n", [{accept_offer}]),
        {keep_state, Data};
      false ->
        io:format("gen_agency[s13]: Postponing event ~p~n", [{accept_offer}]),
        {keep_state, Data, [postpone]}
    end;
s13(cast, {_ClientPid, {resubmit_request}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_agency[s13]: Purging stale event ~p~n", [{resubmit_request}]),
        {keep_state, Data};
      false ->
        io:format("gen_agency[s13]: Postponing event ~p~n", [{resubmit_request}]),
        {keep_state, Data, [postpone]}
    end.


%% ---------- Send helpers----------

-spec send_s4_price_quote(ClientPid :: pid(), _Data :: state_data()) -> ok.
send_s4_price_quote(ClientPid, _Data) ->
    gen_statem:cast(ClientPid, {self(), {price_quote}}).


-spec send_s4_price_quote(ClientPid :: pid(), term(), _Data :: state_data()) -> ok.
send_s4_price_quote(ClientPid, Price, _Data) ->
    gen_statem:cast(ClientPid, {self(), {price_quote, {Price}}}).


-spec send_s8_price_adjustment(ClientPid :: pid(), _Data :: state_data()) -> ok.
send_s8_price_adjustment(ClientPid, _Data) ->
    Path = branch_path(mc1, right),
    commit_current(mc1, right),
    gen_statem:cast(ClientPid, {self(), {price_adjustment}, Path}).


-spec send_s8_price_adjustment(ClientPid :: pid(), term(), _Data :: state_data()) -> ok.
send_s8_price_adjustment(ClientPid, Price, _Data) ->
    Path = branch_path(mc1, right),
    commit_current(mc1, right),
    gen_statem:cast(ClientPid, {self(), {price_adjustment, {Price}}, Path}).


-spec send_s9_accept_confirmation(ClientPid :: pid(), _Data :: state_data()) -> ok.
send_s9_accept_confirmation(ClientPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(ClientPid, {self(), {accept_confirmation}, Path}).


-spec send_s11_reject_confirmation(ClientPid :: pid(), _Data :: state_data()) -> ok.
send_s11_reject_confirmation(ClientPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(ClientPid, {self(), {reject_confirmation}, Path}).


-spec send_s13_repeat_confirmation(ClientPid :: pid(), _Data :: state_data()) -> ok.
send_s13_repeat_confirmation(ClientPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(ClientPid, {self(), {repeat_confirmation}, Path}).


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

