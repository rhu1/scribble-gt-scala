-module(alice2).
-behaviour(gen_alice2).

-export([init/1,
  callback_mode/0,
  start_link/0,
  s3/3,
  s4/3
]).

-include("alice2.hrl").
-type state_data() :: #state_data{alice_pid :: pid() | undefined, bob_pid :: pid() | undefined}.

-spec start_link() -> {ok, pid()} | {error, term()}.
start_link() ->
  gen_alice2:start_link(?MODULE, []).

-spec callback_mode() -> state_functions.
callback_mode() ->
  state_functions.

-spec init(list()) -> {ok, s3, state_data(), [{next_event, internal, {hello}}]}.
init([]) ->
  Data = #state_data{},
  io:format("alice initialized ~n", []),
  {ok, s3, Data, [{next_event, internal, {hello}}]}.

-spec s4(cast, {pid(), {atom(), term()}}, state_data()) -> {stop, normal, state_data()}.
s4(cast, {BobPid, {world}}, #state_data{bob_pid = BobPid} = Data) ->
  io:format("Alice: s4 Received world  from Bob ~p ~n", [BobPid]),
  {stop, normal, Data}.

-spec s3(internal, {atom()}, state_data()) -> {next_state, s4, state_data()}.
s3(internal, {hello}, Data) ->
  Data1 = connection(Data),
  BobPid = Data1#state_data.bob_pid,
  io:format("Alice: s3 Sending hello to Bob ~n", []),
  gen_alice2:send_s3_hello(BobPid, Data1),
  {next_state, s4, Data1}.

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
