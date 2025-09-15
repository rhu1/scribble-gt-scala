-module(alice).
-behaviour(gen_alice).

-export([init/1,
  callback_mode/0,
  start_link/0,
  s1/3,
  s3/3
]).

-include("alice.hrl").
-type state_data() :: #state_data{alice_pid :: pid() | undefined, carol_pid :: pid() | undefined}.

-spec start_link() -> {ok, pid()} | {error, term()}.
start_link() ->
  gen_alice:start_link(?MODULE, []).

-spec callback_mode() -> state_functions.
callback_mode() ->
  state_functions.

-spec init(list()) -> {ok, s1, state_data(), [{next_event, internal, {ping}}]}.
init([]) ->
  Data = #state_data{},
  io:format("alice initialized ~n", []),
  {ok, s1, Data, [{next_event, internal, {ping}}]}.

-spec s3(cast, {pid(), {atom(), term()}}, state_data()) -> {stop, normal, state_data()}.
s3(cast, {CarolPid, {pong}}, #state_data{carol_pid = CarolPid} = Data) ->
  io:format("Alice: s3 Received pong  from Carol ~p ~n", [CarolPid]),
  %% start alice 2 (only if not already running)
  case whereis(alice2) of
    undefined -> _ = alice2:start_link();
    _Pid -> ok
  end,

  {stop, normal, Data}.

-spec s1(internal, {atom()}, state_data()) -> {next_state, s3, state_data()}.
s1(internal, {ping}, Data) ->
  Data1 = connection(Data),
  CarolPid = Data1#state_data.carol_pid,
  io:format("Alice: s1 Sending ping to Carol ~n", []),
  gen_alice:send_s1_ping(CarolPid, Data1),
  {next_state, s3, Data1}.

-spec connection(state_data()) -> state_data().
connection(Data) ->
  io:format("alice connected ~n", []),
  CarolPid = case whereis(carol) of
               undefined ->
                 io:format("carol is not available yet. Will retry...~n", []),
                 timer:sleep(1000),
                 whereis(carol);
               Pid_carol ->
                 Pid_carol
             end,
  Data#state_data{carol_pid = CarolPid}.
