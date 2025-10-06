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
  io:format("alice initialized ~n", []),
  {ok, s5, Data}.

-spec s5(cast, {pid(), {atom(), term()}}, state_data()) ->
  {next_state, s7, state_data(), [{next_event, internal, {response}}]} |
  {keep_state, state_data()}.
s5(cast, {BobPid, {request}}, Data) ->
  Data1 = connection(Data),
  io:format("Alice: s5 Received request  from Bob ~p ~n", [BobPid]),
  {next_state, s7, Data1, [{next_event, internal, {response}}]}.

-spec s7(internal, {atom()}, state_data()) -> {stop, normal, state_data()}.
s7(internal, {response}, #state_data{bob_pid = BobPid} = Data) ->
  io:format("Alice: s7 Sending response to Bob ~n", []),
  gen_alice2:send_s7_response(BobPid, Data),
  {stop, normal, Data}.

-spec connection(state_data()) -> state_data().
connection(Data) ->
  io:format("alice connected ~n", []),
  BobPid = case whereis(bob) of
             undefined ->
               io:format("bob is not available yet. Will retry...~n", []),
               timer:sleep(1000),
               whereis(bob);
             Pid_bob ->
               Pid_bob
           end,
  Data#state_data{bob_pid = BobPid}.

