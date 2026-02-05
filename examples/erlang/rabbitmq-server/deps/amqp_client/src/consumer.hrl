-record(state_data, {
    mc_counter_2 = 0 :: integer(),
    mc_counter_1 = 0 :: integer(),
    channel_pid :: pid() | undefined,
    server_pid  :: pid() | undefined,
    consumer_tag = <<>> :: binary(),      % AMQP consumer tag
    no_ack = false :: boolean()           % AMQP no_ack flag
}).

