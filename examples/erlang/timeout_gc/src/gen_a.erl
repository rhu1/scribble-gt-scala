-module(gen_a).
-behaviour(gen_statem).

-export([init/1,
  callback_mode/0,
  code_change/4,
  terminate/3,
  start_link/2,
  send_s4_a1/2,
  s4/3,
  send_s5_a2/2,
  s5/3,
  s6/3,
  s7/3]).

-include("a.hrl").
-type state_data() :: #state_data{mc_counter_1 :: integer(), b_pid :: pid() | undefined, c_pid :: pid() | undefined}.

%% ---- Mixed Choice identifier ----
-define(MC1, mc1).

%% ---- Callback contracts ----
-callback s4(EventType :: term(), {pid(), {term()} | {atom()}}, state_data()) ->
  {next_state, s5, state_data()} | {keep_state, state_data(), [postpone]} | {stop, normal, state_data()}.
-callback s5(EventType :: term(), {atom()} | {pid(), {term()}}, state_data()) ->
  {next_state, s6, state_data()} | {keep_state, state_data(), [postpone]} | {stop, normal, state_data()}.
-callback s6(term(), {pid(), {atom(), term()}}, state_data()) ->
  {keep_state, state_data(), [postpone]} | {next_state, s7, state_data()} | {stop, normal, state_data()}.
-callback s7(term(), {pid(), {atom(), term()}}, state_data()) ->
  {keep_state, state_data(), [postpone]} | {stop, normal, state_data()}.
-callback init(Args :: list()) ->
  {ok, s4, state_data(), [{next_event, internal, {a1}}]}.

%% ---- OTP boilerplate ----
-spec start_link(CallbackModule :: module(), Args :: list()) ->
  {ok, pid()} | {error, term()}.
start_link(CallbackModule, Args) ->
  case code:ensure_loaded(CallbackModule) of
    {module, CallbackModule} ->
      gen_statem:start_link({local, CallbackModule}, gen_a, {CallbackModule, Args}, [{debug, [trace, {log_to_file, "a_debug.log"}]}]);
    {error, Reason} ->
      {error, Reason}
  end.

-spec callback_mode() -> state_functions.
callback_mode() -> state_functions.

-spec init({CallbackModule :: module(), Args :: list()}) ->
  {ok, s4, state_data(), [{next_event, internal, {a1}}]}.
init({CallbackModule, _Args}) ->
  io:format("a: Initializing with callback module ~p~n", [CallbackModule]),
  put(callback_module, CallbackModule),
  put(commit_map, #{}),
  CallbackModule:init([]).

%% ---- GC helpers (stacked commits & stale) ----
get_commit() -> case get(commit_map) of undefined -> #{}; M -> M end.
set_commit(M) -> put(commit_map, M), M.

-spec commit_entry(atom(), left | right) -> map().
commit_entry(McId, Side) when Side =:= left; Side =:= right ->
  Stack0 = maps:get(McId, get_commit(), []),
  Stack1 = [Side | Stack0],
  set_commit(maps:put(McId, Stack1, get_commit())).

-spec stale([{atom(), left | right}]) -> boolean().
stale(Path) when is_list(Path) ->
  Commit = get_commit(),
  McGroups = lists:foldl(
    fun({Mc,Side}, Acc) ->
      case maps:find(Mc, Acc) of
        {ok, L} -> maps:put(Mc, [Side|L], Acc);
        error   -> maps:put(Mc, [Side], Acc)
      end
    end, #{}, Path),
  maps:fold(
    fun(Mc, InSidesRev, Acc) ->
      InCount   = length(InSidesRev),
      Local     = maps:get(Mc, Commit, []),
      LocCount  = length(Local),
      Acc orelse
        (InCount < LocCount) orelse
        ((InCount =:= LocCount) andalso
          case Local of
            [CurSide | _] ->
              InLast = hd(InSidesRev),
              InLast =/= CurSide;
            [] -> false
          end)
    end, false, McGroups).

%% ---- Path builders ----
-spec current_path() -> [{atom(), left | right}].
current_path() ->
  Commit = get_commit(),
  maps:fold(
    fun(Mc, Sides, Acc) ->
      OldestFirst = lists:reverse(Sides),
      Acc ++ [{Mc, Side} || Side <- OldestFirst]
    end, [], Commit).

-spec current_path_plus([{atom(), left | right}]) -> [{atom(), left | right}].
current_path_plus(Extra) ->
  current_path() ++ Extra.

%% -------- State s4 (entry MC) --------
-spec s4(EventType :: term(), {pid(), {term()}, list()} | {atom()}, state_data()) ->
  {next_state, s5, state_data()} | {keep_state, state_data(), [postpone]} | {stop, normal, state_data()}.
s4(_EventType, {_Pid, {a4}, _Pi}, Data) ->
  io:format("gen_a[s4]: Postponing future event ~p~n", [[a4]]),
  {keep_state, Data, [postpone]};
s4(_EventType, {_Pid, {a5}, _Pi}, Data) ->
  io:format("gen_a[s4]: Postponing future event ~p~n", [[a5]]),
  {keep_state, Data, [postpone]};
%% Internal a1 (LEFT): delegate, then commit LEFT if transitioning
s4(EventType, {a1}, Data) ->
  CallbackModule = get(callback_module),
  Next = CallbackModule:s4(EventType, {a1}, Data),
  case Next of
    {next_state, s5, _}      -> commit_entry(?MC1, left), Next;
    {next_state, s5, _, _}   -> commit_entry(?MC1, left), Next;
    _                        -> Next
  end;
%% Recv TOa (RIGHT): stale-first, delegate, then commit RIGHT if transitioning
s4(EventType, {BPid, {'TOa'}, Pi}, Data) ->
  case stale(Pi) of
    true ->
      io:format("gen_a[s4]: Purging stale event ~p~n", [['TOa']]),
      {keep_state, Data};
    false ->
      CallbackModule = get(callback_module),
      Next = CallbackModule:s4(EventType, {BPid, {'TOa'}}, Data),
      case Next of
        {next_state, s5, _}    -> commit_entry(?MC1, right), Next;
        {next_state, s5, _, _} -> commit_entry(?MC1, right), Next;
        _                      -> Next
      end
  end.

%% -------- State s5 --------
-spec s5(EventType :: term(), {atom()} | {pid(), {term()}, list()}, state_data()) ->
  {next_state, s6, state_data()} | {keep_state, state_data(), [postpone]} | {stop, normal, state_data()}.
s5(_EventType, {_Pid, {a4}, _Pi}, Data) ->
  io:format("gen_a[s5]: Postponing future event ~p~n", [[a4]]),
  {keep_state, Data, [postpone]};
s5(_EventType, {_Pid, {a5}, _Pi}, Data) ->
  io:format("gen_a[s5]: Postponing future event ~p~n", [[a5]]),
  {keep_state, Data, [postpone]};
s5(EventType, {a2}, Data) ->
  CallbackModule = get(callback_module),
  CallbackModule:s5(EventType, {a2}, Data);
%% Optionally receive late TOa: stale-first then delegate
s5(EventType, {BPid, {'TOa'}, Pi}, Data) ->
  case stale(Pi) of
    true ->
      io:format("gen_a[s5]: Purging stale event ~p~n", [['TOa']]),
      {keep_state, Data};
    false ->
      CallbackModule = get(callback_module),
      CallbackModule:s5(EventType, {BPid, {'TOa'}}, Data)
  end.

%% -------- State s6 --------
-spec s6(term(), {pid(), {atom(), term()}, list()}, state_data()) ->
  {keep_state, state_data(), [postpone]} | {next_state, s7, state_data()} | {stop, normal, state_data()}.
s6(_EventType, {_Pid, {a5}, _Pi}, Data) ->
  io:format("gen_a[s6]: Postponing future event ~p~n", [[a5]]),
  {keep_state, Data, [postpone]};
s6(EventType, {BPid, {a4}, Pi}, Data) ->
  case stale(Pi) of
    true ->
      io:format("gen_a[s6]: Purging stale event ~p~n", [[a4]]),
      {keep_state, Data};
    false ->
      CallbackModule = get(callback_module),
      CallbackModule:s6(EventType, {BPid, {a4}}, Data)
  end;
s6(EventType, {BPid, {'TOa'}, Pi}, Data) ->
  case stale(Pi) of
    true ->
      io:format("gen_a[s6]: Purging stale event ~p~n", [['TOa']]),
      {keep_state, Data};
    false ->
      CallbackModule = get(callback_module),
      CallbackModule:s6(EventType, {BPid, {'TOa'}}, Data)
  end.

%% -------- State s7 --------
-spec s7(term(), {pid(), {atom(), term()}, list()}, state_data()) ->
  {keep_state, state_data(), [postpone]} | {stop, normal, state_data()}.
s7(EventType, {CPid, {a5}, Pi}, Data) ->
  case stale(Pi) of
    true ->
      io:format("gen_a[s7]: Purging stale event ~p~n", [[a5]]),
      {keep_state, Data};
    false ->
      CallbackModule = get(callback_module),
      CallbackModule:s7(EventType, {CPid, {a5}}, Data)
  end.

%% -------- Send helpers --------
-spec send_s5_a2(CPid :: pid(), Data :: state_data()) -> ok.
send_s5_a2(CPid, _Data) ->
  Path = current_path(),
  gen_statem:cast(CPid, {self(), {a2}, Path}).

%% Deciding-state send: tag LEFT immediately
-spec send_s4_a1(BPid :: pid(), _Data :: state_data()) -> ok.
send_s4_a1(BPid, _Data) ->
  Path = current_path_plus([{?MC1, left}]),
  gen_statem:cast(BPid, {self(), {a1}, Path}).

%% ---- OTP misc ----
-spec code_change(OldVsn :: term(), StateName :: atom(), StateData :: state_data(), Extra :: term()) ->
  {ok, state_data()}.
code_change(_Vsn, _StateName, StateData, _Extra) -> {ok, StateData}.

-spec terminate(Reason :: term(), State :: atom(), Data :: state_data()) -> ok.
terminate(_Reason, _State, _StateData) -> ok.
