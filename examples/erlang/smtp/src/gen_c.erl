
%%%-------------------------------------------------------------------
%%% gen_c.erl — generated generic behaviour module (gen_statem)
%%%-------------------------------------------------------------------
-module(gen_c).
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
  send_s5_Ehlo/2,
  send_s5_QuitCommit/2,
  send_s11_StartTls/2,
  send_s11_Quit/2,
  send_s13_Ehlo1/2,
  send_s13_Quit/2,
  send_s19_Auth/2,
  send_s19_Quit/2,
  send_s22_Mail/2,
  send_s22_Quit/2,
  send_s27_Rcpt/2,
  send_s27_Bogus/2,
  send_s33_Data/2,
  send_s36_DataLine/2,
  send_s36_Subject/2,
  send_s36_EndOfData/2]).

%% Types & records
-include("c.hrl").
-export_type([state_data/0]).
-type state_data() :: #state_data{}.

-callback init(Args :: list()) -> {ok, s1, state_data()}.
-callback s1(cast, {pid(), {'220'}}, state_data()) -> {next_state, s5, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s5(internal | cast, {'Ehlo'} | {'QuitCommit'} | {pid(), {'Timeout'}}, state_data()) -> {next_state, s53, state_data()} | {next_state, s6, state_data()} | {next_state, s53, state_data(), [{next_event, internal, {'Ehlo'}}] } | {next_state, s53, state_data(), [{next_event, internal, {'QuitCommit'}}] } | {next_state, s6, state_data(), [{next_event, internal, {'Ehlo'}}] } | {next_state, s6, state_data(), [{next_event, internal, {'QuitCommit'}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s6(cast, {pid(), {'EhloCommit'}} | {pid(), {'Timeout'}}, state_data()) -> {next_state, s8, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s8(cast, {pid(), {'250'}} | {pid(), {'250d'}}, state_data()) -> {next_state, s11, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s11(internal, {'Quit'} | {'StartTls'}, state_data()) -> {next_state, s12, state_data()} | {next_state, s51, state_data()} | {next_state, s12, state_data(), [{next_event, internal, {'Quit'}}] } | {next_state, s12, state_data(), [{next_event, internal, {'StartTls'}}] } | {next_state, s51, state_data(), [{next_event, internal, {'Quit'}}] } | {next_state, s51, state_data(), [{next_event, internal, {'StartTls'}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s12(cast, {pid(), {'220'}}, state_data()) -> {next_state, s13, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s13(internal, {'Ehlo1'} | {'Quit'}, state_data()) -> {next_state, s15, state_data()} | {next_state, s49, state_data()} | {next_state, s15, state_data(), [{next_event, internal, {'Ehlo1'}}] } | {next_state, s15, state_data(), [{next_event, internal, {'Quit'}}] } | {next_state, s49, state_data(), [{next_event, internal, {'Ehlo1'}}] } | {next_state, s49, state_data(), [{next_event, internal, {'Quit'}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s15(cast, {pid(), {'250'}} | {pid(), {'250d'}}, state_data()) -> {next_state, s19, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s19(internal, {'Auth'} | {'Quit'}, state_data()) -> {next_state, s20, state_data()} | {next_state, s20, state_data(), [{next_event, internal, {'Auth'}}] } | {next_state, s20, state_data(), [{next_event, internal, {'Quit'}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s20(cast, {pid(), {'235'}} | {pid(), {'535'}}, state_data()) -> {next_state, s22, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s22(internal, {'Mail'} | {'Quit'}, state_data()) -> {next_state, s23, state_data()} | {next_state, s44, state_data()} | {next_state, s23, state_data(), [{next_event, internal, {'Mail'}}] } | {next_state, s23, state_data(), [{next_event, internal, {'Quit'}}] } | {next_state, s44, state_data(), [{next_event, internal, {'Mail'}}] } | {next_state, s44, state_data(), [{next_event, internal, {'Quit'}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s23(cast, {pid(), {'250'}} | {pid(), {'501'}}, state_data()) -> {next_state, s27, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s27(internal, {'Bogus'} | {'Rcpt'}, state_data()) -> {next_state, s28, state_data()} | {next_state, s33, state_data()} | {next_state, s28, state_data(), [{next_event, internal, {'Bogus'}}] } | {next_state, s28, state_data(), [{next_event, internal, {'Rcpt'}}] } | {next_state, s33, state_data(), [{next_event, internal, {'Bogus'}}] } | {next_state, s33, state_data(), [{next_event, internal, {'Rcpt'}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s28(cast, {pid(), {'250'}}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s33(internal | cast, {'Data'} | {pid(), {'Timeout'}}, state_data()) -> {next_state, s34, state_data()} | {next_state, s34, state_data(), [{next_event, internal, {'Data'}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s34(cast, {pid(), {'354'}} | {pid(), {'Timeout'}}, state_data()) -> {next_state, s36, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s36(internal, {'DataLine'} | {'EndOfData'} | {'Subject'}, state_data()) -> {next_state, s41, state_data()} | {next_state, s41, state_data(), [{next_event, internal, {'DataLine'}}] } | {next_state, s41, state_data(), [{next_event, internal, {'EndOfData'}}] } | {next_state, s41, state_data(), [{next_event, internal, {'Subject'}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s41(cast, {pid(), {'250'}}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s44(cast, {pid(), {'221'}}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s49(cast, {pid(), {'Ack'}}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s51(cast, {pid(), {'Ack'}}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
-callback s53(cast, {pid(), {'AckCommit'}} | {pid(), {'Timeout'}}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.

%% ===== API =====
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
callback_mode() -> state_functions.

%% ===== gen_statem =====
-spec init({module(), list()}) ->
    {ok, s1, state_data()}.
init({CallbackModule, _Args}) ->
    io:format("c: Initializing with callback module ~p~n", [CallbackModule]),
    put(callback_module, CallbackModule),
    set_commit(#{}),
    CallbackModule:init([]).

%% ---------- State functions----------
-spec s1(cast, {pid(), {'220'}}, state_data()) -> {next_state, s5, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
s1(cast, {SPid, {'220'}}, Data) ->
    CallbackModule = get(callback_module),
    try CallbackModule:s1(cast, {SPid, {'220'}}, Data)
    catch error:function_clause ->
      io:format("gen_c[s1]: Callback had no clause for ~p, ignoring~n", [{'220'}]),
      {keep_state, Data}
    end;
s1(cast, {_From, _Msg, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s1]: Purging stale early-path event ~p~n", [_Msg]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s1]: Postponing early-path event ~p~n", [_Msg]),
        {keep_state, Data, [postpone]}
    end.

%% Mixed-choice entry state
-spec s5(internal | cast, {'Ehlo'} | {'QuitCommit'} | {pid(), {'Timeout'}, list()}, state_data()) -> {next_state, s53, state_data()} | {next_state, s6, state_data()} | {next_state, s53, state_data(), [{next_event, internal, {'Ehlo'}}] } | {next_state, s53, state_data(), [{next_event, internal, {'QuitCommit'}}] } | {next_state, s6, state_data(), [{next_event, internal, {'Ehlo'}}] } | {next_state, s6, state_data(), [{next_event, internal, {'QuitCommit'}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s5(internal, {'QuitCommit'}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s5(internal, {'QuitCommit'}, Data),
        Next;
s5(internal, {'Ehlo'}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s5(internal, {'Ehlo'}, Data),
        Next;
s5(cast, {SPid, {'Timeout'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s5]: Purging stale event ~p~n", [{'Timeout'}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s5(cast, {SPid, {'Timeout'}}, Data)
               catch error:function_clause ->
                 io:format("gen_c[s5]: Callback had no clause for ~p, postponing~n", [{'Timeout'}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {next_state, s6, _} -> commit_entry(mc1, right), Next;
          {next_state, s6, _, _} -> commit_entry(mc1, right), Next;
          {next_state, s2, _} -> commit_entry(mc1, left), Next;
          {next_state, s2, _, _} -> commit_entry(mc1, left), Next;
          _ -> Next
        end
    end;
s5(cast, {_SPid, {'220'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s5]: Purging stale event ~p~n", [{'220'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s5]: Postponing event ~p~n", [{'220'}]),
        {keep_state, Data, [postpone]}
    end;
s5(cast, {_SPid, {'EhloCommit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s5]: Purging stale event ~p~n", [{'EhloCommit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s5]: Postponing event ~p~n", [{'EhloCommit'}]),
        {keep_state, Data, [postpone]}
    end;
s5(cast, {_SPid, {'250d'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s5]: Purging stale event ~p~n", [{'250d'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s5]: Postponing event ~p~n", [{'250d'}]),
        {keep_state, Data, [postpone]}
    end;
s5(cast, {_SPid, {'250'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s5]: Purging stale event ~p~n", [{'250'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s5]: Postponing event ~p~n", [{'250'}]),
        {keep_state, Data, [postpone]}
    end;
s5(cast, {_SPid, {'235'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s5]: Purging stale event ~p~n", [{'235'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s5]: Postponing event ~p~n", [{'235'}]),
        {keep_state, Data, [postpone]}
    end;
s5(cast, {_SPid, {'535'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s5]: Purging stale event ~p~n", [{'535'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s5]: Postponing event ~p~n", [{'535'}]),
        {keep_state, Data, [postpone]}
    end;
s5(cast, {_SPid, {'501'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s5]: Purging stale event ~p~n", [{'501'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s5]: Postponing event ~p~n", [{'501'}]),
        {keep_state, Data, [postpone]}
    end;
s5(cast, {_SPid, {'354'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s5]: Purging stale event ~p~n", [{'354'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s5]: Postponing event ~p~n", [{'354'}]),
        {keep_state, Data, [postpone]}
    end;
s5(cast, {_SPid, {'221'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s5]: Purging stale event ~p~n", [{'221'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s5]: Postponing event ~p~n", [{'221'}]),
        {keep_state, Data, [postpone]}
    end;
s5(cast, {_SPid, {'Ack'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s5]: Purging stale event ~p~n", [{'Ack'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s5]: Postponing event ~p~n", [{'Ack'}]),
        {keep_state, Data, [postpone]}
    end;
s5(cast, {_SPid, {'AckCommit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s5]: Purging stale event ~p~n", [{'AckCommit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s5]: Postponing event ~p~n", [{'AckCommit'}]),
        {keep_state, Data, [postpone]}
    end.

-spec s6(cast, {pid(), {'EhloCommit'}, list()} | {pid(), {'Timeout'}, list()}, state_data()) -> {next_state, s8, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
s6(cast, {SPid, {'EhloCommit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s6]: Purging stale event ~p~n", [{'EhloCommit'}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s6(cast, {SPid, {'EhloCommit'}}, Data)
               catch error:function_clause ->
                 io:format("gen_c[s6]: Callback had no clause for ~p, postponing~n", [{'EhloCommit'}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> Next
        end
    end;
s6(cast, {SPid, {'Timeout'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s6]: Purging stale event ~p~n", [{'Timeout'}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s6(cast, {SPid, {'Timeout'}}, Data)
               catch error:function_clause ->
                 io:format("gen_c[s6]: Callback had no clause for ~p, postponing~n", [{'Timeout'}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> Next
        end
    end;
s6(cast, {_SPid, {'220'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s6]: Purging stale event ~p~n", [{'220'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s6]: Postponing event ~p~n", [{'220'}]),
        {keep_state, Data, [postpone]}
    end;
s6(cast, {_SPid, {'250d'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s6]: Purging stale event ~p~n", [{'250d'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s6]: Postponing event ~p~n", [{'250d'}]),
        {keep_state, Data, [postpone]}
    end;
s6(cast, {_SPid, {'250'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s6]: Purging stale event ~p~n", [{'250'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s6]: Postponing event ~p~n", [{'250'}]),
        {keep_state, Data, [postpone]}
    end;
s6(cast, {_SPid, {'235'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s6]: Purging stale event ~p~n", [{'235'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s6]: Postponing event ~p~n", [{'235'}]),
        {keep_state, Data, [postpone]}
    end;
s6(cast, {_SPid, {'535'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s6]: Purging stale event ~p~n", [{'535'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s6]: Postponing event ~p~n", [{'535'}]),
        {keep_state, Data, [postpone]}
    end;
s6(cast, {_SPid, {'501'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s6]: Purging stale event ~p~n", [{'501'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s6]: Postponing event ~p~n", [{'501'}]),
        {keep_state, Data, [postpone]}
    end;
s6(cast, {_SPid, {'354'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s6]: Purging stale event ~p~n", [{'354'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s6]: Postponing event ~p~n", [{'354'}]),
        {keep_state, Data, [postpone]}
    end;
s6(cast, {_SPid, {'221'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s6]: Purging stale event ~p~n", [{'221'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s6]: Postponing event ~p~n", [{'221'}]),
        {keep_state, Data, [postpone]}
    end;
s6(cast, {_SPid, {'Ack'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s6]: Purging stale event ~p~n", [{'Ack'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s6]: Postponing event ~p~n", [{'Ack'}]),
        {keep_state, Data, [postpone]}
    end;
s6(cast, {_SPid, {'AckCommit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s6]: Purging stale event ~p~n", [{'AckCommit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s6]: Postponing event ~p~n", [{'AckCommit'}]),
        {keep_state, Data, [postpone]}
    end.

-spec s8(cast, {pid(), {'250d'}, list()} | {pid(), {'250'}, list()}, state_data()) -> {next_state, s11, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
s8(cast, {SPid, {'250d'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s8]: Purging stale event ~p~n", [{'250d'}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s8(cast, {SPid, {'250d'}}, Data)
               catch error:function_clause ->
                 io:format("gen_c[s8]: Callback had no clause for ~p, postponing~n", [{'250d'}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> Next
        end
    end;
s8(cast, {SPid, {'250'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s8]: Purging stale event ~p~n", [{'250'}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s8(cast, {SPid, {'250'}}, Data)
               catch error:function_clause ->
                 io:format("gen_c[s8]: Callback had no clause for ~p, postponing~n", [{'250'}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> Next
        end
    end;
s8(cast, {_SPid, {'220'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s8]: Purging stale event ~p~n", [{'220'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s8]: Postponing event ~p~n", [{'220'}]),
        {keep_state, Data, [postpone]}
    end;
s8(cast, {_SPid, {'Timeout'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s8]: Purging stale event ~p~n", [{'Timeout'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s8]: Postponing event ~p~n", [{'Timeout'}]),
        {keep_state, Data, [postpone]}
    end;
s8(cast, {_SPid, {'EhloCommit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s8]: Purging stale event ~p~n", [{'EhloCommit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s8]: Postponing event ~p~n", [{'EhloCommit'}]),
        {keep_state, Data, [postpone]}
    end;
s8(cast, {_SPid, {'235'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s8]: Purging stale event ~p~n", [{'235'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s8]: Postponing event ~p~n", [{'235'}]),
        {keep_state, Data, [postpone]}
    end;
s8(cast, {_SPid, {'535'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s8]: Purging stale event ~p~n", [{'535'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s8]: Postponing event ~p~n", [{'535'}]),
        {keep_state, Data, [postpone]}
    end;
s8(cast, {_SPid, {'501'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s8]: Purging stale event ~p~n", [{'501'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s8]: Postponing event ~p~n", [{'501'}]),
        {keep_state, Data, [postpone]}
    end;
s8(cast, {_SPid, {'354'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s8]: Purging stale event ~p~n", [{'354'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s8]: Postponing event ~p~n", [{'354'}]),
        {keep_state, Data, [postpone]}
    end;
s8(cast, {_SPid, {'221'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s8]: Purging stale event ~p~n", [{'221'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s8]: Postponing event ~p~n", [{'221'}]),
        {keep_state, Data, [postpone]}
    end;
s8(cast, {_SPid, {'Ack'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s8]: Purging stale event ~p~n", [{'Ack'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s8]: Postponing event ~p~n", [{'Ack'}]),
        {keep_state, Data, [postpone]}
    end;
s8(cast, {_SPid, {'AckCommit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s8]: Purging stale event ~p~n", [{'AckCommit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s8]: Postponing event ~p~n", [{'AckCommit'}]),
        {keep_state, Data, [postpone]}
    end.

-spec s11(internal, {'Quit'} | {'StartTls'}, state_data()) -> {next_state, s12, state_data()} | {next_state, s51, state_data()} | {next_state, s12, state_data(), [{next_event, internal, {'Quit'}}] } | {next_state, s12, state_data(), [{next_event, internal, {'StartTls'}}] } | {next_state, s51, state_data(), [{next_event, internal, {'Quit'}}] } | {next_state, s51, state_data(), [{next_event, internal, {'StartTls'}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s11(internal, {'StartTls'}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s11(internal, {'StartTls'}, Data),
        Next;
s11(internal, {'Quit'}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s11(internal, {'Quit'}, Data),
        Next;
s11(cast, {_SPid, {'220'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s11]: Purging stale event ~p~n", [{'220'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s11]: Postponing event ~p~n", [{'220'}]),
        {keep_state, Data, [postpone]}
    end;
s11(cast, {_SPid, {'Timeout'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s11]: Purging stale event ~p~n", [{'Timeout'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s11]: Postponing event ~p~n", [{'Timeout'}]),
        {keep_state, Data, [postpone]}
    end;
s11(cast, {_SPid, {'EhloCommit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s11]: Purging stale event ~p~n", [{'EhloCommit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s11]: Postponing event ~p~n", [{'EhloCommit'}]),
        {keep_state, Data, [postpone]}
    end;
s11(cast, {_SPid, {'250d'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s11]: Purging stale event ~p~n", [{'250d'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s11]: Postponing event ~p~n", [{'250d'}]),
        {keep_state, Data, [postpone]}
    end;
s11(cast, {_SPid, {'250'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s11]: Purging stale event ~p~n", [{'250'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s11]: Postponing event ~p~n", [{'250'}]),
        {keep_state, Data, [postpone]}
    end;
s11(cast, {_SPid, {'235'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s11]: Purging stale event ~p~n", [{'235'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s11]: Postponing event ~p~n", [{'235'}]),
        {keep_state, Data, [postpone]}
    end;
s11(cast, {_SPid, {'535'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s11]: Purging stale event ~p~n", [{'535'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s11]: Postponing event ~p~n", [{'535'}]),
        {keep_state, Data, [postpone]}
    end;
s11(cast, {_SPid, {'501'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s11]: Purging stale event ~p~n", [{'501'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s11]: Postponing event ~p~n", [{'501'}]),
        {keep_state, Data, [postpone]}
    end;
s11(cast, {_SPid, {'354'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s11]: Purging stale event ~p~n", [{'354'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s11]: Postponing event ~p~n", [{'354'}]),
        {keep_state, Data, [postpone]}
    end;
s11(cast, {_SPid, {'221'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s11]: Purging stale event ~p~n", [{'221'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s11]: Postponing event ~p~n", [{'221'}]),
        {keep_state, Data, [postpone]}
    end;
s11(cast, {_SPid, {'Ack'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s11]: Purging stale event ~p~n", [{'Ack'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s11]: Postponing event ~p~n", [{'Ack'}]),
        {keep_state, Data, [postpone]}
    end;
s11(cast, {_SPid, {'AckCommit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s11]: Purging stale event ~p~n", [{'AckCommit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s11]: Postponing event ~p~n", [{'AckCommit'}]),
        {keep_state, Data, [postpone]}
    end.

-spec s12(cast, {pid(), {'220'}, list()}, state_data()) -> {next_state, s13, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
s12(cast, {SPid, {'220'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s12]: Purging stale event ~p~n", [{'220'}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s12(cast, {SPid, {'220'}}, Data)
               catch error:function_clause ->
                 io:format("gen_c[s12]: Callback had no clause for ~p, postponing~n", [{'220'}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> Next
        end
    end;
s12(cast, {_SPid, {'Timeout'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s12]: Purging stale event ~p~n", [{'Timeout'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s12]: Postponing event ~p~n", [{'Timeout'}]),
        {keep_state, Data, [postpone]}
    end;
s12(cast, {_SPid, {'EhloCommit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s12]: Purging stale event ~p~n", [{'EhloCommit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s12]: Postponing event ~p~n", [{'EhloCommit'}]),
        {keep_state, Data, [postpone]}
    end;
s12(cast, {_SPid, {'250d'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s12]: Purging stale event ~p~n", [{'250d'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s12]: Postponing event ~p~n", [{'250d'}]),
        {keep_state, Data, [postpone]}
    end;
s12(cast, {_SPid, {'250'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s12]: Purging stale event ~p~n", [{'250'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s12]: Postponing event ~p~n", [{'250'}]),
        {keep_state, Data, [postpone]}
    end;
s12(cast, {_SPid, {'235'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s12]: Purging stale event ~p~n", [{'235'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s12]: Postponing event ~p~n", [{'235'}]),
        {keep_state, Data, [postpone]}
    end;
s12(cast, {_SPid, {'535'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s12]: Purging stale event ~p~n", [{'535'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s12]: Postponing event ~p~n", [{'535'}]),
        {keep_state, Data, [postpone]}
    end;
s12(cast, {_SPid, {'501'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s12]: Purging stale event ~p~n", [{'501'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s12]: Postponing event ~p~n", [{'501'}]),
        {keep_state, Data, [postpone]}
    end;
s12(cast, {_SPid, {'354'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s12]: Purging stale event ~p~n", [{'354'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s12]: Postponing event ~p~n", [{'354'}]),
        {keep_state, Data, [postpone]}
    end;
s12(cast, {_SPid, {'221'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s12]: Purging stale event ~p~n", [{'221'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s12]: Postponing event ~p~n", [{'221'}]),
        {keep_state, Data, [postpone]}
    end;
s12(cast, {_SPid, {'Ack'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s12]: Purging stale event ~p~n", [{'Ack'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s12]: Postponing event ~p~n", [{'Ack'}]),
        {keep_state, Data, [postpone]}
    end;
s12(cast, {_SPid, {'AckCommit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s12]: Purging stale event ~p~n", [{'AckCommit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s12]: Postponing event ~p~n", [{'AckCommit'}]),
        {keep_state, Data, [postpone]}
    end.

-spec s13(internal, {'Ehlo1'} | {'Quit'}, state_data()) -> {next_state, s15, state_data()} | {next_state, s49, state_data()} | {next_state, s15, state_data(), [{next_event, internal, {'Ehlo1'}}] } | {next_state, s15, state_data(), [{next_event, internal, {'Quit'}}] } | {next_state, s49, state_data(), [{next_event, internal, {'Ehlo1'}}] } | {next_state, s49, state_data(), [{next_event, internal, {'Quit'}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s13(internal, {'Ehlo1'}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s13(internal, {'Ehlo1'}, Data),
        Next;
s13(internal, {'Quit'}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s13(internal, {'Quit'}, Data),
        Next;
s13(cast, {_SPid, {'220'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s13]: Purging stale event ~p~n", [{'220'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s13]: Postponing event ~p~n", [{'220'}]),
        {keep_state, Data, [postpone]}
    end;
s13(cast, {_SPid, {'Timeout'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s13]: Purging stale event ~p~n", [{'Timeout'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s13]: Postponing event ~p~n", [{'Timeout'}]),
        {keep_state, Data, [postpone]}
    end;
s13(cast, {_SPid, {'EhloCommit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s13]: Purging stale event ~p~n", [{'EhloCommit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s13]: Postponing event ~p~n", [{'EhloCommit'}]),
        {keep_state, Data, [postpone]}
    end;
s13(cast, {_SPid, {'250d'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s13]: Purging stale event ~p~n", [{'250d'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s13]: Postponing event ~p~n", [{'250d'}]),
        {keep_state, Data, [postpone]}
    end;
s13(cast, {_SPid, {'250'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s13]: Purging stale event ~p~n", [{'250'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s13]: Postponing event ~p~n", [{'250'}]),
        {keep_state, Data, [postpone]}
    end;
s13(cast, {_SPid, {'235'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s13]: Purging stale event ~p~n", [{'235'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s13]: Postponing event ~p~n", [{'235'}]),
        {keep_state, Data, [postpone]}
    end;
s13(cast, {_SPid, {'535'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s13]: Purging stale event ~p~n", [{'535'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s13]: Postponing event ~p~n", [{'535'}]),
        {keep_state, Data, [postpone]}
    end;
s13(cast, {_SPid, {'501'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s13]: Purging stale event ~p~n", [{'501'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s13]: Postponing event ~p~n", [{'501'}]),
        {keep_state, Data, [postpone]}
    end;
s13(cast, {_SPid, {'354'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s13]: Purging stale event ~p~n", [{'354'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s13]: Postponing event ~p~n", [{'354'}]),
        {keep_state, Data, [postpone]}
    end;
s13(cast, {_SPid, {'221'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s13]: Purging stale event ~p~n", [{'221'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s13]: Postponing event ~p~n", [{'221'}]),
        {keep_state, Data, [postpone]}
    end;
s13(cast, {_SPid, {'Ack'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s13]: Purging stale event ~p~n", [{'Ack'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s13]: Postponing event ~p~n", [{'Ack'}]),
        {keep_state, Data, [postpone]}
    end;
s13(cast, {_SPid, {'AckCommit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s13]: Purging stale event ~p~n", [{'AckCommit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s13]: Postponing event ~p~n", [{'AckCommit'}]),
        {keep_state, Data, [postpone]}
    end.

-spec s15(cast, {pid(), {'250d'}, list()} | {pid(), {'250'}, list()}, state_data()) -> {next_state, s19, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
s15(cast, {SPid, {'250'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s15]: Purging stale event ~p~n", [{'250'}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s15(cast, {SPid, {'250'}}, Data)
               catch error:function_clause ->
                 io:format("gen_c[s15]: Callback had no clause for ~p, postponing~n", [{'250'}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> Next
        end
    end;
s15(cast, {SPid, {'250d'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s15]: Purging stale event ~p~n", [{'250d'}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s15(cast, {SPid, {'250d'}}, Data)
               catch error:function_clause ->
                 io:format("gen_c[s15]: Callback had no clause for ~p, postponing~n", [{'250d'}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> Next
        end
    end;
s15(cast, {_SPid, {'220'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s15]: Purging stale event ~p~n", [{'220'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s15]: Postponing event ~p~n", [{'220'}]),
        {keep_state, Data, [postpone]}
    end;
s15(cast, {_SPid, {'Timeout'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s15]: Purging stale event ~p~n", [{'Timeout'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s15]: Postponing event ~p~n", [{'Timeout'}]),
        {keep_state, Data, [postpone]}
    end;
s15(cast, {_SPid, {'EhloCommit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s15]: Purging stale event ~p~n", [{'EhloCommit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s15]: Postponing event ~p~n", [{'EhloCommit'}]),
        {keep_state, Data, [postpone]}
    end;
s15(cast, {_SPid, {'235'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s15]: Purging stale event ~p~n", [{'235'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s15]: Postponing event ~p~n", [{'235'}]),
        {keep_state, Data, [postpone]}
    end;
s15(cast, {_SPid, {'535'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s15]: Purging stale event ~p~n", [{'535'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s15]: Postponing event ~p~n", [{'535'}]),
        {keep_state, Data, [postpone]}
    end;
s15(cast, {_SPid, {'501'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s15]: Purging stale event ~p~n", [{'501'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s15]: Postponing event ~p~n", [{'501'}]),
        {keep_state, Data, [postpone]}
    end;
s15(cast, {_SPid, {'354'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s15]: Purging stale event ~p~n", [{'354'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s15]: Postponing event ~p~n", [{'354'}]),
        {keep_state, Data, [postpone]}
    end;
s15(cast, {_SPid, {'221'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s15]: Purging stale event ~p~n", [{'221'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s15]: Postponing event ~p~n", [{'221'}]),
        {keep_state, Data, [postpone]}
    end;
s15(cast, {_SPid, {'Ack'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s15]: Purging stale event ~p~n", [{'Ack'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s15]: Postponing event ~p~n", [{'Ack'}]),
        {keep_state, Data, [postpone]}
    end;
s15(cast, {_SPid, {'AckCommit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s15]: Purging stale event ~p~n", [{'AckCommit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s15]: Postponing event ~p~n", [{'AckCommit'}]),
        {keep_state, Data, [postpone]}
    end.

-spec s19(internal, {'Auth'} | {'Quit'}, state_data()) -> {next_state, s20, state_data()} | {next_state, s20, state_data(), [{next_event, internal, {'Auth'}}] } | {next_state, s20, state_data(), [{next_event, internal, {'Quit'}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s19(internal, {'Auth'}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s19(internal, {'Auth'}, Data),
        Next;
s19(internal, {'Quit'}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s19(internal, {'Quit'}, Data),
        Next;
s19(cast, {_SPid, {'220'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s19]: Purging stale event ~p~n", [{'220'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s19]: Postponing event ~p~n", [{'220'}]),
        {keep_state, Data, [postpone]}
    end;
s19(cast, {_SPid, {'Timeout'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s19]: Purging stale event ~p~n", [{'Timeout'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s19]: Postponing event ~p~n", [{'Timeout'}]),
        {keep_state, Data, [postpone]}
    end;
s19(cast, {_SPid, {'EhloCommit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s19]: Purging stale event ~p~n", [{'EhloCommit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s19]: Postponing event ~p~n", [{'EhloCommit'}]),
        {keep_state, Data, [postpone]}
    end;
s19(cast, {_SPid, {'250d'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s19]: Purging stale event ~p~n", [{'250d'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s19]: Postponing event ~p~n", [{'250d'}]),
        {keep_state, Data, [postpone]}
    end;
s19(cast, {_SPid, {'250'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s19]: Purging stale event ~p~n", [{'250'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s19]: Postponing event ~p~n", [{'250'}]),
        {keep_state, Data, [postpone]}
    end;
s19(cast, {_SPid, {'235'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s19]: Purging stale event ~p~n", [{'235'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s19]: Postponing event ~p~n", [{'235'}]),
        {keep_state, Data, [postpone]}
    end;
s19(cast, {_SPid, {'535'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s19]: Purging stale event ~p~n", [{'535'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s19]: Postponing event ~p~n", [{'535'}]),
        {keep_state, Data, [postpone]}
    end;
s19(cast, {_SPid, {'501'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s19]: Purging stale event ~p~n", [{'501'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s19]: Postponing event ~p~n", [{'501'}]),
        {keep_state, Data, [postpone]}
    end;
s19(cast, {_SPid, {'354'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s19]: Purging stale event ~p~n", [{'354'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s19]: Postponing event ~p~n", [{'354'}]),
        {keep_state, Data, [postpone]}
    end;
s19(cast, {_SPid, {'221'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s19]: Purging stale event ~p~n", [{'221'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s19]: Postponing event ~p~n", [{'221'}]),
        {keep_state, Data, [postpone]}
    end;
s19(cast, {_SPid, {'Ack'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s19]: Purging stale event ~p~n", [{'Ack'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s19]: Postponing event ~p~n", [{'Ack'}]),
        {keep_state, Data, [postpone]}
    end;
s19(cast, {_SPid, {'AckCommit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s19]: Purging stale event ~p~n", [{'AckCommit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s19]: Postponing event ~p~n", [{'AckCommit'}]),
        {keep_state, Data, [postpone]}
    end.

-spec s20(cast, {pid(), {'235'}, list()} | {pid(), {'535'}, list()}, state_data()) -> {next_state, s22, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
s20(cast, {SPid, {'235'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s20]: Purging stale event ~p~n", [{'235'}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s20(cast, {SPid, {'235'}}, Data)
               catch error:function_clause ->
                 io:format("gen_c[s20]: Callback had no clause for ~p, postponing~n", [{'235'}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> Next
        end
    end;
s20(cast, {SPid, {'535'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s20]: Purging stale event ~p~n", [{'535'}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s20(cast, {SPid, {'535'}}, Data)
               catch error:function_clause ->
                 io:format("gen_c[s20]: Callback had no clause for ~p, postponing~n", [{'535'}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> Next
        end
    end;
s20(cast, {_SPid, {'220'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s20]: Purging stale event ~p~n", [{'220'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s20]: Postponing event ~p~n", [{'220'}]),
        {keep_state, Data, [postpone]}
    end;
s20(cast, {_SPid, {'Timeout'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s20]: Purging stale event ~p~n", [{'Timeout'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s20]: Postponing event ~p~n", [{'Timeout'}]),
        {keep_state, Data, [postpone]}
    end;
s20(cast, {_SPid, {'EhloCommit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s20]: Purging stale event ~p~n", [{'EhloCommit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s20]: Postponing event ~p~n", [{'EhloCommit'}]),
        {keep_state, Data, [postpone]}
    end;
s20(cast, {_SPid, {'250d'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s20]: Purging stale event ~p~n", [{'250d'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s20]: Postponing event ~p~n", [{'250d'}]),
        {keep_state, Data, [postpone]}
    end;
s20(cast, {_SPid, {'250'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s20]: Purging stale event ~p~n", [{'250'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s20]: Postponing event ~p~n", [{'250'}]),
        {keep_state, Data, [postpone]}
    end;
s20(cast, {_SPid, {'501'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s20]: Purging stale event ~p~n", [{'501'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s20]: Postponing event ~p~n", [{'501'}]),
        {keep_state, Data, [postpone]}
    end;
s20(cast, {_SPid, {'354'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s20]: Purging stale event ~p~n", [{'354'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s20]: Postponing event ~p~n", [{'354'}]),
        {keep_state, Data, [postpone]}
    end;
s20(cast, {_SPid, {'221'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s20]: Purging stale event ~p~n", [{'221'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s20]: Postponing event ~p~n", [{'221'}]),
        {keep_state, Data, [postpone]}
    end;
s20(cast, {_SPid, {'Ack'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s20]: Purging stale event ~p~n", [{'Ack'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s20]: Postponing event ~p~n", [{'Ack'}]),
        {keep_state, Data, [postpone]}
    end;
s20(cast, {_SPid, {'AckCommit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s20]: Purging stale event ~p~n", [{'AckCommit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s20]: Postponing event ~p~n", [{'AckCommit'}]),
        {keep_state, Data, [postpone]}
    end.

-spec s22(internal, {'Mail'} | {'Quit'}, state_data()) -> {next_state, s23, state_data()} | {next_state, s44, state_data()} | {next_state, s23, state_data(), [{next_event, internal, {'Mail'}}] } | {next_state, s23, state_data(), [{next_event, internal, {'Quit'}}] } | {next_state, s44, state_data(), [{next_event, internal, {'Mail'}}] } | {next_state, s44, state_data(), [{next_event, internal, {'Quit'}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s22(internal, {'Mail'}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s22(internal, {'Mail'}, Data),
        Next;
s22(internal, {'Quit'}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s22(internal, {'Quit'}, Data),
        Next;
s22(cast, {_SPid, {'220'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s22]: Purging stale event ~p~n", [{'220'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s22]: Postponing event ~p~n", [{'220'}]),
        {keep_state, Data, [postpone]}
    end;
s22(cast, {_SPid, {'Timeout'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s22]: Purging stale event ~p~n", [{'Timeout'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s22]: Postponing event ~p~n", [{'Timeout'}]),
        {keep_state, Data, [postpone]}
    end;
s22(cast, {_SPid, {'EhloCommit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s22]: Purging stale event ~p~n", [{'EhloCommit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s22]: Postponing event ~p~n", [{'EhloCommit'}]),
        {keep_state, Data, [postpone]}
    end;
s22(cast, {_SPid, {'250d'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s22]: Purging stale event ~p~n", [{'250d'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s22]: Postponing event ~p~n", [{'250d'}]),
        {keep_state, Data, [postpone]}
    end;
s22(cast, {_SPid, {'250'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s22]: Purging stale event ~p~n", [{'250'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s22]: Postponing event ~p~n", [{'250'}]),
        {keep_state, Data, [postpone]}
    end;
s22(cast, {_SPid, {'235'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s22]: Purging stale event ~p~n", [{'235'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s22]: Postponing event ~p~n", [{'235'}]),
        {keep_state, Data, [postpone]}
    end;
s22(cast, {_SPid, {'535'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s22]: Purging stale event ~p~n", [{'535'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s22]: Postponing event ~p~n", [{'535'}]),
        {keep_state, Data, [postpone]}
    end;
s22(cast, {_SPid, {'501'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s22]: Purging stale event ~p~n", [{'501'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s22]: Postponing event ~p~n", [{'501'}]),
        {keep_state, Data, [postpone]}
    end;
s22(cast, {_SPid, {'354'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s22]: Purging stale event ~p~n", [{'354'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s22]: Postponing event ~p~n", [{'354'}]),
        {keep_state, Data, [postpone]}
    end;
s22(cast, {_SPid, {'221'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s22]: Purging stale event ~p~n", [{'221'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s22]: Postponing event ~p~n", [{'221'}]),
        {keep_state, Data, [postpone]}
    end;
s22(cast, {_SPid, {'Ack'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s22]: Purging stale event ~p~n", [{'Ack'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s22]: Postponing event ~p~n", [{'Ack'}]),
        {keep_state, Data, [postpone]}
    end;
s22(cast, {_SPid, {'AckCommit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s22]: Purging stale event ~p~n", [{'AckCommit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s22]: Postponing event ~p~n", [{'AckCommit'}]),
        {keep_state, Data, [postpone]}
    end.

-spec s23(cast, {pid(), {'250'}, list()} | {pid(), {'501'}, list()}, state_data()) -> {next_state, s27, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
s23(cast, {SPid, {'250'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s23]: Purging stale event ~p~n", [{'250'}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s23(cast, {SPid, {'250'}}, Data)
               catch error:function_clause ->
                 io:format("gen_c[s23]: Callback had no clause for ~p, postponing~n", [{'250'}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> Next
        end
    end;
s23(cast, {SPid, {'501'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s23]: Purging stale event ~p~n", [{'501'}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s23(cast, {SPid, {'501'}}, Data)
               catch error:function_clause ->
                 io:format("gen_c[s23]: Callback had no clause for ~p, postponing~n", [{'501'}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> Next
        end
    end;
s23(cast, {_SPid, {'220'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s23]: Purging stale event ~p~n", [{'220'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s23]: Postponing event ~p~n", [{'220'}]),
        {keep_state, Data, [postpone]}
    end;
s23(cast, {_SPid, {'Timeout'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s23]: Purging stale event ~p~n", [{'Timeout'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s23]: Postponing event ~p~n", [{'Timeout'}]),
        {keep_state, Data, [postpone]}
    end;
s23(cast, {_SPid, {'EhloCommit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s23]: Purging stale event ~p~n", [{'EhloCommit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s23]: Postponing event ~p~n", [{'EhloCommit'}]),
        {keep_state, Data, [postpone]}
    end;
s23(cast, {_SPid, {'250d'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s23]: Purging stale event ~p~n", [{'250d'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s23]: Postponing event ~p~n", [{'250d'}]),
        {keep_state, Data, [postpone]}
    end;
s23(cast, {_SPid, {'235'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s23]: Purging stale event ~p~n", [{'235'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s23]: Postponing event ~p~n", [{'235'}]),
        {keep_state, Data, [postpone]}
    end;
s23(cast, {_SPid, {'535'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s23]: Purging stale event ~p~n", [{'535'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s23]: Postponing event ~p~n", [{'535'}]),
        {keep_state, Data, [postpone]}
    end;
s23(cast, {_SPid, {'354'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s23]: Purging stale event ~p~n", [{'354'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s23]: Postponing event ~p~n", [{'354'}]),
        {keep_state, Data, [postpone]}
    end;
s23(cast, {_SPid, {'221'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s23]: Purging stale event ~p~n", [{'221'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s23]: Postponing event ~p~n", [{'221'}]),
        {keep_state, Data, [postpone]}
    end;
s23(cast, {_SPid, {'Ack'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s23]: Purging stale event ~p~n", [{'Ack'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s23]: Postponing event ~p~n", [{'Ack'}]),
        {keep_state, Data, [postpone]}
    end;
s23(cast, {_SPid, {'AckCommit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s23]: Purging stale event ~p~n", [{'AckCommit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s23]: Postponing event ~p~n", [{'AckCommit'}]),
        {keep_state, Data, [postpone]}
    end.

-spec s27(internal, {'Bogus'} | {'Rcpt'}, state_data()) -> {next_state, s28, state_data()} | {next_state, s33, state_data()} | {next_state, s28, state_data(), [{next_event, internal, {'Bogus'}}] } | {next_state, s28, state_data(), [{next_event, internal, {'Rcpt'}}] } | {next_state, s33, state_data(), [{next_event, internal, {'Bogus'}}] } | {next_state, s33, state_data(), [{next_event, internal, {'Rcpt'}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s27(internal, {'Rcpt'}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s27(internal, {'Rcpt'}, Data),
        Next;
s27(internal, {'Bogus'}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s27(internal, {'Bogus'}, Data),
        Next;
s27(cast, {_SPid, {'220'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s27]: Purging stale event ~p~n", [{'220'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s27]: Postponing event ~p~n", [{'220'}]),
        {keep_state, Data, [postpone]}
    end;
s27(cast, {_SPid, {'Timeout'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s27]: Purging stale event ~p~n", [{'Timeout'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s27]: Postponing event ~p~n", [{'Timeout'}]),
        {keep_state, Data, [postpone]}
    end;
s27(cast, {_SPid, {'EhloCommit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s27]: Purging stale event ~p~n", [{'EhloCommit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s27]: Postponing event ~p~n", [{'EhloCommit'}]),
        {keep_state, Data, [postpone]}
    end;
s27(cast, {_SPid, {'250d'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s27]: Purging stale event ~p~n", [{'250d'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s27]: Postponing event ~p~n", [{'250d'}]),
        {keep_state, Data, [postpone]}
    end;
s27(cast, {_SPid, {'250'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s27]: Purging stale event ~p~n", [{'250'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s27]: Postponing event ~p~n", [{'250'}]),
        {keep_state, Data, [postpone]}
    end;
s27(cast, {_SPid, {'235'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s27]: Purging stale event ~p~n", [{'235'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s27]: Postponing event ~p~n", [{'235'}]),
        {keep_state, Data, [postpone]}
    end;
s27(cast, {_SPid, {'535'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s27]: Purging stale event ~p~n", [{'535'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s27]: Postponing event ~p~n", [{'535'}]),
        {keep_state, Data, [postpone]}
    end;
s27(cast, {_SPid, {'501'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s27]: Purging stale event ~p~n", [{'501'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s27]: Postponing event ~p~n", [{'501'}]),
        {keep_state, Data, [postpone]}
    end;
s27(cast, {_SPid, {'354'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s27]: Purging stale event ~p~n", [{'354'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s27]: Postponing event ~p~n", [{'354'}]),
        {keep_state, Data, [postpone]}
    end;
s27(cast, {_SPid, {'221'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s27]: Purging stale event ~p~n", [{'221'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s27]: Postponing event ~p~n", [{'221'}]),
        {keep_state, Data, [postpone]}
    end;
s27(cast, {_SPid, {'Ack'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s27]: Purging stale event ~p~n", [{'Ack'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s27]: Postponing event ~p~n", [{'Ack'}]),
        {keep_state, Data, [postpone]}
    end;
s27(cast, {_SPid, {'AckCommit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s27]: Purging stale event ~p~n", [{'AckCommit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s27]: Postponing event ~p~n", [{'AckCommit'}]),
        {keep_state, Data, [postpone]}
    end.

-spec s28(cast, {pid(), {'250'}, list()}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
s28(cast, {SPid, {'250'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s28]: Purging stale event ~p~n", [{'250'}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s28(cast, {SPid, {'250'}}, Data)
               catch error:function_clause ->
                 io:format("gen_c[s28]: Callback had no clause for ~p, postponing~n", [{'250'}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> Next
        end
    end;
s28(cast, {_SPid, {'220'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s28]: Purging stale event ~p~n", [{'220'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s28]: Postponing event ~p~n", [{'220'}]),
        {keep_state, Data, [postpone]}
    end;
s28(cast, {_SPid, {'Timeout'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s28]: Purging stale event ~p~n", [{'Timeout'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s28]: Postponing event ~p~n", [{'Timeout'}]),
        {keep_state, Data, [postpone]}
    end;
s28(cast, {_SPid, {'EhloCommit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s28]: Purging stale event ~p~n", [{'EhloCommit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s28]: Postponing event ~p~n", [{'EhloCommit'}]),
        {keep_state, Data, [postpone]}
    end;
s28(cast, {_SPid, {'250d'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s28]: Purging stale event ~p~n", [{'250d'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s28]: Postponing event ~p~n", [{'250d'}]),
        {keep_state, Data, [postpone]}
    end;
s28(cast, {_SPid, {'235'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s28]: Purging stale event ~p~n", [{'235'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s28]: Postponing event ~p~n", [{'235'}]),
        {keep_state, Data, [postpone]}
    end;
s28(cast, {_SPid, {'535'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s28]: Purging stale event ~p~n", [{'535'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s28]: Postponing event ~p~n", [{'535'}]),
        {keep_state, Data, [postpone]}
    end;
s28(cast, {_SPid, {'501'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s28]: Purging stale event ~p~n", [{'501'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s28]: Postponing event ~p~n", [{'501'}]),
        {keep_state, Data, [postpone]}
    end;
s28(cast, {_SPid, {'354'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s28]: Purging stale event ~p~n", [{'354'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s28]: Postponing event ~p~n", [{'354'}]),
        {keep_state, Data, [postpone]}
    end;
s28(cast, {_SPid, {'221'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s28]: Purging stale event ~p~n", [{'221'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s28]: Postponing event ~p~n", [{'221'}]),
        {keep_state, Data, [postpone]}
    end;
s28(cast, {_SPid, {'Ack'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s28]: Purging stale event ~p~n", [{'Ack'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s28]: Postponing event ~p~n", [{'Ack'}]),
        {keep_state, Data, [postpone]}
    end;
s28(cast, {_SPid, {'AckCommit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s28]: Purging stale event ~p~n", [{'AckCommit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s28]: Postponing event ~p~n", [{'AckCommit'}]),
        {keep_state, Data, [postpone]}
    end.

%% Mixed-choice entry state
-spec s33(internal | cast, {'Data'} | {pid(), {'Timeout'}, list()}, state_data()) -> {next_state, s34, state_data()} | {next_state, s34, state_data(), [{next_event, internal, {'Data'}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s33(internal, {'Data'}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s33(internal, {'Data'}, Data),
        Next;
s33(cast, {SPid, {'Timeout'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s33]: Purging stale event ~p~n", [{'Timeout'}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s33(cast, {SPid, {'Timeout'}}, Data)
               catch error:function_clause ->
                 io:format("gen_c[s33]: Callback had no clause for ~p, postponing~n", [{'Timeout'}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          {next_state, s34, _} -> commit_entry(mc2, right), Next;
          {next_state, s34, _, _} -> commit_entry(mc2, right), Next;
          {next_state, s2, _} -> commit_entry(mc2, left), Next;
          {next_state, s2, _, _} -> commit_entry(mc2, left), Next;
          _ -> Next
        end
    end;
s33(cast, {_SPid, {'220'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s33]: Purging stale event ~p~n", [{'220'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s33]: Postponing event ~p~n", [{'220'}]),
        {keep_state, Data, [postpone]}
    end;
s33(cast, {_SPid, {'EhloCommit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s33]: Purging stale event ~p~n", [{'EhloCommit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s33]: Postponing event ~p~n", [{'EhloCommit'}]),
        {keep_state, Data, [postpone]}
    end;
s33(cast, {_SPid, {'250d'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s33]: Purging stale event ~p~n", [{'250d'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s33]: Postponing event ~p~n", [{'250d'}]),
        {keep_state, Data, [postpone]}
    end;
s33(cast, {_SPid, {'250'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s33]: Purging stale event ~p~n", [{'250'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s33]: Postponing event ~p~n", [{'250'}]),
        {keep_state, Data, [postpone]}
    end;
s33(cast, {_SPid, {'235'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s33]: Purging stale event ~p~n", [{'235'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s33]: Postponing event ~p~n", [{'235'}]),
        {keep_state, Data, [postpone]}
    end;
s33(cast, {_SPid, {'535'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s33]: Purging stale event ~p~n", [{'535'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s33]: Postponing event ~p~n", [{'535'}]),
        {keep_state, Data, [postpone]}
    end;
s33(cast, {_SPid, {'501'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s33]: Purging stale event ~p~n", [{'501'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s33]: Postponing event ~p~n", [{'501'}]),
        {keep_state, Data, [postpone]}
    end;
s33(cast, {_SPid, {'354'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s33]: Purging stale event ~p~n", [{'354'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s33]: Postponing event ~p~n", [{'354'}]),
        {keep_state, Data, [postpone]}
    end;
s33(cast, {_SPid, {'221'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s33]: Purging stale event ~p~n", [{'221'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s33]: Postponing event ~p~n", [{'221'}]),
        {keep_state, Data, [postpone]}
    end;
s33(cast, {_SPid, {'Ack'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s33]: Purging stale event ~p~n", [{'Ack'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s33]: Postponing event ~p~n", [{'Ack'}]),
        {keep_state, Data, [postpone]}
    end;
s33(cast, {_SPid, {'AckCommit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s33]: Purging stale event ~p~n", [{'AckCommit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s33]: Postponing event ~p~n", [{'AckCommit'}]),
        {keep_state, Data, [postpone]}
    end.

-spec s34(cast, {pid(), {'Timeout'}, list()} | {pid(), {'354'}, list()}, state_data()) -> {next_state, s36, state_data()} | {keep_state, state_data()} | {stop, normal, state_data()}.
s34(cast, {SPid, {'354'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s34]: Purging stale event ~p~n", [{'354'}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s34(cast, {SPid, {'354'}}, Data)
               catch error:function_clause ->
                 io:format("gen_c[s34]: Callback had no clause for ~p, postponing~n", [{'354'}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> Next
        end
    end;
s34(cast, {SPid, {'Timeout'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s34]: Purging stale event ~p~n", [{'Timeout'}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s34(cast, {SPid, {'Timeout'}}, Data)
               catch error:function_clause ->
                 io:format("gen_c[s34]: Callback had no clause for ~p, postponing~n", [{'Timeout'}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> Next
        end
    end;
s34(cast, {_SPid, {'220'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s34]: Purging stale event ~p~n", [{'220'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s34]: Postponing event ~p~n", [{'220'}]),
        {keep_state, Data, [postpone]}
    end;
s34(cast, {_SPid, {'EhloCommit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s34]: Purging stale event ~p~n", [{'EhloCommit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s34]: Postponing event ~p~n", [{'EhloCommit'}]),
        {keep_state, Data, [postpone]}
    end;
s34(cast, {_SPid, {'250d'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s34]: Purging stale event ~p~n", [{'250d'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s34]: Postponing event ~p~n", [{'250d'}]),
        {keep_state, Data, [postpone]}
    end;
s34(cast, {_SPid, {'250'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s34]: Purging stale event ~p~n", [{'250'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s34]: Postponing event ~p~n", [{'250'}]),
        {keep_state, Data, [postpone]}
    end;
s34(cast, {_SPid, {'235'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s34]: Purging stale event ~p~n", [{'235'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s34]: Postponing event ~p~n", [{'235'}]),
        {keep_state, Data, [postpone]}
    end;
s34(cast, {_SPid, {'535'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s34]: Purging stale event ~p~n", [{'535'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s34]: Postponing event ~p~n", [{'535'}]),
        {keep_state, Data, [postpone]}
    end;
s34(cast, {_SPid, {'501'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s34]: Purging stale event ~p~n", [{'501'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s34]: Postponing event ~p~n", [{'501'}]),
        {keep_state, Data, [postpone]}
    end;
s34(cast, {_SPid, {'221'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s34]: Purging stale event ~p~n", [{'221'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s34]: Postponing event ~p~n", [{'221'}]),
        {keep_state, Data, [postpone]}
    end;
s34(cast, {_SPid, {'Ack'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s34]: Purging stale event ~p~n", [{'Ack'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s34]: Postponing event ~p~n", [{'Ack'}]),
        {keep_state, Data, [postpone]}
    end;
s34(cast, {_SPid, {'AckCommit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s34]: Purging stale event ~p~n", [{'AckCommit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s34]: Postponing event ~p~n", [{'AckCommit'}]),
        {keep_state, Data, [postpone]}
    end.

-spec s36(internal, {'DataLine'} | {'EndOfData'} | {'Subject'}, state_data()) -> {next_state, s41, state_data()} | {next_state, s41, state_data(), [{next_event, internal, {'DataLine'}}] } | {next_state, s41, state_data(), [{next_event, internal, {'EndOfData'}}] } | {next_state, s41, state_data(), [{next_event, internal, {'Subject'}}] } | {keep_state, state_data()} | {stop, normal, state_data()}.
s36(internal, {'EndOfData'}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s36(internal, {'EndOfData'}, Data),
        Next;
s36(internal, {'DataLine'}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s36(internal, {'DataLine'}, Data),
        Next;
s36(internal, {'Subject'}, Data) ->
    CallbackModule = get(callback_module),
    Next = CallbackModule:s36(internal, {'Subject'}, Data),
        Next;
s36(cast, {_SPid, {'220'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s36]: Purging stale event ~p~n", [{'220'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s36]: Postponing event ~p~n", [{'220'}]),
        {keep_state, Data, [postpone]}
    end;
s36(cast, {_SPid, {'Timeout'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s36]: Purging stale event ~p~n", [{'Timeout'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s36]: Postponing event ~p~n", [{'Timeout'}]),
        {keep_state, Data, [postpone]}
    end;
s36(cast, {_SPid, {'EhloCommit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s36]: Purging stale event ~p~n", [{'EhloCommit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s36]: Postponing event ~p~n", [{'EhloCommit'}]),
        {keep_state, Data, [postpone]}
    end;
s36(cast, {_SPid, {'250d'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s36]: Purging stale event ~p~n", [{'250d'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s36]: Postponing event ~p~n", [{'250d'}]),
        {keep_state, Data, [postpone]}
    end;
s36(cast, {_SPid, {'250'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s36]: Purging stale event ~p~n", [{'250'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s36]: Postponing event ~p~n", [{'250'}]),
        {keep_state, Data, [postpone]}
    end;
s36(cast, {_SPid, {'235'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s36]: Purging stale event ~p~n", [{'235'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s36]: Postponing event ~p~n", [{'235'}]),
        {keep_state, Data, [postpone]}
    end;
s36(cast, {_SPid, {'535'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s36]: Purging stale event ~p~n", [{'535'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s36]: Postponing event ~p~n", [{'535'}]),
        {keep_state, Data, [postpone]}
    end;
s36(cast, {_SPid, {'501'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s36]: Purging stale event ~p~n", [{'501'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s36]: Postponing event ~p~n", [{'501'}]),
        {keep_state, Data, [postpone]}
    end;
s36(cast, {_SPid, {'354'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s36]: Purging stale event ~p~n", [{'354'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s36]: Postponing event ~p~n", [{'354'}]),
        {keep_state, Data, [postpone]}
    end;
s36(cast, {_SPid, {'221'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s36]: Purging stale event ~p~n", [{'221'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s36]: Postponing event ~p~n", [{'221'}]),
        {keep_state, Data, [postpone]}
    end;
s36(cast, {_SPid, {'Ack'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s36]: Purging stale event ~p~n", [{'Ack'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s36]: Postponing event ~p~n", [{'Ack'}]),
        {keep_state, Data, [postpone]}
    end;
s36(cast, {_SPid, {'AckCommit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s36]: Purging stale event ~p~n", [{'AckCommit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s36]: Postponing event ~p~n", [{'AckCommit'}]),
        {keep_state, Data, [postpone]}
    end.

-spec s41(cast, {pid(), {'250'}, list()}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
s41(cast, {SPid, {'250'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s41]: Purging stale event ~p~n", [{'250'}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s41(cast, {SPid, {'250'}}, Data)
               catch error:function_clause ->
                 io:format("gen_c[s41]: Callback had no clause for ~p, postponing~n", [{'250'}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> Next
        end
    end;
s41(cast, {_SPid, {'220'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s41]: Purging stale event ~p~n", [{'220'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s41]: Postponing event ~p~n", [{'220'}]),
        {keep_state, Data, [postpone]}
    end;
s41(cast, {_SPid, {'Timeout'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s41]: Purging stale event ~p~n", [{'Timeout'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s41]: Postponing event ~p~n", [{'Timeout'}]),
        {keep_state, Data, [postpone]}
    end;
s41(cast, {_SPid, {'EhloCommit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s41]: Purging stale event ~p~n", [{'EhloCommit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s41]: Postponing event ~p~n", [{'EhloCommit'}]),
        {keep_state, Data, [postpone]}
    end;
s41(cast, {_SPid, {'250d'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s41]: Purging stale event ~p~n", [{'250d'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s41]: Postponing event ~p~n", [{'250d'}]),
        {keep_state, Data, [postpone]}
    end;
s41(cast, {_SPid, {'235'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s41]: Purging stale event ~p~n", [{'235'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s41]: Postponing event ~p~n", [{'235'}]),
        {keep_state, Data, [postpone]}
    end;
s41(cast, {_SPid, {'535'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s41]: Purging stale event ~p~n", [{'535'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s41]: Postponing event ~p~n", [{'535'}]),
        {keep_state, Data, [postpone]}
    end;
s41(cast, {_SPid, {'501'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s41]: Purging stale event ~p~n", [{'501'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s41]: Postponing event ~p~n", [{'501'}]),
        {keep_state, Data, [postpone]}
    end;
s41(cast, {_SPid, {'354'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s41]: Purging stale event ~p~n", [{'354'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s41]: Postponing event ~p~n", [{'354'}]),
        {keep_state, Data, [postpone]}
    end;
s41(cast, {_SPid, {'221'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s41]: Purging stale event ~p~n", [{'221'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s41]: Postponing event ~p~n", [{'221'}]),
        {keep_state, Data, [postpone]}
    end;
s41(cast, {_SPid, {'Ack'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s41]: Purging stale event ~p~n", [{'Ack'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s41]: Postponing event ~p~n", [{'Ack'}]),
        {keep_state, Data, [postpone]}
    end;
s41(cast, {_SPid, {'AckCommit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s41]: Purging stale event ~p~n", [{'AckCommit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s41]: Postponing event ~p~n", [{'AckCommit'}]),
        {keep_state, Data, [postpone]}
    end.

-spec s44(cast, {pid(), {'221'}, list()}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
s44(cast, {SPid, {'221'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s44]: Purging stale event ~p~n", [{'221'}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s44(cast, {SPid, {'221'}}, Data)
               catch error:function_clause ->
                 io:format("gen_c[s44]: Callback had no clause for ~p, postponing~n", [{'221'}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> Next
        end
    end;
s44(cast, {_SPid, {'220'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s44]: Purging stale event ~p~n", [{'220'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s44]: Postponing event ~p~n", [{'220'}]),
        {keep_state, Data, [postpone]}
    end;
s44(cast, {_SPid, {'Timeout'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s44]: Purging stale event ~p~n", [{'Timeout'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s44]: Postponing event ~p~n", [{'Timeout'}]),
        {keep_state, Data, [postpone]}
    end;
s44(cast, {_SPid, {'EhloCommit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s44]: Purging stale event ~p~n", [{'EhloCommit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s44]: Postponing event ~p~n", [{'EhloCommit'}]),
        {keep_state, Data, [postpone]}
    end;
s44(cast, {_SPid, {'250d'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s44]: Purging stale event ~p~n", [{'250d'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s44]: Postponing event ~p~n", [{'250d'}]),
        {keep_state, Data, [postpone]}
    end;
s44(cast, {_SPid, {'250'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s44]: Purging stale event ~p~n", [{'250'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s44]: Postponing event ~p~n", [{'250'}]),
        {keep_state, Data, [postpone]}
    end;
s44(cast, {_SPid, {'235'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s44]: Purging stale event ~p~n", [{'235'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s44]: Postponing event ~p~n", [{'235'}]),
        {keep_state, Data, [postpone]}
    end;
s44(cast, {_SPid, {'535'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s44]: Purging stale event ~p~n", [{'535'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s44]: Postponing event ~p~n", [{'535'}]),
        {keep_state, Data, [postpone]}
    end;
s44(cast, {_SPid, {'501'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s44]: Purging stale event ~p~n", [{'501'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s44]: Postponing event ~p~n", [{'501'}]),
        {keep_state, Data, [postpone]}
    end;
s44(cast, {_SPid, {'354'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s44]: Purging stale event ~p~n", [{'354'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s44]: Postponing event ~p~n", [{'354'}]),
        {keep_state, Data, [postpone]}
    end;
s44(cast, {_SPid, {'Ack'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s44]: Purging stale event ~p~n", [{'Ack'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s44]: Postponing event ~p~n", [{'Ack'}]),
        {keep_state, Data, [postpone]}
    end;
s44(cast, {_SPid, {'AckCommit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s44]: Purging stale event ~p~n", [{'AckCommit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s44]: Postponing event ~p~n", [{'AckCommit'}]),
        {keep_state, Data, [postpone]}
    end.

-spec s49(cast, {pid(), {'Ack'}, list()}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
s49(cast, {SPid, {'Ack'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s49]: Purging stale event ~p~n", [{'Ack'}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s49(cast, {SPid, {'Ack'}}, Data)
               catch error:function_clause ->
                 io:format("gen_c[s49]: Callback had no clause for ~p, postponing~n", [{'Ack'}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> Next
        end
    end;
s49(cast, {_SPid, {'220'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s49]: Purging stale event ~p~n", [{'220'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s49]: Postponing event ~p~n", [{'220'}]),
        {keep_state, Data, [postpone]}
    end;
s49(cast, {_SPid, {'Timeout'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s49]: Purging stale event ~p~n", [{'Timeout'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s49]: Postponing event ~p~n", [{'Timeout'}]),
        {keep_state, Data, [postpone]}
    end;
s49(cast, {_SPid, {'EhloCommit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s49]: Purging stale event ~p~n", [{'EhloCommit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s49]: Postponing event ~p~n", [{'EhloCommit'}]),
        {keep_state, Data, [postpone]}
    end;
s49(cast, {_SPid, {'250d'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s49]: Purging stale event ~p~n", [{'250d'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s49]: Postponing event ~p~n", [{'250d'}]),
        {keep_state, Data, [postpone]}
    end;
s49(cast, {_SPid, {'250'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s49]: Purging stale event ~p~n", [{'250'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s49]: Postponing event ~p~n", [{'250'}]),
        {keep_state, Data, [postpone]}
    end;
s49(cast, {_SPid, {'235'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s49]: Purging stale event ~p~n", [{'235'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s49]: Postponing event ~p~n", [{'235'}]),
        {keep_state, Data, [postpone]}
    end;
s49(cast, {_SPid, {'535'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s49]: Purging stale event ~p~n", [{'535'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s49]: Postponing event ~p~n", [{'535'}]),
        {keep_state, Data, [postpone]}
    end;
s49(cast, {_SPid, {'501'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s49]: Purging stale event ~p~n", [{'501'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s49]: Postponing event ~p~n", [{'501'}]),
        {keep_state, Data, [postpone]}
    end;
s49(cast, {_SPid, {'354'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s49]: Purging stale event ~p~n", [{'354'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s49]: Postponing event ~p~n", [{'354'}]),
        {keep_state, Data, [postpone]}
    end;
s49(cast, {_SPid, {'221'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s49]: Purging stale event ~p~n", [{'221'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s49]: Postponing event ~p~n", [{'221'}]),
        {keep_state, Data, [postpone]}
    end;
s49(cast, {_SPid, {'AckCommit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s49]: Purging stale event ~p~n", [{'AckCommit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s49]: Postponing event ~p~n", [{'AckCommit'}]),
        {keep_state, Data, [postpone]}
    end.

-spec s51(cast, {pid(), {'Ack'}, list()}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
s51(cast, {SPid, {'Ack'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s51]: Purging stale event ~p~n", [{'Ack'}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s51(cast, {SPid, {'Ack'}}, Data)
               catch error:function_clause ->
                 io:format("gen_c[s51]: Callback had no clause for ~p, postponing~n", [{'Ack'}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> Next
        end
    end;
s51(cast, {_SPid, {'220'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s51]: Purging stale event ~p~n", [{'220'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s51]: Postponing event ~p~n", [{'220'}]),
        {keep_state, Data, [postpone]}
    end;
s51(cast, {_SPid, {'Timeout'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s51]: Purging stale event ~p~n", [{'Timeout'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s51]: Postponing event ~p~n", [{'Timeout'}]),
        {keep_state, Data, [postpone]}
    end;
s51(cast, {_SPid, {'EhloCommit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s51]: Purging stale event ~p~n", [{'EhloCommit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s51]: Postponing event ~p~n", [{'EhloCommit'}]),
        {keep_state, Data, [postpone]}
    end;
s51(cast, {_SPid, {'250d'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s51]: Purging stale event ~p~n", [{'250d'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s51]: Postponing event ~p~n", [{'250d'}]),
        {keep_state, Data, [postpone]}
    end;
s51(cast, {_SPid, {'250'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s51]: Purging stale event ~p~n", [{'250'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s51]: Postponing event ~p~n", [{'250'}]),
        {keep_state, Data, [postpone]}
    end;
s51(cast, {_SPid, {'235'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s51]: Purging stale event ~p~n", [{'235'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s51]: Postponing event ~p~n", [{'235'}]),
        {keep_state, Data, [postpone]}
    end;
s51(cast, {_SPid, {'535'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s51]: Purging stale event ~p~n", [{'535'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s51]: Postponing event ~p~n", [{'535'}]),
        {keep_state, Data, [postpone]}
    end;
s51(cast, {_SPid, {'501'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s51]: Purging stale event ~p~n", [{'501'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s51]: Postponing event ~p~n", [{'501'}]),
        {keep_state, Data, [postpone]}
    end;
s51(cast, {_SPid, {'354'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s51]: Purging stale event ~p~n", [{'354'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s51]: Postponing event ~p~n", [{'354'}]),
        {keep_state, Data, [postpone]}
    end;
s51(cast, {_SPid, {'221'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s51]: Purging stale event ~p~n", [{'221'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s51]: Postponing event ~p~n", [{'221'}]),
        {keep_state, Data, [postpone]}
    end;
s51(cast, {_SPid, {'AckCommit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s51]: Purging stale event ~p~n", [{'AckCommit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s51]: Postponing event ~p~n", [{'AckCommit'}]),
        {keep_state, Data, [postpone]}
    end.

-spec s53(cast, {pid(), {'AckCommit'}, list()} | {pid(), {'Timeout'}, list()}, state_data()) -> {keep_state, state_data()} | {stop, normal, state_data()}.
s53(cast, {SPid, {'AckCommit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s53]: Purging stale event ~p~n", [{'AckCommit'}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s53(cast, {SPid, {'AckCommit'}}, Data)
               catch error:function_clause ->
                 io:format("gen_c[s53]: Callback had no clause for ~p, postponing~n", [{'AckCommit'}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> Next
        end
    end;
s53(cast, {SPid, {'Timeout'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s53]: Purging stale event ~p~n", [{'Timeout'}]),
        {keep_state, Data};
      false ->
        CallbackModule = get(callback_module),
        Next = try CallbackModule:s53(cast, {SPid, {'Timeout'}}, Data)
               catch error:function_clause ->
                 io:format("gen_c[s53]: Callback had no clause for ~p, postponing~n", [{'Timeout'}]),
                 {keep_state, Data, [postpone]}
               end,
        case Next of
          _ -> Next
        end
    end;
s53(cast, {_SPid, {'220'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s53]: Purging stale event ~p~n", [{'220'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s53]: Postponing event ~p~n", [{'220'}]),
        {keep_state, Data, [postpone]}
    end;
s53(cast, {_SPid, {'EhloCommit'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s53]: Purging stale event ~p~n", [{'EhloCommit'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s53]: Postponing event ~p~n", [{'EhloCommit'}]),
        {keep_state, Data, [postpone]}
    end;
s53(cast, {_SPid, {'250d'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s53]: Purging stale event ~p~n", [{'250d'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s53]: Postponing event ~p~n", [{'250d'}]),
        {keep_state, Data, [postpone]}
    end;
s53(cast, {_SPid, {'250'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s53]: Purging stale event ~p~n", [{'250'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s53]: Postponing event ~p~n", [{'250'}]),
        {keep_state, Data, [postpone]}
    end;
s53(cast, {_SPid, {'235'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s53]: Purging stale event ~p~n", [{'235'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s53]: Postponing event ~p~n", [{'235'}]),
        {keep_state, Data, [postpone]}
    end;
s53(cast, {_SPid, {'535'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s53]: Purging stale event ~p~n", [{'535'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s53]: Postponing event ~p~n", [{'535'}]),
        {keep_state, Data, [postpone]}
    end;
s53(cast, {_SPid, {'501'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s53]: Purging stale event ~p~n", [{'501'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s53]: Postponing event ~p~n", [{'501'}]),
        {keep_state, Data, [postpone]}
    end;
s53(cast, {_SPid, {'354'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s53]: Purging stale event ~p~n", [{'354'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s53]: Postponing event ~p~n", [{'354'}]),
        {keep_state, Data, [postpone]}
    end;
s53(cast, {_SPid, {'221'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s53]: Purging stale event ~p~n", [{'221'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s53]: Postponing event ~p~n", [{'221'}]),
        {keep_state, Data, [postpone]}
    end;
s53(cast, {_SPid, {'Ack'}, Path}, Data) ->
    case stale(Path) of
      true ->
        io:format("gen_c[s53]: Purging stale event ~p~n", [{'Ack'}]),
        {keep_state, Data};
      false ->
        io:format("gen_c[s53]: Postponing event ~p~n", [{'Ack'}]),
        {keep_state, Data, [postpone]}
    end.


%% ---------- Send helpers----------

-spec send_s5_Ehlo(SPid :: pid(), _Data :: state_data()) -> ok.
send_s5_Ehlo(SPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(SPid, {self(), {'Ehlo'}, Path}).


-spec send_s5_QuitCommit(SPid :: pid(), _Data :: state_data()) -> ok.
send_s5_QuitCommit(SPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(SPid, {self(), {'QuitCommit'}, Path}).


-spec send_s11_StartTls(SPid :: pid(), _Data :: state_data()) -> ok.
send_s11_StartTls(SPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(SPid, {self(), {'StartTls'}, Path}).


-spec send_s11_Quit(SPid :: pid(), _Data :: state_data()) -> ok.
send_s11_Quit(SPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(SPid, {self(), {'Quit'}, Path}).


-spec send_s13_Ehlo1(SPid :: pid(), _Data :: state_data()) -> ok.
send_s13_Ehlo1(SPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(SPid, {self(), {'Ehlo1'}, Path}).


-spec send_s13_Quit(SPid :: pid(), _Data :: state_data()) -> ok.
send_s13_Quit(SPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(SPid, {self(), {'Quit'}, Path}).


-spec send_s19_Auth(SPid :: pid(), _Data :: state_data()) -> ok.
send_s19_Auth(SPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(SPid, {self(), {'Auth'}, Path}).


-spec send_s19_Quit(SPid :: pid(), _Data :: state_data()) -> ok.
send_s19_Quit(SPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(SPid, {self(), {'Quit'}, Path}).


-spec send_s22_Mail(SPid :: pid(), _Data :: state_data()) -> ok.
send_s22_Mail(SPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(SPid, {self(), {'Mail'}, Path}).


-spec send_s22_Quit(SPid :: pid(), _Data :: state_data()) -> ok.
send_s22_Quit(SPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(SPid, {self(), {'Quit'}, Path}).


-spec send_s27_Rcpt(SPid :: pid(), _Data :: state_data()) -> ok.
send_s27_Rcpt(SPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(SPid, {self(), {'Rcpt'}, Path}).


-spec send_s27_Bogus(SPid :: pid(), _Data :: state_data()) -> ok.
send_s27_Bogus(SPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(SPid, {self(), {'Bogus'}, Path}).


-spec send_s33_Data(SPid :: pid(), _Data :: state_data()) -> ok.
send_s33_Data(SPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(SPid, {self(), {'Data'}, Path}).


-spec send_s36_DataLine(SPid :: pid(), _Data :: state_data()) -> ok.
send_s36_DataLine(SPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(SPid, {self(), {'DataLine'}, Path}).


-spec send_s36_Subject(SPid :: pid(), _Data :: state_data()) -> ok.
send_s36_Subject(SPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(SPid, {self(), {'Subject'}, Path}).


-spec send_s36_EndOfData(SPid :: pid(), _Data :: state_data()) -> ok.
send_s36_EndOfData(SPid, _Data) ->
    Path = current_path(),
    gen_statem:cast(SPid, {self(), {'EndOfData'}, Path}).


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

