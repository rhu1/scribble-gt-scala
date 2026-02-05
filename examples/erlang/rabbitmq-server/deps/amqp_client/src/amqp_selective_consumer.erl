-module(amqp_selective_consumer).
-behaviour(gen_consumer).

%% API
-export([start_link/0, callback_mode/0,
         call_consumer/2, call_consumer/3, call_consumer/4]).

-export([init/1,
    s1/3,
    s3/3,
    s4/3,
    s9/3,
    make_choice_basic_cancel/1,
    s13/3,
    make_choice_basic_deliver/1,
    s14/3,
    s11/3,
    s7/3
]).
-include("consumer.hrl").

%% Type aliases for record and AMQP methods
-type state_data() :: #state_data{}.
-type amqp_method() :: term().

-spec start_link() -> {ok, pid()} | {error, term()}.
start_link() ->
    gen_consumer:start_link(?MODULE, []).

-spec callback_mode() -> state_functions.
callback_mode() ->
    state_functions.

%% Synchronous call API
-spec call_consumer(pid(), term()) -> term().
call_consumer(Pid, Msg) ->
    gen_statem:call(Pid, {consumer_call, Msg}).

-spec call_consumer(pid(), amqp_method(), term()) -> term().
call_consumer(Pid, Method, Args) ->
    gen_statem:call(Pid, {consumer_call, Method, Args}).

-spec call_consumer(pid(), amqp_method(), term(), term()) -> term().
call_consumer(Pid, Method, Args, Ctx) ->
    gen_statem:call(Pid, {consumer_call, Method, Args, Ctx}).
%%
%%%% Initial callback
-spec init(list()) -> {ok, s1, state_data(), [{next_event, internal, {register_default_consumer}}]}.
init([]) ->
    % initialize state_data with channel and server pids
    Base = #state_data{},
    Data = connection(Base),
    io:format("consumer initialized ~n", []),
    {ok, s1, Data, [{next_event, internal, {register_default_consumer}}]}.

-spec s3(internal, {atom()}, state_data()) -> {next_state, s4, state_data()}.
s3(internal, {basic_consume}, #state_data{channel_pid = ChannelPid} = Data) ->
    io:format("Consumer: s3 Sending basic_consume to Channel ~n", []),
    gen_consumer:send_s3_basic_consume(ChannelPid, Data),
    {next_state, s4, Data}.

-spec s4(cast, {pid(), {atom(), term()}}, state_data()) -> {next_state, s9, state_data()}.
s4(cast, {ChannelPid, {basic_consume_ok, Consumer_tag}}, #state_data{channel_pid = ChannelPid} = Data) ->
    io:format("Consumer: s4 Received basic_consume_ok Consumer_tag ~p from Channel ~p ~n", [Consumer_tag, ChannelPid]),
    {next_state, s9, Data}.

-spec s11(cast, {pid(), {atom(), term()}}, state_data()) -> {stop, normal, state_data()}.
s11(cast, {ChannelPid, {basic_cancel_ok, Consumer_tag}}, #state_data{channel_pid = ChannelPid} = Data) ->
    io:format("Consumer: s11 Received basic_cancel_ok Consumer_tag ~p from Channel ~p ~n", [Consumer_tag, ChannelPid]),
    {stop, normal, Data}.

-spec s7(cast, {pid(), {atom(), term()}}, state_data()) -> {stop, normal, state_data()}.
s7(cast, {ChannelPid, {basic_cancel_ok2, Consumer_tag}}, #state_data{channel_pid = ChannelPid} = Data) ->
    io:format("Consumer: s7 Received basic_cancel_ok2 Consumer_tag ~p from Channel ~p ~n", [Consumer_tag, ChannelPid]),
    {stop, normal, Data}.

-spec s13(internal | EventType :: term(), {atom()} | {pid(), {term()}, integer()}, state_data()) ->
    {next_state, s11, state_data()} |
    {next_state, s14, state_data(), [{next_event, internal, {processing_complete}}]} |
    {keep_state, state_data()}.
s13(internal, {basic_cancel}, #state_data{channel_pid = ChannelPid} = Data) ->
     case make_choice_basic_cancel(Data) of
         1 ->
             {keep_state, Data};
         2 ->
            gen_consumer:send_s13_basic_cancel(ChannelPid, Data),
             io:format("Consumer: s13 Sending basic_cancel to Channel ~n", []),
             {next_state, s11, Data}
     end;
s13(cast, {ChannelPid, {basic_deliver, Consumer_tag, Delivery_tag, Exchange, Routing_key}}, #state_data{channel_pid = ChannelPid} = Data) ->
    io:format("Consumer: s13 Received basic_deliver Consumer_tag ~p, Delivery_tag ~p, Exchange ~p, Routing_key ~p from Channel ~p ~n", [Consumer_tag, Delivery_tag, Exchange, Routing_key, ChannelPid]),
    case make_choice_basic_deliver(Data) of
        1 ->
            {next_state, s14, Data, [{next_event, internal, {processing_complete}}]};
        2 ->
            gen_consumer:send_s13_basic_cancel(ChannelPid, Data),
            {next_state, s11, Data}
    end.

-spec make_choice_basic_deliver(state_data()) -> integer().
make_choice_basic_deliver(_Data) ->
    rand:uniform(2).

-spec s9(cast, {pid(), {atom(), term()}}, state_data()) ->
    {next_state, s13, state_data(), [{next_event, internal, {basic_cancel}}]} |
    {keep_state, state_data()} |
    {stop, normal, state_data()} |
    {next_state, s7, state_data()}.
s9(cast, {ChannelPid, {process_message}}, #state_data{channel_pid = ChannelPid} = Data) ->
    io:format("Consumer: s9 Received process_message  from Channel ~p ~n", [ChannelPid]),
    {next_state, s13, Data, [{next_event, internal, {basic_cancel}}]};
s9(cast, {ChannelPid, {basic_cancel, Consumer_tag, Nowait}}, #state_data{channel_pid = ChannelPid} = Data) ->
    io:format("Consumer: s9 Received basic_cancel Consumer_tag ~p, Nowait ~p from Channel ~p ~n", [Consumer_tag, Nowait, ChannelPid]),
    {stop, normal, Data};
s9(cast, {ChannelPid, {basic_cancel2, Consumer_tag, Nowait}}, #state_data{channel_pid = ChannelPid} = Data) ->
    io:format("Consumer: s9 Received basic_cancel2 Consumer_tag ~p, Nowait ~p from Channel ~p ~n", [Consumer_tag, Nowait, ChannelPid]),
    {next_state, s7, Data}.

-spec s14(internal, {atom()}, state_data()) -> {next_state, s9, state_data()}.
s14(internal, {processing_complete}, #state_data{channel_pid = ChannelPid} = Data) ->
    io:format("Consumer: s14 Sending processing_complete to Channel ~n", []),
    gen_consumer:send_s14_processing_complete(ChannelPid, Data),
    {next_state, s9, Data}.

-spec make_choice_basic_cancel(state_data()) -> integer().
make_choice_basic_cancel(_Data) ->
    rand:uniform(2).

-spec s1(internal, {atom()}, state_data()) ->
    {next_state, s3, state_data(), [{next_event, internal, {basic_consume}}]} |
    {keep_state, state_data()}.
s1(internal, {register_default_consumer}, #state_data{channel_pid = ChannelPid} = Data) ->
    io:format("Consumer: s1 Sending register_default_consumer to Channel ~n", []),
    gen_consumer:send_s1_register_default_consumer(ChannelPid, Data),
    {next_state, s3, Data, [{next_event, internal, {basic_consume}}]}.

-spec connection(state_data()) -> state_data().
connection(Data) ->
    io:format("consumer connected ~n", []),
    ChannelPid = case whereis(channel) of
                     undefined ->
                         io:format("channel is not available yet. Will retry...~n", []),
                         timer:sleep(1000),
                         whereis(channel);
                     Pid_channel ->
                         Pid_channel
                 end,
    ServerPid = case whereis(server) of
                    undefined ->
                        io:format("server is not available yet. Will retry...~n", []),
                        timer:sleep(1000),
                        whereis(server);
                    Pid_server ->
                        Pid_server
                end,
    Data#state_data{channel_pid = ChannelPid, server_pid = ServerPid}.


%%% -spec init(list()) -> {ok, s1, state_data(), [{next_event, internal, {register_default_consumer}}]}.
%%init([]) ->
%%    Data = #state_data{},
%%    io:format("[consumer] init -> s1~n", []),
%%    {ok, s1, Data, [{next_event, internal, {register_default_consumer}}]}.
%%
%%%% State s1: register default consumer
%%s1(internal, {register_default_consumer}, Data) ->
%%    io:format("[consumer] s1: register_default_consumer~n", []),
%%    gen_consumer:send_s1_register_default_consumer(Data#state_data.channel_pid, Data),
%%    {next_state, s3, Data, [{next_event, internal, basic_consume}]}.
%%
%%%% State s3: send basic_consume
%%s3(internal, basic_consume, Data) ->
%%    io:format("[consumer] s3: basic_consume~n", []),
%%    gen_consumer:send_s3_basic_consume(Data#state_data.channel_pid, Data),
%%    {next_state, s4, Data}.
%%
%%%% State s4: receive consume_ok
%%s4(cast, {ChannelPid, {basic_consume_ok, _}}, Data) ->
%%    io:format("[consumer] s4: basic_consume_ok~n", []),
%%    New = Data#state_data{channel_pid = ChannelPid},
%%    {next_state, s9, New}.
%%
%%%% State s9: delivery vs cancel
%%s9(cast, {_ChannelPid, {basic_deliver, _Tag, _, _, _}}, Data) ->
%%    io:format("[consumer] s9: basic_deliver -> branching~n", []),
%%    case make_choice_basic_deliver() of
%%        1 -> {next_state, s14, Data, [{next_event, internal, processing_complete}]};
%%        2 -> {next_state, s11, Data}
%%    end;
%%
%%s9(cast, {_ChannelPid, {basic_cancel, _Tag, _}}, Data) ->
%%    io:format("[consumer] s9: basic_cancel -> stop~n", []),
%%    {stop, normal, Data}.
%%
%%%% State s14: after processing_complete
%%s14(internal, processing_complete, Data) ->
%%    io:format("[consumer] s14: processing_complete~n", []),
%%    gen_consumer:send_s14_processing_complete(Data#state_data.channel_pid, Data),
%%    {next_state, s9, Data}.
%%
%%%% State s11: stop on basic_cancel_ok
%%s11(cast, {_ChannelPid, {basic_cancel_ok, _}}, Data) ->
%%    io:format("[consumer] s11: basic_cancel_ok -> stop~n", []),
%%    {stop, normal, Data}.
%%
%%%% State s7: stop on basic_cancel_ok2
%%s7(cast, {_ChannelPid, {basic_cancel_ok2, _}}, Data) ->
%%    io:format("[consumer] s7: basic_cancel_ok2 -> stop~n", []),
%%    {stop, normal, Data}.
%%
%%%% State s13: internal cancel branch
%%s13(internal, basic_cancel, Data) ->
%%    io:format("[consumer] s13: basic_cancel branching~n", []),
%%    case make_choice_basic_cancel() of
%%        1 -> {keep_state, Data};
%%        2 -> gen_consumer:send_s13_basic_cancel(Data#state_data.channel_pid, Data),
%%             {next_state, s11, Data}
%%    end.
%%
%%%% Deterministic choice logic based on consumer registration
%%-spec make_choice_basic_deliver() -> 1.
%%make_choice_basic_deliver() ->
%%    %% Always deliver messages to registered consumers
%%    1.
%%
%%-spec make_choice_basic_cancel() -> 2.
%%make_choice_basic_cancel() ->
%%    %% Always handle cancel by stopping consumer
%%    2.
