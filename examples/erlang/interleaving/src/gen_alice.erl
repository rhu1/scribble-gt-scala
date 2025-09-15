-module(gen_alice).
-behaviour(gen_statem).

-export([init/1,
  callback_mode/0,
  code_change/4,
  terminate/3,
  start_link/2,
  send_s1_ping/2,
  s1/3,
  s3/3
]).

-include("alice.hrl").
-type state_data() :: #state_data{alice_pid :: pid() | undefined, carol_pid :: pid() | undefined}.

-callback s3(term(), {pid(), {atom(), term()}}, state_data()) -> {keep_state, state_data(), [postpone]} | {stop, normal, state_data()}.
-callback s1(EventType :: term(), {atom()}, state_data()) -> {next_state, s3, state_data()}.
-callback init(Args :: list()) ->
  {ok, s1, state_data(), [{next_event, internal, {ping}}]}.

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
callback_mode() ->
  state_functions.

-spec init({CallbackModule :: module(), Args :: list()}) ->
  {ok, s1, state_data(), [{next_event, internal, {ping}}]}.
init({CallbackModule, _Args}) ->
  io:format("alice: Initializing with callback module ~p~n", [CallbackModule]),
  put(callback_module, CallbackModule),
  CallbackModule:init([]).

-spec s3(term(), {pid(), {atom(), term()}}, state_data()) ->
  {keep_state, state_data(), [postpone]} |
  {stop, normal, state_data()}.
s3(EventType, {CarolPid, {pong}}, Data) ->
  CallbackModule = get(callback_module),
  CallbackModule:s3(EventType, {CarolPid, {pong}}, Data).

-spec send_s1_ping(CarolPid :: pid(), _Data :: state_data()) -> ok.
send_s1_ping(CarolPid, _Data) ->
  gen_statem:cast(CarolPid, {self(), {ping}}).

-spec s1(EventType :: term(), {atom()}, state_data()) -> {next_state, s3, state_data()}.
s1(EventType, {ping}, Data) ->
  CallbackModule = get(callback_module),
  CallbackModule:s1(EventType, {ping}, Data).

-spec code_change(OldVsn :: term(), StateName :: atom(), StateData :: state_data(), Extra :: term()) ->
  {ok, state_data()}.
code_change(_Vsn, _StateName, StateData, _Extra) ->
  {ok, StateData}.

-spec terminate(Reason :: term(), State :: atom(), Data :: state_data()) -> ok.
terminate(_Reason, _State, _StateData) ->
  ok.

