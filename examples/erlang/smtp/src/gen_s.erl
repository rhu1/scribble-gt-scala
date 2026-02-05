
%%%-------------------------------------------------------------------
%%% gen_s.erl — generated generic behaviour module (gen_statem)
%%%-------------------------------------------------------------------
-module(gen_s).
-behaviour(gen_statem).

%% Public API
-export([start_link/2, callback_mode/0]).

%% gen_statem callbacks
-export([init/1, code_change/4, terminate/3,
  s1/3,
  s5/3,
  s6/3,
  s8/3,
  s11/3,
  s12/3,
  s13/3,
  s15/3,
  s19/3,
  s20/3,
  s22/3,
  s23/3,
  s27/3,
  s28/3,
  s33/3,
  s34/3,
  s36/3,
  s41/3,
  s44/3,
  s49/3,
  s51/3,
  s53/3,
  send_s1_220/2,
  send_s5_Timeout/2,
  send_s6_EhloCommit/2,
  send_s8_250d/2,
  send_s8_250/2,
  send_s12_220/2,
  send_s15_250/2,
  send_s15_250d/2,
  send_s20_535/2,
  send_s20_235/2,
  send_s23_501/2,
  send_s23_250/2,
  send_s28_250/2,
  send_s33_Timeout/2,
  send_s34_354/2,
  send_s41_250/2,
  send_s44_221/2,
  send_s49_Ack/2,
  send_s51_Ack/2,
  send_s53_AckCommit/2]).

%% Types & records
-include("s.hrl").
-export_type([state_data/0]).
-type state_data() :: #state_data{}.

-callback init(Args :: list()) -> {ok, s1, state_data(), [{next_event, internal, {'220'}}]}.
-callback s1(internal, {'220'}, state_data()) -> {next_state, s5, state_data()} | {next_state, s5, state_data(), [{next_event, internal, {'220'}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s5(internal | cast, {'Timeout'} | {pid(), {'Ehlo'}} | {pid(), {'QuitCommit'}}, state_data()) -> {next_state, s53, state_data()} | {next_state, s6, state_data()} | {next_state, s53, state_data(), [{next_event, internal, {'Timeout'}}] } | {next_state, s6, state_data(), [{next_event, internal, {'Timeout'}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s6(internal, {'EhloCommit'}, state_data()) -> {next_state, s8, state_data()} | {next_state, s8, state_data(), [{next_event, internal, {'EhloCommit'}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s8(internal, {'250'} | {'250d'}, state_data()) -> {next_state, s11, state_data()} | {next_state, s11, state_data(), [{next_event, internal, {'250'}}] } | {next_state, s11, state_data(), [{next_event, internal, {'250d'}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s11(cast, {pid(), {'Quit'}} | {pid(), {'StartTls'}}, state_data()) -> {next_state, s12, state_data()} | {next_state, s51, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s12(internal, {'220'}, state_data()) -> {next_state, s13, state_data()} | {next_state, s13, state_data(), [{next_event, internal, {'220'}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s13(cast, {pid(), {'Ehlo1'}} | {pid(), {'Quit'}}, state_data()) -> {next_state, s15, state_data()} | {next_state, s49, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s15(internal, {'250'} | {'250d'}, state_data()) -> {next_state, s19, state_data()} | {next_state, s19, state_data(), [{next_event, internal, {'250'}}] } | {next_state, s19, state_data(), [{next_event, internal, {'250d'}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s19(cast, {pid(), {'Auth'}} | {pid(), {'Quit'}}, state_data()) -> {next_state, s20, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s20(internal, {'235'} | {'535'}, state_data()) -> {next_state, s22, state_data()} | {next_state, s22, state_data(), [{next_event, internal, {'235'}}] } | {next_state, s22, state_data(), [{next_event, internal, {'535'}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s22(cast, {pid(), {'Mail'}} | {pid(), {'Quit'}}, state_data()) -> {next_state, s23, state_data()} | {next_state, s44, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s23(internal, {'250'} | {'501'}, state_data()) -> {next_state, s27, state_data()} | {next_state, s27, state_data(), [{next_event, internal, {'250'}}] } | {next_state, s27, state_data(), [{next_event, internal, {'501'}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s27(cast, {pid(), {'Bogus'}} | {pid(), {'Rcpt'}}, state_data()) -> {next_state, s28, state_data()} | {next_state, s33, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s28(internal, {'250'}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s33(internal | cast, {'Timeout'} | {pid(), {'Data'}}, state_data()) -> {next_state, s34, state_data()} | {next_state, s34, state_data(), [{next_event, internal, {'Timeout'}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s34(internal, {'354'}, state_data()) -> {next_state, s36, state_data()} | {next_state, s36, state_data(), [{next_event, internal, {'354'}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s36(cast, {pid(), {'DataLine'}} | {pid(), {'EndOfData'}} | {pid(), {'Subject'}}, state_data()) -> {next_state, s41, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s41(internal, {'250'}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s44(internal, {'221'}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s49(internal, {'Ack'}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s51(internal, {'Ack'}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s53(internal, {'AckCommit'}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.

%% ===== API =====
-spec start_link(CallbackModule :: module(), Args :: list()) ->
    {ok, pid()} | {error, term()}.
start_link(CallbackModule, Args) ->
    case code:ensure_loaded(CallbackModule) of
        {module, CallbackModule} ->
            gen_statem:start_link({local, CallbackModule}, gen_s, {CallbackModule, Args}, [{debug, [trace, {log_to_file, "s_debug.log"}]}]);
        {error, Reason} ->
            {error, Reason}
    end.

-spec callback_mode() -> state_functions.
callback_mode() -> state_functions.

%% ===== gen_statem =====
-spec init({module(), list()}) ->
    {ok, s1, state_data(), [{next_event, internal, {'220'}}]}.
init({CallbackModule, _Args}) ->
    io:format("s: Initializing with callback module ~p~n", [CallbackModule]),
    put(callback_module, CallbackModule),
    set_commit(#{}),
    CallbackModule:init([]).

%% ---------- State functions----------
-spec s1(internal, {'220'}, state_data()) -> {next_state, s5, state_data()} | {next_state, s5, state_data(), [{next_event, internal, {'220'}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s1(internal, {'220'}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s1(internal, {'220'}, Data),
        Next;
s1(cast, {_From, _Msg, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s1]: Purging stale early-path event ~p~n", [_Msg]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s1]: Postponing early-path event ~p~n", [_Msg]),
        {keep_state, Data, [postpone]}
    end.

%% Mixed-choice entry state
-spec s5(internal | cast, {'Timeout'} | {pid(), {'QuitCommit'}, list()} | {pid(), {'Ehlo'}, list()}, state_data()) -> {next_state, s53, state_data()} | {next_state, s6, state_data()} | {next_state, s53, state_data(), [{next_event, internal, {'Timeout'}}] } | {next_state, s6, state_data(), [{next_event, internal, {'Timeout'}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s5(internal, {'Timeout'}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s5(internal, {'Timeout'}, Data),
        Next;
s5(cast, {CPid, {'QuitCommit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s5]: Purging stale event ~p~n", [{'QuitCommit'}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s5(cast, {CPid, {'QuitCommit'}}, Data)
               catch error:function_clause ->
                 io:format("gen_s[s5]: Callback had no clause for ~p, postponing~n", [{'QuitCommit'}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {next_state, s2, _} -> commit_entry(mc1, right), Next;
          {next_state, s2, _, _} -> commit_entry(mc1, right), Next;
          {next_state, s6, _} -> commit_entry(mc1, left), Next;
          {next_state, s6, _, _} -> commit_entry(mc1, left), Next;
          _ -> Next
        end
    end;
s5(cast, {CPid, {'Ehlo'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s5]: Purging stale event ~p~n", [{'Ehlo'}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s5(cast, {CPid, {'Ehlo'}}, Data)
               catch error:function_clause ->
                 io:format("gen_s[s5]: Callback had no clause for ~p, postponing~n", [{'Ehlo'}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {next_state, s2, _} -> commit_entry(mc1, right), Next;
          {next_state, s2, _, _} -> commit_entry(mc1, right), Next;
          {next_state, s6, _} -> commit_entry(mc1, left), Next;
          {next_state, s6, _, _} -> commit_entry(mc1, left), Next;
          _ -> Next
        end
    end;
s5(cast, {_CPid, {'StartTls'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s5]: Purging stale event ~p~n", [{'StartTls'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s5]: Postponing event ~p~n", [{'StartTls'}]),
        {keep_state, Data, [postpone]}
    end;
s5(cast, {_CPid, {'Quit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s5]: Purging stale event ~p~n", [{'Quit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s5]: Postponing event ~p~n", [{'Quit'}]),
        {keep_state, Data, [postpone]}
    end;
s5(cast, {_CPid, {'Ehlo1'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s5]: Purging stale event ~p~n", [{'Ehlo1'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s5]: Postponing event ~p~n", [{'Ehlo1'}]),
        {keep_state, Data, [postpone]}
    end;
s5(cast, {_CPid, {'Auth'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s5]: Purging stale event ~p~n", [{'Auth'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s5]: Postponing event ~p~n", [{'Auth'}]),
        {keep_state, Data, [postpone]}
    end;
s5(cast, {_CPid, {'Mail'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s5]: Purging stale event ~p~n", [{'Mail'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s5]: Postponing event ~p~n", [{'Mail'}]),
        {keep_state, Data, [postpone]}
    end;
s5(cast, {_CPid, {'Bogus'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s5]: Purging stale event ~p~n", [{'Bogus'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s5]: Postponing event ~p~n", [{'Bogus'}]),
        {keep_state, Data, [postpone]}
    end;
s5(cast, {_CPid, {'Rcpt'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s5]: Purging stale event ~p~n", [{'Rcpt'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s5]: Postponing event ~p~n", [{'Rcpt'}]),
        {keep_state, Data, [postpone]}
    end;
s5(cast, {_CPid, {'Data'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s5]: Purging stale event ~p~n", [{'Data'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s5]: Postponing event ~p~n", [{'Data'}]),
        {keep_state, Data, [postpone]}
    end;
s5(cast, {_CPid, {'Subject'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s5]: Purging stale event ~p~n", [{'Subject'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s5]: Postponing event ~p~n", [{'Subject'}]),
        {keep_state, Data, [postpone]}
    end;
s5(cast, {_CPid, {'EndOfData'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s5]: Purging stale event ~p~n", [{'EndOfData'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s5]: Postponing event ~p~n", [{'EndOfData'}]),
        {keep_state, Data, [postpone]}
    end;
s5(cast, {_CPid, {'DataLine'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s5]: Purging stale event ~p~n", [{'DataLine'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s5]: Postponing event ~p~n", [{'DataLine'}]),
        {keep_state, Data, [postpone]}
    end.

-spec s6(internal, {'EhloCommit'}, state_data()) -> {next_state, s8, state_data()} | {next_state, s8, state_data(), [{next_event, internal, {'EhloCommit'}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s6(internal, {'EhloCommit'}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s6(internal, {'EhloCommit'}, Data),
        Next;
s6(cast, {_CPid, {'Ehlo'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s6]: Purging stale event ~p~n", [{'Ehlo'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s6]: Postponing event ~p~n", [{'Ehlo'}]),
        {keep_state, Data, [postpone]}
    end;
s6(cast, {_CPid, {'QuitCommit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s6]: Purging stale event ~p~n", [{'QuitCommit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s6]: Postponing event ~p~n", [{'QuitCommit'}]),
        {keep_state, Data, [postpone]}
    end;
s6(cast, {_CPid, {'StartTls'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s6]: Purging stale event ~p~n", [{'StartTls'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s6]: Postponing event ~p~n", [{'StartTls'}]),
        {keep_state, Data, [postpone]}
    end;
s6(cast, {_CPid, {'Quit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s6]: Purging stale event ~p~n", [{'Quit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s6]: Postponing event ~p~n", [{'Quit'}]),
        {keep_state, Data, [postpone]}
    end;
s6(cast, {_CPid, {'Ehlo1'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s6]: Purging stale event ~p~n", [{'Ehlo1'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s6]: Postponing event ~p~n", [{'Ehlo1'}]),
        {keep_state, Data, [postpone]}
    end;
s6(cast, {_CPid, {'Auth'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s6]: Purging stale event ~p~n", [{'Auth'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s6]: Postponing event ~p~n", [{'Auth'}]),
        {keep_state, Data, [postpone]}
    end;
s6(cast, {_CPid, {'Mail'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s6]: Purging stale event ~p~n", [{'Mail'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s6]: Postponing event ~p~n", [{'Mail'}]),
        {keep_state, Data, [postpone]}
    end;
s6(cast, {_CPid, {'Bogus'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s6]: Purging stale event ~p~n", [{'Bogus'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s6]: Postponing event ~p~n", [{'Bogus'}]),
        {keep_state, Data, [postpone]}
    end;
s6(cast, {_CPid, {'Rcpt'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s6]: Purging stale event ~p~n", [{'Rcpt'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s6]: Postponing event ~p~n", [{'Rcpt'}]),
        {keep_state, Data, [postpone]}
    end;
s6(cast, {_CPid, {'Data'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s6]: Purging stale event ~p~n", [{'Data'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s6]: Postponing event ~p~n", [{'Data'}]),
        {keep_state, Data, [postpone]}
    end;
s6(cast, {_CPid, {'Subject'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s6]: Purging stale event ~p~n", [{'Subject'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s6]: Postponing event ~p~n", [{'Subject'}]),
        {keep_state, Data, [postpone]}
    end;
s6(cast, {_CPid, {'EndOfData'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s6]: Purging stale event ~p~n", [{'EndOfData'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s6]: Postponing event ~p~n", [{'EndOfData'}]),
        {keep_state, Data, [postpone]}
    end;
s6(cast, {_CPid, {'DataLine'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s6]: Purging stale event ~p~n", [{'DataLine'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s6]: Postponing event ~p~n", [{'DataLine'}]),
        {keep_state, Data, [postpone]}
    end.

-spec s8(internal, {'250'} | {'250d'}, state_data()) -> {next_state, s11, state_data()} | {next_state, s11, state_data(), [{next_event, internal, {'250'}}] } | {next_state, s11, state_data(), [{next_event, internal, {'250d'}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s8(internal, {'250'}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s8(internal, {'250'}, Data),
        Next;
s8(internal, {'250d'}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s8(internal, {'250d'}, Data),
        Next;
s8(cast, {_CPid, {'Ehlo'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s8]: Purging stale event ~p~n", [{'Ehlo'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s8]: Postponing event ~p~n", [{'Ehlo'}]),
        {keep_state, Data, [postpone]}
    end;
s8(cast, {_CPid, {'QuitCommit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s8]: Purging stale event ~p~n", [{'QuitCommit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s8]: Postponing event ~p~n", [{'QuitCommit'}]),
        {keep_state, Data, [postpone]}
    end;
s8(cast, {_CPid, {'StartTls'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s8]: Purging stale event ~p~n", [{'StartTls'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s8]: Postponing event ~p~n", [{'StartTls'}]),
        {keep_state, Data, [postpone]}
    end;
s8(cast, {_CPid, {'Quit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s8]: Purging stale event ~p~n", [{'Quit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s8]: Postponing event ~p~n", [{'Quit'}]),
        {keep_state, Data, [postpone]}
    end;
s8(cast, {_CPid, {'Ehlo1'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s8]: Purging stale event ~p~n", [{'Ehlo1'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s8]: Postponing event ~p~n", [{'Ehlo1'}]),
        {keep_state, Data, [postpone]}
    end;
s8(cast, {_CPid, {'Auth'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s8]: Purging stale event ~p~n", [{'Auth'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s8]: Postponing event ~p~n", [{'Auth'}]),
        {keep_state, Data, [postpone]}
    end;
s8(cast, {_CPid, {'Mail'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s8]: Purging stale event ~p~n", [{'Mail'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s8]: Postponing event ~p~n", [{'Mail'}]),
        {keep_state, Data, [postpone]}
    end;
s8(cast, {_CPid, {'Bogus'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s8]: Purging stale event ~p~n", [{'Bogus'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s8]: Postponing event ~p~n", [{'Bogus'}]),
        {keep_state, Data, [postpone]}
    end;
s8(cast, {_CPid, {'Rcpt'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s8]: Purging stale event ~p~n", [{'Rcpt'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s8]: Postponing event ~p~n", [{'Rcpt'}]),
        {keep_state, Data, [postpone]}
    end;
s8(cast, {_CPid, {'Data'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s8]: Purging stale event ~p~n", [{'Data'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s8]: Postponing event ~p~n", [{'Data'}]),
        {keep_state, Data, [postpone]}
    end;
s8(cast, {_CPid, {'Subject'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s8]: Purging stale event ~p~n", [{'Subject'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s8]: Postponing event ~p~n", [{'Subject'}]),
        {keep_state, Data, [postpone]}
    end;
s8(cast, {_CPid, {'EndOfData'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s8]: Purging stale event ~p~n", [{'EndOfData'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s8]: Postponing event ~p~n", [{'EndOfData'}]),
        {keep_state, Data, [postpone]}
    end;
s8(cast, {_CPid, {'DataLine'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s8]: Purging stale event ~p~n", [{'DataLine'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s8]: Postponing event ~p~n", [{'DataLine'}]),
        {keep_state, Data, [postpone]}
    end.

-spec s11(cast, {pid(), {'Quit'}, list()} | {pid(), {'StartTls'}, list()}, state_data()) -> {next_state, s12, state_data()} | {next_state, s51, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
s11(cast, {CPid, {'StartTls'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s11]: Purging stale event ~p~n", [{'StartTls'}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s11(cast, {CPid, {'StartTls'}}, Data)
               catch error:function_clause ->
                 io:format("gen_s[s11]: Callback had no clause for ~p, postponing~n", [{'StartTls'}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> Next
        end
    end;
s11(cast, {CPid, {'Quit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s11]: Purging stale event ~p~n", [{'Quit'}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s11(cast, {CPid, {'Quit'}}, Data)
               catch error:function_clause ->
                 io:format("gen_s[s11]: Callback had no clause for ~p, postponing~n", [{'Quit'}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> Next
        end
    end;
s11(cast, {_CPid, {'Ehlo'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s11]: Purging stale event ~p~n", [{'Ehlo'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s11]: Postponing event ~p~n", [{'Ehlo'}]),
        {keep_state, Data, [postpone]}
    end;
s11(cast, {_CPid, {'QuitCommit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s11]: Purging stale event ~p~n", [{'QuitCommit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s11]: Postponing event ~p~n", [{'QuitCommit'}]),
        {keep_state, Data, [postpone]}
    end;
s11(cast, {_CPid, {'Ehlo1'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s11]: Purging stale event ~p~n", [{'Ehlo1'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s11]: Postponing event ~p~n", [{'Ehlo1'}]),
        {keep_state, Data, [postpone]}
    end;
s11(cast, {_CPid, {'Auth'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s11]: Purging stale event ~p~n", [{'Auth'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s11]: Postponing event ~p~n", [{'Auth'}]),
        {keep_state, Data, [postpone]}
    end;
s11(cast, {_CPid, {'Mail'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s11]: Purging stale event ~p~n", [{'Mail'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s11]: Postponing event ~p~n", [{'Mail'}]),
        {keep_state, Data, [postpone]}
    end;
s11(cast, {_CPid, {'Bogus'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s11]: Purging stale event ~p~n", [{'Bogus'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s11]: Postponing event ~p~n", [{'Bogus'}]),
        {keep_state, Data, [postpone]}
    end;
s11(cast, {_CPid, {'Rcpt'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s11]: Purging stale event ~p~n", [{'Rcpt'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s11]: Postponing event ~p~n", [{'Rcpt'}]),
        {keep_state, Data, [postpone]}
    end;
s11(cast, {_CPid, {'Data'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s11]: Purging stale event ~p~n", [{'Data'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s11]: Postponing event ~p~n", [{'Data'}]),
        {keep_state, Data, [postpone]}
    end;
s11(cast, {_CPid, {'Subject'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s11]: Purging stale event ~p~n", [{'Subject'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s11]: Postponing event ~p~n", [{'Subject'}]),
        {keep_state, Data, [postpone]}
    end;
s11(cast, {_CPid, {'EndOfData'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s11]: Purging stale event ~p~n", [{'EndOfData'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s11]: Postponing event ~p~n", [{'EndOfData'}]),
        {keep_state, Data, [postpone]}
    end;
s11(cast, {_CPid, {'DataLine'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s11]: Purging stale event ~p~n", [{'DataLine'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s11]: Postponing event ~p~n", [{'DataLine'}]),
        {keep_state, Data, [postpone]}
    end.

-spec s12(internal, {'220'}, state_data()) -> {next_state, s13, state_data()} | {next_state, s13, state_data(), [{next_event, internal, {'220'}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s12(internal, {'220'}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s12(internal, {'220'}, Data),
        Next;
s12(cast, {_CPid, {'Ehlo'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s12]: Purging stale event ~p~n", [{'Ehlo'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s12]: Postponing event ~p~n", [{'Ehlo'}]),
        {keep_state, Data, [postpone]}
    end;
s12(cast, {_CPid, {'QuitCommit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s12]: Purging stale event ~p~n", [{'QuitCommit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s12]: Postponing event ~p~n", [{'QuitCommit'}]),
        {keep_state, Data, [postpone]}
    end;
s12(cast, {_CPid, {'StartTls'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s12]: Purging stale event ~p~n", [{'StartTls'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s12]: Postponing event ~p~n", [{'StartTls'}]),
        {keep_state, Data, [postpone]}
    end;
s12(cast, {_CPid, {'Quit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s12]: Purging stale event ~p~n", [{'Quit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s12]: Postponing event ~p~n", [{'Quit'}]),
        {keep_state, Data, [postpone]}
    end;
s12(cast, {_CPid, {'Ehlo1'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s12]: Purging stale event ~p~n", [{'Ehlo1'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s12]: Postponing event ~p~n", [{'Ehlo1'}]),
        {keep_state, Data, [postpone]}
    end;
s12(cast, {_CPid, {'Auth'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s12]: Purging stale event ~p~n", [{'Auth'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s12]: Postponing event ~p~n", [{'Auth'}]),
        {keep_state, Data, [postpone]}
    end;
s12(cast, {_CPid, {'Mail'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s12]: Purging stale event ~p~n", [{'Mail'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s12]: Postponing event ~p~n", [{'Mail'}]),
        {keep_state, Data, [postpone]}
    end;
s12(cast, {_CPid, {'Bogus'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s12]: Purging stale event ~p~n", [{'Bogus'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s12]: Postponing event ~p~n", [{'Bogus'}]),
        {keep_state, Data, [postpone]}
    end;
s12(cast, {_CPid, {'Rcpt'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s12]: Purging stale event ~p~n", [{'Rcpt'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s12]: Postponing event ~p~n", [{'Rcpt'}]),
        {keep_state, Data, [postpone]}
    end;
s12(cast, {_CPid, {'Data'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s12]: Purging stale event ~p~n", [{'Data'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s12]: Postponing event ~p~n", [{'Data'}]),
        {keep_state, Data, [postpone]}
    end;
s12(cast, {_CPid, {'Subject'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s12]: Purging stale event ~p~n", [{'Subject'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s12]: Postponing event ~p~n", [{'Subject'}]),
        {keep_state, Data, [postpone]}
    end;
s12(cast, {_CPid, {'EndOfData'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s12]: Purging stale event ~p~n", [{'EndOfData'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s12]: Postponing event ~p~n", [{'EndOfData'}]),
        {keep_state, Data, [postpone]}
    end;
s12(cast, {_CPid, {'DataLine'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s12]: Purging stale event ~p~n", [{'DataLine'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s12]: Postponing event ~p~n", [{'DataLine'}]),
        {keep_state, Data, [postpone]}
    end.

-spec s13(cast, {pid(), {'Ehlo1'}, list()} | {pid(), {'Quit'}, list()}, state_data()) -> {next_state, s15, state_data()} | {next_state, s49, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
s13(cast, {CPid, {'Ehlo1'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s13]: Purging stale event ~p~n", [{'Ehlo1'}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s13(cast, {CPid, {'Ehlo1'}}, Data)
               catch error:function_clause ->
                 io:format("gen_s[s13]: Callback had no clause for ~p, postponing~n", [{'Ehlo1'}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> Next
        end
    end;
s13(cast, {CPid, {'Quit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s13]: Purging stale event ~p~n", [{'Quit'}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s13(cast, {CPid, {'Quit'}}, Data)
               catch error:function_clause ->
                 io:format("gen_s[s13]: Callback had no clause for ~p, postponing~n", [{'Quit'}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> Next
        end
    end;
s13(cast, {_CPid, {'Ehlo'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s13]: Purging stale event ~p~n", [{'Ehlo'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s13]: Postponing event ~p~n", [{'Ehlo'}]),
        {keep_state, Data, [postpone]}
    end;
s13(cast, {_CPid, {'QuitCommit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s13]: Purging stale event ~p~n", [{'QuitCommit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s13]: Postponing event ~p~n", [{'QuitCommit'}]),
        {keep_state, Data, [postpone]}
    end;
s13(cast, {_CPid, {'StartTls'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s13]: Purging stale event ~p~n", [{'StartTls'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s13]: Postponing event ~p~n", [{'StartTls'}]),
        {keep_state, Data, [postpone]}
    end;
s13(cast, {_CPid, {'Auth'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s13]: Purging stale event ~p~n", [{'Auth'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s13]: Postponing event ~p~n", [{'Auth'}]),
        {keep_state, Data, [postpone]}
    end;
s13(cast, {_CPid, {'Mail'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s13]: Purging stale event ~p~n", [{'Mail'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s13]: Postponing event ~p~n", [{'Mail'}]),
        {keep_state, Data, [postpone]}
    end;
s13(cast, {_CPid, {'Bogus'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s13]: Purging stale event ~p~n", [{'Bogus'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s13]: Postponing event ~p~n", [{'Bogus'}]),
        {keep_state, Data, [postpone]}
    end;
s13(cast, {_CPid, {'Rcpt'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s13]: Purging stale event ~p~n", [{'Rcpt'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s13]: Postponing event ~p~n", [{'Rcpt'}]),
        {keep_state, Data, [postpone]}
    end;
s13(cast, {_CPid, {'Data'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s13]: Purging stale event ~p~n", [{'Data'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s13]: Postponing event ~p~n", [{'Data'}]),
        {keep_state, Data, [postpone]}
    end;
s13(cast, {_CPid, {'Subject'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s13]: Purging stale event ~p~n", [{'Subject'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s13]: Postponing event ~p~n", [{'Subject'}]),
        {keep_state, Data, [postpone]}
    end;
s13(cast, {_CPid, {'EndOfData'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s13]: Purging stale event ~p~n", [{'EndOfData'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s13]: Postponing event ~p~n", [{'EndOfData'}]),
        {keep_state, Data, [postpone]}
    end;
s13(cast, {_CPid, {'DataLine'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s13]: Purging stale event ~p~n", [{'DataLine'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s13]: Postponing event ~p~n", [{'DataLine'}]),
        {keep_state, Data, [postpone]}
    end.

-spec s15(internal, {'250'} | {'250d'}, state_data()) -> {next_state, s19, state_data()} | {next_state, s19, state_data(), [{next_event, internal, {'250'}}] } | {next_state, s19, state_data(), [{next_event, internal, {'250d'}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s15(internal, {'250d'}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s15(internal, {'250d'}, Data),
        Next;
s15(internal, {'250'}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s15(internal, {'250'}, Data),
        Next;
s15(cast, {_CPid, {'Ehlo'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s15]: Purging stale event ~p~n", [{'Ehlo'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s15]: Postponing event ~p~n", [{'Ehlo'}]),
        {keep_state, Data, [postpone]}
    end;
s15(cast, {_CPid, {'QuitCommit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s15]: Purging stale event ~p~n", [{'QuitCommit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s15]: Postponing event ~p~n", [{'QuitCommit'}]),
        {keep_state, Data, [postpone]}
    end;
s15(cast, {_CPid, {'StartTls'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s15]: Purging stale event ~p~n", [{'StartTls'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s15]: Postponing event ~p~n", [{'StartTls'}]),
        {keep_state, Data, [postpone]}
    end;
s15(cast, {_CPid, {'Quit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s15]: Purging stale event ~p~n", [{'Quit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s15]: Postponing event ~p~n", [{'Quit'}]),
        {keep_state, Data, [postpone]}
    end;
s15(cast, {_CPid, {'Ehlo1'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s15]: Purging stale event ~p~n", [{'Ehlo1'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s15]: Postponing event ~p~n", [{'Ehlo1'}]),
        {keep_state, Data, [postpone]}
    end;
s15(cast, {_CPid, {'Auth'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s15]: Purging stale event ~p~n", [{'Auth'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s15]: Postponing event ~p~n", [{'Auth'}]),
        {keep_state, Data, [postpone]}
    end;
s15(cast, {_CPid, {'Mail'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s15]: Purging stale event ~p~n", [{'Mail'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s15]: Postponing event ~p~n", [{'Mail'}]),
        {keep_state, Data, [postpone]}
    end;
s15(cast, {_CPid, {'Bogus'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s15]: Purging stale event ~p~n", [{'Bogus'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s15]: Postponing event ~p~n", [{'Bogus'}]),
        {keep_state, Data, [postpone]}
    end;
s15(cast, {_CPid, {'Rcpt'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s15]: Purging stale event ~p~n", [{'Rcpt'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s15]: Postponing event ~p~n", [{'Rcpt'}]),
        {keep_state, Data, [postpone]}
    end;
s15(cast, {_CPid, {'Data'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s15]: Purging stale event ~p~n", [{'Data'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s15]: Postponing event ~p~n", [{'Data'}]),
        {keep_state, Data, [postpone]}
    end;
s15(cast, {_CPid, {'Subject'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s15]: Purging stale event ~p~n", [{'Subject'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s15]: Postponing event ~p~n", [{'Subject'}]),
        {keep_state, Data, [postpone]}
    end;
s15(cast, {_CPid, {'EndOfData'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s15]: Purging stale event ~p~n", [{'EndOfData'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s15]: Postponing event ~p~n", [{'EndOfData'}]),
        {keep_state, Data, [postpone]}
    end;
s15(cast, {_CPid, {'DataLine'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s15]: Purging stale event ~p~n", [{'DataLine'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s15]: Postponing event ~p~n", [{'DataLine'}]),
        {keep_state, Data, [postpone]}
    end.

-spec s19(cast, {pid(), {'Auth'}, list()} | {pid(), {'Quit'}, list()}, state_data()) -> {next_state, s20, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
s19(cast, {CPid, {'Quit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s19]: Purging stale event ~p~n", [{'Quit'}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s19(cast, {CPid, {'Quit'}}, Data)
               catch error:function_clause ->
                 io:format("gen_s[s19]: Callback had no clause for ~p, postponing~n", [{'Quit'}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> Next
        end
    end;
s19(cast, {CPid, {'Auth'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s19]: Purging stale event ~p~n", [{'Auth'}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s19(cast, {CPid, {'Auth'}}, Data)
               catch error:function_clause ->
                 io:format("gen_s[s19]: Callback had no clause for ~p, postponing~n", [{'Auth'}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> Next
        end
    end;
s19(cast, {_CPid, {'Ehlo'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s19]: Purging stale event ~p~n", [{'Ehlo'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s19]: Postponing event ~p~n", [{'Ehlo'}]),
        {keep_state, Data, [postpone]}
    end;
s19(cast, {_CPid, {'QuitCommit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s19]: Purging stale event ~p~n", [{'QuitCommit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s19]: Postponing event ~p~n", [{'QuitCommit'}]),
        {keep_state, Data, [postpone]}
    end;
s19(cast, {_CPid, {'StartTls'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s19]: Purging stale event ~p~n", [{'StartTls'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s19]: Postponing event ~p~n", [{'StartTls'}]),
        {keep_state, Data, [postpone]}
    end;
s19(cast, {_CPid, {'Ehlo1'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s19]: Purging stale event ~p~n", [{'Ehlo1'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s19]: Postponing event ~p~n", [{'Ehlo1'}]),
        {keep_state, Data, [postpone]}
    end;
s19(cast, {_CPid, {'Mail'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s19]: Purging stale event ~p~n", [{'Mail'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s19]: Postponing event ~p~n", [{'Mail'}]),
        {keep_state, Data, [postpone]}
    end;
s19(cast, {_CPid, {'Bogus'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s19]: Purging stale event ~p~n", [{'Bogus'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s19]: Postponing event ~p~n", [{'Bogus'}]),
        {keep_state, Data, [postpone]}
    end;
s19(cast, {_CPid, {'Rcpt'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s19]: Purging stale event ~p~n", [{'Rcpt'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s19]: Postponing event ~p~n", [{'Rcpt'}]),
        {keep_state, Data, [postpone]}
    end;
s19(cast, {_CPid, {'Data'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s19]: Purging stale event ~p~n", [{'Data'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s19]: Postponing event ~p~n", [{'Data'}]),
        {keep_state, Data, [postpone]}
    end;
s19(cast, {_CPid, {'Subject'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s19]: Purging stale event ~p~n", [{'Subject'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s19]: Postponing event ~p~n", [{'Subject'}]),
        {keep_state, Data, [postpone]}
    end;
s19(cast, {_CPid, {'EndOfData'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s19]: Purging stale event ~p~n", [{'EndOfData'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s19]: Postponing event ~p~n", [{'EndOfData'}]),
        {keep_state, Data, [postpone]}
    end;
s19(cast, {_CPid, {'DataLine'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s19]: Purging stale event ~p~n", [{'DataLine'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s19]: Postponing event ~p~n", [{'DataLine'}]),
        {keep_state, Data, [postpone]}
    end.

-spec s20(internal, {'235'} | {'535'}, state_data()) -> {next_state, s22, state_data()} | {next_state, s22, state_data(), [{next_event, internal, {'235'}}] } | {next_state, s22, state_data(), [{next_event, internal, {'535'}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s20(internal, {'535'}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s20(internal, {'535'}, Data),
        Next;
s20(internal, {'235'}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s20(internal, {'235'}, Data),
        Next;
s20(cast, {_CPid, {'Ehlo'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s20]: Purging stale event ~p~n", [{'Ehlo'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s20]: Postponing event ~p~n", [{'Ehlo'}]),
        {keep_state, Data, [postpone]}
    end;
s20(cast, {_CPid, {'QuitCommit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s20]: Purging stale event ~p~n", [{'QuitCommit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s20]: Postponing event ~p~n", [{'QuitCommit'}]),
        {keep_state, Data, [postpone]}
    end;
s20(cast, {_CPid, {'StartTls'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s20]: Purging stale event ~p~n", [{'StartTls'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s20]: Postponing event ~p~n", [{'StartTls'}]),
        {keep_state, Data, [postpone]}
    end;
s20(cast, {_CPid, {'Quit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s20]: Purging stale event ~p~n", [{'Quit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s20]: Postponing event ~p~n", [{'Quit'}]),
        {keep_state, Data, [postpone]}
    end;
s20(cast, {_CPid, {'Ehlo1'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s20]: Purging stale event ~p~n", [{'Ehlo1'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s20]: Postponing event ~p~n", [{'Ehlo1'}]),
        {keep_state, Data, [postpone]}
    end;
s20(cast, {_CPid, {'Auth'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s20]: Purging stale event ~p~n", [{'Auth'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s20]: Postponing event ~p~n", [{'Auth'}]),
        {keep_state, Data, [postpone]}
    end;
s20(cast, {_CPid, {'Mail'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s20]: Purging stale event ~p~n", [{'Mail'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s20]: Postponing event ~p~n", [{'Mail'}]),
        {keep_state, Data, [postpone]}
    end;
s20(cast, {_CPid, {'Bogus'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s20]: Purging stale event ~p~n", [{'Bogus'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s20]: Postponing event ~p~n", [{'Bogus'}]),
        {keep_state, Data, [postpone]}
    end;
s20(cast, {_CPid, {'Rcpt'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s20]: Purging stale event ~p~n", [{'Rcpt'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s20]: Postponing event ~p~n", [{'Rcpt'}]),
        {keep_state, Data, [postpone]}
    end;
s20(cast, {_CPid, {'Data'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s20]: Purging stale event ~p~n", [{'Data'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s20]: Postponing event ~p~n", [{'Data'}]),
        {keep_state, Data, [postpone]}
    end;
s20(cast, {_CPid, {'Subject'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s20]: Purging stale event ~p~n", [{'Subject'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s20]: Postponing event ~p~n", [{'Subject'}]),
        {keep_state, Data, [postpone]}
    end;
s20(cast, {_CPid, {'EndOfData'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s20]: Purging stale event ~p~n", [{'EndOfData'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s20]: Postponing event ~p~n", [{'EndOfData'}]),
        {keep_state, Data, [postpone]}
    end;
s20(cast, {_CPid, {'DataLine'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s20]: Purging stale event ~p~n", [{'DataLine'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s20]: Postponing event ~p~n", [{'DataLine'}]),
        {keep_state, Data, [postpone]}
    end.

-spec s22(cast, {pid(), {'Quit'}, list()} | {pid(), {'Mail'}, list()}, state_data()) -> {next_state, s23, state_data()} | {next_state, s44, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
s22(cast, {CPid, {'Quit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s22]: Purging stale event ~p~n", [{'Quit'}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s22(cast, {CPid, {'Quit'}}, Data)
               catch error:function_clause ->
                 io:format("gen_s[s22]: Callback had no clause for ~p, postponing~n", [{'Quit'}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> Next
        end
    end;
s22(cast, {CPid, {'Mail'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s22]: Purging stale event ~p~n", [{'Mail'}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s22(cast, {CPid, {'Mail'}}, Data)
               catch error:function_clause ->
                 io:format("gen_s[s22]: Callback had no clause for ~p, postponing~n", [{'Mail'}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> Next
        end
    end;
s22(cast, {_CPid, {'Ehlo'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s22]: Purging stale event ~p~n", [{'Ehlo'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s22]: Postponing event ~p~n", [{'Ehlo'}]),
        {keep_state, Data, [postpone]}
    end;
s22(cast, {_CPid, {'QuitCommit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s22]: Purging stale event ~p~n", [{'QuitCommit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s22]: Postponing event ~p~n", [{'QuitCommit'}]),
        {keep_state, Data, [postpone]}
    end;
s22(cast, {_CPid, {'StartTls'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s22]: Purging stale event ~p~n", [{'StartTls'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s22]: Postponing event ~p~n", [{'StartTls'}]),
        {keep_state, Data, [postpone]}
    end;
s22(cast, {_CPid, {'Ehlo1'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s22]: Purging stale event ~p~n", [{'Ehlo1'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s22]: Postponing event ~p~n", [{'Ehlo1'}]),
        {keep_state, Data, [postpone]}
    end;
s22(cast, {_CPid, {'Auth'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s22]: Purging stale event ~p~n", [{'Auth'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s22]: Postponing event ~p~n", [{'Auth'}]),
        {keep_state, Data, [postpone]}
    end;
s22(cast, {_CPid, {'Bogus'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s22]: Purging stale event ~p~n", [{'Bogus'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s22]: Postponing event ~p~n", [{'Bogus'}]),
        {keep_state, Data, [postpone]}
    end;
s22(cast, {_CPid, {'Rcpt'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s22]: Purging stale event ~p~n", [{'Rcpt'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s22]: Postponing event ~p~n", [{'Rcpt'}]),
        {keep_state, Data, [postpone]}
    end;
s22(cast, {_CPid, {'Data'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s22]: Purging stale event ~p~n", [{'Data'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s22]: Postponing event ~p~n", [{'Data'}]),
        {keep_state, Data, [postpone]}
    end;
s22(cast, {_CPid, {'Subject'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s22]: Purging stale event ~p~n", [{'Subject'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s22]: Postponing event ~p~n", [{'Subject'}]),
        {keep_state, Data, [postpone]}
    end;
s22(cast, {_CPid, {'EndOfData'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s22]: Purging stale event ~p~n", [{'EndOfData'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s22]: Postponing event ~p~n", [{'EndOfData'}]),
        {keep_state, Data, [postpone]}
    end;
s22(cast, {_CPid, {'DataLine'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s22]: Purging stale event ~p~n", [{'DataLine'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s22]: Postponing event ~p~n", [{'DataLine'}]),
        {keep_state, Data, [postpone]}
    end.

-spec s23(internal, {'250'} | {'501'}, state_data()) -> {next_state, s27, state_data()} | {next_state, s27, state_data(), [{next_event, internal, {'250'}}] } | {next_state, s27, state_data(), [{next_event, internal, {'501'}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s23(internal, {'250'}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s23(internal, {'250'}, Data),
        Next;
s23(internal, {'501'}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s23(internal, {'501'}, Data),
        Next;
s23(cast, {_CPid, {'Ehlo'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s23]: Purging stale event ~p~n", [{'Ehlo'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s23]: Postponing event ~p~n", [{'Ehlo'}]),
        {keep_state, Data, [postpone]}
    end;
s23(cast, {_CPid, {'QuitCommit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s23]: Purging stale event ~p~n", [{'QuitCommit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s23]: Postponing event ~p~n", [{'QuitCommit'}]),
        {keep_state, Data, [postpone]}
    end;
s23(cast, {_CPid, {'StartTls'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s23]: Purging stale event ~p~n", [{'StartTls'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s23]: Postponing event ~p~n", [{'StartTls'}]),
        {keep_state, Data, [postpone]}
    end;
s23(cast, {_CPid, {'Quit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s23]: Purging stale event ~p~n", [{'Quit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s23]: Postponing event ~p~n", [{'Quit'}]),
        {keep_state, Data, [postpone]}
    end;
s23(cast, {_CPid, {'Ehlo1'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s23]: Purging stale event ~p~n", [{'Ehlo1'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s23]: Postponing event ~p~n", [{'Ehlo1'}]),
        {keep_state, Data, [postpone]}
    end;
s23(cast, {_CPid, {'Auth'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s23]: Purging stale event ~p~n", [{'Auth'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s23]: Postponing event ~p~n", [{'Auth'}]),
        {keep_state, Data, [postpone]}
    end;
s23(cast, {_CPid, {'Mail'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s23]: Purging stale event ~p~n", [{'Mail'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s23]: Postponing event ~p~n", [{'Mail'}]),
        {keep_state, Data, [postpone]}
    end;
s23(cast, {_CPid, {'Bogus'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s23]: Purging stale event ~p~n", [{'Bogus'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s23]: Postponing event ~p~n", [{'Bogus'}]),
        {keep_state, Data, [postpone]}
    end;
s23(cast, {_CPid, {'Rcpt'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s23]: Purging stale event ~p~n", [{'Rcpt'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s23]: Postponing event ~p~n", [{'Rcpt'}]),
        {keep_state, Data, [postpone]}
    end;
s23(cast, {_CPid, {'Data'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s23]: Purging stale event ~p~n", [{'Data'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s23]: Postponing event ~p~n", [{'Data'}]),
        {keep_state, Data, [postpone]}
    end;
s23(cast, {_CPid, {'Subject'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s23]: Purging stale event ~p~n", [{'Subject'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s23]: Postponing event ~p~n", [{'Subject'}]),
        {keep_state, Data, [postpone]}
    end;
s23(cast, {_CPid, {'EndOfData'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s23]: Purging stale event ~p~n", [{'EndOfData'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s23]: Postponing event ~p~n", [{'EndOfData'}]),
        {keep_state, Data, [postpone]}
    end;
s23(cast, {_CPid, {'DataLine'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s23]: Purging stale event ~p~n", [{'DataLine'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s23]: Postponing event ~p~n", [{'DataLine'}]),
        {keep_state, Data, [postpone]}
    end.

-spec s27(cast, {pid(), {'Rcpt'}, list()} | {pid(), {'Bogus'}, list()}, state_data()) -> {next_state, s28, state_data()} | {next_state, s33, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
s27(cast, {CPid, {'Rcpt'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s27]: Purging stale event ~p~n", [{'Rcpt'}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s27(cast, {CPid, {'Rcpt'}}, Data)
               catch error:function_clause ->
                 io:format("gen_s[s27]: Callback had no clause for ~p, postponing~n", [{'Rcpt'}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> Next
        end
    end;
s27(cast, {CPid, {'Bogus'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s27]: Purging stale event ~p~n", [{'Bogus'}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s27(cast, {CPid, {'Bogus'}}, Data)
               catch error:function_clause ->
                 io:format("gen_s[s27]: Callback had no clause for ~p, postponing~n", [{'Bogus'}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> Next
        end
    end;
s27(cast, {_CPid, {'Ehlo'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s27]: Purging stale event ~p~n", [{'Ehlo'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s27]: Postponing event ~p~n", [{'Ehlo'}]),
        {keep_state, Data, [postpone]}
    end;
s27(cast, {_CPid, {'QuitCommit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s27]: Purging stale event ~p~n", [{'QuitCommit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s27]: Postponing event ~p~n", [{'QuitCommit'}]),
        {keep_state, Data, [postpone]}
    end;
s27(cast, {_CPid, {'StartTls'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s27]: Purging stale event ~p~n", [{'StartTls'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s27]: Postponing event ~p~n", [{'StartTls'}]),
        {keep_state, Data, [postpone]}
    end;
s27(cast, {_CPid, {'Quit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s27]: Purging stale event ~p~n", [{'Quit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s27]: Postponing event ~p~n", [{'Quit'}]),
        {keep_state, Data, [postpone]}
    end;
s27(cast, {_CPid, {'Ehlo1'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s27]: Purging stale event ~p~n", [{'Ehlo1'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s27]: Postponing event ~p~n", [{'Ehlo1'}]),
        {keep_state, Data, [postpone]}
    end;
s27(cast, {_CPid, {'Auth'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s27]: Purging stale event ~p~n", [{'Auth'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s27]: Postponing event ~p~n", [{'Auth'}]),
        {keep_state, Data, [postpone]}
    end;
s27(cast, {_CPid, {'Mail'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s27]: Purging stale event ~p~n", [{'Mail'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s27]: Postponing event ~p~n", [{'Mail'}]),
        {keep_state, Data, [postpone]}
    end;
s27(cast, {_CPid, {'Data'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s27]: Purging stale event ~p~n", [{'Data'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s27]: Postponing event ~p~n", [{'Data'}]),
        {keep_state, Data, [postpone]}
    end;
s27(cast, {_CPid, {'Subject'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s27]: Purging stale event ~p~n", [{'Subject'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s27]: Postponing event ~p~n", [{'Subject'}]),
        {keep_state, Data, [postpone]}
    end;
s27(cast, {_CPid, {'EndOfData'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s27]: Purging stale event ~p~n", [{'EndOfData'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s27]: Postponing event ~p~n", [{'EndOfData'}]),
        {keep_state, Data, [postpone]}
    end;
s27(cast, {_CPid, {'DataLine'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s27]: Purging stale event ~p~n", [{'DataLine'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s27]: Postponing event ~p~n", [{'DataLine'}]),
        {keep_state, Data, [postpone]}
    end.

-spec s28(internal, {'250'}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
s28(internal, {'250'}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s28(internal, {'250'}, Data),
        Next;
s28(cast, {_CPid, {'Ehlo'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s28]: Purging stale event ~p~n", [{'Ehlo'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s28]: Postponing event ~p~n", [{'Ehlo'}]),
        {keep_state, Data, [postpone]}
    end;
s28(cast, {_CPid, {'QuitCommit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s28]: Purging stale event ~p~n", [{'QuitCommit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s28]: Postponing event ~p~n", [{'QuitCommit'}]),
        {keep_state, Data, [postpone]}
    end;
s28(cast, {_CPid, {'StartTls'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s28]: Purging stale event ~p~n", [{'StartTls'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s28]: Postponing event ~p~n", [{'StartTls'}]),
        {keep_state, Data, [postpone]}
    end;
s28(cast, {_CPid, {'Quit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s28]: Purging stale event ~p~n", [{'Quit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s28]: Postponing event ~p~n", [{'Quit'}]),
        {keep_state, Data, [postpone]}
    end;
s28(cast, {_CPid, {'Ehlo1'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s28]: Purging stale event ~p~n", [{'Ehlo1'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s28]: Postponing event ~p~n", [{'Ehlo1'}]),
        {keep_state, Data, [postpone]}
    end;
s28(cast, {_CPid, {'Auth'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s28]: Purging stale event ~p~n", [{'Auth'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s28]: Postponing event ~p~n", [{'Auth'}]),
        {keep_state, Data, [postpone]}
    end;
s28(cast, {_CPid, {'Mail'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s28]: Purging stale event ~p~n", [{'Mail'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s28]: Postponing event ~p~n", [{'Mail'}]),
        {keep_state, Data, [postpone]}
    end;
s28(cast, {_CPid, {'Bogus'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s28]: Purging stale event ~p~n", [{'Bogus'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s28]: Postponing event ~p~n", [{'Bogus'}]),
        {keep_state, Data, [postpone]}
    end;
s28(cast, {_CPid, {'Rcpt'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s28]: Purging stale event ~p~n", [{'Rcpt'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s28]: Postponing event ~p~n", [{'Rcpt'}]),
        {keep_state, Data, [postpone]}
    end;
s28(cast, {_CPid, {'Data'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s28]: Purging stale event ~p~n", [{'Data'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s28]: Postponing event ~p~n", [{'Data'}]),
        {keep_state, Data, [postpone]}
    end;
s28(cast, {_CPid, {'Subject'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s28]: Purging stale event ~p~n", [{'Subject'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s28]: Postponing event ~p~n", [{'Subject'}]),
        {keep_state, Data, [postpone]}
    end;
s28(cast, {_CPid, {'EndOfData'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s28]: Purging stale event ~p~n", [{'EndOfData'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s28]: Postponing event ~p~n", [{'EndOfData'}]),
        {keep_state, Data, [postpone]}
    end;
s28(cast, {_CPid, {'DataLine'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s28]: Purging stale event ~p~n", [{'DataLine'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s28]: Postponing event ~p~n", [{'DataLine'}]),
        {keep_state, Data, [postpone]}
    end.

%% Mixed-choice entry state
-spec s33(internal | cast, {'Timeout'} | {pid(), {'Data'}, list()}, state_data()) -> {next_state, s34, state_data()} | {next_state, s34, state_data(), [{next_event, internal, {'Timeout'}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s33(internal, {'Timeout'}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s33(internal, {'Timeout'}, Data),
        Next;
s33(cast, {CPid, {'Data'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s33]: Purging stale event ~p~n", [{'Data'}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s33(cast, {CPid, {'Data'}}, Data)
               catch error:function_clause ->
                 io:format("gen_s[s33]: Callback had no clause for ~p, postponing~n", [{'Data'}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {next_state, s2, _} -> commit_entry(mc2, right), Next;
          {next_state, s2, _, _} -> commit_entry(mc2, right), Next;
          {next_state, s34, _} -> commit_entry(mc2, left), Next;
          {next_state, s34, _, _} -> commit_entry(mc2, left), Next;
          _ -> Next
        end
    end;
s33(cast, {_CPid, {'Ehlo'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s33]: Purging stale event ~p~n", [{'Ehlo'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s33]: Postponing event ~p~n", [{'Ehlo'}]),
        {keep_state, Data, [postpone]}
    end;
s33(cast, {_CPid, {'QuitCommit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s33]: Purging stale event ~p~n", [{'QuitCommit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s33]: Postponing event ~p~n", [{'QuitCommit'}]),
        {keep_state, Data, [postpone]}
    end;
s33(cast, {_CPid, {'StartTls'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s33]: Purging stale event ~p~n", [{'StartTls'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s33]: Postponing event ~p~n", [{'StartTls'}]),
        {keep_state, Data, [postpone]}
    end;
s33(cast, {_CPid, {'Quit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s33]: Purging stale event ~p~n", [{'Quit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s33]: Postponing event ~p~n", [{'Quit'}]),
        {keep_state, Data, [postpone]}
    end;
s33(cast, {_CPid, {'Ehlo1'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s33]: Purging stale event ~p~n", [{'Ehlo1'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s33]: Postponing event ~p~n", [{'Ehlo1'}]),
        {keep_state, Data, [postpone]}
    end;
s33(cast, {_CPid, {'Auth'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s33]: Purging stale event ~p~n", [{'Auth'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s33]: Postponing event ~p~n", [{'Auth'}]),
        {keep_state, Data, [postpone]}
    end;
s33(cast, {_CPid, {'Mail'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s33]: Purging stale event ~p~n", [{'Mail'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s33]: Postponing event ~p~n", [{'Mail'}]),
        {keep_state, Data, [postpone]}
    end;
s33(cast, {_CPid, {'Bogus'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s33]: Purging stale event ~p~n", [{'Bogus'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s33]: Postponing event ~p~n", [{'Bogus'}]),
        {keep_state, Data, [postpone]}
    end;
s33(cast, {_CPid, {'Rcpt'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s33]: Purging stale event ~p~n", [{'Rcpt'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s33]: Postponing event ~p~n", [{'Rcpt'}]),
        {keep_state, Data, [postpone]}
    end;
s33(cast, {_CPid, {'Subject'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s33]: Purging stale event ~p~n", [{'Subject'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s33]: Postponing event ~p~n", [{'Subject'}]),
        {keep_state, Data, [postpone]}
    end;
s33(cast, {_CPid, {'EndOfData'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s33]: Purging stale event ~p~n", [{'EndOfData'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s33]: Postponing event ~p~n", [{'EndOfData'}]),
        {keep_state, Data, [postpone]}
    end;
s33(cast, {_CPid, {'DataLine'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s33]: Purging stale event ~p~n", [{'DataLine'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s33]: Postponing event ~p~n", [{'DataLine'}]),
        {keep_state, Data, [postpone]}
    end.

-spec s34(internal, {'354'}, state_data()) -> {next_state, s36, state_data()} | {next_state, s36, state_data(), [{next_event, internal, {'354'}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s34(internal, {'354'}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s34(internal, {'354'}, Data),
        Next;
s34(cast, {_CPid, {'Ehlo'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s34]: Purging stale event ~p~n", [{'Ehlo'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s34]: Postponing event ~p~n", [{'Ehlo'}]),
        {keep_state, Data, [postpone]}
    end;
s34(cast, {_CPid, {'QuitCommit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s34]: Purging stale event ~p~n", [{'QuitCommit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s34]: Postponing event ~p~n", [{'QuitCommit'}]),
        {keep_state, Data, [postpone]}
    end;
s34(cast, {_CPid, {'StartTls'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s34]: Purging stale event ~p~n", [{'StartTls'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s34]: Postponing event ~p~n", [{'StartTls'}]),
        {keep_state, Data, [postpone]}
    end;
s34(cast, {_CPid, {'Quit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s34]: Purging stale event ~p~n", [{'Quit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s34]: Postponing event ~p~n", [{'Quit'}]),
        {keep_state, Data, [postpone]}
    end;
s34(cast, {_CPid, {'Ehlo1'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s34]: Purging stale event ~p~n", [{'Ehlo1'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s34]: Postponing event ~p~n", [{'Ehlo1'}]),
        {keep_state, Data, [postpone]}
    end;
s34(cast, {_CPid, {'Auth'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s34]: Purging stale event ~p~n", [{'Auth'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s34]: Postponing event ~p~n", [{'Auth'}]),
        {keep_state, Data, [postpone]}
    end;
s34(cast, {_CPid, {'Mail'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s34]: Purging stale event ~p~n", [{'Mail'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s34]: Postponing event ~p~n", [{'Mail'}]),
        {keep_state, Data, [postpone]}
    end;
s34(cast, {_CPid, {'Bogus'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s34]: Purging stale event ~p~n", [{'Bogus'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s34]: Postponing event ~p~n", [{'Bogus'}]),
        {keep_state, Data, [postpone]}
    end;
s34(cast, {_CPid, {'Rcpt'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s34]: Purging stale event ~p~n", [{'Rcpt'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s34]: Postponing event ~p~n", [{'Rcpt'}]),
        {keep_state, Data, [postpone]}
    end;
s34(cast, {_CPid, {'Data'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s34]: Purging stale event ~p~n", [{'Data'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s34]: Postponing event ~p~n", [{'Data'}]),
        {keep_state, Data, [postpone]}
    end;
s34(cast, {_CPid, {'Subject'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s34]: Purging stale event ~p~n", [{'Subject'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s34]: Postponing event ~p~n", [{'Subject'}]),
        {keep_state, Data, [postpone]}
    end;
s34(cast, {_CPid, {'EndOfData'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s34]: Purging stale event ~p~n", [{'EndOfData'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s34]: Postponing event ~p~n", [{'EndOfData'}]),
        {keep_state, Data, [postpone]}
    end;
s34(cast, {_CPid, {'DataLine'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s34]: Purging stale event ~p~n", [{'DataLine'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s34]: Postponing event ~p~n", [{'DataLine'}]),
        {keep_state, Data, [postpone]}
    end.

-spec s36(cast, {pid(), {'EndOfData'}, list()} | {pid(), {'Subject'}, list()} | {pid(), {'DataLine'}, list()}, state_data()) -> {next_state, s41, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
s36(cast, {CPid, {'EndOfData'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s36]: Purging stale event ~p~n", [{'EndOfData'}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s36(cast, {CPid, {'EndOfData'}}, Data)
               catch error:function_clause ->
                 io:format("gen_s[s36]: Callback had no clause for ~p, postponing~n", [{'EndOfData'}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> Next
        end
    end;
s36(cast, {CPid, {'Subject'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s36]: Purging stale event ~p~n", [{'Subject'}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s36(cast, {CPid, {'Subject'}}, Data)
               catch error:function_clause ->
                 io:format("gen_s[s36]: Callback had no clause for ~p, postponing~n", [{'Subject'}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> Next
        end
    end;
s36(cast, {CPid, {'DataLine'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s36]: Purging stale event ~p~n", [{'DataLine'}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s36(cast, {CPid, {'DataLine'}}, Data)
               catch error:function_clause ->
                 io:format("gen_s[s36]: Callback had no clause for ~p, postponing~n", [{'DataLine'}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> Next
        end
    end;
s36(cast, {_CPid, {'Ehlo'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s36]: Purging stale event ~p~n", [{'Ehlo'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s36]: Postponing event ~p~n", [{'Ehlo'}]),
        {keep_state, Data, [postpone]}
    end;
s36(cast, {_CPid, {'QuitCommit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s36]: Purging stale event ~p~n", [{'QuitCommit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s36]: Postponing event ~p~n", [{'QuitCommit'}]),
        {keep_state, Data, [postpone]}
    end;
s36(cast, {_CPid, {'StartTls'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s36]: Purging stale event ~p~n", [{'StartTls'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s36]: Postponing event ~p~n", [{'StartTls'}]),
        {keep_state, Data, [postpone]}
    end;
s36(cast, {_CPid, {'Quit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s36]: Purging stale event ~p~n", [{'Quit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s36]: Postponing event ~p~n", [{'Quit'}]),
        {keep_state, Data, [postpone]}
    end;
s36(cast, {_CPid, {'Ehlo1'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s36]: Purging stale event ~p~n", [{'Ehlo1'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s36]: Postponing event ~p~n", [{'Ehlo1'}]),
        {keep_state, Data, [postpone]}
    end;
s36(cast, {_CPid, {'Auth'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s36]: Purging stale event ~p~n", [{'Auth'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s36]: Postponing event ~p~n", [{'Auth'}]),
        {keep_state, Data, [postpone]}
    end;
s36(cast, {_CPid, {'Mail'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s36]: Purging stale event ~p~n", [{'Mail'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s36]: Postponing event ~p~n", [{'Mail'}]),
        {keep_state, Data, [postpone]}
    end;
s36(cast, {_CPid, {'Bogus'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s36]: Purging stale event ~p~n", [{'Bogus'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s36]: Postponing event ~p~n", [{'Bogus'}]),
        {keep_state, Data, [postpone]}
    end;
s36(cast, {_CPid, {'Rcpt'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s36]: Purging stale event ~p~n", [{'Rcpt'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s36]: Postponing event ~p~n", [{'Rcpt'}]),
        {keep_state, Data, [postpone]}
    end;
s36(cast, {_CPid, {'Data'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s36]: Purging stale event ~p~n", [{'Data'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s36]: Postponing event ~p~n", [{'Data'}]),
        {keep_state, Data, [postpone]}
    end.

-spec s41(internal, {'250'}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
s41(internal, {'250'}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s41(internal, {'250'}, Data),
        Next;
s41(cast, {_CPid, {'Ehlo'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s41]: Purging stale event ~p~n", [{'Ehlo'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s41]: Postponing event ~p~n", [{'Ehlo'}]),
        {keep_state, Data, [postpone]}
    end;
s41(cast, {_CPid, {'QuitCommit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s41]: Purging stale event ~p~n", [{'QuitCommit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s41]: Postponing event ~p~n", [{'QuitCommit'}]),
        {keep_state, Data, [postpone]}
    end;
s41(cast, {_CPid, {'StartTls'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s41]: Purging stale event ~p~n", [{'StartTls'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s41]: Postponing event ~p~n", [{'StartTls'}]),
        {keep_state, Data, [postpone]}
    end;
s41(cast, {_CPid, {'Quit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s41]: Purging stale event ~p~n", [{'Quit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s41]: Postponing event ~p~n", [{'Quit'}]),
        {keep_state, Data, [postpone]}
    end;
s41(cast, {_CPid, {'Ehlo1'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s41]: Purging stale event ~p~n", [{'Ehlo1'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s41]: Postponing event ~p~n", [{'Ehlo1'}]),
        {keep_state, Data, [postpone]}
    end;
s41(cast, {_CPid, {'Auth'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s41]: Purging stale event ~p~n", [{'Auth'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s41]: Postponing event ~p~n", [{'Auth'}]),
        {keep_state, Data, [postpone]}
    end;
s41(cast, {_CPid, {'Mail'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s41]: Purging stale event ~p~n", [{'Mail'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s41]: Postponing event ~p~n", [{'Mail'}]),
        {keep_state, Data, [postpone]}
    end;
s41(cast, {_CPid, {'Bogus'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s41]: Purging stale event ~p~n", [{'Bogus'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s41]: Postponing event ~p~n", [{'Bogus'}]),
        {keep_state, Data, [postpone]}
    end;
s41(cast, {_CPid, {'Rcpt'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s41]: Purging stale event ~p~n", [{'Rcpt'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s41]: Postponing event ~p~n", [{'Rcpt'}]),
        {keep_state, Data, [postpone]}
    end;
s41(cast, {_CPid, {'Data'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s41]: Purging stale event ~p~n", [{'Data'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s41]: Postponing event ~p~n", [{'Data'}]),
        {keep_state, Data, [postpone]}
    end;
s41(cast, {_CPid, {'Subject'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s41]: Purging stale event ~p~n", [{'Subject'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s41]: Postponing event ~p~n", [{'Subject'}]),
        {keep_state, Data, [postpone]}
    end;
s41(cast, {_CPid, {'EndOfData'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s41]: Purging stale event ~p~n", [{'EndOfData'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s41]: Postponing event ~p~n", [{'EndOfData'}]),
        {keep_state, Data, [postpone]}
    end;
s41(cast, {_CPid, {'DataLine'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s41]: Purging stale event ~p~n", [{'DataLine'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s41]: Postponing event ~p~n", [{'DataLine'}]),
        {keep_state, Data, [postpone]}
    end.

-spec s44(internal, {'221'}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
s44(internal, {'221'}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s44(internal, {'221'}, Data),
        Next;
s44(cast, {_CPid, {'Ehlo'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s44]: Purging stale event ~p~n", [{'Ehlo'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s44]: Postponing event ~p~n", [{'Ehlo'}]),
        {keep_state, Data, [postpone]}
    end;
s44(cast, {_CPid, {'QuitCommit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s44]: Purging stale event ~p~n", [{'QuitCommit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s44]: Postponing event ~p~n", [{'QuitCommit'}]),
        {keep_state, Data, [postpone]}
    end;
s44(cast, {_CPid, {'StartTls'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s44]: Purging stale event ~p~n", [{'StartTls'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s44]: Postponing event ~p~n", [{'StartTls'}]),
        {keep_state, Data, [postpone]}
    end;
s44(cast, {_CPid, {'Quit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s44]: Purging stale event ~p~n", [{'Quit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s44]: Postponing event ~p~n", [{'Quit'}]),
        {keep_state, Data, [postpone]}
    end;
s44(cast, {_CPid, {'Ehlo1'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s44]: Purging stale event ~p~n", [{'Ehlo1'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s44]: Postponing event ~p~n", [{'Ehlo1'}]),
        {keep_state, Data, [postpone]}
    end;
s44(cast, {_CPid, {'Auth'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s44]: Purging stale event ~p~n", [{'Auth'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s44]: Postponing event ~p~n", [{'Auth'}]),
        {keep_state, Data, [postpone]}
    end;
s44(cast, {_CPid, {'Mail'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s44]: Purging stale event ~p~n", [{'Mail'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s44]: Postponing event ~p~n", [{'Mail'}]),
        {keep_state, Data, [postpone]}
    end;
s44(cast, {_CPid, {'Bogus'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s44]: Purging stale event ~p~n", [{'Bogus'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s44]: Postponing event ~p~n", [{'Bogus'}]),
        {keep_state, Data, [postpone]}
    end;
s44(cast, {_CPid, {'Rcpt'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s44]: Purging stale event ~p~n", [{'Rcpt'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s44]: Postponing event ~p~n", [{'Rcpt'}]),
        {keep_state, Data, [postpone]}
    end;
s44(cast, {_CPid, {'Data'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s44]: Purging stale event ~p~n", [{'Data'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s44]: Postponing event ~p~n", [{'Data'}]),
        {keep_state, Data, [postpone]}
    end;
s44(cast, {_CPid, {'Subject'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s44]: Purging stale event ~p~n", [{'Subject'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s44]: Postponing event ~p~n", [{'Subject'}]),
        {keep_state, Data, [postpone]}
    end;
s44(cast, {_CPid, {'EndOfData'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s44]: Purging stale event ~p~n", [{'EndOfData'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s44]: Postponing event ~p~n", [{'EndOfData'}]),
        {keep_state, Data, [postpone]}
    end;
s44(cast, {_CPid, {'DataLine'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s44]: Purging stale event ~p~n", [{'DataLine'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s44]: Postponing event ~p~n", [{'DataLine'}]),
        {keep_state, Data, [postpone]}
    end.

-spec s49(internal, {'Ack'}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
s49(internal, {'Ack'}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s49(internal, {'Ack'}, Data),
        Next;
s49(cast, {_CPid, {'Ehlo'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s49]: Purging stale event ~p~n", [{'Ehlo'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s49]: Postponing event ~p~n", [{'Ehlo'}]),
        {keep_state, Data, [postpone]}
    end;
s49(cast, {_CPid, {'QuitCommit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s49]: Purging stale event ~p~n", [{'QuitCommit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s49]: Postponing event ~p~n", [{'QuitCommit'}]),
        {keep_state, Data, [postpone]}
    end;
s49(cast, {_CPid, {'StartTls'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s49]: Purging stale event ~p~n", [{'StartTls'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s49]: Postponing event ~p~n", [{'StartTls'}]),
        {keep_state, Data, [postpone]}
    end;
s49(cast, {_CPid, {'Quit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s49]: Purging stale event ~p~n", [{'Quit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s49]: Postponing event ~p~n", [{'Quit'}]),
        {keep_state, Data, [postpone]}
    end;
s49(cast, {_CPid, {'Ehlo1'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s49]: Purging stale event ~p~n", [{'Ehlo1'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s49]: Postponing event ~p~n", [{'Ehlo1'}]),
        {keep_state, Data, [postpone]}
    end;
s49(cast, {_CPid, {'Auth'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s49]: Purging stale event ~p~n", [{'Auth'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s49]: Postponing event ~p~n", [{'Auth'}]),
        {keep_state, Data, [postpone]}
    end;
s49(cast, {_CPid, {'Mail'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s49]: Purging stale event ~p~n", [{'Mail'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s49]: Postponing event ~p~n", [{'Mail'}]),
        {keep_state, Data, [postpone]}
    end;
s49(cast, {_CPid, {'Bogus'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s49]: Purging stale event ~p~n", [{'Bogus'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s49]: Postponing event ~p~n", [{'Bogus'}]),
        {keep_state, Data, [postpone]}
    end;
s49(cast, {_CPid, {'Rcpt'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s49]: Purging stale event ~p~n", [{'Rcpt'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s49]: Postponing event ~p~n", [{'Rcpt'}]),
        {keep_state, Data, [postpone]}
    end;
s49(cast, {_CPid, {'Data'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s49]: Purging stale event ~p~n", [{'Data'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s49]: Postponing event ~p~n", [{'Data'}]),
        {keep_state, Data, [postpone]}
    end;
s49(cast, {_CPid, {'Subject'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s49]: Purging stale event ~p~n", [{'Subject'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s49]: Postponing event ~p~n", [{'Subject'}]),
        {keep_state, Data, [postpone]}
    end;
s49(cast, {_CPid, {'EndOfData'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s49]: Purging stale event ~p~n", [{'EndOfData'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s49]: Postponing event ~p~n", [{'EndOfData'}]),
        {keep_state, Data, [postpone]}
    end;
s49(cast, {_CPid, {'DataLine'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s49]: Purging stale event ~p~n", [{'DataLine'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s49]: Postponing event ~p~n", [{'DataLine'}]),
        {keep_state, Data, [postpone]}
    end.

-spec s51(internal, {'Ack'}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
s51(internal, {'Ack'}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s51(internal, {'Ack'}, Data),
        Next;
s51(cast, {_CPid, {'Ehlo'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s51]: Purging stale event ~p~n", [{'Ehlo'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s51]: Postponing event ~p~n", [{'Ehlo'}]),
        {keep_state, Data, [postpone]}
    end;
s51(cast, {_CPid, {'QuitCommit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s51]: Purging stale event ~p~n", [{'QuitCommit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s51]: Postponing event ~p~n", [{'QuitCommit'}]),
        {keep_state, Data, [postpone]}
    end;
s51(cast, {_CPid, {'StartTls'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s51]: Purging stale event ~p~n", [{'StartTls'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s51]: Postponing event ~p~n", [{'StartTls'}]),
        {keep_state, Data, [postpone]}
    end;
s51(cast, {_CPid, {'Quit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s51]: Purging stale event ~p~n", [{'Quit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s51]: Postponing event ~p~n", [{'Quit'}]),
        {keep_state, Data, [postpone]}
    end;
s51(cast, {_CPid, {'Ehlo1'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s51]: Purging stale event ~p~n", [{'Ehlo1'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s51]: Postponing event ~p~n", [{'Ehlo1'}]),
        {keep_state, Data, [postpone]}
    end;
s51(cast, {_CPid, {'Auth'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s51]: Purging stale event ~p~n", [{'Auth'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s51]: Postponing event ~p~n", [{'Auth'}]),
        {keep_state, Data, [postpone]}
    end;
s51(cast, {_CPid, {'Mail'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s51]: Purging stale event ~p~n", [{'Mail'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s51]: Postponing event ~p~n", [{'Mail'}]),
        {keep_state, Data, [postpone]}
    end;
s51(cast, {_CPid, {'Bogus'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s51]: Purging stale event ~p~n", [{'Bogus'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s51]: Postponing event ~p~n", [{'Bogus'}]),
        {keep_state, Data, [postpone]}
    end;
s51(cast, {_CPid, {'Rcpt'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s51]: Purging stale event ~p~n", [{'Rcpt'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s51]: Postponing event ~p~n", [{'Rcpt'}]),
        {keep_state, Data, [postpone]}
    end;
s51(cast, {_CPid, {'Data'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s51]: Purging stale event ~p~n", [{'Data'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s51]: Postponing event ~p~n", [{'Data'}]),
        {keep_state, Data, [postpone]}
    end;
s51(cast, {_CPid, {'Subject'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s51]: Purging stale event ~p~n", [{'Subject'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s51]: Postponing event ~p~n", [{'Subject'}]),
        {keep_state, Data, [postpone]}
    end;
s51(cast, {_CPid, {'EndOfData'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s51]: Purging stale event ~p~n", [{'EndOfData'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s51]: Postponing event ~p~n", [{'EndOfData'}]),
        {keep_state, Data, [postpone]}
    end;
s51(cast, {_CPid, {'DataLine'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s51]: Purging stale event ~p~n", [{'DataLine'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s51]: Postponing event ~p~n", [{'DataLine'}]),
        {keep_state, Data, [postpone]}
    end.

-spec s53(internal, {'AckCommit'}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
s53(internal, {'AckCommit'}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s53(internal, {'AckCommit'}, Data),
        Next;
s53(cast, {_CPid, {'Ehlo'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s53]: Purging stale event ~p~n", [{'Ehlo'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s53]: Postponing event ~p~n", [{'Ehlo'}]),
        {keep_state, Data, [postpone]}
    end;
s53(cast, {_CPid, {'QuitCommit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s53]: Purging stale event ~p~n", [{'QuitCommit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s53]: Postponing event ~p~n", [{'QuitCommit'}]),
        {keep_state, Data, [postpone]}
    end;
s53(cast, {_CPid, {'StartTls'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s53]: Purging stale event ~p~n", [{'StartTls'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s53]: Postponing event ~p~n", [{'StartTls'}]),
        {keep_state, Data, [postpone]}
    end;
s53(cast, {_CPid, {'Quit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s53]: Purging stale event ~p~n", [{'Quit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s53]: Postponing event ~p~n", [{'Quit'}]),
        {keep_state, Data, [postpone]}
    end;
s53(cast, {_CPid, {'Ehlo1'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s53]: Purging stale event ~p~n", [{'Ehlo1'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s53]: Postponing event ~p~n", [{'Ehlo1'}]),
        {keep_state, Data, [postpone]}
    end;
s53(cast, {_CPid, {'Auth'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s53]: Purging stale event ~p~n", [{'Auth'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s53]: Postponing event ~p~n", [{'Auth'}]),
        {keep_state, Data, [postpone]}
    end;
s53(cast, {_CPid, {'Mail'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s53]: Purging stale event ~p~n", [{'Mail'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s53]: Postponing event ~p~n", [{'Mail'}]),
        {keep_state, Data, [postpone]}
    end;
s53(cast, {_CPid, {'Bogus'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s53]: Purging stale event ~p~n", [{'Bogus'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s53]: Postponing event ~p~n", [{'Bogus'}]),
        {keep_state, Data, [postpone]}
    end;
s53(cast, {_CPid, {'Rcpt'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s53]: Purging stale event ~p~n", [{'Rcpt'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s53]: Postponing event ~p~n", [{'Rcpt'}]),
        {keep_state, Data, [postpone]}
    end;
s53(cast, {_CPid, {'Data'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s53]: Purging stale event ~p~n", [{'Data'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s53]: Postponing event ~p~n", [{'Data'}]),
        {keep_state, Data, [postpone]}
    end;
s53(cast, {_CPid, {'Subject'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s53]: Purging stale event ~p~n", [{'Subject'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s53]: Postponing event ~p~n", [{'Subject'}]),
        {keep_state, Data, [postpone]}
    end;
s53(cast, {_CPid, {'EndOfData'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s53]: Purging stale event ~p~n", [{'EndOfData'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s53]: Postponing event ~p~n", [{'EndOfData'}]),
        {keep_state, Data, [postpone]}
    end;
s53(cast, {_CPid, {'DataLine'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_s[s53]: Purging stale event ~p~n", [{'DataLine'}]),
        {keep_state, Data};
      false ->
        io:format("gen_s[s53]: Postponing event ~p~n", [{'DataLine'}]),
        {keep_state, Data, [postpone]}
    end.


%% ---------- Send helpers----------

-spec send_s1_220(CPid :: pid(), _Data :: state_data()) -> ok.
send_s1_220(CPid, _Data) ->
    gen_statem:cast(CPid, {self(), {'220'}}).


-spec send_s5_Timeout(CPid :: pid(), _Data :: state_data()) -> ok.
send_s5_Timeout(CPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(CPid, {self(), {'Timeout'}, Path}).


-spec send_s6_EhloCommit(CPid :: pid(), _Data :: state_data()) -> ok.
send_s6_EhloCommit(CPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(CPid, {self(), {'EhloCommit'}, Path}).


-spec send_s8_250d(CPid :: pid(), _Data :: state_data()) -> ok.
send_s8_250d(CPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(CPid, {self(), {'250d'}, Path}).


-spec send_s8_250(CPid :: pid(), _Data :: state_data()) -> ok.
send_s8_250(CPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(CPid, {self(), {'250'}, Path}).


-spec send_s12_220(CPid :: pid(), _Data :: state_data()) -> ok.
send_s12_220(CPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(CPid, {self(), {'220'}, Path}).


-spec send_s15_250(CPid :: pid(), _Data :: state_data()) -> ok.
send_s15_250(CPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(CPid, {self(), {'250'}, Path}).


-spec send_s15_250d(CPid :: pid(), _Data :: state_data()) -> ok.
send_s15_250d(CPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(CPid, {self(), {'250d'}, Path}).


-spec send_s20_535(CPid :: pid(), _Data :: state_data()) -> ok.
send_s20_535(CPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(CPid, {self(), {'535'}, Path}).


-spec send_s20_235(CPid :: pid(), _Data :: state_data()) -> ok.
send_s20_235(CPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(CPid, {self(), {'235'}, Path}).


-spec send_s23_501(CPid :: pid(), _Data :: state_data()) -> ok.
send_s23_501(CPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(CPid, {self(), {'501'}, Path}).


-spec send_s23_250(CPid :: pid(), _Data :: state_data()) -> ok.
send_s23_250(CPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(CPid, {self(), {'250'}, Path}).


-spec send_s28_250(CPid :: pid(), _Data :: state_data()) -> ok.
send_s28_250(CPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(CPid, {self(), {'250'}, Path}).


-spec send_s33_Timeout(CPid :: pid(), _Data :: state_data()) -> ok.
send_s33_Timeout(CPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(CPid, {self(), {'Timeout'}, Path}).


-spec send_s34_354(CPid :: pid(), _Data :: state_data()) -> ok.
send_s34_354(CPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(CPid, {self(), {'354'}, Path}).


-spec send_s41_250(CPid :: pid(), _Data :: state_data()) -> ok.
send_s41_250(CPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(CPid, {self(), {'250'}, Path}).


-spec send_s44_221(CPid :: pid(), _Data :: state_data()) -> ok.
send_s44_221(CPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(CPid, {self(), {'221'}, Path}).


-spec send_s49_Ack(CPid :: pid(), _Data :: state_data()) -> ok.
send_s49_Ack(CPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(CPid, {self(), {'Ack'}, Path}).


-spec send_s51_Ack(CPid :: pid(), _Data :: state_data()) -> ok.
send_s51_Ack(CPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(CPid, {self(), {'Ack'}, Path}).


-spec send_s53_AckCommit(CPid :: pid(), _Data :: state_data()) -> ok.
send_s53_AckCommit(CPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(CPid, {self(), {'AckCommit'}, Path}).


%% ===== misc OTP =====
-spec code_change(OldVsn :: term(), StateName :: atom(), StateData :: state_data(), Extra :: term()) ->
    {ok, state_data()}.
code_change(_Vsn, _StateName, StateData, _Extra) ->
    {ok, StateData}.

-spec terminate(Reason :: term(), State :: atom(), Data :: state_data()) -> ok.
terminate(_Reason, _State, _StateData) ->
    ok.


%% ---------- GC / commitment helpers (per-mixed-choice side) ----------
%% We track, per MC id, which side this role is committed to: left | right.
%% Uncommitted MCs have no entry.
get_commit() -> case get(commit_map) of undefined -> #{}; M -> M end.
set_commit(M) -> put(commit_map, M), M.

-spec commit_entry(atom(), left | right) -> map().
commit_entry(McId, Side) when Side =:= left; Side =:= right ->
    set_commit(maps:put(McId, Side, get_commit())).

%% Staleness follows Section 4.1: a message is stale if, for some MC on its Path,
%% following the Path hits a stale side (i.e., we are committed to the opposite side).
%% We approximate local type commitment using the commit_map.

-spec stale([{atom(), left | right}]) -> boolean().
stale(Path) when is_list(Path) ->
    Commit = get_commit(),
    lists:any(
      fun({Mc, MsgSide}) ->
        case maps:find(Mc, Commit) of
          error -> false; %% not committed => nothing is stale for this MC
          {ok, LocalSide} -> LocalSide =/= MsgSide
        end
      end, Path).


%% current_path/0 is used only to annotate outgoing messages with the sender's
%% current MC context, when this role is inside an active mixed-choice region.
-spec current_path() -> [{atom(), left | right}].
current_path() ->
    Commit = get_commit(),
    lists:sort(maps:to_list(Commit)).

