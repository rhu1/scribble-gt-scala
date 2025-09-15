-module(bob).
-behaviour(gen_bob).

-export([init/1,
	 callback_mode/0,
	 start_link/0,
	 s5/3,
	 s7/3
	]).

-include("bob.hrl").
-type state_data() :: #state_data{alice_pid :: pid() | undefined, bob_pid :: pid() | undefined}.

-spec start_link() -> {ok, pid()} | {error, term()}.
start_link() ->
    gen_bob:start_link(?MODULE, []).

-spec callback_mode() -> state_functions.
callback_mode() ->
    state_functions.

-spec init(list()) -> {ok, s5, state_data()}.
init([]) ->
    Data = #state_data{},
    io:format("bob initialized ~n", []),
    {ok, s5, Data}.

-spec s5(cast, {pid(), {atom(), term()}}, state_data()) ->
    {next_state, s7, state_data(), [{next_event, internal, {world}}]} |
    {keep_state, state_data()}.
s5(cast, {AlicePid, {hello}}, Data) ->
    Data1 = connection(Data),
    io:format("Bob: s5 Received hello  from Alice ~p ~n", [AlicePid]),
    {next_state, s7, Data1, [{next_event, internal, {world}}]}.

-spec s7(internal, {atom()}, state_data()) -> {stop, normal, state_data()}.
s7(internal, {world}, #state_data{alice_pid = AlicePid} = Data) ->
    io:format("Bob: s7 Sending world to Alice ~n", []),
    gen_bob:send_s7_world(AlicePid, Data),
    {stop, normal, Data}.

-spec connection(state_data()) -> state_data().
connection(Data) ->
    io:format("bob connected ~n", []),
    AlicePid = case whereis(alice2) of
        undefined ->
            io:format("alice2 is not available yet. Will retry...~n", []),
            timer:sleep(1000),
            whereis(alice2);
        Pid_alice2 ->
            Pid_alice2
    end,
    Data#state_data{alice_pid = AlicePid}.
