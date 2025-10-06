%%%-------------------------------------------------------------------
%% @doc interleaving public API
%% @end
%%%-------------------------------------------------------------------

-module(interleaving_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    %% Ensure global turn is reset on app start
    catch turn:reset(),
    interleaving_sup:start_link().

stop(_State) ->
    ok.
