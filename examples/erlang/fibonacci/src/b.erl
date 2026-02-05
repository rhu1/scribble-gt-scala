-module(b).
-behaviour(gen_b).

-export([init/1, callback_mode/0, start_link/0,
         s5/3,
         s6/3,
         s9/3]).

-include("b.hrl").

%% Keep the state_data() type aligned with the generated record in b.hrl.
-type state_data() :: #state_data{}.

-spec start_link() -> {ok, pid()} | {error, term()}.
start_link() ->
  gen_b:start_link(?MODULE, []).

-spec callback_mode() -> state_functions.
callback_mode() ->
  state_functions.

-spec init(list()) -> {ok, s5, state_data(), [{next_event, internal, {error}}]}.
init([]) ->
  APid = case whereis(a) of
           undefined ->
             io:format("a is not available yet. Will retry...~n", []),
             timer:sleep(1000),
             whereis(a);
           Pid ->
             Pid
         end,
  %% Notify a of our pid (matches examples/erlang/fibonacci)
  APid ! {b_pid, self()},

  %% Fibonacci state (kept outside the generated record)
  put(prev_value, 0),
  put(curr_value, 0),

  Data = #state_data{a_pid = APid},
  io:format("b initialized~n", []),
  %% internal {error} just idles unless you want to demo the error path
  {ok, s5, Data, [{next_event, internal, {error}}]}.

%% ===== States =====

-spec s5(internal | cast, {error} | {pid(), {fibonacci, term()}} | {pid(), {stop}}, state_data()) ->
  {keep_state, state_data()} |
  {next_state, s6, state_data()} |
  {next_state, s9, state_data()} |
  {stop, normal, state_data()}.

s5(internal, {error}, Data) ->
  %% In this example we never raise error; keep running.
  {keep_state, Data};

s5(cast, {APid, {stop}}, #state_data{a_pid = APid} = Data) ->
  io:format("B: s5 Received stop from A, will ack and stop~n", []),
  {next_state, s9, Data, [{next_event, internal, {ack}}]};

s5(cast, {APid, {fibonacci, {Num}}}, #state_data{a_pid = APid} = Data) when is_integer(Num) ->
  %% Update our local Fibonacci state based on input.
  Curr = case get(curr_value) of undefined -> 0; V1 -> V1 end,
  put(prev_value, Curr),
  put(curr_value, Num),
  {next_state, s6, Data, [{next_event, internal, {fibonacci}}]}.

-spec s6(internal, {fibonacci}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.

s6(internal, {fibonacci}, #state_data{a_pid = APid} = Data) ->
  Prev = case get(prev_value) of undefined -> 0; V2 -> V2 end,
  Curr = case get(curr_value) of undefined -> 0; V3 -> V3 end,
  Next = Prev + Curr,
  put(prev_value, Curr),
  put(curr_value, Next),
  io:format("B: s6 Sending fibonacci ~p to A~n", [Next]),
  %% Use generated wrapper/API (this sends {fibonacci,{Num}} with the correct Path).
  gen_b:send_s6_fibonacci(APid, Next, Data),
  {next_state, s5, Data}.

%% Ack state
-spec s9(internal, {ack}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
s9(internal, {ack}, #state_data{a_pid = APid} = Data) ->
  io:format("B: s9 Sending ack to A~n", []),
  gen_b:send_s9_ack(APid, Data),
  {stop, normal, Data}.
