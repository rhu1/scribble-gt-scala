-module(gen_alice2).
-behaviour(gen_statem).

-export([init/1,
  callback_mode/0,
  code_change/4,
  terminate/3,
  start_link/2,
  s5/3,
  send_s7_response/2,
  s7/3
]).

-include("alice2.hrl").
-type state_data() :: #state_data{bob_pid :: pid() | undefined, alice_pid :: pid() | undefined}.

-callback s5(term(), {pid(), {atom(), term()}}, state_data()) -> {keep_state, state_data(), [postpone]} | {next_state, s7, state_data(), [{next_event, internal, {response}}]} | {keep_state, state_data()}.
-callback s7(EventType :: term(), {atom()}, state_data()) -> {stop, normal, state_data()}.
-callback init(Args :: list()) ->
  {ok, s5, state_data()}.

-spec start_link(CallbackModule :: module(), Args :: list()) ->
  {ok, pid()} | {error, term()}.
start_link(CallbackModule, Args) ->
  case code:ensure_loaded(CallbackModule) of
    {module, CallbackModule} ->
      gen_statem:start_link({local, CallbackModule}, gen_alice2, {CallbackModule, Args}, [{debug, [trace, {log_to_file, "alice_debug.log"}]}]);
    {error, Reason} ->
      {error, Reason}
  end.

-spec callback_mode() -> state_functions.
callback_mode() ->
  state_functions.

-spec init({CallbackModule :: module(), Args :: list()}) ->
  {ok, s5, state_data()}.
init({CallbackModule, _Args}) ->
  io:format("alice: Initializing with callback module ~p~n", [CallbackModule]),
  put(callback_module, CallbackModule),
  CallbackModule:init([]).

-spec send_s7_response(BobPid :: pid(), _Data :: state_data()) -> ok.
send_s7_response(BobPid, _Data) ->
  gen_statem:cast(BobPid, {self(), {response}}).

-spec s5(term(), {pid(), {atom(), term()}}, state_data()) ->
  {keep_state, state_data(), [postpone]} |
  {next_state, s7, state_data(), [{next_event, internal, {response}}]} |
  {keep_state, state_data()}.
s5(EventType, {BobPid, {request}}, Data) ->
  CallbackModule = get(callback_module),
  CallbackModule:s5(EventType, {BobPid, {request}}, Data).

-spec s7(EventType :: term(), {atom()}, state_data()) -> {stop, normal, state_data()}.
s7(EventType, {response}, Data) ->
  CallbackModule = get(callback_module),
  CallbackModule:s7(EventType, {response}, Data).

-spec code_change(OldVsn :: term(), StateName :: atom(), StateData :: state_data(), Extra :: term()) ->
  {ok, state_data()}.
code_change(_Vsn, _StateName, StateData, _Extra) ->
  {ok, StateData}.

-spec terminate(Reason :: term(), State :: atom(), Data :: state_data()) -> ok.
terminate(_Reason, _State, _StateData) ->
  ok.

