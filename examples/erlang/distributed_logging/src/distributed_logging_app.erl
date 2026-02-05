%%%-------------------------------------------------------------------
%% @doc `distributed_logging` OTP application entrypoint.
%%
%% Standard OTP application wiring: starting the supervision tree
%% (`distributed_logging_sup`) starts all protocol roles for the demo.
%%
%% See `README.md` in this directory for expected behaviour and usage.
%% @end
%%%-------------------------------------------------------------------

-module(distributed_logging_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    distributed_logging_sup:start_link().

stop(_State) ->
    ok.
