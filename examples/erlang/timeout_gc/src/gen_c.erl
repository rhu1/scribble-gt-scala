% -*- erlang -*-
-module(gen_c).
-behaviour(gen_statem).

-export([init/1, 
	 callback_mode/0, 
	 code_change/4, 
	 terminate/3, 
	 start_link/2, 
	 s4/3, 
	 s5/3, 
	 send_s6_a5/2, 
	 s6/3
	 ]).

-include("c.hrl").
-type state_data() :: #state_data{mc_counter_1 :: integer(), a_pid :: pid() | undefined, b_pid :: pid() | undefined}.

% ---- Mixed Choice identifiers and path tags ----
-define(MC1, mc1).
-define(PATH_LEFT,  [{?MC1, left}]).
-define(PATH_RIGHT, [{?MC1, right}]).

% ---- Callback contracts (callback does NOT see the path) ----
-callback s4(EventType :: term(), {pid(), {term()}}, state_data()) ->
    {next_state, s5, state_data()} | {keep_state, state_data(), [postpone]} | {stop, normal, state_data()}.
-callback s5(term(), {pid(), {atom(), term()}}, state_data()) ->
    {keep_state, state_data(), [postpone]} | {stop, normal, state_data()} | {next_state, s6, state_data(), [{next_event, internal, {a5}}]} | {keep_state, state_data()}.
-callback s6(EventType :: term(), {atom()}, state_data()) -> {stop, normal, state_data()}.
-callback init(Args :: list()) -> 
	{ok, s4, state_data()}.

-spec start_link(CallbackModule :: module(), Args :: list()) ->
    {ok, pid()} | {error, term()}.
start_link(CallbackModule, Args) ->
    case code:ensure_loaded(CallbackModule) of
        {module, CallbackModule} ->
            gen_statem:start_link({local, CallbackModule}, gen_c, {CallbackModule, Args}, [{debug, [trace, {log_to_file, "c_debug.log"}]}]);
        {error, Reason} ->
            {error, Reason}
    end.

-spec callback_mode() -> state_functions.
callback_mode() ->
    state_functions.

-spec init({CallbackModule :: module(), Args :: list()}) -> 
	{ok, s4, state_data()}.
init({CallbackModule, _Args}) ->
    io:format("c: Initializing with callback module ~p~n", [CallbackModule]),
    put(callback_module, CallbackModule),
    put(commit_map, #{}),
    CallbackModule:init([]).

%% -------- Internal helpers for purge (gc) --------
get_commit() ->
    case get(commit_map) of
        undefined -> #{};
        M -> M
    end.

set_commit(M) -> put(commit_map, M), M.

commit_side(Side) when Side =:= left; Side =:= right ->
    M0 = get_commit(),
    set_commit(maps:put(?MC1, Side, M0)).

-spec stale([{atom(), left | right}]) -> boolean().
stale(Path) when is_list(Path) ->
    M = get_commit(),
    lists:any(fun
        ({?MC1, left})  -> case maps:get(?MC1, M, none) of right -> true; _ -> false end;
        ({?MC1, right}) -> case maps:get(?MC1, M, none) of left  -> true; _ -> false end;
        (_) -> false
    end, Path).

%% -------- State s4 --------
-spec s4(EventType :: term(), {pid(), {term()}, list()}, state_data()) ->
    {next_state, s5, state_data()} |
    {keep_state, state_data(), [postpone]} |
    {stop, normal, state_data()}.
% Future message a3: postpone in s4
s4(_EventType, {_Pid, {a3}, _Pi}, Data) ->
    io:format("gen_c[s4]: Postponing future event ~p~n", [[a3]]),
    {keep_state, Data, [postpone]};
% Receive a2 (LEFT) or TOc (RIGHT): purge if stale; else commit and deliver
s4(EventType, {APid, {a2}, Pi}, Data) ->
    case stale(Pi) of
        true ->
            io:format("gen_c[s4]: Purging stale event ~p~n", [[a2]]),
            {keep_state, Data};
        false ->
            commit_side(left),
            CallbackModule = get(callback_module),
            CallbackModule:s4(EventType, {APid, {a2}}, Data)
    end;
s4(EventType, {BPid, {'TOc'}, Pi}, Data) ->
    case stale(Pi) of
        true ->
            io:format("gen_c[s4]: Purging stale event ~p~n", [['TOc']]),
            {keep_state, Data};
        false ->
            commit_side(right),
            CallbackModule = get(callback_module),
            CallbackModule:s4(EventType, {BPid, {'TOc'}}, Data)
    end.

%% -------- State s5 --------
-spec s5(term(), {pid(), {atom(), term()}, list()}, state_data()) ->
    {keep_state, state_data(), [postpone]} |
    {stop, normal, state_data()} |
    {next_state, s6, state_data(), [{next_event, internal, {a5}}]} |
    {keep_state, state_data()}.
% Incoming TOc or a3: purge if stale; else deliver
s5(EventType, {BPid, {'TOc'}, Pi}, Data) ->
    case stale(Pi) of
        true ->
            io:format("gen_c[s5]: Purging stale event ~p~n", [['TOc']]),
            {keep_state, Data};
        false ->
            CallbackModule = get(callback_module),
            CallbackModule:s5(EventType, {BPid, {'TOc'}}, Data)
    end;
s5(EventType, {BPid, {a3}, Pi}, Data) ->
    case stale(Pi) of
        true ->
            io:format("gen_c[s5]: Purging stale event ~p~n", [[a3]]),
            {keep_state, Data};
        false ->
            CallbackModule = get(callback_module),
            CallbackModule:s5(EventType, {BPid, {a3}}, Data)
    end.

%% -------- State s6 --------
-spec s6(EventType :: term(), {atom()}, state_data()) -> {stop, normal, state_data()}.
s6(EventType, {a5}, Data) ->
    CallbackModule = get(callback_module),
    CallbackModule:s6(EventType, {a5}, Data).

%% -------- Send helpers attach π-paths --------
-spec send_s6_a5(APid :: pid(), _Data :: state_data()) -> ok.
send_s6_a5(APid, _Data) ->
    gen_statem:cast(APid, {self(), {a5}, ?PATH_LEFT}).

-spec code_change(OldVsn :: term(), StateName :: atom(), StateData :: state_data(), Extra :: term()) ->
    {ok, state_data()}.
code_change(_Vsn, _StateName, StateData, _Extra) ->
    {ok, StateData}.

-spec terminate(Reason :: term(), State :: atom(), Data :: state_data()) -> ok.
terminate(_Reason, _State, _StateData) ->
    ok.
