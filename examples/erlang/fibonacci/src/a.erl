%%%-------------------------------------------------------------------
%%% @doc Fibonacci demo role: `a`.
%%%
%%% Role implementation module: this code implements the generated behaviour
%%% `gen_a`.
%%% Protocol source: `examples/scribble/Fibonacci.scr`.
%%%-------------------------------------------------------------------

-module(a).

-behaviour(gen_a).

%% Public API
-export([start_link/0, callback_mode/0]).

%% gen_<role> callbacks (delegated via behaviour)
-export([init/1, code_change/4, terminate/3, s5/3, s6/3, s9/3]).

%% Types & records
-include("a.hrl").
%% Expect #state_data{} to be defined in the HRL. If not, uncomment:
%% -record(state_data, {}).

-ifdef(TEST).
-compile(export_all).
-endif.

%% Optional: public types for dialyzer users
-export_type([state_data/0]).
-type state_data() :: #state_data{}.

%% ===== API =====

-spec start_link() -> {ok, pid()} | {error, term()}.
start_link() ->
    gen_a:start_link(?MODULE, []).

-spec callback_mode() -> state_functions.
callback_mode() ->
    state_functions.

%% ===== gen_<role> behaviour =====

-spec init(list()) ->
    {ok, s5, state_data()} | {ok, s5, state_data(), [{next_event, internal, {fibonacci_1}}] }.
init([]) ->
    put(prev_value, 0),
    put(curr_value, 1),
    put(iter, 0),
    put(limit, application:get_env(fibonacci, limit, 10)),

    Data = #state_data{b_pid = undefined},
    io:format("a initialized~n", []),

    %% Kick off the protocol
    {ok, s5, Data, [{next_event, internal, {fibonacci_1}}]}.

%% ---------- State functions (state_functions mode) ----------

%% Mixed-choice entry state

-spec s5(internal | cast, {fibonacci_1} | {stop} | {pid(), {error}}, state_data()) ->
    {next_state, s6, state_data()} |
    {next_state, s9, state_data()} |
    {keep_state, state_data()} |
    {stop, normal, state_data()}.

s5(cast, {BPid, {error}}, #state_data{b_pid = BPid} = Data) ->
    io:format("A: s5 Received error from B~n", []),
    {stop, normal, Data};

s5(internal, {fibonacci_1}, Data0) ->
    Data = connect(Data0),
    BPid = Data#state_data.b_pid,
    Curr = case get(curr_value) of undefined -> 1; V1 -> V1 end,
    io:format("A: s5 Sending fibonacci_1 ~p to B~n", [Curr]),
    gen_a:send_s5_fibonacci_1(BPid, Curr, Data),
    {next_state, s6, Data};

s5(internal, {stop}, Data0) ->
    Data = connect(Data0),
    BPid = Data#state_data.b_pid,
    io:format("A: s5 Sending stop to B~n", []),
    gen_a:send_s5_stop(BPid, Data),
    {next_state, s9, Data}.

-spec s6(cast, {pid(), {error}} | {pid(), {fibonacci_2, {term()}}}, state_data()) ->
    {next_state, s5, state_data(), [{next_event, internal, {fibonacci_1}}]} |
    {next_state, s5, state_data(), [{next_event, internal, {stop}}]} |
    {stop, normal, state_data()}.

s6(cast, {BPid, {error}}, #state_data{b_pid = BPid} = Data) ->
  io:format("A: s6 Received error from B~n", []),
  {stop, normal, Data};

s6(cast, {BPid, {fibonacci_2, {Num}}}, #state_data{b_pid = BPid} = Data) when is_integer(Num) ->
  Prev = case get(prev_value) of undefined -> 0; V2 -> V2 end,
  Curr = case get(curr_value) of undefined -> 1; V3 -> V3 end,
  Next = Prev + Curr,

  put(prev_value, Curr),
  put(curr_value, Next),

  Iter0 = case get(iter) of undefined -> 0; V4 -> V4 end,
  Iter = Iter0 + 1,
  put(iter, Iter),
  Limit = case get(limit) of undefined -> 10; V5 -> V5 end,

  io:format("A: s6 Received fibonacci_2 ~p from B, next is ~p (iter=~p)~n", [Num, Next, Iter]),

  %% Deterministic stop after N iterations (keep it in sync with examples/erlang/fibonacci)
  case Iter < Limit of
    true  -> {next_state, s5, Data, [{next_event, internal, {fibonacci_1}}]};
    false -> {next_state, s5, Data, [{next_event, internal, {stop}}]}
  end.

-spec s9(cast, {pid(), {ack}} | {pid(), {error}}, state_data()) ->
    {keep_state, state_data()} | {stop, normal, state_data()}.

s9(cast, {BPid, {ack}}, #state_data{b_pid = BPid} = Data) ->
    io:format("A: s9 Received ack from B~n", []),
    {stop, normal, Data};

s9(cast, {BPid, {error}}, #state_data{b_pid = BPid} = Data) ->
    io:format("A: s9 Received error from B~n", []),
    {stop, normal, Data}.


%% ===== misc OTP =====

-spec code_change(term(), atom(), state_data(), term()) -> {ok, state_data()}.
code_change(_OldVsn, _State, Data, _Extra) ->
    {ok, Data}.

-spec terminate(term(), atom(), state_data()) -> ok.
terminate(_Reason, _State, _Data) ->
    ok.

%% ---------- Helpers ----------

-spec connect(state_data()) -> state_data().
connect(Data = #state_data{b_pid = BPid}) when is_pid(BPid) ->
    Data;
connect(Data0) ->
    %% Handshake message sent by role b: APid ! {b_pid, self()}.
    BPid = receive {b_pid, Pid1} when is_pid(Pid1) -> Pid1 end,
    Data0#state_data{b_pid = BPid}.
