
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
    set_commit(#{}),
    CallbackModule:init([]).

%% ---------- State functions----------
-spec s1(internal, {first}, state_data()) -> {next_state, s3, state_data()} | {next_state, s3, state_data(), [{next_event, internal, {first}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s1(internal, {first}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s1(internal, {first}, Data),
        Next;
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
        Next;
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
        Next;
s5(cast, {_SrvPid, {timeout}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_carol[s5]: Purging stale event ~p~n", [{timeout}]),
        {keep_state, Data};
      false ->
        io:format("gen_carol[s5]: Postponing event ~p~n", [{timeout}]),
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
        Next;
s7(cast, {SrvPid, {timeout}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_carol[s7]: Purging stale event ~p~n", [{timeout}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s7(cast, {SrvPid, {timeout}}, Data)
               catch error:function_clause ->
                 io:format("gen_carol[s7]: Callback had no clause for ~p, postponing~n", [{timeout}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {next_state, s8, _} -> commit_entry(mc1, right), Next;
          {next_state, s8, _, _} -> commit_entry(mc1, right), Next;
          {next_state, s5, _} -> commit_entry(mc1, left), Next;
          {next_state, s5, _, _} -> commit_entry(mc1, left), Next;
          _ -> Next
        end
    end;
s7(internal, {diff}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s7(internal, {diff}, Data),
        Next;
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
s8(cast, {SrvPid, {timeout}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_carol[s8]: Purging stale event ~p~n", [{timeout}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s8(cast, {SrvPid, {timeout}}, Data)
               catch error:function_clause ->
                 io:format("gen_carol[s8]: Callback had no clause for ~p, postponing~n", [{timeout}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> Next
        end
    end;
s8(cast, {SrvPid, {result_sum, {Result}}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_carol[s8]: Purging stale event ~p~n", [{result_sum, {Result}}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s8(cast, {SrvPid, {result_sum, {Result}}}, Data)
               catch error:function_clause ->
                 io:format("gen_carol[s8]: Callback had no clause for ~p, postponing~n", [{result_sum, {Result}}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> Next
        end
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
        Next;
s9(cast, {_SrvPid, {timeout}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_carol[s9]: Purging stale event ~p~n", [{timeout}]),
        {keep_state, Data};
      false ->
        io:format("gen_carol[s9]: Postponing event ~p~n", [{timeout}]),
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
    case stale(Path) of
      true ->
        io:format("gen_carol[s11]: Purging stale event ~p~n", [{result_diff, {Result}}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s11(cast, {SrvPid, {result_diff, {Result}}}, Data)
               catch error:function_clause ->
                 io:format("gen_carol[s11]: Callback had no clause for ~p, postponing~n", [{result_diff, {Result}}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> Next
        end
    end;
s11(cast, {SrvPid, {timeout}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_carol[s11]: Purging stale event ~p~n", [{timeout}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s11(cast, {SrvPid, {timeout}}, Data)
               catch error:function_clause ->
                 io:format("gen_carol[s11]: Callback had no clause for ~p, postponing~n", [{timeout}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> Next
        end
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
        Next;
s12(cast, {_SrvPid, {timeout}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_carol[s12]: Purging stale event ~p~n", [{timeout}]),
        {keep_state, Data};
      false ->
        io:format("gen_carol[s12]: Postponing event ~p~n", [{timeout}]),
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
    Path = current_path(),
    gen_statem:cast(SrvPid, {self(), {sum}, Path}).


-spec send_s7_diff(SrvPid :: pid(), _Data :: state_data()) -> ok.
send_s7_diff(SrvPid, _Data) ->
    Path = current_path(),
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

