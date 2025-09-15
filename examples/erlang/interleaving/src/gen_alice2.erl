-module(gen_alice2).
-behaviour(gen_statem).

-export([init/1, 
	 callback_mode/0, 
	 code_change/4, 
	 terminate/3, 
	 start_link/2, 
	 send_s3_hello/2, 
	 s3/3, 
	 s4/3
	 ]).

-include("alice2.hrl").
-type state_data() :: #state_data{alice_pid :: pid() | undefined, bob_pid :: pid() | undefined}.

-callback s4(term(), {pid(), {atom(), term()}}, state_data()) -> {keep_state, state_data(), [postpone]} | {stop, normal, state_data()}.
-callback s3(EventType :: term(), {atom()}, state_data()) -> {next_state, s4, state_data()}.
-callback init(Args :: list()) -> 
	{ok, s3, state_data(), [{next_event, internal, {hello}}]}.

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
	{ok, s3, state_data(), [{next_event, internal, {hello}}]}.
init({CallbackModule, _Args}) ->
    io:format("alice: Initializing with callback module ~p~n", [CallbackModule]),
    put(callback_module, CallbackModule),
    CallbackModule:init([]).

-spec s4(term(), {pid(), {atom(), term()}}, state_data()) ->
    {keep_state, state_data(), [postpone]} |
    {stop, normal, state_data()}.
s4(EventType, {BobPid, {world}}, Data) ->
    CallbackModule = get(callback_module),
    CallbackModule:s4(EventType, {BobPid, {world}}, Data).

-spec send_s3_hello(BobPid :: pid(), _Data :: state_data()) -> ok.
send_s3_hello(BobPid, _Data) ->
    gen_statem:cast(BobPid, {self(), {hello}}).

-spec s3(EventType :: term(), {atom()}, state_data()) -> {next_state, s4, state_data()}.
s3(EventType, {hello}, Data) ->
    CallbackModule = get(callback_module),
    CallbackModule:s3(EventType, {hello}, Data).

-spec code_change(OldVsn :: term(), StateName :: atom(), StateData :: state_data(), Extra :: term()) ->
    {ok, state_data()}.
code_change(_Vsn, _StateName, StateData, _Extra) ->
    {ok, StateData}.

-spec terminate(Reason :: term(), State :: atom(), Data :: state_data()) -> ok.
terminate(_Reason, _State, _StateData) ->
    ok.
