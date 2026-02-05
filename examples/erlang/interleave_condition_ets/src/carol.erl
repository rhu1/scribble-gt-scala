%%-------------------------------------------------------------------
%% @doc Interleaving demo (ETS condition) role: `carol`.
%%
%% Role implementation module: implements generated behaviour `gen_carol`.
%%-------------------------------------------------------------------

-module(carol).
-behaviour(gen_carol).

-export([init/1,
    callback_mode/0,
    start_link/0,
    s1/3,
    s3/3
]).

-include("carol.hrl").
-type state_data() :: #state_data{carol_pid :: pid() | undefined, alice_pid :: pid() | undefined}.

-spec start_link() -> {ok, pid()} | {error, term()}.
start_link() ->
    gen_carol:start_link(?MODULE, []).

-spec callback_mode() -> state_functions.
callback_mode() ->
    state_functions.

-spec init(list()) -> {ok, s1, state_data(), [{next_event, internal, {pong}}]}.
init([]) ->
    Data = #state_data{},
    io:format("carol initialized ~n", []),
    {ok, s1, Data, [{next_event, internal, {pong}}]}.

-spec s3(cast, {pid(), {atom(), term()}}, state_data()) -> {stop, normal, state_data()}.
s3(cast, {AlicePid, {ping}}, #state_data{alice_pid = AlicePid} = Data) ->
    io:format("Carol: s3 Received ping  from Alice ~p ~n", [AlicePid]),
    {stop, normal, Data}.

-spec s1(internal, {atom()}, state_data()) -> {next_state, s3, state_data()}.
s1(internal, {pong}, Data) ->
    Data1 = connection(Data),
    AlicePid = Data1#state_data.alice_pid,
    io:format("Carol: s1 Sending pong to Alice ~n", []),
    gen_carol:send_s1_pong(AlicePid, Data1),
    {next_state, s3, Data1}.

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
