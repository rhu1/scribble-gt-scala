-module(bob).
-behaviour(gen_bob).

-export([init/1,
	 callback_mode/0,
	 start_link/0,
    s1/3,
    s3/3
	]).

-include("bob.hrl").
-type state_data() :: #state_data{alice_pid :: pid() | undefined, bob_pid :: pid() | undefined}.

-spec start_link() -> {ok, pid()} | {error, term()}.
start_link() ->
    gen_bob:start_link(?MODULE, []).

-spec callback_mode() -> state_functions.
callback_mode() ->
    state_functions.

-spec init(list()) -> {ok, s1, state_data(), [{next_event, internal, {request}}]}.
init([]) ->
    Data = #state_data{},
    io:format("bob initialized ~n", []),
    {ok, s1, Data, [{next_event, internal, {request}}]}.

-spec s3(cast, {pid(), {atom(), term()}}, state_data()) -> {stop, normal, state_data()}.
s3(cast, {AlicePid, {response}}, #state_data{alice_pid = AlicePid} = Data) ->
    io:format("Bob: s3 Received response  from Alice ~p ~n", [AlicePid]),
    {stop, normal, Data}.

-spec s1(internal, {atom()}, state_data()) -> {next_state, s3, state_data()}.
s1(internal, {request}, Data) ->
    Data1 = connection(Data),
    AlicePid = Data1#state_data.alice_pid,
    io:format("Bob: s1 Sending request to Alice ~n", []),
    gen_bob:send_s1_request(AlicePid, Data1),
    {next_state, s3, Data1}.

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
