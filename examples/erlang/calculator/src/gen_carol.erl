
%%%-------------------------------------------------------------------
%%% gen_carol.erl — generated generic behaviour module (gen_statem)
%%%-------------------------------------------------------------------
-module(gen_carol).
-behaviour(gen_statem).

%% Public API
-export([start_link/2, callback_mode/0]).

%% gen_statem callbacks
-export([init/1, code_change/4, terminate/3,
  s1/3,
  s3/3,
  s5/3,
  s7/3,
  s8/3,
  s9/3,
  s11/3,
  s12/3,
  send_s1_first/3,
  send_s1_first/2,
  send_s3_second/3,
  send_s3_second/2,
  send_s5_cancel/2,
  send_s7_sum/2,
  send_s7_diff/2,
  send_s9_sum_result/2,
  send_s9_sum_result/3,
  send_s12_diff_result/3,
  send_s12_diff_result/2]).

%% Types & records
-include("carol.hrl").
-export_type([state_data/0]).
-type state_data() :: #state_data{}.

-callback init(Args :: list()) -> {ok, s1, state_data(), [{next_event, internal, {first}}]}.
-callback s1(internal, {first}, state_data()) -> {next_state, s3, state_data()} | {next_state, s3, state_data(), [{next_event, internal, {first}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s3(internal, {second}, state_data()) -> {next_state, s7, state_data()} | {next_state, s7, state_data(), [{next_event, internal, {second}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s5(internal, {cancel}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s7(internal | cast, {diff} | {sum} | {pid(), {timeout}}, state_data()) -> {next_state, s11, state_data()} | {next_state, s5, state_data()} | {next_state, s8, state_data()} | {next_state, s11, state_data(), [{next_event, internal, {diff}}] } | {next_state, s11, state_data(), [{next_event, internal, {sum}}] } | {next_state, s5, state_data(), [{next_event, internal, {diff}}] } | {next_state, s5, state_data(), [{next_event, internal, {sum}}] } | {next_state, s8, state_data(), [{next_event, internal, {diff}}] } | {next_state, s8, state_data(), [{next_event, internal, {sum}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s8(cast, {pid(), {result_sum, {term()}}} | {pid(), {timeout}}, state_data()) -> {next_state, s5, state_data()} | {next_state, s9, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s9(internal, {sum_result}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s11(cast, {pid(), {result_diff, {term()}}} | {pid(), {timeout}}, state_data()) -> {next_state, s12, state_data()} | {next_state, s5, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s12(internal, {diff_result}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.

%% ===== API =====
-spec start_link(CallbackModule :: module(), Args :: list()) ->
    {ok, pid()} | {error, term()}.
start_link(CallbackModule, Args) ->
    case code:ensure_loaded(CallbackModule) of
        {module, CallbackModule} ->
            gen_statem:start_link({local, CallbackModule}, gen_carol, {CallbackModule, Args}, [{debug, [trace, {log_to_file, "carol_debug.log"}]}]);
        {error, Reason} ->
            {error, Reason}
    end.

-spec callback_mode() -> state_functions.
callback_mode() -> state_functions.

%% ===== gen_statem =====
-spec init({module(), list()}) ->
    {ok, s1, state_data(), [{next_event, internal, {first}}]}.
init({CallbackModule, _Args}) ->
    io:format("carol: Initializing with callback module ~p~n", [CallbackModule]),
    put(callback_module, CallbackModule),
    init_context(),
    CallbackModule:init([]).

%% ---------- State functions----------
-spec s1(internal, {first}, state_data()) -> {next_state, s3, state_data()} | {next_state, s3, state_data(), [{next_event, internal, {first}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s1(internal, {first}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s1(internal, {first}, Data),
    after_transition(Next);
s1(cast, {_From, _Msg, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_carol[s1]: Purging stale early-path event ~p~n", [_Msg]),
        {keep_state, Data};
      false ->
        io:format("gen_carol[s1]: Postponing early-path event ~p~n", [_Msg]),
        {keep_state, Data, [postpone]}
    end.

-spec s3(internal, {second}, state_data()) -> {next_state, s7, state_data()} | {next_state, s7, state_data(), [{next_event, internal, {second}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s3(internal, {second}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s3(internal, {second}, Data),
    after_transition(Next);
s3(cast, {_From, _Msg, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_carol[s3]: Purging stale early-path event ~p~n", [_Msg]),
        {keep_state, Data};
      false ->
        io:format("gen_carol[s3]: Postponing early-path event ~p~n", [_Msg]),
        {keep_state, Data, [postpone]}
    end.

-spec s5(internal, {cancel}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
s5(internal, {cancel}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s5(internal, {cancel}, Data),
    after_transition(Next);
s5(cast, {SrvPid, {timeout}, Path}, Data) ->
    case message_status(Path, branch_path(mc1, right)) of
      stale ->
        io:format("gen_carol[s5]: Purging stale interrupt ~p~n", [{timeout}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s7(cast, {SrvPid, {timeout}}, Data)
               catch error:function_clause ->
                 io:format("gen_carol[s5]: Callback had no interrupt clause for ~p, postponing~n", [{timeout}]),
                 {keep_state, Data, [postpone]}
               end,
        after_transition(commit_if_taken(Next, mc1, right));
      not_ready ->
        io:format("gen_carol[s5]: Postponing not-ready interrupt ~p~n", [{timeout}]),
        {keep_state, Data, [postpone]}
    end;
s5(cast, {_SrvPid, {result_sum, {Result}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_carol[s5]: Purging stale event ~p~n", [{result_sum, {Result}}]),
        {keep_state, Data};
      false ->
        io:format("gen_carol[s5]: Postponing event ~p~n", [{result_sum, {Result}}]),
        {keep_state, Data, [postpone]}
    end;
s5(cast, {_SrvPid, {result_diff, {Result}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_carol[s5]: Purging stale event ~p~n", [{result_diff, {Result}}]),
        {keep_state, Data};
      false ->
        io:format("gen_carol[s5]: Postponing event ~p~n", [{result_diff, {Result}}]),
        {keep_state, Data, [postpone]}
    end.

%% Mixed-choice entry state
-spec s7(internal | cast, {diff} | {sum} | {pid(), {timeout}, list()}, state_data()) -> {next_state, s11, state_data()} | {next_state, s5, state_data()} | {next_state, s8, state_data()} | {next_state, s11, state_data(), [{next_event, internal, {diff}}] } | {next_state, s11, state_data(), [{next_event, internal, {sum}}] } | {next_state, s5, state_data(), [{next_event, internal, {diff}}] } | {next_state, s5, state_data(), [{next_event, internal, {sum}}] } | {next_state, s8, state_data(), [{next_event, internal, {diff}}] } | {next_state, s8, state_data(), [{next_event, internal, {sum}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s7(internal, {sum}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s7(internal, {sum}, Data),
    after_transition(Next);
s7(internal, {diff}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s7(internal, {diff}, Data),
    after_transition(Next);
s7(cast, {SrvPid, {timeout}, Path}, Data) ->
    case message_status(Path, branch_path(mc1, right)) of
      stale ->
        io:format("gen_carol[s7]: Purging stale event ~p~n", [{timeout}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s7(cast, {SrvPid, {timeout}}, Data)
               catch error:function_clause ->
                 io:format("gen_carol[s7]: Callback had no clause for ~p, postponing~n", [{timeout}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {next_state, s5, _} -> after_transition(commit_if_taken(Next, mc1, right));
          {next_state, s5, _, _} -> after_transition(commit_if_taken(Next, mc1, right));
          _ -> after_transition(Next)
        end;
      not_ready ->
        io:format("gen_carol[s7]: Postponing not-ready event ~p~n", [{timeout}]),
        {keep_state, Data, [postpone]}
    end;
s7(cast, {_SrvPid, {result_sum, {Result}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_carol[s7]: Purging stale event ~p~n", [{result_sum, {Result}}]),
        {keep_state, Data};
      false ->
        io:format("gen_carol[s7]: Postponing event ~p~n", [{result_sum, {Result}}]),
        {keep_state, Data, [postpone]}
    end;
s7(cast, {_SrvPid, {result_diff, {Result}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_carol[s7]: Purging stale event ~p~n", [{result_diff, {Result}}]),
        {keep_state, Data};
      false ->
        io:format("gen_carol[s7]: Postponing event ~p~n", [{result_diff, {Result}}]),
        {keep_state, Data, [postpone]}
    end.

-spec s8(cast, {pid(), {timeout}, list()} | {pid(), {result_sum, {term()}}, list()}, state_data()) -> {next_state, s5, state_data()} | {next_state, s9, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
s8(cast, {SrvPid, {result_sum, {Result}}, Path}, Data) ->
    case message_status(Path, current_path()) of
      stale ->
        io:format("gen_carol[s8]: Purging stale event ~p~n", [{result_sum, {Result}}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s8(cast, {SrvPid, {result_sum, {Result}}}, Data)
               catch error:function_clause ->
                 io:format("gen_carol[s8]: Callback had no clause for ~p, postponing~n", [{result_sum, {Result}}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> after_transition(Next)
        end;
      not_ready ->
        io:format("gen_carol[s8]: Postponing not-ready event ~p~n", [{result_sum, {Result}}]),
        {keep_state, Data, [postpone]}
    end;
s8(cast, {SrvPid, {timeout}, Path}, Data) ->
    case message_status(Path, branch_path(mc1, right)) of
      stale ->
        io:format("gen_carol[s8]: Purging stale event ~p~n", [{timeout}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s8(cast, {SrvPid, {timeout}}, Data)
               catch error:function_clause ->
                 io:format("gen_carol[s8]: Callback had no clause for ~p, postponing~n", [{timeout}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {next_state, s5, _} -> after_transition(commit_if_taken(Next, mc1, right));
          {next_state, s5, _, _} -> after_transition(commit_if_taken(Next, mc1, right));
          _ -> after_transition(Next)
        end;
      not_ready ->
        io:format("gen_carol[s8]: Postponing not-ready event ~p~n", [{timeout}]),
        {keep_state, Data, [postpone]}
    end;
s8(cast, {_SrvPid, {result_diff, {Result}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_carol[s8]: Purging stale event ~p~n", [{result_diff, {Result}}]),
        {keep_state, Data};
      false ->
        io:format("gen_carol[s8]: Postponing event ~p~n", [{result_diff, {Result}}]),
        {keep_state, Data, [postpone]}
    end.

-spec s9(internal, {sum_result}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
s9(internal, {sum_result}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s9(internal, {sum_result}, Data),
    after_transition(Next);
s9(cast, {SrvPid, {timeout}, Path}, Data) ->
    case message_status(Path, branch_path(mc1, right)) of
      stale ->
        io:format("gen_carol[s9]: Purging stale interrupt ~p~n", [{timeout}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s7(cast, {SrvPid, {timeout}}, Data)
               catch error:function_clause ->
                 io:format("gen_carol[s9]: Callback had no interrupt clause for ~p, postponing~n", [{timeout}]),
                 {keep_state, Data, [postpone]}
               end,
        after_transition(commit_if_taken(Next, mc1, right));
      not_ready ->
        io:format("gen_carol[s9]: Postponing not-ready interrupt ~p~n", [{timeout}]),
        {keep_state, Data, [postpone]}
    end;
s9(cast, {_SrvPid, {result_sum, {Result}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_carol[s9]: Purging stale event ~p~n", [{result_sum, {Result}}]),
        {keep_state, Data};
      false ->
        io:format("gen_carol[s9]: Postponing event ~p~n", [{result_sum, {Result}}]),
        {keep_state, Data, [postpone]}
    end;
s9(cast, {_SrvPid, {result_diff, {Result}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_carol[s9]: Purging stale event ~p~n", [{result_diff, {Result}}]),
        {keep_state, Data};
      false ->
        io:format("gen_carol[s9]: Postponing event ~p~n", [{result_diff, {Result}}]),
        {keep_state, Data, [postpone]}
    end.

-spec s11(cast, {pid(), {timeout}, list()} | {pid(), {result_diff, {term()}}, list()}, state_data()) -> {next_state, s12, state_data()} | {next_state, s5, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
s11(cast, {SrvPid, {result_diff, {Result}}, Path}, Data) ->
    case message_status(Path, current_path()) of
      stale ->
        io:format("gen_carol[s11]: Purging stale event ~p~n", [{result_diff, {Result}}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s11(cast, {SrvPid, {result_diff, {Result}}}, Data)
               catch error:function_clause ->
                 io:format("gen_carol[s11]: Callback had no clause for ~p, postponing~n", [{result_diff, {Result}}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> after_transition(Next)
        end;
      not_ready ->
        io:format("gen_carol[s11]: Postponing not-ready event ~p~n", [{result_diff, {Result}}]),
        {keep_state, Data, [postpone]}
    end;
s11(cast, {SrvPid, {timeout}, Path}, Data) ->
    case message_status(Path, branch_path(mc1, right)) of
      stale ->
        io:format("gen_carol[s11]: Purging stale event ~p~n", [{timeout}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s11(cast, {SrvPid, {timeout}}, Data)
               catch error:function_clause ->
                 io:format("gen_carol[s11]: Callback had no clause for ~p, postponing~n", [{timeout}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {next_state, s5, _} -> after_transition(commit_if_taken(Next, mc1, right));
          {next_state, s5, _, _} -> after_transition(commit_if_taken(Next, mc1, right));
          _ -> after_transition(Next)
        end;
      not_ready ->
        io:format("gen_carol[s11]: Postponing not-ready event ~p~n", [{timeout}]),
        {keep_state, Data, [postpone]}
    end;
s11(cast, {_SrvPid, {result_sum, {Result}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_carol[s11]: Purging stale event ~p~n", [{result_sum, {Result}}]),
        {keep_state, Data};
      false ->
        io:format("gen_carol[s11]: Postponing event ~p~n", [{result_sum, {Result}}]),
        {keep_state, Data, [postpone]}
    end.

-spec s12(internal, {diff_result}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
s12(internal, {diff_result}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s12(internal, {diff_result}, Data),
    after_transition(Next);
s12(cast, {SrvPid, {timeout}, Path}, Data) ->
    case message_status(Path, branch_path(mc1, right)) of
      stale ->
        io:format("gen_carol[s12]: Purging stale interrupt ~p~n", [{timeout}]),
        {keep_state, Data};
      ready ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s7(cast, {SrvPid, {timeout}}, Data)
               catch error:function_clause ->
                 io:format("gen_carol[s12]: Callback had no interrupt clause for ~p, postponing~n", [{timeout}]),
                 {keep_state, Data, [postpone]}
               end,
        after_transition(commit_if_taken(Next, mc1, right));
      not_ready ->
        io:format("gen_carol[s12]: Postponing not-ready interrupt ~p~n", [{timeout}]),
        {keep_state, Data, [postpone]}
    end;
s12(cast, {_SrvPid, {result_sum, {Result}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_carol[s12]: Purging stale event ~p~n", [{result_sum, {Result}}]),
        {keep_state, Data};
      false ->
        io:format("gen_carol[s12]: Postponing event ~p~n", [{result_sum, {Result}}]),
        {keep_state, Data, [postpone]}
    end;
s12(cast, {_SrvPid, {result_diff, {Result}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_carol[s12]: Purging stale event ~p~n", [{result_diff, {Result}}]),
        {keep_state, Data};
      false ->
        io:format("gen_carol[s12]: Postponing event ~p~n", [{result_diff, {Result}}]),
        {keep_state, Data, [postpone]}
    end.


%% ---------- Send helpers----------

-spec send_s1_first(SrvPid :: pid(), term(), _Data :: state_data()) -> ok.
send_s1_first(SrvPid, Number, _Data) ->
    gen_statem:cast(SrvPid, {self(), {first, {Number}}}).


-spec send_s1_first(SrvPid :: pid(), _Data :: state_data()) -> ok.
send_s1_first(SrvPid, _Data) ->
    gen_statem:cast(SrvPid, {self(), {first}}).


-spec send_s3_second(SrvPid :: pid(), term(), _Data :: state_data()) -> ok.
send_s3_second(SrvPid, Number, _Data) ->
    gen_statem:cast(SrvPid, {self(), {second, {Number}}}).


-spec send_s3_second(SrvPid :: pid(), _Data :: state_data()) -> ok.
send_s3_second(SrvPid, _Data) ->
    gen_statem:cast(SrvPid, {self(), {second}}).


-spec send_s5_cancel(AlicePid :: pid(), _Data :: state_data()) -> ok.
send_s5_cancel(AlicePid, _Data) ->
    Path = current_path(),
    gen_statem:cast(AlicePid, {self(), {cancel}, Path}).


-spec send_s7_sum(SrvPid :: pid(), _Data :: state_data()) -> ok.
send_s7_sum(SrvPid, _Data) ->
    Path = branch_path(mc1, left),
    set_current_path(Path),
    gen_statem:cast(SrvPid, {self(), {sum}, Path}).


-spec send_s7_diff(SrvPid :: pid(), _Data :: state_data()) -> ok.
send_s7_diff(SrvPid, _Data) ->
    Path = branch_path(mc1, left),
    set_current_path(Path),
    gen_statem:cast(SrvPid, {self(), {diff}, Path}).


-spec send_s9_sum_result(AlicePid :: pid(), _Data :: state_data()) -> ok.
send_s9_sum_result(AlicePid, _Data) ->
    Path = current_path(),
    gen_statem:cast(AlicePid, {self(), {sum_result}, Path}).


-spec send_s9_sum_result(AlicePid :: pid(), term(), _Data :: state_data()) -> ok.
send_s9_sum_result(AlicePid, Result, _Data) ->
    Path = current_path(),
    gen_statem:cast(AlicePid, {self(), {sum_result, {Result}}, Path}).


-spec send_s12_diff_result(AlicePid :: pid(), term(), _Data :: state_data()) -> ok.
send_s12_diff_result(AlicePid, Result, _Data) ->
    Path = current_path(),
    gen_statem:cast(AlicePid, {self(), {diff_result, {Result}}, Path}).


-spec send_s12_diff_result(AlicePid :: pid(), _Data :: state_data()) -> ok.
send_s12_diff_result(AlicePid, _Data) ->
    Path = current_path(),
    gen_statem:cast(AlicePid, {self(), {diff_result}, Path}).


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

after_transition({next_state, s7, _} = Next) -> enter_mc(mc1), Next;
after_transition({next_state, s7, _, _} = Next) -> enter_mc(mc1), Next;
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

