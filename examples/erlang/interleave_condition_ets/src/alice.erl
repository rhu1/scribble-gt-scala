%%-------------------------------------------------------------------
%% @doc Interleaving demo (ETS condition) role: `alice`.
%%
%% Similar to interleave_condition, but uses an ETS-backed turn/enable flag
%% (see `turn.erl`) to coordinate session interleaving.
%%-------------------------------------------------------------------

-module(alice).
-behaviour(gen_alice).

-export([init/1,
  callback_mode/0,
  start_link/0,
  s5/3,
  s7/3
]).

-include("alice.hrl").
-type state_data() :: #state_data{carol_pid :: pid() | undefined, alice_pid :: pid() | undefined}.

-spec start_link() -> {ok, pid()} | {error, term()}.
start_link() ->
  gen_alice:start_link(?MODULE, []).

-spec callback_mode() -> state_functions.
callback_mode() ->
  state_functions.

-spec init(list()) -> {ok, s5, state_data()}.
init([]) ->
  Data = #state_data{},
  io:format("alice initialized ~n", []),
  {ok, s5, Data}.

-spec s5(cast, {pid(), {atom(), term()}}, state_data()) ->
  {next_state, s7, state_data(), [{next_event, internal, {ping}}]} |
  {keep_state, state_data()}.
s5(cast, {CarolPid, {pong}}, Data) ->
  Data1 = connection(Data),
  io:format("Alice: s5 Received pong  from Carol ~p ~n", [CarolPid]),
  {next_state, s7, Data1, [{next_event, internal, {ping}}]}.

-spec s7(internal, {atom()}, state_data()) -> {stop, normal, state_data()}.
s7(internal, {ping}, #state_data{carol_pid = CarolPid} = Data) ->
  io:format("Alice: s7 Sending ping to Carol ~n", []),
  gen_alice:send_s7_ping(CarolPid, Data),
  %% Signal via ETS that it's alice2's turn now
  catch turn:set(true),
  {stop, normal, Data}.

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
