-module(gen_c).
-behaviour(gen_statem).

-export([init/1,
  callback_mode/0,
  code_change/4,
  terminate/3,
  start_link/2,
  s4/3,
  s5/3,
  send_s6_a5/2,
  s6/3]).

-include("c.hrl").
-type state_data() :: #state_data{mc_counter_1 :: integer(), a_pid :: pid() | undefined, b_pid :: pid() | undefined}.

%% ---- Mixed Choice identifier ----
-define(MC1, mc1).

%% ---- Callback contracts ----
-callback s4(EventType :: term(), {pid(), {term()}}, state_data()) ->
  {next_state, s5, state_data()} | {keep_state, state_data(), [postpone]} | {stop, normal, state_data()}.
-callback s5(term(), {pid(), {atom(), term()}}, state_data()) ->
  {keep_state, state_data(), [postpone]} | {stop, normal, state_data()} | {next_state, s6, state_data(), [{next_event, internal, {a5}}]} | {keep_state, state_data()}.
-callback s6(EventType :: term(), {atom()}, state_data()) -> {stop, normal, state_data()}.
-callback init(Args :: list()) ->
  {ok, s4, state_data()}.

%% ---- OTP boilerplate ----
-spec start_link(CallbackModule :: module(), Args :: list()) ->
  {ok, pid()} | {error, term()}.
start_link(CallbackModule, Args) ->
  case code:ensure_loaded(CallbackModule) of
    {module, CallbackModule} ->
      gen_statem:start_link({local, CallbackModule}, gen_c, {CallbackModule, Args}, [{debug, [trace, {log_to_file, "c_debug.log"}]}]);
    {error, Reason} ->
      {error, Reason}
  end.

-spec callback_mode() -> state_functions.
callback_mode() -> state_functions.

-spec init({CallbackModule :: module(), Args :: list()}) ->
  {ok, s4, state_data()}.
init({CallbackModule, _Args}) ->
  io:format("c: Initializing with callback module ~p~n", [CallbackModule]),
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

%% ---- Path builder ----
-spec current_path() -> [{atom(), left | right}].
current_path() ->
  Commit = get_commit(),
  maps:fold(
    fun(Mc, Sides, Acc) ->
      OldestFirst = lists:reverse(Sides),
      Acc ++ [{Mc, Side} || Side <- OldestFirst]
    end, [], Commit).

%% -------- State s4 (entry MC, both branches via recv) --------
-spec s4(EventType :: term(), {pid(), {term()}, list()}, state_data()) ->
  {next_state, s5, state_data()} | {keep_state, state_data(), [postpone]} | {stop, normal, state_data()}.
%% Recv a2 (LEFT): stale-first, delegate, commit LEFT if transitioning
s4(EventType, {APid, {a2}, Pi}, Data) ->
  case stale(Pi) of
    true ->
      io:format("gen_c[s4]: Purging stale event ~p~n", [[a2]]),
      {keep_state, Data};
    false ->
      CallbackModule = get(callback_module),
      Next = CallbackModule:s4(EventType, {APid, {a2}}, Data),
      case Next of
        {next_state, s5, _}    -> commit_entry(?MC1, left), Next;
        {next_state, s5, _, _} -> commit_entry(?MC1, left), Next;
        _                      -> Next
      end
  end;
%% Recv TOc (RIGHT): stale-first, delegate, commit RIGHT if transitioning
s4(EventType, {BPid, {'TOc'}, Pi}, Data) ->
  case stale(Pi) of
    true ->
      io:format("gen_c[s4]: Purging stale event ~p~n", [['TOc']]),
      {keep_state, Data};
    false ->
      CallbackModule = get(callback_module),
      Next = CallbackModule:s4(EventType, {BPid, {'TOc'}}, Data),
      case Next of
        {next_state, s5, _}    -> commit_entry(?MC1, right), Next;
        {next_state, s5, _, _} -> commit_entry(?MC1, right), Next;
        _                      -> Next
      end
  end.

%% -------- State s5 --------
-spec s5(term(), {pid(), {atom(), term()}, list()}, state_data()) ->
  {keep_state, state_data(), [postpone]} | {stop, normal, state_data()} | {next_state, s6, state_data(), [{next_event, internal, {a5}}]} | {keep_state, state_data()}.
%% Incoming TOc or a3: stale-first then delegate
s5(EventType, {BPid, {'TOc'}, Pi}, Data) ->
  case stale(Pi) of
    true ->
      io:format("gen_c[s5]: Purging stale event ~p~n", [['TOc']]),
      {keep_state, Data};
    false ->
      CallbackModule = get(callback_module),
      CallbackModule:s5(EventType, {BPid, {'TOc'}}, Data)
  end;
s5(EventType, {BPid, {a3}, Pi}, Data) ->
  case stale(Pi) of
    true ->
      io:format("gen_c[s5]: Purging stale event ~p~n", [[a3]]),
      {keep_state, Data};
    false ->
      CallbackModule = get(callback_module),
      CallbackModule:s5(EventType, {BPid, {a3}}, Data)
  end.

%% -------- State s6 --------
-spec s6(EventType :: term(), {atom()}, state_data()) -> {stop, normal, state_data()}.
s6(EventType, {a5}, Data) ->
  CallbackModule = get(callback_module),
  CallbackModule:s6(EventType, {a5}, Data).

%% -------- Send helpers --------
-spec send_s6_a5(APid :: pid(), _Data :: state_data()) -> ok.
send_s6_a5(APid, _Data) ->
  Path = current_path(),
  gen_statem:cast(APid, {self(), {a5}, Path}).

%% ---- OTP misc ----
-spec code_change(OldVsn :: term(), StateName :: atom(), StateData :: state_data(), Extra :: term()) ->
  {ok, state_data()}.
code_change(_Vsn, _StateName, StateData, _Extra) -> {ok, StateData}.

-spec terminate(Reason :: term(), State :: atom(), Data :: state_data()) -> ok.
terminate(_Reason, _State, _StateData) -> ok.
