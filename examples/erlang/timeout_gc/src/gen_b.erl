% -*- erlang -*-
-module(gen_b).
-behaviour(gen_statem).

-export([init/1, 
	 callback_mode/0, 
	 code_change/4, 
	 terminate/3, 
	 start_link/2, 
	 send_s5_TOa/2, 
	 s5/3, 
	 send_s6_a3/2, 
	 s6/3, 
	 send_s7_a4/2, 
	 s7/3, 
	 send_s3_TOc/2, 
	 s3/3
	 ]).

-include("b.hrl").
-type state_data() :: #state_data{mc_counter_1 :: integer(), a_pid :: pid() | undefined, c_pid :: pid() | undefined}.

% ---- Mixed Choice identifiers and path tags ----
-define(MC1, mc1).
-define(PATH_LEFT,  [{?MC1, left}]).
-define(PATH_RIGHT, [{?MC1, right}]).

% ---- Callback contracts ----
-callback s3(EventType :: term(), {atom()}, state_data()) -> {stop, normal, state_data()}.
-callback s5(EventType :: term(), {atom()} | {pid(), {term()}}, state_data()) ->
    {next_state, s3, state_data(), [{next_event, internal, {'TOc'}}]} |
    {keep_state, state_data()} |
    {keep_state, state_data(), [postpone]} |
    {next_state, s6, state_data(), [{next_event, internal, {a3}}]}.
-callback s6(EventType :: term(), {atom()}, state_data()) -> {next_state, s7, state_data(), [{next_event, internal, {a4}}]} | {keep_state, state_data()}.
-callback s7(EventType :: term(), {atom()}, state_data()) -> {stop, normal, state_data()}.
-callback init(Args :: list()) -> 
	{ok, s5, state_data(), [{next_event, internal, {'TOa'}}]}.

-spec start_link(CallbackModule :: module(), Args :: list()) ->
    {ok, pid()} | {error, term()}.
start_link(CallbackModule, Args) ->
    case code:ensure_loaded(CallbackModule) of
        {module, CallbackModule} ->
            gen_statem:start_link({local, CallbackModule}, gen_b, {CallbackModule, Args}, [{debug, [trace, {log_to_file, "b_debug.log"}]}]);
        {error, Reason} ->
            {error, Reason}
    end.

-spec callback_mode() -> state_functions.
callback_mode() ->
    state_functions.

-spec init({CallbackModule :: module(), Args :: list()}) -> 
	{ok, s5, state_data(), [{next_event, internal, {'TOa'}}]}.
init({CallbackModule, _Args}) ->
    io:format("b: Initializing with callback module ~p~n", [CallbackModule]),
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

%% -------- State s3 --------
-spec s3(EventType :: term(), {atom()}, state_data()) -> {stop, normal, state_data()}.
s3(EventType, {'TOc'}, Data) ->
    CallbackModule = get(callback_module),
    CallbackModule:s3(EventType, {'TOc'}, Data).

%% -------- State s5 --------
-spec s5(EventType :: term(), {atom()} | {pid(), {term()}, list()}, state_data()) ->
    {next_state, s3, state_data(), [{next_event, internal, {'TOc'}}]} |
    {keep_state, state_data()} |
    {keep_state, state_data(), [postpone]} |
    {next_state, s6, state_data(), [{next_event, internal, {a3}}]}.
% Incoming a1: purge if stale; else commit LEFT and deliver
s5(EventType, {APid, {a1}, Pi}, Data) ->
    case stale(Pi) of
        true ->
            io:format("gen_b[s5]: Purging stale event ~p~n", [[a1]]),
            {keep_state, Data};
        false ->
            commit_side(left),
            CallbackModule = get(callback_module),
            CallbackModule:s5(EventType, {APid, {a1}}, Data)
    end;
% Internal TOa choice: commit RIGHT and deliver
s5(EventType, {'TOa'}, Data) ->
    commit_side(right),
    CallbackModule = get(callback_module),
    CallbackModule:s5(EventType, {'TOa'}, Data).

%% -------- State s6 --------
-spec s6(EventType :: term(), {atom()}, state_data()) ->
    {next_state, s7, state_data(), [{next_event, internal, {a4}}]} |
    {keep_state, state_data()}.
s6(EventType, {a3}, Data) ->
    CallbackModule = get(callback_module),
    CallbackModule:s6(EventType, {a3}, Data).

%% -------- State s7 --------
-spec s7(EventType :: term(), {atom()}, state_data()) -> {stop, normal, state_data()}.
s7(EventType, {a4}, Data) ->
    CallbackModule = get(callback_module),
    CallbackModule:s7(EventType, {a4}, Data).

%% -------- Send helpers attach π-paths --------
-spec send_s5_TOa(APid :: pid(), Data :: state_data()) -> ok.
send_s5_TOa(APid, _Data) ->
    gen_statem:cast(APid, {self(), {'TOa'}, ?PATH_RIGHT}).

-spec send_s3_TOc(CPid :: pid(), _Data :: state_data()) -> ok.
send_s3_TOc(CPid, _Data) ->
    gen_statem:cast(CPid, {self(), {'TOc'}, ?PATH_RIGHT}).

-spec send_s7_a4(APid :: pid(), _Data :: state_data()) -> ok.
send_s7_a4(APid, _Data) ->
    gen_statem:cast(APid, {self(), {a4}, ?PATH_LEFT}).

-spec send_s6_a3(CPid :: pid(), _Data :: state_data()) -> ok.
send_s6_a3(CPid, _Data) ->
    gen_statem:cast(CPid, {self(), {a3}, ?PATH_LEFT}).

-spec code_change(OldVsn :: term(), StateName :: atom(), StateData :: state_data(), Extra :: term()) ->
    {ok, state_data()}.
code_change(_Vsn, _StateName, StateData, _Extra) ->
    {ok, StateData}.

-spec terminate(Reason :: term(), State :: atom(), Data :: state_data()) -> ok.
terminate(_Reason, _State, _StateData) ->
    ok.
