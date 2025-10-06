-module(turn).

-export([get/0, set/1, reset/0]).

-define(TAB, turn_tab).
-define(KEY, turn).

ensure() ->
  case ets:info(?TAB) of
    undefined -> ets:new(?TAB, [named_table, public, set]), ok;
    _ -> ok
  end.

-spec get() -> boolean().
get() ->
  ensure(),
  case ets:lookup(?TAB, ?KEY) of
    [{?KEY, Val}] when is_boolean(Val) -> Val;
    _ -> false
  end.

-spec set(boolean()) -> ok.
set(Bool) when is_boolean(Bool) ->
  ensure(),
  true = ets:insert(?TAB, {?KEY, Bool}),
  ok.

-spec reset() -> ok.
reset() -> set(false).
