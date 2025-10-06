%%%-------------------------------------------------------------------
%% @doc interleaving top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(interleaving_sup).

-behaviour(supervisor).

-export([start_link/0]).

-export([init/1]).

-define(SERVER, ?MODULE).

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

init([]) ->
    SupFlags = #{strategy => one_for_one, intensity => 5, period => 10},
    ChildSpecs = [
        #{id => alice,
            start => {alice, start_link, []},
            restart => temporary,
            shutdown => 5000,
            type => worker},
        #{id => bob,
            start => {bob, start_link, []},
            restart => temporary,
            shutdown => 5000,
            type => worker},
        #{id => carol,
            start => {carol, start_link, []},
            restart => temporary,
            shutdown => 5000,
            type => worker}
    ],
    {ok, {SupFlags, ChildSpecs}}.