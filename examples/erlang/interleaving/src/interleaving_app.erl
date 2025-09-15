%%%-------------------------------------------------------------------
%% @doc interleaving public API
%% @end
%%%-------------------------------------------------------------------

-module(interleaving_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    interleaving_sup:start_link().

stop(_State) ->
    ok.

