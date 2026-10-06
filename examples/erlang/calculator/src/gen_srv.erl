
%%%-------------------------------------------------------------------
%%% gen_srv.erl — generated generic behaviour module (gen_statem)
%%%-------------------------------------------------------------------
-module(gen_srv).
-behaviour(gen_statem).

%% Public API
-export([start_link/2, callback_mode/0]).

%% gen_statem callbacks
-export([init/1, code_change/4, terminate/3,
  s1/3,
  s3/3,
  s6/3,
  s7/3,
  s9/3,
  send_s6_timeout/2,
  send_s7_result_sum/2,
  send_s7_result_sum/3,
  send_s9_result_diff/2,
  send_s9_result_diff/3]).

%% Types & records
-include("srv.hrl").
-export_type([state_data/0]).
-type state_data() :: #state_data{}.

-callback init(Args :: list()) -> {ok, s1, state_data()}.
-callback s1(cast, {pid(), {first, {term()}}}, state_data()) -> {next_state, s3, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s3(cast, {pid(), {second, {term()}}}, state_data()) -> {next_state, s6, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s6(internal | cast, {timeout} | {pid(), {diff}} | {pid(), {sum}}, state_data()) -> {next_state, s7, state_data()} | {next_state, s9, state_data()} | {next_state, s7, state_data(), [{next_event, internal, {timeout}}] } | {next_state, s9, state_data(), [{next_event, internal, {timeout}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s7(internal, {result_sum}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s9(internal, {result_diff}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.

%% ===== API =====
-spec start_link(CallbackModule :: module(), Args :: list()) ->
    {ok, pid()} | {error, term()}.
start_link(CallbackModule, Args) ->
    case code:ensure_loaded(CallbackModule) of
        {module, CallbackModule} ->
            gen_statem:start_link({local, CallbackModule}, gen_srv, {CallbackModule, Args}, [{debug, [trace, {log_to_file, "srv_debug.log"}]}]);
        {error, Reason} ->
            {error, Reason}
    end.

-spec callback_mode() -> state_functions.
callback_mode() -> state_functions.

%% ===== gen_statem =====
-spec init({module(), list()}) ->
    {ok, s1, state_data()}.
init({CallbackModule, _Args}) ->
    io:format("srv: Initializing with callback module ~p~n", [CallbackModule]),
    put(callback_module, CallbackModule),
    init_context(),
    CallbackModule:init([]).

%% ---------- State functions----------
-spec s1(cast, {pid(), {first, {term()}}}, state_data()) -> {next_state, s3, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
s1(cast, {CarolPid, {first, {Number}}}, Data) ->
    CallbackModule = get(callback_module),
    Next = try CallbackModule:s1(cast, {CarolPid, {first, {Number}}}, Data)
           catch error:function_clause ->
             io:format("gen_srv[s1]: Callback had no clause for ~p, ignoring~n", [{first, {Number}}]),
             {keep_state, Data}
           end,
    after_transition(Next);
s1(cast, {_From, _Msg, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_srv[s1]: Purging stale early-path event ~p~n", [_Msg]),
        {keep_state, Data};
      false ->
        io:format("gen_srv[s1]: Postponing early-path event ~p~n", [_Msg]),
        {keep_state, Data, [postpone]}
    end.

-spec s3(cast, {pid(), {second, {term()}}}, state_data()) -> {next_state, s6, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
s3(cast, {CarolPid, {second, {Number}}}, Data) ->
    CallbackModule = get(callback_module),
    Next = try CallbackModule:s3(cast, {CarolPid, {second, {Number}}}, Data)
           catch error:function_clause ->
             io:format("gen_srv[s3]: Callback had no clause for ~p, ignoring~n", [{second, {Number}}]),
             {keep_state, Data}
           end,
    after_transition(Next);
s3(cast, {_From, _Msg, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_srv[s3]: Purging stale early-path event ~p~n", [_Msg]),
        {keep_state, Data};
      false ->
        io:format("gen_srv[s3]: Postponing early-path event ~p~n", [_Msg]),
        {keep_state, Data, [postpone]}
    end.

%% Mixed-choice entry state
-spec s6(internal | cast, {timeout} | {pid(), {sum}, list()} | {pid(), {diff}, list()}, state_data()) -> {next_state, s7, state_data()} | {next_state, s9, state_data()} | {next_state, s7, state_data(), [{next_event, internal, {timeout}}] } | {next_state, s9, state_data(), [{next_event, internal, {timeout}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s6(cast, {CarolPid, {sum}, Path}, Data) ->
    case message_status(Path, branch_path(mc1, left)) of
      stale ->
        io:format("gen_srv[s6]: Purging stale event ~p~n", [{sum}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s6(cast, {CarolPid, {sum}}, Data)
               catch error:function_clause ->
                 io:format("gen_srv[s6]: Callback had no clause for ~p, postponing~n", [{sum}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {next_state, s7, _} -> after_transition(commit_if_taken(Next, mc1, left));
          {next_state, s7, _, _} -> after_transition(commit_if_taken(Next, mc1, left));
          {stop, _, _} -> after_transition(commit_if_taken(Next, mc1, right));
          _ -> after_transition(Next)
        end;
      not_ready ->
        io:format("gen_srv[s6]: Postponing not-ready event ~p~n", [{sum}]),
        {keep_state, Data, [postpone]}
    end;
s6(cast, {CarolPid, {diff}, Path}, Data) ->
    case message_status(Path, branch_path(mc1, left)) of
      stale ->
        io:format("gen_srv[s6]: Purging stale event ~p~n", [{diff}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s6(cast, {CarolPid, {diff}}, Data)
               catch error:function_clause ->
                 io:format("gen_srv[s6]: Callback had no clause for ~p, postponing~n", [{diff}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {next_state, s9, _} -> after_transition(commit_if_taken(Next, mc1, left));
          {next_state, s9, _, _} -> after_transition(commit_if_taken(Next, mc1, left));
          {stop, _, _} -> after_transition(commit_if_taken(Next, mc1, right));
          _ -> after_transition(Next)
        end;
      not_ready ->
        io:format("gen_srv[s6]: Postponing not-ready event ~p~n", [{diff}]),
        {keep_state, Data, [postpone]}
    end;
s6(internal, {timeout}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s6(internal, {timeout}, Data),
    after_transition(Next);
s6(cast, {_CarolPid, {first, {Number}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_srv[s6]: Purging stale event ~p~n", [{first, {Number}}]),
        {keep_state, Data};
      false ->
        io:format("gen_srv[s6]: Postponing event ~p~n", [{first, {Number}}]),
        {keep_state, Data, [postpone]}
    end;
s6(cast, {_CarolPid, {second, {Number}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_srv[s6]: Purging stale event ~p~n", [{second, {Number}}]),
        {keep_state, Data};
      false ->
        io:format("gen_srv[s6]: Postponing event ~p~n", [{second, {Number}}]),
        {keep_state, Data, [postpone]}
    end.

-spec s7(internal, {result_sum}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
s7(internal, {result_sum}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s7(internal, {result_sum}, Data),
    after_transition(Next);
s7(cast, {_CarolPid, {first, {Number}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_srv[s7]: Purging stale event ~p~n", [{first, {Number}}]),
        {keep_state, Data};
      false ->
        io:format("gen_srv[s7]: Postponing event ~p~n", [{first, {Number}}]),
        {keep_state, Data, [postpone]}
    end;
s7(cast, {_CarolPid, {second, {Number}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_srv[s7]: Purging stale event ~p~n", [{second, {Number}}]),
        {keep_state, Data};
      false ->
        io:format("gen_srv[s7]: Postponing event ~p~n", [{second, {Number}}]),
        {keep_state, Data, [postpone]}
    end;
s7(cast, {_CarolPid, {diff}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_srv[s7]: Purging stale event ~p~n", [{diff}]),
        {keep_state, Data};
      false ->
        io:format("gen_srv[s7]: Postponing event ~p~n", [{diff}]),
        {keep_state, Data, [postpone]}
    end;
s7(cast, {_CarolPid, {sum}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_srv[s7]: Purging stale event ~p~n", [{sum}]),
        {keep_state, Data};
      false ->
        io:format("gen_srv[s7]: Postponing event ~p~n", [{sum}]),
        {keep_state, Data, [postpone]}
    end.

-spec s9(internal, {result_diff}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
s9(internal, {result_diff}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s9(internal, {result_diff}, Data),
    after_transition(Next);
s9(cast, {_CarolPid, {first, {Number}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_srv[s9]: Purging stale event ~p~n", [{first, {Number}}]),
        {keep_state, Data};
      false ->
        io:format("gen_srv[s9]: Postponing event ~p~n", [{first, {Number}}]),
        {keep_state, Data, [postpone]}
    end;
s9(cast, {_CarolPid, {second, {Number}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_srv[s9]: Purging stale event ~p~n", [{second, {Number}}]),
        {keep_state, Data};
      false ->
        io:format("gen_srv[s9]: Postponing event ~p~n", [{second, {Number}}]),
        {keep_state, Data, [postpone]}
    end;
s9(cast, {_CarolPid, {diff}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_srv[s9]: Purging stale event ~p~n", [{diff}]),
        {keep_state, Data};
      false ->
        io:format("gen_srv[s9]: Postponing event ~p~n", [{diff}]),
        {keep_state, Data, [postpone]}
    end;
s9(cast, {_CarolPid, {sum}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_srv[s9]: Purging stale event ~p~n", [{sum}]),
        {keep_state, Data};
      false ->
        io:format("gen_srv[s9]: Postponing event ~p~n", [{sum}]),
        {keep_state, Data, [postpone]}
    end.


%% ---------- Send helpers----------

-spec send_s6_timeout(CarolPid :: pid(), _Data :: state_data()) -> ok.
send_s6_timeout(CarolPid, _Data) ->
    Path = branch_path(mc1, right),
    commit_current(mc1, right),
    gen_statem:cast(CarolPid, {self(), {timeout}, Path}).


-spec send_s7_result_sum(CarolPid :: pid(), _Data :: state_data()) -> ok.
send_s7_result_sum(CarolPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(CarolPid, {self(), {result_sum}, Path}).


-spec send_s7_result_sum(CarolPid :: pid(), term(), _Data :: state_data()) -> ok.
send_s7_result_sum(CarolPid, Result, _Data) ->
    Path = current_path(),
    gen_statem:cast(CarolPid, {self(), {result_sum, {Result}}, Path}).


-spec send_s9_result_diff(CarolPid :: pid(), _Data :: state_data()) -> ok.
send_s9_result_diff(CarolPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(CarolPid, {self(), {result_diff}, Path}).


-spec send_s9_result_diff(CarolPid :: pid(), term(), _Data :: state_data()) -> ok.
send_s9_result_diff(CarolPid, Result, _Data) ->
    Path = current_path(),
    gen_statem:cast(CarolPid, {self(), {result_diff, {Result}}, Path}).


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

after_transition({next_state, s6, _} = Next) -> enter_mc(mc1), Next;
after_transition({next_state, s6, _, _} = Next) -> enter_mc(mc1), Next;
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

