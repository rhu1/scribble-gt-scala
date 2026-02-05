%%-------------------------------------------------------------------
%% @doc Interrupt demo role: `p`.
%%
%% Role implementation module: implements generated behaviour `gen_p`.
%% Protocol source: `examples/scribble/Interrupt.scr`.
%%-------------------------------------------------------------------

-module(p).
-behaviour(gen_p).

-export([
  init/1,
  callback_mode/0,
  start_link/0,
  s4/3,
  s5/3,
  s7/3,
  s10/3
]).

-include("p.hrl").
%% state_data record is defined in p.hrl (mc_path + peer pids). Keep type alias in sync.
-type state_data() :: #state_data{}.

-spec start_link() -> {ok, pid()} | {error, term()}.
start_link() ->
    gen_p:start_link(?MODULE, []).

-spec callback_mode() -> state_functions.
callback_mode() ->
    state_functions.

-spec init(list()) -> {ok, s4, state_data(), [{next_event, internal, {'Start'}}]}.
init([]) ->
    Data = #state_data{},
    io:format("p initialized ~n", []),
    {ok, s4, Data, [{next_event, internal, {'Start'}}]}.

%% ---- s4 (MC entry) ----
-spec s4(internal | cast, {'Start'} | {pid(), {'Interrupt'}}, state_data()) ->
    {next_state, s5, state_data()} |
    {keep_state, state_data()} |
    {stop, normal, state_data()}.

s4(internal, {'Start'}, Data) ->
    NewData = connection(Data),
    QPid = NewData#state_data.q_pid,
    io:format("P: s4 Sending Start to Q ~p~n", [QPid]),
    gen_p:send_s4_Start(QPid, NewData),
    {next_state, s5, NewData};

s4(cast, {QPid, {'Interrupt'}}, Data) ->
    io:format("P: s4 Received Interrupt from Q ~p ~n", [QPid]),
    {stop, normal, Data}.

%% ---- s5 ----
-spec s5(internal | cast, {'More'} | {'Stop'} | {pid(), {'Interrupt'}}, state_data()) ->
    {next_state, s10, state_data()} |
    {next_state, s7, state_data()} |
    {keep_state, state_data()} |
    {stop, normal, state_data()}.

s5(internal, {'Stop'}, Data) ->
    {next_state, s10, Data};

s5(internal, {'More'}, #state_data{q_pid = QPid} = Data) ->
    io:format("P: s5 Sending More to Q ~n", []),
    gen_p:send_s5_More(QPid, Data),
    {next_state, s7, Data};

s5(cast, {QPid, {'Interrupt'}}, Data) ->
    io:format("P: s5 Received Interrupt from Q ~p ~n", [QPid]),
    {stop, normal, Data}.

%% ---- s7 ----
-spec s7(internal | cast, {'More'} | {pid(), {'Interrupt'}}, state_data()) ->
    {keep_state, state_data()} |
    {stop, normal, state_data()}.

s7(internal, {'More'}, #state_data{q_pid = QPid} = Data) ->
    io:format("P: s7 Sending More to Q ~n", []),
    gen_p:send_s7_More(QPid, Data),
    {keep_state, Data};

s7(cast, {QPid, {'Interrupt'}}, Data) ->
    io:format("P: s7 Received Interrupt from Q ~p ~n", [QPid]),
    {stop, normal, Data}.

%% ---- s10 ----
-spec s10(cast, {pid(), {'Ack'}} | {pid(), {'Interrupt'}}, state_data()) ->
    {keep_state, state_data()} |
    {stop, normal, state_data()}.

s10(cast, {QPid, {'Ack'}}, Data) ->
    io:format("P: s10 Received Ack from Q ~p ~n", [QPid]),
    {stop, normal, Data};

s10(cast, {QPid, {'Interrupt'}}, Data) ->
    io:format("P: s10 Received Interrupt from Q ~p ~n", [QPid]),
    {stop, normal, Data}.

-spec connection(state_data()) -> state_data().
connection(Data) ->
    io:format("p connected ~n", []),
    QPid = case whereis(q) of
        undefined ->
            io:format("q is not available yet. Will retry...~n", []),
            timer:sleep(2000),
            whereis(q);
        Pid_q ->
            Pid_q
    end,
    Data#state_data{q_pid = QPid}.
