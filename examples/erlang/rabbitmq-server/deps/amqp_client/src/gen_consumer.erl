%%-module(gen_consumer).
%%-behaviour(gen_statem).
%%
%%-export([start_link/2, callback_mode/0, init/1, terminate/3, code_change/4]).
%%-export([s1/3, s3/3, s4/3, s9/3, s11/3, s7/3, s13/3, s14/3]).
%%-export([send_s1_register_default_consumer/2,
%%         send_s3_basic_consume/2,
%%         send_s13_basic_cancel/2,
%%         send_s14_processing_complete/2]).
%%
%%-type state_data() :: term().
%%
%%%% Start with priority for DOWN messages
%%-spec start_link(module(), list()) -> {ok, pid()} | {error, term()}.
%%start_link(Mod, Args) ->
%%    gen_statem:start_link({local, Mod}, ?MODULE, {Mod, Args}, [{priority, high}]).
%%
%%-spec callback_mode() -> state_functions.
%%callback_mode() ->
%%    state_functions.
%%
%%-spec init({module(), list()}) -> gen_statem:init_return().
%%init({Mod, Args}) ->
%%    put(callback_module, Mod),
%%    Mod:init(Args).
%%
%%%% State function stubs forward to callback module
%%s1(Event, EventData, Data) ->
%%    Mod = get(callback_module),
%%    apply(Mod, s1, [Event, EventData, Data]).
%%
%%s3(Event, EventData, Data) ->
%%    Mod = get(callback_module),
%%    apply(Mod, s3, [Event, EventData, Data]).
%%
%%s4(Event, EventData, Data) ->
%%    Mod = get(callback_module),
%%    apply(Mod, s4, [Event, EventData, Data]).
%%
%%s9(Event, EventData, Data) ->
%%    Mod = get(callback_module),
%%    apply(Mod, s9, [Event, EventData, Data]).
%%
%%s11(Event, EventData, Data) ->
%%    Mod = get(callback_module),
%%    apply(Mod, s11, [Event, EventData, Data]).
%%
%%s7(Event, EventData, Data) ->
%%    Mod = get(callback_module),
%%    apply(Mod, s7, [Event, EventData, Data]).
%%
%%s13(Event, EventData, Data) ->
%%    Mod = get(callback_module),
%%    apply(Mod, s13, [Event, EventData, Data]).
%%
%%s14(Event, EventData, Data) ->
%%    Mod = get(callback_module),
%%    apply(Mod, s14, [Event, EventData, Data]).
%%
%%-spec send_s1_register_default_consumer(pid(), state_data()) -> ok.
%%send_s1_register_default_consumer(ChannelPid, _Data) ->
%%    gen_statem:cast(ChannelPid, {internal, {register_default_consumer}}).
%%
%%-spec send_s3_basic_consume(pid(), state_data()) -> ok.
%%send_s3_basic_consume(ChannelPid, _Data) ->
%%    gen_statem:cast(ChannelPid, {internal, basic_consume}).
%%
%%-spec send_s13_basic_cancel(pid(), state_data()) -> ok.
%%send_s13_basic_cancel(ChannelPid, _Data) ->
%%    gen_statem:cast(ChannelPid, {internal, basic_cancel}).
%%
%%-spec send_s14_processing_complete(pid(), state_data()) -> ok.
%%send_s14_processing_complete(ChannelPid, _Data) ->
%%    gen_statem:cast(ChannelPid, {internal, processing_complete}).
%%
%%terminate(Reason, StateName, Data) ->
%%    Mod = get(callback_module),
%%    apply(Mod, terminate, [Reason, StateName, Data]).
%%
%%code_change(OldVsn, StateName, Data, Extra) ->
%%    Mod = get(callback_module),
%%    apply(Mod, code_change, [OldVsn, StateName, Data, Extra]).


-module(gen_consumer).
-behaviour(gen_statem).

-export([init/1,
    callback_mode/0,
    code_change/4,
    terminate/3,
    start_link/2,
    send_s1_register_default_consumer/2,
    s1/3,
    send_s3_basic_consume/2,
    send_s3_basic_consume/4,
    s3/3,
    s4/3,
    s9/3,
    send_s13_basic_cancel/4,
    s13/3,
    send_s14_processing_complete/3,
    s14/3,
    s11/3,
    s7/3
]).

-include("consumer.hrl").
-type state_data() :: #state_data{mc_counter_2 :: integer(), mc_counter_1 :: integer(), channel_pid :: pid() | undefined, server_pid :: pid() | undefined}.

-callback s3(EventType :: term(), {atom()}, state_data()) -> {next_state, s4, state_data()}.
-callback s4(term(), {pid(), {atom(), term()}}, state_data()) -> {keep_state, state_data(), [postpone]} | {next_state, s9, state_data()}.
-callback s11(term(), {pid(), {atom(), term()}}, state_data()) -> {keep_state, state_data(), [postpone]} | {stop, normal, state_data()}.
-callback s7(term(), {pid(), {atom(), term()}}, state_data()) -> {keep_state, state_data(), [postpone]} | {stop, normal, state_data()}.
-callback s13(EventType :: term(), {atom()} | {pid(), {term()}, integer()}, state_data()) -> {next_state, s11, state_data()} | {keep_state, state_data(), [postpone]} | {next_state, s14, state_data(), [{next_event, internal, {processing_complete}}]} | {keep_state, state_data()}.
-callback s9(EventType :: term(), {pid(), {term()}, integer()}, state_data()) -> {next_state, s13, state_data(), [{next_event, internal, {basic_cancel}}]} | {keep_state, state_data()} | {stop, normal, state_data()} | {keep_state, state_data(), [postpone]} | {next_state, s7, state_data()}.
-callback s14(EventType :: term(), {atom()}, state_data()) -> {next_state, s9, state_data()}.
-callback s1(EventType :: term(), {atom()}, state_data()) -> {next_state, s3, state_data(), [{next_event, internal, {basic_consume}}]} | {keep_state, state_data()}.
-callback init(Args :: list()) ->
    {ok, s1, state_data(), [{next_event, internal, {register_default_consumer}}]}.

-spec start_link(CallbackModule :: module(), Args :: list()) ->
    {ok, pid()} | {error, term()}.
start_link(CallbackModule, Args) ->
    case code:ensure_loaded(CallbackModule) of
        {module, CallbackModule} ->
            gen_statem:start_link({local, CallbackModule}, gen_consumer, {CallbackModule, Args}, [{debug, [trace, {log_to_file, "consumer_debug.log"}]}]);
        {error, Reason} ->
            {error, Reason}
    end.

-spec callback_mode() -> state_functions.
callback_mode() ->
    state_functions.

-spec init({CallbackModule :: module(), Args :: list()}) ->
    {ok, s1, state_data(), [{next_event, internal, {register_default_consumer}}]}.
init({CallbackModule, _Args}) ->
    io:format("consumer: Initializing with callback module ~p~n", [CallbackModule]),
    put(callback_module, CallbackModule),
    CallbackModule:init([]).

-spec s3(EventType :: term(), {atom()}, state_data()) -> {next_state, s4, state_data()}.
s3(EventType, {basic_consume}, Data) ->
    CallbackModule = get(callback_module),
    CallbackModule:s3(EventType, {basic_consume}, Data).

-spec s4(term(), {pid(), {atom(), term()}}, state_data()) ->
    {keep_state, state_data(), [postpone]} |
    {next_state, s9, state_data()}.
s4(_EventType, {_Pid, {basic_cancel2, Consumer_tag, Nowait}, Counter}, #state_data{mc_counter_2 = MC} = Data) when Counter >= MC ->
    io:format("gen_consumer: Postponing event ~p~n", [[basic_cancel2, Consumer_tag, Nowait]]),
    {keep_state, Data, [postpone]};
s4(_EventType, {_Pid, {basic_cancel, Consumer_tag, Nowait}, Counter}, #state_data{mc_counter_2 = MC} = Data) when Counter >= MC ->
    io:format("gen_consumer: Postponing event ~p~n", [[basic_cancel, Consumer_tag, Nowait]]),
    {keep_state, Data, [postpone]};
s4(_EventType, {_Pid, {process_message}, Counter}, #state_data{mc_counter_2 = MC} = Data) when Counter >= MC ->
    io:format("gen_consumer: Postponing event ~p~n", [[process_message]]),
    {keep_state, Data, [postpone]};
s4(_EventType, {_Pid, {basic_deliver, Consumer_tag, Delivery_tag, Exchange, Routing_key}, Counter}, #state_data{mc_counter_1 = MC} = Data) when Counter >= MC ->
    io:format("gen_consumer: Postponing event ~p~n", [[basic_deliver, Consumer_tag, Delivery_tag, Exchange, Routing_key]]),
    {keep_state, Data, [postpone]};
s4(_EventType, {_Pid, {basic_cancel_ok2, Consumer_tag}, Counter}, #state_data{mc_counter_2 = MC} = Data) when Counter >= MC ->
    io:format("gen_consumer: Postponing event ~p~n", [[basic_cancel_ok2, Consumer_tag]]),
    {keep_state, Data, [postpone]};
s4(_EventType, {_Pid, {basic_cancel_ok, Consumer_tag}, Counter}, #state_data{mc_counter_1 = MC} = Data) when Counter >= MC ->
    io:format("gen_consumer: Postponing event ~p~n", [[basic_cancel_ok, Consumer_tag]]),
    {keep_state, Data, [postpone]};
s4(EventType, {ChannelPid, {basic_consume_ok, Consumer_tag}}, Data) ->
    CallbackModule = get(callback_module),
    CallbackModule:s4(EventType, {ChannelPid, {basic_consume_ok, Consumer_tag}}, Data).

-spec s11(term(), {pid(), {atom(), term()}}, state_data()) ->
    {keep_state, state_data(), [postpone]} |
    {stop, normal, state_data()}.
s11(_EventType, {_Pid, {basic_cancel_ok, Consumer_tag}, Counter}, #state_data{mc_counter_1 = MC} = Data) when Counter > MC ->
    io:format("gen_consumer: Postponing event ~p~n", [[basic_cancel_ok, Consumer_tag]]),
    {keep_state, Data, [postpone]};
s11(EventType, {ChannelPid, {basic_cancel_ok, Consumer_tag}, Counter}, #state_data{mc_counter_1 = MC} = Data) when Counter =:= MC ->
    CallbackModule = get(callback_module),
    CallbackModule:s11(EventType, {ChannelPid, {basic_cancel_ok, Consumer_tag}}, Data);
s11(_EventType, {_Pid, Msg, _Counter}, Data) when Msg =:= {process_message} ->
    io:format("gen_consumer: Garbage collecting event ~p~n", [Msg]),
    {keep_state, Data};
s11(_EventType, {_Pid, {basic_deliver, Consumer_tag, Delivery_tag, Exchange, Routing_key}, _Counter}, Data) ->
    io:format("gen_consumer: Garbage collecting event ~p~n", [{basic_deliver, Consumer_tag, Delivery_tag, Exchange, Routing_key}]),
    {keep_state, Data};
s11(_EventType, {_Pid, {basic_cancel_ok2, Consumer_tag}, _Counter}, Data) ->
    io:format("gen_consumer: Garbage collecting event ~p~n", [{basic_cancel_ok2, Consumer_tag}]),
    {keep_state, Data};
s11(_EventType, {_Pid, {basic_cancel_ok, Consumer_tag}, _Counter}, Data) ->
    io:format("gen_consumer: Garbage collecting event ~p~n", [{basic_cancel_ok, Consumer_tag}]),
    {keep_state, Data}.

-spec send_s1_register_default_consumer(ChannelPid :: pid(), _Data :: state_data()) -> ok.
send_s1_register_default_consumer(ChannelPid, _Data) ->
    gen_statem:cast(ChannelPid, {self(), {register_default_consumer}}).

-spec s7(term(), {pid(), {atom(), term()}}, state_data()) ->
    {keep_state, state_data(), [postpone]} |
    {stop, normal, state_data()}.
s7(_EventType, {_Pid, {basic_cancel_ok2, Consumer_tag}, Counter}, #state_data{mc_counter_2 = MC} = Data) when Counter > MC ->
    io:format("gen_consumer: Postponing event ~p~n", [[basic_cancel_ok2, Consumer_tag]]),
    {keep_state, Data, [postpone]};
s7(EventType, {ChannelPid, {basic_cancel_ok2, Consumer_tag}, Counter}, #state_data{mc_counter_2 = MC} = Data) when Counter =:= MC ->
    CallbackModule = get(callback_module),
    CallbackModule:s7(EventType, {ChannelPid, {basic_cancel_ok2, Consumer_tag}}, Data);
s7(_EventType, {_Pid, {basic_cancel_ok2, Consumer_tag}, _Counter}, Data) ->
    io:format("gen_consumer: Garbage collecting event ~p~n", [{basic_cancel_ok2, Consumer_tag}]),
    {keep_state, Data}.

-spec s13(EventType :: term(), {atom()} | {pid(), {term()}, integer()}, state_data()) ->
    {next_state, s11, state_data()} |
    {keep_state, state_data(), [postpone]} |
    {next_state, s14, state_data(), [{next_event, internal, {processing_complete}}]} |
    {keep_state, state_data()}.
s13(_EventType, {_Pid, {basic_cancel2, Consumer_tag, Nowait}, Counter}, #state_data{mc_counter_2 = MC} = Data) when Counter >= MC ->
    io:format("gen_consumer: Postponing event ~p~n", [[basic_cancel2, Consumer_tag, Nowait]]),
    {keep_state, Data, [postpone]};
s13(_EventType, {_Pid, {basic_cancel, Consumer_tag, Nowait}, Counter}, #state_data{mc_counter_2 = MC} = Data) when Counter >= MC ->
    io:format("gen_consumer: Postponing event ~p~n", [[basic_cancel, Consumer_tag, Nowait]]),
    {keep_state, Data, [postpone]};
s13(_EventType, {_Pid, {process_message}, Counter}, #state_data{mc_counter_2 = MC} = Data) when Counter >= MC ->
    io:format("gen_consumer: Postponing event ~p~n", [[process_message]]),
    {keep_state, Data, [postpone]};
s13(_EventType, {_Pid, {basic_cancel_ok2, Consumer_tag}, Counter}, #state_data{mc_counter_2 = MC} = Data) when Counter >= MC ->
    io:format("gen_consumer: Postponing event ~p~n", [[basic_cancel_ok2, Consumer_tag]]),
    {keep_state, Data, [postpone]};
s13(_EventType, {_Pid, {basic_cancel_ok, Consumer_tag}, Counter}, #state_data{mc_counter_1 = MC} = Data) when Counter >= MC ->
    io:format("gen_consumer: Postponing event ~p~n", [[basic_cancel_ok, Consumer_tag]]),
    {keep_state, Data, [postpone]};
s13(_EventType, {_Pid, {basic_deliver, Consumer_tag, Delivery_tag, Exchange, Routing_key}, Counter}, #state_data{mc_counter_1 = MC} = Data) when Counter > MC ->
    io:format("gen_consumer: Postponing event ~p~n", [[basic_deliver, Consumer_tag, Delivery_tag, Exchange, Routing_key]]),
    {keep_state, Data, [postpone]};
s13(EventType, {basic_cancel}, #state_data{mc_counter_1 = MC} = Data) ->
    NewData = Data#state_data{mc_counter_1 = MC + 1},
    CallbackModule = get(callback_module),
    CallbackModule:s13(EventType, {basic_cancel}, NewData);
s13(EventType, {ChannelPid, {basic_deliver, Consumer_tag, Delivery_tag, Exchange, Routing_key}, Counter}, #state_data{mc_counter_1 = MC} = Data) when Counter =:= MC ->
    CallbackModule = get(callback_module),
    CallbackModule:s13(EventType, {ChannelPid, {basic_deliver, Consumer_tag, Delivery_tag, Exchange, Routing_key}}, Data);
s13(_EventType, {_Pid, Msg, _Counter}, Data) when Msg =:= {process_message} ->
    io:format("gen_consumer: Garbage collecting event ~p~n", [Msg]),
    {keep_state, Data};
s13(_EventType, {_Pid, {basic_deliver, Consumer_tag, Delivery_tag, Exchange, Routing_key}, _Counter}, Data) ->
    io:format("gen_consumer: Garbage collecting event ~p~n", [{basic_deliver, Consumer_tag, Delivery_tag, Exchange, Routing_key}]),
    {keep_state, Data};
s13(_EventType, {_Pid, {basic_cancel_ok2, Consumer_tag}, _Counter}, Data) ->
    io:format("gen_consumer: Garbage collecting event ~p~n", [{basic_cancel_ok2, Consumer_tag}]),
    {keep_state, Data};
s13(_EventType, {_Pid, {basic_cancel_ok, Consumer_tag}, _Counter}, Data) ->
    io:format("gen_consumer: Garbage collecting event ~p~n", [{basic_cancel_ok, Consumer_tag}]),
    {keep_state, Data}.

-spec send_s3_basic_consume(ChannelPid :: pid(), Consumer_tag :: term(), Nowait :: term(), _Data :: state_data()) -> ok.
send_s3_basic_consume(ChannelPid, Consumer_tag, Nowait, _Data) ->
    gen_statem:cast(ChannelPid, {self(), {basic_consume, Consumer_tag, Nowait}}).

%% Compatibility wrapper for older callback code: defaults to an empty consumer tag and nowait=false.
-spec send_s3_basic_consume(ChannelPid :: pid(), Data :: state_data()) -> ok.
send_s3_basic_consume(ChannelPid, Data) ->
    send_s3_basic_consume(ChannelPid, <<>>, false, Data).

-spec s9(EventType :: term(), {pid(), {term()}, integer()}, state_data()) ->
    {next_state, s13, state_data(), [{next_event, internal, {basic_cancel}}]} |
    {keep_state, state_data()} |
    {stop, normal, state_data()} |
    {keep_state, state_data(), [postpone]} |
    {next_state, s7, state_data()}.
s9(_EventType, {_Pid, {basic_deliver, Consumer_tag, Delivery_tag, Exchange, Routing_key}, Counter}, #state_data{mc_counter_1 = MC} = Data) when Counter >= MC + 1 ->
    io:format("gen_consumer: Postponing event ~p~n", [[basic_deliver, Consumer_tag, Delivery_tag, Exchange, Routing_key]]),
    {keep_state, Data, [postpone]};
s9(_EventType, {_Pid, {basic_cancel_ok2, Consumer_tag}, Counter}, #state_data{mc_counter_2 = MC} = Data) when Counter >= MC + 1 ->
    io:format("gen_consumer: Postponing event ~p~n", [[basic_cancel_ok2, Consumer_tag]]),
    {keep_state, Data, [postpone]};
s9(_EventType, {_Pid, {basic_cancel_ok, Consumer_tag}, Counter}, #state_data{mc_counter_1 = MC} = Data) when Counter >= MC + 1 ->
    io:format("gen_consumer: Postponing event ~p~n", [[basic_cancel_ok, Consumer_tag]]),
    {keep_state, Data, [postpone]};
s9(_EventType, {_Pid, {basic_cancel2, Consumer_tag, Nowait}, Counter}, #state_data{mc_counter_2 = MC} = Data) when Counter > MC + 1 ->
    io:format("gen_consumer: Postponing event ~p~n", [[basic_cancel2, Consumer_tag, Nowait]]),
    {keep_state, Data, [postpone]};
s9(_EventType, {_Pid, {basic_cancel, Consumer_tag, Nowait}, Counter}, #state_data{mc_counter_2 = MC} = Data) when Counter > MC + 1 ->
    io:format("gen_consumer: Postponing event ~p~n", [[basic_cancel, Consumer_tag, Nowait]]),
    {keep_state, Data, [postpone]};
s9(_EventType, {_Pid, {process_message}, Counter}, #state_data{mc_counter_2 = MC} = Data) when Counter > MC + 1 ->
    io:format("gen_consumer: Postponing event ~p~n", [[process_message]]),
    {keep_state, Data, [postpone]};
s9(EventType, {ChannelPid, {process_message}, Counter}, #state_data{mc_counter_2 = MC} = Data) when Counter =:= MC + 1 ->
    NewData = Data#state_data{mc_counter_2 = MC + 1},
    CallbackModule = get(callback_module),
    CallbackModule:s9(EventType, {ChannelPid, {process_message}}, NewData);
s9(EventType, {ChannelPid, {basic_cancel, Consumer_tag, Nowait}, Counter}, #state_data{mc_counter_2 = MC} = Data) when Counter =:= MC + 1 ->
    NewData = Data#state_data{mc_counter_2 = MC + 1},
    CallbackModule = get(callback_module),
    CallbackModule:s9(EventType, {ChannelPid, {basic_cancel, Consumer_tag, Nowait}}, NewData);
s9(EventType, {ChannelPid, {basic_cancel2, Consumer_tag, Nowait}, Counter}, #state_data{mc_counter_2 = MC} = Data) when Counter =:= MC + 1 ->
    NewData = Data#state_data{mc_counter_2 = MC + 1},
    CallbackModule = get(callback_module),
    CallbackModule:s9(EventType, {ChannelPid, {basic_cancel2, Consumer_tag, Nowait}}, NewData);
s9(_EventType, {_Pid, Msg, _Counter}, Data) when Msg =:= {process_message} ->
    io:format("gen_consumer: Garbage collecting event ~p~n", [Msg]),
    {keep_state, Data};
s9(_EventType, {_Pid, {basic_deliver, Consumer_tag, Delivery_tag, Exchange, Routing_key}, _Counter}, Data) ->
    io:format("gen_consumer: Garbage collecting event ~p~n", [{basic_deliver, Consumer_tag, Delivery_tag, Exchange, Routing_key}]),
    {keep_state, Data};
s9(_EventType, {_Pid, {basic_cancel2, Consumer_tag, Nowait}, _Counter}, Data) ->
    io:format("gen_consumer: Garbage collecting event ~p~n", [{basic_cancel2, Consumer_tag, Nowait}]),
    {keep_state, Data};
s9(_EventType, {_Pid, {basic_cancel_ok2, Consumer_tag}, _Counter}, Data) ->
    io:format("gen_consumer: Garbage collecting event ~p~n", [{basic_cancel_ok2, Consumer_tag}]),
    {keep_state, Data};
s9(_EventType, {_Pid, {basic_cancel, Consumer_tag, Nowait}, _Counter}, Data) ->
    io:format("gen_consumer: Garbage collecting event ~p~n", [{basic_cancel, Consumer_tag, Nowait}]),
    {keep_state, Data};
s9(_EventType, {_Pid, {basic_cancel_ok, Consumer_tag}, _Counter}, Data) ->
    io:format("gen_consumer: Garbage collecting event ~p~n", [{basic_cancel_ok, Consumer_tag}]),
    {keep_state, Data}.

-spec s14(EventType :: term(), {atom()}, state_data()) -> {next_state, s9, state_data()}.
s14(EventType, {processing_complete}, Data) ->
    CallbackModule = get(callback_module),
    CallbackModule:s14(EventType, {processing_complete}, Data).

-spec send_s14_processing_complete(ChannelPid :: pid(), Delivery_tag :: term(), Data :: state_data()) -> ok.
send_s14_processing_complete(ChannelPid, Delivery_tag, Data) ->
    Counter = Data#state_data.mc_counter_1,
    gen_statem:cast(ChannelPid, {self(), {processing_complete, Delivery_tag}, Counter}).

-spec send_s13_basic_cancel(ChannelPid :: pid(), Consumer_tag :: term(), Nowait :: term(), Data :: state_data()) -> ok.
send_s13_basic_cancel(ChannelPid, Consumer_tag, Nowait, Data) ->
    Counter = Data#state_data.mc_counter_1,
    gen_statem:cast(ChannelPid, {self(), {basic_cancel, Consumer_tag, Nowait}, Counter}).

-spec s1(EventType :: term(), {atom()}, state_data()) ->
    {next_state, s3, state_data(), [{next_event, internal, {basic_consume}}]} |
    {keep_state, state_data()}.
s1(EventType, {register_default_consumer}, Data) ->
    CallbackModule = get(callback_module),
    CallbackModule:s1(EventType, {register_default_consumer}, Data).

-spec code_change(OldVsn :: term(), StateName :: atom(), StateData :: state_data(), Extra :: term()) ->
    {ok, state_data()}.
code_change(_Vsn, _StateName, StateData, _Extra) ->
    {ok, StateData}.

-spec terminate(Reason :: term(), State :: atom(), Data :: state_data()) -> ok.
terminate(_Reason, _State, _StateData) ->
    ok.
