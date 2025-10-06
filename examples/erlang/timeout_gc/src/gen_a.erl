% -*- erlang -*-
-module(gen_a).
-behaviour(gen_statem).

-export([init/1, 
	 callback_mode/0, 
	 code_change/4, 
	 terminate/3, 
	 start_link/2, 
	 send_s4_a1/2, 
	 s4/3, 
	 send_s5_a2/2, 
	 s5/3, 
	 s6/3, 
	 s7/3
	 ]).

-include("a.hrl").
-type state_data() :: #state_data{mc_counter_1 :: integer(), b_pid :: pid() | undefined, c_pid :: pid() | undefined}.

% ---- Mixed Choice identifiers and path tags ----
-define(MC1, mc1).
-define(PATH_LEFT,  [{?MC1, left}]).
-define(PATH_RIGHT, [{?MC1, right}]).

% ---- Callback contracts (callback does NOT see the path) ----
-callback s4(EventType :: term(), {pid(), {term()} | {atom()}}, state_data()) ->
    {next_state, s5, state_data()} | {keep_state, state_data(), [postpone]} | {stop, normal, state_data()}.
-callback s5(EventType :: term(), {atom()} | {pid(), {term()}}, state_data()) ->
    {next_state, s6, state_data()} | {keep_state, state_data(), [postpone]} | {stop, normal, state_data()}.
-callback s6(term(), {pid(), {atom(), term()}}, state_data()) ->
    {keep_state, state_data(), [postpone]} | {next_state, s7, state_data()} | {stop, normal, state_data()}.
-callback s7(term(), {pid(), {atom(), term()}}, state_data()) ->
    {keep_state, state_data(), [postpone]} | {stop, normal, state_data()}.
-callback init(Args :: list()) -> 
	{ok, s4, state_data(), [{next_event, internal, {a1}}]}.

-spec start_link(CallbackModule :: module(), Args :: list()) ->
    {ok, pid()} | {error, term()}.
start_link(CallbackModule, Args) ->
    case code:ensure_loaded(CallbackModule) of
        {module, CallbackModule} ->
            gen_statem:start_link({local, CallbackModule}, gen_a, {CallbackModule, Args}, [{debug, [trace, {log_to_file, "a_debug.log"}]}]);
        {error, Reason} ->
            {error, Reason}
    end.

-spec callback_mode() -> state_functions.
callback_mode() ->
    state_functions.

-spec init({CallbackModule :: module(), Args :: list()}) -> 
	{ok, s4, state_data(), [{next_event, internal, {a1}}]}.
init({CallbackModule, _Args}) ->
    io:format("a: Initializing with callback module ~p~n", [CallbackModule]),
    put(callback_module, CallbackModule),
    % initialize empty commitment map
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
-spec s4(EventType :: term(), {pid(), {term()}, list()} | {atom()}, state_data()) ->
    {next_state, s5, state_data()} |
    {keep_state, state_data(), [postpone]} |
    {stop, normal, state_data()}.
% Future messages for this state: postpone deterministically
s4(_EventType, {_Pid, {a4}, _Pi}, Data) ->
    io:format("gen_a[s4]: Postponing future event ~p~n", [[a4]]),
    {keep_state, Data, [postpone]};
s4(_EventType, {_Pid, {a5}, _Pi}, Data) ->
    io:format("gen_a[s4]: Postponing future event ~p~n", [[a5]]),
    {keep_state, Data, [postpone]};
% Local internal choice: sending a1 commits us LEFT
s4(EventType, {a1}, Data) ->
    commit_side(left),
    CallbackModule = get(callback_module),
    CallbackModule:s4(EventType, {a1}, Data);
% Receive TOa: purge if stale; otherwise commit RIGHT then deliver
s4(EventType, {BPid, {'TOa'}, Pi}, Data) ->
    case stale(Pi) of
        true ->
            io:format("gen_a[s4]: Purging stale event ~p~n", [['TOa']]),
            {keep_state, Data};
        false ->
            commit_side(right),
            CallbackModule = get(callback_module),
            CallbackModule:s4(EventType, {BPid, {'TOa'}}, Data)
    end.

%% -------- State s5 --------
-spec s5(EventType :: term(), {atom()} | {pid(), {term()}, list()}, state_data()) ->
    {next_state, s6, state_data()} |
    {keep_state, state_data(), [postpone]} |
    {stop, normal, state_data()}.
% Future messages for this state: postpone deterministically
s5(_EventType, {_Pid, {a4}, _Pi}, Data) ->
    io:format("gen_a[s5]: Postponing future event ~p~n", [[a4]]),
    {keep_state, Data, [postpone]};
s5(_EventType, {_Pid, {a5}, _Pi}, Data) ->
    io:format("gen_a[s5]: Postponing future event ~p~n", [[a5]]),
    {keep_state, Data, [postpone]};
% Internal next step a2
s5(EventType, {a2}, Data) ->
    CallbackModule = get(callback_module),
    CallbackModule:s5(EventType, {a2}, Data);
% Receive TOa here too: purge if stale; otherwise commit RIGHT then deliver
s5(EventType, {BPid, {'TOa'}, Pi}, Data) ->
    case stale(Pi) of
        true ->
            io:format("gen_a[s5]: Purging stale event ~p~n", [['TOa']]),
            {keep_state, Data};
        false ->
            commit_side(right),
            CallbackModule = get(callback_module),
            CallbackModule:s5(EventType, {BPid, {'TOa'}}, Data)
    end.

%% -------- State s6 --------
-spec s6(term(), {pid(), {atom(), term()}, list()}, state_data()) ->
    {keep_state, state_data(), [postpone]} |
    {next_state, s7, state_data()} |
    {stop, normal, state_data()}.
% Future message (a5) should be postponed in s6
s6(_EventType, {_Pid, {a5}, _Pi}, Data) ->
    io:format("gen_a[s6]: Postponing future event ~p~n", [[a5]]),
    {keep_state, Data, [postpone]};
% Receive a4 (LEFT branch): drop if stale, else deliver
s6(EventType, {BPid, {a4}, Pi}, Data) ->
    case stale(Pi) of
        true ->
            io:format("gen_a[s6]: Purging stale event ~p~n", [[a4]]),
            {keep_state, Data};
        false ->
            CallbackModule = get(callback_module),
            CallbackModule:s6(EventType, {BPid, {a4}}, Data)
    end;
% Receive TOa (RIGHT branch): drop if stale, else commit RIGHT then deliver
s6(EventType, {BPid, {'TOa'}, Pi}, Data) ->
    case stale(Pi) of
        true ->
            io:format("gen_a[s6]: Purging stale event ~p~n", [['TOa']]),
            {keep_state, Data};
        false ->
            commit_side(right),
            CallbackModule = get(callback_module),
            CallbackModule:s6(EventType, {BPid, {'TOa'}}, Data)
    end.

%% -------- State s7 --------
-spec s7(term(), {pid(), {atom(), term()}, list()}, state_data()) ->
    {keep_state, state_data(), [postpone]} |
    {stop, normal, state_data()}.
% Only a5 is meaningful here
s7(EventType, {CPid, {a5}, Pi}, Data) ->
    case stale(Pi) of
        true ->
            io:format("gen_a[s7]: Purging stale event ~p~n", [[a5]]),
            {keep_state, Data};
        false ->
            CallbackModule = get(callback_module),
            CallbackModule:s7(EventType, {CPid, {a5}}, Data)
    end.

%% -------- Send helpers attach π-paths --------
-spec send_s5_a2(CPid :: pid(), Data :: state_data()) -> ok.
send_s5_a2(CPid, _Data) ->
    gen_statem:cast(CPid, {self(), {a2}, ?PATH_LEFT}).

-spec send_s4_a1(BPid :: pid(), _Data :: state_data()) -> ok.
send_s4_a1(BPid, _Data) ->
    gen_statem:cast(BPid, {self(), {a1}, ?PATH_LEFT}).

-spec code_change(OldVsn :: term(), StateName :: atom(), StateData :: state_data(), Extra :: term()) ->
    {ok, state_data()}.
code_change(_Vsn, _StateName, StateData, _Extra) ->
    {ok, StateData}.

-spec terminate(Reason :: term(), State :: atom(), Data :: state_data()) -> ok.
terminate(_Reason, _State, _StateData) ->
    ok.
