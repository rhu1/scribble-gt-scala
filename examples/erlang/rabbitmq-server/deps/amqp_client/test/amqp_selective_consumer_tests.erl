%% Unit tests for the custom selective consumer callback.
%%
%% These tests are *pure* state-machine tests (no RabbitMQ broker required).
%% We simulate the "channel" process the consumer expects.

-module(amqp_selective_consumer_tests).

-include_lib("eunit/include/eunit.hrl").

%% The helper record is defined alongside the consumer code.
-include("../src/consumer.hrl").


%% --- Helpers ---

start_fake_peers() ->
    %% The consumer's connection/1 expects these to be registered.
    ChannelPid = spawn_link(fun fake_channel/0),
    ServerPid  = spawn_link(fun fake_server/0),
    true = register(channel, ChannelPid),
    true = register(server, ServerPid),
    {ChannelPid, ServerPid}.

stop_fake_peers({ChannelPid, ServerPid}) ->
    catch unregister(channel),
    catch unregister(server),
    exit(ChannelPid, kill),
    exit(ServerPid, kill),
    ok.

fake_server() ->
    receive
        _ -> fake_server()
    end.

fake_channel() ->
    receive
        Msg ->
            case Msg of
                %% Consumer registers itself as default consumer.
                {ConsumerPid, {register_default_consumer}} when is_pid(ConsumerPid) ->
                    %% Nothing else required for this unit test.
                    fake_channel();

                %% Consumer requests basic_consume.
                %% NOTE: gen_consumer:send_s3_basic_consume/4 sends a 3-tuple including a counter.
                {ConsumerPid, {basic_consume, _ConsumerTag, _Nowait}, _Counter} when is_pid(ConsumerPid) ->
                    %% gen_consumer:s4/3 expects: {ChannelPid, {basic_consume_ok, Tag}}
                    gen_statem:cast(ConsumerPid, {whereis(channel), {basic_consume_ok, <<"ctag">>}}),
                    fake_channel();

                %% Compatibility: gen_consumer:send_s3_basic_consume/2 (used by
                %% amqp_selective_consumer.erl) sends a 2-tuple (no counter).
                {ConsumerPid, {basic_consume, _ConsumerTag, _Nowait}} when is_pid(ConsumerPid) ->
                    gen_statem:cast(ConsumerPid, {whereis(channel), {basic_consume_ok, <<"ctag">>}}),
                    fake_channel();

                %% Consumer indicates it finished processing a delivery.
                {ConsumerPid, {processing_complete, _DeliveryTag}, _Counter} when is_pid(ConsumerPid) ->
                    %% Nothing to do; stay alive.
                    fake_channel();

                %% Consumer requests cancel.
                {ConsumerPid, {basic_cancel, _ConsumerTag, _Nowait}, Counter} when is_pid(ConsumerPid) ->
                    %% gen_consumer:s11/3 expects: {ChannelPid, {basic_cancel_ok, Tag}, Counter}
                    gen_statem:cast(ConsumerPid, {whereis(channel), {basic_cancel_ok, <<"ctag">>}, Counter}),
                    fake_channel();

                _Other ->
                    fake_channel()
            end
    end.


%% --- Tests ---

%% This is a *pure* callback-module test: we drive the amqp_selective_consumer
%% state functions directly, without going through gen_consumer.
callback_happy_path_test() ->
    {setup,
     fun start_fake_peers/0,
     fun stop_fake_peers/1,
     fun(_Peers) ->
         %% init/1
         {ok, s1, Data1, _Actions1} = amqp_selective_consumer:init([]),

         %% s1 -> s3
         {next_state, s3, Data3, _Actions3} = amqp_selective_consumer:s1(internal, {register_default_consumer}, Data1),

         %% s3 -> s4
         {next_state, s4, Data4} = amqp_selective_consumer:s3(internal, {basic_consume}, Data3),

         %% s4 -> s9
         ChannelPid = whereis(channel),
         {next_state, s9, Data9} = amqp_selective_consumer:s4(cast, {ChannelPid, {basic_consume_ok, <<"ctag">>}}, Data4),

         %% s9 -> s13
         {next_state, s13, Data13, _} = amqp_selective_consumer:s9(cast, {ChannelPid, {process_message}}, Data9),

         %% Deliver, force cancel branch by calling s13(internal,basic_cancel) repeatedly
         %% until it returns next_state s11.
         {StateAfterDeliver, DataAfterDeliver} =
             case amqp_selective_consumer:s13(cast, {ChannelPid, {basic_deliver, <<"ctag">>, 1, <<"ex">>, <<"rk">>}}, Data13) of
                 {next_state, s14, D14, _} -> {s14, D14};
                 {next_state, s11, D11} -> {s11, D11}
             end,

         %% If it went to s14, run processing_complete back to s9 then to s13.
         {State2, Data2} =
             case StateAfterDeliver of
                 s14 ->
                     {next_state, s9, D9b} = amqp_selective_consumer:s14(internal, {processing_complete}, DataAfterDeliver),
                     {next_state, s13, D13b, _} = amqp_selective_consumer:s9(cast, {ChannelPid, {process_message}}, D9b),
                     {s13, D13b};
                 s11 -> {s11, DataAfterDeliver}
             end,

         %% Now ensure we can reach s11 via basic_cancel.
         {next_state, s11, Data11} = ensure_cancel_to_s11(State2, Data2),

         %% Finally, basic_cancel_ok stops.
         {stop, normal, _} = amqp_selective_consumer:s11(cast, {ChannelPid, {basic_cancel_ok, <<"ctag">>}}, Data11),
         ok
     end}.

ensure_cancel_to_s11(s11, Data) ->
    {next_state, s11, Data};
ensure_cancel_to_s11(s13, Data) ->
    %% s13(internal,basic_cancel) is nondeterministic: try up to 100 times.
    ensure_cancel_to_s11_loop(Data, 100).

ensure_cancel_to_s11_loop(_Data, 0) ->
    erlang:error(cancel_never_chosen);
ensure_cancel_to_s11_loop(Data, N) ->
    case amqp_selective_consumer:s13(internal, {basic_cancel}, Data) of
        {next_state, s11, D11} -> {next_state, s11, D11};
        {keep_state, D1} -> ensure_cancel_to_s11_loop(D1, N - 1)
    end.

%% Cover the "basic_cancel2" path: s9 can transition to s7 on receiving
%% {basic_cancel2, ConsumerTag, Nowait}. We assert it then stops on
%% basic_cancel_ok2.
callback_cancel_ok2_path_test() ->
    {setup,
     fun start_fake_peers/0,
     fun stop_fake_peers/1,
     fun(_Peers) ->
         {ok, s1, Data1, _} = amqp_selective_consumer:init([]),
         {next_state, s3, Data3, _} = amqp_selective_consumer:s1(internal, {register_default_consumer}, Data1),
         {next_state, s4, Data4} = amqp_selective_consumer:s3(internal, {basic_consume}, Data3),

         ChannelPid = whereis(channel),
         {next_state, s9, Data9} = amqp_selective_consumer:s4(cast, {ChannelPid, {basic_consume_ok, <<"ctag">>}}, Data4),

         %% Drive to s9 then trigger the cancel2 transition.
         {next_state, s7, Data7} = amqp_selective_consumer:s9(cast, {ChannelPid, {basic_cancel2, <<"ctag">>, false}}, Data9),

         %% And stop normally on cancel_ok2.
         {stop, normal, _} = amqp_selective_consumer:s7(cast, {ChannelPid, {basic_cancel_ok2, <<"ctag">>}}, Data7),
         ok
     end}.
