%%-------------------------------------------------------------------
%% @doc Interleaving demo (condition) role: `alice2`.
%%
%% Second-session role. In the condition variant, some messages may be buffered
%% until the enabling condition is satisfied.
%%-------------------------------------------------------------------

-module(alice2).
-behaviour(gen_alice2).

-export([init/1,
  callback_mode/0,
  start_link/0,
  s5/3,
  s7/3
]).

-include("alice2.hrl").
-type state_data() :: #state_data{bob_pid :: pid() | undefined, alice_pid :: pid() | undefined}.

-spec start_link() -> {ok, pid()} | {error, term()}.
start_link() ->
  gen_alice2:start_link(?MODULE, []).

-spec callback_mode() -> state_functions.
callback_mode() ->
  state_functions.

-spec init(list()) -> {ok, s5, state_data()}.
init([]) ->
  Data = #state_data{},
  io:format("alice2 initialized ~n", []),
  {ok, s5, Data}.

-spec s5(cast, {pid(), {atom(), term()}}, state_data()) ->
  {next_state, s7, state_data(), [{next_event, internal, {response}}]} |
  {keep_state, state_data()}.
s5(cast, {BobPid, {request}}, Data) ->
  Data1 = Data#state_data{bob_pid = BobPid},
  case whereis(alice) of
    undefined ->
      %% Alice is done => accept request and move to s7
      io:format("alice2: Alice finished; processing request now~n", []),
      {next_state, s7, Data1, [{next_event, internal, {response}}]};
    _AlivePid ->
      %% Alice not done yet => requeue the request as a future cast
      _ = erlang:send_after(50, self(), {'$gen_cast', {BobPid, {request}}}),
      io:format("alice2: waiting for Alice to finish; stashing request~n", []),
      {keep_state, Data1}
  end.


-spec s7(internal, {atom()}, state_data()) -> {stop, normal, state_data()}.
s7(internal, {response}, #state_data{bob_pid = BobPid} = Data) ->
  io:format("Alice: s7 Sending response to Bob ~n", []),
  gen_alice2:send_s7_response(BobPid, Data),
  {stop, normal, Data}.
