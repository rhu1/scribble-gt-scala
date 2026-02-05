%% This Source Code Form is subject to the terms of the Mozilla Public
%% License, v. 2.0. If a copy of the MPL was not distributed with this
%% file, You can obtain one at https://mozilla.org/MPL/2.0/.
%%
%% Copyright (c) 2007-2025 Broadcom. All Rights Reserved. The term “Broadcom” refers to Broadcom Inc. and/or its subsidiaries. All rights reserved.
%%

-include("amqp_client.hrl").

% -type state() :: any().
% -type consume() :: #'basic.consume'{}.
% -type consume_ok() :: #'basic.consume_ok'{}.
% -type cancel() :: #'basic.cancel'{}.
% -type cancel_ok() :: #'basic.cancel_ok'{}.
% -type deliver() :: #'basic.deliver'{}.
% -type from() :: any().
% -type reason() :: any().
% -type ok_error() :: {ok, state()} | {error, reason(), state()}.

% -spec init([any()]) -> {ok, state()}.
% -spec handle_consume(consume(), pid(), state()) -> ok_error().
% -spec handle_consume_ok(consume_ok(), consume(), state()) ->
%                                   ok_error().
% -spec handle_cancel(cancel(), state()) -> ok_error().
% -spec handle_server_cancel(cancel(), state()) -> ok_error().
% -spec handle_cancel_ok(cancel_ok(), cancel(), state()) -> ok_error().
% -spec handle_deliver(deliver(), #amqp_msg{}, state()) -> ok_error().
% -spec handle_info(any(), state()) -> ok_error().
% -spec handle_call(any(), from(), state()) ->
%                            {reply, any(), state()} | {noreply, state()} |
%                             {error, reason(), state()}.
% -spec terminate(any(), state()) -> state().

%% amqp_gen_consumer_spec.hrl
%% Shared types & records for the selective consumer behaviour
-define(DEFAULT_CHANNEL_PID, undefined).
-define(DEFAULT_SERVER_PID, undefined).

%% State data record capturing channel and server pids
-record(state_data, {
    channel_pid = ?DEFAULT_CHANNEL_PID :: pid(),  % the AMQP channel process
    server_pid  = ?DEFAULT_SERVER_PID  :: pid()   % the AMQP server process (if needed)
}).

%% Type alias for the state_data record
-type state_data() :: #state_data{}.

%% The set of AMQP methods your callbacks handle
-type amqp_method() ::
      #'basic.consume'{}
    | #'basic.consume_ok'{}
    | #'basic.cancel'{}
    | #'basic.cancel_ok'{}
    | #'basic.deliver'{}.

%% The return type for synchronous calls
-type call_return() ::
      {reply, term(), state_data()}
    | {noreply, state_data()}
    | {stop, Term :: term(), state_data()}.

%% The return type for info messages
-type info_return() ::
      {keep_state, state_data()}
    | {next_state, StateName :: atom(), state_data()}.
