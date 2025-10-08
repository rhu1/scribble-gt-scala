-module(gen_b).
-behaviour(gen_statem).

-export([init/1,
  callback_mode/0,
  code_change/4,
  terminate/3,
  start_link/2,
  send_s5_TOa/2,
  s5/3,
  send_s6_a3/2,
  s6/3,
  send_s7_a4/2,
  s7/3,
  send_s3_TOc/2,
  s3/3]).

-include("b.hrl").
-type state_data() :: #state_data{mc_counter_1 :: integer(), a_pid :: pid() | undefined, c_pid :: pid() | undefined}.

%% ---- Mixed Choice identifier ----
-define(MC1, mc1).

%% ---- Callback contracts ----
-callback s3(EventType :: term(), {atom()}, state_data()) -> {stop, normal, state_data()}.
-callback s5(EventType :: term(), {atom()} | {pid(), {term()}}, state_data()) ->
  {next_state, s3, state_data(), [{next_event, internal, {'TOc'}}]} |
  {keep_state, state_data()} |
  {keep_state, state_data(), [postpone]} |
  {next_state, s6, state_data(), [{next_event, internal, {a3}}]}.
-callback s6(EventType :: term(), {atom()}, state_data()) ->
  {next_state, s7, state_data(), [{next_event, internal, {a4}}]} |
  {keep_state, state_data()}.
-callback s7(EventType :: term(), {atom()}, state_data()) -> {stop, normal, state_data()}.
-callback init(Args :: list()) ->
  {ok, s5, state_data(), [{next_event, internal, {'TOa'}}]}.

-spec start_link(CallbackModule :: module(), Args :: list()) ->
  {ok, pid()} | {error, term()}.
start_link(CallbackModule, Args) ->
  case code:ensure_loaded(CallbackModule) of
    {module, CallbackModule} ->
      gen_statem:start_link({local, CallbackModule}, gen_b, {CallbackModule, Args}, [{debug, [trace, {log_to_file, "b_debug.log"}]}]);
    {error, Reason} ->
      {error, Reason}
  end.

-spec callback_mode() -> state_functions.
callback_mode() -> state_functions.

-spec init({CallbackModule :: module(), Args :: list()}) ->
  {ok, s5, state_data(), [{next_event, internal, {'TOa'}}]}.
init({CallbackModule, _Args}) ->
  io:format("b: Initializing with callback module ~p~n", [CallbackModule]),
  put(callback_module, CallbackModule),
  put(commit_map, #{}),
  CallbackModule:init([]).

%% -------- GC helpers: commit stack, stale check, current path --------
get_commit() ->
  case get(commit_map) of
    undefined -> #{};
    M -> M
  end.

set_commit(M) -> put(commit_map, M), M.

%% Push a new activation side for MC1 (recursion-safe)
-spec commit_entry(atom(), left | right) -> map().
commit_entry(McId, Side) when Side =:= left; Side =:= right ->
  Stack0 = maps:get(McId, get_commit(), []),
  Stack1 = [Side | Stack0],
  set_commit(maps:put(McId, Stack1, get_commit())).

%% Purge rule:
%% - older: message has fewer {?MC1,_} than our stack
%% - same depth: last incoming side != our current side
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

%% Build π with repeated tags (oldest -> newest per MC)
-spec current_path() -> [{atom(), left | right}].
current_path() ->
  Commit = get_commit(),
  maps:fold(
    fun(Mc, Sides, Acc) ->
      OldestFirst = lists:reverse(Sides),
      Acc ++ [ {Mc, Side} || Side <- OldestFirst ]
    end, [], Commit).

%% -------- State s3 --------
-spec s3(EventType :: term(), {atom()}, state_data()) -> {stop, normal, state_data()}.
s3(EventType, {'TOc'}, Data) ->
  commit_entry(?MC1, left),
  CallbackModule = get(callback_module),
  CallbackModule:s3(EventType, {'TOc'}, Data).

%% -------- State s5 --------
-spec s5(EventType :: term(), {atom()} | {pid(), {term()}, list()}, state_data()) ->
  {next_state, s3, state_data(), [{next_event, internal, {'TOc'}}]} |
  {keep_state, state_data()} |
  {keep_state, state_data(), [postpone]} |
  {next_state, s6, state_data(), [{next_event, internal, {a3}}]}.
s5(EventType, {'TOa'}, Data) ->
  CallbackModule = get(callback_module),
  CallbackModule:s5(EventType, {'TOa'}, Data);
s5(EventType, {APid, {a1}, Pi}, Data) ->
  case stale(Pi) of
    true ->
      io:format("gen_b[s5]: Purging stale event ~p~n", [[a1]]),
      {keep_state, Data};
    false ->
      CallbackModule = get(callback_module),
      CallbackModule:s5(EventType, {APid, {a1}}, Data)
  end.

%% -------- State s6 --------
-spec s6(EventType :: term(), {atom()}, state_data()) ->
  {next_state, s7, state_data(), [{next_event, internal, {a4}}]} |
  {keep_state, state_data()}.
s6(EventType, {a3}, Data) ->
  commit_entry(?MC1, right),
  CallbackModule = get(callback_module),
  CallbackModule:s6(EventType, {a3}, Data).

%% -------- State s7 --------
-spec s7(EventType :: term(), {atom()}, state_data()) -> {stop, normal, state_data()}.
s7(EventType, {a4}, Data) ->
  CallbackModule = get(callback_module),
  CallbackModule:s7(EventType, {a4}, Data).

%% -------- Send helpers --------
-spec send_s5_TOa(APid :: pid(), Data :: state_data()) -> ok.
send_s5_TOa(APid, _Data) ->
  Path = current_path(),
  gen_statem:cast(APid, {self(), {'TOa'}, Path}).

-spec send_s3_TOc(CPid :: pid(), _Data :: state_data()) -> ok.
send_s3_TOc(CPid, _Data) ->
  Path = current_path(),
  gen_statem:cast(CPid, {self(), {'TOc'}, Path}).

-spec send_s7_a4(APid :: pid(), _Data :: state_data()) -> ok.
send_s7_a4(APid, _Data) ->
  Path = current_path(),
  gen_statem:cast(APid, {self(), {a4}, Path}).

-spec send_s6_a3(CPid :: pid(), _Data :: state_data()) -> ok.
send_s6_a3(CPid, _Data) ->
  Path = current_path(),
  gen_statem:cast(CPid, {self(), {a3}, Path}).

-spec code_change(OldVsn :: term(), StateName :: atom(), StateData :: state_data(), Extra :: term()) ->
  {ok, state_data()}.
code_change(_Vsn, _StateName, StateData, _Extra) -> {ok, StateData}.

-spec terminate(Reason :: term(), State :: atom(), Data :: state_data()) -> ok.
terminate(_Reason, _State, _StateData) -> ok.
