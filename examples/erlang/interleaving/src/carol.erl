-module(carol).
-behaviour(gen_carol).

-export([init/1,
	 callback_mode/0,
	 start_link/0,
	 s5/3,
	 s7/3
	]).

-include("carol.hrl").
-type state_data() :: #state_data{alice_pid :: pid() | undefined, carol_pid :: pid() | undefined}.

-spec start_link() -> {ok, pid()} | {error, term()}.
start_link() ->
    gen_carol:start_link(?MODULE, []).

-spec callback_mode() -> state_functions.
callback_mode() ->
    state_functions.

-spec init(list()) -> {ok, s5, state_data()}.
init([]) ->
    Data = #state_data{},
    io:format("carol initialized ~n", []),
    {ok, s5, Data}.

-spec s5(cast, {pid(), {atom(), term()}}, state_data()) ->
    {next_state, s7, state_data(), [{next_event, internal, {pong}}]} |
    {keep_state, state_data()}.
s5(cast, {AlicePid, {ping}}, Data) ->
    Data1 = connection(Data),
    io:format("Carol: s5 Received ping  from Alice ~p ~n", [AlicePid]),
    {next_state, s7, Data1, [{next_event, internal, {pong}}]}.

-spec s7(internal, {atom()}, state_data()) -> {stop, normal, state_data()}.
s7(internal, {pong}, #state_data{alice_pid = AlicePid} = Data) ->
    io:format("Carol: s7 Sending pong to Alice ~n", []),
    gen_carol:send_s7_pong(AlicePid, Data),
    {stop, normal, Data}.

-spec connection(state_data()) -> state_data().
connection(Data) ->
    io:format("carol connected ~n", []),
    AlicePid = case whereis(alice) of
        undefined ->
            io:format("alice is not available yet. Will retry...~n", []),
            timer:sleep(1000),
            whereis(alice);
        Pid_alice ->
            Pid_alice
    end,
    Data#state_data{alice_pid = AlicePid}.

