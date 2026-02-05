%%%-------------------------------------------------------------------
%% @doc `timeout` OTP application entrypoint.
%%
%% Standard OTP application wiring: starting `timeout_sup` launches the roles
%% for the Timeout demo derived from `examples/scribble/Timeout.scr`.
%%
%% See `README.md` in this directory for run instructions and expected behaviour.
%% @end
%%%-------------------------------------------------------------------

-module(timeout_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    timeout_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
