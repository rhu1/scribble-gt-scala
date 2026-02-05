%%%-------------------------------------------------------------------
%% @doc `interrupt` OTP application entrypoint.
%%
%% Standard OTP application wiring: starting `interrupt_sup` launches the
%% protocol roles for the Interrupt demo.
%%
%% See `README.md` in this directory for run instructions and expected behaviour.
%% @end
%%%-------------------------------------------------------------------

-module(interrupt_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    interrupt_sup:start_link().

stop(_State) ->
    ok.
